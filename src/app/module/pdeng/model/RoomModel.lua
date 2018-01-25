--
-- Author: tony
-- Date: 2014-07-08 14:23:34
--

local SeatStateMachine = import(".SeatStateMachine")
local HandPoker = import(".HandPoker")
local logger = bm.Logger.new("RoomModel")
local RoomModel = {}

function RoomModel.new()
    local instance = {}
    local datapool = {}
    local function getData(table, key)
        return RoomModel[key] or datapool[key]
    end
    local function setData(table, key, value)
        datapool[key] = value
    end
    local function clearData(self)
        local newdatapool = {}
        for k, v in pairs(datapool) do
            if type(v) == "function" then
                newdatapool[k] = v
            end
        end
        datapool = newdatapool
        return self
    end
    instance.clearData = clearData
    local mtable = {__index = getData, __newindex = setData}
    setmetatable(instance, mtable)
    instance:ctor()
    return instance
end

function RoomModel:ctor()
    self.isSelfInGame_ = false  
    self.selfSeatId_ = -1    
    self.roomType_ = 0
    self.isPDengRoom_ = true
end

-- 是否是自己
function RoomModel:isSelf(uid)
    return nk.userData.uid == uid
end

-- 是否正在游戏（游戏开始至游戏刷新，弃牌置为false）
function RoomModel:isSelfInGame()
    return self.isSelfInGame_
end

-- 本人是否在座
function RoomModel:isSelfInSeat()
    return self.selfSeatId_ >= 0 and self.selfSeatId_ <= 9
end

-- 本人是否为庄家
function RoomModel:isSelfDealer()
    return self.selfSeatId_ == self.gameInfo.dealerSeatId
end


-- 获取自己的座位id
function RoomModel:selfSeatId()
    return self.selfSeatId_
end

-- 获取自己
function RoomModel:selfSeatData()
    return self.playerList[self.selfSeatId_]
end

-- 获取庄家
function RoomModel:dealerSeatData()
    return self.playerList[self.gameInfo.dealerSeatId]
end

function RoomModel:isCoinRoom()
    return false
end

-- 获取当前房间类型
function RoomModel:roomType()
    return self.roomType_
end
-- 获取庄家需要补币的额度
function RoomModel:getDealerAddCoinNum()
    return self.dealerAddCoinNum_ or 0
end
--获取首先发牌的玩家座位号
function RoomModel:getFirstDealCardSeatId()
    return self.firstDealCardSeatId_ or 0
end

--获取抢庄最小门槛值
function RoomModel:getGrabDealerNeedCoin()
    return self.grabNeedCoin_ or 0
end
--获取房间内金币变化值
--(玩家抢庄、补币，需要一个自己的最大金币，nk.userdata["aUser.money"]
--在玩家退出房间才会刷新，所以此值不能作为自己的最大抢庄值和补币值
--需要加上在牌局中赢的钱和减去输的钱)
function RoomModel:getExchangeMoney()
    return self.exchangeMoney_ or 0
end
function RoomModel:getCurBetMoney()
    return self.betMoeny_ or 0
end
-- 获取当前在桌人数
function RoomModel:getNumInSeat()
    local num = 0
    for i = 0, 9 do
        if self.playerList[i] then
            num = num + 1
        end
    end

    return num
end
-- 获取牌桌所有用户的UID 
function RoomModel:getTableAllUid()
    local tableAllUid = ""
    local userUid = ""
    local toUidArr = {}
    for seatId = 0, 9 do
        local player = self.playerList[seatId]
        if player and player.uid then
            userUid = userUid..","..player.uid
            table.insert(toUidArr, player.uid)
        end
        tableAllUid = string.sub(userUid,2)
    end
    return tableAllUid,toUidArr
end

function RoomModel:getSeatIdByUid(uid)
    for seatId = 0, 9 do
        local player = self.playerList[seatId]
        if player and player.uid == uid then
            return seatId
        end
    end
    return -1
end


-- 获取本轮参与玩家人数
function RoomModel:getNumInRound()
    local num = 0
    for i = 0, 9 do
        if self.playerList[i] and self.playerList[i].isPlay == 1 then
            num = num + 1
        end
    end
    return num
end

function RoomModel:getNewCardType(cardType, pointCount)
    return CardType.new(cardType, pointCount)
end


function RoomModel:initWithLoginSuccessPack(pack)
    self.clearData()
    self.isSelfInGame_ = false
    self.selfSeatId_ = -1
    self.roomType_ = 0
    self.isPDengRoom_ = true

    --座位配置
    local seatsInfo = {}
    self.seatsInfo = seatsInfo
    seatsInfo.seatNum = pack.maxSeatCnt
    for i=1, pack.maxSeatCnt do
        local seatId = i - 1
        local seatInfo = {}
        seatInfo.seatId = seatId
        seatsInfo[seatId] = seatInfo
    end

    --房间信息
    local roomInfo = {}
    self.roomInfo = roomInfo
    roomInfo.minBuyIn = pack.minAnte
    roomInfo.maxBuyIn = pack.maxAnte
    roomInfo.roomType = pack.roomType or 101
    roomInfo.blind = pack.baseAnte
    roomInfo.playerNum = pack.maxSeatCnt
    roomInfo.tid     = pack.tableId
    roomInfo.enterLimit = pack.minAnte

    --房间level, 房间类型
    self.roomType_ = roomInfo.roomType


    --游戏信息
    local gameInfo = {}
    self.gameInfo = gameInfo
    
    --桌子当前状态 0牌局已结束 1下注中 2等待用户获取第3张牌
    gameInfo.gameStatus = pack.tableStatus
    if gameInfo.gameStatus ~= 2 then
        self.firstDealCardSeatId_ = pack.curDealSeatId
    end

    if gameInfo.gameStatus == consts.PDENG_GAME_STATUS.GET_POKER then
        gameInfo.curDealSeatId = pack.curDealSeatId
    else
        gameInfo.curDealSeatId = -1
    end
    gameInfo.dealerSeatId = 9--pack.dealerSeatId
    gameInfo.userAnteTime = pack.userAnteTime
    gameInfo.extraCardTime = pack.extraCardTime
    gameInfo.totalAnte = pack.totalAnte

    gameInfo.grabDoor = pack.banker_threshold --上庄门槛
    self.grabNeedCoin_ = gameInfo.grabDoor

    gameInfo.candidates = pack.candidates
    for i, condidate in ipairs(gameInfo.candidates) do
        if condidate then
            self:updateUserInfo(condidate)
        end
    end

    --在玩玩家信息
    local playerList = {}
    self.playerList = playerList
    for i, player in ipairs(pack.playerList) do
        
        self:updateUserInfo(player)
        if not player.userInfo then
            player.userInfo = nk.getUserInfo(true) 
            player.giftId = player.userInfo.giftId
            player.nick = player.userInfo.name
            player.userInfo.nick = player.userInfo.name
            player.img = player.userInfo.mavatar
            player.userInfo.img = player.userInfo.mavatar
        end

        playerList[player.seatId] = player
        
        player.isSelf = self:isSelf(player.uid)        
        if player.isSelf then
            self.selfSeatId_ = player.seatId
            self.isSelfInGame_ = (player.isPlay == 1)               
        end        
        if player.isOutCard == 1 then
            if player.card1 ~= 0 then
                player.cards = {player.card1, player.card2}
                if player.card3 ~= 0 then
                    player.cards[3] = player.card3
                end
                player.card1 = nil
                player.card2 = nil
                player.card3 = nil
            end
            if player.cards then
                local HandPoker = HandPoker.new()
                HandPoker:setCards(player.cards)
                player.HandPoker = HandPoker
                player.cardsCount = #player.cards
            else
                player.cardsCount = 0 
            end
        end
        player.isDealer =  (player.seatId == self.gameInfo.dealerSeatId)
        player.statemachine = SeatStateMachine.new(player, player.seatId == gameInfo.curDealSeatId, gameInfo.gameStatus)
    end   
end

function RoomModel:processGameStart(pack)
    -- 设置gameInfo
    self.gameInfo.gameStatus = consts.PDENG_GAME_STATUS.BET_ROUND
    self.gameInfo.dealerSeatId = 9--pack.dealerSeatId
    self.firstDealCardSeatId_ = pack.firstSeatId
    for i = 0, 9 do
        local player = self.playerList[i]
        if player then
            player.isPlay = 1
            player.isDealer =  ( i ==  self.gameInfo.dealerSeatId )        
            player.statemachine:doEvent(SeatStateMachine.GAME_START)
            if player.isDealer then                
                player.statemachine:doEvent(SeatStateMachine.SET_DEALER)
            end
            player.isOutCard = 0
            player.betChips = 0
            player.cards = nil
            player.cardsCount = 0
            player.HandPoker = nil
            player.trunMoney = 0
            player.getExp = 0
            player.isPlayBeforeGameOver = 0
            if player.isSelf then
                self.isSelfInGame_ = true  
            end
        end
    end

    for _,row in ipairs(pack.seatChipsList) do
        local player = self.playerList[row.seatId]
        player.seatChips = row.seatChips
    end    
end

function RoomModel:isChangeDealer()
    if self.gameInfo == nil or self.gameInfo.dealerSeatId == nil then
        return true
    end
    local oldDealer = self.gameInfo.dealerSeatId
    local maxMoney = 0
    local dealerSeatId = 0
    for i=0,9 do
        local player = self.playerList[i]
        if player then
            if player.seatChips > maxMoney then
                dealerSeatId = player.seatId
                maxMoney = player.seatChips
            end
        end
    end    
    return oldDealer ~= dealerSeatId
end

function RoomModel:processBetSuccess(pack)
    local player = self.playerList[pack.seatId] 
    player.currBetChips = pack.currBetChips 
    player.betChips = player.betChips + pack.currBetChips -- 总下注
    player.seatChips = player.seatChips - pack.currBetChips
    if player.seatChips < 0 then
        printError("seatChips is "..player.seatChips)
    end
    if player.isSelf then
        self.betMoeny_ = player.betChips
    end
    return pack.seatId
end

function RoomModel:processPot(pack)
    self.gameInfo.totalAnte = pack.totalAnte 
    for i=0, 9 do
        local player = self.playerList[i]
        if player and player.statemachine:getState() == SeatStateMachine.STATE_BETTING then
            player.statemachine:doEvent(SeatStateMachine.BET_END) 
        end
    end 
end

--发牌
function RoomModel:processDeal(pack)
    local player = self:selfSeatData()
    player.cards = pack.cards
    player.cardsCount = #pack.cards
    local HandPoker = HandPoker.new()
    HandPoker:setCards(player.cards)
    player.HandPoker = HandPoker
    player.isOutCard = 0
end

--亮牌
function RoomModel:processShowHand(pack)
    local player = self.playerList[pack.seatId] 
    player.cards = pack.cards
    player.isOutCard = 1
    player.cardsCount = #pack.cards
    local HandPoker = HandPoker.new()
    HandPoker:setCards(player.cards)
    player.HandPoker = HandPoker
    player.statemachine:doEvent(SeatStateMachine.SHOW_POKER)
end

function RoomModel:processTurnToGetPoker(pack)
    self.gameInfo.gameStatus = consts.PDENG_GAME_STATUS.GET_POKER
    local player = self.playerList[pack.seatId] 
    if player then
        player.statemachine:doEvent(SeatStateMachine.TURN_TO)
    end
    return pack.seatId
end

function RoomModel:processGetPoker(pack)
    local player = self.playerList[pack.seatId] 
    player.statemachine:doEvent(SeatStateMachine.GET_POKER)
    if pack.type == 1 then
        player.cardsCount = 3
    else
        player.cardsCount = 2
    end
    return pack.seatId
end

function RoomModel:processGetPokerBySelf(pack)
    local player = self:selfSeatData()     
    player.cardsCount = 3
    player.HandPoker:addCard(pack.card)
    player.cards[3] = pack.card
    player.isOutCard = 0
end

function RoomModel:processSitDown(pack)
    local player = pack
    local prePlayer = self.playerList[player.seatId]
    local isAutoBuyin = false
    if prePlayer then
        if prePlayer.uid == player.uid then
            isAutoBuyin = true
        end
    end

    self:updateUserInfo(player)
    if not player.userInfo then
            player.userInfo = nk.getUserInfo(true) 
            player.giftId = player.userInfo.giftId
            player.nick = player.userInfo.name
            player.userInfo.nick = player.userInfo.name
            player.img = player.userInfo.mavatar
            player.userInfo.img = player.userInfo.mavatar
    end

    player.isPlay = 0
    player.isDealer = (player.seatId == self.gameInfo.dealerSeatId)   
    player.statemachine = SeatStateMachine.new(player, false, self.gameInfo.gameStatus)
    self.playerList[player.seatId] = player
    player.isSelf = self:isSelf(player.uid)

   -- dump(self.playerList,"玩家列表")
    -- 判断是否是自己
    if player.isSelf then
        self.selfSeatId_ = player.seatId
        player.userInfo.img = nk.userData.s_picture
        player.userInfo.giftId = nk.userData.user_gift
        bm.DataProxy:setData(nk.dataKeys.SIT_OR_STAND, self:isSelfInSeat())
        --更新互动道具数量
        bm.HttpService.POST({mod="user", act="getUserFun"}, function(ret)
            local num = tonumber(ret)
            if num then
                nk.userData.hddjNum = num
            end
        end)
    end
    return player.seatId, isAutoBuyin
end

function RoomModel:processStandUp(pack,isOther)
    local player = self.playerList[pack.seatId]

    if not isOther then              
        self.isSelfInGame_ = false
        self.selfSeatId_ = -1
        bm.DataProxy:setData(nk.dataKeys.SIT_OR_STAND, self:isSelfInSeat())
        -- 设置金钱
        nk.userData.money = pack.chips
    end

    local isIgnore = false
    if isOther and ((not player) or (player and player.isSelf)) then
        isIgnore = true
        return pack.seatId,isIgnore
    end
    
    if isOther then
        local otherUid = pack.uid
        if otherUid ~= player.uid then
            isIgnore = true
            return pack.seatId,isIgnore
        end
    end

    if not isOther and not player.isSelf then
        isIgnore = true
        return pack.seatId,isIgnore
    end 

    player = nil
    self.playerList[pack.seatId] = nil
    
    --dump(self.playerList,"processStandUp===",10)
    return pack.seatId,isIgnore
end

function RoomModel:processGameOver(pack)
    self.gameInfo.gameStatus = consts.PDENG_GAME_STATUS.READY_TO_START
    --dump(pack.playerList,"pack.playerListfuckdandan")
    self.turn_money_ = 0
    for _,row in ipairs(pack.playerList) do
       local player = self.playerList[row.seatId]
       if player then
            player.seatChips = row.seatChips
            player.userInfo.money = player.seatChips

            -- dump(row.seatId,"seatID")
            -- dump(row.trunMoney,"筹码变化值")

            -- 如果闲家金币变化为0则退还筹码
            if row.trunMoney == 0 and not player.isDealer then
                player.trunMoney = player.betChips
            else                
                player.trunMoney = row.trunMoney
                if not player.isDealer then
                    player.trunMoney = row.trunMoney + row.betChips
                end
            end
            player.cards = row.cards
            local HandPoker = HandPoker.new()
            HandPoker:setCards(player.cards)
            player.HandPoker = HandPoker
            player.cardsCount = #player.cards
            player.isOutCard = 1
            player.getExp = row.getExp            

            if player.isSelf then
                
                self.exchangeMoney_ = self:getExchangeMoney() + row.trunMoney; 
                self.betMoeny_ = 0
                self.lastBets = row.betChips
                self.turn_money_ = row.trunMoney

                -- nk.TopTipManager:showTopTip(""..checkint(checkint(row.trunMoney)* .05))
                -- 上报游戏结束
                bm.EventCenter:dispatchEvent({name = nk.DailyTasksEventHandler.REPORT_GAME_OVER, 
                    data = {
                        roomInfo = self.roomInfo,
                        selfWin = (row.trunMoney > 0) and true or false,
                        inSeat = self:isSelfInSeat(),
                        seatId = player.seatId,
                        ctx = self.ctx
                    }})
            end
       end
    end

    -- local selfData = self:selfSeatData()
    -- if selfData and selfData.cards then

    --     local selfCardData = {}
    --     table.insert(selfCardData,clone(selfData.cards))
    --     table.insert(selfCardData,self.turn_money_)

    --     bm.DataProxy:setData(nk.dataKeys.PRE_GAME_CARDS, selfCardData)
    -- end

    local dealer = self:dealerSeatData()
    if dealer and checkint(dealer.trunMoney) < 0 then 
        dealer.betChips = - dealer.trunMoney
    end

    for i = 0, 9 do
        local player = self.playerList[i]
        if player then
            player.isPlayBeforeGameOver = player.isPlay
            player.isPlay = 0            
            player.statemachine:doEvent(SeatStateMachine.GAME_OVER)
        end
    end
    self.isSelfInGame_ = false
end

function RoomModel:processGrabDealer(pack)
    local candidate = {}
    candidate.uid = pack.uid
    candidate.money = pack.money
    candidate.userInfo = pack.userInfo
    self:updateUserInfo(candidate)
    self.gameInfo.candidates[#self.gameInfo.candidates + 1] = candidate
end

function RoomModel:processDropDealer(pack)
    if self.gameInfo and self.gameInfo.candidates and #self.gameInfo.candidates > 0 then
        for i = #self.gameInfo.candidates, 1, -1 do
            if pack.uid == self.gameInfo.candidates[i].uid then
                table.remove(self.gameInfo.candidates, i)
            end
        end
    end
end

function RoomModel:processSendChipSuccess(pack)
    local fromPlayer = self.playerList[pack.fromSeatId]
        local toPlayer = self.playerList[pack.toSeatId]
        local chips = pack.chips
        if fromPlayer then
            fromPlayer.seatChips = fromPlayer.seatChips - chips
        end
        if toPlayer then
            toPlayer.seatChips = toPlayer.seatChips + chips
        end
end

function RoomModel:processSendExpression(pack)
    local player = self.playerList[pack.seatId]
    local expressionId = pack.expressionId
    if player then
        if pack.minusChips > 0 and player.seatChips >= pack.minusChips then
            player.seatChips = player.seatChips - pack.minusChips
            return pack.seatId, expressionId, player.isSelf, pack.minusChips
        else
            return pack.seatId, expressionId, player.isSelf, 0
        end
    end
    return nil, nil, nil
end

function RoomModel:processRoomBroadcast(pack)
    local content = json.decode(pack.content)
    local mtype = content.type
    if mtype == 1 then
        local chatHistory = bm.DataProxy:getData(nk.dataKeys.ROOM_CHAT_HISTORY)
        if not chatHistory then
            chatHistory = {}
        end
        local msg = bm.LangUtil.getText("ROOM", "CHAT_FORMAT", content.name, content.msg)
        chatHistory[#chatHistory + 1] = {messageContent = msg, time = bm.getTime(), mtype = 2}
        bm.DataProxy:setData(nk.dataKeys.ROOM_CHAT_HISTORY, chatHistory)
        local seatId = -1
        for i = 0, 9 do
            local player = self.playerList[i]
            if player and player.uid == content.uid then
                seatId = i
                break
            end
        end
        return mtype, content, seatId, msg
    elseif mtype == 2 then
        --换头像
        local uid = pack.param
        local seatId = self:getSeatIdByUid(uid)
        local url = content.url
        logger:debugf("receive head image update packet-> %s, %s, %s", uid, seatId, url)
        if seatId ~= -1 then
            local player = self.playerList[seatId]
            logger:debugf("modify seat %s img -> %s", seatId, url)
            player.img = url
        end
        return mtype, content, seatId, uid, url
    elseif mtype == 3 then
        -- 赠送礼物
        local fromUid = pack.param
        local fromSeatId = self:getSeatIdByUid(fromUid)
        local giftId = content.giftId
        local toUidArr = content.toUidArr
        local toSeatIdArr = {}
        if toUidArr and #toUidArr > 0 then
            for _, toUid in ipairs(toUidArr) do
                local toSeatId = self:getSeatIdByUid(toUid)
                if toSeatId ~= -1 then
                    self.playerList[toSeatId].giftId = giftId
                    table.insert(toSeatIdArr, toSeatId)
                end
            end
        end
        return mtype, content, giftId, fromSeatId, toSeatIdArr, fromUid, toUidArr
    elseif mtype == 4 then
        -- 设置礼物
        local uidToSet = pack.param
        local giftId = content.giftId
        local seatIdToSet = self:getSeatIdByUid(uidToSet)
        if seatIdToSet ~= -1 then
            self.playerList[seatIdToSet].giftId = giftId
        end
        return mtype, content, seatIdToSet, giftId
    end
    return mtype, content, pack.param
end
function RoomModel:processSvrAddvanceDealer(pack)
    self.dealerAddCoinNum_ = pack.addCoin
    return self.dealerAddCoinNum_
end

--当前桌子上的总筹码（奖池+座位已下注筹码)
function RoomModel:totalChipsInTable()

    local total = 0
    -- local pots = self.gameInfo.pots
    -- if pots then
    --     for _,v in pairs(pots) do
    --         total = total + v.potChips
    --     end
    -- end
    -- for i = 0, 8 do
    --     local player = self.playerList[i]
    --     if player and player.betChips then
    --         total = total + tonumber(player.betChips)
    --     end
    -- end
    return total
end
function RoomModel:reset()  
    self.isSelfInGame_ = false
    self.betMoeny_ = 0
end

function RoomModel:updateUserInfo(player)
    -- 添加exUserInfo 信息
    if player.userInfo and player.userInfo ~= "" then
        local userInfo = json.decode(player.userInfo)
        if userInfo then
            for k,v in pairs(userInfo) do
                player[k] = v
            end
            player.userInfo = userInfo
        else
            player.userInfo = nil
        end
    end
end

return RoomModel