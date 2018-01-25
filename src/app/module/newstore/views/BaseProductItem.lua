--
-- Author: kevinYu
-- Date: 2016-5-24
-- 一行一个商品基类

local BaseProductItem = class("BaseProductItem", bm.ui.ListItem)

local CUR_PRICE_COLOR = cc.c3b(0xc4, 0xdf, 0xfb) --当前价格label颜色
local PRICE_COLOR = cc.c3b(0x6d, 0x72, 0x91) --打折时，原价label颜色
local FLOOR_Y = 25

function BaseProductItem:ctor(item_w, item_h, isShowBtn)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

    BaseProductItem.super.ctor(self, item_w, item_h + 2)

    self:setNodeEventEnabled(true)

    self.bg_w, self.bg_h = item_w, item_h

    local w, h = self.bg_w, self.bg_h
    
    self.light_ = display.newSprite("#store_light.png")
        :align(display.TOP_CENTER, 95, h + FLOOR_Y + 17)
        :addTo(self)

    display.newScale9Sprite("#store_goods_floor.png", 0, 0, cc.size(w, 56))
        :align(display.TOP_CENTER, w/2, FLOOR_Y)
        :addTo(self)

    self.bg_ = display.newNode()
        :size(w, h)
        :addTo(self)

    local bg = self.bg_

    local state_x, state_y = 60, 68 + FLOOR_Y
    self.hot_ = display.newSprite("#store_label_hot.png"):pos(state_x, state_y):addTo(bg, 1)
    self.new_ = display.newSprite("#store_label_new.png"):pos(state_x, state_y):addTo(bg, 1):hide()
    self.off_ = display.newSprite("#store_label_off.png"):pos(state_x, state_y):addTo(bg, 1):hide()

    --优惠额度
    self.offLabel_ = ui.newTTFLabel({text="", size=16, color=cc.c3b(0xee, 0xff, 0x31), align=ui.TEXT_ALIGN_CENTER})
        :pos(state_x - 8, state_y + 10)
        :rotation(-45)
        :addTo(bg, 1):hide()

    --商品标题，原价或者推荐商品才显示
    local origin_x, origin_y = 160, 45 + FLOOR_Y
    self.title_ = ui.newTTFLabel({text="", size=24, color = CUR_PRICE_COLOR, align=ui.TEXT_ALIGN_LEFT})
        :align(display.LEFT_CENTER, origin_x, origin_y)
        :addTo(bg)
   
    --打折后的价格，只有打折的时候才显示
    self.titleOff_ = ui.newTTFLabel({text="", size=24, color = CUR_PRICE_COLOR, align=ui.TEXT_ALIGN_LEFT})
        :align(display.LEFT_CENTER, origin_x, origin_y)
        :addTo(bg)

    --原价画个横线，只有打折的时候才显示
    local oy = origin_y - 25
    self.titleOffOrigin_ = ui.newTTFLabel({text="", size=24, color = PRICE_COLOR, align=ui.TEXT_ALIGN_LEFT})
        :align(display.LEFT_CENTER, origin_x, oy)
        :addTo(bg)
 
    self.titleOffOriginDeleteLine_ = display.newRect(1, 2, {fill=true, fillColor=cc.c4f(0x7c / 0xff, 0x4b / 0xff, 0x4e / 0xff, 1)})
        :align(display.LEFT_CENTER, origin_x, oy)
        :addTo(bg)

    --汇率
    self.rate_ = ui.newTTFLabel({text="", size=18, color=cc.c3b(0x97, 0x92, 0xda), align=ui.TEXT_ALIGN_RIGHT})
        :pos(w * 0.5, origin_y)
        :addTo(bg)

    self.des_ = ui.newTTFLabel({text="", size=18, color=cc.c3b(0x97, 0x92, 0xda), align=ui.TEXT_ALIGN_RIGHT})
        :align(display.LEFT_CENTER, origin_x, oy)
        :addTo(bg)
        :hide()

    --价格，因为googleplay的原因，不能用BMFont
    local price_x, price_y = w - 130, origin_y

    self.isShowBtn_ = isShowBtn
    if isShowBtn then
        cc.ui.UIPushButton.new({normal = "#common_btn_green_normal.png", pressed = "#common_btn_green_pressed.png"}, {scale9 = true})
            :setButtonSize(160, 52)
            :onButtonClicked(function()
                self:onBuyClicked_()
            end)
            :pos(price_x, price_y)
            :addTo(bg)
            
    end

    self.priceLabel_1 =  ui.newBMFontLabel({font = "fonts/store.fnt"})
            :pos(price_x, price_y)
            :addTo(bg)
            
    self.priceLabel_2 =  ui.newTTFLabel({size = 36, color=cc.c3b(0xff, 0xb4, 0x14)})
        :pos(price_x, price_y)
        :addTo(bg)
end

--增加商品描述，主要是道具的时候调用
function BaseProductItem:showGoodsDes(text)
    self.rate_:hide()

    self.des_:setString(text)
    self.des_:show()
end

function BaseProductItem:addFirstFloor_()
    if not self.firstFloor_ then
        local w, h = self.bg_w, self.bg_h + FLOOR_Y
        self.firstFloor_ = true

        display.newScale9Sprite("#store_goods_floor.png", 0, 0, cc.size(w, 56))
            :align(display.TOP_CENTER, w/2, h)
            :addTo(self)

        self:setContentSize(cc.size(w, h))
    end
end

function BaseProductItem:onDataSet(dataChanged, data)
    if dataChanged then
        self.data_ = data
        if data.rate then
            if data.propType == 35 then --黄金币
                if data.rate > 1000 then
                    local rate = tonumber(string.format("%d", data.rate))
                    self.rate_:setString(bm.LangUtil.getText("STORE", "RATE_GOLD", bm.formatNumberWithSplit(rate), data.priceDollar))
                else
                    self.rate_:setString(bm.LangUtil.getText("STORE", "RATE_GOLD", string.format("%.1f", data.rate or 0), data.priceDollar))
                end
            elseif data.propType == 2 then --道具
                if data.rate > 1000 then
                    local rate = tonumber(string.format("%d", data.rate))
                    self.rate_:setString(bm.LangUtil.getText("STORE", "RATE_PROP", bm.formatNumberWithSplit(rate), data.priceDollar))
                else
                    self.rate_:setString(bm.LangUtil.getText("STORE", "RATE_PROP", string.format("%.1f", data.rate or 0), data.priceDollar))
                end
            else--筹码
                if data.rate > 1000 then
                    local rate = tonumber(string.format("%d", data.rate))
                    self.rate_:setString(bm.LangUtil.getText("STORE", "RATE_CHIP", bm.formatNumberWithSplit(rate), data.priceDollar))
                else
                    self.rate_:setString(bm.LangUtil.getText("STORE", "RATE_CHIP", string.format("%.1f", data.rate or 0), data.priceDollar))
                end
            end
        end

        if data.discount ~= 1 then
            self.hot_:hide()
            self.new_:hide()
            self.off_:show()
            self.offLabel_:show():setString(string.format("%+d%%",  math.round((data.discount - 1) * 100)))
        elseif data.tag == "hot" then
            self.hot_:show()
            self.new_:hide()
            self.off_:hide()
            self.offLabel_:hide()
        elseif data.tag == "new" then
            self.hot_:hide()
            self.new_:show()
            self.off_:hide()
            self.offLabel_:hide()
        else
            self.hot_:hide()
            self.new_:hide()
            self.off_:hide()
            self.offLabel_:hide()
        end

        if data.discount == 1 then
            self.title_:show()
            self.title_:setString(data.title or "")
            self.titleOffOrigin_:hide()
            self.titleOffOriginDeleteLine_:hide()
            self.titleOff_:hide()
        else
            self.title_:hide()
            self.titleOffOrigin_:show()
            self.titleOffOrigin_:setString(data.title or "")
            self.titleOffOriginDeleteLine_:setScaleX(self.titleOffOrigin_:getContentSize().width)
            self.titleOffOriginDeleteLine_:show()
            self.titleOff_:show()
            self.titleOff_:setString(data.discountTitle)
        end

        if self.prdImg_ then
            self.prdImg_:removeFromParent()
            self.prdImg_ = nil
        end

        self:setProductIcon_()

        if data.priceDollar == "THB" and data.pmode ~= "12" then
           self.priceLabel_1:setString(data.priceNum .. "T")
           self.priceLabel_2:setString("")
        else
            self.priceLabel_2:setString(data.priceLabel)
            self.priceLabel_1:setString("")
        end

        self:loadIconImage_(data)

        if self.index_ == 1 then
            if self.isShowBtn_ then
                self.light_:hide()
            else
                self:addFirstFloor_()
            end
        end

        -- 群组折扣
        if (not data.noDiscount) and Global_inGroupShopDis and tonumber(Global_inGroupShopDis) > 0 and Global_StorePopupType then
            self.hot_:hide()
            self.new_:hide()
            self.off_:show()
            local disStr = string.format("%+d%%",  Global_inGroupShopDis * 100)
            self.offLabel_:show():setString(disStr)

            self.title_:hide()
            self.titleOffOrigin_:show()
            self.titleOffOrigin_:setString(data.title or "")
            self.titleOffOriginDeleteLine_:setScaleX(self.titleOffOrigin_:getContentSize().width)
            self.titleOffOriginDeleteLine_:show()
            self.titleOff_:show()
            -- self.titleOff_:setString(data.discountTitle)
            -- self.titleOff_:setString((data.title or ""))
            self.titleOff_:setString((data.title or "")..disStr)
            bm.fitSprteWidth(self.titleOff_, self.titleOffOrigin_:getContentSize().width)
        else
            self.titleOff_:setScale(1)
        end
    end
end

function BaseProductItem:onBuyClicked_(evt)
    local thisTime = bm.getTime()
    if not BaseProductItem.buyBtnLastClickTime or math.abs(thisTime - BaseProductItem.buyBtnLastClickTime) > 1 then
        BaseProductItem.buyBtnLastClickTime = thisTime
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
        self:dispatchEvent({name="ITEM_EVENT", type="MAKE_PURCHASE", pid = self.data_.pid, goodsItem = self.data_})
    end
end

function BaseProductItem:loadIconImage_(data)
    if data.bygood and data.bygood.desc then
        local descJson = json.decode(data.bygood.desc)
        if string.len(descJson.url1) > 0 then
            filename = nk.userData.cdn..descJson.url1
            if not self.iconLoaderId_ then
                self.iconLoaderId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id
            end

            nk.ImageLoader:loadAndCacheImage(
                self.iconLoaderId_,
                filename,
                handler(self, self.onloadIconComplete_),
                nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
            )
        end
    end
end

function BaseProductItem:onloadIconComplete_(success, sprite)
    if success then
        local dw, dh = 90, 90
        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()
        self.prdImg_:setTexture(tex)
        self.prdImg_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
        local xscale, yscale = dw/texSize.width, dh/texSize.height
        local minVal = math.min(xscale, yscale)
        self.prdImg_:setScale(minVal)
    end
end

function BaseProductItem:onCleanup()
    if self.iconLoaderId_ then
        nk.ImageLoader:cancelJobByLoaderId(self.iconLoaderId_)
        self.iconLoaderId_ = nil
    end
end

return BaseProductItem