--
-- Author: KevinLiang@boyaa.com
-- Date: 2016-07-29 11:57:54
--
local AchievementRewardPopup = class("AchievementRewardPopup", function() return display.newNode() end)

local WIDTH = 600
local HEIGHT = 264
local TEXT_COLOR = cc.c3b(0xEE, 0xEE, 0xEE)

function AchievementRewardPopup:ctor(iconTex, data)
    self:setNodeEventEnabled(true)
    self.iconTex_ = iconTex
    self.achieve = data
    self:setupView()
end

function AchievementRewardPopup:setupView()

    local bg = display.newScale9Sprite("#pop_achievement_reward_bg.png", 0, 0, cc.size(WIDTH, HEIGHT), cc.rect(0,45,1,1)):pos(0, 0):addTo(self)
	bg:setTouchEnabled(true)
    bg:setTouchSwallowEnabled(true)

    cc.ui.UIPushButton.new({normal = "#pop_achievement_share_close_normal.png", pressed = "#pop_achievement_share_close_pressed.png"})
        :pos(WIDTH * 0.5 - 50, HEIGHT * 0.5 - 32)
        :onButtonClicked(function()
                self:hide()
                nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
            end)
        :addTo(self)

    local title_pos_y = 124
    local title_width_half = 114
    local title_left = display.newSprite("#pop_achievement_reward_title_bg.png")
            :addTo(self, 2, 2):pos(-title_width_half + 1, title_pos_y)

    local title_right = display.newSprite("#pop_achievement_reward_title_bg.png")
            :addTo(self, 3, 3):pos(title_width_half - 1, title_pos_y)
    title_right:setScaleX(-1)
    self.title_ = display.newSprite("#pop_achievement_reward_title.png")
        :addTo(self, 4, 4)
        :pos(0, title_pos_y + 2)

    display.newSprite("#pop_achievement_reward_light.png")
            :addTo(self):pos(0, 16)
    display.newSprite("#pop_achievement_reward_light_point.png")
            :addTo(self):pos(0, 16)

    -- 内容
	self.content = display.newNode():addTo(self):pos(0, 14)
    local star_distance = 30
    local star_pos_y = -19
    self.icon = display.newSprite(self.iconTex_)
            :addTo(self.content)
    self.stars_bg = display.newSprite("#pop_task_achieve_star_bg.png")
            :addTo(self.content):pos(0, star_pos_y - 11)
    self.stars = {}
    for k = 1, 3 do
        display.newSprite("#pop_task_achieve_star_gray.png")
            :addTo(self.content):pos((k - 2) * star_distance, star_pos_y - (k % 2) * 3)
        if k <= self.achieve.currentSubTaskIndex then
            self.stars[k] = display.newSprite("#pop_task_achieve_star_light.png")
                :addTo(self.content):pos((k - 2) * star_distance, star_pos_y - (k % 2) * 3)
            -- self.item_stars[k]:hide()
        end
    end
    
    self.shareButton = cc.ui.UIPushButton.new({normal = "#common_btn_blue_normal.png", pressed = "#common_btn_blue_pressed.png", disabled = "#common_btn_disabled.png"},{scale9 = true})
        :pos(0, -90)
        :setButtonSize(174, 55)
        :setButtonLabel(ui.newTTFLabel({text = bm.LangUtil.getText("COMMON", "SHARE"), color = TEXT_COLOR, size = 22, align = ui.TEXT_ALIGN_CENTER}))
        :addTo(self)
    self.shareButton:onButtonClicked(function(event)
        self:onShareBtnListener_()
    end)
end

function AchievementRewardPopup:onShareBtnListener_()
    local feedData = clone(bm.LangUtil.getText("FEED", "ACHIEVEMENT_REWARD"))
    feedData.name = bm.LangUtil.formatString(feedData.name, self.achieve.name, self.achieve.reward)
    nk.Facebook:shareFeed(feedData, function(success, result)
             if not success then
                 self.shareBtn_:setButtonEnabled(true)
                 nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_FAILED"))
             else
                 nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_SUCCESS"))
                 self:hide()
             end
         end)
end

function AchievementRewardPopup:show()
    nk.PopupManager:addPopup(self)
    return self
end

function AchievementRewardPopup:hide()
    nk.PopupManager:removePopup(self)
    return self
end

return AchievementRewardPopup