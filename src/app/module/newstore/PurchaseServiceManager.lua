--
-- Author: tony
-- Date: 2014-11-17 16:44:39
--
local InAppBillingPurchaseService   = import(".services.InAppBillingPurchaseService")
local InAppPurchasePurchaseService  = import(".services.InAppPurchasePurchaseService")
local BluePayPurchaseService        = import(".services.BluePayPurchaseService")
local MolPurchaseService            = import(".services.MolPurchaseService")
local Easy2PayApiPurchaseService    = import(".services.Easy2PayApiPurchaseService")
local BluePayIosPurchaseService     = import(".services.BluePayIosPurchaseService")
local ByCardPurchaseService         = import(".services.ByCardPurchaseService")
local LinePayPurchaseService        = import(".services.LinePayPurchaseService")
local AisFlowPurchaseService        = import(".services.AisFlowPurchaseService")
local BindPhonePurchaseService      = import(".services.BindPhonePurchaseService")

local PURCHASE_TYPE = import(".PURCHASE_TYPE")

local PurchaseServiceManager = class("PurchaseServiceManager")

function PurchaseServiceManager:getInstance()
    if not PurchaseServiceManager.instance_ then
        PurchaseServiceManager.instance_ = PurchaseServiceManager.new()
    end
    return PurchaseServiceManager.instance_
end

function PurchaseServiceManager:ctor()
    self.availablePurchaseService_ = {}
    self.purchaseServices_ = {}
    if device.platform == "android" then
        self.availablePurchaseService_[PURCHASE_TYPE.IN_APP_BILLING] = InAppBillingPurchaseService
        -- self.availablePurchaseService_[PURCHASE_TYPE.MOL_TRUE_MONEY] = MolPurchaseService
        -- self.availablePurchaseService_[PURCHASE_TYPE.MOL_Z_CARD] = MolPurchaseService
        -- self.availablePurchaseService_[PURCHASE_TYPE.MOL_POINT_CARD] = MolPurchaseService
        -- self.availablePurchaseService_[PURCHASE_TYPE.MOL_12_CALL] = MolPurchaseService
        -- self.availablePurchaseService_[PURCHASE_TYPE.EASY_2_PAY_API] = Easy2PayApiPurchaseService
        -- self.availablePurchaseService_[PURCHASE_TYPE.BLUE_PAY] = BluePayPurchaseService
        -- self.availablePurchaseService_[PURCHASE_TYPE.BLUE_BANK_PAY] = BluePayPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.BY_CARD] = ByCardPurchaseService
        -- self.availablePurchaseService_[PURCHASE_TYPE.LINE_PAY] = LinePayPurchaseService
        -- self.availablePurchaseService_[PURCHASE_TYPE.AIS_FLOW] = AisFlowPurchaseService
        -- self.availablePurchaseService_[PURCHASE_TYPE.BINDPHONE] = BindPhonePurchaseService
    elseif device.platform == "ios" then
        self.availablePurchaseService_[PURCHASE_TYPE.IN_APP_PURCHASE] = InAppPurchasePurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.MOL_TRUE_MONEY] = MolPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.MOL_Z_CARD] = MolPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.MOL_POINT_CARD] = MolPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.MOL_12_CALL] = MolPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.EASY_2_PAY_API] = Easy2PayApiPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.BLUE_PAY_IOS] = BluePayIosPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.BLUE_BANK_PAY] = BluePayIosPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.BY_CARD] = ByCardPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.LINE_PAY_IOS] = LinePayPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.BINDPHONE] = BindPhonePurchaseService
    elseif device.platform == "windows" then
        self.availablePurchaseService_[PURCHASE_TYPE.IN_APP_BILLING] = InAppBillingPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.IN_APP_PURCHASE] = InAppPurchasePurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.MOL_TRUE_MONEY] = MolPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.MOL_Z_CARD] = MolPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.MOL_POINT_CARD] = MolPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.MOL_12_CALL] = MolPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.EASY_2_PAY_API] = Easy2PayApiPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.BLUE_PAY] = BluePayPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.BLUE_BANK_PAY] = BluePayPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.BLUE_PAY_IOS] = BluePayIosPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.BLUE_BANK_PAY] = BluePayIosPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.BY_CARD] = ByCardPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.LINE_PAY] = LinePayPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.LINE_PAY_IOS] = LinePayPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.AIS_FLOW] = AisFlowPurchaseService
        self.availablePurchaseService_[PURCHASE_TYPE.BINDPHONE] = BindPhonePurchaseService
    end
end

function PurchaseServiceManager:isServiceAvailable(serviceId)
    return self.availablePurchaseService_[serviceId]
end

function PurchaseServiceManager:init(payConfig, isLoadData)
    for i, config in ipairs(payConfig) do
        local PurchaseServiceClass = self.availablePurchaseService_[config.id]
        local purchaseServiceInstance_ = self.purchaseServices_[config.id]
        if PurchaseServiceClass then
            if not purchaseServiceInstance_ then
                purchaseServiceInstance_ = PurchaseServiceClass.new()
                self.purchaseServices_[config.id] = purchaseServiceInstance_
            end
            purchaseServiceInstance_:init(config, isLoadData)
        end
    end
end

function PurchaseServiceManager:getPurchaseService(serviceId)
    return self.purchaseServices_[serviceId]
end

function PurchaseServiceManager:autoDispose()
    for id, service in pairs(self.purchaseServices_) do
        service:autoDispose()
    end
end

return PurchaseServiceManager
