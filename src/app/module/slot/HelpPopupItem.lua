--
-- Author: viking@boomegg.com
-- Date: 2014-12-01 11:53:13
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--
local HelpPopupItem = class("HelpPopupItem", function()
    return display.newNode()
end)

--大条目
local bigItemWidth = 262
local bigItemHeight = 43
HelpPopupItem.BIG_WIDTH = bigItemWidth
HelpPopupItem.BIG_HEIGHT = bigItemHeight

--小条目
local smallItemWidth = 174
local smallItemHeight = 32
HelpPopupItem.SMALL_WIDTH = smallItemWidth
HelpPopupItem.SMALL_HEIGHT = smallItemHeight

local textColor = cc.c3b(0x00, 0x00, 0x00)
local textBigSize = 20
local textSmallSize = 15

local elements = {
    A = "#slot_element_red7.png",
    B = "#slot_element_gold7.png",
    C = "#slot_element_diamond.png",
    D = "#slot_element_watermelon.png",
    E = "#slot_element_cherry.png",
    F = "#slot_element_blueberry.png",
    G = "#slot_element_orange.png",
    H = "#slot_element_banana.png",
    I = "#slot_element_lemon.png",
    J = "#slot_element_bar.png",
    X = "#slot_element_any.png",
    Y = "#slot_element_same.png"
}

function HelpPopupItem:ctor(types, multiple, isBig)
    local bgFrame = "#slot_help_reward_small_bg.png"
    local bgWidth, bgHeight = smallItemWidth, smallItemHeight
    local typeScale = 0.3
    local labelTextSize = textSmallSize
    local type2MarginLeft = 5
    local type3MarginLeft = 5
    if isBig then
        bgFrame = "#slot_help_reward_big_bg.png"
        bgWidth, bgHeight = bigItemWidth, bigItemHeight
        typeScale = 0.4
        labelTextSize = textBigSize
        type2MarginLeft = 10
        type3MarginLeft = 10
    end

    local itemBg = display.newScale9Sprite(bgFrame):size(bgWidth, bgHeight):addTo(self)
    local type1 = display.newSprite(elements[types[1]]):addTo(itemBg):scale(typeScale)
    local type1Size = type1:getContentSize()
    local type1MarginLeft = 15
    local posX = 0
    type1:pos(posX + typeScale * type1Size.width/2 + type1MarginLeft, typeScale * type1Size.height/2 + (bgHeight - typeScale * type1Size.height)/2)

    local type2 = display.newSprite(elements[types[2]]):addTo(itemBg):scale(typeScale)
    local type2Size = type2:getContentSize()
    posX = posX + typeScale * type1Size.width + type1MarginLeft
    type2:pos(posX + typeScale * type2Size.width/2 + type2MarginLeft, typeScale * type2Size.height/2 + (bgHeight - typeScale * type2Size.height)/2)

    local type3 = display.newSprite(elements[types[3]]):addTo(itemBg):scale(typeScale)
    local type3Size = type3:getContentSize()
    posX = posX + typeScale * type2Size.width + type2MarginLeft
    type3:pos(posX + typeScale * type3Size.width/2 + type3MarginLeft, typeScale * type3Size.height/2 + (bgHeight - typeScale * type3Size.height)/2)

    local multipleLabel = ui.newTTFLabel({
            text = multiple,
            size = labelTextSize, 
            color = textColor,
            align = ui.TEXT_ALIGN_CENTER
        }):addTo(itemBg)
    multipleLabel:setAnchorPoint(cc.p(1, 0.5))
    local labelSize = multipleLabel:getContentSize()
    local labelMarginRight = 15
    multipleLabel:pos(bgWidth - labelMarginRight, labelSize.height/2 + (bgHeight - labelSize.height)/2)
end

return HelpPopupItem