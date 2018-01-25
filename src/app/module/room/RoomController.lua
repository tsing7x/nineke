--
-- 房间控制器
-- Author: tony
-- Date: 2014-07-08 11:43:07
--

local RoomController = class("RoomController")


local RoomModel        = import(".model.RoomModel")
local SeatManager      = import(".SeatManager")
local DealerManager    = import(".DealerManager")
local DealCardManager  = import(".DealCardManager")
local LampManager      = import(".LampManager")
local ChipManager      = import(".ChipManager")
local AnimManager      = import(".AnimManager")
local OperationManager = import(".OperationManager")
local BetChipView      = import(".views.BetChipView")
local UserCrash        = import("app.module.room.userCrash.UserCrash")
local NewUserCrash     = import("app.module.room.userCrash.NewUserCrash")
local StorePopup       = import("app.module.newstore.StorePopup")
local logger           = bm.Logger.new("RoomController")
local MatchStartPopup  = import("app.module.match.MatchStartPopup")
local FirstPayPopup    = import("app.module.firstpay.FirstPayPopup")
local GuidePayPopup    = import("app.module.firstpay.GuidePayPopup")


RoomController.EVT_PACKET_RECEIVED = nk.socket.RoomSocket.EVT_PACKET_RECEIVED

local PACKET_PROC_FRAME_INTERVAL = 4

function RoomController:ctor(scene)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

    local ctx = {}
    ctx.roomController = self
    ctx.scene = scene
    ctx.model = RoomModel.new(ctx)
    ctx.controllerEventProxy = cc.EventProxy.new(self, scene)
    ctx.schedulerPool = bm.SchedulerPool.new()
    ctx.sceneSchedulerPool = bm.SchedulerPool.new()
    ctx.gameSchedulerPool = bm.SchedulerPool.new()

    ctx.seatManager = SeatManager.new(ctx, false)

    ctx.dealerManager = DealerManager.new(ctx, nk.userData.dealerId, false)

    ctx.dealCardManager = DealCardManager.new()
    ctx.lampManager = LampManager.new()
    ctx.chipManager = ChipManager.new()
    ctx.animManager = AnimManager.new()
    ctx.oprManager = OperationManager.new()

    ctx.export = function(target)
        if target ~= ctx.model then
            target.ctx = ctx    --不是model元素 都绑定一个ctx
            for k, v in pairs(ctx) do
                if k ~= "export" and v ~= target then --每个ctx的元素也保存一份，但不保存export函数，自己本身也不保存
                    target[k] = v
                end
            end
        else
            rawset(target, "ctx", ctx) --设置ctx.model.ctx = ctx
            for k, v in pairs(ctx) do
                if k ~= "export" and v ~= target then
                    rawset(target, k, v)
                end
            end
        end
        return target
    end

    ctx.export(self)
    ctx.export(ctx.seatManager)
    ctx.export(ctx.dealerManager)
    ctx.export(ctx.dealCardManager)
    ctx.export(ctx.lampManager)
    ctx.export(ctx.chipManager)
    ctx.export(ctx.animManager)
    ctx.export(ctx.oprManager)

    cc.EventProxy.new(nk.socket.RoomSocket, scene)
        :addEventListener(nk.socket.RoomSocket.EVT_PACKET_RECEIVED, handler(self, self.onPacketReceived_))
        :addEventListener(nk.socket.RoomSocket.EVT_CONNECTED, handler(self, self.onConnected_))

    self.loginRoomFailListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.LOGIN_ROOM_FAIL, handler(self, self.onLoginRoomFail_))
    self.roomConnProblemListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.ROOM_CONN_PROBLEM, handler(self, self.onLoginRoomFail_))
    self.serverStopListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.SERVER_STOPPED, handler(self, self.onServerStop_))
    -- 比赛监听
    self.matchStartListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.MATCH_STARTING, handler(self, self.onMatchStarting_))
    self.joinMatchFailListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.MATCH_JOIN_ERROR, handler(self, self.onJoinMatchError_))
    self.packetCache_ = {}
    self.loginRoomRetryTimes_ = 0
    self.frameNo_ = 1

    ctx.sceneSchedulerPool:loopCall(handler(self, self.onEnterFrame_), 1 / 30)
    ctx.sceneSchedulerPool:loopCall(function()
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
        return not self.isDisposed_
    end, 60)
end

function RoomController:dispose()
    self.isDisposed_ = true
    self.seatManager:dispose()
    self.dealerManager:dispose()
    self.dealCardManager:dispose()
    self.lampManager:dispose()
    self.chipManager:dispose()
    self.animManager:dispose()
    self.oprManager:dispose()

    self.schedulerPool:clearAll()
    self.sceneSchedulerPool:clearAll()
    self.gameSchedulerPool:clearAll()

    self:unbindDataObservers_()

    bm.EventCenter:removeEventListener(self.loginRoomFailListenerId_)
    bm.EventCenter:removeEventListener(self.roomConnProblemListenerId_)
    bm.EventCenter:removeEventListener(self.serverStopListenerId_)
    bm.EventCenter:removeEventListener(self.matchStartListenerId_)
    bm.EventCenter:removeEventListener(self.joinMatchFailListenerId_)
end

function RoomController:createNodes()
    self.seatManager:createNodes()
    self.dealerManager:createNodes()
    self.dealCardManager:createNodes()
    self.lampManager:createNodes()
    self.chipManager:createNodes()
    self.animManager:createNodes()
    self.oprManager:createNodes()

    self.oprManager:hideOperationButtons(false)

    nk.socket.RoomSocket:resume()

    self:bindDataObservers_()
end

function RoomController:checkGuideHight()
    if not self.model or not nk.userData.sbGuide then return; end
    local curList = nil
    local attribute="money"
    if self.model.is4K then
        curList = nk.userData.sbGuide["k4"]
    else
        curList = nk.userData.sbGuide["normal"]
    end
    if self.model:isCoinRoom() then
        curList = nk.userData.sbGuide["gold"]
        attribute = "gcoins"
    end
    if not curList and #curList<1 then return; end
    if attribute=="money" and nk.userData.sbGuideHight==1 then return; end
    if attribute=="gcoins" and nk.userData.sbGcoinsGuideHight==1 then return; end

    for k,v in ipairs(curList) do
        local rang = v.rang
        local sb = v.sb
        if nk.userData[attribute]>=rang[1] and nk.userData[attribute]<=rang[2] then
            local isInFit = false
            if not sb[1] or (sb[1] and sb[1]==self.model.roomInfo.blind) then
                isInFit = true
            end
            if sb[2] and sb[2]==self.model.roomInfo.blind then
                isInFit = true
            end
            if not isInFit then
                -- 提示
                if attribute=="money" then
                    self.animManager:showChatMsg(-100, bm.LangUtil.getText("ROOM", "GUIDEHEIGHT",bm.formatBigNumber(sb[1])))
                    nk.userData.sbGuideHight = 1
                elseif attribute=="gcoins" then
                    self.animManager:showChatMsg(-100, bm.LangUtil.getText("ROOM", "GUIDEHEIGHT1",bm.formatBigNumber(sb[1])))
                    nk.userData.sbGcoinsGuideHight = 1
                end
            end
            break;
        end
    end
end

--登录房间失败
function RoomController:onLoginRoomFail_(evt)
    if self.roomLoading_ then
        self.roomLoading_:removeFromParent()
        self.roomLoading_ = nil
    end
    if not evt or not evt.silent then
        nk.ui.Dialog.new({
            hasCloseButton = false,
            messageText = bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"), 
            secondBtnText = bm.LangUtil.getText("COMMON", "RETRY"),
            callback = function (type)
                if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                    self.roomLoading_ = nk.ui.RoomLoading.new(bm.LangUtil.getText("ROOM", "RECONNECT_MSG"))
                        :pos(display.cx, display.cy)
                        :addTo(self.scene, 100)

                    nk.socket.RoomSocket:disconnectRoom()
                    nk.socket.RoomSocket:connectToRoom(evt.data.ip, evt.data.port, evt.data.tid, evt.data.isPlayNow)
                elseif type == nk.ui.Dialog.FIRST_BTN_CLICK or type == nk.ui.Dialog.CLOSE_BTN_CLICK then
                    display.addSpriteFrames("hall_texture.plist", "hall_texture.png", handler(self.scene, self.scene.onLoadedHallTexture_))
                    self.roomLoading_ = nk.ui.RoomLoading.new(bm.LangUtil.getText("ROOM", "OUT_MSG"))
                        :pos(display.cx, display.cy)
                        :addTo(self.scene, 100)
                end
            end
        }):show()
    end
end

--比赛开始提醒
function RoomController:onMatchStarting_(evt)
    if not app.immediateDealMatch then return end
    local pack = evt.data
    if pack and pack.matchlevel and pack.matchid then
        -- 弹窗处理  违背框架
        local dailog = MatchStartPopup.new({
            messageText = bm.LangUtil.getText("MATCH", "JOINMATCHTIPS"),
            closeWhenTouchModel = false,
            hasCloseButton = false,
            time = evt.data.joinTime,
            callback = function (type)
                if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                    nk.socket.MatchSocket:sendJoinGame({matchlevel = pack.matchlevel,matchid = pack.matchid})
                else
                    nk.match.MatchModel:setCancelRegistered(pack.matchlevel,true)
                end
            end
        }):show(self.scene)
        -- dailog:addTo(self.ctx.scene, 1000-1)
        -- dailog:pos(display.cx, display.cy)
    end
end

-- 请求进入比赛失败
function RoomController:onJoinMatchError_(evt)
    -- 请求进入比赛失败
    local pack = evt.data
    local matchid = pack.matchid
    if not matchid or matchid==0 or matchid=="" then
        matchid = nk.match.MatchModel.regList and nk.match.MatchModel.regList[pack.matchlevel]
    end
    if not matchid or matchid==0 or matchid=="" then
        pack.ret = 2
    end
    if pack.ret==0 then
        -- 删除时间
        bm.EventCenter:removeEventListener(self.loginRoomFailListenerId_)
        bm.EventCenter:removeEventListener(self.roomConnProblemListenerId_)
        bm.EventCenter:removeEventListener(self.serverStopListenerId_)
        bm.EventCenter:removeEventListener(self.matchStartListenerId_)
        -- 正在玩牌 直接站起 弃牌 并退出
        -- 如果坐下
        nk.socket.RoomSocket:sendStandUp()
        nk.socket.RoomSocket:sendLogout()
        -- 关闭连接
        nk.socket.RoomSocket:disconnectRoom()
        self.scene.unDispose = true
    -- elseif pack.ret==1 then --房间不存在
    -- elseif pack.ret==2 then --用户已经在房间
    -- elseif pack.ret==3 then --房间人数已满
    -- else
    --[[
    fmt = {
        { name = "tid", type = T.INT },
        { name = "serverid", type = T.INT },
        { name = "matchlevel", type = T.INT },
        { name = "ret", type = T.INT }
    }
    --]]
        local extData = {}
        extData.vip = 0
        
        local isVip, vipconfig = self:checkIsVip_()
        if isVip then
            extData.vip = vipconfig.vip.level
        end

        nk.socket.MatchSocket:sendLogin({
            tid    = pack.tid,
            matchlevel = pack.matchlevel,
            matchid = matchid,
            uid    = nk.userData.uid,
            mtkey  = nk.userData.mtkey,
            img    = nk.userData.s_picture,
            giftId = nk.userData.user_gift, 
            nick   = nk.userData.nick,
            gender = nk.userData.sex,
            extData = extData
            });
        return
    end
    -- 移除加载loading
    if self.roomLoading_ then
        self.roomLoading_:removeFromParent()
        self.roomLoading_ = nil
    end
    nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "JOINMATCHFAILTIPS"))
    -- 取消当前报名
    nk.match.MatchModel:setCancelRegistered(pack.matchlevel,true)
    nk.socket.MatchSocket:disconnect(true)
    if pack.ret==1 then--房间不存在

    elseif pack.ret==2 then--用户已经在房间

    elseif pack.ret==3 then--房间人数已满

    else

    end
end

--yk
function RoomController:checkIsVip_()
    local isVip = false
    local config
    local vipconfig = nk.OnOff:getConfig('vipmsg')
    local vipconfig_2 = nk.OnOff:getConfig('newvipmsg')

    if vipconfig_2 and vipconfig_2.newvip == 1 then
      isVip = true
      config = vipconfig_2
    else
      if vipconfig and vipconfig.isvip == 1 and vipconfig.vip and vipconfig.vip.light and vipconfig.vip.light == 1 then
        isVip = true
        config = vipconfig
      else
        config = vipconfig_2
      end
    end

    return isVip, config
end

--弹出登出提示弹窗
function RoomController:onServerStop_(evt)
    if self.roomLoading_ then
        self.roomLoading_:removeFromParent()
        self.roomLoading_ = nil
    end
    nk.ui.Dialog.new({
        messageText = bm.LangUtil.getText("ROOM", "SERVER_STOPPED_MSG"), 
        secondBtnText = bm.LangUtil.getText("COMMON", "LOGOUT"), 
        closeWhenTouchModel = false,
        hasFirstButton = false,
        hasCloseButton = false,
        callback = function (type)
            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                display.addSpriteFrames("hall_texture.plist", "hall_texture.png", handler(self.scene, self.scene.onLoadedHallTextureLogout_))
                self.roomLoading_ = nk.ui.RoomLoading.new(bm.LangUtil.getText("ROOM", "OUT_MSG"))
                    :pos(display.cx, display.cy)
                    :addTo(self.scene, 100)
            end
        end,
    }):show()
end

function RoomController:onConnected_(evt)
    self.packetCache_ = {}
    self.loginRoomRetryTimes_ = 0
end

function RoomController:onEnterFrame_(dt)
    if #self.packetCache_ > 0 then
        if #self.packetCache_ == 1 then
            self.frameNo_ = 1
            local pack = table.remove(self.packetCache_, 1)
            self:processPacket_(pack)
        else
            --先检查并干掉累计的超过一局的包
            local removeFromIdx = 0
            local removeEndIdx = 0
            for i, v in ipairs(self.packetCache_) do
                if v.cmd == nk.socket.RoomSocket.PROTOCOL.SVR_GAME_OVER then
                    if removeFromIdx == 0 then
                        removeFromIdx = i + 1 --这里从结束包的下一个开始干掉
                    else
                        removeEndIdx = i --到最后一个结束包
                    end
                end
            end
            if removeFromIdx ~= 0 and removeEndIdx ~= 0 then
                print("!=!=!=! THROW AWAY PACKET FROM " .. removeFromIdx .. " to " .. removeEndIdx)
                --干掉超过一局的包，但是要保留坐下站起包，以保证座位数据正确
                local keepPackets = {}
                for i = removeFromIdx, removeEndIdx do
                    local pack = table.remove(self.packetCache_, removeFromIdx)
                    if pack.cmd == nk.socket.RoomSocket.PROTOCOL.SVR_SIT_DOWN or pack.cmd == nk.socket.RoomSocket.PROTOCOL.SVR_STAND_UP then
                        keepPackets[#keepPackets + 1] = pack
                        pack.fastForward = true
                    end
                end
                if #keepPackets > 0 then
                    table.insertto(self.packetCache_, keepPackets, removeFromIdx)
                end
            end
            self.frameNo_ = self.frameNo_ + 1
            if self.frameNo_ > PACKET_PROC_FRAME_INTERVAL then
                self.frameNo_ = 1
                local pack = table.remove(self.packetCache_, 1)
                self:processPacket_(pack)
            end
        end
    end
    return true
end

--接收发过来的包，并缓存
function RoomController:onPacketReceived_(evt)
    table.insert(self.packetCache_, evt.packet)
end
-- 禁止聊天
function RoomController:forbidChat(uid)
    if not uid then
        self.forbidChatList = {}
    else
        if not self.forbidChatList then
            self.forbidChatList = {}
        end
        self.forbidChatList[uid] = true
    end
end
--解析包 
function RoomController:processPacket_(pack)
    local cmd = pack.cmd
    local ctx = self.ctx
    local model = self.model
    local P = nk.socket.RoomSocket.PROTOCOL
    printf("RoomController.processPacket[%x]%s", cmd, table.keyof(P, cmd))

    if cmd == P.SVR_LOGIN_SUCCESS or cmd == P.SVR_RELOGIN_SUCCESS or cmd == P.SVR_LOGIN_SUCCESS_4K then
        if cmd == P.SVR_LOGIN_SUCCESS then
            self:forbidChat()
        end
        if self.roomLoading_ then
            self.roomLoading_:removeFromParent()
            self.roomLoading_ = nil
        end
        if self.scene and self.scene.roomLoading_ then
            self.scene.roomLoading_:removeFromParent()
            self.scene.roomLoading_ = nil
        end
        -- 上报广告平台  玩牌
        nk.AdSdk:report(consts.AD_TYPE.AD_PLAY,{uid =tostring(nk.userData.uid)})
        self:reset()
        
        local is4K = false
        if cmd == P.SVR_LOGIN_SUCCESS_4K then
            self.scene:removeSelectCardView()
            self:changeDealer(5)
            is4K = true
        end

        --登录成功
        model:initWithLoginSuccessPack(pack,is4K)

        --显示邀请玩牌视图
        self.scene:showInvitePlayView()

        if model:roomType() == consts.ROOM_TYPE.TYPE_5K then
            self:changeDealer(6)
        end
        self.scene:changeRoomBg(model:roomType(),model.roomInfo.blind)
        --显示房间信息
        self.scene:updateCoinRoom()
        self.scene:setRoomInfoText(model.roomInfo)
        --老虎机盲注
        self.scene:setSlotBlind(model.roomInfo)

        --初始化座位及玩家
        ctx.seatManager:initSeats(model.seatsInfo, model.playerList)

        --设置庄家指示
        ctx.animManager:moveDealerTo(ctx.seatManager:getSeatPositionId(model.gameInfo.dealerSeatId), false)

        --初始隐藏灯光
        if model.gameInfo.bettingSeatId ~= -1 then
            ctx.lampManager:show()
            ctx.lampManager:turnTo(ctx.seatManager:getSeatPositionId(model.gameInfo.bettingSeatId), false)

            --座位开始计时器动画
            ctx.seatManager:startCounter(model.gameInfo.bettingSeatId)
        else
            ctx.lampManager:hide()
            ctx.seatManager:stopCounter()
        end

        --(要在庄家指示和灯光之后转动，否则可能位置不正确)
        if model:isSelfInSeat() then
            ctx.seatManager:rotateSelfSeatToCenter(model:selfSeatId(), false)
        end

        --如果玩家坐下并且不在本轮游戏，则提示等待下轮游戏
        if model:isSelfInSeat() and not model:isSelfInGame() then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "WAIT_NEXT_ROUND"))
        end

        --重置操作栏自动操作状态
        ctx.oprManager:resetAutoOperationStatus()
        --更新操作栏状态
        ctx.oprManager:updateOperationStatus()
        --动画显示操作栏
        if model:isSelfInSeat() then
            ctx.oprManager:showOperationButtons(true)
        else
            ctx.oprManager:hideOperationButtons(true)
        end
        
        -- 设置登录筹码堆
        ctx.chipManager:setLoginChipStacks()

        self.gameSchedulerPool:clearAll()

        self:updateChangeRoomButtonMode()

        --自动坐下
        self:applyAutoSitDown()

        if model:isSelfInSeat() and model:isSelfInGame() and pack.gameStatus == consts.SVR_GAME_STATUS.WAIT_FOLD_CARD and pack.handCardFlag == 2 then
            self.scene:AddSelectCardView(pack.selectCards,true,pack.timeout)
        end

        if model.gameInfo.dropCard then
            ctx.dealCardManager:showFoldCard(model.gameInfo.dropCard)
        end
        model.standChatCount = 0;
    elseif cmd == P.SVR_GAME_START then
        if not self.hasReset_ then
            self:reset()
        end
        self.hasReset_ = false

        --牌局开始
        model:processGameStart(pack)

        --如果前2张手牌为0，客户端模拟站起操作（处理服务器已经站起，但客户端还没站起的情况）
        if pack.handCard1 == 0 and pack.handCard2 == 0 then
            self:forceStandUp_()
            return
        end

        --移动庄家指示
        ctx.animManager:moveDealerTo(ctx.seatManager:getSeatPositionId(model.gameInfo.dealerSeatId), true)

        -- 从庄家位置开始发牌
        if model:roomType() == consts.ROOM_TYPE.NORMAL then
            self.gameStartDelay_ = 2 + model:getNumInRound() * 3 * 0.1
        elseif model:roomType() == consts.ROOM_TYPE.PRO then
            self.gameStartDelay_ = 2 + model:getNumInRound() * 2 * 0.1
        end
        ctx.seatManager:prepareDealCards()
        self.gameSchedulerPool:delayCall(function ()
            ctx.dealCardManager:dealCards(1)
        end, 2)

        --重置操作栏自动操作状态
        ctx.oprManager:resetAutoOperationStatus()
        --更新操作栏状态
        ctx.oprManager:updateOperationStatus()

        --更新座位状态
        ctx.seatManager:updateAllSeatState()

        self:updateChangeRoomButtonMode()
    elseif cmd == P.SVR_BET_SUCCESS then
        --下注成功
        local seatId = model:processBetSuccess(pack)

        --更新座位信息
        ctx.seatManager:updateSeatState(seatId)

        local player = model.playerList[seatId]
        local isSelf = model:isSelf(player.uid)
        if player then
            --如果当前座位正在计时，强制停止
            ctx.seatManager:stopCounterOnSeat(seatId)
            ctx.chipManager:betChip(player)

            local betState = player.betState

            -- 前注标志
            if betState == consts.SVR_BET_STATE.PRE_CALL then
                self.isPreCall_ = true
            else
                self.isPreCall_ = false
            end

            -- 前注
            if betState == consts.SVR_BET_STATE.PRE_CALL then
                nk.SoundManager:playSound(nk.SoundManager.CALL)
            -- 看牌
            elseif betState == consts.SVR_BET_STATE.CHECK then
                nk.SoundManager:playSound(nk.SoundManager.CHECK)
            -- 弃牌
            elseif betState == consts.SVR_BET_STATE.FOLD then
                nk.SoundManager:playSound(nk.SoundManager.FOLD)

                ctx.dealCardManager:foldCard(player)
                -- print(player.seatId)
                ctx.seatManager:fadeSeat(seatId)
            -- 跟注
            elseif betState == consts.SVR_BET_STATE.CALL then
                nk.SoundManager:playSound(nk.SoundManager.CALL)
            -- 加注
            elseif betState == consts.SVR_BET_STATE.RAISE then
                nk.SoundManager:playSound(nk.SoundManager.RAISE)
            -- all in
            elseif betState == consts.SVR_BET_STATE.ALL_IN then
                nk.SoundManager:playSound(nk.SoundManager.ALLIN)
                if not isSelf then
                    ctx.seatManager:playAllInAnimation(seatId)
                else
                    ctx.animManager:playDragonBonesAnim(11)
                end
            end
        end
    elseif cmd == P.SVR_TURN_TO_BET then 
        local selectview = self.scene:getSelectCardView()
        if selectview ~= nil then
            self.schedulerPool:delayCall(function() 
                self.scene:removeSelectCardView()
            end, 2)
        end
        --轮到某个玩家下注
        local seatId = model:processTurnToBet(pack)

        --更新座位信息
        ctx.seatManager:updateSeatState(seatId)

        local turnToDelay = 0
        if self.isPreCall_ then
            turnToDelay = self.gameStartDelay_ or 3
        end
        local roundCount = self.model.gameInfo.roundCount
        if self.turnToDelayId_ then
            self.gameSchedulerPool:clear(self.turnToDelayId_)
            self.turnToDelayId_ = nil
        end
        local turnToFunc = function()
                if model:selfSeatId() == seatId then
                    nk.SoundManager:playSound(nk.SoundManager.NOTICE)
                    if nk.userDefault:getBoolForKey(nk.cookieKeys.SHOCK, false) then
                        nk.Native:vibrate(500)
                    end
                end
                --打光切换
                ctx.lampManager:show()
                ctx.lampManager:turnTo(self.seatManager:getSeatPositionId(seatId), true)
                --座位开始计时器动画
                self.gameSchedulerPool:delayCall(function()
                    ctx.seatManager:startCounter(seatId)
                    --更新操作栏状态
                    ctx.oprManager:updateOperationStatus()
                end, 0.5)
            end
        if turnToDelay > 0 then
            self.turnToDelayId_ = self.gameSchedulerPool:delayCall(turnToFunc, turnToDelay)
        else
            turnToFunc()
        end
    elseif cmd == P.SVR_DEAL_THIRD_CARD then
        -- 发第三张牌（仅限专业场）
        model:processDealThirdCard(pack)

        -- 播放发牌动画
        ctx.dealCardManager:dealCards(2)

        --座位停止计时器
        ctx.seatManager:stopCounter()
    elseif cmd == P.SVR_POT then
        -- 奖池
        model:processPot(pack)

        -- 收奖池动画
        ctx.chipManager:gatherPot()

        --禁用操作栏
        ctx.oprManager:blockOperationButtons()
    elseif cmd == P.SVR_SIT_DOWN then 
        --坐下
        local seatId, isAutoBuyin = model:processSitDown(pack)
        if isAutoBuyin then
            local seatView_ = ctx.seatManager:getSeatView(seatId)
            seatView_:playAutoBuyinAnimation(pack.seatChips)
            return
        end

        local anim = not pack.fastForward

        if model:selfSeatId() == seatId then
            --更新全部座位状态，没人的座位会隐藏
            ctx.seatManager:updateAllSeatState()
            --把自己的座位转到中间去
            ctx.seatManager:rotateSelfSeatToCenter(seatId, anim)
            --动画显示操作栏
            ctx.oprManager:showOperationButtons(anim)
            --记录坐下时的钱数
            nk.userData.seatdownMoney = pack.chips
            model.standChatCount = 0;
        else
            --更新座位信息
            ctx.seatManager:updateSeatState(seatId)
        end
        --播放坐下动画
        if anim then
            ctx.seatManager:playSitDownAnimation(seatId)
        end
        self:updateChangeRoomButtonMode()

        -- bm.EventCenter:dispatchEvent({name=nk.eventNames.UPDATE_SEAT_INVITE_VIEW, data={ctx = self.ctx,seatId = seatId}})
        -- bm.EventCenter:dispatchEvent({name=nk.eventNames.UPDATE_SEAT_PUSH_VIEW, data={ctx = self.ctx,seatId = seatId}})
        bm.EventCenter:dispatchEvent({name=nk.eventNames.UPDATE_SEAT_INVITE_PLAY_VIEW, data={ctx = self.ctx, seatId = seatId}})

        --检查坐下状态提示
        -- self:checkSitdownTips()
        if model:selfSeatId() == seatId then
            self.scene:performWithDelay(handler(self, self.checkSitdownTips), 1.5)
            self:checkReportGameNumber(0)
            self:checkPokerActivityStatus()
        end
    elseif cmd == P.SVR_STAND_UP then 
        --站起
        local selfSeatId = model:selfSeatId()
        local seatId = model:processStandUp(pack)
        local positionId = ctx.seatManager:getSeatPositionId(seatId)
        local anim = not pack.fastForward

        --如果自己站起，则把位置转回去
        if selfSeatId == seatId then
            -- ctx.animManager:stopDBCountDownAnim()
            self.scene:removeSelectCardView()
            --更新全部座位状态，没人的座位会显示
            ctx.seatManager:updateAllSeatState()
            --把转动过的座位还原
            ctx.seatManager:rotateSeatToOrdinal()
            --动画隐藏操作栏
            ctx.oprManager:hideOperationButtons(false)
            if self.model:isCoinRoom() and not self.scene.isback_ then
                if appconfig and appconfig.CRASHGCOINS and nk.userData.gcoins < tonumber(appconfig.CRASHGCOINS) then
                    self:processGCoinsCrash()
                end
            else
                if nk.userData.money + nk.userData.bank_money < appconfig.CRASHMONEY and not self.scene.isback_ then
                    self:processCrash(0,0)
                end
            end
        else
            --更新座位信息
            if not anim then
                ctx.seatManager:updateSeatState(seatId)
            end
        end
        --播放站起动画
        if anim then
            ctx.seatManager:playStandUpAnimation(seatId, function() 
                ctx.seatManager:updateSeatState(seatId)
            end)
        end
        --干掉已经发的手牌
        self.dealCardManager:stopDealCardToPos(positionId)
        self.dealCardManager:hideDealedCard(positionId)
        --如果当前座位正在计时，强制停止
        ctx.seatManager:stopCounterOnSeat(seatId)

        self:updateChangeRoomButtonMode()

        -- bm.EventCenter:dispatchEvent({name=nk.eventNames.UPDATE_SEAT_INVITE_VIEW, data={ctx = self.ctx,standUpSeatId = seatId}})
        -- bm.EventCenter:dispatchEvent({name=nk.eventNames.UPDATE_SEAT_PUSH_VIEW, data={ctx = self.ctx,standUpSeatId = seatId}})
        bm.EventCenter:dispatchEvent({name=nk.eventNames.UPDATE_SEAT_INVITE_PLAY_VIEW, data={ctx = self.ctx,standUpSeatId = seatId}})
    elseif cmd == P.SVR_GAME_OVER then
        -- ctx.animManager:stopDBCountDownAnim()
        local selectview = self.scene:getSelectCardView()
        local selectStatus = false
        if selectview ~= nil then
            selectStatus = true
            selectview:delayRemoveCard()
            self.schedulerPool:delayCall(function() 
                self.scene:removeSelectCardView()
            end, 3)
        end
        self.gameSchedulerPool:clearAll()
        --[[
            牌局结束
            前注处理时间3s
            server预留处理游戏结束时间（每个奖池处理时间为3s）：
            普通场或专业场正常结束：奖池数量 * 3 + 4s
            专业场第一轮发牌后all in：奖池数量 * 3 + 2s + 4s
        ]] 
        model:processGameOver(pack,selectStatus)

        --隐藏灯光
        ctx.lampManager:hide()

        --禁用操作按钮
        ctx.oprManager:blockOperationButtons()
        --座位停止计时器
        ctx.seatManager:stopCounter()

        -- 延迟处理
        local splitPotsDelayTime = 0
        local resetDelayTime = 0
        if (model:roomType() == consts.ROOM_TYPE.PRO or model:roomType() == consts.ROOM_TYPE.TYPE_4K) and model.gameInfo.allAllIn then
            splitPotsDelayTime = BetChipView.MOVE_FROM_SEAT_DURATION + BetChipView.MOVE_TO_POT_DURATION + 0.6 + 2
            resetDelayTime = #model.gameInfo.splitPots * 3 + splitPotsDelayTime
            self.schedulerPool:delayCall(function() 
                self.seatManager:showHandCard()
            end, 2)
        else
            splitPotsDelayTime = BetChipView.MOVE_FROM_SEAT_DURATION + BetChipView.MOVE_TO_POT_DURATION + 0.6
            resetDelayTime = #model.gameInfo.splitPots * 3 + splitPotsDelayTime
            if model:canShowHandcard() then
                if model:canShowHandcardButton() then
                    ctx.oprManager:showExtOperationView()
                end
            elseif self.model.gameInfo.dealed3rdCard then
                self.seatManager:showHandCard()
            end
        end
        -- 分奖池动画
        self.schedulerPool:delayCall(function ()
            ctx.chipManager:splitPots(model.gameInfo.splitPots)
            --座位经验值变化动画
            ctx.seatManager:playExpChangeAnimation()
        end, splitPotsDelayTime)
        -- 刷新游戏状态
        self.schedulerPool:delayCall(handler(self, self.reset), resetDelayTime)

        --上报当前总资产 身上的和保险箱
        self:countContinuousGameNumber_()

        --上报牌局记录
        if self.model:isSelfInRound() and not self.model:isInMatch() then
            self:checkReportGameNumber(1)
            self.scene:performWithDelay(handler(self, self.checkPokerActivityStatus), 2.0)
        else
            self:checkReportGameNumber(0)
        end
    elseif cmd == P.SVR_ADD_FRIEND then
        --用户加牌友
        self.animManager:playAddFriendAnimation(pack.fromSeatId, pack.toSeatId)
    elseif cmd == P.SVR_SEND_CHIPS_SUCCESS then
        --赠送筹码成功
        model:processSendChipSuccess(pack)
        self.animManager:playSendChipAnimation(pack.fromSeatId, pack.toSeatId, pack.chips)
    elseif cmd == P.SVR_SEND_CHIPS_SUCC_1 then
        model:processSendChipSuccess(pack,true)
        self.animManager:playSendChipAnimation(pack.fromSeatId, pack.toSeatId, pack.chips)
    elseif cmd == P.SVR_SEND_CHIPS_FAIL then
        --赠送筹码失败
        local errorCode = pack.errorCode
        local Q = consts.SVR_SEND_CHIPS_FAIL_CODE
        if errorCode == Q.NOT_ENOUGH_CHIPS then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SEND_CHIP_NOT_ENOUGH_CHIPS"))
        elseif errorCode == Q.TOO_OFTEN then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SEND_CHIP_TOO_OFTEN"))
        elseif errorCode == Q.TOO_MANY then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SEND_CHIP_TOO_MANY"))
        end
    elseif cmd == P.SVR_CMD_SEND_DEALER_CHIP_SUCC then
        --给荷官赠送筹码
        local fromSeatId = pack.fromSeatId
        local player = self.model.playerList[fromSeatId]
        if player then
            self.animManager:playSendChipAnimation(fromSeatId, pack.toSeatId, pack.chips)
            self.seatManager:checkRewardWhenSendChipToDealer(fromSeatId, pack.toSeatId, pack.chips)
            self.sceneSchedulerPool:delayCall(function() 
                    ctx.dealerManager:kissPlayer()
                    local lastWin_ = 0
                    if self.model.gameInfo and self.model.gameInfo.splitPots then
                        for i, v in ipairs(self.model.gameInfo.splitPots) do
                            if v.seatId == fromSeatId and v.isReallyWin then
                                lastWin_ = 1
                            end
                        end
                        if lastWin_ ~= 1 then
                            lastWin_ = 2
                        end
                    end
                    bm.EventCenter:dispatchEvent({name = nk.eventNames.SEND_DEALER_CHIP_BUBBLE_VIEW, nick=player.nick, lastWin = lastWin_})
                end, 2)
            local sendNumber_ =    cc.UserDefault:getInstance():getIntegerForKey(nk.cookieKeys.RECORD_SEND_DEALER_CHIP_TIME .. nk.userData.uid, 5)
                sendNumber_ = sendNumber_  - 1
                cc.UserDefault:getInstance():setIntegerForKey(nk.cookieKeys.RECORD_SEND_DEALER_CHIP_TIME .. nk.userData.uid, sendNumber_)
            if sendNumber_ <= 0 then
                self.sceneSchedulerPool:delayCall(function() 
                        self.animManager:playHddjAnimation(pack.toSeatId, fromSeatId,math.random(3,4))
                    end, 4)
                cc.UserDefault:getInstance():setIntegerForKey(nk.cookieKeys.RECORD_SEND_DEALER_CHIP_TIME .. nk.userData.uid, 5)
            end
            if model:selfSeatId() == fromSeatId then
                local gcoins = 0
                if self.model:isCoinRoom() then
                    gcoins = 1
                end
                bm.EventCenter:dispatchEvent({
                        name = nk.DailyTasksEventHandler.REPORT_SEND_DEALER,
                        data = {isgcoin = gcoins}
                    })
            end
        end
        

    elseif cmd == P.SVR_CMD_SEND_DEALER_CHIP_FAIL then
        --给荷官赠送失败
        if model:isCoinRoom() then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("COINROOM", "SELF_CHIP_NO_ENOUGH_SEND_DELEAR"))
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SELF_CHIP_NO_ENOUGH_SEND_DELEAR"))
        end
    elseif cmd == P.SVR_SEND_HDDJ then
        --发送互动道具
        local selfUid = nk.userData.uid
        local fromPlayer = model.playerList[pack.fromSeatId]
        local toPlayer = model.playerList[pack.toSeatId]
        local sendToDealer = toPlayer or (pack.toSeatId == 10)
        if selfUid ~= pack.uid and sendToDealer and fromPlayer then
            --自己发送的互动道具动画已经提前播过了
            self.animManager:playHddjAnimation(pack.fromSeatId, pack.toSeatId, pack.hddjId, selfUid ~= pack.uid)
        end
    elseif cmd == P.SVR_SEND_EXPRESSION then
        --发送表情
        local seatId, expressionId, isSelf, minusChips = model:processSendExpression(pack)
        if seatId then
            self.animManager:playExpression(seatId, expressionId)
            if isSelf and minusChips > 0 then
                --是自己并且有扣钱，播放扣钱动画
                self.animManager:playChipsChangeAnimation(seatId, -minusChips)
            end
        end
    elseif cmd == P.SVR_SEND_ROOM_BROADCAST then

        -- dump(json.decode(pack.content), "RoomController:processPacket_[SVR_SEND_ROOM_BROADCAST].pack.content :==============")
        local mtype, jsonTable, param1, param2, param3, param4, param5 = model:processRoomBroadcast(pack)
        -- print("mtype, jsonTable, param1, param2, param3 => ", mtype, jsonTable, param1, param2, param3,param4)
        if mtype == 1 then
            --聊天消息
            local seatId, msg = param1, param2
            local player = model.playerList[seatId]
            local canShow = true
            if player and self.forbidChatList then
                if self.forbidChatList[player.uid] then
                    canShow = false
                end
            end
            if canShow then
                self.animManager:showChatMsg(seatId, jsonTable.msg)
                --更新最近聊天文字
                self.oprManager:setLatestChatMsg(msg)
                -- 快捷聊天音效
                if seatId>-1 then
                    local shortcutList = bm.LangUtil.getText("ROOM", "CHAT_SHORTCUT")
                    for k,v in ipairs(shortcutList) do
                        if jsonTable.msg==v then
                            nk.SoundManager:playChatSound(k)
                            break
                        end
                    end
                end
            end
        elseif mtype == 2 then
            --用户换头像
            local seatId, uid, url = param1, param2, param3
            if seatId ~= -1 then
                self.seatManager:updateHeadImage(seatId, url)
            end
        elseif mtype == 3 then
            -- 赠送礼物
            local giftId, fromSeatId, toSeatIdArr, fromUid, toUidArr = param1, param2, param3, param4, param5
            if fromSeatId ~= -1 and #toSeatIdArr > 0 then
                self.animManager:playSendGiftAnimation(giftId, fromUid, toUidArr)
            elseif #toSeatIdArr > 0 then
                for _, seatId in ipairs(toSeatIdArr) do
                    if seatId ~= -1 then
                        self.seatManager:updateGiftUrl(seatId, giftId)
                    end
                end
            end
        elseif mtype == 4 then
            --设置礼物
            local seatId, giftId = param1, param2
            if seatId ~= -1 then
                self.seatManager:updateGiftUrl(seatId, giftId)
            end
        elseif mtype == 5 then--发送VIP表情
            local seatId, expressionId, isSelf, minusChips = model:processSendExpression(jsonTable)
            if seatId then
                self.animManager:playExpression(seatId, expressionId, 1 / 9)
            end
        end
    elseif cmd == P.SVR_LOGOUT_SUCCESS then
        --登出成功
        if self.isKickedOut then
            self.scene:doBackToHall()
            self.isKickedOut = false
        end
        -- 记录给荷官送筹码次数大于五次，播放互动道具动画
        cc.UserDefault:getInstance():setIntegerForKey(nk.cookieKeys.RECORD_SEND_DEALER_CHIP_TIME .. nk.userData.uid, 5)
        
    elseif cmd == P.SVR_SIT_DOWN_FAIL then
        --坐下失败
        local errorCode = pack.errorCode
        local Q = consts.SVR_SIT_DOWN_FAIL_CODE
        local M = bm.LangUtil.getText("ROOM", "SIT_DOWN_FAIL_MSG")
        local msg = nil
        printf("SVR_SIT_DOWN_FAIL ==> %x", errorCode)
        if errorCode == Q.IP_LIMIT then
            msg = M["IP_LIMIT"]
            nk.reportToDAdmin("IP_LIMIT", "IP_LIMIT_COUNT=1")
        elseif errorCode == Q.SEAT_NOT_EMPTY then
            msg = M["SEAT_NOT_EMPTY"]
        elseif errorCode == Q.TOO_RICH then
            msg = M["TOO_RICH"]
        elseif errorCode == Q.TOO_POOR then
            msg = M["TOO_POOR"]
        elseif errorCode == Q.NO_OPER then
            msg = M["NO_OPER"]
        end
        if msg then
            nk.TopTipManager:showTopTip(msg)
        end
    elseif cmd == P.SVR_SHOW_HANDCARD then
        --亮出手牌
        ctx.seatManager:showHandCardByOther(pack)
    elseif cmd == P.SVR_CMD_USER_CRASH then
        -- 破产
    elseif cmd == P.SVR_CMD_SERVER_UPGRADE then
        --服务器升级，给个提示消息
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SERVER_UPGRADE_MSG"))
    elseif cmd == P.SVR_KICKED_BY_ADMIN then
        --被管理员踢出房间
        nk.socket.RoomSocket:disconnectRoom()
        nk.ui.Dialog.new({
            messageText = bm.LangUtil.getText("ROOM", "KICKED_BY_ADMIN_MSG"), 
            secondBtnText = bm.LangUtil.getText("ROOM", "BACK_TO_HALL"), 
            closeWhenTouchModel = false,
            hasFirstButton = false,
            hasCloseButton = false,
            callback = function (type)
                if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                    self.scene:doBackToHall()
                end
            end,
        }):show()
    elseif cmd == P.SVR_KICKED_BY_USER then
        --被用户踢出房间
        nk.socket.RoomSocket:disconnectRoom()
        self.scene:doBackToHall()
    elseif cmd == P.SVR_KICKED_BY_USER_MSG then
        --被用户踢出房间提醒
        if model:isSelfInGame() then
            nk.ui.Dialog.new({
                messageText = bm.LangUtil.getText("ROOM", "TO_BE_KICKED_BY_USER_MSG", pack.param3), 
                closeWhenTouchModel = false,
                hasFirstButton = false,
                hasCloseButton = false,
            }):show()
        else
            nk.socket.RoomSocket:disconnectRoom()
            nk.ui.Dialog.new({
                messageText = bm.LangUtil.getText("ROOM", "KICKED_BY_USER_MSG", pack.param3), 
                secondBtnText = bm.LangUtil.getText("ROOM", "BACK_TO_HALL"),
                closeWhenTouchModel = false,
                hasFirstButton = false,
                hasCloseButton = false,
                callback = function (type)
                    if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                        self.scene:doBackToHall()
                    end
                end,
            }):show()
        end
    elseif cmd == P.SVR_KICKED_BY_USER_NEW then
        --被用户踢出房间
        if pack.kickedUid and pack.kickedUid == nk.userData.uid then
            self.isKickedOut = true
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("VIP", "KICKED_TIP", pack.kickerNick))
        end
    elseif cmd == P.SVR_CMD_BROADCAST_FEE then
         --扣服务费成功
        local seatId = model:processFee(pack)
        ctx.seatManager:updateSeatState(seatId)
    elseif cmd == P.SVR_MODIFY_USERINFO then
        local seatId = model:svrModifyUserinfo(pack)
        if seatId > 0 then
            ctx.seatManager:updateSeatState(seatId)
        end
    elseif cmd == P.SVR_GAME_START_4K then
        if not self.hasReset_ then
            self:reset()
        end
        self.hasReset_ = false
        --牌局开始
        model:processGameStart4K(pack)

        --如果前2张手牌为0，客户端模拟站起操作（处理服务器已经站起，但客户端还没站起的情况）
        if pack.handCard1 == 0 and pack.handCard2 == 0 then
            self:forceStandUp_()
            return
        end

        --移动庄家指示
        ctx.animManager:moveDealerTo(ctx.seatManager:getSeatPositionId(model.gameInfo.dealerSeatId), true)

        -- 从庄家位置开始发牌
        if model:roomType() == consts.ROOM_TYPE.NORMAL then
            self.gameStartDelay_ = 2 + model:getNumInRound() * 3 * 0.1
        elseif model:roomType() == consts.ROOM_TYPE.PRO then
            self.gameStartDelay_ = 2 + model:getNumInRound() * 2 * 0.1
        elseif model:roomType() == consts.ROOM_TYPE.TYPE_4K then
            self.gameStartDelay_ = 2 + model:getNumInRound() * 4 * 0.1
        elseif model:roomType() == consts.ROOM_TYPE.TYPE_5K then
            self.gameStartDelay_ = 2 + model:getNumInRound() * 5 * 0.1
        end
        ctx.seatManager:prepareDealCards()
        self.gameSchedulerPool:delayCall(function ()
            ctx.dealCardManager:dealCards(1)
        end, 1.5)

        --重置操作栏自动操作状态
        ctx.oprManager:resetAutoOperationStatus()
        --更新操作栏状态
        ctx.oprManager:updateOperationStatus()

        --更新座位状态
        ctx.seatManager:updateAllSeatState()

        self:updateChangeRoomButtonMode()
        if model:isSelfInSeat() and model:isSelfInGame() then
            self.scene:AddSelectCardView(pack.handCards)
        end
    elseif cmd == P.SVR_BRO_FOLD_START_4K then
        model:processBroFoldStart(pack)
        self.scene:setSelectedCardTime(pack.timeout)
    elseif cmd == P.SVR_BRO_FOLD_CARD_SUCC_4K then
        local player,isself = model:processBroFoldCard(pack)
        if pack.status == 1 then
            if not isself then
                ctx.dealCardManager:drop4kCard(player)
            end
        elseif pack.status == 2 then
            if not isself then
                ctx.seatManager:updateSeatState(pack.seatId)
                ctx.dealCardManager:foldCard(player)
                ctx.seatManager:fadeSeat(pack.seatId)
            else
                nk.SoundManager:playSound(nk.SoundManager.FOLD)
                ctx.dealCardManager:fold4kCardSelf(player)
                ctx.seatManager:fadeSeat(pack.seatId)
                ctx.oprManager:showOperationButtons(true)
            end
        end
    elseif cmd == P.SVR_USER_FOLD_CARD_RET_4K then
        model:processUserFoldCard4K(pack)
        if pack.ret == 0 then
            ctx.dealCardManager:drop4kCardSelf(pack.holdCards)
            ctx.oprManager:showOperationButtons(true)
            -- self.scene:removeSelectCardView()
        elseif pack.ret == 2 then
            -- self.scene:removeSelectCardView()
        end
    else
        logger:debugf("not processed pack %x", pack.cmd)
    end

    self:dispatchEvent({["name"]=RoomController.EVT_PACKET_RECEIVED, ["pack"]=pack})
end

--强制站起
function RoomController:forceStandUp_()
    local pack = {
        cmd = nk.socket.RoomSocket.PROTOCOL.SVR_STAND_UP,
        chips = nk.userData.money,
        seatId = self.model:selfSeatId()
    }
    self:processPacket_(pack)
end

--申请自动坐下
function RoomController:applyAutoSitDown()
    if not self.model:isSelfInGame() then
        local emptySeatId = self.seatManager:getEmptySeatId()
        if emptySeatId then
            local isAutoSit = nk.userDefault:getBoolForKey(nk.cookieKeys.AUTO_SIT, true)
            if self.model:isCoinRoom() then
                -- isAutoSit = false
            end
            if isAutoSit or nk.socket.RoomSocket:isPlayNow() then
                local userData = nk.userData
                local money = userData.money
                if self.model:isCoinRoom() then
                    money = userData.gcoins
                end
                if money >= self.model.roomInfo.minBuyIn then
                    logger:debug("auto sit down", emptySeatId)
                    nk.socket.RoomSocket:sendSitDown(emptySeatId, math.min(money, self.model.roomInfo.maxBuyIn * 0.5))
                    local isAutoBuyin = nk.userDefault:getBoolForKey(nk.cookieKeys.AUTO_BUY_IN, true)
                    if isAutoBuyin then
                        nk.socket.RoomSocket:sendAutoBuyin()
                    end
                else
                    if not nk.socket.RoomSocket:isPlayNow() then
                        return
                    end
                    --这里可能scene还未切换完成，等待1S再弹对话框
                        self.sceneSchedulerPool:delayCall(function()
                            if userData.money < userData.limitMin then
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
                        end, 1)
                end
            end
        else
            logger:debug("can't auto sit down, no emtpy seat")
        end
    end
end

function RoomController:updateChangeRoomButtonMode()
    if self.model:isSelfInSeat() then
        self.scene:setChangeRoomButtonMode(2)
    else
        self.scene:setChangeRoomButtonMode(1)
    end
end

-- 上报破产
function RoomController:reportUserCrash_(times, subsidizeChips)
    if self.model ~= nil  and self.model.roomInfo ~= nil then
        bm.HttpService.POST({mod="bankruptcy", act="reportCenter", 
            uphillPouring = self.model.roomInfo.blind, 
            playground = tostring(self.model:roomType()), 
            money = subsidizeChips,  -- 救济钱数  = 0表示破产没有救济
            times = times -- 第几次救济
        })
    end
end


function RoomController:processCrash(times, subsidizeChips)
    if subsidizeChips > 0 then
        self:processCrash_(times, subsidizeChips, 0 ,0)
    else
        bm.HttpService.POST({mod="Broke", act="check",
            uphillPouring = self.model.roomInfo.blind, 
            playground = tostring(self.model:roomType())},
            function(data)
                local jsonData = json.decode(data)
                if jsonData.newbie and jsonData.newbie == 1 then 
                    self:newCrashHandle_(jsonData)
                else
                    if jsonData and jsonData.money and jsonData.waiteTime then
                        self:processCrash_(times, 0, jsonData.money,jsonData.waiteTime)
                    else
                        self:processCrash_(times, 0, 0, 0)
                    end
                end
            end,
            function()
                self:processCrash_(times, 0, 0 ,0)
            end)
    end  
end

--新版破产处理
function RoomController:newCrashHandle_(data)
    if data.ret == 1 then --可以领取
        NewUserCrash.new(1, data.reward):show()
        self:playBoxRewardAnimation_(data.reward)
    elseif data.ret == -1 then --已经超过3次
        NewUserCrash.new(2, nk.userData.inviteBackReward):show()
    end
end

function RoomController:playBoxRewardAnimation_(money)
    local rewards = {}
    local info = {
        type = 1,
        icon = "match_chip.png",
        txt  = bm.LangUtil.getText("MATCH", "MONEY").." + "..tostring(money),
        num  = bm.formatBigNumber(money),
        val  = money
    }
        
    table.insert(rewards, #info + 1, info)

    nk.UserInfoChangeManager:playBoxRewardAnimation(nk.UserInfoChangeManager.RoomScene, rewards, true)
end

function RoomController:processGCoinsCrash()
    bm.HttpService.POST(
        {mod = "table", act = "siteInRoom", sb = self.model.roomInfo.blind, match = 0, isgcoin = 1},
        function (data)
            local retData = json.decode(data)
            if retData and retData.showBox == 1 and retData.box >= 3 then
                local minBuy = bm.formatBigNumber(self.model.roomInfo.blind * 10) or nk.userData.limitMin
                retData.minBuy = minBuy
                if retData.box == 11 then
                    GuidePayPopup.new(106, nil, retData):show()
                end
            else
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
            end
        end,
        function ()
            end
        )
end

function RoomController:processCrash_(times, subsidizeChips, phpCrashChips,waitTimes)  
    if nk.userData.seatdownMoney and nk.userData.seatdownMoney >= 1000 then     
        self:reportUserCrash_(times,subsidizeChips)
    end
    self.schedulerPool:delayCall(function() 
            local userCrash = UserCrash.new(times,subsidizeChips,phpCrashChips,waitTimes,
                {
                    uphillPouring = self.model.roomInfo.blind, 
                    playground = tostring(self.model:roomType()),
                }, self.model:roomField())
            userCrash:show()
        end, 1)
end

-- 上报牌局
local HALLOWEEN_ENABLED_SB = 50000
-- type: 1:请求加牌局
--     : 0:只请求牌局信息
function RoomController:checkReportGameNumber(type_)
    if self.model ~= nil  and self.model.roomInfo ~= nil then
        local sb_ = self.model.roomInfo.blind
        local roomtype_ = tostring(self.model:roomType())
        local time_ = os.time()
        local conductConfig = nk.OnOff:getConfig('conductConfig')
        if conductConfig and conductConfig.sb then
            HALLOWEEN_ENABLED_SB = conductConfig.sb
        end
        local gameCount = 30
        if conductConfig and conductConfig.num then
            gameCount = conductConfig.num
        end
        if nk.config.SONGKRAN_ACTIVITY_ENABLED then
            gameCount = 20
            HALLOWEEN_ENABLED_SB = 2000
        end
        if nk.config.HALLOWEEN_ENABLED and sb_ >= HALLOWEEN_ENABLED_SB then 
            bm.HttpService.POST({mod="RecordNum", act="record", 
                sb = sb_, 
                roomtype = roomtype_,
                type = type_,
                time = time_,
                sign = crypto.md5(time_ .. "1e2c206269c42354c6dae040bca194c8f")
            },
            function(data)
                local jsonData = json.decode(data)
                if jsonData then
                    local tmp = tonumber(jsonData.num)
                    if tmp > gameCount then
                        tmp = gameCount
                    end
                    local showReward = false
                    self.needShowReward = jsonData.award and tonumber(jsonData.award)
                    if self.needShowReward and self.needShowReward == 0 then
                        -- nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALLOWEEN", "TIPS3", gameCount))
                        showReward = true
                    end
                    local pro = tmp .. "/" .. gameCount
                    if nk.config.SONGKRAN_ACTIVITY_ENABLED then
                        pro = ""
                        if jsonData.sgjreward and tonumber(jsonData.sgjreward) > 0 then
                            showReward = true
                        else
                            showReward = false
                        end
                    end
                    if self.scene and self.scene.updateHalloweenRoomProgress then
                        self.scene:updateHalloweenRoomProgress(true, pro, showReward)
                    end
                end
            end,
            function()
            end)
        else
            if self.scene and self.scene.updateHalloweenRoomProgress then
                self.scene:updateHalloweenRoomProgress(false)
            end
        end
    end
end

function RoomController:transformPokerActivityRoomType()
    local paSwitch = nk.OnOff:getConfig('paSwitch') --// 1普通场，2黄金币场，3 4K场普通，4 4K场黄金币，5 5K场普通， 6 5K黄金币
    local ind = 1
    if self.ctx.model:isCoinRoom() then
        ind = 2
    end
    local step = 1
    if self.ctx.model:roomType() == consts.ROOM_TYPE.TYPE_4K then
        step = 2
    elseif self.ctx.model:roomType() == consts.ROOM_TYPE.TYPE_5K then
        step = 3
    end
    local index = (step - 1) * 2 + ind
    return (paSwitch and paSwitch[index .. ""] == 1), index
end

-- 检查牌局活动是否可以领奖
function RoomController:checkPokerActivityStatus()
    if nk.config.POKER_ACTIVITY_ENABLED and self.model ~= nil  and self.model.roomInfo ~= nil then
        local enable, roomType = self:transformPokerActivityRoomType()
        if not enable then
            return
        end
        bm.HttpService.POST({mod="Task", act="paList", type = roomType},
            function(data)
                local callData = json.decode(data)
                if callData and callData.ret and callData.ret == 0 then
                        if callData.list and callData.cur and callData.select and callData.select == 1 then
                            local rewardable = false
                            for i = 1, 3 do
                                if callData.list[i].rewarded and callData.list[i].rewarded == 0 then
                                    if callData.cur >= callData.list[i].num then
                                        rewardable = true
                                        break
                                    end
                                end
                            end
                            if rewardable then
                                self.scene:updatePokerActivityStatus(true)
                            else
                                self.scene:updatePokerActivityStatus(false)
                            end
                        end
                end
            end, function()
        end)
    end
end

-- 坐下检查是否提示领奖
function RoomController:checkSitdownTips()
    if self.model:isCoinRoom() then
        return
    end
    if nk.config.HALLOWEEN_ENABLED and self.model ~= nil  and self.model.roomInfo ~= nil then
        local sb = self.model.roomInfo.blind
        local conductConfig = nk.OnOff:getConfig('conductConfig')
        if conductConfig and conductConfig.sb then
            HALLOWEEN_ENABLED_SB = conductConfig.sb
        end
        local gameCount = 30
        if conductConfig and conductConfig.num then
            gameCount = conductConfig.num
        end
        if nk.config.SONGKRAN_ACTIVITY_ENABLED then
            gameCount = 20
            HALLOWEEN_ENABLED_SB = 2000
        end
        if sb >= HALLOWEEN_ENABLED_SB then 
            if self.needShowReward and self.needShowReward > 2 then
                -- nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALLOWEEN", "TIPS2", gameCount))
            end
        elseif nk.userData.money and nk.userData.money > HALLOWEEN_ENABLED_SB * 10 then
            -- nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALLOWEEN", "TIPS1", HALLOWEEN_ENABLED_SB, gameCount), 
            --     {text = bm.LangUtil.getText("HALLOWEEN", "GOPLAY"), callback = handler(self, self.gotoHigherRoom)})
            self.scene:updateHalloweenRoomProgress(false)
        else
            self.scene:updateHalloweenRoomProgress(false)
        end
    else
        self.scene:updateHalloweenRoomProgress(false)
    end
end

function RoomController:gotoHigherRoom()
    -- print("···RoomController:gotoHigherRoom")
    self.scene:onChangeRoom_(false, false, HALLOWEEN_ENABLED_SB)
end

function RoomController:isPreCall()
    return self.isPreCall_
end

function RoomController:reset()
    self.hasReset_ = true
    self.isPreCall_ = false
    self.turnToDelayId_ = nil

    self.model:reset()
    self.dealCardManager:reset()
    self.chipManager:reset()
    self.seatManager:reset()

    self.lampManager:hide()

    self.schedulerPool:clearAll()
    self.gameSchedulerPool:clearAll()
end

function RoomController:bindDataObservers_()
    self.maxDiscountObserver_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "__user_discount", function(discount)
        self.scene:setStoreDiscount(discount)
    end)
end

function RoomController:unbindDataObservers_()
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "__user_discount", self.maxDiscountObserver_)
end

--统计连续玩牌局数，目前用于上报总资产，进行资产排行榜更新
function RoomController:countContinuousGameNumber_()
    local curGameNum = nk.userData.continuousGameNumber or 0 --当前连续玩牌局数
    local interval = nk.userData.reportMoneyRanking --上报资产排行间隔
    if self.model:isSelfInRound() and not self.model:isInMatch() then
        curGameNum = curGameNum + 1
        nk.userData.continuousGameNumber = curGameNum
        if curGameNum > 0 and curGameNum % interval == 0 then
            local totalMoney = nk.userData.bank_money + nk.userData.money
            local time_ = os.time()
            bm.HttpService.POST(
                {
                    mod="Ranklist",
                    act="report",
                    money = totalMoney,
                    time = time_,
                    sign = crypto.md5(time_ .. "1e2c206269c42354c6dae040bca194c8f")
                },
                function ()
                    print("RoomController:countContinuousGameNumber_()")
                end,
                function ()
                end)
        end
    end      
end

function RoomController:changeDealer(dealerId)
    self.dealerManager:changeDealer(dealerId, false)
end

return RoomController
