--
-- Author: XT
-- Date: 2015-09-10 17:53:03
--
local LuckturnController = class("LuckturnController");

-- 每日转盘抽奖操作
LuckturnController.DailyLuckDraw_Event = "DailyLuckDraw"
-- 普通转盘获取日志事件key
LuckturnController.GetFreeLkWheelRecord_Event = "GetFreeLkWheelRecord_Event"
-- 付费转盘事件key和缓存key
LuckturnController.GetScoreWheelBtnCfg_Event = "GetScoreWheelBtnCfg_Event"
LuckturnController.GetScoreWheelBtnCfg_Cache = "GetScoreWheelBtnCfg_Cache"
-- 每日门票转盘事件key和缓存key
LuckturnController.GetDailyBigWheel_Event = "GetDailyBigWheel_Event"
LuckturnController.GetDailyBigWheel_Cache = "GetDailyBigWheel_Cache"

LuckturnController.GetScoreWheelConfig_Event = "GetScoreWheelConfig_Event"
LuckturnController.GetScoreLkWheelRecord_Event = "GetScoreLkWheelRecord_Event"
LuckturnController.GetSelfWheelRecord_Event = "GetSelfWheelRecord_Event"

LuckturnController.BuyChance_Event = "BuyChance_Event" -- 购买转盘次数

function LuckturnController:ctor(view)
	self.view_ = view;

	self.isTimesReady_ = false
    self.isConfigReady_ = false

    self.otherUserDetailList = {}

    self.selfRecordData = {}
end

function LuckturnController:addSelfRecord(cfgId,data)
	local list = self.selfRecordData[cfgId]
	if list then
		local data1 = clone(data)
		data1.isSelf = true
		table.insert(list, 1, data1)
	end
end

function LuckturnController:playNow(cfgId, callback)
-- 抽奖
-- 返回：{
-- 	ret :  0,  // -1ID有误,-2条件不够,-3抽奖失败
-- 	data : {
-- 		pos :  1,   // 中奖区域，0~7
-- 		name :  200K chips, // 中奖名称
-- 		type :  chips, // 奖品类型
-- 		img :  aa.png // 奖品图片
-- 	}
-- }
	self.playNowId = bm.HttpService.POST( {
            mod = "Match", act = "luckyDraw", id = cfgId
        },
        function(data)
            local retData = json.decode(data)

            if retData and retData.ret == 0 then
                callback(true, retData.data)
            else
            	callback(false, retData)
            end
        end,
        function() callback(false) end
    );
end

function LuckturnController:dispose()
    bm.HttpService.CANCEL(self.playNowId)
    bm.HttpService.CANCEL(self.selfWheelId_)
end

-- 获取抽奖历史记录
function LuckturnController:getBigWheelLog(cfgId, callback)
    self.getBigWheelLogId_ = bm.HttpService.POST( {
            mod = "Match", act = "luckyDrawLog",
            id = cfgId,
            type = 1
        },
        function(data)
            local retData = json.decode(data)
            if retData and retData.ret == 0 then
                callback(retData.data);
            end
        end,
        function() 
            callback(nil, nil);
        end
    );
end

-- 购买邀请码功能
function LuckturnController:buyChance()
	if self.buyChanceId_ then
		return
	end

	self.buyChanceId_ = bm.HttpService.POST({
			mod="LuckyWheel",
			act="buyChance",
		},handler(self, self.callbackBuyChanceHandler_),
		function()
			self.buyChanceId_ = nil
		end)
end

function LuckturnController:callbackBuyChanceHandler_(data)
	local retData = json.decode(data)
	if retData then
		bm.EventCenter:dispatchEvent({name=LuckturnController.BuyChance_Event, data=retData})
	end
	self.buyChanceId_ = nil
end

-- 拉取每日转盘配置信息
function LuckturnController:getDailyBigWheel()
	self:dispatchLocalBigWheelDataList_()

	if self.getBigWheelId_ then
		return
	end

	self.getBigWheelId_ = bm.HttpService.POST({
			mod="Match",
			act="bigwheel",
			id=100
		},handler(self, self.callbackBigWheelHandler_),
		function()
			self.getBigWheelId_ = nil;
		end)
end

function LuckturnController:callbackBigWheelHandler_(data)
	local retData = json.decode(data)
	if retData and retData.ret == 0 and retData.data and retData.data.list then
		local cfg
		local len = #retData.data.list
		local datalist = {}
		for i=1,len do
			cfg = retData.data.list[i]
			cfg.img = retData.data.cdn..cfg.img;
			table.insert(datalist,cfg)
		end

		local isEqual = self:comparseDataList(nk.userData.dailyBigWheelDataList, datalist)
		if isEqual or not nk.userData.dailyBigWheelDataList then
			nk.userData.dailyBigWheelDataList = datalist
			bm.EventCenter:dispatchEvent({name=LuckturnController.GetDailyBigWheel_Event, data=nk.userData.dailyBigWheelDataList})

			local jsonData = json.encode(datalist);
			self:updateUserDefaultData(LuckturnController.GetDailyBigWheel_Cache, jsonData)
		end	
	end
	self.getBigWheelId_ = nil;
end

-- 派发本地数据
function LuckturnController:dispatchLocalBigWheelDataList_()
	-- 判断本地换成是否
	if nk.userData.dailyBigWheelDataList then
		bm.EventCenter:dispatchEvent({name=LuckturnController.GetDailyBigWheel_Event, data=nk.userData.dailyBigWheelDataList})
		return
	end

	local jsonData = self:getUserDefaultData(LuckturnController.GetDailyBigWheel_Cache)
	if jsonData and string.len(jsonData) > 32 then
		local datalist = json.decode(jsonData)
		bm.EventCenter:dispatchEvent({name=LuckturnController.GetDailyBigWheel_Event, data=datalist})
		nk.userData.dailyBigWheelDataList = datalist
	end
end

-- 每日转盘抽奖操作
function LuckturnController:onDailyLuckDraw()
	if self.dailyLuckDrawId_ then
		return;
	end

	local params = {
		mod="Match",
		act="luckyDraw",
		id=100
	}
	self.dailyLuckDrawId_ = bm.HttpService.POST(
		params,
		function(data)
			local retData = json.decode(data);
			if retData then
				if retData.ret == 0 then
					nk.OnOff:saveDailyLuckCount(retData.data.cnt)
					bm.EventCenter:dispatchEvent({name=LuckturnController.DailyLuckDraw_Event, data=retData.data})
				elseif retData.ret == -1 then
					nk.TopTipManager:showTopTip("ID ผิดพลาด") -- ID有误
				elseif retData.ret == -2 then
					nk.TopTipManager:showTopTip("เงื่อนไขไม่พอ") -- 条件不够
				elseif retData.ret == -3 then
					nk.TopTipManager:showTopTip("ลุ้นรางวัลล้มเหลว") -- 抽奖失败
				elseif retData.ret == -4 then
					nk.TopTipManager:showTopTip("เกินจำนวนจำกัด") -- 超过限制次数
					nk.OnOff:saveDailyLuckCount(0)
					bm.EventCenter:dispatchEvent({name=LuckturnController.DailyLuckDraw_Event, data=nil})
				end
			end
			self.dailyLuckDrawId_ = nil;
		end,
		function()
			self.dailyLuckDrawId_ = nil;
		end)
end

-- 获取免费转盘免费次数
function LuckturnController:getPlayTimes(callback)
    self.playTimesId = bm.HttpService.POST(
        {
            mod = "luckyWheel", act = "getFreeTimes"
        },
        function(data)
            local retData = json.decode(data)
            if retData and retData.ret == 0 then
                self.isTimesReady_ = true
                self.freeTimes_ = retData.freeTimes
                callback(true, retData.freeTimes, retData.fbTimes)
            end
        end,
        function()
            self.isTimesReady_ = false
            callback(false)
        end
    )
end

-- 大厅转盘获取免费转盘免费次数
function LuckturnController:getPlayTimes2(callback)
    self.playTimesId = bm.HttpService.POST(
        {
            mod = "ExchangeLuckWheel",
            act = "getFreeTimes",
            uid = nk.userData.uid,
        },
        function(data)
            local retData = json.decode(data)
            if retData and retData.ret == 0 then
                self.isTimesReady_ = true
                self.freeTimes_ = retData.freeTimes
                callback(true, retData.freeTimes, retData.fbTimes)
            end
        end,
        function()
            self.isTimesReady_ = false
            callback(false)
        end
    )
end

function LuckturnController:reportClickTimes(callback)
    self.playTimesId = bm.HttpService.POST(
        {
            mod = "ExchangeLuckWheel",
            act = "reportClick",
            uid = nk.userData.uid,
        },
        function(data)
            local retData = json.decode(data)
            if retData and retData.ret == 0 then
                self.isTimesReady_ = true
                self.freeTimes_ = retData.freeTimes
                callback(true, retData.freeTimes, retData.fbTimes)
            end
        end,
        function()
            self.isTimesReady_ = false
            callback(false)
        end
    )
end

-- 获取免费转盘配置信息
function LuckturnController:getFreeConfig(callback)
	self.freeConfigId_ = bm.HttpService.POST(
        {
            mod = "LuckyWheel", act = "getConfigFile"
        },
        function(data)
            local retData = json.decode(data)
            if retData and retData.ret == 0 and retData.configfile then
            	-- 转化成URL
            	for k,v in pairs(retData.configfile) do
            		v.url = nk.userData.CNDURL.."images/freebigwheel/"..v.url
            	end
                self.isConfigReady_ = true
                local wheelItems_ = retData.configfile
                callback(true, wheelItems_)
                self.wheelItems_ = wheelItems_
            end
        end,
        function()
            self.isConfigReady_ = false
            callback(false)
        end
    )
end

-- 获取大厅转盘配置信息
function LuckturnController:getFreeConfig2(callback)
	self.freeConfigId_ = bm.HttpService.POST(
        {
            mod = "ExchangeLuckWheel",
            act = "getConfigFile",
			uid = nk.userData.uid,
        },
        function(data)        	
            local retData = json.decode(data)
            if retData and retData.ret == 0 and retData.configfile then
            	-- 转化成URL
            	for k,v in pairs(retData.configfile) do
            		v.url = nk.userData.CNDURL.."images/freebigwheel/"..v.url
            	end
                self.isConfigReady_ = true
                local wheelItems_ = retData.configfile
                callback(true, wheelItems_)
                self.wheelItems_ = wheelItems_
            end
        end,
        function()
            self.isConfigReady_ = false
            callback(false)
        end
    )
end

-- 转动免费转盘
function LuckturnController:playFreeNow(callback)
    self.playNowId = bm.HttpService.POST( {
            mod = "luckyWheel", act = "playLuckyWheel"
        },
        function(data)
            local retData = json.decode(data)
            if retData and retData.ret == 0 then
                local rewardResult = retData.result
                callback(true, rewardResult)
            else
            	callback(false)
            end
        end,
        function() 
        	callback(false) 
        end
    )
end

-- 大厅转盘抽奖
function LuckturnController:playFreeNow2(callback)
    self.playNowId = bm.HttpService.POST( {
            mod = "ExchangeLuckWheel",
            act = "playLuckyWheel",
			uid = nk.userData.uid,
        },
        function(data)
            local retData = json.decode(data)
            if retData and retData.ret == 0 then
                local rewardResult = retData.result
                callback(true, rewardResult)
            else
            	callback(false)
            end
        end,
        function() 
        	callback(false) 
        end
    )
end

-- 获取免费转盘记录
function LuckturnController:getFreeWheelRecord()
	if nk.userData.freeRecords_ then
		bm.EventCenter:dispatchEvent({name=LuckturnController.GetFreeLkWheelRecord_Event, data=nk.userData.freeRecords_})
	end

	if self.recordFreeId_ then
		return
	end

	self.recordFreeId_ = bm.HttpService.POST({
		mod="LuckyWheel", act="getFreeLkWheelRecord"
	},
	function(data)
		local retData = json.decode(data)
		if retData then
			local len = #retData
			local list = {}
			for i=1,len do
				local id = retData[i].goodsid 
				if self.wheelItems_ then
					retData[i].resIsFromCDN = true
					retData[i].giftResId = self.wheelItems_[id+1].url
					retData[i].reward = self.wheelItems_[id+1].desc
				end
				retData[i].uid = tonumber(retData[i].uid)
				retData[i].img = retData[i].pic
			end

			local isEqual = self:comparseDataList(nk.userData.freeRecords_, retData)
			if isEqual or not nk.userData.freeRecords_ then
				nk.userData.freeRecords_ = retData
				bm.EventCenter:dispatchEvent({name=LuckturnController.GetFreeLkWheelRecord_Event, data=nk.userData.freeRecords_})
			end	
		end
		self.recordFreeId_ = nil
	end,
	function()
		self.recordFreeId_ = nil
	end)
end

-- 获取现金币转盘按钮配置列表
function LuckturnController:getScoreWheelBtnCfg()
	self:dispatchGetScoreWheelBtnCfg_()
	if self.getBigWheelListId_ then
		return;
	end

    self.getBigWheelListId_ = bm.HttpService.POST( {
            mod = "Match", 
            act = "bigwheelList"
        },
        handler(self, self.callbackGetScoreWheelBtnCfg_),
        function() 
            self.getBigWheelId_ = nil
        end
    )
end

-- 获取现金币转盘按钮配置列表 回调
function LuckturnController:callbackGetScoreWheelBtnCfg_(data)
	self.getBigWheelId_ = nil
	local retData = json.decode(data)
    if retData and retData.ret == 0 then
        local datalist = {};
        for k,v in pairs(retData.data.list) do
            v.img = retData.data.cdn..v.img;
            if v.realImg then
            	v.realImg = retData.data.cdn..v.realImg
            end
            if not v.realImg and v.img then
            	v.realImg = v.img
            end
            table.insert(datalist, #datalist+1, v);
        end

        local isEqual = self:comparseDataList(nk.userData.scoreWheelBtnCfg, datalist)
		if isEqual or not nk.userData.scoreWheelBtnCfg then
			nk.userData.scoreWheelBtnCfg = datalist
			bm.EventCenter:dispatchEvent({name=LuckturnController.GetScoreWheelBtnCfg_Event, data=nk.userData.scoreWheelBtnCfg})

			local jsonData = json.encode(datalist);
			self:updateUserDefaultData(LuckturnController.GetScoreWheelBtnCfg_Cache, jsonData)
		end	
    end
end

-- 获取现金币转盘按钮配置列表 派发本地数据
function LuckturnController:dispatchGetScoreWheelBtnCfg_()
	-- 判断本地换成是否
	if nk.userData.scoreWheelBtnCfg then
		bm.EventCenter:dispatchEvent({name=LuckturnController.GetScoreWheelBtnCfg_Event, data=nk.userData.scoreWheelBtnCfg})
		return
	end

	local jsonData = self:getUserDefaultData(LuckturnController.GetScoreWheelBtnCfg_Cache)
	if jsonData and string.len(jsonData) > 32 then
		local datalist = json.decode(jsonData)
		bm.EventCenter:dispatchEvent({name=LuckturnController.GetScoreWheelBtnCfg_Event, data=datalist})
		nk.userData.scoreWheelBtnCfg = datalist
	end
end

-- 获取付费转盘配置详情
function LuckturnController:getScoreWheelConfig(cfgId)
	self:dispatchGetScoreWheelConfig_(cfgId)
	if self.getScoreWheelCfgId_ then
		return;
	end
	self.cfgId_ = cfgId
    self.getScoreWheelCfgId_ = bm.HttpService.POST( {
            mod = "Match", 
            act = "bigwheel",
            id = cfgId
        },
        handler(self, self.callbackGetScoreWheelConfig),
        function() 
            self.getScoreWheelCfgId_ = nil
            self.cfgId_ = nil
        end
    )
end

-- 获取付费转盘配置详情 回调
function LuckturnController:callbackGetScoreWheelConfig(data)
	local retData = json.decode(data)
    if retData and retData.ret == 0 and retData.data and retData.data.list then
        local datalist = {};
        for k,v in pairs(retData.data.list) do
            v.img = retData.data.cdn..v.img;
            if not v.desc and v.name then
            	v.desc = v.name
            end
            table.insert(datalist, #datalist+1, v);
        end

        local key = "scoreWheelCfg"..tostring(self.cfgId_)
        local isEqual = self:comparseDataList(nk.userData[key], datalist)
		if isEqual or not nk.userData[key] then
			nk.userData[key] = datalist
			bm.EventCenter:dispatchEvent({name=LuckturnController.GetScoreWheelConfig_Event, data=nk.userData[key]})

			local jsonData = json.encode(datalist);
			self:updateUserDefaultData(key, jsonData)
		end
    end

    self.getScoreWheelCfgId_ = nil
	self.cfgId_ = nil
end

-- 获取付费转盘配置详情 派发本地数据
function LuckturnController:dispatchGetScoreWheelConfig_(cfgId)
	if nil == cfgId then
		return
	end
	-- 判断本地换成是否
	local key = "scoreWheelCfg"..tostring(cfgId)
	if nk.userData[key] then
		bm.EventCenter:dispatchEvent({name=LuckturnController.GetScoreWheelConfig_Event, data=nk.userData[key]})
		return
	end

	local jsonData = self:getUserDefaultData(key)
	if jsonData and string.len(jsonData) > 32 then
		local datalist = json.decode(jsonData)
		bm.EventCenter:dispatchEvent({name=LuckturnController.GetScoreWheelConfig_Event, data=datalist})
		nk.userData[key] = datalist
	end
end

function LuckturnController:getScoreWheelConfigById(cfgId)
	local key = "scoreWheelCfg"..tostring(self.cfgId_)
	return nk.userData[key]
end

-- 获取个人转盘记录
function LuckturnController:getSelfWheelRecord(cfgId,isDown)
	if not cfgId then
		bm.EventCenter:dispatchEvent({name=LuckturnController.GetSelfWheelRecord_Event, data={cfgId, {}}})
		return
	end
	local gettedData = self.selfRecordData[cfgId]
	if not gettedData then
		gettedData = {}
		self.selfRecordData[cfgId] = gettedData
	end
	-- 是否是拖拽哦
	gettedData.isDown = isDown
	if gettedData and gettedData.isEnd then
		bm.EventCenter:dispatchEvent({name=LuckturnController.GetSelfWheelRecord_Event, data={cfgId, gettedData}})
		return
	end
	if not gettedData.isDown then
		if gettedData.isEnd or #gettedData>0 then
			bm.EventCenter:dispatchEvent({name=LuckturnController.GetSelfWheelRecord_Event, data={cfgId, gettedData}})
			return
		end
	end
	if not gettedData.page then
		gettedData.page = 0
	end
	gettedData.page = gettedData.page + 1
	-- 最多是5页码
	if gettedData.page>5 then
		gettedData.isEnd = true
		bm.EventCenter:dispatchEvent({name=LuckturnController.GetSelfWheelRecord_Event, data={cfgId, gettedData}})
		return
	end
	local selfWheelId = bm.HttpService.POST({
		mod = "Match", 
		act = "luckyDrawLog",
        id = cfgId,
        type = 2,
        p = gettedData.page
	},

	function(rets)
		local retData = json.decode(rets)
		local userData = nk.userData
		if retData and retData.ret==0 then
			local list = retData.data
			if list and #list>0 then
				local len = #list
				for i=1,len do
					list[i].reward = list[i].msg
					list[i].sex = userData.sex
					list[i].uid = userData.uid
					list[i].nick = userData.nick
					list[i].img = userData.s_picture
					list[i].pos = "null"
					list[i].isSelf = true
					table.insert(gettedData,list[i])
				end
			else
				gettedData.isEnd = true
			end
		end
		bm.EventCenter:dispatchEvent({name=LuckturnController.GetSelfWheelRecord_Event, data={cfgId, gettedData}})
	end,
	function()
		bm.EventCenter:dispatchEvent({name=LuckturnController.GetSelfWheelRecord_Event, data={cfgId, gettedData}})
	end)
	self.selfWheelId_ = selfWheelId
end

-- 获取现金币转盘记录
function LuckturnController:getScoreWheelRecord(cfgId)
	if self.recordScoreId_ then
		return
	end

	self.cfgId_ = cfgId
	local key = "scoreRecords"..tostring(self.cfgId_)
	if nk.userData[key] then
		bm.EventCenter:dispatchEvent({name=LuckturnController.GetScoreLkWheelRecord_Event, data={self.cfgId_, nk.userData[key]}})
	end

	self.recordScoreId_ = bm.HttpService.POST({
		mod = "Match", 
		act = "luckyDrawLog",
        id = cfgId,
        type = 1
	},
	handler(self, self.callbackGetScoreWheelRecord_),
	function()
		self.recordScoreId_ = nil
	end)
end

-- 获取现金币转盘记录 回调
function LuckturnController:callbackGetScoreWheelRecord_(data)
	local retData = json.decode(data)
	if retData and retData.data then
		local key = "scoreRecords"..tostring(self.cfgId_)
		local retData = retData.data
		local len = #retData
		local list = {}
		local cfg,pos
		for i=1,len do
			-- 获取物品ID
			pos = retData[i].pos 
			cfg = self:getScoreWheelConfigById(self.cfgId_)
			retData[i].reward = retData[i].msg
			retData[i].img = retData[i].s_picture
			if cfg and pos and cfg[pos + 1] then
				local item = cfg[pos + 1]
				retData[i].giftImg = item.img
				retData[i].reward = item.name
				retData[i].type = item.type
				retData[i].num = item.num
			end
		end

		local isEqual = self:comparseDataList(nk.userData[key], retData)
		if isEqual or not nk.userData[key] or #retData == 0 then
			nk.userData[key] = retData
			bm.EventCenter:dispatchEvent({name=LuckturnController.GetScoreLkWheelRecord_Event, data={self.cfgId_, nk.userData[key]}})
		end	
	end
	self.recordScoreId_ = nil
end

-- 获取其他玩家详细信息
function LuckturnController:getOtherUserDetail(uid, callback)
	if self.otherUserDetailList[uid] then
		callback(self.otherUserDetailList[uid])
		return
	end

	self.userothermainId_ = bm.HttpService.POST({
		mod = "user", 
		act = "othermain",
        puid = uid
	},
	function(data)
		local jsonData = json.decode(data)
		if callback then
        	callback(jsonData)
    	end

		self.otherUserDetailList[uid] = jsonData

		self.userothermainId_ = nil
	end,
	function()
		if callback then
        	callback(nil)
    	end
		self.userothermainId_ = nil
	end)
end

-- 添加好友
function LuckturnController:setFriendPoker(uid, callback)
	self.setFriendPokerId_ = bm.HttpService.POST({
		mod="friend", 
		act="setPoker", 
		fuid=uid,
		new=1
	}, function(data)
        if callback then
        	callback(data)
    	end
        self.setFriendPokerId_ = nil
    end, function()
        if callback then
        	callback(nil)
    	end
    	self.setFriendPokerId_ = nil
    end)
end

-- 删除好友关系 
function LuckturnController:delFriendPoker(uid, callback)
	self.delFriendPokerId_ = bm.HttpService.POST({
		mod="friend", 
		act="delPoker", 
		fuid=uid
	}, function(data)
        if callback then
        	callback(data)
    	end
        self.delFriendPokerId_ = nil
    end, function()
        if callback then
        	callback(nil)
    	end
    	self.delFriendPokerId_ = nil
    end)
end

function LuckturnController:isTimesReady()
    return self.isTimesReady_
end

function LuckturnController:isConfigReady()
    return self.isConfigReady_
end

function LuckturnController:isAllReady()
    return self.isTimesReady_ and self.isConfigReady_
end

-- 把dataStr保存到本地
function LuckturnController:updateUserDefaultData(key, dataStr)
    local keyStr = self:getKeyStr_(key);
    nk.userDefault:setStringForKey(keyStr, dataStr);
    nk.userDefault:flush();
end

-- 获取保存本地数据
function LuckturnController:getUserDefaultData(key)
    local keyStr = self:getKeyStr_(key);
    return nk.userDefault:getStringForKey(keyStr);
end

function LuckturnController:getKeyStr_(key)
	return key
end

-- true为有不同，false为相同
function LuckturnController:comparseDataList(datalist1, datalist2)
	local isEqual = false
	if datalist1 and datalist2 then
		if #datalist1 == #datalist2 then
			for i=1,#datalist1 do
				for key,v in pairs(datalist1[i]) do
					if "table" ~=  tostring(type(datalist1[i][key])) and datalist1[i][key] ~= datalist2[i][key] then
						isEqual = true
						break;
					end
				end
			end
		else
			isEqual = true
		end
	else
		isEqual = true
	end
	return isEqual
end

return LuckturnController;