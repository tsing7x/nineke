--
-- Author: johnny@boomegg.com
-- Date: 2014-07-30 16:17:52
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local LuaOCBridge = class("LuaOCBridge")
local logger = bm.Logger.new("LuaOCBridge")

function LuaOCBridge:ctor()
end

function LuaOCBridge:vibrate(time)
    cc.Native:vibrate()
end

function LuaOCBridge:showSMSView(content)
    luaoc.callStaticMethod("LuaOCBridge", "showSMSView", {
        content = content,
        cannotCallback = handler(self, self.cannotShowSMSView_)
    })
end

function LuaOCBridge:cannotShowSMSView_()
    nk.ui.Dialog.new({
        messageText = bm.LangUtil.getText("FRIEND", "CANNOT_SEND_SMS"),
        secondBtnText = bm.LangUtil.getText("COMMON", "CONFIRM")
    })
        :show()
end

function LuaOCBridge:showEmailView(subject, content)
    luaoc.callStaticMethod("LuaOCBridge", "showMAILView", {
        subject = subject,
        content = content,
        cannotCallback = handler(self, self.cannotShowMAILView_)
    })
end

function LuaOCBridge:cannotShowMAILView_()
    nk.ui.Dialog.new({
        messageText = bm.LangUtil.getText("FRIEND", "CANNOT_SEND_MAIL"),
        firstBtnText = bm.LangUtil.getText("COMMON", "CANCEL"),
        secondBtnText = bm.LangUtil.getText("COMMON", "CONFIRM"),
        callback = function (type)
            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                CCNative:openURL("mailto:")
            end
        end
    })
        :show()
end

function LuaOCBridge:showLineView(content, callback)
    luaoc.callStaticMethod("LuaOCBridge", "showLineView", {
        content = content,
        cannotCallback = callback
    })
end

function LuaOCBridge:pickImage(callback)
    self.pickImageCallback_ = callback
    luaoc.callStaticMethod("LuaOCBridge", "showImagePicker", {pickedImageCallback = handler(self, self.onPickedImage_)})
end

function LuaOCBridge:onPickedImage_(imagePath)
    logger:debugf("imagePath: %s", imagePath)
    if self.pickImageCallback_ then
        if imagePath and imagePath ~= "" then
            self.pickImageCallback_(true, imagePath)
        else
            self.pickImageCallback_(false, imagePath)
        end
    end
end

function LuaOCBridge:pickupPic(callback)
    self.pickupPicCallback_ = callback
    luaoc.callStaticMethod("LuaOCBridge", "pickupPic", {pickedImageCallback = handler(self, self.onPickupPic_)})
end

function LuaOCBridge:onPickupPic_(imagePath)
    logger:debugf("imagePath: %s", imagePath)
    if self.pickupPicCallback_ then
        if imagePath and imagePath ~= "" then
            self.pickupPicCallback_(true, imagePath)
        else
            self.pickupPicCallback_(false, "")
        end
    end
end

function LuaOCBridge:getFixedWidthText(fontName, fontSize, text, fixedWidth)
    local ok, fixedString = luaoc.callStaticMethod(
        "LuaOCBridge",
        "getFixedWidthText",
        {
            text = text,
            fixedWidth = fixedWidth,
            fontName = fontName,
            fontSize = fontSize,
        }
    )
    if ok then
        return fixedString
    else
        return text
    end
end

function LuaOCBridge:CheckPackageExist(packageName)
    return true
end

function LuaOCBridge:getLoginToken()
    local openUdid = nk.userDefault:getStringForKey("OPEN_UDID")
    if not openUdid or openUdid == "" then
        --- DOC
        -- 解决iOS游客玩家卸载应用之后，唯一id丢失，无法找回原来的帐号
        -- 尝试从持久存储中获取UDID，找不到就把保存新生成的
        local ok
        openUdid = device.getOpenUDID()
        ok, openUdid = luaoc.callStaticMethod(
            'LuaOCBridge',
            'tryLoadOpenUDID',
            { openUdid }
        )
        if ok then
            nk.userDefault:setStringForKey("OPEN_UDID", openUdid)
            nk.userDefault:flush()
        else
            print 'error! tryLoadOpenUDID failed!'
        end
    else
        -- 确保旧版本中未在'卸载安全位置'保存的udid保存好.
        luaoc.callStaticMethod(
            'LuaOCBridge',
            'assureSaveOpenUDID',
            { openUdid }
        )
    end
    --"C6:6A:B7:61:7E:C7".."_abctest"
    return crypto.encodeBase64(openUdid .. "_abctest")
end

function LuaOCBridge:getAppVersion()
    local ok, version = luaoc.callStaticMethod(
        "LuaOCBridge",
        "getAppVersion", nil)
    return ok and version or '1.0.0'
end

function LuaOCBridge:getChannelId()
    return "AppStore"
end

function LuaOCBridge:getByChannelId()
    return "AppStore"
end

function LuaOCBridge:getDeviceInfo()
    local deviceInfo = {deviceId = "", deviceName = "", deviceModel = "", installInfo = "", cpuInfo = "", ramSize = "", simNum = "", networkType = "", osVersion = "", phoneNumbers = "", location = ""}
    local ok, deviceInfoJson = luaoc.callStaticMethod(
        "LuaOCBridge",
        "getDeviceInfo", nil)
    if ok then
        deviceInfo = json.decode(deviceInfoJson)
    end

    local ret = {
        deviceId    = device.getOpenUDID(),
        deviceName  = deviceInfo.deviceName or "",
        deviceModel = deviceInfo.deviceModel or "",
        installInfo = deviceInfo.installInfo or "",
        cpuInfo     = deviceInfo.cpuInfo or "",
        ramSize     = deviceInfo.ramSize or "",
        simNum      = deviceInfo.simNum or "",
        networkType = network.getInternetConnectionStatus(),
        osVersion   = deviceInfo.osVersion or "",
        phoneNumbers = deviceInfo.phoneNumbers or "",
        location = deviceInfo.location or ""
    }

    return ret
end

function LuaOCBridge:getBatteryInfo(callback)
    local ok, result = luaoc.callStaticMethod("LuaOCBridge","getBatteryInfo",nil)
    print("result is :" .. result)
    if ok then
        callback(result)
    else
        callback(0)
    end
end

function LuaOCBridge:getMacAddr()
    return nil
end

function LuaOCBridge:getStartType()
    return -1
end
function LuaOCBridge:getPushCode()
    return nil
end

function LuaOCBridge:getIDFA()
    local ok, r = luaoc.callStaticMethod("LuaOCBridge", "getiOSIDFA", nil)
    return ok and r or 'getiOSIDFA_nil'
end

-- 粘贴到剪贴板
function LuaOCBridge:setClipboardText(content)
    luaoc.callStaticMethod("LuaOCBridge", "setClipboardText", {content})
end

function LuaOCBridge:isAppInstalled(packageName)
    packageName = packageName or ""
    --暂无需求，return false
    return false
end

-- 截图
function LuaOCBridge:screenShot(callback,x,y,w,h)
    -- self:call_("com/boomegg/nineke/ScreenShotUtil", "screenShot", {function(result)
    --         logger:debug("screenShot result:", result)
            if callback then
                callback(1)
            end
    --     end,x,y,w,h}, "(I;I;I;I;I)V")
end

-- 刷新路径
function LuaOCBridge:updateMediaStore(filePath,fileName,callback)
    -- self:call_("com/boomegg/nineke/ScreenShotUtil", "updateMediaStore", {filePath,fileName,function(result)
    --         logger:debug("updateMediaStore result:", result)
            if callback then
                callback(1)
            end
    --     end}, "(Ljava/lang/String;Ljava/lang/String;I)V")
end

-- 打开商城WebView
function LuaOCBridge:openWebview(url, callback)
    if callback then
        callback(1)
    end
end
-- 移除商城WebView
function LuaOCBridge:removeWebView()
    
end

return LuaOCBridge
