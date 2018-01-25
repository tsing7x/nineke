--
-- Author: HLF(IdaHuang@boyaa.com)
-- Date: 2016-02-16 19:33:28
-- 玩家保险箱
local ModifyBankPassWordPopup = import("app.module.room.bank.ModifyBankPassWordPopup")

local UserBankPopup = class("UserBankPopup", nk.ui.Panel)

local W = 746
local H = 504
local TOP = H * 0.5
local BOTTOM = H * -0.5 + 40
local LEFT = W * -0.5
local RIGHT = W * 0.5
local STUFF_BAR_H = 120
local bank_pos_x = 15
local bank_pos_y = 42
local BUTTON_W = 174
local BUTTON_H = 55

local PRO_RESID = {
    "chip_icon.png",
    "icon_score.png"
}

local ACTION_SAVE_MONEY = "bankSaveMoney"
local ACTION_SAVE_SCORE = "bankSaveScore"
local ACTION_GET_MONEY = "bankGetMoney"
local ACTION_GET_SCORE = "bankGetScore"

function UserBankPopup:ctor()
    UserBankPopup.super.ctor(self, {W, H})
    self:setNodeEventEnabled(true)
    if display.getRunningScene().name == "PdengScene" then
        self.isPdeng_ = true
    else
        self.isPdeng_ = false
    end
    --修改背景框
    self:setBackgroundStyle1()

    self:addTopIcon("#pop_bank_icon.png", 0)  

    self:addCloseBtn()
    px, py = self.closeBtn_:getPosition()
    self.closeBtn_:pos(px, py - 16)

    px, py = 0, self.height_ * 0.5 - nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5 - 44
    local text = clone(bm.LangUtil.getText("BANK", "MAIN_TAB_TEXT"))
    self.mainTabBar_ = nk.ui.CommonPopupTabBar.new(
            {
                popupWidth = 650,
                iconOffsetX = 10, 
                btnText = text, 
            }
        )
        :pos(px, py)
        :addTo(self, 10)
    self:addTopDivide(nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5 + 12)

    self:createTwoProIcon()
    self:createBankView()
    self.currentBankFortune_ = 0
    self.currentFortune_ = 0

    self.showExistPassWordIcon_ = bm.EventCenter:addEventListener(nk.eventNames.SHOW_EXIST_PASSWORD_ICON, handler(self, self.renderSetPasswordStatus_))
end

function UserBankPopup:createBankView()
    -- 银行面板
    local px, py
    self.bankView_ = display.newNode()
        :pos(-20,0)
        :addTo(self)

    display.newScale9Sprite("#pop_userinfo_my_bank_bg.png",0, 0, cc.size(W - 40, 264), cc.rect(18, 18, 1, 1))
        :pos(20, 0)
        :addTo(self.bankView_)

    -- 银行的输入框背景
    local bank_input_offset_y = 48+0
    px, py = bank_pos_x - 104, bank_pos_y + bank_input_offset_y
    self.inputBg_ = display.newScale9Sprite("#pop_userinfo_my_bank_input_bg.png",0, 0, cc.size(410, 53), cc.rect(18, 18, 1, 1))
        :pos(px, py)
        :addTo(self.bankView_)

    self.grayBar_ = display.newScale9Sprite("#pop_bank_gray_bar.png",0, 0, cc.size(53, 53), cc.rect(18, 18, 1, 1))--display.newSprite("#pop_bank_gray_bar.png")
        :addTo(self.bankView_)

    local sz = self.grayBar_:getContentSize()
    px = px - 410*0.5 + sz.width*0.5 - 1
    self.grayBar_:pos(px, py)
    self.currentProIcon_ = display.newSprite("#"..PRO_RESID[1])
        :pos(px, py)
        :addTo(self.bankView_)

    -- 显示筹码显示区域
    px, py = bank_pos_x - 104 - 180 + sz.width, bank_pos_y + bank_input_offset_y
    self.textInputChip = ui.newTTFLabel({text = "0", color = styles.FONT_COLOR.GOLDEN_TEXT, size = 28, align = ui.TEXT_ALIGN_RIGHT})
    self.textInputChip:setAnchorPoint(cc.p(0, 0.5))
    self.textInputChip:pos(px, py)
    self.textInputChip:addTo(self.bankView_)

    self.cursorIcon_ = display.newSprite("#pop_bank_line.png")
        :pos(px+18, py)
        :addTo(self.bankView_)
    self.cursorIcon_:runAction(cc.RepeatForever:create(transition.sequence({
            cc.FadeIn:create(0.8),
            cc.DelayTime:create(0.2),
            cc.FadeOut:create(0.3),
        })))

    -- 银行删除按钮
    self.deleteButton_ = cc.ui.UIPushButton.new({normal = "#pop_userinfo_my_bank_input_back.png", pressed = "#pop_userinfo_my_bank_input_back_pressed.png"})
        :pos(bank_pos_x + 62, bank_pos_y + bank_input_offset_y)
        :onButtonClicked(buttontHandler(self, self.onDeleteChipNumberClick_))
        :addTo(self.bankView_)

    local firstNumber = {1 ,2 , 3 , 4 ,5}
    self.curString = ""
    for i=1,5 do
        self.firstRowButton = cc.ui.UIPushButton.new({normal = "#pop_userinfo_my_bank_number_bg.png", pressed = "#pop_userinfo_my_bank_number_pressed_bg.png"},{scale9 = true})
            :pos(bank_pos_x - 270 + ( (i-1) * (84)) , bank_pos_y - 32 + 12)
            :setButtonSize(80, 51)
            :setButtonLabel(ui.newTTFLabel({text = firstNumber[i], color = styles.FONT_COLOR.GOLDEN_TEXT, size = 26, align = ui.TEXT_ALIGN_CENTER}))
            :setButtonLabelString(firstNumber[i])
            :onButtonClicked(buttontHandler(self, self.modifyInputLabel))
            :addTo(self.bankView_)
    end

    local secondNumber = {6 ,7, 8 , 9 ,0}
    for i=1,5 do
        cc.ui.UIPushButton.new({normal = "#pop_userinfo_my_bank_number_bg.png", pressed = "#pop_userinfo_my_bank_number_pressed_bg.png"},{scale9 = true})
            :pos(bank_pos_x - 270 + ( (i-1) * (84)) , bank_pos_y - 98 + 12)
            :setButtonSize(80, 51)
            :setButtonLabel(ui.newTTFLabel({text = secondNumber[i], color = styles.FONT_COLOR.GOLDEN_TEXT, size = 26, align = ui.TEXT_ALIGN_CENTER}))
            :onButtonClicked(buttontHandler(self, self.modifyInputLabel))
            :addTo(self.bankView_)
    end

    -- 存钱
    local offX = 236
    local offY = 24
    self.bankSaveButton= cc.ui.UIPushButton.new({normal = "#common_btn_green_normal.png", pressed = "#common_btn_green_pressed.png", disabled = "#common_btn_disabled.png"},{scale9 = true})
        :pos(bank_pos_x + offX, bank_pos_y + offY + 21 + 0)
        :setButtonSize(BUTTON_W, BUTTON_H)
        :setButtonLabel(ui.newTTFLabel({text = bm.LangUtil.getText("BANK","SAVE_BUTTON_LABEL"), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 20, align = ui.TEXT_ALIGN_CENTER}))
        :onButtonClicked(buttontHandler(self, self.saveChipClick_))
        :addTo(self.bankView_)

    if self.isPdeng_ then
        self.bankSaveButton:setButtonEnabled(false)
    end
    -- 取钱
    self.bankDrawButton = cc.ui.UIPushButton.new({normal = "#common_btn_blue_normal.png", pressed = "#common_btn_blue_pressed.png" , disabled = "#common_btn_disabled.png"},{scale9 = true})
        :pos(bank_pos_x + offX, bank_pos_y + offY - 63 + 6)
        :setButtonSize(BUTTON_W, BUTTON_H)
        :setButtonLabel(ui.newTTFLabel({text = bm.LangUtil.getText("BANK","DRAW_BUTTON_LABEL"), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 20, align = ui.TEXT_ALIGN_CENTER}))
        :onButtonClicked(buttontHandler(self, self.drawChipClick_))
        :addTo(self.bankView_)

    -- 设置密码
    px, py = bank_pos_x + offX, bank_pos_y + offY - 145 + 6
    self.setPasswordButton = cc.ui.UIPushButton.new({normal = "#common_btn_yellow_normal.png", pressed = "#common_btn_yellow_pressed.png" , disabled = "#common_btn_disabled.png"},{scale9 = true})
        :setButtonSize(BUTTON_W, BUTTON_H)
        :setButtonLabel(ui.newTTFLabel({text = bm.LangUtil.getText("BANK","BANK_SETTING_RESETPASSWORD_BUTTON_LABEL"), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 20, align = ui.TEXT_ALIGN_CENTER}))
        :onButtonClicked(buttontHandler(self, self.setPasswordClick_))
        :pos(px, py)
        :addTo(self.bankView_)

    self.passwordUnderLine_ = display.newNode()
        :pos(px, py)
        :addTo(self.bankView_)

    local underTxt = ui.newTTFLabel({
            text=bm.LangUtil.getText("BANK","BANK_SETTING_PASSWORD_BUTTON_LABEL"),
            color=cc.c3b(0x27, 0x83, 0xc0),
            size=20,
            align=ui.TEXT_ALIGN_CENTER
        })
        :addTo(self.passwordUnderLine_)

    px, py = 0, 0
    local sz = underTxt:getContentSize()
    local underBtn = cc.ui.UIPushButton.new({normal = "#transparent.png", pressed = "#transparent.png"}, {scale9=true})
        :setButtonSize(sz.width, sz.height)
        :pos(px, py)
        :addTo(self.passwordUnderLine_)
        :onButtonClicked(buttontHandler(self, self.setPasswordClick_))

    local underLine = display.newScale9Sprite(
            "#user-info-desc-button-background-down-line.png",
            px, py-12,
            cc.size(sz.width+45, 2)
        )
        :addTo(self.passwordUnderLine_)
    self.passwordUnderLine_:hide()

    px, py = bank_pos_x - 50, bank_pos_y - 150 + 12
    self.txtTips_ = ui.newTTFLabel({text = bm.LangUtil.getText("BANK","USERINFO_BANK_TIPS"), color = cc.c3b(0xb0,0xb3,0xfb), size = 20, 
                dimensions = cc.size(500, 64), align = ui.TEXT_ALIGN_LEFT})
        :pos(px, py)
        :addTo(self.bankView_)

    self.txtTips_:hide()
end

-- 修改输入数字
function UserBankPopup:modifyInputLabel(evt)
    if self:isLoading() then
        return
    end

    if (string.len(self.curString) > 0) and (tonumber(self.curString) >= math.max(self.currentFortune_, self.currentBankFortune_)) then
        return
    end

    local label = evt.target:getButtonLabel()
    self.curString = self.curString..label:getString()
    self.textInputChip:setString(bm.formatNumberWithSplit(self.curString))
    if tonumber(self.curString) > math.max(self.currentFortune_, self.currentBankFortune_) then -- 如果输入的钱大于银行中的钱或者身上的钱让它置为两者较大的数额
        self.textInputChip:setString(bm.formatNumberWithSplit(math.max(self.currentFortune_, self.currentBankFortune_)))
    elseif self.curString == "00" then -- 如果连续两次都输入0 只让显示一个0
        local currentString = string.sub(self.curString,0,1)
        self.curString = currentString
    end

    if self.curString and string.len(self.curString) > 0 and  tonumber(self.curString) > 0 then
        if (self.currentFortune_ > self.currentBankFortune_) and  (tonumber(self.curString) > self.currentBankFortune_)  then
            self.bankDrawButton:setButtonEnabled(false)
        elseif (self.currentBankFortune_ > self.currentFortune_) and (tonumber(self.curString) > self.currentFortune_) then
            self.bankSaveButton:setButtonEnabled(false)
        end
    end

    self:renderCursorPos_()
end

-- 删除输入数字
function UserBankPopup:onDeleteChipNumberClick_()
    if self.curString == "0" or self:isLoading() then
        return
    end

    local curLength = string.len(self.curString)
    local currentString = string.sub(self.curString,0,curLength-1)
    self.curString = currentString
    self.textInputChip:setString(bm.formatNumberWithSplit(self.curString))
    if self.curString and string.len(self.curString) > 0 and tonumber(self.curString) > 0 then
        if (self.currentFortune_ > self.currentBankFortune_) and  (tonumber(self.curString) < self.currentFortune_) then
            if self.currentBankFortune_ ~= 0 and  (tonumber(self.curString) <= self.currentBankFortune_) then
                self.bankDrawButton:setButtonEnabled(true)
            else
                self.bankDrawButton:setButtonEnabled(false)
            end
        elseif (self.currentBankFortune_ > self.currentFortune_) and (tonumber(self.curString) < self.currentBankFortune_)  then
            if self.currentFortune_ ~= 0 and (tonumber(self.curString) <= self.currentFortune_) then
                if self.selectedTab_ == 1 and self.isPdeng_ then
                    self.bankSaveButton:setButtonEnabled(false)
                else
                    self.bankSaveButton:setButtonEnabled(true)
                end
            else
                self.bankSaveButton:setButtonEnabled(false)
            end
        end
    end

    self:renderCursorPos_()
end

-- 存钱
function UserBankPopup:saveChipClick_()
    if self.saveRequestId_ or self:isLoading() then
        return
    end

    local bankAct = ACTION_SAVE_MONEY
    if self.selectedTab_ == 2 then
        bankAct = ACTION_SAVE_SCORE
    end

    local money = string.gsub(self.textInputChip:getString() or "",",","")
    if self.curString == "" or tonumber(self.curString) == 0 or string.len(self.curString) == 0 then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK", "EMPYT_CHIP_NUMBER_TOP_TIP"))
        return
    end

    self:setLoading(true)
    self.saveRequestId_ = bm.HttpService.POST({
        mod="bank", act=bankAct,
        token = crypto.md5(nk.userData.uid..nk.userData.mtkey..os.time().."*&%$#@123++web-ipoker)(abc#@!<>;:to"),
        time = os.time(), money = tonumber(money), score = tonumber(money)
    },
    function(data)
        self.saveRequestId_ = nil
        local callData = json.decode(data)
        if callData then
            if callData.tag == 0 then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK","USE_BANK_NO_VIP_TOP_TIP"))
            elseif callData.tag == 1 then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK","USE_BANK_SAVE_CHIP_SUCCESS_TOP_TIP"))
                self:onOffEvent(true)
                local value = 0
                if bankAct == ACTION_SAVE_MONEY then
                    value = nk.userData.money - callData.gameMoney
                    nk.userData.bank_money = callData.bankmoney
                    nk.userData.money = callData.gameMoney                    
                else
                    value = nk.userData.score - callData.gameScore
                    nk.userData.bank_score = callData.bankscore
                    nk.userData.score = callData.gameScore 
                end
                self.textInputChip:setString("0")
                self.curString = "0"
                self:updateBankButtonStatue()
                -- 播放动画
                self:playAnimation_(bankAct, value)
                -- Umeng统计
                self:analyticsUmeng(bankAct)
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK","USE_BANK_SAVE_CHIP_FAIL_TOP_TIP"))
            end
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK","USE_BANK_SAVE_CHIP_FAIL_TOP_TIP"))
        end
        self:setLoading(false)
    end, function()
        self.saveRequestId_ = nil
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK","USE_BANK_SAVE_CHIP_FAIL_TOP_TIP"))
        self:setLoading(false)
    end)
end

-- 取钱
function UserBankPopup:drawChipClick_()
    if self.drawRequestId_ or self:isLoading() then
        return
    end

    local bankAct = ACTION_GET_MONEY
    if self.selectedTab_ == 2 then
        bankAct = ACTION_GET_SCORE
    end

    local money = string.gsub(self.textInputChip:getString() or "",",","")
    if self.curString == "" or tonumber(self.curString) == 0 or string.len(self.curString) == 0 then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK", "EMPYT_CHIP_NUMBER_TOP_TIP"))
        return
    end

    self:setLoading(true)
    self.drawRequestId_ = bm.HttpService.POST({
        mod="bank", act=bankAct, 
        token = crypto.md5(nk.userData.uid..nk.userData.mtkey..os.time().."*&%$#@123++web-ipoker)(abc#@!<>;:to"),
        time = os.time(),
        money = tonumber(money),
        score = tonumber(money)
    },
    function(data)
        self.drawRequestId_ = nil
        local callData = json.decode(data)
        if callData then
            if callData.tag == -3 then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK", "USE_BANK_DRAW_CHIP_FAIL_TOP_TIP"))
            elseif callData.tag == 1 then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK", "USE_BANK_DRAW_CHIP_SUCCESS_TOP_TIP"))
                self:onOffEvent(true)
                local value = 0
                if bankAct == ACTION_GET_MONEY then
                    value = callData.gameMoney - nk.userData.money
                    nk.userData.bank_money = callData.bankmoney
                    nk.userData.money = callData.gameMoney
                else
                    value = callData.gameScore - nk.userData.score
                    nk.userData.bank_score = callData.bankscore
                    nk.userData.score = callData.gameScore 
                end

                self.textInputChip:setString("0")
                self.curString = "0"
                self:updateBankButtonStatue()

                self:playAnimation_(bankAct, value)
                -- Umeng统计
                self:analyticsUmeng(bankAct)
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK", "USE_BANK_DRAW_CHIP_FAIL_TOP_TIP"))
            end
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK", "USE_BANK_DRAW_CHIP_FAIL_TOP_TIP"))
        end
        self:setLoading(false)
    end, function()
        self.drawRequestId_ = nil
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK", "USE_BANK_DRAW_CHIP_FAIL_TOP_TIP"))
        self:setLoading(false)
    end)
end

function UserBankPopup:playAnimation_(act, value)
    local ts = 0.2
    local delayTs = 0.1
    local upTs = 0.3
    local upDh = 80
    local px1, py1
    local px2, py2
    local icon
    local offY = 38
    local rect1, rect2
    if act == ACTION_GET_MONEY then
        px1, py1 = self.bankNode_:getPosition()
        px2, py2 = self.carryNode_:getPosition()
        rect1 = self.bankNode_.proTxt1:getParent():convertToWorldSpace(cc.p(self.bankNode_.proTxt1:getPosition()))
        rect2 = self.carryNode_.proTxt1:getParent():convertToWorldSpace(cc.p(self.carryNode_.proTxt1:getPosition()))
        icon = display.newSprite("match_chip.png")
            :pos(px1, py1)
            :addTo(self)

        icon:runAction(transition.sequence({
            cc.MoveBy:create(upTs, cc.p(0, upDh)),
            cc.RotateBy:create(ts, 360*2),
            cc.DelayTime:create(delayTs),
            cc.MoveTo:create(ts, cc.p(px2, py2)),
            cc.CallFunc:create(function(obj)
                app:tip(1, math.abs(value), rect2.x, rect2.y, 9999, 0, 20)
                app:tip(1, -1*math.abs(value), rect1.x, rect1.y-32, 9999, 0, 20)

                self:renderInfo_()
                icon:removeFromParent()
                self:onOffEvent(false)
            end)
        }))
    elseif act == ACTION_GET_SCORE then
        px1, py1 = self.bankNode_:getPosition()
        px2, py2 = self.carryNode_:getPosition()
        rect1 = self.bankNode_.proTxt2:getParent():convertToWorldSpace(cc.p(self.bankNode_.proTxt2:getPosition()))
        rect2 = self.carryNode_.proTxt2:getParent():convertToWorldSpace(cc.p(self.carryNode_.proTxt2:getPosition()))
        icon = display.newSprite("match_score.png")
            :pos(px1, py1)
            :addTo(self)
        icon:runAction(transition.sequence({
            cc.MoveBy:create(upTs, cc.p(0, upDh)),
            cc.RotateBy:create(ts, 360*2),
            cc.DelayTime:create(delayTs),
            cc.MoveTo:create(ts, cc.p(px2, py2)),
            cc.CallFunc:create(function(obj)
                app:tip(3, -1*math.abs(value), rect1.x, rect1.y, 9999, 0, 20, offY)
                app:tip(3, math.abs(value), rect2.x, rect2.y, 9999, 0, 20, offY)

                self:renderInfo_()
                icon:removeFromParent()
                self:onOffEvent(false)
            end)
        }))
    elseif act == ACTION_SAVE_MONEY then
        px2, py2 = self.bankNode_:getPosition()
        px1, py1 = self.carryNode_:getPosition()
        rect1 = self.bankNode_.proTxt1:getParent():convertToWorldSpace(cc.p(self.bankNode_.proTxt1:getPosition()))
        rect2 = self.carryNode_.proTxt1:getParent():convertToWorldSpace(cc.p(self.carryNode_.proTxt1:getPosition()))
        icon = display.newSprite("match_chip.png")
            :pos(px1, py1)
            :addTo(self)
        icon:runAction(transition.sequence({
            cc.MoveBy:create(upTs, cc.p(0, upDh)),
            cc.RotateBy:create(ts, 360*2),
            cc.DelayTime:create(delayTs),
            cc.MoveTo:create(ts, cc.p(px2, py2)),
            cc.CallFunc:create(function(obj)
                app:tip(1, math.abs(value), rect1.x, rect1.y, 9999, 0, 20)
                app:tip(1, -1*math.abs(value), rect2.x, rect2.y-32, 9999, 0, 20)

                self:renderInfo_()
                icon:removeFromParent()
                self:onOffEvent(false)
            end)
        }))
    elseif act == ACTION_SAVE_SCORE then
        px2, py2 = self.bankNode_:getPosition()
        px1, py1 = self.carryNode_:getPosition()
        rect1 = self.bankNode_.proTxt2:getParent():convertToWorldSpace(cc.p(self.bankNode_.proTxt2:getPosition()))
        rect2 = self.carryNode_.proTxt2:getParent():convertToWorldSpace(cc.p(self.carryNode_.proTxt2:getPosition()))
        icon = display.newSprite("match_score.png")
            :pos(px1, py1)
            :addTo(self)
        icon:runAction(transition.sequence({
            cc.MoveBy:create(upTs, cc.p(0, upDh)),
            cc.RotateBy:create(ts, 360*2),
            cc.DelayTime:create(delayTs),
            cc.MoveTo:create(ts, cc.p(px2, py2)),
            cc.CallFunc:create(function(obj)
                app:tip(3, math.abs(value), rect1.x, rect1.y, 9999, 0, 20, offY)
                app:tip(3, -1*math.abs(value), rect2.x, rect2.y, 9999, 0, 20, offY)

                self:renderInfo_()
                icon:removeFromParent()
                self:onOffEvent(false)
            end)
        }))
    end
end

function UserBankPopup:CancelPassWordClick_()
    self.cancelPasswordRequestId_ = bm.HttpService.POST({
        mod="bank",
        act="canclePWD",
        token = crypto.md5(nk.userData.uid..nk.userData.mtkey..os.time().."*&%$#@123++web-ipoker)(abc#@!<>;:to"),
        time =os.time()
    },
    function(data)
        self.cancelPasswordRequestId_ = nil
        local callData = json.decode(data)
        if callData ~= nil and callData.tag == 0 then
            nk.userData.bank_password = false
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK","CANCEL_PASSWORD_SUCCESS_TOP_TIP"))
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK","CANCEL_PASSWORD_FAIL_TOP_TIP"))
        end

        self:renderSetPasswordStatus_()
    end, function()
        self.cancelPasswordRequestId_ = nil
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK","CANCEL_PASSWORD_FAIL_TOP_TIP"))
    end)
end

function UserBankPopup:setPasswordClick_()
    -- 有密码的时候和没有密码时候图标不同
    if nk.userData.bank_password then
        nk.ui.Dialog.new({
            hasCloseButton = true,
            messageText = bm.LangUtil.getText("BANK", "BANK_CANCEL_OR_SETING_PASSWORD"),
            firstBtnText = bm.LangUtil.getText("BANK", "BANK_CACEL_PASSWORD_BUTTON_LABEL"),
            secondBtnText = bm.LangUtil.getText("BANK", "BANK_SETTING_PASSWORD_BUTTON_LABEL"),
            callback = function (type)
                if type == nk.ui.Dialog.FIRST_BTN_CLICK then
                    self:CancelPassWordClick_()
                elseif type == nk.ui.Dialog.SECOND_BTN_CLICK then
                    self:onSetPassWordClick_()
                end
            end
        }):show()
    else
        self:onSetPassWordClick_()
    end
end

function UserBankPopup:updateBankButtonStatue()
    if self.selectedTab_ == 1 then
        if tonumber(nk.userData.money or 0) > 0 then
            if self.isPdeng_ then
                self.bankSaveButton:setButtonEnabled(false)
            else
                self.bankSaveButton:setButtonEnabled(true)
            end
        else
            self.bankSaveButton:setButtonEnabled(false) 
        end

        if tonumber(nk.userData.bank_money or 0) > 0 then
            self.bankDrawButton:setButtonEnabled(true)
        else
            self.bankDrawButton:setButtonEnabled(false) 
        end
    else
        if tonumber(nk.userData.score or 0) > 0 then
            self.bankSaveButton:setButtonEnabled(true)
        else
            self.bankSaveButton:setButtonEnabled(false) 
        end

        if tonumber(nk.userData.bank_score or 0) > 0 then
            self.bankDrawButton:setButtonEnabled(true)
        else
            self.bankDrawButton:setButtonEnabled(false) 
        end
    end
end

function UserBankPopup:onSetPassWordClick_()
    bm.HttpService.POST(
        {
            mod="PwdProtected",
            act="getPwdquestion"
        },
        function(data)
            local ret = json.decode(data)
            if ret and ret.tag == 1 then
                ModifyBankPassWordPopup.new(ret):show()

            else
                ModifyBankPassWordPopup.new():show()
            end
        end,
        function()
            ModifyBankPassWordPopup.new():show()
        end)
    
end

-- 创建两个图标
function UserBankPopup:createTwoProIcon()
    local px, py
    local bankParams={
        "pop_bank_saved_icon.png",
        bm.LangUtil.getText("BANK", "MYSELFBANK"),
        "0",
        "0",
        1
    }
    local carryParams={
        "pop_bank_carry_icon.png",
        bm.LangUtil.getText("BANK", "CARRYMONEY"),
        "0",
        "0",
        1
    }
    self.bankNode_ = self:addProIcon(unpack(bankParams))
    px, py = -W*0.5 + 100, -H*0.5+STUFF_BAR_H*0.5 + 20
    self.bankNode_:pos(px, py)

    self.carryNode_ = self:addProIcon(unpack(carryParams))
    px, py = W*0.5 - 260, -H*0.5+STUFF_BAR_H*0.5 + 20
    self.carryNode_:pos(px, py)
end

-- 添加图标
function UserBankPopup:addProIcon(iconResId, txtString, proString1, proString2, scaleVal)
    local px, py
    local node = display.newNode()
        :addTo(self)
    local icon = display.newSprite("#"..iconResId)
        :addTo(node)
    icon:setScale(scaleVal)

    local sz = icon:getContentSize()
    sz.width = sz.width*scaleVal
    sz.height = sz.height*scaleVal
    px, py = 0, -sz.height*0.5 - 4
    local iconTxt = ui.newTTFLabel({
            text=txtString,
            color=styles.FONT_COLOR.GOLDEN_TEXT,
            size=20,
            align=ui.TEXT_ALIGN_CENTER
        })
        :pos(px, py)
        :addTo(node)

    display.newSprite("#pop_userinfo_my_bank_divide.png")
        :addTo(node)
        :pos(sz.width*0.5 + 4, -4)
        
    local offY = -40
    px, py = sz.width*0.5 + 12, 12
    local proIcon1 = display.newSprite("#"..PRO_RESID[1])
        :align(display.LEFT_CENTER, px, py)
        :addTo(node)

    local fontSize = 22
    sz = proIcon1:getContentSize()
    local proTxt1 = ui.newTTFLabel({
            text=proString1,
            color=styles.FONT_COLOR.LIGHT_TEXT,
            size=fontSize,
            align=ui.TEXT_ALIGN_LEFT
        })
        :align(display.LEFT_CENTER, px + sz.width + 5,py)
        :addTo(node)

    px = px + 2
    local proIcon2 = display.newSprite("#"..PRO_RESID[2])
        :align(display.LEFT_CENTER, px, py+offY)
        :addTo(node)

    sz = proIcon2:getContentSize()
    local proTxt2 = ui.newTTFLabel({
            text=proString2,
            color=styles.FONT_COLOR.LIGHT_TEXT,
            size=fontSize,
            align=ui.TEXT_ALIGN_LEFT
        })
        :align(display.LEFT_CENTER, px + sz.width + 5,py+offY)
        :addTo(node)

    node.icon = icon
    node.iconTxt = iconTxt
    node.proIcon1 = proIcon1
    node.proTxt1 = proTxt1
    node.proIcon2 = proIcon2
    node.proTxt2 = proTxt2

    return node
end

function UserBankPopup:onOffEvent(value)
    if value then
        bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="Wheel_start"})
    else
        bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="Wheel_end"}) 
    end
end

function UserBankPopup:onExit()
    nk.schedulerPool:delayCall(function()
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end, 0.1)

    self.cursorIcon_:stopAllActions()
    bm.EventCenter:removeEventListener(self.showExistPassWordIcon_)
end

function UserBankPopup:onClose_()
    self:hide()
end

function UserBankPopup:onShowed()
end

function UserBankPopup:show()
    nk.PopupManager:addPopup(self, true, true, true, true)
end

function UserBankPopup:onShowed()
    -- 延迟设置，防止list出现触摸边界的问题
    self.mainTabBar_:onTabChange(handler(self, self.onMainTabChange_))
end

function UserBankPopup:hide()
    self:onOffEvent(false)
    nk.PopupManager:removePopup(self)
end

function UserBankPopup:onCleanup()
    self:onOffEvent(false)
end

function UserBankPopup:onMainTabChange_(selectedTab)
    self.selectedTab_ = selectedTab
    self.curString = "0"
    self.textInputChip:setString(bm.formatNumberWithSplit(self.curString))
    self.currentProIcon_:setSpriteFrame(display.newSpriteFrame(PRO_RESID[selectedTab]))

    self.bankNode_.proTxt1:setTextColor(selectedTab==1 and styles.FONT_COLOR.LIGHT_TEXT or styles.FONT_COLOR.GREY_TEXT)
    self.bankNode_.proIcon1:setColor(selectedTab==1 and styles.FONT_COLOR.LIGHT_TEXT or styles.FONT_COLOR.GREY_TEXT)
    self.bankNode_.proTxt2:setTextColor(selectedTab==2 and styles.FONT_COLOR.LIGHT_TEXT or styles.FONT_COLOR.GREY_TEXT)
    self.bankNode_.proIcon2:setColor(selectedTab==2 and styles.FONT_COLOR.LIGHT_TEXT or styles.FONT_COLOR.GREY_TEXT)

    self.carryNode_.proTxt1:setTextColor(selectedTab==1 and styles.FONT_COLOR.LIGHT_TEXT or styles.FONT_COLOR.GREY_TEXT)
    self.carryNode_.proIcon1:setColor(selectedTab==1 and styles.FONT_COLOR.LIGHT_TEXT or styles.FONT_COLOR.GREY_TEXT)
    self.carryNode_.proTxt2:setTextColor(selectedTab==2 and styles.FONT_COLOR.LIGHT_TEXT or styles.FONT_COLOR.GREY_TEXT)
    self.carryNode_.proIcon2:setColor(selectedTab==2 and styles.FONT_COLOR.LIGHT_TEXT or styles.FONT_COLOR.GREY_TEXT)

    self:renderInfo_()
    self:renderSetPasswordStatus_()
    self:updateBankButtonStatue()
end

function UserBankPopup:renderInfo_()
    if not self.lastBankMoney_ or self.lastBankMoney_ == nk.userData.bank_money then
        self.bankNode_.proTxt1:setString(bm.formatNumberWithSplit(nk.userData.bank_money))        
    else
        bm.blinkTextTarget(self.bankNode_.proTxt1, bm.formatNumberWithSplit(nk.userData.bank_money))
    end

    if not self.lastBankScore_ or self.lastBankScore_ == nk.userData.bank_score then
        self.bankNode_.proTxt2:setString(bm.formatNumberWithSplit(nk.userData.bank_score))        
    else
        bm.blinkTextTarget(self.bankNode_.proTxt2, bm.formatNumberWithSplit(nk.userData.bank_score))
    end

    if not self.lastMoney_ or self.lastMoney_ == nk.userData.money then
        self.carryNode_.proTxt1:setString(bm.formatNumberWithSplit(nk.userData.money))
    else
        bm.blinkTextTarget(self.carryNode_.proTxt1, bm.formatNumberWithSplit(nk.userData.money))
    end

    if not self.lastScore_ or self.lastScore_ == nk.userData.score then
        self.carryNode_.proTxt2:setString(bm.formatNumberWithSplit(nk.userData.score))
    else
        bm.blinkTextTarget(self.carryNode_.proTxt2, bm.formatNumberWithSplit(nk.userData.score))
    end

    self.lastBankMoney_ = nk.userData.bank_money
    self.lastBankScore_ = nk.userData.bank_score
    self.lastMoney_ = nk.userData.money
    self.lastScore_ = nk.userData.score

    self:renderCursorPos_()

    if self.selectedTab_ == 1 then
        self.currentBankFortune_ = nk.userData.bank_money
        self.currentFortune_ = nk.userData.money
    else
        self.currentBankFortune_ = nk.userData.bank_score or 0
        self.currentFortune_ = nk.userData.score
    end
end

-- 刷新游标位置
function UserBankPopup:renderCursorPos_()
    local px, py = self.textInputChip:getPosition()
    local sz = self.textInputChip:getContentSize()
    self.cursorIcon_:setPositionX(px + sz.width)
end

function UserBankPopup:renderSetPasswordStatus_()
    -- 有密码的时候和没有密码时候图标不同
    if nk.userData.bank_password then
        self.txtTips_:hide()
        self.setPasswordButton:hide()
        self.passwordUnderLine_:show()
    else
        self.txtTips_:show()
        self.setPasswordButton:show()
        self.passwordUnderLine_:hide()
    end
end

-- action:统计动作，save存，draw取；itype：为类型 money为筹码，score为现金币
function UserBankPopup:analyticsUmeng(actionType)
    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand{
            command = "event",args = {eventId = "new_user_bank_action",label = actionType}
        }
    end
end

function UserBankPopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
                :addTo(self)
                :pos(0, 0)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

function UserBankPopup:isLoading()
    if self.juhua_ then
        return true
    else
        return false
    end
end

return UserBankPopup