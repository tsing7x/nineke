--
-- Author: Tom
-- Date: 2014-12-04 14:29:12
--
local LoadMatchControl =  class("LoadMatchControl")
local instance

function LoadMatchControl:getInstance()
    instance = instance or LoadMatchControl.new()

    return instance
end

function LoadMatchControl:deleteInstance()
    if instance then
        instance:clean()
    end
    instance = nil
end

function LoadMatchControl:clean()
    self:clearCountdown()
    self:clearCoolDown()
    self.schedulerPool_:clearAll()
end

function LoadMatchControl:ctor()
    self.requestId_ = 0
    self.requests_ = {}
    self.isConfigLoaded_ = false
    self.isConfigLoading_ = false
    self.matchIP_ = nil
    self.matchPort_ = nil

    self.allTimes_ = nil
    self.nextTime_ = nil
    self.countdownId_ = nil
    self.coolDownId_ = nil
    self.schedulerPool_ = bm.SchedulerPool.new()
    self.openList_ = {}
end

function LoadMatchControl:clearCountdown()
    if self.countdownId_ then
        self.schedulerPool_:clear(self.countdownId_)
        self.countdownId_ = nil
    end
end

function LoadMatchControl:dealMatchTimeConfig()
    self.allTimes_ = {}  -- 排序
    if self.matchData_ then
        for k,v in ipairs(self.matchData_) do
            -- 次数初始化
            local exchange = v.exchange
            if exchange and exchange.limit and exchange.limit>0 then
                v.playTimes = exchange.limit--标准次数
                v.buyChips = exchange.chips--购买需要金币
                v.enum = exchange.enum or 1--一次性购买次数
                v.leftTimes = 0 --剩余次数
            end

            if v.times then
                table.insertto(self.allTimes_, v.times)
            end
        end
    end
    table.sort(self.allTimes_)
    self:getLeftEntry()
end

-- 核对是否要进行倒计时
function LoadMatchControl:checkCoolDown()
    if self.matchData_ then
        local needRestart = false
        for kk,vv in pairs(self.matchData_) do
            if vv.playTimes and vv.playTimes>0 then
                if tonumber(vv.leftTimes)>=tonumber(vv.playTimes) then
                    vv.CDTime = nil
                elseif vv.CDTime==nil then
                    vv.clientFreeStart = os.time()
                    vv.CDTime = vv.riseTime
                    vv.CDTime1 = vv.riseTime
                    needRestart = true
                end
            end
        end
        if needRestart and self.coolDownId_ == nil then
            -- 冷却时间处理
            self:dealCoolDown()
        end
    end
end

-- 删除
function LoadMatchControl:clearCoolDown()
    if self.coolDownId_ then
        self.schedulerPool_:clear(self.coolDownId_)
        self.coolDownId_ = nil
    end
end

-- 倒计时冷却处理
function LoadMatchControl:dealCoolDown()
    self:clearCoolDown()
    self.coolDownId_ = self.schedulerPool_:loopCall(function()
            -- 倒计时处理
            local needClear = true
            local needReRequest = false
            local clientCurrentTime = os.time()
            for kk,vv in pairs(self.matchData_) do
                if vv.CDTime then
                    needClear = false
                    vv.CDTime = vv.CDTime1 - clientCurrentTime + vv.clientFreeStart
                    if vv.CDTime<1 then
                        needReRequest = true
                    end
                end
            end
            -- 通知显示层
            bm.EventCenter:dispatchEvent("Match_Cool_Down_Change")
            if needClear or needReRequest then
                self:clearCoolDown()
                if needReRequest then
                    self:getLeftEntry()
                end
            end
            return true
        end,
        1)
end

-- 获取玩家剩余次数
function LoadMatchControl:getLeftEntry(callBack)
    bm.HttpService.POST(
        {
            mod = "Match",
            act = "getLeftEntry",
        },
        function(data1)
            local retData = json.decode(data1)
            local data = retData and retData.data
            if data and retData.ret==0 and self.matchData_ then
                local riseTime = retData.riseTime or 1800 -- 涨的时间间隔
                local serverTime = retData.time or os.time() -- 服务器时间
                for k,v in pairs(data) do
                    for kk,vv in pairs(self.matchData_) do
                        if tonumber(k)==vv.id then
                            vv.leftTimes = tonumber(v)
                            vv.riseTime = riseTime
                            vv.freeStart = nil
                            vv.clientFreeStart = nil
                            vv.CDTime = nil

                            break;
                        end
                    end
                end

                local freeStart = retData.freeStart
                if freeStart then
                    for k,v in pairs(freeStart) do
                        for kk,vv in pairs(self.matchData_) do
                            if tonumber(k)==vv.id then
                                vv.freeStart = tonumber(v)
                                vv.clientFreeStart = os.time()
                                vv.CDTime = vv.riseTime - tonumber(serverTime) + vv.freeStart
                                vv.CDTime1 = vv.CDTime
                                if vv.CDTime<0 then
                                    vv.CDTime = 0
                                end
                                break;
                            end
                        end
                    end
                end

                if callBack then
                    callBack()
                end

                -- 冷却时间处理
                self:dealCoolDown()
            end
            if retData.ret~=0 then
                self:getLeftEntry(callBack)
            end
        end,
        function()
            self:getLeftEntry(callBack)
        end
    )
end

-- 兑换次数
function LoadMatchControl:exchangeEntry(level,callBack)
    bm.HttpService.POST(
        {
            mod = "Match",
            act = "exchangeEntry",
            level = level,
        },
        function(data1)
            local retData = json.decode(data1)
            local data = retData and retData.data
            if data and data.level and self.matchData_ then
                for kk,vv in pairs(self.matchData_) do
                    if tonumber(data.level)==vv.id then
                        vv.leftTimes = tonumber(data.num)
                        self:checkCoolDown()
                        break;
                    end
                end
            end

            if data and data.ret==0 then
                bm.EventCenter:dispatchEvent({name = "exchangeEntry", data = retData});
            end

            if callBack then
                callBack(retData)
            end
        end,
        function()
            if callBack then
                callBack(nil)
            end
        end
    )
end

function LoadMatchControl:getTimeStrAndSecByGMT(serverTime)
    local date = os.date("*t",serverTime)
    local hour = tonumber(date.hour)
    local min = tonumber(date.min)
    local sec = tonumber(date.sec) + 1 -- 解决时间相同问题
    local currentSec = sec + min * 60 + hour * 3600
    if hour<10 then
        hour = "0"..hour
    end
    if min<10 then
        min = "0"..min
    end
    if sec<10 then
        sec = "0"..sec
    end
    hour = hour..":"..min..":"..sec
    return hour,currentSec,date
end

function LoadMatchControl:dealServerTime()
    if not self.allTimes_ then return end
    if #self.allTimes_<1 then return end
    local serverTime = nk.socket.MatchSocket.serverTime
    if not serverTime then return end
    serverTime = serverTime + os.time() - nk.socket.MatchSocket.clientTime
    local hour,currentSec,date = self:getTimeStrAndSecByGMT(serverTime)
    local temp ={}
    for k,v in ipairs(self.allTimes_) do
        temp[k] = v
    end
    local nextTime,nextSec = self:getNextTime(temp,hour)
    self.nextTime_ = nextTime
    -- 设置各个项
    for k,v in ipairs(self.matchData_) do
        v.factor1 = nil -- 用于显示2
        if v.type==2 and v.times then
            local isInSelf = false
            local temp1 = {} -- 不在组内重新排序
            for kk,vv in ipairs(v.times) do
                if vv==self.nextTime_ then
                    isInSelf = true
                end
                temp1[kk] = vv
            end

            -- 日期赛 （周赛、月赛）
            local isTheSameDay = true
            local isTheSameDayButPassed = false -- 是同一天但正好过了
            if v.timestamp then
                isTheSameDay = false
                local timestamp = v.timestamp
                if #timestamp>0 then
                    local tempDay = os.time({year = tonumber(date.year), month = tonumber(date.month), day = tonumber(date.day), hour=0})
                    local nextDay = nil
                    for m=#timestamp, 1, -1 do
                        if tempDay == timestamp[m] then
                            isTheSameDay = true
                            local hahaTime = string.split(temp1[#temp1],":")
                            local val = tempDay+tonumber(hahaTime[3])+tonumber(hahaTime[2])*60+tonumber(hahaTime[1])*3600;
                            if ((tempDay+tonumber(hahaTime[3])+tonumber(hahaTime[2])*60+tonumber(hahaTime[1])*3600)<serverTime) then
                                isTheSameDayButPassed = true
                                isTheSameDay = false
                            end
                            break;
                        elseif timestamp[m]>tempDay then
                            nextDay = timestamp[m]
                        end
                    end
                    if not isTheSameDay or isTheSameDayButPassed then
                        if nextDay==nil then
                            v.open = 0  --比赛已经结束，没有下一场了
                        else
                            local tempDate = os.date("*t",nextDay)
                            local nextTimeTable = string.split(temp1[1],":")
                            local startDayTime = {
                                year = tempDate.year,
                                month = tempDate.month,
                                day = tempDate.day,
                                hour = nextTimeTable[1],
                                min = nextTimeTable[2],
                                sec = nextTimeTable[3],
                            }

                            -- 赋值下一场
                            v.factor1 = (tempDate.month>9 and tempDate.month or ("0"..tempDate.month)) .."/".. (tempDate.day>9 and tempDate.day or ("0"..tempDate.day)) .." "..temp1[1]
                            
                            -- 倒计时用
                            v.leftTime = os.time(startDayTime)-serverTime
                            v.serverTime = os.time()
                        end
                    end
                else
                    v.open = 0
                end
            end

            if isInSelf then
                if isTheSameDay then
                    v.factor1 = self.nextTime_
                    -- 倒计时用
                    v.leftTime = nextSec-currentSec
                    v.serverTime = os.time()
                    -- 本地下一阶段
                    v.factor1 = self:getNextTime(temp1,self:getTimeStrAndSecByGMT(v.serverTime))
                end
            else -- 不在自己这个组内
                if isTheSameDay then
                    local nextTime1,nextSec1 = self:getNextTime(temp1,hour)
                    v.factor1 = nextTime1
                    -- 倒计时用
                    v.leftTime = nextSec1-currentSec
                    v.serverTime = os.time()
                    -- 本地下一阶段
                    v.factor1 = self:getNextTime(temp1,self:getTimeStrAndSecByGMT(v.serverTime))
                end
            end
            if v.factor1 then
                local factor1Table = string.split(v.factor1,":")
                if factor1Table[3] == "00" then
                    v.factor1 = factor1Table[1]..":"..factor1Table[2]
                end
            end
        end
    end
    -- 倒计时刷新
    self:clearCountdown()
    self.countdownId_ = self.schedulerPool_:delayCall(function()
        self:dealServerTime()
    end, nextSec-currentSec)
    bm.EventCenter:dispatchEvent(nk.eventNames.MATCH_TIME_CHANGE)
end

function LoadMatchControl:getNextTime(arr,time)
    table.insert(arr,time)
    table.sort(arr) -- 排序查找位置
    local nextTime,nextSec
    local index = 0
    for k,v in ipairs(arr) do
        if v==time then
            index = k
            break
        end
    end
    local backIndex = index
    index = index + 1
    nextTime = arr[index]
    if not nextTime then
        nextTime = arr[1]
    end

    local nextTimeTable = string.split(nextTime,":")
    local hour1 = nextTimeTable[1]
    local min1 = nextTimeTable[2]
    local sec1 = nextTimeTable[3]
    nextSec = sec1 + min1*60 + hour1*3600
    if not arr[index] then
        nextSec = nextSec + 24*3600
    end
    table.remove(arr,backIndex)
    return nextTime,nextSec
end

function LoadMatchControl:filterAndSortOpen()
    self.openList_ = {}

    local openMatchIds = {}
    for i=1,#self.matchData_ do
        -- E2P专场
        local condition = self.matchData_[i].condition
        if condition and condition.ticket and tonumber(condition.ticket)==2000 then         
            condition.gameCouponE2P = 1
        end

        local days = self.matchData_[i].days

        if days then
            table.sort(days) -- 按照数字进行排序
            local timestamp = {} -- 转化为时间戳哦
            for j=1,#days do
                local playDay = string.split(days[j],"-")
                local timeTable ={
                    year = playDay[1],
                    month = playDay[2],
                    day = playDay[3],
                    hour = 0,
                }
                timestamp[j] = os.time(timeTable)
            end
            self.matchData_[i].timestamp = timestamp
        end

        if tonumber(self.matchData_[i].open) == 1 then
            table.insert(self.openList_,self.matchData_[i])
            if not self.matchData_[i].sort then
                self.matchData_[i].sort = 1
            end
        else
            self.matchData_[i].sort = -1
        end
    end

    table.sort(self.openList_,function(a,b) return tonumber(a.sort) < tonumber(b.sort)  end)
    for i=1,#self.openList_ do
        self.openList_[i].sort = i  -- 方便显示层获取
        table.insert(openMatchIds,tonumber(self.openList_[i].id))
    end

    nk.match.MatchModel.openMatchIds = openMatchIds
end

function LoadMatchControl:getMatchDetail(matchId,callback)
    if not self.matchData_ or not matchId then return end
    for k,v in pairs(self.matchData_) do
        if tonumber(v.id)== matchId then
            if not v.reward or v.reward=="" then
                break
            else
                if callback then
                    callback()
                end 
                return
            end
        end
    end
    bm.HttpService.POST(
        {
            mod = "Match",
            act = "getConfigById",
            id = matchId
        },
        function(data1)
            local retData = json.decode(data1)
            local data = retData and retData.data
            if data then
                for k,v in pairs(self.matchData_) do
                    if tonumber(v.id)==tonumber(data.id) then
                        v.reward = data.reward
                        v.rules = data.rules
                    end
                end
            end
            if callback then
                callback()
            end
        end,
        function()
            if callback then
                callback()
            end
        end
    )
end

function LoadMatchControl:dispatchRoomLoading(tempIP, tempPort)
    local evtData = {}
    evtData.ip = tempIP;
    evtData.port = tempPort;
    evtData.src = "2";
    bm.EventCenter:dispatchEvent({name="update_matchIpPort_roomLoading", data=evtData})
end

function LoadMatchControl:getMatchTabList()
    if self.tabList_ then
        return self.tabList_;
    end
    local cfg;
    self.tabList_ = {};
    for i=1,#self.matchCfgData_.tabs do
        cfg = {};
        cfg.list = {}
        cfg.id = i;
        cfg.name = self.matchCfgData_.tabs[i].name;
        for _,v in pairs(self.matchCfgData_.tabs[i].ids) do
            for _,k in pairs(self.matchData_) do
                if v == k.id then
                    table.insert(cfg.list, #cfg.list+1, k);
                end
            end
        end

        table.insert(self.tabList_, #self.tabList_+1, cfg);
    end
    return self.tabList_;
end

function LoadMatchControl:startLoad(callback)
    if self.isConfigLoaded_ then
        if callback then
            callback()
        end
        if self.loadMatchConfigCallback_ then
            self.loadMatchConfigCallback_(true, self.matchData_)
        end
    else
        if self.isConfigLoading_ then return end
        self.isConfigLoading_ = true
        bm.HttpService.POST(
            {
                mod = "Match",
                act = "getConfig",
                new = 1
            },
            function(data)
                local retData = json.decode(data)
                self.isConfigLoading_ = false
                if retData and retData.ret == 0 then
                    local data = retData.data
                    local server = data.server
                    self.matchCfgData_ = data;
                    self.matchIP_ = server.ip
                    self.matchPort_ = server.port
                    self.matchData_ = data.desc
                    self.isConfigLoaded_ = true

                    self:dispatchRoomLoading(self.matchIP_, self.matchPort_)
                    if self.matchData_ then
                        -- 先-排序
                        self:filterAndSortOpen()
                        for k, v in pairs(self.requests_) do
                            local called = false
                            for i=1,#self.matchData_ do
                                if v.matchId and tonumber(self.matchData_[i].id) == tonumber(v.matchId) then
                                    if v.callback then
                                        called = true
                                        v.callback(self.matchData_[i])
                                        break
                                    end
                                end
                                if v.indexId and tonumber(self.matchData_[i].sort) == tonumber(v.indexId) then
                                    if v.callback then
                                        called = true
                                        v.callback(self.matchData_[i])
                                        break
                                    end
                                end
                            end
                            if not called and v.callback then
                                v.callback(nil)
                            end
                        end
                        self:dealMatchTimeConfig()
                    end
                    if callback then
                        callback()
                    end
                    if self.loadMatchConfigCallback_ then
                        self.loadMatchConfigCallback_(true, self.matchData_)
                    end
                else
                    if callback then
                        callback()
                    end
                    if self.loadMatchConfigCallback_ then
                        self.loadMatchConfigCallback_(false)
                    end
                end
            end,
            function()
                self.isConfigLoading_ = false
                if callback then
                    callback()
                end
                if self.loadMatchConfigCallback_ then
                    self.loadMatchConfigCallback_(false)
                end
            end
        )
    end
end

function LoadMatchControl:loadConfig(url, callback)
    self.loadMatchConfigCallback_ = callback
    self:startLoad()
end

function LoadMatchControl:cancel(requestId)
    self.requests_[requestId] = nil
end

function LoadMatchControl:getMatchById(matchId, callback)
    if self.isConfigLoaded_ then
        if self.matchData_ then
            for i=1,#self.matchData_ do
                if tonumber(self.matchData_[i].id) == tonumber(matchId) then
                    if callback then
                        callback(self.matchData_[i])
                        return nil
                    end
                end
            end
        end
    else
        self.requestId_ = self.requestId_ + 1
        self.requests_[self.requestId_] = {matchId=matchId, callback=callback}

        self:startLoad()
        return self.requestId_
    end
end

function LoadMatchControl:getMatchByIndex(indexId, callback)
    if self.isConfigLoaded_ then
        if self.matchData_ then
            for i=1,#self.matchData_ do
                if tonumber(self.matchData_[i].sort) == tonumber(indexId) then
                    if callback then
                        callback(self.matchData_[i])
                        return nil
                    end
                end
            end
        end
    else
        self.requestId_ = self.requestId_ + 1
        self.requests_[self.requestId_] = {indexId=indexId, callback=callback}

        self:startLoad()
        return self.requestId_
    end
end

return LoadMatchControl