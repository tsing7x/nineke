--
-- Author: tony
-- Date: 2014-07-08 14:27:55
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local DealCardManager = class("DealCardManager")

local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local RoomViewPosition = import(".views.RoomViewPosition")
local P = RoomViewPosition.DealCardPosition
local log = bm.Logger.new("DealCardManager")
local tweenDuration = 0.5
local tweenDuration4K = 0.25

local BIG_CARD_SCALE = 116 * 0.8 / 32

function DealCardManager:ctor()
    self.startDeal_ = false
end

function DealCardManager:createNodes()
    -- self.cardBatchNode_ = display.newBatchNode("room_texture.png"):addTo(self.scene.nodes.dealCardNode)
    self.cardBatchNode_ = display.newNode():addTo(self.scene.nodes.dealCardNode)
    self.numNeedCards_ = 0
    --最多9个人，先创建好27张牌反面
    self.dealCards_ = {}
    for i = 1, 5 do
        self.dealCards_[i] = {}
        for j = 1, 9 do
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
function DealCardManager:dealCards(currentRound)
    if currentRound==1 then
        self.showOver_ =  nil -- FIX NOT CALL callBack
    end
    local roomType = self.model.roomInfo.roomType
    log:info("self.model.roomInfo.roomType ", roomType)
    if currentRound == 1 and roomType == consts.ROOM_TYPE.NORMAL then -- 一次性发3张
        self:dealCardsWithRound(1, 3)
    elseif currentRound == 1 and roomType == consts.ROOM_TYPE.PRO then -- 第一轮发2张
        self:dealCardsWithRound(1, 2)
    elseif currentRound == 2 and roomType == consts.ROOM_TYPE.PRO then -- 第二轮发1张，即第3张
        -- 第一轮还有牌未发完的极端情况
        if self.numNeedCards_ > 0 then
            scheduler.performWithDelayGlobal(handler(self, function (obj)
                obj:dealCardsWithRound(3, 3)
            end), self.numNeedCards_ * 0.1)
        else
            self:dealCardsWithRound(3, 3)
        end
    elseif currentRound == 1 and roomType == consts.ROOM_TYPE.TYPE_4K then
        self:dealCardsWithRound(1,4,true)
    elseif currentRound == 2 and roomType == consts.ROOM_TYPE.TYPE_4K then
        if self.numNeedCards_ > 0 then
            scheduler.performWithDelayGlobal(handler(self, function (obj)
                obj:dealCardsWithRound(3, 3)
            end), self.numNeedCards_ * 0.1)
        else
            self:dealCardsWithRound(3, 3)
        end
    elseif currentRound == 1 and roomType == consts.ROOM_TYPE.TYPE_5K then
        self:dealCardsWithRound(1,5,true)
    end
end

-- startDealIndex扑克牌起始ID，endDealIndex扑克牌结束ID  ID为1， 2，3
function DealCardManager:dealCardsWithRound(startDealIndex, endDealIndex,is4K)
    if not self.dealCards_ then
        return self
    end
    if is4K then
        self.is4K_ = is4K
    else
        self.is4K_ = false
    end
    self.currentDealSeatId_ = -1  -- 初始发牌座位id
    self.numInGamePlayers_  = 0   -- 在玩玩家数量
    self.numNeedCards_      = 0   -- 需要发牌的数量
    self.numDealedCards_    = 0   -- 已经发牌的数量
    self.dealSeatIdList_    = nil -- 需要发牌的座位id列表
    self.dealCardsNum_ = endDealIndex - startDealIndex + 1 --每个玩家的扑克牌数量
    local gameInfo = self.model.gameInfo
    local playerList = self.model.playerList

    self.tempIndex_ = nil  -- 发牌BUG

    if startDealIndex == 1 then
        self.currentDealSeatId_ = gameInfo.dealerSeatId -- 从第一轮开始，则先从庄家位置开始发牌
        self.numInGamePlayers_ = self.model:getNumInRound() -- 当前在玩人数
        self.numNeedCards_ = self.numInGamePlayers_ * (endDealIndex - startDealIndex + 1) -- 计算本次需要发多少张牌
        self.dealSeatIdList_ = {}
        local index = 1
        for i = 0, 8 do
            if playerList[i] and playerList[i].inRound then
                self.dealSeatIdList_[index] = i
                if i == self.currentDealSeatId_ then
                    self.tempIndex_ = index
                end
                index = index + 1
            end
        end
    else
        --[[
            不是从第一轮开始，如庄家在玩，则先从庄家位置开始发牌；
            如庄家不在玩，则找到离庄家最近的下一位在玩玩家开始发牌。
        ]] 
        for i = 0, 8 do
            local seatId = gameInfo.dealerSeatId + i
            if seatId > 8 then
                seatId = seatId - 9
            end
            local player = playerList[seatId]
            if player and player.inGame then
                self.currentDealSeatId_ = seatId
                break
            end
        end

        -- 计算当前在玩人数
        self.dealSeatIdList_ = {}
        local index = 1
        for i = 0, 8 do
            local player = playerList[i]
            if player and player.inGame then
                self.dealSeatIdList_[index] = i
                if i == self.currentDealSeatId_ then
                    self.tempIndex_ = index
                end
                index = index + 1
                self.numInGamePlayers_ = self.numInGamePlayers_ + 1
            end
        end
        self.numNeedCards_ = self.numInGamePlayers_ * (endDealIndex - startDealIndex + 1) -- 计算本次需要发多少张牌
    end
    -- 发牌报错【发牌时候玩家正好离开】只显示两张或者一张牌
    if not self.tempIndex_ then
        local index = 1
        for i = 0, 8 do
            local seatId = gameInfo.dealerSeatId + i
            if seatId > 8 then
                seatId = seatId - 9
            end
            local player = playerList[seatId]
            if player and player.inGame then
                self.currentDealSeatId_ = seatId
                self.tempIndex_ = index
                break
            end
            index = index + 1
        end
    end

    -- 发牌定时器
    if self.currentDealSeatId_ >= 0 and self.currentDealSeatId_ <= 8 then
        self.startDealIndex_ = startDealIndex -- 开始发第几张牌
        if self.scheduleHandle_ then
            scheduler.unscheduleGlobal(self.scheduleHandle_)
            self.startDeal_ = false
            self.stopPos = {}
            self.scheduleHandle_ = nil
        end
        self.startDeal_ = true
        self.scheduleHandle_  = scheduler.scheduleGlobal(handler(self, self.scheduleHandler), 0.1)
    end

    return self
end

function DealCardManager:scheduleHandler()
    if self.is4K_ then
        self:dealCard4K_(self.seatManager:getSeatPositionId(self.currentDealSeatId_))
    else
        self:dealCard_(self.seatManager:getSeatPositionId(self.currentDealSeatId_))
    end
    -- 找到下一个需要发牌的座位id
    self.currentDealSeatId_ = self:findNextDealSeatId_()

    -- 已发牌总数加1
    self.numDealedCards_ = self.numDealedCards_ + 1
    -- if self.numDealedCards_ == self.numInGamePlayers_ or self.numDealedCards_ == self.numInGamePlayers_ * 2 or self.numDealedCards_ == self.numInGamePlayers_ * 3 then
    --     self.startDealIndex_ = self.startDealIndex_ + 1
    -- end
    if self.numDealedCards_ % self.numInGamePlayers_ == 0 then
        self.startDealIndex_ = self.startDealIndex_ + 1
    end
    -- 需发牌总数减1，发牌总数为0则已发完，结束发牌
    self.numNeedCards_ = self.numNeedCards_ - 1
    if self.numNeedCards_ == 0 then
        scheduler.unscheduleGlobal(self.scheduleHandle_)
        self.startDeal_ = false
        self.stopPos = {}
        self.scheduleHandle_ = nil
    end
end

function DealCardManager:dealCard_(positionId)
    local dealingcard = self.dealCards_[self.startDealIndex_][positionId]
    if not dealingcard then return end

    if dealingcard:getParent() then
        dealingcard:removeFromParent()
    end
    dealingcard:setScale(1)
    if dealingcard:getNumberOfRunningActions() == 0 then
        dealingcard:addTo(self.cardBatchNode_):pos(P[10].x, P[10].y):rotation(180)
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
    local seatView = self.seatManager:getSeatView(self.currentDealSeatId_)
    if self.model:isSelfInSeat() and positionId == 5 then
        local seatData = seatView:getSeatData()
        local cardIndex = self.startDealIndex_
        local cardNum = self.dealCardsNum_
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
        transition.scaleTo(dealingcard, {scaleX=BIG_CARD_SCALE, scaleY=BIG_CARD_SCALE, time=tweenDuration,onComplete=function()
            if self.model:isSelfInSeat() then
                if dealingcard:getParent() then
                    dealingcard:removeFromParent()
                end
                if cardIndex == cardNum and (cardNum == 2 or cardNum == 3) then
                    --发专业场的第二张和普通场的第三张时翻牌
                    seatView:showHandCardsElement(cardIndex)
                    seatView:flipAllHandCards()
                    self.schedulerPool:delayCall(function() 
                        seatView:showCardTypeIf()
                    end, 0.8)
                elseif cardIndex == 3 and cardNum == 1 then
                    --发专业场的第三张时，只翻第三张
                    seatView:setHandCardNum(3)
                    seatView:setHandCardValue(seatData.handCards)
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
        transition.moveTo(dealingcard, {time=tweenDuration, x=targetX, y=P[positionId].y, onComplete=function() 
                if self.showOver_==true then
                    dealingcard:removeFromParent()
                end
            end})
        dealingcard:rotateTo(tweenDuration, targetR)
    else
        transition.moveTo(dealingcard, {time=tweenDuration, x=targetX, y=P[positionId].y, onComplete=function() 
                if (not seatView:getSeatData() and dealingcard:getParent()) or self.showOver_==true then
                    dealingcard:removeFromParent()
                end
            end})
        dealingcard:rotateTo(tweenDuration, targetR)
    end
    nk.SoundManager:playSound(nk.SoundManager.DEAL_CARD)
end

function DealCardManager:dealCard4K_(positionId)
    local dealingcard = self.dealCards_[self.startDealIndex_][positionId]
    if not dealingcard then return end

    if dealingcard:getParent() then
        dealingcard:removeFromParent()
    end
    dealingcard:setScale(1)
    if dealingcard:getNumberOfRunningActions() == 0 then
        dealingcard:addTo(self.cardBatchNode_):pos(P[10].x, P[10].y):rotation(180)
    end

    local targetX
    local targetR
    if self.startDealIndex_ == 1 then
        targetX = P[positionId].x - 16
        targetR = -12
    elseif self.startDealIndex_ == 2 then
        targetX = P[positionId].x - 8
        targetR = -6
    elseif self.startDealIndex_ == 3 then
        targetX = P[positionId].x
        targetR = 0
    elseif self.startDealIndex_ == 4 then
        targetX = P[positionId].x + 8
        targetR = 6
    elseif self.startDealIndex_ == 5 then
        targetX = P[positionId].x + 16
        targetR = 12
    end

    local seatView = self.seatManager:getSeatView(self.currentDealSeatId_)
    if self.model:isSelfInSeat() and positionId == 5 then
        local seatData = seatView:getSeatData()
        local cardIndex = self.startDealIndex_
        local cardNum = self.dealCardsNum_
        local CARD_GAP = 60
        -- if self.startDealIndex_ == 1 then
        --     targetX = display.cx - (self.startDealIndex_ - (cardNum + 1) / 2) * CARD_GAP
        -- elseif self.startDealIndex_ == 2 then
        --     targetX = display.cx - (self.startDealIndex_ - (cardNum + 1) / 2) * CARD_GAP
        -- elseif self.startDealIndex_ == 3 then
        --     targetX = display.cx + (self.startDealIndex_ - (cardNum + 1) / 2) * CARD_GAP
        -- elseif self.startDealIndex_ == 4 then
        --     targetX = display.cx + (self.startDealIndex_ - (cardNum + 1) / 2) * CARD_GAP
        -- elseif self.startDealIndex_ == 5 then
        --     targetX = display.cx + (self.startDealIndex_ - (cardNum + 1) / 2) * CARD_GAP
        -- end
        targetX = display.cx + (self.startDealIndex_ - (cardNum + 1) / 2) * CARD_GAP
        local selectView = self.scene:getSelectCardView()
        assert(selectView ~= nil,"selectView must have a view")
        selectView:show()
        transition.scaleTo(dealingcard, {scaleX=BIG_CARD_SCALE * 1.2, scaleY=BIG_CARD_SCALE * 1.2, time=tweenDuration4K,onComplete=function()
            if self.model:isSelfInSeat() then
                if dealingcard:getParent() then
                    dealingcard:removeFromParent()
                end
                if cardIndex == self.dealCardsNum_ then
                    if selectView ~= nil then
                        selectView:flipAllCards()
                    end
                else
                    if selectView ~= nil then
                        selectView:showWithIndex(cardIndex)
                    end
                end

            elseif not seatView:getSeatData() then
                if dealingcard:getParent() then
                    dealingcard:removeFromParent()
                end
            end
        end})
        transition.moveTo(dealingcard, {time=tweenDuration4K, x=targetX, y=display.cy - 150, onComplete=function() 
            end})
        dealingcard:rotateTo(tweenDuration4K, 720)
    else
        if self.stopPos and #self.stopPos > 0 then
            for i,v in pairs(self.stopPos) do
                if positionId == v then
                    dealingcard:removeFromParent()
                    return 
                end
            end
        end
        transition.moveTo(dealingcard, {time=tweenDuration4K, x=targetX, y=P[positionId].y, onComplete=function() 
                if (not seatView:getSeatData() and dealingcard:getParent()) or self.showOver_==true then
                    dealingcard:removeFromParent()
                end
            end})
        dealingcard:rotateTo(tweenDuration4K, targetR)
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
    for i = 1, 5 do
        local foldingCard = self.dealCards_[i][positionId]
        if foldingCard:getParent() then
            local moveAction = cc.MoveTo:create(tweenDuration, cc.p(P[10].x, P[10].y))
            local rotateAction = cc.RotateTo:create(tweenDuration, 180)
            local callback = cc.CallFunc:create(function ()
                foldingCard:removeFromParent()
            end)
            foldingCard:runAction(cc.Sequence:create(cc.Spawn:create(moveAction, rotateAction), callback))
        end
    end
end

function DealCardManager:drop4kCard(player)
    local positionId = self.seatManager:getSeatPositionId(player.seatId)
    local foldCount = 1
    for i = 5, 1,-1 do
        local foldingCard = self.dealCards_[i][positionId]
        if foldingCard:getParent() then
            local moveAction = cc.MoveTo:create(tweenDuration, cc.p(P[10].x, P[10].y))
            local rotateAction = cc.RotateTo:create(tweenDuration, 180)
            local callback = cc.CallFunc:create(function ()
                foldingCard:removeFromParent()
            end)
            if foldCount > 2 then
                break
            else
                foldCount = foldCount + 1
            end
            foldingCard:runAction(cc.Sequence:create(cc.Spawn:create(moveAction, rotateAction), callback))
        end
    end
end

-- function DealCardManager:fold4kCard(player)
--     local positionId = self.seatManager:getSeatPositionId(player.seatId)
--     for i = 1, 4 do
--         local foldingCard = self.dealCards_[i][positionId]
--         if foldingCard:getParent() then
--             local moveAction = cc.MoveTo:create(tweenDuration, cc.p(P[10].x, P[10].y))
--             local rotateAction = cc.RotateTo:create(tweenDuration, 180)
--             local callback = cc.CallFunc:create(function ()
--                 foldingCard:removeFromParent()
--             end)
--             foldingCard:runAction(cc.Sequence:create(cc.Spawn:create(moveAction, rotateAction), callback))
--         end
--     end
-- end

function DealCardManager:drop4kCardSelf(holdcards)
    local holdNum = 0
    for i,v in pairs(holdcards) do
        if v ~= 0 then
            holdNum = holdNum + 1
        end
    end
    local seatView = self.seatManager:getSelfSeatView()
    seatView:setHandCardNum(holdNum)
    seatView:setHandCardValue(seatView:getSeatData().handCards)
    local selectView = self.scene:getSelectCardView()
    assert(selectView ~= nil,"selectView must have a view")
    local holdIndex = 1
    local foldIndex = 1
    selectView:showDropCardAnim(holdcards,function(isHold,foldcards)
            if isHold then
                if holdIndex >= holdNum then
                    seatView:showHandCards()
                    seatView:showHandCardsElement(holdIndex)
                    seatView:showHandCardFrontAll()
                    seatView:showCardTypeIf()
                else
                    seatView:showHandCardsElement(holdIndex)
                end
                holdIndex = holdIndex + 1
            else
                if foldIndex == 2 then
                    self:showFoldCard(foldcards)
                end
                foldIndex = foldIndex + 1
            end
        end)
    -- self.schedulerPool:delayCall(function() 
    --     self.scene:removeSelectCardView()
    -- end, 0.8)
end

function DealCardManager:fold4kCardSelf(player)
    local seatView = self.seatManager:getSelfSeatView()
    local selectView = self.scene:getSelectCardView()
    seatView:setFoldCardValue(seatView:getSeatData().handCards_4k)
    assert(selectView ~= nil,"selectView must have a view")
    local cardIndex = 1
    selectView:showFoldCardAnim(function()
            if cardIndex >= 4 then
                seatView:showFoldCards()
            end
            cardIndex = cardIndex + 1
        end)
    -- self.schedulerPool:delayCall(function() 
    --     self.scene:removeSelectCardView()
    -- end, 0.8)
    self:foldCard(player)
end

function DealCardManager:showFoldCard(cards)
    local PokerCard = nk.ui.PokerCard
    self.cards = {}
    for i = 1,#cards do 
        self.cards[i] = PokerCard.new():pos(P[10].x + 30 * i, P[10].y):addTo(self.scene.nodes.dealCardNode):scale(32 / 116)
        self.cards[i]:setCard(cards[i])
        self.cards[i]:showFront()
        self.cards[i]:addDark()
    end
end

function DealCardManager:cleanFoldCard()
    if self.cards then
        local count = #self.cards
        if count <=0 then return end 
        for i = 1,count do
            if self.cards[i] then
                self.cards[i]:removeFromParent()
                self.cards[i] = nil
            end
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
        deadCard:show()
        deadCard:setScale(1)
        if i <= cardNum then
            deadCard:addTo(self.cardBatchNode_):pos(P[positionId].x + (i - (cardNum + 1) /2 )* 8, P[positionId].y):rotation((i - (cardNum + 1) /2 ) * 12)
        end
    end
end

-- 隐藏所有的发牌sprite
function DealCardManager:hideAllDealedCard()
    print("hideAllDealedCard")
    for i = 1, 5 do
        for j = 1, 9 do
            if self.dealCards_[i] and self.dealCards_[i][j] then
                self.dealCards_[i][j]:removeFromParent()
            end
        end
    end
end

-- 隐藏指定位置id的发牌sprite
function DealCardManager:hideDealedCard(positionId)
    print("hideDealedCard", positionId)
    for i = 1, 5 do
        local deadCard = self.dealCards_[i][positionId]
        if deadCard and deadCard:getParent() then
            deadCard:removeFromParent()
        end
    end
end

function DealCardManager:stopDealCardToPos(positionId)
    if self.startDeal_ then
        if self.stopPos then
            table.insert(self.stopPos,positionId)
        else
            self.stopPos = {}
            table.insert(self.stopPos,positionId)
        end
    end
end

-- 移动至座位中央
function DealCardManager:moveDealedCardToSeat(player, callback)
    self.showOver_ = true -- FIX NOT CALL callBack
    local positionId = self.seatManager:getSeatPositionId(player.seatId)
    local destPosition = self.seatManager:getSeatPosition(player.seatId)
    if destPosition then
        for i = 1, 3 do
            local deadCard = self.dealCards_[i][positionId]
            -- FIX NOT CALL callBack
            if not deadCard:getParent() then
                deadCard:addTo(self.cardBatchNode_):pos(P[10].x, P[10].y):rotation(180)
            end
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
        for i = 1, 5 do
            for j = 1, 9 do
                self.dealCards_[i][j]:removeFromParent()
                self.dealCards_[i][j]:stopAllActions()
            end
        end
    end
    if self.scheduleHandle_ then
        scheduler.unscheduleGlobal(self.scheduleHandle_)
        self.scheduleHandle_ = nil
    end
    self:cleanFoldCard()
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