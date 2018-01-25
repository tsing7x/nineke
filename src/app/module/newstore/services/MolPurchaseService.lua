-- module app.module.newstore.services.MolPurchaseService.lua
-- Author: tony
-- Date: 2014-12-16 20:29:21
--
local PurchaseHelper = import("app.module.newstore.PurchaseHelper")
local PURCHASE_TYPE = import("app.module.newstore.PURCHASE_TYPE")
local MolPurchaseService = class("MolPurchaseService", import("app.module.newstore.PurchaseServiceBase"))

function MolPurchaseService:ctor()
    MolPurchaseService.super.ctor(self, "MolPurchaseService")
    self.helper_ = PurchaseHelper.new("MolPurchaseService")
end

function MolPurchaseService:init(config)
    if config then
        if config.id == PURCHASE_TYPE.MOL_TRUE_MONEY or config.id == PURCHASE_TYPE.MOL_12_CALL then
            config.inputType = "singleLine"
        else
            config.inputType = "twoLine"
        end
    end
    self.config_ = config
    self.active_ = true
    self.isPurchasing_ = false
    self:configLoadHandler_(config.goods)
end

-- 目前MOL 支付渠道只有 泰语版 (?), 所以这里没有多语言支持

function MolPurchaseService:prepareEditBox(input1, input2, submitBtn)
    if self.config_.id == PURCHASE_TYPE.MOL_TRUE_MONEY then
        --=14个数字密码
        input1:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
        input1:setMaxLength(14)
        input1:setPlaceHolder("กรุณากรอกรหัสเติมเงินตรงนี้ค่ะ")
    elseif self.config_.id == PURCHASE_TYPE.MOL_12_CALL then
        --<=16个数字密码
        input1:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
        input1:setMaxLength(16)
        input1:setPlaceHolder("กรุณากรอกรหัสเติมเงินตรงนี้ค่ะ")
    elseif self.config_.id == PURCHASE_TYPE.MOL_Z_CARD then
        --=12位数字+字母账号
        input1:setMaxLength(12)
        input1:setPlaceHolder("กรุณากรอกหมายเลขSerialที่นี้ค่ะ")
        --=12位数字+字母密码
        input2:setMaxLength(12)
        input2:setPlaceHolder("กรุณากรอกPINที่นี้ค่ะ")
    elseif self.config_.id == PURCHASE_TYPE.MOL_POINT_CARD then
        --=10位数字+字母账号
        input1:setMaxLength(10)
        input1:setPlaceHolder("กรุณากรอกหมายเลขSerialที่นี้ค่ะ")
        --=14位数字+字母密码
        input2:setMaxLength(14)
        input2:setPlaceHolder("กรุณากรอกPINที่นี้ค่ะ")
    end
end

function MolPurchaseService:onInputCardInfo(productType, pmode, input1, input2, submitBtn, callback)
    local serial_no = nil
    local pin_no = nil
    local channel = ""
    local cardInput1 = input1:getText()
    local cardInput2 = input2:getText()
    cardInput1 = (cardInput1 and string.trim(cardInput1) or nil)
    cardInput2 = (cardInput2 and string.trim(cardInput2) or nil)
    if cardInput1 == "" then cardInput1 = nil end
    if cardInput2 == "" then cardInput2 = nil end
    if self.config_.id == PURCHASE_TYPE.MOL_TRUE_MONEY then
        if not cardInput1 then
            self:toptip("กรุณากรอกรหัสเติมเงินก่อนค่ะ")
            return
        end
        serial_no = ""
        pin_no = cardInput1
        channel = "truemoney"
    elseif self.config_.id == PURCHASE_TYPE.MOL_12_CALL then
        if not cardInput1 then
            self:toptip("กรุณากรอกรหัสเติมเงินก่อนค่ะ")
            return
        end
        serial_no = ""
        pin_no = cardInput1
        channel = "12call"
    elseif self.config_.id == PURCHASE_TYPE.MOL_Z_CARD then
        if not cardInput1 or not cardInput2 then
            self:toptip("กรุณากรอกSerialและPINก่อนค่ะ")
            return
        end
        serial_no = cardInput1
        pin_no = cardInput2
        channel = "zest"
    elseif self.config_.id == PURCHASE_TYPE.MOL_POINT_CARD then
        if not cardInput1 or not cardInput2 then
            self:toptip("กรุณากรอกSerialและPINก่อนค่ะ")
            return
        end
        serial_no = cardInput1
        pin_no = cardInput2
        channel = "molpoint"
    end
    local pid
    if self.products_ and productType == 1 then
        pid = self.products_.chips[1].pid
    elseif self.products_ and productType == 2 then
        pid = self.products_.props[1].pid
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
                channel = channel
            },function(data)
                local jsn = json.decode(data)
                if jsn and jsn.RET == 0 and jsn.errCode == 200 then
                    self:toptip(bm.LangUtil.getText("STORE", "DELIVERY_SUCC_MSG"))
                    submitBtn:setButtonEnabled(true)
                    if self.purchaseCallback_ then
                        self.purchaseCallback_(true)
                    end
                elseif jsn and jsn.RET ~= 0 then
                    self:toptip(bm.LangUtil.getText("STORE", "PURCHASE_FAILED_MSG"))
                    self.logger:debug(jsn.MSG)
                    submitBtn:setButtonEnabled(true)
                elseif jsn and jsn.errCode ~= 200 then
                    self:toptip(bm.LangUtil.getText("STORE", "PURCHASE_FAILED_MSG_2"))
                    self.logger:debug(jsn.errMsg)
                    submitBtn:setButtonEnabled(true)
                else
                    retry = retry - 1
                    if retry > 0 then
                        request()
                    else
                        submitBtn:setButtonEnabled(true)
                        nk.badNetworkToptip()
                    end
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

function MolPurchaseService:autoDispose()
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

--callback(payType, isComplete, data)
function MolPurchaseService:loadChipProductList(callback)
    self.loadChipCallback_ = callback
    self.loadChipRequested_ = true
    self:loadProcess_()
end

--callback(payType, isComplete, data)
function MolPurchaseService:loadPropProductList(callback)
    self.loadPropCallback_ = callback
    self.loadPropRequested_ = true
    self:loadProcess_()
end

function MolPurchaseService:loadGoldProductList(callback)
    self.loadGoldCallback_ = callback
    self.loadGoldRequested_ = true
    self:loadProcess_()
end

function MolPurchaseService:loadProcess_()
    if not self.products_ then
        self.logger:debug("remote config is loading..")
        self:configLoadHandler_(self.config_.goods)
        self:invokeCallback_(3, false)
    elseif self.loadChipRequested_ or self.loadPropRequested_ or self.loadGoldRequested_ then
        self.helper_:updateDiscount(self.products_, self.config_)
        self:invokeCallback_(1, true, self.products_.chips)
        self:invokeCallback_(2, true, self.products_.props)
        self:invokeCallback_(4, true, self.products_.golds)
    else
        self:invokeCallback_(3, false)
    end
end

function MolPurchaseService:invokeCallback_(flag, isComplete, data)
    if self.loadChipRequested_ and self.loadChipCallback_ and (flag == 1 or flag == 3) then
        self.loadChipCallback_(self.config_, isComplete, data)
    end

    if self.loadPropRequested_ and self.loadPropCallback_ and (flag == 2 or flag == 3)  then
        self.loadPropCallback_(self.config_, isComplete, data)
    end

    if self.loadGoldRequested_ and self.loadGoldCallback_ and (flag == 4 or flag == 3)  then
        self.loadGoldCallback_(self.config_, isComplete, data)
    end
end

function MolPurchaseService:configLoadHandler_(content)
    self.logger:debug("remote config file loaded.")
    self.products_ = self.helper_:parseGoods(content, function(category, product)
            product.buyButtonEnabled = false
            product.priceLabel = string.format("%dTHB", product.price)
            product.priceNum = product.price
            product.priceDollar = "THB"
        end)
    self:loadProcess_()
end

function MolPurchaseService:makePurchase(pid, callback)
end

return MolPurchaseService
