--
-- Author: tony
-- Date: 2014-08-18 16:49:49
--
local FacebookPluginAndroid = class("FacebookPluginAndroid")
local logger = bm.Logger.new("FacebookPluginAndroid")

function FacebookPluginAndroid:ctor()
    self.loginResultHandler_ = handler(self, self.onLoginResult_)
    self.invitableFriendsResultHandler_ = handler(self, self.onInvitableFriendsResult_)
    self.sendInvitesResultHandler_ = handler(self, self.onSendInvitesResult_)
    self.shareFeedResultHandler_ = handler(self, self.onShareFeedResult_)
    self.getRequestIdHandler_ = handler(self, self.onGetRequestIdResult_)
    self.uploadPhotoResultHandler_ = handler(self, self.onUploadPhotoResult_)
    self.getFacebookUserInfoHandler_ = handler(self,self.onGetFacebookUserInfoResult_)

    self:call_("setLoginCallback", {self.loginResultHandler_}, "(I)V")
    self:call_("setInvitableFriendsCallback", {self.invitableFriendsResultHandler_}, "(I)V")
    self:call_("setSendInvitesCallback", {self.sendInvitesResultHandler_}, "(I)V")
    self:call_("setShareFeedResultCallback", {self.shareFeedResultHandler_}, "(I)V")
    self:call_("setGetRequestIdResultCallback", {self.getRequestIdHandler_}, "(I)V")
    self:call_("setUploadPhotoResultCallback", {self.uploadPhotoResultHandler_}, "(I)V")
    self:call_("setGetFacebookUserCallback", {self.getFacebookUserInfoHandler_},"(I)V")

    self.cacheData_ = {}
end

function FacebookPluginAndroid:login(callback)
    self.loginCallback_ = callback
    self:call_("login", {}, "()V")
end

function FacebookPluginAndroid:logout()
    self.cacheData_ = {}
    self:call_("logout", {}, "()V")
end

function FacebookPluginAndroid:getInvitableFriends(inviteLimit, callback)
    self.getInvitableFriendsCallback_ = callback
    if self.cacheData_['getInvitableFriendsCallback_'] == nil then
        self:call_("getInvitableFriends", {inviteLimit}, "(I)V")
    else
        self:onInvitableFriendsResult_(self.cacheData_['getInvitableFriendsCallback_'])
    end
end

function FacebookPluginAndroid:sendInvites(data, toID, title, message, callback)
    self.sendInvitesCallback_ = callback 
    self:call_("sendInvites", {data, toID, title, message}, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
end

function FacebookPluginAndroid:shareFeed(params, callback)
    self.shareFeedCallback_ = callback

    local lastLoginType = nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE)
    if lastLoginType ==  "FACEBOOK" or params.forceFacebook then
        if nk.openFeedWord~=1 then
            params.name = ""
            params.caption = ""
            params.message = ""
        end
        if params.picture then
            params.picture = params.picture.."?v="..os.time()
        end
        self:call_("shareFeed", {json.encode(params)}, "(Ljava/lang/String;)V")
    else
        self:ShareBySystem(params, callback)
    end
end

function FacebookPluginAndroid:ShareBySystem(params, callback)
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
    self:call_("ShareBySystem", {json.encode(self.shareData)}, "(Ljava/lang/String;)V")
    print("FacebookPluginAndroid:callSystemShare")
end

--更多邀请
function FacebookPluginAndroid:moreInvite(params, callback)
    self:call_("ShareBySystem", {json.encode(params)}, "(Ljava/lang/String;)V")
end

function FacebookPluginAndroid:onImageLoadComplete_()
    print("FacebookPluginAndroid:onImageLoadComplete_")
    local url = self.shareData.picture
    local path = nk.ImageLoader.cacheConfig_[nk.ImageLoader.CACHE_TYPE_SHARE].path
    if path then
        local hash = crypto.md5(url)
        if string.find(url, "/") then
            local arr = string.split(url, "/")
            hash = arr[#arr]
        end
        local file = path .. hash
        if io.exists(file) then
            self.shareData.picture = file
            self.shareData.link = bm.LangUtil.getText("COMMON", "CHECK") .. ": " .. bm.LangUtil.getText("FEED", "SHARE_LINK")
            self:call_("ShareBySystem", {json.encode(self.shareData)}, "(Ljava/lang/String;)V")
        end
    end
        
end

function FacebookPluginAndroid:uploadPhoto(params, callback)
    self.uploadPhotoCallback_ = callback
    self:call_("uploadPhoto", {json.encode(params)}, "(Ljava/lang/String;)V")
end

function FacebookPluginAndroid:updateAppRequest()
    self.updateInviteRetryTimes_ = 3
    self:call_("getRequestId", {}, "()V")
end

function FacebookPluginAndroid:onGetRequestIdResult_(result)
    logger:debugf("onGetRequestIdResult_ %s", result)

    if result == "canceled" or result == "failed" then return end

    result = json.decode(result)
    if result and result.requestData and result.requestId then
        -- 老用户召回
        if string.find(result.requestData,"oldUserRecall") ~= nil then
            local localData = string.gsub(result.requestData,"oldUserRecall","")
            cc.analytics:doCommand{
                command = "eventCustom",
                args = {
                    eventId = "invite_olduser_success_count",
                    attributes = "type,invite_olduser_success",
                    counter = 1
                }
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
                        self:call_("deleteRequestId", {result.requestId}, "(Ljava/lang/String;)V")
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

            -- 普通邀请
            bm.HttpService.POST(
                {
                    mod = "invite", 
                    act = "update",
                    match = isMatch,
                    gid = gid,
                    data = result.requestData, 
                    requestid = result.requestId
                }, 
                function (data)
                    logger:debugf("invite.update::"..data.."  isMatch::"..tostring(isMatch));
                    local retData = json.decode(data)
                    if retData and retData.ret and retData.ret == 0 then
                        -- 删除requestId
                        self:call_("deleteRequestId", {result.requestId}, "(Ljava/lang/String;)V")
                    end
                end, 
                function ()
                    if self.updateInviteRetryTimes_ > 0 then
                        self:onGetRequestIdResult_(result)
                        self.updateInviteRetryTimes_ = self.updateInviteRetryTimes_ - 1
                    end
                end
            );
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

function FacebookPluginAndroid:onShareFeedResult_(result)
    logger:debugf("onShareFeedResult_ %s", result)
    local success = (result ~= "canceled" and result ~= "failed")
    if self.shareFeedCallback_ then
        self.shareFeedCallback_(success, result)
    end
    if success then
        nk.AdSdk:report(consts.AD_TYPE.AD_SHARE,{uid =tostring(nk.userData.uid)})
        bm.EventCenter:dispatchEvent({
            name = nk.DailyTasksEventHandler.REPORT_FB_SHARE
        })
    end
end

function FacebookPluginAndroid:onUploadPhotoResult_(result)
    logger:debugf("onUploadPhotoResult_ %s", result)
    local success = (result ~= "canceled" and result ~= "failed")
    if self.uploadPhotoCallback_ then
        self.uploadPhotoCallback_(success, result)
    end
end

function FacebookPluginAndroid:onSendInvitesResult_(result)
    logger:debugf("onSendInvitesResult_ %s", result)
    local success = (result ~= "canceled" and result ~= "failed" and string.sub(result, 1, 6) ~= "failed" )
    if success then        
        nk.AdSdk:report(consts.AD_TYPE.AD_INVITE,{uid =tostring(nk.userData.uid)})
        result = json.decode(result)        
    end

    if self.sendInvitesCallback_ then
        self.sendInvitesCallback_(success, result)
    end
end

function FacebookPluginAndroid:onInvitableFriendsResult_(result)
    logger:debugf("onInvitableFriendsResult_ %s", result)
    local success = (result ~= "canceled" and result ~= "failed")
    local accesstoken
    if success then
        self.cacheData_['getInvitableFriendsCallback_'] = result
        result = json.decode(result)
        local len = #result
        accesstoken = result[len].token
        table.remove(result, len)
    end

    if self.getInvitableFriendsCallback_ then        
        self.getInvitableFriendsCallback_(success, result, accesstoken)
    end
end

function FacebookPluginAndroid:onLoginResult_(result)
    logger:debugf("onLoginResult_ %s", result)
    local success = (result ~= "canceled" and result ~= "failed")
    if self.loginCallback_ then
        self.loginCallback_(success, result)
    end
end

function FacebookPluginAndroid:onGetFacebookUserInfoResult_(result)
    self.cacheData_['fbId'] = result
end

function FacebookPluginAndroid:call_(javaMethodName, javaParams, javaMethodSig)
    if device.platform == "android" then
        local ok, ret = luaj.callStaticMethod("com/boomegg/cocoslib/facebook/FacebookBridge", javaMethodName, javaParams, javaMethodSig)
        if not ok then
            if ret == -1 then
                logger:errorf("call %s failed, -1 不支持的参数类型或返回值类型", javaMethodName)
            elseif ret == -2 then
                logger:errorf("call %s failed, -2 无效的签名", javaMethodName)
            elseif ret == -3 then
                logger:errorf("call %s failed, -3 没有找到指定的方法", javaMethodName)
            elseif ret == -4 then
                logger:errorf("call %s failed, -4 Java 方法执行时抛出了异常", javaMethodName)
            elseif ret == -5 then
                logger:errorf("call %s failed, -5 Java 虚拟机出错", javaMethodName)
            elseif ret == -6 then
                logger:errorf("call %s failed, -6 Java 虚拟机出错", javaMethodName)
            end
        end
        return ok, ret
    else
        logger:debugf("call %s failed, not in android platform", javaMethodName)
        return false, nil
    end
end

return FacebookPluginAndroid
