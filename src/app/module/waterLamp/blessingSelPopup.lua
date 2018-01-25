local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

local BlessingSelPopup = class("BlessingSelPopup", function()
    return display.newNode()
end)

----[[
local POP_WIDTH = 264
local POP_HEIGHT = 185
local PANEL_CLOSE_BTN_Z_ORDER = 99

local LIST_WIDTH = 264
local LIST_HEIGHT = 155

function BlessingSelPopup:ctor(...)
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

    local backFrame = display.newSprite("#waterLampBlessingFrame.png"):pos(40, -14):addTo(self)
    backFrame:setTouchEnabled(true)
    backFrame:setTouchSwallowEnabled(true)

    cc.ui.UIPushButton.new({normal = "#waterLampTransparentSkin.png", pressed = "#waterLampTransparentSkin.png"}, {scale9 = true})
        :setButtonSize(238, 34)
        :onButtonClicked(handler(self, function()  
            self:hide() 
            params[1]:modBlessingText(bm.LangUtil.getText("WATERLAMP", "BLESSING21"))
        end))
        :pos(40, 56)
        :addTo(self)

    cc.ui.UIPushButton.new({normal = "#waterLampTransparentSkin.png", pressed = "#waterLampTransparentSkin.png"}, {scale9 = true})
        :setButtonSize(238, 42)
        :onButtonClicked(handler(self, function()  
            self:hide() 
            params[1]:modBlessingText(bm.LangUtil.getText("WATERLAMP", "BLESSING22"))
        end))
        :pos(40, 20)
        :addTo(self)

    cc.ui.UIPushButton.new({normal = "#waterLampTransparentSkin.png", pressed = "#waterLampTransparentSkin.png"}, {scale9 = true})
        :setButtonSize(238, 42)
        :onButtonClicked(handler(self, function()  
            self:hide() 
            params[1]:modBlessingText(bm.LangUtil.getText("WATERLAMP", "BLESSING23"))
        end))
        :pos(40, -23)
        :addTo(self)

    cc.ui.UIPushButton.new({normal = "#waterLampTransparentSkin.png", pressed = "#waterLampTransparentSkin.png"}, {scale9 = true})
        :setButtonSize(238, 42)
        :onButtonClicked(handler(self, function()  
            self:hide() 
            params[1]:modBlessingText(bm.LangUtil.getText("WATERLAMP", "BLESSING24"))
        end))
        :pos(40, -66)
        :addTo(self)

end

function BlessingSelPopup:show()
    nk.PopupManager:addPopup(self, true ~= false, true ~= false, true ~= false, nil ~= false)
    return self
end

function BlessingSelPopup:hide()
    nk.PopupManager:removePopup(self)
    return self
end

--]]

return BlessingSelPopup
