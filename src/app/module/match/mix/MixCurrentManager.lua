--
-- Author: hlf
-- Date: 2015-12-08 14:44:18
-- 货币道具转化合成方案
local MixListPopup = import("app.module.match.mix.MixListPopup")
local MixCurrentManager = class("MixCurrentManager")

function MixCurrentManager:ctor()
end

function MixCurrentManager:isOnOfff()
	return nk.userData.isMix == 1 and true or false
end

-- 打开货币道具转化合成界面
function MixCurrentManager:openMixListPopup()
	MixListPopup.new(nil):show(handler(self, self.onCloseMixListPopupCallback_))
	self:onOpenMixListCallback_()
end

function MixCurrentManager:onOpenMixListCallback_()
	self:removeListener()
	self:addListener()
	self:asyncMinxConfig()
end

function MixCurrentManager:addListener()
	self.mixGetReturnId_ = bm.EventCenter:addEventListener("mix_get_return", handler(self, self.callbackOpenMixListPopup_))
end

function MixCurrentManager:removeListener()
	if self.mixGetReturnId_ then
		bm.EventCenter:removeEventListener(self.mixGetReturnId_)
		self.mixGetReturnId_ = nil
	end
end

function MixCurrentManager:callbackOpenMixListPopup_(evt)
	self:removeListener()
	self:onCloseMixListPopupCallback_()
	self:setLoading(false)

	self.mixListSelectItemId_ = bm.EventCenter:addEventListener("Mix_List_Select_Item", handler(self, self.onMixListSelectItemHandler_))
end

function MixCurrentManager:onCloseMixListPopupCallback_()
	if self.mixListSelectItemId_ then
		bm.EventCenter:removeEventListener(self.mixListSelectItemId_)
		self.mixListSelectItemId_ = nil
	end
end

function MixCurrentManager:onMixListSelectItemHandler_(evt)
	local mixData = self:getMixData()
	local dataItem = evt.data

	local doRequest = true
	local msgTxt = nil
	if mixData.leftCnt < 1 and dataItem and dataItem.type~=5 then
		doRequest = false
		msgTxt = bm.LangUtil.getText("MixCurrent", "MIX_NOT_ENOUGH_NUM")
	end
	-- 其他条件
	if doRequest then
		for key,val in pairs(dataItem.from) do
	    	local proVal = dataItem.getUserProValByKey(key)
	    	if proVal < val then
	    		doRequest = false
	    		if key == "chips" then
					msgTxt = bm.LangUtil.formatString(bm.LangUtil.getText("MATCH", "NOTENOUGHCHIPS"))
				elseif key == "gameCoupon" then
					msgTxt = bm.LangUtil.formatString(bm.LangUtil.getText("MATCH", "NOTENOUGHGAMECOUPON"))
				elseif key == "goldCoupon" then
					msgTxt = bm.LangUtil.formatString(bm.LangUtil.getText("MATCH", "NOTENOUGHGOLDCOUPON"))
				elseif key == "score" then
					msgTxt = bm.LangUtil.formatString(bm.LangUtil.getText("WHEEL", "LUCKTURN_NOT_ENOUGH_MONEY"))
				elseif key == "gcoins" then
					msgTxt = bm.LangUtil.formatString(bm.LangUtil.getText("MATCH", "NOTENOUGHGOLDCOIN"))
				elseif key == "tick" then
					msgTxt = ""
					return
				end
	    		break
	    	end
	    end
	end
	if doRequest then
		msgTxt = bm.LangUtil.formatString(bm.LangUtil.getText("MixCurrent", "MIX_DESC_MSG"), dataItem.fromStr, dataItem.toStr)
	end
    nk.ui.Dialog.new({
        messageText = msgTxt,
        hasFirstButton = doRequest,
        closeWhenTouchModel = not doRequest,
        callback = function (type)
            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
            	if doRequest then
	                bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="Wheel_start"})
	                nk.MixCurrentManager:exchange(dataItem.type, dataItem.id, function(retData)
	                	if not retData then
	                		bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="Wheel_end"})
	                	else
	                    	bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="Wheel_end"})
	                	end
	                end)
	            end
            end
        end
    }):show()
end

-- 合成接口
function MixCurrentManager:exchange(itype, id, callback)
	if self.cfgInfo_ and (self.cfgInfo_.leftCnt > 0 or itype==5) then
		self:setLoading(true)
		bm.HttpService.POST({
				mod="Mix",
				act="exchange",
				type=itype,
				id=id,
				new=1
			},
			function(data)
				-- ret: 0, // 非0异常，-1开关关闭，-2参数异常，-3今天次数已用完，-100参数不全，-101配置不存在，-102条件不足，-103扣除条件失败，-104合成道具失败
				local retData = json.decode(data)
				local isSuccss = nil
				if retData.ret == 0 then
					self.cfgInfo_.cur = retData.cur
					self.cfgInfo_.leftCnt = self.cfgInfo_.limit - self.cfgInfo_.cur
					bm.EventCenter:dispatchEvent({name="Mix_Exchange_Success"})
					isSuccss = true
				elseif retData.ret == -1 then
					nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
				elseif retData.ret == -2 then
					nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
				elseif retData.ret == -3 then
					nk.TopTipManager:showTopTip("โอกาสหลอมวันนี้ของท่านใช้หมดแล้ว")
				else
					
				end

				if callback then
					callback(isSuccss)
				end
				self:setLoading(false)
			end,
			function()
				if callback then
					callback(nil)
					self:setLoading(false)
				end
			end
		)
	end
end

-- 获取配置信息
function MixCurrentManager:asyncMinxConfig(callback)
	bm.HttpService.POST({
			mod="Mix",
			act="get",
			new=1
		},
		function(data)
			local retData = json.decode(data)
			if retData and retData.ret == 0 then
				self:parseData_(retData.data)
				self:setLoading(false)
			else
					
			end
			
		end,
		function()
			self:setLoading(false)
			nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
		end
	)
end

-- 解析数据
function MixCurrentManager:parseData_(retData)
	local list = retData.list
	for _,v in pairs(list) do
		v.url = self:getMixUrlByType_(v.type)
		for _,k in pairs(v.list) do
			k.type = v.type
			k.img = nk.userData.cdn..""..k.img
			k.fromNum = 0 -- 合成道具的需要的种类数量
			k.fromStr, k.toStr, k.fromIcons, k.toIcons = self:getItemDesc(retData, k)
			k.desc = k.toStr .. " = " .. k.fromStr
			k.getUserProValByKey = handler(self, self.getUserProValByKey)
		end
	end

	retData.leftCnt = retData.limit - retData.cur
	self.cfgInfo_ = retData
	bm.EventCenter:dispatchEvent({name="mix_get_return"})
end

-- 获取描述信息
function MixCurrentManager:getItemDesc(retData, item)
	local fromLib = {}
	local fromIcons = {}
	for key,val in pairs(item.from) do
		if retData.langs[key] then
			local str = bm.formatBigNumber(val).." "..retData.langs[key]
			table.insert(fromLib, #fromLib+1, str)

			fromIcons[key] = self:getLocationIconUrl_(key)
			item.fromNum = item.fromNum + 1
			item["str"..key] = str
		end
	end

	local toLib = {}
	local toIcons = {}
	for key,val in pairs(item.to) do
		if retData.langs[key] then
			local str = bm.formatBigNumber(val).." "..retData.langs[key]
			table.insert(toLib, #toLib+1, str)

			toIcons[key] = self:getLocationIconUrl_(key)
		end
	end
	
	return table.concat(fromLib, " + "), table.concat(toLib, " + "), fromIcons, toIcons
end

-- 获取用户属性值
function MixCurrentManager:getUserProValByKey(key)
	if key == "chips" then
		return nk.userData.money
	elseif key == "gameCoupon" then
		return nk.userData.gameCoupon
	elseif key == "goldCoupon" then
		return nk.userData.goldCoupon
	elseif key == "score" then
		return nk.userData.score
	elseif key == "gcoins" then
		return nk.userData.gcoins
	else
		return 0
	end
end

-- 获取本地图标URL
function MixCurrentManager:getLocationIconUrl_(key)
	local url
	if key == "chips" then
		url = "match_chip.png"
	elseif key == "gameCoupon" then
		url = "match_gamecoupon.png"
	elseif key == "goldCoupon" then
		url = "match_goldcoupon.png"
	elseif key == "score" then
		url = "match_score.png"
	elseif key == "tick" then
		url = "matchTick_icon.png"
	elseif key == "gcoins" then -- 黄金币
		url = "match_gcoins.png"
	end
	return url
end

-- 根据Mix获取类型图标
function MixCurrentManager:getMixUrlByType_(itype)
	local url
    if itype == 2 then -- 转比赛券
        url = "match_gamecoupon.png"
    elseif itype == 1 then -- 转筹码
        url = "match_chip.png"
    elseif itype == 3 then -- 转现金币
        url = "match_score.png"
    elseif itype == 4 then -- 金币转黄金币
        -- url = "match_goldcoupon.png"
        url = "match_chip.png"
    elseif itype == 5 then -- 比赛券黄金币
        -- url = "matchTick_icon.png"
   		-- url = "match_gcoins.png"
   		url = "match_gamecoupon.png"
    else
    	url = "match_chip.png"
    end
    return url
end

-- 获取合成炉配置信息
function MixCurrentManager:getMixData()
	return self.cfgInfo_
end

function MixCurrentManager:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
        	local runScene = display.getRunningScene()
            self.juhua_ = nk.ui.Juhua.new()
                :pos(display.cx, display.cy)
                :addTo(runScene, 9999, 9999)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

return MixCurrentManager
