--
-- Author: johnny@boomegg.com
-- Date: 2014-08-31 20:13:50
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
-- 控制器

local FriendPopupController = class("FriendPopupController")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local logger = bm.Logger.new("FriendPopupController")

function FriendPopupController:ctor(view)
    self.view_ = view
    self.friendPage_ = 1
    self.onePageCount_ = 7
    self.maxPage_ = false
end

function FriendPopupController:onMainTabChange(selectedTab)
    self.view_:setLoading(false)
    self.mainSelectedTab_ = selectedTab
    requestRetryTimes_ = 2
    if self.mainSelectedTab_ == 1 then
        if not self.friendData_ then   
            self.view_:setNoDataTip(true)
            self.view_:setLoading(true)
            self:requestFriendDataPage_()
            self:getCanRecallFriends()
            self.view_:setNoDataTip(false)
        else
            if #self.friendData_ > 0 then
                self.view_:setListData(self.friendData_)
                if self.oneKeyRecallData then
                    self:updateRecallView(self.oneKeyRecallData)
                end
                if self.sendChipsData then
                    self:updateSendChipsView()
                end
            else
                self.view_:setNoDataTip(true)
            end
        end
    elseif self.mainSelectedTab_ == 2 then
        if not self.codeData_ then
            self.view_:setLoading(true)
            self:getInviteCode(true)
        else
            self.view_:addInviteNode_(self.codeData_)
        end
    elseif self.mainSelectedTab_ == 3 then --群组消息
        self.view_:addGroupNode_()
    end
end

function FriendPopupController:getDelFriendData()
    self.mainSelectedTab_  = 0
    requestRetryTimes_ = 2
    self:requestDelFriendData_()
    self.view_:setLoading(true)
    self.view_:setDelListNoDataTip(false)
end

-- 使用分页加载模型请求数据
function FriendPopupController:requestFriendDataPage_()
    if not self.maxPage_ then
        if not self.friendData_ then
            self.friendData_ = {}
        end
        if not self.sendChipsData then
            self.sendChipsData = {}
        end
        bm.HttpService.CANCEL(self.friendDataRequestId_)
        self.friendDataRequestId_ = bm.HttpService.POST(
        {
            mod = "friend",
            act = "list",
            new = 1,
            page = self.friendPage_
        },
        handler(self, self.onGetFriendDataPage_),
        function ()
            requestRetryTimes_ = requestRetryTimes_ - 1
            if requestRetryTimes_ > 0 then
                self.friendDataRequestScheduleHandle_ = scheduler.performWithDelayGlobal(handler(self, self.requestFriendDataPage_), 1)
            end
        end
    )
    end
end

function FriendPopupController:onGetFriendDataPage_(jsondata)
    if jsondata then
        local jsondata_ = json.decode(jsondata)
        self.sendChipsData.cnt = jsondata_.cnt or 0
        self.sendChipsData.money = jsondata_.money or 100000
        local data = jsondata_.flist or {}
        if #data == 0 then
            self.maxPage_ = true
            if self.friendPage_ > 1 then
                return
            end
        end

        self.friendPage_ = self.friendPage_ + 1
        for i=0,#data do
            table.insert(self.friendData_,data[i])
        end

        local uidList = {}
        if self.friendData_ then
            for i, v in ipairs(self.friendData_) do
                uidList[#uidList + 1] = v.uid
            end
        end

        if self.mainSelectedTab_ == 1 then
            if #self.friendData_ > 0 then
                self.view_:setListData(self.friendData_)
            else
                self.view_:setNoDataTip(true)
            end
            self.view_:setLoading(false)
            if self.sendChipsData then
                self:updateSendChipsView()
            end
        end
    else
        self.friendDataRequestScheduleHandle_ = scheduler.performWithDelayGlobal(handler(self, self.requestFriendDataPage_), 2)
    end
end

function FriendPopupController:sendChip(friendListItem)
    bm.HttpService.CANCEL(self.sendChipRequestId_)
    self.sendChipRequestId_ = bm.HttpService.POST(
        {
            mod = "Usernews",
            act = "setRewardToFriend",
            friuid = friendListItem:getData().uid
        },
        function (data)
            self:onSendChip_(data, friendListItem)
        end,
        function ()
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("TIPS", "ERROR_SEND_FRIEND_CHIP"))
        end
    )
end

function FriendPopupController:onSendChip_(data, friendListItem)
    if data then
        local retData = json.decode(data)
        if retData.ret then
            if retData.ret == 0 then
                -- 没钱了
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "SEND_CHIP_TOO_POOR"))
            elseif retData.ret == 1 then
                -- 赠送次数用完
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "SEND_CHIP_COUNT_OUT"))
            elseif retData.ret == 2 then
                -- 赠送成功
                if friendListItem then
                    friendListItem:onSendChipSucc()
                    if self.sendChipsData then
                        self.sendChipsData.cnt = self.sendChipsData.cnt - 1
                        self:updateSendChipsView()
                    end
                end
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("TIPS", "EXCEPTION_SEND_FRIEND_CHIP"))
            end
        end
    else
        local t = bm.LangUtil.getText("TIPS", "EXCEPTION_SEND_FRIEND_CHIP")
        nk.TopTipManager:showTopTip(t)
    end
end

--一键赠送
function FriendPopupController:oneKeySend()
    if self.sendChipsData and self.sendChipsData.cnt and self.sendChipsData.cnt > 0 then
        local tm = self.sendChipsData.cnt * self.sendChipsData.money 
        if tm * 2 > nk.userData.money then
            nk.ui.Dialog.new({
                messageText = bm.LangUtil.getText("FRIEND", "ONE_KEY_SEND_CHIP_TOO_POOR"), 
                hasFirstButton = false,
                callback = function (type)
                    if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                        return
                    end
                end
            }):show()
            return
        end
        if self.sendChipsData.cnt >= 20 then
            nk.ui.Dialog.new({
                messageText = bm.LangUtil.getText("FRIEND", "ONE_KEY_SEND_CHIP_CONFIRM", self.sendChipsData.cnt, bm.formatBigNumber(tm)), 
                callback = function (type)
                    if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                        self:oneKeySendFriends()
                    end
                end
            }):show()
        else
            self:oneKeySendFriends()
        end
    end
end

function FriendPopupController:oneKeySendFriends()
    bm.HttpService.POST(
        {
            mod = "Usernews",
            act = "setRewardToFriends",
            type = 1,
        },
        function (data)
            local retData = json.decode(data)
            if retData.ret == 0 then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "SEND_CHIP_SUCCESS", bm.formatNumberWithSplit(retData.cnt * self.sendChipsData.money)))
                self:resetSendChipsData()
            elseif retData.ret == -3 then
                -- 没钱了
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "SEND_CHIP_TOO_POOR"))
            elseif retData.ret == -2 then
                -- 赠送次数用完
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "SEND_CHIP_COUNT_OUT"))
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("TIPS", "EXCEPTION_SEND_FRIEND_CHIP"))
            end
        end,
        function ()
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("TIPS", "ERROR_SEND_FRIEND_CHIP"))
        end
    )
end

function FriendPopupController:updateSendChipsView()
    if self.sendChipsData and self.sendChipsData.cnt and self.sendChipsData.cnt > 0 then
        local tm = self.sendChipsData.cnt * self.sendChipsData.money
        if tm > 0 then
            self.view_:updateFriendSendData(true)
            self.view_:updateFriendSendReward(tm)
        else
            self.view_:updateFriendSendData(false)
            self.view_:updateFriendSendReward(0)
        end
    else
        self.view_:updateFriendSendData(false)
        self.view_:updateFriendSendReward(0)
    end
end

function FriendPopupController:resetSendChipsData()
    if self.friendData_ then
        for i, v in ipairs(self.friendData_) do
            v.send = 0
        end
    end

    if self.mainSelectedTab_ == 1 then
        if #self.friendData_ > 0 then
            self.view_:setListData(self.friendData_)
        end
    end

    self.view_:updateFriendSendData(false)
    self.view_:updateFriendSendReward(0)
end

--召回好友
function FriendPopupController:recallFriend(friendData, oneKeyCallback)
    -- 上报使用邀请老用户好友功能的用户数上报
    local date = nk.userDefault:getStringForKey(nk.cookieKeys.DALIY_REPORT_OLDUSER_INVITED)
    if date ~= os.date("%Y%m%d") then
        nk.userDefault:setStringForKey(nk.cookieKeys.DALIY_REPORT_OLDUSER_INVITED, os.date("%Y%m%d"))
        cc.analytics:doCommand{
            command = "eventCustom",
            args = {
                eventId = "invite_olduser_count",
                attributes = "type,invite_olduser",
                counter = 1
            }
        }
    end

    local toIds, names, toIdArr, nameArr = '', '', {}, {}

    for _, item in ipairs(friendData) do
        table.insert(toIdArr, tostring(item.siteid))
        table.insert(nameArr, item.nick)
    end

    toIds = table.concat(toIdArr, ",")
    names = table.concat(nameArr, "#")

    -- 发送邀请
    if toIds ~= "" then
        bm.HttpService.POST(
            {
                mod = "recall", 
                act = "getRecallID"
            }, 
            function (data)
                local retData = json.decode(data)
                local requestData

                if retData.ret and retData.ret == 0 then
                    requestData = "u:"..retData.u..";id:"..retData.id..";sk:"..retData.sk
                else
                    return
                end
                local retry = 10
                local function send_fb_invites()
                    local msg = "มาเล่นไพ่ด้วยกัน คิดถึงๆ！"
                    nk.Facebook:sendInvites(
                        "oldUserRecall" .. requestData, 
                        toIds, 
                        bm.LangUtil.getText("FRIEND", "INVITE_SUBJECT"), 
                        msg,
                        function (success, result)
                            if success then

                                if names ~= "" then
                                    local recalledNames = nk.userDefault:getStringForKey(nk.cookieKeys.FACEBOOK_RECALLED_NAMES, "")
                                    local today = os.date("%Y%m%d")
                                    if recalledNames == "" or string.sub(recalledNames, 1, 8) ~= today then
                                        recalledNames = today .."#" .. names
                                    else
                                        recalledNames = recalledNames .. "#" .. names
                                    end
                                    nk.userDefault:setStringForKey(nk.cookieKeys.FACEBOOK_RECALLED_NAMES, recalledNames)
                                    nk.userDefault:flush()
                                end

                                local noreward_ = 0
                                if oneKeyCallback then
                                    oneKeyCallback()
                                    noreward_ = 1  -- 一键召回的时候发推送了，不需要发奖
                                end

                                -- 去掉最后一个逗号
                                if result.toIds then
                                    local idLen = string.len(result.toIds)
                                    if idLen > 0 and string.sub(result.toIds, idLen, idLen) == "," then
                                        result.toIds = string.sub(result.toIds, 1, idLen - 1)
                                    end
                                end

                                nk.reportToDAdmin("recallV2", "recallClicked=sendFBCount")

                                -- 上报php，领奖
                                local postData = {
                                    mod = "recall", 
                                    act = "report", 
                                    data = requestData, 
                                    requestid = result.requestId, 
                                    list = result.toIds, 
                                    sig = crypto.md5(result.toIds .. "ab*&()[cae!@+?>#5981~.,-zm"),
                                    source = "recall",
                                    type = "recall",
                                    noreward = noreward_
                                }

                                bm.HttpService.POST(
                                    postData, 
                                    function (data)
                                        local retData = json.decode(data)
                                        if retData and retData.ret == 0 and retData.money and retData.money > 0 then
                                            self:showRecallSuccTip_()
                                            local historyVal = nk.userDefault:getIntegerForKey(nk.cookieKeys.FACEBOOK_INVITE_MONEY, 0)
                                            historyVal = historyVal + retData.money
                                            nk.userDefault:setIntegerForKey(nk.cookieKeys.FACEBOOK_INVITE_MONEY, historyVal)
                                        end
                                    end
                                )
                            else
                                logger:debugf("sendInvites result %s", result)
                                if string.find(result,"facebookErrorCode: 100") ~= nil or
                                    string.find(result,"does not resolve to a valid user ID") ~= nil then
                                    local reg = "message%:%s+%d+"
                                    local matStr = string.match(result,reg)
                                    local desId = string.match(matStr,"%d+")

                                    logger:debugf("sendInvites result faild, rectry! desId:%s", desId)
                                    for i = #toIdArr, 1, -1 do
                                        if toIdArr[i] == desId then
                                            table.remove(toIdArr, i)
                                            table.remove(nameArr, i)
                                        end
                                    end
                                    toIds = table.concat(toIdArr, ",")
                                    names = table.concat(nameArr, "#")
                                    
                                    if retry > 0 and #toIdArr > 0 then
				    	                retry = retry - 1
                                        send_fb_invites()
                                    else
                                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "USER_NEED_RELOGIN"))
                                    end
                                end
                            end
                        end
                    )
                end
                send_fb_invites()
            end, 
            function ()
            end
        )
    end
end

--发送推送消息
function FriendPopupController:sendPushNews(touid)
    self.sendPushNewsRequestId_ = bm.HttpService.POST(
        {
            mod = "recall",
            act = "pushNews",
            touid = touid
        },
        function(data)
            local retData = json.decode(data)
            if retData.code == 1 or retData.code == -2 then --1表示发送成功并发送推送，-2表示发送成功，但不会发送推送
                nk.reportToDAdmin("recallV2", "recallClicked=pushNewsCount")
                self:showRecallSuccTip_()
            else
                self:showRecallFailedTip_()
            end
        end,
        function()
            self:showRecallFailedTip_()
        end
    )
end

--一键召回
function FriendPopupController:oneKeyRecall()
    self:oneKeyRecallFriends()
end

function FriendPopupController:oneKeyRecallFriends()
    local recallFbList = nil
    if self.oneKeyRecallData then
        recallFbList = self.oneKeyRecallData.fblist
    end
    if recallFbList and #recallFbList > 0 then
        if #recallFbList >= 50 then
            for i = #recallFbList, 50, -1 do
                table.remove(recallFbList, i)
            end
        end
        self:recallFriend(recallFbList, handler(self, self.oneKeyPushFriends))
    else
        self:oneKeyPushFriends()
    end
end

function FriendPopupController:oneKeyPushFriends()
    self:resetRecallData()
    bm.HttpService.POST({
            mod = "recall",
            act = "sendRecallMulti",
        },
        handler(self, self.onOneKeyPushResult),
        function () end
    )
end

function FriendPopupController:onOneKeyPushResult(data)
    local jsonData = json.decode(data or {})
    if jsonData and jsonData.code == 1 then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText(
            "FRIEND",
            "RECALL_SUCC_TIP",
            jsonData.money,
            nk.userData.recallBackChips))
    else
        self:showRecallFailedTip_()
    end
end

function FriendPopupController:getCanRecallFriends()
    bm.HttpService.POST({
        mod = "recall",
        act = "getCanRecallList",
    },
    handler(self, self.onGetCanRecallData),
    function () end
    )
end

function FriendPopupController:onGetCanRecallData(data)
    local jsonData = json.decode(data or {})
    if jsonData and jsonData.code == 0 then
        self.oneKeyRecallData = jsonData
        self:updateRecallView(self.oneKeyRecallData)
    end
end

function FriendPopupController:updateRecallView(jsonData)
    if jsonData and jsonData.code == 0 then
        if jsonData.money and jsonData.money > 0 then
            self.view_:updateFriendRecallData(true)
            self.view_:updateFriendRecallReward(jsonData.money)
        else
            self.view_:updateFriendRecallData(false)
            self.view_:updateFriendRecallReward(0)
        end
    end
end

function FriendPopupController:resetRecallData()
    if self.friendData_ then
        for i, v in ipairs(self.friendData_) do
            v.isCanRecall = 0
        end
    end

    if self.mainSelectedTab_ == 1 then
        if #self.friendData_ > 0 then
            self.view_:setListData(self.friendData_)
        end
    end

    self.view_:updateFriendRecallData(false)
end

--发送召回成功提示
function FriendPopupController:showRecallSuccTip_()
    self:getCanRecallFriends()--重新获取一键召回数据
    nk.TopTipManager:showTopTip(bm.LangUtil.getText(
        "FRIEND",
        "RECALL_SUCC_TIP",
        nk.userData.recallSendChips,
        nk.userData.recallBackChips))
end

--发送召回失败提示
function FriendPopupController:showRecallFailedTip_()
    nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "RECALL_FAILED_TIP"))
end

function FriendPopupController:requestDelFriendData_()
    bm.HttpService.CANCEL(self.delFriendDataRequestId_)
    self.delFriendDataRequestId_ = bm.HttpService.POST(
        {
            mod = "friend",
            act = "delFriendsList",
        },
        handler(self, self.onGetDelFriendData_),
        function ()
            requestRetryTimes_ = requestRetryTimes_ - 1
            if requestRetryTimes_ > 0 then
                self.delFriendDataRequestScheduleHandle_ = scheduler.performWithDelayGlobal(handler(self, self.requestDelFriendData_), 1) 
            end
        end
    )
end

function FriendPopupController:onGetDelFriendData_(data)
    if data then
        local retData = json.decode(data)
        if retData then
            self.delFriendData_ = retData.list
            if self.mainSelectedTab_ == 0 then
                if #self.delFriendData_ > 0 then
                    self.view_:setDelListData(self.delFriendData_)
                else
                    self.view_:setDelListNoDataTip(true)
                end
                self.view_:setLoading(false)
            end
        else
            self.view_:setDelListNoDataTip(true)
        end
    else
        self.friendDataRequestScheduleHandle_ = scheduler.performWithDelayGlobal(handler(self, self.requestDelFriendData_), 2)
    end
end

function FriendPopupController:restoreFriend(friendListItem)
    local fuid = friendListItem:getData().uid
    bm.HttpService.POST({mod="friend", act="setPoker", fuid=fuid, from="restore", new=1},
    function(data)
        local retData = json.decode(data)
        if retData then
            if retData.ret == 1 or retData.ret == 2 then
                self:restoreFriendSuccess_(friendListItem)
                self:clearAllFriendData()
                if retData.ret == 2 then
                    local noticed = nk.userDefault:getBoolForKey(nk.cookieKeys.FRIENDS_FULL_TIPS .. nk.userData.uid, false)
                    if not noticed then
                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "ADD_FULL_TIPS",nk.OnOff:getConfig("maxFriendNum") or "300"))
                        nk.userDefault:setBoolForKey(nk.cookieKeys.FRIENDS_FULL_TIPS .. nk.userData.uid, true)
                    end
                end
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "ADD_FRIEND_FAILED_MSG"))
            end
        end
    end, function()
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "ADD_FRIEND_FAILED_MSG"))
    end)
end

function FriendPopupController:restoreFriendSuccess_(friendListItem)
    if friendListItem:getOwner() then
        local send = friendListItem:getData().send
        if self.sendChipsData and send and send > 0 then
            self.sendChipsData.cnt = self.sendChipsData.cnt + 1
            self:updateSendChipsView()
        end
        local list2 = friendListItem:getOwner()
        local data2 = list2:getData()
        local itemData2 = data2[friendListItem:getIndex()]
        table.remove(data2, friendListItem:getIndex())
        list2:setData(nil)
        list2:setData(data2)
    end
end

--获取邀请码
function FriendPopupController:getInviteCode(isCreate)
    bm.HttpService.POST(
        {
            mod = "InviteCode",
            act = "getInviteCode",
        },
        function(data)
            local jsonData = json.decode(data)

            if jsonData.ret == 1 then
                self.codeData_ = jsonData
                if isCreate then
                    self.view_:addInviteNode_(jsonData)
                end
            end
        end,
        function ()
        end
    )
end

--清除好友数据，可以重新发送请求获取
function FriendPopupController:clearAllFriendData()
    self.friendData_ = nil
    self.friendPage_ = 1
end

function FriendPopupController:dispose()
    bm.HttpService.CANCEL(self.friendDataRequestId_)
    bm.HttpService.CANCEL(self.delFriendDataRequestId_)
    bm.HttpService.CANCEL(self.sendChipRequestId_)
    bm.HttpService.CANCEL(self.sendPushNewsRequestId_)

    if self.friendDataRequestScheduleHandle_ then
        scheduler.unscheduleGlobal(self.friendDataRequestScheduleHandle_)
    end
    
    if self.delFriendDataRequestScheduleHandle_ then
        scheduler.unscheduleGlobal(self.delFriendDataRequestScheduleHandle_)
    end
end

return FriendPopupController
