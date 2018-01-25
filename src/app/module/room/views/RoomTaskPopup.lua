--
-- Author: KevinLiang@boyaa.com
-- Date: 2016-07-29 11:57:54
--
local RoomTaskPopup = class("RoomTaskPopup", function() return display.newNode() end)
local DailyTask = import("app.module.dailytasks.DailyTask")
local WIDTH = 350
local HEIGHT = 378
local TEXT_COLOR = cc.c3b(0xEE, 0xEE, 0xEE)

RoomTaskPopup.LOAD_TASK_LIST_ALREAD_EVENT_TAG = 93100
RoomTaskPopup.GET_REWARD_ALREAD_EVENT_TAG = 93101
RoomTaskPopup.ON_REWARD_ALREAD_EVENT_TAG = 93102
RoomTaskPopup.UPDATE_BOX_TASK = 93103

function RoomTaskPopup:ctor()
    self:setNodeEventEnabled(true)
    self:setupView()
    self:pos(display.width + WIDTH * 0.5, HEIGHT * 0.5 + 164)

    bm.EventCenter:addEventListener(nk.DailyTasksEventHandler.LOAD_TASK_LIST_ALREAD, handler(self, self.loadDataCallback), RoomTaskPopup.LOAD_TASK_LIST_ALREAD_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.DailyTasksEventHandler.GET_RWARD, handler(self, self.onGetReward_), RoomTaskPopup.GET_REWARD_ALREAD_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.DailyTasksEventHandler.GET_RWARD_ALREADY, handler(self, self.loadDataCallback), RoomTaskPopup.ON_REWARD_ALREAD_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.DailyTasksEventHandler.UPDATE_BOX_TASK, handler(self, self.updateCountDownBox), RoomTaskPopup.UPDATE_BOX_TASK)

    self:getTasksListData()
end

function RoomTaskPopup:onCleanup()
    bm.EventCenter:removeEventListenersByTag(RoomTaskPopup.LOAD_TASK_LIST_ALREAD_EVENT_TAG)
    bm.EventCenter:removeEventListenersByTag(RoomTaskPopup.GET_REWARD_ALREAD_EVENT_TAG)
    bm.EventCenter:removeEventListenersByTag(RoomTaskPopup.ON_REWARD_ALREAD_EVENT_TAG)
    bm.EventCenter:removeEventListenersByTag(RoomTaskPopup.UPDATE_BOX_TASK)
end

function RoomTaskPopup:setupView()
    local bg = display.newScale9Sprite("#room_task_bg.png", 0, 0, cc.size(WIDTH, HEIGHT)):pos(0, 0):addTo(self)
	bg:setTouchEnabled(true)
    bg:setTouchSwallowEnabled(true)

    display.newScale9Sprite("#room_task_bottom_bg.png", 0, 0, cc.size(WIDTH - 8, 70))
        :addTo(self):pos(0, -HEIGHT * 0.5 + 38)

    display.newSprite("#room_task_top_light.png")
        :addTo(self):pos(-120, HEIGHT * 0.5 - 18)

    display.newSprite("#room_task_bottom_light.png")
        :addTo(self):pos(120, -HEIGHT * 0.5 + 4)

    self.title_ = ui.newTTFLabel({
            text = bm.LangUtil.getText("HALL", "DAILY_MISSION"), 
            size = 28, 
            color = TEXT_COLOR, 
            align = ui.TEXT_ALIGN_CENTER,
        })
        :addTo(self, 4, 4)
        :pos(0, HEIGHT * 0.5 - 24)

    -- 内容
    local ITEM_DISTANCE = 82
    local name_pos_x = -144
    self.item_nodes = {}
    self.item_buttons = {}
    self.item_button_labels = {}
    self.item_names = {}
    self.item_progress = {}
    self.item_progress_labels = {}

    for i = 1, 3 do
        self.item_nodes[i] = display.newNode()
            :pos(0, 96 - ITEM_DISTANCE * (i - 1))
            :addTo(self)
            :hide()

        display.newScale9Sprite("#room_task_list_bg.png", 0, 0, cc.size(WIDTH - 18, 76))
            :addTo(self.item_nodes[i])

        --名称
        self.item_names[i] = ui.newTTFLabel({
                text = "",
                size = 22,
                color = TEXT_COLOR,
                align = ui.TEXT_ALIGN_CENTER
            })
            :align(display.LEFT_CENTER, name_pos_x + 8, 16)
            :addTo(self.item_nodes[i])

        --进度
        local progress_width = 120
        self.item_progress[i] = nk.ui.ProgressBar.new(
                "#pop_common_progress_bg.png", 
                "#pop_common_progress_img.png", 
                {
                    bgWidth = progress_width, 
                    bgHeight = 26, 
                    fillWidth = 34, 
                    fillHeight = 20
                }
            )
            :pos(name_pos_x, -12)
            :setValue(0)
            :addTo(self.item_nodes[i])

        --进度文字 
        self.item_progress_labels[i] = ui.newTTFLabel({
                text = "",
                size = 22,
                color = TEXT_COLOR,
                align = ui.TEXT_ALIGN_CENTER
            })
            :pos(progress_width * 0.5, 0)
            :addTo(self.item_progress[i])

        self.item_buttons[i] = cc.ui.UIPushButton.new({normal = "#room_task_button_yellow_normal.png", pressed = "#room_task_button_yellow_pressed.png"}, {scale9 = true})
            :setButtonSize(108, 48)
            :onButtonClicked(function(evt)
                nk.SoundManager:playSound(nk.SoundManager.BOX_OPEN_REWARD)
                self:onGetRewardBtnListener_(i)
            end)
            :pos(100, 0)
            :addTo(self.item_nodes[i])

        self.item_button_labels[i] = ui.newTTFLabel({
                text = "", 
                size = 24, 
                color = TEXT_COLOR, 
                align = ui.TEXT_ALIGN_CENTER
            })
            :pos(100, 0)
            :addTo(self.item_nodes[i])
    end

    local bottom_pos_y = -150
    display.newSprite("#room_task_clock.png")
        :pos(-140, bottom_pos_y)
        :addTo(self)

    self.time = ui.newTTFLabel({
            text = "", 
            size = 22, 
            color = TEXT_COLOR, 
            align = ui.TEXT_ALIGN_CENTER,
        })
        :addTo(self)
        :pos(-96, bottom_pos_y)
    
    self.getRewardButton = cc.ui.UIPushButton.new({normal = "#room_task_button_yellow_normal.png", pressed = "#room_task_button_yellow_pressed.png"},{scale9 = true})
        :setButtonSize(108, 48)
        :onButtonClicked(function(event)
            self:onGetRewardBtnListener_(0)
        end)
        :pos(100, bottom_pos_y)
        :addTo(self)

    self.getRewardButtonLabel = ui.newTTFLabel({
            text = "", 
            size = 24, 
            color = TEXT_COLOR, 
            align = ui.TEXT_ALIGN_CENTER
        })
        :pos(100, bottom_pos_y)
        :addTo(self) 
end

function RoomTaskPopup:setString(text)
    self.contentText:setString(text)
end

function RoomTaskPopup:updateUI()
    if self.taskData then
        local total = #self.taskData
        if total > 3 then
            total = 3
        end
        for i = 1, total do
            local task = self.taskData[i]
            self.item_nodes[i]:show()
            self.item_names[i]:setString(task.name)
            self.item_button_labels[i]:setString(task.rewardDesc)
            self.item_progress[i]:setValue(task.progress / task.target)
            self.item_progress_labels[i]:setString(task.progress.."/"..task.target)
            if task.progress == 0 then
                self.item_progress[i].fill_:hide()
            end

            if task.status ==  DailyTask.STATUS_UNDER_WAY then
                self.item_buttons[i]:hide()
            elseif task.status ==  DailyTask.STATUS_CAN_REWARD then
                self.item_buttons[i]:show()
            elseif task.status ==  DailyTask.STATUS_FINISHED then
                self.item_buttons[i]:hide()
                self.item_button_labels[i]:setString(bm.LangUtil.getText("DAILY_TASK", "HAD_FINISH"))
            end
        end

        if total < 3 then
            for k = total + 1, 3 do
                self.item_nodes[k]:hide()
            end
        end
    end
end

function RoomTaskPopup:getTasksListData()
    self:setLoading(true)
    bm.EventCenter:dispatchEvent(nk.DailyTasksEventHandler.GET_TASK_LIST)
end

function RoomTaskPopup:setCountDownBox(box)
    self.countDownBox = box
    if box then
        self:updateCountDownBox()
    end
end

function RoomTaskPopup:updateCountDownBox()
    local box = self.countDownBox
    if box then
        if box.isFinished then
            self.getRewardButtonLabel:setString(bm.LangUtil.getText("DAILY_TASK", "HAD_FINISH"))
            self.getRewardButton:hide()
        else
            local multipleStr = (box.multiple and tonumber(box.multiple) > 1 and "x" .. tostring(box.multiple)) or ""
            self.getRewardButtonLabel:setString(bm.LangUtil.getText("CRASH", "CHIPS", tostring(box.reward)) .. multipleStr)
            if box.remainTime > 0 then
                self.getRewardButton:hide()
                timeStr = bm.TimeUtil:getTimeString(box.remainTime)
                self.time:setString(timeStr)
            else
                self.getRewardButton:show()
                self.time:setString("00:00")
            end
        end
    end
end

function RoomTaskPopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
                :pos(0, 0)
                :addTo(self)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

function RoomTaskPopup:loadDataCallback(evt)
    self:setLoading(false)
    self.taskData = evt.data
    self:updateUI()
end

function RoomTaskPopup:onGetReward_()
    self:setLoading(true)
end

function RoomTaskPopup:onGetRewardBtnListener_(index_)
    if index_ then
        if index_ > 0 then
            local task = self.taskData[index_]
            bm.EventCenter:dispatchEvent({name = nk.DailyTasksEventHandler.GET_RWARD, data = task})
        else
            if self.countDownBox and self.countDownBox.getReward then
                self.countDownBox:getReward()
            end
        end
    end
end

function RoomTaskPopup:showPanel()
    nk.PopupManager:addPopup(self, true, false, true, false)
end

function RoomTaskPopup:hidePanel()
    nk.PopupManager:removePopup(self)
end

function RoomTaskPopup:onRemovePopup(removeFunc)
    self:stopAllActions()
    transition.moveTo(self, {time=0.2, x=display.width + WIDTH * 0.5, easing="OUT", onComplete=function() 
        removeFunc()
    end})
end

function RoomTaskPopup:onShowPopup()
    self:stopAllActions()
    transition.moveTo(self, {time=0.2, x=display.width - WIDTH * 0.5 - 10, easing="OUT", onComplete=function()
        if self.onShow then
            self:onShow()
        end
    end})
end

return RoomTaskPopup