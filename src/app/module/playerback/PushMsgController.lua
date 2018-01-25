--
-- Author: Jonah0608@gmail.com
-- Date: 2015-12-29 09:44:23
--
local PushMsgController = class("PushMsgController")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

function PushMsgController:ctor(view,title, msg, showIcon, type)
    self.view_ = view
    self.msgtitle_ = title or " " 
    self.msg_ = msg or " "
    self.showIcon_ = showIcon or false
    self.type_ = type
end

function PushMsgController:getListData()
    self.view_:setLoading(true)
    if not self.pushData_ then
        bm.HttpService.CANCEL(self.friendDataRequestId_)
        self.friendDataRequestId_ = bm.HttpService.POST(
        {
            mod = "friend",
            act = "list",
            washed = 14,
            offline=1
        },
        handler(self, self.onGetPushData_),
        function ()
            requestRetryTimes_ = requestRetryTimes_ - 1
            if requestRetryTimes_ > 0 then
                self.pushDataRequestScheduleHandle_ = scheduler.performWithDelayGlobal(handler(self, self.getListData), 1)
            else
                self.view_:setLoading(false)
            end
        end
    )
    end
end

function PushMsgController:onGetPushData_(data)
    if data then
        self.pushData_ = json.decode(data)
        if #self.pushData_ > 0 then
            self.view_:setListData(self.pushData_)
        else
            self.view_:setNoDataTip(true)
        end
        self.view_:setLoading(false)
    else
        self.pushDataRequestScheduleHandle_ = scheduler.performWithDelayGlobal(handler(self, self.getListData), 2)
    end

end

function PushMsgController:getMsg(msg,item)
    if msg == "room" then
        return bm.LangUtil.getText("PUSHMSG","ROOM_PUSH",item:getData().nick,nk.userData.nick)
    else
        return msg
    end
end

function PushMsgController:pushMsg(item)
    local msg = self:getMsg(self.msg_,item)
    nk.pushMsg(item:getData().uid,self.msgtitle_ ,msg, self.showIcon_, self.type_ or 2)
    self.view_:hide()
end

function PushMsgController:dispose()
    bm.HttpService.CANCEL(self.pushDataRequestId_)
    if self.pushDataRequestScheduleHandle_ then
        scheduler.unscheduleGlobal(self.pushDataRequestScheduleHandle_)
    end
end

return PushMsgController