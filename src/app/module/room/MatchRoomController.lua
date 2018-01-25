--
-- 房间控制器
-- Author: tony
-- Date: 2014-07-08 11:43:07
--

local RoomModel = import(".model.RoomModel")
local SeatManager = import(".SeatManager")
local DealerManager = import(".DealerManager")
local DealCardManager = import(".DealCardManager")
local LampManager = import(".LampManager")
local ChipManager = import(".ChipManager")
local AnimManager = import(".AnimManager")
local OperationManager = import(".OperationManager")
local BetChipView = import(".views.BetChipView")
local UserCrash = import("app.module.room.userCrash.UserCrash")
local StorePopup = import("app.module.newstore.StorePopup")
local MatchRoomController = class("MatchRoomController")
local logger = bm.Logger.new("MatchRoomController")
local MatchStartPopup = import("app.module.match.MatchStartPopup")

local MatchEventHandler = import("app.module.match.MatchEventHandler")

MatchRoomController.EVT_PACKET_RECEIVED = nk.socket.MatchSocket.EVT_PACKET_RECEIVED
MatchRoomController.ON_MATCH_SOCKET_RECEIVED = "ON_MATCH_SOCKET_RECEIVED"

local PACKET_PROC_FRAME_INTERVAL = 2

function MatchRoomController:ctor(scene)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

    local ctx = {}
    ctx.roomController = self
    ctx.scene = scene
    ctx.model = RoomModel.new(ctx)
    ctx.model:setInMatch(true)
    ctx.controllerEventProxy = cc.EventProxy.new(self, scene)
    ctx.schedulerPool = bm.SchedulerPool.new()
    ctx.sceneSchedulerPool = bm.SchedulerPool.new()
    ctx.gameSchedulerPool = bm.SchedulerPool.new()

    ctx.seatManager = SeatManager.new(ctx,true)

    local dealer_id = DealerManager.GetDealerId(nk.gameState.roomLevel)
    ctx.dealerManager = DealerManager.new(ctx,dealer_id,true)

    ctx.dealCardManager = DealCardManager.new()
    ctx.lampManager = LampManager.new()
    ctx.chipManager = ChipManager.new()
    ctx.animManager = AnimManager.new()
    ctx.oprManager = OperationManager.new()

    ctx.export = function(target)
        if target ~= ctx.model then
            target.ctx = ctx
            for k, v in pairs(ctx) do
                if k ~= "export" and v ~= target then
                    target[k] = v
                end
            end
        else
            rawset(target, "ctx", ctx)
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
    cc.EventProxy.new(nk.socket.MatchSocket,scene)
        :addEventListener(nk.socket.MatchSocket.EVT_PACKET_RECEIVED, handler(self, self.onPacketReceived_))
        :addEventListener(nk.socket.MatchSocket.EVT_CONNECTED, handler(self, self.onConnected_))
    
    -- self.socketReceivedId_ = bm.EventCenter:addEventListener(MatchEventHandler.ROOM_PACKET_RECEIVED, handler(self, self.onPacketReceived_), MatchRoomController.ON_MATCH_SOCKET_RECEIVED)
    
    -- self.loginRoomFailListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.LOGIN_ROOM_FAIL, handler(self, self.onLoginRoomFail_))
    -- self.roomConnProblemListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.ROOM_CONN_PROBLEM, handler(self, self.onLoginRoomFail_))
    -- self.serverStopListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.SERVER_STOPPED, handler(self, self.onServerStop_))
    -- 比赛监听
    self.matchLoginSuccessId_ = bm.EventCenter:addEventListener(nk.eventNames.LOGIN_MATCH_SUCC, handler(self, self.onLoginMatchSucc_))
    self.matchLoginFailId_ = bm.EventCenter:addEventListener(nk.eventNames.LOGIN_MATCH_FAIL, handler(self, self.onLoginMatchFail_))
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

    self.lastStartLevel_ = nk.socket.MatchSocket.currentRoomMatchLevel;
end

function MatchRoomController:onLoginMatchSucc_()
    -- 移除加载loading
    if self.matchLoading_ then
        self.matchLoading_:removeFromParent()
        self.matchLoading_ = nil
    end
end
function MatchRoomController:onLoginMatchFail_(evt)
    -- 移除加载loading
    if self.matchLoading_ then
        self.matchLoading_:removeFromParent()
        self.matchLoading_ = nil
    end

    -- 系统弹窗直接引导 重新连接
    nk.ui.Dialog.new({
        messageText = bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"), 
        secondBtnText = bm.LangUtil.getText("COMMON", "RETRY"),
        closeWhenTouchModel = false,
        hasCloseButton = false,
        callback = function (type)
            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                self.matchLoading_ = nk.ui.RoomLoading.new(
                        bm.LangUtil.getText("ROOM", "ENTERING_MSG"))
                    :pos(display.cx,display.cy)
                    :addTo(self.scene, 1000-1)
                local LoadMatchControl = import("app.module.match.LoadMatchControl")
                nk.socket.MatchSocket:connectToMatch(LoadMatchControl:getInstance().matchIP_, LoadMatchControl:getInstance().matchPort_)
            elseif type == nk.ui.Dialog.FIRST_BTN_CLICK then
                self.scene:doBackToHall()
            end
        end
    }):show()
end

function MatchRoomController:dispose()
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

    -- bm.EventCenter:removeEventListener(self.loginRoomFailListenerId_)
    -- bm.EventCenter:removeEventListener(self.roomConnProblemListenerId_)
    -- bm.EventCenter:removeEventListener(self.serverStopListenerId_)
    -- bm.EventCenter:removeEventListener(self.socketReceivedId_)
    bm.EventCenter:removeEventListener(self.matchStartListenerId_)
    bm.EventCenter:removeEventListener(self.joinMatchFailListenerId_)
    bm.EventCenter:removeEventListener(self.matchLoginSuccessId_)
    bm.EventCenter:removeEventListener(self.matchLoginFailId_)
    -- 派发一个比赛场结束消息事件
    -- bm.EventCenter:dispatchEvent({name = nk.eventNames.MATCH_ROOM_END, data=self.lastStartLevel_})
end

function MatchRoomController:createNodes()
    self.seatManager:createNodes()
    self.dealerManager:createNodes()
    self.dealCardManager:createNodes()
    self.lampManager:createNodes()
    self.chipManager:createNodes()
    self.animManager:createNodes()
    self.animManager:changeColor( 0xB4, 0xB4, 0xB4)
    self.oprManager:createNodes()

    self.oprManager:hideOperationButtons(false)

    nk.socket.MatchSocket:resume()

    self:bindDataObservers_()
end

function MatchRoomController:onLoginRoomFail_(evt)
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

                    nk.socket.RoomSocket:disconnect()
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

function MatchRoomController:onMatchStarting_(evt)
    if not app.immediateDealMatch then return end
    local pack = evt.data
    local startLevel = pack and pack.matchlevel or 0

    if nk.socket.MatchSocket.currentRoomMatchLevel<startLevel then
        self.showBigMatchGuide_ = true
        if pack and pack.matchlevel and pack.matchid then
            -- 统计引导数量
            if not self.scene.showMatchStartTimes then
                self.scene.showMatchStartTimes = 0
            end
            self.scene.showMatchStartTimes = self.scene.showMatchStartTimes + 1
            -- 弹窗处理
            local dailog = MatchStartPopup.new({
                messageText = bm.LangUtil.getText("MATCH", "JOINMATCHTIPS"),
                closeWhenTouchModel = false,
                hasCloseButton = false,
                time = evt.data.joinTime,
                callback = function (type)
                    if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                        -- 当前引导等级 前一场还没有发牌就切场的BUG(切换场结算时没有弹奖励框)
                        self.guideStartLevel_ = startLevel

                        self.reShowTime_ = true
                        self:clearChangeMatchRoomId()
                        -- 取消当前场次报名状态
                        nk.match.MatchModel:setCancelRegistered(nk.socket.MatchSocket.currentRoomMatchLevel,true)
                        -- 两个协议并一起处理
                        nk.socket.MatchSocket:sendLogout({matchlevel = pack.matchlevel,matchid = pack.matchid})
                        nk.socket.MatchSocket.currentRoomMatchLevel = pack.matchlevel -- 不管你有没有进去 解决多个场次同时开始的问题
                    else
                        if self.scene.showMatchStartTimes<1 then
                            self.showBigMatchGuide_ = false
                        end
                        -- 取消收到报名场的报名状态
                        nk.match.MatchModel:setCancelRegistered(pack.matchlevel,true)
                    end
                end
            }):show(self.scene)
            -- dailog:addTo(self.ctx.scene, 1000-1)
            -- dailog:pos(display.cx, display.cy)
        end
    end
end

function MatchRoomController:onJoinMatchError_(evt)
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
        -- bm.EventCenter:removeEventListener(self.loginRoomFailListenerId_)
        -- bm.EventCenter:removeEventListener(self.roomConnProblemListenerId_)
        -- bm.EventCenter:removeEventListener(self.serverStopListenerId_)
        -- bm.EventCenter:removeEventListener(self.matchStartListenerId_)
        -- 正在玩牌 直接站起 弃牌 并退出
        -- 如果坐下
        -- nk.socket.RoomSocket:sendStandUp()
        -- nk.socket.MatchSocket:sendLogout()
        -- 关闭连接
        -- nk.socket.RoomSocket:disconnect()

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
            })
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
    if pack.ret==1 then--房间不存在

    elseif pack.ret==2 then--用户已经在房间

    elseif pack.ret==3 then--房间人数已满

    else

    end
    -- 进入新比赛失败了 直接回到登陆界面
    nk.socket.MatchSocket.canDelayResume = false -- dispose resume了
    nk.socket.MatchSocket:pause()
    self:clearChangeMatchRoomId()
    self.changeMatchRoomId_ = self.sceneSchedulerPool:delayCall(function()
        self.scene:doBackToHall()
    end, 3)
end

--yk
function MatchRoomController:checkIsVip_()
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

function MatchRoomController:onServerStop_(evt)
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

function MatchRoomController:onConnected_(evt)
    self.packetCache_ = {}
    self.loginRoomRetryTimes_ = 0
end

function MatchRoomController:onEnterFrame_(dt)
    if #self.packetCache_ > 0 then
        if #self.packetCache_ == 1 then
            self.frameNo_ = 1
            local pack = table.remove(self.packetCache_, 1)
            self:processPacket_(pack)
        else
            --先检查并干掉累计的超过一局的包
            local removeFromIdx = 0
            local removeEndIdx = 0
            -- 比赛中最后换桌的包也截取下
            local changeTableFromIdx = -1
            local matchAwardPac = nk.socket.MatchSocket.matchRewardPack  -- MatchSocket提前缓存
            for i, v in ipairs(self.packetCache_) do
                if v.cmd == nk.socket.MatchSocket.PROTOCOL.SVR_LOGIN_SUCCESS then
                    changeTableFromIdx = i
                end

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
                local keepPackets = {}  -- 只存最后一个登陆包
                if changeTableFromIdx~=-1 then
                    if changeTableFromIdx>removeFromIdx and changeTableFromIdx<removeEndIdx then
                        local pack = self.packetCache_[changeTableFromIdx]
                        keepPackets[#keepPackets + 1] = pack
                    end
                end
                local realIndex = removeFromIdx-1
                local realRemoveIdx = removeFromIdx   -- 保证原来坐下和站起的序列 否则玩家会先站起后发牌
                for i = removeFromIdx, removeEndIdx do
                    realIndex = realIndex + 1
                    local pack = table.remove(self.packetCache_, realRemoveIdx)
                    if (pack.cmd == nk.socket.RoomSocket.PROTOCOL.SVR_SIT_DOWN or pack.cmd == nk.socket.RoomSocket.PROTOCOL.SVR_STAND_UP) and (realIndex>changeTableFromIdx) then
                        -- keepPackets[#keepPackets + 1] = pack  -- 不加入保证序列正确 添加回去
                        pack.fastForward = true
                        table.insert(self.packetCache_, realRemoveIdx, pack)
                        realRemoveIdx = realRemoveIdx + 1
                    end
                end
                
                if #keepPackets > 0 then  -- 只有一个元素
                    -- table.insertto(self.packetCache_, keepPackets, removeFromIdx)
                    -- table.insertto(self.packetCache_, keepPackets)
                    table.insert(self.packetCache_, removeFromIdx, keepPackets[1])
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

function MatchRoomController:onPacketReceived_(evt)
    -- printf("MatchRoomController.processPacket[%x]%s", evt.packet.cmd, table.keyof(P, evt.packet.cmd))
    if evt.packet.cmd < 0x800 and evt.packet.cmd ~= 0x109 then 
        if evt.packet.cmd == 0x402 then
            -- 清楚rebuy框框
            if self.matchRebuyPopup_ then
                self.matchRebuyPopup_:onClose()
                self.matchRebuyPopup_ = nil
            end
        end
        return 
    end
    table.insert(self.packetCache_, evt.packet)
end
-- 禁止聊天
function MatchRoomController:forbidChat(uid)
    if not uid then
        self.forbidChatList = {}
    else
        if not self.forbidChatList then
            self.forbidChatList = {}
        end
        self.forbidChatList[uid] = true
    end
end
function MatchRoomController:processPacket_(pack)
    local cmd = pack.cmd
    local ctx = self.ctx
    local model = self.model
    local P = nk.socket.MatchSocket.PROTOCOL
    printf("MatchRoomController.processPacket[%x]%s", cmd, table.keyof(P, cmd))

    if cmd == P.SVR_LOGIN_SUCCESS or cmd == P.SVR_RELOGIN_SUCCESS then
        if self.reShowTime_ then
            self.scene:startJoinTimeCountDown(true)
            self.scene:changeTableTexture()

            -- local dealer_id = DealerManager.GetDealerId(nk.gameState.roomLevel)
            local dealer_id = 1
            if nk.userData.tableFlag then
                local tableFlag = tonumber(nk.userData.tableFlag)
                if tableFlag == 1 or  tableFlag == 5 then
                    local dealer_id = 1
                elseif tableFlag == 2 or tableFlag  == 6 then
                    local dealer_id = 2
                end
            end
            
            self.dealerManager:changeDealer(dealer_id,true)
            if cmd == P.SVR_LOGIN_SUCCESS then
                self:forbidChat()
            end
        end
        self.reShowTime_ = nil

        nk.socket.MatchSocket:resume()  -- 切换比赛前一场没有颁奖
        if self.roomLoading_ then
            self.roomLoading_:removeFromParent()
            self.roomLoading_ = nil
        end
        self.scene:onStopChangeRoom()
        -- 上报广告平台  玩牌
        nk.AdSdk:report(consts.AD_TYPE.AD_PLAY,{uid =tostring(nk.userData.uid)})
        
        self:reset()

        --登录成功
        model:initWithLoginSuccessPack(pack)
        model:setInMatch(true)

        --显示房间信息
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
        -- if model:isSelfInSeat() and not model:isSelfInGame() then
            -- nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "WAIT_NEXT_ROUND"))
        -- end

        --重置操作栏自动操作状态
        ctx.oprManager:resetAutoOperationStatus()
        --更新操作栏状态
        self:updateOperationStatus();-- ctx.oprManager:updateOperationStatus()
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
        -- 重练正好在换做
        if pack.gameStatus==0 and pack.playerList and #pack.playerList<1 then
            self.scene:gameStart()
            self.scene:playNowChangeRoom()
        end
    elseif cmd == P.SVR_GAME_START then
        -- 重置Guide
        if self.guideStartLevel_==nk.socket.MatchSocket.currentRoomMatchLevel then
            self.showBigMatchGuide_ = false
            self.guideStartLevel_ = nil
        end
        -- 停止桌面倒计时
        if self.scene and self.scene.animationDownNum_ then
            self.scene.animationDownNum_:cleanUp();
        end
        self.scene:gameStart()
        if not self.hasReset_ then
            self:reset()
        end
        self.hasReset_ = false

        --牌局开始
        model:processGameStart(pack)

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
        self:updateOperationStatus();-- ctx.oprManager:updateOperationStatus()

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
                print(player.seatId)
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
                    self:updateOperationStatus();-- ctx.oprManager:updateOperationStatus()
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
        -- 第一个坐下是清掉上一个桌子上的人
        -- if self.waitingOtherRoomComplte_ then
        --     self.waitingOtherRoomComplte_ = false
        -- end
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
        else
            --更新座位信息
            ctx.seatManager:updateSeatState(seatId)
        end
        --播放坐下动画
        if anim then
            ctx.seatManager:playSitDownAnimation(seatId)
        end
        self:updateChangeRoomButtonMode()
    elseif cmd == P.SVR_STAND_UP then 
        --站起
        local selfSeatId = model:selfSeatId()
        local seatId = model:processStandUp(pack)
        local positionId = ctx.seatManager:getSeatPositionId(seatId)
        local anim = not pack.fastForward

        --如果自己站起，则把位置转回去
        if selfSeatId == seatId then
            --更新全部座位状态，没人的座位会显示
            ctx.seatManager:updateAllSeatState()
            --把转动过的座位还原
            ctx.seatManager:rotateSeatToOrdinal()
            --动画隐藏操作栏
            ctx.oprManager:hideOperationButtons(anim)
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
        self.dealCardManager:hideDealedCard(positionId)
        --如果当前座位正在计时，强制停止
        ctx.seatManager:stopCounterOnSeat(seatId)

        self:updateChangeRoomButtonMode()
    elseif cmd == P.SVR_GAME_OVER then
        self.gameSchedulerPool:clearAll()
        --[[
            牌局结束
            前注处理时间3s
            server预留处理游戏结束时间（每个奖池处理时间为3s）：
            普通场或专业场正常结束：奖池数量 * 3 + 4s
            专业场第一轮发牌后all in：奖池数量 * 3 + 2s + 4s
        ]] 
        model:processGameOver(pack)

        --隐藏灯光
        ctx.lampManager:hide()

        --禁用操作按钮
        ctx.oprManager:blockOperationButtons()
        --座位停止计时器
        ctx.seatManager:stopCounter()

        -- 延迟处理
        local splitPotsDelayTime = 0
        local resetDelayTime = 0
        if (model:roomType() == consts.ROOM_TYPE.PRO and model.gameInfo.allAllIn) then
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
            --座位经验值变化动画（比赛场需要屏蔽）
            -- ctx.seatManager:playExpChangeAnimation()
        end, splitPotsDelayTime)
        -- 刷新游戏状态
        self.schedulerPool:delayCall(handler(self, self.reset), resetDelayTime)

        -- 猎杀动画
        if self.huntUid and self.huntReward then
            local huntedNum = 0
            local huntedList = {}
            local perReward = 0
            local huntSeatId = -1
            for i, v in ipairs(pack.seatChangeList) do
                local seatId = (i - 1)*nk.socket.MatchSocket.multiple
                local player = self.model.playerList[seatId]
                if player and v.seatChips>0 and player.uid==self.huntUid then
                    huntSeatId = player.seatId
                elseif player and player.uid and player.uid>0 and v.seatChips<1 then
                    table.insert(huntedList,player.seatId)
                    huntedNum = huntedNum + 1
                end
            end
            -- 自己则手动加
            if self.huntUid==nk.userData.uid then
                nk.userData.gcoins = nk.userData.gcoins + self.huntReward
            end
            perReward = self.huntReward/huntedNum
            local totalHuntReward = self.huntReward
            -- 播放动画
            self.sceneSchedulerPool:delayCall(function() 
                for i,v in ipairs(huntedList) do
                    local startCoord = ctx.seatManager:getSeatPosition(v)
                    local seatView = ctx.seatManager:getSeatView(v)
                    local endCoord = ctx.seatManager:getSeatPosition(huntSeatId)
                    if startCoord and endCoord then
                        if i==#huntedList then
                            ctx.animManager:playLieShaAnim(totalHuntReward,startCoord.x, startCoord.y,endCoord.x, endCoord.y, seatView)
                        else
                            -- ctx.animManager:playLieShaAnim(perReward,startCoord.x, startCoord.y,endCoord.x, endCoord.y, seatView)
                            ctx.animManager:playLieShaAnim(nil,startCoord.x, startCoord.y,endCoord.x, endCoord.y, seatView)
                        end
                    end
                end
            end, 4.0)
        end
        self.huntUid = nil
        self.huntReward = nil
    elseif cmd == P.SVR_ADD_FRIEND then
        --用户加牌友
        self.animManager:playAddFriendAnimation(pack.fromSeatId, pack.toSeatId)
    elseif cmd == P.SVR_SEND_CHIPS_SUCCESS then
        --赠送筹码成功
        model:processSendChipSuccess(pack)
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
            self.sceneSchedulerPool:delayCall(function() 
                    ctx.dealerManager:kissPlayer()
                    bm.EventCenter:dispatchEvent({name = nk.eventNames.SEND_DEALER_CHIP_BUBBLE_VIEW, nick=player.nick})
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
        end
        

    elseif cmd == P.SVR_CMD_SEND_DEALER_CHIP_FAIL then
        --给荷官赠送失败
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SELF_CHIP_NO_ENOUGH_SEND_DELEAR"))
    elseif cmd == P.SVR_SEND_HDDJ then
        --发送互动道具
        local selfUid = nk.userData.uid
        local fromPlayer = model.playerList[pack.fromSeatId]
        local toPlayer = model.playerList[pack.toSeatId]
        if selfUid ~= pack.uid and toPlayer and fromPlayer then
            --自己发送的互动道具动画已经提前播过了
            self.animManager:playHddjAnimation(pack.fromSeatId, pack.toSeatId, pack.hddjId)
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
        local mtype, jsonTable, param1, param2, param3, param4, param5 = model:processRoomBroadcast(pack)
        print("mtype, jsonTable, param1, param2, param3 => ", mtype, jsonTable, param1, param2, param3,param4)
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
        end
    elseif cmd == P.SVR_LOGOUT_SUCCESS then
        --登出成功

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
        elseif errorCode == Q.TOO_POOL then
            msg = M["TOO_POOL"]
        end
        if msg then
            nk.TopTipManager:showTopTip(msg)
        end
    elseif cmd == P.SVR_SHOW_HANDCARD then
        --亮出手牌
        ctx.seatManager:showHandCardByOther(pack)
    elseif cmd == P.SVR_CMD_SERVER_UPGRADE then
        --服务器升级，给个提示消息
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SERVER_UPGRADE_MSG"))
    elseif cmd == P.SVR_KICKED_BY_ADMIN then
        --被管理员踢出房间
        nk.socket.RoomSocket:disconnect()
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
        nk.socket.RoomSocket:disconnect()
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
            nk.socket.RoomSocket:disconnect()
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
    elseif cmd == P.SVR_CMD_USER_MATCH_RISECHIP then
        self.scene:setMatchInfo(pack)
        self.lastRiseChip_ = pack.currentChip;
    elseif cmd == P.SVR_CMD_USER_MATCH_RANK then
        -- 自己的排名及涨盲信息
        self.scene:setRankInfo(pack)
        -- 保存比赛场在玩总人数
        if pack.totalCount then
            nk.MatchRecordManager:saveMatchOnlineCount(pack.totalCount)
        end
    elseif cmd == P.SVR_CMD_CHANGE_ROOM then
        -- self.waitingOtherRoomComplte_ = true
        --比赛时屏蔽多余的提示信息
        -- nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "WAITOTHERROOMTIP"))
        self.scene:gameStart()
        self.scene:playNowChangeRoom()
    elseif cmd == P.SVR_CANCEL_REGISTER then
        if nk.socket.MatchSocket.currentRoomMatchLevel == pack.matchlevel 
        and nk.socket.MatchSocket.currentRoomMatchId == pack.matchid 
        then
            -- local str = ""
            -- if pack.reason==2 then
            --     str = 
            -- end
            nk.ui.Dialog.new({
                messageText = bm.LangUtil.getText("MATCH", "CANCELTIP1"),
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
    elseif cmd == P.SVR_CMD_HUNTING then
        self.huntUid = pack.huntUid
        self.huntReward = pack.huntReward
    elseif cmd == P.SVR_CMD_REBUY then
        -- rebuy场次
        local MatchRebuyPopup = import("app.module.match.MatchRebuyPopup")
        self.matchRebuyPopup_ = MatchRebuyPopup.new(pack)
        if display.getRunningScene()==self.scene then
            self.matchRebuyPopup_:show()
        else -- 大厅场景直接进来就移除了
            self.sceneSchedulerPool:delayCall(function()
                self.matchRebuyPopup_:show()
            end, 0.5)
        end
    elseif cmd == P.SVR_CMD_REBUYRESULT then
        if pack.err==0 then
            if self.matchRebuyPopup_ then
                self.matchRebuyPopup_:onClose()
                self.matchRebuyPopup_ = nil
            end
            -- self.scene:gameStart()
            -- self.scene:playNowChangeRoom()
        else
            if self.matchRebuyPopup_ then
                self.matchRebuyPopup_:onRebuy(1,true)
            end
        end
    elseif cmd == P.SVR_CMD_REBUYUSER then
        local playerList = model.playerList
        local rebuyList = pack.rebuyList
        local coord = nil
        for kk,uid in pairs(rebuyList) do
            for k,v in pairs(playerList) do
                if v.uid==uid then
                    coord = ctx.seatManager:getSeatPosition(v.seatId)
                    if coord then
                        ctx.animManager:playRebuyAnim(coord.x, coord.y+80)
                    end
                end
            end
        end
    else
        logger:debugf("not processed pack %x", pack.cmd)
    end

    self:dispatchEvent({["name"]=MatchRoomController.EVT_PACKET_RECEIVED, ["pack"]=pack})
end

function MatchRoomController:clearChangeMatchRoomId()
    if self.changeMatchRoomId_ then
        self.sceneSchedulerPool:clear(self.changeMatchRoomId_)
        self.changeMatchRoomId_ = nil
    end
end

function MatchRoomController:doBackToHall1()
    if not self.showBigMatchGuide_ then
        self.scene:doBackToHall()
    end
    self.showBigMatchGuide_ = false
end
function MatchRoomController:resetMatchGuide()
    self.showBigMatchGuide_ = false
end

function MatchRoomController:applyAutoSitDown()
    -- 比赛场比自动坐下
    do return end
    if not self.model:isSelfInGame() then
        local emptySeatId = self.seatManager:getEmptySeatId()
        if emptySeatId then
            local isAutoSit = nk.userDefault:getBoolForKey(nk.cookieKeys.AUTO_SIT, true)
            if isAutoSit or nk.socket.RoomSocket:isPlayNow() then
                local userData = nk.userData
                if userData.money >= self.model.roomInfo.minBuyIn then
                    logger:debug("auto sit down", emptySeatId)
                    nk.socket.RoomSocket:sendSitDown(emptySeatId, math.min(userData.money, self.model.roomInfo.maxBuyIn * 0.5))
                    local isAutoBuyin = nk.userDefault:getBoolForKey(nk.cookieKeys.AUTO_BUY_IN, true)
                    if isAutoBuyin then
                        nk.socket.RoomSocket:sendAutoBuyin()
                    end
                else
                    --这里可能scene还未切换完成，等待1S再弹对话框
                    if userData.money < userData.limitMin then
                        self.sceneSchedulerPool:delayCall(function()
                            nk.ui.Dialog.new({
                                messageText = bm.LangUtil.getText("COMMON", "NOT_ENOUGH_MONEY_TO_PLAY_NOW_MSG", nk.userData.limitMin), 
                                hasCloseButton = false,
                                callback = function (type)
                                    if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                                        StorePopup.new():showPanel()
                                    end
                                end
                            }):show()
                        end, 1)
                    else
                        self.sceneSchedulerPool:delayCall(function()
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
                        end, 1)
                    end
                end
            end
        else
            logger:debug("can't auto sit down, no emtpy seat")
        end
    end
end

function MatchRoomController:updateChangeRoomButtonMode()
    if self.model:isSelfInSeat() then
        self.scene:setChangeRoomButtonMode(2)
    else
        self.scene:setChangeRoomButtonMode(1)
    end
end

-- 上报破产
function MatchRoomController:reportUserCrash_(times, subsidizeChips)
    if self.model ~= nil  and self.model.roomInfo ~= nil then
        bm.HttpService.POST({mod="bankruptcy", act="reportCenter", 
            uphillPouring = self.model.roomInfo.blind, 
            playground = tostring(self.model:roomType()), 
            money = subsidizeChips,  -- 救济钱数  = 0表示破产没有救济
            times = times -- 第几次救济
        })
    end
end

function MatchRoomController:isPreCall()
    return self.isPreCall_
end

function MatchRoomController:reset()
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

function MatchRoomController:bindDataObservers_()
    self.maxDiscountObserver_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "__user_discount", function(discount)
        self.scene:setStoreDiscount(discount)
    end)
end

function MatchRoomController:unbindDataObservers_()
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "__user_discount", self.maxDiscountObserver_)
end

function MatchRoomController:updateOperationStatus()
    if self.ctx then
        local ctx = self.ctx;
        if self.lastRiseChip_ then
            if self.model and self.model.gameInfo and self.lastRiseChip_ > self.model.gameInfo.minRaiseChips and self.lastRiseChip_ < self.model.gameInfo.maxRaiseChips then
                self.model.gameInfo.minRaiseChips = self.lastRiseChip_;
            end
            -- maxRaiseChips
        else
            -- 默认最低筹码为200
            self.model.gameInfo.minRaiseChips = 200;
        end

        -- local selfSeatId = ctx.model:selfSeatId();
        -- if selfSeatId and selfSeatId > 0 and ctx.model.playerList[selfSeatId] then
        --     local maxRaiseChips = ctx.model.playerList[selfSeatId].seatChips;
        --     if self.model.gameInfo.minRaiseChips > maxRaiseChips then
        --         self.model.gameInfo.minRaiseChips = maxRaiseChips;
        --     end 
        -- end
        ctx.oprManager:updateOperationStatus();
    end
end

return MatchRoomController
