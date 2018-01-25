--
-- Author: tony
-- Date: 2014-11-24 19:01:49
--
local PurchaseHelper = import("app.module.newstore.PurchaseHelper")
local Store = import("app.module.newstore.Store")

local InAppPurchasePurchaseService = class("InAppPurchasePurchaseService", import("app.module.newstore.PurchaseServiceBase"))

function InAppPurchasePurchaseService:ctor()
    InAppPurchasePurchaseService.super.ctor(self, "InAppPurchasePurchaseService")
    self.helper_ = PurchaseHelper.new("InAppBillingPurchaseService")
    self.store_ = Store.new()
    self.store_:addEventListener(Store.LOAD_PRODUCTS_FINISHED, handler(self, self.loadProductFinished_))
    self.store_:addEventListener(Store.TRANSACTION_PURCHASED, handler(self, self.transactionPurchased_))
    self.store_:addEventListener(Store.TRANSACTION_RESTORED, handler(self, self.transactionRestored_))
    self.store_:addEventListener(Store.TRANSACTION_FAILED, handler(self, self.transactionFailed_))
    self.store_:addEventListener(Store.TRANSACTION_UNKNOWN_ERROR, handler(self, self.transactionUnkownError_))
end

function InAppPurchasePurchaseService:init(config)
    self.active_ = true
    self.config_ = config
    self.isPurchasing_ = false
    self.isSupported_ = self.store_:canMakePurchases()
    if not self.products_ then
        self.logger:debug("remote config is loading..")
        self:configLoadHandler_(self.config_.goods)
    end
    self.store_:restore()
end

function InAppPurchasePurchaseService:autoDispose()
    self.products_ = nil
    self.active_ = false
    self.loadChipRequested_ = false
    self.loadPropRequested_ = false
    self.loadChipCallback_ = nil
    self.loadPropCallback_ = nil
    self.purchaseCallback_ = nil
    self.isProductPriceLoaded_ = false
    self.isProductRequesting_ = false
end

--callback(payType, isComplete, data)
function InAppPurchasePurchaseService:loadChipProductList(callback)
    self.loadChipCallback_ = callback
    self.loadChipRequested_ = true
    self:loadProcess_()
end

--callback(payType, isComplete, data)
function InAppPurchasePurchaseService:loadPropProductList(callback)
    self.loadPropCallback_ = callback
    self.loadPropRequested_ = true
    self:loadProcess_()
end

function InAppPurchasePurchaseService:loadProcess_()
    if not self.isSupported_ then
        self.logger:debug("iap not supported")
        self:invokeCallback_(3, true, bm.LangUtil.getText("STORE", "NOT_SUPPORT_MSG"))
    else
        if not self.products_ then
            self.logger:debug("remote config is loading..")
            self:configLoadHandler_(self.config_.goods)
        end
        if self.loadChipRequested_ or self.loadPropRequested_ then
            if self.products_ then
                if self.isProductPriceLoaded_ then
                    --更新折扣
                    self.helper_:updateDiscount(self.products_)
                    self:invokeCallback_(1, true, self.products_.chips)
                    self:invokeCallback_(2, true, self.products_.props)
                elseif not self.isProductRequesting_ then
                    self.isProductRequesting_ = true
                    self.logger:debug("start loading price...")
                    self:invokeCallback_(3, false)
                    self.store_:loadProducts(self.products_.skus)
                else
                    self:invokeCallback_(3, false)
                end
            else
                self:invokeCallback_(3, false)
            end
        else
            self:invokeCallback_(3, false)
        end
    end
end

function InAppPurchasePurchaseService:invokeCallback_(flag, isComplete, data)
    if self.loadChipRequested_ and self.loadChipCallback_ and (flag == 1 or flag == 3) then
        self.loadChipCallback_(self.config_, isComplete, data)
    end
    if self.loadPropRequested_ and self.loadPropCallback_ and (flag == 2 or flag == 3)  then
        self.loadPropCallback_(self.config_, isComplete, data)
    end
end

function InAppPurchasePurchaseService:configLoadHandler_(content)
    self.logger:debug("remote config file loaded.")
    self.products_ = self.helper_:parseGoods(content, function(category, json, product)
    end)

    self:loadProcess_()
end

function InAppPurchasePurchaseService:makePurchase(pid, callback, goodsItem)

    if self.isPurchasing_ then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "BUSY_PURCHASING_MSG"))
        return
    end

    self.purchaseCallback_ = callback
    local params = {}
    self.isPurchasing_ = true
     self.helper_:generateOrderId(pid, goodsItem.pmode, params, function(succ, orderId, msg, orderData)
            if succ then
                self.orderId_ = orderId
                local uid = tostring(nk.userData.uid) or ""
                local channel = tostring(nk.userData.channel) or ""

                local finalPid = goodsItem.skus
                self.store_:purchaseProduct(finalPid)
                self.isPurchasing_ = true
                self:restoreOrderInfo(pid,orderId,"chips")
            else
                self.isPurchasing_ = false
                self:clearOrderInfo()
                if msg and msg ~= "" then
                    nk.TopTipManager:showTopTip(msg)
                end
            end
        end)
end

function InAppPurchasePurchaseService:restoreOrderInfo(pid,orderId,ptype)
    local payInfoStr = pid .. "#" .. orderId .. "#" .. ptype
    nk.userDefault:setStringForKey(nk.cookieKeys.IOS_ORDER_INFO, payInfoStr)
    nk.userDefault:flush()
end

function InAppPurchasePurchaseService:clearOrderInfo()
    nk.userDefault:setStringForKey(nk.cookieKeys.IOS_ORDER_INFO, "")
    nk.userDefault:flush()
end

--OC to lua
function InAppPurchasePurchaseService:loadProductFinished_(evt)
    self.isProductRequesting_ = false
    local function getPriceLabel(prd)
        return luaoc.callStaticMethod(
                            "LuaOCBridge", 
                            "getPriceLabel", 
                            {
                                priceLocale = prd.priceLocale, 
                                price = prd.price, 
                            }
                        )
    end
    if evt.products and #evt.products > 0 then
        --更新价格
        for i, prd in ipairs(evt.products) do
            if self.products_.chips then
                for j, chip in ipairs(self.products_.chips) do
                    if prd.productIdentifier == chip.skus then
                        local ok, price = getPriceLabel(prd)
                        if ok then
                            chip.priceLabel = price
                        else
                            chip.priceLabel = prd.price
                        end
                        chip.priceNum = prd.price
                    end
                end
            end
            if self.products_.props then
                for j, prop in ipairs(self.products_.props) do
                    if prd.productIdentifier == prop.skus then
                        local ok, price = getPriceLabel(prd)
                        if ok then
                            prop.priceLabel = price
                        else
                            prop.priceLabel = prd.price
                        end
                        prop.priceNum = prd.price
                    end
                end
            end
            if self.products_.coins then
                for j, coin in ipairs(self.products_.coins) do
                    if prd.productIdentifier == coin.skus then
                        local ok, price = getPriceLabel(prd)
                        if ok then
                            coin.priceLabel = price
                        else
                            coin.priceLabel = prd.price
                        end
                        coin.priceNum = prd.price
                    end
                end
            end
        end
        self.isProductPriceLoaded_ = true
        self:loadProcess_()
        return
    end
    self:invokeCallback_(3, true, bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
end
--OC to lua
function InAppPurchasePurchaseService:transactionPurchased_(evt)
    nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "PURCHASE_SUCC_AND_DELIVERING"))
    self:delivery(evt.transaction, true)
end
--OC to lua
function InAppPurchasePurchaseService:transactionRestored_(evt)
    
    local payInfoStr = nk.userDefault:getStringForKey(nk.cookieKeys.IOS_ORDER_INFO)
    if payInfoStr and payInfoStr ~= "" then
        local payTb = string.split(payInfoStr,"#")
        if payTb and payTb[2] then
          self.orderId_ = payTb[2]
        end
    end
    self.isPurchasing_ = true
    self:delivery(evt.transaction, false)
end
--OC to lua
function InAppPurchasePurchaseService:transactionFailed_(evt)
    if self.purchaseCallback_ then
        self.purchaseCallback_(false, "AppPurchaseError")
    end
    self.isPurchasing_ = false
    self:clearOrderInfo()
end
--OC to lua
function InAppPurchasePurchaseService:transactionUnkownError_(evt)
    if self.purchaseCallback_ then
        self.purchaseCallback_(false, "AppPurchaseError")
    end
    self.isPurchasing_ = false
    self:clearOrderInfo()
end

function InAppPurchasePurchaseService:delivery(transaction, showMsg)
    local date = transaction.date
    local errorCode = transaction.errorCode
    local errorString = transaction.errorString
    local productIdentifier = transaction.productIdentifier
    local quantity = transaction.quantity
    local receipt = crypto.encodeBase64(transaction.receipt)
    local receiptVerifyMode = transaction.receiptVerifyMode
    local receiptVerifyStatus = transaction.receiptVerifyStatus
    local state = transaction.state
    local transactionIdentifier = transaction.transactionIdentifier

    local productId = string.gsub(productIdentifier,"%D","")
    productId = string.sub(productId, 2, string.len(productId))

    local params = {}
    params.pid = self.orderId_ or ""  -- 新流程不需要
    params.pdealno = transactionIdentifier
    params.receipt = receipt
    params.pmode = self.config_.pmode
    params.id = productId or ""
    params.mod = "Payment"
    params.act = "callClientPayment"
    params.siteuid = nk.userData.siteuid or ""
    params.uid = nk.userData.uid or ""


    if IS_SANDBOX then
        params.test = "test"
    end

    local retryLimit = 6
    local deliveryFunc
    deliveryFunc = function()
            bm.HttpService.POST(params, function(data)
                    local jsn = json.decode(data)
                    if jsn then
                        local ErrorCode = tonumber(jsn.ErrorCode)
                        if ErrorCode == 1 then
                            self.logger:debug("dilivery success, consume it")

                            self.store_:finishTransaction(transaction)
                            if showMsg then
                                nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "DELIVERY_SUCC_MSG"))
                                if self.purchaseCallback_ then
                                    self.purchaseCallback_(true)
                                end
                            end
                            self.isPurchasing_ = false
                            self:clearOrderInfo()

                        elseif ErrorCode == 0 then
                            --发过货的订单
                            if showMsg then
                                nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "DELIVERY_FAILED_MSG"))
                                if self.purchaseCallback_ then
                                    self.purchaseCallback_(false, "error")
                                end
                            end
                            self.store_:finishTransaction(transaction)
                            self.isPurchasing_ = false
                            self:clearOrderInfo()

                        elseif ErrorCode == 6 then
                            --交易号重复的订单
                            local realPid = jsn.realPid
                            local realStatus = jsn.realStatus
                            if 0 == realStatus then
                                --交易号在其他订单号使用过，但未曾发货
                               
                                if params and realPid and realPid ~= "" then
                                 --获取交易号所在的订单号重新请求发货
                                    params.pid = realPid

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
                                        self.isPurchasing_ = false
                                        self:clearOrderInfo()
                                    end
                                else
                                    self.store_:finishTransaction(transaction)
                                    if showMsg then
                                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "DELIVERY_FAILED_MSG"))
                                        if self.purchaseCallback_ then
                                            self.purchaseCallback_(false, "error")
                                        end
                                    end
                                    self.isPurchasing_ = false
                                    self:clearOrderInfo()
                                end
                            elseif 2 == realStatus then
                                --交易号在其他订单号使用过，且已发货,需要清除IAP记录
                                self.store_:finishTransaction(transaction)
                                self.isPurchasing_ = false
                                self:clearOrderInfo()
                            end
                        end
     
                    else
                        self.logger:debug("delivery failed => " .. json.encode(jsn))
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
                            self.isPurchasing_ = false
                            self:clearOrderInfo()
                        end
                    end
                end,
                function()
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

return InAppPurchasePurchaseService
