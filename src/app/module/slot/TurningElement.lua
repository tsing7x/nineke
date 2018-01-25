--
-- Author: viking@boomegg.com
-- Date: 2014-11-21 18:20:13
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--
local TurningElement = class("TurningElement", function()
    return display.newNode()
end)

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
    J = "#slot_element_bar.png"
}

TurningElement.ACCELERATE_TIME = 1.5
TurningElement.UNIFORM_TIME = 1.5
TurningElement.DECELERATE_TIME = 1.5

function TurningElement:ctor()
    self.schedulerPool_ = bm.SchedulerPool.new()
    local padding = 16
    self.heights = {}
    local sumHeight = 0

    local batch = display.newBatchNode("slot_texture.png", 3):addTo(self)

    local J0height = 69
    local J0 = display.newSprite(elements.J):addTo(batch):pos(0, -J0height - padding)

    local Aheight = 63
    local A = display.newSprite(elements.A):addTo(batch):pos(0, sumHeight)
    self.heights.A = sumHeight

    sumHeight = sumHeight + Aheight + padding
    local Bheight = 63
    local B = display.newSprite(elements.B):addTo(batch):pos(0, sumHeight)
    self.heights.B = sumHeight

    sumHeight = sumHeight + Bheight + padding
    local Cheight = 71
    local C = display.newSprite(elements.C):addTo(batch):pos(0, sumHeight)
    self.heights.C = sumHeight

    sumHeight = sumHeight + Cheight + padding
    local Dheight = 74
    local D = display.newSprite(elements.D):addTo(batch):pos(0, sumHeight)
    self.heights.D = sumHeight

    sumHeight = sumHeight + Dheight + padding
    local Eheight = 83
    local E = display.newSprite(elements.E):addTo(batch):pos(0, sumHeight)
    self.heights.E = sumHeight

    sumHeight = sumHeight + Eheight + padding
    local Fheight = 80
    local F = display.newSprite(elements.F):addTo(batch):pos(0, sumHeight)
    self.heights.F = sumHeight

    sumHeight = sumHeight + Fheight + padding
    local Gheight = 73
    local G = display.newSprite(elements.G):addTo(batch):pos(0, sumHeight)
    self.heights.G = sumHeight

    sumHeight = sumHeight + Gheight + padding
    local Hheight = 74
    local H = display.newSprite(elements.H):addTo(batch):pos(0, sumHeight)
    self.heights.H = sumHeight

    sumHeight = sumHeight + Hheight + padding
    local Iheight = 67
    local I = display.newSprite(elements.I):addTo(batch):pos(0, sumHeight)
    self.heights.I = sumHeight

    sumHeight = sumHeight + Iheight + padding
    local Jheight = 69
    local J = display.newSprite(elements.J):addTo(batch):pos(0, sumHeight)
    self.heights.J = sumHeight

    --second
    sumHeight = sumHeight + Jheight + padding
    local A2 = display.newSprite(elements.A):addTo(batch):pos(0, sumHeight)
    self.heights.A2 = sumHeight

    sumHeight = sumHeight + Aheight + padding
    local B2 = display.newSprite(elements.B):addTo(batch):pos(0, sumHeight)
    self.heights.B2 = sumHeight

    sumHeight = sumHeight + Bheight + padding
    local C2 = display.newSprite(elements.C):addTo(batch):pos(0, sumHeight)
    self.heights.C2 = sumHeight

    sumHeight = sumHeight + Cheight + padding
    local D2 = display.newSprite(elements.D):addTo(batch):pos(0, sumHeight)
    self.heights.D2 = sumHeight

    sumHeight = sumHeight + Dheight + padding
    local E2 = display.newSprite(elements.E):addTo(batch):pos(0, sumHeight)
    self.heights.E2 = sumHeight

    sumHeight = sumHeight + Eheight + padding
    local F2 = display.newSprite(elements.F):addTo(batch):pos(0, sumHeight)
    self.heights.F2 = sumHeight

    sumHeight = sumHeight + Fheight + padding
    local G2 = display.newSprite(elements.G):addTo(batch):pos(0, sumHeight)
    self.heights.G2 = sumHeight

    sumHeight = sumHeight + Gheight + padding
    local H2 = display.newSprite(elements.H):addTo(batch):pos(0, sumHeight)
    self.heights.H2 = sumHeight

    sumHeight = sumHeight + Hheight + padding
    local I2 = display.newSprite(elements.I):addTo(batch):pos(0, sumHeight)
    self.heights.I2 = sumHeight

    sumHeight = sumHeight + Iheight + padding
    local J2 = display.newSprite(elements.J):addTo(batch):pos(0, sumHeight)
    self.heights.J2 = sumHeight + Jheight + padding

    self.sumHeight_ = self.heights.J2
end

function TurningElement:start(isAccelerate, callback)
    self:stopAllActions()
    self:show()
    local sequence = transition.sequence({
        isAccelerate and cc.EaseIn:create(cc.MoveTo:create(TurningElement.ACCELERATE_TIME, cc.p(0, -self.heights.J2)), 2.5) 
            or cc.MoveTo:create(TurningElement.UNIFORM_TIME, cc.p(0, -self.heights.J2)),
        cc.CallFunc:create(function() 
            -- print("TurningElement:accelerate over")
            self:pos(0, self.heights.C)
            self:hide()
            if callback then
                callback()
            end
        end),
    })
    self:runAction(sequence)
end

function TurningElement:getHeight()
    return self.sumHeight_ or 0
end

function TurningElement:turnToWhich(element, callback)
    self:show()
    local sequence = transition.sequence({
            cc.EaseOut:create(cc.MoveTo:create(TurningElement.DECELERATE_TIME, cc.p(0, -self.heights[element])), 1.5),
            cc.CallFunc:create(function()
                if callback then
                    callback()
                end
            end),
        })
    self:runAction(sequence)
end

function TurningElement:stop()
    self:stopAllActions()
    self.schedulerPool_:clearAll()
end

return TurningElement