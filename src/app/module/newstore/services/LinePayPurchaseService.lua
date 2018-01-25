--
-- Author: Vanfo
-- Date: 2015-12-16 16:22:20
--
local PurchaseHelper = import("app.module.newstore.PurchaseHelper")
local LinePayPurchaseService = class("LinePayPurchaseService", import("app.module.newstore.PurchaseServiceBase"))

function LinePayPurchaseService:ctor()
    LinePayPurchaseService.super.ctor(self, "LinePayPurchaseService")
    self.helper_ = PurchaseHelper.new("LinePayPurchaseService")
end

function LinePayPurchaseService:init(config)
    self.config_ = config
    self.active_ = true
    self.isPurchasing_ = false

    if not self.products_ then
        self.logger:debug("remote config is loading..")
        self:configLoadHandler_(config.goods)
    end
end

function LinePayPurchaseService:autoDispose()
    self.products_ = nil
    self.active_ = false

    self.loadChipRequested_ = false
    self.loadPropRequested_ = false
    self.loadGoldRequested_ = false

    self.loadChipCallback_ = nil
    self.loadPropCallback_ = nil
    self.loadGoldCallback_ = nil

    self.purchaseCallback_ = nil

    if self.appForegroundListenerId_ then
        bm.EventCenter:removeEventListener(self.appForegroundListenerId_)
        self.appForegroundListenerId_ = nil
    end   
end

--callback(payType, isComplete, data)
function LinePayPurchaseService:loadChipProductList(callback)
    self.loadChipCallback_ = callback
    self.loadChipRequested_ = true
    self:loadProcess_()
end

--callback(payType, isComplete, data)
function LinePayPurchaseService:loadPropProductList(callback)
    self.loadPropCallback_ = callback
    self.loadPropRequested_ = true
    self:loadProcess_()
end

function LinePayPurchaseService:loadGoldProductList(callback)
    self.loadGoldCallback_ = callback
    self.loadGoldRequested_ = true
    self:loadProcess_()
end

function LinePayPurchaseService:makePurchase(pid, callback, goodsItem)
    self.purchaseCallback_ = callback

    self.helper_:generateOrderId(pid, goodsItem.pmode, nil, function(succ, orderId, msg, data)
        if succ then
            local URL = data.URL
            if URL and URL ~= "" then
                if not self.appForegroundListenerId_ then
                    self.appForegroundListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.APP_ENTER_FOREGROUND, handler(self, self.onOpenURLReturned_))
                end

                device.openURL(URL)
            end
        else
            if msg and msg ~= "" then
                nk.TopTipManager:showTopTip(msg)
            end
        end
    end,
    function()
    end)
end

function LinePayPurchaseService:onOpenURLReturned_()
    if self.appForegroundListenerId_ then
        bm.EventCenter:removeEventListener(self.appForegroundListenerId_)
        self.appForegroundListenerId_ = nil
    end

    if self.purchaseCallback_ then
        self.purchaseCallback_(true)
    end
end

--加载商品信息流程
function LinePayPurchaseService:loadProcess_()
    if not self.products_ then
        self.logger:debug("remote config is loading..")
        self:configLoadHandler_(self.config_.goods)
        self:invokeCallback_(4, false)
    elseif self.loadChipRequested_ or self.loadPropRequested_ or self.loadGoldRequested_ then
        self.helper_:updateDiscount(self.products_, self.config_)
        self:invokeCallback_(1, true, self.products_.chips)
        self:invokeCallback_(2, true, self.products_.props)
        self:invokeCallback_(3, true, self.products_.golds)
    else
        self:invokeCallback_(4, false)
    end
end

function LinePayPurchaseService:invokeCallback_(flag, isComplete, data)
    if self.loadChipRequested_ and self.loadChipCallback_ and (flag == 1 or flag == 4) then
        self.loadChipCallback_(self.config_, isComplete, data)
    end

    if self.loadPropRequested_ and self.loadPropCallback_ and (flag == 2 or flag == 4)  then
        self.loadPropCallback_(self.config_, isComplete, data)
    end

    if self.loadGoldRequested_ and self.loadGoldCallback_ and (flag == 3 or flag == 4) then
        self.loadGoldCallback_(self.config_, isComplete, data)
    end
end

function LinePayPurchaseService:configLoadHandler_(content)
    self.logger:debug("remote config file loaded.")
    self.products_ = self.helper_:parseGoods(content, function(category, json, product)
    end)

    self:loadProcess_()
end

return LinePayPurchaseService