--
-- Author: tony
-- Date: 2014-11-19 21:36:36
--
local PurchaseHelper = import("app.module.newstore.PurchaseHelper")
local InAppBillingPurchaseService = class("InAppBillingPurchaseService", import("app.module.newstore.PurchaseServiceBase"))

function InAppBillingPurchaseService:ctor()
    InAppBillingPurchaseService.super.ctor(self, "InAppBillingPurchaseService")

    self.helper_ = PurchaseHelper.new("InAppBillingPurchaseService")

    if device.platform == "android" then
        self.invokeJavaMethod_ = self:createJavaMethodInvoker("com/boomegg/cocoslib/iab/InAppBillingBridge")
        self.invokeJavaMethod_("setSetupCompleteCallback", {handler(self, self.onSetupComplete_)}, "(I)V")
        self.invokeJavaMethod_("setLoadProductsCompleteCallback", {handler(self, self.onLoadProductsComplete_)}, "(I)V")
        self.invokeJavaMethod_("setPurchaseCompleteCallback", {handler(self, self.onPurchaseComplete_)}, "(I)V")
        self.invokeJavaMethod_("setDeliveryMethod", {handler(self, self.doDelivery_)}, "(I)V")
        self.invokeJavaMethod_("setConsumeCompleteCallback", {handler(self, self.onConsumeComplete_)}, "(I)V")
    else
        self.invokeJavaMethod_ = function(method, param, sig)
            if method == "setup" then
                self.schedulerPool_:delayCall(function()
                    self:onSetupComplete_("true")
                end, 1)
            elseif method == "makePurchase" then
                self.schedulerPool_:delayCall(function()
                    self:onPurchaseComplete_([[{"sku":"com.boomegg.nineke.fakepid", "originalJson":"{}", "signature":"fakesignature"}]])
                end, 1)
            elseif method == "loadProductList" then
                self.schedulerPool_:delayCall(function()
                    self:onLoadProductsComplete_([[ [{"description":"ไอเทมใช้ได้120ครั้ง\n","price":"THB65.16","sku":"114998","title":"ไอเทม120ครั้ง (เก้าเกไทย)","type":"inapp","priceDollar":"฿"},{"description":"ไอเทมใช้ได้50ครั้ง\n","price":"THB32.00","sku":"114999","title":"ไอเทม50ครั้ง  (เก้าเกไทย)","type":"inapp","priceDollar":"฿"},{"description":"40M ชิป\n","price":"THB1,684.64","sku":"114991","title":"40M ชิป (เก้าเกไทย)","type":"inapp","priceDollar":"฿"},{"description":"600K ชิป\n","price":"THB32.00","sku":"114995","title":"600K ชิป (เก้าเกไทย)","type":"inapp","priceDollar":"฿"},{"description":"3.2M ชิป\n","price":"THB165.14","sku":"114994","title":"3.2M ชิป (เก้าเกไทย)","type":"inapp","priceDollar":"฿"}] ]])
                end, 1)
            end
        end
    end

    -- if device.platform == "android" or device.platform == "ios" then
    --     cc.analytics:start("analytics.UmengAnalytics")
    -- end
end

function InAppBillingPurchaseService:init(config)
    self.config_ = config
    self.active_ = true
    local success, ret = self.invokeJavaMethod_("isSetupComplete", {}, "()Z")
    if success then
        self.isSetupComplete_ = ret
    end
    success, ret = self.invokeJavaMethod_("isSupported", {}, "()Z")
    if success then
        self.isSupported_ = ret
    end
    if not self.isSetupComplete_ then
        self.isSetuping_ = true
        self.logger:debug("start setup..")
        self.invokeJavaMethod_("setup", {}, "()V")
    end

    if not self.products_ then
        self.logger:debug("remote config is loading..")
        self:configLoadHandler_(self.config_.goods)
    end
end

function InAppBillingPurchaseService:autoDispose()
    self.products_ = nil
    self.active_ = false
    self.isProductPriceLoaded_ = false  --确保每次重新load价格，触发发货检查
    self.isProductRequesting_ = false
    self.loadChipRequested_ = false
    self.loadPropRequested_ = false
    self.loadVipRequested_ = false
    self.loadGoldRequested_ = false
    self.loadChipCallback_ = nil
    self.loadPropCallback_ = nil
    self.loadVipCallback_ = nil
    self.loadGoldCallback_ = nil
    self.purchaseCallback_ = nil
    self.invokeJavaMethod_("delayDispose", {60}, "(I)V")
end

--callback(payType, isComplete, data)
function InAppBillingPurchaseService:loadChipProductList(callback)
    self.loadChipCallback_ = callback
    self.loadChipRequested_ = true
    self:loadProcess_()
end

--callback(payType, isComplete, data)
function InAppBillingPurchaseService:loadPropProductList(callback)
    self.loadPropCallback_ = callback
    self.loadPropRequested_ = true
    self:loadProcess_()
end

function InAppBillingPurchaseService:loadVipProductList(callback)
    self.loadVipCallback_ = callback
    self.loadVipRequested_ = true
    self:loadProcess_()
end

function InAppBillingPurchaseService:loadGoldProductList(callback)
    self.loadGoldCallback_ = callback
    self.loadGoldRequested_ = true
    self:loadProcess_()
end

function InAppBillingPurchaseService:makePurchase(pid, callback, goodsItem)
    self.purchaseCallback_ = callback
    local params = {}
    self.helper_:generateOrderId(pid, goodsItem.pmode, params, function(succ, orderId, msg, orderData)
            if succ then
                local uid = tostring(nk.userData.uid) or ""
                local channel = tostring(nk.userData.channel) or ""
                self.invokeJavaMethod_("makePurchase", {orderId, goodsItem.skus, uid, channel}, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
            else
                if msg and msg ~= "" then
                    self:toptip(msg)
                end
            end
        end)
end

--加载商品信息流程
function InAppBillingPurchaseService:loadProcess_()
    if not self.products_ then
        self.logger:debug("remote config is loading..")
        self:configLoadHandler_(self.config_.goods)
    end
    if self.isSetupComplete_ then
        if self.isSupported_ then
            if self.loadChipRequested_ or self.loadPropRequested_ or self.loadVipRequested_  or self.loadGoldRequested_ then
                if self.products_ then
                    if self.isProductPriceLoaded_ then
                        --更新折扣
                        self.helper_:updateDiscount(self.products_)
                        self:invokeCallback_(1, true, self.products_.chips)
                        self:invokeCallback_(2, true, self.products_.props)      
                        self:invokeCallback_(4, true, self.products_.vips)
                        self:invokeCallback_(5, true, self.products_.golds)
                    elseif not self.isProductRequesting_ then
                        self.isProductRequesting_ = true
                        local joinedSkuList = table.concat(self.products_.skus, ",")
                        self.logger:debug("start loading price...")
                        self:invokeCallback_(3, false)
                        self.invokeJavaMethod_("loadProductList", {joinedSkuList}, "(Ljava/lang/String;)V")
                    else
                        self:invokeCallback_(3, false)
                    end
                else
                    self:invokeCallback_(3, false)
                end
            end
        else
            self.logger:debug("iab not supported")
            self:invokeCallback_(3, true, bm.LangUtil.getText("STORE", "NOT_SUPPORT_MSG"))
        end
    elseif self.isSetuping_ then
        self.logger:debug("setuping ...")
        self:invokeCallback_(3, false)
    else
        self.isSetuping_ = true
        self.logger:debug("start setup..")
        self:invokeCallback_(3, false)
        self.invokeJavaMethod_("setup", {}, "()V")
    end
end

--Java call lua
function InAppBillingPurchaseService:onSetupComplete_(isSupported)
    self.logger:debug("setup complete.")
    self.isSetuping_ = false
    self.isSetupComplete_ = true
    self.isSupported_ = (isSupported == "true")
    self.logger:debug("isSupported raw:", isSupported)
    self:loadProcess_()
end

--Java call lua
function InAppBillingPurchaseService:onLoadProductsComplete_(jsonString)
    self.logger:debug("price load complete -> " .. jsonString)
    local success = (jsonString ~= "fail")
    self.isProductRequesting_ = false
    if success then
        local products = json.decode(jsonString)
        --更新价格
        if products and self.products_ then
            for i, prd in ipairs(products) do
                self.invokeJavaMethod_("consume", {prd.sku}, "(Ljava/lang/String;)V")
                if self.products_.chips then
                    for j, chip in ipairs(self.products_.chips) do
                        if prd.sku == chip.skus then
                            chip.priceLabel = prd.price
                            if prd.priceNum and prd.priceDollar then
                                chip.priceNum = prd.priceNum
                                chip.priceDollar = prd.priceDollar
                            end
                        end
                    end
                end
                if self.products_.props then
                    for j, prop in ipairs(self.products_.props) do
                        if prd.sku == prop.skus then
                            prop.priceLabel = prd.price
                            if prd.priceNum and prd.priceDollar then
                                prop.priceNum = prd.priceNum
                                prop.priceDollar = prd.priceDollar
                            end
                        end
                    end
                end
                if self.products_.coins then
                    for j, coin in ipairs(self.products_.coins) do
                        if prd.sku == coin.skus then
                            coin.priceLabel = prd.price
                            if prd.priceNum and prd.priceDollar then
                                coin.priceNum = prd.priceNum
                                coin.priceDollar = prd.priceDollar
                            end
                        end
                    end
                end
                if self.products_.vips then
                    for j, vip in ipairs(self.products_.vips) do
                        if prd.sku == vip.skus then
                            vip.priceLabel = prd.price
                            if prd.priceNum and prd.priceDollar then
                                vip.priceNum = prd.priceNum
                                vip.priceDollar = prd.priceDollar
                            end
                        end
                    end
                end
            end
            self.isProductPriceLoaded_ = true
            self:loadProcess_()
            return
        end
    end
    self:invokeCallback_(3, true, bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
end

--Java call lua
function InAppBillingPurchaseService:onPurchaseComplete_(jsonString)
    self.logger:debug("purchase complete -> ", jsonString)
    local success = (string.sub(jsonString, 1, 4) ~= "fail")

    if success then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "PURCHASE_SUCC_AND_DELIVERING"))
        local json = json.decode(jsonString)
        self:delivery(json.sku, json.originalJson, json.signature, true)
    else
        local reportParams = {}
        reportParams.mod = "Report"
        reportParams.act = "upload"
        reportParams.uid = nk.userData.uid
        reportParams.time = os.time()
        reportParams.type = 0
        reportParams.msg = jsonString

        if string.sub(jsonString, 6) == "canceled" then
            --todo
            -- if device.platform == "android" or device.platform == "ios" then
            --     cc.analytics:doCommand{command = "eventCustom", args = {eventId = "checkout_error_report", attributes = "error,ret[cancel]:" .. jsonString},
            --         label = "checkout pay Wrong RET.cancel"
            --     }
            -- end
            reportParams.type = 1

            nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "PURCHASE_CANCELED_MSG"))
            if self.purchaseCallback_ then
                self.purchaseCallback_(false, "canceled")
            end
        else
            -- if device.platform == "android" or device.platform == "ios" then
            --     cc.analytics:doCommand{command = "eventCustom", args = {eventId = "checkout_error_report", attributes = "error,ret[error]:" .. jsonString},
            --         label = "checkout pay Wrong RET.error"
            --     }
            -- end
            reportParams.type = 0

            nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "PURCHASE_FAILED_MSG"))
            if self.purchaseCallback_ then
                self.purchaseCallback_(false, "error")
            end
        end

        -- bm.HttpService.POST(reportParams, function(retData)
        --     -- dump(retData, "bm.HttpService.POST[.].retData :=============")
        -- end, function(errData)
        --     -- body
        --     dump(errData, "bm.HttpService.POST[.].errData :=============")
        -- end)
    end
end

--Java call lua
function InAppBillingPurchaseService:doDelivery_(jsonString)
    self.logger:debug("doDelivery_ ", jsonString)
    local json = json.decode(jsonString)
    self:delivery(json.sku, json.originalJson, json.signature, false)
    nk.userData.marketData.showCheckout = 0
end

--Java call lua
function InAppBillingPurchaseService:onConsumeComplete_(jsonString)
    self.logger:debug("onConsumeComplete_", jsonString)
end

function InAppBillingPurchaseService:invokeCallback_(flag, isComplete, data)
    if self.loadChipRequested_ and self.loadChipCallback_ and (flag == 1 or flag == 3) then
        self.loadChipCallback_(self.config_, isComplete, data)
    end
    if self.loadPropRequested_ and self.loadPropCallback_ and (flag == 2 or flag == 3)  then
        self.loadPropCallback_(self.config_, isComplete, data)
    end    
    if self.loadVipRequested_ and self.loadVipCallback_ and (flag == 4 or flag == 3)  then
        self.loadVipCallback_(self.config_, isComplete, data)
    end
    if self.loadGoldRequested_ and self.loadGoldCallback_ and (flag == 5 or flag == 3)  then
        self.loadGoldCallback_(self.config_, isComplete, data)
    end
end

function InAppBillingPurchaseService:configLoadHandler_(content)
    self.logger:debug("remote config file loaded.")
    self.products_ = self.helper_:parseGoods(content, function(category, product)
    end)
    self.isProductPriceLoaded_ = false
    self:loadProcess_()
end

function InAppBillingPurchaseService:delivery(sku, receipt, signature, showMsg)
    local retryLimit = 6
    local deliveryFunc = nil
    local params = {}
    params.mod = "Payment"
    params.act = "callClientPayment"
    params.pmode = "12"
    params.siteuid = nk.userData.siteuid or ""
    params.uid = nk.userData.uid or ""
    params.signedData = crypto.encodeBase64(receipt)
    params.signature = signature
    deliveryFunc = function()
        bm.HttpService.POST(params, function(data)
            local json = json.decode(data)
            if json and json.RET == 0 then
                self.logger:debug("dilivery success, consume it")
                self.invokeJavaMethod_("consume", {sku}, "(Ljava/lang/String;)V")
                if showMsg then
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "DELIVERY_SUCC_MSG"))
                    if self.purchaseCallback_ then
                        self.purchaseCallback_(true)
                    end
                end
            else
                self.logger:debug("delivery failed => " .. data)
                retryLimit = retryLimit - 1
                if retryLimit > 0 then
                    self.schedulerPool_:delayCall(function()
                        deliveryFunc()
                    end, 10)
                else
                    if showMsg then
                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "DELIVERY_FAILED_MSG"))
                        if self.purchaseCallback_ then
                            self.purchaseCallback_(false, "error")
                        end
                    end
                end
            end
        end, function() 
            retryLimit = retryLimit - 1
            if retryLimit > 0 then
                self.schedulerPool_:delayCall(function()
                    deliveryFunc()
                end, 10)
            else
                if showMsg then
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "DELIVERY_FAILED_MSG"))
                    if self.purchaseCallback_ then
                        self.purchaseCallback_(false, "error")
                    end
                end
            end
        end)
    end
    deliveryFunc()
end

return InAppBillingPurchaseService
