--
-- Author: KevinLiang@boyaa.com
-- Date: 2016-08-01 11:57:54
--
-- 任务元素

local DailyTasksListItem = class("DailyTasksListItem", bm.ui.ListItem)

local DailyTask = import(".DailyTask")

DailyTasksListItem.WIDTH = 745
DailyTasksListItem.HEIGHT = 115

local labelSize = 22
local labelColor = cc.c3b(0xEF, 0xEF, 0xEF)
local buttonSize = 22
local buttonColor = labelColor
local progressSize = 18
local progressColor = cc.c3b(0xEF, 0xEF, 0xEF)

function DailyTasksListItem:ctor()
    self:setNodeEventEnabled(true)
    DailyTasksListItem.super.ctor(self, DailyTasksListItem.WIDTH, DailyTasksListItem.HEIGHT)

    local width, height = DailyTasksListItem.WIDTH, DailyTasksListItem.HEIGHT

    display.newScale9Sprite("#pop_task_listitem_bg.png", self.width_ * 0.5, self.height_ * 0.5, cc.size(self.width_ - 40, self.height_ - 10), cc.rect(14, 14, 1, 1))
        :addTo(self)

    --图标
    self.iconWidth, self.iconHeight = 90, 90
    local iconMarginLeft = 40
    self.icon = display.newSprite("#pop_task_icon_default.png"):addTo(self):pos(self.iconWidth/2 + iconMarginLeft, self.height_ * 0.5)

    self.iconLoaderId_ = nk.ImageLoader:nextLoaderId() -- 图标加载id

    --名称
    self.nameLabel = ui.newTTFLabel({
            size = labelSize,
            color = labelColor,
            align = ui.TEXT_ALIGN_CENTER
        }):addTo(self)
    self.nameLabel:setAnchorPoint(cc.p(0, 0.5))
    self.nameLabel:pos(self.iconWidth + 60, height/2 + 16)

    --奖励
    self.rewardLabel = ui.newTTFLabel({
            size = labelSize,
            color = labelColor,
            align = ui.TEXT_ALIGN_CENTER
        }):addTo(self)
    self.rewardLabel:setAnchorPoint(cc.p(0, 0.5))
    self.rewardLabel:pos(width/2 + 60, height/2)

    --进度
    local progressWidth = 150
    local progressHeight = 20
    local progressMarginRight = 40
    self.progress = nk.ui.ProgressBar.new(
        "#pop_common_progress_bg.png", 
        "#pop_common_progress_img.png", 
        {
            bgWidth = progressWidth, 
            bgHeight = 26, 
            fillWidth = 34, 
            fillHeight = progressHeight
        }
    ):addTo(self):setValue(0.0)
    self.progress:setAnchorPoint(cc.p(1, 0.5))
    self.progress:pos(self.iconWidth + 60, height/2 - 20)

    --进度文字 
    self.progressLabel = ui.newTTFLabel({
            size = progressSize,
            color = progressColor,
            align = ui.TEXT_ALIGN_CENTER
        }):addTo(self.progress):pos(progressWidth/2, 0) 

    --奖励按钮
    local buttonWidth = 150
    local buttonHeight = 55
    self.rewardButton = cc.ui.UIPushButton.new({normal = "#common_btn_yellow_normal.png", pressed = "#common_btn_yellow_pressed.png"}, {scale9 = true})
        :setButtonLabel(ui.newTTFLabel({
            text = bm.LangUtil.getText("DAILY_TASK", "GET_REWARD"), 
            size = buttonSize, 
            color = buttonColor, 
            align = ui.TEXT_ALIGN_CENTER}))
        :onButtonClicked(buttontHandler(self, self.onGetReward_))
        :addTo(self)
        :pos(width - buttonWidth/2 - progressMarginRight, height/2)
        :setButtonSize(buttonWidth, buttonHeight)
        :hide()

    self.gotoButton = cc.ui.UIPushButton.new({normal = "#common_btn_blue_normal.png", pressed = "#common_btn_blue_pressed.png"}, {scale9 = true})
        :setButtonLabel(ui.newTTFLabel({
            text = bm.LangUtil.getText("PLAYER_BACK", "GOTO"), 
            size = buttonSize, 
            color = buttonColor, 
            align = ui.TEXT_ALIGN_CENTER}))
        :onButtonClicked(buttontHandler(self, self.onGotoTask_))
        :addTo(self)
        :pos(width - buttonWidth/2 - progressMarginRight, height/2)
        :setButtonSize(buttonWidth, buttonHeight)
        :hide()

    --已经完成
    self.finishLabel = ui.newTTFLabel({
            text = bm.LangUtil.getText("DAILY_TASK", "HAD_FINISH"), 
            size = buttonSize, 
            color = buttonColor, 
            align = ui.TEXT_ALIGN_CENTER,
            valign = ui.TEXT_VALIGN_CENTER,
            dimensions = cc.size(buttonWidth, buttonHeight)
        })
        :addTo(self)
        :pos(width - buttonWidth/2 - progressMarginRight, height/2)
        :hide()
        
end

function DailyTasksListItem:onDataSet(dataChanged, data)
    if dataChanged then
        -- print("onDataSet:", data.iconUrl, data.progress, data.target, data.id)
        self.task = data

        if data.iconUrl then
            nk.ImageLoader:loadAndCacheImage(
                self.iconLoaderId_, 
                data.iconUrl, 
                handler(self, self.onIconLoadComplete_)
            )
        elseif data.icon then
            self.icon:setSpriteFrame(display.newSpriteFrame(data.icon))
        end

        self.nameLabel:setString(data.name)
        if data.rewardDesc then
            self.rewardLabel:setString(data.rewardDesc)
        else
            self.rewardLabel:hide()
            self.nameLabel:pos(self.nameLabel:getPositionX(), DailyTasksListItem.HEIGHT * 0.5)
            self.nameLabel:setSystemFontSize(24)
        end

        if data.progress and data.target then
            self.progress:setValue(data.progress / data.target)
            self.progressLabel:setString(data.progress.."/"..data.target)
            if data.progress == 0 then
                self.progress.fill_:hide()
            end
        else
            self.progress:hide()
        end

        if data.status ==  DailyTask.STATUS_UNDER_WAY then
            self.rewardButton:hide()
            self.finishLabel:hide()
            self.gotoButton:show()
        elseif data.status ==  DailyTask.STATUS_CAN_REWARD then
            self.rewardButton:show()
            self.finishLabel:hide()
            self.gotoButton:hide()
        elseif data.status ==  DailyTask.STATUS_FINISHED then
            self.rewardButton:hide()
            self.finishLabel:show()
            self.gotoButton:hide()
        elseif data.status ==  DailyTask.STATUS_SPECIAL then
            self.gotoButton:setButtonLabelString("normal", bm.LangUtil.getText("MATCH", "MATCHDETAIL"))
            self.rewardButton:hide()
            self.finishLabel:hide()
            self.gotoButton:show()
        end
    end
end

function DailyTasksListItem:onIconLoadComplete_(success, sprite)
    if success then
        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()
        self.icon:setTexture(tex)
        self.icon:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
        self.icon:setScaleX(self.iconWidth / texSize.width)
        self.icon:setScaleY(self.iconHeight / texSize.height)
    end
end

function DailyTasksListItem:onGetReward_()
    bm.EventCenter:dispatchEvent({name = nk.DailyTasksEventHandler.GET_RWARD, data = self.task})
end

function DailyTasksListItem:onGotoTask_()
    bm.EventCenter:dispatchEvent({name = nk.DailyTasksEventHandler.GOTO_TASK, data = self.task})
end

function DailyTasksListItem:onCleanup()
    nk.ImageLoader:cancelJobByLoaderId(self.iconLoaderId_)
end

return DailyTasksListItem