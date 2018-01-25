--
-- Author: johnny@boomegg.com
-- Date: 2014-08-23 20:56:37
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local CommonPopupTabBar = class("CommonPopupTabBar", function ()
    return display.newNode()
end)

CommonPopupTabBar.TAB_BAR_HEIGHT = 66

local whiteColor = cc.c3b(0xff, 0xff, 0xff)
local selectedColor = whiteColor
local unselectedColor = cc.c3b(0xaa, 0xaa, 0xaa)

function CommonPopupTabBar:ctor(args, txtSize)
    self.bgWidth_ = args.popupWidth * (args.scale or 0.85)
    self.iconTexture_ = args.iconTexture

    self.bgHeight_ = args.bgHeight or CommonPopupTabBar.TAB_BAR_HEIGHT - 16
    self.itemHeight_ = args.itemHeight or (CommonPopupTabBar.TAB_BAR_HEIGHT - 18)
    self.selectedColor_ = args.selectedColor or selectedColor
    self.unselectedColor_ = args.unselectedColor or unselectedColor

    local yOffset_ = args.yOffset or 0
    local container = display.newNode():addTo(self):pos(0, yOffset_)

    -- 每个按钮宽度
    local item_width = self.bgWidth_ / #args.btnText
    local item_offset_y = -10
    local item_offset_x = 1


    display.newScale9Sprite(args.bg or "#pop_common_tab_bg.png", 0, item_offset_y, cc.size(self.bgWidth_, self.bgHeight_), cc.rect(33, 23, 1, 1))
        :addTo(container)

    -- tab按钮
    self.edgeBgW_, self.edgeBgH_ = item_width, self.itemHeight_ --两边按钮宽高
    self.middleBgW_, self.middleBgH_ = item_width, self.itemHeight_ --中间按钮宽高

    local firstBgW, firstBgH = self.edgeBgW_, self.edgeBgH_

    local itemFirstPressedbg = display.newScale9Sprite(
            args.edgeBg or "#pop_common_tab_item_pressed.png",
            -item_width * 0.5 + item_offset_x,
            item_offset_y,
            cc.size(firstBgW, firstBgH),
            args.edgeRect or cc.rect(25, 22, 1, 1)
        ):addTo(container, 2)
        :hide()

    local itemFirstSelectedbg = display.newScale9Sprite(
            args.edgeSelectedBg or "#pop_common_tab_item_selected.png",
            -item_width * 0.5 + item_offset_x,
            item_offset_y,
            cc.size(firstBgW, firstBgH),
            args.edgeRect or cc.rect(50, 22, 1, 1)
        ):addTo(container, 3):hide()

    local lastBgW, lastBgH = self.edgeBgW_, self.edgeBgH_
    local itemLastPressedbg = display.newScale9Sprite(
            args.edgeBg or "#pop_common_tab_item_pressed.png",
            item_width * 0.5 - item_offset_x,
            item_offset_y,
            cc.size(lastBgW, lastBgH),
            args.edgeRect or cc.rect(25, 22, 1, 1)
        ):addTo(container, 2)
        :hide()
    itemLastPressedbg:setScaleX(-1)

    local itemLastSelectedbg = display.newScale9Sprite(
            args.edgeSelectedBg or "#pop_common_tab_item_selected.png",
            item_width * 0.5 - item_offset_x,
            item_offset_y,
            cc.size(lastBgW, lastBgH),
            args.edgeRect or cc.rect(50, 22, 1, 1)
        ):addTo(container, 3):hide()
    itemLastSelectedbg:setScaleX(-1)
        
    self.itemSelectedbgs = {itemFirstSelectedbg, itemLastSelectedbg}
    self.itemPressedbgs = {itemFirstPressedbg, itemLastPressedbg}
    if #args.btnText == 4 then
        local middleBgW, middleBgH = self.middleBgW_, self.middleBgH_
        local itemPressedBg2_ = display.newScale9Sprite(
                args.middleBg or "#pop_common_tab_item_middle_pressed.png",
                -middleBgW * 0.5,
                item_offset_y,
                cc.size(middleBgW, middleBgH),
                args.middleRect or cc.rect(10, 22, 1, 1)
            ):addTo(container, 2):hide()
            
        local itemSelectedbg2_ = display.newScale9Sprite(
                args.middleSelectedBg or "#pop_common_tab_item_middle_selected.png",
                -middleBgW * 0.5,
                item_offset_y,
                cc.size(middleBgW, middleBgH),
                args.middleRect or cc.rect(10, 22, 1, 1)
            ):addTo(container, 3):hide()

        local itemPressedBg3_ = display.newScale9Sprite(
                args.middleBg or "#pop_common_tab_item_middle_pressed.png",
                middleBgW * 0.5,
                item_offset_y,
                cc.size(middleBgW, middleBgH),
                args.middleRect or cc.rect(10, 22, 1, 1)
            ):addTo(container, 2):hide()
            
        local itemSelectedbg3_ = display.newScale9Sprite(
                args.middleSelectedBg or "#pop_common_tab_item_middle_selected.png",
                middleBgW * 0.5,
                item_offset_y,
                cc.size(middleBgW, middleBgH),
                args.middleRect or cc.rect(10, 22, 1, 1)
            ):addTo(container, 3):hide()

        display.newSprite("#pop_common_tab_item_divide.png"):addTo(container):pos(-item_width, item_offset_y)
        display.newSprite("#pop_common_tab_item_divide.png"):addTo(container):pos(0, item_offset_y)
        display.newSprite("#pop_common_tab_item_divide.png"):addTo(container):pos(item_width, item_offset_y)

        itemFirstPressedbg:pos(-item_width * 1.5 + item_offset_x, item_offset_y)
        itemLastPressedbg:pos(item_width * 1.5 - item_offset_x, item_offset_y)
        itemFirstSelectedbg:pos(-item_width * 1.5 + item_offset_x, item_offset_y)
        itemLastSelectedbg:pos(item_width * 1.5 - item_offset_x, item_offset_y)

        table.insert(self.itemSelectedbgs, 2, itemSelectedbg2_)
        table.insert(self.itemSelectedbgs, 3, itemSelectedbg3_)

        table.insert(self.itemPressedbgs, 2, itemPressedBg2_)
        table.insert(self.itemPressedbgs, 3, itemPressedBg3_)
    end

    if #args.btnText == 3 then
        local middleBgW, middleBgH = self.middleBgW_, self.middleBgH_
        local itemPressedBg2_ = display.newScale9Sprite(
                args.middleBg or "#pop_common_tab_item_middle_pressed.png",
                0,
                item_offset_y,
                cc.size(middleBgW, middleBgH),
                args.middleRect or cc.rect(10, 22, 1, 1)
            ):addTo(container, 2):hide()
            
        local itemSelectedbg2_ = display.newScale9Sprite(
                args.middleSelectedBg or "#pop_common_tab_item_middle_selected.png",
                0,
                item_offset_y,
                cc.size(middleBgW, middleBgH),
                args.middleRect or cc.rect(10, 22, 1, 1)
            ):addTo(container, 3):hide()

        display.newSprite("#pop_common_tab_item_divide.png"):addTo(container):pos(-item_width * 0.5, item_offset_y)
        display.newSprite("#pop_common_tab_item_divide.png"):addTo(container):pos(item_width * 0.5, item_offset_y)

        itemFirstPressedbg:pos(-item_width * 1 + item_offset_x, item_offset_y)
        itemLastPressedbg:pos(item_width * 1 - item_offset_x, item_offset_y)
        itemFirstSelectedbg:pos(-item_width * 1 + item_offset_x, item_offset_y)
        itemLastSelectedbg:pos(item_width * 1 - item_offset_x, item_offset_y)

        table.insert(self.itemSelectedbgs, 2, itemSelectedbg2_)

        table.insert(self.itemPressedbgs, 2, itemPressedBg2_)
    end

    -- 字按钮
    self.subBtns_ = {}
    self.btnIcons_ = {}
    self.btnIconsBg_ = {}
    self.btnText_ = args.btnText
 
    txtSize = txtSize or 20  
    for i = 1, #args.btnText do
        if args.iconTexture then
            self.btnIcons_[i] = display.newSprite(args.iconTexture[i][1]):pos(args.iconOffsetX, 0)
            self.btnIconsBg_[i] = display.newSprite("#popup_tab_bar_icon_selected.png"):pos(args.iconOffsetX, 0)
        end

        self.subBtns_[i] = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png"}, {scale9 = true})
            :setButtonSize(self.bgWidth_ / #args.btnText, CommonPopupTabBar.TAB_BAR_HEIGHT)
            :setButtonLabel("normal", ui.newTTFLabel({text = self.btnText_[i], color = self.selectedColor_, size = txtSize, align = ui.TEXT_ALIGN_CENTER}))
            :pos(self.bgWidth_ * -0.5 + (i - 0.5) * (self.bgWidth_ / #args.btnText), item_offset_y)
            :addTo(container, 5)
            :onButtonClicked(buttontHandler(self, self.onBtnClick_))
            :onButtonPressed(function(evt)
                self.itemPressedbgs[i]:show()
            end)
            :onButtonRelease(function(evt)
                self.itemPressedbgs[i]:hide()
            end)

        if args.iconTexture then
            self.subBtns_[i]:setButtonLabelOffset(self.btnIcons_[i]:getContentSize().width, 0)
            :add(self.btnIcons_[i])
            :add(self.btnIconsBg_[i])
        end

        if args.iconTexture then
            self.btnIcons_[i]:setPositionX(-0.5 * self.subBtns_[i]:getButtonLabel("normal"):getContentSize().width - args.iconOffsetX)
            self.btnIconsBg_[i]:setPositionX(-0.5 * self.subBtns_[i]:getButtonLabel("normal"):getContentSize().width - args.iconOffsetX)
        end
    end

    self.selectedTab_ = 1
    self:gotoTab(self.selectedTab_)
end

function CommonPopupTabBar:onBtnClick_(event)
    local btnId = table.keyof(self.subBtns_, event.target) + 0
    if btnId ~= self.selectedTab_ then
        self:gotoTab(btnId)
    end
end

-- 注:btnId = 0所有tab 都不选中
function CommonPopupTabBar:gotoTab(btnId)
    local padding = 0

    for i, v in ipairs(self.subBtns_) do
        local btn = self.subBtns_[i]
        local icon = self.btnIcons_[i]
        local iconBg = self.btnIconsBg_[i]
        local lb = btn:getButtonLabel()
        if i == btnId then
            lb:setTextColor(self.selectedColor_)

            if icon then
                icon:setSpriteFrame(display.newSpriteFrame(string.gsub(self.iconTexture_[i][1], "#", "")))
            end

            if iconBg then
                iconBg:setSpriteFrame(display.newSpriteFrame("popup_tab_bar_icon_selected.png"))
            end

            for k = 1, #self.itemSelectedbgs do
                if i == k then
                    self.itemSelectedbgs[k]:show()
                else
                    self.itemSelectedbgs[k]:hide()
                end
                self.itemPressedbgs[k]:hide()
            end
        else
            lb:setTextColor(self.unselectedColor_)
            if icon then
                icon:setSpriteFrame(display.newSpriteFrame(string.gsub(self.iconTexture_[i][2], "#", "")))
            end
            if iconBg then
                iconBg:setSpriteFrame(display.newSpriteFrame("popup_tab_bar_icon_unselected.png"))
            end
        end
    end

    self.selectedTab_ = btnId
    if self.callback_ then
        self.callback_(self.selectedTab_)
    end
end

function CommonPopupTabBar:onTabChange(callback)
    assert(type(callback) == "function", "callback should be a function")

    self.callback_ = callback
    if self.callback_ then
        self.callback_(self.selectedTab_)
    end

    return self
end

function CommonPopupTabBar:addTabTipIcon(params)
    local index = params.index
    local image = params.image
    local offx, offy = params.offx or 0, params.offy or 0
    local bg = self.itemSelectedbgs[index]
    display.newSprite(image)
        :align(display.LEFT_CENTER, bg:getPositionX() + offx, offy)
        :addTo(bg:getParent(), 10)
end

return CommonPopupTabBar