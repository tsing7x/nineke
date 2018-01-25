--
-- Author: tony
-- Date: 2014-07-08 14:27:55
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--
-- 发牌
local DealCardManager = class("DealCardManager")

local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local RoomViewPosition = import(".views.RoomViewPosition")
local SEP = RoomViewPosition.SeatPosition
local P = RoomViewPosition.DealCardPosition
local SP = RoomViewPosition.DealCardStartPosition
local log = bm.Logger.new("DealCardManager")
local tweenDuration = 0.5

local BIG_CARD_SCALE = 116 * 0.8 / 32

function DealCardManager:ctor()
end

function DealCardManager:createNodes()
    self.cardBatchNode_ = display.newNode():addTo(self.scene.nodes.dealCardNode)--display.newBatchNode("room_texture.png"):addTo(self.scene.nodes.dealCardNode)

    self.numNeedCards_ = 0
    self.dealCards_ = {}
    for i = 1, 3 do
        self.dealCards_[i] = {}
        for j = 1, 10 do
            self.dealCards_[i][j] = display.newSprite("#room_dealed_hand_card.png")
            self.dealCards_[i][j]:retain()
        end
    end
end

--[[
    从庄家位置开始发手牌：
        普通场一次性发3张，专业场第一次发2张，第二次再发1张，即第3张
    currentRound：
        1为游戏开始时的第一次；
        2为游戏中途的第二次，仅限专业场
]]
function DealCardManager:dealCards()
    self:dealCardsWithRound(1,2)
end

-- 给指定玩家发牌
function DealCardManager:dealCardToPlayer(seatId)
    self.currentDealSeatId_ = seatId
    self.startDealIndex_  = 3
    self.dealCardsNum_ = 1
    self:dealCard_(self.seatManager:getSeatPositionId(seatId))
end

-- roundStartIndex指定开始轮次，roundEndIndex指定结束轮次
function DealCardManager:dealCardsWithRound(startDealIndex, endDealIndex)
    if not self.dealCards_ then
        return self
    end
    self.currentDealSeatId_ = -1  -- 初始发牌座位id
    self.numInGamePlayers_  = 0   -- 在玩玩家数量
    self.numNeedCards_      = 0   -- 需要发牌的数量
    self.numDealedCards_    = 0   -- 已经发牌的数量
    self.dealSeatIdList_    = nil -- 需要发牌的座位id列表
    self.dealCardsNum_ = endDealIndex - startDealIndex + 1

    local gameInfo = self.model.gameInfo
    local playerList = self.model.playerList    

    for i = 1, 9 do
        local seatId = gameInfo.dealerSeatId + i
        if seatId > 9 then
            seatId = seatId - 10
        end
        local player = playerList[seatId]
        if player and player.isPlay == 1 then
            self.currentDealSeatId_ = seatId
            break
        end
    end
   
    -- seatId = self.model:getFirstDealCardSeatId() 
    self.currentDealSeatId_ = self.model:getFirstDealCardSeatId() 
    self.tempIndex_ = self.currentDealSeatId_

    -- 计算当前在玩人数
    self.dealSeatIdList_ = {}
    local index = 1
    for i = 0, 9 do
        local player = playerList[i]
        if player and player.isPlay == 1 then
            self.dealSeatIdList_[index] = i
            if i == self.currentDealSeatId_ then
                self.tempIndex_ = index
            end
            index = index + 1
            self.numInGamePlayers_ = self.numInGamePlayers_ + 1
        end
    end
    self.numNeedCards_ = self.numInGamePlayers_ * (endDealIndex - startDealIndex + 1) -- 计算本次需要发多少张牌

    -- seatId = self.model:getFirstDealCardSeatId() 
    -- self.currentDealSeatId_ = self.model:getFirstDealCardSeatId() 
    -- self.tempIndex_ = 9

    -- dump(self.numNeedCards_,"self.numNeedCards_")
    -- dump(self.dealSeatIdList_,"self.dealSeatIdList_")

    -- 发牌定时器
    --dump(self.currentDealSeatId_,"self.currentDealSeatId_")
    if self.currentDealSeatId_ >= 0 and self.currentDealSeatId_ <= 9 then
        self.startDealIndex_ = startDealIndex -- 开始发第几张牌
        if self.scheduleHandle_ then
            scheduler.unscheduleGlobal(self.scheduleHandle_)
            self.scheduleHandle_ = nil
        end
        self.scheduleHandle_  = scheduler.scheduleGlobal(handler(self, self.scheduleHandler), 0.1)
    end

    return self
end

function DealCardManager:scheduleHandler()
    self:dealCard_(self.seatManager:getSeatPositionId(self.currentDealSeatId_))

    -- 找到下一个需要发牌的座位id

    self.currentDealSeatId_ = self:findNextDealSeatId_()
    -- 已发牌总数加1
    self.numDealedCards_ = self.numDealedCards_ + 1
    if self.numDealedCards_ == self.numInGamePlayers_ or self.numDealedCards_ == self.numInGamePlayers_ * 2 then
        self.startDealIndex_ = self.startDealIndex_ + 1
    end

    -- 需发牌总数减1，发牌总数为0则已发完，结束发牌
    self.numNeedCards_ = self.numNeedCards_ - 1
    if self.numNeedCards_ == 0 then
        scheduler.unscheduleGlobal(self.scheduleHandle_)
        self.scheduleHandle_ = nil
    end
end

function DealCardManager:dealCard_(positionId)
    if self.dealCards_ == nil then return end
    if self.dealCards_[self.startDealIndex_] == nil then return end -- 这里可能是空的
    local dealingcard = self.dealCards_[self.startDealIndex_][positionId]
    if not dealingcard then return end

    if dealingcard:getParent() then
        dealingcard:removeFromParent()
    end
    dealingcard:setScale(1)
    if dealingcard:getNumberOfRunningActions() == 0 then
        local dealerSeatId = -1
        if self.ctx.model.gameInfo.dealerSeatId and self.ctx.model.gameInfo.dealerSeatId >= 0 then
            dealerSeatId = self.ctx.model.gameInfo.dealerSeatId
        end
        local startPosId = 10
        if dealerSeatId ~= -1 then
            startPosId = self.seatManager:getSeatPositionId(dealerSeatId)
        end
        dealingcard:addTo(self.cardBatchNode_):pos(SP[startPosId].x, SP[startPosId].y):rotation(180)
    end

    local targetX
    local targetR
    if self.startDealIndex_ == 1 then
        targetX = P[positionId].x - 8
        targetR = -12
    elseif self.startDealIndex_ == 2 then
        targetX = P[positionId].x
        targetR = 0
    elseif self.startDealIndex_ == 3 then
        targetX = P[positionId].x + 8
        targetR = 12
    end
    local cardIndex = self.startDealIndex_
    local cardNum = self.dealCardsNum_
    local seatView = self.seatManager:getSeatView(self.currentDealSeatId_)
    local seatData = seatView:getSeatData()
    local selfSeatId = self.model:selfSeatId()
    local selfSeatPosId = self.seatManager:getSeatPositionId(selfSeatId)
    
    if self.model:isSelfInSeat() and (positionId == selfSeatPosId) then        
        if cardNum == 2 then
            if self.startDealIndex_ == 1 then
                targetX = targetX + 60 - 6
            elseif self.startDealIndex_ == 2 then
                targetX = targetX + 60 + 6
            end
        else
            if self.startDealIndex_ == 1 then
                targetX = targetX + 60 - 6
            elseif self.startDealIndex_ == 2 then
                targetX = targetX + 60
            elseif self.startDealIndex_ == 3 then
                targetX = targetX + 60 + 6
            end
        end
        local targetY = P[positionId].y
        if selfSeatId ~= 9 then
            targetX = targetX - 100
            targetY = targetY + 40
        end
        transition.scaleTo(dealingcard, {scaleX=BIG_CARD_SCALE, scaleY=BIG_CARD_SCALE, time=tweenDuration,onComplete=function()
            if self.model:isSelfInSeat() then
                if dealingcard:getParent() then
                    dealingcard:removeFromParent()
                end
                if cardIndex == cardNum and cardNum == 2 then                    
                    seatView:showHandCardsElement(cardIndex)
                    seatView:flipAllHandCards()
                    self.schedulerPool:delayCall(function() 
                        seatView:showCardTypeIf()
                    end, 0.8)
                elseif cardIndex == 3 and cardNum == 1 then                    
                    seatView:setHandCardNum(3)
                    seatView:setHandCardValue(seatData.cards)
                    seatView:showHandCardsElement(cardIndex)
                    seatView:flipHandCardsElement(cardIndex)
                    self.schedulerPool:delayCall(function() 
                        seatView:showCardTypeIf()
                    end, 0.8)
                else
                    seatView:showHandCardsElement(cardIndex)
                end
            elseif not seatView:getSeatData() then
                if dealingcard:getParent() then
                    dealingcard:removeFromParent()
                end
            end
        end})
        dealingcard:moveTo(tweenDuration, targetX, targetY):rotateTo(tweenDuration, targetR)
    else
        transition.moveTo(dealingcard, {time=tweenDuration, x=targetX, y=P[positionId].y, onComplete=function()
                if not seatData and dealingcard:getParent() then
                    dealingcard:removeFromParent()
                else
                    if (cardIndex == cardNum and cardNum == 2) or  (cardIndex == 3 and cardNum == 1) then                    
                        self.seatManager:showHandCardByOther(seatData.seatId)
                    end
                end
            end})
        dealingcard:rotateTo(tweenDuration, targetR)
    end
    nk.SoundManager:playSound(nk.SoundManager.DEAL_CARD)
end

function DealCardManager:findNextDealSeatId_()
    self.tempIndex_ = self.tempIndex_ + 1
    if self.tempIndex_ > #self.dealSeatIdList_ then
        self.tempIndex_ = 1
    end
    return self.dealSeatIdList_[self.tempIndex_]
end

-- 玩家弃牌
function DealCardManager:foldCard(player)
    local positionId = self.seatManager:getSeatPositionId(player.seatId)
    for i = 1, 3 do
        local foldingCard = self.dealCards_[i][positionId]
        if foldingCard:getParent() then
            local moveAction = cc.MoveTo:create(tweenDuration, cc.p(P[10].x, P[10].y))
            local rotateAction = cc.RotateTo:create(tweenDuration, 180)
            local callback = cc.CallFunc:create(function ()
                foldingCard:removeFromParent()
            end)
            foldingCard:runAction(cc.Sequence:createWithTwoActions(cc.Spawn:createWithTwoActions(moveAction, rotateAction), callback))
        end
    end
end

-- 显示指定位置id的发牌sprite
function DealCardManager:showDealedCard(player, cardNum)    
    local positionId = self.seatManager:getSeatPositionId(player.seatId)
    for i = 1, cardNum do
        local deadCard = self.dealCards_[i][positionId]
        if deadCard:getParent() then
            deadCard:removeFromParent()
        end
        deadCard:setScale(1)
        if i <= cardNum then
            deadCard:addTo(self.cardBatchNode_):pos(P[positionId].x + i * 8 - 16, P[positionId].y):rotation(i * 12 - 24)
        end
    end
end

-- 隐藏所有的发牌sprite
function DealCardManager:hideAllDealedCard()
    print("hideAllDealedCard")
    for i = 1, 3 do
        for j = 1, 10 do--这里要改10
            if self.dealCards_[i] and self.dealCards_[i][j] then
                self.dealCards_[i][j]:removeFromParent()
            end
        end
    end
end

-- 隐藏指定位置id的发牌sprite
function DealCardManager:hideDealedCard(positionId)
    print("hideDealedCard", positionId)
    for i = 1, 3 do
        local deadCard = self.dealCards_[i][positionId]
        if deadCard:getParent() then
            deadCard:removeFromParent()
        end
    end
end

-- 移动至座位中央
function DealCardManager:moveDealedCardToSeat(player, callback)
    local positionId = self.seatManager:getSeatPositionId(player.seatId)
    local destPosition = self.seatManager:getSeatPosition(player.seatId)
    if self.model.isSelfDealer and self.model:isSelfDealer() then
        destPosition = SEP[positionId]
    end
    if destPosition then
        for i = 1, 3 do
            local deadCard = self.dealCards_[i][positionId]
            transition.moveTo(deadCard, {
                time = tweenDuration, 
                x = destPosition.x + i * 8 - 16, 
                y = destPosition.y,
                onComplete = function ()
                    deadCard:removeFromParent()
                    print("moveDealedCardToSeat", i)
                    if i == 1 and callback then
                        print("moveDealedCardToSeat")
                        callback()
                    end
                end
            })
        end
    end
end

-- 重置位置与角度
function DealCardManager:reset()
    print("reset")
    if self.dealCards_ then
        for i = 1, 3 do
            for j = 1, 10 do
                self.dealCards_[i][j]:removeFromParent()
                self.dealCards_[i][j]:stopAllActions()
            end
        end
    end
    if self.scheduleHandle_ then
        scheduler.unscheduleGlobal(self.scheduleHandle_)
        self.scheduleHandle_ = nil
    end
    return self
end

-- 清理
function DealCardManager:dispose()
    bm.objectReleaseHelper(self.dealCards_)
    if self.scheduleHandle_ then
        scheduler.unscheduleGlobal(self.scheduleHandle_)
        self.scheduleHandle_ = nil
    end
end

return DealCardManager