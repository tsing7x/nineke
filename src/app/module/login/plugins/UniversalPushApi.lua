--- API
--
-- register(callback) : callback(boolean is_okay, string token)
--
-- @seconds {number} : 延迟提醒时间 单位秒
-- @message {string} : 消息内容
-- addLocalNotification(seconds, message)


local UniversalPushService
if device.platform == "android" then
    UniversalPushService = import(".XinGePushAndroid") -- ".GoogleCloudMessaging"
elseif device.platform == "ios" then
    UniversalPushService = import(".ApplePushService")
end

return UniversalPushService
