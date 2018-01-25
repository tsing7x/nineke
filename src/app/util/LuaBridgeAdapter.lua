--
-- Author: tony
-- Date: 2014-07-30 14:21:29
--
local LuaBridgeAdapter = {}

local mtable = {
    __index = function(table, key)
        if LuaBridgeAdapter[key] then
            return LuaBridgeAdapter[key]
        else
            return function(...)
                local params = {...}
                for i, v in ipairs(params) do
                    params[i] = tostring(v)
                end
                print("CALL FUNCTION " .. key, unpack(params))
            end
        end
    end,
    __newindex = function(table, key, value)
        error("invalid set data to LuaBridgeAdapter")
    end
}

function LuaBridgeAdapter:getFixedWidthText(font, size, text, width)
    return bm.limitNickLength(text, 13)
end

function LuaBridgeAdapter:CheckPackageExist(packageName)
    return true
end


function LuaBridgeAdapter:getLoginToken()
    -- NOTE: 这里的_abctest不能修改, web服务器对此有要求
    --[[
    -- 示例PlayerUUID.lua 本文件被git仓库忽略
    -- 实现本地有一份唯一的string作为player的uuid
    -- davidxifeng July 2, 2015
    return 'F1:BC:AD:5S:5C:A8'
    --]]
    local ok, local_uuid_string = pcall(require, 'app.util.PlayerUUID')
    if not ok then
        -- local_uuid_string = "A4:6A:B7:51:6A:A2"
        -- local_uuid_string = "A4:6A:B7:51:7A:A1"
        -- local_uuid_string = "A5:2A:B7:51:7A:A111"
        -- local_uuid_string = "B4:6A:B7:51:7A:A8"
        -- local_uuid_string = "B4:6A:B7:5b:7c:A5"
        -- local_uuid_string = "B4:6A:B7:5b:7c:A9"--11074
        -- local_uuid_string = "B4:6A:B7:5b:7c:A1"-- 测试 11075
        -- local_uuid_string = "B4:6A:B7:5b:7c:b5"--11849
        -- local_uuid_string = "80:4e:81:b4:08:b0"--10846
        -- local_uuid_string = "94:fe:22:72:18:cb"--10666
        -- local_uuid_string = "B4:6A:B7:cb:cc:A9"
        -- local_uuid_string = "f4:6A:B7:5b:7c:A1"
        -- local_uuid_string = "1c:87:2c:ab:09:6b"
        -- local_uuid_string = "3968144223ae8e626ef696eb6673fbeaa3c63a0a" --IOS
        -- local_uuid_string = "B4:6A:B7:5b:7f:A1"
        -- local_uuid_string = "8c:be:be:67:6b:82"
        -- local_uuid_string = "58:7A:66:C6:FC:3435"
        -- local_uuid_string = "58:7F:66:C6:FC:34"
        local_uuid_string = "A4:6A:B7:51:7A:A1"
        -- local_uuid_string = "f4:8b:32:71:4e:03" --zhiyong

        -- local_uuid_string = "C8:1F:66:22:E9:102"
        -- local_uuid_string = "C9-1F-66-22-E8-A0012"
        -- local_uuid_string = "4C9-1F-66-22-E8-A6"
        -- local_uuid_string = "C9-1F-66-22-E8-A3"
        -- local_uuid_string = "C9-1F-66-22-E8-A8224"
        -- local_uuid_string = "C9-1F-66-22-E8-A15"
        -- local_uuid_string = "A4:6A:B7:51:7b:A33513"

        -- local_uuid_string = "C8:1F:66:22:E9:102" --梅老板测试
        -- local_uuid_string = "B4:66:B7:5b:8c:A1"

        --wanjia
        -- local_uuid_string = "a0:f9:e0:1c:ec:09"
        -- local_uuid_string = "24:4b:81:fe:13:60" --8231808
        -- local_uuid_string = "a4:eb:d3:1b:66:9c"--10533654
        -- local_uuid_string = "ac:36:13:de:1f:0a"
        -- local_uuid_string = "84:2e:27:28:ac:42"
        -- local_uuid_string = "84:38:38:c2:a2:76"

    end
    return crypto.encodeBase64(local_uuid_string .. "_abctest")
end

function LuaBridgeAdapter:pickImage(callback)
    callback(false, "error")
end

function LuaBridgeAdapter:getChannelId()
    return "test"
end

function LuaBridgeAdapter:getByChannelId()
    return "test"
end

function LuaBridgeAdapter:getDeviceInfo()
    local upd = require("update.init")

    return {
        deviceId = "deviceId",
        deviceName = "deviceName",
        deviceModel = "deviceModel", 
        installInfo = "installInfo",
        cpuInfo = "cpuInfo",
        ramSize = "ramSize",
        simNum = "simNum",
        networkType = "networkType",
        location = "location",
        osVersion = upd.conf.CLIENT_VERSION
    }
end

function LuaBridgeAdapter:getMacAddr()
    return "getMacAddr"
end

function LuaBridgeAdapter:getStartType()
    return -1
end
function LuaBridgeAdapter:getPushCode()
    return nil
end

function LuaBridgeAdapter:isAppInstalled(packageName)
    packageName = packageName or ""
    

    local packInfo = {}
    packInfo.flag = "true"
    packInfo.firstInstallTime = "1435561512693"
    packInfo.lastUpdateTime = "1435561512153"
    
    return false, packInfo
    
end

function LuaBridgeAdapter:launchApp(packageName)
    return true
end

function LuaBridgeAdapter:showLineView(content, callback)
    local result = "showLineView test"
    if callback then
        callback(result)
    end
end

return setmetatable({}, mtable)
