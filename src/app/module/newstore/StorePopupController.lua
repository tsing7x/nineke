--
-- Author: tony
-- Date: 2014-11-17 16:33:16
--
local PurchaseServiceManager = import(".PurchaseServiceManager")
local StorePopupController = class("StorePopupController")
local logger = bm.Logger.new("StorePopupController")

function StorePopupController:ctor(view, id)
    self.view_ = view
    self.manager_ = PurchaseServiceManager:getInstance()
    self.schedulerPool_ = bm.SchedulerPool.new()
end

function StorePopupController:loadPayConfig()
    if nk.userData.marketData and nk.userData.marketData.ret >= 0 then
            logger:debug("loadPayConfig .. user preLoad")
            local tb = nk.userData.marketData
            local payTypeAvailable = {}
            for i, p in ipairs(tb.payTypes) do
                p.id = tonumber(p.id)
                p.payLevel = tonumber(p.payLevel)
                if self.manager_:isServiceAvailable(p.id) then
                    payTypeAvailable[#payTypeAvailable + 1] = p
                end
            end
            
            --在这对支付列表排序
            table.sort(payTypeAvailable, function(a, b)
                return a.payLevel > b.payLevel
            end)

            self.manager_:init(payTypeAvailable, true)
            self.view_:createMainUI(payTypeAvailable, tb.showTypes, tb.showTips)
            return
    end

    logger:debug("loadPayConfig ..")
    local retryTimes = 3
    local loadPayConfig
    loadPayConfig = function ()
        bm.HttpService.POST({
            mod = "Payment",
            act = "getAllPayList",
        },
        function(data)
            local tb = json.decode(data)
            if tb and tb.ret >= 0 then --请求成功
                logger:debug("loadPayConfig complete")
                local payTypeAvailable = {}
                
                for i, p in ipairs(tb.payTypes) do
                    p.id = tonumber(p.id)
                    p.payLevel = tonumber(p.payLevel)
                    if self.manager_:isServiceAvailable(p.id) then
                        payTypeAvailable[#payTypeAvailable + 1] = p
                    end
                end

                --在这对支付列表排序
                table.sort(payTypeAvailable, function(a, b)
                    return a.payLevel > b.payLevel
                end)

                self.manager_:init(payTypeAvailable)
                self.view_:createMainUI(payTypeAvailable, tb.showTypes, tb.showTips)
            else
                retryTimes = retryTimes - 1 --请求失败后， 重试次数，3次以后还失败，就关闭商城界面
                if retryTimes > 0 then
                    loadPayConfig()
                end
            end
        end,
        function()
            retryTimes = retryTimes - 1
            if retryTimes > 0 then
                loadPayConfig()
            end
        end)
    end
    loadPayConfig()
end

function StorePopupController:getPurchaseService_(paytype)
    return self.manager_:getPurchaseService(paytype.id)
end

function StorePopupController:loadChipProductList(paytype)
    local service = self:getPurchaseService_(paytype)
    service:loadChipProductList(handler(self, self.loadChipProductListResult_))
end

function StorePopupController:loadChipProductListResult_(paytype, isComplete, data)
    self.view_:setChipList(paytype, isComplete, data)
end

function StorePopupController:loadPropProductList(paytype)
    local service = self:getPurchaseService_(paytype)
    service:loadPropProductList(handler(self, self.loadPropProductListResult_))
end

function StorePopupController:loadPropProductListResult_(paytype, isComplete, data)
    self.view_:setPropList(paytype, isComplete, data)
end

-- 加载黄金币
function StorePopupController:loadGoldProductList(paytype)
    local service = self:getPurchaseService_(paytype);
    service:loadGoldProductList(handler(self, self.loadGoldProductListResult_))
end

function StorePopupController:loadGoldProductListResult_(paytype, isComplete, data)
    self.view_:setGoldList(paytype, isComplete, data)
end

-- 加载大礼包
function StorePopupController:loadPackageProductList(paytype)
    local service = self:getPurchaseService_(paytype);
    service:loadPackageProductList(handler(self, self.loadPackageProductListResult_))
end

function StorePopupController:loadPackageProductListResult_(paytype, isComplete, data)
    self.view_:setPackageList(paytype, isComplete, data)
end

-- 加载VIP
function StorePopupController:loadVipProductList(paytype)
    local service = self:getPurchaseService_(paytype);
    service:loadVipProductList(handler(self, self.loadVipProductListResult_))
end

function StorePopupController:loadVipProductListResult_(paytype, isComplete, data)
    self.view_:setVipList(paytype, isComplete, data)
end

function StorePopupController:makePurchase(paytype, pid, goodsItem)
    local service = self:getPurchaseService_(paytype)
    service:makePurchase(pid, handler(self, self.purchaseResult_), goodsItem)
end

function StorePopupController:prepareEditBox(paytype, input1, input2, submitBtn)
    local service = self:getPurchaseService_(paytype)
    service:prepareEditBox(input1, input2, submitBtn)
end

function StorePopupController:onInputCardInfo(paytype, productType, input1, input2, submitBtn)
    local service = self:getPurchaseService_(paytype)

    service:onInputCardInfo(productType, paytype.pmode, input1, input2, submitBtn, handler(self, self.purchaseResult_))
end

function StorePopupController:purchaseResult_(succ, result)
    if succ then
        if nk.userData.firstPay and nk.userData.firstpayData and nk.userData.marketData then
            self:removeFirstPayData(nk.userData.firstpayData, nk.userData.marketData)
            nk.userData.firstpayData = nil
            if self.view_ then
                self.view_:hidePanel()
            end
            
        end
        nk.userData.firstPay = false
        self.history_ = nil
        self:loadHistory()
        bm.EventCenter:dispatchEvent(nk.eventNames.ROOM_REFRESH_HDDJ_NUM)
        
        -- FIXME:没有上报具体的金额
        -- 上报广告平台 支付成功
        -- nk.AdSdk:reportPay("0.00", "HKD")

        local userData = nk.userData
        local monitorMoney = userData.money
        local retryTimes = 4
        local monitorMoneyChange
        monitorMoneyChange = function()
            bm.HttpService.POST({mod="user", act="getUserProperty"}, function(ret)
                    local js = json.decode(ret)
                    if js then
                        if js.money ~= monitorMoney then
                            userData.money = js.money
                            return
                        end
                    end
                    retryTimes = retryTimes - 1
                    if retryTimes > 0 then
                        self.schedulerPool_:delayCall(monitorMoneyChange, 10)
                    end
                end, function()
                    retryTimes = retryTimes - 1
                    if retryTimes > 0 then
                        self.schedulerPool_:delayCall(monitorMoneyChange, 10)
                    end
                end)
        end
        monitorMoneyChange()

        --更新互动道具数量
        bm.HttpService.POST(
            {
                mod = "user", 
                act = "getUserFun"
            }, 
            function (data)
                userData.hddjNum = tonumber(data)
            end
        )
    else
        if result == "AppPurchaseError" then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "PURCHASE_FAILED_MSG"))
        end
    end
end

function StorePopupController:loadHistory()
    if self.history_ then
        if #self.history_ > 0 then
            self:setHistoryList_(true, self.history_)
        else
            self:setHistoryList_(true, bm.LangUtil.getText("STORE", "NO_BUY_HISTORY_HINT"))
        end
    elseif self.isHistoryLoading_ then
        self:setHistoryList_(false)
    else
        self.isHistoryLoading_ = true
        self:setHistoryList_(false)
        self.loadHistoryRequestId_ = bm.HttpService.POST({mod="Payment", act="getPaymentRecord", channel=nk.userData.channel}, function(data)
                self.loadHistoryRequestId_ = nil
                self.isHistoryLoading_ = false
                local jarray = json.decode(data)
                self.history_ = jarray
                if jarray then
                    if #jarray > 0 then
                        self:setHistoryList_(true, jarray)
                    else
                        self:setHistoryList_(true, bm.LangUtil.getText("STORE", "NO_BUY_HISTORY_HINT"))
                    end
                else
                    self:setHistoryList_(true, bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
                end
            end,
            function()
                self.loadHistoryRequestId_ = nil
                self.isHistoryLoading_ = false
                self:setHistoryList_(true, bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
            end)
    end
end

function StorePopupController:setHistoryList_(isComplete, listdata)
    bm.EventCenter:dispatchEvent({
        name = "setStoreHistoryList",
        data = {isComplete = isComplete, list = listdata}
    })
end

function StorePopupController:combineFirstPayData(firstpayData_, marketData_)
    if firstpayData_ and marketData_ then
        for i, p in ipairs(marketData_.payTypes) do
            for j = 1, #firstpayData_ do
                if p.pmode == firstpayData_[j].pmode then
                    p.goods[#p.goods] = firstpayData_[j]
                end
            end
        end
    end

end

function StorePopupController:removeFirstPayData(firstpayData_, marketData_)
    if firstpayData_ and marketData_ then
        for i, p in ipairs(marketData_.payTypes) do
            for j = 1, #firstpayData_ do
                if p.pmode == firstpayData_[j].pmode then
                    for m = 1, #p.goods do
                        if p.goods[m].id == firstpayData_[j].id then
                            p.goods[m] = nil
                        end
                    end
                end
            end
        end
    end
end

function StorePopupController:init()
    if nk.userData.firstPay and nk.userData.firstpayData and nk.userData.marketData then
        self:combineFirstPayData(nk.userData.firstpayData, nk.userData.marketData)
    else
        self:removeFirstPayData(nk.userData.firstpayData, nk.userData.marketData)
    end
    self:loadPayConfig()
end

function StorePopupController:dispose()
    if self.loadHistoryRequestId_ then
        bm.HttpService.CANCEL(self.loadHistoryRequestId_)
        self.loadHistoryRequestId_ = nil
    end

    self.manager_:autoDispose()
    self.view_ = nil
end

return StorePopupController
