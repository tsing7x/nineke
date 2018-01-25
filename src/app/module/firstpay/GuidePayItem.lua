--
-- Author: KevinLiang@boyaa.com
-- Date: 2015-10-23 14:27:06
--

local GuidePayItem = class("GuidePayItem",function()
    return display.newNode()
end)

local WIDTH, HEIGHT = 752, 140

function GuidePayItem:ctor()
    local line_w, line_x = 38, -365
    for i = 1, 19 do
        display.newSprite("#crash_split_line.png")
            :align(display.LEFT_BOTTOM, line_x + (i - 1) * line_w, -70)
            :addTo(self)
    end

    --图标
    self.chips = display.newSprite()
        :align(display.BOTTOM_CENTER, -WIDTH / 2 + 86, -HEIGHT/2 + 10)
        :addTo(self, 1)

    --名字和汇率
    self.title_ = ui.newTTFLabel({text="", size=36, align=ui.TEXT_ALIGN_LEFT})
        :align(display.LEFT_CENTER, -WIDTH/2 + 150, 15)
        :addTo(self)
    
    self.rate_ = ui.newTTFLabel({text="", size=20, color=cc.c3b(0xff, 0xde, 0x46), align=ui.TEXT_ALIGN_RIGHT})
        :align(display.LEFT_CENTER, -WIDTH/2 + 150, -25)
        :addTo(self)

    --打折
    self.discount_icon = display.newSprite("#guidepay_discount_icon_bg.png")
            :pos(-WIDTH * 0.5 + 30, HEIGHT * 0.25 - 10)
            :addTo(self)
            :hide()
    self.discount_info = ui.newTTFLabel({text="", size=18, color=cc.c3b(0x6d, 0x25, 0x00), align=ui.TEXT_ALIGN_CENTER})
            :pos(31, 27)
            :addTo(self.discount_icon)

    --按钮
    local btn_x = WIDTH/2 - 100
    self.buyBtn_ = cc.ui.UIPushButton.new({normal="#common_btn_green_normal.png", pressed="#common_btn_green_pressed.png"}, {scale9=true})
        :setButtonSize(160, 52)
        :setButtonLabel(ui.newTTFLabel({size=28, color=cc.c3b(0xff, 0xff, 0xff), align=ui.TEXT_ALIGN_CENTER}))
        :onButtonClicked(function(evt)
            local thisTime = bm.getTime()
            if not buyBtnLastClickTime or math.abs(thisTime - buyBtnLastClickTime) > 2 then
                buyBtnLastClickTime = thisTime
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                if self.callback_ then
                    self.callback_(self.data_)
                end
            end
        end)
        :pos(btn_x, 0)
        :addTo(self)

    --原价
    self.origalPrice = ui.newTTFLabel({text="", size=16, color=cc.c3b(0xaa, 0xaa, 0xaa), align=ui.TEXT_ALIGN_RIGHT})
    self.origalPrice:pos(btn_x, -40)
    self.origalPrice:addTo(self):hide()
end

function GuidePayItem:setGoodsDiscount(discount_)
    self.goodsDiscount_ = discount_
end

function GuidePayItem:setData(data, callback)
    self.callback_ = callback
    self.data_ = data
    local rate = 0
    local is_gcions = false
    local discount = tonumber(data.discount)
    if tonumber(data.ptype) == 35 then
        is_gcions = true
    end

    if tonumber(data.ptype) ~= 7 then
        data.pchips = data.pnum
    else
        data.content = json.decode(good.ext.content)
        data.pchips = data.content.chips
    end

    if discount ~= 1 then
        rate = data.pchips * discount / data.pamount
        local numOff = math.floor(data.pchips * discount)
        if is_gcions then
            data.getname = bm.LangUtil.getText("STORE", "FORMAT_GOLD", bm.formatBigNumber(numOff))
        else
            data.getname = bm.LangUtil.getText("STORE", "FORMAT_CHIP", bm.formatBigNumber(numOff))
        end
    else
        rate = data.pchips / data.pamount
    end

    if self.goodsDiscount_ and self.goodsDiscount_ > 0 then
        self.title_:setSystemFontSize(24)
        discount = (self.goodsDiscount_ or 0) * 0.01 + 1
    end
    self.title_:setString(data.getname)

    if is_gcions then
        local str_ = bm.formatNumberWithSplit(tonumber(string.format("%.1f", rate)))
        if not string.find(str_, "%.") then
            str_ = str_ .. ".0"
        end
        self.rate_:setString(bm.LangUtil.getText("STORE", "RATE_GOLD", str_, "THB"))
    else
        self.rate_:setString(bm.LangUtil.getText("STORE", "RATE_CHIP", bm.formatNumberWithSplit(tonumber(string.format("%.0f", rate))), "THB"))
    end

    if discount and discount > 0 and discount ~= 1 then
        self.discount_icon:show()
        self.discount_info:setString("+" .. (discount * 100 - 100) .. "%")

        self.origalPrice:show()
        self.origalPrice:setString(bm.LangUtil.getText("GUIDE_PAY", "PRICE_ORIGAL_TIPS", math.floor(data.pamount * discount)))

        local size = self.origalPrice:getContentSize()
        local w, h = size.width, size.height
        local posX,posY = self.origalPrice:getPositionX(),self.origalPrice:getPositionY()

        display.newScale9Sprite("#guide_pay_line.png", w/2, h/2, cc.size(w, 3))
            :pos(posX, posY)
            :addTo(self)
    end

    self.buyBtn_:setButtonLabelString("normal", data.pamount .. "THB")

    local index_ = 105
    local amount = tonumber(data.pamount)
    if amount > 100 then
        index_ = 105
    elseif amount > 50 then
        index_ = 103
    elseif amount > 30 then
        index_ = 102
    elseif amount > 15 then
        index_ = 101
    else
        index_ = 100
    end
    if is_gcions then
        self.chips:setSpriteFrame(display.newSpriteFrame("store_prd_gold_" .. index_ .. ".png"))
    else
        if index_ > 100 and index_ < 105 then
            index_ = index_ + 1
        end
        self.chips:setSpriteFrame(display.newSpriteFrame("store_prd_" .. index_ .. ".png"))
    end
end

return GuidePayItem