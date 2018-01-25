--
-- Author: Tom
-- Date: 2014-12-30 16:41:00
-- 登录界面的反馈给官方信息弹窗
local WIDTH = 640
local HEIGHT = 380

local LoginFeedBack = class("LoginFeedBack", nk.ui.Panel)
local FeedbackCommon = import("app.module.feedback.FeedbackCommon")
function LoginFeedBack:ctor()
    LoginFeedBack.super.ctor(self,{WIDTH,HEIGHT})

    self:setNodeEventEnabled(true)
    self:setCommonStyle(bm.LangUtil.getText("LOGIN", "FEED_BACK_TITLE"))
    
    local TOP = self.height_*0.5
    local BOTTOM = -self.height_*0.5
    local LEFT = -self.width_*0.5
    local RIGHT = self.width_*0.5
    local TOP_HEIGHT = 64

    local contentWidth = WIDTH
    local contentHeight = HEIGHT
    local upContentHeight = 200

    local contentPadding = 12 

    --多行输入框
    local inputWidth  = 454
    local inputHeight = 136
    local inputContentSize = 20
    local inputContentColor = cc.c3b(0xca, 0xca, 0xca)
    self.inputEditBox = ui.newEditBox({
            image = "#common_input_bg.png",
            imagePressed="#common_input_bg_down.png", 
            size = cc.size(inputWidth, inputHeight),
            x = 0,
            y = 30,
            listener = handler(self, self.onContentEdit_)
        })
        :addTo(self)
    self.inputEditBox:setTouchSwallowEnabled(false)
    self.inputEditBox:setFontColor(inputContentColor)
    self.inputEditBox:setPlaceholderFontColor(inputContentColor)
    self.inputEditBox:setFont(ui.DEFAULT_TTF_FONT, inputContentSize)
    self.inputEditBox:setPlaceholderFont(ui.DEFAULT_TTF_FONT, inputContentSize)
    self.inputEditBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.inputEditBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)

    self.showContent = ui.newTTFLabel({
            text = "",
            size = inputContentSize,
            color = inputContentColor,
            align = ui.TEXT_ALIGN_LEFT,
            valign = ui.TEXT_VALIGN_TOP,
            dimensions = cc.size(inputWidth - 30, inputHeight - 30)
        })
        :pos(0, 40)
        :addTo(self)
        :size(inputWidth, inputHeight)
    self.showContent:setString(bm.LangUtil.getText("LOGIN", "FEED_BACK_HINT"))

    local inputTextBox = display.newNode():pos(17,-70):addTo(self)
    self.input1_ = ui.newEditBox({
            image = "#common_input_bg.png",
            imagePressed = "#common_input_bg_down.png",
            size = cc.size(323, 38),
            align = ui.TEXT_ALIGN_CENTER
    }):pos(0,0):addTo(inputTextBox, 100)
    self.input1_:setFontName(ui.DEFAULT_TTF_FONT)
    self.input1_:setFontSize(20)
    self.input1_:setFontColor(inputContentColor)
    self.input1_:setPlaceholderFontName(ui.DEFAULT_TTF_FONT)
    self.input1_:setPlaceholderFontSize(20)
    self.input1_:setPlaceholderFontColor(inputContentColor)
    self.input1_:setPlaceHolder(bm.LangUtil.getText("LOGIN", "PHONE_NUMBER"))
    self.input1_:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.input1_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)

    display.newSprite("phone_num.png"):pos(-323/2-15, 0):addTo(inputTextBox, 101)

    self.sendButton_ = cc.ui.UIPushButton.new({normal = "#common_btn_green_normal.png",pressed = "#common_btn_green_pressed.png"},{scale9 = true})
    :setButtonLabel("normal", ui.newTTFLabel({text = bm.LangUtil.getText("COMMON", "SEND"),size = 26,color = cc.c3b(0xd6, 0xff, 0xef),align = ui.TEXT_ALIGN_CENTER}))
    :setButtonSize(180, 55)
    :pos(0, BOTTOM + 55)
    :onButtonClicked(buttontHandler(self, self.sendFeedBackHandler_))
    :addTo(self)
end

function LoginFeedBack:onContentEdit_(event, editbox)
    if event == "began" then
        -- 开始输入
        local displayingText = self.showContent:getString()
        if displayingText == bm.LangUtil.getText("LOGIN", "FEED_BACK_HINT") then
            self.inputEditBox:setText("")
        else
            self.inputEditBox:setText(displayingText)
        end
        self.showContent:setString("")
    elseif event == "changed" then
        -- 输入框内容发生变化
    elseif event == "ended" then
        -- 输入结束
        local text = editbox:getText()
        if text == "" then 
            text = bm.LangUtil.getText("LOGIN", "FEED_BACK_HINT")
        end
        self.showContent:setString(text)
        editbox:setText("")
    elseif event == "return" then
        -- 从输入框返回
    end
end

function LoginFeedBack:sendFeedBackHandler_()
    if self.showContent:getString() ==  bm.LangUtil.getText("LOGIN", "FEED_BACK_HINT") then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("HELP", "MUST_INPUT_FEEDBACK_TEXT_MSG"))
        return
    end

    local phone = string.trim(self.input1_:getText())
    if string.len(phone) == 0 then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("HELP", "MUST_INPUT_FEEDBACK_PHONE_NUM"))
        return
    end

    local postParam = {
        title = "",
        ftype = 402,
        fwords = "login feedback:"..self.showContent:getString(),
        fcontact = "phone:"..phone
    }
    FeedbackCommon.sendFeedback(postParam,function(succ,reason)
            if succ then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("HELP", "FEED_BACK_SUCCESS"))
                self.showContent:setString(bm.LangUtil.getText("LOGIN", "FEED_BACK_HINT"))
                self:hide()
            else
                if reason == "network" then
                    nk.TopTipManager:showTopTip(bm.LanUtil.getText("TIPS", "ERROR_SEND_FEEDBACK"))
                elseif reason == 'paramerr' then
                    nk.TopTipManager:showTopTip(bm.LanUtil.getText("TIPS", "ERROR_FEEDBACK_SERVER_ERROR"))
                end
            end
        end)
    
    if appconfig.SID == nil then
        appconfig.SID = {}
    end
    local version = BM_UPDATE and BM_UPDATE.VERSION or nk.Native:getAppVersion()
    local params = {
            mod = "Feedback",
            act = "sendEmail",           
            msg = "login feedback: <br />&nbsp;&nbsp;&nbsp;&nbsp;"..self.showContent:getString() .. "<br />".."version: ".. version .."<br />" .."phone: "..phone,
            time = bm.getTime(),           
            sig = crypto.md5(bm.getTime().."feedback_befor_login@#$%^"),
            lid = 1,
            sid = appconfig.SID[string.upper(device.platform)] or 1,
            version = version
        }
    local feedBackUrl = BM_UPDATE.FEEDBACK_URL
    if string.len(feedBackUrl) > 5 then
            bm.HttpService.POST_URL(feedBackUrl,
            params         
        )
    end
end

function LoginFeedBack:show()
    self:showPanel_()
end

function LoginFeedBack:hide()
    self:hidePanel_()
end

return LoginFeedBack
