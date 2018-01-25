--
-- Author: KevinYu
-- Date: 2016-05-18 18:04:31
-- 一行多个个商品基类

local BaseProductItems = class("BaseProductItems", function ()
	return display.newNode()
end)

local CUR_PRICE_COLOR = cc.c3b(0xc4, 0xdf, 0xfb) --当前价格label颜色
local PRICE_COLOR = cc.c3b(0x6d, 0x72, 0x91) --打折时，原价label颜色

function BaseProductItems:ctor(params)
	self:setNodeEventEnabled(true)

	self.bg_w, self.bg_h = params.width, params.height
	local w, h = self.bg_w, self.bg_h

    self.bg_ = display.newNode()
        :size(w, h)
        :align(display.CENTER, 0, 25)
        :addTo(self)

    local bg = self.bg_
    local normalBg = display.newScale9Sprite("#store_goods_big_bg.png", 0, 0, cc.size(w, h))
        :pos(w/2, h/2)
        :addTo(bg)

    local selectBg = display.newScale9Sprite("#store_goods_big_bg_pressed.png", 0, 0, cc.size(w, h))
        :pos(w/2, h/2)
        :addTo(bg)
        :hide()

    normalBg:setTouchEnabled(true)
    normalBg:setTouchSwallowEnabled(false)
    normalBg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(evt)
        local name = evt.name
        if name == "began" then
            self.beginX_ = evt.x
            self.beginY_ = evt.y

            normalBg:hide()
            selectBg:show()

            return true
        elseif name == "ended" then
            local offset = math.abs(evt.y - self.beginY_)
            if offset < 10 then
                self:onBuyClicked_()
            end

            normalBg:show()
            selectBg:hide()
        end
    end)

    display.newSprite("#store_goods_big_bg_light.png")
        :pos(w/2, h/2 + 20)
        :addTo(bg)

    --商品标记，优惠额度或者新品，热门
    local state_x, state_y          --打折标记坐标
    local off_x, off_y              --新品，热门标记坐标
    local offRotation = 0           --打折文字旋转角度
    local off_label_x, off_label_y  --打折文字坐标
    local offImage = ""             --打折标记图片
    local hotImage = ""
    local newImage = ""
    local markType = params.markType or 1

    if markType == 1 then --标记在中间
        state_x, state_y = w/2 + 50, h/2 - 20
        off_x, off_y = state_x, state_y
        off_label_x, off_label_y = state_x, state_y
        offImage = "#store_label_off_2.png"
        hotImage = "#store_label_hot2.png"
        newImage = "#store_label_new2.png"
    else --标记在左上角
        state_x, state_y = 36, h - 38
        off_x, off_y = 36, h - 38
        off_label_x, off_label_y = state_x - 8, state_y + 10
        offImage = "#store_label_off.png"
        hotImage = "#store_label_hot.png"
        newImage = "#store_label_new.png"
        offRotation = -45
    end

    self.hot_ = display.newSprite(hotImage)
        :pos(off_x, off_y)
        :addTo(bg, 1)

    self.new_ = display.newSprite(newImage)
        :pos(off_x, off_y)
        :addTo(bg, 1):hide()

    self.off_ = display.newSprite(offImage)
        :pos(state_x, state_y)
        :addTo(bg, 1):hide()

    --优惠额度
    self.offLabel_ = ui.newTTFLabel({text="", size=16, color=cc.c3b(0xee, 0xff, 0x31), align=ui.TEXT_ALIGN_CENTER})
        :pos(off_label_x, off_label_y)
        :rotation(offRotation)
        :addTo(bg, 1):hide()

    --商品标题，原价或者推荐商品才显示
    local origin_x, origin_y = w/2, h - 30
    self.title_ = ui.newTTFLabel({text="", color = CUR_PRICE_COLOR, size=24, align=ui.TEXT_ALIGN_LEFT})
        :pos(origin_x, origin_y)
        :addTo(bg)
    
    --打折后的价格，只有打折的时候才显示
    self.titleOff_ = ui.newTTFLabel({text="", size=24, color = CUR_PRICE_COLOR, align=ui.TEXT_ALIGN_LEFT})
        :pos(origin_x, origin_y)
        :addTo(bg)

    --原价画个横线，只有打折的时候才显示
    self.titleOffOrigin_ = ui.newTTFLabel({text="", size=24, color = PRICE_COLOR, align=ui.TEXT_ALIGN_LEFT})
        :pos(origin_x, origin_y - 25)
        :addTo(bg)

   self.titleOffOriginDeleteLine_ = display.newRect(1, 2, {fill=true, fillColor=cc.c4f(0x7c / 0xff, 0x4b / 0xff, 0x4e / 0xff, 1)})
        :pos(origin_x, origin_y - 25)
        :addTo(bg)

    --汇率
    self.rate_ = ui.newTTFLabel({text="", size=18, color=cc.c3b(0x97, 0x92, 0xda), align=ui.TEXT_ALIGN_RIGHT})
        :pos(w/2, 70)
        :addTo(bg)

    --价格，因为googleplay的原因，不能用BMFont
    self.priceLabel_1 =  ui.newBMFontLabel({font = "fonts/store.fnt"})
            :pos(w/2, 32)
            :addTo(bg)
            
    self.priceLabel_2 =  ui.newTTFLabel({size = 36, color=cc.c3b(0xff, 0xb4, 0x14)})
        :pos(w/2, 32)
        :addTo(bg)

    self.light_ = display.newSprite("#store_light.png")
        :align(display.TOP_CENTER, w/2, h + 65)
        :addTo(bg)
        :hide()
end

function BaseProductItems:showTopLight()
    self.light_:show()
end

function BaseProductItems:onBuyClicked_(evt)
    local thisTime = bm.getTime()
    if not BaseProductItems.buyBtnLastClickTime or math.abs(thisTime - BaseProductItems.buyBtnLastClickTime) > 1 then
        BaseProductItems.buyBtnLastClickTime = thisTime
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
        self:getParent():dispatchEvent({name="ITEM_EVENT", type="MAKE_PURCHASE", pid = self.data_.pid, goodsItem = self.data_})
    end
end

function BaseProductItems:setProductData(dataChanged, data)
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
            if data.pmode == "348" then
                self.rate_:setString(data.skus or "")
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
        if data.propType ~= 6 then
            self.title_:hide()
            self.titleOffOrigin_:show()
            self.titleOffOrigin_:setString(data.title or "")
            self.titleOffOriginDeleteLine_:setScaleX(self.titleOffOrigin_:getContentSize().width)
            self.titleOffOriginDeleteLine_:show()
            self.titleOff_:show()
            self.titleOff_:setString(data.discountTitle)
        end
    end

    if data.propType == 6 then
        self.title_:show()
        self.title_:setString(data.title or "")
        self.titleOffOrigin_:hide()
        self.titleOffOriginDeleteLine_:hide()
        self.titleOff_:hide()
        self.rate_:hide()
    else
        self.rate_:show()
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
    -- 群组折扣
    if (not data.noDiscount) and Global_inGroupShopDis and tonumber(Global_inGroupShopDis) > 0 and Global_StorePopupType then
        self.hot_:hide()
        self.new_:hide()
        self.off_:show()
        local disStr = string.format("%+d%%",  Global_inGroupShopDis* 100)
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
        bm.fitSprteWidth(self.titleOff_, self.bg_w-60)
        self.titleOff_:setPositionX(self.bg_w*0.5+15)
    else
        self.titleOff_:setScale(1)
        self.titleOff_:setPositionX(self.bg_w*0.5)
    end
end

function BaseProductItems:loadIconImage_(data)
    if data.bygood and data.bygood.desc then
        local descJson = json.decode(data.bygood.desc);
        if string.len(descJson.url1) > 0 then
            filename = nk.userData.cdn..descJson.url1;
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

function BaseProductItems:onloadIconComplete_(success, sprite)
    if success then
        local dw, dh = 90, 90;
        local tex = sprite:getTexture();
        local texSize = tex:getContentSize();
        self.prdImg_:setTexture(tex)
        self.prdImg_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height));
        local xscale, yscale = dw/texSize.width, dh/texSize.height;
        local minVal = math.min(xscale, yscale)
        self.prdImg_:setScale(minVal);
    end
end

function BaseProductItems:onCleanup()
    if self.iconLoaderId_ then
        nk.ImageLoader:cancelJobByLoaderId(self.iconLoaderId_)
        self.iconLoaderId_ = nil;
    end
end

return BaseProductItems
