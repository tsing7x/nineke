--
-- Author: viking@boomegg.com
-- Date: 2014-11-25 11:29:53
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--
local BetChip = class("BetChip", function()
    return display.newNode()
end)

BetChip.WIDTH = 54
BetChip.HEIGHT = 54

function BetChip:ctor(params)
    local normalTexture_ = params.normal
    local glowTexture_ = params.glow
    local text_ = params.text or ""
    self.callback_ = params.callback
    self.isInRoom = params.isInRoom
    self.isGcoins = params.isGcoins
    self.lblcolor = params.lblcolor

    --触摸区域
    local touchNode_ = display.newScale9Sprite("#transparent.png"):size(BetChip.WIDTH, BetChip.HEIGHT):addTo(self)
    bm.TouchHelper.new(touchNode_, handler(self, self.onClickListener_))

    --未被选择
    local normalMarginTop = -3
    self.normalChips_ = display.newSprite(normalTexture_):addTo(self):pos(0, normalMarginTop)

    --选择状态
    local glowMarginTop = -2
    self.glowChips_ = display.newSprite(glowTexture_):addTo(self):hide():pos(0, glowMarginTop)

    --下注数
    local fontsize = 18
    local py = 2
    if not self.isInRoom then
        fontsize = 16
    end
    if self.isGcoins then
        py = -2
    end
    self.betLabel_ = ui.newTTFLabel({
        text = text_,
        size = fontsize, 
        color = self.lblcolor,
        align = ui.TEXT_ALIGN_CENTER})
        :pos(0, py)
        :addTo(self)
end

function BetChip:setBetLabel(bet)
    self.bet_ = bet
    self.betLabel_:setString(bm.formatBigNumber(bet))
end

function BetChip:getBet()
    return self.bet_ or 0
end

function BetChip:setGlow(isGlow)
    self.normalChips_:setVisible(not isGlow)
    self.glowChips_:setVisible(isGlow)
end

function BetChip:onClickListener_(target, evt)
    if evt == bm.TouchHelper.TOUCH_BEGIN then
        
    elseif evt == bm.TouchHelper.TOUCH_END then
        
    elseif evt == bm.TouchHelper.CLICK then
        print("BetChip:onClickListener_")
        nk.SoundManager:playSound(nk.SoundManager.SLOT_BET)
        self.callback_(self)
    end
end
-- 
function BetChip:setStylesResId(normalResId, selectResId, lblcolor)
    self.normalChips_:setSpriteFrame(display.newSpriteFrame(normalResId))
    self.glowChips_:setSpriteFrame(display.newSpriteFrame(selectResId))
    self.betLabel_:setTextColor(lblcolor)
end

return BetChip