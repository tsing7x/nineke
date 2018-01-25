--
-- Date: 2014-11-03 15:52:13
--

local updateConfig = {}

local func = require("update.functions")

updateConfig.DEBUG                 = false
-- NOTE: 开发模式下,可以设置不启用热更新检查
if DEBUG == 0 then
    updateConfig.ENABLED           = true
else
    updateConfig.ENABLED           = false
end
-- updateConfig.ENABLED = true
updateConfig.DEBUG_SVR_VERSION     = nil --覆盖mobilespecial返回的服务端版本号
updateConfig.DEBUG_VERSION         = "10.0.0" --客户端版本(Player运行取这个)
updateConfig.CLIENT_VERSION        = func.getAppVersion() or updateConfig.DEBUG_VERSION
updateConfig.SKIT_UPDATE_TIMES_KEY = "SKIT_UPDATE_TIMES_KEY" .. updateConfig.CLIENT_VERSION
updateConfig.UPDATE_DIR            = device.writablePath .. "upd/"
updateConfig.UPDATE_RES_DIR        = updateConfig.UPDATE_DIR .. "res/"
updateConfig.UPDATE_RES_TMP_DIR    = updateConfig.UPDATE_DIR .. "restmp/"
updateConfig.UPDATE_LIST_FILE_NAME = "flist" .. updateConfig.CLIENT_VERSION
updateConfig.UPDATE_LIST_FILE      = updateConfig.UPDATE_DIR .. updateConfig.UPDATE_LIST_FILE_NAME
if DEBUG ~= 0 then
	updateConfig.UPDATE_LIST_FILE_NAME = "testflist" .. updateConfig.CLIENT_VERSION
end
if device.platform == "ios" then
    updateConfig.SERVER_FILE_URL_FMT = appconfig.UPDATE_RESOURCE_URL_IOS ..
        "%s?dev=" .. device.platform .. "&%s"
else
    updateConfig.SERVER_FILE_URL_FMT = appconfig.UPDATE_RESOURCE_URL_ANDROID ..
        "%s?dev=" .. device.platform .. "&%s"
end

return updateConfig
