--
-- Author: KevinYu
-- Date: 2016-09-07 10:22:57
-- 博雅卡

local PurchaseHelper = import("app.module.newstore.PurchaseHelper")
local PURCHASE_TYPE = import("app.module.newstore.PURCHASE_TYPE")
local ByCardPurchaseService = class("ByCardPurchaseService", import("app.module.newstore.PurchaseServiceBase"))

function ByCardPurchaseService:ctor()
    ByCardPurchaseService.super.ctor(self, "ByCardPurchaseService")
    self.helper_ = PurchaseHelper.new("ByCardPurchaseService")
end

function ByCardPurchaseService:init(config)
    if config then
		config.inputType = "twoLine"
    end

    self.config_ = config
    self.active_ = true
    self.isPurchasing_ = false
    self:configLoadHandler_(config.goods)
end

function ByCardPurchaseService:prepareEditBox(input1, input2, submitBtn)
        --=16位数字+字母账号
        input1:setMaxLength(16)
        input1:setPlaceHolder("กรุณากรอกหมายเลขSerialที่นี้ค่ะ")

        --=16位数字+字母密码
        input2:setMaxLength(16)
        input2:setPlaceHolder("กรุณากรอกPINที่นี้ค่ะ")
end

function ByCardPurchaseService:onInputCardInfo(productType, pmode, input1, input2, submitBtn, callback)
    local serial_no = input1:getText() --账号
    local pin_no = input2:getText() --密码

    serial_no = (serial_no and string.trim(serial_no) or nil)
    pin_no = (pin_no and string.trim(pin_no) or nil)

    if serial_no == "" then serial_no = nil end
    if pin_no == "" then pin_no = nil end
    
    if not serial_no or not pin_no then
        self:toptip("กรุณากรอกSerialและPINก่อนค่ะ")
        return
    end

    local pid
    if self.products_ and productType == 1 then
        pid = self.products_.chips[1].pid
    elseif self.products_ and productType == 3 then
        pid = self.products_.golds[1].pid
    end

    self.purchaseCallback_ = callback
    local request
    local retry = 3
    submitBtn:setButtonEnabled(false)
    request = function()
        bm.HttpService.POST({
            mod = "Payment",
            act="callPayOrder",
            id = pid,
            ptype = productType,
            pmode = pmode,
            siteuid = nk.userData.siteuid or "",
            uid = nk.userData.uid or "",
            serial_no = serial_no,
            pin_no = pin_no,
            channel = "bycard"
        },
        function(data)
            local jsn = json.decode(data)
            if jsn and jsn.RET == 0 then
                self:toptip(bm.LangUtil.getText("STORE", "DELIVERY_SUCC_MSG"))
                submitBtn:setButtonEnabled(true)
                if self.purchaseCallback_ then
                    self.purchaseCallback_(true)
                end
            elseif jsn and jsn.RET == -2 then
                self:toptip(bm.LangUtil.getText("STORE", "PURCHASE_FAILED_MSG_2"))
                self.logger:debug(jsn.MSG)
                submitBtn:setButtonEnabled(true)
            else
                self:toptip(bm.LangUtil.getText("STORE", "PURCHASE_FAILED_MSG"))
                self.logger:debug(jsn.errMsg)
                submitBtn:setButtonEnabled(true)
            end
        end,
        function(data)
            retry = retry - 1
            if retry > 0 then
                request()
            else
                submitBtn:setButtonEnabled(true)
                nk.badNetworkToptip()
            end
        end)
    end
        
    request()
end

function ByCardPurchaseService:autoDispose()
    self.products_ = nil
    self.active_ = false

    self.loadChipRequested_ = false
    self.loadGoldRequested_ = false

    self.loadGoldCallback_ = nil
    self.loadChipCallback_ = nil

    self.purchaseCallback_ = nil
end

function ByCardPurchaseService:loadChipProductList(callback)
    self.loadChipCallback_ = callback
    self.loadChipRequested_ = true
    self:loadProcess_()
end

function ByCardPurchaseService:loadGoldProductList(callback)
    self.loadGoldCallback_ = callback
    self.loadGoldRequested_ = true
    self:loadProcess_()
end

function ByCardPurchaseService:loadProcess_()
    if not self.products_ then
        self.logger:debug("remote config is loading..")
        self:configLoadHandler_(self.config_.goods)
        self:invokeCallback_(3, false)
    elseif self.loadChipRequested_ or self.loadGoldRequested_ then
        self.helper_:updateDiscount(self.products_, self.config_)
        self:invokeCallback_(1, true, self.products_.chips)
        self:invokeCallback_(2, true, self.products_.golds)
    else
        self:invokeCallback_(3, false)
    end
end

function ByCardPurchaseService:invokeCallback_(flag, isComplete, data)
    if self.loadChipRequested_ and self.loadChipCallback_ and (flag == 1 or flag == 3) then
        self.loadChipCallback_(self.config_, isComplete, data)
    end

    if self.loadGoldRequested_ and self.loadGoldCallback_ and (flag == 2 or flag == 3)  then
        self.loadGoldCallback_(self.config_, isComplete, data)
    end
end

function ByCardPurchaseService:configLoadHandler_(content)
    self.logger:debug("remote config file loaded.")
    self.products_ = self.helper_:parseGoods(content, function(category, product)
            product.buyButtonEnabled = false
            product.priceLabel = string.format("%dPoint", product.price)
            product.priceNum = product.price
            product.priceDollar = "Point"
            product.noDiscount = true
        end)
    self:loadProcess_()
end

function ByCardPurchaseService:makePurchase(pid, callback)
end

return ByCardPurchaseService
