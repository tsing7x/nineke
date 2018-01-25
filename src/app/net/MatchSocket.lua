--
-- Author: Jonah0608@gmail.com
-- Date: 2015-06-27 10:41:03
-- 注意在比赛场中断线重练问题
--
local PROTOCOL = import(".MATCH_SOCKET_PROTOCOL")
local SocketBase = import(".SocketBase")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local MatchEventHandler = import("app.module.match.MatchEventHandler")

local MatchSocket = class("MatchSocket", SocketBase)

local MatchManager = import("app.module.match.MatchManager")
local LoadMatchControl = import("app.module.match.LoadMatchControl")

local CONN_TO_TEST = false
local MULTIPLE = 2
function MatchSocket:ctor()
    MatchSocket.super.ctor(self, "MatchSocket", PROTOCOL)
    self.multiple = MULTIPLE
    self.canDelayResume = true
    self.freeNum = ""  -- 免费场开场人数
    self.waitTimeList = {} -- 平均等待时间
    self.regCountList = {} -- 报名时候的人数
    self.catchMatchStartPack = {} -- 入场缓存包

    self.heartBeatCount_ = 0
    self.heartBeatDelay_ = 0
end

function MatchSocket:connectToMatch(ip, port)
    self.logger_:debugf("connectToMatch %s:%s", ip, port)
    if CONN_TO_TEST then
        ip = "192.168.203.211"
        port = 4703
    end
    self.ip_ = ip
    self.port_ = port
    self.isFromBack = false
    self:cleanConnectSchedulerId_()
    self.connectSchedulerHandle_ = scheduler.performWithDelayGlobal(handler(self, self.onConnectTimeout_), 5)
    self:connectDirect(self.ip_, self.port_)
end
-- 
function MatchSocket:disconnect(noEvent)
    self:cleanConnectSchedulerId_()
    self.logger_:debugf("disconnect %s" , noEvent)
    self.isFromBack = false
    self.isRoomEntered_ = false
    self.isLoginned_ = false
    self.receivedLevel = nil
    MatchSocket.super.disconnect(self, noEvent)
end

function MatchSocket:onConnectTimeout_()
    self:onFail_()
end

function MatchSocket:onAfterConnected()
    self.logoutRequested_ = false
    app.immediateDealMatch = true --立即比赛
    local userData = nk.userData

    if self.loginTimeoutHandle_ then
        scheduler.unscheduleGlobal(self.loginTimeoutHandle_)
        self.loginTimeoutHandle_ = nil
    end

    local report = self:getReportCurrentProxyFailFunction("login timeoutCount")
    self.loginTimeoutHandle_ = scheduler.performWithDelayGlobal(function()
        self.logger_:debug("login match timeout..")
        report()
        self.loginTimeoutHandle_ = nil
        self.socket_:disconnect()
    end, 3)

    local userInfo = {nick = nk.userData.nick,img = nk.userData.s_picture,mtkey = nk.userData.mtkey}

    self:sendLoginHall({
            uid    = userData.uid,
            info   = json.encode(userInfo)
        })

end

function MatchSocket:onClosed(evt)
    self.isRoomEntered_ = false
    self.isConnected_ = false
    self.isLoginned_ = false
    self.isFromBack = false
    self.receivedLevel = nil
    self:unscheduleHeartBeat()
    if self.shouldConnect_ then
        if not self:reconnect_() then
            self:onAfterConnectFailure()
            self:dispatchEvent({name=SocketBase.EVT_CONNECT_FAIL})
            self.logger_:debug("closed and reconnect fail")
            self:checkIsInMatchAndEnterHall()
        else
            self.logger_:debug("closed and reconnecting")
        end
    else
        self.logger_:debug("closed and do not reconnect")
        self:dispatchEvent({name=SocketBase.EVT_CLOSED})
    end
end

function MatchSocket:onClose(evt)
    self:unscheduleHeartBeat()
    if self.isFromBack==true then
        self.isFromBack = false
        -- 服务器主动断开连接
        local curScene = display.getRunningScene()
        if curScene.name == "MatchRoomScene" then  -- 房间内断线重连
            local isDisconnect = false   -- 已经主动断开连接 避免多次进入大厅场景
            if self.shouldConnect_==false and self.isConnecting_==false
                and self.isConnected_==false then
                isDisconnect = true  --以及在别处disconnect了，有可能已经已经进入大厅，不能多次进入报错
            end
            self:disconnect(true)
            if isDisconnect==false then
                curScene:setServerIsClosed() -- dispose执行
                self:enterHall()
                -- 弹窗引导 重新进入比赛  在 match场景onclean中有
            end
        end
    end
end

function MatchSocket:checkIsInMatchAndEnterHall()
    -- 在比赛场中出现了异常
    local curScene = display.getRunningScene()
    if curScene.name == "MatchRoomScene" then
        self:disconnect(true)
        nk.match.MatchModel:setCancelRegistered(self.currentRoomMatchLevel,true)
        curScene:setServerIsClosed() -- dispose执行
        self:enterHall()
        -- 弹窗引导 重新进入比赛  在 match场景onclean中有
    end
end

function MatchSocket:enterHall()
    display.addSpriteFrames("hall_texture.plist", "hall_texture.png", function()
        local HallController = import("app.module.hall.HallController")
        app:enterHallScene({HallController.MAIN_HALL_VIEW})
    end)
end

function MatchSocket:buildHeartBeatPack()
    return self:createPacketBuilder(PROTOCOL.CLISVR_HEART_BEAT):build()
end

function MatchSocket:onHeartBeatTimeout(timeoutCount)
    bm.DataProxy:setData(nk.dataKeys.SIGNAL_STRENGTH, 0)
    self.heartBeatCount_ = self.heartBeatCount_ + 1
    self.heartBeatDelay_ = self.heartBeatDelay_ + self.heartBeatTimeout_
    if timeoutCount >= 3 then
        self.socket_:disconnect()
        self.receivedLevel = nil
    end
end

function MatchSocket:onHeartBeatReceived(delaySeconds)
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
    self.heartBeatCount_ = self.heartBeatCount_ + 1
    self.heartBeatDelay_ = self.heartBeatDelay_ + delaySeconds
    bm.DataProxy:setData(nk.dataKeys.SIGNAL_STRENGTH, signalStrength)
end

function MatchSocket:onAfterConnectFailure()
    self:onFail_()
end

-- some send method
function MatchSocket:sendLoginHall(params)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_LOGIN_HALL)
        :setParameter("uid", params.uid)
        :setParameter("info", params.info)
        :build()
    self:send(pack)
end

function MatchSocket:sendReg(params)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_REGISTER)
        :setParameter("matchlevel", params.matchlevel)
        :setParameter("userinfo", params.userinfo)
        :build()
    self:send(pack)
end

function MatchSocket:sendGetOnlineCount(params)
    if not params or #params<1 then return end
    local list = {}
    for k,v in pairs(params) do
        table.insert(list,{level=v})
    end
    local pack = self:createPacketBuilder(PROTOCOL.CLI_GET_COUNT)
        :setParameter("list",list)
        :build()
    self:send(pack)
end


function MatchSocket:sendCancelReg(params)
    if not params.matchid or params.matchid=="1" then params.matchid="" end
    local pack = self:createPacketBuilder(PROTOCOL.CLI_CANCEL_REGISTER)
        :setParameter("matchlevel", params.matchlevel)
        :setParameter("matchid", params.matchid)
        :build()
    self:send(pack)
end

function MatchSocket:sendJoinGame(params)
    if not params.matchid or params.matchid=="1" then params.matchid="" end
    print("params.matchid=="..params.matchid)
    app.immediateDealMatch = false
    -- 清楚缓存包
    self.catchMatchStartPack[params.matchlevel] = nil
    local pack = self:createPacketBuilder(PROTOCOL.CLI_JOIN_GAME)
        :setParameter("level", params.matchlevel)
        :setParameter("matchid", params.matchid)
        :build()
    self:send(pack)
    self.outData_ = nil
end

function MatchSocket:resume()
    self.canDelayResume = true
    MatchSocket.super.resume(self)
end

function MatchSocket:sendLogin(params)
    -- self.delayPackCache_ = nil  --清空之前所有数据包 假如有颁奖怎么办
    self.canDelayResume = false
    -- 保存当前房间的比赛信息
    self.currentRoomMatchLevel = params.matchlevel
    self.currentRoomMatchId = params.matchid
    -- 设置荷官
    nk.gameState.roomLevel = "middle"
    
    LoadMatchControl:getInstance():getMatchById(params.matchlevel,function(matchData)
        local style = matchData and matchData.style and tonumber(matchData.style) or 1
        nk.gameState.roomLevel = nk.gameState.RoomLevel[style] or "middle"
    end)
    self:pause()

    -- 附加信息
    local vipconfig = self:getVipConfig_()
    local userInfo = {}
    if vipconfig then
        userInfo.vipmsg = vipconfig
    end

    self.tid_ = params.tid;
    local pack = self:createPacketBuilder(PROTOCOL.CLI_LOGIN)
        :setParameter("tid", params.tid)
        :setParameter("matchid",params.matchid)
        :setParameter("uid", params.uid)
        :setParameter("mtkey", params.mtkey)
        :setParameter("img", params.img)
        :setParameter("giftId", params.giftId)
        :setParameter("nick",params.nick)
        :setParameter("gender",params.gender)
        :setParameter("userInfo",json.encode(userInfo))
        :build();
    self:send(pack)
end

--yk
function MatchSocket:getVipConfig_()
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

function MatchSocket:sendLogout(outData)
    self.outData_ = outData
    if self.isRoomEntered_ then  -- 已经退出去了 不再发送
        self.logoutRequested_ = true
        self:send(self:createPacketBuilder(PROTOCOL.CLI_LOGOUT):build())
    elseif self.outData_ then
        self:sendJoinGame(self.outData_)
    end
end

function MatchSocket:sendSitDown(seatId, buyIn)
    seatId =  seatId/MULTIPLE
    -- local pack = self:createPacketBuilder(PROTOCOL.CLI_SIT_DOWN)
    --     :setParameter("seatId", seatId)
    --     :setParameter("buyIn", buyIn)
    --     :build()
    -- self:send(pack)
end

function MatchSocket:sendAutoBuyin()
    -- self:send(self:createPacketBuilder(PROTOCOL.CLI_SET_AUTO_SIT):build())
end

function MatchSocket:sendStandUp()
    self:send(self:createPacketBuilder(PROTOCOL.CLI_STAND_UP):build())
end

function MatchSocket:showHandcard()
    self:send(self:createPacketBuilder(PROTOCOL.CLI_SHOW_HAND_CARD):build())
end

function MatchSocket:sendBet(betType, betChips)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_BET)
        :setParameter("betType", betType)
        :setParameter("betChips", betChips)
        :build()
    self:send(pack)
end

function MatchSocket:sendAddFriend(fromSeatId, toSeatId)
    fromSeatId = fromSeatId/MULTIPLE
    toSeatId = toSeatId/MULTIPLE
    local pack = self:createPacketBuilder(PROTOCOL.CLI_ADD_FRIEND)
        :setParameter("fromSeatId", fromSeatId)
        :setParameter("toSeatId", toSeatId)
        :build()
    self:send(pack)
end

function MatchSocket:sendSendChips(fromSeatId, toSeatId, chips)
    fromSeatId = fromSeatId/MULTIPLE
    toSeatId = toSeatId/MULTIPLE
    local pack = self:createPacketBuilder(PROTOCOL.CLI_SEND_CHIPS)
        :setParameter("fromSeatId", fromSeatId)
        :setParameter("toSeatId", toSeatId)
        :setParameter("chips", chips)
        :build()
    self:send(pack)
end


--给荷官小费
function MatchSocket:sendDealerChip()
    self:send(self:createPacketBuilder(PROTOCOL.CLI_CMD_SEND_DEALER_MONEY):build())
end

function MatchSocket:sendSrvChangeHead(uid, picUrl)
    self:sendRoomBroadCast_(uid, json.encode({type=2, url=picUrl}))
end

--广播赠送礼物
function MatchSocket:sendPresentGift(giftId, fromUid, toUidArr)
    self:sendRoomBroadCast_(fromUid, json.encode({type=3, giftId=giftId, toUidArr=toUidArr}))
end

--广播设置礼物
function MatchSocket:sendSetGift(giftId, uid)
    self:sendRoomBroadCast_(uid, json.encode({type=4, giftId=giftId}))
end

-- 获取当前场次人数 
function MatchSocket:getRegedCount(level)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_GET_REGED_COUNT)
        :setParameter("matchlevel", level)
        :build()
    self:send(pack)
end

function MatchSocket:setPushInfo(matchlevel,open)
    if not matchlevel or not open then return end
    local pack = self:createPacketBuilder(PROTOCOL.SET_PUSH_INFO)
        :setParameter("matchlevel",matchlevel)
        :setParameter("open",open)
        :build()
    self:send(pack)
end
function MatchSocket:getPushInfo(matchlevel)
    if not matchlevel then return end
    local pack = self:createPacketBuilder(PROTOCOL.GET_PUSH_INFO)
        :setParameter("matchlevel",matchlevel)
        :build()
    self:send(pack)
end
function MatchSocket:sendExpression(expressionType, expressionId)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_SEND_EXPRESSION)
        :setParameter("expressionType", expressionType)
        :setParameter("expressionId", expressionId)
        :build()
    self:send(pack)
end

function MatchSocket:sendSendHddj(fromSeatId, toSeatId, hddjId)
    fromSeatId = fromSeatId/MULTIPLE
    toSeatId = toSeatId/MULTIPLE
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
function MatchSocket:sendRoomBroadCast_(param, content)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_SEND_ROOM_BROADCAST)
        :setParameter("tid", self.tid_)
        :setParameter("param", param)
        :setParameter("content", content)
        :build()
    self:send(pack)
end

function MatchSocket:sendChatMsg(message)
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

function MatchSocket:sendRebuy(type)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_CMD_REBUY)
        :setParameter("rebuy_type", type)
        :build()
    self:send(pack)
end

function MatchSocket:getMatchStatus(matchlevel,matchid)
    local pack = self:createPacketBuilder(PROTOCOL.CLI_GET_MATCH_STATUS)
        :setParameter("matchlevel", matchlevel)
        :build()
        self:send(pack)
    -- -- 测试
    -- pack:setParameter("matchlevel", matchlevel)
    -- local buf = pack:build()
    -- -- local list = {11,12,41,42,21,31}
    -- local list = {51,12,41,42,21,31,53,54,52}
    -- for i=1,#list do
    --     buf:setPos(buf:getLen() + 1)
    --     buf:writeStringBytes("ES")                    -- ES
    --     buf:writeUShort( 0x106 )                    -- 命令字
    --     buf:writeUShort(1)
    --     buf:writeUShort(4)
    --     buf:writeInt(list[i])
    -- end
    -- self:send(buf)
    
end

-- receiver method
function MatchSocket:onProcessPacket(pack)
    local cmd = pack.cmd
    self.isHasNetwork_ = false  --标记是否有网络，网络不好导致登录失败
    if cmd == PROTOCOL.SVR_CMD_USER_MATCH_SCORE then
        nk.match.MatchModel:lastMatchInfo(pack.selfRank,pack.totalCount)
        nk.match.MatchModel:setCancelRegistered(self.currentRoomMatchLevel,true)
        -- 
        bm.EventCenter:dispatchEvent({name=nk.eventNames.SVR_CMD_USER_MATCH_SCORE})
    elseif cmd == PROTOCOL.SVR_REGISTER_RET then
        if pack.ret == 0 or pack.ret == 1 then
            -- nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "REGISTERSUCC"))
            nk.match.MatchModel:setRegistered(pack.matchlevel, pack.matchid)
            self.waitTimeList[pack.matchlevel] = os.time()
            self.regCountList[pack.matchlevel] = nk.match.MatchModel[pack.matchlevel] and (nk.match.MatchModel[pack.matchlevel]-1) or 0
            if self.catchMatchStartPack then
                self.catchMatchStartPack[pack.matchlevel] = nil
            end
        -- elseif pack.ret == 1 then
            -- nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "REGISTER_RET1"))
        elseif pack.ret == 2 then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "REGISTER_RET2"))
        elseif pack.ret == 3 then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "REGISTER_RET3"))
        elseif pack.ret == 4 then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "REGISTER_RET4"))
        elseif pack.ret == 5 then
            -- 比赛券
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "NOTENOUGHGAMECOUPON"))
        elseif pack.ret == 6 then
            -- 金券
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "NOTENOUGHGOLDCOUPON"))
        elseif pack.ret == 8 then
            -- 筹码不足
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "NOTENOUGHCHIPS"))
        elseif pack.ret == 9 then
            -- 没有比赛，禁止报名
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "ROOMDEFEND1"))
        elseif pack.ret == 10 then
            -- 系统维护，禁止报名
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "ROOMDEFEND"))
        elseif pack.ret == 101 then
            -- 现金币不足
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "NOTENOUGHSCORE"))
        elseif pack.ret == 102 then
            -- 黄金币不足
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "NOTENOUGHGOLDCOIN"))
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "REGISTERFAIL"))
        end
        if pack.ret ~= 0 and pack.ret ~= 1 then
            -- 刷新显示界面
            nk.match.MatchModel:setCancelRegistered(pack.matchlevel)
            if self.catchMatchStartPack then
                self.catchMatchStartPack[pack.matchlevel] = nil
            end
        end
    elseif cmd == PROTOCOL.SVR_CANCEL_REGISTER_RET then
        if pack.ret == 0 or pack.ret == 1 then
            -- nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "UNREGISTERSUCC"))
            -- 重置
            nk.match.MatchModel:setCancelRegistered(pack.matchlevel)
            if self.catchMatchStartPack then
                self.catchMatchStartPack[pack.matchlevel] = nil
            end
        else
            -- 细节
            -- 1--比赛不存在，2--比赛状态错误，无法取消,3--请求比赛等级错误,4--写入缓存失败（门票报名的）
            -- if pack.ret == 1 or pack.ret == 2 or pack.ret == 3 then
                -- nk.PopupManager:removeAllPopup()
                -- nk.match.MatchModel:setCancelRegistered(pack.matchlevel)
            -- end
            -- nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "UNREGISTERFAIL"))
        end
    elseif cmd == PROTOCOL.ON_GET_PUSH_INFO then
        bm.EventCenter:dispatchEvent({name="ABOUT_MATCH_PUSH",data=pack})
    elseif cmd == PROTOCOL.SVR_LOGIN_SUCCESS_HALL then
        self.catchMatchStartPack = {} -- 入场缓存包
        self:cleanConnectSchedulerId_()
        if self.loginTimeoutHandle_ then
            scheduler.unscheduleGlobal(self.loginTimeoutHandle_)
            self.loginTimeoutHandle_ = nil
        end
        self:scheduleHeartBeat(PROTOCOL.CLISVR_HEART_BEAT, 10, 2)

        self.isLoginned_ = true
        self.loginPacket_ = pack
        self.serverTime = pack.time
        self.clientTime = os.time()
        -- 派发事件
        self.receivedLevel = {}
        self.isSendRelogin = false
        bm.EventCenter:dispatchEvent(nk.eventNames.LOGIN_MATCH_SUCC)
        -- 获取状态
        local matchIds = nk.match.MatchModel.openMatchIds
        self.loginPacket_.sendNum = #matchIds
        self.loginPacket_.acceptNum = 0
        for i=1,#matchIds do
            self:getMatchStatus(matchIds[i])
        end
        self.heartBeatCount_ = 0
        self.heartBeatDelay_ = 0
        -- -- self:getMatchStatus(51)
        -- self:getMatchStatus(11)
    elseif cmd == PROTOCOL.SVR_LOGIN_FAIL_HALL then --有网络，但连接失败
        self.isHasNetwork_ = true
        self.isLoginned_ = false
    elseif cmd == PROTOCOL.SVR_JOIN_GAME then
        if self.catchMatchStartPack and self.catchMatchStartPack[pack.matchlevel] then
            -- 当前场次还没有处理
            return;
        end
        if self.waitTimeList and self.waitTimeList[pack.matchlevel] then
            local prevTime = self.waitTimeList[pack.matchlevel]
            self.waitTimeList[pack.matchlevel] = nil
            local count = self.regCountList[pack.matchlevel] or 0
            self.regCountList[pack.matchlevel] = nil
            if device.platform == "android" or device.platform == "ios" then
                cc.analytics:doCommand{
                    command = "eventCustom",
                    args = {
                        eventId = "match"..pack.matchlevel.."_wait_time",
                        attributes = "regCount,"..count,
                        counter = os.time() - prevTime
                    }
                }
            end
        end
        -- 报名了但是场次停掉了 入场后连接关闭掉了 --MatchManager:onExitMatch()
        local matchid = pack.matchid
        if not matchid or matchid==0 or matchid=="" then
            matchid = "1"
        end
        if not nk.match.MatchModel.regList then
            nk.match.MatchModel.regList = {}
        end
        nk.match.MatchModel.regList[pack.matchlevel] = matchid

        -- 缓存开始包
        self.catchMatchStartPack[pack.matchlevel] = {
            time = os.time(),
            pack = pack
        },
        nk.match.MatchModel:startDownTime(pack.joinTime)
        bm.EventCenter:dispatchEvent({name=nk.eventNames.MATCH_STARTING,data=pack}) -- 弹窗比赛开始
        -- self:sendJoinGame({matchlevel = nk.match.MatchModel.matchlevel_,matchid = nk.match.MatchModel.matchid_})
    elseif cmd == PROTOCOL.SVR_JOIN_GAME_SUCC then
        -- 清楚缓存包
        self.catchMatchStartPack[pack.matchlevel] = nil
        -- 操作移植到control处理
        bm.EventCenter:dispatchEvent({name=nk.eventNames.MATCH_JOIN_ERROR,data=pack}) -- 弹窗比赛开始
        -- 正在进入的过程中有其他比赛正好开始了 进入失败 要验证 成功的话会在每个场景的cleanUp处理
        if pack.ret~=0 then
            app:dealEnterMatch()-- 坑爹
        end
    elseif cmd == PROTOCOL.SVR_ADD_FRIEND or cmd == PROTOCOL.SVR_SEND_CHIPS_SUCCESS or
           cmd == PROTOCOL.SVR_SEND_HDDJ or cmd == PROTOCOL.SVR_CMD_SEND_DEALER_CHIP_SUCC then
        pack.fromSeatId = pack.fromSeatId*MULTIPLE
        pack.toSeatId = pack.toSeatId*MULTIPLE
    elseif cmd == PROTOCOL.SVR_SIT_DOWN or cmd == PROTOCOL.SVR_STAND_UP or
           cmd == PROTOCOL.SVR_BET_SUCCESS or cmd == PROTOCOL.SVR_BET_FAIL or
           cmd == PROTOCOL.SVR_SHOW_HANDCARD or cmd == PROTOCOL.SVR_TURN_TO_BET or
           cmd == PROTOCOL.SVR_SEND_EXPRESSION then
        pack.seatId = pack.seatId*MULTIPLE
    elseif cmd == PROTOCOL.SVR_GAME_OVER then
        local playerCardsList = pack.playerCardsList
        for k,v in pairs(playerCardsList) do
            v.seatId = v.seatId*MULTIPLE
        end
        local potsList = pack.potsList
        for k,v in pairs(potsList) do
            v.seatId = v.seatId*MULTIPLE
        end
    elseif cmd == PROTOCOL.SVR_GAME_START then
        pack.dealerSeatId = pack.dealerSeatId*MULTIPLE
        local playerList = pack.playerList
        for k,v in pairs(playerList) do
            v.seatId = v.seatId*MULTIPLE
        end
    elseif cmd == PROTOCOL.SVR_LOGIN_SUCCESS then
        pack.dealerSeatId = pack.dealerSeatId*MULTIPLE
        if pack.bettingSeatId>0 then
            pack.bettingSeatId = pack.bettingSeatId*MULTIPLE
        end
        local playerList = pack.playerList
        for k,v in pairs(playerList) do
            v.seatId = v.seatId*MULTIPLE
        end

        self.outData_ = nil
        local curScene = display.getRunningScene()
        if not self.isRoomEntered_ then
            if curScene.name == "MatchRoomScene" then  -- 房间内断线重连 直接resume 无需切换场景
                self:resume()
            else
                nk.match.MatchModel:startEnterMatchRoom() -- 直接入场
                --比赛时屏蔽多余的提示信息
                -- nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "STARTINGTIP"))
            end
            self.isRoomEntered_ = true
        else -- 房间内重复登录卡住的BUG
            if curScene.name == "MatchRoomScene" then
                self:resume()
            end
        end
        bm.EventCenter:dispatchEvent(nk.eventNames.LOGIN_MATCH_ROOM_SUCC)
    elseif cmd == PROTOCOL.SVR_LOGIN_FAIL then
        if pack.errCode == 11 then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "LOGIN_ROOM_FAIL"))
        end
        bm.EventCenter:dispatchEvent(nk.eventNames.LOGIN_MATCH_ROOM_FAIL)
        self:resume()
        self:checkIsInMatchAndEnterHall()
    elseif cmd == PROTOCOL.SVR_LOGOUT_SUCCESS then
        self.isRoomEntered_ = false
        if self.outData_ then
            self:sendJoinGame(self.outData_)
        end
    elseif cmd == PROTOCOL.SVR_CMD_MATCH_REWARD then
        -- 延后颁奖 MatchModel内部处理
        -- nk.match.MatchModel:handleMatchAward(pack.type,pack.info)
        -- 清除105 去报没有
        local info = pack.info
        if info and self.catchMatchStartPack then
            local retData = json.decode(info)
            if retData.matchlevel then
                self.catchMatchStartPack[retData.matchlevel] = nil
            end
        end
        self.matchRewardPack = pack  -- 缓存包
    elseif cmd == PROTOCOL.SVR_REGISTER_COUNT then
        nk.match.MatchModel:saveRegCount(pack)
        bm.EventCenter:dispatchEvent({name=nk.eventNames.MATCH_REG_COUNT,data=pack}) -- 弹窗比赛开始
    elseif cmd == PROTOCOL.SVR_REGED_COUNT then
        nk.match.MatchModel:saveRegCount(pack)
        bm.EventCenter:dispatchEvent({name=nk.eventNames.MATCH_REG_COUNT,data=pack}) -- 弹窗比赛开始
    elseif cmd== PROTOCOL.SVR_MATCH_STATUS then
        if not self.receivedLevel then
            self.receivedLevel = {}
        end
        self.receivedLevel[pack.matchlevel] = true
        if pack.matchid and pack.matchid~="" then
            nk.match.MatchModel:setRegistered(pack.matchlevel,pack.matchid,true)
        elseif pack.status>-1 then -- 定时赛 如果没开赛 matchid=""
            nk.match.MatchModel:setRegistered(pack.matchlevel,"",true)
        else
            nk.match.MatchModel:setCancelRegistered(pack.matchlevel,true)
        end
        bm.EventCenter:dispatchEvent({name="GET_ONE_MATCH_STATUS",data=pack}) -- 比赛状态
        --[[
            包的格式
            matchlevel = 10
            tid = 10
            [1] = {
                ret         : int(结果值：0--成功，1--比赛不存在，3--等级错误)
                matchlevel  : int(比赛等级)
                matchid     : string(比赛ID)
                status      : int(比赛状态，-1 --未报名，0--等待报名；1--正在入场；2--比赛中；3--比赛结束)
            }
        --]]
        self.loginPacket_.acceptNum = self.loginPacket_.acceptNum + 1
        self.loginPacket_[self.loginPacket_.acceptNum] = pack
        if self.loginPacket_.acceptNum>=self.loginPacket_.sendNum then
            if not self.isSendRelogin then
                local selectPack = nil
                local tempPack = nil
                local haveMatchStatus = false
                if self.loginPacket_.matchlevel and self.loginPacket_.matchlevel>0 
                and self.loginPacket_.tid and self.loginPacket_.tid>0 then
                    for i=1,self.loginPacket_.sendNum,1 do
                        tempPack = self.loginPacket_[i]
                        if tempPack.matchlevel==self.loginPacket_.matchlevel then
                            haveMatchStatus = true
                            self:sendLogin({
                                tid = self.loginPacket_.tid,
                                matchlevel = tempPack.matchlevel,
                                matchid = tempPack.matchid,
                                uid = nk.userData.uid,
                                mtkey  = nk.userData.mtkey,
                                img    = nk.userData.s_picture,
                                giftId = nk.userData.user_gift,
                                nick   = nk.userData.nick,
                                gender = nk.userData.sex
                            })
                            break
                        end
                    end
                else -- 遍历哪个正在开赛
                    local prevStatus = -1
                    local prevLevel = -1
                    for i=1,self.loginPacket_.sendNum,1 do
                        tempPack = self.loginPacket_[i]
                        if tempPack.matchid and (tempPack.status==1 or tempPack.status==2) then
                            if tempPack.status>prevStatus then  -- 比赛中的大于正在入场的
                                selectPack = tempPack
                                prevStatus = tempPack.status
                                prevLevel = tempPack.matchlevel
                            elseif tempPack.status==prevStatus then -- 同时两场开赛入场，优先进入更加高级的场次
                                if tempPack.matchlevel>prevLevel then
                                    selectPack = tempPack
                                    prevStatus = tempPack.status
                                    prevLevel = tempPack.matchlevel
                                end
                            end
                        end
                    end
                end
                -- bm.EventCenter:dispatchEvent(nk.eventNames.LOGIN_MATCH_SUCC)
                if selectPack then
                    local curScene = display.getRunningScene()
                    if curScene.name == "MatchRoomScene" then  -- 房间内断线重连(正在换桌状态)
                        if selectPack.status==1 then
                            -- 此时有可能收到比赛结束了
                            if curScene.controller and curScene.controller.clearChangeMatchRoomId then
                                curScene.controller:clearChangeMatchRoomId()
                            end
                            self:sendJoinGame({matchlevel = selectPack.matchlevel,matchid = selectPack.matchid})
                        else -- 如果在换桌中tid被清掉了...
                            if not self.delayPackCache_ then
                                self.delayPackCache_ = {}
                            end
                            table.insert(self.delayPackCache_,{cmd = PROTOCOL.SVR_CMD_CHANGE_ROOM})
                        end
                    else
                        -- 弹窗引导
                        nk.match.MatchModel:startDownTime(10)
                        bm.EventCenter:dispatchEvent({name=nk.eventNames.MATCH_STARTING,data={cmd = PROTOCOL.SVR_JOIN_GAME,matchlevel=selectPack.matchlevel,matchid=selectPack.matchid,joinTime = 10}}) -- 弹窗比赛开始
                    end
                elseif haveMatchStatus==false then  -- 房间场景实际已经比赛结束
                    -- 没有报名直接关闭连接
                    -- 检测比赛报名情况 连接比赛服务器
                    -- 关闭不必要的连接
                    local matchStatus = nk.userDefault:getIntegerForKey(nk.cookieKeys.IS_JOIN_MATCH..nk.userData.uid,0)
                    if matchStatus~=1 then
                        local curScene = display.getRunningScene()
                        if curScene.name == "RoomScene" then
                            self:disconnect(true)
                            -- 大厅中的自己关闭掉
                            -- 比赛中的在checkIsInMatchAndEnterHall关闭掉
                        end
                    end
                    self:checkIsInMatchAndEnterHall()
                end
            end
            bm.EventCenter:dispatchEvent({name="GET_ALL_MATCH_STATUS",data=nil}) -- 比赛状态
        else
            -- 优先重练
            if self.loginPacket_.matchlevel and self.loginPacket_.matchlevel>0 
            and self.loginPacket_.tid and self.loginPacket_.tid>0 then
                if pack.matchlevel==self.loginPacket_.matchlevel then
                    self.isSendRelogin = true
                    self:sendLogin({
                        tid = self.loginPacket_.tid,
                        matchlevel = pack.matchlevel,
                        matchid = pack.matchid,
                        uid = nk.userData.uid,
                        mtkey  = nk.userData.mtkey,
                        img    = nk.userData.s_picture,
                        giftId = nk.userData.user_gift,
                        nick   = nk.userData.nick,
                        gender = nk.userData.sex
                    })
                end
            else
                local curScene = display.getRunningScene()
                if curScene.name == "MatchRoomScene" then  -- 房间内断线重连(正在换桌状态)
                    if self.currentRoomMatchLevel == pack.matchlevel and
                    pack.matchid == "" and pack.status==-1 then --当前场次已经结束
                        self:checkIsInMatchAndEnterHall()
                    end
                end
            end
        end
        -- -- ret         : int(结果值：0--成功，1--比赛不存在，3--等级错误)
        -- -- matchlevel  : int(比赛等级)
        -- -- matchid     : string(比赛ID)
        -- -- status      : int(比赛状态，0--等待报名；1--正在入场；2--比赛中；3--比赛结束)
        -- local curScene = display.getRunningScene()
        -- if pack.ret==0 then
        --     if pack.status==0 then  -- 不用处理
        --         print("baomingzhong....")
        --     elseif pack.status==1 or pack.status==2 then-- 进入游戏正好比赛开始了
        --         if curScene.name == "MatchRoomScene" then  -- 房间内断线重连(正在换桌状态)
        --             -- 模拟 SVR_CMD_CHANGE_ROOM
        --             -- self:dispatchEvent({name=PROTOCOL.SVR_CMD_CHANGE_ROOM})
        --             table.insert(nk.socket.RoomSocket.delayPackCache_,{cmd = PROTOCOL.SVR_CMD_CHANGE_ROOM})
        --         else   -- 弹窗引导
        --             nk.match.MatchModel:startDownTime(10)
        --             bm.EventCenter:dispatchEvent({name=nk.eventNames.MATCH_STARTING,data={cmd = PROTOCOL.SVR_JOIN_GAME,matchlevel=pack.matchlevel,matchid=pack.matchid,joinTime = 10}}) -- 弹窗比赛开始
        --         end
        --     -- self:sendJoinGame({matchlevel = pack.matchlevel,matchid = pack.matchid})
        --     --[[
        --     elseif pack.status==2 then
        --         local curScene = display.getRunningScene()
        --         if curScene.name ~= "HallScene" then
        --             self:enterHall()
        --         end
        --         nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "JOINMATCHFAILTIPS"))
        --         --]]
        --     elseif pack.status==3 then
        --         -- local curScene = display.getRunningScene()
        --         -- if curScene.name ~= "HallScene" then
        --         --     self:enterHall()
        --         -- end
        --         -- nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "JOINMATCHFAILTIPS"))
        --         self:checkIsInMatchAndEnterHall()
        --     end
        -- else
        --     self:checkIsInMatchAndEnterHall()
        -- end
    elseif cmd == PROTOCOL.SVR_CANCEL_REGISTER then
        -- 清楚缓存包
        self.catchMatchStartPack[pack.matchlevel] = nil
        nk.match.MatchModel:setCancelRegistered(pack.matchlevel,true)
    elseif cmd == PROTOCOL.UPDATE_USER_PROP then
        nk.UserInfoChangeManager:updateUserProp(pack.count);
        -- local list = pack.count
        -- local prop = nil
        -- for i=1,#list,1 do
        --     prop = list[i]
        --     if prop.pid==2 then
        --         nk.userData.changeGoldCoupon = tonumber(prop.num) - tonumber(nk.userData.goldCoupon)
        --         nk.userData.goldCoupon = prop.num
        --         nk.userData.changeGoldCoupon = nil
        --     elseif prop.pid==3 then
        --         nk.userData.changeGameCoupon = tonumber(prop.num) - tonumber(nk.userData.gameCoupon)
        --         nk.userData.gameCoupon = prop.num
        --         nk.userData.changeGameCoupon = nil
        --     elseif prop.pid==4 then
        --         nk.userData.changeMoney = tonumber(prop.money) - tonumber(nk.userData.money)
        --         prop.num = prop.money
        --         nk.userData.money = prop.num
        --         nk.userData.changeMoney = nil
        --     end
        -- end
        -- 刷新界面
        -- bm.EventCenter:dispatchEvent({name = MatchEventHandler.MATCH_AWARD})
    elseif cmd == PROTOCOL.SVR_CMD_REBUYRESULT then
        if pack.err==0 then
            pack.count = -1*pack.count
            nk.UserInfoChangeManager:updateUserProp_change({[1]=pack})
        end
    end
end

function MatchSocket:onFail_(silent)
    self.isMatchEntered_ = false
    self:cleanConnectSchedulerId_()
    print("match socket onFail_")
    local connInfo = {ip=self.ip_, port=self.port_}
    self:disconnect(true)
    if self.isRoomEntered_ then
    else
        bm.EventCenter:dispatchEvent({name=nk.eventNames.LOGIN_MATCH_FAIL, data = connInfo, silent = silent, isHasNetwork = self.isHasNetwork_})
    end
end

function MatchSocket:cleanConnectSchedulerId_()
    if self.connectSchedulerHandle_ then
        scheduler.unscheduleGlobal(self.connectSchedulerHandle_)
        self.connectSchedulerHandle_ = nil
    end
end

return MatchSocket