--
-- Author: KevinLiang@boyaa.com
-- Date: 2016-08-01 11:57:54
--

local DailyTasksController = class("DailyTasksController")
local DailyTask = import(".DailyTask")
local Achieve = import(".Achieve")


function DailyTasksController:ctor()
    self.allTaskList = {}
    self.allAchieveList = {}
end

function DailyTasksController:setData()
    self.allTaskList = nil  
    self.schedulerPool = bm.SchedulerPool.new()
    self.isBusy = false

    self.schedulerPool:delayCall(function()
        self:getTasksListData(true)
    end, 0.5)
end

function DailyTasksController:getTasksListData(init)
    if not self.isBusy then
        self.isBusy = true
        self.allTaskList = nil
        self.allTaskList = {}

        bm.HttpService.POST(
            {
                mod = "Task",
                act = "getListVTwo"
            },
            function(data)
                if CF_DEBUG > 1 then
                    print("task.list::"..data)
                end

                local retData = json.decode(data)
                if retData and retData.ret == 0 then
                    self:setTaskDataFromJSONObject(retData, init)
                end
            end,
            function() end
        )
    end
end

function DailyTasksController:getAchieveListData(init)
    if not self.isAchieveBusy then
        self.isAchieveBusy = true
        self.allAchieveList = nil
        self.allAchieveList = {}

        bm.HttpService.POST(
            {
                mod = "Achievement",
                act = "get"
            },
            function(data)
                if CF_DEBUG then
                    print("Achievement.list::"..data)
                end

                local retData = json.decode(data)
                if retData and retData.ret == 0 then
                    self:setAchieveDataFromJSONObject(retData, init)
                end
            end,
            function() end
        )
    end
end

function DailyTasksController:setTaskDataFromJSONObject(retData, init)
    if retData and retData.list then
        for k,v in pairs(retData.list) do
            v.iconUrl = retData.cdn .. v.image
        end
    end

    self:processTask(retData.list, retData.loginReward, retData.signin)
    if not init then 
        bm.EventCenter:dispatchEvent({name = nk.DailyTasksEventHandler.LOAD_TASK_LIST_ALREAD, data = self.allTaskList}) 
    end

    bm.DataProxy:setData(nk.dataKeys.NEW_REWARD_TASK, self:checkCanRewardTask())

    self.isBusy = false
end

function DailyTasksController:setAchieveDataFromJSONObject(retData, init)

    if retData and retData.list then
        for k,v in pairs(retData.list) do
            v.iconUrl = retData.cdn .. v.image
            v.id = k
        end
    end

    self:processAchieve(retData.list)
    if not init then bm.EventCenter:dispatchEvent({name = nk.DailyTasksEventHandler.LOAD_ACHIEVE_LIST_ALREAD, 
        data = self.allAchieveList}) end
    bm.DataProxy:setData(nk.dataKeys.NEW_REWARD_ACHIEVE, self:checkCanRewardAchieve())

    self.isAchieveBusy = false
end

function DailyTasksController:checkCanRewardTask()
    for _,task in pairs(self.allTaskList) do
        if task and task.status == DailyTask.STATUS_CAN_REWARD then
            return true
        end
    end
    return false
end

function DailyTasksController:checkCanRewardAchieve()
    for _,achieve in pairs(self.allAchieveList) do
        if achieve and achieve.status == Achieve.STATUS_CAN_REWARD then
            return true
        end
    end
    return false
end

function DailyTasksController:processTask(taskList, loginReward_, signin_)
    if taskList then
        for _,v in pairs(taskList) do
            if v then
                local task = DailyTask.new()
                task:fromJSON(v)
                table.insert(self.allTaskList, task)
            end
        end
        local curScene = display.getRunningScene()
        if nk.userData.switchAct and nk.userData.switchAct == 1 then
            if curScene.name == "HallScene" then
                local task = DailyTask.new()
                task.id = 1103
                task.name = bm.LangUtil.getText("CARD_ACT", "TITLE")
                task.sort = 1
                task.icon = "card_activity_icon.png"
                task.goto = 1103
                task.status = DailyTask.STATUS_SPECIAL
                task.subtask = {}

                table.insert(self.allTaskList, task)
            end
        end

        if loginReward_ and loginReward_ == 1 and curScene.name == "HallScene" then
            local task = DailyTask.new()
            task.id = DailyTask.LOGINREWARD_TASK_ID
            task.name = DailyTask.LOGINREWARD_TASK_NAME
            task.sort = DailyTask.LOGINREWARD_TASK_SORT
            task.icon = DailyTask.LOGINREWARD_TASK_ICON
            task.goto = DailyTask.LOGINREWARD_TASK_GOTO
            task.status = DailyTask.STATUS_SPECIAL
            task.subtask = {}

            table.insert(self.allTaskList, task)
        end

        self:sortTask()
    end
end

function DailyTasksController:sortTask()
    if self.allTaskList then
        for _,v in pairs(self.allTaskList) do
            v:update()
        end
        table.sort(self.allTaskList, function(o1, o2)
            if o1.status == o2.status then
                if o1.progress and o1.target and o2.progress and o2.target then
                    local p1 = o1.progress*1.0/o1.target
                    local p2 = o2.progress*1.0/o2.target
                    if math.abs(p1 - p2) < 0.02 then
                        return o1.sort > o2.sort
                    else
                        return p1 > p2
                    end
                else
                    return o1.sort > o2.sort
                end
            else
                return o1.status < o2.status
            end
        end)
    end
end

function DailyTasksController:processAchieve(AchieveList)
    if AchieveList then
        for _,v in pairs(AchieveList) do
            if v then
                local achieve = Achieve.new()
                achieve:fromJSON(v)
                table.insert(self.allAchieveList, achieve)
            end
        end
        table.sort(self.allAchieveList, function(o1, o2)
            return o1.sort > o2.sort
        end)
    end
end

--type:1 allin; 2. fb分享; 3.赠送荷官
function DailyTasksController:reportDailyTask(type, data)
    local params = {mod = "Task", act = "report"}
    if type == 1 then
        params.allin = 1
        if data and data.iswin then
            params.iswin = data.iswin
        end
    elseif type == 2 then
        params.sharefb = 1
    elseif type == 3 then
        params.senddealer = 1
    elseif type == 4 and data then
        if data.cardType == consts.CARD_TYPE.FLUSH then
            params.flush = 1
        elseif data.cardType == consts.CARD_TYPE.STRAIGHT then
            params.straight = 1
        elseif data.cardType == consts.CARD_TYPE.ROYAL then
            params.xsg = 1
        elseif data.cardType == consts.CARD_TYPE.STRAIGHT_FLUSH then
            params.straight_flush = 1
        elseif data.cardType == consts.CARD_TYPE.THREE_KIND then
            params.dsg = 1
        end
    end
    if data and data.isgcoin then
        params.isgcoin = data.isgcoin
    end
    bm.HttpService.POST(params,
        function(data)
        end,
        function() end
    )
end


function DailyTasksController:onGetReward_(evt)
    local curScene = display.getRunningScene()
    if curScene.name == "HallScene" then
        bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="Wheel_start"})
    end
    local task = evt.data
    local time = os.time()
    bm.HttpService.POST(
            {
                mod = "Task",
                act = "rewardVTwo",
                id = task.id,
                subtask = task.currentSubTaskId or 0,
            },
            function(data)
                if CF_DEBUG then
                    -- print("TaskData:::"..tostring(data))
                end
                
                local retData = json.decode(data)
                if retData.ret == 0 then

                    local str = ""
                    if task.reward.money and task.reward.money ~= 0 then
                        str = bm.LangUtil.getText("DAILY_TASK", "CHIP_REWARD", task.reward.money)
                        retData.money = task.reward.money
                    end

                    if str ~= "" then
                        nk.TopTipManager:showTopTip(str)
                    end
                    if task.subtask and task.subtask[task.currentSubTaskIndex] then
                        task.subtask[task.currentSubTaskIndex].rewarded = 1
                    end
                    -- 
                    if curScene.name == "HallScene" then
                        self:playBoxRewardAnimation_(retData)
                    end
                else
                    print("onGetReward_", retData.ret)
                    if curScene.name == "HallScene" then
                        bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="Wheel_end"})
                    end
                end
                self:sortTask()
                bm.EventCenter:dispatchEvent({name = nk.DailyTasksEventHandler.GET_RWARD_ALREADY, data = self.allTaskList})
                bm.DataProxy:setData(nk.dataKeys.NEW_REWARD_TASK, self:checkCanRewardTask())
            end,
            function()
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("TIPS", "ERROR_TASK_REWARD"))
                if curScene.name == "HallScene" then
                    bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="Wheel_end"})
                end
            end
        )
end

function DailyTasksController:onGetAchieveReward_(evt)
    local curScene = display.getRunningScene()
    if curScene.name == "HallScene" then
        bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="Wheel_start"})
    end
    local achieve = evt.data
    local time = os.time()
    bm.HttpService.POST(
            {
                mod = "Achievement",
                act = "reward",
                id = achieve.id,
                subtask = achieve.currentSubTaskId or 0,
            },
            function(data)
                
                local retData = json.decode(data)
                if retData.ret == 0 then

                    local str = ""
                    if achieve.reward and achieve.reward ~= 0 then
                        str = bm.LangUtil.getText("DAILY_TASK", "CHIP_REWARD", achieve.reward)
                        retData.money = achieve.reward
                    end

                    if str ~= "" then
                        nk.TopTipManager:showTopTip(str)
                    end
                    if achieve.subtask and achieve.subtask[achieve.currentSubTaskIndex] then
                        achieve.subtask[achieve.currentSubTaskIndex].rewarded = 1
                        achieve:update()
                    end
                    -- 
                    if curScene.name == "HallScene" then
                        self:playBoxRewardAnimation_(retData)
                    end
                else
                    print("onGetReward_", retData.ret)
                    if curScene.name == "HallScene" then
                        bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="Wheel_end"})
                    end
                end
                bm.EventCenter:dispatchEvent({name = nk.DailyTasksEventHandler.GET_ACHIEVE_RWARD_ALREADY, data = self.allAchieveList})
                bm.DataProxy:setData(nk.dataKeys.NEW_REWARD_ACHIEVE, self:checkCanRewardAchieve())
            end,
            function()
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("TIPS", "ERROR_TASK_REWARD"))
                if curScene.name == "HallScene" then
                    bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="Wheel_end"})
                end
            end
        )
end

function DailyTasksController:playBoxRewardAnimation_(retData)
    local rewards = {};
    local info;
    if retData.money and retData.money ~= 0 then 
        info={};
        info.type = 1;
        info.icon = "match_chip.png"
        info.txt = bm.LangUtil.getText("MATCH", "MONEY").." + "..tostring(retData.money)
        info.num = bm.formatBigNumber(retData.money);
        info.val = retData.money;
        table.insert(rewards, #info+1, info)
    end

    if #rewards > 0 then
        nk.UserInfoChangeManager:playBoxRewardAnimation(nk.UserInfoChangeManager.MainHall, rewards, true)
    end
end


return DailyTasksController
