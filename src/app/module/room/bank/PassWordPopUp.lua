--
-- Author: Tom
-- Date: 2014-11-07 16:06:44
--
local WIDTH = 640 
local HEIGHT = 420 
local PassWordPopUp = class("PassWordPopUp", nk.ui.Panel)
local SettingAndHelpPopup = import("app.module.settingAndhelp.SettingAndHelpPopup")
local PasswordProtect = import("app.module.room.bank.PasswordProtect")
local PADDING = 4

function PassWordPopUp:ctor()
    PassWordPopUp.super.ctor(self,{WIDTH,HEIGHT})

    local TOP = self.height_*0.5
    local BOTTOM = -self.height_*0.5
    local LEFT = -self.width_*0.5
    local RIGHT = self.width_*0.5
    local TOP_HEIGHT = 72

    -- overlay
    display.newScale9Sprite("#panel_overlay.png", 0, 0, cc.size(self.width_ - PADDING * 2, self.height_ - PADDING * 4 - TOP_HEIGHT))
        :pos(0, -30)
        :addTo(self)
    
    -- 添加标签
    self:setCommonStyle(bm.LangUtil.getText("BANK", "BANK_POPUP_TOP_TITIE"))


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
    self.editInputPassword_:setPlaceHolder(bm.LangUtil.getText("BANK","BANK_INPUT_TEXT_DEFAULT_LABEL"))
    self.editInputPassword_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.editInputPassword_:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.editInputPassword_:addTo(self)

    -- 密码正确的时候图标
    self.correctPassWordIcon = display.newSprite("#common-password-correct-icon.png")
        :pos(self.editInputPassword_:getPositionX()+ self.editInputPassword_:getContentSize().width * 0.5 + 30, 65)
        :addTo(self)
        :hide()

    -- 密码错误的时候图标
    self.errorPassWordIcon = display.newSprite("#common-password-error-icon.png")
        :pos(self.editInputPassword_:getPositionX()+ self.editInputPassword_:getContentSize().width * 0.5 + 30, 65)
        :addTo(self)
        :hide()


    -- 忘记密码
    self.forgetButton_ = cc.ui.UIPushButton.new({normal = "#common_btn_blue_normal.png", pressed = "#common_btn_blue_pressed.png"}, {scale9 = true})
        :setButtonSize(200, 55)
        :setButtonLabel(ui.newTTFLabel({text=bm.LangUtil.getText("BANK", "BANK_FORGET_PASSWORD_BUTTON_LABEL"), size=24, color=cc.c3b(0xb2, 0xdc, 0xff), align=ui.TEXT_ALIGN_CENTER}))
        :onButtonClicked(handler(self, self.forgetPassWordClick_))
        :pos(LEFT + 160, BOTTOM + 63)
        :addTo(self)


    -- 确认输入密码
    self.confirmButton_ = cc.ui.UIPushButton.new({normal = "#common_btn_green_normal.png", pressed = "#common_btn_green_pressed.png"}, {scale9 = true})
        :setButtonSize(200, 55)
        :setButtonLabel(ui.newTTFLabel({text=bm.LangUtil.getText("COMMON", "CONFIRM"), size=24, color=cc.c3b(0xb2, 0xdc, 0xff), align=ui.TEXT_ALIGN_CENTER}))
        :onButtonClicked(handler(self, self.confirmPassWordClick_))
        :pos(RIGHT - 160, BOTTOM + 63)
        :addTo(self)

    --忘记密码提示
    self.forgetPrompt = ui.newTTFLabel({text = bm.LangUtil.getText("BANK","BANK_FORGET_PASSWORD_FEEDBACK"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 24,dimensions = cc.size(WIDTH - 120, 200), align = ui.TEXT_ALIGN_LEFT})
        :pos(20, BOTTOM + 173)
        :addTo(self)

end


function PassWordPopUp:onInputPassWordCodeEdit_(event)
    if event == "began" then
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    elseif event == "changed" then
        self.inputCodeEdit_ = self.editInputPassword_:getText()
    elseif event == "ended" then
    elseif event == "return" then
    end
end

function PassWordPopUp:confirmPassWordClick_()
    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    if self.inputCodeEdit_ == nil then
        return
    end
    local st = "*&%$#@123++web-ipoker)(abc#@!<>;:to"
    local tk = nk.userData.uid..nk.userData.mtkey .. os.time() .. st
    self.confirmPasswordRequestId_ = bm.HttpService.POST(
        {
            mod="bank",
            act="bankCheckpsw",
            token = crypto.md5(tk),
            time =os.time(),
            password = crypto.md5(crypto.md5(string.trim(self.inputCodeEdit_)))
        },
        function(data)
            self.confirmPasswordRequestId_ = nil
            local callData = json.decode(data)
            if callData then
                if callData.tag == 1 then
                    bm.EventCenter:dispatchEvent({name = nk.eventNames.OPEN_BANK_POPUP_VIEW})
                    self.correctPassWordIcon:show()
                    self:hide()
                elseif callData.tag == 0  then
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK", "BANK_INPUT_PASSWORD_ERROR"))
                    self.errorPassWordIcon:show()
                else
                    --nk.TopTipManager:showTopTip(bm.LangUtil.getText("TIPS", "EXCEPTION_BACK_CHECK_PWD"))
                end
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("TIPS", "EXCEPTION_BACK_CHECK_PWD"))
            end
        end, function()
            self.confirmPasswordRequestId_ = nil
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("TIPS", "ERROR_BACK_CHECK_PWD"))
        end)
end

function PassWordPopUp:forgetPassWordClick_()
    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    bm.HttpService.POST(
        {
            mod="PwdProtected",
            act="getPwdquestion"
        },
        function(data)
            local ret = json.decode(data)
            if ret and ret.tag == 1 then
                PasswordProtect.new(PasswordProtect.OPT_VERIFY,ret.data[1],ret.data[2]):show()
                self:hide()
            else
                SettingAndHelpPopup.new(false ,true ,1):show()
            end
        end,
        function()
            SettingAndHelpPopup.new(false ,true ,1):show()
        end)
    -- SettingAndHelpPopup.new(false ,true ,1):show()
end

function PassWordPopUp:show()
    self:showPanel_()
end

function PassWordPopUp:hide()
    self:hidePanel_()
end


return PassWordPopUp
