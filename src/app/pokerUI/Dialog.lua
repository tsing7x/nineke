--
-- Author: johnny@boomegg.com
-- Date: 2014-08-14 14:42:32
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local Panel = import(".Panel")
local Dialog = class("Dialog", Panel)

local DEFAULT_WIDTH = 640
local DEFAULT_HEIGHT = 360
local TOP_HEIGHT = 76
local PADDING = 26
local BTN_HEIGHT = 55

Dialog.FIRST_BTN_CLICK  = 1
Dialog.SECOND_BTN_CLICK = 2
Dialog.CLOSE_BTN_CLICK  = 3

function Dialog:ctor(args)
    if type(args) == "string" then
        self.messageText_ = args
        self.firstBtnText_ = bm.LangUtil.getText("COMMON", "CANCEL")
        self.secondBtnText_ = bm.LangUtil.getText("COMMON", "CONFIRM")
        self.titleText_ = bm.LangUtil.getText("COMMON", "NOTICE")
    elseif type(args) == "table" then
        self.messageText_ = args.messageText
        self.specialWidth_ = args.specialWidth
        self.callback_ = args.callback
        self.firstBtnText_ = args.firstBtnText or bm.LangUtil.getText("COMMON", "CANCEL")
        self.secondBtnText_ = args.secondBtnText or bm.LangUtil.getText("COMMON", "CONFIRM")
        self.titleText_ = args.titleText or bm.LangUtil.getText("COMMON", "NOTICE")
        self.noCloseBtn_ = (args.hasCloseButton == false)
        self.noFristBtn_ = (args.hasFirstButton == false)
        self.notCloseWhenTouchModel_ = not args.closeWhenTouchModel
    end

    -- 设置dialog的尺寸
    local dialogWidth = self.specialWidth_ or DEFAULT_WIDTH
    -- 初始化文本
    local messageLabel = ui.newTTFLabel({
            text = self.messageText_,
            color = styles.FONT_COLOR.LIGHT_TEXT,
            size = 26,
            align = ui.TEXT_ALIGN_CENTER,
            dimensions = cc.size(dialogWidth - 64, 0)
        })
        :pos(0, (PADDING + BTN_HEIGHT - TOP_HEIGHT) * 0.5)

    local dialogHeight =  messageLabel:getContentSize().height + PADDING * 3 + BTN_HEIGHT + TOP_HEIGHT
    if dialogHeight < DEFAULT_HEIGHT then dialogHeight = DEFAULT_HEIGHT end
    Dialog.super.ctor(self, {dialogWidth, dialogHeight})

    self:setCommonStyle(self.titleText_)
    if self.noCloseBtn_ then
        self.closeBtn_:hide()
    end
    
    -- 添加标签
    messageLabel:addTo(self)

    display.newScale9Sprite("#pop_common_bottom_bg.png", 0, 0, cc.size(dialogWidth - 16, 82), cc.rect(20,0,1,1)):pos(0, -dialogHeight * 0.5 + 56):addTo(self)

    -- 初始化按钮
    local showFirstBtn = false
    local buttonWidth = 0
    if not self.noFristBtn_ then
        if self.firstBtnText_ then
            showFirstBtn = true
        end
    end
    self.secondBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_green_normal.png", pressed = "#common_btn_green_pressed.png"}, {scale9 = true})
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.onButtonClick_))
        :setButtonLabel("normal", ui.newTTFLabel({text = self.secondBtnText_, color = styles.FONT_COLOR.LIGHT_TEXT, size = 30, align = ui.TEXT_ALIGN_CENTER}))
        :setButtonLabel("pressed", ui.newTTFLabel({text = self.secondBtnText_, color = styles.FONT_COLOR.GREY_TEXT, size = 30, align = ui.TEXT_ALIGN_CENTER}))
    
    if showFirstBtn then
        self.firstBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_blue_normal.png", pressed = "#common_btn_blue_pressed.png"}, {scale9 = true})
            :addTo(self)
            :onButtonClicked(buttontHandler(self, self.onButtonClick_))
            :setButtonLabel("normal", ui.newTTFLabel({text = self.firstBtnText_, color = styles.FONT_COLOR.LIGHT_TEXT, size = 30, align = ui.TEXT_ALIGN_CENTER}))
            :setButtonLabel("pressed", ui.newTTFLabel({text = self.firstBtnText_, color = styles.FONT_COLOR.GREY_TEXT, size = 30, align = ui.TEXT_ALIGN_CENTER}))
        buttonWidth = (dialogWidth - 8 * PADDING) * 0.5
        self.firstBtn_:setButtonSize(buttonWidth, BTN_HEIGHT):pos(-(PADDING *2 + buttonWidth) * 0.5, -dialogHeight * 0.5 + PADDING + BTN_HEIGHT * 0.5)
        self.secondBtn_:setButtonSize(buttonWidth, BTN_HEIGHT):pos((PADDING *2 + buttonWidth) * 0.5, -dialogHeight * 0.5 + PADDING + BTN_HEIGHT * 0.5)
    else
        buttonWidth = 240
        self.secondBtn_:setButtonSize(buttonWidth, BTN_HEIGHT):pos(0, -dialogHeight * 0.5 + PADDING + BTN_HEIGHT * 0.5)
    end
end

-- 按钮点击事件处理
function Dialog:onButtonClick_(event)
    if self.callback_ then
        if event.target == self.firstBtn_ then
            self.callback_(Dialog.FIRST_BTN_CLICK)
        elseif event.target == self.secondBtn_ then
            self.callback_(Dialog.SECOND_BTN_CLICK)
        end

        self.callback_ = nil
    end
    
    if self.hidePanel_ then
        self:hidePanel_()
    end
end

function Dialog:show()
    if self.notCloseWhenTouchModel_ then
        self:showPanel_(true, true, false, true)
    else
        self:showPanel_()
    end
    return self
end

function Dialog:onRemovePopup(removeFunc)
    if self.callback_ then
        self.callback_(Dialog.CLOSE_BTN_CLICK)
    end
    removeFunc()
end

-- override onClose()
function Dialog:onClose()
    if self.callback_ then
        self.callback_(Dialog.CLOSE_BTN_CLICK)
    end
    
    self.callback_ = nil
    self:hidePanel_()
end

return Dialog