--
-- Author: viking@boomegg.com
-- Date: 2014-12-04 15:24:48
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--
local MinusMoneyView = class("MinusMoneyView", function()
    return display.newNode()
end)

local textSize = 24
local textColor = cc.c3b(0xec, 0xce, 0x0b)

function MinusMoneyView:ctor(srcX)
    --文本显示
    self.label_ = ui.newTTFLabel({
            text = "-5000",
            size = textSize,
            color = textColor,
            align = ui.TEXT_ALIGN_CENTER
        }):addTo(self)
    self.label_:setAnchorPoint(cc.p(0, 0.5))
    self.srcX_ = srcX
end

function MinusMoneyView:playAnim(betMoney)
    print("MinusMoneyView:playAnim", betMoney)
    self:setPositionX(self.srcX_)
    self:opacity(255)
    self:show()
    self.label_:setString("-" .. betMoney)
    local x = self:getPositionX()
    local y = self:getPositionY()
    local padding = 38 + self.label_:getContentSize().width
    local sequence = transition.sequence({
            cc.MoveTo:create(0.5, cc.p(x - padding, y)),
            cc.DelayTime:create(1),
            cc.FadeOut:create(0.5),
            cc.CallFunc:create(function()
                self:hide()
            end),
        })
    self:runAction(sequence)
end

function MinusMoneyView:stop()
    self:hide()
    self:stopAllActions()
end

function MinusMoneyView:dispose()
    self:stopAllActions()
end

return MinusMoneyView