--
-- Author: viking@boomegg.com
-- Date: 2014-11-25 15:37:06
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--
local BetChipBar = class("BetChipBar", function()
    return display.newNode()
end)

local BetChip = import(".BetChip")

function BetChipBar:ctor(preBlind, isInRoom, isGcoins, callback)
    self.callback_ = callback
    self.isInRoom = isInRoom
    self.isGcoins = isGcoins
    local betWidth = BetChip.WIDTH
    local betHeight = BetChip.HEIGHT
    --筹码1
    local betChip1MarginLeft = 24
    local betChipMarginBottom = 5
    local padding = 22
    local CHIP_Y = betHeight / 2 + betChipMarginBottom

    local betChipTxts = {"0", "0", "0"}
    if type(preBlind) == "table" then
        betChipTxts[1] = tostring(preBlind[1])
        betChipTxts[2] = tostring(preBlind[2])
        betChipTxts[3] = tostring(preBlind[3])
    else
        betChipTxts[1] = tostring(preBlind * 1)
        betChipTxts[2] = tostring(preBlind * 3)
        betChipTxts[3] = tostring(preBlind * 5)
    end
    -- 
    self.betChips = {}
    -- 
    local betChip
    for i=1,3 do
        betChip = self:getBetChip_(i, betChipTxts[i], betChip1MarginLeft, CHIP_Y, padding)
        table.insert(self.betChips, betChip)
    end
    -- 
    self:initBetStatus()
    self.betChips[1]:setGlow(true)
    self.bet_ = self.bet_ or self.betChips[1]:getBet()
    print("BetChipBar:ctor", self.bet_)
end

function BetChipBar:getBetChipResId(idx)
    local normalResId, glowResId,lblcolor,offy
    if self.isGcoins then
        normalResId = "slot_gcoin_unselected.png"
        glowResId = "slot_gcoin_selected.png"
        lblcolor = cc.c3b(137,69,16)
        offy = 2
    else
        normalResId = "slot_bet_chip"..idx.."_unselected.png"
        glowResId = "slot_bet_chip"..idx.."_selected.png"
        lblcolor = cc.c3b(0xff,0xff,0xff)
        offy = 0
    end

    return normalResId, glowResId,lblcolor,offy
end

function BetChipBar:getBetChip_(idx, betChipTxt, px, py, padding)
    local normalResId, glowResId, lblcolor, offy = self:getBetChipResId(idx)
    py = py + offy
    -- 
    local betChip = BetChip.new({
        normal = "#"..normalResId,
        glow = "#"..glowResId,
        text = betChipTxt,
        callback = handler(self, self.selectedCallback_),
        isInRoom = self.isInRoom,
        isGcoins = self.isGcoins,
        lblcolor = lblcolor
    })
    :pos(BetChip.WIDTH/2*(idx*2-1) + px + padding*(idx-1), py)
    :addTo(self)

    return betChip
end

function BetChipBar:initBetStatus()
    for _, betChip in ipairs(self.betChips) do
        betChip:setGlow(false)
    end
end

function BetChipBar:setPreBlind(preBlind, isGcoins)
    print("BetChipBar:setPreBlind", preBlind)
    self.isGcoins = isGcoins
    self:initBetStatus()
    -- 
    local betChip, betVal
    local normalResId, glowResId, lblcolor, offy
    for i=1,#self.betChips do
        normalResId, glowResId, lblcolor, offy = self:getBetChipResId(i)
        betChip = self.betChips[i]
        betChip:setStylesResId(normalResId, glowResId, lblcolor)
        -- 
        if type(preBlind) == "table" then
            betVal = preBlind[i]
        else
            betVal = preBlind * (i*2-1)
        end
        betChip:setBetLabel(betVal)

        if i == 1 then
            betChip:setGlow(true)
            self.bet_ = betChip:getBet()
        end
    end
    -- 
    print("BetChipBar:setPreBlind", self.bet_)
    if self.callback_ then
        self.callback_(self.bet_)
    end
end

function BetChipBar:selectedCallback_(target)
    self:initBetStatus()
    target:setGlow(true)
    self.bet_ = target:getBet()
    print("BetChipBar:selectedCallback_", self.bet_)
    if self.callback_ then
        self.callback_(self.bet_)
    end
end

function BetChipBar:getBet()
    return self.bet_ or 0
end

function BetChipBar:dispose()
    -- body
end

return BetChipBar
