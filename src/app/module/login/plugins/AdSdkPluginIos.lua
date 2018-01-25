--
-- Author: LeoLuo
-- Date: 2015-05-20 18:06:25
--
--

local AdSdkPluginIos = class("AdSdkPluginIos")
local logger = bm.Logger.new("AdSdkPluginIos")

function AdSdkPluginIos:ctor()
   
end

-- function AdSdkPluginIos:reportStart()

-- end

-- function AdSdkPluginIos:reportReg(uid)
-- 	luaoc.callStaticMethod("AdSdkBridge", "registerNewUser", {uid = uid})
-- end

-- function AdSdkPluginIos:reportLogin(uid)
--     luaoc.callStaticMethod("AdSdkBridge", "loginWithUserId", {uid = uid})
-- end

-- function AdSdkPluginIos:reportPlay()
--     luaoc.callStaticMethod("AdSdkBridge", "playGame")
-- end

-- function AdSdkPluginIos:reportPay(payMoney, currencyCode)
--     luaoc.callStaticMethod("AdSdkBridge", "purchase", {payMoney = payMoney, currencyCode = currencyCode})
-- end

-- function AdSdkPluginIos:reportRecall(fbid)
   
-- end

-- function AdSdkPluginIos:reportLogout()
--     self:reportCustom("userlogout", "")
-- end

-- function AdSdkPluginIos:reportCustom(eventName, eventValue)
--     luaoc.callStaticMethod("AdSdkBridge", "trackEvent", {eventName = eventName, eventValue = eventValue})
-- end

function AdSdkPluginIos:report(type,params)
    local data = params or {}
    data.type = type
    luaoc.callStaticMethod("AdSdkBridge", "report", data)
end

return AdSdkPluginIos
