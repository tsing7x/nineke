--
-- Author: KevinLiang
-- Date: 2016-01-23 20:56:37
--

local RoomPopupTabBar = class("RoomPopupTabBar", function ()
    return display.newNode()
end)

RoomPopupTabBar.TAB_BAR_HEIGHT = 72

local whiteColor = cc.c3b(0xff, 0xff, 0xff)
local selectedColor = whiteColor
local unselectedColor = cc.c3b(0xaa, 0xaa, 0xaa)

function RoomPopupTabBar:ctor(args, txtSize)
    self.bgWidth_ = args.popupWidth * (args.scale or 0.85)
    self.iconTexture_ = args.iconTexture

    local yOffset_ = args.yOffset or -5
    local container = display.newNode():addTo(self):pos(0, yOffset_)

    -- 背景1
    self.bg1_ = display.newScale9Sprite("#room_pop_tab_bg.png", 0, 0, cc.size(self.bgWidth_, RoomPopupTabBar.TAB_BAR_HEIGHT), cc.rect(22, 0, 1, 1))
        :addTo(container)

    self.itemFirstSelectedbg_ = display.newScale9Sprite("#room_pop_chat_tab_selected.png", -self.bgWidth_ * 0.25, -3, cc.size(self.bgWidth_ * 0.5 - 2, RoomPopupTabBar.TAB_BAR_HEIGHT - 6), cc.rect(10, 0, 1, 1))
        :addTo(container)
        :hide()
    self.itemFirstSelectedbg_:setScaleX(-1)
    self.itemLastSelectedbg_ = display.newScale9Sprite("#room_pop_chat_tab_selected.png", self.bgWidth_ * 0.25, -3, cc.size(self.bgWidth_ * 0.5 - 2, RoomPopupTabBar.TAB_BAR_HEIGHT - 6), cc.rect(10, 0, 1, 1))
        :addTo(container)
        :hide()

    -- 字按钮
    self.subBtns_ = {}
    self.btnIcons_ = {}
    self.btnIconsBg_ = {}
    self.btnText_ = args.btnText
    -- 
    txtSize = txtSize or 20;    
    for i = 1, #args.btnText do
        if args.iconTexture then
            self.btnIcons_[i] = display.newSprite(args.iconTexture[i][1]):pos(args.iconOffsetX, 0)
        end
        self.subBtns_[i] = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png"}, {scale9 = true})
            :setButtonSize(self.bgWidth_ / #args.btnText, RoomPopupTabBar.TAB_BAR_HEIGHT)
            :setButtonLabel("normal", ui.newTTFLabel({text = self.btnText_[i], color = selectedColor, size = txtSize, align = ui.TEXT_ALIGN_CENTER}))
            :pos(self.bgWidth_ * -0.5 + (i - 0.5) * (self.bgWidth_ / #args.btnText), 2)
            :addTo(container)
            :onButtonClicked(buttontHandler(self, self.onBtnClick_))
        if args.iconTexture then
            self.subBtns_[i]:setButtonLabelOffset(self.btnIcons_[i]:getContentSize().width - 20, 0)
            :add(self.btnIcons_[i])
        end
        if args.iconTexture then
            self.btnIcons_[i]:setPositionX(-0.5 * self.subBtns_[i]:getButtonLabel("normal"):getContentSize().width - args.iconOffsetX)
        end
    end

    self.selectedTab_ = 1
    self:gotoTab(self.selectedTab_)
end

function RoomPopupTabBar:onBtnClick_(event)
    local btnId = table.keyof(self.subBtns_, event.target) + 0
    if btnId ~= self.selectedTab_ then
        self:gotoTab(btnId)
    end
end

-- 注:btnId = 0所有tab 都不选中
function RoomPopupTabBar:gotoTab(btnId)
    local padding = 0
    for i, v in ipairs(self.subBtns_) do
        local btn = self.subBtns_[i]
        local icon = self.btnIcons_[i]
        local lb = btn:getButtonLabel()
        if i == btnId then
            lb:setTextColor(selectedColor)
            if icon then
                icon:setSpriteFrame(display.newSpriteFrame(string.gsub(self.iconTexture_[i][1], "#", "")))
            end
            if i == 1 then
                self.itemFirstSelectedbg_:show()
                self.itemLastSelectedbg_:hide()
            elseif i == #self.subBtns_ then
                self.itemFirstSelectedbg_:hide()
                self.itemLastSelectedbg_:show()
            end
        else
            lb:setTextColor(unselectedColor)
            if icon then
                icon:setSpriteFrame(display.newSpriteFrame(string.gsub(self.iconTexture_[i][2], "#", "")))
            end
        end
    end

    self.selectedTab_ = btnId
    if self.callback_ then
        self.callback_(self.selectedTab_)
    end
end

function RoomPopupTabBar:onTabChange(callback)
    assert(type(callback) == "function", "callback should be a function")
    self.callback_ = callback
    if self.callback_ then
        self.callback_(self.selectedTab_)
    end
    return self
end

return RoomPopupTabBar