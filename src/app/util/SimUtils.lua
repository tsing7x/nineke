--
-- Author: Jonah0608@gmail.com
-- Date: 2015-10-20 16:47:31
--
local SimUtils = class("SimUtils")
local logger = bm.Logger.new("SimUtils")

function SimUtils:ctor()
end

function SimUtils:call_(javaMethodName, javaParams, javaMethodSig)
    local javaClassName = "com/boomegg/cocoslib/core/utils/SimUtils"
    if device.platform == "android" then
        local ok, ret = luaj.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
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

function SimUtils:haveSimCard()
    local ok, ret = self:call_("isE2PSupported",{}, "()Z")
    if ok then
        return ret or false
    else
        return false
    end
end

function SimUtils:isE2PSupported()
    local ok, ret = self:call_("isE2pSupported",{}, "()Z")
    if ok then
        return ret or false
    else
        return false
    end
end

return SimUtils