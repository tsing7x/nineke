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
local UserCrash        = import("app.module.room.userCrash.UserCrash")
local NewUserCrash     = import("app.module.room.userCrash.NewUserCrash")
local StorePopup = import("app.module.newstore.StorePopup")
local UpgradePopup = import("app.module.upgrade.UpgradePopup")
local AnimationDownNum = import("app.module.room.views.AnimationDownNum")

local RoomController = class("RoomController")
local logger = bm.Logger.new("RoomController")


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

    ctx.seatManager = SeatManager.new()
    ctx.dealerManager = DealerManager.new()
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
    ctx.export(ctx.model)

    cc.EventProxy.new(nk.socket.RoomSocket, scene)
        :addEventListener(nk.socket.RoomSocket.EVT_PACKET_RECEIVED, handler(self, self.onPacketReceived_))
        :addEventListener(nk.socket.RoomSocket.EVT_CONNECTED, handler(self, self.onConnected_))

    local P = nk.socket.RoomSocket.PROTOCOL
    self.func_ = {
        [P.SVR_PDENG_LOGIN_ROOM_OK] = handler(self, RoomController.SVR_LOGIN_ROOM_OK),
        [P.SVR_PDENG_LOGIN_ROOM_FAIL] = handler(self, RoomController.SVR_LOGIN_ROOM_FAIL),
        [P.SVR_PDENG_LOGOUT_ROOM_OK] = handler(self, RoomController.SVR_LOGOUT_ROOM_OK),
        [P.SVR_PDENG_SEAT_DOWN] = handler(self, RoomController.SVR_SEAT_DOWN),
        [P.SVR_PDENG_STAND_UP] = handler(self, RoomController.SVR_STAND_UP), 
        [P.SVR_PDENG_OTHER_CARD] = handler(self, RoomController.SVR_OTHER_CARD), 
        [P.SVR_PDENG_DEAL] = handler(self, RoomController.SVR_DEAL),
        [P.SVR_PDENG_SELF_SEAT_DOWN_OK] = handler(self, RoomController.SVR_SELF_SEAT_DOWN_OK), 
        [P.SVR_PDENG_OTHER_STAND_UP] = handler(self, RoomController.SVR_OTHER_STAND_UP),
        [P.SVR_PDENG_GAME_START] = handler(self, RoomController.SVR_GAME_START),
        [P.SVR_PDENG_GAME_OVER] = handler(self, RoomController.SVR_GAME_OVER),
        [P.SVR_PDENG_BET] = handler(self, RoomController.SVR_BET),
        [P.SVR_PDENG_CAN_OTHER_CARD] = handler(self, RoomController.SVR_CAN_OTHER_CARD),
        [P.SVR_PDENG_OTHER_OTHER_CARD] = handler(self, RoomController.SVR_OTHER_OTHER_CARD),
        [P.SVR_PDENG_SHOW_CARD] = handler(self, RoomController.SVR_SHOW_CARD),
        [P.SVR_PDENG_CARD_NUM] = handler(self, RoomController.SVR_CARD_NUM),
        [P.SVR_PDENG_WILL_KICK_OUT] = handler(self, RoomController.SVR_KICK_OUT),
        [P.SVR_KICKED_BY_USER_NEW] = handler(self, RoomController.SVR_KICKED_BY_USER_NEW),
        [P.SVR_PDENG_SELF_REQUEST_BANKER_OK] = handler(self,RoomController.SVR_REQUEST_GRAB_DEALER_RESULT),
        [P.SVR_PDENG_OTHER_REQUEST_BANKER] = handler(self,RoomController.SVR_BROADCAST_USER_GRAB_DEALER),
        [P.SVR_PDENG_OTHER_CANCEL_BANKER] = handler(self,RoomController.SVR_BROADCAST_USER_DROP_DEALER),
        [P.SVR_PDENG_ADD_FRIEND_SUCC] = handler(self,RoomController.SVR_PDENG_ADD_FRIEND_SUCC),
        [P.SVR_PDENG_SEND_CHIPS_SUCC] = handler(self,RoomController.SVR_PDENG_SEND_CHIPS_SUCC),
        [P.SVR_PDENG_SEND_EXPRESSION] = handler(self,RoomController.SVR_PDENG_SEND_EXPRESSION),
        [P.SVR_SEND_HDDJ] = handler(self,RoomController.SVR_PDENG_SEND_HDDJ_SUCC),
        [P.SVR_SEND_ROOM_BROADCAST] = handler(self,RoomController.SVR_PDENG_ROOM_BROADCAST),
    }

    self.loginRoomFailListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.LOGIN_ROOM_FAIL, handler(self, self.onLoginRoomFail_))
    self.roomConnProblemListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.ROOM_CONN_PROBLEM, handler(self, self.onLoginRoomFail_))
    self.serverStopListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.SERVER_STOPPED, handler(self, self.onServerStop_))
    self.packetCache_ = {}
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

                    nk.socket.RoomSocket:disconnectPdeng()
                    nk.socket.RoomSocket:connectToPdeng(evt.data.ip, evt.data.port, evt.data.tid, evt.data.isPlayNow)
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
end

function RoomController:onEnterFrame_(dt)
    if self.seatManager.isTransitionForDealer then
        if #self.packetCache_ > 7 then
            self.seatManager.isTransitionForDealer = false
        end
        return true
    end
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

function RoomController:onPacketReceived_(evt)
    print("RoomController:onPacketReceived_")
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

function RoomController:SVR_LOGIN_ROOM_OK(pack)   
    local ctx = self.ctx
    local model = self.model

    if self.roomLoading_ then
        self.roomLoading_:removeFromParent()
        self.roomLoading_ = nil
    end
    if self.scene and self.scene.roomLoading_ then
        self.scene.roomLoading_:removeFromParent()
        self.scene.roomLoading_ = nil
    end
    self:forbidChat()

    self:reset()

    --登录成功
    model:initWithLoginSuccessPack(pack)

    --显示房间信息
    self.scene:setRoomInfoText(model.roomInfo)
    --初始化座位及玩家
    if model:isSelfInSeat() and model:selfSeatId() == 9 then
        ctx.seatManager:initSeats(model.seatsInfo, model.playerList, true)
    else
        ctx.seatManager:initSeats(model.seatsInfo, model.playerList, false)
    end

    --设置庄家指示
    ctx.animManager:moveDealerTo(ctx.seatManager:getSeatPositionId(model.gameInfo.dealerSeatId), false)

    --初始隐藏灯光
    if model.gameInfo.curDealSeatId ~= -1 then
        ctx.lampManager:show()
        ctx.lampManager:turnTo(ctx.seatManager:getSeatPositionId(model.gameInfo.curDealSeatId), false)

        --座位开始计时器动画
        ctx.seatManager:startCounter(model.gameInfo.curDealSeatId)
    else
        ctx.lampManager:hide()
        ctx.seatManager:stopCounter()
    end

    --(要在庄家指示和灯光之后转动，否则可能位置不正确)
    if model:isSelfInSeat() then
        if not model:isSelfDealer() then
            ctx.seatManager:rotateSelfSeatToCenter(model:selfSeatId(), false)
        end
        ctx.oprManager:showBottom(false)
    end

    --如果玩家坐下并且不在本轮游戏，则提示等待下轮游戏
    if model:isSelfInSeat() and not model:isSelfInGame() then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "WAIT_NEXT_ROUND"))
    end

    if model.gameInfo and model.gameInfo.candidates and #model.gameInfo.candidates > 0 then
        local is_cand = false
        for i, cand in ipairs(model.gameInfo.candidates) do
            if nk.userData.uid == cand.uid then
                is_cand = true
                break
            end
        end
        ctx.oprManager:updateGrabDealerStatus(is_cand)
    end

    --重置操作栏自动操作状态
    ctx.oprManager:resetAutoOperationStatus()
    --更新操作栏状态
    ctx.oprManager:setBaseChips(model.roomInfo.blind)
    ctx.oprManager:updateCurMoney(nk.userData.money)
    ctx.oprManager:updateOperationStatus()

    -- 设置登录筹码堆
    ctx.chipManager:setLoginChipStacks()

    self.gameSchedulerPool:clearAll()

    self:updateChangeRoomButtonMode()

    

    --设置抢庄倒计时
    --self.scene:setGrabLeftTime(pack.grabDealerLeftTime)
    --进场，只要庄家位上无人，即可抢庄
    --相反，如果庄家位置有人，且自己是庄家，则显示补币按钮
    -- uid=1为系统庄家
    local showGrabBtn = true
     for i = 0, 9 do
        local player = model.playerList[i]
        if player and player.seatId == 9 and player.uid >1 then
            showGrabBtn = false
        end
    end
    if showGrabBtn == true then
        self.dealerManager:showDealer()
        self.seatManager:setDealerSeat(false)
    else
        self.dealerManager:hideDealer()
    end
    if model:isSelfInSeat() and model:selfSeatId() == 9 then
        self.ctx.oprManager:updateDealerStatus(true, true)
        self:selfChangeDealer(true)
    else
        self.ctx.oprManager:updateDealerStatus(false, true)
        self:selfChangeDealer(false)
    end
    --自动坐下
    if nk.socket.RoomSocket.needShowDealer then
        if model:isSelfDealer() then
            --我成为庄家
            nk.socket.RoomSocket.needShowDealer=false
            -- nk.TopTipManager:showTopTip("抢庄成功")
            return 
        end

        if model:isSelfInSeat() then--我在座位，但我不是庄家

        else
            --我不在座位，我在等待现在庄家下庄
            self.dealerManager:hideDealer()
            self.scene:showWaitDealerView(true)
        end

    else
        self:applyAutoSitDown()
    end
end

function RoomController:SVR_LOGIN_ROOM_FAIL(pack)
end

function RoomController:SVR_LOGOUT_ROOM_OK(pack)
    --self.scene:doBackToHall()
    nk.userData.money = pack.money
    if self.scene and self.scene.doBackToHall then
        --todo
        self.scene:doBackToHall()
    end
end

function RoomController:SVR_SEAT_DOWN(pack)
    local ctx = self.ctx
    local model = self.model
    --坐下
    local seatId, isAutoBuyin = model:processSitDown(pack)
    --如果我坐下不是庄家位，但我的视图是一个庄家视图，那么需要切换回来
    if model:selfSeatId() == seatId then
         if seatId ~= 9 and nk.socket.RoomSocket.needShowDealer then
            nk.socket.RoomSocket.needShowDealer=false
            self.seatManager:reInitSeat()
            -- self:selfChangeDealer(false)
            self.scene:updateRoomTable_(false)
            self.dealerManager:updateSelfDealer(false)
            for i = 0, 9 do
                local player = model.playerList[i]
                if player and player.seatId == 9 and player.uid == 1 then
                    self.dealerManager:showDealer()
                end
            end
            self.seatManager:initSeats(model.seatsInfo, model.playerList, true)
            self.oprManager:updateState(true)
            self.scene:showWaitDealerView(false)


        end 
    end
    if isAutoBuyin then
        local seatView_ = ctx.seatManager:getSeatView(seatId)
        seatView_:playAutoBuyinAnimation(pack.seatChips)
        return
    end
    if model:selfSeatId() == seatId then
         --更新全部座位状态，没人的座位会隐藏
        ctx.seatManager:updateAllSeatState()
        ctx.oprManager:showBottom(false)
    end
    if model:selfSeatId() == seatId and seatId ~= 9 then
        --把自己的座位转到中间去
        ctx.seatManager:rotateSelfSeatToCenter(seatId, true)
    else        
        --更新座位信息
        ctx.seatManager:updateSeatState(seatId)       
    end

    if seatId == 9 then -- 强制更新
        ctx.seatManager:updateSeatState(seatId)

        local player = model.playerList[9]
        if checkint(player.uid) ~= 1 then
            self.seatManager:setDealerSeat(true)
            self.dealerManager:hideDealer()
        else
            self.seatManager:setDealerSeat(false)
            self.dealerManager:showDealer()
        end
    end

    --自己是庄家，开启庄家位补币按钮
    if model:selfSeatId() == seatId and seatId == 9 then
        self:selfChangeDealer(true)
        -- nk.TopTipManager:showTopTip("抢庄成功")
        self.scene:showWaitDealerView(false)
        nk.socket.RoomSocket.needShowDealer=false
    end
    ctx.seatManager:playSitDownAnimation(seatId)
    self:updateChangeRoomButtonMode()

    --坑，我通过抢庄进来，但是没给庄给我坐
    -- if model:selfSeatId() ~= seatId and seatId == 9 and nk.socket.RoomSocket.needShowDealer== true then
    --     nk.TopTipManager:showTopTip("您将在当前庄家下庄后自动上庄")
    -- end

    --如果我是个闲家，但是我可能是个庄家视图，那么我坐在闲家位，我要转回去
    -- if model:selfSeatId() == seatId and seatId ~= 9 and nk.socket.RoomSocket.needShowDealer == true then
    --     if self.isDealerView_ == true then
    --         self:selfChangeDealer(false)
    --         self.scene:showWaitDealerView(false)
    --     end
    -- end

    bm.EventCenter:dispatchEvent({name=nk.eventNames.UPDATE_SEAT_INVITE_VIEW, data={ctx = self.ctx,seatId = seatId}})
end

function RoomController:SVR_DEAL(pack)
    local ctx = self.ctx
    local model = self.model
    model:processDeal(pack)   
    ctx.seatManager:prepareDealCards()   
    ctx.dealCardManager:dealCards()   
    self.gameSchedulerPool:delayCall(function()
        ctx.oprManager:updateOperationStatus()
    end, 1.5)   
        
end

function RoomController:SVR_SELF_SEAT_DOWN_OK(pack)   
    if pack.ret ~= 0 then
        --坐下失败
        local errorCode = pack.ret
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
    end  
end

function RoomController:SVR_STAND_UP(pack)
    if pack.ret ~= 0 and pack.ret ~= 3 then
        if pack.ret == 2 then
            local tips = bm.LangUtil.getText("PDENG", "BACK_TIPS_IN_GAME")
            if nk.socket.RoomSocket.stand_type then
                if nk.socket.RoomSocket.stand_type == 2 then
                    tips = bm.LangUtil.getText("PDENG", "STAND_TIPS_IN_GAME")
                elseif nk.socket.RoomSocket.stand_type == 3 then
                    tips = bm.LangUtil.getText("PDENG", "DROP_DEALER_TIPS_IN_GAME")
                end
            end
            nk.TopTipManager:showTopTip(tips)
        elseif pack.ret == 1 then
            local tips = bm.LangUtil.getText("PDENG", "BACK_ERROR_IN_THREE")
            if nk.socket.RoomSocket.stand_type then
                if nk.socket.RoomSocket.stand_type == 2 then
                    tips = bm.LangUtil.getText("PDENG", "STAND_ERROR_IN_THREE")
                elseif nk.socket.RoomSocket.stand_type == 3 then
                    tips = bm.LangUtil.getText("PDENG", "DROP_DEALER_ERROR_IN_THREE")
                end
            end
            nk.TopTipManager:showTopTip(tips)
        end
        return
    end
    if pack.ret == 3 then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("PDENG", "DROP_DEALER_TIPS_WHEN_POOR"))
    end

    local ctx = self.ctx
    local model = self.model
    local seatId,isIgnore = model:processStandUp(pack, false)
    local positionId = ctx.seatManager:getSeatPositionId(seatId) 
    --更新全部座位状态，没人的座位会显示
    ctx.seatManager:updateAllSeatState()
    --把转动过的座位还原
    if seatId ~= 9 then
        ctx.seatManager:rotateSeatToOrdinal()
    end 
    ctx.oprManager:hideBottom(false)
    --动画隐藏操作栏
    ctx.oprManager:hideOperationButtons(true)
    
    --如果当前座位正在计时，强制停止
    ctx.seatManager:stopCounterOnSeat(seatId)

    self:updateChangeRoomButtonMode() 
    ctx.chipManager:clearChip(seatId) 


    if isIgnore then
        return
    end  

    --庄家位站起，开启抢庄
    if seatId == 9 then
        self.seatManager:setDealerSeat(false)
        self.dealerManager:showDealer()
        self:selfChangeDealer(false)
    end  

    ctx.seatManager:playStandUpAnimation(seatId, function() 
        ctx.seatManager:updateSeatState(seatId)
    end)

    if nk.userData.money + nk.userData.bank_money < appconfig.CRASHMONEY and not self.scene.isback_ then
        self:processCrash(0,0)
    else

    end

    --干掉已经发的手牌
    self.dealCardManager:hideDealedCard(positionId)
    bm.EventCenter:dispatchEvent({name=nk.eventNames.UPDATE_SEAT_INVITE_VIEW, data={ctx = self.ctx,standUpSeatId = seatId}})
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

    nk.UserInfoChangeManager:playBoxRewardAnimation(nk.UserInfoChangeManager.PdengScene, rewards, true)
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
                }, self.model.roomInfo.blind)
            userCrash:show()
        end, 1)
end

function RoomController:SVR_OTHER_STAND_UP(pack)
    local ctx = self.ctx
    local model = self.model

    --站起
    local selfSeatId = model:selfSeatId()
    local seatId,isIgnore = model:processStandUp(pack, true)
    if isIgnore then
        return
    end
    local positionId = ctx.seatManager:getSeatPositionId(seatId)   
    
    --播放站起动画    
    ctx.seatManager:playStandUpAnimation(seatId, function() 
        ctx.seatManager:updateSeatState(seatId)
    end)
    
    --干掉已经发的手牌
    self.dealCardManager:hideDealedCard(positionId)
    
    --如果当前座位正在计时，强制停止
    ctx.seatManager:stopCounterOnSeat(seatId)

    self:updateChangeRoomButtonMode()
    
    ctx.chipManager:clearChip(seatId)

    --庄家位站起，开启抢庄
    if seatId == 9 and selfSeatId == seatId then
        self:selfChangeDealer(false)
    end

    bm.EventCenter:dispatchEvent({name=nk.eventNames.UPDATE_SEAT_INVITE_VIEW, data={ctx = self.ctx,standUpSeatId = seatId}})
end

function RoomController:SVR_GAME_START(pack)
    local ctx = self.ctx
    local model = self.model

    if not self.hasReset_ then
        self:reset()
    end
    self.hasReset_ = false
    --nk.socket.RoomSocket.needShowDealer = false
    --牌局开始
    model:processGameStart(pack)

    --移动庄家指示
    ctx.animManager:moveDealerTo(ctx.seatManager:getSeatPositionId(model.gameInfo.dealerSeatId), true)

    self.gameStartDelay_ = 2 + model:getNumInRound() * 3 * 0.1

    --重置操作栏自动操作状态
    ctx.oprManager:resetAutoOperationStatus()    
    
    --更新操作栏状态
    ctx.oprManager:updateOperationStatus()

    --更新座位状态
    ctx.seatManager:updateAllSeatState()

    self:updateChangeRoomButtonMode()

    --如果自己在桌位上
    if model:isSelfInSeat() then
        --不是庄家,显示倒计时
        if not model:isSelfDealer() then   
            nk.SoundManager:playSound(nk.SoundManager.NOTICE)
            if nk.userDefault:getBoolForKey(nk.cookieKeys.SHOCK, false) then
                nk.Native:vibrate(500)
            end
            -- ctx.seatManager:startCounter(model:selfSeatId())
            ctx.seatManager:showClock(model.gameInfo.userAnteTime, bm.LangUtil.getText("PDENG", "BET_TIPS"), function()
                    ctx.oprManager:stopBetButton()
                end)
        else
            --庄家显示进度条
            ctx.oprManager:hideOperationButtons()
            ctx.seatManager:showClock(model.gameInfo.userAnteTime, bm.LangUtil.getText("PDENG", "WAIT_OTHER_BET"))
        end
        local player = model.playerList[model:selfSeatId()]
        if player then
            ctx.oprManager:buyInMoney(player.seatChips)
            ctx.oprManager:updateBetButtonState()
        end
    end
end

function RoomController:SVR_BROADCAST_USER_GRAB_DEALER(pack)
    self.model:processGrabDealer(pack)
    if pack.uid == nk.userData.uid then
        self.ctx.oprManager:updateGrabDealerStatus(true)
    end
end

function RoomController:SVR_BROADCAST_USER_DROP_DEALER(pack)
    self.model:processDropDealer(pack)
    if pack.uid == nk.userData.uid then
        self.ctx.oprManager:updateGrabDealerStatus(false)
    end
end

function RoomController:SVR_PDENG_ADD_FRIEND_SUCC(pack)
    --用户加牌友
    self.animManager:playAddFriendAnimation(pack.fromSeatId, pack.toSeatId)
end

function RoomController:SVR_PDENG_SEND_CHIPS_SUCC(pack)
    --赠送筹码成功
    self.model:processSendChipSuccess(pack)
    self.animManager:playSendChipAnimation(pack.fromSeatId, pack.toSeatId, pack.chips)
end

function RoomController:SVR_PDENG_SEND_EXPRESSION(pack)
    --发送表情
    local seatId, expressionId, isSelf, minusChips = self.model:processSendExpression(pack)
    if seatId then
        self.animManager:playExpression(seatId, expressionId)
        if isSelf and minusChips > 0 then
            --是自己并且有扣钱，播放扣钱动画
            self.animManager:playChipsChangeAnimation(seatId, -minusChips)
        end
    end
end

function RoomController:SVR_PDENG_ROOM_BROADCAST(pack)
    -- dump(pack, "RoomController:SVR_PDENG_ROOM_BROADCAST.pack :==================")
    local mtype, jsonTable, param1, param2, param3, param4, param5 = self.model:processRoomBroadcast(pack)

    if mtype == 1 then
        --聊天消息
        local seatId, msg = param1, param2
        local player = self.model.playerList[seatId]
        local canShow = true
        if player and self.forbidChatList then
            if self.forbidChatList[player.uid] then
                canShow = false
            end
        end
        if canShow then
            --更新最近聊天文字
            self.animManager:showChatMsg(seatId, jsonTable.msg)
            self.ctx.oprManager:setLatestChatMsg(msg)
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
    elseif mtype == 5 then--发送VIP表情
        self.animManager:playExpression(jsonTable.seatId, jsonTable.expressionId)
    end
end

function RoomController:SVR_PDENG_SEND_HDDJ_SUCC(pack)
    --发送互动道具
    local selfUid = nk.userData.uid
    local fromPlayer = self.model.playerList[pack.fromSeatId]
    local toPlayer = self.model.playerList[pack.toSeatId]
    local sendToDealer = toPlayer or (pack.toSeatId == 10)
    if selfUid ~= pack.uid and sendToDealer and fromPlayer then
        --自己发送的互动道具动画已经提前播过了
        self.animManager:playHddjAnimation(pack.fromSeatId, pack.toSeatId, pack.hddjId)
    end
end

--server回复抢庄结果
function RoomController:SVR_REQUEST_GRAB_DEALER_RESULT(pack)
    if pack.ret == 0 or pack.ret < 10 then 
        if pack.ret == 1 then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("PDENG", "GRAB_DEALER_SUCCESS"))
        end
    elseif pack.ret >= 10 and pack.ret < 20 then
        if pack.ret == 10 then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("PDENG", "GRAB_DEALER_SUCCESS_WAIT"))
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("PDENG", "GRAB_DEALER_SUCCESS_WAIT_X", pack.ret - 10))
        end
    else
        local errorString = ""
        if pack.ret == 302 or pack.ret == 303 then
            errorString = bm.LangUtil.getText("PDENG", "GRAB_DEALER_FAILED_MONEY_LIMIT", self.model:getGrabDealerNeedCoin())
        elseif pack.ret == 304 then
            errorString = bm.LangUtil.getText("PDENG", "GRAB_DEALER_FAILED_ALREADY")
        elseif pack.ret == 306 then
            errorString = bm.LangUtil.getText("PDENG", "GRAB_DEALER_FAILED_FULL")
        else
            errorString = bm.LangUtil.getText("PDENG", "GRAB_DEALER_FAILED")
        end
        nk.TopTipManager:showTopTip(errorString)
    end
end

function RoomController:selfChangeDealer(isDealer)
    self.isDealerView_ = isDealer
    if isDealer and not self.dealerTable then
        self.dealerTable = true
        self.ctx.oprManager:updateDealerStatus(true)
        self.scene:updateRoomTable_(true)
        self.dealerManager:updateSelfDealer(true)
        self.seatManager:rotateSelfSeatToDealer(true)
    elseif not isDealer and self.dealerTable then
        self.dealerTable = false
        self.ctx.oprManager:updateDealerStatus(false)
        self.scene:updateRoomTable_(false)
        self.dealerManager:updateSelfDealer(false)
        self.seatManager:rotateSelfSeatToDealer(false)
    end
end

function RoomController:turnTo_(seatId)
    local ctx = self.ctx
    local model = self.model
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

--下注
function RoomController:SVR_BET(pack)
    local ctx = self.ctx
    local model = self.model
    --下注成功
    local seatId = model:processBetSuccess(pack)

    --更新座位信息
    ctx.seatManager:updateSeatState(seatId)

    local player = model.playerList[seatId]
    local isSelf = model:isSelf(player.uid)
    if player then
        if player.currBetChips > 0 then
            ctx.chipManager:betChip(player)       
            nk.SoundManager:playSound(nk.SoundManager.CALL)
        end

        if player.currBetChips == 0 and isSelf then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("PDENG", "BET_LIMIT_TIPS"))
        end
    end
    if isSelf then
        ctx.oprManager:updateOperationStatus()
        ctx.oprManager:subCurrMoney(pack.currBetChips)
    end
end

function RoomController:SVR_CAN_OTHER_CARD(pack)
    local model = self.model
    local ctx = self.ctx
    local seatId = model:processTurnToGetPoker(pack)
    self:turnTo_(seatId)
end

function RoomController:SVR_OTHER_OTHER_CARD(pack)
    local model = self.model
    local ctx = self.ctx
    --发第三张牌
    local seatId = model:processGetPoker(pack)
    if model:selfSeatId() ~= seatId and pack.type == 1 then
        ctx.dealCardManager:dealCardToPlayer(seatId)
    end
    ctx.seatManager:stopCounterOnSeat(seatId)
    ctx.seatManager:updateSeatState(seatId)
end

function RoomController:SVR_OTHER_CARD(pack)
    local ctx = self.ctx
    local model = self.model
    model:processGetPokerBySelf(pack)
    ctx.dealCardManager:dealCardToPlayer(self.model:selfSeatId())
end

-- 亮牌
function RoomController:SVR_SHOW_CARD(pack)
    local model = self.model
    model:processShowHand(pack)
    --这里只标注需要亮牌,亮牌动画在发牌动画结束之后
end

-- 连续不操作被踢出房间
function RoomController:SVR_KICK_OUT(pack)
    if pack.count and pack.count > 0 then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("PDENG", "BACK_TIPS_WHEN_NO_OPR", pack.count))
    end
end

-- 被其他人踢出房间
function RoomController:SVR_KICKED_BY_USER_NEW(pack)
    if pack.kickedUid and pack.kickedUid == nk.userData.uid then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("VIP", "KICKED_TIP", pack.kickerNick))
    end
end

-- 广播发牌 
function RoomController:SVR_CARD_NUM(pack)
    local ctx = self.ctx
    local model = self.model

    model:processPot(pack)
    ctx.lampManager:hide()
    -- if not model:isSelfDealer() then  
    --     ctx.oprManager:updateOperationStatus()
    -- end
    ctx.oprManager:hideBetButtons(true)
    -- ctx.oprManager:updateOperationStatus()
    if not model:isSelfInSeat() then
        ctx.seatManager:prepareDealCards()   
        ctx.dealCardManager:dealCards()   
    end
end


function RoomController:SVR_GAME_OVER(pack)
    local ctx = self.ctx
    local model = self.model
    self.gameSchedulerPool:clearAll()
    model:processGameOver(pack)
    --隐藏灯光
    ctx.lampManager:hide()
    --禁用操作按钮
    ctx.oprManager:blockOperationButtons()
    --座位停止计时器
    ctx.seatManager:stopCounter()
    --亮牌
    self.seatManager:showHandCard()

    -- 延迟处理
    local resetDelayTime = 6
    local chipDelayTime = 0
    -- local dealer = model:dealerSeatData()
    -- if dealer and checkint(dealer.trunMoney) < 0  then
    --     ctx.chipManager:betChipToPot(dealer)
    --     chipDelayTime = 0
    -- else
    --     chipDelayTime = 0
    -- end
    for i = 0, 9 do
        local player = model.playerList[i]
        if player and checkint(player.trunMoney) < 0 then
            ctx.chipManager:betChipToPot(player)
            if player.isSelf then
                ctx.seatManager:playChipDoubleChangeAnimation()
            end
        end
    end

    self.schedulerPool:delayCall(function ()
        ctx.chipManager:gatherPot()        
    end, chipDelayTime)

    -- 分奖池动画 ,播放Winner动画
    self.schedulerPool:delayCall(function ()
        ctx.chipManager:splitPots()        
    end, chipDelayTime + 1)

    self.schedulerPool:delayCall(function ()
        --座位经验值变化动画
        ctx.seatManager:playExpChangeAnimation()   
        local player = model.playerList[model:selfSeatId()]
        if player then
            ctx.oprManager:updateCurMoney(player.seatChips)
        end
    end, chipDelayTime + 3)

    -- 刷新游戏状态
    self.schedulerPool:delayCall(handler(self, self.reset), resetDelayTime)
end


function RoomController:processPacket_(pack)
    print("RoomController:processPacket_")
    if self.func_[pack.cmd] then
        self.func_[pack.cmd](pack)
    end   
end

--申请自动坐下
function RoomController:applyAutoSitDown()
    if not self.model:isSelfInGame() then
        local emptySeatId = self.seatManager:getEmptySeatId()
        if emptySeatId then
            local isAutoSit = nk.userDefault:getBoolForKey(nk.cookieKeys.AUTO_SIT, true)
            if isAutoSit or nk.socket.RoomSocket:isPlayNow() then
                local userData = nk.userData
                local money = userData.money
                if money >= self.model.roomInfo.minBuyIn then
                    logger:debug("auto sit down", emptySeatId)
                    nk.socket.RoomSocket:sendSeatDownPdeng(emptySeatId, money)
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
                                        messageText = bm.LangUtil.getText("WHEEL", "NOTENOUGHMONEY"), 
                                        secondBtnText = bm.LangUtil.getText("ROOM", "CHARGE_CHIPS"), 
                                        callback = function (type)
                                            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
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
    if self.model:isSelfInSeat() and not self.model:isSelfDealer() then
        self.scene:setChangeRoomButtonMode(2)
    else
        self.scene:setChangeRoomButtonMode(1)
    end
end

function RoomController:reset()
    self.hasReset_ = true
    if self.model:isChangeDealer() then
        self.animManager:moveDealerTo(10, true)
    end
    
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


return RoomController