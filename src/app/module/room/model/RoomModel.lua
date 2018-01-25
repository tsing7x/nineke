--
-- Author: tony
-- Date: 2014-07-08 14:23:34
--

local SeatStateMachine = import(".SeatStateMachine")
local CardType = import(".CardType")
local logger = bm.Logger.new("RoomModel")
local PlayerbackModel     = import("app.module.playerback.PlayerbackModel")
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
    self.isInitialized = false

    self.isSelfInGame_ = false
    self.isSelfInRound_ = false
    self.isInMatch_ = false
    self.isSelfAllIn_ = false
    self.canShowHandcard_ = false
    self.canShowHandcardButton_ = false
    self.selfSeatId_ = -1
    self.selfTotalBet_ = 0
    self.roomType_ = 0
    self.roomField_ = 1 
end

-- 是否是自己
function RoomModel:isSelf(uid)
    return nk.userData.uid == uid
end

-- 是否在本轮游戏（游戏开始至游戏刷新）
function RoomModel:isSelfInRound()
    return self.isSelfInRound_
end

-- 是否正在游戏（游戏开始至游戏刷新，弃牌置为false）
function RoomModel:isSelfInGame()
    return self.isSelfInGame_
end

-- 本人是否在座
function RoomModel:isSelfInSeat()
    return self.selfSeatId_ >= 0 and self.selfSeatId_ <= 8
end

-- 本人是否all in
function RoomModel:isSelfAllIn()
    return self.isSelfAllIn_
end

--可以亮出手牌
function RoomModel:canShowHandcard()
    return self.canShowHandcard_
end

function RoomModel:canShowHandcardButton()
    return self.canShowHandcardButton_
end

-- 是否在比赛场
function RoomModel:isInMatch()
    return self.isInMatch_
end

function RoomModel:setInMatch(inMatch)
    self.isInMatch_ = inMatch
end

-- 获取自己的座位id
function RoomModel:selfSeatId()
    return self.selfSeatId_
end

function RoomModel:selfSeatData()
    return self.playerList[self.selfSeatId_]
end

-- 自己本轮下注总筹码
function RoomModel:selfTotalBet()
    return self.selfTotalBet_
end

-- 获取当前房间类型
function RoomModel:roomType()
    return self.roomType_
end

-- ｛1初级场 2中级场 3高级场 4现金币场 5黄金场｝
function RoomModel:roomField()
    return self.roomField_
end

-- 判断是否为黄金币场
function RoomModel:isCoinRoom()
    return self.roomField_ == 5
end

--判断是否为私人房，大于0为私人房
function RoomModel:isGroupRoom()
    return self.roomFlag_ > 0
end

-- 获取当前在桌人数
function RoomModel:getNumInSeat()
    local num = 0
    for i = 0, 8 do
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
    for seatId = 0, 8 do
        local player = self.playerList[seatId]
        if player and player.uid then
            userUid = userUid..","..player.uid
            table.insert(toUidArr, player.uid)
        end
        tableAllUid = string.sub(userUid,2)
    end
    return tableAllUid,toUidArr
end

-- 获取当前在玩人数
function RoomModel:getNumInGame()
    local num = 0
    for i = 0, 8 do
        if self.playerList[i] and self.playerList[i].inGame then
            num = num + 1
        end
    end

    return num
end

function RoomModel:getSeatIdByUid(uid)
    for seatId = 0, 8 do
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
    for i = 0, 8 do
        if self.playerList[i] and self.playerList[i].inRound then
            num = num + 1
        end
    end

    return num
end

function RoomModel:getNewCardType(cardType, pointCount)
    return CardType.new(cardType, pointCount)
end

function RoomModel:selfCallNeedChips()
    local seatData = self:selfSeatData()
    if seatData  then
        return seatData.betNeedChips
    end
    return 0
end

--当前桌子上的总筹码（奖池+座位已下注筹码)
function RoomModel:totalChipsInTable()

    local total = 0
    local pots = self.gameInfo.pots
    if pots and #pots > 0 then
        for i = 1, #pots do
            total = total + pots[i]
        end
    end
    for i = 0, 8 do
        local player = self.playerList[i]
        if player and player.betChips then
            total = total + tonumber(player.betChips)
        end
    end
    return total
end

function RoomModel:currentMaxBetChips()
    local max = 0
    for i = 0, 8 do
        local player = self.playerList[i]
        if player and player.inGame and player.betChips and player.betChips > max then
            max = player.betChips
        end
    end
    return max
end

function RoomModel:initWithLoginSuccessPack(pack,is4K)
    self.clearData()
    self.isInitialized = true
    self.isSelfInGame_ = false
    self.isSelfInRound_ = false
    self.isInMatch_ = false
    self.isSelfAllIn_ = false
    self.canShowHandcard_ = false
    self.canShowHandcardButton_ = false
    self.selfSeatId_ = -1
    self.selfTotalBet_ = 0
    self.roomType_ = 0
    self.is4K = is4K

    --座位配置
    local seatsInfo = {}
    self.seatsInfo = seatsInfo
    seatsInfo.seatNum = pack.seatNum
    for i=1, pack.seatNum do
        local seatId = i - 1
        local seatInfo = {}
        seatInfo.seatId = seatId
        seatsInfo[seatId] = seatInfo
    end
    --房间信息
    local roomInfo = {}
    self.roomInfo = roomInfo
    roomInfo.betExpire = pack.betExpire
    roomInfo.roomField = pack.roomField
    roomInfo.roomFlag = pack.roomFlag
    roomInfo.minBuyIn = pack.minBuyIn
    roomInfo.maxBuyIn = pack.maxBuyIn
    roomInfo.roomName = pack.roomName
    roomInfo.roomType = pack.roomType
    roomInfo.blind = pack.blind
    roomInfo.playerNum = pack.seatNum
    roomInfo.ip     = pack.ip
    roomInfo.port     = pack.port
    roomInfo.tid     = pack.tid

    -- 设置当前field  判断是否是现金币场 ｛1初级场 2中级场 3高级场 4现金币场 5黄金场｝
    self.roomField_ = roomInfo.roomField

    self.roomFlag_ = roomInfo.roomFlag

    -- 设置当前房间类型，判断是否是比赛场
    self.roomType_ = roomInfo.roomType
    if self.roomType_ == consts.ROOM_TYPE.TOURNAMENT or self.roomType_ == consts.ROOM_TYPE.KNOCKOUT or self.roomType_ == consts.ROOM_TYPE.PROMOTION then
        self.isInMatch_ = true
    end

    --游戏信息
    local gameInfo = {}
    self.gameInfo = gameInfo
    gameInfo.gameStatus = pack.gameStatus
    gameInfo.roundCount = pack.roundCount
    gameInfo.bettingSeatId = pack.bettingSeatId
    gameInfo.dealerSeatId = pack.dealerSeatId
    gameInfo.pots = pack.pots
    gameInfo.hasRaise = false
    if gameInfo.bettingSeatId ~= -1 then
        gameInfo.callChips = pack.callChips
        gameInfo.minRaiseChips = roomInfo.blind--pack.minRaiseChips
        gameInfo.maxRaiseChips = pack.maxRaiseChips
    else
        gameInfo.callChips = 0
        gameInfo.minRaiseChips = 0
        gameInfo.maxRaiseChips = 0
    end
    gameInfo.selfBuyInChips = pack.userChips
    if pack.handCardFlag == 1 then
        gameInfo.handCards = pack.handCards
        gameInfo.cardType = CardType.new(pack.cardType, pack.cardPoint)
        if is4K then
            gameInfo.dropCard = {pack.card4,pack.card5}
            gameInfo.handCards_4k = {pack.handCards[1],pack.handCards[2],pack.card4,pack.card5}
        end
    elseif pack.handCardFlag == 2 then
        gameInfo.handCards_4k = pack.selectCards
    end
    self.gameInfo.dealed3rdCard = false
    if self:roomType() == consts.ROOM_TYPE.PRO or self:roomType() == consts.ROOM_TYPE.TYPE_4K then
        if gameInfo.gameStatus == consts.SVR_GAME_STATUS.BET_ROUND_2 or gameInfo.gameStatus == consts.SVR_GAME_STATUS.READY_TO_START then
            self.gameInfo.dealed3rdCard = true
        end
    else
        if gameInfo.gameStatus == consts.SVR_GAME_STATUS.BET_ROUND_1 or gameInfo.gameStatus == consts.SVR_GAME_STATUS.READY_TO_START then
            self.gameInfo.dealed3rdCard = true
        end
    end

    --在玩玩家信息
    local playerList = {}
    self.playerList = playerList
    -- 需要考虑只有一个玩家在座但游戏尚未结束的情况
    if #pack.playerList == 1 then
        pack.playerList[1].betState = consts.SVR_BET_STATE.WAITTING_BET
    end
    for i, player in ipairs(pack.playerList) do
        -- 判断是否在玩
        if player.betState ~= consts.SVR_BET_STATE.WAITTING_START and player.betState ~= consts.SVR_BET_STATE.FOLD then
            player.inGame = true
            player.inRound = true
        else
            player.inGame = false
            player.inRound = false
        end

        self:updateUserInfo(player)
        
        playerList[player.seatId] = player
        player.statemachine = SeatStateMachine.new(player, player.seatId == gameInfo.bettingSeatId, gameInfo.gameStatus)
        player.isSelf = self:isSelf(player.uid)
        -- 判断是否是自己，获取自己的座位id，判断是否在游戏中
        if player.isSelf then
            self.selfSeatId_ = player.seatId
            if player.inGame then
                self.isSelfInGame_ = true
                self.isSelfInRound_ = true
                if player.betState == consts.SVR_BET_STATE.FOLD then
                    player.handCards = {0,0,0}
                    player.cardType = nil
                    player.handCards_4k = gameInfo.handCards_4k
                else
                    player.handCards = gameInfo.handCards
                    player.cardType = gameInfo.cardType
                end
            end
        end
    end
    -- if  false and self.selfSeatId_ and self.selfSeatId_ ~= -1 then
    --     local player = {}
    --     -- {name = "seatId"    , type = T.BYTE}   , --座位ID
    --     -- {name = "uid"       , type = T.UINT}   , --用户id
    --     -- {name = "chips"     , type = T.ULONG}  , --用户钱数
    --     -- {name = "exp"       , type = T.UINT}   , --用户经验
    --     -- {name = "vip"       , type = T.BYTE}   , --VIP标识
    --     -- {name = "nick"      , type = T.STRING} , --用户昵称
    --     -- {name = "gender"    , type = T.STRING} , --用户性别
    --     -- {name = "img"       , type = T.STRING} , --用户头像
    --     -- {name = "win"       , type = T.UINT}   , --用户赢局数
    --     -- {name = "lose"      , type = T.UINT}   , --用户输局数
    --     -- {name = "curPlace"  , type = T.STRING} , --用户所在地
    --     -- {name = "homeTown"  , type = T.STRING} , --用户家乡
    --     -- {name = "giftId"    , type = T.INT}    , --礼物ID
    --     -- {name = "seatChips" , type = T.ULONG}  , --座位的钱数
    --     -- {name = "betChips"  , type = T.ULONG}  , --座位的总下注数
    --     -- {name = "betState"  , type = T.BYTE}   , --下注类型(座位状态)

    --     player.seatId = pack.selfSeatId
    --     player.uid = nk.userData.uid
    --     player.chips = nk.userData.money
    --     player.exp = nk.userData.experience
    --     player.vip = nk.userData.vip
    --     player.nick = nk.userData.nick
    --     player.gender = nk.userData.sex
    --     -- player.img =  
    --     player.win = nk.userData.win
    --     player.lose = nk.userData.lose
    --     player.curPlace = ""
    --     player.homeTown = ""
    --     self.selfSeatId_ = pack.selfSeatId
    --     player.img = nk.userData.s_picture
    --     player.giftId = nk.userData.user_gift
    --     player.seatChips = 0
    --     player.betChips = 0
    --     player.betState = 0
    --     player.inGame = false
    --     player.inRound = false
    --     player.statemachine = SeatStateMachine.new(player, false)
    --     bm.DataProxy:setData(nk.dataKeys.SIT_OR_STAND, self:isSelfInSeat())
    --     --更新互动道具数量
    --     bm.HttpService.POST({mod="user", act="getUserFun"}, function(ret)
    --         local num = tonumber(ret)
    --         if num then
    --             nk.userData.hddjNum = num
    --         end
    --     end)
    --     playerList[pack.selfSeatId] = player
    -- end
    if self.isSelfInRound_ then
        for i, player in ipairs(pack.playerList) do
            if player.betChips > self:selfSeatData().betChips then
                gameInfo.hasRaise = true
            end
        end
    end
end

function RoomModel:processGameStart(pack)
    
    -- 设置gameInfo
    self.gameInfo.gameStatus = consts.SVR_GAME_STATUS.BET_ROUND_1
    self.gameInfo.roundCount = pack.roundCount
    self.gameInfo.dealerSeatId = pack.dealerSeatId
    self.gameInfo.bettingSeatId = -1
    self.gameInfo.pots = {}
    self.gameInfo.handCards = {pack.handCard1, pack.handCard2, pack.handCard3}
    self.gameInfo.cardType = CardType.new(pack.cardType, pack.cardPoint)
    self.gameInfo.selfBuyInChips = pack.userChips
    --是否有加注
    self.gameInfo.hasRaise = false
    --是否发了第三张牌
    if self:roomType() == consts.ROOM_TYPE.PRO and self.gameInfo.handCards[3] == 0 then
        self.gameInfo.dealed3rdCard = false
    else
        self.gameInfo.dealed3rdCard = true
    end


    -- 设置playerList
    for i, v in ipairs(pack.playerList) do
        local player = self.playerList[v.seatId]
        assert(player, "PLAYER NOT FOUND")
        assert(player.uid == v.uid, "PLAYER CHANGED " .. player.uid .. " to " .. v.uid)
        player.seatChips = v.seatChips
        player.betChips = 0
    end
    for i = 0, 8 do
        local player = self.playerList[i]
        if player then
            player.inGame = true
            player.inRound = true
            player.statemachine:doEvent(SeatStateMachine.GAME_START)

            if player.isSelf then
                self.isSelfInGame_ = true
                self.isSelfInRound_ = true
                player.handCards = self.gameInfo.handCards
                player.cardType = self.gameInfo.cardType
            else
                player.handCards = {0, 0, 0}
                player.cardType = nil
            end
        end
    end
end

function RoomModel:processGameStart4K(pack)
    -- 设置gameInfo
    self.gameInfo.gameStatus = consts.SVR_GAME_STATUS.WAIT_FOLD_CARD
    self.gameInfo.roundCount = pack.roundCount
    self.gameInfo.dealerSeatId = pack.dealerSeatId
    self.gameInfo.bettingSeatId = -1
    self.gameInfo.pots = {}
    self.gameInfo.handCards = {0, 0, 0}
    self.gameInfo.handCards_4k = pack.handCards
    self.gameInfo.cardType = CardType.new(pack.cardType, pack.cardPoint)
    self.gameInfo.selfBuyInChips = pack.userChips
    --是否有加注
    self.gameInfo.hasRaise = false
    --是否发了第三张牌
    if self:roomType() == consts.ROOM_TYPE.PRO and self.gameInfo.handCards[3] == 0 then
        self.gameInfo.dealed3rdCard = false
    else
        self.gameInfo.dealed3rdCard = true
    end

    for i, v in ipairs(pack.playerList) do
        local player = self.playerList[v.seatId]
        assert(player, "PLAYER NOT FOUND")
        assert(player.uid == v.uid, "PLAYER CHANGED " .. player.uid .. " to " .. v.uid)
        player.seatChips = v.seatChips
        player.betChips = 0
    end
    for i = 0, 8 do
        local player = self.playerList[i]
        if player then
            player.inGame = true
            player.inRound = true
            player.statemachine:doEvent(SeatStateMachine.GAME_START_4K)

            if player.isSelf then
                self.isSelfInGame_ = true
                self.isSelfInRound_ = true
                player.handCards = self.gameInfo.handCards
                player.cardType = self.gameInfo.cardType
                player.handCards_4k = self.gameInfo.handCards_4k
            else
                player.handCards = {0, 0, 0}
                player.cardType = nil
            end
        end
    end
end

function RoomModel:processBroFoldStart(pack)
    self.timeout_4k = pack.timeout
end

function RoomModel:processBroFoldCard(pack)
    local player = self.playerList[pack.seatId]
    local isSelf = self:isSelf(pack.uid)
    if pack.status == 1 then
        player.statemachine:doEvent(SeatStateMachine.DROP_CARD)
    elseif pack.status == 2 then
         player.inGame = false
        if player.isSelf then
            self.isSelfInGame_ = false
        end
        player.statemachine:doEvent(SeatStateMachine.FOLD)
        if isSelf then
            player.handCards = {0,0,0}
        end
    end
    return player,isSelf
end

function RoomModel:processUserFoldCard4K(pack)
    if pack.ret == 0 then
        self.gameInfo.handCards = pack.holdCards
        self.gameInfo.cardType = CardType.new(pack.cardType, pack.cardPoint)
        local player = self:selfSeatData()
        if player.isSelf then
            player.handCards = self.gameInfo.handCards
            player.cardType = self.gameInfo.cardType
        end
    else
        if pack.ret == 1 then
        elseif pack.ret == 2 then
        end
    end
end

function RoomModel:processBetSuccess(pack)
    local player = self.playerList[pack.seatId]
    assert(player, "PLAYER NOT EXISTS")
    player.betState = pack.betState
    player.betNeedChips = pack.betChips - player.betChips -- 当前实际下注
    player.betChips = pack.betChips -- 总下注
    player.seatChips = player.seatChips - player.betNeedChips

    local betState = player.betState
    -- 前注
    if betState == consts.SVR_BET_STATE.PRE_CALL then
        -- 下完前注自己没钱了，算自己all in
        if player.isSelf and player.betChips == 0 then
            self.isSelfAllIn_ = true
            player.statemachine:doEvent(SeatStateMachine.ALL_IN, player.betNeedChips)
        end
    -- 看牌
    elseif betState == consts.SVR_BET_STATE.CHECK then
        player.statemachine:doEvent(SeatStateMachine.CHECK)
    -- 弃牌
    elseif betState == consts.SVR_BET_STATE.FOLD then
        player.inGame = false

        -- 自己弃牌
        if player.isSelf then
            self.isSelfInGame_ = false
        end
        player.statemachine:doEvent(SeatStateMachine.FOLD)
    -- 跟注
    elseif betState == consts.SVR_BET_STATE.CALL then
        if player.isSelf then
            self.gameInfo.hasRaise = false
        end
        player.statemachine:doEvent(SeatStateMachine.CALL, player.betNeedChips)
    -- 加注
    elseif betState == consts.SVR_BET_STATE.RAISE then
        if player.isSelf then
            self.gameInfo.hasRaise = false
        else
            self.gameInfo.hasRaise = true
        end
        player.statemachine:doEvent(SeatStateMachine.RAISE, player.betNeedChips)
    -- all in
    elseif betState == consts.SVR_BET_STATE.ALL_IN then
        -- 自己all in，需播放加注的声音
        if player.isSelf then
            self.isSelfAllIn_ = true
            self.gameInfo.hasRaise = false
        else
            if self:selfSeatData() and player.betChips > self:selfSeatData().betChips then
                self.gameInfo.hasRaise = true
            end
        end
        player.statemachine:doEvent(SeatStateMachine.ALL_IN, player.betNeedChips)
    end

    return pack.seatId
end

function RoomModel:processPot(pack)
    self.gameInfo.pots = pack.pots
    self.gameInfo.hasRaise = false
    for i = 0, 8 do
        local player = self.playerList[i]
        if player then
            if player.isSelf and self.isSelfInGame_ then
                self.selfTotalBet_ = self.selfTotalBet_ + player.betChips
            end
            player.betChips = 0
        end
    end
end

function RoomModel:processFee(pack)
     local player = self.playerList[pack.seatId]
     if player then
        player.chips = pack.coins
        player.seatChips = pack.curCoins
    end
    return pack.seatId
end

function RoomModel:processDealThirdCard(pack)
    self.gameInfo.gameStatus = consts.SVR_GAME_STATUS.BET_ROUND_2
    self.gameInfo.dealed3rdCard = true
    if self.gameInfo.handCards then
        self.gameInfo.handCards[3] = pack.handCard3
        self.gameInfo.cardType = CardType.new(pack.cardType, pack.cardPoint)
        if self:isSelfInGame() then
            self:reportBestPoker_(self.gameInfo.handCards, self.gameInfo.cardType)
        end
    end
    if self.isSelfInGame_ then
        for i = 0, 8 do
            local player = self.playerList[i]
            if player and player.isSelf then
                player.handCards[3] = pack.handCard3
                player.cardType = self.gameInfo.cardType
            end
        end
    end
    
    --发第三张牌时，如果只剩少于2个人可以加注，则牌局结束，直接比牌(其他人都弃牌则不会发第三张牌)
    local notAllInPlayerNum = 0
    for i = 0, 8 do
        local player = self.playerList[i]
        if player and player.inGame and player.betState ~= consts.SVR_BET_STATE.ALL_IN then
            notAllInPlayerNum = notAllInPlayerNum + 1
        end
    end
    if notAllInPlayerNum < 2 then
        self.gameInfo.allAllIn = true
    end
end

function RoomModel:processTurnToBet(pack)
    local player = self.playerList[pack.seatId]
    self.gameInfo.bettingSeatId = pack.seatId
    self.gameInfo.callChips = pack.callChips
    if pack.callChips + self.roomInfo.blind < pack.maxRaiseChips then
        self.gameInfo.minRaiseChips = pack.callChips + self.roomInfo.blind
    else
        self.gameInfo.minRaiseChips = pack.minRaiseChips
    end
    -- self.gameInfo.minRaiseChips = pack.callChips + self.roomInfo.blind--pack.minRaiseChips
    self.gameInfo.maxRaiseChips = pack.maxRaiseChips
    player.statemachine:doEvent(SeatStateMachine.TURN_TO)
    return pack.seatId
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

    player.betChips = 0
    player.betState = 0
    player.inGame = false
    player.inRound = false
    player.statemachine = SeatStateMachine.new(player, false)
    self.playerList[player.seatId] = player
    player.isSelf = self:isSelf(player.uid)
    -- 判断是否是自己
    if player.isSelf then
        self.selfSeatId_ = player.seatId
        player.img = nk.userData.s_picture
        player.giftId = nk.userData.user_gift
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

function RoomModel:processStandUp(pack)
    local player = self.playerList[pack.seatId]
    if player and player.isSelf then
        self.isSelfAllIn_ = false
        self.canShowHandcard_ = false
        self.canShowHandcardButton_ = false
        self.isSelfInRound_ = false
        self.isSelfInGame_ = false
        self.selfSeatId_ = -1
        bm.DataProxy:setData(nk.dataKeys.SIT_OR_STAND, self:isSelfInSeat())

        if self.isInMatch_ then

        else
            if self:roomField() == 5 then
                nk.userData.gcoins = pack.chips
            else
                -- 设置金钱
                nk.userData.money = pack.chips
            end
        end
    end
    player = nil
    self.playerList[pack.seatId] = nil
    return pack.seatId
end

function RoomModel:processGameOver(pack)
    self.gameInfo.gameStatus = consts.SVR_GAME_STATUS.READY_TO_START
    --把座位的经验和筹码变化值清零
    for i = 0, 8 do
        local player = self.playerList[i]
        if player then
            player.changeExp = 0
            player.changeSeatChips = 0
        end
    end
    for i, v in ipairs(pack.seatChangeList) do
        local seatId = i - 1
        local player = self.playerList[seatId]
        if player then
            player.changeExp = v.exp
            player.changeSeatChips = v.seatChips
        end
    end
    for i, v in ipairs(pack.playerCardsList) do
        local player = self.playerList[v.seatId]
        if player then
            if not player.handCards then
                player.handCards = {0, 0, 0}
            end
            player.handCards[1] = v.handCard1 ~= 0 and v.handCard1 or player.handCards[1]
            player.handCards[2] = v.handCard2 ~= 0 and v.handCard2 or player.handCards[2]
            player.handCards[3] = v.handCard3 ~= 0 and v.handCard3 or player.handCards[3]
            if not player.cardType or not player.cardType:getLabel() then
                player.cardType = CardType.new(v.cardType, v.cardPoint)
            end
        end
    end

    local selfPlayer = self.playerList[self.selfSeatId_]
    if #pack.playerCardsList <= 1 then
        self.canShowHandcard_ = true
        if self.isSelfInGame_ then
            if selfPlayer.handCards[1] == 0 then
                self.canShowHandcardButton_ = false
            else
                self.canShowHandcardButton_ = true
            end
        end
    end

    self.gameInfo.splitPots = {}
    local isSelfWin = false
    for i, v in ipairs(pack.potsList) do
        local pot = {}
        self.gameInfo.splitPots[#self.gameInfo.splitPots + 1] = pot
        pot.winChips = v.winChips
        pot.seatId = v.seatId
        pot.uid = v.uid
        pot.cardType = CardType.new(v.cardType, v.cardPoint)
        pot.handCards = {v.handCard1, v.handCard2, v.handCard3}
        if i == 1 then
            --第一个奖池扣取台费
            pot.fee = pack.fee
            pot.isReallyWin = true
        elseif i == #pack.potsList then
            if not pack.lastPotIsNotWinChips or pack.lastPotIsNotWinChips == -1 then
                pot.isReallyWin = true
            else
                pot.isReallyWin = false
            end
        end
        local player = self.playerList[v.seatId]
        if player then
            if not player.handCards then
                player.handCards = {0, 0, 0}
            end
            player.handCards[1] = v.handCard1 ~= 0 and v.handCard1 or player.handCards[1]
            player.handCards[2] = v.handCard2 ~= 0 and v.handCard2 or player.handCards[2]
            player.handCards[3] = v.handCard3 ~= 0 and v.handCard3 or player.handCards[3]
            if not player.cardType or not player.cardType:getLabel() then
                player.cardType = pot.cardType
            end
        end

        if v.seatId == self.selfSeatId_ then
            isSelfWin = true
        end
    end

    --上报游戏结束
    if self.isSelfInRound_ and not self.isInMatch_ then

        if PlayerbackModel.isTask2Doing() then
            nk.userDefault:setStringForKey("task2CanReward","done")
        end
        local dataStr = nk.userDefault:getStringForKey(nk.userData.uid.. "pokersDate","")
        if dataStr == os.date("%Y%m%d") then
            local count = nk.userDefault:getIntegerForKey(nk.userData.uid.. "pokersCount", 0)
            nk.userDefault:setIntegerForKey(nk.userData.uid .. "pokersCount", count + 1)
        else
            nk.userDefault:setStringForKey(nk.userData.uid .. "pokersDate",os.date("%Y%m%d"))
            nk.userDefault:setIntegerForKey(nk.userData.uid .. "pokersCount", 1)
        end
        nk.userDefault:flush()
        if nk.userData.gameCount then
            nk.userData.gameCount = nk.userData.gameCount + 1
            if nk.userData.gameCount == 10 then
                nk.AdSdk:report(consts.AD_TYPE.AD_CUSTOM,{uid =tostring(nk.userData.uid),event_name = "newUserGame10" })
            elseif nk.userData.gameCount == 15 then
                nk.AdSdk:report(consts.AD_TYPE.AD_CUSTOM,{uid =tostring(nk.userData.uid),event_name = "newUserGame15" })
            elseif nk.userData.gameCount == 20 then
                nk.AdSdk:report(consts.AD_TYPE.AD_CUSTOM,{uid =tostring(nk.userData.uid),event_name = "newUserGame20" })
            elseif nk.userData.gameCount == 30 then
                nk.AdSdk:report(consts.AD_TYPE.AD_CUSTOM,{uid =tostring(nk.userData.uid),event_name = "newUserGame30" })
            end
        end

        --上报成就
        local gcoins = 0
        if self:isCoinRoom() then
            gcoins = 1
        end
        for _, pot in ipairs(self.gameInfo.splitPots) do
            if pot.isReallyWin and pot.seatId == self.selfSeatId_ then
                local player = self:selfSeatData()
                if player and player.handCards and player.cardType then
                    local cardType_ = player.cardType:getCardTypeValue()
                    if cardType_ > consts.CARD_TYPE.POINT_CARD then
                        bm.EventCenter:dispatchEvent({
                            name = nk.DailyTasksEventHandler.REPORT_WIN_GOODCARD,
                            data = {isgcoin = gcoins, cardType = cardType_}
                        })
                        break
                    end
                end
            end
        end
        if self.isSelfAllIn_ then
            local iswin_ = 0
            if isSelfWin then
                iswin_ = 1
            end
            bm.EventCenter:dispatchEvent({
                name = nk.DailyTasksEventHandler.REPORT_USER_ALLIN,
                data = {isgcoin = gcoins, iswin = iswin_}
            })
        end
    end
    if self.isSelfInRound_ and self.isInMatch_ then
        if PlayerbackModel.isTask3Doing() then
            nk.userDefault:setStringForKey("task3CanReward","done")
        end
    end

    for i = 0, 8 do
        local player = self.playerList[i]
        if player then
            player.inGameBeforeGameOver = player.inGame
            player.inGame = false
            player.inRound = false
            
            player.statemachine:doEvent(SeatStateMachine.GAME_OVER)
        end
    end
end


function RoomModel:processSendChipSuccess(pack,toPacket)
    local fromPlayer = self.playerList[pack.fromSeatId]
        local toPlayer = self.playerList[pack.toSeatId]
        local chips = pack.chips
        if fromPlayer then
            if toPacket==true then
                fromPlayer.chips = fromPlayer.chips - chips
            else
                fromPlayer.seatChips = fromPlayer.seatChips - chips
            end
        end
        if toPlayer then
            if toPacket==true then
                toPlayer.chips = toPlayer.chips + chips
            else
                toPlayer.seatChips = toPlayer.seatChips + chips
            end
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
        for i = 0, 8 do
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

--上报最佳牌型
function RoomModel:reportBestPoker_(handCards, cardType)
    local prevCardType = 0
    local prevCardPoint = 0
    local prevPoker = nk.userData.bestpoker
    if prevPoker and string.len(prevPoker) == 8 then
        prevCardType = tonumber(string.sub(prevPoker, 1, 1))
        prevCardPoint = tonumber(string.sub(prevPoker, 2, 2))
    end
    if self:isSelfInRound() and cardType:getCardTypeValue() > prevCardType or cardType:getCardTypeValue() == prevCardType and prevCardType == 1 and cardType:getCardPointValue() > prevCardPoint then
        local thisPoker = string.format("%d%d%x%x%x%x%x%x",
            cardType:getCardTypeValue(),
            cardType:getCardPointValue(),
            math.floor(handCards[1] / 256),
            handCards[1] % 256,
            math.floor(handCards[2] / 256),
            handCards[2] % 256,
            math.floor(handCards[3] / 256),
            handCards[3] % 256)
        --bm.HttpService.POST({mod="user", act="setMostStat", bestpoker=thisPoker})
        nk.userData.bestpoker = thisPoker
    end
end

function RoomModel:reset()
    if self.gameInfo then
        self.gameInfo.allAllIn = false
    end

    self.isSelfAllIn_ = false
    self.canShowHandcard_ = false
    self.canShowHandcardButton_ = false
    self.isSelfInRound_ = false
    self.isSelfInGame_ = false

    self.selfTotalBet_ = 0
end

function RoomModel:updateUserInfo(player)
    -- 添加exUserInfo 信息
    if player.exUserInfo ~= "" then
        local exUserInfo = json.decode(player.exUserInfo)
        if exUserInfo then
            if exUserInfo.giftId then
                player.giftId = exUserInfo.giftId
            end
            if exUserInfo.nick then
                player.nick = exUserInfo.nick
            end
            if exUserInfo.img then
                player.img = exUserInfo.img
            end
        end
    end
end

function RoomModel:svrModifyUserinfo(pack)
    local uid = pack.uid
    local exUserInfo = json.decode(pack.exUserInfo)
    local seatId = self:getSeatIdByUid(uid)
    if seatId < 0 then
        return seatId
    end
    local player = self.playerList[seatId]
    if exUserInfo then
        player.exUserInfo = pack.exUserInfo
        if exUserInfo.giftId then
            player.giftId = exUserInfo.giftId
        end
        if exUserInfo.nick then
            player.nick = exUserInfo.nick
            if player.statemachine then
                player.statemachine:setDefaultString(player.nick)
            end
        end
        if exUserInfo.img then
            player.img = exUserInfo.img
        end
    end
    return seatId
end

return RoomModel
