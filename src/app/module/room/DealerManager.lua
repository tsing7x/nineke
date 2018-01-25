--
-- Author: tony
-- Date: 2014-07-08 13:22:01
--
local DealerManager = class("DealerManager")
local RoomViewPosition = import(".views.RoomViewPosition")
local RoomDealer = import(".views.RoomDealer")
local DealerHddjDialog = import(".views.DealerHddjDialog")

function DealerManager:ctor(ctx,dealerID,isMatch)
    self.ctx_ = ctx
    self.dealerID = dealerID
    self.isMatch_ = isMatch
end

function DealerManager:createNodes()
    -- 加入荷官
    self.roomDealer_ = RoomDealer.new(self.dealerID, self.isMatch_, handler(self,self.dealerClick_))
        :pos(display.cx, RoomViewPosition.SeatPosition[1].y + 6)
        :addTo(self.scene.nodes.dealerNode)
end

function DealerManager:dealerClick_()
    DealerHddjDialog.new(self.ctx_):show()
end

function DealerManager:changeDealer(dealerID,isMatch)
    if dealerID == self.dealerID then
        return
    end

    if self.roomDealer_ then
        self.roomDealer_:removeFromParent()
        self.roomDealer_ = nil
    end

    self.dealerID = dealerID
    self.isMatch_ = isMatch
    self:createNodes()
end

function DealerManager:kissPlayer()
    self.roomDealer_:kissPlayer()

    return self
end

function DealerManager:tapTable()
    self.roomDealer_:tapTable()

    return self
end

function DealerManager:dispose()
end

-- static method
-- TODO: 重构之后放到合适位置
-- 根据房间类型获取荷官ID 规则在这里定义修改 (当前只有房间类型)
function DealerManager.GetDealerId(roomLevel)
    return ({ low = 1, middle = 2, high = 3, })[roomLevel] or 1
end

return DealerManager
