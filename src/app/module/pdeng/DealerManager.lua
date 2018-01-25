
local DealerManager = class("DealerManager")
local RoomViewPosition = import(".views.RoomViewPosition")

function DealerManager:ctor()
end

function DealerManager:createNodes()
    -- 加入荷官
    local dealerNode_ = display.newNode()
        :pos(display.cx, RoomViewPosition.SeatPositionForDealer[1].y - 12)
        :addTo(self.scene.nodes.dealerNode)
    self.systemDealerChair_ = display.newSprite("#pdeng_room_dealer_chair.png")
        :pos(display.cx, RoomViewPosition.SeatPositionForDealer[1].y - 12)
        :addTo(self.scene.nodes.backgroundNode)
    self.systemDealer_ = display.newSprite("#pdeng_room_dealer.png")
        :pos(0, 6)
        :addTo(dealerNode_)
    if nk.socket.RoomSocket.needShowDealer then
        self.isSelfDealer = true
        self.systemDealerChair_:setSpriteFrame("pdeng_room_upbanker_chair.png")
        self.systemDealerChair_:pos(display.cx, RoomViewPosition.SeatPositionForDealer[1].y - 12 - 462)
        --self.systemDealer_:hide()
        self:hideDealer()
    end
end
function DealerManager:hideDealer()
    self.systemDealer_:stopAllActions()
    self.systemDealer_:runAction(cc.FadeOut:create(0.5))
    -- self.systemDealerChair_:hide()
end

function DealerManager:showDealer()
    self.systemDealer_:stopAllActions()
	self.systemDealer_:runAction(transition.sequence({cc.DelayTime:create(1), cc.FadeIn:create(0.5)}))
    -- self.systemDealerChair_:show()
end

function DealerManager:updateSelfDealer(isSelfDealer)
    if isSelfDealer and not self.isSelfDealer then
        self.isSelfDealer = true
        -- self.systemDealer_:runAction(transition.sequence({
        --     cc.MoveBy:create(0.5, cc.p(0, -392))}))
        
        self.systemDealerChair_:runAction(transition.sequence({
            cc.RotateBy:create(0.5, 180),
            cc.CallFunc:create(function() 
                    self.systemDealerChair_:setRotation(0)
                    self.systemDealerChair_:setSpriteFrame("pdeng_room_upbanker_chair.png")
            end),
            cc.MoveBy:create(0.5, cc.p(0, -462))}))
    elseif not isSelfDealer and self.isSelfDealer then
        self.isSelfDealer = false
        -- self.systemDealer_:runAction(transition.sequence({
        --     cc.MoveBy:create(0.5, cc.p(0, 392))}))

        self.systemDealerChair_:runAction(transition.sequence({
            cc.RotateBy:create(0.5, 180),
            cc.CallFunc:create(function() 
                    self.systemDealerChair_:setRotation(0)
                    self.systemDealerChair_:setSpriteFrame("pdeng_room_dealer_chair.png")
            end),
            cc.MoveBy:create(0.5, cc.p(0, 462))}))
    end
end

function DealerManager:kissPlayer()
    return self
end

function DealerManager:tapTable()
    return self
end

function DealerManager:dispose()
end

return DealerManager