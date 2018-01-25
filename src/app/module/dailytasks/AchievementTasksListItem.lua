--
-- Author: KevinLiang@boyaa.com
-- Date: 2016-08-01 11:57:54
--
local AchievementTasksListItem = class("AchievementTasksListItem", bm.ui.ListItem)
local DisplayUtil = import("boomegg.util.DisplayUtil")
local Achieve = import(".Achieve")
local AchievementRewardPopup = import(".AchievementRewardPopup")
local AchievementTipsPopup = import(".AchievementTipsPopup")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

AchievementTasksListItem.WIDTH = 745
AchievementTasksListItem.HEIGHT = 204
AchievementTasksListItem.ROW_NUM = 4

local labelSize = 22
local labelColor = cc.c3b(0xEF, 0xEF, 0xEF)
local buttonSize = 20
local buttonColor = labelColor
local progressSize = 18
local progressColor = cc.c3b(0xEF, 0xEF, 0xEF)

function AchievementTasksListItem:ctor()
    self:setNodeEventEnabled(true)
    AchievementTasksListItem.super.ctor(self, AchievementTasksListItem.WIDTH, AchievementTasksListItem.HEIGHT)

    --图标
    self.iconWidth, self.iconHeight = 90, 90
    local posY = self.height_ * 0.5
    local star_distance = 30
    local star_pos_y = -19
    local ITEM_DISTANCE = 194
    self.item_nodes = {}
    self.item_lights = {}
    self.item_icons = {}
    self.iconLoaderIds = {}
    self.item_stars_bg = {}
    self.item_stars = {}
    self.item_buttons = {}
    self.item_names = {}
    self.item_progress = {}
    self.item_progress_labels = {}
    self.item_reward_buttons = {}
    self.item_reward_icons = {}
    self.item_reward_labels = {}
    self.finishLabels = {}

    for i = 1, AchievementTasksListItem.ROW_NUM do
        self.item_nodes[i] = display.newNode():addTo(self):pos(150 + ITEM_DISTANCE * (i - 1), posY + 16)

        self.item_lights[i] = display.newSprite("#pop_task_achieve_light.png")
            :addTo(self.item_nodes[i]):pos(0, 6)
        display.newSprite("#pop_task_achieve_light_point.png")
            :addTo(self.item_lights[i]):pos(80, 80)

        self.item_icons[i] = display.newSprite("#achievement_task_default.png")
            :addTo(self.item_nodes[i]):pos(0, 6)

        self.iconLoaderIds[i] = nk.ImageLoader:nextLoaderId() -- 图标加载id

        self.item_buttons[i] = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png"},{scale9 = true})
            :setButtonSize(self.item_icons[i]:getContentSize().width, self.item_icons[i]:getContentSize().height)
            :addTo(self.item_nodes[i])
            :onButtonClicked(function(evt)
                    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                    self:onIconClick(i)
                end)
        self.item_buttons[i]:setTouchSwallowEnabled(false)

        
        self.item_stars_bg[i] = display.newSprite("#pop_task_achieve_star_bg.png")
            :addTo(self.item_nodes[i]):pos(0, star_pos_y - 11)
        self.item_stars[i] = {}
        for k = 1, 3 do
            display.newSprite("#pop_task_achieve_star_gray.png")
                :addTo(self.item_nodes[i]):pos((k - 2) * star_distance, star_pos_y - (k % 2) * 3)
            self.item_stars[i][k] = display.newSprite("#pop_task_achieve_star_light.png")
                :addTo(self.item_nodes[i]):pos((k - 2) * star_distance, star_pos_y - (k % 2) * 3)
            self.item_stars[i][k]:hide()
        end

        --名称
        self.item_names[i] = ui.newTTFLabel({
                text = "",
                size = labelSize,
                color = labelColor,
                align = ui.TEXT_ALIGN_CENTER
            }):addTo(self.item_nodes[i])
        self.item_names[i]:pos(0, -72)

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
        ):addTo(self.item_nodes[i]):setValue(0)
        self.item_progress[i]:setAnchorPoint(cc.p(1, 0.5))
        self.item_progress[i]:pos(-progress_width * 0.5, -100)

        --进度文字 
        self.item_progress_labels[i] = ui.newTTFLabel({
                text = "",
                size = progressSize,
                color = progressColor,
                align = ui.TEXT_ALIGN_CENTER
            }):addTo(self.item_progress[i]):pos(progress_width * 0.5, 0) 


        self.item_reward_buttons[i] = cc.ui.UIPushButton.new({normal = "#pop_task_achieve_button_normal.png", pressed = "#pop_task_achieve_button_pressed.png"}, {scale9 = true})
            :setButtonLabel(ui.newTTFLabel({
                text = "", 
                size = buttonSize, 
                color = buttonColor, 
                align = ui.TEXT_ALIGN_CENTER}))
            :setButtonLabelOffset(12, 2)
            :onButtonClicked(function(evt)
                    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                    self:onGetReward_(i)
                end)
            :addTo(self.item_nodes[i])
            :pos(0, -100)
            :setButtonSize(86, 32)
        self.item_reward_icons[i] = display.newSprite("#chip_icon.png")
            :addTo(self.item_reward_buttons[i]):pos(-26, 2)
            :scale(0.7)

        --已经完成
        self.finishLabels[i] = ui.newTTFLabel({
                text = bm.LangUtil.getText("DAILY_TASK", "HAD_FINISH"), 
                size = buttonSize, 
                color = buttonColor, 
                align = ui.TEXT_ALIGN_CENTER,
                valign = ui.TEXT_VALIGN_CENTER,
            })
            :addTo(self.item_nodes[i])
            :pos(0, -100)
            :hide()
    end
end

function AchievementTasksListItem:onDataSet(dataChanged, data)
    if dataChanged then
        self.task = data
        for i = 1, #data do
            nk.ImageLoader:loadAndCacheImage(
                    self.iconLoaderIds[i], 
                    data[i].iconUrl, 
                    handler(self, self.onIconLoadComplete_)
                )

            self.item_names[i]:setString(data[i].name)
            self.item_reward_buttons[i]:setButtonLabelString("normal", data[i].reward)

            if data[i].status ==  Achieve.STATUS_UNDER_WAY then
                self.item_progress[i]:setValue(data[i].progress / data[i].target)
                self.item_progress_labels[i]:setString(bm.formatBigNumber(data[i].progress) .. "/" .. bm.formatBigNumber(data[i].target))
                if data[i].progress == 0 then
                    self.item_progress[i].fill_:hide()
                end
                
                self.item_lights[i]:hide()
                self.item_reward_buttons[i]:hide()
                self.finishLabels[i]:hide()

                if data[i].currentSubTaskIndex > 1 then
                    for k = 1, data[i].currentSubTaskIndex - 1 do
                        self.item_stars[i][k]:show()
                    end
                else
                    DisplayUtil.setGray(self.item_icons[i])
                    DisplayUtil.setGray(self.item_stars_bg[i])
                end
            elseif data[i].status ==  Achieve.STATUS_CAN_REWARD then
                self.item_progress[i]:hide()
                self.item_lights[i]:show()
                self.item_reward_buttons[i]:show()
                self.finishLabels[i]:hide()

                for k = 1, data[i].currentSubTaskIndex do
                    self.item_stars[i][k]:show()
                end
            elseif data[i].status ==  Achieve.STATUS_FINISHED then
                self.item_progress[i]:hide()
                self.item_lights[i]:hide()
                self.item_reward_buttons[i]:hide()
                self.finishLabels[i]:show()

                for k = 1, 3 do
                    self.item_stars[i][k]:show()
                end
            end
        end
        if #data < AchievementTasksListItem.ROW_NUM then
            for i = #data + 1, AchievementTasksListItem.ROW_NUM do
                self.item_nodes[i]:hide()
            end
        end
    end
end

function AchievementTasksListItem:onIconLoadComplete_(success, sprite, loadId)
    if success then
        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()

        local index = nil
        for i = 1, AchievementTasksListItem.ROW_NUM do
            if self.iconLoaderIds[i] == loadId then
                index = i
            end
        end
        if index and index > 0 and index <= AchievementTasksListItem.ROW_NUM then
            self.item_icons[index]:setTexture(tex)
            self.item_icons[index]:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
        end
    end
end

function AchievementTasksListItem:onGetReward_(index)
    local texture = self.item_icons[index]:getTexture()
    local data = clone(self.task[index])
    bm.EventCenter:dispatchEvent({name = nk.DailyTasksEventHandler.GET_ACHIEVE_RWARD, data = self.task[index]})
    scheduler.performWithDelayGlobal(function ()
                if texture and data then
                    AchievementRewardPopup.new(texture, data):show()
                end
            end, 2.5)
end

function AchievementTasksListItem:onIconClick(index)
    if self.owner_.tips then
        self.owner_.tips:stopAllActions()
        self.owner_.tips:removeFromParent()
        self.owner_.tips = nil
    end
    local str_len = string.len(self.task[index].task_desc)
    local w = 60 + str_len
    local tips = AchievementTipsPopup.new(self.task[index].task_desc, 18, cc.size(w, 120))
    local x = self.item_nodes[index]:getPositionX() + 80 + w * 0.5
    if index > 2 then
        x = self.item_nodes[index]:getPositionX() - 80 - w * 0.5
    end
    tips:pos(x, self.item_nodes[index]:getPositionY()):addTo(self)
    tips:runAction(transition.sequence({cc.DelayTime:create(2), cc.CallFunc:create(function() 
            tips:removeFromParent()
            self.owner_.tips = nil
        end)}))
    self.owner_.tips = tips
end

function AchievementTasksListItem:onCleanup()
    for i = 1, AchievementTasksListItem.ROW_NUM do
        nk.ImageLoader:cancelJobByLoaderId(self.iconLoaderIds[i])
    end
end

return AchievementTasksListItem