--
-- Author: Jonah0608@gmail.com
-- Date: 2016-09-05 09:47:05
--
local DiceBetChipView = class("DiceBetChipView")
local P = import(".DiceViewPosition")

local MOVE_DELAY_DURATION = 0.075
local MOVE_FROM_SEAT_DURATION = 0.4
local MOVE_TO_SEAT_DURATION = 0.5
local MOVE_FROM_DEALER_DURATION = 0.5
local MOVE_TO_DEALER_DURATION = 0.5

local MOVE_DELAY_TIME = 0.01
local START_MOVE_DELAY_TIME = 0
local DEALER_WIDTH = 160
local DEALER_HEIGHT = 160
local CHIP_WIDTH = 40

function DiceBetChipView:ctor(parent,manager,typeId)
    self.parent_ = parent
    self.manager_ = manager
    self.typeId_ = typeId
    self.chips_ = 0
    self.areaData = {}
    self.potData_ = {}
    self.areaData.p = P.BetTypePosition[typeId]
    self.areaData.w = P.BetTypeArea[typeId].width
    self.areaData.h = P.BetTypeArea[typeId].height
end

function DiceBetChipView:generateChipPos(posX,posY)
    local x = self.areaData.p.x
    local y = self.areaData.p.y
    local w = self.areaData.w - CHIP_WIDTH
    local h = self.areaData.h - CHIP_WIDTH
    local r1 = (math.random() + math.random() + math.random())/3
    local r2 = (math.random() + math.random() + math.random())/3

    return cc.p(x + (r1 - 0.5) * w, y + (r2 - 0.5) * h)
end

function DiceBetChipView:userBet(seatId,chips,callback,x,y)
    self.chips_ = self.chips_ + chips
    local position = P.SeatPosition[seatId]
    local chipsData = self.manager_:getChipData(chips)
    if chipsData then
        local chipNum = #chipsData
        for i,chipData in ipairs(chipsData) do
            local sp = chipData:getSprite()
            sp:pos(position.x, position.y):addTo(self.parent_)
            sp:setRotation(math.random(1,360))
            local p = self:generateChipPos(x,y)
            table.insert(self.potData_,chipData)
            if i > 1 then
                transition.execute(
                    sp, 
                    cc.Spawn:create(cc.EaseSineIn:create(cc.MoveTo:create(
                        MOVE_FROM_SEAT_DURATION,
                        cc.p(p.x, p.y))),
                    cc.RotateBy:create(MOVE_FROM_SEAT_DURATION + 0.1, math.random(1,90))),
                    {delay = i * MOVE_DELAY_TIME / chipNum + START_MOVE_DELAY_TIME}
                )
            else
                transition.execute(
                    sp, 
                    cc.Spawn:create(cc.EaseSineIn:create(cc.MoveTo:create(
                        MOVE_FROM_SEAT_DURATION, 
                        cc.p(p.x, p.y))),
                    cc.RotateBy:create(MOVE_FROM_SEAT_DURATION  + 0.1 ,math.random(1,90))),
                    {delay = MOVE_DELAY_TIME + START_MOVE_DELAY_TIME, onComplete = function()
                        if callback then
                            callback()
                        end
                    end}
                )
            end
        end
    end
end

function DiceBetChipView:spawn(actions)
    local prev = actions[1]
    for i = 2, #actions do
        prev = cc.Spawn:create(prev, actions[i])
    end
    return prev
end


function DiceBetChipView:showChips(winchips)
    local chipsData = self.manager_:getChipData(winchips - self.chips_)
    if chipsData then
        for i,chipData in ipairs(chipsData) do
            table.insert(self.potData_,chipData)
            local sp = chipData:getSprite()
            local p = self:generateChipPos()
            sp:pos(p.x,p.y):addTo(self.parent_)
            sp:setRotation(math.random(1,360))
        end
    end
end

function DiceBetChipView:showWinResult(data,dealId)
    self:moveFromDealer(data.winchips - self.chips_,dealId,function()
        for i,v in pairs(data.winseats) do
            if v.chips ~= 0 then
                self:showWinChips(v.seatId,v.chips,v.uid)
            end
        end
        self:reset()
    end)
    
end

function DiceBetChipView:showWinChips(seatId,chip,uid)
    nk.SoundManager:playSound(nk.SoundManager.DICE_CHIPMOVE)
    local positionId = self.manager_.diceSeatManager:getPosition(seatId,uid)
    local position = P.SeatPosition[positionId]
    local chipsData = self.manager_:getChipData(chip)
    if chipsData then
        for i,chipData in ipairs(chipsData) do
            local sp = chipData:getSprite()
            local p = self:generateChipPos()
            sp:pos(p.x, p.y):opacity(255):addTo(self.parent_)
            transition.execute(
                sp, 
                cc.MoveTo:create(
                    0.8, 
                    cc.p(position.x, position.y)
                ), 
                {delay = 0.05,onComplete = function ()
                    self.manager_:recycleChip(chipData)
                end}
            )
        end
    end
end

function DiceBetChipView:moveToDealer(dealId,callback)
    local chipNum = #self.potData_
    nk.SoundManager:playSound(nk.SoundManager.DICE_CHIPMOVE)
    for i,chipData in pairs(self.potData_) do
        local sp = chipData:getSprite()
        if i > 1 then
            transition.execute(
                sp, 
                cc.MoveTo:create(
                    MOVE_TO_DEALER_DURATION, 
                    P.DealPosition[dealId]
                ),
                {delay = i * MOVE_DELAY_TIME / chipNum}
            )
        else
            transition.execute(
                sp, 
                cc.MoveTo:create(
                    MOVE_TO_DEALER_DURATION, 
                    P.DealPosition[dealId]
                ),
                {delay = MOVE_DELAY_TIME,onComplete = function ()
                    if callback then
                        callback()
                    end
                    self:reset()
                end}
            )
        end
    end
end

function DiceBetChipView:moveFromDealer(winchips,dealId,callback)
    local position = P.DealPosition[dealId]
    local chipsData = self.manager_:getChipData(winchips)
    if chipsData then
        local chipNum = #chipsData
        for i,chipData in ipairs(chipsData) do
            local sp = chipData:getSprite()
            sp:pos(position.x, position.y):addTo(self.parent_)
            sp:setRotation(math.random(1,360))
            local p = self:generateChipPos()
            table.insert(self.potData_,chipData)
            if i > 1 then
                transition.execute(
                    sp, 
                        cc.EaseSineOut:create(cc.MoveTo:create(
                            MOVE_FROM_DEALER_DURATION, 
                            cc.p(p.x, p.y)
                    )),
                    {delay = i * MOVE_DELAY_TIME / chipNum}
                )
            else
                transition.execute(
                    sp, 
                    cc.EaseSineOut:create(cc.MoveTo:create(
                            MOVE_FROM_DEALER_DURATION, 
                            cc.p(p.x, p.y)
                    )),
                    {delay = MOVE_DELAY_TIME, onComplete = function()
                        if callback then
                            callback()
                        end
                    end}
                )
            end
        end
    end
end

function DiceBetChipView:reset()
    if self.potData_ then
        self.manager_:recycleChipData(self.potData_)
    end
    self.potData_ = {}
    self.chips_ = 0
end

return DiceBetChipView