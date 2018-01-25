--
-- Author: Jonah0608@gmail.com
-- Date: 2015-05-05 12:00:52
--
local AdSdkPluginAdapter = class("AdSdkPluginAdapter")
local logger = bm.Logger.new("AdSdkPluginAdapter")

function AdSdkPluginAdapter:ctor()
end

-- function AdSdkPluginAdapter:reportStart()
--     logger:debug("reportStart")
-- end

-- function AdSdkPluginAdapter:reportReg()
--     logger:debug("reportReg")
-- end

-- function AdSdkPluginAdapter:reportLogin()
--     logger:debug("reportLogin")
-- end

-- function AdSdkPluginAdapter:reportPlay()
--     logger:debug("reportPlay")
-- end

-- function AdSdkPluginAdapter:reportPay(payMoney,currencyCode)
--     logger:debug("reportPay: payMoney:" .. payMoney .. " currencyCode:" .. currencyCode)
-- end

-- function AdSdkPluginAdapter:reportRecall(fbid)
--     logger:debug("reportRecall: fbid:" .. fbid)
-- end

-- function AdSdkPluginAdapter:reportLogout()
--      logger:debug("reportLogout")
-- end

-- function AdSdkPluginAdapter:reportCustom(eCustom)
--     logger:debug("reportCustom")
-- end

function AdSdkPluginAdapter:report(type,params)
    local data = params or {}
    data.type = type
    dump(data)
end

return AdSdkPluginAdapter