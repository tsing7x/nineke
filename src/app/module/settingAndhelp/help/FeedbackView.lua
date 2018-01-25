--
-- Author: viking@boomegg.com
-- Date: 2014-08-28 15:25:08
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local FeedbackView = class("FeedbackView", function ()
    return display.newNode()
end)

local FeedbackListItem = import(".listItems.FeedbackListItem")
local FeedbackCommon = import("app.module.feedback.FeedbackCommon")
local logger = bm.Logger.new("FeedbackView")

FeedbackView.feedbackInfo = {
    uid = "",
    tid = "",
    model = ""
}

function FeedbackView:ctor(helpView)
    self:setNodeEventEnabled(true)
    self.helpView_ = helpView
    self.viewRectWidth_, self.viewRectHeight_ = helpView.viewRectWidth, helpView.viewRectHeight
    self.controller_ = helpView.controller_
    self:setupView()
end

function FeedbackView:setupView()
    local contentWidth = self.viewRectWidth_
    local contentHeight = self.viewRectHeight_

    --多行输入框
    local inputWidth  = 480
    local inputHeight = 190
    local inputContentSize = 24
    local inputContentColor = cc.c3b(0xca, 0xca, 0xca)
    local inputEditBox_x, inputEditBox_y = -contentWidth/2 + 20, 70
    self.inputEditBox = ui.newEditBox({
            image = "#common_input_bg.png",
            imagePressed="#common_input_bg_down.png", 
            size = cc.size(inputWidth, inputHeight),
            listener = handler(self, self.onContentEdit_)
        })
        :align(display.LEFT_CENTER, inputEditBox_x, inputEditBox_y)
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
            size = 20,
            color = inputContentColor,
            align = ui.TEXT_ALIGN_LEFT,
            valign = ui.TEXT_VALIGN_TOP,
            dimensions = cc.size(inputWidth - 50, inputHeight - 10)
        })
        :align(display.LEFT_CENTER, inputEditBox_x + 10, inputEditBox_y - 4)
        :addTo(self)
        :size(inputWidth, inputHeight)
    self.showContent:setString(bm.LangUtil.getText("HELP", "FEED_BACK_HINT"))

    --上传图片
    self.uploadPicBtnWidth = 180
    self.uploadPicBtnHeight = 120
    self.uploadPicIcon_ = display.newSprite("#help_upload_pic_icon.png"):align(display.CENTER, 8, 0)

    local icon_x = contentWidth/2 - self.uploadPicBtnWidth/2 - 30
    local icon_y = contentHeight/2 - self.uploadPicBtnHeight/2 + 18
    display.newScale9Sprite(
        "#pop_help_upload_icon_bg.png",
        icon_x, icon_y,
        cc.size(self.uploadPicBtnWidth, self.uploadPicBtnHeight)):addTo(self)
    self.uploadPicBtn = cc.ui.UIPushButton.new({normal = "#transparent.png", pressed = "#common_button_pressed_cover.png"}, {scale9 = true})
        :addTo(self)
        :setButtonSize(self.uploadPicBtnWidth, self.uploadPicBtnHeight)
        :pos(icon_x, icon_y)
        :onButtonClicked(buttontHandler(self, self.onUploadPic_))
        :add(self.uploadPicIcon_)
        self.uploadPicBtn:setTouchSwallowEnabled(false)

    --确定上传
    local sendBtnHeight = 55
    self.sendBtn = cc.ui.UIPushButton.new({normal = "#common_btn_green_normal.png", pressed = "#common_btn_green_pressed.png", disabled="#common_btn_disabled.png"}, {scale9 = true})
        :addTo(self)
        :setButtonSize(self.uploadPicBtnWidth, sendBtnHeight)
        :pos(icon_x, icon_y - self.uploadPicBtnHeight/2 - sendBtnHeight/2 - 10)
        :onButtonClicked(buttontHandler(self, self.onSend_))
        :setButtonLabel("normal", ui.newTTFLabel({
            text = bm.LangUtil.getText("COMMON", "SEND"),
            size = 26,
            color = cc.c3b(0xd6, 0xff, 0xef),
            align = ui.TEXT_ALIGN_CENTER
        }))
        self.sendBtn:setTouchSwallowEnabled(false)

    --反馈列表
    local listItemTitleColor = cc.c3b(0x56, 0xae, 0xf3)
    local listItemTitleSize = 24

    --没有反馈提示
    self.noFeedbackHint = ui.newTTFLabel({
            text = bm.LangUtil.getText("HELP", "NO_FEED_BACK"),
            color = listItemTitleColor,
            size = listItemTitleSize,
            align = ui.TEXT_ALIGN_CENTER
        })
        :pos(0, -70)
        :addTo(self)
        :hide()
        
    --反馈列表
    FeedbackListItem.WIDTH = contentWidth - 120
    local feedbackListMarginTop, feedbackListMarginBottom = 4, 4
    local feedbackListHeight = 95
    self.feedbackList = bm.ui.ListView.new({
        viewRect = cc.rect(-0.5 * contentWidth, -0.5 * feedbackListHeight, contentWidth + 120, feedbackListHeight), 
        direction = bm.ui.ListView.DIRECTION_VERTICAL}, FeedbackListItem)
        :pos(-60, -feedbackListHeight/2 - feedbackListMarginTop - 25)
        :hide()
        :addTo(self)
        
    self.feedbackList:setNotHide(true)
end

function FeedbackView:onUploadPic_()
    nk.Native:pickupPic(function(success, result)
        logger:debug("nk.Native:pickupPic callback ", success, result)
        if success then
            self.picSuccess = true
            self.picFilePath = result
            --设置上传图片
            if self.uploadPic then
                cc.Director:getInstance():getTextureCache():removeTexture(self.uploadPic:getTexture())
                self.uploadPic:removeFromParent()
                self.uploadPic = nil
            end
            local setImageSize = function(width, height, sprite)
                local sX = width / sprite:getContentSize().width
                local sY = height/ sprite:getContentSize().height
                local scale = math.min(sX, sY)
                sprite:scale(scale*0.9)
            end
            self.uploadPic = display.newSprite(self.picFilePath):addTo(self.uploadPicBtn)
            setImageSize(self.uploadPicBtnWidth, self.uploadPicBtnHeight, self.uploadPic)
            self.uploadPicIcon_:setVisible(false)
        else
            if result == "nosdcard" then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "UPLOAD_PIC_NO_SDCARD"))
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "UPLOAD_PIC_PICK_IMG_FAIL"))
            end
        end
    end)
end

function FeedbackView:onSend_()
    if self.showContent:getString() ==  bm.LangUtil.getText("HELP", "FEED_BACK_HINT") then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("HELP", "MUST_INPUT_FEEDBACK_TEXT_MSG"))
        return
    end
    self.sendBtn:setButtonEnabled(false)

    self:onFeedback("1",self.showContent:getString())
end

function FeedbackView:onFeedback( type, content)
    local postParam = {
        title = "",
        ftype = type,
        fwords = content,
        fcontact = "",
    }
    FeedbackCommon.sendFeedback(postParam,function(succ,result)
        if succ then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("HELP", "FEED_BACK_SUCCESS"))
            if self.picSuccess then
                self:uploadImg(result.ret.fid, self.picFilePath)
            else
                self:sendFeedbackSucc_()
            end
        else
            if result == "network" then
                nk.TopTipManager:showTopTip(bm.LanUtil.getText("TIPS", "ERROR_SEND_FEEDBACK"))
            elseif result == 'paramerr' then
                nk.TopTipManager:showTopTip(bm.LanUtil.getText("TIPS", "ERROR_FEEDBACK_SERVER_ERROR"))
            end
        end
        self.sendBtn:setButtonEnabled(true)
    end)
    self:updateListView()
end

function FeedbackView:uploadImg(fid,picFilePath)
    FeedbackCommon.uploadPic(fid,picFilePath,function(succ, result)
            if succ then
                self:sendFeedbackSucc_()
            else
                nk.TopTipManager:showTopTip(bm.LanUtil.getText("TIPS", "FEEDBACK_UPLOAD_PIC_FAILED"))
            end
        end)
end

function FeedbackView:sendFeedbackSucc_()
    self.showContent:setString(bm.LangUtil.getText("HELP", "FEED_BACK_HINT"))
    self.uploadPicIcon_:setVisible(true)
    if self.uploadPic then
        cc.Director:getInstance():getTextureCache():removeTexture(self.uploadPic:getTexture())
        self.uploadPic:removeFromParent()
        self.uploadPic = nil
    end
end

function FeedbackView:upLoadPicNetWork()
    local userData = nk.userData
    local uploadURL = userData.UPLOAD_PIC
    nk.TopTipManager:showTopTip(bm.LangUtil.getText("HELP", "UPLOADING_PIC_MSG"))

    network.uploadFile(function(evt)
        if evt.name == "completed" then
                local request = evt.request
                local ret = request:getResponseString()
                logger:debugf("REQUEST getResponseStatusCode() = %d", request:getResponseStatusCode())
                logger:debugf("REQUEST getResponseHeadersString() =\n%s", request:getResponseHeadersString())
                 logger:debugf("REQUEST getResponseDataLength() = %d", request:getResponseDataLength())
                logger:debugf("REQUEST getResponseString() =\n%s", ret)
                local retTable = json.decode(ret)
                if retTable then
                    self:onFeedback_("1000", self.showContent:getString(), retTable.url, retTable.key)
                else
                    self.sendBtn:setButtonEnabled(true)
                end
            end
        end,
        uploadURL,
        {
            fileFieldName = "upload",
            filePath = self.picFilePath,
            contentType = "Image/jpeg",
            extra={
                {"mtkey", userData.mtkey},
                {"skey", userData.skey},
                {"uid", userData.uid},
            }
        }
    )
end

function FeedbackView:uploadContentNoPic()
    self:onFeedback_("1000", self.showContent:getString())
end

function FeedbackView:onFeedback_(type, content, url, key)
    local params = {
            mod = "feedback",
            act = "setNew",
            type = type,
            content = content,
            url = url,
            key = key,
        }
    bm.HttpService.POST(
        params,
        function (data)
            local feedbackRetData = json.decode(data)
            if feedbackRetData.ret == 0 then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("HELP", "FEED_BACK_SUCCESS"))
                self.showContent:setString(bm.LangUtil.getText("HELP", "FEED_BACK_HINT"))
                self.uploadPicIcon_:setVisible(true)
                if self.uploadPic then
                    cc.Director:getInstance():getTextureCache():removeTexture(self.uploadPic:getTexture())
                    self.uploadPic:removeFromParent()
                    self.uploadPic = nil
                end
            end
            self.sendBtn:setButtonEnabled(true)
        end,
        function ()
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("TIPS", "ERROR_SEND_FEEDBACK"))
            self.sendBtn:setButtonEnabled(true)
        end
    )

    self:updateListView()
end

function FeedbackView:updateListView()
    table.insert(self.feedbackListData, 1, {answer = "", content = self.showContent:getString()})
    self.feedbackList:setData(self.feedbackListData)
end

function FeedbackView:onContentEdit_(event, editbox)
    if event == "began" then
        local displayingText = self.showContent:getString()
        if displayingText == bm.LangUtil.getText("HELP", "FEED_BACK_HINT") then
            self.inputEditBox:setText("")
        else
            self.inputEditBox:setText(displayingText)
        end
        self.showContent:setString("")
    elseif event == "changed" then
    elseif event == "ended" then
        local text = editbox:getText()
        if text == "" then 
            text = bm.LangUtil.getText("HELP", "FEED_BACK_HINT")
        end
        self.showContent:setString(text)
        editbox:setText("")
    elseif event == "return" then
    end
end

function FeedbackView:setFeedbackList(data)
    if data then 
        self.feedbackListData = data
        self.feedbackList:show()
        self.noFeedbackHint:hide()
        self.feedbackList:setData(data)
    else 
        self.feedbackList:hide()
        self.noFeedbackHint:show()
    end
end

function FeedbackView:getFeedbackList()
    return self.feedbackList
end

function FeedbackView:onShowed()
    self.feedbackList:setScrollContentTouchRect()
end

function FeedbackView:onCleanup()
    if self.uploadPic then
        cc.Director:getInstance():getTextureCache():removeTexture(self.uploadPic:getTexture())
        self.uploadPic:removeFromParent()
        self.uploadPic = nil
    end
end

return FeedbackView
