--
-- Author: KevinYu
-- Date: 2016-11-07
-- 

local QuickPurchaseServiceManager = import("app.module.newstore.QuickPurchaseServiceManager")
local StorePopup = import("app.module.newstore.StorePopup")
local GuidePayItem = import(".GuidePayItem")

local GuidePayPopup = class("GuidePayPopup", function ()
    return display.newNode()
end)

local WIDTH, HEIGHT = 798, 428

-- type:
-- 2.进入房间时弹引导商品  102.进入黄金币场时弹引导商品
-- 4.坐下时弹引导商品  104.坐下黄金币场时弹引导商品
-- 6.参赛时弹引导商品  106.参赛黄金币场时弹引导商品
-- 13.限时优惠订单
function GuidePayPopup:ctor(type, callback, data,isDice)
    self:setNodeEventEnabled(true)

    self.type_ = type 
    self.quickPayService_ = QuickPurchaseServiceManager.getInstance()
    self.callback_ = callback
    self.data_ = data
    self.goodsItem = {}
    self.isDice_ = isDice or false
    self:setupView()
end

function GuidePayPopup:setupView()
    local node = display.newScale9Sprite("#transparent.png", 0, 0, cc.size(WIDTH, HEIGHT)):addTo(self)
    node:setTouchEnabled(true)
    node:setTouchSwallowEnabled(true)

    local img = "#guide_pay_bg_1.png"
    if self.type_ == 13 then
        img = "#guide_pay_bg_2.png"
    end
    self.bg_ = display.newSprite(img):addTo(self)

    local bg = self.bg_

    cc.ui.UIPushButton.new({normal = "#pop_common_close_normal.png", pressed = "#pop_common_close_pressed.png"})
        :onButtonClicked(buttontHandler(self, self.hide))
        :pos(WIDTH - 50, HEIGHT - 55)
        :addTo(bg)

    self:addTitle_(str)

    if self.type_%2 == 0 then
        local goods = self.data_.goodsInfo
        if #goods == 2 then
            GuidePayItem.new()
                :pos(WIDTH/2, HEIGHT/2 + 60)
                :addTo(bg)
                :setData(goods[1], handler(self, self.makePurchase))

            GuidePayItem.new()
                :pos(WIDTH/2, HEIGHT/2 - 60)
                :addTo(bg)
                :setData(goods[2], handler(self, self.makePurchase))
        end
    elseif  self.type_ == 13 then
        local goods = self.data_.goodsInfo
        if #goods == 2 then
            local item = GuidePayItem.new():addTo(bg)
            item:setGoodsDiscount(self.data_.discount)
            item:pos(WIDTH/2, HEIGHT/2-54)
            item:setData(goods[1], handler(self, self.makePurchase))

            item = GuidePayItem.new():addTo(bg)
            item:setGoodsDiscount(self.data_.discount)
            item:pos(WIDTH/2, HEIGHT/2 + 70)
            item:setData(goods[2], handler(self, self.makePurchase))
            nk.reportToDAdmin("jmtPreferentialOrder", "jmtPreferentialOrder=goods")
        end
    end

    local btn_x, btn_y = WIDTH - 150, 50
    self.enterWatch = cc.ui.UIPushButton.new()
        :setButtonLabel(ui.newTTFLabel({text=bm.LangUtil.getText("GUIDE_PAY", "ENTER_ROOM_WATCH"), size=22, color=cc.c3b(0xee, 0xee, 0xee), align=ui.TEXT_ALIGN_CENTER}))
        :pos(btn_x, btn_y)
        :addTo(bg)
        :onButtonClicked(function()
            self:onEnterWatchBtnListener_()
        end)

    self.morePayMethod = cc.ui.UIPushButton.new()
        :setButtonLabel(ui.newTTFLabel({text=bm.LangUtil.getText("GUIDE_PAY", "MORE_PAY_METHOD"), size=22, color=cc.c3b(0xee, 0xee, 0xee), align=ui.TEXT_ALIGN_CENTER}))
        :pos(btn_x, btn_y)
        :addTo(bg)
        :onButtonClicked(function()
            self:onMoreBtnListener_()
        end)

    if self.type_ == 102 then
        self.morePayMethod:hide()
    else
        self.enterWatch:hide()
    end

    if self.type_ > 6 then
        self.morePayMethod:hide()
    end

    if self.type_ == 13 or self.type_ == 104 or self.type_ == 106 then
        self.morePayMethod:show()
    end

    if self.isDice_ then
        self.enterWatch:hide()
    end
end

function GuidePayPopup:addTitle_()
    local title = ""
    if self.type_ == 13 then
        title = bm.LangUtil.getText("GUIDE_PAY","TITLE_DISCOUNT_COUNTDOWN")
    elseif self.type_ > 105 then
        title = bm.LangUtil.getText("GUIDE_PAY","TITLE_GCOINS_MATCH_SUPPLY", self.data_.minBuy)
    elseif self.type_ > 101 then
        title = bm.LangUtil.getText("GUIDE_PAY","TITLE_GCOINS_SUPPLY", self.data_.minBuy)
    elseif self.type_ > 4 then
        title = bm.LangUtil.getText("GUIDE_PAY","TITLE__MATCH_SUPPLY", self.data_.minBuy)
    else
        title = bm.LangUtil.getText("GUIDE_PAY","TITLE_SUPPLY", self.data_.minBuy)
    end

    local node = display.newNode()
        :pos(WIDTH/2, HEIGHT - 50)
        :addTo(self.bg_)

    display.newSprite("#crash_title_bg.png")
        :align(display.RIGHT_CENTER, 1, 0)
        :addTo(node)

    display.newSprite("#crash_title_bg.png")
        :align(display.LEFT_CENTER, -1, 0)
        :flipX(true)
        :addTo(node)

    local col = cc.c3b(0xc8, 0x7f, 0xfd)
    if self.type_ == 13 then
        local time = ui.newTTFLabel({text="", size=26})
            :pos(0, 13)
            :addTo(node)

        time:runAction((cc.RepeatForever:create(transition.sequence({
                cc.CallFunc:create(function()
                    local onsaletime_ = nk.OnOff:getCurrentTime(nk.OnOff.onsaleCountDownTimerId)
                    if onsaletime_ > 0 then
                        local str = bm.TimeUtil:getTimeString1(onsaletime_)
                        time:setString(str)
                    else
                        time:stopAllActions()
                        self:hide()
                    end
                end),
                cc.DelayTime:create(1.0)
        }))))

        ui.newTTFLabel({font = "fonts/BLK-Suphanburi.ttf", color = cc.c3b(0x99, 0x37, 0x02), text=title, size=24})
            :pos(0, -12)
            :addTo(node)
    else
        ui.newTTFLabel({font = "fonts/BLK-Suphanburi.ttf", text=title, size=24})
            :addTo(node)

        col = cc.c3b(0xe4, 0x53, 0x53)
    end

    local goods = self.data_.goodsInfo
    local str = "E2P"
    if #goods > 0 and goods[1] and goods[1].pmode and self.quickPayService_:isBluePay(tonumber(goods[1].pmode)) then
        str = "bluepay"
    end

    if #goods > 0 and goods[1] and goods[1].pmode and self.quickPayService_:isIabPay(tonumber(goods[1].pmode)) then
        str = "Google Play"
    end

    ui.newTTFLabel({text = bm.LangUtil.getText("GUIDE_PAY", "TIPS_PAY_METHOD", str), color = col, size = 17, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER, 50, 50)
        :addTo(self.bg_)
end

function GuidePayPopup:parseGoods(goods)
    if not goods then return nil end 
    local item = {}
    item.pid = goods.id
    item.id = goods.id
    item.price = goods.pamount
    item.title = goods.getname
    item.pnum = goods.pnum
    if tonumber(goods.ptype) == 7 then
        item.content = json.decode(goods.ext.content)
        item.pchips = item.content.chips
    end
    item.pamount = goods.pamount
    item.tag = ""
    item.pmode = goods.pmode
    item.bygood = goods
    item.discount = tonumber(goods.discount)
    item.category = "chips"
    item.skus = goods.skus or {}
    local payInfo = {}
    payInfo.merchantId = "4165"
    payInfo.priceId = tonumber(goods.pamount) 
    item.payInfo = payInfo

    return item
end

--直接进入房间 
function GuidePayPopup:onEnterWatchBtnListener_()
    if self.data_ and self.data_.ret == 0 then
        bm.EventCenter:dispatchEvent({name = nk.eventNames.ENTER_ROOM_WITH_DATA, data = {
            ip = self.data_.ip,
            port = self.data_.port,
            tid = self.data_.tid,
            isPlayNow = false
        }})
    end

    self:hide()
end

function GuidePayPopup:onMoreBtnListener_()
    local tab_ = 1
    if self.type_ > 100 then
        tab_ = 3
    end

    StorePopup.new(tab_):showPanel()

    self:hide()
end

function GuidePayPopup:purchaseResult_(succ, result)
    if succ then
        nk.userData.firstPay = false
        nk.OnOff:clearTimer(nk.OnOff.onsaleCountDownTimerId)
        nk.userData.onsaleCountDownTime = -1
        bm.EventCenter:dispatchEvent(nk.eventNames.ROOM_REFRESH_HDDJ_NUM)
        local userData = nk.userData
        --更新互动道具数量
        bm.HttpService.POST(
            {
                mod = "user", 
                act = "getUserFun"
            }, 
            function (data)
                userData.hddjNum = tonumber(data)
            end
        )

        local pid_ = ""
        if result and type(result) == "table" then
            if result.pid then
                pid_ = result.pid
            end
        else
            pid_ = result
        end
        if nk.userData.cache_guidepay_goodsid then
            if nk.userData.cache_guidepay_goodsid == 13 then
                nk.reportToDAdmin("jmtPreferentialOrder", "jmtPreferentialOrderSuccessed=goods" .. pid_)
            elseif nk.userData.cache_guidepay_goodsid == 1 then
                nk.reportToDAdmin("jmtFirstPay", "jmtFirstPayOrderSuccessed=goods2_" .. pid_)
            end
        end
    end
end

function GuidePayPopup:makePurchase(data)
    if data then
        local goods = self:parseGoods(data)
        if goods then
            self.quickPayService_:makePurchase(goods.pid, handler(self, self.purchaseResult_), goods)
        end
        if self.type_ == 13 then --优惠支付
            nk.userData.cache_guidepay_goodsid = 13
        elseif self.type_%2 == 1 and self.type_ < 7 then --首冲支付
            nk.userData.cache_guidepay_goodsid = 1
        else
            nk.userData.cache_guidepay_goodsid = -1
        end

        self:hide()
    end
end

function GuidePayPopup:onCloseBtnListener_()
    self:hide()
end

function GuidePayPopup:show()
    nk.PopupManager:addPopup(self)

    return self
end

function GuidePayPopup:hide()
    nk.PopupManager:removePopup(self)

    return self
end

function GuidePayPopup:onShowed()
end

function GuidePayPopup:onRemovePopup(func)
    if self.callback_ then
        self.callback_()
    end
    func()
end

function GuidePayPopup:onCleanup()
end

return GuidePayPopup