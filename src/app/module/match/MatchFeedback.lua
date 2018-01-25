--
-- Author: Jonah0608@gmail.com
-- Date: 2015-07-10 16:38:12

local MatchFeedback = class("MatchFeedback", nk.ui.Panel)

local FeedbackRadioButton = import(".FeedbackRadioButton")
local FeedbackCommon = import("app.module.feedback.FeedbackCommon")
local MatchFeedList = import(".MatchFeedList")
local ArenaRulesPopup = import ("app.module.hall.arena.ArenaRulesPopup")
local BubbleButton = import("boomegg.ui.BubbleButton")

local logger = bm.Logger.new("MatchFeedback")
local WIDTH = 750
local HEIGHT = 480
local TOP = HEIGHT*0.5
local BOTTOM = -HEIGHT*0.5
local LEFT = -WIDTH*0.5
local RIGHT = WIDTH*0.5
local TOP_HEIGHT = 30
local PADDING = 15

local TOP_BUTTOM_WIDTH   = 78*0.8
local TOP_BUTTOM_HEIGHT  = 64*0.8

MatchFeedback.RADIO_BUTTON_IMAGES = {
    off = "match_feedback_checkbox_unselected.png",
    on = "match_feedback_checkbox_selected.png",
    bg_pressed = "#match_feedback_checkbox_bg.png",
    bg_normal = "#match_feedback_checkbox_bg.png",
}

function MatchFeedback:ctor()
    MatchFeedback.super.ctor(self, {WIDTH+30, HEIGHT+30})
    self:addBgLight()

    display.addSpriteFrames("match_feedback.plist", "match_feedback.png")

    self:setNodeEventEnabled(true)
    
    self.title_ = ui.newTTFLabel({text=bm.LangUtil.getText("MATCH", "FEEDBACK"), size=36, color=cc.c3b(0xfb, 0xd0, 0x0a), align=ui.TEXT_ALIGN_CENTER})
        :pos(0, TOP - 25)
        :addTo(self)

    self:addCloseBtn()
    local x,y = self.closeBtn_:getPosition()
    self.closeBtn_:pos(x+6,y+6)
    self:setupView()
end

function MatchFeedback:onCleanup()
    self.feedListData_ = nil

    nk.EditBoxManager:removeEditBox(self.inputEditBox)

    display.removeSpriteFramesWithFile("match_feedback.plist", "match_feedback.png")
end

function MatchFeedback:setupView()
    local feedBgWidth = WIDTH - PADDING * 2
    local feedBgHeight = HEIGHT - PADDING * 2 - TOP_HEIGHT
    local feedBgContent = display.newScale9Sprite("#panel_overlay.png",
        0, - TOP_HEIGHT / 2,
        cc.size(feedBgWidth, feedBgHeight)):addTo(self)

    self.feedContent_ = feedBgContent
    self.feedContent_:setVisible(true)

    -- 类型名称
    local yPos = feedBgHeight - PADDING
    local feedTypeImg = display.newSprite("#match_feedback_type.png")
        :align(display.LEFT_TOP, PADDING, yPos + 5)
        :addTo(feedBgContent)

    ui.newTTFLabel({text=bm.LangUtil.getText("MATCH", "FEEDBACK_TYPE"), size=25, color=cc.c3b(0xd7, 0xf6, 0xff)})
        :align(display.LEFT_TOP, PADDING  + feedTypeImg:getContentSize().width, yPos)
        :addTo(feedBgContent)

    yPos = yPos - 95
    local feedTypeContent = display.newScale9Sprite(
        "#panel_overlay.png", 
        feedBgWidth / 2,  yPos,
        cc.size(feedBgWidth - PADDING * 2, 120)):addTo(feedBgContent)
    
    -- 类型group
    self.radioBtns = {}
    local text = bm.LangUtil.getText("MATCH", "FEEDBACK_TYPE_LIST")
    for i = 1,8 do
        if i > 4 then
            self.radioBtns[i] = FeedbackRadioButton.new(MatchFeedback.RADIO_BUTTON_IMAGES,i,text[i])
                :align(display.LEFT_TOP, 90 + 170 * (i - 5), 30)
                :addTo(feedTypeContent)
        else
            self.radioBtns[i] = FeedbackRadioButton.new(MatchFeedback.RADIO_BUTTON_IMAGES,i,text[i])
                :align(display.LEFT_TOP, 90 + 170 * (i - 1), 87)
                :addTo(feedTypeContent)
        end
        self.radioBtns[i]:onButtonSelectChanged(handler(self, self.onRadioBtnChanged_))
    end

    -- 问题描述
    yPos = yPos - 85
    local feedDescImg = display.newSprite("#match_feedback_faq.png")
        :align(display.LEFT_TOP, PADDING, yPos + 5)
        :addTo(feedBgContent)

    local feedDescText = ui.newTTFLabel({text=bm.LangUtil.getText("MATCH", "FEEDBACK_DESC"), size=25, color=cc.c3b(0xd7, 0xf6, 0xff)})
        :align(display.LEFT_TOP, PADDING + feedDescImg:getContentSize().width, yPos)
        :addTo(feedBgContent)

    yPos = yPos - 125
    local feedDescContent = display.newScale9Sprite("#panel_overlay.png", 
            feedBgWidth / 2 ,  yPos,
            cc.size(feedBgWidth - PADDING * 2, 170)):addTo(feedBgContent)

    local contentWidth = WIDTH
    local contentHeight = 200
    local upContentHeight = 200

    local contentPadding = 12 

    --多行输入框
    local inputWidth  = 530
    local inputHeight = 100
    local inputContentSize = 24
    local inputContentColor = cc.c3b(0xca, 0xca, 0xca)
    self.inputEditBox = ui.newEditBox({image = "#transparent.png", 
            image = "#common_input_bg.png",
            imagePressed="#common_input_bg_down.png", 
            size = cc.size(inputWidth, inputHeight),
            x =inputWidth / 2 + contentPadding,
            y = inputHeight / 2 + 60,
            listener = handler(self, self.onContentEdit_)
        }):addTo(feedDescContent)

    self.inputEditBox:setTouchSwallowEnabled(false)
    self.inputEditBox:setFontColor(inputContentColor)
    self.inputEditBox:setPlaceholderFontColor(inputContentColor)
    self.inputEditBox:setFont(ui.DEFAULT_TTF_FONT, inputContentSize)
    self.inputEditBox:setPlaceholderFont(ui.DEFAULT_TTF_FONT, inputContentSize)
    self.inputEditBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.inputEditBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)

    nk.EditBoxManager:addEditBox(self.inputEditBox)

    display.newScale9Sprite("#common_input_bg.png", inputWidth / 2 + contentPadding, inputHeight / 2 + 60, cc.size(inputWidth, inputHeight)):addTo(feedDescContent)

    self.showContent = ui.newTTFLabel({
            text = "",
            size = inputContentSize,
            color = inputContentColor,
            align = ui.TEXT_ALIGN_LEFT,
            valign = ui.TEXT_VALIGN_TOP,
            dimensions = cc.size(inputWidth - 30, inputHeight - 30)
        })
        :addTo(feedDescContent):pos(inputWidth / 2 + contentPadding,inputHeight / 2 + 60)
        :size(inputWidth, inputHeight)
    self.showContent:setString(bm.LangUtil.getText("MATCH", "FEED_BACK_HINT"))

    --上传图片
    self.uploadPicBtnWidth = 125
    self.uploadPicBtnHeight = 105
    self.uploadPicIcon_ = display.newSprite("#help_upload_pic_icon.png"):align(display.CENTER, 8, 0)
    display.newScale9Sprite("#panel_overlay.png",inputWidth + self.uploadPicBtnWidth / 2 + 20, self.uploadPicBtnHeight  / 2 + 60, cc.size(self.uploadPicBtnWidth, self.uploadPicBtnHeight)):addTo(feedDescContent)
    
    self.uploadPicBtn = cc.ui.UIPushButton.new({normal = "#transparent.png", pressed = "#common_button_pressed_cover.png"}, {scale9 = true})
        :addTo(feedDescContent)
        :setButtonSize(self.uploadPicBtnWidth, self.uploadPicBtnHeight)
        :pos(inputWidth + self.uploadPicBtnWidth / 2 + 20,self.uploadPicBtnHeight  / 2 + 60)
        :onButtonClicked(buttontHandler(self, self.onUploadPic_))
        :add(self.uploadPicIcon_)

    self.uploadPicBtn:setTouchSwallowEnabled(false)

    --确定上传
    local sendBtnHeight = 52
    self.sendBtn = cc.ui.UIPushButton.new({normal = "#common_btn_green_normal.png", pressed = "#common_btn_green_pressed.png"}, {scale9 = true})
        :addTo(feedDescContent)
        :setButtonSize(self.uploadPicBtnWidth, sendBtnHeight)
        :pos(WIDTH / 2  - PADDING, sendBtnHeight / 2 + 5)
        :onButtonClicked(buttontHandler(self, self.onSend_))
        :setButtonLabel("normal", ui.newTTFLabel({
            text = bm.LangUtil.getText("COMMON", "SEND"),
            size = 26,
            color = cc.c3b(0xd6, 0xff, 0xef),
            align = ui.TEXT_ALIGN_CENTER
        }))

    self.sendBtn:setTouchSwallowEnabled(false)

    -- 反馈记录
    local btn = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png"}, {scale9 = true})
        :setButtonLabel("normal", ui.newTTFLabel({text = bm.LangUtil.getText("HELP","VIEW_BACK_LIST") or "", color = cc.c3b(0xff, 0xff, 0xff), size = 24, align = ui.TEXT_ALIGN_CENTER}))
        :setButtonSize(self.uploadPicBtnWidth+60, sendBtnHeight)
        :pos(WIDTH / 2  + PADDING+200, sendBtnHeight / 2 + 5)
        :addTo(feedDescContent)
        :onButtonClicked(buttontHandler(self, function(...)
            self.newMessagePoint:setVisible(false)
            MatchFeedList.new():show(self.feedListData_)
        end))

    -- 新恢复标记
    self.newMessagePoint = display.newSprite(nk.userData.motherDayRedNodePath):addTo(btn)
        :pos((self.uploadPicBtnWidth)*0.5,sendBtnHeight*0.3)
    self.newMessagePoint:setVisible(false)

    -- 比赛场规则按钮
    local px, py = 40, 28
    BubbleButton.createCommonBtn({
            iconNormalResId="#login_feedback_btn_normal.png",
            btnNormalResId="#common_btn_bg_normal.png",
            btnOverResId="#common_btn_bg_pressed.png",
            parent=feedDescContent,
            x=px,
            y=py,
            iconScale = 0.8,
            scaleVal = 0.7,
            isBtnScale9=false,
            btnScale = 0.7,
            buttonWidth=TOP_BUTTOM_WIDTH,
            buttonHeight=TOP_BUTTOM_HEIGHT,
            onClick=buttontHandler(self, self.onRulesBtnClick_),
        })
end

function MatchFeedback:onRulesBtnClick_(evt)
    ArenaRulesPopup.new():show()
end

function MatchFeedback:onRadioBtnChanged_(tag)
    if self.groupSelectId_ then
        self.radioBtns[self.groupSelectId_]:setState(false)
    end
    self.groupSelectId_ = tag
end

function MatchFeedback:onContentEdit_(event, editbox)
    if event == "began" then
        local displayingText = self.showContent:getString()
        if displayingText == bm.LangUtil.getText("MATCH", "FEED_BACK_HINT") then
            self.inputEditBox:setText("")
        else
            self.inputEditBox:setText(displayingText)
        end
        self.showContent:setString("")
    elseif event == "changed" then
    elseif event == "ended" then
        local text = editbox:getText()
        if text == "" then 
            text = bm.LangUtil.getText("MATCH", "FEED_BACK_HINT")
        end

        self.showContent:setString(text)
        editbox:setText("")
    elseif event == "return" then
    end
end

function MatchFeedback:onUploadPic_()
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


function MatchFeedback:onSend_()
    if self.showContent:getString() ==  bm.LangUtil.getText("MATCH", "FEED_BACK_HINT") then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("HELP", "MUST_INPUT_FEEDBACK_TEXT_MSG"))
        return
    end

    if self.groupSelectId_ == nil then
        -- 请选择问题类型 กรุณาเลือกประเภทปัญหาที่พบ
        nk.TopTipManager:showTopTip("กรุณาเลือกประเภทปัญหาที่พบ")
        return
    end


    self.sendBtn:setButtonEnabled(false)

    if  self.picSuccess then
        self:upLoadPicNetWork()
    else
        self:uploadContentNoPic()
    end

    -- 反馈中心
    local postParam = {
        title = bm.LangUtil.getText("HELP", "MATCH_QUESTION"),
        ftype = 404,  -- 比赛问题
        fwords = self.showContent:getString(),
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
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("TIPS", "ERROR_SEND_FEEDBACK"))
            elseif result == 'paramerr' then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("TIPS", "ERROR_FEEDBACK_SERVER_ERROR"))
            end
        end
        self.sendBtn:setButtonEnabled(true)
    end)
end

-- 清空
function MatchFeedback:sendFeedbackSucc_()
    if self.feedListData_ then
        table.insert(self.feedListData_, 1, {answer = "", content = self.showContent:getString()})
    end

    self.showContent:setString(bm.LangUtil.getText("MATCH", "FEED_BACK_HINT"))
    self.uploadPicIcon_:setVisible(true)

    if self.uploadPic then
        cc.Director:getInstance():getTextureCache():removeTexture(self.uploadPic:getTexture())
        self.uploadPic:removeFromParent()
        self.uploadPic = nil
    end

    self.picSuccess = false
end

--传图
function MatchFeedback:uploadImg(fid,picFilePath)
    FeedbackCommon.uploadPic(fid,picFilePath,function(succ, result)
        if succ then
            self:sendFeedbackSucc_()
        else
            nk.TopTipManager:showTopTip(bm.LanUtil.getText("TIPS", "FEEDBACK_UPLOAD_PIC_FAILED"))
        end
    end)
end

function MatchFeedback:upLoadPicNetWork()
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
                    self:onFeedback_(self.groupSelectId_, self.showContent:getString(), retTable.url, retTable.key)
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

function MatchFeedback:uploadContentNoPic()
    self:onFeedback_(self.groupSelectId_, self.showContent:getString())
end

function MatchFeedback:onFeedback_(type, content, url, key)
    local params = {
            mod = "Feedback",
            act = "match",
            category = type,
            msg = content,
            url = url,
            key = key,
        }

    self.inputEditBox:setVisible(false)
    bm.HttpService.POST(
        params,
        function (data)
            local feedbackRetData = json.decode(data)
            if feedbackRetData.ret == 0 then
                local data = feedbackRetData.data
                local chips = data and data.chips and data.chips or 0
                if tonumber(chips)>0 then
                    nk.userData.money = nk.userData.money + chips
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("CRASH", "GET_REWARD", chips))
                else
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("HELP", "FEED_BACK_SUCCESS"))
                end
                self.showContent:setString(bm.LangUtil.getText("MATCH", "FEED_BACK_HINT"))
                self.uploadPicIcon_:setVisible(true)
                if self.uploadPic then
                    cc.Director:getInstance():getTextureCache():removeTexture(self.uploadPic:getTexture())
                    self.uploadPic:removeFromParent()
                    self.uploadPic = nil
                end
            end
            self.sendBtn:setButtonEnabled(true)
            self.inputEditBox:setVisible(true)
        end,
        function ()
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("TIPS", "ERROR_MATCH_FEEDBACK"))
            self.sendBtn:setButtonEnabled(true)
        end
    )

    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand{
                command = "event",
                args = {eventId = "matchFeed_type"..tostring(type)}, label = "MatchFeedback"
            }
    end
end

function MatchFeedback:onShowed()
    if self.feedbackList_ then
        self.feedbackList_:update()
    end
end

function MatchFeedback:show()
    self:showPanel_(true, true, true)
    FeedbackCommon.getFeedbackList(function(succ,feedbackRetData)
        if succ then
            local haveNews = false
            self.feedListData_ = {}
            for i = 1, #feedbackRetData.data do
                table.insert(self.feedListData_,feedbackRetData.data[i])
            end

            table.sort(self.feedListData_,function(a,b) return a.mtime > b.mtime end)
            if haveNews then
                self.newMessagePoint:setVisible(true)
            end
        end
    end)
    
    return self
end

return MatchFeedback
