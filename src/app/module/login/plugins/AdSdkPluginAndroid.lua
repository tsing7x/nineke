--
-- Author: Jonah0608@gmail.com
-- Date: 2015-05-05 11:47:47
--
local AdSdkPluginAndroid = class("AdSdkPluginAndroid")
local logger = bm.Logger.new("AdSdkPluginAndroid")

function AdSdkPluginAndroid:ctor()
    self:call_("setFbAppId", { appconfig.ADSDK_FBAPPID_ANDROID }, "(Ljava/lang/String;)V")
end

function AdSdkPluginAndroid:report(type,params)
    local data = params or {}
    data.type = type
    self:call_("report",{json.encode(data)},"(Ljava/lang/String;)V")
end

function AdSdkPluginAndroid:call_(javaMethodName, javaParams, javaMethodSig)
    if device.platform == "android" then
        local ok, ret = luaj.callStaticMethod("com/boomegg/cocoslib/adsdk/AdSdkBridge", javaMethodName, javaParams, javaMethodSig)
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

return AdSdkPluginAndroid
