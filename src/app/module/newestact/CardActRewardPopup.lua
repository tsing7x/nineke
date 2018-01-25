--
-- Author: Jonah0608@gmail.com
-- Date: 2016-12-06 10:12:56
--
local CardActRewardPopup = class("CardActRewardPopup",function()
    return display.newNode()
end)

local WIDTH = 575
local HEIGHT = 270

function CardActRewardPopup:ctor(rewardData,rewardId)
    self:setNodeEventEnabled(true)
    self:setupView(rewardData,rewardId)
end

function CardActRewardPopup:setupView(rewardData,rewardId)
   local bg = display.newScale9Sprite("#pop_achievement_reward_bg.png", 0, 0, cc.size(WIDTH, HEIGHT), cc.rect(1,45,1,1)):pos(0, 0):addTo(self)
    bg:setTouchEnabled(true)
    bg:setTouchSwallowEnabled(true)
    self.rewardLoaderId_ = nk.ImageLoader:nextLoaderId()

     display.newSprite("#card_activity_reward_title.png")
        :addTo(self, 2, 2):pos(0,130)

    cc.ui.UIPushButton.new({normal = "#pop_achievement_share_close_normal.png", pressed = "#pop_achievement_share_close_pressed.png"})
        :pos(WIDTH * 0.5 - 50, HEIGHT * 0.5 - 32)
        :onButtonClicked(function()
            self:hide()
            nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
        end)
        :addTo(self)

    display.newSprite("#pop_achievement_reward_light.png")
        :addTo(self):pos(0, -10)

    display.newSprite("#pop_achievement_reward_light_point.png")
        :addTo(self):pos(0, -10)

    self.rewardName_ = ui.newTTFLabel({text = "", color = cc.c3b(0xab, 0xab, 0xff), size = 22, align = ui.TEXT_ALIGN_LEFT})
        :pos(0,-110)
        :addTo(self)

    if rewardData.reward and rewardData.reward.money then
        self.rewardSprite_ = display.newSprite("#card_activity_money_" .. (rewardId + 1) .. ".png")
            :addTo(self):pos(0,-10)
        self.rewardName_:setString(rewardData.reward.money .. bm.LangUtil.getText("CARD_ACT","MONEY"))
    else
        self.rewardSprite_ = display.newSprite("#transparent.png")
            :addTo(self):pos(0,-10)
        if rewardData.reward.img and string.len(rewardData.reward.img) > 5 then
            self:loadImage(rewardData.reward.img)
        end
        self.rewardName_:setString(rewardData.reward.name)
    end
end

function CardActRewardPopup:loadImage(imgUrl)
    nk.ImageLoader:loadAndCacheImage(
        self.rewardLoaderId_,
        imgUrl,
        handler(self, self.onLoadComplete_),
        nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
    )
end

function CardActRewardPopup:onLoadComplete_(success, sprite)
    if success then
        sprite:addTo(self):pos(0,-10)
        -- local tex = sprite:getTexture();
        -- local texSize = tex:getContentSize();
        -- self.rewardSprite_:setTexture(tex)
    end
end

function CardActRewardPopup:show()
    nk.PopupManager:addPopup(self)
    return self
end

function CardActRewardPopup:hide()
    nk.PopupManager:removePopup(self)
    return self
end

return CardActRewardPopup