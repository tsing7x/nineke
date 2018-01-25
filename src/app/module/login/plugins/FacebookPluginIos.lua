--
-- Author: johnny@boomegg.com
-- Maintainer: github.com/DavidFeng
-- Date: 2014-08-23 17:50:02
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local FacebookPluginIos = class("FacebookPluginIos")
local logger = bm.Logger.new("FacebookPluginIos")

function FacebookPluginIos:ctor()
    luaoc.callStaticMethod("FacebookBridge", "initFB")
    self.cacheData_ = {}
end

function FacebookPluginIos:login(callback)
    self.loginCallback_ = callback
    luaoc.callStaticMethod("FacebookBridge", "login", {listener = handler(self, self.onLoginResult_)})
end

function FacebookPluginIos:onLoginResult_(accessToken, errorInfo)
    if errorInfo then
        logger:error('Facebook iOS login errorInfo: ', errorInfo)
    end
    if self.loginCallback_ then
        local success = (accessToken and accessToken ~= "")
        self.loginCallback_(success, accessToken)
    end
end

function FacebookPluginIos:logout()
    luaoc.callStaticMethod("FacebookBridge", "logout")
    self.cacheData_ = {}
end

function FacebookPluginIos:ShareBySystem(params, callback)
    -- if params.picture and string.len(params.picture) > 5 then
    --     if not self.imageLoaderId_ then
    --         self.imageLoaderId_ = nk.ImageLoader:nextLoaderId()
    --     end
    --     nk.ImageLoader:cancelJobByLoaderId(self.imageLoaderId_)
    --     self.shareData = params

    --     nk.ImageLoader:loadAndCacheImage(
    --     self.imageLoaderId_, 
    --     params.picture, 
    --     handler(self, self.onImageLoadComplete_), 
    --     nk.ImageLoader.CACHE_TYPE_SHARE
    --     )
    -- end
    self.shareData = params
    self.shareData.picture = ""
    self.shareData.link = bm.LangUtil.getText("COMMON", "CHECK") .. ": " .. bm.LangUtil.getText("FEED", "SHARE_LINK")
    luaoc.callStaticMethod("LuaOCBridge", "shareText", self.shareData)
end


function FacebookPluginIos:shareFeed(args, callback)
    self.shareFeedCallback_ = callback
    local lastLoginType = nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE)
    if lastLoginType == "FACEBOOK" or args.forceFacebook then
        if type(args) == "table" then
            if args.picture then
                args.picture = args.picture.."?v="..os.time()
            end
            self.shareFeedCallback_ = callback
            args.listener = handler(self, self.onShareFeedResult_)
            luaoc.callStaticMethod("FacebookBridge", "shareFeed", args);
        end
    else
        self:ShareBySystem(args, callback)
    end
end

function FacebookPluginIos:moreInvite(params, callback)
    self:ShareBySystem(params, callback)
end

function FacebookPluginIos:onShareFeedResult_(status)
    local success = (status ~= "failed" and status ~= "canceled")
    if self.shareFeedCallback_ then
        self.shareFeedCallback_(success, status)
    end
    if success then
        bm.EventCenter:dispatchEvent({
            name = nk.DailyTasksEventHandler.REPORT_FB_SHARE
        })
    end
end

function FacebookPluginIos:getInvitableFriends(inviteLimit, callback)
    self.getInvitableFriendsCallback_ = callback
    if self.cacheData_['getInvitableFriendsCallback_'] == nil then
        luaoc.callStaticMethod("FacebookBridge", "getInvitableFriends", {limit = tostring(inviteLimit),listener = handler(self, self.onGetInvitableFriendsResult_)})
    else
        self:onGetInvitableFriendsResult_(self.cacheData_['getInvitableFriendsCallback_'])
    end
end

function FacebookPluginIos:onGetInvitableFriendsResult_(invitabledFriends)
    --[[
        invitabledFriends = {
            {name = "sanpang", id = "sdksl988fjf7fhjak", url = ""}
        }
    ]]
    -- local success = false
    
    -- if self.getInvitableFriendsCallback_ then
    --     success = type(invitabledFriends) == "table"
    --     self.getInvitableFriendsCallback_(success, invitabledFriends)
    -- end
    -- if success then
    --     self.cacheData_['getInvitableFriendsCallback_'] = invitabledFriends
    -- end
    
    --yk
    local success = type(invitabledFriends) == "table"
    local accesstoken
    local result = invitabledFriends
    if success then
        self.cacheData_['getInvitableFriendsCallback_'] = invitabledFriends
        result = clone(invitabledFriends)
        local len = #result
        accesstoken = result[len].token
        table.remove(result, len)
    end

    if self.getInvitableFriendsCallback_ then        
        self.getInvitableFriendsCallback_(success, result, accesstoken)
    end
end

function FacebookPluginIos:sendInvites(data, toIds, title, message, callback)
    self.sendInvitesCallback_ = callback
    luaoc.callStaticMethod("FacebookBridge", "sendInvites", {
        listener = handler(self, self.onsendInvitesResult_),
        data = data,
        toIds = toIds,
        title = title,
        message = message
    })
end

function FacebookPluginIos:onsendInvitesResult_(result)
    if result and self.sendInvitesCallback_ then
        local success = (result and result.requestId ~= "")
        self.sendInvitesCallback_(success, result)
    end
end

function FacebookPluginIos:updateAppRequest()
    luaoc.callStaticMethod("FacebookBridge", "getRequestId", {listener = handler(self, self.onGetRequestId_)})
    self.updateInviteRetryTimes_ = 3
end

function FacebookPluginIos:onGetRequestId_(result)
    logger:debugf("iOS onGetRequestIdResult_ %s, %s", type(result), result)

    if result and result.requestData and result.requestId then

        -- 老用户召回
        if string.find(result.requestData, 'oldUserRecall') ~= nil then
            local localData = string.gsub(result.requestData,"oldUserRecall","")
            cc.analytics:doCommand {
                command = 'eventCustom',
                args = {
                    eventId    = "invite_olduser_success_count",
                    attributes = "type,invite_olduser_success",
                    counter    = 1,
                },
            }
            bm.HttpService.POST(
                {
                    mod = "recall",
                    act = "update",
                    data = localData,
                    requestid = result.requestId
                },
                function (data)
                    local retData = json.decode(data)
                    if retData and retData.ret and retData.ret == 0 then
                        -- 删除requestId
                        luaoc.callStaticMethod("FacebookBridge", "deleteRequestId", {requestId = result.requestId})
                    end
                end,
                function ()
                    if self.updateInviteRetryTimes_ > 0 then
                        self:onGetRequestIdResult_(result)
                        self.updateInviteRetryTimes_ = self.updateInviteRetryTimes_ - 1
                    end
                end
            )
        else
            local isMatch = 0;
            local gid = 0;
            -- 
            if string.find(result.requestData,";match:4") ~= nil then
                result.requestData = string.gsub(result.requestData,";match:4","");
                isMatch = 4;

                local fidx, lidx = string.find(result.requestData, ";gid:");
                if fidx ~= nil then
                    local tmpRequestData = string.sub(result.requestData, 1, fidx - 1);
                    local gidStr = string.sub(result.requestData, fidx);
                    fidx, lidx = string.find(gidStr, ";gid:");
                    if fidx ~= nil then
                        gid = string.gsub(gidStr, ";gid:", "");
                    end

                    result.requestData = tmpRequestData;
                end
            end

            if string.find(result.requestData,";match:3") ~= nil then
                result.requestData = string.gsub(result.requestData,";match:3","");
                isMatch = 3;
            end
            -- 判断是否为全量邀请
            if string.find(result.requestData,";match:2") ~= nil then
                result.requestData = string.gsub(result.requestData,";match:2","");
                isMatch = 2;
            end

            if string.find(result.requestData,";match:1") ~= nil then
                result.requestData = string.gsub(result.requestData,";match:1","");
                isMatch = 1;
            end

            -- 邀请新用户
            bm.HttpService.POST(
                {
                    mod = "invite",
                    act = "update",
                    data = result.requestData,
                    requestid = result.requestId
                },
                function (data)
                    local retData = json.decode(data)
                    if retData and retData.ret and retData.ret == 0 then
                        -- 删除requestId
                        luaoc.callStaticMethod("FacebookBridge", "deleteRequestId", {requestId = result.requestId})
                    end
                end,
                function ()
                    if self.updateInviteRetryTimes_ > 0 then
                        self:onGetRequestId_(result)
                        self.updateInviteRetryTimes_ = self.updateInviteRetryTimes_ - 1
                    end
                end
            )
            -- 
            if isMatch == 2 then
                bm.HttpService.POST({
                        mod = "Statistics", 
                        act = "report",
                        stat_data = json.encode({et_id="inviteMatch2",succ=1}),
                    },
                    function(data)
                        local retData = json.decode(data)
                        if retData and retData.ret and retData.ret == 0 then
                            -- ret = 1 成功（-1：stat_data数据异常，-2：et_id异常）
                        end
                    end
                );
            end
        end

    end
end

return FacebookPluginIos
