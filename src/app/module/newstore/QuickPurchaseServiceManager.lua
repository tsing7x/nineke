-- 
-- 快速支付
-- @author leoluo
--
local PURCHASE_TYPE = import(".PURCHASE_TYPE")
local Easy2PayApiPurchaseService = import(".services.Easy2PayApiPurchaseService")
local BluePayPurchaseService = import(".services.BluePayPurchaseService")
local BluePayIosPurchaseService = import(".services.BluePayIosPurchaseService")
local InAppBillingPurchaseService = import(".services.InAppBillingPurchaseService")
local PurchaseServiceManager = import(".PurchaseServiceManager")
local QuickPurchaseServiceManager = class("QuickPurchaseServiceManager")
local logger = bm.Logger.new("QuickPurchaseServiceManager")

function QuickPurchaseServiceManager:getInstance()
    if not QuickPurchaseServiceManager.instance_ then
        QuickPurchaseServiceManager.instance_ = QuickPurchaseServiceManager.new()
    end
    return QuickPurchaseServiceManager.instance_
end

function QuickPurchaseServiceManager:ctor()
	self.easy2pay_ = Easy2PayApiPurchaseService.new()
	if device.platform == "ios" then
		self.bluepay_ = BluePayIosPurchaseService.new()
		self.bluepay_:init_()
	else
		self.bluepay_ = BluePayPurchaseService.new()
		self.bluepay_:init_()
	end

	if device.platform == "android" then
		self.purchaseServiceManager = PurchaseServiceManager.getInstance()
		self.iabpay_ = self.purchaseServiceManager:getPurchaseService(100)
		if not self.iabpay_ then
			self.purchaseServiceManager.purchaseServices_[100] = InAppBillingPurchaseService.new()
			self.iabpay_ = self.purchaseServiceManager:getPurchaseService(100)
		end 
	end
end

function QuickPurchaseServiceManager:isBluePay(type_)
	if type_ then
		if type_ == PURCHASE_TYPE.BLUE_PAY or type_ == PURCHASE_TYPE.BLUE_PAY_IOS or type_ == PURCHASE_TYPE.BLUE_BANK_PAY then
			return true
		end
	end
	return false
end

function QuickPurchaseServiceManager:isIabPay(type_)
	if type_ then
		if type_ == 12 then
			return true
		end
	end
	return false
end

function QuickPurchaseServiceManager:makePurchase(pid, callback, goodsItem)
	if pid and goodsItem then
		if goodsItem.pmode and tonumber(goodsItem.pmode) == PURCHASE_TYPE.EASY_2_PAY_API then 
			self.easy2pay_:firstMakePurchase(pid, callback or handler(self, self.purchaseResult_), goodsItem)
		elseif goodsItem.pmode and (tonumber(goodsItem.pmode) == PURCHASE_TYPE.BLUE_PAY) or (tonumber(goodsItem.pmode) == PURCHASE_TYPE.BLUE_BANK_PAY) then 
			self.bluepay_:makePurchase(pid, callback, goodsItem)
		elseif goodsItem.pmode and tonumber(goodsItem.pmode) == PURCHASE_TYPE.BLUE_PAY_IOS then 
			self.bluepay_:makePurchase(pid, callback, goodsItem)
		elseif goodsItem.pmode and tonumber(goodsItem.pmode) == 12 then 
			if self.iabpay_ then
				self.iabpay_:makePurchase(pid, callback, goodsItem)
			else
				callback(false, pid)
			end
		else
			if callback then
				callback(false, pid)
			end
		end
	end
end

function QuickPurchaseServiceManager:firstMakePurchase(pid, callback, goodsItem)
	if pid and goodsItem then
		if goodsItem.pmode and tonumber(goodsItem.pmode) == PURCHASE_TYPE.EASY_2_PAY_API then 
			self.easy2pay_:firstMakePurchase(pid, callback or handler(self, self.purchaseResult_), goodsItem)
		elseif goodsItem.pmode and (tonumber(goodsItem.pmode) == PURCHASE_TYPE.BLUE_PAY) or (tonumber(goodsItem.pmode) == PURCHASE_TYPE.BLUE_BANK_PAY) then 
			self.bluepay_:firstMakePurchase(pid, callback, goodsItem)
		elseif goodsItem.pmode and tonumber(goodsItem.pmode) == PURCHASE_TYPE.BLUE_PAY_IOS then 
			self.bluepay_:firstMakePurchase(pid, callback, goodsItem)
		elseif goodsItem.pmode and tonumber(goodsItem.pmode) == 12 then 
			if self.iabpay_ then
				self.iabpay_:makePurchase(pid, callback, goodsItem)
			else
				callback(false, pid)
			end
		else
			if callback then
				callback(false, pid)
			end
		end
	end
end

return QuickPurchaseServiceManager