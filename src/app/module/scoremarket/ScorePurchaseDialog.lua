--
-- Author: HLF
-- Date: 2015-09-26 17:08:30
--
local ScorePurchaseDialog = class("ScorePurchaseDialog", nk.ui.Panel)

ScorePurchaseDialog.WIDTH = 540
ScorePurchaseDialog.HEIGHT = 280
local TOP_HEIGHT = 68
local PADDING = 32
local BTN_HEIGHT = 72

function ScorePurchaseDialog:ctor(args)
    ScorePurchaseDialog.super.ctor(self, {ScorePurchaseDialog.WIDTH+30, ScorePurchaseDialog.HEIGHT+30})
    self:addBgLight()
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
        self.notCloseWhenTouchModel_ = (args.closeWhenTouchModel == false)
    end
	self:initView()

    self:addTopDivide()
end

function ScorePurchaseDialog:initView()
	local width,height = ScorePurchaseDialog.WIDTH, ScorePurchaseDialog.HEIGHT
	
    self.mainContainer_ = display.newNode()
	self.mainContainer_ = display.newNode():addTo(self)
    self.mainContainer_:setContentSize(width,height)
    self.mainContainer_:setTouchEnabled(true)
    self.mainContainer_:setTouchSwallowEnabled(true)

    local dw, dh = 50, 170
    self.border_ = display.newScale9Sprite("#sm_dialog_border.png", 0, 0 + 12, cc.size(width - dw, height - dh))
        :addTo(self.mainContainer_)
        :hide()

    -- 关闭按钮
    self:addCloseBtn()

    self.titlelbl_ = ui.newTTFLabel({
            text = self.titleText_,
            color = cc.c3b(0xfb, 0xd0, 0x0a),
            size = 32, 
            align = ui.TEXT_ALIGN_CENTER
        }):pos(0, height*0.5 - 22):addTo(self)

    local messageLabel = ui.newTTFLabel({
            text = self.messageText_,
            color = styles.FONT_COLOR.LIGHT_TEXT,
            size = 26,
            align = ui.TEXT_ALIGN_CENTER,
            dimensions = cc.size(width - dw, 0)
        })
        :pos(0, (PADDING + BTN_HEIGHT - TOP_HEIGHT) * 0.5)
        :addTo(self)

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
        buttonWidth = (width - 4 * PADDING) * 0.5
        self.firstBtn_:setButtonSize(buttonWidth, BTN_HEIGHT)
                    :pos(-(PADDING + buttonWidth) * 0.5, -height * 0.5 + PADDING + BTN_HEIGHT * 0.5 - 20)
        self.secondBtn_:setButtonSize(buttonWidth, BTN_HEIGHT)
                    :pos((PADDING + buttonWidth) * 0.5, -height * 0.5 + PADDING + BTN_HEIGHT * 0.5 - 20)
    else
        buttonWidth = 280
        self.secondBtn_:setButtonSize(buttonWidth, BTN_HEIGHT):pos(0, -height * 0.5 + PADDING + BTN_HEIGHT * 0.5 - 20)
    end
end

-- 按钮点击事件处理
function ScorePurchaseDialog:onButtonClick_(event)
    if self.callback_ then
        if event.target == self.firstBtn_ then
            self.callback_(1)
        elseif event.target == self.secondBtn_ then
            self.callback_(2)
        end
    end
    self.callback_ = nil
    self:close()
end

function ScorePurchaseDialog:show()
    nk.PopupManager:addPopup(self)
    return self
end

function ScorePurchaseDialog:onClose()
    self:close()
end

function ScorePurchaseDialog:close()
    nk.PopupManager:removePopup(self)
    return self
end

return ScorePurchaseDialog