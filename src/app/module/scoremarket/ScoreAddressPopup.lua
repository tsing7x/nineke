--
-- Author: XT
-- Date: 2015-09-25 11:54:54
--
local ScrollView = import("boomegg.ui.ScrollView")
local ComboboxView = import("boomegg.ui.ComboboxView")
local ScoreComboItem = import(".ScoreComboItem")
local DropDownList = import("app.module.room.bank.DropDownList")

local ScoreAddressPopup = class("ScoreAddressPopup", nk.ui.Panel)

local AREA_TXT="ตำบล" -- 区
local AREA_DESC = "ตำบลที่ท่านอยู่" -- 您所在的区
local COUNTRY_TXT="อำเภอ" -- 县
local COUNTRY_DESC="อำเภอที่ท่านอยู่" -- 您所在的县
local POSTALCODE_TXT = "รหัสไปรษณีย์" -- 邮政编码
local POSTALCODE_DESC = "รหัสไปรษณีย์" -- 邮政编码
local PROVINCE_TXT = "จังหวัด" -- 府
local POPUP_WIDTH, POPUP_HEIGHT = 790, 480 --弹窗宽高

local lblTxts = {
    bm.LangUtil.getText("SCOREMARKET", "USER_NAME"),
    bm.LangUtil.getText("SCOREMARKET", "USER_SEX"),
    bm.LangUtil.getText("SCOREMARKET", "DETAIL_ADDRESS"),
    AREA_TXT,
    COUNTRY_TXT,
    PROVINCE_TXT,
    bm.LangUtil.getText("SCOREMARKET", "MOBEL_TEL"),
    POSTALCODE_TXT,
    bm.LangUtil.getText("SCOREMARKET", "EMAIL"),
}

function ScoreAddressPopup:ctor(ctrl, callback)
    self:setNodeEventEnabled(true)

    self.ctrl_ = ctrl
    self.callback_ = callback
    self:initView()
    self.ctrl_:getMatchAddress1(handler(self, self.bindAddressInfo_))
end

function ScoreAddressPopup:initView()
    local width, height = POPUP_WIDTH, POPUP_HEIGHT
    ScoreAddressPopup.super.ctor(self, {width, height})

    ui.newTTFLabel({
        text = bm.LangUtil.getText("SCOREMARKET", "RECEIVE_INFOS"),
        color = styles.FONT_COLOR.LIGHT_TEXT, 
        size = 28, 
        align = ui.TEXT_ALIGN_CENTER
    }):pos(0, height*0.5 - 30):addTo(self)

    self:addCloseBtn()
    self:setCloseBtnOffset(10, 4)

    --信息栏
    local frame_w, frame_h = POPUP_WIDTH - 48, 334
    self.scrollFrame_ = display.newScale9Sprite("#sm_dialog_border.png", 0, 18, cc.size(frame_w, frame_h))
        :addTo(self)

    local scroll_dw, scroll_dh = width - 50, frame_h - 8
    self.mainContainer_ = display.newNode()
    self.scrollView_ = bm.ui.ScrollView.new {
        viewRect = cc.rect(-scroll_dw/2, -scroll_dh/2, scroll_dw, scroll_dh),
        direction = bm.ui.ScrollView.DIRECTION_VERTICAL, 
        scrollContent = self.mainContainer_,
    }
    :pos(frame_w/2, frame_h/2)
    :addTo(self.scrollFrame_)

    self:addTouchLayer_(frame_w/2, frame_h/2, scroll_dw, scroll_dh)

    -- 画线
    self.lbls_ = {}
    local px, py = -width/2 + 160, 52
    local offy = py * 2 + 80
    local maxLdw = 0

    for i = 1, #lblTxts do
        local msg = lblTxts[i].." : "
        local lbl = ui.newTTFLabel({
            text = msg,
            color = cc.c3b(0xc4,0xdd,0xf3),
            size = 22, 
            align = ui.TEXT_ALIGN_CENTER,
        })
        :pos(px, offy + 20)
        :addTo(self.mainContainer_)

        local sz = lbl:getContentSize()
        if sz.width > maxLdw then
            maxLdw = sz.width
        end

        table.insert(self.lbls_, #self.lbls_+1, {
            lbl = lbl,
            py = offy + 20,
            px = px,
            sz = sz,
        })
        offy = offy - py
    end

    maxLdw = maxLdw + 60
    for _, v in pairs(self.lbls_) do
        px = -width/2 + maxLdw - v.sz.width/2
        v.lbl:setPositionX(px)
        v.px = px + v.sz.width/2
    end

    self:addNewField_()

    -- 保存
    local buttonDw, buttonDh = 150, 52
    px, py = 0, -height*0.5 + buttonDh - 5
    self.saveIcon_ = display.newScale9Sprite("#sm_button_green_up.png", px, py, cc.size(buttonDw, buttonDh), cc.rect(9,20, 5, 5))
        :addTo(self)

    self.savelbl_ = ui.newTTFLabel({
        text = bm.LangUtil.getText("SCOREMARKET", "SAVE_ADDRESS"),
        color = styles.FONT_COLOR.LIGHT_TEXT, 
        size = 32, 
        align = ui.TEXT_ALIGN_CENTER
    }):pos(px, py):addTo(self)

    self.saveBtn_ = cc.ui.UIPushButton.new({
        normal = "#common_transparent_skin.png", 
        pressed = "#rounded_rect_6.png"}, 
        {scale9 = true})
    :setButtonSize(buttonDw, buttonDh)
    :pos(px, py)
    :onButtonClicked(buttontHandler(self, self.onSave_))
    :addTo(self)

    self.editEmail_ = ""
    self.editTel_ = ""
    self.editAddress_ = ""
    self.editNick_ = ""
    self.editArea_ = ""
    self.editCountry_ = ""
    self.editPost_ = ""

    self.scrollView_:update()
end

--统一设置编辑框触摸开关
function ScoreAddressPopup:setEditBoxTouchEnabled_(enabled)
    for _, editbox in ipairs(self.editBoxList_) do
        editbox:setTouchEnabled(enabled)
    end
end

--添加一个触摸层，级别为0，用于屏蔽输入框
function ScoreAddressPopup:addTouchLayer_(x, y, w, h)
    local node = display.newNode()
    node:setContentSize(cc.size(w, h))
    node:pos(x, y)
    node:addTo(self.scrollFrame_, 10)

    local rect = cc.rect(-w/2, -h/2, w, h)

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(function(touch, event)--(Touch* touch, Event* event)
        local pos = touch:getLocation()
        pos = node:convertToNodeSpace(pos)

        if not cc.rectContainsPoint(rect, pos) then
            self:setEditBoxTouchEnabled_(false)
            return true
        end

        return false
    end, cc.Handler.EVENT_TOUCH_BEGAN)

    listener:registerScriptHandler(function(touch, event)
        self:setEditBoxTouchEnabled_(true)
    end, cc.Handler.EVENT_TOUCH_ENDED)

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)

    --描边
    -- display.newRect(w, h, {borderColor = cc.c4f(1.0, 0.0, 0.0, 1.0), borderWidth = 1})
    --     :pos(x, y)
    --     :addTo(self.scrollFrame_)
end

function ScoreAddressPopup:addComboBox_(cpx, cpy, offy)
    -- 详细地址
    local datalist = bm.LangUtil.getText("SCOREMARKET", "CITY")
    local itemDH = 36
    local itemDW = 160
    local params = {}
    params.borderRes = "#sm_drop_bg.png"
    params.barUpRes = "#sm_combo_bar.png"
    params.barDownRes = "#sm_combo_bar_down.png"
    params.itemCls = ScoreComboItem
    params.listWidth = itemDW
    params.listHeight = itemDH * 7
    params.listOffY = -itemDH * 0.5
    params.borderSize = cc.size(itemDW,itemDH)
    params.lblSize = 20
    params.data = datalist
    local px, py = cpx+itemDW*0.5 + 0, cpy + 5 + offy
    self.combo_ = ComboboxView.new(params):addTo(self.mainContainer_, 9999):pos(px, py)
end

function ScoreAddressPopup:addNewField_()
    local fontSize = 28
    local offy = -5
    local cfgi, bdw, px, py, sz

    -- 姓名
    cfgi = self.lbls_[1]
    bdw = 320
    px, py = cfgi.px + bdw*0.5, cfgi.py + 5
    display.newScale9Sprite("#sm_dialog_border.png", px, py, cc.size(bdw, 42)):addTo(self.mainContainer_)
    self.nameEdit_ = ui.newEditBox({image = "#transparent.png", listener = handler(self, self.onNameEdit_), size = cc.size(bdw, 40)})
        :pos(px, py)
        :addTo(self.mainContainer_)

    self.nameEdit_:setFont(ui.DEFAULT_TTF_FONT, 26)
    self.nameEdit_:setPlaceholderFont(ui.DEFAULT_TTF_FONT, 26)
    self.nameEdit_:setMaxLength(128)
    self.nameEdit_:setPlaceholderFontColor(cc.c3b(0x94,0x88, 0xae))
    self.nameEdit_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.nameEdit_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.nameEdit_:setPlaceHolder(bm.LangUtil.getText("SCOREMARKET", "USER_NAME"))
    self.alertN_ = ui.newTTFLabel({
        text = "*",
        color = cc.c3b(0xFF, 0x0, 0x0), 
        size = 32, 
        align = ui.TEXT_ALIGN_CENTER
    })
    :pos(px+bdw*0.5+10, py+offy)
    :addTo(self.mainContainer_):hide()

    -- 性别
    fontSize = 26
    cfgi = self.lbls_[2]
    sz = cfgi.lbl:getContentSize()
    local resIdOn = "#sm_radio_selected.png"
    local resIdOff = "#sm_radio_unselect.png"
    self.sexgroup_ = cc.ui.UICheckBoxButtonGroup.new()
        :addButton(cc.ui.UICheckBoxButton.new({off=resIdOff, on=resIdOn}, {scale9 = false})
            :setButtonLabel(cc.ui.UILabel.new({text = bm.LangUtil.getText("SCOREMARKET", "MAN"), size = fontSize, color = cc.c3b(0xc7, 0xdb, 0xf4)}))
            :setButtonLabelAlignment(ui.TEXT_ALIGN_CENTER)
            :setButtonLabelOffset(60, 0)
            :align(display.LEFT_CENTER))
        :addButton(cc.ui.UICheckBoxButton.new({off=resIdOff, on=resIdOn}, {scale9 = false})
            :setButtonLabel(cc.ui.UILabel.new({text = bm.LangUtil.getText("SCOREMARKET", "FEMALE"), size = fontSize, color = cc.c3b(0xc7, 0xdb, 0xf4)}))
            :setButtonLabelAlignment(ui.TEXT_ALIGN_CENTER)
            :setButtonLabelOffset(60, 0)
            :align(display.LEFT_CENTER))
        :setButtonsLayoutMargin(10, 60, 10, 10)
        :onButtonSelectChanged(function(event)
            nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
            self.sexIndex_ = event.selected
        end)
        :pos(cfgi.px, cfgi.py - 25)
        :addTo(self.mainContainer_)

    local selectIdx = (nk.userData.sex == "f") and 2 or 1
    self.sexgroup_:getButtonAtIndex(selectIdx):setButtonSelected(true)

    -- 地址
    bdw = 360
    cfgi = self.lbls_[3]
    px, py = cfgi.px + bdw*0.5, cfgi.py + 5
    display.newScale9Sprite("#sm_dialog_border.png", px, py, cc.size(bdw, 42)):addTo(self.mainContainer_)
    self.addressEdit_ = ui.newEditBox({image = "#transparent.png", listener = handler(self, self.onAddressEdit_), size = cc.size(bdw, 40)})
        :pos(px, py)
        :addTo(self.mainContainer_)

    self.addressEdit_:setFont(ui.DEFAULT_TTF_FONT, 26)
    self.addressEdit_:setPlaceholderFont(ui.DEFAULT_TTF_FONT, 26)
    self.addressEdit_:setMaxLength(256)
    self.addressEdit_:setPlaceholderFontColor(cc.c3b(0x94,0x88, 0xae))
    self.addressEdit_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.addressEdit_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.addressEdit_:setPlaceHolder(bm.LangUtil.getText("SCOREMARKET", "DETAIL_ADDRESS"))
    self.alertA_ = ui.newTTFLabel({
        text = "*",
        color = cc.c3b(0xFF, 0x0, 0x0), 
        size = 32, 
        align = ui.TEXT_ALIGN_CENTER
    })
    :pos(px+bdw*0.5+10, py+offy)
    :addTo(self.mainContainer_):hide()

    -- 电话号码
    bdw = 320
    cfgi = self.lbls_[7]
    px, py = cfgi.px + bdw*0.5, cfgi.py + 5
    display.newScale9Sprite("#sm_dialog_border.png", px, py, cc.size(bdw, 42)):addTo(self.mainContainer_)
    self.telEdit_ = ui.newEditBox({image = "#transparent.png", listener = handler(self, self.onTelEdit_), size = cc.size(bdw, 40)})
        :pos(px, py)
        :addTo(self.mainContainer_)

    self.telEdit_:setFont(ui.DEFAULT_TTF_FONT, 26)
    self.telEdit_:setPlaceholderFont(ui.DEFAULT_TTF_FONT, 26)
    self.telEdit_:setMaxLength(10)
    self.telEdit_:setPlaceholderFontColor(cc.c3b(0x94,0x88, 0xae))
    self.telEdit_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.telEdit_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.telEdit_:setPlaceHolder(bm.LangUtil.getText("SCOREMARKET", "MOBEL_TEL"))

    px, py = px+bdw*0.5+10, py+offy
    self.alertT_ = ui.newTTFLabel({
            text = "*",
            color = cc.c3b(0xFF, 0x0, 0x0), 
            size = 32, 
            align = ui.TEXT_ALIGN_CENTER
        })
        :pos(px, py)
        :addTo(self.mainContainer_):hide()

    self:addAlertPopup(px + 16, cfgi.py,"เช่น 0845555555")

    --详细地址
    bdw = 360
    cfgi = self.lbls_[6]
    self:addComboBox_(cfgi.px, cfgi.py, offy+5)

    -- 电子邮件
    bdw = 320
    cfgi = self.lbls_[9]
    px, py = cfgi.px + bdw*0.5, cfgi.py + 5
    display.newScale9Sprite("#sm_dialog_border.png", px, py, cc.size(bdw, 42)):addTo(self.mainContainer_)
    self.emailEdit_ = ui.newEditBox({image = "#transparent.png", listener = handler(self, self.onEmailEdit_), size = cc.size(bdw, 40)})
        :pos(px, py)
        :addTo(self.mainContainer_)
    self.emailEdit_:setFont(ui.DEFAULT_TTF_FONT, 26)
    self.emailEdit_:setPlaceholderFont(ui.DEFAULT_TTF_FONT, 26)
    self.emailEdit_:setMaxLength(64)
    self.emailEdit_:setPlaceholderFontColor(cc.c3b(0x94,0x88, 0xae))
    self.emailEdit_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.emailEdit_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.emailEdit_:setPlaceHolder(bm.LangUtil.getText("SCOREMARKET", "EMAIL"))
    px, py = px+bdw*0.5+10, py+offy
    self.alertE_ = ui.newTTFLabel({
        text = "*",
        color = cc.c3b(0xFF, 0x0, 0x0), 
        size = 32, 
        align = ui.TEXT_ALIGN_CENTER
    })
    :pos(px, py)
    :addTo(self.mainContainer_):hide()

    self:addAlertPopup(px+16, cfgi.py,"เช่น nineke@hotmail.com")

    -- 区
    cfgi = self.lbls_[4]
    bdw = 320
    px, py = cfgi.px + bdw*0.5, cfgi.py + 5
    display.newScale9Sprite("#sm_dialog_border.png", px, py, cc.size(bdw, 42)):addTo(self.mainContainer_)
    self.areaEdit_ = ui.newEditBox({image = "#transparent.png", listener = handler(self, self.onAreaEdit_), size = cc.size(bdw, 40)})
        :pos(px, py)
        :addTo(self.mainContainer_)

    self.areaEdit_:setFont(ui.DEFAULT_TTF_FONT, 26)
    self.areaEdit_:setPlaceholderFont(ui.DEFAULT_TTF_FONT, 26)
    self.areaEdit_:setMaxLength(128)
    self.areaEdit_:setPlaceholderFontColor(cc.c3b(0x94,0x88, 0xae))
    self.areaEdit_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.areaEdit_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.areaEdit_:setPlaceHolder(AREA_DESC)
    self.alertArea_ = ui.newTTFLabel({
        text = "*",
        color = cc.c3b(0xFF, 0x0, 0x0), 
        size = 32, 
        align = ui.TEXT_ALIGN_CENTER
    })
    :pos(px+bdw*0.5+10, py+offy)
    :addTo(self.mainContainer_):hide()

    -- 县
    bdw = 320
    cfgi = self.lbls_[5]
    px, py = cfgi.px + bdw*0.5, cfgi.py + 5    
    display.newScale9Sprite("#sm_dialog_border.png", px, py, cc.size(bdw, 42)):addTo(self.mainContainer_)
    self.countryEdit_ = ui.newEditBox({image = "#transparent.png", listener = handler(self, self.onCountryEdit_), size = cc.size(bdw, 40)})
        :pos(px, py)
        :addTo(self.mainContainer_)

    self.countryEdit_:setFont(ui.DEFAULT_TTF_FONT, 26)
    self.countryEdit_:setPlaceholderFont(ui.DEFAULT_TTF_FONT, 26)
    self.countryEdit_:setMaxLength(128)
    self.countryEdit_:setPlaceholderFontColor(cc.c3b(0x94,0x88, 0xae))
    self.countryEdit_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.countryEdit_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.countryEdit_:setPlaceHolder(COUNTRY_DESC)
    self.alertCountry_ = ui.newTTFLabel({
        text = "*",
        color = cc.c3b(0xFF, 0x0, 0x0), 
        size = 32, 
        align = ui.TEXT_ALIGN_CENTER
    })
    :pos(px+bdw*0.5+10, py+offy)
    :addTo(self.mainContainer_):hide()

    -- 邮政编码
    bdw = 320
    cfgi = self.lbls_[8]
    px, py = cfgi.px + bdw*0.5, cfgi.py + 5
    display.newScale9Sprite("#sm_dialog_border.png", px, py, cc.size(bdw, 42)):addTo(self.mainContainer_)
    self.postEdit_ = ui.newEditBox({image = "#transparent.png", listener = handler(self, self.onPostEdit_), size = cc.size(bdw, 40)})
        :pos(px, py)
        :addTo(self.mainContainer_)

    self.postEdit_:setFont(ui.DEFAULT_TTF_FONT, 26)
    self.postEdit_:setPlaceholderFont(ui.DEFAULT_TTF_FONT, 26)
    self.postEdit_:setMaxLength(8)
    self.postEdit_:setPlaceholderFontColor(cc.c3b(0x94,0x88, 0xae))
    self.postEdit_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.postEdit_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.postEdit_:setPlaceHolder(POSTALCODE_DESC)
    self.alertPost_ = ui.newTTFLabel({
        text = "*",
        color = cc.c3b(0xFF, 0x0, 0x0), 
        size = 32, 
        align = ui.TEXT_ALIGN_CENTER
    })
    :pos(px+bdw*0.5+10, py+offy)
    :addTo(self.mainContainer_):hide()

    self.editBoxList_ = {
        self.nameEdit_,
        self.addressEdit_,
        self.telEdit_,
        self.emailEdit_,
        self.areaEdit_,
        self.countryEdit_,
        self.postEdit_
    }

    for _, editbox in ipairs(self.editBoxList_) do
        nk.EditBoxManager:addEditBox(editbox)
    end
end

function ScoreAddressPopup:addAlertPopup(px, py, text)
    local alertPopup_ = display.newNode():addTo(self.mainContainer_):pos(px-20, py)
    local arrowIcon_ = display.newSprite("#user-info-desc-background-arrow-icon.png"):addTo(alertPopup_, 1)
    local lbl_ = ui.newTTFLabel({
            text = text,
            color = cc.c3b(0xff, 0xff, 0xff),
            size = 20,
            align = ui.TEXT_ALIGN_CENTER
        })
        :addTo(alertPopup_, 3)
    local sz = lbl_:getContentSize()
    local nscale = 1
    if sz.width > 195 then
        nscale = 195/sz.width
        lbl_:scale(nscale)
    end
    
    local dw, dh = sz.width*nscale + 13, sz.height + 10
    local aborder_ = display.newScale9Sprite("#user_info_prop_bg.png", dw*0.5, 0, cc.size(dw, dh))
        :addTo(alertPopup_, 2)
    lbl_:setPosition(dw*0.5+3, 0)

    alertPopup_:runAction(cc.RepeatForever:create(transition.sequence({
            cc.MoveBy:create(0.6, cc.p(10, 0)),
            cc.MoveBy:create(0.6, cc.p(-10, 0)),
        })))

    return alertPopup_
end

function ScoreAddressPopup:onBackgroundTouch_(target, evt)
    if evt == bm.TouchHelper.CLICK then
        self.combo_:hideList()
    end
end

function ScoreAddressPopup:onNameEdit_(event)
    if event == "began" then
    elseif event == "changed" then
        local text = self.nameEdit_:getText()
        local filteredText = nk.keyWordFilter(text)

        if filteredText ~= text then
            self.nameEdit_:setText(filteredText)
        end

        self.editNick_ = string.trim(self.nameEdit_:getText())

        if self.editNick_ ~= "" then
            self.alertN_:hide()
        else
            self.alertN_:show()
        end
    elseif event == "ended" then
    elseif event == "return" then
    end
end

-- 区
function ScoreAddressPopup:onAreaEdit_(event)
    if event == "began" then
    elseif event == "changed" then
        local text = self.areaEdit_:getText()
        local filteredText = nk.keyWordFilter(text)
        if filteredText ~= text then
            self.areaEdit_:setText(filteredText)
        end
        self.editArea_ = string.trim(self.areaEdit_:getText())
        if self.editArea_ ~= "" then
            self.alertArea_:hide()
        else
            self.alertArea_:show()
        end
    elseif event == "ended" then
    elseif event == "return" then
    end
end

-- 县
function ScoreAddressPopup:onCountryEdit_(event)
    if event == "began" then
    elseif event == "changed" then
        local text = self.countryEdit_:getText()
        local filteredText = nk.keyWordFilter(text)
        if filteredText ~= text then
            self.countryEdit_:setText(filteredText)
        end

        self.editCountry_ = string.trim(self.countryEdit_:getText())
        if self.editCountry_ ~= "" then
            self.alertCountry_:hide()
        else
            self.alertCountry_:show()
        end
    elseif event == "ended" then
    elseif event == "return" then
    end
end

-- 邮政编码
function ScoreAddressPopup:onPostEdit_(event)
    if event == "began" then
    elseif event == "changed" then
        local text = self.postEdit_:getText()
        if string.find(text,"^[+-]?%d+$") then
            local len = string.len(string.trim(text))
            if len > 10 then
                -- 提示超出长度
                text = string.sub(text, 1, 10)
            end

            self.editPost_ = text
            self.postEdit_:setText(text)
        else
            -- 输入字符非法
            self.editPost_ = self.editPost_ or ""
            self.postEdit_:setText(self.editPost_)
        end

        if self.editPost_ ~= "" then
            self.alertPost_:hide()
        else
            self.alertPost_:show()
        end
    elseif event == "ended" then
    elseif event == "return" then
    end
end

function ScoreAddressPopup:onTelEdit_(event)
    if event == "began" then
    elseif event == "changed" then
        local text = self.telEdit_:getText()
        if string.find(text,"^[+-]?%d+$") then
            local len = string.len(string.trim(text))
            if len > 10 then
                text = string.sub(text, 1, 10)
            end

            self.editTel_ = text
            self.telEdit_:setText(text)
        else
            -- 输入字符非法
            self.editTel_ = self.editTel_ or ""
            self.telEdit_:setText(self.editTel_)
        end

        if self.editTel_ ~= "" then
            self.alertT_:hide()
        else
            self.alertT_:show()
        end
    elseif event == "ended" then
    elseif event == "return" then
    end
end

function ScoreAddressPopup:onAddressEdit_(event)
    if event == "began" then
    elseif event == "changed" then
        local text = self.addressEdit_:getText()
        local filteredText = nk.keyWordFilter(text)

        if filteredText ~= text then
            self.addressEdit_:setText(filteredText)
        end

        self.editAddress_ = string.trim(self.addressEdit_:getText())

        if self.editAddress_ ~= "" then
            self.alertA_:hide()
        else
            self.alertA_:show()
        end
    elseif event == "ended" then
    elseif event == "return" then
    end
end

function ScoreAddressPopup:onEmailEdit_(event)
    if event == "began" then
    elseif event == "changed" then
        local text = self.emailEdit_:getText()
        if self:isRightEmail(text) then
            local len = string.len(string.trim(text))

            if len > 32 then
            else
                self.editEmail_ = text
                self.emailEdit_:setText(text)
            end

            if self.editEmail_ ~= "" then
                self.alertE_:hide()
            else
                self.alertE_:show()
            end
        else
            -- 输入字符非法
            self.editEmail_ = text
        end
    elseif event == "ended" then
    elseif event == "return" then
    end
end

function ScoreAddressPopup:onCleanup()
    for _, editbox in ipairs(self.editBoxList_) do
        nk.EditBoxManager:removeEditBox(editbox)
    end
end

function ScoreAddressPopup:show(callback)
    self.callback_ = callback
    nk.PopupManager:addPopup(self)
    return self
end

function ScoreAddressPopup:onShowed()
    if self.scrollView_ then
        self.scrollView_:setScrollContentTouchRect()
        self.scrollView_:update()
    end
end

function ScoreAddressPopup:bindAddressInfo_(params)
    if params then
        self.editEmail_ = params.email
        self.editTel_ = params.phone
        self.editAddress_ = params.address
        self.editNick_ = params.name

        self.combo_:setText(params.city)    
        self.emailEdit_:setText(params.email) 
        self.nameEdit_:setText(params.name)
        self.telEdit_:setText(params.phone)
        self.addressEdit_:setText(params.address)

        self.editArea_ = params.area or ""
        self.areaEdit_:setText(self.editArea_)

        self.editCountry_ = params.country or ""
        self.countryEdit_:setText(self.editCountry_)

        self.editPost_ = params.post or ""
        self.postEdit_:setText(self.editPost_)


        params.sex = tonumber(params.sex)
        if params.sex ~= 1 and params.sex ~= 2 then
            params.sex = 1
        end

        self.sexIndex_ = params.sex
        self.sexgroup_:getButtonAtIndex(params.sex):setButtonSelected(true)
    end
end

function ScoreAddressPopup:onSave_()
    local result = nil
    local params = {}
    params.name = self.editNick_
    if params.name == nil or params.name == "" then
        self.alertN_:show()
        result = bm.LangUtil.getText("SCOREMARKET", "USER_NAME")
    end

    params.phone = self.editTel_
    if params.phone == nil or params.phone == "" then
        self.alertT_:show()
        result = bm.LangUtil.getText("SCOREMARKET", "MOBEL_TEL")
    end

    params.address = self.editAddress_
    if params.address == nil or params.address == "" then
        self.alertA_:show()
        result = bm.LangUtil.getText("SCOREMARKET", "DETAIL_ADDRESS")
    end

    params.email = self.editEmail_
    if params.email == nil or params.email == "" or not self:isRightEmail(params.email) then
        self.alertE_:show()
        result = bm.LangUtil.getText("SCOREMARKET", "EMAIL")
    end

        -- 区
    params.area = self.editArea_
    if params.area == nil or params.area == "" then
        self.alertArea_:show()
        result = AREA_TXT
    end
    -- 县
    params.country = self.editCountry_
    if params.country == nil or params.country == "" then
        self.alertCountry_:show()
        result = COUNTRY_TXT
    end
    -- 邮编
    params.post = self.editPost_
    if params.post == nil or params.post == "" then
        self.alertPost_:show()
        result = POSTALCODE_DESC
    end

    if result then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("SCOREMARKET", "ALERT_WRITEADDRESS", result))
        return
    end

    params.sex = self.sexIndex_
    params.city = self.combo_:getText()

    self.ctrl_:saveMatchAddress(params)
    self:onClose()

    if self.callback_ then
        self.callback_(params)
    end
end

function ScoreAddressPopup:onClose()
    self:close()
end

function ScoreAddressPopup:close()
    nk.PopupManager:removePopup(self)
    return self
end

function ScoreAddressPopup:isRightEmail(str)
     if string.len(str or "") < 6 then return false end
     local b,e = string.find(str or "", '@')
     local bstr = ""
     local estr = ""
     if b then
         bstr = string.sub(str, 1, b-1)
         estr = string.sub(str, e+1, -1)
     else
         return false
     end

     -- check the string before '@'
     local p1,p2 = string.find(bstr, "[%w_.]+")
     if (p1 ~= 1) or (p2 ~= string.len(bstr)) then return false end

     -- check the string after '@'
     if string.find(estr, "^[%.]+") then return false end
     if string.find(estr, "%.[%.]+") then return false end
     if string.find(estr, "@") then return false end
     if string.find(estr, "[%.]+$") then return false end

     _,count = string.gsub(estr, "%.", "")
     if (count < 1 ) or (count > 3) then
         return false
     end

     return true
 end

return ScoreAddressPopup