--
-- Author: tony
-- Date: 2014-07-17 15:20:01
--
local OperationButton = import(".views.OperationButton")
local OperationButtonGroup = import(".views.OperationButtonGroup")
local RaiseSlider = import(".views.RaiseSlider")
local RoomImageButton = import(".views.RoomImageButton")
local ChatMsgPanel = import(".views.ChatMsgPanel")
local RoomTipsView = import(".views.RoomTipsView")
local ExtOperationView = import(".views.ExtOperationView")
local OperationManager = class("OperationManager")

local LB_FOLD = bm.LangUtil.getText("ROOM", "FOLD")
local LB_CHECK = bm.LangUtil.getText("ROOM", "CHECK")
local LB_CALL = bm.LangUtil.getText("ROOM", "CALL").." "
local LB_RAISE = bm.LangUtil.getText("ROOM", "RAISE")
local LB_RAISE_NUM = bm.LangUtil.getText("ROOM", "RAISE_NUM", "%%s")
local LB_AUTO_CHECK = bm.LangUtil.getText("ROOM", "AUTO_CHECK")
local LB_AUTO_CHECK_OR_FOLD = bm.LangUtil.getText("ROOM", "AUTO_CHECK_OR_FOLD")
local LB_AUTO_CALL = bm.LangUtil.getText("ROOM", "CALL_NUM", "%%s")
local LB_AUTO_FOLD = bm.LangUtil.getText("ROOM", "AUTO_FOLD")
local LB_AUTO_CALL_ANY = bm.LangUtil.getText("ROOM", "AUTO_CALL_ANY")

function OperationManager:ctor()
    self.schedulerPool_ = bm.SchedulerPool.new()
end

function OperationManager:createNodes()
    --聊天按钮
    self.chatNode_ = display.newNode():pos(8, 6):addTo(self.scene.nodes.oprNode, 2, 2)
    self.chatNode_:setAnchorPoint(cc.p(0, 0))
    local chatW = math.round(display.width * 0.32)
    local padding = math.round((display.width * 0.05 - 16) / 4)
    local oprBtnW = math.round((display.width - 16 - chatW - 4 * padding) / 3)

    --- new ---
    self.chatBtn_ = cc.ui.UIPushButton.new({normal = {"#common_btn_bg_normal.png","#room_chat_icon_normal.png"},pressed = {"#common_btn_bg_pressed.png","#room_chat_icon_pressed.png"}})
        :onButtonClicked(function()
            nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
            self.chatPanel_ = ChatMsgPanel.new(self.ctx)
            self.chatPanel_:showPanel()
        end)
        :pos(43, 39)
        :addTo(self.chatNode_)

    self.raiseSlider_ = RaiseSlider.new()
        :onButtonClicked(buttontHandler(self, self.onRaiseSliderButtonClicked_))
        :pos(display.right - 110, 275 + 80 + 2)
        :addTo(self.scene.nodes.popupNode, 3, 3)
        :hide()

    RoomTipsView.WIDTH = display.width * 0.7 - 16 - padding
    self.tipsView_ = RoomTipsView.new():pos(display.right - 8 - RoomTipsView.WIDTH * 0.5, display.bottom + 44):addTo(self.scene.nodes.oprNode, 4, 4)

    ExtOperationView.WIDTH = display.width * 0.7 - 16 - padding
    self.extOptView_ = ExtOperationView.new(self.seatManager):pos(display.right - 8 - ExtOperationView.WIDTH * 0.5, display.bottom + 44):addTo(self.scene.nodes.oprNode, 4, 4)
        :setShowHandcardCallback(handler(self, self.showHandcardCallback_))

    self.oprNode_ = display.newNode():pos(display.right - 8, display.bottom + 44):addTo(self.scene.nodes.oprNode, 5, 5)
    self.checkGroup_ = OperationButtonGroup.new()
    OperationButton.BUTTON_WIDTH = oprBtnW
    self.oprBtn1_ = OperationButton.new(""):setLabel(LB_CHECK):pos(- oprBtnW * 2.5 - 2 * padding, 0):addTo(self.oprNode_)
    self.oprBtn2_ = OperationButton.new("_red"):setLabel(LB_CALL):pos(- oprBtnW * 1.5 - padding, 0):addTo(self.oprNode_)
    self.oprBtn3_ = OperationButton.new("_yellow"):setLabel(LB_RAISE):pos(-oprBtnW * 0.5, 0):addTo(self.oprNode_)

    self.checkGroup_:add(1, self.oprBtn1_)
    self.checkGroup_:add(2, self.oprBtn2_)
    self.checkGroup_:add(3, self.oprBtn3_)
    self.scene:addEventListener(self.scene.EVT_BACKGROUND_CLICK, handler(self, self.onBackgroundClicked))


    self.mainBtnWidth_ = oprBtnW
    self.fastBtnWidth_ = math.round((chatW-5*4)/3)
    self.fastBtnHeight_ = 73
    self.fastBtnPadding_ = self.fastBtnWidth_+12
    self.fastBtnStart_ = self.fastBtnWidth_*0.5 + 16

    self.normalBtnWidth_ = math.round((display.width - self.mainBtnWidth_ - 7*padding)/5)
    self.normalPadding_ = padding
    self.oprFastNode_ = display.newNode()
        :pos(-display.width, 0)
        :addTo(self.oprNode_)

    self.oprFastNode_:setContentSize(cc.size(316,65))
    self.oprFastNode_:hide()
    
    self.blind3Btn_ = self:createAddFastBtn(1)
    self.blind3Btn_:pos(self.fastBtnStart_, 0):addTo(self.oprFastNode_)
    self.blind3Btn_:getButtonLabel("normal"):setString(bm.LangUtil.getText("ROOM", "BLIND3"))
        
    self.blind4Btn_ = self:createAddFastBtn(1)
    self.blind4Btn_:pos(self.fastBtnStart_+self.fastBtnPadding_, 0):addTo(self.oprFastNode_)
    self.blind4Btn_:getButtonLabel("normal"):setString(bm.LangUtil.getText("ROOM", "BLIND4"))
    
    self.totalChipsInTable_ = self:createAddFastBtn(1)
    self.totalChipsInTable_:pos(self.fastBtnStart_+self.fastBtnPadding_*2, 0):addTo(self.oprFastNode_)
    self.totalChipsInTable_:getButtonLabel("normal"):setString(bm.LangUtil.getText("ROOM", "TABLECHIPS"))

    self.oprFastNode_.show = function(obj)
        cc.Node.show(obj)
        self:setAddBtnStatus()
    end
end

function OperationManager:setLatestChatMsg(msg)
end

function OperationManager:createAddFastBtn(type)
    local BG_W,BG_H = self.normalBtnWidth_,73
    local buttonSize,buttonColor = 22,cc.c3b(0xfF, 0xfF, 0xfF)
    local resTable = {
        normal="#room_opr_check_up.png", 
        pressed="#room_opr_check_down.png",
    }
    if type==1 then
        BG_W,BG_H = math.round(display.width * 0.32)/3-5*2,73
        resTable = {
            normal="#room_opr_fast_up.png", 
            pressed="#room_opr_fast_down.png",
        }
    elseif type==2 then
        BG_W = self.mainBtnWidth_
        resTable = {
            normal="#room_opr_btn_up_yellow.png", 
            pressed="#room_opr_btn_down_yellow.png",
        }
    end
    local btn = cc.ui.UIPushButton.new(resTable, {scale9 = true})
        :setButtonLabel(ui.newTTFLabel({
            text = "",
            size = (type==2) and 24 or buttonSize,
            color = buttonColor,
            align = ui.TEXT_ALIGN_CENTER}))
        :setButtonLabelOffset(0,5)
        :setButtonSize(BG_W, BG_H)
    btn.setButtonEnabled = function(obj,value)
        if value==true then
            obj:setColor(cc.c3b(255,255,255))
            cc.ui.UIPushButton.super.setButtonEnabled(obj,true)
        else
            obj:setColor(cc.c3b(150, 150, 150))
            cc.ui.UIPushButton.super.setButtonEnabled(obj,false)
        end
    end
    btn:onButtonClicked(function()
        btn:setButtonEnabled(false)
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
        self:onAddFastBtnHandler(btn)
    end)
    return btn
end

function OperationManager:onAddFastBtnHandler(btn)
    if btn==self.blind3Btn_ then
        self:reportPlayData_("CALL_RAISE")
        nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.CALL, self.model.roomInfo.blind*3)
    elseif btn==self.blind4Btn_ then
        self:reportPlayData_("CALL_RAISE")
        nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.CALL, self.model.roomInfo.blind*4)
    elseif btn==self.totalChipsInTable_ then
        self:onRaiseSliderButtonClicked_(1)
    elseif btn==self.blind5Btn_ then
        self:reportPlayData_("CALL_RAISE")
        nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.CALL, self.model.roomInfo.blind*5)
    elseif btn==self.blind10Btn_ then
        self:reportPlayData_("CALL_RAISE")
        nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.CALL, self.model.roomInfo.blind*10)
    elseif btn==self.blind25Btn_ then
        self:reportPlayData_("CALL_RAISE")
        nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.CALL, self.model.roomInfo.blind*25)
    elseif btn==self.blind50Btn_ then
        self:reportPlayData_("CALL_RAISE")
        nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.CALL, self.model.roomInfo.blind*50)
    elseif btn==self.blind100Btn_ then
        self:reportPlayData_("CALL_RAISE")
        nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.CALL, self.model.roomInfo.blind*100)
    elseif btn==self.addConfirmBtn_ then
        if self.raiseSlider_:isVisible() then
            if self.raiseSlider_:getSliderPercentValue() == 1 then
                self:reportPlayData_("ALL_IN")
            else
                self:reportPlayData_("CALL_RAISE")
            end
            nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.CALL, self.raiseSlider_:getValue())
        end
    end
    self.raiseSlider_:hidePanel()
    self:disabledStatus_()
    if self.addNode_ then
        self.addNode_:hide()
    end
end

function OperationManager:dispose()
    self.schedulerPool_:clear(self.showOptSchedulerId)
end

function OperationManager:showOperationButtons(animation)
    self.showOped_ = true
    self.oprNode_:stopAllActions()
    self.extOptView_:hide()
    if animation then
        self.oprNode_:show():moveTo(0.5, display.right - 8, display.bottom + 44)
        transition.moveTo(self.tipsView_, {y = -80, time=0.5, onComplete=function() self.tipsView_:hide():stop() end})
    else
        self.oprNode_:show():pos(display.right - 8, display.bottom + 44)
        self.tipsView_:hide():setPositionY(-80):stop()
    end
end

function OperationManager:hideOperationButtons(animation)
    self.showOped_ = false
    self.oprNode_:stopAllActions()
    self.extOptView_:hide()
    if animation then
        self.tipsView_:show():play():moveTo(0.5, display.right - 8 - RoomTipsView.WIDTH * 0.5, display.bottom + 44)
        transition.moveTo(self.oprNode_, {y=-80, time=0.5, onComplete=function() self.oprNode_:hide() end})
    else
        self.oprNode_:hide():setPositionY(-80)
        self.tipsView_:show():play():setPositionY(display.bottom + 44)
    end
end

function OperationManager:showExtOperationView(animation)
    self.oprNode_:hide()
    self.tipsView_:hide()
    self.extOptView_:show()
    self.showOptSchedulerId = self.schedulerPool_:delayCall(function()
        self.extOptView_:hide()
        self.oprNode_:show()
    end, 3)
end

function OperationManager:showHandcardCallback_()
    self.schedulerPool_:clear(self.showOptSchedulerId)
    self.extOptView_:hide()
    self.oprNode_:show()
    self:blockOperationButtons()
end

function OperationManager:blockOperationButtons()
    self:disabledStatus_()
end

function OperationManager:resetAutoOperationStatus()
    self.checkGroup_:onChecked(nil):uncheck()
    self.autoAction_ = nil
end

function OperationManager:updateOperationStatus()
    local callChips = self.model.gameInfo.callChips
    local minRaiseChips = self.model.gameInfo.minRaiseChips
    local maxRaiseChips = self.model.gameInfo.maxRaiseChips
    local bettingSeatId = self.model.gameInfo.bettingSeatId
    local selfSeatId = self.model:selfSeatId()
    printf("updateOperationStatus==> %s=%s", "callChips", callChips)
    printf("updateOperationStatus==> %s=%s", "minRaiseChips", minRaiseChips)
    printf("updateOperationStatus==> %s=%s", "maxRaiseChips", maxRaiseChips)
    printf("updateOperationStatus==> %s=%s", "bettingSeatId", bettingSeatId)
    printf("updateOperationStatus==> %s=%s", "isSelfInSeat", self.model:isSelfInSeat())
    printf("updateOperationStatus==> %s=%s", "isSelfInGame", self.model:isSelfInGame())

    self.schedulerPool_:clear(self.showOptSchedulerId)
    self.extOptView_:hide()
    self.oprNode_:show()
    if not self.model:isSelfInSeat() or not self.model:isSelfInGame() or bettingSeatId == -1 then
        --自己不在座 或 自己不在游戏 或 没在下注
        self:disabledStatus_()
    else
        local seatChips = self.model:selfSeatData().seatChips
        printf("updateOperationStatus==> %s=%s", "seatChips", seatChips)
        if selfSeatId == bettingSeatId then
            --轮到自己操作
            if self:applyAutoOperation_() then
                --自动操作已经触发，则直接禁用操作栏
                printf("updateOperationStatus==> %s=%s", "applyAutoOperation_", true)
                self:disabledStatus_()
            else
                printf("updateOperationStatus==> %s=%s", "applyAutoOperation_", false)
                if callChips > 0 then
                    --需要下注
                    if seatChips > callChips then
                        --有钱足够加注
                        if minRaiseChips == maxRaiseChips then
                            --没有加注空间
                            if callChips == minRaiseChips then
                                --加注和跟注值是一样的，当做不能加注处理
                                self:selfCannotRaiseStatus_()
                            else
                                self:selfCanRaiseFixedStatus_(minRaiseChips)
                            end
                        else
                            --有加注空间
                            self:selfCanRaiseStatus_(minRaiseChips, maxRaiseChips)
                        end
                    else
                        --自己没钱加注
                        self:selfCannotRaiseStatus_()
                    end
                else
                    --不需要下注
                    if minRaiseChips == maxRaiseChips then
                        --没有加注空间
                        self:selfNoBetCanRaiseFixedStatus_(minRaiseChips)
                    else
                        --有加注空间
                        self:selfNoBetCanRaiseStatus_(minRaiseChips, maxRaiseChips)
                    end
                end
            end
        else
            --轮到别人操作
            if seatChips > 0 then
                --自己没有all in
                if self.model.gameInfo.hasRaise then
                    --有加注
                    self:otherBetStatus_(math.min(self.model:currentMaxBetChips() - self.model:selfSeatData().betChips, self.model:selfSeatData().seatChips))
                elseif self.model.gameInfo.bettingSeatId ~= -1 and self.model:selfSeatData() then
                    --没有加注
                    self:otherNoBetStatus_(self.model.playerList[self.model.gameInfo.bettingSeatId].betChips - self.model:selfSeatData().betChips)
                end
            else
                --自己已经all in
                self:disabledStatus_()
            end
        end
    end
    self.raiseSlider_:hidePanel()
    if self.addNode_ then
        self.addNode_:hide()
    end
end

function OperationManager:setSliderStatus(minRaiseChips, maxRaiseChips)
    local selfSeatData = self.model:selfSeatData()
    local totalChipsInTable = self.model:totalChipsInTable()
    local currentMaxBetChips = self.model:currentMaxBetChips()
    print("totalChipsInTable -----> " .. totalChipsInTable)
    print("currentMaxBetChips ----> " .. currentMaxBetChips)
    self.raiseSlider_:setButtonStatus(
        totalChipsInTable >= minRaiseChips and totalChipsInTable <= maxRaiseChips,                 --全部奖池按钮
        totalChipsInTable * 0.75 >= minRaiseChips and totalChipsInTable * 0.75 <= maxRaiseChips,--3/4奖池按钮
        totalChipsInTable * 0.5 >= minRaiseChips and totalChipsInTable * 0.5 <= maxRaiseChips,    --1/2奖池按钮
        currentMaxBetChips * 3 >= minRaiseChips and currentMaxBetChips * 3 <= maxRaiseChips,    --3倍反加按钮
        maxRaiseChips == selfSeatData.seatChips                                              --最大加注是否allin
    )
    self.raiseSlider_:setValueRange(minRaiseChips, maxRaiseChips)
end

--无法操作的状态
function OperationManager:disabledStatus_()
    self.oprBtn1_:setLabel(LB_CHECK):setEnabled(false):setCheckMode(false)
    self.oprBtn2_:setLabel(LB_FOLD):setEnabled(false):setCheckMode(false)
    self.oprBtn3_:setLabel(LB_RAISE):setEnabled(false):setCheckMode(false)
    self.raiseSlider_:hidePanel()
    self.oprFastNode_:hide()
    self.chatBtn_:show()
    if self.addNode_ then
        self.addNode_:hide()
    end
end

--轮到自己，可以加注状态
function OperationManager:selfCanRaiseStatus_(minRaiseChips, maxRaiseChips)
    local callMoney = 0
    local callChips = self.model.gameInfo.callChips
    local seatChips = self.model:selfSeatData().seatChips
    if seatChips>callChips then
        callMoney = callChips
    else
        callMoney = seatChips
    end
    self.oprBtn1_:setLabel(LB_CALL..bm.formatBigNumber(callMoney)):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.callClickHandler))
    self.oprBtn2_:setLabel(LB_FOLD):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.foldClickHandler))
    self.oprBtn3_:setLabel(LB_RAISE):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.raiseRangeClickHandler))
    self:setSliderStatus(minRaiseChips, maxRaiseChips)
    self.oprFastNode_:show()
    self.chatBtn_:hide()
end

--轮到自己，只能加固定注状态
function OperationManager:selfCanRaiseFixedStatus_(raiseChips)
    local callMoney = 0
    local callChips = self.model.gameInfo.callChips
    local seatChips = self.model:selfSeatData().seatChips
    if seatChips>callChips then
        callMoney = callChips
    else
        callMoney = seatChips
    end
    self.raiseFixedChips_ = raiseChips
    self.oprBtn1_:setLabel(LB_CALL..bm.formatBigNumber(callMoney)):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.callClickHandler))
    self.oprBtn2_:setLabel(LB_FOLD):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.foldClickHandler))
    -- self.oprBtn3_:setLabel(string.format(LB_RAISE_NUM, raiseChips)):setEnabled(false):setCheckMode(false):onTouch(handler(self, self.raiseFixedClickHandler))
    self.oprBtn3_:setLabel(string.format(LB_RAISE_NUM, raiseChips),true):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.raiseFixedClickHandler))
    self.oprFastNode_:show()
    self.chatBtn_:hide()
end

--轮到自己，不能加注状态
function OperationManager:selfCannotRaiseStatus_()
    local callMoney = 0
    local callChips = self.model.gameInfo.callChips
    local seatChips = self.model:selfSeatData().seatChips
    if seatChips>callChips then
        callMoney = callChips
        self.oprBtn3_:setLabel(string.format(LB_RAISE_NUM, callMoney),true):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.raiseFixedClickHandler))
    else
        callMoney = seatChips
        self.oprBtn3_:setLabel(bm.LangUtil.getText("ROOM", "ALL_IN"),true):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.raiseFixedClickHandler))
    end
    self.raiseFixedChips_ = callMoney
    self.oprBtn1_:setLabel(LB_CALL..bm.formatBigNumber(callMoney)):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.callClickHandler))
    self.oprBtn2_:setLabel(LB_FOLD):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.foldClickHandler))
    -- self.oprBtn3_:setLabel(LB_RAISE):setEnabled(false):setCheckMode(false)
    self.oprFastNode_:show()
    self.chatBtn_:hide()
end

--轮到自己，桌面没有加注，可以选择加注
function OperationManager:selfNoBetCanRaiseStatus_(minRaiseChips, maxRaiseChips)
    self.oprBtn1_:setLabel(LB_CHECK):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.checkClickHandler))
    self.oprBtn2_:setLabel(LB_FOLD):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.foldClickHandler))
    self.oprBtn3_:setLabel(LB_RAISE):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.raiseRangeClickHandler))
    self:setSliderStatus(minRaiseChips, maxRaiseChips)
    self.oprFastNode_:show()
    self.chatBtn_:hide()
end

--轮到自己，桌面没有加注，只能加固定的住
function OperationManager:selfNoBetCanRaiseFixedStatus_(raiseChips)
    self.raiseFixedChips_ = raiseChips
    self.oprBtn1_:setLabel(LB_CHECK):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.checkClickHandler))
    self.oprBtn2_:setLabel(LB_FOLD):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.foldClickHandler))
    self.oprBtn3_:setLabel(string.format(LB_RAISE_NUM, raiseChips)):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.raiseFixedClickHandler))
    self.oprFastNode_:show()
    self.chatBtn_:hide()
end

--没轮到自己操作，且没有加注（自动看牌、看或弃、跟任何注）
function OperationManager:otherNoBetStatus_()
    self.checkGroup_:onChecked(function(id) 
        if id == 1 then
            self.autoAction_ = "CHECK";
        elseif id == 2 then
            self.autoAction_ = "CHECK_OR_FOLD"
        elseif id == 3 then
            self.autoAction_ = "CALL_ANY"
        else
            self.autoAction_ = nil
        end
    end)
    local checkedId = self.checkGroup_:getCheckedId()
    if self.oprBtn2_:getLabel() ~= LB_AUTO_CHECK_OR_FOLD and not (self.oprBtn3_:getLabel() == LB_AUTO_CALL_ANY and checkedId == 3)  then
        self.checkGroup_:uncheck()
    end
    self.oprBtn1_:setLabel(LB_AUTO_CHECK):setEnabled(true):setCheckMode(true):onTouch(nil)
    self.oprBtn2_:setLabel(LB_AUTO_CHECK_OR_FOLD):setEnabled(true):setCheckMode(true):onTouch(nil)
    self.oprBtn3_:setLabel(LB_AUTO_CALL_ANY):setEnabled(true):setCheckMode(true):onTouch(nil)
    self.oprFastNode_:hide()
    self.chatBtn_:show()
end

--没轮到自己操作，有加注(跟XX注, 自动弃牌，跟任何注)
function OperationManager:otherBetStatus_(autoCallChips)
    self.autoCallChips_ = autoCallChips
    self.checkGroup_:onChecked(function(id) 
        if id == 1 then
            self.autoAction_ = "CALL";
        elseif id == 2 then
            self.autoAction_ = "FOLD"
        elseif id == 3 then
            self.autoAction_ = "CALL_ANY"
        else
            self.autoAction_ = nil
        end
    end)
    local checkedId = self.checkGroup_:getCheckedId()
    local lb = string.format(LB_AUTO_CALL, autoCallChips)
    if self.oprBtn2_:getLabel() ~= LB_AUTO_FOLD and not (self.oprBtn3_:getLabel() == LB_AUTO_CALL_ANY and checkedId == 3) 
        or checkedId == 1 and lb ~= self.oprBtn1_:getLabel() then
        self.checkGroup_:uncheck()
    end
    self.oprBtn1_:setLabel(lb):setEnabled(true):setCheckMode(true):onTouch(nil)
    self.oprBtn2_:setLabel(LB_AUTO_FOLD):setEnabled(true):setCheckMode(true):onTouch(nil)
    self.oprBtn3_:setLabel(LB_AUTO_CALL_ANY):setEnabled(true):setCheckMode(true):onTouch(nil)

    self.oprFastNode_:hide()
    self.chatBtn_:show()
end


function OperationManager:checkClickHandler(evt)
    if evt == bm.TouchHelper.CLICK then
        self:reportPlayData_("CHECK")
        nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.CHECK, 0)
        self:disabledStatus_()
    end
end

function OperationManager:foldClickHandler(evt)
    if evt == bm.TouchHelper.CLICK then
        self:reportPlayData_("FOLD")
        nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.FOLD, 0)
        self:disabledStatus_()
    end
end

function OperationManager:callClickHandler(evt)
    if evt == bm.TouchHelper.CLICK then
        self:reportPlayData_("CALL")
        nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.CALL, self.model.gameInfo.callChips)
        self:disabledStatus_()
    end
end

function OperationManager:raiseFixedClickHandler(evt)
    if evt == bm.TouchHelper.CLICK then
        if self.oprBtn3_.isAllIn then
            self:reportPlayData_("ALL_IN")
            nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.CALL, self.raiseFixedChips_)
            self:disabledStatus_()
            return
        end
        self:reportPlayData_("CALL_FIXED")
        nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.CALL, self.raiseFixedChips_)
        self:disabledStatus_()
    end
end

function OperationManager:raiseRangeClickHandler(evt)
    if evt == bm.TouchHelper.CLICK then
        if self.raiseSlider_:isVisible() then
            if self.raiseSlider_:getSliderPercentValue() == 1 then
                self:reportPlayData_("ALL_IN")
            else
                self:reportPlayData_("CALL_RAISE")
            end
            nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.CALL, self.raiseSlider_:getValue())
            self:disabledStatus_()
        else
            self.oprNode_:hide()
            -- 点击桌面回退
            if not self.addNode_ then
                local startX = self.normalBtnWidth_*0.5 + self.normalPadding_
                local itemWidth = self.normalBtnWidth_+self.normalPadding_
                self.addNode_ = display.newNode()
                    :pos(2, display.bottom + 44)
                    :addTo(self.scene.nodes.oprNode, 6, 6)
                self.addNode_:setContentSize(cc.size(316,65))
                self.blind5Btn_ = self:createAddFastBtn()
                self.blind5Btn_:pos(startX, 0):addTo(self.addNode_)
                self.blind5Btn_:getButtonLabel("normal"):setString(bm.formatBigNumber(self.model.roomInfo.blind*5))
                self.blind10Btn_ = self:createAddFastBtn()
                self.blind10Btn_:pos(startX+itemWidth, 0):addTo(self.addNode_)
                self.blind10Btn_:getButtonLabel("normal"):setString(bm.formatBigNumber(self.model.roomInfo.blind*10))
                self.blind25Btn_ = self:createAddFastBtn()
                self.blind25Btn_:pos(startX+itemWidth*2, 0):addTo(self.addNode_)
                self.blind25Btn_:getButtonLabel("normal"):setString(bm.formatBigNumber(self.model.roomInfo.blind*25))
                self.blind50Btn_ = self:createAddFastBtn()
                self.blind50Btn_:pos(startX+itemWidth*3, 0):addTo(self.addNode_)
                self.blind50Btn_:getButtonLabel("normal"):setString(bm.formatBigNumber(self.model.roomInfo.blind*50))
                self.blind100Btn_ = self:createAddFastBtn()
                self.blind100Btn_:pos(startX+itemWidth*4, 0):addTo(self.addNode_)
                self.blind100Btn_:getButtonLabel("normal"):setString(bm.formatBigNumber(self.model.roomInfo.blind*100))
                self.addConfirmBtn_ = self:createAddFastBtn(2)
                self.addConfirmBtn_:pos(startX+itemWidth*4+self.normalBtnWidth_*0.5+self.normalPadding_+self.mainBtnWidth_*0.5, 0):addTo(self.addNode_)
                self.raiseSlider_:setAddBtn(self.addConfirmBtn_)
                self:setAddBtnStatus()
            end
            self.raiseSlider_:showPanel()
            self.addNode_:show()
        end
    end
end

-- 勾选了自动看牌跟注等，在这里自动发包
function OperationManager:applyAutoOperation_()
    local autoAction = self.autoAction_
    local appliedAction = true
    if autoAction == "CHECK" then
        if self.model.gameInfo.callChips == 0 then
            self:reportPlayData_("CHECK")
            nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.CHECK, 0)
        else
            appliedAction = false
        end
    elseif autoAction == "CHECK_OR_FOLD" then
        if self.model.gameInfo.callChips > 0 then
            self:reportPlayData_("FOLD")
            nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.FOLD, 0)
        else
            self:reportPlayData_("CHECK")
            nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.CHECK, 0)
        end
    elseif autoAction == "CALL_ANY" then
        if self.model.gameInfo.callChips > 0 then
            self:reportPlayData_("CALL")
            nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.CALL, self.model.gameInfo.callChips)
        else
            appliedAction = false
        end
    elseif autoAction == "CALL" then
        if self.autoCallChips_ == self.model.gameInfo.callChips then
            self:reportPlayData_("CALL")
            nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.CALL, self.model.gameInfo.callChips)
        else
            appliedAction = false
        end
    elseif autoAction == "FOLD" then
        self:reportPlayData_("FOLD")
        nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.FOLD, 0)
    else
        appliedAction = false
    end

    self.checkGroup_:onChecked(nil):uncheck()
    self.autoAction_ = nil

    if appliedAction then
        self:disabledStatus_()
    end

    return appliedAction
end

function OperationManager:onRaiseSliderButtonClicked_(tag)
    local totalChipsInTable = self.model:totalChipsInTable()
    if tag == 1 then
        self:reportPlayData_("CALL_RAISE")
        nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.CALL, totalChipsInTable)
    elseif tag == 2 then
        self:reportPlayData_("CALL_RAISE")
        nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.CALL, totalChipsInTable * 0.75)
    elseif tag == 3 then
        self:reportPlayData_("CALL_RAISE")
        nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.CALL, totalChipsInTable * 0.5)
    elseif tag == 4 then
        self:reportPlayData_("CALL_RAISE")
        nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.CALL, self.model:currentMaxBetChips() * 3)
    elseif tag == 5 then
        self:reportPlayData_("ALL_IN")
        nk.socket.RoomSocket:sendBet(consts.CLI_BET_TYPE.CALL, self.raiseSlider_:getValue())
    end
    self.raiseSlider_:hidePanel()
    self:disabledStatus_()
    if self.addNode_ then
        self.addNode_:hide()
    end
end

function OperationManager:reportPlayData_(dataLabel)
    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand{command = "event",
            args = {eventId = "play_count_" .. dataLabel} , label = "play_count " .. dataLabel}
    end
end

function OperationManager:onBackgroundClicked()
    self.raiseSlider_:hidePanel()
    if self.addNode_ then
        self.addNode_:hide()
    end
    if self.showOped_ then
        self.oprNode_:show()
    end
end

function OperationManager:setAddBtnStatus()
    local callChips = self.model.gameInfo.callChips
    local minRaiseChips = self.model.gameInfo.minRaiseChips
    local maxRaiseChips = self.model.gameInfo.maxRaiseChips
    local bettingSeatId = self.model.gameInfo.bettingSeatId
    local seatChips = self.model:selfSeatData().seatChips
    local blind = self.model.roomInfo.blind
    local totalChipsInTable = self.model:totalChipsInTable()
    local currentMaxBetChips = self.model:currentMaxBetChips()
    self.totalChipsInTable_:setButtonEnabled(seatChips>=totalChipsInTable and totalChipsInTable<=maxRaiseChips)
    self.blind3Btn_:setButtonEnabled(blind*3>=callChips and seatChips>=blind*3 and blind*3<=maxRaiseChips)
    self.blind4Btn_:setButtonEnabled(blind*4>=callChips and seatChips>=blind*4 and blind*4<=maxRaiseChips)
    if self.blind5Btn_ then
        self.blind5Btn_:setButtonEnabled(blind*5>=callChips and seatChips>=blind*5 and blind*5<=maxRaiseChips)
    end
    if self.blind10Btn_ then
        self.blind10Btn_:setButtonEnabled(blind*10>=callChips and seatChips>=blind*10 and blind*10<=maxRaiseChips)
    end
    if self.blind25Btn_ then
        self.blind25Btn_:setButtonEnabled(blind*25>=callChips and seatChips>=blind*25 and blind*25<=maxRaiseChips)
    end
    if self.blind50Btn_ then
        self.blind50Btn_:setButtonEnabled(blind*50>=callChips and seatChips>=blind*50 and blind*50<=maxRaiseChips)
    end
    if self.blind100Btn_ then
        self.blind100Btn_:setButtonEnabled(blind*100>=callChips and seatChips>=blind*100 and blind*100<=maxRaiseChips)
    end
    if self.addConfirmBtn_ then
        self.addConfirmBtn_:setButtonEnabled(true)
    end
end

return OperationManager