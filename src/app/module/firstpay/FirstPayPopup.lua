--
-- Author: KevinYu
-- Date: 2016-11-03 16:27:06
-- 首冲礼包

local QuickPurchaseServiceManager = import("app.module.newstore.QuickPurchaseServiceManager")
local StorePopup = import("app.module.newstore.StorePopup")

local FirstPayPopup = class("FirstPayPopup", function ()
    return display.newNode()
end)

local WIDTH, HEIGHT = 798, 428

local FirstPayId = 31001
local FirstPayServiceId = "4165"
--1.进入房间时弹首付礼包 3.坐下时弹首付礼包 5.参赛时弹首付礼包 三种情况以前在GuidePayPopup创建
--现在统一由FirstPayPopup创建
function FirstPayPopup:ctor(data)
    self:setNodeEventEnabled(true)

    self.roomData_ = data
    self.goodsItem = {}

    self:setupView()

    self.quickPayService_ = QuickPurchaseServiceManager.getInstance()
end

function FirstPayPopup:setupView()
    local node = display.newScale9Sprite("#transparent.png", 0, 0, cc.size(WIDTH, HEIGHT)):addTo(self)
    node:setTouchEnabled(true)
    node:setTouchSwallowEnabled(true)

    local bg = display.newSprite("#first_pay_bg.png"):addTo(self)

    cc.ui.UIPushButton.new({normal = "#pop_common_close_normal.png", pressed = "#pop_common_close_pressed.png"})
        :onButtonClicked(buttontHandler(self, self.onCloseBtnListener_))
        :pos(WIDTH - 55, HEIGHT - 55)
        :addTo(bg)

    display.newSprite("#first_pay_title.png")
        :align(display.TOP_CENTER, WIDTH/2, HEIGHT - 20)
        :addTo(bg)

    --价格描述
    -- self.priceTips_ = ui.newTTFLabel({text = "",  size = 20, align = ui.TEXT_ALIGN_CENTER})
    --     :pos(308, 15)
    --     :addTo(bg)

    self.product_ = ui.newBMFontLabel({text = "", font = "fonts/first_pay_name.fnt"})
        :pos(WIDTH/2, HEIGHT/2 + 75)
        :addTo(bg)

    self.price_ = ui.newBMFontLabel({text = "", font = "fonts/first_pay_price.fnt"})
        :pos(WIDTH/2, HEIGHT/2 - 20)
        :addTo(bg)
        

    self.buyBtn_ = cc.ui.UIPushButton.new({normal = "#first_pay_buy_btn_normal.png", pressed = "#first_pay_buy_btn_pressed.png"},{scale9 = true})
        :setButtonSize(260, 76)
        :onButtonPressed(function()
            self.btnText_:setSpriteFrame(display.newSpriteFrame("first_pay_btn_txt_pressed.png"))
        end)
        :onButtonRelease(function()
            self.btnText_:setSpriteFrame(display.newSpriteFrame("first_pay_btn_txt_normal.png"))
        end)
        :onButtonClicked(handler(self, self.onBuyBtnListener_))
        :pos(WIDTH/2, 85)
        :addTo(bg)
    self.buyBtn_:setButtonEnabled(false)

    self.btnText_ = display.newSprite("#first_pay_btn_txt_normal.png")
        :pos(0, 5)
        :addTo(self.buyBtn_)

    bm.HttpService.POST({
        mod = "Payment",
        act = "getFirstPaygoods"
    },function(data)
        local jsnData = json.decode(data)
        if jsnData and #jsnData > 0 then
            nk.userData.firstpayData = jsnData

            self:parseGoods(jsnData[1])
        end
    end,
    function()
    end)

    nk.reportToDAdmin("jmtFirstPay", "jmtFirstPayOrder=goods")
end

function FirstPayPopup:parseGoods(goods)
    local item = {}
    item.pid = goods.id
    item.id = goods.id
    item.price = goods.pamount
    item.title = goods.getname
    item.pnum = goods.pnum
    if tonumber(goods.ptype) == 7 then
        item.content = json.decode(goods.ext.content)
        item.pchips = item.content.chips
        item.propNum = item.content.funFace
    end
    item.pamount = goods.pamount
    item.tag = ""
    item.pmode = goods.pmode
    item.bygood = goods
    item.skus = goods.skus or ""
    item.discount = 3
    item.category = "chips"
    local payInfo = {}
    payInfo.merchantId = "4165"
    payInfo.priceId = tonumber(goods.pamount) 
    item.payInfo = payInfo

    self.goodsItem = item
    if self.buyBtn_ then
        self.buyBtn_:setButtonEnabled(true)
    end

    --设置商品内容和价格 C：筹码 D：道具 T：价格
    local str = bm.formatBigNumber(item.pchips) .. "C+" .. item.propNum .. "D"
    self.product_:setString(str)
    self.price_:setString(item.price .. "T")

    -- local tips = bm.LangUtil.getText("FIRST_PAY", "PRICE_TIPS", item.price)
    -- self.priceTips_:setString(tips)
end

function FirstPayPopup:purchaseResult_(succ, result)
    if succ then
        nk.userData.firstPay = false
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
        nk.reportToDAdmin("jmtFirstPay", "jmtFirstPayOrderSuccessed=goods" .. pid_)
    end
end

function FirstPayPopup:onBuyBtnListener_()
    if self.goodsItem then
        if nk.userData.isConfirmFirstpay == 1 then
            self.quickPayService_:makePurchase(self.goodsItem.pid, handler(self, self.purchaseResult_), self.goodsItem)
        else
            self.quickPayService_:firstMakePurchase(self.goodsItem.pid, handler(self, self.purchaseResult_), self.goodsItem)
        end

        self:hide()
    end
end

function FirstPayPopup:onCloseBtnListener_()
    self:hide()
end

function FirstPayPopup:show()
    nk.PopupManager:addPopup(self)

    return self
end

function FirstPayPopup:hide()
    nk.PopupManager:removePopup(self)

    return self
end

function FirstPayPopup:onShowed()
end

function FirstPayPopup:onRemovePopup(func)
    if self.roomData_ and self.roomData_.ret == 0 then
        bm.EventCenter:dispatchEvent({name = nk.eventNames.ENTER_ROOM_WITH_DATA, data = {
            ip = self.roomData_.ip,
            port = self.roomData_.port,
            tid = self.roomData_.tid,
            dice = self.roomData_.dice or 0,
            isPlayNow = false
        }})
    end

    func()
end

function FirstPayPopup:onCleanup()
end

return FirstPayPopup