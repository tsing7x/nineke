--
-- Author: tony
-- Date: 2014-07-28 11:34:41
--

local LuaJavaBridge = class("LuaJavaBridge")
local logger = bm.Logger.new("LuaJavaBridge")

function LuaJavaBridge:ctor()
end

function LuaJavaBridge:call_(javaClassName, javaMethodName, javaParams, javaMethodSig)
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

function LuaJavaBridge:getMac()
    local ok, ret = self:call_("com/boomegg/cocoslib/core/functions/GetMacFunction", "apply", {}, "()Ljava/lang/String;")
    if ok then
        return ret
    end
    return nil
end

function LuaJavaBridge:getMacAddr()
    local ok, ret = self:call_("com/boomegg/cocoslib/core/functions/GetMacFunction", "getMacAddr", {}, "()Ljava/lang/String;")
    if ok then
        return ret
    end
    return nil
end

function LuaJavaBridge:getStartType()
    local ok, ret = self:call_("com/boomegg/nineke/NineKe", "getPushType", {}, "()I")
    if ok then
        return ret
    end
    return -1
end
function LuaJavaBridge:getPushCode()
    local ok, ret = self:call_("com/boomegg/nineke/NineKe", "getPushCode", {}, "()Ljava/lang/String;")
    if ok then
        return ret
    end
    return nil
end

function LuaJavaBridge:getIDFA()
    local deviceInfo = self:getDeviceInfo()
    return deviceInfo.deviceId or self:getMacAddr() or 'android_idfa_nil'
end

function LuaJavaBridge:vibrate(time)
    self:call_("com/boomegg/cocoslib/core/functions/VibrateFunction", "apply", {time}, "(I)V")
end


function LuaJavaBridge:getFixedWidthText(font, size, text, width)
    local ok, ret = self:call_("com/boomegg/cocoslib/core/functions/GetFixedWidthTextFunction", "apply", {font or "", size or 20, text or "", width or device.display.widthInPixels}, "(Ljava/lang/String;ILjava/lang/String;I)Ljava/lang/String;")
    if ok then
        return ret or ""
    end
    return ""
end

function LuaJavaBridge:CheckPackageExist(packageName)
    local ok, ret = self:call_("com/boomegg/cocoslib/core/functions/CheckPackageExist", "apply",{packageName or ""},"(Ljava/lang/String;)Z")
    if ok then
        return ret or false
    end
    return false
end

function LuaJavaBridge:pickImage(callback)
    self:call_("com/boomegg/cocoslib/core/functions/PickImageFunction", "apply", {function(result)
            logger:debug("pickImage result:", result)
            if callback then
                if result == "nosdcard" then
                    callback(false, "nosdcard")
                elseif result == "error" then
                    callback(false, "error")
                else
                    callback(true, result)
                end
            end
        end}, "(I)V")
end

function LuaJavaBridge:pickupPic(callback)
    self:call_("com/boomegg/cocoslib/core/functions/PickupPicFunction", "apply", {function(result)
            logger:debug("pickupPic result:", result)
            if callback then
                if result == "nosdcard" then
                    callback(false, "nosdcard")
                elseif result == "error" then
                    callback(false, "error")
                else
                    callback(true, result)
                end
            end
        end}, "(I)V")
end

function LuaJavaBridge:getAppVersion()
    local ok, ret = self:call_("com/boomegg/cocoslib/core/functions/GetAppVersionFunction", "apply", {}, "()Ljava/lang/String;")
    return ok and ret or '1.0.0'
end

function LuaJavaBridge:getDeviceInfo()
    local deviceInfo = {deviceId = "", deviceName = "", deviceModel = "", installInfo = "", cpuInfo = "", ramSize = "", simNum = "", networkType = "", osVersion = "", phoneNumbers = "", location = ""}
    local ok, ret = self:call_("com/boomegg/cocoslib/core/functions/GetDeviceInfoFunction", "apply", {}, "()Ljava/lang/String;")
    if ok and ret ~= "" then
        deviceInfo = json.decode(ret)
    end
    local ret = { 
            deviceId = deviceInfo.deviceId,
            deviceName = deviceInfo.deviceName,
            deviceModel = deviceInfo.deviceModel,
            installInfo = deviceInfo.installInfo,
            cpuInfo = deviceInfo.cpuInfo,
            ramSize = deviceInfo.ramSize,
            simNum = deviceInfo.simNum,
            networkType = deviceInfo.networkType,
            osVersion = deviceInfo.deviceModel,
            phoneNumbers = deviceInfo.phoneNumbers,
            location = deviceInfo.location
    }
    return ret
end

function LuaJavaBridge:showSMSView(content)
    self:call_("com/boomegg/cocoslib/core/functions/ShowSMSViewFunction", "apply", {content}, "(Ljava/lang/String;)V")
end

function LuaJavaBridge:showEmailView(subject, content)
    self:call_("com/boomegg/cocoslib/core/functions/ShowEmailViewFunction", "apply", {subject,content}, "(Ljava/lang/String;Ljava/lang/String;)V")
end

function LuaJavaBridge:showLineView(content, callback)
    self:call_("com/boomegg/cocoslib/core/functions/ShowLineViewFunction", "apply", {content, function(result)
        logger:debug("showLineView result:", result)
        if callback then
            callback(result)
        end
    end}, "(Ljava/lang/String;I)V")
end

function LuaJavaBridge:getLoginToken()
    return crypto.encodeBase64(self:getMac() .. "_abctest")
end

function LuaJavaBridge:getChannelId()
    local ok, ret = self:call_("com/boomegg/cocoslib/core/functions/GetChannelIdFunction", "apply", {}, "()Ljava/lang/String;")
    if ok then
        return ret or "GooglePlay"
    end
    return "GooglePlay"
end
function LuaJavaBridge:getByChannelId()
    local ok, ret = self:call_("com/boomegg/cocoslib/core/functions/GetByChannelIdFunction", "apply", {}, "()Ljava/lang/String;")
    if ok then
        return ret or ""
    end
    return ""
end
-- 粘贴到剪贴板
function LuaJavaBridge:setClipboardText(content)
    self:call_("com/boomegg/cocoslib/core/functions/ClipboardManagerFunction", "apply", {content}, "(Ljava/lang/String;)V")
end

function LuaJavaBridge:isAppInstalled(packageName)
    packageName = packageName or ""
    local ok, ret = self:call_("com/boomegg/cocoslib/core/functions/GetPackageInfoFunction", "isAppInstalled", {packageName}, "(Ljava/lang/String;)Ljava/lang/String;")
    if ok then
        if not ret or ret == "" then
            return false,nil
        end
        -- flag: 是否安装查询的应用
        --firstInstallTime: 初次安装时间
        --lastUpdateTime: 最近更新应用时间
        local packInfo = json.decode(ret)
        if not packInfo then
            return false,nil
        end
        return (packInfo.flag == "true" and true or false),packInfo
    

    end
    return false,nil
    
end

-- 返回值
-- nil:未安装 
-- true:成功调用方法
-- false:未成功调用方法
function LuaJavaBridge:launchApp(packageName)
    packageName = packageName or ""
    local isAppInstalled = self:isAppInstalled(packageName)

    if not isAppInstalled then
        return nil
    end

    local ok, ret = self:call_("com/boomegg/cocoslib/core/functions/GetPackageInfoFunction", "launchApp", {packageName}, "(Ljava/lang/String;)V")
    return ok
end

-- 获取电量
function LuaJavaBridge:getBatteryInfo(callback)
    self:call_("com/boomegg/cocoslib/core/functions/BatteryFunction", "apply", {function(result)
            logger:debug("pickupPic result:", result)
            if callback then
                callback(result)
            end
        end}, "(I)V")
end

-- 获取网络类型
function LuaJavaBridge:getNetWorkType(callback)
    self:call_("com/boomegg/cocoslib/core/functions/GetNetWorkTypeFunction", "apply", {function(result)
            logger:debug("pickupPic result:", result)
            if callback then
                callback(result)
            end
        end}, "(I)V")
end

-- 截图
function LuaJavaBridge:screenShot(callback,x,y,w,h)
    self:call_("com/boomegg/nineke/ScreenShotUtil", "screenShot", {function(result)
            logger:debug("screenShot result:", result)
            if callback then
                callback(result)
            end
        end,x,y,w,h}, "(IIIII)V")
end

-- 刷新路径
function LuaJavaBridge:updateMediaStore(filePath,fileName,callback)
    self:call_("com/boomegg/nineke/ScreenShotUtil", "updateMediaStore", {filePath,fileName,function(result)
            logger:debug("updateMediaStore result:", result)
            if callback then
                callback(result)
            end
        end}, "(Ljava/lang/String;Ljava/lang/String;I)V")
end

-- 打开商城WebView
function LuaJavaBridge:openWebview(url, callback, dw, dh, tip, isShowBg, isShowClose)
    local w = dw;
    local h = dh;
    if not dw or not dh then
        local glview = cc.Director:getInstance():getOpenGLView()
        local size = glview:getFrameSize()
        w = size.width
        h = size.height
    end
    -- 
    isShowBg = isShowBg or 1; -- 0为不显示，1为显示
    isShowClose = isShowClose or 1; -- 0为不显示，1为显示
    -- 
    local key = "NineKe"
    tip = tip or "loading......"
    self:call_("com/boomegg/nineke/"..key, "openWebview", {url, tip, w, h, isShowBg, isShowClose, function(result)
            logger:debug("openWebview result:", result)
            if callback then
                callback(result)
            end
            nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
        end}, "(Ljava/lang/String;Ljava/lang/String;IIIII)V")
end
-- 移除商城WebView
function LuaJavaBridge:removeWebView()
    print("NineKe removeAllWebView::client");
    self:call_("com/boomegg/nineke/NineKe", "removeAllWebView", {}, "()V")
end

return LuaJavaBridge
