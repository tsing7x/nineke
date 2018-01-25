--
-- Author: Jonah0608@gmail.com
-- Date: 2016-08-31 14:19:52
--
local DiceModel = {}

function DiceModel.new()
    local instance = {}
    local datapool = {}
    local function getData(table,key)
        return DiceModel[key] or datapool[key]
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

function DiceModel:ctor()
    self.isInitialized = false
    self.rates = {}
    self.history_ = {}
    self.selfSeatId_ = -1
    self.isdice_ = true
    self.curcount = 0
    self.isbet_ = false
    self.roomType_ = 0
end

-- »ñÈ¡µ±Ç°·¿¼äÀàÐÍ
function DiceModel:roomType()
    return self.roomType_
end

function DiceModel:initWithLoginSuccessPack(pack)
    -- self.clearData()
    self.isdice_ = true
    local roomInfo = {}
    self.roomInfo = roomInfo
    roomInfo.basechip = pack.basechip
    roomInfo.minbuy = pack.minbuy
    roomInfo.maxbuy = pack.maxbuy
    roomInfo.roomType = pack.roomType
    roomInfo.maxnum = pack.maxnum
    roomInfo.rates = pack.typeArr
    roomInfo.tid = pack.tid
    roomInfo.ip = pack.ip
    roomInfo.port = pack.port
    roomInfo.blind = pack.basechip

    self.roomType_ = roomInfo.roomType
    local playerList = {}
    self.playerList = playerList
    for i,player in ipairs(pack.playerList) do
        if player.uid == nk.userData.uid then
            self.selfSeatId_ = player.seatId
        else
            playerList[player.seatId] = player
            self:updateUserInfo(player)
        end
    end
end

function DiceModel:processSitDown(pack)
    local player = pack
    local isSelf = false
    if player.uid == nk.userData.uid then
        self.selfSeatId_ = player.seatId
        isSelf = true
    else
        self.playerList[player.seatId] = player
    end
    return player.seatId,isSelf
end

function DiceModel:processStandUp(pack)
    self.playerList[pack.seatId] = nil
    return pack.seatId
end

function DiceModel:processGameStart(pack)
    nk.userData.money = pack.money
    for i,v in pairs(pack.seatInfo) do
        if self.playerList[v.seatId] then
            self.playerList[v.seatId].curChips = v.chips
            self.playerList[v.seatId].money = v.money
        end
    end
    self.Bets = {}
end

function DiceModel:svrModifyUserinfo(pack)
    local uid = pack.uid
    if uid == nk.userData.uid then
        return 9
    end
    local seatId = self:getSeatIdByUid(uid)
    if seatId < 0 then
        return seatId
    end
    local player = self.playerList[seatId]
    if player then
        if pack.exUserInfo then
            player.userInfoEx = pack.exUserInfo
        end
        self:updateUserInfo(player)
    end
    return seatId
end

function DiceModel:updateUserInfo(player)
    if player.userInfoEx ~= "" then
        local exUserInfo = json.decode(player.userInfoEx)
        if exUserInfo then
            local info = json.decode(player.userInfo)
            if exUserInfo.giftId then
                info.giftId = exUserInfo.giftId
            end
            if exUserInfo.nick then
                info.nick = exUserInfo.nick
            end
            if exUserInfo.img then
                info.img = exUserInfo.img
            end
            player.userInfo = json.encode(info)
        end
    end
end


function DiceModel:getSeatIdByUid(uid)
    for seatId = 0, 8 do
        local player = self.playerList[seatId]
        if player and player.uid == uid then
            return seatId
        end
    end
    return -1
end

function DiceModel:getWinSeats(type,allchip,pack)
    local seats = {}
    local chip = 0
    for i,v in pairs(pack.betresult) do
        if v.type == type then
            local data = {}
            data.uid = nk.userData.uid
            data.chips = v.winChip
            data.seatId = self:selfSeatId()
            table.insert(seats,data)
            chip = chip + v.winChip
            break
        end
    end
    for _,v in pairs(pack.playerList) do
        if v.uid == nk.userData.uid then
        else
            for _,value in pairs(v.betresult) do
                if value.type == type then
                    local data = {}
                    data.uid = v.uid
                    data.chips = value.winChip
                    data.seatId = v.seatId
                    table.insert(seats,data)
                    chip = chip + value.winChip
                    break
                end
            end
        end
    end
    if allchip > chip then
        local data = {}
        data.uid = -1
        data.chips = allchip - chip
        data.seatId = -1
        table.insert(seats,data)
    end
    return seats
end

function DiceModel:processSelfBetSuccess(pack)
    local bet_data = {}
    bet_data.betType = pack.betType
    bet_data.betChip = pack.betChip
    if not self.Bets then
        self.Bets = {}
    end
    for i = 1, #self.Bets do
        if self.Bets[i].betType == bet_data.betType then
            self.Bets[i].betChip = self.Bets[i].betChip + bet_data.betChip
            return
        end
    end
    table.insert(self.Bets, bet_data)
end

function DiceModel:processResult(pack)
    self.isbet_ = false
    local result = {}
    result.carddata_ = {}
    result.carddata_.cards1 = {pack.card11,pack.card12,pack.card13}
    result.carddata_.type1 = pack.type1
    result.carddata_.cards2 = {pack.card21,pack.card22,pack.card23}
    result.carddata_.type2 = pack.type2
    result.carddata_.res = pack.res
    result.windeal = pack.res
    result.windata_ = {}
    for i,v in pairs(pack.winresult) do
        local data = {}
        data.wintype = v.type
        data.winchips = v.chips / 100
        data.winseats = self:getWinSeats(v.type,v.chips / 100,pack)
        table.insert(result.windata_,data)
    end

    self.lastBets = {}
    for i,v in pairs(pack.betresult) do
        local bet_data = {}
        bet_data.betType = v.type
        bet_data.betChip = v.betChip
        table.insert(self.lastBets, bet_data)
    end

    self:expChange(pack.trunExp)
    return result
end

function DiceModel:expChange(changeExp)
    nk.userData.experience = nk.userData.experience + changeExp
    local level = nk.Level:getLevelByExp(nk.userData.experience) or nk.userData.level
    if tonumber(level) > tonumber(nk.userData.level) then
    --     self:levelUp_(level)
    -- else
        nk.userData.level = level
    end
    nk.userData.title = nk.Level:getTitleByExp(nk.userData.experience) or nk.userData.title
end

function DiceModel:selfSeatId()
    return self.selfSeatId_
end

function DiceModel:isSelfInSeat()
    return true
end

function DiceModel:processGetHistory(pack)
    if not self.history_ then
        self.history_ = {}
    end
    local count = 1
    for i,v in pairs(pack.history) do
        if v.res == 1 then
            self.history_[count] = v.type1
        else
            self.history_[count] = v.type2
        end
        count = count + 1
    end
end

function DiceModel:insertToHistory(type)
    local count = #self.history_
    if count == 0 then
        self.history_[1] = type
        return
    end
    for i = count,1,-1 do
        if i > 36 then
            self.history_[i] = nil
        else
            self.history_[i + 1] = self.history_[i]
        end
    end
    self.history_[1] = type
end

function DiceModel:getHistory()
    return self.history_
end

function DiceModel:processRoomBroadcast(pack)
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
    end
    return mtype, content, pack.param
end

return DiceModel