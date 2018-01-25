
local Store = class("Store")
local logger = bm.Logger.new("Store")

Store.LOAD_PRODUCTS_FINISHED    = "LOAD_PRODUCTS_FINISHED"
Store.TRANSACTION_PURCHASED     = "TRANSACTION_PURCHASED"
Store.TRANSACTION_RESTORED      = "TRANSACTION_RESTORED"
Store.TRANSACTION_FAILED        = "TRANSACTION_FAILED"
Store.TRANSACTION_UNKNOWN_ERROR = "TRANSACTION_UNKNOWN_ERROR"

local isSimulated = (device.platform == "windows")

function Store:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    if not isSimulated then
        self.provider = require("framework.cc.sdk.Store")
        if self.provider then
            self.provider.init(handler(self, self.transactionCallback))
            self.provider.setReceiptVerifyMode(cc.CCStoreReceiptVerifyModeNone, IS_SANDBOX)
        end
    end
    self.products = {}
end

function Store:canMakePurchases()
    if isSimulated then
        return true
    else
        return self.provider.canMakePurchases()
    end
end

function Store:loadProducts(productsId)
    if isSimulated then
        self:dispatchEvent({
            name = Store.LOAD_PRODUCTS_FINISHED,
            products = {{}},
            invalidProducts = {}
        })
    else
        self.provider.loadProducts(productsId, function(event)
            self.products = {}
            for _, product in ipairs(event.products) do
                self.products[product.productIdentifier] = clone(product)
            end

            self:dispatchEvent({
                name = Store.LOAD_PRODUCTS_FINISHED,
                products = event.products,
                invalidProducts = event.invalidProducts
            })
        end)
    end
end

function Store:getProductDetails(productId)
    local product = self.products[productId]
    if product then
        return clone(product)
    else
        return nil
    end
end

function Store:cancelLoadProducts()
    if not isSimulated then
        self.provider.cancelLoadProducts()
    end
end

function Store:isProductLoaded(productId)
    if isSimulated then
        return true
    else
        return self.provider.isProductLoaded(productId)
    end
end

function Store:purchaseProduct(productId)
    logger:debug("purchase product ", productId)
    if isSimulated then
        self:transactionCallback({
            transaction = {
                state = "purchased",
                productIdentifier = productId,
                quantity = 1,
                transactionIdentifier = "fakeIdentifier",
                receipt = "",
            }
         })
    else
        self.provider.purchase(productId)
    end
end

function Store:transactionCallback(event)
    local transaction = event.transaction
    if transaction.state == "purchased" then
        logger:debug("Transaction succuessful!")
        logger:debug("productIdentifier", transaction.productIdentifier)
        logger:debug("quantity", transaction.quantity)
        logger:debug("transactionIdentifier", transaction.transactionIdentifier)
        logger:debug("date", os.date("%Y-%m-%d %H:%M:%S", transaction.date))
        logger:debug("receipt", transaction.receipt)
        self:dispatchEvent({
            name = Store.TRANSACTION_PURCHASED,
            transaction = transaction,
        })
    elseif  transaction.state == "restored" then
        logger:debug("Transaction restored (from previous session)")
        logger:debug("productIdentifier", transaction.productIdentifier)
        logger:debug("receipt", transaction.receipt)
        logger:debug("transactionIdentifier", transaction.identifier)
        logger:debug("date", transaction.date)
        logger:debug("originalReceipt", transaction.originalReceipt)
        logger:debug("originalTransactionIdentifier", transaction.originalIdentifier)
        logger:debug("originalDate", transaction.originalDate)
        self:dispatchEvent({
            name = Store.TRANSACTION_RESTORED,
            transaction = transaction,
        })
    elseif transaction.state == "failed" then
        logger:debug("Transaction failed")
        logger:debug("errorCode", transaction.errorCode)
        logger:debug("errorString", transaction.errorString)
        self:dispatchEvent({
            name = Store.TRANSACTION_FAILED,
            transaction = transaction,
        })
    else
        logger:debug("unknown event")
        self:dispatchEvent({
            name = Store.TRANSACTION_UNKNOWN_ERROR,
            transaction = transaction,
        })
    end
end

function Store:finishTransaction(transaction)
    if not isSimulated then
        self.provider.finishTransaction(transaction)
    end
end

function Store:restore()
    if not isSimulated then
        self.provider.restore()
    end
end

return Store
