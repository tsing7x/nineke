--
-- Author: Jonah0608@gmail.com
-- Date: 2017-03-02 10:15:31
--

local PurchaseHelper = import("app.module.newstore.PurchaseHelper")
local AisFlowPurchaseService = class("AisFlowPurchaseService",import("app.module.newstore.PurchaseServiceBase"))
function AisFlowPurchaseService:ctor()
    AisFlowPurchaseService.super.ctor(self, "AisFlowPurchaseService")
    self.helper_ = PurchaseHelper.new("AisFlowPurchaseService")

    if device.platform == "android" then
        self.invokeJavaMethod_ = self:createJavaMethodInvoker("com/boomegg/cocoslib/aisflow/AisFlowBridge")
        self.invokeJavaMethod_("setLoginResultListener", {handler(self, self.onLoginResult_)}, "(I)V")
        self.invokeJavaMethod_("setPayResultListener", {handler(self, self.onPayResult_)}, "(I)V")
    elseif device.platform == "ios" then
    else
         self.invokeJavaMethod_ = function(method, param, sig)
            if method == "login" then
                self:onLoginResult_([[{"isSucc":"true", "privateId":"1233212344556"}]])
            end
            if method == "pay" then
                self:onPayResult_("succ")
            end
        end
    end
end

function AisFlowPurchaseService:init(config)
    self.config_ = config
    self.active_ = true
    self.isPurchasing_ = false
    self:configLoadHandler_(config.goods)
end

function AisFlowPurchaseService:autoDispose()
    self.products_ = nil
    self.active_ = false
    
    self.loadChipRequested_ = false
    self.loadPropRequested_ = false
    self.loadGoldRequested_ = false

    self.loadGoldCallback_ = nil
    self.loadChipCallback_ = nil
    self.loadPropCallback_ = nil

    self.purchaseCallback_ = nil
end


function AisFlowPurchaseService:loadChipProductList(callback)
    self.loadChipCallback_ = callback
    self.loadChipRequested_ = true
    self:loadProcess_()
end

-- function AisFlowPurchaseService:loadPropProductList(callback)
--     self.loadPropCallback_ = callback
--     self.loadPropRequested_ = true
--     self:loadProcess_()
-- end

-- function AisFlowPurchaseService:loadGoldProductList(callback)
--     self.loadGoldCallback_ = callback
--     self.loadGoldRequested_ = true
--     self:loadProcess_()
-- end

function AisFlowPurchaseService:loadProcess_()
    if not self.products_ then
        -- self.logger:debug("remote config is loading..")
        self:configLoadHandler_(self.config_.goods)
        self:invokeCallback_(4, false)
    elseif self.loadChipRequested_ or self.loadPropRequested_ or self.loadGoldRequested_ then
        self.helper_:updateDiscount(self.products_)
        self:invokeCallback_(1, true, self.products_.chips)
        self:invokeCallback_(2, true, self.products_.props)
        self:invokeCallback_(3, true, self.products_.golds)
    else
        self:invokeCallback_(4, false)
    end
end

function AisFlowPurchaseService:invokeCallback_(flag, isComplete, data)
    if self.loadChipRequested_ and self.loadChipCallback_ and (flag == 1 or flag == 4) then
        self.loadChipCallback_(self.config_, isComplete, data)
    end

    if self.loadPropRequested_ and self.loadPropCallback_ and (flag == 2 or flag == 4)  then
        self.loadPropCallback_(self.config_, isComplete, data)
    end
    
    if self.loadGoldRequested_ and self.loadGoldCallback_ and (flag == 3 or flag == 4)  then
        self.loadGoldCallback_(self.config_, isComplete, data)
    end
end

function AisFlowPurchaseService:configLoadHandler_(content)
    self.products_ = self.helper_:parseGoods(content,function(category, product)
            product.priceLabel = string.format("%dTHB", product.price)
            product.priceNum = product.price
            product.priceDollar = "THB"
        end)
    self:loadProcess_()
end

function AisFlowPurchaseService:makePurchase(pid, callback, goodsItem)
    self.logincallback_ = function(userName)
        self:makePurchase_(pid, callback, goodsItem,userName)
    end
    local args = {}
    local sig = "()V"
    self.invokeJavaMethod_("login", args,sig)
end

function AisFlowPurchaseService:makePurchase_(pid, callback, goodsItem,userName)
    local params = {}
    params.username = userName
    params.flow = goodsItem.bygood.flow
    self.isPurchasing_ = true
    self.helper_:generateOrderId(pid, goodsItem.pmode, params, function(succ,orderId,msg,data)
        if succ then
            local args = {goodsItem.bygood.flow}
            local sig = "(Ljava/lang/String;)V"
            self.invokeJavaMethod_("pay", args,sig)
        else
            if msg and msg ~= "" then
                self:toptip(msg)
            else
                self:toptip("get order fail")
            end
        end
    end)
end

function AisFlowPurchaseService:onLoginResult_(jsonString)
    local data = json.decode(jsonString)
    if data and data.isSucc and data.isSucc == "true" then
        if self.logincallback_ then
            self.logincallback_(data.privateId)
        end
    else
        self:toptip("login fail:" .. (data.userMessage or ""))
    end
    
end

function AisFlowPurchaseService:onPayResult_(result)
    local data = json.decode(jsonString)
    if data and data.isSucc and data.isSucc == "true" then
        self:toptip("กรุณารอรับ sms ยืนยันการซื้อแพคเกจ")
    else
        self:toptip("กรุณารอรับ sms ยืนยันการซื้อแพคเกจ")
    end
end

return AisFlowPurchaseService