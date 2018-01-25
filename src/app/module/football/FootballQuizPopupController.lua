--
-- Author: KevinYu
-- Date: 2017-02-27 10:32:10
--

local FootballQuizPopupController = class("FootballQuizPopupController")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local requestRetryTimes_ = 3

function FootballQuizPopupController:ctor(view)
	requestRetryTimes_ = 3
    self.view_ = view
end

function FootballQuizPopupController:getMatchConfig()
	self.view_:setLoading(true)
	bm.HttpService.CANCEL(self.getMatchConfigId_)
	self.getMatchConfigId_ = bm.HttpService.POST(
        {
            mod = "Quiz",
            act = "getMatchCfg",
        },
        handler(self, self.onGetMatchConfig_),
        function ()
            requestRetryTimes_ = requestRetryTimes_ - 1
            if requestRetryTimes_ > 0 then
                self.getMatchConfigScheduleHandle_ = scheduler.performWithDelayGlobal(handler(self, self.getMatchConfig), 1)
            end
        end
    )
end

--获取比赛信息配置
function FootballQuizPopupController:onGetMatchConfig_(jsonData)
	self.view_:setLoading(false)
	local retData = json.decode(jsonData)
	local matchData = {}
	for _, v in pairs(retData) do
		if tonumber(v.curtime) < tonumber(v.endtime) then--当前时间小于截止时间
			local data = {}
			data.matchid = v.matchid
			data.matchTitle = v.matchtype
			data.matchtime = v.matchtime
			data.time = bm.TimeUtil:getFootballMathTime(v.matchtime)
			data.match = v.hometeam .. "\nVS\n" .. v.visitingteam
			data.hometeam = v.hometeam
			data.visitors = v.visitingteam

			data.odds = {
				v.homewinrate,
				v.tierate,
				v.visitingwinrate
			}

			data.bettingRatio = {
				v.homewinpercent * 100 .. "%",
				v.tiepercent * 100 .. "%",
				v.visitingpercent * 100 .. "%"
			}

			data.betTitle = {
				v.homewinratename,
				v.tieratename,
				v.visitingwinratename
			}
			table.insert(matchData, data)
		end
	end
	
	table.sort(matchData, function (a, b)
		return a.matchtime < b.matchtime
	end)

	self.view_:setMatchViewData(matchData)
end

--单独下注
function FootballQuizPopupController:aloneBet(data)
	self.view_:setLoading(true)
	local betList = {}
	for _, v in ipairs(data) do
		local bet = {}
		bet.matchid = v.matchid
		bet.betmoney = v.chip
		bet.gcoins = v.gcoins
		bet.wintype = v.betType

		table.insert(betList, bet)
	end

	local betStr = json.encode(betList)
	bm.HttpService.CANCEL(self.aloneBetId_)
	self.aloneBetId_ = bm.HttpService.POST(
        {
            mod = "Quiz",
            act = "footballBetAlone",
            betting = betStr,
        },
        handler(self, self.onBetCallback_),
        function ()
        end
    )
end

--组合下注
function FootballQuizPopupController:groupBet(data)
	self.view_:setLoading(true)
	local betList = {}
	local matchidList = data.matchid
	local betTypeList = data.betType
	local len = #matchidList
	for i = 1, len do
		local bet = {}
		bet.matchid =matchidList[i]
		bet.wintype = betTypeList[i]

		table.insert(betList, bet)
	end
	
	local betStr = json.encode(betList)

	bm.HttpService.CANCEL(self.groupBetId_)
	self.groupBetId_ = bm.HttpService.POST(
        {
            mod = "Quiz",
            act = "footballBetCombined",
            betting = betStr,
            betmoney = data.chip,
            gcoins = data.gcoins
        },
        handler(self, self.onBetCallback_),
        function ()
        end
    )
end

function FootballQuizPopupController:onBetCallback_(data)
	self.view_:setLoading(false)
	local retData = json.decode(data)
	if retData.code == 1 then
		nk.TopTipManager:showTopTip(bm.LangUtil.getText("FOOTBALL", "BET_SUCC_TIPS"))
	elseif retData.code == -2 then
		nk.TopTipManager:showTopTip(bm.LangUtil.getText("FOOTBALL", "BET_TIMEOUT_TIPS"))
		self.view_:updateMatchInfo()
	else
		nk.TopTipManager:showTopTip(bm.LangUtil.getText("FOOTBALL", "BET_FAIL_TIPS"))
	end
end

--获取竞猜记录
function FootballQuizPopupController:getBetRecord()
	self.view_:setLoading(true)
	bm.HttpService.CANCEL(self.getBetRecordId_)
	self.getBetRecordId_ = bm.HttpService.POST(
        {
            mod = "Quiz",
            act = "getBetRecord",
        },
        handler(self, self.onGetBetRecord_),
        function ()
            requestRetryTimes_ = requestRetryTimes_ - 1
            if requestRetryTimes_ > 0 then
                self.getBetRecordScheduleHandle_ = scheduler.performWithDelayGlobal(handler(self, self.getBetRecord), 1)
            end
        end
    )
end

function FootballQuizPopupController:onGetBetRecord_(jsonData)
	self.view_:setLoading(false)
	local retData = json.decode(jsonData)
	local recordData = {}
	for _, data in pairs(retData) do
		local record = {}
		record.state = tonumber(data.status)
		record.betgcoins = tonumber(data.betgcoins)
		record.betmoney = tonumber(data.betmoney)
		record.betrate = data.betrate
		record.id = data.id
		record.info = {}
		
		for _, v in ipairs(data.betting) do
			local bet = {}
			bet.time = bm.TimeUtil:getFootballMathTime(v.matchtime, "\n")
			bet.match = v.hometeam .. "\nVS\n" .. v.visitingteam
			bet.quiz = v.betdesc
			bet.score = v.result

			table.insert(record.info, bet)
		end

		table.insert(recordData, record)
	end

	self.view_:setRecordViewData(recordData)
end

--获取竞猜奖励
function FootballQuizPopupController:getBetReward(id, succCallback, failCallback)
	self.view_:setLoading(true)
	bm.HttpService.CANCEL(self.getBetRecordId_)
	self.getBetRecordId_ = bm.HttpService.POST(
        {
            mod = "Quiz",
            act = "getReward",
            id = id
        },
        function(data)
        	self.view_:setLoading(false)
        	local retData = json.decode(data)
        	if retData.code == 1 then
        		succCallback()
        	else
        		failCallback()
        	end
        end,
        function ()
            requestRetryTimes_ = requestRetryTimes_ - 1
            if requestRetryTimes_ > 0 then
                self.getBetRecordScheduleHandle_ = scheduler.performWithDelayGlobal(handler(self, self.getBetRecord), 1)
            else
            	failCallback()
            end
        end
    )
end

function FootballQuizPopupController:dispose()
    bm.HttpService.CANCEL(self.getMatchConfigId_)
    bm.HttpService.CANCEL(self.aloneBetId_)
    bm.HttpService.CANCEL(self.groupBetId_)
    bm.HttpService.CANCEL(self.getBetRecordId_)

    if self.getMatchConfigScheduleHandle_ then
        scheduler.unscheduleGlobal(self.getMatchConfigScheduleHandle_)
    end

    if self.getBetRecordScheduleHandle_ then
        scheduler.unscheduleGlobal(self.getBetRecordScheduleHandle_)
    end
end

return FootballQuizPopupController