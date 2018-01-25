--
-- Author: VincentZeng
-- Date: 2017-06-19 17:21:00
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local DiscountInfoPopup = class("DiscountInfoPopup", function()
    return display.newNode()
end)

----[[
local POP_WIDTH = 890
local POP_HEIGHT = 570
local PANEL_CLOSE_BTN_Z_ORDER = 99

function DiscountInfoPopup:ctor(...)
    self:setNodeEventEnabled(true)

    local bgScaleX, bgScaleY = 1, 1
    if display.width > 960 and display.height == 640 then
        bgScaleX = display.width / 960
    elseif display.width == 960 and display.height > 640 then
        bgScaleY = display.height / 640
    end
    self:setScaleX(bgScaleX)
    self:setScaleY(bgScaleY)

    local params = {...}

    self.background_ = params[1]
    self.callback_ = params[3]

    if not self.background_ then
        self:onGotoClicked()
        return
    end

    display.addSpriteFrames("activity_popup.plist", "activity_popup.png", function()
        
        local backFrame = display.newSprite("#backFrame.png"):addTo(self)
        backFrame:setTouchEnabled(true)
        backFrame:setTouchSwallowEnabled(true)

        local background = display.newSprite(self.background_):pos(0, 20):addTo(self)        
        local frontFrame = display.newSprite("#frontFrame.png"):pos(0, 20):addTo(self)        

        local sizeFrontFrame = frontFrame:getContentSize()
        local sizeBackground = background:getContentSize()
        background:setScale(sizeFrontFrame.width/sizeBackground.width - 0.008, sizeFrontFrame.height/sizeBackground.height - 0.008)

        self:addCloseBtn()
        if self.callback_ then
            self:addGoBtn()
        end

    end)

end

function DiscountInfoPopup:addCloseBtn()
    local px = POP_WIDTH/2 - 10
    local py = POP_HEIGHT/2 - 10
    if not self.closeBtn_ then
        self.closeBtn_ = cc.ui.UIPushButton.new({normal = "#close_btn.png", pressed="#closeBtnPress.png"})
            :pos(px, py)
            :onButtonClicked(function()
                self:hide()
                nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
            end)
            :addTo(self, PANEL_CLOSE_BTN_Z_ORDER)
    end
end

function DiscountInfoPopup:addGoBtn()
    local px = 0
    local py = -POP_HEIGHT/2 + 40        

    if not self.goBtn_ then           
        
        self.goBtnBg_ = cc.ui.UIPushButton.new({normal = "#btn.png", pressed="#btn.png"})
            :pos(px, py)
            :onButtonClicked(buttontHandler(self, self.onGotoClicked))
            :addTo(self, PANEL_CLOSE_BTN_Z_ORDER)

        self.goBtn_ = display.newSprite("#quickGo.png")
            :pos(px, py)            
            :addTo(self, PANEL_CLOSE_BTN_Z_ORDER)
    end
end

function DiscountInfoPopup:onGotoClicked()
    if self.callback_ then
        self.callback_()
    end

    self:hide()
end

function DiscountInfoPopup:show()
    if self.background_ then
        nk.PopupManager:addPopup(self, true ~= false, true ~= false, true ~= false, nil ~= false)
    end
    return self
end

function DiscountInfoPopup:hide()
    if self.background_ then
        nk.PopupManager:removePopup(self)
    end
    return self
end


--]]

return DiscountInfoPopup
