--
-- Author: johnny@boomegg.com
-- Date: 2014-08-25 22:04:49
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.

local RankingPopupController = class("RankingPopupController")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

local requestRetryTimes_ = 2

RankingPopupController.currentRankingType = 1 -- 1代表盈利排行，2代表魅力排行，3游戏币排行，4现金币排行

function RankingPopupController:ctor(view)
    self.view_ = view
end

function RankingPopupController:onMainTabChange(selectedTab)
    self.mainSelectedTab_ = selectedTab

    self:cancelAllRequest_()
    requestRetryTimes_ = 2
    if self.mainSelectedTab_ == 2 then
        if self.friendCashData_ then
            -- 好友排行
            if self.subSelectedTab_ == 1 then                
                -- 现金币排行
                table.sort(self.friendCashData_, function(o1, o2)
                    return o1.val > o2.val
                end)
                RankingPopupController.currentRankingType = 4
                self.view_:setListData(self.friendCashData_)
            else
                -- 资产排行
                table.sort(self.friendData_, function(o1, o2)
                    return o1.money > o2.money
                end)
                RankingPopupController.currentRankingType = 3
                self.view_:setListData(self.friendData_)
            end
        else
            if self.subSelectedTab_ == 1 then
                RankingPopupController.currentRankingType = 4
            else
                RankingPopupController.currentRankingType = 3
            end
            self:requestFriendCashData_()
            self:requestFriendData_()
            self.view_:setLoading(true)
        end
    else
        if self.totalProfitData_ then
            -- 总排行
            if self.subSelectedTab_ == 1 then
                -- 盈利排行                
                RankingPopupController.currentRankingType = 1
                self.view_:setListData(self.totalProfitData_)
            elseif self.subSelectedTab_ == 2 then
                --游戏币排行
                RankingPopupController.currentRankingType = 3
                self.view_:setListData(self.rankingData_.money)                   
            end
        else
            if self.subSelectedTab_ == 1 then
                RankingPopupController.currentRankingType = 1
            elseif self.subSelectedTab_ == 2 then
                RankingPopupController.currentRankingType = 3
            end
            self:requestTotalProfitData_()
            self:requestRankingData_()
            self.view_:setLoading(true)
        end
    end
end

function RankingPopupController:onSubTabChange(selectedTab)
    self.subSelectedTab_ = selectedTab
    self.view_:setLoading(true)
    if self.mainSelectedTab_ == 1 then
        -- 总排行
        if self.subSelectedTab_ == 1 then
            -- 盈利排行                
            RankingPopupController.currentRankingType = 1
            if self.totalProfitData_ then
                self.view_:setListData(self.totalProfitData_)
            end
        elseif self.subSelectedTab_ == 2 then
            --游戏币排行
            RankingPopupController.currentRankingType = 3
            if self.rankingData_ then
                self.view_:setListData(self.rankingData_.money)
            end          
        end        
    elseif self.mainSelectedTab_ == 2 then
        -- 好友排行
        if self.subSelectedTab_ == 1 then
            -- 现金币排行
            RankingPopupController.currentRankingType = 4
            if self.friendCashData_ then
                table.sort(self.friendCashData_, function(o1, o2)
                    return o1.val > o2.val
                end)
                self.view_:setListData(self.friendCashData_)
            end
        else
            -- 资产排行
            RankingPopupController.currentRankingType = 3
            if self.friendData_ then
                table.sort(self.friendData_, function(o1, o2)
                    return o1.money > o2.money
                end)
                self.view_:setListData(self.friendData_)
            end
        end
    end   
end

-- 获取好友列表-现金币
function RankingPopupController:requestFriendCashData_()
    if not self.friendCashData_ then
        local time_ = os.time()
        self.friendCashDataRequestId_ = bm.HttpService.POST(
        {
            mod = "Ranklist", 
            act = "friendMon",
            time = time_,
            sign = crypto.md5(time_ .. "1e2c206269c42354c6dae040bca194c8f") 
        }, 
        handler(self, self.onGetFriendCashData_), 
        function ()
            requestRetryTimes_ = requestRetryTimes_ - 1
            if requestRetryTimes_ > 0 then
                self.friendCashDataRequestScheduleHandle_ = scheduler.performWithDelayGlobal(handler(self, self.requestFriendCashData_), 2)
            else
                self.view_:setListData()
            end
        end
    )
    end
end

function RankingPopupController:onGetFriendCashData_(data)
    if data then
        local recallData = json.decode(data)
        local cashData = recallData.userlist
        -- 获取数据后，把自己的数据添加进去
        local selfData = {
            uid = nk.userData.uid,
            nick = nk.userData.nick, 
            img = nk.userData.s_picture,
            sex = nk.userData.sex,
            money = nk.userData.money, 
            val = nk.userData.score,
        }
        table.insert(cashData, selfData)
        
        if self.mainSelectedTab_ == 2 then
            if self.subSelectedTab_ == 1 then
                table.sort(cashData, function (a, b) return a.val > b.val end)
                self.friendCashData_ = cashData
                self.view_:setListData(cashData)
            end
        end
    else
        self.friendCashDataRequestScheduleHandle_ = scheduler.performWithDelayGlobal(handler(self, self.requestFriendData_), 2)
    end
end

-- 获取好友列表-游戏币
function RankingPopupController:requestFriendData_()
    if not self.friendData_ then
        self.friendDataRequestId_ = bm.HttpService.POST(
        {
            mod = "friend", 
            act = "list", 
        }, 
        handler(self, self.onGetFriendData_), 
        function ()
            requestRetryTimes_ = requestRetryTimes_ - 1
            if requestRetryTimes_ > 0 then
                self.friendDataRequestScheduleHandle_ = scheduler.performWithDelayGlobal(handler(self, self.requestFriendData_), 2)
            else
                self.view_:setListData()
            end
        end
    )
    end
end

function RankingPopupController:onGetFriendData_(data)
    if data then
        self.friendData_ = json.decode(data)

        -- 获取数据后，把自己的数据添加进去
        local selfData = {
            uid = nk.userData.uid,
            nick = nk.userData.nick, 
            img = nk.userData.s_picture,
            sex = nk.userData.sex,
            money = nk.userData.money, 
            level = nk.userData.level
        }
        table.insert(self.friendData_, selfData)
        
        if self.mainSelectedTab_ == 2 then
            if self.subSelectedTab_ == 2 then
                table.sort(self.friendData_, function (a, b) return a.money > b.money end)
                self.view_:setListData(self.friendData_)
            end
        end
    else
        self.friendDataRequestScheduleHandle_ = scheduler.performWithDelayGlobal(handler(self, self.requestFriendData_), 2)
    end
end

-- 获取总排行榜数据
function RankingPopupController:requestRankingData_()
    if not self.rankingData_ then
        self.rankingDataRequestId_ = bm.HttpService.POST(
        {
            mod = "rank", 
            act = "main", 
        }, 
        handler(self, self.onGetRankingData_), 
        function ()
            requestRetryTimes_ = requestRetryTimes_ - 1
            if requestRetryTimes_ > 0 then
                self.rankingDataRequestScheduleHandle_ = scheduler.performWithDelayGlobal(handler(self, self.requestRankingData_), 2)
            else
                self.view_:setListData()
            end
        end
    )
    end
end

function RankingPopupController:onGetRankingData_(data)
    if data then
        self.rankingData_ = json.decode(data)
        if self.mainSelectedTab_ == 1 then
            if self.subSelectedTab_ == 2 then
                self.view_:setListData(self.rankingData_.money)
            end
        end
    else
        self.rankingDataRequestScheduleHandle_ = scheduler.performWithDelayGlobal(handler(self, self.requestRankingData_), 2)
    end
end

-- 获取总排行榜-盈利数据
function RankingPopupController:requestTotalProfitData_()
    if not self.totalProfitData_ then
        local time_ = os.time()
        self.totalProfitDataRequestId_ = bm.HttpService.POST(
        {
            mod = "Ranklist", 
            act = "earnRanklist", 
            time = time_,
            sign = crypto.md5(time_ .. "1e2c206269c42354c6dae040bca194c8f") 
        }, 
        handler(self, self.onGetTotalProfitData_), 
        function ()
            requestRetryTimes_ = requestRetryTimes_ - 1
            if requestRetryTimes_ > 0 then
                self.totalProfitDataRequestScheduleHandle_ = scheduler.performWithDelayGlobal(handler(self, self.requestTotalProfitData_), 2)
            else
                self.view_:setListData()
            end
        end
    )
    end
end

function RankingPopupController:onGetTotalProfitData_(data)
    if data then
        local recallData = json.decode(data)
        if recallData.code == 1 then
            self.totalProfitData_ = recallData.userlist
            nk.userData.curProfitVal = recallData.ownerval or 0 --当前盈利
            if self.mainSelectedTab_ == 1 then
                if self.subSelectedTab_ == 1 then
                    self.view_:setListData(self.totalProfitData_)
                end
            end
        else
            
        end      
    else
        self.totalProfitDataRequestScheduleHandle_ = scheduler.performWithDelayGlobal(handler(self, self.requestTotalProfitData_), 2)
    end
end

-- 获取昨日盈利榜冠军信息
function RankingPopupController:requestYesterdayChampionData()
    if not self.yesterdayChampionData_ then
        local time_ = os.time()
        self.yesterdayChampionDataRequestId_ = bm.HttpService.POST(
        {
            mod = "Ranklist", 
            act = "yesterdaylist", 
            time = time_,
            sign = crypto.md5(time_ .. "1e2c206269c42354c6dae040bca194c8f") 
        }, 
        handler(self, self.onGetYesterdayChampionData_), 
        function ()
            requestRetryTimes_ = requestRetryTimes_ - 1
            if requestRetryTimes_ > 0 then
                self.yesterdayChampionDataRequestScheduleHandle_ = scheduler.performWithDelayGlobal(handler(self, self.requestYesterdayChampionData), 2)
            else
                local yesterdayData = {
                    sex = "m",
                    img = "1",  
                    championType = 1,
                    rank = 9999,
                    isGetReward = 0,
                    notChampion = true
                }
                self.view_:showUI(yesterdayData)
            end
        end)
    end
end

function RankingPopupController:onGetYesterdayChampionData_(data)
    if data then
        local recallData = json.decode(data)
        if recallData.code == 1 then
            self.yesterdayChampionData_ = recallData
            local champion = recallData.champion
            local reward = recallData.reward
            local yesterdayData

            if next(champion) == nil then
                yesterdayData = {
                    sex = "m",
                    img = "1",  
                    championType = 1,
                    rank = 9999,
                    isGetReward = 0,
                    notChampion = true
                }
            else
                yesterdayData = champion
                yesterdayData.name = champion.nick --姓名
                yesterdayData.value = champion.val --盈利值
                yesterdayData.sex = champion.sex --性别 "m" "f"
                yesterdayData.img = champion.img --头像
                yesterdayData.win = champion.wins
                yesterdayData.lose = champion.loses
                yesterdayData.isFriend = champion.isFriend
                yesterdayData.championType = recallData.type or 1 --冠军类型:1昨日盈利 2昨日大师
                yesterdayData.rank = reward.rank or 9999 --排名,在榜内，会小于20，榜外就设置成一个大值，偏于统一判断
                yesterdayData.isGetReward = reward.can or 0--是否可以领奖 0不能领奖 1可以领奖
                yesterdayData.winsmoney = reward.winsmoney or 0--自己赢的钱
            end

            self.view_:showUI(yesterdayData)
        end
    else
        self.yesterdayChampionDataRequestScheduleHandle_ = scheduler.performWithDelayGlobal(handler(self, self.requestYesterdayChampionData), 2)
    end
end

-- 刷新排行榜，目前只有 earn(今日盈利总榜) mon(现金币榜单)
function RankingPopupController:refreshRankingData(rankType)
    if not rankType then
        return   
    end
    self.view_:setLoading(true)
    local time_ = os.time()
    bm.HttpService.POST(
        {
            mod = "Ranklist", 
            act = "refresh", 
            type = rankType,
            time = time_,
            sign = crypto.md5(time_ .. "1e2c206269c42354c6dae040bca194c8f") 
        }, 
        handler(self, self.onRefreshRankingData_),
        function ()
            --不重试，减少频繁操作
        end
    )
end

function RankingPopupController:onRefreshRankingData_(data)
    if data then
        local recallData = json.decode(data)
        if recallData.code == 1 then
            if self.mainSelectedTab_ == 1 then
                if self.subSelectedTab_ == 1 then
                    self.totalProfitData_ = recallData.userlist
                    nk.userData.curProfitVal = recallData.ownerval or 0 --当前盈利
                    self.view_:setListData(self.totalProfitData_)
                end
            elseif self.mainSelectedTab_ == 2 then
                if self.subSelectedTab_ == 1 then
                    local cashList = recallData.userlist
                    local selfData = {
                        uid = nk.userData.uid,
                        nick = nk.userData.nick, 
                        img = nk.userData.s_picture,
                        sex = nk.userData.sex,
                        money = nk.userData.money, 
                        val = nk.userData.score,
                    }
                    table.insert(cashList, selfData)
                    table.sort(cashList, function (a, b) return a.val > b.val end)
                    self.friendCashData_ = cashList
                    self.view_:setListData(cashList)
                end          
            end
        end
    end
end

--领取昨天的奖励
function RankingPopupController:getYesterdayReward_()
    local time_ = os.time()
    bm.HttpService.POST(
        {
            mod = "Ranklist", 
            act = "yesterdayReward", 
            time = time_,
            sign = crypto.md5(time_ .. "1e2c206269c42354c6dae040bca194c8f") 
        }, 
        function(data)
            local recallData = json.decode(data)
            if recallData.code == 1 then
                self.view_:showGetRewardSuccess()
            elseif recallData.code == -6 then --已经领取过奖
                self.view_:showAlreadyGetReward()
            end
        end,
        function ()
        end)
end

function RankingPopupController:cancelAllRequest_()
    bm.HttpService.CANCEL(self.friendDataRequestId_)
    bm.HttpService.CANCEL(self.friendCashDataRequestScheduleHandle_)

    bm.HttpService.CANCEL(self.rankingDataRequestId_)
    bm.HttpService.CANCEL(self.totalProfitDataRequestId_)
end

function RankingPopupController:dispose()
    self:cancelAllRequest_()

    if self.friendDataRequestScheduleHandle_ then
        scheduler.unscheduleGlobal(self.friendDataRequestScheduleHandle_)
    end

    if self.friendCashDataRequestScheduleHandle_ then
        scheduler.unscheduleGlobal(self.friendCashDataRequestScheduleHandle_)
    end

    if self.rankingDataRequestScheduleHandle_ then
        scheduler.unscheduleGlobal(self.rankingDataRequestScheduleHandle_)
    end

    if self.totalProfitDataRequestScheduleHandle_ then
        scheduler.unscheduleGlobal(self.totalProfitDataRequestScheduleHandle_)
    end

    if self.yesterdayChampionDataRequestScheduleHandle_ then
        scheduler.unscheduleGlobal(self.yesterdayChampionDataRequestScheduleHandle_)
    end
end

return RankingPopupController