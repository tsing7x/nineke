--
-- Author: viking@boomegg.com
-- Date: 2014-10-15 18:44:55
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local XinGePushAndroid = class("XinGePushAndroid")
local logger = bm.Logger.new("XinGePushAndroid")

function XinGePushAndroid:ctor()
    self:call_("setRegisteredCallback", {handler(self, self.registerCallback_)}, "(I)V")
end

--- 注册回调来获取push token
function XinGePushAndroid:register(callback)
    self.callback_ = callback
    self:call_("register", {}, "()V")
end

--- 添加本地通知消息
function XinGePushAndroid:addLocalNotification(seconds, message)
    print 'TODO: android local notification api'
end

--- 回调函数
-- Java代码中, XinGePushBridge 类 callRegisteredCallback 调用
-- 用来传递获取到的push token
function XinGePushAndroid:registerCallback_(jsonString)
    logger:debug(jsonString)
    local jsonTbl = json.decode(jsonString)
    local stype = jsonTbl.type
    local success = jsonTbl.success
    local detail = jsonTbl.detail
    if stype == "GOT_PUSH_TOKEN" and self.callback_ then
        self.callback_(success, detail)
    end
end

function XinGePushAndroid:call_(javaMethodName, javaParams, javaMethodSig)
    if device.platform == "android" then
        local ok, ret = luaj.callStaticMethod("com/boomegg/cocoslib/xinge/XinGePushBridge", javaMethodName, javaParams, javaMethodSig)
        if not ok then
            if ret == -1 then
                logger:errorf("call %s failed, -1 不支持的参数类型或返回值类型", javaMethodName)
            elseif ret == -2 then
                logger:errorf("call %s failed, -2 无效的签名", javaMethodName)
            elseif ret == -3 then
                logger:errorf("call %s failed, -3 没有找到指定的方法", javaMethodName)
            elseif ret == -4 then
                logger:errorf("call %s failed, -4 Java 方法执行时抛出了异常", javaMethodName)
            elseif ret == -5 then
                logger:errorf("call %s failed, -5 Java 虚拟机出错", javaMethodName)
            elseif ret == -6 then
                logger:errorf("call %s failed, -6 Java 虚拟机出错", javaMethodName)
            end
        end
        return ok, ret
    else
        logger:debugf("call %s failed, not in android platform", javaMethodName)
        return false, nil
    end
end

return XinGePushAndroid
