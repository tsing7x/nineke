--好友数据
local FriendData = class("FriendData")

-- 相当于static
FriendData.hasNewMessage = false

function FriendData:ctor()
    self:requestMessageData()
end

function FriendData:requestMessageData()
    self.requestMessageDataId = bm.HttpService.POST({
        mod = "recall",
        act = "checkRecallUser",
    },
    handler(self, self.onGetMessageData),
    function () end
    )
end

function FriendData:onGetMessageData(data)
    FriendData.hasNewMessage = false
    local jsonData = json.decode(data or {})
    if jsonData and jsonData.code == 1 then
        if jsonData.status == 1 then
            FriendData.hasNewMessage = true
        end
    end
    bm.DataProxy:setData(nk.dataKeys.NEW_FRIEND_DATA, FriendData.hasNewMessage)
end

return FriendData
