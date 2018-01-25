--
-- Author: viking@boomegg.com
-- Date: 2014-11-21 18:23:05
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--
local TurningContent = class("TurningContent", function()
    return display.newNode()
end)

local TurningView = import(".TurningView")

local width, height = 444, 168

function TurningContent:ctor(turningStopCallback)
    self.callback_ = turningStopCallback
    self.schedulerPool_ = bm.SchedulerPool.new()
    --背景
    display.newScale9Sprite("#slot_content_bg.png"):size(width, height):addTo(self)

    --华丽丽的分割线
    local elementWidth = width/3
    display.newSprite("#slot_content_divider.png"):pos(-elementWidth/2, 0):addTo(self)
    display.newSprite("#slot_content_divider.png"):pos(elementWidth/2, 0):addTo(self)

    --滚动条elements
    local elementNode_ = display.newNode()
    local elementLeft = TurningView.new():pos(-elementWidth, 0):addTo(elementNode_)
    local elementMiddle = TurningView.new():pos(0, 0):addTo(elementNode_)
    local elementRight = TurningView.new():pos(elementWidth, 0):addTo(elementNode_)
    self.elements = {elementLeft, elementMiddle, elementRight}

    --遮罩模板
    local elementsClipNode_ = cc.ClippingNode:create():addTo(self)
    local stencil = display.newDrawNode()
    local stencilPadding = 5
    stencil:drawPolygon({
             {-width/2, -height/2 + stencilPadding},
             {-width/2, height/2 - stencilPadding},
             {width/2, height/2 - stencilPadding},
             {width/2, -height/2 + stencilPadding}
        })
    elementsClipNode_:setStencil(stencil)
    elementsClipNode_:addChild(elementNode_)

    --上面的小白光条
    local whiteLineWidth = 5
    local whiteLineHeight = 28
    local whiteLineScale = 0.9
    display.newSprite("#slot_content_white_light.png"):pos(-elementWidth/2 - whiteLineWidth/2, height/2 - whiteLineHeight/2):addTo(self)--left1
    display.newSprite("#slot_content_white_light.png"):pos(-elementWidth/2 + whiteLineWidth/2, height/2 - whiteLineHeight/2):addTo(self):scale(whiteLineScale)--right1
    display.newSprite("#slot_content_white_light.png"):pos(elementWidth/2 - whiteLineWidth/2,  height/2 - whiteLineHeight/2):addTo(self)--left2
    display.newSprite("#slot_content_white_light.png"):pos(elementWidth/2 + whiteLineWidth/2,  height/2 - whiteLineHeight/2):addTo(self):scale(whiteLineScale)--right2

    --下面的小黄光条
    local yellowLineWidth = 13
    local yellowLineHeight = 43
    local yellowLineScale = 0.9
    display.newSprite("#slot_content_yellow_light.png"):pos(-elementWidth/2 - yellowLineWidth/2, -height/2 + yellowLineHeight/2):addTo(self)--left3
    display.newSprite("#slot_content_yellow_light.png"):pos(-elementWidth/2 + yellowLineWidth/2, -height/2 + yellowLineHeight/2):addTo(self):scale(yellowLineScale)--right3
    display.newSprite("#slot_content_yellow_light.png"):pos(elementWidth/2 - yellowLineWidth/2,  -height/2 + yellowLineHeight/2):addTo(self)--left4
    display.newSprite("#slot_content_yellow_light.png"):pos(elementWidth/2 + yellowLineWidth/2,  -height/2 + yellowLineHeight/2):addTo(self):scale(yellowLineScale)--right4

    --遮罩
    local overlayWidth = 438
    local overlayHeight = 162
    display.newScale9Sprite("#slot_content_overlay.png"):size(overlayWidth, overlayHeight):addTo(self)

    --从上往下，小光, 大光，黄光
    local smallLightWidth = 434
    local samllLightHeight = 22
    local bigMarginTop = 5
    local bigLightWidth = 453
    local bigLightHeight = 41
    local yellowLightWidth = 435
    local yellowLightHeight = 43
    local lightpadding = 20
    display.newSprite("#slot_content_light2_top.png"):pos(0, height/2 - samllLightHeight/2 - lightpadding):addTo(self)
    display.newSprite("#slot_content_light1_top.png"):pos(0, height/2 - bigLightHeight/2 - bigMarginTop - lightpadding):addTo(self)
    display.newSprite("#slot_content_yellow_bottom.png"):pos(0, -height/2 + yellowLightHeight/2):addTo(self)
end

function TurningContent:start(data)
    local changeValues = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J"}--0~9
    local values = data.values
    local value1 = changeValues[values[1] + 1]
    local value2 = changeValues[values[2] + 1]
    local value3 = changeValues[values[3] + 1]
    print("TurningContent:start", value1, value2, value3)
    local elements = {value1, value2, value3}
    local rewardMoney = data.rewardMoney
    local leftMoney = data.totalNum
    self.schedulerPool_:clearAll()
    for i, element in ipairs(self.elements) do
        self.schedulerPool_:delayCall(function()
            element:start(elements[i], function()
                self.callback_(i, rewardMoney, leftMoney)
            end)
        end, 0.5 * (i - 1))
    end
end

function TurningContent:stop()
    for i, element in ipairs(self.elements) do
        element:stop()
    end
    self.schedulerPool_:clearAll()
end

function TurningContent:dispose()
    self:stop()
end

return TurningContent