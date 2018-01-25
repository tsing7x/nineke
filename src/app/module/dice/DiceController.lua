--
-- Author: Jonah0608@gmail.com
-- Date: 2016-08-29 09:54:26
--
local DiceController = class("DiceController")

local DiceModel = import(".DiceModel")
local OperManager = import(".OperManager")
local BetTypeManager = import(".BetTypeManager")
local DiceSeatManager = import(".DiceSeatManager")
local DiceDealManager = import(".DiceDealManager")
local DiceChipManager = import(".DiceChipManager")
local DiceAnimManager = import(".DiceAnimManager")
local UserCrash        = import("app.module.room.userCrash.UserCrash")
local NewUserCrash     = import("app.module.room.userCrash.NewUserCrash")

DiceController.EVT_PACKET_RECEIVED = nk.socket.HallSocket.EVT_PACKET_RECEIVED

local PACKET_PROC_FRAME_INTERVAL = 1

function DiceController:ctor(scene)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    local ctx = {}
    ctx.diceController = self
    ctx.scene = scene
    ctx.model = DiceModel.new()
    ctx.controllerEventProxy = cc.EventProxy.new(self, scene)
    ctx.schedulerPool = bm.SchedulerPool.new()
    ctx.sceneSchedulerPool = bm.SchedulerPool.new()
    ctx.gameSchedulerPool = bm.SchedulerPool.new()

    ctx.operManager = OperManager.new()
    ctx.diceSeatManager = DiceSeatManager.new()
    ctx.betTypeManager = BetTypeManager.new()
    ctx.diceDealManager = DiceDealManager.new()
    ctx.diceChipManager = DiceChipManager.new()
    ctx.animManager = DiceAnimManager.new()
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
    ctx.export(ctx.operManager)
    ctx.export(ctx.diceSeatManager)
    ctx.export(ctx.betTypeManager)
    ctx.export(ctx.diceDealManager)
    ctx.export(ctx.diceChipManager)
    ctx.export(ctx.animManager)

    cc.EventProxy.new(nk.socket.HallSocket, scene)
        :addEventListener(DiceController.EVT_PACKET_RECEIVED, handler(self, self.onPacketReceived_))
        :addEventListener(nk.socket.HallSocket.EVT_CONNECTED, handler(self, self.onConnected_))
    self.loginDiceFailListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.LOGIN_DICE_FAIL, handler(self, self.onLoginDiceFail_))
    self.diceConnProblemListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.DICE_CONN_PROBLEM, handler(self, self.onLoginDiceFail_))
    self.serverStopListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.SERVER_STOPPED, handler(self, self.onServerStop_))

    self.packetCache_ = {}
    self.loginRoomRetryTimes_ = 0
    self.frameNo_ = 1

    ctx.sceneSchedulerPool:loopCall(handler(self, self.onEnterFrame_), 1 / 30)
    ctx.sceneSchedulerPool:loopCall(function()
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
        return not self.isDisposed_
    end, 60)
end

function DiceController:dispose()
    self.isDisposed_ = true
    self.schedulerPool:clearAll()
    self.sceneSchedulerPool:clearAll()
    self.gameSchedulerPool:clearAll()
    self.animManager:dispose()
    -- self.operManager:dispose()
    -- self.betTypeManager:dispose()
    -- self.diceSeatManager:dispose()
    -- self.diceDealManager:dispose()
    -- self.diceChipManager:dispose()
    bm.EventCenter:removeEventListener(self.loginDiceFailListenerId_)
    bm.EventCenter:removeEventListener(self.diceConnProblemListenerId_)
    bm.EventCenter:removeEventListener(self.serverStopListenerId_)
end

function DiceController:createNodes()
    self.operManager:createNodes()
    self.betTypeManager:createNodes()
    self.diceSeatManager:createNodes()
    self.diceDealManager:createNodes()
    self.diceChipManager:createNodes()
    self.animManager:createNodes()
    nk.socket.HallSocket:resume()
end

function DiceController:onLoginDiceFail_(evt)
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

                    nk.socket.HallSocket:disconnectDice()
                    nk.socket.HallSocket:connectToDice(evt.data.ip, evt.data.port, evt.data.tid)
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

--弹出登出提示弹窗
function DiceController:onServerStop_(evt)
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

function DiceController:onConnected_(evt)
    self.packetCache_ = {}
    self.loginRoomRetryTimes_ = 0
end

function DiceController:onEnterFrame_(dt)
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
                if v.cmd == nk.socket.HallSocket.PROTOCOL.SVR_GAME_RESULT_DICE then
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

function DiceController:onPacketReceived_(evt)
    local P = nk.socket.HallSocket.PROTOCOL
    if evt.packet.cmd == P.SVR_BET_SUCC_DICE then
        -- return
    elseif evt.packet.cmd == P.SVR_BRO_SITUSER_BET_DICE then
        if evt.packet.uid == nk.userData.uid then
            return
        end
    end
    table.insert(self.packetCache_, evt.packet)
end

function DiceController:processPacket_(pack)
    local cmd = pack.cmd
    local ctx = self.ctx
    local model = self.model
    local P = nk.socket.HallSocket.PROTOCOL
    printf("DiceController.processPacket[%x]%s", cmd, table.keyof(P, cmd))
    if cmd == P.SVR_LOGIN_SUCCESS_DICE then
        if self.roomLoading_ then
            self.roomLoading_:removeFromParent()
            self.roomLoading_ = nil
        end
        if self.scene and self.scene.roomLoading_ then
            self.scene.roomLoading_:removeFromParent()
            self.scene.roomLoading_ = nil
        end
        self:reset()
        nk.socket.HallSocket:getDiceHistory()
        model:initWithLoginSuccessPack(pack)
        ctx.operManager:setBaseChips(model.roomInfo.basechip)
        ctx.betTypeManager:setRate(model.roomInfo.rates)
        ctx.diceSeatManager:resetBindIds()
        ctx.diceSeatManager:initSeats(model.playerList)
        ctx.operManager:updateCurMoney(pack.curChips)
        self.scene:setRoomInfoText(model.roomInfo)
        if pack.state == consts.DICE_STATE.STATE_STOP then
            ctx.betTypeManager:setButtonEnabled(false)
        elseif pack.state == consts.DICE_STATE.STATE_READY then
            ctx.diceDealManager:reset()
            ctx.betTypeManager:reset()
            ctx.diceChipManager:reset()
            ctx.diceDealManager:showCardAndDeal()
            ctx.betTypeManager:setButtonEnabled(false)
        elseif pack.state == consts.DICE_STATE.STATE_BET then
            ctx.diceDealManager:reset()
            ctx.diceDealManager:showCardAndDeal()
            ctx.diceDealManager:showClock(pack.timeout)
            ctx.betTypeManager:setButtonEnabled(true)
            ctx.betTypeManager:updateMyBet(pack.betState)
            ctx.betTypeManager:updateAllBet(pack.typeBet)
            ctx.diceChipManager:updateAllChips(pack.typeBet)
        end
    elseif cmd == P.SVR_BET_SUCC_DICE then
        if pack.ret == 0 then
            ctx.diceChipManager:betChipSelf(pack.betType,pack.betChip,0,0,function()
                ctx.betTypeManager:updateMyChips(pack.betType,pack.betChip)
                ctx.operManager:updateCurMoney(pack.curChip)
                ctx.operManager:updateBetButtonState()
            end)
            model:processSelfBetSuccess(pack)
        elseif pack.ret == 2 then
            if pack.maxBetChip and pack.maxBetChip>0 then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM","BET_LIMIT_1",bm.formatBigNumber(pack.maxBetChip)))
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM","BET_LIMIT"))
            end
        end
    elseif cmd == P.SVR_BRO_USER_SIT_DICE then
        local seatId,isSelf = model:processSitDown(pack)
        if not isSelf then
            ctx.diceSeatManager:updateUserSitDown(seatId)
        end
    elseif cmd == P.SVR_BRO_GAME_START_DICE then
        self.gameSchedulerPool:clearAll()
        ctx.diceDealManager:reset()
        ctx.betTypeManager:reset()
        ctx.diceChipManager:reset()
        ctx.scene:hideResultPopup()
        ctx.diceDealManager:showStartAnim()
        model:processGameStart(pack)
        ctx.operManager:buyInMoney(pack.chips)
        if nk.userData.money + nk.userData.bank_money < appconfig.CRASHMONEY then
            if not self.hadShowCrashPop then
                self.hadShowCrashPop = true
                self:processCrash(0,0)
            end
        else
            self.hadShowCrashPop = false
            if pack.chips < model.roomInfo.basechip then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("DICE", "NOT_ENOUGH_MONEY", model.roomInfo.basechip))
            end
        end
    elseif cmd == P.SVR_BRO_START_BET_DICE then
        ctx.diceDealManager:hideStartAnim()
        self.animManager:playTipsAnim("start",function()
                ctx.diceDealManager:showClock(pack.timeout,function()
                    ctx.betTypeManager:setButtonEnabled(false)
                    ctx.operManager:stopBetButton()
                end)
                ctx.betTypeManager:setButtonEnabled(true)
                ctx.operManager:updateBetButtonState()
            end)
    elseif cmd == P.SVR_BRO_SITUSER_BET_DICE then
    elseif cmd == P.SVR_BRO_OTHER_BET_DICE then
        for i,v in pairs(pack.otherBet) do
            ctx.diceChipManager:betChipOther(v.betType,v.betChip,function()
                ctx.betTypeManager:updateAllChips(v.betType,v.betChip)
            end)
        end
        for i,sitBetData in pairs(pack.sitBet) do
            if sitBetData.uid == nk.userData.uid then
                return
            end
            for k,betData in pairs(sitBetData.betData) do
                ctx.diceChipManager:betChip(sitBetData.uid,betData.betType,betData.betChip,function()
                    ctx.betTypeManager:updateAllChips(betData.betType,betData.betChip)
                end)
            end
        end
    elseif cmd == P.SVR_GAME_RESULT_DICE then
        ctx.diceDealManager:stopClock()
        ctx.betTypeManager:setButtonEnabled(false)
        ctx.operManager:stopBetButton()
        self.animManager:playTipsAnim("result",function()
            end)
        local result = model:processResult(pack)
        ctx.diceDealManager:setCardsResult(result.carddata_)
        self.gameSchedulerPool:delayCall(function ()
            ctx.betTypeManager:updateHistory(pack.res,pack.winresult)
            ctx.diceDealManager:showWinType(result.windata_)
            ctx.diceChipManager:showWinResult(result.windata_,result.windeal)
        end, 2)
        self.gameSchedulerPool:delayCall(function ()
            if #pack.betresult > 0 then
                local wintype = 1
                for i,v in pairs(pack.betresult) do
                    if v.winChip > 0 then
                        if v.type < 4 then
                            wintype = 2
                        elseif v.type < 7 then
                            wintype = 3
                        end
                    end
                end
                ctx.scene:showResultPopup(pack.turnChip,wintype)
            end
            ctx.operManager:updateCurMoney(pack.curChips)
        end, 5)
        
    elseif cmd == P.SVR_BRO_USER_EXIT_DICE then
        local seatId = model:processStandUp(pack)
        ctx.diceSeatManager:updateUserStandUp(seatId)
    elseif cmd == P.SVR_LOGOUT_SUCC_DICE then
        nk.userData.money = pack.money
        if pack.ret == 1 then
            nk.ui.Dialog.new({
                messageText = bm.LangUtil.getText("DICE", "NO_OPER_TIPS"), 
                hasFirstButton = false,
                hasCloseButton = false,
                callback = function (type)
                    if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                        ctx.scene:doBackToHall()
                    end
                end
            }):show()
        elseif pack.ret == 2 then
            nk.ui.Dialog.new({
                messageText = bm.LangUtil.getText("DICE", "MONEY_NOT_ENOUGH"), 
                hasFirstButton = false,
                hasCloseButton = false,
                callback = function (type)
                    if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                        ctx.scene:doBackToHall()
                    end
                end
            }):show()
        else
            ctx.scene:doBackToHall()
        end
    elseif cmd == P.SVR_GET_HISTORY then
        self.betTypeManager:setHistory(pack.history)
    elseif cmd == P.SVR_SEND_ROOM_BROADCAST then
        local mtype, jsonTable, param1, param2, param3, param4, param5 = model:processRoomBroadcast(pack)
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
                --更新最近聊天文字
                self.operManager:setLatestChatMsg(msg)
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
            self.animManager:playExpression(jsonTable.seatId, jsonTable.uid, jsonTable.expressionId)
        end
    elseif cmd == P.SVR_SEND_EXPRESSION_DICE then
        self.animManager:playExpression(pack.seatId,pack.uid,pack.expressionId)
    elseif cmd == P.SVR_SEND_DEALER_CHIP_SUCC_DICE then
        --给荷官赠送筹码
        self.animManager:playSendToDealChipAnimation(pack.fromSeatId,pack.fromUid, 
            pack.receiverID, pack.chips)
    elseif cmd == P.SVR_CMD_SEND_DEALER_CHIP_FAIL then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SELF_CHIP_NO_ENOUGH_SEND_DELEAR"))
    elseif cmd == P.SVR_SEND_CHIPS_SUCC_DICE or cmd == P.SVR_SEND_CHIPS_SUCC_1 then
        self.animManager:playSendChipAnimation(pack.fromSeatId,pack.fromUid,
             pack.toSeatId,pack.toUid, pack.chips)
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
    elseif cmd == P.SVR_ADD_FRIEND_SUCC_DICE then
        --用户加牌友
        self.animManager:playAddFriendAnimation(pack.fromSeatId,pack.fromUid, pack.toSeatId,pack.toUid)
    elseif cmd == P.SVR_SEND_HDDJ_SUCC then
        local isRecv = true
        if pack.fromUid == tonumber(nk.userData.uid) then 
            isRecv = false
        end
        self.animManager:playHddjAnimation(pack.fromSeatId,pack.toSeatId,pack.daojuType,pack.fromUid,pack.toUid, isRecv)
    elseif cmd == P.SVR_USER_COUNT then
        model.curcount = pack.seatnum + pack.looknum
        bm.EventCenter:dispatchEvent({name="UserCountChange"})
    elseif cmd == P.SVR_GET_ALL_USERINFO then
        bm.EventCenter:dispatchEvent({name="getPageUser",data=pack})
    elseif cmd == P.SVR_WILL_KICK_OUT then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("DICE", "KICK_OFF"))
    elseif cmd == P.SVR_KICKED_BY_USER_NEW then
        --被用户踢出房间
        if pack.kickedUid and pack.kickedUid == nk.userData.uid then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("VIP", "KICKED_TIP", pack.kickerNick))
        end
    elseif cmd == P.SVR_MODIFY_USERINFO then
        local seatId = model:svrModifyUserinfo(pack)
        if seatId == 9 then
            self.ctx.operManager:updateInfo()
            return
        end
        if seatId > 0 then
            self.ctx.diceSeatManager:updateSeatState(seatId)
        end

    end
end

-- 上报破产
function DiceController:reportUserCrash_(times, subsidizeChips)
    if self.model ~= nil  and self.model.roomInfo ~= nil then
        bm.HttpService.POST({mod="bankruptcy", act="reportCenter", 
            uphillPouring = self.model.roomInfo.blind, 
            playground = tostring(self.model:roomType()), 
            money = subsidizeChips,  -- 救济钱数  = 0表示破产没有救济
            times = times -- 第几次救济
        })
    end
end

function DiceController:processCrash(times, subsidizeChips)
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

function DiceController:processCrash_(times, subsidizeChips, phpCrashChips,waitTimes)  
    if nk.userData.money + nk.userData.bank_money < appconfig.CRASHMONEY then     
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

--新版破产处理
function DiceController:newCrashHandle_(data)
    if data.ret == 1 then --可以领取
        NewUserCrash.new(1, data.reward):show()
        self:playBoxRewardAnimation_(data.reward)
    elseif data.ret == -1 then --已经超过3次
        NewUserCrash.new(2, nk.userData.inviteBackReward):show()
    end
end

function DiceController:playBoxRewardAnimation_(money)
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

function DiceController:forbidChat(uid)
    if not uid then
        self.forbidChatList = {}
    else
        if not self.forbidChatList then
            self.forbidChatList = {}
        end
        self.forbidChatList[uid] = true
    end
end

function DiceController:reset()
    self.schedulerPool:clearAll()
    self.gameSchedulerPool:clearAll()
end

function DiceController:requestBet(type,chip,x,y)
    if self.ctx.operManager:getCurMoney() <= 0 then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("DICE", "BET_FAIL"))
        return false
    end
    local bet = chip
    if self.ctx.operManager:getCurMoney() < chip then
        bet = self.ctx.operManager:getCurMoney()
    end
    self.ctx.model.isbet_ = true
    nk.socket.HallSocket:sendBetDice(type,bet)
    return true
end

return DiceController