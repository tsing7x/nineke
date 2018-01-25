

local DailyTasksPopup = class("DailyTasksPopup", nk.ui.Panel)
local LoginRewardView   = import("app.module.loginreward.LoginRewardView")
local DailyTask = import(".DailyTask")
local DailyTasksListItem = import(".DailyTasksListItem")
local AchievementTasksListItem = import(".AchievementTasksListItem")

local POP_WIDTH = 896
local POP_HEIGHT = 544
local LIST_WIDTH = 860
local LIST_HEIGHT = 394

DailyTasksPopup.LOAD_TASK_LIST_ALREAD_EVENT_TAG = 99100
DailyTasksPopup.GET_REWARD_ALREAD_EVENT_TAG = 99101
DailyTasksPopup.ON_REWARD_ALREAD_EVENT_TAG = 99102
DailyTasksPopup.GOTO_TASK = 99111

DailyTasksPopup.LOAD_ACHIEVE_LIST_ALREAD_EVENT_TAG = 99200
DailyTasksPopup.GET_ACHIEVE_REWARD_ALREAD_EVENT_TAG = 99201
DailyTasksPopup.ON_ACHIEVE_REWARD_ALREAD_EVENT_TAG = 99202

function DailyTasksPopup:ctor()
    DailyTasksPopup.super.ctor(self, {POP_WIDTH, POP_HEIGHT})

    self:setupView()
    bm.EventCenter:addEventListener(nk.DailyTasksEventHandler.LOAD_TASK_LIST_ALREAD, handler(self, self.loadDataCallback), DailyTasksPopup.LOAD_TASK_LIST_ALREAD_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.DailyTasksEventHandler.GET_RWARD, handler(self, self.onGetReward_), DailyTasksPopup.GET_REWARD_ALREAD_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.DailyTasksEventHandler.GET_RWARD_ALREADY, handler(self, self.onGetRewardAlready_), DailyTasksPopup.ON_REWARD_ALREAD_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.DailyTasksEventHandler.GOTO_TASK, handler(self, self.goto_), DailyTasksPopup.GOTO_TASK)

    bm.EventCenter:addEventListener(nk.DailyTasksEventHandler.LOAD_ACHIEVE_LIST_ALREAD, handler(self, self.loadAchieveDataCallback), DailyTasksPopup.LOAD_ACHIEVE_LIST_ALREAD_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.DailyTasksEventHandler.GET_ACHIEVE_RWARD, handler(self, self.onGetReward_), DailyTasksPopup.GET_ACHIEVE_REWARD_ALREAD_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.DailyTasksEventHandler.GET_ACHIEVE_RWARD_ALREADY, handler(self, self.onGetAchieveRewardAlready_), DailyTasksPopup.ON_ACHIEVE_REWARD_ALREAD_EVENT_TAG)

    self:setNodeEventEnabled(true)

    local curScene = display.getRunningScene()
    if curScene.name == "HallScene" then
        if curScene.controller_ then
            self.hall_controller_ = curScene.controller_
        end
    end
end

function DailyTasksPopup:onExit()
    bm.EventCenter:removeEventListenersByTag(DailyTasksPopup.LOAD_TASK_LIST_ALREAD_EVENT_TAG)
    bm.EventCenter:removeEventListenersByTag(DailyTasksPopup.GET_REWARD_ALREAD_EVENT_TAG)
    bm.EventCenter:removeEventListenersByTag(DailyTasksPopup.ON_REWARD_ALREAD_EVENT_TAG)
    bm.EventCenter:removeEventListenersByTag(DailyTasksPopup.GOTO_TASK)
    nk.schedulerPool:delayCall(function()
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end, 0.1)

    bm.EventCenter:removeEventListenersByTag(DailyTasksPopup.LOAD_ACHIEVE_LIST_ALREAD_EVENT_TAG)
    bm.EventCenter:removeEventListenersByTag(DailyTasksPopup.GET_ACHIEVE_REWARD_ALREAD_EVENT_TAG)
    bm.EventCenter:removeEventListenersByTag(DailyTasksPopup.ON_ACHIEVE_REWARD_ALREAD_EVENT_TAG)
end

function DailyTasksPopup:setupView()
    local width, height = POP_WIDTH, POP_HEIGHT

    --修改背景框
    self:setBackgroundStyle1()

    -- tab
    self.tabBar = nk.ui.CommonPopupTabBar.new(
        {
            popupWidth = POP_WIDTH,
            scale = 468/POP_WIDTH,
            iconOffsetX = 10,
            btnText = bm.LangUtil.getText("DAILY_TASK", "TAB_TEXT"),
        })
        :pos(0, self.height_ * 0.5 - nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5 - 40)
        :addTo(self)

    self:addTopDivide(nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5 + 8)
    self:addTopIcon("#pop_task_icon.png", 0)  

    --内容
    local container = display.newNode():addTo(self)

    local topMargin = 60
    local contentPadding = 12
    local contentWidth = width - contentPadding * 2
    local contentHeight = height - topMargin

    --内容列表
    self.listPosY_ = - nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5 - 16  --设置任务列表的偏移量
    DailyTasksListItem.WIDTH = contentWidth
    AchievementTasksListItem.WIDTH = contentWidth

    --任务列表
    self.taskListView = bm.ui.ListView.new({viewRect = cc.rect(-LIST_WIDTH * 0.5, -LIST_HEIGHT * 0.5, LIST_WIDTH, LIST_HEIGHT), 
                                direction = bm.ui.ListView.DIRECTION_VERTICAL}, 
                                DailyTasksListItem):addTo(container)
        :pos(0, self.listPosY_)
    self:getTasksListData()--获取任务列表

    --成就列表
    self.achievementListView = bm.ui.ListView.new({viewRect = cc.rect(-LIST_WIDTH * 0.5, -LIST_HEIGHT * 0.5, LIST_WIDTH, LIST_HEIGHT), 
                                direction = bm.ui.ListView.DIRECTION_VERTICAL}, 
                                AchievementTasksListItem):addTo(container)
        :pos(0, self.listPosY_)
        :hide()

    self:addCloseBtn()
    self:setCloseBtnOffset(0, -16)
end

function DailyTasksPopup:show()
    nk.PopupManager:addPopup(self)
    return self
end

function DailyTasksPopup:close()
    nk.PopupManager:removePopup(self)
    return self
end

function DailyTasksPopup:onClose()
    self:close()
end

function DailyTasksPopup:onShowed()
    self.tabBar:onTabChange(handler(self, self.onTabChange))
    if self.taskListData then
        self.taskListView:setData(self.taskListData)
        self:setLoading(false)
    end

    if self.achievementListData then
        self.achievementListView:setData(self:transformAchievementTasksData(self.achievementListData))
        self:setLoading(false)
    end
    self.isShowed = true

    if self.taskListView then
        self.taskListView:setScrollContentTouchRect()
        self.taskListView:update()
    end

    if self.achievementListView then
        self.achievementListView:setScrollContentTouchRect()
        self.achievementListView:update()
    end
end

function DailyTasksPopup:transformAchievementTasksData(taskData)
    local ret = {}
    local row_num = AchievementTasksListItem.ROW_NUM
    if taskData then
        for i = 1, #taskData do
            local m = math.floor(i / row_num) + 1
            local n = i % row_num
            if n == 0 then
                n = row_num
                m = m - 1
            end
            if not ret[m] then
                ret[m] = {}
            end
            ret[m][n] = taskData[i]
        end
    end
    return ret
end

function DailyTasksPopup:getTasksListData()
    self:setLoading(true)
    bm.EventCenter:dispatchEvent(nk.DailyTasksEventHandler.GET_TASK_LIST)
end

function DailyTasksPopup:getAchieveListData()
    self:setLoading(true)
    bm.EventCenter:dispatchEvent(nk.DailyTasksEventHandler.GET_ACHIEVE_LIST)
end

function DailyTasksPopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
                :pos(0, self.listPosY_)
                :addTo(self)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

function DailyTasksPopup:loadDataCallback(evt)
    self.taskListData = evt.data
    if self.isShowed then
        self.taskListView:setData(self.taskListData)
        self:setLoading(false)
    end
    dump(self.taskListData)
    --print("请求任务列表返回")
    --self:setLoading(false)
end

function DailyTasksPopup:loadAchieveDataCallback(evt)
    self.achievementListData = evt.data
    if self.isShowed then
        self.achievementListView:setData(self:transformAchievementTasksData(self.achievementListData))
        self:setLoading(false)
    end
end

function DailyTasksPopup:onTabChange(selectedTab)
    self.selectedTab = selectedTab
    if selectedTab == 1 then
        self.taskListView:show()
        self.achievementListView:hide()
    else
        if not self.achievementListData then
            self:getAchieveListData()
        end
        self.taskListView:hide()
        self.achievementListView:show()
    end
end

function DailyTasksPopup:onGetReward_()
    self:setLoading(true)
end

--     1 => '普通场',
--     2 => '中级场',
--     3 => '高级场',
--     4 => '比赛场大厅',
--     5 => '快速开始',
--     6 => '好友弹窗',
--     7 => '邀请页面',
--     8 => '打开大转盘',
--     9 => '打开礼物弹窗',
--     10 => '打开老虎机',
--     11 => '打开宝箱',
--     12 => '打开彩票',
--     13 => '打开足球彩票',
--     15 => '绑定手机'
function DailyTasksPopup:goto_(evt)
    local task = evt.data
    if task.goto == 1 or task.goto == 2 or task.goto == 3 then
        if self.hall_controller_ then
            local last = nil
            if nk.userData.lastChooseRoomType then
                last = nk.userData.lastChooseRoomType
                if (last == self.hall_controller_.CHOOSE_4K_VIEW or last == self.hall_controller_.CHOOSE_5K_VIEW) 
                        and task.goto == 1 then
                    last = self.hall_controller_.CHOOSE_PRO_VIEW
                end
            end
            self.hall_controller_:showChooseRoomView(last 
                or self.hall_controller_.CHOOSE_PRO_VIEW, task.goto)
        end
    elseif task.goto == 4 then
        if self.hall_controller_ then
            self.hall_controller_:onEnterMatch()
        end
    elseif task.goto == 5 then
        if self.hall_controller_ then
            self.hall_controller_:getEnterRoomData(nil, true)
        end
    elseif task.goto == 6 then
        local FriendPopup = import("app.module.friend.FriendPopup")
        FriendPopup.new():show()
    elseif task.goto == 7 then
        local InvitePopup = import("app.module.friend.InvitePopup")
        InvitePopup.new():show()
    elseif task.goto == 8 then
        local HallController = import("app.module.hall.HallController")
        local LuckWheelFreePopup = import("app.module.luckturn.LuckWheelFreePopup")
        LuckWheelFreePopup.load(self.hall_controller_, HallController.MAIN_HALL_VIEW)
    elseif task.goto == 9 then
        local GiftShopPopup = import("app.module.gift.GiftShopPopup")
        GiftShopPopup.new(2):show(false, nk.userData.uid)
    elseif task.goto == 10 then
        if self.hall_controller_ then
            self.hall_controller_:showSlotPopup()
        end
    elseif task.goto == 11 then
        local CrazedBoxPopup = import("app.module.crazedbox.CrazedBoxPopup")
        display.addSpriteFrames("crazed_box_texture.plist", "crazed_box_texture.png",function()
            CrazedBoxPopup.new():show()
        end)
    elseif task.goto == 12 then
        local LotteryPopup = import("app.module.lottery.LotteryPopup")
        LotteryPopup.new():show()
    elseif task.goto == 13 then
        local FootballQuizPopup = import("app.module.football.FootballQuizPopup")
        display.addSpriteFrames("football_quiz_texture.plist", "football_quiz_texture.png", function()
            FootballQuizPopup.new():showPanel()
        end)
    elseif task.goto == 15 then
        local PhoneBind = import("app.module.dailytasks.PhoneBindPopup")
        PhoneBind.new():show()
        -- local activityTitle = import("app.module.activity.ActivityTitle")
        -- activityTitle.new(111,111):show()
        
        --bm.EventCenter:dispatchEvent({name = "onGotoOrdinaryHallEvent", data = nil})

    elseif task.goto == DailyTask.LOGINREWARD_TASK_GOTO then
        nk.userData.popup = nil
        nk.PopupManager:addPopup(LoginRewardView.new(false),true, true, true, true)
    elseif task.goto == 1103 then
        local CardActPopup        = import("app.module.newestact.CardActPopup")
        CardActPopup.new():show()
    end
    self:close()
end

function DailyTasksPopup:onGetRewardAlready_(evt)
    self.taskListView:setData(nil)
    self.taskListView:setData(evt.data)
    self:setLoading(false)
end

function DailyTasksPopup:onGetAchieveRewardAlready_(evt)
    self.achievementListView:setData(nil)
    self.achievementListView:setData(self:transformAchievementTasksData(evt.data))
    self:setLoading(false)
end

return DailyTasksPopup