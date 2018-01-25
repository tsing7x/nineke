local PurchaseHelper = import("app.module.newstore.PurchaseHelper")
local PURCHASE_TYPE = import("app.module.newstore.PURCHASE_TYPE")
local BluePayPurchaseService = class("BluePayPurchaseService", import("app.module.newstore.PurchaseServiceBase"))

function BluePayPurchaseService:ctor()
    BluePayPurchaseService.super.ctor(self, "BluePayPurchaseService")

    self.helper_ = PurchaseHelper.new("BluePayPurchaseService")

    if device.platform == "android" then
        self.invokeJavaMethod_ = self:createJavaMethodInvoker("com/boomegg/cocoslib/bluepay/BluePayBridge")
        self.invokeJavaMethod_("setSetupCompleteCallback", {handler(self, self.onSetupComplete_)}, "(I)V")
        self.invokeJavaMethod_("setPurchaseCompleteCallback", {handler(self, self.onPurchaseComplete_)}, "(I)V")
    else
        self.invokeJavaMethod_ = function(method, param, sig)
            if method == "setup" then
                self.schedulerPool_:delayCall(function()
                    self:onSetupComplete_("true")
                end, 1)
            elseif method == "payBySMS" then
                self.schedulerPool_:delayCall(function()
                    self:onPurchaseComplete_([[{"isSuccess":"true", "code":"200", "result":"fakesignature","title":"bluepay"}]])
                end, 1)
            elseif method == "payByBank" then
                self.schedulerPool_:delayCall(function()
                    self:onPurchaseComplete_([[{"isSuccess":"true", "code":"200", "result":"fakesignature","title":"bluepay"}]])
                end, 1)
            elseif method == "isSetupComplete" then
            	return true,true
            elseif method == "isSupported" then
            	return true,true
            end
        end
    end
end

function BluePayPurchaseService:init(config, isLoadData)
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

function BluePayPurchaseService:init_()
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
end

function BluePayPurchaseService:autoDispose()
    self.products_ = nil
    self.active_ = false
    self.isProductPriceLoaded_ = false  --确保每次重新load价格，触发发货检查
    self.isProductRequesting_ = false
    
    self.loadChipRequested_ = false
    self.loadPropRequested_ = false
    self.loadGoldRequested_ = false
    self.loadPackageRequested_ = false
    self.loadVipRequested_ = false

    self.loadGoldCallback_ = nil
    self.loadChipCallback_ = nil
    self.loadPropCallback_ = nil
    self.loadPackageCallback_ = nil
    self.loadVipCallback_ = nil
    

    -- self.purchaseCallback_ = nil --防止主动关闭商城后，还是显示礼包
end

--callback(payType, isComplete, data)
function BluePayPurchaseService:loadChipProductList(callback)
    self.loadChipCallback_ = callback
    self.loadChipRequested_ = true
    self:loadProcess_()
end

--callback(payType, isComplete, data)
function BluePayPurchaseService:loadPropProductList(callback)
    self.loadPropCallback_ = callback
    self.loadPropRequested_ = true
    self:loadProcess_()
end

function BluePayPurchaseService:loadGoldProductList(callback)
    self.loadGoldCallback_ = callback
    self.loadGoldRequested_ = true
    self:loadProcess_()
end

function BluePayPurchaseService:loadPackageProductList(callback)
    self.loadPackageCallback_ = callback
    self.loadPackageRequested_ = true
    self:loadProcess_()
end

function BluePayPurchaseService:loadVipProductList(callback)
    self.loadVipCallback_ = callback
    self.loadVipRequested_ = true
    self:loadProcess_()
end

function BluePayPurchaseService:makePurchase(pid, callback, goodsItem)
    self.purchaseCallback_ = callback
    if nk.userData.isConfirmSmsPay == 1 then
        local mes_ = bm.LangUtil.getText("E2P_TIPS", "PURCHASE_TIPS", goodsItem.discountTitle or goodsItem.title, goodsItem.price)
        if tonumber(goodsItem.pmode) == PURCHASE_TYPE.BLUE_BANK_PAY then
            mes_ = bm.LangUtil.getText("E2P_TIPS", "BANK_PURCHASE_TIPS", goodsItem.discountTitle or goodsItem.title, goodsItem.price)
        end
        nk.ui.Dialog.new({
            messageText = mes_,
            callback = function(param)
                if param == nk.ui.Dialog.SECOND_BTN_CLICK then
                    self:makePurchase_(pid, goodsItem)
                else
                end
            end
        }):show()
    else
        self:makePurchase_(pid, goodsItem)
    end
end

--下单
function BluePayPurchaseService:makePurchase_(pid, goodsItem)
    self.helper_:generateOrderId(pid, goodsItem.pmode, nil, function(succ, orderId, msg, data)
        if succ then
            self.pendingPid = pid
            local uid = tostring(nk.userData.uid) or ""
            local pid = tostring(data.PAYCONFID) or ""
            local currency = tostring(data.CURRENCY) or "THB"
            local price = tonumber(data.PAMOUNT) * 100 -- (X100 是BluePay要求,平台上的泰铢是真实世界中泰铢的1/100,免得小数点 )
            local propsName = goodsItem.title or ""
            local isShowDialog = false
            local smsId = 0
            if goodsItem.smsId then
                smsId = goodsItem.smsId
            else
                if goodsItem.category and goodsItem.price then
                    smsId = self:getSmsIdByPrice(goodsItem.category,goodsItem.price)
                end
            end
            self.logger:debug("BluePayPurchaseService : makePurchase smsId = " .. smsId)
            if tonumber(goodsItem.pmode) == PURCHASE_TYPE.BLUE_PAY then 
                self:payBySMS(uid,pid,orderId,currency,price,smsId,propsName,isShowDialog)
            elseif tonumber(goodsItem.pmode) == PURCHASE_TYPE.BLUE_BANK_PAY then
                self:payByBank(uid,pid,orderId,currency,price,propsName,isShowDialog)
            end
        else
            if msg and msg ~= "" then
                self:toptip(msg)
            end
        end
    end)
end

function BluePayPurchaseService:firstMakePurchase(pid, callback, goodsItem)
    self.purchaseCallback_ = callback
    self:makePurchase_(pid, goodsItem)
end

function BluePayPurchaseService:payBySMS(uid,pid,transactionId,currency,price,smsId,propsName,isShowDialog)
	self.invokeJavaMethod_("payBySMS", {uid,pid,transactionId,currency,price,smsId,propsName,isShowDialog}, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;Z)V")
end

function BluePayPurchaseService:payByCashcard(uid,pid,transactionId,propsName,publicer,cardNo,serialNo)
	self.invokeJavaMethod_("payByCashcard", {uid,pid,transactionId,propsName,publicer,cardNo,serialNo}, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
end

function BluePayPurchaseService:payBySteps(uid,pid,transactionId,currency,price,smsId,propsName,mode,isShowDialog)
    self.invokeJavaMethod_("payBySteps", {uid,pid,transactionId,currency,price,smsId,propsName,mode,isShowDialog}, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;IZ)V")
end

function BluePayPurchaseService:payByBank(uid,pid,transactionId,currency,price,propsName,isShowDialog)
    self.invokeJavaMethod_("payByBank", {uid,pid,transactionId,currency,price,propsName,isShowDialog}, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Z)V")
end

--加载商品信息流程
function BluePayPurchaseService:loadProcess_()
    if not self.products_ then
        self.logger:debug("remote config is loading..")
        self:configLoadHandler_(self.config_.goods)
        self:invokeCallback_(3, false)
    end
    if self.isSetupComplete_ then
        if self.isSupported_ then
            if self:isRequested_() then
                if self.products_ then
                    self.helper_:updateDiscount(self.products_, self.config_)
                    self:invokeCallback_(1, true, self.products_.chips)
                    self:invokeCallback_(2, true, self.products_.props)
                    self:invokeCallback_(3, true, self.products_.golds)
                    self:invokeCallback_(5, true, self.products_.packages)
                    self:invokeCallback_(6, true, self.products_.vips)
                else
                    self:invokeCallback_(4, false)
                end
            end
        else
            self.logger:debug("bluepay not supported")
            self:invokeCallback_(4, true, bm.LangUtil.getText("STORE", "NOT_SUPPORT_MSG"))
        end
    elseif self.isSetuping_ then
        self.logger:debug("setuping ...")
        self:invokeCallback_(4, false)
    else
        self.isSetuping_ = true
        self.logger:debug("start setup..")
        self:invokeCallback_(4, false)
        self.invokeJavaMethod_("setup", {}, "()V")
    end
end

function BluePayPurchaseService:isRequested_()
    return self.loadChipRequested_ or
           self.loadPropRequested_ or
           self.loadGoldRequested_ or
           self.loadPackageRequested_ or 
           self.loadVipRequested_
end

--Java call lua
function BluePayPurchaseService:onSetupComplete_(isSupported)
    self.logger:debug("setup complete.")
    self.isSetuping_ = false
    self.isSetupComplete_ = true
    self.isSupported_ = (isSupported == "true")
    self.logger:debug("isSupported raw:", isSupported)
    if self.config_ then
        --这里加载商品数据可能会让首冲礼包不能添加进来
        -- self:loadProcess_()
    end
end


--[[
    返回码         说明           适用场景
    200    当前流程成功结束    服务端通知，表示所有流程结束
    201    当前步骤流程结束，还有后续步骤SDK给游戏返回的计费请求已经发送，或其他还需要有后续异步流程的场景
    
    400    请求参数错误   SDK返回游戏，比如必填参数为空或参数无效。
    401    未授权          SDK返回游戏，当前游戏没有获得当前接口的使用权。
    402    双卡错误             SDK返回游戏, 用户为双卡手机, 发送短信出现异常
    403    SIM卡异常   SDK 返回游戏, 1. 用户没有SIM卡2. 非支持的SIM卡类型. 3. 运营商不支持的SIM卡
    404    请求数据不存在或请求异常    通用于服务端validPIN, queryTrans等请求，查询数据结果为空
    405    SDK使用错误    SDK返回游戏, 用户使用SDK错误, 或参数填写错误, 或是非UI环境调用函数
    406    Cash card调用失败   SDK返回游戏, SDK调用cash card接口时失败
    407    短信发送错误     SDK返回游戏, 短信无法发出. (不是指发送过程中被拦截.)

    500    JMT内部错误         所有因为JMT服务错误导致的失败。
    501    SDK与JMT服务通信异常      SDK返回游戏，因为网络原因导致的通信异常，可以提示用户稍后再试。
    502    JMT在运营商测服务异常      属于JMT异常，运营商侧服务变更导致。
    503    网络限制    用户访问网络不允许，通常是当前接口只能支持无线网络计费，不支持wifi。
    504    用户当日累计消费超过日限制   属于业务异常，可以提示用户次日再试。
    505    用户当月累计消费超过月限制   属于业务异常，可以提示用户下个月再试。
    506    用户黑名单   当前用户已经被添加入黑名单，需要联系BLUEPAY客服处理
    507    用户消费间隔时间少于60s   当前用户上一次操作到本次操作少于60s，请稍候再试。 
    508    待确认密码已经被使用  适用于短信上行的web充值流程、trueMony充值卡，12call充值卡，当前使用的密码已经被使用过。
    509    待确认密码不存在或非法 适用于短信上行的web充值流程、trueMony充值卡，12call充值卡，当前充值密码状态不正常
    510    待确认密码已经过期   适用于短信上行的web充值流程、trueMoney充值卡，12call充值卡，当前输入的确认密码已经过期
    511    当前用户频繁试错，请稍候再试  适用于短信上行的web充值流程、trueMoney充值卡，12call充值卡，
           当前用户频繁试错 可能存在机器欺诈行为，一个小时内将不能再次进行交易

    600    运营商服务错误 所有因为运营商服务错误导致的失败，提示用户稍后再试
    601    用户余额不足  用户余额不足导致计费失败，提示用户充钱后再试
    602    用户状态异常  因为用户状态异常导致的运营商拒绝服务，提示用户检查运营商侧的服务状态
    603    用户取消操作  用户在付费过程中取消，提示用户
    604    系统预留            不会出现在用户使用流程中
    605    用户重复使用相同transaction id付费    如果当前的短信计费请求使用了与以前相同的transaction id，会得到这个错误码。 一般来说可能会出现在QR code计费流程中
--]]

--Java call lua
function BluePayPurchaseService:onPurchaseComplete_(jsonString)
    self.logger:debug("purchase complete -> ", jsonString)
    local jsonData = json.decode(jsonString)
    local success = (jsonData.isSuccess == "true") and true or false
    local code = jsonData.code
    local result = jsonData.result
    local title = jsonData.title
    if success then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "PURCHASE_SUCC_AND_DELIVERING"))
        jsonData.pid = self.pendingPid
        if self.purchaseCallback_ then
            self.purchaseCallback_(true, jsonData)
        end
    else
        if DEBUG >= 5 then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "PURCHASE_FAILED_MSG") .. "---" .. result)
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "PURCHASE_FAILED_MSG"))
        end
        if self.purchaseCallback_ then
            self.purchaseCallback_(false, "error")
        end
    end
end

function BluePayPurchaseService:invokeCallback_(flag, isComplete, data)
    if self.loadChipRequested_ and self.loadChipCallback_ and (flag == 1 or flag == 4) then
        self.loadChipCallback_(self.config_, isComplete, data)
    end

    if self.loadPropRequested_ and self.loadPropCallback_ and (flag == 2 or flag == 4)  then
        self.loadPropCallback_(self.config_, isComplete, data)
    end

    if self.loadGoldRequested_ and self.loadGoldCallback_ and (flag == 3 or flag == 4)  then
        self.loadGoldCallback_(self.config_, isComplete, data)
    end

    if self.loadPackageRequested_ and self.loadPackageCallback_ and (flag == 5 or flag == 4)  then
        self.loadPackageCallback_(self.config_, isComplete, data)
    end

    if self.loadVipRequested_ and self.loadVipCallback_ and (flag == 6 or flag == 4)  then
        self.loadVipCallback_(self.config_, isComplete, data)
    end
end

function BluePayPurchaseService:configLoadHandler_(content)
    self.logger:debug("remote config file loaded.")
    self.products_ = self.helper_:parseGoods(content, function(category, product)
    	product.priceLabel = string.format("%dTHB", product.price)
        product.priceNum = product.price
        product.priceDollar = "THB"
        product.smsId = self:getSmsIdByPrice(category,product.price)
    end)
    self:loadProcess_()
end

function BluePayPurchaseService:getSmsIdByPrice(category,price)
    price = tonumber(price)
    if category == "chips" then
        if price == 9 then
            return 56
        elseif price == 29 then
            return 57
        elseif price == 49 then
            return 58
        elseif price == 99 then
            return 59
        elseif price == 149 then
            return 60
        elseif price == 249 then
            return 61
        elseif price == 19 then
            return 68
        elseif price == 5 then
            return 71
        end
    elseif category == "props" or category == "match_chips" then
        if price == 9 then
            return 62
        elseif price == 29 then
            return 63
        elseif price == 49 then
            return 64
        elseif price == 99 then
            return 65
        elseif price == 149 then
            return 66
        elseif price == 249 then
            return 67
        elseif price == 19 then
            return 69
        elseif price == 5 then
            return 72
        end
    end
    return 0
end

return BluePayPurchaseService

