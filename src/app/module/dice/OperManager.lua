--
-- Author: Jonah0608@gmail.com
-- Date: 2016-08-31 14:43:06
--
local OperManager = class("OperManager")
local ChatMsgPanel = import("app.module.room.views.ChatMsgPanel")
local UserInfoPopup = import("app.module.userInfo.UserInfoPopup")

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

function OperManager:ctor()
    self.betchip_ = 100
    self.betmoney_ = 0
    self.showNewMsg_ = false
    self.betchips_ = {self.betchip_,self.betchip_ * 5,self.betchip_ * 10,self.betchip_* 100}
end

function OperManager:createNodes()
    self.mynode_ = display.newNode():addTo(self.scene.nodes.selfNode)
    self.chatBtn_ = cc.ui.UIPushButton.new({normal = {"#common_btn_bg_normal.png","#room_chat_icon_normal.png"},pressed = {"#common_btn_bg_pressed.png","#room_chat_icon_pressed.png"}})
        :onButtonClicked(function()
                if self.chatOpen_ then
                    return
                end
                self.chatOpen_ = true
                self.gameSchedulerPool:delayCall(function()
                    self.chatOpen_ = false
                end, 0.5)
                self.newMessagePoint:hide()
                self.showNewMsg_ = false
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                self.chatPanel_ = ChatMsgPanel.new(self.ctx)
                self.chatPanel_:showPanel()
            end)
        :pos(44-1, 32+7)
        :addTo(self.mynode_)

    self.newMessagePoint = display.newSprite(nk.userData.motherDayRedNodePath)
        :pos(33,30)
        :addTo(self.chatBtn_):hide()

    self.avatar_ = nk.ui.CircleIcon.new():addTo(self.mynode_):pos(140,52)
    self.avatar_:setSexAndImgUrl("m","")
    self.touchHelper_ = bm.TouchHelper.new(self.avatar_, handler(self, self.onTouch_))
    self.nickbg_ = display.newScale9Sprite("#dice_text_bg.png",0,0,cc.size(120,26))
        :pos(244,54)
        :addTo(self.mynode_)
    self.nick_ = ui.newTTFLabel({text = nk.Native:getFixedWidthText("", 18, nk.userData.nick, 110), color = cc.c3b(0xff, 0xff, 0xff), size = 18, align = ui.TEXT_ALIGN_CENTER})
        :pos(60,12)
        :addTo(self.nickbg_)
    self.moneybg_ = display.newScale9Sprite("#dice_text_bg.png",0,0,cc.size(120,26))
        :pos(244,22)
        :addTo(self.mynode_)
    self.chipsicon_ = display.newSprite("#dice_chips.png")
        :pos(12,12)
        :addTo(self.moneybg_)
    self.money_ = ui.newTTFLabel({text = "", color = cc.c3b(215, 101, 79), size = 18, align = ui.TEXT_ALIGN_CENTER})
        :pos(73,12)
        :addTo(self.moneybg_)

    self.group_ = cc.ui.UICheckBoxButtonGroup.new(display.LEFT_TO_RIGHT)
    for i = 1, 4 do
        self.group_:addButton(cc.ui.UICheckBoxButton.new(self:getRadioImg(i)))
    end
    local margin = (display.width - 306 * 2 - 4 * 70) / 4
    self.group_:setButtonsLayoutMargin(0, 0, 0, margin)
    self.group_:onButtonSelectChanged(function(event)
        self:onChangeChips(event.selected)
    end)
    local bet_pos_y = 41
    self.group_:pos(290, bet_pos_y - 36)
    self.group_:addTo(self.mynode_, 2)
    self.btnlight_ = display.newSprite("#dice_bet_btn_selected_light.png")
        :pos(self.group_:getButtonAtIndex(1):getPositionX() + self.group_:getPositionX() + 1, bet_pos_y)
        :addTo(self.mynode_)
        :scale(0.95)
    self.group_:getButtonAtIndex(1):setButtonSelected(true)
    self:updateInfo()
    self.touchHelper_:enableTouch()

    local button_width = 126
    local button_height = 54

    self.betDoubleLabel_ = ui.newTTFLabel({text = bm.LangUtil.getText("DICE","BET_DOUBLE"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})
    self.betDoubleBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_yellow_normal.png", pressed = "#common_btn_yellow_pressed.png", disabled = "#common_btn_disabled.png"}, {scale9 = true})
        :setButtonSize(button_width, button_height)
        :setButtonLabel("normal", self.betDoubleLabel_)
        :pos(display.width - button_width * 1.7, bet_pos_y)
        :onButtonClicked(buttontHandler(self, self.onBetDoubleClick_))
        :addTo(self.mynode_, 2)
        :setButtonEnabled(false)
    local bg_scale_offset = 10
    display.newScale9Sprite("#dice_bet_btn_bg.png", 0, 0, cc.size(button_width + bg_scale_offset, 62), cc.rect(40,30,1,1))
        :addTo(self.mynode_)
        :pos(self.betDoubleBtn_:getPositionX(), self.betDoubleBtn_:getPositionY() + 1)

    self.betLastLabel_ = ui.newTTFLabel({text = bm.LangUtil.getText("DICE","BET_LAST"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})
    self.betLastBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_green_normal.png", pressed = "#common_btn_green_pressed.png", disabled = "#common_btn_disabled.png"}, {scale9 = true})
        :setButtonSize(button_width, button_height)
        :setButtonLabel("normal", self.betLastLabel_)
        :pos(display.width - button_width * 0.64, bet_pos_y)
        :onButtonClicked(buttontHandler(self, self.onBetLastClick_))
        :addTo(self.mynode_, 2)
        :setButtonEnabled(false)
    display.newScale9Sprite("#dice_bet_btn_bg.png", 0, 0, cc.size(button_width + bg_scale_offset, 62), cc.rect(40,30,1,1))
        :addTo(self.mynode_)
        :pos(self.betLastBtn_:getPositionX(), self.betLastBtn_:getPositionY() + 1)
end

function OperManager:getRadioImg(id)
    id = 2
   local ret = {
        off = "#dice_bet_btn_normal_"..id .. ".png",
        off_pressed = "#dice_bet_btn_normal_"..id .. ".png",
        off_disabled = "#dice_bet_btn_normal_"..id .. ".png",
        on = "#dice_bet_btn_normal_"..id .. ".png",
        on_pressed = "#dice_bet_btn_normal_"..id .. ".png",
        on_disabled = "#dice_bet_btn_normal_"..id .. ".png",
    }
    return ret
end

function OperManager:updateBtnImage(button,img)
    button:setButtonImage("off", img, true)
    button:setButtonImage("off_pressed",img, true)
    button:setButtonImage("off_disabled",img, true)
    button:setButtonImage("on",img, true)
    button:setButtonImage("on_pressed", img, true)
    button:setButtonImage("on_disabled", img, true)
end

function OperManager:setBaseChips(basechips)
    for i = 1, 4 do
        local btn = self.group_:getButtonAtIndex(i)
        if BET_SPRITE[basechips * BET_MUL[i]] then
            self:updateBtnImage(btn,BET_SPRITE[basechips * BET_MUL[i]])
        end
    end
    self.betchip_ = basechips
    self.betchips_ = {basechips,basechips * 5,basechips * 10,basechips* 100}
    self:onChangeChips(1)
    self.group_:getButtonAtIndex(1):setButtonSelected(true)
end

function OperManager:updateInfo()
    self.nick_:setString(nk.Native:getFixedWidthText("", 18, nk.userData.nick, 110))
    self.avatar_:setSexAndImgUrl(nk.userData.sex,nk.userData.s_picture)
end

function OperManager:updateCurMoney(money)
    self.money_:setString(money)
    self.betmoney_ = money
end

function OperManager:updateBetButtonState()
    if self:getCurMoney() < self.betchip_ then
        self.betDoubleBtn_:setButtonEnabled(false)
        self.betLastBtn_:setButtonEnabled(false)
    end
    local model = self.model
    if model and model.Bets and #model.Bets > 0 then
        self.betDoubleBtn_:setButtonEnabled(true)
    else
        self.betDoubleBtn_:setButtonEnabled(false)
    end
    if model and model.lastBets and #model.lastBets > 0 and not self.hadBetLast then
        self.betLastBtn_:setButtonEnabled(true)
    else
        self.betLastBtn_:setButtonEnabled(false)
    end
end

function OperManager:stopBetButton()
    self.betDoubleBtn_:setButtonEnabled(false)
    self.betLastBtn_:setButtonEnabled(false)
end

function OperManager:subCurrMoney(money)
    self.betmoney_ = self.betmoney_ - money
    self.money_:setString(self.betmoney_)
end

function OperManager:buyInMoney(money)
    self.hadBetLast = false
    if self.betmoney_ == money then
        return
    else
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("DICE","AUTO_BUYIN",money - self.betmoney_))
        self.money_:setString(money)
        self.betmoney_ = money
    end
end

function OperManager:getCurMoney()
    return self.betmoney_ or 0
end

function OperManager:onBetDoubleClick_()
    self:betDoubleOrLast(false)
end

function OperManager:onBetLastClick_()
    self:betDoubleOrLast(true)
    self.hadBetLast = true
    self:updateBetButtonState()
end

function OperManager:betDoubleOrLast(isLast)
    local model = self.model
    local currentBets = {}
    if not isLast and model.Bets then
        currentBets = clone(model.Bets)
    elseif isLast and model.lastBets then
        currentBets = clone(model.lastBets)
    end
    for i = 1, #currentBets do
        local succ = self.ctx.diceController:requestBet(currentBets[i].betType, currentBets[i].betChip)
        if not succ then
            return
        end
    end
end

function OperManager:onChangeChips(selected)
    self.betchip_ = self.betchips_[selected]
    local btn = self.group_:getButtonAtIndex(selected)
    self.btnlight_:pos(btn:getPositionX() + self.group_:getPositionX() + 1, self.btnlight_:getPositionY())
end

function OperManager:getBetChip()
    return self.betchip_
end

function OperManager:setLatestChatMsg()
    if self.showNewMsg_ then
        return
    end
    self.showNewMsg_ = true
    self.newMessagePoint:show()
end

function OperManager:onTouch_(target, evt)
    if evt == bm.TouchHelper.CLICK then
        UserInfoPopup.new():show(false,nil,true)
    end
end

return OperManager