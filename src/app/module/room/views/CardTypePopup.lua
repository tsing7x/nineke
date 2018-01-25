--
-- Author: tony
-- Date: 2014-08-28 15:14:46
--
local CardTypePopup = class("CardTypePopup", function() return display.newNode() end)

CardTypePopup.WIDTH = 450
CardTypePopup.HEIGHT = 550

function CardTypePopup:ctor()
    self.content_ = display.newSprite("room_card_type.png"):addTo(self)
    self.content_:setTouchEnabled(true)
    self.content_:setTouchSwallowEnabled(true)
    self:pos(-CardTypePopup.WIDTH * 0.5, CardTypePopup.HEIGHT * 0.5 + 80)
end

function CardTypePopup:showPanel()
    nk.PopupManager:addPopup(self, true, false, true, false)
end

function CardTypePopup:hidePanel()
    nk.PopupManager:removePopup(self)
end

function CardTypePopup:onRemovePopup(removeFunc)
    self:stopAllActions()
    transition.moveTo(self, {time=0.2, x=-CardTypePopup.WIDTH * 0.5, easing="OUT", onComplete=function() 
        removeFunc()
    end})
end

function CardTypePopup:onShowPopup()
    self:stopAllActions()
    transition.moveTo(self, {time=0.2, x=CardTypePopup.WIDTH * 0.5 + 8, easing="OUT", onComplete=function()
        if self.onShow then
            self:onShow()
        end
    end})
end

return CardTypePopup