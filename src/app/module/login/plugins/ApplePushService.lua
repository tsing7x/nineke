--
-- Author: johnny@boomegg.com
-- Maintainer: DavidFeng
-- Date: 2014-08-29 14:22:13
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local ApplePushService = class("ApplePushService")

function ApplePushService:ctor()
end

--- 注册回调来获取push token
function ApplePushService:register(callback)
    assert(callback, 'callback is nil')
    local ok, pushToken = luaoc.callStaticMethod("LuaOCBridge", "getPushToken")
    if ok then
        if pushToken and pushToken ~= "" then
            pushToken = string.gsub(pushToken, " ", "")
            pushToken = string.gsub(pushToken, "<", "")
            pushToken = string.gsub(pushToken, ">", "")
            callback(true, pushToken)
        else
            print "[LuaOCBridge getPushToken] return ''"
            callback(false, '')
        end
    else
        print('call [LuaOCBridge getPushToken] error')
    end
end

--- 添加本地通知消息
function ApplePushService:addLocalNotification(seconds, message)
    local ok = luaoc.callStaticMethod('LuaOCBridge', 'addLocalNotification', {
        seconds = seconds,
        message = message,
    })
    if not ok then print 'iOS addLocalNotification failed' end
end

return ApplePushService
