--
-- Author: Jonah0608@gmail.com
-- Date: 2015-10-14 16:32:14
--
local PurchaseHelper = import("app.module.newstore.PurchaseHelper")
local Easy2PayApiPurchaseService = class("Easy2PayApiPurchaseService", import("app.module.newstore.PurchaseServiceBase"))

RES_CODE_SUCC              = "100"
RES_CODE_NOT_SUPPORT       = "201"
RES_CODE_NOT_OPERATORCODE  = "202"
RES_CODE_SMS_SENT_FAIL     = "300"
RES_CODE_SMS_TEXT_EMPTY    = "401"
RES_CODE_SMS_ADDRESS_EMPTY = "402"
RES_CODE_SMS_NOSIM         = "404"
RES_CODE_SMS_NO_PRICEPOINT = "500"

function Easy2PayApiPurchaseService:ctor()
    self.payStatistics_ = {}
    Easy2PayApiPurchaseService.super.ctor(self, "Easy2PayApiPurchaseService")
    self.helper_ = PurchaseHelper.new("Easy2PayApiPurchaseService")

    if device.platform == "android" then
        self.invokeJavaMethod_ = self:createJavaMethodInvoker("com/boomegg/cocoslib/easy2payapi/Easy2PayApiBridge")
        self.invokeJavaMethod_("setCallback", {handler(self, self.onPayResult_)}, "(I)V")
    elseif device.platform == "ios" then
    else
         self.invokeJavaMethod_ = function(method, param, sig)
            if method == "makePurchase" then
                self:onPayResult_([[{"code":"100", "msg":""}]])
            end
        end
    end
end

function Easy2PayApiPurchaseService:init(config)
    self.config_ = config
    self.active_ = true
    self.isPurchasing_ = false
    self:configLoadHandler_(config.goods)
end

function Easy2PayApiPurchaseService:autoDispose()
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


function Easy2PayApiPurchaseService:loadChipProductList(callback)
    self.loadChipCallback_ = callback
    self.loadChipRequested_ = true
    self:loadProcess_()
end

function Easy2PayApiPurchaseService:loadPropProductList(callback)
    self.loadPropCallback_ = callback
    self.loadPropRequested_ = true
    self:loadProcess_()
end

function Easy2PayApiPurchaseService:loadGoldProductList(callback)
    self.loadGoldCallback_ = callback
    self.loadGoldRequested_ = true
    self:loadProcess_()
end

function Easy2PayApiPurchaseService:loadProcess_()
    if not self.products_ then
        self.logger:debug("remote config is loading..")
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

function Easy2PayApiPurchaseService:invokeCallback_(flag, isComplete, data)
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

function Easy2PayApiPurchaseService:configLoadHandler_(content)
    local payInfo = {}
    self.products_ = self.helper_:parseGoods(content,function(category, product)
            if category == "chips" then
                payInfo[product.id] = {
                    merchantId="4165",
                    priceId = tostring(product.price),
                }
            elseif category == "props" then
                payInfo[product.id] = {
                    merchantId="4165",
                    priceId = tostring(product.price),
                }
            elseif category == "match_chips" then
                payInfo[product.id] = {
                    merchantId="4165",
                    priceId = tostring(product.price),
                }
            elseif category == "golds" then
                payInfo[product.id] = {
                    merchantId="4165",
                    priceId = tostring(product.price),
                }
            end
            product.priceLabel = string.format("%dTHB", product.price)
            product.priceNum = product.price
            product.priceDollar = "THB"
        end)
    if self.products_ then
        self.products_.payInfo = payInfo
    end
    self:loadProcess_()
end

function Easy2PayApiPurchaseService:makePurchase(pid, callback, goodsItem)
    if self.isPurchasing_ then
        self:toptip(bm.LangUtil.getText("STORE", "BUSY_PURCHASING_MSG"))
        return
    end

    self.purchaseCallback_ = callback
    self.logger:debug("make purchase ", pid)
    local userId = tostring(nk.userData.uid)
    local payInfo = self.products_.payInfo[pid]
    if userId and payInfo and pid and userId ~= "" and payInfo.merchantId and payInfo.priceId then
        if nk.userData.isConfirmSmsPay == 1 then
            nk.ui.Dialog.new({
                messageText = bm.LangUtil.getText("E2P_TIPS", "PURCHASE_TIPS", goodsItem.discountTitle or goodsItem.title, payInfo.priceId),
                callback = function(param)
                    if param == nk.ui.Dialog.SECOND_BTN_CLICK then
                        self:makePurchase_(pid, userId, payInfo, goodsItem)
                    else
                        self.isPurchasing_ = false
                    end
                end
            }):show()  
        else
            self:makePurchase_(pid, userId, payInfo, goodsItem)
        end
        
    end
end

function Easy2PayApiPurchaseService:makePurchase_(pid, userId, payInfo, goodsItem)
    local params = {}
    params.channel = "psms"
    params.email = userId
    self.isPurchasing_ = true
    self.helper_:generateOrderId(pid, goodsItem.pmode, params, function(succ,orderId,msg,data)
        if succ then
            self.logger:debugf("call makePurchase -> %s, %s, %s, %s", orderId, userId, payInfo.merchantId, payInfo.priceId)

            if device.platform == 'ios' then

                local function start()
                end
                local function finish()
                    if not tolua.isnull(self.openWebviewLoading) then
                        self.openWebviewLoading:hide()
                    end
                end
                local function fail(error_info)
                    if not tolua.isnull(self.openWebviewLoading) then
                        self.openWebviewLoading:hide()
                    end
                end
                local function userClose()
                    if self.bgLayer then
                        self.bgLayer:removeFromParent()
                        self.bgLayer = nil
                        self.openWebviewLoading = nil -- child of bgLayer
                    end
                    nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)

                    -- 清除 正在支付 状态
                    self.isPurchasing_ = false
                    nk.userData.firstPay = false
                end

                local function shouldStartLoad(url)
                    return true
                end

                -- webview
                local W, H = 860, 614 - 72
                local x, y = display.cx - W / 2, display.cy - H / 2

                local view, err = Webview.create(start, finish, fail, userClose, shouldStartLoad)
                if view then
                    view:show(x,y,W,H)
                    view:updateURL(data.url)
                end

                self.bgLayer = display.newNode():addTo(display.getRunningScene(), 10000)
                self.bgLayer:setTouchEnabled(true)
                self.bgLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function() return true end)

                display.newColorLayer(cc.c4f(0, 0, 0, 128)):addTo(self.bgLayer)
                self.openWebviewLoading = nk.ui.Juhua.new()
                    :addTo(self.bgLayer)
                    :pos(display.cx, display.cy)
                    :show()

            else
                local args = {orderId, userId, payInfo.merchantId, payInfo.priceId}
                local sig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"
                self.invokeJavaMethod_("makePurchase", args, sig)
            end
        else
            self.isPurchasing_ = false
            if msg and msg ~= "" then
                self:toptip(msg)
            end
        end
    end)
end

function Easy2PayApiPurchaseService:firstMakePurchase(pid, callback, goodsItem)
    if self.isPurchasing_ then
        self:toptip(bm.LangUtil.getText("STORE", "BUSY_PURCHASING_MSG"))
        return
    end

    self.purchaseCallback_ = callback
    self.logger:debug("make purchase ", pid)
    local userId = tostring(nk.userData.uid)
    local payInfo = goodsItem.payInfo
    if userId and payInfo and pid and userId ~= "" and payInfo.merchantId and payInfo.priceId then
        nk.ui.Dialog.new({
                messageText = bm.LangUtil.getText("E2P_TIPS", "PURCHASE_TIPS", goodsItem.discountTitle or goodsItem.title, payInfo.priceId),
                callback = function(param)
                    if param == nk.ui.Dialog.SECOND_BTN_CLICK then
                        local params = {}
                        params.channel = "psms"
                        params.email = userId
                        self.isPurchasing_ = true
                        self.helper_:generateOrderId(pid, goodsItem.pmode, params, function(succ,orderId,msg,data)
                                if succ then
                                    self.logger:debugf("call makePurchase -> %s, %s, %s, %s", orderId, userId, payInfo.merchantId, payInfo.priceId)
                                    self.pendingPid = pid
                                    if device.platform == 'ios' then

                                        local function start()
                                        end
                                        local function finish()
                                            if not tolua.isnull(self.openWebviewLoading) then
                                                self.openWebviewLoading:hide()
                                            end
                                        end
                                        local function fail(error_info)
                                            if not tolua.isnull(self.openWebviewLoading) then
                                                self.openWebviewLoading:hide()
                                            end
                                        end
                                        local function userClose()

                                            self.bgLayer:removeFromParent()
                                            self.bgLayer = nil
                                            self.openWebviewLoading = nil -- child of bgLayer
                                            nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)

                                            -- 清除 正在支付 状态
                                            self.isPurchasing_ = false
                                            nk.userData.firstPay = false
                                        end

                                        -- webview
                                        local W, H = 860, 614 - 72
                                        local x, y = display.cx - W / 2, display.cy - H / 2

                                        local view, err = Webview.create(start, finish, fail, userClose)
                                        if view then
                                            view:show(x,y,W,H)
                                            view:updateURL(data.url)
                                        end

                                        self.bgLayer = display.newNode():addTo(display.getRunningScene(), 10000)
                                        self.bgLayer:setTouchEnabled(true)
                                        self.bgLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function() return true end)

                                        display.newColorLayer(cc.c4f(0, 0, 0, 128)):addTo(self.bgLayer)
                                        self.openWebviewLoading = nk.ui.Juhua.new()
                                            :addTo(self.bgLayer)
                                            :pos(display.cx, display.cy)
                                            :show()

                                    else
                                        local args = {orderId, userId, payInfo.merchantId, payInfo.priceId}
                                        local sig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"
                                        self.invokeJavaMethod_("makePurchase", args, sig)
                                        self.isPurchasing_ = false
                                    end
                                else
                                    self.isPurchasing_ = false
                                    if msg and msg ~= "" then
                                        self:toptip(msg)
                                    end
                                end
                            end)
                    else
                        self.isPurchasing_ = false
                    end
                end
            })
        :show()  
    end
end

function Easy2PayApiPurchaseService:onPayResult_(jsonString)
    self.isPurchasing_ = false
    local tb = json.decode(jsonString)
    self.isPurchasing_ = false
    if tb and tb.code then
         local errCode = tb.code
        if errCode == RES_CODE_SUCC then
            local str = bm.LangUtil.getText("E2P_TIPS","SMS_SUCC")
            self:toptip(str)
            if self.purchaseCallback_ then
                self.purchaseCallback_(true, self.pendingPid)
            end
        elseif errCode == RES_CODE_NOT_SUPPORT then
            local str = bm.LangUtil.getText("E2P_TIPS","NOT_SUPPORT")
            self:toptip(str)
        elseif errCode == RES_CODE_NOT_OPERATORCODE then
            local str = bm.LangUtil.getText("E2P_TIPS","NOT_OPERATORCODE")
            self:toptip(str)
        elseif errCode >=300 and errCode <400 then
            local str = bm.LangUtil.getText("E2P_TIPS","SMS_SENT_FAIL")
            self:toptip(str)
        elseif errCode == RES_CODE_SMS_TEXT_EMPTY then
            local str = bm.LangUtil.getText("E2P_TIPS","SMS_TEXT_EMPTY")
            self:toptip(str)
        elseif errCode == RES_CODE_SMS_ADDRESS_EMPTY then
            local str = bm.LangUtil.getText("E2P_TIPS","SMS_ADDRESS_EMPTY")
            self:toptip(str)
        elseif errCode == RES_CODE_SMS_NOSIM then
            local str = bm.LangUtil.getText("E2P_TIPS","SMS_NOSIM")
            self:toptip(str)
        elseif errCode == RES_CODE_SMS_NO_PRICEPOINT then
            local str = bm.LangUtil.getText("E2P_TIPS","SMS_NO_PRICEPOINT")
            self:toptip(str)
        end
    else
        self:toptip(str)
    end
end

return Easy2PayApiPurchaseService