--
-- Author: tony
-- Date: 2014-07-08 15:00:15
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local ChipManager = class("ChipManager")

local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local GrabChipData = import("app.module.room.model.ChipData")
local BetChipView = import(".views.BetChipView")
local PotChipView = import(".views.PotChipView")
local RoomViewPosition = import(".views.RoomViewPosition")
local BP = RoomViewPosition.BetPosition
local logger = bm.Logger.new("ChipManager")

function ChipManager:ctor()
end

function ChipManager:createNodes()
    -- 文字背景层，不移动，根据positionId确定位置
    self.textBgBatchNode_ = display.newNode()--newBatchNode("room_texture.png")
        :addTo(self.scene.nodes.chipNode)
    self.betChipTextBgs_ = {}
    for i = 1, 10 do--9
        self.betChipTextBgs_[i] = display.newSprite("#room_chip_text_bg.png")
            :addTo(self.textBgBatchNode_)
            :pos(BP[i].x, BP[i].y)
            :hide()
    end

    -- 文字标签层，不移动，根据positionId或者potId确定位置
    self.betChipTextLabels_ = {}
    for i = 1, 10 do--9
        self.betChipTextLabels_[i] = ui.newTTFLabel({text = "999.9M", size = 20, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 204, 0)})
            :addTo(self.scene.nodes.chipNode)
            :pos(BP[i].x, BP[i].y)
            :hide()
    end

    -- 筹码对象池
    local function funcFactory(filename, oddOrEven, key)
        return function()
            return GrabChipData.new(filename, oddOrEven, key)
        end
    end
    self.chipPool_ = {}
    self.chipPool_.odd = {}
    self.chipPool_.odd[1] = bm.ObjectPool.new(funcFactory("#room_chip_odd_1.png", "odd", 1), true, 10, 15, true)
    self.chipPool_.odd[2] = bm.ObjectPool.new(funcFactory("#room_chip_odd_2.png", "odd", 2), true, 10, 15, true)
    self.chipPool_.odd[5] = bm.ObjectPool.new(funcFactory("#room_chip_odd_5.png", "odd", 5), true, 10, 15, true)
    self.chipPool_.even = {}
    self.chipPool_.even[1] = bm.ObjectPool.new(funcFactory("#room_chip_even_1.png", "even", 1), true, 10, 15, true)
    self.chipPool_.even[2] = bm.ObjectPool.new(funcFactory("#room_chip_even_2.png", "even", 2), true, 10, 15, true)
    self.chipPool_.even[5] = bm.ObjectPool.new(funcFactory("#room_chip_even_5.png", "even", 5), true, 10, 15, true)

    -- 筹码容器
    self.chipBatchNode_ = display.newNode()--newBatchNode("room_texture.png")
        :addTo(self.scene.nodes.chipNode)
    -- 下注筹码试图，key由seatId确定
    self.betChipViews_ = {}
    for i = 0, 9 do--8
        self.betChipViews_[i] = BetChipView.new(self.chipBatchNode_, self, i)
    end
    -- 下注筹码试图，key由potId确定
    self.potChipViews_ = {}
    for i = 1, 10 do
        self.potChipViews_[i] = PotChipView.new(self.chipBatchNode_, self, i)
    end
end

-- 登录成功，设置登录筹码堆
function ChipManager:setLoginChipStacks()
    local gameInfo = self.model.gameInfo
    local playerList = self.model.playerList

    -- 下注筹码堆
    for i = 0, 9 do
        if playerList[i] then
            local betTotalChips = playerList[i].betChips
            local seatId        = playerList[i].seatId
            local positionId    = self.seatManager:getSeatPositionId(seatId)
            self.betChipViews_[seatId]:resetChipStack(betTotalChips)
            self:modifyBetText(betTotalChips, positionId)
        end
    end
end

-- 坐下动画，移动筹码堆
function ChipManager:moveChipStack()
    for i = 0, 9 do
        local positionId = self.seatManager:getSeatPositionId(i)
        self.betChipViews_[i]:rotate(positionId)
        self:modifyBetText(self.betChipViews_[i]:getBetTotalChips(), positionId)
    end
end

-- 筹码下注动画
function ChipManager:betChip(player)
    local betChips      = player.currBetChips 
    local totalBetChips = player.betChips
    if player.isDealer then
        betChips = player.betChips --此为庄家的下注
    end
    local seatId        = player.seatId
    local positionId    = self.seatManager:getSeatPositionId(seatId)
    if betChips and betChips > 0 then
        -- 播放下注动画
        self.betChipViews_[seatId]:moveFromSeat(betChips, totalBetChips)
        self:modifyBetText(totalBetChips, positionId)
    end
end

function ChipManager:betChipToPot(player)
    local betChips      = 0
    if player and checkint(player.trunMoney) < 0 then
        betChips = -player.trunMoney
    end
    if player.isDealer then
        betChips = player.betChips --此为庄家的下注
    end
    local seatId        = player.seatId
    if betChips and betChips > 0 then
        -- 播放下注动画
        self.betChipViews_[seatId]:moveFromSeatToPot(betChips)
    end
end

function ChipManager:clearChip(seatId)    
    local positionId    = self.seatManager:getSeatPositionId(seatId)
    self.betChipViews_[seatId]:reset(0)
    self:modifyBetText(0, positionId)
end

-- 设置下注筹码数字
function ChipManager:modifyBetText(chips, positionId)
    if chips > 0 then
        self.betChipTextBgs_[positionId]:show()
        self.betChipTextLabels_[positionId]:show():setString(bm.formatBigNumber(chips))
    else
        self.betChipTextBgs_[positionId]:hide()
        self.betChipTextLabels_[positionId]:hide()
    end
end

-- 合奖池动画
function ChipManager:gatherPot()
    -- 设置需要移至奖池区的筹码数据
    for i = 0, 9 do --8
        self.betChipViews_[i]:setPotChipData()
    end

    if self.gatherPotScheduleHandle_ then
        scheduler.unscheduleGlobal(self.gatherPotScheduleHandle_)
    end

    self.gatherPotScheduleHandle_ = scheduler.performWithDelayGlobal(
        handler(self, self.gatherPotDelayCallback_), 
        BetChipView.MOVE_FROM_SEAT_DURATION 
    )
end

function ChipManager:gatherPotDelayCallback_()
    for seatId = 0, 9 do --8
        self.betChipViews_[seatId]:moveToPot()
        self:modifyBetText(self.betChipViews_[seatId]:getBetTotalChips(), self.seatManager:getSeatPositionId(seatId))
    end
    self.createPotScheduleHandle_ = scheduler.performWithDelayGlobal(
        handler(self, self.createPotDelayCallback_), 
        BetChipView.MOVE_TO_POT_DURATION
    )
end

function ChipManager:createPotDelayCallback_()    
    self.potChipViews_[1]:resetChipStack(self.model.gameInfo.totalAnte)
    self:modifyPotText(self.model.gameInfo.totalAnte, 1) 
end

-- 设置奖池筹码数字
function ChipManager:modifyPotText(chips, potId)

end

-- 分奖池
function ChipManager:splitPots()
    self.potChipViews_[1]:reset()
    for i=0,9 do
        local player = self.model.playerList[i]
        if player then
            local seatId = player.seatId
            -- local positionId = self.seatManager:getSeatPositionId(seatId)
            if player.trunMoney ~= nil and player.trunMoney > 0 then
                if  player.trunMoney ~= player.betChips then
                    self.seatManager:playSeatWinAnimation(seatId)
                end
                if i < 10 then            
                    self.potChipViews_[seatId + 1]:resetChipStack(player.trunMoney)
                    self.potChipViews_[seatId + 1]:moveToSeat(seatId, function(localPotChips) 
                        local player = self.model.playerList[seatId]
                        if player then
                            player.betChips = 0
                            --player.seatChips = player.seatChips + winChips - fee
                            self.seatManager:updateSeatState(seatId)
                        end
                    end)
                end

                -- 播放筹码声音
                nk.SoundManager:playSound(nk.SoundManager.MOVE_CHIP)

                -- 如果是自己，播放赢牌动画
                if self.model:selfSeatId() == seatId and player.trunMoney ~= player.betChips then
                    self.animManager:playYouWinAnim()
                end
            end
        end
    end
end

-- 从对象池获取筹码数据
function ChipManager:getChipData(chips)
    local numStr = tostring(chips)
    local strLen = string.len(numStr)
    local ChipDataArr = {}
    for i = strLen, 1, -1 do
        local oddOrEven
        local value
        if (strLen - i + 1) % 2 == 0 then
            oddOrEven = "even"
        else
            oddOrEven = "odd"
        end
        
        value = checkint(string.sub(numStr, i, i))
        if value > 5 then
            table.insert(ChipDataArr, self.chipPool_[oddOrEven][5]:retrive())
            value = value - 5
        end
        while value >= 2 do
            table.insert(ChipDataArr, self.chipPool_[oddOrEven][2]:retrive())
            value = value - 2
        end
        if value == 1 then
            table.insert(ChipDataArr, self.chipPool_[oddOrEven][1]:retrive())
        end
    end
    return ChipDataArr
end

-- 回收筹码数据
function ChipManager:recycleChipData(ChipDataArr)
    if ChipDataArr then
        for _, ChipData in pairs(ChipDataArr) do
            ChipData:getSprite():opacity(255):removeFromParent()
            self.chipPool_[ChipData:getOddOrEven()][ChipData:getKey()]:recycle(ChipData)
        end
    end
end

-- 重置筹码视图
function ChipManager:reset()
    -- 重置定时器
    if self.gatherPotScheduleHandle_ then
        scheduler.unscheduleGlobal(self.gatherPotScheduleHandle_)
    end
    if self.createPotScheduleHandle_ then
        scheduler.unscheduleGlobal(self.createPotScheduleHandle_)
    end
    if self.splitPotsScheduleHandle_ then
        scheduler.unscheduleGlobal(self.splitPotsScheduleHandle_)
    end

    -- 重置筹码堆
    for _, v in pairs(self.betChipViews_) do
        v:reset()
    end
    for _, v in pairs(self.potChipViews_) do
        v:reset()
    end

    -- 隐藏文字显示区
    for i = 1, 10 do
        self.betChipTextBgs_[i]:hide()
        self.betChipTextLabels_[i]:hide()
    end
end

-- 清理
function ChipManager:dispose()
    -- 重置定时器
    if self.gatherPotScheduleHandle_ then
        scheduler.unscheduleGlobal(self.gatherPotScheduleHandle_)
    end
    if self.createPotScheduleHandle_ then
        scheduler.unscheduleGlobal(self.createPotScheduleHandle_)
    end
    if self.splitPotsScheduleHandle_ then
        scheduler.unscheduleGlobal(self.splitPotsScheduleHandle_)
    end

    -- 释放下注和奖池筹码视图
    for _, v in pairs(self.betChipViews_) do
        v:dispose()
    end
    for _, v in pairs(self.potChipViews_) do
        v:dispose()
    end

    -- 释放对象池
    for _, v in pairs(self.chipPool_.odd) do
        v:dispose()
    end
    for _, v in pairs(self.chipPool_.even) do
        v:dispose()
    end
end

return ChipManager