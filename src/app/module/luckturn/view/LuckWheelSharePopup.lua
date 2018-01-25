--
-- Author: HLF(IdaHuang@boyaa.com)
-- Date: 2016-04-12 12:30:54

local LuckWheelSharePopup = class("LuckWheelSharePopup", function() return display.newNode() end)

local WIDTH = 600
local HEIGHT = 264
local TEXT_COLOR = cc.c3b(0xEE, 0xEE, 0xEE)

local textColor = cc.c3b(0xff, 0xff, 0xff)
local shareColor = cc.c3b(0xff, 0xff, 0x0)
local textSize = 22
local bigSize = 32
local ICON_WIDTH = 100
local ICON_HEIGHT = 100
local AVATAR_TAG = 101

function LuckWheelSharePopup:ctor(item)
	self.item_ = item
    self:setupView()
    self:setNodeEventEnabled(true)
end

function LuckWheelSharePopup:setupView()
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
    self.content = display.newNode():addTo(self):pos(0, 0)
    local star_distance = 30
    local star_pos_y = -19
    self.icon = display.newSprite(self.iconTex_)
            :addTo(self.content)
    self.shareBtn = cc.ui.UIPushButton.new({normal = "#common_btn_blue_normal.png", pressed = "#common_btn_blue_pressed.png", disabled = "#common_btn_disabled.png"},{scale9 = true})
        :pos(0, -90)
        :setButtonSize(174, 55)
        :setButtonLabel(ui.newTTFLabel({text = bm.LangUtil.getText("COMMON", "SHARE"), color = TEXT_COLOR, size = 22, align = ui.TEXT_ALIGN_CENTER}))
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.onShareBtnListener_))
    self:render_()
end

function LuckWheelSharePopup:render_()
    --奖品图片
    local desc
    if self.item_.img then
        self:loadImg_()
        desc = self.item_.name
    elseif self.item_.url then
        self:loadUrl_()
        desc = self.item_.desc
    end

    --中奖文字
    local rewards = bm.LangUtil.getText("WHEEL", "REWARD")
    local labelMarginLeft = 36
    local label1MarginTop = 10
    local rewardLabel1 = ui.newTTFLabel({
             text = rewards[1],
             size = bigSize,
             color = textColor,
             align = ui.TEXT_ALIGN_CENTER
        })
        :addTo(self)
        :hide()
    local rewardLabel1Size = rewardLabel1:getContentSize()
    rewardLabel1:pos(0, HEIGHT/2 - rewardLabel1Size.height/2 - label1MarginTop)

    local dw = 290
    local label2MarginTop = 2
    local rewardLabel2 = ui.newTTFLabel({
             text = bm.LangUtil.formatString(rewards[2], desc),
             size = textSize,
             color = styles.FONT_COLOR.GOLDEN_TEXT,
             align = ui.TEXT_ALIGN_LEFT
        })
        :pos(25, -46)
        :addTo(self)
end

function LuckWheelSharePopup:loadImg_()
    local px = 0
    local py = 32
    local icon
    local cfg = self.item_
    if cfg.type == "fun_face" then
        -- 互动道具
        icon = display.newSprite("#prop_hddj_icon.png")
            :pos(px, py)
            :addTo(self.content)
            :scale(1.8);
    elseif cfg.type == "score" then
        -- 积分现金卡
        icon = display.newSprite("#turn_reward_card.png")
            :pos(px, py)
            :addTo(self.content)
            :scale(0.65)
        local numlbl = ui.newTTFLabel({
            text = cfg.num, 
            color = cc.c3b(0xa0,0x0,0x0),
            size = 32, align = ui.TEXT_ALIGN_CENTER
            })
            :pos(33, 33)
            :addTo(icon)
        -- 
        bm.fitSprteWidth(numlbl, 30)

        local isz = icon:getContentSize()
        local iscale = 80/isz.height
        icon:setScale(iscale)
        -- 
        local len = string.len(tostring(cfg.num))
        if len == 1 then
            bm.fitSprteWidth(numlbl, 12)
        elseif len == 2 then
            bm.fitSprteWidth(numlbl, 20)
        elseif len == 3 then
            bm.fitSprteWidth(numlbl, 30)
        else
            bm.fitSprteWidth(numlbl, 40)
        end
    elseif cfg.type == "game_coupon" then
        -- 比赛券
        icon = display.newSprite("match_gamecoupon.png")
            :pos(px, py)
            :addTo(self.content)
            :scale(1);
    elseif cfg.type == "chips" then
        local res;
        if cfg.num < 800 then
            res = "wheel_reward_6.png";
        elseif cfg.num < 1500 then
            res = "wheel_reward_5.png";
        elseif cfg.num < 4000 then
            res = "wheel_reward_4.png";
        elseif cfg.num < 70000 then
            res = "wheel_reward_3.png";
        elseif cfg.num < 500000 then
            res = "wheel_reward_2.png";
        else
            res = "wheel_reward_1.png";
        end

        icon = display.newSprite("#"..res)
            :pos(px, py)
            :addTo(self.content)
            :scale(1.5);
    elseif cfg.type == "ticket" or cfg.type == "real" then
        local iconContainer = display.newNode()
            :pos(px, py)
            :size(ICON_WIDTH, ICON_HEIGHT)
            :addTo(self.content)
        local iconLoaderId = nk.ImageLoader:nextLoaderId()
        local defaultIcon = display.newSprite("#transparent.png")
            :addTo(iconContainer, AVATAR_TAG, AVATAR_TAG)
            :scale(0.4)
        self.iconLoaderId_ = iconLoaderId

        nk.ImageLoader:cancelJobByLoaderId(self.iconLoaderId_)
        nk.ImageLoader:loadAndCacheImage(iconLoaderId,
            cfg.img,
            function(success, sprite)
                if sprite and type(sprite) ~= "string" then
                    local tex = sprite:getTexture()
                    local texSize = tex:getContentSize()
                    local oldAvatar = iconContainer:getChildByTag(AVATAR_TAG)
                    if oldAvatar then
                        oldAvatar:removeFromParent()
                    end

                    local iconSize = iconContainer:getContentSize()
                    local xxScale = iconSize.width/texSize.width
                    local yyScale = iconSize.height/texSize.height
                    local scaleVal = xxScale<yyScale and xxScale or yyScale;
                    sprite:addTo(iconContainer, 0, AVATAR_TAG)
                        :scale(scaleVal)
                        :pos(0, 0);
                end
            end
        )
    end
end

function LuckWheelSharePopup:loadUrl_()
    local iconContainer = display.newNode()
        :pos(0, 20)
        :size(ICON_WIDTH, ICON_HEIGHT)
        :addTo(self.content, 1)
    local iconLoaderId = nk.ImageLoader:nextLoaderId()
    local defaultIcon = display.newSprite("#transparent.png")
        :addTo(iconContainer, AVATAR_TAG, AVATAR_TAG)
        :scale(0.4)
    self.iconLoaderId_ = iconLoaderId

    nk.ImageLoader:cancelJobByLoaderId(self.iconLoaderId_)
    nk.ImageLoader:loadAndCacheImage(iconLoaderId,
        self.item_.url,
        function(success, sprite)
            if sprite and type(sprite) ~= "string" then
                local tex = sprite:getTexture()
                local texSize = tex:getContentSize()
                local oldAvatar = iconContainer:getChildByTag(AVATAR_TAG)
                if oldAvatar then
                    oldAvatar:removeFromParent()
                end
                -- 
                local iconSize = iconContainer:getContentSize()
                local xxScale = iconSize.width/texSize.width
                local yyScale = iconSize.height/texSize.height
                local scaleVal = xxScale<yyScale and xxScale or yyScale;
                sprite:addTo(iconContainer, 0, AVATAR_TAG)
                    :pos(0, 0);
            end
        end
    )
end

function LuckWheelSharePopup:onCloseBtnListener_()
    self:hide()
end

function LuckWheelSharePopup:onShareBtnListener_()
    self.shareBtn:setButtonEnabled(false)
    local feedData = clone(bm.LangUtil.getText("FEED", "WHEEL_REWARD"))
     feedData.name = bm.LangUtil.formatString(feedData.name, self.item_.desc)
     nk.Facebook:shareFeed(feedData, function(success, result)
         print("FEED.WHEEL_REWARD result handler -> ", success, result)
         if not success then
             self.shareBtn:setButtonEnabled(true)
             nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_FAILED"))
         else
             self:hide()
             nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_SUCCESS"))
         end
     end)
    self.shareBtn:setButtonEnabled(true)
end

function LuckWheelSharePopup:show(callback)
    self.callback_ = callback;
	nk.PopupManager:addPopup(self);
	self:playRewardParticle_()
	return self;
end

function LuckWheelSharePopup:onShowed()
end

function LuckWheelSharePopup:hide()
    nk.PopupManager:removePopup(self)
    return self
end

function LuckWheelSharePopup:playRewardParticle_()
	local particleNode = display.newNode()
		:pos(0, HEIGHT*0.5)
		:addTo(self)
	for i=0,14 do
		local filename = "Particle/luckturn/fx_caidai"..string.format("%02d", i)..".plist"
		local emitter = cc.ParticleSystemQuad:create(filename)
			:addTo(particleNode)

		emitter:setAutoRemoveOnFinish(true)
	end
end

function LuckWheelSharePopup:onCleanup()
    if self.iconLoaderId_ then
        nk.ImageLoader:cancelJobByLoaderId(self.iconLoaderId_)
        self.iconLoaderId_ = nil
    end
end

function LuckWheelSharePopup:onRemovePopup(func)
    self:onCleanup()

    if self.callback_ then
        self.callback_()
        self.callback_ = nil
    end

    func()
end

return LuckWheelSharePopup