local GroupPassWordPopup = class("GroupPassWordPopup", nk.ui.Panel)

local logger = bm.Logger.new("GroupPassWordPopup")

function GroupPassWordPopup:ctor(roomid,tid,delegate)
	GroupPassWordPopup.super.ctor(self,{420, 270})
    self.roomid_ = roomid
    self.tid_ = tid
    self.delegate_ = delegate
    self.this_ = self
	self:setNodeEventEnabled(true)
	self:setCommonStyle(bm.LangUtil.getText("GROUP","PWDPOPTITLE"))
    self:addCloseBtn()

    -- 昵称标签
    self.nickEdit_ = ui.newEditBox({
            listener = handler(self, self.onNickEdit_), 
            size = cc.size(180, 50),
            image = "#common_input_bg.png",
            imagePressed="#common_input_bg_down.png",
        })
        :pos(-90,0)
        :addTo(self)
    self.nickEdit_:setFont(ui.DEFAULT_TTF_FONT, 26) 
    self.nickEdit_:setPlaceholderFont(ui.DEFAULT_TTF_FONT, 26)
    self.nickEdit_:setMaxLength(25)
    self.nickEdit_:setAnchorPoint(cc.p(0, 0.5))
    self.nickEdit_:setPlaceholderFontColor(cc.c3b(0xEE, 0, 0))
    self.nickEdit_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.nickEdit_:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.nickEdit_:setPlaceHolder(bm.LangUtil.getText("GROUP","PWDPOPINPUT"))

    cc.ui.UIPushButton.new({normal = "#common_btn_yellow_normal.png", pressed = "#common_btn_yellow_pressed.png"},{scale9 = true})
        :setButtonSize(140, 55)
        :setButtonLabel(ui.newTTFLabel({text = bm.LangUtil.getText("GROUP","PWDPOPCONFIRM"),size = 22,color = cc.c3b(0xff, 0xff, 0xff)}))
        :pos(0,-self.height_*0.5+50)
        :addTo(self)
        :onButtonClicked(buttontHandler(self, function(...)
            -- 回调哦
            if self.delegate_ and self.delegate_.enterGroupRoom then
                self.delegate_:enterGroupRoom(self.roomid_,self.tid_,self.editPreNick_)
            end
            self:hidePanel_()
        end))
end

function GroupPassWordPopup:onCleanup()
   
end

function GroupPassWordPopup:show()
    self:showPanel_()
end

function GroupPassWordPopup:onShowed()

end

function GroupPassWordPopup:onNickEdit_(event)
    if event == "began" then
        -- 开始输入
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
        self.nickEdit_:setText(self.editPreNick_)
    elseif event == "changed" then
        -- 输入框内容发生变化
        local text = self.nickEdit_:getText()
        local filteredText = text
        self.editNick_ = string.trim(filteredText)
        self.editPreNick_ = filteredText
    elseif event == "ended" then
        local text = self.nickEdit_:getText()
        local filteredText = text
        self.nickEdit_:setText(nk.Native:getFixedWidthText("",26,filteredText,190))
        -- 输入结束
    elseif event == "return" then
        local text = self.nickEdit_:getText()
        local filteredText = text
        self.nickEdit_:setText(nk.Native:getFixedWidthText("",26,filteredText,190))
        -- 从输入框返回
    end
end

return GroupPassWordPopup