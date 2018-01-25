--消息数据
local MessageData = class("MessageData")

-- 相当于static
MessageData.hasNewMessage = false

function MessageData:ctor()
    self:requestMessageData()
end

function MessageData:requestMessageData()
    self.requestMessageDataId = bm.HttpService.POST({
        mod = "Usernews",
        act = "checkNew",
    },
    handler(self, self.onGetMessageData),
    function () end
    )
end

function MessageData:onGetMessageData(data)
    MessageData.hasNewMessage = false
    local jsonData = json.decode(data or {})
    if jsonData and jsonData.code == 1 then
        if jsonData.redFri == 1 or jsonData.redSys == 1 then
            MessageData.hasNewMessage = true
        end
    end
    bm.DataProxy:setData(nk.dataKeys.NEW_MESSAGE, MessageData.hasNewMessage)
end

return MessageData
