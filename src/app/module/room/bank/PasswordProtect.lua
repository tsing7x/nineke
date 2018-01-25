--
-- Author: Jonah0608@gmail.com
-- Date: 2015-07-27 17:05:02
--
local WIDTH = 640 
local HEIGHT = 380 
local TOP_HEIGHT = 84
local PADDING = 4

local DropDownList = import("app.module.room.bank.DropDownList")
local SettingAndHelpPopup = import("app.module.settingAndhelp.SettingAndHelpPopup")
local PasswordProtect = class("PasswordProtect", nk.ui.Panel)

PasswordProtect.OPT_SET = 1
PasswordProtect.OPT_UPDATE = 2
PasswordProtect.OPT_VERIFY = 3

function PasswordProtect:ctor(opt,question1,question2)
    PasswordProtect.super.ctor(self,{WIDTH,HEIGHT})
    self.opt_ = opt or PasswordProtect.OPT_SET
    self.question1_ = question1 or 1
    self.question2_ = question2 or 6

    self:setupView()

    self:setNodeEventEnabled(true)
end

function PasswordProtect:onCleanup()
    if self.onEditBoxTouchEnabledId_ then
        bm.EventCenter:removeEventListener(self.onEditBoxTouchEnabledId_)
        self.onEditBoxTouchEnabledId_ = nil
    end

    if self.onEditBoxTouchDisenabledId_ then
        bm.EventCenter:removeEventListener(self.onEditBoxTouchDisenabledId_)
        self.onEditBoxTouchDisenabledId_ = nil
    end

    nk.EditBoxManager:removeEditBox(self.protectAns1_)
    nk.EditBoxManager:removeEditBox(self.protectAns2_)
end

function PasswordProtect:setupView()
    local TOP = self.height_*0.5
    local BOTTOM = -self.height_*0.5
    local LEFT = -self.width_*0.5 + 20
    local RIGHT = self.width_*0.5
    local TOP_HEIGHT = 72

    -- panel背景
    display.newScale9Sprite("#panel_overlay.png", 0, 0, cc.size(self.width_ - PADDING * 2, self.height_ - PADDING * 4 - TOP_HEIGHT))
        :pos(0, -30)
        :addTo(self)

    local titleStr = bm.LangUtil.getText("BANK","PROTECT_SET")
    if self.opt_ == PasswordProtect.OPT_UPDATE then
        titleStr = bm.LangUtil.getText("BANK","PROTECT_UPDATE")
    elseif self.opt_ == PasswordProtect.OPT_VERIFY then
        titleStr = bm.LangUtil.getText("BANK","PROTECT_VERIFY")
    end

    --标题
    self:setCommonStyle(titleStr)

    local titleTips = bm.LangUtil.getText("BANK","PROTECT_TITLETIPS_SET")
    if self.opt_ == PasswordProtect.OPT_UPDATE then
        titleTips = bm.LangUtil.getText("BANK","PROTECT_TITLETIPS_UPDATE")
    elseif self.opt_ == PasswordProtect.OPT_VERIFY then
        titleTips = bm.LangUtil.getText("BANK","PROTECT_TITLETIPS_VERIFY")
    end

    -- 说明
    local posY = self.height_ * 0.5 - TOP_HEIGHT * 0.5 - TOP_HEIGHT
    ui.newTTFLabel({text = titleTips, color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})
        :pos(0, posY)
        :addTo(self)
    posY = posY - 40

    -- 问题1
    ui.newTTFLabel({text = bm.LangUtil.getText("BANK","PROTECT_QUES1TITLE"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 24, dimensions=cc.size(150,30), align = ui.TEXT_ALIGN_RIGHT})
        :pos(LEFT + 50, posY)
        :addTo(self)

    local data = bm.LangUtil.getText("BANK","PROTECT_QUESTIONS")
    if self.question1_ > #data or self.question1_ <= 0 then
        self.question1_ = 1
    end

    if self.question2_ > #data or self.question2_ <= 0 then
        self.question2_ = 6
    end

    if self.opt_  == PasswordProtect.OPT_VERIFY then
        ui.newTTFLabel({text = data[self.question1_], color = styles.FONT_COLOR.LIGHT_TEXT, size = 24, dimensions=cc.size(WIDTH - 260,30), align = ui.TEXT_ALIGN_LEFT})
        :align(display.LEFT_CENTER)
        :pos(LEFT + 150, posY)
        :addTo(self)
    else
        self.ans1_ = DropDownList.new({width = WIDTH - 260,height = 35, posX = 510,posY = 235, listData = data,selected = self.question1_})
            :pos(LEFT + 330,posY)
            :addTo(self,100)
    end

    posY = posY - 40
    ui.newTTFLabel({text = bm.LangUtil.getText("BANK","PROTECT_ANSTITLE"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 24, dimensions=cc.size(150,30), align = ui.TEXT_ALIGN_RIGHT})
        :pos(LEFT + 50, posY)
        :addTo(self)
    self.protectAns1_ = ui.newEditBox({
        size = cc.size(WIDTH - 260, 35),
        align=ui.TEXT_ALIGN_CENTER,
        image="#invite_friend_inputback.png",
        imagePressed="#invite_friend_inputback.png",
        x = 30,
        y = posY,
        listener = handler(self, self.onInputAns1Edit_)
    })
    self.protectAns1_:setFontName(ui.DEFAULT_TTF_FONT)
    self.protectAns1_:setFontSize(24)
    self.protectAns1_:setFontColor(cc.c3b(0x92, 0x8d, 0x8d))
    self.protectAns1_:setPlaceholderFontName(ui.DEFAULT_TTF_FONT)
    self.protectAns1_:setPlaceholderFontSize(24)
    self.protectAns1_:setPlaceholderFontColor(cc.c3b(0x92, 0x8d, 0x8d))
    self.protectAns1_:setPlaceHolder(bm.LangUtil.getText("BANK", "PROTECT_ANSTIPS"))
    self.protectAns1_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.protectAns1_:setReturnType( cc.KEYBOARD_RETURNTYPE_GO)
    self.protectAns1_:addTo(self)

    posY = posY - 40
    ui.newTTFLabel({text = bm.LangUtil.getText("BANK","PROTECT_QUES2TITLE"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 24, dimensions=cc.size(150,30), align = ui.TEXT_ALIGN_RIGHT})
        :pos(LEFT + 50, posY)
        :addTo(self)

    if self.opt_ == PasswordProtect.OPT_VERIFY then
        ui.newTTFLabel({text = data[self.question2_], color = styles.FONT_COLOR.LIGHT_TEXT, size = 24, dimensions=cc.size(WIDTH - 260,30), align = ui.TEXT_ALIGN_LEFT})
        :align(display.LEFT_CENTER)
        :pos(LEFT + 150, posY)
        :addTo(self)
    else
        self.ans2_ = DropDownList.new({width = WIDTH - 260,height = 35, posX = 510,posY = 155, listData = data,selected = self.question2_})
            :pos(LEFT + 330,posY)
            :addTo(self,100)
    end
    
    posY = posY - 40
    ui.newTTFLabel({text = bm.LangUtil.getText("BANK","PROTECT_ANSTITLE"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 24, dimensions=cc.size(150,30), align = ui.TEXT_ALIGN_RIGHT})
        :pos(LEFT + 50, posY)
        :addTo(self)
    self.protectAns2_ = ui.newEditBox({
        size = cc.size(WIDTH - 260, 35),
        align=ui.TEXT_ALIGN_CENTER,
        image="#invite_friend_inputback.png",
        imagePressed="#invite_friend_inputback.png",
        x = 30,
        y = posY,
        listener = handler(self, self.onInputAns2Edit_)
    })
    self.protectAns2_:setFontName(ui.DEFAULT_TTF_FONT)
    self.protectAns2_:setFontSize(24)
    self.protectAns2_:setFontColor(cc.c3b(0x92, 0x8d, 0x8d))
    self.protectAns2_:setPlaceholderFontName(ui.DEFAULT_TTF_FONT)
    self.protectAns2_:setPlaceholderFontSize(24)
    self.protectAns2_:setPlaceholderFontColor(cc.c3b(0x92, 0x8d, 0x8d))
    self.protectAns2_:setPlaceHolder(bm.LangUtil.getText("BANK", "PROTECT_ANSTIPS"))
    self.protectAns2_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.protectAns2_:setReturnType( cc.KEYBOARD_RETURNTYPE_GO)
    self.protectAns2_:addTo(self)

    nk.EditBoxManager:addEditBox(self.protectAns1_)
    nk.EditBoxManager:addEditBox(self.protectAns2_)

    if self.opt_ == PasswordProtect.OPT_VERIFY then
        self.confirmButton_ = cc.ui.UIPushButton.new({normal = "#common_btn_blue_normal.png", pressed = "#common_btn_blue_pressed.png"}, {scale9 = true})
            :setButtonSize(200, 55)
            :setButtonLabel(ui.newTTFLabel({text=bm.LangUtil.getText("BANK","PROTECT_FEEDBACK"), size=24, color=cc.c3b(0xb2, 0xdc, 0xff), align=ui.TEXT_ALIGN_CENTER}))
            :onButtonClicked(handler(self, self.forgetPasswordProtect_))
            :pos(LEFT + 160, BOTTOM + 53)
            :addTo(self)
        self.verifyButton_ = cc.ui.UIPushButton.new({normal = "#common_btn_green_normal.png", pressed = "#common_btn_green_pressed.png"}, {scale9 = true})
            :setButtonSize(200, 55)
            :setButtonLabel(ui.newTTFLabel({text=bm.LangUtil.getText("COMMON", "CONFIRM"), size=24, color=cc.c3b(0xb2, 0xdc, 0xff), align=ui.TEXT_ALIGN_CENTER}))
            :onButtonClicked(handler(self, self.verifyAns_))
            :pos(RIGHT - 160, BOTTOM + 53)
            :addTo(self)
    else
        self.confirmButton_ = cc.ui.UIPushButton.new({normal = "#common_btn_green_normal.png", pressed = "#common_btn_green_pressed.png"}, {scale9 = true})
            :setButtonSize(200, 55)
            :setButtonLabel(ui.newTTFLabel({text=bm.LangUtil.getText("COMMON", "CONFIRM"), size=24, color=cc.c3b(0xb2, 0xdc, 0xff), align=ui.TEXT_ALIGN_CENTER}))
            :onButtonClicked(handler(self, self.confirmProtectAnsClick_))
            :pos(0, BOTTOM + 53)
            :addTo(self)
    end
end

function PasswordProtect:onInputAns1Edit_(event)
    if event == "began" then
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    elseif event == "changed" then
        self.inputAns1Edit_ = self.protectAns1_:getText()
    elseif event == "ended" then
    elseif event == "return" then
    end
end

function PasswordProtect:onInputAns2Edit_(event)
    if event == "began" then
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    elseif event == "changed" then
        self.inputAns2Edit_ = self.protectAns2_:getText()
    elseif event == "ended" then
    elseif event == "return" then
    end
end

function PasswordProtect:confirmProtectAnsClick_()
    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    if (self.inputAns1Edit_ == nil or self.inputAns2Edit_ == nil) then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK", "PROTECT_ERRORTIPS"))
        return 
    end

    local qusData = {}
    qusData.qusid = {self.ans1_:getId(),self.ans2_:getId()}
    qusData.answer = {self.inputAns1Edit_ , self.inputAns2Edit_}

    local qusJson = json.encode(qusData)
    self.confirmRequestId_ = bm.HttpService.POST(
        {mod="PwdProtected", act="setPwdquestion", question = qusJson},
        function(data) 
            self.confirmRequestId_ = nil
            local callData = json.decode(data)
            if callData ~= nil and callData.tag == 1 then
                self:hide()
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK", "PROTECT_SETSUCC"))
            elseif callData ~= nil and callData.tag == 2 then
                self:hide()
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK", "PROTECT_UPDATESUCC"))
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK", "PROTECT_SETERROR"))
            end
        end, function()
            self.confirmRequestId_ = nil
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK", "PROTECT_SETERROR"))
        end)
end

function PasswordProtect:forgetPasswordProtect_()
    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    SettingAndHelpPopup.new(false ,true ,1):show()
end

function PasswordProtect:verifyAns_()
    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    if (self.inputAns1Edit_ == nil or self.inputAns2Edit_ == nil) then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK", "PROTECT_ERRORTIPS"))
        return 
    end

    local ansData = {self.inputAns1Edit_ , self.inputAns2Edit_}
    local ansJson = json.encode(ansData)
    self.confirmRequestId_ = bm.HttpService.POST(
        {mod="PwdProtected", act="testPwdquestion", answer = ansJson},
        function(data) 
            self.confirmRequestId_ = nil
            local callData = json.decode(data)
            if callData ~= nil and callData.tag == 1 then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK", "PROTECT_ANSSUCCESS"))
                bm.EventCenter:dispatchEvent({name = nk.eventNames.OPEN_RESET_PASSWORD_DIALOG})
                self:hide()

                PasswordProtect.analyticsUmeng()
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK", "PROTECT_VERIFYERROR"))
            end
        end, function()
            self.confirmRequestId_ = nil
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK", "PROTECT_VERIFYERROR"))
        end)
end

function PasswordProtect.analyticsUmeng()
    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand{
            command = "event",args = {eventId = "new_user_resetPasswordProect",label = "new_user_resetPasswordProect"}
        }
    end
end

function PasswordProtect:show()
    self:showPanel_()
end

function PasswordProtect:hide()
    self:hidePanel_()
end

return PasswordProtect