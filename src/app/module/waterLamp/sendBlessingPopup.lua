local SendBlessingPopup = class("SendBlessingPopup", function()
    return display.newNode()
end)

----[[
local POP_WIDTH = 589
local POP_HEIGHT = 368
local PANEL_CLOSE_BTN_Z_ORDER = 99

function SendBlessingPopup:ctor(...)
    self:setNodeEventEnabled(true)

    local bgScaleX, bgScaleY = 1, 1
    if display.width > 960 and display.height == 640 then
        bgScaleX = display.width / 960
    elseif display.width == 960 and display.height > 640 then
        bgScaleY = display.height / 640
    end
    self:setScaleX(bgScaleX)
    self:setScaleY(bgScaleY)
          
    --中奖数据
    local params = {...}

    local backFrame = display.newSprite("waterLamp/sendBlessingBg.png"):addTo(self)
    backFrame:setTouchEnabled(true)
    backFrame:setTouchSwallowEnabled(true)

    self:addEditBox()
    self:addOkBtn()
    self:updatePresentView(params[1])
    self:addCloseBtn()
end

function SendBlessingPopup:addEditBox() 

    self.editboxId_ = ui.newEditBox({
        size = cc.size(60, 24),
        image = "#waterLampTransparentSkin.png",--#waterLampTransparentSkin.png
        align = ui.TEXT_ALIGN_CENTER,
        listener = callback
    })
    :align(display.LEFT_CENTER, 30, 0)
    :pos(-180, 93)
    :addTo(self)

    self.editboxId_:setFontName(ui.DEFAULT_TTF_FONT)
    self.editboxId_:setFontSize(13)
    self.editboxId_:setFontColor(cc.c3b(0x00, 0x00, 0x00))
    self.editboxId_:setPlaceholderFontColor(cc.c3b(0xb1, 0xa9, 0x96))
    self.editboxId_:setPlaceHolder(bm.LangUtil.getText("WATERLAMP", "DEFAULT_ID_TIP"))
    self.editboxId_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.editboxId_:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)

    self.editboxContent_ = ui.newEditBox({
        size = cc.size(280, 24),
        image = "#waterLampTransparentSkin.png",--pngtempFrame
        align = ui.TEXT_ALIGN_CENTER,
        listener = callback
    })
    :align(display.LEFT_CENTER, 30, 0)
    :pos(-70, 93)
    :addTo(self)

    self.editboxContent_:setFontName(ui.DEFAULT_TTF_FONT)
    self.editboxContent_:setFontSize(13)
    self.editboxContent_:setFontColor(cc.c3b(0x00, 0x00, 0x00))
    self.editboxContent_:setPlaceholderFontColor(cc.c3b(0xb1, 0xa9, 0x96))
    self.editboxContent_:setPlaceHolder(bm.LangUtil.getText("WATERLAMP", "DEFAULT_BLESSING_TIP"))
    self.editboxContent_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.editboxContent_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)

    cc.ui.UIPushButton.new({normal= "#waterLampTransparentSkin.png",pressed="#waterLampTransparentSkin.png"},{scale9 = true})
        :setButtonSize(33, 23)
        :pos(-110, 90)
        :onButtonClicked(function()   
            local FriendSelPopup = import("app.module.waterLamp.friendSelPopup")
            FriendSelPopup.new(self):show()
        end)
        :addTo(self)

    cc.ui.UIPushButton.new({normal= "#waterLampTransparentSkin.png",pressed="#waterLampTransparentSkin.png"},{scale9 = true})
        :setButtonSize(33, 23)
        :pos(228, 90)
        :onButtonClicked(function()
            local BlessingSelPopup = import("app.module.waterLamp.blessingSelPopup")
            BlessingSelPopup.new(self):show()
        end)
        :addTo(self)
end

function SendBlessingPopup:modToId(id)
    self.editboxId_:setText(id)
end

function SendBlessingPopup:modBlessingText(txt)
    self.editboxContent_:setText(txt)
end

function SendBlessingPopup:updatePresentView(lottoData)
    local present = {[4] = "#waterLampPresentA.png", [1] = "#waterLampPresentB.png", [2] = "#waterLampPresentC.png", [3] = "#waterLampPresentD.png"}

    display.newSprite(present[lottoData.reward[2]]):pos(-10, -50):addTo(self)
    display.newSprite("#waterLampPropAB.png"):pos(178, -40):addTo(self)

    ui.newTTFLabel({
        text = lottoData.reward[1], 
        color = cc.c3b(0x64, 0x10, 0x10), 
        size = 20, 
        dimensions=cc.size(100, 0),
        align = ui.TEXT_ALIGN_RIGHT,
    })
    :pos(-236, -102)
    :addTo(self)

    ui.newTTFLabel({
        text = lottoData.reward[3], 
        color = cc.c3b(0x64, 0x10, 0x10), 
        size = 20, 
        dimensions=cc.size(100, 0),
        align = ui.TEXT_ALIGN_RIGHT,
    })
    :pos(-51, -102)
    :addTo(self)

    ui.newTTFLabel({
        text = lottoData.reward[5], 
        color = cc.c3b(0x64, 0x10, 0x10), 
        size = 20, 
        dimensions=cc.size(100, 0),
        align = ui.TEXT_ALIGN_RIGHT,
    })
    :pos(114, -102)
    :addTo(self)
end

function SendBlessingPopup:addCloseBtn()
    local px = POP_WIDTH/2 - 30
    local py = POP_HEIGHT/2 - 19
    if not self.closeBtn_ then
        self.closeBtn_ = cc.ui.UIPushButton.new({normal = "#waterLampCloseBtn.png", pressed="#waterLampCloseBtn.png"})
            :pos(px, py)
            :scale(0.75)
            :onButtonClicked(function()
                self:hide()
                nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
            end)
            :addTo(self, PANEL_CLOSE_BTN_Z_ORDER)            
    end
end

function SendBlessingPopup:addOkBtn()
    local px = 0
    local py = POP_HEIGHT/2 - 330

    self.okBtn_ = cc.ui.UIPushButton.new({normal = "#sendBlessingOkBtn.png", pressed="#sendBlessingOkBtn.png"})
        :pos(px, py)
        :onButtonClicked(function()

            if self.editboxId_:getText() == "" then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("WATERLAMP", "INPUT_ID_TIP"))
            elseif self.editboxContent_:getText() == "" then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("WATERLAMP", "INPUT_BLESSING_TIP"))
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("WATERLAMP", "BLESSING_SUCCESS"))
                bm.HttpService.POST(
                {
                    mod = "Lkf",
                    act = "send",
                    uid = tonumber(nk.userData.uid),
                    toUid = tonumber(self.editboxId_:getText()),
                    message = self.editboxContent_:getText(),
                 },
                function (data)
                end,
                function (data)
                end)
                self:hide()
            end

        end)
        :addTo(self, PANEL_CLOSE_BTN_Z_ORDER)     
end

function SendBlessingPopup:show()
    nk.PopupManager:addPopup(self, true ~= false, true ~= false, true ~= false, nil ~= false)
    return self
end

function SendBlessingPopup:hide()
    nk.PopupManager:removePopup(self)
    return self
end

--]]

return SendBlessingPopup
