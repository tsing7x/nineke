--
-- Author: tony
-- Date: 2014-08-24 15:17:41
--
local GoogleCloudMessaging = class("GoogleCloudMessaging")
local logger = bm.Logger.new("GoogleCloudMessaging")

function GoogleCloudMessaging:ctor()
    self:call_("setRegisteredCallback", {handler(self, self.registerCallback_)}, "(I)V")
end

function GoogleCloudMessaging:register(callback)
    self.callback_ = callback
    self:call_("register", {}, "()V")
end

function GoogleCloudMessaging:registerCallback_(jsonString)
    logger:debug(jsonString)
    local jsonTbl = json.decode(jsonString)
    local stype = jsonTbl.type
    local success = jsonTbl.success
    local detail = jsonTbl.detail
    if stype == "REG" and self.callback_ then
        self.callback_(success, detail)
    end
end

function GoogleCloudMessaging:call_(javaMethodName, javaParams, javaMethodSig)
    if device.platform == "android" then
        local ok, ret = luaj.callStaticMethod("com/boomegg/cocoslib/gcm/GoogleCloudMessagingBridge", javaMethodName, javaParams, javaMethodSig)
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

return GoogleCloudMessaging