--
-- Author: TsingZhang@boyaa.com
-- Date: 2017-12-14 15:34:04
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: GodSdkCheckoutPurchaseService.lua Created By Tsing7x.
--

local purchaseHelper = import("app.module.newstore.PurchaseHelper")
local purchaseServiceBase = import("app.module.newstore.PurchaseServiceBase")

local GodSdkCheckoutPurchaseService = class("GodSdkCheckoutPurchaseService", purchaseServiceBase)

function GodSdkCheckoutPurchaseService:ctor()
	-- body
	dump("GodSdkCheckoutPurchaseService:ctor Called!")

	GodSdkCheckoutPurchaseService.super.ctor(self, "GodSdkCheckoutPurchaseService")

	self.helper_ = purchaseHelper.new("GodSdkCheckoutPurchaseService")
	if device.platform == "android" then
		dump("Enter platform judgement!")
        self.invokeJavaMethod_ = self:createJavaMethodInvoker("com/boomegg/cocoslib/godsdk/GodSdkBridge")

        dump("invokeJavaMethod Created!")
        self.invokeJavaMethod_("setIabPurchaseCallback", {handler(self, self.onPurchaseResultCallback_)}, "(I)V")

        dump("invokeJavaMethod setIabPurchaseCallback binding!")
        self.invokeJavaMethod_("setIabQueryUnfinishedIapCallback", {handler(self, self.onIabQueryUnfinishedIAPCallback_)}, "(I)V")
        
        dump("invokeJavaMethod setIabQueryUnfinishedIapCallback binding!")
        self.invokeJavaMethod_("setIabLoadProductListCallback", {handler(self, self.onIabLoadProductCallback_)}, "(I)V")
    
        dump("invokeJavaMethod setIabLoadProductListCallback binding!")
    else
        self.invokeJavaMethod_ = function(method, param, sig)
        	if method == "makePurchase" then
            	self:onPurchaseResultCallback_([[{"ret":"0", "pmode":"12", "signedData":"sfklj14532adw55920(^%$#^", "signature":"hda&*hbhh&/alkkl*dhjjabjd156422"}]])
            end

            if method == "iabConsumeProduct" then
            	--todo
            	local productId = param[1]
            	dump("Product Id : " .. productId .. "Consume Ret Succ!")
            end

            if method == "iabQueryUnfinishedIAP" then
            	--todo
            	self:onIabQueryUnfinishedIAPCallback_([[{"ret":"0", "pmode":"12", "signedData":"sfklj14sda2adw55920(^%$#^", "signature":"hda&*hbhh&/alkkl*dhjaws156422"}]])
            end
        end
    end
end

function GodSdkCheckoutPurchaseService:init(config)
	-- body
	self.config_ = config
	self.active_ = true
    self.isPurchasing_ = false

    if not self.products_ then
    	--todo
    	self:configLoadHandler_(config.goods)
    end
end

function GodSdkCheckoutPurchaseService:invokeCallback_(flag, isComplete, data)
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

function GodSdkCheckoutPurchaseService:configLoadHandler_(productContent)
	-- body
	self.products_ = self.helper_:parseGoods(productContent, function(category, product)
            -- product.priceLabel = string.format("%dTHB", product.price)
            -- product.priceNum = product.price
            -- product.priceDollar = "THB"
        end)
	self.isProductPriceLoaded_ = false
    self:loadProcess_()
end

function GodSdkCheckoutPurchaseService:loadProcess_()
	-- body
	if not self.products_ then
		dump("Remote Config Is Loading..")
        self:configLoadHandler_(self.config_.goods)
        self:invokeCallback_(4, false)
    elseif self.loadChipRequested_ or self.loadPropRequested_ or self.loadVipRequested_ or self.loadGoldRequested_ then
        if self.isProductPriceLoaded_ then
        	--todo
        	self.helper_:updateDiscount(self.products_)
	        self:invokeCallback_(1, true, self.products_.chips)
	        self:invokeCallback_(2, true, self.products_.props)      
	        self:invokeCallback_(4, true, self.products_.vips)
	        self:invokeCallback_(5, true, self.products_.golds)
        elseif not self.isProductLoading_ then
        	--todo
        	self.isProductLoading_ = true
        	local joinedSkuList = table.concat(self.products_.skus, ",")
            self:invokeCallback_(3, false)
            self.invokeJavaMethod_("iabLoadProductList", {joinedSkuList}, "(Ljava/lang/String;)V")
        else
        	self:invokeCallback_(3, false)
        end
        
    else
        self:invokeCallback_(3, false)
    end

    self:queryUnfinishedIap()
end

function GodSdkCheckoutPurchaseService:doDelivery_(jsonStr)
	-- body
    local json = json.decode(jsonStr)
    dump(json, "GodSdkCheckoutPurchaseService:doDelivery_.json :")

    self:delivery(json.originalJson, json.signature, false)
    nk.userData.marketData.showCheckout = 0
end

function GodSdkCheckoutPurchaseService:delivery(receipt, signature, showMsg)
	-- body
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
            dump(json, "GodSdkCheckoutPurchaseService:delivery[Payment.callClientPayment].retData :============")

            if json and json.RET == 0 then
                dump("dilivery success, consume it")

                self:consumeProduct(self.productId_)
                -- self.invokeJavaMethod_("consume", {sku}, "(Ljava/lang/String;)V")
                if showMsg then
                	self:topTip(bm.LangUtil.getText("STORE", "DELIVERY_SUCC_MSG"))
                    if self.purchaseCallback_ then
                        self.purchaseCallback_(true)
                    end
                end
            else
                dump("delivery failed => " .. data)
                retryLimit = retryLimit - 1
                if retryLimit > 0 then
                    self.schedulerPool_:delayCall(function()
                        deliveryFunc()
                    end, 10)
                else
                    if showMsg then
                    	self:topTip(bm.LangUtil.getText("STORE", "DELIVERY_FAILED_MSG"))
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
                	self:topTip(bm.LangUtil.getText("STORE", "DELIVERY_FAILED_MSG"))
                    if self.purchaseCallback_ then
                        self.purchaseCallback_(false, "error")
                    end
                end
            end
        end)
    end
    deliveryFunc()
end

function GodSdkCheckoutPurchaseService:loadChipProductList(callback)
    self.loadChipCallback_ = callback
    self.loadChipRequested_ = true
    self:loadProcess_()
end

function GodSdkCheckoutPurchaseService:loadPropProductList(callback)
    self.loadPropCallback_ = callback
    self.loadPropRequested_ = true
    self:loadProcess_()
end

function GodSdkCheckoutPurchaseService:loadVipProductList(callback)
    self.loadVipCallback_ = callback
    self.loadVipRequested_ = true
    self:loadProcess_()
end

function GodSdkCheckoutPurchaseService:loadGoldProductList(callback)
    self.loadGoldCallback_ = callback
    self.loadGoldRequested_ = true
    self:loadProcess_()
end

function GodSdkCheckoutPurchaseService:makePurchase(pid, callback, goodsItem)
	dump(goodsItem, "GodSdkCheckoutPurchaseService:makePurchase[pid :" .. pid .. "].goodsItem :===============")

	self.purchaseCallback_ = callback
	self.helper_:generateOrderId(pid, goodsItem.pmode, {}, function(succ, orderId, msg, orderData)
		-- body
		if succ then
			--todo
			local payParam = {
				productId			= tostring(orderData.PAYCONFID or ""),
				orderId			= tostring(orderId or ""),
				pmode				= tostring(goodsItem.pmode or 12)
			}

			self.productId_ = payParam.productId

		    local args = {json.encode(payParam)}
		    local sig = "(Ljava/lang/String;)V"
		    self.invokeJavaMethod_("iabPurchase", args, sig)
		else
			dump("GenerateOrderId Ret Wrong!")

			if msg and string.len(msg) > 0 then
                self:toptip(msg)
            end
		end
	end)
end

function GodSdkCheckoutPurchaseService:consumeProduct(productId)
	-- body
	local args = {productId}
	local sig = "(Ljava/lang/String;)V"
	self.invokeJavaMethod_("iabConsumeProduct", args, sig)
end

function GodSdkCheckoutPurchaseService:queryUnfinishedIap()
	-- body
	local args = {}
	local sig = "()V"
	self.invokeJavaMethod_("iabQueryUnfinishedIAP", args, sig)
end

function GodSdkCheckoutPurchaseService:onIabLoadProductCallback_(resultJsonArray)
	-- body
	dump(resultJsonArray, "GodSdkCheckoutPurchaseService:onIabLoadProductCallback_.resultJsonArray :================")
	self.isProductLoading_ = false
	local products = json.decode(resultJsonArray)

	if products and self.products_ then
		--todo
		for i, prd in ipairs(products) do
			if self.products_.chips then
				--todo
				for j, chip in ipairs(self.products_.chips) do
					if prd.sku == chip.skus then
						--todo
						if prd.price then
							--todo
							chip.priceNum = prd.price
						end
					end
				end
			end

			if self.products_.props then
				--todo
				for j, prop in ipairs(self.products_.props) do
					if prd.sku == prop.skus then
						--todo
						if prd.price then
							--todo
							prop.priceNum = prd.price
						end
					end
				end
			end

			if self.products_.coins then
				--todo
				for j, cion in ipairs(self.products_.coins) do
					if prd.sku == cion.skus then
						--todo
						if prd.price then
							--todo
							cion.priceNum = prd.price
						end
					end
				end
			end

			if self.products_.vips then
				--todo
				for j, vip in ipairs(self.products_.vips) do
					if prd.sku == vip.skus then
						--todo
						if prd.price then
							--todo
							vip.priceNum = prd.price
						end
					end
				end

				self.isProductPriceLoaded_ = true
	            self:loadProcess_()

	            return
			end
		end
	end

	self:invokeCallback_(3, true, bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
end

function GodSdkCheckoutPurchaseService:onPurchaseResultCallback_(resultJson)
	-- body
	local data = json.decode(resultJson)

	dump(data, "GodSdkCheckoutPurchaseService:onPurchaseResultCallback_.data :==============")

	if data then
		--todo
		if data.ret and tonumber(data.ret) == 0 then
			--todo
			self:toptip(bm.LangUtil.getText("STORE", "PURCHASE_SUCC_AND_DELIVERING"))
			self:delivery(data.signedData or "", data.signature or "", true)
		else
			self.productId_ = nil

			if self.purchaseCallback_ then
                self.purchaseCallback_(false, "faild")
            end
			self:toptip(bm.LangUtil.getText("STORE", "PURCHASE_FAILED_MSG"))
		end
	else
		self.productId_ = nil

		dump(resultJson, "PurchaseResult Ret Json Analysis Wrong!With Str :==========")
	end
end

function GodSdkCheckoutPurchaseService:onIabQueryUnfinishedIAPCallback_(resultJson)
	-- body
	local data = json.decode(resultJson)

	if data then
		--todo
		if data.ret and tonumber(data.ret) == 0 then
			--todo
			dump("QueryUnfinishedIAP Payment Ret Ok!")
			self:doDelivery_(resultJson)
		elseif tonumber(data.pmode or 0) == 12 and tonumber(data.subStatus or - 1) and self.productId_ then
			--todo
			dump(data, "QueryUnfinishedIAP Payment Ret Wrong, Redo It!With Data :=========")
			self:queryUnfinishedIap()
		else
			dump(data, "QueryUnfinishedIAP Payment Ret Wrong!With Data :=========")
		end
	else
		dump(resultJson, "QueryUnfinishedIAP Ret Json Analysis Wrong!With Str :==========")
	end
end

function GodSdkCheckoutPurchaseService:autoDispose()
	-- body
	self.products_ = nil
    self.active_ = false
    self.isProductPriceLoaded_ = false
    self.isProductLoading_ = false

    self.loadChipRequested_ = false
    self.loadPropRequested_ = false
    self.loadGoldRequested_ = false
    self.loadVipRequested_ = false

    self.loadGoldCallback_ = nil
    self.loadChipCallback_ = nil
    self.loadPropCallback_ = nil
    self.loadVipCallback_ = nil

    self.purchaseCallback_ = nil
end

return GodSdkCheckoutPurchaseService