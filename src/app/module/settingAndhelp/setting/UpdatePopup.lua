--
-- Author: viking@boomegg.com
-- Date: 2014-09-04 10:38:07
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local Panel = import("app.pokerUI.Panel")
local UpdatePopup = class("UpdatePopup", Panel)

UpdatePopup.WIDTH = 600
UpdatePopup.HEIGHT = 400 - 20

local TOP_HEIGHT = 64 - 20
local CONTENT_WIDTH = 540
local CONTENT_HEIGHT = 200
local topTitleSize = 30
local topTitleColor = cc.c3b(0xb2, 0xdc, 0xff)
local contentSize = 25
local contentColor = cc.c3b(0x6e, 0xa1, 0xd3)
local BUTTON_WIDTH = 205
local BUTTON_HEIGHT = 55

function UpdatePopup:ctor(verTitle, verMessage, updateUrl)
    UpdatePopup.super.ctor(self, {UpdatePopup.WIDTH, UpdatePopup.HEIGHT})
    self.updateUrl_ = updateUrl

    self:setCommonStyle(bm.LangUtil.getText("UPDATE", "TITLE"))

    local container = display.newNode():addTo(self):pos(0, -20)

    local contentMarginTop = 20
    local contentOriginY = UpdatePopup.HEIGHT/2 - TOP_HEIGHT - contentMarginTop
    --内容背景
    display.newScale9Sprite("#panel_overlay.png", 0, contentOriginY - CONTENT_HEIGHT/2, cc.size(CONTENT_WIDTH, CONTENT_HEIGHT)):addTo(container)

    --logo
    local iconWidth = 100
    local iconHeight = 100
    local logoMarginLeft = 55
    local logoMarginTop = 52
    display.newSprite("#logo_icon100.png", -UpdatePopup.WIDTH/2 + iconWidth/2 + logoMarginLeft, contentOriginY - iconHeight/2 - logoMarginTop):addTo(container)

    --升级文字
    local labelPadding = 16
    local labelWidth = CONTENT_WIDTH - logoMarginLeft - iconWidth - labelPadding

    local w, h = CONTENT_WIDTH - logoMarginLeft - iconWidth, CONTENT_HEIGHT - labelPadding * 2
    local bound = cc.rect(-0.5*w, -0.5*h, w, h)
    local scrollContent = display.newNode() 
    local labelContent = display.newNode():addTo(scrollContent) 

    self.updateLabel = ui.newTTFLabel({
            text = verMessage,
            size = contentSize,
            color = contentColor,
            align = ui.TEXT_ALIGN_LEFT,
            valign = ui.TEXT_VALIGN_TOP,
            dimensions = cc.size(labelWidth, 0)
        }):addTo(labelContent)
    self.updateLabel:setAnchorPoint(cc.p(0, 0.5))
    local labelHeight = self.updateLabel:getContentSize().height
    self.updateLabel:pos(0, -labelHeight/2)

    labelContent:pos(-w/2, labelHeight/2)
    self.scrollView_ = bm.ui.ScrollView.new({viewRect = bound, scrollContent = scrollContent, direction = bm.ui.ScrollView.DIRECTION_VERTICAL})
        :addTo(container)
        :pos(iconWidth/2 + labelPadding, contentOriginY - h/2 - labelPadding)

    local btnPadding = 30
    local btnMarginBottom = 30
    local btnLabelSize = 26

    --立即升级
    local updateBtn = cc.ui.UIPushButton.new({normal = "#common_btn_green_normal.png", pressed = "#common_btn_green_pressed.png"}, {scale9 = true})
        :setButtonLabel("normal", ui.newTTFLabel({text = bm.LangUtil.getText("UPDATE", "UPDATE_NOW"), size = btnLabelSize, color = topTitleColor, align = ui.TEXT_ALIGN_CENTER}))
        :onButtonClicked(buttontHandler(self, self.onUpdateNow_))
        :addTo(self)
        :setButtonSize(BUTTON_WIDTH, BUTTON_HEIGHT)
        :pos(0, -UpdatePopup.HEIGHT/2 + btnMarginBottom + BUTTON_HEIGHT/2)
end

function UpdatePopup:show()
    self:showPanel_()
end

function UpdatePopup:hide()
    self:hidePanel_()
end

function UpdatePopup:onShowed()
    self.scrollView_:setScrollContentTouchRect()
end

function UpdatePopup:onUpdateNow_()
    print("update onupdate:"..self.updateUrl_)
    device.openURL(self.updateUrl_)
end

return UpdatePopup