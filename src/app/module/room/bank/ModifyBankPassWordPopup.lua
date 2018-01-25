--
-- Author: Tom
-- Date: 2014-11-06 16:04:59
--
local WIDTH = 640 
local HEIGHT = 380 
local TOP_HEIGHT = 84
local ModifyBankPassWordPopup = class("ModifyBankPassWordPopup", nk.ui.Panel)
local PADDING = 4

local PasswordProtect = import(".PasswordProtect")

function ModifyBankPassWordPopup:ctor(protectData)
    ModifyBankPassWordPopup.super.ctor(self,{WIDTH,HEIGHT})

    local TOP = self.height_*0.5
    local BOTTOM = -self.height_*0.5
    local LEFT = -self.width_*0.5
    local RIGHT = self.width_*0.5
    local TOP_HEIGHT = 72

    self.protectData_ = protectData

    display.newScale9Sprite("#panel_overlay.png", 0, 0, cc.size(self.width_ - PADDING * 2, self.height_ - PADDING * 4 - TOP_HEIGHT))
        :pos(0, -30)
        :addTo(self)
    
    -- 添加标签
    self:setCommonStyle(bm.LangUtil.getText("BANK", "BANK_SET_PASSWORD_TOP_TITLE"))

    self.editInputPassword_ = ui.newEditBox({
        size = cc.size(WIDTH - 160, 52),
        align=ui.TEXT_ALIGN_CENTER - 30,
        image="#common_input_bg.png",
        imagePressed="#common_input_bg_down.png",
        x = 0,
        y = 65,
        listener = handler(self, self.onInputPassWordCodeEdit_)
    })
    self.editInputPassword_:setFontName(ui.DEFAULT_TTF_FONT)
    self.editInputPassword_:setFontSize(24)
    self.editInputPassword_:setFontColor(cc.c3b(0x92, 0x8d, 0x8d))
    self.editInputPassword_:setPlaceholderFontName(ui.DEFAULT_TTF_FONT)
    self.editInputPassword_:setPlaceholderFontSize(24)
    self.editInputPassword_:setPlaceholderFontColor(cc.c3b(0x92, 0x8d, 0x8d))
    self.editInputPassword_:setPlaceHolder(bm.LangUtil.getText("BANK", "BANK_INPUT_TEXT_DEFAULT_LABEL"))
    self.editInputPassword_:setReturnType(cc.KEYBOARD_RETURNTYPE_GO)
    self.editInputPassword_:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.editInputPassword_:addTo(self)

    self.editConfirmInputPassword_ = ui.newEditBox({
        size = cc.size(WIDTH - 160, 62),
        align=ui.TEXT_ALIGN_CENTER - 30,
        image="#common_input_bg.png",
        imagePressed="#common_input_bg_down.png",
        x = 0,
        y = -20,
        listener = handler(self, self.onConfirmInputPassWordCodeEdit_)
    })
    self.editConfirmInputPassword_:setFontName(ui.DEFAULT_TTF_FONT)
    self.editConfirmInputPassword_:setFontSize(24)
    self.editConfirmInputPassword_:setFontColor(cc.c3b(0x92, 0x8d, 0x8d))
    self.editConfirmInputPassword_:setPlaceholderFontName(ui.DEFAULT_TTF_FONT)
    self.editConfirmInputPassword_:setPlaceholderFontSize(24)
    self.editConfirmInputPassword_:setPlaceholderFontColor(cc.c3b(0x92, 0x8d, 0x8d))
    self.editConfirmInputPassword_:setPlaceHolder(bm.LangUtil.getText("BANK","BANK_CONFIRM_INPUT_TEXT_DEFAULT_LABEL"))
    self.editConfirmInputPassword_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.editConfirmInputPassword_:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.editConfirmInputPassword_:addTo(self)

    --密码保护
    local protectStr = bm.LangUtil.getText("BANK","PROTECT_SET")
    if self.protectData_ and self.protectData_.tag == 1 then
        protectStr = bm.LangUtil.getText("BANK","PROTECT_UPDATE")
    end

    self.protectButton_ = cc.ui.UIPushButton.new({normal = "#common_btn_blue_normal.png", pressed = "#common_btn_blue_pressed.png"}, {scale9 = true})
        :setButtonSize(200, 55)
        :setButtonLabel(ui.newTTFLabel({text=protectStr, size=24, color=cc.c3b(0xb2, 0xdc, 0xff), align=ui.TEXT_ALIGN_CENTER}))
        :onButtonClicked(handler(self, self.setPasswordProtect_))
        :pos(-150, BOTTOM + 63)
        :addTo(self)

    if self.protectData_ and self.protectData_.tag == 1 then
    else
        display.newSprite("#password_protect_add_money.png")
            :pos(-50,BOTTOM + 83)
            :addTo(self)
    end

    -- 确认输入密码
    self.confirmButton_ = cc.ui.UIPushButton.new({normal = "#common_btn_green_normal.png", pressed = "#common_btn_green_pressed.png"}, {scale9 = true})
        :setButtonSize(200, 55)
        :setButtonLabel(ui.newTTFLabel({text=bm.LangUtil.getText("COMMON", "CONFIRM"), size=24, color=cc.c3b(0xb2, 0xdc, 0xff), align=ui.TEXT_ALIGN_CENTER}))
        :onButtonClicked(handler(self, self.confirmPassWordClick_))
        :pos(150, BOTTOM + 63)
        :addTo(self)
end

function ModifyBankPassWordPopup:onInputPassWordCodeEdit_(event)
    if event == "began" then
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    elseif event == "changed" then
        self.inputCodeEdit_ = self.editInputPassword_:getText()
    elseif event == "ended" then
    elseif event == "return" then
    end
end

function ModifyBankPassWordPopup:onConfirmInputPassWordCodeEdit_(event)
    if event == "began" then
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    elseif event == "changed" then
        self.confirmCodeEdit_ = self.editConfirmInputPassword_:getText()
    elseif event == "ended" then  
    elseif event == "return" then
    end
end

function ModifyBankPassWordPopup:setPasswordProtect_()
    self:hide()
    nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
    if self.protectData_ and self.protectData_.tag == 1 then
        PasswordProtect.new(PasswordProtect.OPT_UPDATE,self.protectData_.data[1],self.protectData_.data[2]):show()
    else
        PasswordProtect.new(PasswordProtect.OPT_SET):show()
    end
end

function ModifyBankPassWordPopup:confirmPassWordClick_()
    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    if (self.confirmCodeEdit_ == nil or self.inputCodeEdit_ == nil) then
        return 
    end

    if nk.userData.level >= 5 then
        self.confirmRequestId_ = bm.HttpService.POST({mod="bank", act="setPwd", token = crypto.md5(nk.userData.uid..nk.userData.mtkey..os.time().."*&%$#@123++web-ipoker)(abc#@!<>;:to"), time =os.time(), password1 = crypto.md5(crypto.md5(string.trim(self.inputCodeEdit_))) , password2 = crypto.md5(crypto.md5(string.trim(self.confirmCodeEdit_)))},
        function(data) 
            self.confirmRequestId_ = nil
            local callData = json.decode(data)
            if callData ~= nil and callData.tag == 1 then
                self:hide()
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK", "BANK_SET_PASSWORD_SUCCESS_TOP_TIP"))
                nk.userData.bank_password = true 
                bm.EventCenter:dispatchEvent({name = nk.eventNames.SHOW_EXIST_PASSWORD_ICON})
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK", "BANK_SET_PASSWORD_FAIL_TOP_TIP"))
            end
        end, function()
            self.confirmRequestId_ = nil
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK", "BANK_SET_PASSWORD_FAIL_TOP_TIP"))
        end)
    else
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK", "BANK.BANK_LEVELS_DID_NOT_REACH"))
    end
end

function ModifyBankPassWordPopup:show()
    self:showPanel_()
end

function ModifyBankPassWordPopup:hide()
    self:hidePanel_()
end


return ModifyBankPassWordPopup