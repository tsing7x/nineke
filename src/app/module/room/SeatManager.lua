--
-- Author: tony
-- Date: 2014-07-08 12:45:14
--
local SeatManager = class("SeatManager")

local SeatView              = import(".views.SeatView")
local RoomViewPosition      = import(".views.RoomViewPosition")
local SeatProgressTimer     = import(".views.SeatProgressTimer")
local UserInfoOtherDialog   = import(".views.UserInfoOtherDialog")
local UpgradePopup          = import("app.module.upgrade.UpgradePopup")
local BuyInPopup            = import(".views.BuyInPopup")
local StorePopup            = import("app.module.newstore.StorePopup")
local UserInfoPopup         = import("app.module.userInfo.UserInfoPopup")
local FirstPayPopup         = import("app.module.firstpay.FirstPayPopup")
local GuidePayPopup         = import("app.module.firstpay.GuidePayPopup")
local SeatStateMachine      = import("app.module.room.model.SeatStateMachine")

local SeatPosition = RoomViewPosition.SeatPosition

local SEAT_PROGRESS_TIMER_TAG = 8390

local SEATS_9 = {0, 1, 2, 3, 4, 5, 6, 7, 8}
local SEATS_5 = {0, 2, 4, 6, 8}
local SEATS_2 = {2, 6}
local isMatch_ = false

local logger = bm.Logger.new("SeatManager")
local USE_COUNTER_POOL = false

function SeatManager:ctor(ctx, isMatch)
    self.appEnterForegroundListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.APP_ENTER_FOREGROUND, handler(self, self.onAppEnterForeground_))
    self.appEnterBackgroundListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.APP_ENTER_BACKGROUND, handler(self, self.onAppEnterBackground_))
    self.addExpListenerId_ =  bm.EventCenter:addEventListener(nk.eventNames.SVR_BROADCAST_ADD_EXP, handler(self, self.onAddExp))
    self.onOffLoadId_ = bm.EventCenter:addEventListener("OnOff_Load", handler(self, self.onOffLoadCallback_))
    self.onAddMoneyAnimationId_ =  bm.EventCenter:addEventListener("onAddMoneyAnimationEvent", handler(self, self.onAddMoneyAnimation))
    -- if isMatch then
    --     SEATS_5 = {0, 1, 2, 3, 4}
    -- else
    --     SEATS_5 = {0, 2, 4, 6, 8}
    -- end
end

function SeatManager:createNodes()
    --创建座位
    self.seats_ = {}
    for i = 0, 8 do
        local seat = SeatView.new(self.ctx, i) --seatId 0~8
        cc.EventProxy.new(seat, self.scene)
            :addEventListener(SeatView.CLICKED, handler(self, self.onSeatClicked_))
        self.seats_[i] = seat
    end

    --倒计时对象池
    if USE_COUNTER_POOL then
        self.counterPool_ = bm.ObjectPool.new(function()
            return SeatProgressTimer.new(self.model.roomInfo.betExpire)
        end, true, 1, 4, true)
    end
end

function SeatManager:onAppEnterBackground_()
    logger:debug("onAppEnterBackground_", self.counterSeatId_)
    local counterSeatId = self.counterSeatId_
    self:stopCounter()
    if USE_COUNTER_POOL then
        self.counterPool_:dispose()
    end
    self.counterSeatId_ = counterSeatId
end

function SeatManager:onAppEnterForeground_()
    logger:debug("onAppEnterForeground_", self.counterSeatId_)
    if USE_COUNTER_POOL then
        self.counterPool_ = bm.ObjectPool.new(function()
            return SeatProgressTimer.new(self.model.roomInfo.betExpire)
        end, true, 1, 4, true)
    end

    --延时0.1s，如果这里直接开始计时, 测试时发现有可能导致材质损坏
    self.gameSchedulerPool:delayCall(function()
        local counterSeatId = self.counterSeatId_
        if counterSeatId then
            logger:debug("startCounter", counterSeatId)
            self:stopCounter()
            self:startCounter(counterSeatId)
        end
    end, 0.1)
end

function SeatManager:dispose()
    if self.seats_ then
        for i = 0, 8 do
            local seat = self.seats_[i]
            if seat then
                local counter = seat:getChildByTag(SEAT_PROGRESS_TIMER_TAG)
                if counter then
                    counter:removeFromParent()
                end
                seat:dispose()
            end
        end
    end
    if USE_COUNTER_POOL then
        self.counterPool_:dispose()
    end
    if self.appEnterForegroundListenerId_ then
        bm.EventCenter:removeEventListener(self.appEnterForegroundListenerId_)
        self.appEnterForegroundListenerId_ = nil
    end
    if self.appEnterBackgroundListenerId_ then
        bm.EventCenter:removeEventListener(self.appEnterBackgroundListenerId_)
        self.appEnterBackgroundListenerId_ = nil
    end
    if self.addExpListenerId_ then
        bm.EventCenter:removeEventListener(self.addExpListenerId_)
        self.addExpListenerId_ = nil
    end
    if self.onOffLoadId_ then
        bm.EventCenter:removeEventListener(self.onOffLoadId_)
        self.onOffLoadId_ = nil
    end
    if self.onAddMoneyAnimationId_ then
        bm.EventCenter:removeEventListener(self.onAddMoneyAnimationId_)
        self.onAddMoneyAnimationId_ = nil
    end
end

function SeatManager:getSeatView(seatId)
    return self.seats_[seatId]
end

function SeatManager:getSelfSeatView()
    return self:getSeatView(self.model:selfSeatId())
end

function SeatManager:getSeatPosition(seatId)
    local seat = self.seats_[seatId]
    if seat then
        return SeatPosition[seat:getPositionId()]
    end
    return nil
end

function SeatManager:getSeatPositionId(seatId)
    local seat = self.seats_[seatId]
    if seat then
        return seat:getPositionId()
    end
    return nil
end

function SeatManager:getEmptySeatId()
    if self.seatIds_ then
        local playerList = self.model.playerList
        for i, seatId in ipairs(self.seatIds_) do
            if not playerList[seatId] then
                return seatId
            end
        end
    end
    return nil
end

function SeatManager:initSeats(seatsInfo, playerList)
    local model = self.model
    local scene = self.scene
    local seats = self.seats_
    assert(seatsInfo and seatsInfo.seatNum, "seatNum is nil")
    local P = SeatPosition
    local seatIds = nil
    if seatsInfo.seatNum == 9 then
        seatIds = SEATS_9
    elseif seatsInfo.seatNum == 5 then
        seatIds = SEATS_5
    elseif seatsInfo.seatNum == 2 then
        seatIds = SEATS_2
    end
    self.seatIds_ = seatIds

    self.dealCardManager:reset()
    for seatId = 0, 8 do
        local shouldShow = false
        if seatIds then
            for i, v in ipairs(seatIds) do
                if v == seatId then
                    shouldShow = true
                    break
                end
            end
        end
        local seat = self.seats_[seatId]
        if shouldShow then
            local pos = P[seatId + 1]
            seat:setPosition(pos)
            seat:setPositionId(seatId + 1)
            local player = playerList[seatId]
            seat:resetToEmpty()
            seat:setSeatData(player)
            -- 猎杀动画移动动画播放器中了，确保添加成功
            local curParent = seat:getParent()
            if curParent and curParent~=scene.nodes.seatNode then
                seat:removeFromParent()
                curParent = nil
            end

            if not curParent then
                seat:addTo(scene.nodes.seatNode, seatId + 1, seatId + 1)
                seat:enableTouch()
            end

            if player then
                local gameStatus = self.model.gameInfo.gameStatus
                if player.isSelf then
                    if self.model:roomType() == consts.ROOM_TYPE.PRO and gameStatus == consts.SVR_GAME_STATUS.BET_ROUND_1 then
                        seat:setHandCardNum(2)
                    elseif self.model:roomType() == consts.ROOM_TYPE.TYPE_4K and gameStatus == consts.SVR_GAME_STATUS.BET_ROUND_1 then
                        seat:setHandCardNum(2)
                    elseif self.model:roomType() == consts.ROOM_TYPE.TYPE_4K and gameStatus == consts.SVR_GAME_STATUS.WAIT_FOLD_CARD then
                        if player.betState == consts.SVR_BET_STATE.WAITTING_DROP then
                        else
                            seat:setHandCardNum(2)
                        end
                    else
                        seat:setHandCardNum(3)
                    end
                    if player.handCards and #player.handCards > 1 and player.betState ~= consts.SVR_BET_STATE.WAITTING_DROP then
                        seat:setHandCardValue(player.handCards)
                        seat:showHandCardFrontAll()
                        seat:showAllHandCardsElement()
                        seat:showHandCards()
                        seat:showCardTypeIf()
                    else
                        seat:hideHandCards()
                        seat:hideFoldCards()
                    end
                else
                    if self.model:roomType() == consts.ROOM_TYPE.PRO and gameStatus == consts.SVR_GAME_STATUS.BET_ROUND_1 then
                        self.dealCardManager:showDealedCard(player, 2)
                    elseif self.model:roomType() == consts.ROOM_TYPE.TYPE_4K and gameStatus == consts.SVR_GAME_STATUS.WAIT_FOLD_CARD then
                        if player.betState == consts.SVR_BET_STATE.WAITTING_DROP then
                            self.dealCardManager:showDealedCard(player, 4)
                        else
                            self.dealCardManager:showDealedCard(player, 2)
                        end
                    elseif self.model:roomType() == consts.ROOM_TYPE.TYPE_5K and gameStatus == consts.SVR_GAME_STATUS.WAIT_FOLD_CARD then
                        if player.betState == consts.SVR_BET_STATE.WAITTING_DROP then
                            self.dealCardManager:showDealedCard(player, 5)
                        else
                            self.dealCardManager:showDealedCard(player, 3)
                        end
                    elseif self.model:roomType() == consts.ROOM_TYPE.TYPE_4K and gameStatus == consts.SVR_GAME_STATUS.BET_ROUND_1 then
                        self.dealCardManager:showDealedCard(player, 2)
                    elseif gameStatus == consts.SVR_GAME_STATUS.BET_ROUND_1 or gameStatus == consts.SVR_GAME_STATUS.BET_ROUND_2 then
                        self.dealCardManager:showDealedCard(player, 3)
                    end
                end
            end

            seat:updateState()
        else
            seat:removeFromParent()
        end
    end
end

function SeatManager:rotateSeatToOrdinal()
    if self.dealCardRotateShowDelayId_ then
        self.schedulerPool:clear(self.dealCardRotateShowDelayId_)
        self.dealCardRotateShowDelayId_ = nil
    end

    local seat = self.seats_[2]
    local positionId = seat:getPositionId()
    if positionId ~= 3 then
        local step = positionId - 3
        self:rotateSeatByStep_(step, true)
    end
    if self.selfArrowDelayId_ then
        self.schedulerPool:clear(self.selfArrowDelayId_)
        self.selfArrowDelayId_ = nil
    end
end

function SeatManager:rotateSelfSeatToCenter(selfSeatId, animation)
    if self.dealCardRotateShowDelayId_ then
        self.schedulerPool:clear(self.dealCardRotateShowDelayId_)
        self.dealCardRotateShowDelayId_ = nil
    end

    local selfSeat = self.seats_[selfSeatId]
    local selfPositionId = selfSeat:getPositionId()
    if selfPositionId ~= 5 then
        local step = selfPositionId - 5
        self:rotateSeatByStep_(step, animation)
    end
    if animation then
        self.selfArrowDelayId_ = self.schedulerPool:delayCall(function() 
            self.selfArrowDelayId_ = nil
            local p = cc.p(SeatPosition[5].x, SeatPosition[5].y + 140)
            local pt = cc.p(p.x, p.y - 25)
            local arrow = display.newSprite("#room_self_seat_arrow.png")
            arrow:setPosition(p)
            arrow:addTo(self.scene.nodes.animNode)
            transition.execute(arrow, cc.Repeat:create(
                transition.sequence({
                    cc.MoveTo:create(0, p),
                    cc.MoveTo:create(0.5, pt),
                    cc.MoveTo:create(0.2, p),
                }), 4), 
                {onComplete=function() 
                    arrow:removeFromParent()
                end})
        end, 0.5)
    end
end

function SeatManager:rotateSeatByStep_(step, animation)
    if step > 4 then
        step = step - 9
    elseif step < -4 then
        step = step + 9
    end
    self.dealCardManager:reset()
    local setDealedCardDisplay = function()
        --显示手牌
        for i = 0, 8 do
            local player = self.model.playerList[i]
            if player and not player.isSelf and player.inGame then
                if self.model:roomType() == consts.ROOM_TYPE.PRO then
                    if self.model.gameInfo.gameStatus == consts.SVR_GAME_STATUS.BET_ROUND_1 then
                        self.dealCardManager:showDealedCard(player, 2)
                    elseif self.model.gameInfo.gameStatus == consts.SVR_GAME_STATUS.BET_ROUND_2 then
                        self.dealCardManager:showDealedCard(player, 3)
                    end
                elseif self.model:roomType() == consts.ROOM_TYPE.TYPE_4K then
                    if self.model.gameInfo.gameStatus == consts.SVR_GAME_STATUS.WAIT_FOLD_CARD then
                        local state = player.statemachine:getState()
                        if state == SeatStateMachine.STATE_DROP then
                            self.dealCardManager:showDealedCard(player, 4)
                        else
                            self.dealCardManager:showDealedCard(player, 2)
                        end
                    elseif self.model.gameInfo.gameStatus == consts.SVR_GAME_STATUS.BET_ROUND_1 then
                        self.dealCardManager:showDealedCard(player, 2)
                    elseif self.model.gameInfo.gameStatus == consts.SVR_GAME_STATUS.BET_ROUND_2 then
                        self.dealCardManager:showDealedCard(player, 3)
                    end
                elseif self.model:roomType() == consts.ROOM_TYPE.TYPE_5K then
                    if self.model.gameInfo.gameStatus == consts.SVR_GAME_STATUS.WAIT_FOLD_CARD then
                        local state = player.statemachine:getState()
                        if state == SeatStateMachine.STATE_DROP then
                            self.dealCardManager:showDealedCard(player, 5)
                        else
                            self.dealCardManager:showDealedCard(player, 3)
                        end
                    elseif self.model.gameInfo.gameStatus == consts.SVR_GAME_STATUS.BET_ROUND_1 then
                        self.dealCardManager:showDealedCard(player, 3)
                    end
                else
                    if self.model.gameInfo.gameStatus == consts.SVR_GAME_STATUS.BET_ROUND_1 then
                        self.dealCardManager:showDealedCard(player, 3)
                    end
                end
            end
        end
    end

    --转动座位
    local capacity = math.abs(step)
    for seatId = 0, 8 do
        local seat = self.seats_[seatId]
        local seatCurPos = seat:getPositionId()
        local len = 1
        if seat then
            local seatPa = {}
            seatPa[#seatPa + 1] = cc.p(seat:getPositionX(), seat:getPositionY())
            for i = 1, capacity do
                local idx
                if step > 0 then
                    --逆时针转
                    if seatCurPos - i >= 1 then
                        idx = seatCurPos - i
                    else
                        idx = seatCurPos - i + 9
                    end
                else
                    --顺时针转
                    if seatCurPos + i <= 9 then
                        idx = seatCurPos + i
                    else
                        idx = seatCurPos + i - 9
                    end
                end
                seatPa[#seatPa + 1] = SeatPosition[idx]
                if i == capacity then
                    seat:setPositionId(idx)
                    if not seat:getParent() or not animation then
                        seat:setPosition(SeatPosition[idx])
                    end
                end
            end
            if animation then
                if seat:getParent() then
                    seat:runAction(cc.CatmullRomTo:create(0.5, seatPa))
                end
            end
        end
    end

    if animation then
        --隐藏手牌
        self.dealCardRotateShowDelayId_ = self.schedulerPool:delayCall(function()
            self.dealCardRotateShowDelayId_ = nil
            setDealedCardDisplay()
        end, 0.6)
    else
        setDealedCardDisplay()
    end

    --移动dealer位置
    self.animManager:rotateDealer(step)

    --转动灯光
    local lampPositionId = self.lampManager:getPositionId()
    lampPositionId = lampPositionId - step
    if lampPositionId > 9 then
        lampPositionId = lampPositionId - 9
    elseif lampPositionId < 1 then
        lampPositionId = lampPositionId + 9
    end
    self.lampManager:turnTo(lampPositionId, true)

    -- 转动筹码
    self.chipManager:moveChipStack()
end

function SeatManager:updateAllSeatState()
    for i = 0, 8 do
        local seat = self.seats_[i]
        seat:setSeatData(self.model.playerList[i])
        seat:updateState()
    end
end

function SeatManager:updateSeatState(seatId)
    local seat = self.seats_[seatId]
    local seatData = self.model.playerList[seatId]
    seat:setSeatData(seatData)
    seat:updateState()
end

function SeatManager:playSitDownAnimation(seatId)
    local seat = self.seats_[seatId]
    if seat then
        seat:playSitDownAnimation()
    end
end

function SeatManager:fadeSeat(seatId)
    local seat = self.seats_[seatId]
    if seat then
        seat:fade()
    end
end

function SeatManager:playAllInAnimation(seatId, onCompleteCallback)
    local seat = self.seats_[seatId]
    if seat then
        seat:playAllInAnimation(onCompleteCallback)
    end
end

function SeatManager:playStandUpAnimation(seatId, onCompleteCallback)
    local seat = self.seats_[seatId]
    if seat then
        seat:playStandUpAnimation(onCompleteCallback)
    end
end

function SeatManager:updateHeadImage(seatId, imageUrl)
    local seat = self.seats_[seatId]
    if seat then
        if imageUrl then
            seat:updateHeadImage(imageUrl)
        end
    end
end

function SeatManager:updateGiftUrl(seatId, giftId)
    local seat = self.seats_[seatId]
    if seat and giftId then
        seat:updateGiftUrl(giftId)
    end
end

function SeatManager:playSeatWinAnimation(seatId, type_, label_)
    local seat = self.seats_[seatId]
    if seat then
        seat:playWinAnimation(type_, label_)
    end
end

function SeatManager:stopCounter()
    for i = 0, 8 do
        local counter = self.seats_[i]:getChildByTag(SEAT_PROGRESS_TIMER_TAG)
        if counter then
            counter:removeFromParent()
            if USE_COUNTER_POOL then
                self.counterPool_:recycle(counter)
            end
        end
    end
    if self.counterTimeoutId_ then
        self.schedulerPool:clear(self.counterTimeoutId_)
        self.counterTimeoutId_ = nil
    end
    if self.dealerTapTableTimeoutId_ then
        self.schedulerPool:clear(self.dealerTapTableTimeoutId_)
        self.dealerTapTableTimeoutId_ = nil
    end
    self.counterSeatId_ = nil
end

function SeatManager:stopCounterOnSeat(seatId)
    local counter = nil

    if self.seats_ and self.seats_[seatId] then
        --todo
        counter = self.seats_[seatId]:getChildByTag(SEAT_PROGRESS_TIMER_TAG)
    end
    
    if counter then
        counter:removeFromParent()
        if USE_COUNTER_POOL then
            self.counterPool_:recycle(counter)
        end

        if self.counterTimeoutId_ then
            self.schedulerPool:clear(self.counterTimeoutId_)
            self.counterTimeoutId_ = nil
        end
        if self.dealerTapTableTimeoutId_ then
            self.schedulerPool:clear(self.dealerTapTableTimeoutId_)
            self.dealerTapTableTimeoutId_ = nil
        end
        self.counterSeatId_ = nil
    end
end

function SeatManager:startCounter(seatId)
    self:stopCounter()
    local seat = self.seats_[seatId]
    local seatData = seat:getSeatData()
    if seat and seatData then
        self.counterSeatId_ = seatId
        if USE_COUNTER_POOL then
            self.counterPool_:retrive():addTo(seat, 1, SEAT_PROGRESS_TIMER_TAG)
        else
            self.seatTimerBetExpire_ = self.model.roomInfo.betExpire or self.seatTimerBetExpire_
            SeatProgressTimer.new(self.seatTimerBetExpire_):addTo(seat, 1, SEAT_PROGRESS_TIMER_TAG)
        end
        if seatData.isSelf then
            self.counterTimeoutId_ = self.schedulerPool:delayCall(function() 
                seat:shakeAllHandCards()
            end, self.model.roomInfo.betExpire * 0.75)
        end

        -- 荷官敲桌子
        self.dealerTapTableTimeoutId_ = self.schedulerPool:delayCall(function() 
            self.dealerManager:tapTable()
        end, self.model.roomInfo.betExpire * 0.5)
    end
end

function SeatManager:setLoading(isLoading)
    if isLoading then
        if not self.scene.juhua_ then
            self.scene.juhua_ = nk.ui.Juhua.new()
                :pos(display.cx, display.cy)
                :addTo(self.scene)
        end
    else
        if self.scene.juhua_ then
            self.scene.juhua_:removeFromParent()
            self.scene.juhua_ = nil
        end
    end
end

function SeatManager:onSeatClicked_(evt)
    local seat = self.seats_[evt.seatId]
    if seat:isEmpty() then
        local canSeat = nk.userData.money < self.model.roomInfo.minBuyIn
        local isgcoin_ = 0
        local isNewVersion_ = 1--1: 普通、专业、4k、5k 0:黄金币场
        if self.model:isCoinRoom() then
            canSeat = nk.userData.gcoins < self.model.roomInfo.minBuyIn
            isgcoin_ = 1
            isNewVersion_ = 0
        end
        if canSeat then
            local thisTime = bm.getTime()
            if not SeatManager.buyBtnLastClickTime or math.abs(thisTime - SeatManager.buyBtnLastClickTime) > 2 then
                SeatManager.buyBtnLastClickTime = thisTime
                self:setLoading(true)
                bm.HttpService.POST(
                    {
                        mod = "table",
                        act = "siteInRoom",
                        sb = self.model.roomInfo.blind,
                        match = 0,
                        isgcoin = isgcoin_,
                        isNewVersion = isNewVersion_
                    },
                    function (data)
                        local retData = json.decode(data)
                            self:setLoading(false)
                            if retData and retData.showBox == 1 and retData.box >= 3 then
                                local minBuy = bm.formatBigNumber(self.model.roomInfo.blind * 5) or nk.userData.limitMin
                                retData.minBuy = minBuy
                                if retData.box == 3 then
                                    nk.ui.Dialog.new({
                                        messageText = bm.LangUtil.getText("COMMON", "NOT_ENOUGH_MONEY_TO_PLAY_NOW_MSG", minBuy),
                                        hasCloseButton = false,
                                        callback = function (type)
                                            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                                                FirstPayPopup.new(retData):show()
                                            end
                                        end
                                    }):show()
                                elseif retData.box > 3 then
                                    if retData.box < 10 then
                                        GuidePayPopup.new(4, nil, retData):show()
                                    elseif retData.box == 11 then
                                        GuidePayPopup.new(104, nil, retData):show()
                                    end
                                end
                            else
                                if isgcoin_ > 0 then
                                    local minBuy = bm.formatBigNumber(self.model.roomInfo.blind * 10)
                                    nk.ui.Dialog.new({
                                        messageText = bm.LangUtil.getText("COINROOM", "NOT_ENOUGH_MONEY_TO_PLAY_NOW_MSG", minBuy),
                                        hasCloseButton = false,
                                        callback = function (type)
                                            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                                                bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, 5)
                                                self.scene:doBackToHall()
                                            end
                                        end
                                    }):show()
                                elseif nk.userData.money < nk.userData.limitMin then
                                        nk.ui.Dialog.new({
                                            messageText = bm.LangUtil.getText("COMMON", "NOT_ENOUGH_MONEY_TO_PLAY_NOW_MSG", nk.userData.limitMin), 
                                            hasCloseButton = false,
                                            callback = function (type)
                                                if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                                                    StorePopup.new():showPanel()
                                                end
                                            end
                                        }):show()
                                else
                                    nk.ui.Dialog.new({
                                        hasCloseButton = false,
                                        messageText = bm.LangUtil.getText("ROOM", "SIT_DOWN_NOT_ENOUGH_MONEY"), 
                                        firstBtnText = bm.LangUtil.getText("ROOM", "AUTO_CHANGE_ROOM"),
                                        secondBtnText = bm.LangUtil.getText("ROOM", "CHARGE_CHIPS"), 
                                        callback = function (type)
                                            if type == nk.ui.Dialog.FIRST_BTN_CLICK then
                                                self.scene:playNowChangeRoom()
                                            elseif type == nk.ui.Dialog.SECOND_BTN_CLICK then
                                                StorePopup.new():showPanel()
                                            end
                                        end
                                    }):show()
                                end
                            end
                    end,
                    function ()
                        self:setLoading(false)
                    end
                )
            end
        else
            BuyInPopup.new({
                    minBuyIn = self.model.roomInfo.minBuyIn,
                    maxBuyIn = self.model.roomInfo.maxBuyIn,
                    isAutoBuyin = nk.userDefault:getBoolForKey(nk.cookieKeys.AUTO_BUY_IN, true),
                    isCoinRoom = self.model:isCoinRoom(),
                    blind = self.model.roomInfo.blind,
                    callback = function(buyinChips, isAutoBuyin1)
                        self:onBuyin_(evt.seatId, buyinChips, isAutoBuyin1)
                    end
                }):showPanel()
        end
    elseif seat:getSeatData().isSelf then
        local tableAllUid, toUidArr = self.model:getTableAllUid()
        local tableNum = self.model:getNumInSeat()
        local tableMessage = {tableAllUid = tableAllUid,toUidArr = toUidArr,tableNum = tableNum}
        if self.isUserInfoClick_ then
            return
        end
        self.isUserInfoClick_ = true
        nk.schedulerPool:delayCall(function()
            self.isUserInfoClick_ = false
        end, 0.5)
        UserInfoPopup.new(self.ctx):show(true,tableMessage)
    else
        if self.isUserInfoOtherClick_ then
            return
        end
        self.isUserInfoOtherClick_ = true
        nk.schedulerPool:delayCall(function()
            self.isUserInfoOtherClick_ = false
        end, 0.5)
        UserInfoOtherDialog.new(self.ctx):show(seat:getSeatData()) 
    end
end

function SeatManager:onBuyin_(seatId, buyinChips, isAutoBuyin)
    nk.socket.RoomSocket:sendSitDown(seatId, buyinChips)
    if isAutoBuyin then
        nk.socket.RoomSocket:sendAutoBuyin()
    end
end

local function isHandcard3_(handcards)
    return handcards and #handcards == 3 and handcards[1] and handcards[2] and handcards[3] and handcards[1] > 0 and handcards[2] > 0 and handcards[3] > 0
end

local function isHandcard2_(handcards)
    return handcards and handcards[1] and handcards[2] and handcards[1] > 0 and handcards[2] > 0
end

function SeatManager:showHandCard()
    for i = 0, 8 do
        local seat = self.seats_[i]
        local seatData = seat:getSeatData()
        if seatData and seatData.inGameBeforeGameOver then
            local handCards = seatData.handCards
            local is3 = isHandcard3_(handCards)
            local is2 = isHandcard2_(handCards)
            if is3 or is2 then
                if not seatData.isSelf then
                    self.dealCardManager:moveDealedCardToSeat(seatData, function()
                        print("seat " .. seat.seatId_ .. " showHandCard")
                        if seat:getSeatData() == seatData then
                            if is3 then
                                seat:setHandCardNum(3)
                            elseif is2 then
                                seat:setHandCardNum(2)
                            end
                            seat:setHandCardValue(handCards)
                            seat:showHandCardBackAll()
                            seat:showAllHandCardsElement()
                            seat:showHandCards()
                            seat:flipAllHandCards()
                            self.schedulerPool:delayCall(function() 
                                if seat:getSeatData() == seatData then
                                    seat:showCardTypeIf()
                                end
                            end, 0.8)
                        elseif seat:getSeatData() == nil then
                            print("seat " .. seat.seatId_ .. " player changed from " .. seatData.uid .. " to nil")
                        else
                            print("seat " .. seat.seatId_ .. " player changed from " .. seatData.uid .. " to " .. seat:getSeatData().uid)
                        end
                    end)
                else
                    if is3 then
                        seat:setHandCardNum(3)
                    elseif is2 then
                        seat:setHandCardNum(2)
                    end
                    seat:setHandCardValue(handCards)
                    seat:showAllHandCardsElement()
                    seat:showHandCardFrontAll()
                    seat:showHandCards()
                    seat:showCardTypeIf()
                end
            end
        end
    end
end

function SeatManager:showHandCardByOther(pack)
    local seatId = pack.seatId
    local seat = self.seats_[seatId]
    local seatData = seat:getSeatData()
    if seatData and seatData.inGameBeforeGameOver then
        if not seatData.isSelf then
            self.dealCardManager:moveDealedCardToSeat(seatData, function()
                print("seat " .. seat.seatId_ .. " showHandCard")
                if seat:getSeatData() == seatData then
                    seatData.handCards = nil
                    seatData.handCards = {}
                    if pack.cardCount == 2 then
                        local card1 = pack.handCard1
                        local card2 = pack.handCard2
                        print("seat " .. seat.seatId_ .. " showHandCard", card1, card2)
                        table.insert(seatData.handCards, card1)
                        table.insert(seatData.handCards, card2)
                        table.insert(seatData.handCards, 0)
                        seat:setHandCardNum(2)
                    else
                        local card1 = pack.handCard1
                        local card2 = pack.handCard2
                        local card3 = pack.handCard3
                        print("seat " .. seat.seatId_ .. " showHandCard", card1, card2, card3)
                        table.insert(seatData.handCards, card1)
                        table.insert(seatData.handCards, card2)
                        table.insert(seatData.handCards, card3)
                        local cardType = pack.cardType
                        local pointCount = pack.pointcount
                        seatData.cardType = self.model:getNewCardType(cardType, pointCount)
                        seat:setHandCardNum(3)
                    end
                    seat:setHandCardValue(seatData.handCards)
                    seat:showHandCardBackAll()
                    seat:showAllHandCardsElement()
                    seat:showHandCards()
                    seat:flipAllHandCards()
                    self.schedulerPool:delayCall(function() 
                        if seat:getSeatData() == seatData then
                            seat:showCardTypeIf()
                        end
                    end, 0.8)
                elseif seat:getSeatData() == nil then
                    print("seat " .. seat.seatId_ .. " player changed from " .. seatData.uid .. " to nil")
                else
                    print("seat " .. seat.seatId_ .. " player changed from " .. seatData.uid .. " to " .. seat:getSeatData().uid)
                end
            end)
        end
    end
end

function SeatManager:prepareDealCards()
    local selfSeatId = self.model:selfSeatId()
    for i = 0, 8 do
        local seat = self.seats_[i]
        seat:setSeatData(self.model.playerList[i])
        if self.model:roomType() == consts.ROOM_TYPE.PRO then
            seat:setHandCardNum(2)
        else
            seat:setHandCardNum(3)
        end
        if i == selfSeatId then
            seat:setHandCardValue(seat:getSeatData().handCards)
            seat:showHandCardBackAll()
            seat:hideAllHandCardsElement()
            seat:showHandCards()
        else
            seat:showHandCardBackAll()
            seat:hideHandCards()
            seat:hideFoldCards()
        end
    end
end

function SeatManager:onOffLoadCallback_()
    local selfSeatId = self.model:selfSeatId()
    if selfSeatId ~= -1 then
        local seat = self.seats_[selfSeatId]
        if seat then
            seat:updateVipIcon()
        end
    end
end

function SeatManager:onAddExp(evt)
    local selfSeatId = self.model:selfSeatId()
    if selfSeatId ~= -1 and evt and evt.exp and evt.exp ~= 0 then
        local seat = self.seats_[selfSeatId]
        if seat then
            seat:playExpChangeAnimation(evt.exp)
        end
    end
end
-- 筹码、黄金币变化
function SeatManager:onAddMoneyAnimation(evt)
    -- itype, value
    local evtData = evt.data
    if not evtData or not evtData.itype or not evtData.num or evtData.num == 0 then
        return
    end
    -- 
    local seatId = evtData.seatId or self.model:selfSeatId()
    if seatId ~= -1 then
        local seat = self.seats_[seatId]
        if seat then
            local rect = seat:getParent():convertToWorldSpace(cc.p(seat:getPosition()))
            local fontSize = 20
            if evtData.num > 0 then
                fontSize = 32
            end
            app:tip(evtData.itype, evtData.num, rect.x, rect.y-20, 999, 0, fontSize, 0)
        end
    end
end
--播放座位加经验的动画，只播放自己的
function SeatManager:playExpChangeAnimation()
    if self.model:isSelfInSeat() then
        local selfSeatId = self.model:selfSeatId()
        local playerSelf = self.model:selfSeatData()
        if playerSelf and playerSelf.inGameBeforeGameOver then
            if playerSelf.changeExp > 0 then
                self:expChange(playerSelf.changeExp)
                local seat = self.seats_[selfSeatId]
                if seat then
                    seat:playExpChangeAnimation(playerSelf.changeExp)
                end
            end
        end
    end
end

-- 检查是否送荷官小费中奖
function SeatManager:checkRewardWhenSendChipToDealer(fromSeatId, toSeatId, chips)
    local open = nk.OnOff:check("lkf")
    if self.model:selfSeatId() == fromSeatId and open then
        local param = {mod = "Lkf", act = "reward", sb = self.model.roomInfo.blind}
        bm.HttpService.POST(
                    param,
                    function (data)
                        local jsonData = json.decode(data)
                        if jsonData and jsonData.code then
                            if jsonData.code == -2 and jsonData.msg then
                                nk.TopTipManager:showTopTip(jsonData.msg)
                            elseif jsonData.code == 0 and jsonData.bagtype and jsonData.msg then
                                self.schedulerPool:delayCall(function()
                                    -- 刷新onoff
                                    app:loadOnOffData()
                                    nk.MatchTickManager:synchPhpTickList()
                                    self.animManager:playRewardAnimationWhenSendChipToDealer(toSeatId, fromSeatId, jsonData)
                                end, 2.6)
                                
                            end
                        end
                    end,
                    function ()
                    end
                )
    end
end

function SeatManager:expChange(changeExp)
    nk.userData.experience = nk.userData.experience + changeExp
    local level = nk.Level:getLevelByExp(nk.userData.experience) or nk.userData.level
    if tonumber(level) > tonumber(nk.userData.level) then
        self:levelUp_(level)
    else
        nk.userData.level = level
    end
    nk.userData.title = nk.Level:getTitleByExp(nk.userData.experience) or nk.userData.title
end

function SeatManager:levelUp_(level)
    nk.userData.level = level
    nk.userData.title = nk.Level:getTitleByLevel(level)
    if level ~= 1 and level ~= 2 then
        nk.userData.nextRwdLevel = level
        display.addSpriteFrames("upgrade_texture.plist", "upgrade_texture.png", function()
            UpgradePopup.new(nk.userData.nextRwdLevel):show()
        end)
    end
end

function SeatManager:reset()
    for i = 0, 8 do
        local seat = self.seats_[i]
        seat:reset()
    end
    self:stopCounter()
end

return SeatManager
