--
-- Author: viking@boomegg.com
-- Date: 2014-12-17 16:29:12
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--
local AddMoneyView = class("AddMoneyView", function()
    return display.newNode()
end)

local textSize = 24
local textColor = cc.c3b(0xec, 0xce, 0x0b)

local function spawn(actions)
    if #actions < 1 then return end
    if #actions < 2 then return actions[1] end

    local prev = actions[1]
    for i = 2, #actions do
        prev = cc.Spawn:create(prev, actions[i])
    end
    return prev
end

function AddMoneyView:ctor(srcX)
    --文本显示
    self.label_ = ui.newTTFLabel({
            text = "+5000",
            size = textSize,
            color = textColor,
            align = ui.TEXT_ALIGN_CENTER
        }):addTo(self)
    self.label_:setAnchorPoint(cc.p(1, 0.5))
    self.srcX_ = srcX
end

function AddMoneyView:playAnim(winMoney)
    print("AddMoneyView:playAnim", winMoney)
    self:setPositionX(self.srcX_)
    self:opacity(255)
    self:show()
    self.label_:setString("+" .. winMoney)
    local x = self:getPositionX()
    local y = self:getPositionY()
    local padding = 38 + self.label_:getContentSize().width
    local sequence = transition.sequence({
            cc.DelayTime:create(1),
            spawn({
                cc.MoveTo:create(0.5, cc.p(x + padding, y)),
                cc.FadeOut:create(0.5),
            }),
            cc.CallFunc:create(function()
                self:hide()
            end),
        })
    self:runAction(sequence)
end

function AddMoneyView:stop()
    self:hide()
    self:stopAllActions()
end

function AddMoneyView:dispose()
    self:stopAllActions()
end

return AddMoneyView