--
-- Author: Jonah0608@gmail.com
-- Date: 2016-01-12 10:22:07
--
local PROTOCOL = import(".HALL_SOCKET_PROTOCOL")
local SocketBase = import(".SocketBase")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local HallBroadcast = import(".HallBroadcast")
local HallSocket = class("HallSocket", SocketBase)

local IS_CONN_TO_TEST_ROOM = false
local IS_CONN_TO_TEST_DICE = false

function HallSocket:ctor()
    HallSocket.super.ctor(self,"HallSocket", PROTOCOL)
    self.isLogin_ = false
    self.hallBroadcast_ = HallBroadcast.new()
end

function HallSocket:connectToRoom(ip, port, tid, isPlayNow, psword)
    self.isDice_ = false
    self.isPdeng_ = false
    self.logger_:debugf("connectToRoom %s:%s %s %s", ip, port, tid, isPlayNow)
    if IS_CONN_TO_TEST_ROOM then
        ip = "192.168.0.169"
        port = 11170
        tid = 2114903
    end
    self.roomip_ = ip
    self.roomport_ = port
    self.roomtid_ = tid
    self.isPlayNow_ = isPlayNow
    self.isRoomEntered_ = false
    self.psword_ = psword
    local pack = self:createPacketBuilder(PROTOCOL.HALL_CLI_LOGIN_ROOM)
        :setParameter("ip", self.roomip_)
        :setParameter("port", self.roomport_)
        :build()
    self:send(pack)

    --登录房间超时检测
    if self.loginRoomTimeoutHandle_ then
        scheduler.unscheduleGlobal(self.loginRoomTimeoutHandle_)
        self.loginRoomTimeoutHandle_ = nil
    end
    self.loginRoomTimeoutHandle_ = scheduler.performWithDelayGlobal(function()
        self.logger_:debug("login room timeout..")
        bm.EventCenter:dispatchEvent({name=nk.eventNames.LOGIN_ROOM_FAIL, silent=false})
        -- local connInfo = {ip=self.roomip_, port=self.roomport_, tid=self.roomtid_, isPlayNow=self.isPlayNow_}
        -- if self.isRoomEntered_ then
        --     bm.EventCenter:dispatchEvent({name=nk.eventNames.ROOM_CONN_PROBLEM, data=connInfo, silent=true})
        -- else
        --     bm.EventCenter:dispatchEvent({name=nk.eventNames.LOGIN_ROOM_FAIL, data=connInfo, silent=true})
        -- end
        self.loginRoomTimeoutHandle_ = nil
        self:disconnectRoom()
    end, 4)
end

function HallSocket:sendLoginToRoom()
    local userData = nk.userData
    self:sendLogin({
            tid    = self.roomtid_, 
            uid    = userData.uid,
            mtkey  = userData.mtkey,
            img    = userData.s_picture,
            giftId = userData.user_gift
        })
end

function HallSocket:getTid()
    return self.roomtid_
end

function HallSocket:isPlayNow()
    return self.isPlayNow_
end

function HallSocket:disconnect(noEvent)
    self.logger_:debugf("disconnect %s", noEvent)
    HallSocket.super.disconnect(self, noEvent)
end

function HallSocket:disconnectRoom(noEvent)
    self.logger_:debugf("disconnect room %s", self.isRoomEntered_)
    if self.isRoomEntered_ then 
        self:sendLogout()
    end
    self.isPlayNow_ = nil
end

function HallSocket:disconnectDice(noEvent)
    self.logger_:debugf("disconnect dice %s", self.isRoomEntered_)
    if self.isRoomEntered_ then 
        self:sendLogoutDice()
    end
    self.isPlayNow_ = nil
end

function HallSocket:onConnectTimeout_()
    self:onFail_(consts.SVR_ERROR.ERROR_HEART_TIME_OUT)
end

function HallSocket:login()
    if self.loginTimeoutHandle_ then
        scheduler.unscheduleGlobal(self.loginTimeoutHandle_)
        self.loginTimeoutHandle_ = nil
    end
    self.loginTimeoutHandle_ = scheduler.performWithDelayGlobal(function()
        self.loginTimeoutHandle_ = nil
        self:disconnect()
        self:onFail_(consts.SVR_ERROR.ERROR_LOGIN_TIME_OUT)
        local ip,port = string.match(nk.userData.HallServer[1], "([%d%.]+):(%d+)")
        nk.socket.HallSocket:connectDirect(ip, port, true) 
    end, 5)

    local uid = nk.userData.uid   
    local userInfo = nk.getUserInfo()
    local pack = self:createPacketBuilder(PROTOCOL.HALL_CLI_LOGIN)
        :setParameter("uid", uid)
        :setParameter("uinfo", json.encode(userInfo))       
        :build()
    self:send(pack)
end

function HallSocket:onAfterConnected()
    self:login()
end

function HallSocket:onClosed(evt)
    self.isLogin_ = false
    HallSocket.super.onClosed(self, evt)
end

function HallSocket:onClose(evt)
    self:unscheduleHeartBeat()
end

function HallSocket:buildHeartBeatPack()
    return self:createPacketBuilder(PROTOCOL.CLISVR_HEART_BEAT):build()
end

function HallSocket:onHeartBeatTimeout(timeoutCount)
    bm.DataProxy:setData(nk.dataKeys.SIGNAL_STRENGTH, 0)
    if timeoutCount >= 3 then
        self:onFail_(consts.SVR_ERROR.ERROR_HEART_TIME_OUT)
        self:disconnect()
    end
end

function HallSocket:onHeartBeatReceived(delaySeconds)
    local signalStrength
    if delaySeconds < 0.4 then
        signalStrength = 4
    elseif delaySeconds < 0.8 then
        signalStrength = 3
    elseif delaySeconds < 1.2 then
        signalStrength = 2
    else
        signalStrength = 1
    end
    bm.DataProxy:setData(nk.dataKeys.SIGNAL_STRENGTH, signalStrength)
end

function HallSocket:onAfterConnectFailure()
    self:onFail_(consts.SVR_ERROR.ERROR_CONNECT_FAILURE)
end

--房间消息
function HallSocket:sendUserInfoChanged() 
    local exUserInfo = {}
    exUserInfo.nick = nk.userData.nick
    exUserInfo.img = nk.userData.s_picture
    exUserInfo.giftId = nk.userData.user_gift
    local pack = self:createPacketBuilder(PROTOCOL.CLI_MODIFY_USERINFO)
        :setParameter("exUserInfo",json.encode(exUserInfo))
        :build()
    self:send(pack)
end

function HallSocket:sendLogin(params)
    local vipconfig = self:getVipConfig_()
    local userInfo = {}
    if vipconfig then
        userInfo.vipmsg = vipconfig
    end

    local pack = self:createPacketBuilder(PROTOCOL.CLI_LOGIN)
        :setParameter("tid", params.tid)
        :setParameter("uid", params.uid)
        :setParameter("mtkey", params.mtkey)
        :setParameter("img", params.img)
        :setParameter("giftId", params.giftId)
        :setParameter("ver", 1)
        :setParameter("userInfo", json.encode(userInfo))
        :setParameter("ExUserInfo", "")
        :setParameter("psword", self.psword_ or "")
        :build()
    self:send(pack)
    self.psword_ = nil
end

--yk
function HallSocket:getVipConfig_()
    local config
    local vipconfig = nk.OnOff:getConfig('vipmsg')
    local vipconfig_2 = nk.OnOff:getConfig('newvipmsg')

    if vipconfig_2 and vipconfig_2.newvip == 1 then
      config = vipconfig_2
    else
      if vipconfig and vipconfig.isvip == 1 and vipconfig.vip and vipconfig.vip.light and vipconfig.vip.light == 1 then
        config = vipconfig
      else
        config = vipconfig_2
      end
    end

    return config
end

function HallSocket:sendLogout()
    self.logoutRequested_ = true
    self.isRoomEntered_ = false
    self.roomip_ = nil
    self.roomport = nil
    self.roomtid_ = nil
    self:send(self:createPacketBuilder(PROTOCOL.CLI_LOGOUT):build())
end

function HallSocket:sendSitDown(seatId, buyIn)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_SIT_DOWN)
        :setParameter("seatId", seatId)
        :setParameter("buyIn", buyIn)
        :build()
    self:send(pack)
end

function HallSocket:sendAutoBuyin()
    self:send(self:createPacketBuilder(PROTOCOL.CLI_SET_AUTO_SIT):build())
end

function HallSocket:sendStandUp()
    self:send(self:createPacketBuilder(PROTOCOL.CLI_STAND_UP):build())
end

function HallSocket:showHandcard()
    self:send(self:createPacketBuilder(PROTOCOL.CLI_SHOW_HAND_CARD):build())
end

function HallSocket:sendBet(betType, betChips)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_BET)
        :setParameter("betType", betType)
        :setParameter("betChips", betChips)
        :build()
    self:send(pack)
end

function HallSocket:sendAddFriend(fromSeatId, toSeatId)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_ADD_FRIEND)
        :setParameter("fromSeatId", fromSeatId)
        :setParameter("toSeatId", toSeatId)
        :build()
    self:send(pack)
end

function HallSocket:sendSendChips(fromSeatId, toSeatId, toUid, chips)
    self:sendChips_1(fromSeatId, toSeatId,toUid, chips);
    -- local pack = self:createPacketBuilder(PROTOCOL.CLI_SEND_CHIPS)
    --     :setParameter("fromSeatId", fromSeatId)
    --     :setParameter("toSeatId", toSeatId)
    --     :setParameter("chips", chips)
    --     :build()
    -- self:send(pack)
end

--给荷官小费
function HallSocket:sendDealerChip()
    self:send(self:createPacketBuilder(PROTOCOL.CLI_CMD_SEND_DEALER_MONEY):build())
end

function HallSocket:sendSrvChangeHead(uid, picUrl)
    self:sendRoomBroadCast_(uid, json.encode({type=2, url=picUrl}))
end

--广播赠送礼物
function HallSocket:sendPresentGift(giftId, fromUid, toUidArr)
    self:sendRoomBroadCast_(fromUid, json.encode({type=3, giftId=giftId, toUidArr=toUidArr}))
end

--广播设置礼物
function HallSocket:sendSetGift(giftId, uid)
    self:sendRoomBroadCast_(uid, json.encode({type=4, giftId=giftId}))
end


function HallSocket:sendExpression(expressionType, expressionId)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_SEND_EXPRESSION)
        :setParameter("expressionType", expressionType)
        :setParameter("expressionId", expressionId)
        :build()
    self:send(pack)
end

function HallSocket:sendSendHddj(fromSeatId, toSeatId, hddjId)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_SEND_HDDJ)
        :setParameter("fromSeatId", fromSeatId)
        :setParameter("toSeatId", toSeatId)
        :setParameter("hddjId", hddjId)
        :build()
    self:send(pack)
end

--[[
    发送房间广播消息
]]
function HallSocket:sendRoomBroadCast_(param, content)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_SEND_ROOM_BROADCAST)
        :setParameter("tid", self.roomtid_)
        :setParameter("param", param)
        :setParameter("content", content)
        :build()
    self:send(pack)
end

function HallSocket:sendChatMsg(message)
    local messageType
    if message.messagetype then
        if message.messagetype == 3 then
            messageType = 3
        else
            messageType = 1
        end
        self:sendRoomBroadCast_(0, json.encode({
            type=messageType,
            uid=nk.userData.uid,
            name=nk.userData.nick,
            msg=message.content
        }))
    else
        self:sendRoomBroadCast_(0, json.encode({
            type=1,
            uid=nk.userData.uid,
            name=nk.userData.nick,
            msg=message
        }))
    end
end

function HallSocket:dropCards4K(holdcards,foldcards)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_DROP_CARD_4K)
        :setParameter("holdcards", holdcards)
        :setParameter("foldcards", foldcards)
        :build()
    self:send(pack)
end

function HallSocket:foldCards4K()
    local pack = self:createPacketBuilder(PROTOCOL.CLI_FOLD_CARD_4K):build()
    self:send(pack)
end

function HallSocket:connectToDice(ip,port,tid)
    self.isDice_ = true
    self.logger_:debugf("connectToDice %s:%s %s", ip, port, tid)
    if IS_CONN_TO_TEST_DICE then
        ip = "192.168.0.168"
        port = "13003"
        tid = 818372
    end
    self.roomip_ = ip
    self.roomport_ = port
    self.roomtid_ = tid
    self.isPlayNow_ = isPlayNow
    self.isRoomEntered_ = false
    local pack = self:createPacketBuilder(PROTOCOL.HALL_CLI_LOGIN_ROOM)
        :setParameter("ip", self.roomip_)
        :setParameter("port", self.roomport_)
        :build()
    self:send(pack)

    --登录房间超时检测
    if self.loginRoomTimeoutHandle_ then
        scheduler.unscheduleGlobal(self.loginRoomTimeoutHandle_)
        self.loginRoomTimeoutHandle_ = nil
    end
    self.loginRoomTimeoutHandle_ = scheduler.performWithDelayGlobal(function()
        self.logger_:debug("login room timeout..")
        -- bm.EventCenter:dispatchEvent({name=nk.eventNames.LOGIN_DICE_FAIL, silent=false})
        local connInfo = {ip=self.roomip_, port=self.roomport_, tid=self.roomtid_, isPlayNow=self.isPlayNow_}
        if self.isRoomEntered_ then
            bm.EventCenter:dispatchEvent({name=nk.eventNames.DICE_CONN_PROBLEM, data=connInfo, silent=true})
        else
            bm.EventCenter:dispatchEvent({name=nk.eventNames.LOGIN_DICE_FAIL, data=connInfo, silent=true})
        end
        self.loginRoomTimeoutHandle_ = nil
        self:disconnectDice()
    end, 4)
end

function HallSocket:sendLoginToDice()
    local pack = self:createPacketBuilder(PROTOCOL.CLI_LOGIN_DICE)
        :setParameter("tid",self.roomtid_)
        :setParameter("uid",nk.userData.uid)
        :setParameter("mtkey",nk.userData.mtkey)
        :setParameter("userInfo",json.encode(self:buildUserInfo()))
        :setParameter("ExUserInfo","")
        :build()
    self:send(pack)
end

function HallSocket:buildUserInfo()
    local userInfo = {}
    local vipconfig = self:getVipConfig_()
    if vipconfig then
        userInfo.vipmsg = vipconfig
    end

    userInfo.uid = nk.userData.uid
    userInfo.chips = nk.userData.money
    userInfo.exp = nk.userData.experience
    userInfo.level = nk.userData.level
    userInfo.nick = nk.userData.nick
    userInfo.gender = nk.userData.sex
    userInfo.img = nk.userData.s_picture
    userInfo.win = nk.userData.win
    userInfo.lose = nk.userData.lose
    userInfo.giftId = nk.userData.user_gift
    
    return userInfo
end

function HallSocket:sendLogoutDice()
    self.logoutRequested_ = true
    self.isRoomEntered_ = false
    self.roomip_ = nil
    self.roomport = nil
    self.roomtid_ = nil
    local pack = self:createPacketBuilder(PROTOCOL.CLI_LOGOUT_DICE)
        :build()
    self:send(pack)
end

function HallSocket:sendBetDice(type,chips)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_BET_DICE)
        :setParameter("betType",type)
        :setParameter("betChip",chips)
        :build()
    self:send(pack)
end

function HallSocket:getDiceHistory()
    local pack = self:createPacketBuilder(PROTOCOL.CLI_GET_HISTORY):build()
    self:send(pack)
end

function HallSocket:getAllUser(index,size)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_GET_ALL_USERINFO)
        :setParameter("index",index)
        :setParameter("showSize",size)
        :build()
    self:send(pack)
end

function HallSocket:getUserCount()
    local pack = self:createPacketBuilder(PROTOCOL.CLI_GET_COUNT):build()
    self:send(pack)
end

function HallSocket:setDealChipsDice(dealId,money)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_SEND_DEALER_MONEY_DICE)
        :setParameter("receiverID",dealId)
        :setParameter("money",money)
        :build()
    self:send(pack)
end

function HallSocket:sendSendChipsDice(fromSeatId, toSeatId,toUid, chips)
    self:sendChips_1(fromSeatId, toSeatId,toUid, chips);
    -- local pack = self:createPacketBuilder(PROTOCOL.CLI_SEND_CHIPS_DICE)
    --     :setParameter("fromSeatId", fromSeatId)
    --     :setParameter("toSeatId", toSeatId)
    --     :setParameter("toUid",toUid)
    --     :setParameter("chips", chips)
    --     :build()
    -- self:send(pack)
end
function HallSocket:sendChips_1(fromSeatId, toSeatId,toUid, chips)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_SEND_CHIPS_1)
        :setParameter("fromSeatId", fromSeatId)
        :setParameter("toSeatId", toSeatId)
        :setParameter("toUid",toUid)
        :setParameter("chips", chips)
        :build()
    self:send(pack)
end

function HallSocket:sendAddFriendDice(fromSeatId, toSeatId,friendId)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_ADD_FRIEND_DICE)
        :setParameter("fromSeatId", fromSeatId)
        :setParameter("toSeatId", toSeatId)
        :setParameter("friendId",friendId)
        :build()
    self:send(pack)
end

function HallSocket:sendExpressionDice(expressionType, expressionId)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_SEND_EXPRESSION_DICE)
        :setParameter("expressionType", expressionType)
        :setParameter("expressionId", expressionId)
        :build()
    self:send(pack)
end







function HallSocket:connectToPdeng(ip,port,tid,isGrabDealer)
    self.isDice_ = false
    self.isPdeng_ = true
    
    IS_CONN_TO_TEST_PDENG = false
    if IS_CONN_TO_TEST_PDENG then
        ip = "111.223.41.168"
        port = "13206"
        tid = 20000018
    end
    self.logger_:debugf("connectToPdeng %s:%s %s", ip, port, tid)
    self.roomip_ = ip
    self.roomport_ = port
    self.roomtid_ = tid
    self.isGrabDealer = isGrabDealer
    self.needShowDealer = isGrabDealer
    self.isRoomEntered_ = false
    local pack = self:createPacketBuilder(PROTOCOL.HALL_CLI_LOGIN_ROOM)
        :setParameter("ip", self.roomip_)
        :setParameter("port", self.roomport_)
        :build()
    self:send(pack)

    --登录房间超时检测
    if self.loginRoomTimeoutHandle_ then
        scheduler.unscheduleGlobal(self.loginRoomTimeoutHandle_)
        self.loginRoomTimeoutHandle_ = nil
    end
    self.loginRoomTimeoutHandle_ = scheduler.performWithDelayGlobal(function()
        self.logger_:debug("login room timeout..")
        local connInfo = {ip=self.roomip_, port=self.roomport_, tid=self.roomtid_, isGrabDealer=self.isGrabDealer}
        bm.EventCenter:dispatchEvent({name=nk.eventNames.LOGIN_PDENG_FAIL, data=connInfo, silent=true})
        self.loginRoomTimeoutHandle_ = nil
        self:disconnectPdeng()
    end, 4)
end


function HallSocket:disconnectPdeng(noEvent)
    self.logger_:debugf("disconnect Pdeng %s", self.isRoomEntered_)
    if self.isRoomEntered_ then 
        self:sendLogoutPdeng()
    end
    self.isPlayNow_ = nil
end

function HallSocket:sendLoginToPdeng()
    local isDealer = 0;
    if self.isGrabDealer == true then
        isDealer = 1
    end
    local pack = self:createPacketBuilder(PROTOCOL.CLI_PDENG_LOGIN_ROOM)
        :setParameter("tid",self.roomtid_)
        :setParameter("uid",nk.userData.uid)
        :setParameter("mtkey",nk.userData.mtkey)
        :setParameter("userInfo",json.encode(self:buildUserInfo()))
        :setParameter("ExUserInfo","")
        :setParameter("reqBanker",isDealer)
        :build()
    self:send(pack)
end

function HallSocket:sendLogoutPdeng()
    if (not self:isConnected()) or (not self.isRoomEntered_) then
        self.logoutRequested_ = true
        self.isRoomEntered_ = false
        self.roomip_ = nil
        self.roomport = nil
        self.roomtid_ = nil
    end
    local pack = self:createPacketBuilder(PROTOCOL.CLI_PDENG_LOGOUT_ROOM)
        :build()
    self:send(pack)
end

function HallSocket:sendBetPdeng(chips)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_PDENG_SET_BET)
        :setParameter("bet",chips)
        :build()
    self:send(pack)
end

function HallSocket:sendSeatDownPdeng(seatId, ante)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_PDENG_SEAT_DOWN)
        :setParameter("seatId",seatId)
        :setParameter("ante",ante)
        :build()
    self:send(pack)
end

function HallSocket:sendStandUpPdeng()
    local pack = self:createPacketBuilder(PROTOCOL.CLI_PDENG_STAND_UP)
        :build()
    self:send(pack)
end

function HallSocket:sendRequestGrabDealerPdeng(chips)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_PDENG_REQUEST_GRAB_DEALER)
        :setParameter("handCoin",chips)
        :build()
    self:send(pack)
end

function HallSocket:sendOtherCardPdeng(type)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_PDENG_OTHER_CARD)
        :setParameter("type",type)
        :build()
    self:send(pack)
end

function HallSocket:sendDealChipsPdeng()
    local pack = self:createPacketBuilder(PROTOCOL.CLI_PDENG_SEND_DEALER_MONEY)
        :build()
    self:send(pack)
end

function HallSocket:sendSendChipsPdeng(fromSeatId, toSeatId,toUid, chips)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_PDENG_SEND_CHIPS)
        :setParameter("fromSeatId", fromSeatId)
        :setParameter("toSeatId", toSeatId)
        :setParameter("toUid",toUid)
        :setParameter("chips", chips)
        :build()
    self:send(pack)
end

function HallSocket:sendAddFriendPdeng(fromSeatId, toSeatId,friendId)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_PDENG_ADD_FRIEND)
        :setParameter("fromSeatId", fromSeatId)
        :setParameter("toSeatId", toSeatId)
        :setParameter("friendId",friendId)
        :build()
    self:send(pack)
end

function HallSocket:sendExpressionPdeng(expressionType, expressionId)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_PDENG_SEND_EXPRESSION)
        :setParameter("expressionType", expressionType)
        :setParameter("expressionId", expressionId)
        :build()
    self:send(pack)
end




function HallSocket:isLogin()
    return self.isLogin_
end


function HallSocket:svrLoginOk(pack)
    if self.loginTimeoutHandle_ then
        scheduler.unscheduleGlobal(self.loginTimeoutHandle_)
        self.loginTimeoutHandle_ = nil
    end
    self:scheduleHeartBeat(PROTOCOL.CLISVR_HEART_BEAT, 10, 3)
    self.isLogin_ = true
    bm.EventCenter:dispatchEvent({name=nk.eventNames.SVR_LOGIN_OK, data=pack})
    if self.isRoomEntered_ then
        if self.roomip_ and self.roomport_ and self.roomtid_ then
            if self.isDice_ then
                self:connectToDice(self.roomip_, self.roomport_,self.roomtid_)
            elseif self.isPdeng_ then
                self:connectToPdeng(self.roomip_, self.roomport_,self.roomtid_)
            else
                self:connectToRoom(self.roomip_, self.roomport_,self.roomtid_,self.isPlayNow_)
            end
        end
    end
end

function HallSocket:onProcessPacket(pack)
    local cmd = pack.cmd
    if cmd == PROTOCOL.HALL_SVR_LOGIN_OK then
        self:svrLoginOk(pack)
    elseif cmd == PROTOCOL.HALL_SVR_LOGIN_ROOM_RESULT then
        if pack.ret == 0 then
            if self.isDice_ then
                self:sendLoginToDice()
            elseif self.isPdeng_ then
                self:sendLoginToPdeng()
            else
                self:sendLoginToRoom()
            end
        else
            self:disconnectRoom()
        end
    elseif cmd == PROTOCOL.HALL_SVR_DOUBLELOGIN then
        self.shouldConnect_ = false
        bm.EventCenter:dispatchEvent(nk.eventNames.DOUBLE_LOGIN_LOGINOUT)
    else
        self:onProcessPacket_(pack)
    end
end

function HallSocket:onProcessPacket_(pack)
    local cmd = pack.cmd
    if cmd == PROTOCOL.SVR_LOGIN_SUCCESS or cmd == PROTOCOL.SVR_LOGIN_SUCCESS_4K then
        if self.loginRoomTimeoutHandle_ then
            scheduler.unscheduleGlobal(self.loginRoomTimeoutHandle_)
            self.loginRoomTimeoutHandle_ = nil
        end
        self.isRoomEntered_ = true
        -- 通知登录成功
        pack.tid = self.roomtid_
        pack.ip = self.roomip_
        pack.port = self.roomport_
        bm.EventCenter:dispatchEvent(nk.eventNames.LOGIN_ROOM_SUCC)
    elseif cmd == PROTOCOL.SVR_LOGIN_SUCCESS_DICE then
        if self.loginRoomTimeoutHandle_ then
            scheduler.unscheduleGlobal(self.loginRoomTimeoutHandle_)
            self.loginRoomTimeoutHandle_ = nil
        end
        self.isRoomEntered_ = true
        pack.tid = self.roomtid_
        pack.ip = self.roomip_
        pack.port = self.roomport_
        bm.EventCenter:dispatchEvent(nk.eventNames.LOGIN_DICE_SUCC)
    elseif cmd == PROTOCOL.SVR_PDENG_LOGIN_ROOM_OK then
        if self.loginRoomTimeoutHandle_ then
            scheduler.unscheduleGlobal(self.loginRoomTimeoutHandle_)
            self.loginRoomTimeoutHandle_ = nil
        end
        if self.isGrabDealer then
            self:sendRequestGrabDealerPdeng(nk.userData.money)
            self.isGrabDealer = false
        end
        self.isRoomEntered_ = true
        pack.tid = self.roomtid_
        pack.ip = self.roomip_
        pack.port = self.roomport_
        bm.EventCenter:dispatchEvent(nk.eventNames.LOGIN_PDENG_SUCC)
    elseif cmd == PROTOCOL.SVR_CMD_SERVER_UPGRADE then
        self.serverUpgradeRequestd_ = true
    elseif cmd == PROTOCOL.SVR_LOGOUT_SUCCESS then
        -- 通知登出成功
        self:unscheduleHeartBeat()
        bm.EventCenter:dispatchEvent(nk.eventNames.LOGOUT_ROOM_SUCC)
        if self.logoutRequested_ then
            self.logoutRequested_ = false
            self:disconnectRoom()
        elseif self.serverUpgradeRequestd_ then
            self.serverUpgradeRequestd_ = false
            self:disconnectRoom()
        end
        self.isRoomEntered_ = false
    elseif cmd == PROTOCOL.SVR_LOGOUT_SUCC_DICE then
        -- 通知登出成功
         self:unscheduleHeartBeat()
        bm.EventCenter:dispatchEvent(nk.eventNames.LOGOUT_DICE_SUCC)
        if self.logoutRequested_ then
            self.logoutRequested_ = false
            self:disconnectDice()
        elseif self.serverUpgradeRequestd_ then
            self.serverUpgradeRequestd_ = false
            self:disconnectDice()
        end
    elseif cmd == PROTOCOL.SVR_PDENG_LOGOUT_ROOM_OK then
        -- 通知登出成功
        self.logoutRequested_ = true
        self.isRoomEntered_ = false
        self.roomip_ = nil
        self.roomport = nil
        self.roomtid_ = nil
         self:unscheduleHeartBeat()
        bm.EventCenter:dispatchEvent(nk.eventNames.LOGOUT_PDENG_SUCC)
        if self.logoutRequested_ then
            self.logoutRequested_ = false
            self:disconnectPdeng()
        elseif self.serverUpgradeRequestd_ then
            self.serverUpgradeRequestd_ = false
            self:disconnectPdeng()
        end
    elseif cmd == PROTOCOL.SVR_LOGIN_FAIL then
        self.logger_:debugf("login error ==> %x", pack.errorCode)
        if self.loginRoomTimeoutHandle_ then
            scheduler.unscheduleGlobal(self.loginRoomTimeoutHandle_)
            self.loginRoomTimeoutHandle_ = nil
        end
        if pack.errorCode == consts.SVR_LOGIN_FAIL_CODE.INVALID_MTKEY or 
            pack.errorCode == consts.SVR_LOGIN_FAIL_CODE.ROOM_ERR or 
            pack.errorCode == consts.SVR_LOGIN_FAIL_CODE.RECONN_TO_OTHER_ROOM or 
            pack.errorCode == consts.SVR_LOGIN_FAIL_CODE.SOMEONE_ELSE_RELOGIN then
            self:disconnectRoom()
            self:disconnectDice()
            self:resetMtkeyAndSkey_()
        elseif pack.errorCode == consts.SVR_LOGIN_FAIL_CODE.WRONG_PASSWORD then -- 密码错误
            bm.EventCenter:dispatchEvent({name=nk.eventNames.LOGIN_ROOM_FAIL, pswError=true, silent=false})
            self:disconnectRoom()
            self:disconnectDice()
        else
            if pack.errorCode == consts.SVR_LOGIN_FAIL_CODE.SERVER_STOPPED then
                bm.EventCenter:dispatchEvent(nk.eventNames.SERVER_STOPPED)
                self:disconnectRoom()
                self:disconnectDice()
            elseif pack.errorCode == consts.SVR_LOGIN_FAIL_CODE.USER_BANNED then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "USER_BANNED"))
            elseif pack.errorCode == consts.SVR_LOGIN_FAIL_CODE.ROOM_FULL then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "ROOM_FULL"))
            elseif pack.errorCode == consts.SVR_LOGIN_FAIL_CODE.KICKED_ENTER_AGAIN then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("VIP", "KICKED_ENTER_AGAIN"))
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "LOGIN_ROOM_FAIL_MSG"))
            end
            -- 通知登录失败
            bm.EventCenter:dispatchEvent({name=nk.eventNames.LOGIN_ROOM_FAIL, silent=true})
            self:onFail_(consts.SVR_ERROR.ERROR_LOGIN_TIME_OUT)
        end
    elseif cmd == PROTOCOL.SVR_LOGIN_FAIL_DICE then
        self.logger_:debugf("login error ==> %x", pack.errorCode)
        if self.loginRoomTimeoutHandle_ then
            scheduler.unscheduleGlobal(self.loginRoomTimeoutHandle_)
            self.loginRoomTimeoutHandle_ = nil
        end
        if pack.errorCode == consts.SVR_LOGIN_FAIL_CODE.INVALID_MTKEY or 
            pack.errorCode == consts.SVR_LOGIN_FAIL_CODE.ROOM_ERR or 
            pack.errorCode == consts.SVR_LOGIN_FAIL_CODE.RECONN_TO_OTHER_ROOM or 
            pack.errorCode == consts.SVR_LOGIN_FAIL_CODE.SOMEONE_ELSE_RELOGIN then
            self:disconnectRoom()
            self:disconnectDice()
            self:resetMtkeyAndSkey_()
        elseif pack.errorCode == consts.SVR_LOGIN_FAIL_CODE.WRONG_PASSWORD then -- 密码错误
            bm.EventCenter:dispatchEvent({name=nk.eventNames.LOGIN_ROOM_FAIL, pswError=true, silent=false})
            self:disconnectRoom()
            self:disconnectDice()
        else
            if pack.errorCode == consts.SVR_LOGIN_FAIL_CODE.SERVER_STOPPED then
                bm.EventCenter:dispatchEvent(nk.eventNames.SERVER_STOPPED)
                self:disconnectRoom()
                self:disconnectDice()
            elseif pack.errorCode == consts.SVR_LOGIN_FAIL_CODE.USER_BANNED then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "USER_BANNED"))
            elseif pack.errorCode == consts.SVR_LOGIN_FAIL_CODE.ROOM_FULL then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("DICE", "ERROR_TIP_ROOM_FULL"))
            elseif pack.errorCode == consts.SVR_LOGIN_FAIL_CODE.NOT_ENOUGH_MONEY then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("DICE", "ERROR_TIP_MONEY_NOT_ENOUGH"))
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "LOGIN_ROOM_FAIL_MSG"))
            end
            bm.EventCenter:dispatchEvent({name=nk.eventNames.LOGIN_DICE_FAIL, silent=true})
            -- 通知登录失败
            self:onFail_(consts.SVR_ERROR.ERROR_LOGIN_TIME_OUT)
        end
    elseif cmd == PROTOCOL.SVR_PDENG_LOGIN_ROOM_FAIL then
        self.logger_:debugf("login pdeng error ==> %x", pack.errorCode)
        if self.loginRoomTimeoutHandle_ then
            scheduler.unscheduleGlobal(self.loginRoomTimeoutHandle_)
            self.loginRoomTimeoutHandle_ = nil
        end
        self.isGrabDealer = false
        if pack.errorCode == consts.SVR_LOGIN_FAIL_CODE.INVALID_MTKEY or 
            pack.errorCode == consts.SVR_LOGIN_FAIL_CODE.ROOM_ERR or 
            pack.errorCode == consts.SVR_LOGIN_FAIL_CODE.RECONN_TO_OTHER_ROOM or 
            pack.errorCode == consts.SVR_LOGIN_FAIL_CODE.SOMEONE_ELSE_RELOGIN then
            self:disconnectPdeng()
            self:resetMtkeyAndSkey_()
        else
            if pack.errorCode == consts.SVR_LOGIN_FAIL_CODE.SERVER_STOPPED then
                bm.EventCenter:dispatchEvent(nk.eventNames.SERVER_STOPPED)
                self:disconnectPdeng()
            elseif pack.errorCode == consts.SVR_LOGIN_FAIL_CODE.USER_BANNED then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "USER_BANNED"))
            elseif pack.errorCode == consts.SVR_LOGIN_FAIL_CODE.ROOM_FULL then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("DICE", "ERROR_TIP_ROOM_FULL"))
            elseif pack.errorCode == consts.SVR_LOGIN_FAIL_CODE.NOT_ENOUGH_MONEY then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("DICE", "ERROR_TIP_MONEY_NOT_ENOUGH"))
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "LOGIN_ROOM_FAIL_MSG"))
            end
            bm.EventCenter:dispatchEvent({name=nk.eventNames.LOGIN_PDENG_FAIL, silent=true})
            -- 通知登录失败
            self:onFail_(consts.SVR_ERROR.ERROR_LOGIN_TIME_OUT)
        end
    elseif cmd == PROTOCOL.SVR_CMD_SERVER_STOP then
        self:disconnectRoom()
        self:disconnectDice()
        self:disconnectPdeng()
        if self.loginTimeoutHandle_ then
            scheduler.unscheduleGlobal(self.loginTimeoutHandle_)
            self.loginTimeoutHandle_ = nil
        end
        bm.EventCenter:dispatchEvent(nk.eventNames.SERVER_STOPPED)
        self:onFail_(consts.SVR_ERROR.ERROR_LOGIN_TIME_OUT)
    elseif cmd == PROTOCOL.BROADCAST_PERSON then
        self.hallBroadcast_:onProcessPacket(pack)
    elseif cmd == PROTOCOL.BROADCAST_SYSTEM then
        self.hallBroadcast_:onProcessPacket(pack)
    end
end

-- 重置mtkey和skey
function HallSocket:resetMtkeyAndSkey_()
    bm.HttpService.POST(
        {
            mod = "user", 
            act = "setmtkey"
        }, 
        function (data)
            local retData = json.decode(data)
            if retData.mtkey then
                nk.userData.mtkey = retData.mtkey
                nk.userData.skey  = retData.skey
                bm.HttpService.setDefaultParameter("mtkey", retData.mtkey)
                nk.userDefault:setStringForKey(nk.cookieKeys.LOGIN_MTKEY, retData.mtkey)
                nk.userDefault:flush()
                bm.HttpService.setDefaultParameter("skey", retData.skey)

                if retData.tid and tonumber(retData.tid) > 0 then
                    -- 重新登录房间
                    nk.roomInfo = {tid=json.tid, ip=json.ip, port=json.port}
                    self:connectToRoom(retData.ip, tonumber(retData.port), tonumber(retData.tid))
                else
                    -- self:onFail_(consts.SVR_ERROR.ERROR_LOGIN_TIME_OUT)
                    bm.EventCenter:dispatchEvent({name=nk.eventNames.LOGIN_ROOM_FAIL, silent=false})
                end
            else
                -- self:onFail_(consts.SVR_ERROR.ERROR_LOGIN_TIME_OUT)
                bm.EventCenter:dispatchEvent({name=nk.eventNames.LOGIN_ROOM_FAIL, silent=false})
            end
        end, 
        function()
            bm.EventCenter:dispatchEvent({name=nk.eventNames.LOGIN_ROOM_FAIL, silent=false})
        end
    )
end

function HallSocket:onFail_(errorCode)
    bm.EventCenter:dispatchEvent({name=nk.eventNames.SVR_ERROR, data=errorCode})
end

return HallSocket