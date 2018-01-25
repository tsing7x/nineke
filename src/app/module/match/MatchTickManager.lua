--
-- Author: hlf
-- Date: 2015-10-30 14:17:22
-- 比赛场门票管理基类

local HallController = import("app.module.hall.HallController")
local MatchTickManager = class("MatchTickManager");
local logger = bm.Logger.new("MatchTickManager");

MatchTickManager.TYPE1 = 1;-- 过期门票弹出框使用门票
MatchTickManager.TYPE2 = 2;-- 个人档门票弹出框使用门票
MatchTickManager.TYPE3 = 3;-- 比赛场大厅点击报名使用门票次数。

MatchTickManager.iconUrl = "matchTick_icon.png"

-- 事件
-- 使用门票
MatchTickManager.EVENT_USE_TICK_MATCH = "USE_TICK_MATCH"
-- 拉取PHP门票数据
MatchTickManager.EVENT_SYNCH_TICK = "Synch_Tick"
-- 
MatchTickManager.EVENT_OPENED_CHOOSEARENAROOMVIEW = "Opened_ChooseArenaRoomView"


--[[
门票数据结构：
{
	uid: 用户ID,
	tid: 门票类型ID,
	num: 数量,
	endtime: 过期时间，0为不过期，其它为时间戳,
	status: 状态，0未使用，1冻结，2已使用，现只会返回未使用的,
	img: 门票图片,
	name: 门票名称,
	level: 可参数的比赛场,
}]]

function MatchTickManager:ctor()
end

function MatchTickManager:getTickDateStr(endtime, isShowTime)
	if endtime == 0 then
		return ""
	end

	local splitStr = "-"
	local timeStr = bm.TimeUtil:getTimeStampString(tonumber(endtime), splitStr);
	local dateArr = string.split(timeStr, "  ")
	local arr = string.split(dateArr[1], splitStr)

	if isShowTime then
		return self:getTickDate(arr[1], arr[2], arr[3]).." "..dateArr[2].." น.";
	else
		return self:getTickDate(arr[1], arr[2], arr[3]);
	end
end

function MatchTickManager:getTickDate(year, month, day)
	local monthStr = bm.LangUtil.getText("TICKET", "MONTHS")[tonumber(month)]
	local yearStr = tostring(tonumber(year) + 543);
	yearStr = string.sub(yearStr,-2)

	return bm.LangUtil.formatString(bm.LangUtil.getText("TICKET", "FORMAT_DATE"), monthStr, day, yearStr)
end

-- 同步PHP门票数据列表
function MatchTickManager:synchPhpTickList(callback)
	bm.HttpService.POST({
			mod = "Match",
			act = "tickets"
		},
		function(data)
			local retJson = json.decode(data or "");
			if retJson and retJson.ret == 0 then
				self:parseData_(retJson)
			end			
		end,
		function()
			-- 异常重新请求
			self:synchPhpTickList(callback)
		end
	);
end

function MatchTickManager:parseData_(retJson)
	self.serverTime_ = retJson.data.time or 0;
    self.clientTime_ = os.time()
	self.tickList_ = {};

	for k,v in pairs(retJson.data.list) do
		item = self:createTickItem_(retJson.data.cdn, v, false);
		table.insert(self.tickList_, #self.tickList_+1, item);
	end

	if retJson.data.expired then
		for k,v in pairs(retJson.data.expired) do
			item = self:createTickItem_(retJson.data.cdn, v, true);
			table.insert(self.tickList_, #self.tickList_+1, item);
		end
		nk.userData.nextExpireTickets = 1;
	end

	-- 派发一个门票同步消息
	bm.EventCenter:dispatchEvent({name=MatchTickManager.EVENT_SYNCH_TICK})
end

-- 获取服务器时间
function MatchTickManager:getServerTime()
	return self.serverTime_ + os.time() - self.clientTime_;
end

-- 判断门票是否快要过期
function MatchTickManager:isNextExpireTickets(serverTime, tickItem)
	local result = false;
	local preTime = tickItem.endtime - nk.userData.nextExpireTickets*3600*24;
	if nk.userData.nextExpireTickets > 0 and tickItem.endtime > serverTime and serverTime > preTime then
		result = true;
	end

	return result;
end

function MatchTickManager:createTickItem_(cdn, v, isExpired)
	local item = {}
	item.tid = v.tid;
	item.num = tonumber(v.num);
	item.endtime = tonumber(v.endtime);
	item.status = tonumber(v.status);
	item.img = cdn..""..v.img.."?ver=1";
	item.name = tostring(v.name);
	item.level = tonumber(v.level);
	item.isOverDate = isExpired;
	return item;
end

-- 使用比赛场门票
function MatchTickManager:applyTick(tickData, callback)
	self.tickData_ = tickData;
	self.callback_ = callback;
	local viewStatus = bm.DataProxy:getData(nk.dataKeys.CURRENT_HALL_VIEW);
	-- 判断场景如果是比赛房间或普通房间拒绝使用门票
	if viewStatus == HallController.CHOOSE_ARENA_VIEW then
		nk.PopupManager:removeAllPopup();
		bm.EventCenter:dispatchEvent({name = MatchTickManager.EVENT_USE_TICK_MATCH, data = tickData})		
	elseif viewStatus == HallController.MAIN_HALL_VIEW then
		nk.PopupManager:removeAllPopup();
		local currentScene = display.getRunningScene()
        if currentScene and currentScene.controller_ and currentScene.controller_.onEnterMatch then
        	-- 添加监听
        	self:addListenerChooseArenaRoow();
            currentScene.controller_:onEnterMatch()
        end
	else
		if callback then
			callback(false);
		end
		-- 显示免费转盘 
		if LuckWheelFreePopupGetTick==true then
			local currentScene = display.getRunningScene()
	        if currentScene and currentScene.controller_ and currentScene.controller_.onEnterMatch then
	        	if nk.userData.level >= nk.userData.arenaLimiteLevel then
			        nk.PopupManager:removeAllPopup();
			    end
	        	
	        	currentScene.controller_.view_ = nil
	        	-- 添加监听
	        	self:addListenerChooseArenaRoow();
	            currentScene.controller_:onEnterMatch()
	        end
		end
	end
end

-- 添加“比赛场大厅加载完成”事件
function MatchTickManager:addListenerChooseArenaRoow()
	self:removeListenerChooseArenaRoow();
	self.onOpenChooseArenaRoomViewId_ = bm.EventCenter:addEventListener(MatchTickManager.EVENT_OPENED_CHOOSEARENAROOMVIEW, handler(self, self.onOpenedChooseArenaRoomViewHandler_))
end

-- 移除“比赛场大厅加载完成”事件
function MatchTickManager:removeListenerChooseArenaRoow()
	if self.onOpenChooseArenaRoomViewId_ then
		bm.EventCenter:removeEventListener(self.onOpenChooseArenaRoomViewId_)
		self.onOpenChooseArenaRoomViewId_ = nil;
	end
end

function MatchTickManager:onOpenedChooseArenaRoomViewHandler_(evt)
	self:removeListenerChooseArenaRoow()
	bm.EventCenter:dispatchEvent({name = MatchTickManager.EVENT_USE_TICK_MATCH, data = self.tickData_})
	if self.callback_ then
		self.callback_(true);
	end
end

-- 获取总计门票数量
function MatchTickManager:getTotalTickNum()
	local num = 0;
	if not self.tickList_ then
		return num;
	end

	for i,v in ipairs(self.tickList_) do
		num = num + v.num;
	end

	return num;
end

-- 获取道具门票数据
function MatchTickManager:getTickToolItem()
	return {
		icon = MatchTickManager.iconUrl,
		label = bm.LangUtil.getText("TICKET", "label"),
		num = self:getTotalTickNum(),
		btnType = 2
	}
end

-- 获取道具门票数据
function MatchTickManager:getAllTickets()
	if not self.tickList_ then
		return {}
	end

	for i,v in ipairs(self.tickList_) do
		v.icon = v.img
		v.label = v.name
		v.btnType = 3
	end
	return self.tickList_
end

-- Server同步门票属性
function MatchTickManager:updateSvData(objData)
	-- {
	-- 	level: {
	-- 		endtime: num,
	-- 		endtime: num
	-- 	},
	-- 	level: {
	-- 		endtime: num,
	-- 		endtime: num
	-- 	},
	-- }
	local ret = false;-- 是否
	for level,itme in pairs(objData) do
        if type(itme) == "table" then
            for endtime,num in pairs(itme) do
                if not self:changeMatchTickNum_(level, endtime, num) then
                	ret = true;
            	end
            end
        end
    end

    if ret then
    	self:synchPhpTickList();
    end
    bm.EventCenter:dispatchEvent("USER_TICKET_CHANGE")
end

function MatchTickManager:test()
	local objData = json.decode('{\"12\":{\"1447520400\":99}}')
	self:updateSvData(objData)
end

-- 更新门票数量
-- matchLevel 可参赛的比赛场matchlevel
-- endtime 门票的过期时间
-- num 同步的门票数量
function MatchTickManager:changeMatchTickNum_(matchLevel, endtime, num)
	for i,v in ipairs(self.tickList_) do
		if tostring(v.level) == tostring(matchLevel) and tostring(v.endtime) == tostring(endtime) then
			v.num = num;

			return true;
		end
	end

	return false;
end

-- 查找匹配的比赛场的门票，返回匹配门票
function MatchTickManager:getTickByMatchLevel(matchLevel)
	if nil == matchLevel or nil == self.tickList_ then
		return nil;
	end

	for i,v in ipairs(self.tickList_) do
		if tostring(matchLevel) == tostring(v.level) and v.num > 0 and not v.isOverDate then
			return v;
		end
	end

	return nil;
end

-- 查找匹配的比赛场的门票，返回匹配门票
function MatchTickManager:getTickById(id)
	for i,v in ipairs(self.tickList_) do
		if id == v.id then
			return v;
		end
	end

	return nil;
end

-- 标记Tick（门票）为使用过
function MatchTickManager:markTickUsedByMatchLevel(matchLevel)
	local tickItem = self:getTickByMatchLevel(matchLevel);
	if tickItem and tickItem.num > 0 then
		return true;
	end

	return false;
end

-- 获取门票列表
function MatchTickManager:getTickData()
	return self.tickList_;
end

-- 获取门票列表
function MatchTickManager:getTickList()
	local list = {}
	local expiredList = {}
	if self.tickList_ then
		for k,v in pairs(self.tickList_) do
			-- 判断是否过去,有效时间大于当前时间标识为有效
			-- isOverDate 为true表示门票过期，
			if v.endtime == 0 or v.endtime > self:getServerTime() then
				v.isOverDate = false;
				v.sortVal = 0
			else
				v.isOverDate = true;
				v.sortVal = v.endtime + 365*3600*24*2;
			end

			if v.num > 0 then
				if v.isOverDate then
					table.insert(expiredList, #expiredList+1, v)
				else
					table.insert(list, #list+1, v)
				end				
			end
		end
	end

	table.insertto(list, expiredList)

	return list;
end

-- 获取有效的门票
function MatchTickManager:getValidTickList()
	local list = {}
	if self.tickList_ then
		for k,v in pairs(self.tickList_) do
			-- 判断是否过去,有效时间大于当前时间标识为有效
			-- isOverDate 为true表示门票过期，
			if v.endtime == 0 or v.endtime > self:getServerTime() then
				v.isOverDate = false;
				v.sortVal = 0
			else
				v.isOverDate = true;
				v.sortVal = v.endtime + 365*3600*24*2;
			end

			if v.num > 0 then
				if not v.isOverDate then
					table.insert(list, #list+1, v)
				end				
			end
		end
	end
	return list;
end

-- 获取无效的门票
function MatchTickManager:getAvalidTickList()
	local expiredList = {}
	if self.tickList_ then
		for k,v in pairs(self.tickList_) do
			-- 判断是否过去,有效时间大于当前时间标识为有效
			-- isOverDate 为true表示门票过期，
			if v.endtime == 0 or v.endtime > self:getServerTime() then
				v.isOverDate = false;
				v.sortVal = 0
			else
				v.isOverDate = true;
				v.sortVal = v.endtime + 365*3600*24*2;
			end

			if v.num > 0 then
				if v.isOverDate then
					table.insert(expiredList, #expiredList+1, v)
				end				
			end
		end
	end

	return expiredList;
end

-- 获取即将过期的门票
function MatchTickManager:getOverdueTickList()
	local list = {}
	if self.tickList_ then
		local serverTime = self:getServerTime();
		local allTickList = self:getTickList();
		for k,v in pairs(allTickList) do
			-- 判断是否过去,有效时间大于当前时间标识为有效
			-- isOverDate 为true表示门票过期，
			if v.num > 0 and not v.isOverDate and self:isNextExpireTickets(serverTime, v) then
				table.insert(list, #list+1, v)
			end
		end
	end

	return list;
end

-- ticketValue为门票面值
function MatchTickManager:createTicketSprite(ticketValue)
	display.addSpriteFrames("upgrade_texture.plist", "upgrade_texture.png")
	local spr = display.newSprite("matchTick_icon_default.png")
	local node, dw, dh = self:getNumBatchNode_(ticketValue)
	local sz = spr:getContentSize();
	node:pos(sz.width*0.5-12, sz.height*0.5+4):addTo(spr)
	node:setScale(0.32)
	node:setSkewX(10)
	local tickSprite = bm.cloneNode(spr, cc.size(sz.width, sz.height), -sz.width*0.0, -sz.height*0.0)
	return tickSprite
end

function MatchTickManager:getNumBatchNode_(val)
	local batchNode = display.newNode()
	local valStr = tostring(val)
	local len = string.len(valStr);
	local dw,dh = 0,0;
	local px;
	for i=1,len do
		local numNode = display.newSprite(self:formatString("#upgrade_{1}.png", string.sub(valStr, i, i))):addTo(batchNode);
		local sz = numNode:getContentSize();
		if nil == px then
			px = -sz.width*(len - 1)*0.5;
		end
		dh = sz.height;
		numNode:pos(px, 0);
		dw = dw + sz.width;
		px = px + sz.width;
	end

	batchNode:setCascadeOpacityEnabled(true);

	return batchNode,dw,dh;
end

function MatchTickManager:formatString(str, ...)
    local numArgs = select("#", ...)
    if numArgs >= 1 then
        local output = str
        for i = 1, numArgs do
            local value = select(i, ...)
            output = string.gsub(output, "{" .. i .. "}", value)
        end
        return output
    else
        return str
    end
end

return MatchTickManager;