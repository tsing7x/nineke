--
-- Author: KevinLiang@boyaa.com
-- Date: 2016-08-11 11:57:54
--
local AchievementTipsPopup = class("AchievementTipsPopup", function() return display.newNode() end)

local WIDTH = 372
local HEIGHT = 132
local TEXT_COLOR = cc.c3b(0xEE, 0xEE, 0xEE)

function AchievementTipsPopup:ctor(text, size, dimensions)
    self.text_ = text
    self.size_ = size
    self.dimensions_ = dimensions
    self:setNodeEventEnabled(true)
    self:setupView()
end

function AchievementTipsPopup:setupView()
    WIDTH = self.dimensions_.width + 32
    HEIGHT = self.dimensions_.height + 16
    local bg = display.newScale9Sprite("#pop_achievement_reward_tips_bg.png", 0, 0, cc.size(WIDTH, HEIGHT), cc.rect(25,20,1,1)):pos(0, 0):addTo(self)
	bg:setTouchEnabled(true)
    bg:setTouchSwallowEnabled(true)


    self.contentText = ui.newTTFLabel({
            text = self.text_, 
            size = self.size_, 
            color = TEXT_COLOR, 
            align = ui.TEXT_ALIGN_LEFT,
            dimensions = self.dimensions_
        })
        :addTo(self, 4, 4)
        :pos(0, 0)
end

function AchievementTipsPopup:setString(text)
    self.contentText:setString(text)
end


function AchievementTipsPopup:show()
    nk.PopupManager:addPopup(self)
    return self
end

function AchievementTipsPopup:hide()
    nk.PopupManager:removePopup(self)
    return self
end

return AchievementTipsPopup