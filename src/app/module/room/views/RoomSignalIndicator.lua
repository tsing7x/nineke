--
-- Author: tony
-- Date: 2014-08-31 13:49:30
--
local RoomSignalIndicator = class("RoomSignalIndicator", function() return display.newNode() end)

function RoomSignalIndicator:ctor()
    self.signalIcon_ = display.newSprite("#room_signal_normal.png", 0, 0)
    local size = self.signalIcon_:getContentSize()
    self.signalWidth_,self.signalHeight_ = size.width,size.height
    self.perWidth_ = self.signalWidth_*0.25
    --遮罩
    local viewClipNode_ = cc.ClippingNode:create():addTo(self)
    local stencil = display.newDrawNode()
    stencil:drawPolygon({
             {-self.signalWidth_/2, -self.signalHeight_/2},
             {-self.signalWidth_/2, self.signalHeight_/2},
             {self.signalWidth_/2, self.signalHeight_/2},
             {self.signalWidth_/2, -self.signalHeight_/2}
        })
    viewClipNode_:setStencil(stencil)
    viewClipNode_:addChild(self.signalIcon_)

    self.stencil_ = stencil

    self.isFlashing_ = false
end

function RoomSignalIndicator:reSetMask(num)
    if not num or num<2 then
        num = 2
    end
    self.stencil_:clear()
    self.stencil_:drawPolygon({
         {-self.signalWidth_/2, -self.signalHeight_/2},
         {-self.signalWidth_/2, self.signalHeight_/2},
         {-self.signalWidth_/2+self.perWidth_*num, self.signalHeight_/2},
         {-self.signalWidth_/2+self.perWidth_*num, -self.signalHeight_/2}
    })
end

function RoomSignalIndicator:setSignalStrength(strength)
    if strength>2 then
        self.signalIcon_:setSpriteFrame(display.newSpriteFrame("room_signal_normal.png"))
    else
        self.signalIcon_:setSpriteFrame(display.newSpriteFrame("room_signal_abnormal.png"))
    end
    self:reSetMask(strength)
    self:flash_(strength == 0)
end

function RoomSignalIndicator:flash_(isFlash)
    if self.isFlashing_ ~= isFlash then
        self.isFlashing_ = isFlash
        self:stopAllActions();
        if isFlash then
            self:runAction(cc.RepeatForever:create(transition.sequence({
                cc.Show:create(),
                cc.DelayTime:create(0.8),
                cc.Hide:create(),
                cc.DelayTime:create(0.6)
            })))
        else
            self:show()
        end
    end
end

return RoomSignalIndicator