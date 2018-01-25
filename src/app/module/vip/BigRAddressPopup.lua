--
-- Author: HLF(IdaHuang@boyaa.com)
-- Date: 2016-03-07 16:00:35
--
local ComboboxView = import("boomegg.ui.ComboboxView")
local ScoreComboItem = import("app.module.scoremarket.ScoreComboItem")
local ScoreMarketController = import("app.module.scoremarket.ScoreMarketController")
local BigRAddressPopup = class("BigRAddressPopup", nk.ui.Panel)

local WIDTH = 670
local HEIGHT = 392

local TITLE_TXT = "ข้อมูลผู้เล่นอันทรงเกียรติ" -- "尊贵玩家信息有奖收集"
local ALERT_TXT = "ประกาศ：ข้อมูลทั้งหมดใช้เพื่ออำนวยความสะดวกในการมอบรางวัล จะถูกปิดเป็นความลับ ปลอดภัยค่ะ" --官方申明那行改为这个
-- local ALERT_TXT = "ประกาศ：ข้อมูลที่กรอกทั้งหมดใช้เพื่ออำนวยความสะดวกในการมอบรางวัลให้แก่ท่านผู้เล่นทั้งหลาย จะถูกปิดเป็นความลับไม่เปิดเผยต่อสาธารณชนค่ะ" -- "官方声明:本次信息将仅会用作后续的尊贵玩家专人服务及福利发放用途，请放心填写！"
local NAME_TXT = "ชื่อ-สกุล" -- 您的姓名
local NAME_DESC = "กรุณากรอกชื่อ-สกุลจริง" -- 您的姓名
local MOBILE_TXT = "เบอร์โทร" -- 您的手机号
local MOBILE_DESC = "จำเป็นต้องกรอก"
local LINE_TXT = "บัญชี line" -- 您的LINE帐号
local LINE_DESC = "บัญชี line" -- 您的LINE帐号
local ADDRESS_TXT = "ที่อยู่"  -- 您的地址
local ADDRESS_DESC = "ที่อยู่"  -- 您的地址
local TIPS_TXT = "กรอกข้อมูลที่มีหมายเลข * จะได้รับรางวัล 100K ชิป"
local CHIP_TXT = "+100K ชิป"
local SAVE_SUCCESS = "ยินดีที่ได้รับรางวัล 100K ชิป ขอบคุณที่ให้การสนับสนุนเกมส์เก้าเกไทยค่ะ"  --感谢您对游戏的支持 恭喜您得到xxx游戏币
local ALERT_SAVE_MSG = "กรุณากรอกข้อมูลที่มีหมายเลข * ให้ครบก่อนนะคะ"

function BigRAddressPopup:ctor()
	BigRAddressPopup.super.ctor(self, {WIDTH, HEIGHT})
    local sz
	local titleHeight = 56
	local px, py = 0, -titleHeight/2 + 8
    self.contain_ = display.newNode()
        :pos(0,24)
        :addTo(self)
    self.bg_ = display.newSprite("bigR_bgr.png")
        :pos(px, py)
        :addTo(self.contain_)
    self.bg_:setScale(1.0)
    -- 回退按钮 common_transparent_skin
    self.close_x_ = WIDTH*0.5 - 32
    self.close_y_ = HEIGHT*0.5 - 30
    self:addCloseBtn()
    -- 
    px, py = 0, (HEIGHT - titleHeight)/2 - 18
    self.titleTxt_ = ui.newTTFLabel({
    		text=TITLE_TXT,
    		size=36,
    		color=cc.c3b(0xe1, 0xbe, 0xe3),
    		align=ui.TEXT_ALIGN_CENTER
    	})
    	:pos(px, py)
    	:addTo(self.contain_)
    -- 
    local dw = 580
    py = py - titleHeight*1.0 + 15    
    px = -20
    self.alertTxt_ = ui.newTTFLabel({
    		text=ALERT_TXT,
    		size=20,
    		color=cc.c3b(0xf5, 0xff, 0x59),
    		align=ui.TEXT_ALIGN_CENTER,
    	})
    	:pos(px, py)
    	:addTo(self.contain_)
    bm.fitSprteWidth(self.alertTxt_, dw)

    self.tipsTxt_ = ui.newTTFLabel({
            text=TIPS_TXT,
            size=14,
            color=styles.FONT_COLOR.LIGHT_TEXT,
            aling=ui.TEXT_ALIGN_CENTER
        })
        :pos(40, -HEIGHT*0.5 + 0)
        :addTo(self.contain_)
    -- 
    self.lbls_ = {}
    local lbls = {
        NAME_TXT,
        MOBILE_TXT,
        LINE_TXT,
        ADDRESS_TXT,
    }
    py = py - 50
    local offVal = 45
    local dh = 50
    local bdw = 0
    local ldw = 300
    local fontSize = 20
    local maxLdw = 0
    local offy = -8
    local cfgi
    px = -WIDTH*0.5 + ldw*0.5 + 15 - 50
    for i=1,#lbls do
        --         
        local msg = lbls[i].." : "
        local lbl = ui.newTTFLabel({
            text = msg,
            color = cc.c3b(0xf5,0xff,0x59),
            size = fontSize, 
            align = ui.TEXT_ALIGN_CENTER,
        })
        :pos(px, py)
        :addTo(self.contain_)

        local alert = ui.newTTFLabel({
            text = "*",
            color = cc.c3b(0xff,0x0,0x0),
            size = fontSize, 
            align = ui.TEXT_ALIGN_CENTER,
        })
        :pos(px, py+offy)
        :addTo(self.contain_)

        sz = lbl:getContentSize()
        if sz.width > maxLdw then
            maxLdw = sz.width
        end
        -- 
        table.insert(self.lbls_, #self.lbls_+1, {
                lbl = lbl,
                alert = alert,
                py = py,
                px = px,
                sz = sz,
            })
        py = py - offVal
    end
    -- -- 
    maxLdw = maxLdw + 30
    for k,v in pairs(self.lbls_) do
        px = -WIDTH*0.5 + maxLdw - v.sz.width*0.5 + 135 - 50
        v.lbl:setPositionX(px)
        v.alert:setPositionX(px - v.sz.width*0.5 - 6)
        v.alert:hide()
        v.px = px + v.sz.width*0.5
    end
    ------ 姓名
    local fontColor = cc.c3b(0x41, 0x04, 0x8a)
    local placeFontColor = cc.c3b(0x94,0x88, 0xae)
    local inputBgResId = "#invite_friend_inputback.png"
    local inputBgSizeDH = 32
    fontSize = 20
    cfgi = self.lbls_[1]
    bdw = 360
    px, py = cfgi.px + bdw*0.5, cfgi.py + 5
    display.newScale9Sprite(inputBgResId, px, py+offy, cc.size(bdw, inputBgSizeDH)):addTo(self.contain_)
    self.nameEdit_ = ui.newEditBox({image = "#transparent.png", listener = handler(self, self.onNameEdit_), size = cc.size(bdw, inputBgSizeDH-2)})
        :pos(px, py+offy)
        :addTo(self.contain_)
    self.nameEdit_:setColor(fontColor)
    self.nameEdit_:setFont(ui.DEFAULT_TTF_FONT, fontSize)
    self.nameEdit_:setPlaceholderFont(ui.DEFAULT_TTF_FONT, fontSize)
    self.nameEdit_:setMaxLength(128)
    self.nameEdit_:setPlaceholderFontColor(placeFontColor)
    self.nameEdit_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.nameEdit_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.nameEdit_:setPlaceHolder(NAME_DESC)
    -- 您的手机号
    cfgi = self.lbls_[2]
    bdw = 360
    px, py = cfgi.px + bdw*0.5, cfgi.py + 5
    display.newScale9Sprite(inputBgResId, px, py+offy, cc.size(bdw, inputBgSizeDH)):addTo(self.contain_)
    self.mobileEdit_ = ui.newEditBox({image = "#transparent.png", listener = handler(self, self.onMobileEdit_), size = cc.size(bdw, inputBgSizeDH-2)})
        :pos(px, py+offy)
        :addTo(self.contain_)
    self.mobileEdit_:setColor(fontColor)
    self.mobileEdit_:setFont(ui.DEFAULT_TTF_FONT, fontSize)
    self.mobileEdit_:setPlaceholderFont(ui.DEFAULT_TTF_FONT, fontSize)
    self.mobileEdit_:setMaxLength(10)
    self.mobileEdit_:setPlaceholderFontColor(placeFontColor)
    self.mobileEdit_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.mobileEdit_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.mobileEdit_:setPlaceHolder(MOBILE_DESC)
    -- 您的LINE帐号
    cfgi = self.lbls_[3]
    bdw = 360
    px, py = cfgi.px + bdw*0.5, cfgi.py + 5
    display.newScale9Sprite(inputBgResId, px, py+offy, cc.size(bdw, inputBgSizeDH)):addTo(self.contain_)
    self.lineEdit_ = ui.newEditBox({image = "#transparent.png", listener = handler(self, self.onLineEdit_), size = cc.size(bdw, inputBgSizeDH-2)})
        :pos(px, py+offy)
        :addTo(self.contain_)
    self.lineEdit_:setColor(fontColor)
    self.lineEdit_:setFont(ui.DEFAULT_TTF_FONT, fontSize)
    self.lineEdit_:setPlaceholderFont(ui.DEFAULT_TTF_FONT, fontSize)
    self.lineEdit_:setMaxLength(64)
    self.lineEdit_:setPlaceholderFontColor(placeFontColor)
    self.lineEdit_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.lineEdit_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.lineEdit_:setPlaceHolder(LINE_DESC)
    -- 您的地址
    cfgi = self.lbls_[4]
    bdw = 360
    px, py = cfgi.px + bdw*0.5, cfgi.py + 5
    display.newScale9Sprite(inputBgResId, px, py+offy, cc.size(bdw, inputBgSizeDH)):addTo(self.contain_)
    self.addressEdit_ = ui.newEditBox({image = "#transparent.png", listener = handler(self, self.onAddressEdit_), size = cc.size(bdw, inputBgSizeDH-2)})
        :pos(px, py+offy)
        :addTo(self.contain_)
    self.addressEdit_:setColor(fontColor)
    self.addressEdit_:setFont(ui.DEFAULT_TTF_FONT, fontSize)
    self.addressEdit_:setPlaceholderFont(ui.DEFAULT_TTF_FONT, fontSize)
    self.addressEdit_:setMaxLength(256)
    self.addressEdit_:setPlaceholderFontColor(placeFontColor)
    self.addressEdit_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.addressEdit_:setPlaceHolder(ADDRESS_DESC)
    -- 
    bdw = 360
    cfgi = self.lbls_[4]
    local datalist = bm.LangUtil.getText("SCOREMARKET", "CITY")
    local itemDH = 42
    local itemDW = 242
    local params = {}
    params.barRes = "#dropdown_list_button.png"
    params.borderRes = inputBgResId-- "inputBgResId.png" -- "#user-info-desc-modify-nick-line.png"
    params.itemCls = ScoreComboItem
    params.listWidth = itemDW-20
    params.listOffX = -20
    params.listHeight = itemDH*4+0
    params.listOffY = -itemDH*0.5
    params.borderSize = cc.size(itemDW,itemDH)
    params.lblSize = 18
    px, py = cfgi.px+itemDW*0.5 + 0, cfgi.py+offy-40 
    self.combo_ = ComboboxView.new(params):addTo(self, 100):pos(px, py)
    self.combo_:setData(datalist, datalist[1])
    self.combo_:hide()
    -- 保存
    local BUTTON_DW, BUTTON_DH = 170, 48
    px, py = 30, -HEIGHT*0.5 + 50
    self.saveBtn_ = cc.ui.UIPushButton.new({normal= "#common_toptips_button.png",pressed="#common_toptips_button_pressed.png"},{scale9 = true})
        :setButtonSize(BUTTON_DW, BUTTON_DH)
        :setButtonLabel(ui.newTTFLabel({text=CHIP_TXT, size=28, color=styles.FONT_COLOR.LIGHT_TEXT, align=ui.TEXT_ALIGN_CENTER}))
        :setButtonLabelOffset(0, 3)
        :onButtonClicked(buttontHandler(self, self.onsaveButtonHandler_))
        :pos(px, py)
        :addTo(self.contain_)
    self.texRpt_ = display.newTilesSprite("repeat/panel_repeat_tex.png", cc.rect(0, 0, BUTTON_DW, BUTTON_DH))
        :pos(px-BUTTON_DW*0.5, py-BUTTON_DH*0.5)
        :addTo(self.contain_)
    self.texRpt_:setNodeEventEnabled(false)

    self:setNodeEventEnabled(true)

    self.editName_ = ""
    self.editMobile_ = ""
    self.editLine_ = ""
    self.editAddress_ = ""
    self.lbls_[1].alert:show()
    self.lbls_[2].alert:show()

    self.ctrl_ = ScoreMarketController.new(self)
    self.ctrl_:getMatchAddress1(handler(self, self.bindAddressInfo_))
end

function BigRAddressPopup:bindAddressInfo_(params)
    if params then
        self.editMobile_ = params.phone or ""
        self.editName_ = params.name or ""
        self.editAddress_ = (params.city or "")..(params.country or "")..(params.area or "")..(params.address or "")

        self.nameEdit_:setText(self.editName_)
        self.mobileEdit_:setText(self.editMobile_)
        self.addressEdit_:setText(self.editAddress_)
    end
end

function BigRAddressPopup:show()
    self:showPanel_()
    
end

function BigRAddressPopup:onCleanup()

end

function BigRAddressPopup:onShowed()
    self.isShowed_ = true
end

function BigRAddressPopup:onNameEdit_(event)
    if event == "began" then
    elseif event == "changed" then
        local text = self.nameEdit_:getText()
        local filteredText = nk.keyWordFilter(text)
        if filteredText ~= text then
            self.nameEdit_:setText(filteredText)
        end
        self.editName_ = string.trim(self.nameEdit_:getText())
        if self.editName_ ~= "" then
            self.lbls_[1].alert:show()
        else
            self.lbls_[1].alert:show()
        end
    elseif event == "ended" then
    elseif event == "return" then
    end
end

-- 您的手机号
function BigRAddressPopup:onMobileEdit_(event)
    if event == "began" then
    elseif event == "changed" then
        local text = self.mobileEdit_:getText()
        if string.find(text,"^[+-]?%d+$") then
            local len = string.len(string.trim(text))
            if len > 10 then
                -- 提示超出长度
                text = string.sub(text, 1, 10)
            end
            self.editMobile_ = text
            self.mobileEdit_:setText(text)
        else
            -- 输入字符非法
            self.editMobile_ = self.editMobile_ or ""
            self.mobileEdit_:setText(self.editMobile_)
        end

        if self.editMobile_ ~= "" then
            self.lbls_[2].alert:show()
        else
            self.lbls_[2].alert:show()
        end
    elseif event == "ended" then
    elseif event == "return" then
    end
end

-- 您的LINE帐号
function BigRAddressPopup:onLineEdit_(event)
    if event == "began" then
    elseif event == "changed" then
        local text = self.lineEdit_:getText()
        local filteredText = nk.keyWordFilter(text)
        if filteredText ~= text then
            self.lineEdit_:setText(filteredText)
        end
        self.editLine_ = string.trim(self.lineEdit_:getText())
        if self.editLine_ ~= "" then
            self.lbls_[3].alert:hide()
        else
            self.lbls_[3].alert:hide()
        end
    elseif event == "ended" then
    elseif event == "return" then
    end
end

-- 您的地址
function BigRAddressPopup:onAddressEdit_(event)
    if event == "began" then
    elseif event == "changed" then
        local text = self.addressEdit_:getText()
        local filteredText = nk.keyWordFilter(text)
        if filteredText ~= text then
            self.addressEdit_:setText(filteredText)
        end
        self.editAddress_ = string.trim(self.addressEdit_:getText())
        if self.editAddress_ ~= "" then
            self.lbls_[4].alert:hide()
        else
            self.lbls_[4].alert:hide()
        end
    elseif event == "ended" then
    elseif event == "return" then
    end
end

-- 保存记录
function BigRAddressPopup:onsaveButtonHandler_(evt)
    local result = nil
    local params = {}
    -- 您的手机号
    params.name = self.editName_
    if params.name == nil or params.name == "" then
        self.lbls_[1].alert:show()
        result = ALERT_SAVE_MSG
    end
    -- 您的手机号
    params.phone = self.editMobile_
    if params.phone == nil or params.phone == "" then
        self.lbls_[2].alert:show()
        result = ALERT_SAVE_MSG
    end
    -- 您的LINE帐号
    params.line = self.editLine_ or ""

    -- 您的地址
    params.address = self.editAddress_ or ""

    params.province = self.combo_:getText()

    if result then
        nk.TopTipManager:showTopTip(result)
        return
    end

    self:saveBigVInfo(params)
end

function BigRAddressPopup:saveBigVInfo(params)
    if self.getBigRAddressId_ then
        return
    end

    self.getBigRAddressId_ = bm.HttpService.POST( {
            mod = "Mobile", 
            act = "bigrAddress",
            name = params.name or "",
            phone = params.phone or "",
            line = params.line or "",
            address = params.address or "",
            province = params.province or "",
        },
        function(data)
            local retData = json.decode(data)
            if retData then
                self.getBigRAddressId_ = nil
                if retData.ret == 0 then
                    self:onClose()
                    nk.userData.isOpenBigR = 0
                    nk.TopTipManager:showTopTip(SAVE_SUCCESS)

                    if device.platform == "android" or device.platform == "ios" then
                        cc.analytics:doCommand {
                            command = "event",
                            args = {eventId = "BigR_UserAddress_Detail", label = "UID::"..tostring(nk.userData.uid)},
                        }
                    end
                elseif retData.ret == -1 then
                    self:onClose()
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("SCOREMARKET", "SAVEADDRESS_FAIL"))
                elseif retData.ret == -2 then
                    self.lbls_[2].alert:show()
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("SCOREMARKET", "ALERT_WRITEADDRESS", MOBILE_DESC))
                elseif retData.ret == -3 then
                    self:onClose()
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("SCOREMARKET", "SAVEADDRESS_FAIL"))
                end
            end           
        end,
        function()
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("SCOREMARKET", "SAVEADDRESS_FAIL"))
            self.getBigRAddressId_ = nil
        end
    )
end

return BigRAddressPopup