function __G__TRACKBACK__(errorMessage)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback("", 2))
    print("----------------------------------------")
    -- if nk and nk.OnOff then
    --     local isReport = nk.OnOff:checkReportError("clientLog")
    --     if isReport and nk.http and nk.http["getDefaultURL"] then
    --             local defaultUrl = nk.http.getDefaultURL()
    --             if defaultUrl ~= nil and (type(defaultUrl) == "string") and string.len(defaultUrl) > 0 then
    --                 local str = (tostring(errorMessage) or "") .. "|" .. (debug.traceback() or "")
    --                 if str and string.len(str) > 0 then
    --                     str = string.gsub(str,"[%c%s]","")
    --                     str = string.gsub(str,"\"","")
    --                     nk.http.reportError(str)
    --                 end

    --             end

    --     end

    -- end

    if CF_DEBUG > 0 and app then
        local errorinfo = tostring(errorMessage).."\n"..debug.traceback("", 2)
        local scene = display.getRunningScene()
        if scene then
            if not errorInfo_ then
                errorInfo_ = ui.newTTFLabel({
                    text = "",
                    font = "Arial.ttf",
                    size = 20,
                    x = display.cx,
                    y = display.cy,
                    color=cc.c3b(0xff,0x00,0x00),
                    align = ui.TEXT_ALIGN_LEFT,
                    dimensions = cc.size(display.width,display.height)
                }):addTo(scene, 9900);
            end
            errorInfo_:setString(errorinfo)
        end    
    end

end

-- 注: 本文件在AppDelegate::applicationDidFinishLaunching() 函数中执行

require("umeng_boot")
require("config")
require("framework.init")
require("cocos.init")

_G.appconfig = require("appconfig")
if device.platform == "ios" then
    require("update.UpdateController").new()
else
    require("welcome.WelcomeController").new()
end
-- require("update.UpdateController").new()
-- require("welcome.WelcomeController").new()
