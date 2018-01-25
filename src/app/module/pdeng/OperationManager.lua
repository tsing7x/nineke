--
-- Author: tony
-- Date: 2014-07-17 15:20:01
--
local OperationButton = import(".views.OperationButton")
local OperationButtonGroup = import("app.module.room.views.OperationButtonGroup")
local SeatStateMachine = import("app.module.pdeng.model.SeatStateMachine")

local ChatMsgPanel = import("app.module.room.views.ChatMsgPanel")
local UserInfoPopup = import("app.module.userInfo.UserInfoPopup")
local CandidatesPopup = import(".views.CandidatesPopup")

local OperationManager = class("OperationManager")


local BET_MUL = {1, 5, 10, 100}

local BET_SPRITE = {
    [100] = "#dice_bet_btn_normal_100.png",
    [500] = "#dice_bet_btn_normal_500.png",
    [1000] = "#dice_bet_btn_normal_1k.png",
    [5000] = "#dice_bet_btn_normal_5k.png",
    [10000] = "#dice_bet_btn_normal_10k.png",
    [50000] = "#dice_bet_btn_normal_50k.png",
    [100000] = "#dice_bet_btn_normal_100k.png",
    [1000000] = "#dice_bet_btn_normal_1m.png",
}

function OperationManager:ctor()
    self.schedulerPool_ = bm.SchedulerPool.new()
    self.betchip_ = 100
    self.antemoney_ = 0
    self.showNewMsg_ = false
    self.betchips_ = {self.betchip_,self.betchip_ * 5,self.betchip_ * 10,self.betchip_* 100}
end

function OperationManager:createNodes()
    
    self.bottomNode_ = display.newNode():addTo(self.scene.nodes.seatNode):hide()
    local bg_1 = display.newScale9Sprite("#pdeng_room_bottom_bg_left.png", 0, 0, cc.size(display.width * 0.5, 90), cc.rect(8, 40, 2, 1))
        :pos(display.cx * 0.5, 45)
        :addTo(self.bottomNode_)
    local bg_2 = display.newScale9Sprite("#pdeng_room_bottom_bg_left.png", 0, 0, cc.size(display.width * 0.5, 90), cc.rect(8, 40, 2, 1))
        :pos(display.cx * 1.5, 45)
        :addTo(self.bottomNode_)
    bg_2:setScaleX(-1)

    self.bottomMiddleNode_ = display.newNode():addTo(self.bottomNode_):hide()
    local bgm_1 = display.newSprite("#pdeng_room_bottom_bg_middle.png")
        :pos(display.cx, 47)
        :addTo(self.bottomMiddleNode_)
    bgm_1:setAnchorPoint(cc.p(1, 0.5))
    local bgm_2 = display.newSprite("#pdeng_room_bottom_bg_middle.png")
        :pos(display.cx, 47)
        :addTo(self.bottomMiddleNode_)
    bgm_2:setAnchorPoint(cc.p(1, 0.5))
    bgm_2:setScaleX(-1)
    
    self.chatBtn_ = cc.ui.UIPushButton.new({normal = {"#common_btn_bg_normal.png","#room_chat_icon_normal.png"},pressed = {"#common_btn_bg_pressed.png","#room_chat_icon_pressed.png"}})
        :onButtonClicked(function()
                if self.chatOpen_ then
                    return
                end
                self.chatOpen_ = true
                self.schedulerPool_:delayCall(function()
                    self.chatOpen_ = false
                end, 0.5)
                self.newMessagePoint:hide()
                self.showNewMsg_ = false
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                self.chatPanel_ = ChatMsgPanel.new(self.ctx)
                self.chatPanel_:showPanel()
            end)
        :pos(36, 130)
        :scale(0.9)
        :addTo(self.bottomNode_)

    self.newMessagePoint = display.newSprite(nk.userData.motherDayRedNodePath)
        :pos(33,30)
        :addTo(self.chatBtn_):hide()

    self.mynode_ = display.newNode():addTo(self.bottomNode_)
    self.avatar_ = nk.ui.CircleIcon.new():addTo(self.mynode_):pos(60,52)
    self.avatar_:setSexAndImgUrl("m","")
    self.touchHelper_ = bm.TouchHelper.new(self.avatar_, handler(self, self.onTouch_))
    self.nick_ = ui.newTTFLabel({text = nk.Native:getFixedWidthText("", 18, nk.userData.nick, 110), color = cc.c3b(0xff, 0xff, 0xff), size = 18, align = ui.TEXT_ALIGN_LEFT})
        :pos(120,56)
        :addTo(self.mynode_)
    self.nick_:setAnchorPoint(cc.p(0, 0.5))
    self.chipsicon_ = display.newSprite("#dice_chips.png")
        :pos(126,28)
        :addTo(self.mynode_)
    self.money_ = ui.newTTFLabel({text = "", color = cc.c3b(215, 101, 79), size = 18, align = ui.TEXT_ALIGN_LEFT})
        :align(display.LEFT_CENTER,142,28)
        -- :pos(172,28)
        :addTo(self.mynode_)

    self.oprNode_ = display.newNode():addTo(self.scene.nodes.oprNode, 5, 5)

    self.betNode_ = display.newNode():addTo(self.oprNode_)

    local bet_pos_y = 36
    self.betGroup_ = {}
    for i = 1, 4 do
        self.betGroup_[i] = cc.ui.UIPushButton.new({normal = "#dice_bet_btn_normal_2.png", pressed = {"#dice_bet_btn_selected_light.png", "#dice_bet_btn_normal_2.png"}})
            :pos(display.cx + 80 * (i - 2.5), bet_pos_y + 6)
            :onButtonClicked(function()
                self:setBet_(self.betchips_[i])
            end)
            :addTo(self.betNode_, 2)
    end

    self:updateInfo()
    self.touchHelper_:enableTouch()

    local button_width = 126
    local button_height = 56

    self.betDoubleLabel_ = ui.newTTFLabel({text = bm.LangUtil.getText("DICE","BET_DOUBLE"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})
    self.betDoubleBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_blue_normal.png", pressed = "#common_btn_blue_pressed.png", disabled = "#common_btn_disabled.png"}, {scale9 = true})
        :setButtonSize(button_width, button_height)
        :setButtonLabel("normal", self.betDoubleLabel_)
        :pos(display.width - button_width * 1.7, bet_pos_y)
        :onButtonClicked(buttontHandler(self, self.onBetDoubleClick_))
        :addTo(self.betNode_, 2)
        :setButtonEnabled(false)

    self.betLastLabel_ = ui.newTTFLabel({text = bm.LangUtil.getText("DICE","BET_LAST"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})
    self.betLastBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_yellow_normal.png", pressed = "#common_btn_yellow_pressed.png", disabled = "#common_btn_disabled.png"}, {scale9 = true})
        :setButtonSize(button_width, button_height)
        :setButtonLabel("normal", self.betLastLabel_)
        :pos(display.width - button_width * 0.64, bet_pos_y)
        :onButtonClicked(buttontHandler(self, self.onBetLastClick_))
        :addTo(self.betNode_, 2)
        :setButtonEnabled(false)

    self.getCardNode_ = display.newNode():addTo(self.oprNode_)

    self.checkGroup_ = OperationButtonGroup.new()
    OperationButton.BUTTON_WIDTH = button_width + 8
    self.oprBtn1_ = OperationButton.new("blue"):setLabel(bm.LangUtil.getText("PDENG","GET_POKER")):pos(display.width - button_width * 1.84, bet_pos_y):addTo(self.getCardNode_)
    self.oprBtn2_ = OperationButton.new("yellow"):setLabel(bm.LangUtil.getText("PDENG","NOT_GET_POKER")):pos(display.width - button_width * 0.66, bet_pos_y):addTo(self.getCardNode_)

    self.checkGroup_:add(1, self.oprBtn1_)
    self.checkGroup_:add(2, self.oprBtn2_)

    self.grabDealerBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_green_normal.png", pressed = "#common_btn_green_pressed.png", disabled = "#common_btn_disabled.png"}, {scale9 = true})
        :setButtonSize(button_width - 20, button_height)
        :setButtonLabel("normal", ui.newTTFLabel({text = bm.LangUtil.getText("PDENG","GRAB_DEALER"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER}))
        :pos(display.cx + 108, display.cy + 222)
        :onButtonClicked(buttontHandler(self, self.onGrabDealerClick))
        :addTo(self.scene.nodes.oprNode)
        :hide()

    self.dropDealerBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_green_normal.png", pressed = "#common_btn_green_pressed.png", disabled = "#common_btn_disabled.png"}, {scale9 = true})
        :setButtonSize(button_width, button_height)
        :setButtonLabel("normal", ui.newTTFLabel({text = bm.LangUtil.getText("PDENG","DROP_DEALER"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER}))
        :pos(100, 40)
        :onButtonClicked(buttontHandler(self, self.requesetDropDealer))
        :addTo(self.scene.nodes.oprNode)
        :hide()
end

function OperationManager:updateBtnImage(button,img)
    button:setButtonImage("normal", img, true)
    button:setButtonImage("pressed",{"#dice_bet_btn_selected_light.png", img}, true)
end

function OperationManager:setBaseChips(basechips)
    for i = 1, 4 do
        local btn = self.betGroup_[i]
        if BET_SPRITE[basechips * BET_MUL[i]] then
            self:updateBtnImage(btn,BET_SPRITE[basechips * BET_MUL[i]])
        end
    end
    self.betchip_ = basechips
    self.betchips_ = {basechips,basechips * 5,basechips * 10,basechips* 100}
end

function OperationManager:updateInfo()
    self.nick_:setString(nk.Native:getFixedWidthText("", 18, nk.userData.nick, 110))
    self.avatar_:setSexAndImgUrl(nk.userData.sex,nk.userData.s_picture)
end

function OperationManager:updateCurMoney(money)
    self.money_:setString(money)
    self.antemoney_ = money
end

function OperationManager:updateBetButtonState()
    if self:getCurMoney() < self.betchip_ then
        self.betDoubleBtn_:setButtonEnabled(false)
        self.betLastBtn_:setButtonEnabled(false)
    end
    local model = self.model
    if model and model:getCurBetMoney() > 0 then
        self.betDoubleBtn_:setButtonEnabled(true)
    else
        self.betDoubleBtn_:setButtonEnabled(false)
    end
    if model and model.lastBets and model.lastBets > 0 and not self.hadBetLast then
        self.betLastBtn_:setButtonEnabled(true)
    else
        self.betLastBtn_:setButtonEnabled(false)
    end
end

function OperationManager:stopBetButton()
    self.betDoubleBtn_:setButtonEnabled(false)
    self.betLastBtn_:setButtonEnabled(false)
end

function OperationManager:subCurrMoney(money)
    self.antemoney_ = self.antemoney_ - money
    self.money_:setString(self.antemoney_)
end

function OperationManager:buyInMoney(money)
    self.hadBetLast = false
    if self.antemoney_ == money then
        return
    else
        -- nk.TopTipManager:showTopTip(bm.LangUtil.getText("DICE","AUTO_BUYIN",money - self.antemoney_))
        self.money_:setString(money)
        self.antemoney_ = money
    end
end

function OperationManager:getCurMoney()
    return self.antemoney_ or 0
end

function OperationManager:onBetDoubleClick_()
    self:betDoubleOrLast(false)
end

function OperationManager:onBetLastClick_()
    self:betDoubleOrLast(true)
    self.hadBetLast = true
    self:updateBetButtonState()
end

function OperationManager:betDoubleOrLast(isLast)
    local model = self.model
    local needBet = 0
    if not isLast and model:getCurBetMoney() > 0 then
        needBet = model:getCurBetMoney()
    elseif isLast and model.lastBets then
        needBet = model.lastBets
    end
    if needBet > 0 then
        self:setBet_(needBet)
    end
end

function OperationManager:setLatestChatMsg()
    if self.showNewMsg_ then
        return
    end
    self.showNewMsg_ = true
    self.newMessagePoint:show()
end

function OperationManager:onTouch_(target, evt)
    if evt == bm.TouchHelper.CLICK then
        local tableAllUid, toUidArr = self.model:getTableAllUid()
        local tableNum = self.model:getNumInSeat()
        local tableMessage = {tableAllUid = tableAllUid,toUidArr = toUidArr,tableNum = tableNum}
        UserInfoPopup.new():show(true, tableMessage, false,true)
    end
end

function OperationManager:dispose()

    if self.startLoadingId_ then
        self.schedulerPool_:clear(self.startLoadingId_)
        self.startLoadingId_ = nil
    end

    if self.showOptSchedulerId then
        self.schedulerPool_:clear(self.showOptSchedulerId)
        self.showOptSchedulerId = nil
    end
end

function OperationManager:showOperationButtons(animation)
    self.oprNode_:stopAllActions()
    if animation then
        self.oprNode_:show():moveTo(0.5, 0, 0)
    else
        self.oprNode_:show():pos(0, 0)
    end
end

function OperationManager:hideOperationButtons(animation)
    self.oprNode_:stopAllActions()
    if animation then
        transition.moveTo(self.oprNode_, {y=0, time=0.5, onComplete=function() self.oprNode_:hide() end})
    else
        self.oprNode_:hide():setPositionY(0)
    end
end

function OperationManager:showBetButtons(animation)
    self.bottomMiddleNode_:stopAllActions()
    if animation then
        self.bottomMiddleNode_:show():moveTo(0.5, 0, 0)
    else
        self.bottomMiddleNode_:show():pos(0, 0)
    end
    self.betNode_:stopAllActions()
    if animation then
        self.betNode_:show():moveTo(0.5, 0, 0)
    else
        self.betNode_:show():pos(0, 0)
    end
end

function OperationManager:hideBetButtons(animation)
    self.bottomMiddleNode_:stopAllActions()
    if animation then
        transition.moveTo(self.bottomMiddleNode_, {y=0, time=0.5, onComplete=function() self.bottomMiddleNode_:hide() end})
    else
        self.bottomMiddleNode_:hide():setPositionY(0)
    end
    self.betNode_:stopAllActions()
    if animation then
        transition.moveTo(self.betNode_, {y=0, time=0.5, onComplete=function() self.betNode_:hide() end})
    else
        self.betNode_:hide():setPositionY(0)
    end
end

function OperationManager:showBottom(animation)
    self.bottomNode_:stopAllActions()
    if animation then
        self.bottomNode_:show():moveTo(0.5, 0, 0)
    else
        self.bottomNode_:show():pos(0, 0)
    end
end

function OperationManager:hideBottom(animation)
    self.bottomNode_:stopAllActions()
    if animation then
        transition.moveTo(self.bottomNode_, {y=0, time=0.5, onComplete=function() self.bottomNode_:hide() end})
    else
        self.bottomNode_:hide():setPositionY(0)
    end
end

function OperationManager:blockOperationButtons()
    self:disabledStatus_()
end

function OperationManager:resetAutoOperationStatus()
    self.checkGroup_:onChecked(nil):uncheck()
    self.autoAction_ = nil
end

function OperationManager:updateOperationStatus()
    self.schedulerPool_:clear(self.showOptSchedulerId)
    self.showOptSchedulerId = nil
    self.oprNode_:show()
    local selfSeatId = self.model:selfSeatId()
    local gameStatus = self.model.gameInfo.gameStatus

    if not self.model:isSelfInSeat() or not self.model:isSelfInGame()  then
        self:disabledStatus_()
    else
        local selfPlayer = self.model:selfSeatData()
        local playerState = selfPlayer.statemachine:getState() 
        if playerState == SeatStateMachine.STATE_BETTING then            
            --下注
            self.getCardNode_:hide()
            if self.model:isSelfDealer() then
                self.betNode_:hide()
                self.bottomMiddleNode_:hide()
            else
                self.betNode_:show()
                self.bottomMiddleNode_:show()
            end
            self:setBaseChips(self.model.roomInfo.blind)
            self:updateBetButtonState()
        elseif playerState == SeatStateMachine.STATE_WAIT_GET then
            self.getCardNode_:show()
            self.betNode_:hide()
            self.bottomMiddleNode_:hide()
            self:willGetPokerStatus_()
        elseif playerState == SeatStateMachine.STATE_GETTING then
            if self:applyAutoOperation_() then
                self:disabledStatus_()
            else
                self.getCardNode_:show()
                self.betNode_:hide()
                self.bottomMiddleNode_:hide()
                self:getPokerStatus_()
            end
        else
            self:disabledStatus_()
        end
    end
end

-- 切换上下庄
function OperationManager:updateDealerStatus(dealer, no_anim)
    if dealer then
        self.grabDealerBtn_:hide()
        if not no_anim then
            self.gameSchedulerPool:delayCall(function()
                    self.dropDealerBtn_:show()
            end, 1)
        else
            self.dropDealerBtn_:show()
        end
        self.mynode_:hide()
    else
        if not no_anim then
            self.gameSchedulerPool:delayCall(function()
                    self.grabDealerBtn_:show()
            end, 1)
        else
            self.grabDealerBtn_:show()
        end
        self.dropDealerBtn_:hide()
        self.mynode_:show()
    end
end

-- 上庄
function OperationManager:onGrabDealerClick()
    if self.is_candidate then
        local candidates = self.ctx.model.gameInfo.candidates
        CandidatesPopup.new(candidates):show()
    else
        local money = nk.userData.money--self:getCurMoney()
        local door = self.ctx.model:getGrabDealerNeedCoin()
        -- if money < door then
        --     nk.TopTipManager:showTopTip(bm.LangUtil.getText("PDENG", "GRAB_DEALER_FAILED_MONEY_LIMIT", door))
        --     return
        -- end
        nk.socket.RoomSocket:sendRequestGrabDealerPdeng(money)
    end
end

-- 下庄
function OperationManager:requesetDropDealer()
    nk.socket.RoomSocket.stand_type = 3
    nk.socket.RoomSocket:sendStandUpPdeng()
end

-- 更新上庄状态
function OperationManager:updateGrabDealerStatus(is_grab)
    if self.isShowGrabBtn_ == false then return end
    if is_grab then
        self.grabDealerBtn_:setButtonImage("normal", "#common_btn_blue_normal.png", true)
        self.grabDealerBtn_:setButtonImage("pressed", "#common_btn_blue_pressed.png", true)
        self.grabDealerBtn_:setButtonLabelString(bm.LangUtil.getText("PDENG","WAIT_GRAB_DEALER"))
        self.is_candidate = true
        self.grabDealerBtn_:show()
    else
        self.grabDealerBtn_:setButtonImage("normal", "#common_btn_green_normal.png", true)
        self.grabDealerBtn_:setButtonImage("pressed", "#common_btn_green_pressed.png", true)
        self.grabDealerBtn_:setButtonLabelString(bm.LangUtil.getText("PDENG","GRAB_DEALER"))
        self.is_candidate = false
        self.grabDealerBtn_:show()
    end
end

function OperationManager:setGrabDealerVisible(isshow)
    self.isShowGrabBtn_ = isshow
    if isshow == false then
        self.grabDealerBtn_:hide()
    end
end

function OperationManager:updateState(show)
    self.isShowGrabBtn_ = show
    self:updateGrabDealerStatus(show)
end


--无法操作的状态
function OperationManager:disabledStatus_()
    self:hideOperationButtons(false)
end

--要牌
function OperationManager:getPokerStatus_()
    self:showOperationButtons(false)
    self.oprBtn1_:setLabel(bm.LangUtil.getText("PDENG","GET_POKER")):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.getPokerClickHandler))
    self.oprBtn2_:setLabel(bm.LangUtil.getText("PDENG","NOT_GET_POKER")):setEnabled(true):setCheckMode(false):onTouch(handler(self, self.notGetPokerClickHandler))
    self.oprBtn1_.label_:setSystemFontSize(24)
    self.oprBtn2_.label_:setSystemFontSize(24)
    self.betNode_:hide()
    self.bottomMiddleNode_:hide()
end

-- 将要要牌
function OperationManager:willGetPokerStatus_()
    self:showOperationButtons(false)
    self.oprBtn1_:setLabel(bm.LangUtil.getText("PDENG","AUTO_GET_POKER")):setEnabled(true):setCheckMode(true):onTouch(nil)
    self.oprBtn2_:setLabel(bm.LangUtil.getText("PDENG","AUTO_NOT_GET_POKER")):setEnabled(true):setCheckMode(true):onTouch(nil)
    self.oprBtn1_.label_:setSystemFontSize(20)
    self.oprBtn2_.label_:setSystemFontSize(20)
    
    self.checkGroup_:onChecked(function(id) 
        if id == 1 then
            self.autoAction_ = "GET_POKER"
        elseif id == 2 then
            self.autoAction_ = "NOT_GET_POKER"       
        else
            self.autoAction_ = nil
        end
    end)

    self.betNode_:hide()
    self.bottomMiddleNode_:hide()
end

function OperationManager:getPokerClickHandler(evt)
    if evt == bm.TouchHelper.CLICK then
        self:setGetCard_(1)
        self:disabledStatus_()
    end
end

function OperationManager:notGetPokerClickHandler(evt)
    if evt == bm.TouchHelper.CLICK then
        self:setGetCard_(0)
        self:disabledStatus_()
    end
end

-- 下注
function OperationManager:setBet_(chip)
    local money = self:getCurMoney()
    if money <= 0 then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("DICE", "BET_FAIL"))
        return false
    end
    local bet = chip
    if money < chip then
        bet = money
    end
    self.ctx.model.isbet_ = true
    nk.socket.RoomSocket:sendBetPdeng(bet)
end

-- 要牌
function OperationManager:setGetCard_(get_)
    nk.socket.RoomSocket:sendOtherCardPdeng(get_)
    self.seatManager:stopClock()
    self.seatManager:stopCounterOnSelf()
end


-- 勾选了自动看牌跟注等，在这里自动发包
function OperationManager:applyAutoOperation_()
    local autoAction = self.autoAction_
    local appliedAction = true
    if autoAction == "GET_POKER" then
        self:setGetCard_(1)
    elseif autoAction == "NOT_GET_POKER" then
        self:setGetCard_(0)
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

return OperationManager