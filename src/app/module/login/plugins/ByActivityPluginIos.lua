
local logger = bm.Logger.new("ByActivityPluginIOS")

local ByActivityJumpManager = import("..ByActivityJumpManager")

local ByActivityPluginIOS = class("ByActivityPluginIOS")

local ApiUrl_test = "http://192.168.204.68/operating/web/index.php?m=%s&p=%s&appid=%s&newapi=%s"
local ApiUrl_online = "http://mvlp9kapi.boyaagame.com/?m=%s&p=%s&appid=%s&newapi=%s"
local isDebug = (not (appconfig.LOGIN_SERVER_URL == "http://mvlptl9k01.boyaagame.com/mobile.php"))
local appid = 9606


function ByActivityPluginIOS:ctor()
    dump("ByActivityPluginIOS")
    
    -- self.apiUrl_ = isDebug and ApiUrl_test or ApiUrl_online

	-- self.byActivityListener_ = handler(self, self.onByActivityActionListener)
 --    self.byActivityCloseListener = handler(self,self.onByActivityCloseListener)
	-- self:call_("setByActivityCallback",{self.byActivityListener_},"(I)V")
 --    self:call_("setByActivityCloseCallback",{self.byActivityCloseListener},"(I)V")

    self.isSetupSucc_ = false
end

--该初始化接口在登录完成，nk.userData 赋值之后才调用
function ByActivityPluginIOS:setup()
	dump("ByActivityPluginIOS:setup")
    if appconfig.LOGIN_SERVER_URL == "http://mvlptl9k01.boyaagame.com/mobile.php" then
        self.apiUrl_ = ApiUrl_online
    else
        self.apiUrl_ = ApiUrl_test
    end
    local deviceInfo = nk.Native:getDeviceInfo()
    self.mid_ = nk.userData.uid
    self.sitemid_ = nk.userData.siteuid
    self.userType_ = nk.userData.lid--nk.userData["aUser.lid"]
    local currentVersion = nk.Native:getAppVersion()
    self.version_ = currentVersion
    self.api_ = appconfig.SID[string.upper(device.platform)]--nk.userData["aUser.sid"]
    self.appid_ = appid
    self.deviceno_ = nk.Native:getIDFA() or ""
    self.osversion_ = deviceInfo.osVersion or ""
    self.networkstate_ = deviceInfo.networkType or ""

    self.isSetupSucc_ = true

    dump(self.isSetupSucc_,"ByActivityPluginIOS:setup")


	-- self:call_("setup",{mid,sitemid,userType,version,api,appid,deviceno},"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")

    self._jumpManager = ByActivityJumpManager.new()
    self:displayForce()
end


function ByActivityPluginIOS:getFullUrl(m,p,api)
    local appid = self.appid_
    return string.format(self.apiUrl_,m,p,appid,api)
end

function ByActivityPluginIOS:onByActivityActionListener(jsonStr)
	
        local jsonObj = json.decode(jsonStr)
        if jsonObj then
            if self.displayCallback_ then
                self.displayCallback_(jsonObj)
            end
            self._jumpManager:doJump(jsonObj)

            self:disposeWebView()
        end
        
end

--退出活动界面时候调用
function ByActivityPluginIOS:onByActivityCloseListener(str)

    if self.closeCallBack_ then
        self.closeCallBack_(str)
    end

    -- self.getUserinfoRequestId_ = nk.http.getMemberInfo(nk.userData["aUser.mid"],
    -- function(retData)
    --     self.getUserinfoRequestId_ = nil
    --     -- nk.http.cancel(self.getUserinfoRequestId_)
    --     -- nk.userData["aUser.money"] = retData.aUser.money or nk.userData["aUser.money"] or 0
    --     nk.userData["aUser.money"] = retData.aUser.money or nk.userData["aUser.money"] or 0
    --     nk.userData["aUser.gift"] = retData.aUser.gift or nk.userData["aUser.gift"] or 0
    --     nk.userData["aUser.mlevel"] = retData.aUser.mlevel or nk.userData["aUser.mlevel"] or 1
    --     nk.userData["aUser.exp"] = retData.aUser.exp or nk.userData["aUser.exp"] or 0

    --     nk.userData["aBest.maxmoney"] = retData.aBest.maxmoney or nk.userData["aBest.maxmoney"] or 0
    --     nk.userData["aBest.maxwmoney"] = retData.aBest.maxwmoney or nk.userData["aBest.maxwmoney"] or 0
    --     nk.userData["aBest.maxwcard"] = retData.aBest.maxwcard or nk.userData["aBest.maxwcard"] or 0
    --     nk.userData["aBest.rankMoney"] = retData.aBest.rankMoney or nk.userData["aBest.rankMoney"] or 0

    --     nk.userData["match"] = retData.match
    --     nk.userData['match.point'] = retData.match.point
    --     nk.userData['match.highPoint'] = retData.match.highPoint
    -- end,
    -- function(errData)
    --     -- nk.http.cancel(self.getUserinfoRequestId_)
    --     dump(errData, "getMemberInfo.errData :=========================")        
    --     self.getUserinfoRequestId_ = nil
    -- end
    -- )

    -- self.getMyGiftInfoRequestId_ = nk.http.getUserGift(
    -- function(data)
    --     nk.http.cancel(self.getMyGiftInfoRequestId_)
    --     if data and data.pnid then
    --         nk.userData["aUser.gift"] = checkint(data.pnid)
    --     end
    -- end,
    -- function(errorData)
    --     nk.http.cancel(self.getMyGiftInfoRequestId_)
    -- end
    -- )
end



function ByActivityPluginIOS:disposeWebView()
    if self.actWebView_ then
        self.actWebView_:dispose()
        self.actWebView_ = nil
    end

    if self.bgLayer then
        self.bgLayer:removeFromParent()
        self.bgLayer = nil
        self.openWebviewLoading = nil -- child of bgLayer
    end
end


function ByActivityPluginIOS:getBaseParams()
    local tb = {}
    tb.mid = self.mid_
    tb.version = self.version_
    tb.sid = self.userType_
    tb.api = self.api_
    tb.osversion = self.osversion_
    tb.appid = self.appid_
    tb.sitemid = self.sitemid_
    tb.networkstate = self.networkstate_
    tb.deviceno = self.deviceno_

    return tb
end

--展示活动
function ByActivityPluginIOS:display(displayCallback,closeCallBack)
    self.displayCallback_ = displayCallback
    self.closeCallBack_ = closeCallBack

    if self.isSetupSucc_ then
        local params = self:getBaseParams()
        dump(params,"ByActivityPluginIOS:display")

        local function shouldStartLoad(url)

            dump(url,"shouldStartLoad")
            local orgUrl = string.urldecode(url)
            dump(orgUrl,"orgUrl")

            if orgUrl and orgUrl ~= "" then
                local gmatchFun = string.gmatch(orgUrl,"%b{}")
                local jumpStr
                if gmatchFun then
                    for str in gmatchFun do 
                        local target = string.match(str,"target")
                        local desc = string.match(str,"desc")
                        if target then
                            jumpStr = str
                            if jumpStr and jumpStr ~= "" then
                                -- local jumpObj = json.decode(jumpStr)
                                self:onByActivityActionListener(jumpStr)
                                dump(jumpStr,"jumpStr")
                                return false
                            end
                            break;
                        end
                    end

                end

                
            end
            return true
        end
        local function start()
        end
        local function finish()
            if not tolua.isnull(self.openWebviewLoading) then
                self.openWebviewLoading:hide()
            end
        end
        local function fail(error_info)
            if not tolua.isnull(self.openWebviewLoading) then
                self.openWebviewLoading:hide()
            end
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL", "ACTIVITY_ERROR"))
            self:disposeWebView()
            dump(error_info,"webview-loaderr")
            return true
        end
        local function userClose()
            self:disposeWebView()
            nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
        end

        -- webview
        local W, H = display.width, display.height
        local x, y = display.cx - W / 2, display.cy - H / 2

        local view, err = Webview.create(start, finish, fail, userClose, shouldStartLoad)
        if view then
            self.actWebView_ = view
            view:show(x,y,W,H)
            view:setCloseBtnVisible(false)
            local r,g,b,a = 0,0,0,0
            view:setBackgroundColor(r,g,b,a)
            local webUrl = self:getFullUrl("activities","index",string.urlencode(json.encode(params)))
            dump(webUrl,"ByActivityPluginIOS:display-webUrl")
            view:updateURL(webUrl)
            -- view:updateURL("https://www.baidu.com")
        end

        self.bgLayer = display.newNode():addTo(display.getRunningScene(), 10000)
        self.bgLayer:setTouchEnabled(true)
        self.bgLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function() return true end)

        display.newSprite("activity_bg.jpg")
        :pos(display.cx,display.cy)
        :size(display.width,display.height)
        :addTo(self.bgLayer)

        --display.newColorLayer(ccc4(0, 0, 0, 128)):addTo(self.bgLayer)
        self.openWebviewLoading = nk.ui.Juhua.new()
            :addTo(self.bgLayer)
            :pos(display.cx, display.cy)
            :show()
        --todo
        -- self:call_("display",{},"()V")
    else
        dump("SDK incorrect return in setup!")
    end
	
end

--强推 @param size: 0:小 1:中  2:大
function ByActivityPluginIOS:displayForce(size,displayCallback,closeCallBack)
    self.displayCallback_ = displayCallback
    self.closeCallBack_ = closeCallBack

   if self.isSetupSucc_ then
        local params = self:getBaseParams()
        local relatedurl = self:getFullUrl("activities","actrelated",string.urlencode(json.encode(params)))
        bm.HttpService.GET_URL(relatedurl,{},function(data)
            local act_data = json.decode(data)
            if act_data and act_data.act_push and act_data.act_push.url then
                self:displayForceForUrl(size,act_data.act_push.url)
            end
        end,
        function()
        end)
   else
        dump("SDK incorrect return in setup!")
    end
end

function ByActivityPluginIOS:displayForceForUrl(size,url)
    local params = self:getBaseParams()
    local urlreal = url .."&appid=" .. self.appid_ .. "&newapi=" .. string.urlencode(json.encode(params))
    local function shouldStartLoad(url)
        dump(url,"shouldStartLoad")
        local orgUrl = string.urldecode(url)
        dump(orgUrl,"orgUrl")
        if orgUrl and orgUrl ~= "" then
            local gmatchFun = string.gmatch(orgUrl,"%b{}")
            local jumpStr
            if gmatchFun then
                for str in gmatchFun do 
                    local target = string.match(str,"target")
                    local desc = string.match(str,"desc")
                    if target then
                        jumpStr = str
                        if jumpStr and jumpStr ~= "" then
                            -- local jumpObj = json.decode(jumpStr)
                            self:onByActivityActionListener(jumpStr)
                            dump(jumpStr,"jumpStr")
                            return false
                        end
                        break;
                    end
                end
            end
        end
        return true
    end
    local function start()
    end
    local function finish()
        if not tolua.isnull(self.openWebviewLoading) then
            self.openWebviewLoading:hide()
        end
    end
    local function fail(error_info)
        if not tolua.isnull(self.openWebviewLoading) then
            self.openWebviewLoading:hide()
        end
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL", "ACTIVITY_ERROR"))
        self:disposeWebView()
        dump(error_info,"webview-loaderr")
        return true
    end
    local function userClose()
        self:disposeWebView()
        nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
    end

    -- webview
    local W, H = 860, 614 - 72--display.width, display.height
    local x, y = display.cx - W / 2, display.cy - H / 2

    local view, err = Webview.create(start, finish, fail, userClose, shouldStartLoad)
    if view then
        self.actWebView_ = view
        view:show(x,y,W,H)
        view:setCloseBtnVisible(true)
        local r,g,b,a = 0,0,0,0
        view:setBackgroundColor(r,g,b,a)
        local webUrl = urlreal--self:getFullUrl("activities","index",string.urlencode(json.encode(params)))
        dump(webUrl,"ByActivityPluginIOS:display-webUrl")
        view:updateURL(webUrl)
    end

    self.bgLayer = display.newNode():addTo(display.getRunningScene(), 10000)
    self.bgLayer:setTouchEnabled(true)
    self.bgLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function() return true end)

    self.bg_ = display.newSprite("activity_bg.jpg")
    :pos(display.cx,display.cy)
    -- :size(W,H)
    :addTo(self.bgLayer)

    self.bg_:setScaleX(W/self.bg_:getContentSize().width)
    self.bg_:setScaleY(H/self.bg_:getContentSize().height)

    --display.newColorLayer(ccc4(0, 0, 0, 128)):addTo(self.bgLayer)
    self.openWebviewLoading = nk.ui.Juhua.new()
        :addTo(self.bgLayer)
        :pos(display.cx, display.cy)
        :show()
end

-- @param serverId: 1代表测试服务器，0代表正式服务器，传其他的值没有用的哦
function ByActivityPluginIOS:switchServer(serverId)
    -- body
    local serverId = serverId or 1  -- 默认切换到测试服
    self:call_("switchServer", {serverId}, "(I)V")
end

function ByActivityPluginIOS:setWebViewTimeOut(timeOut)
    -- body
    local time = timeOut or 250
    self:call_("setWebViewTimeOut", {time}, "(I)V")
end

function ByActivityPluginIOS:setWebViewCloseTip(closeTip)
    -- body
    self:call_("setWebViewCloseTip", {closeTip}, "(Ljava/lang/String;)V")
end

function ByActivityPluginIOS:setNetWorkBadTip(badNetTip)
    -- body
    self:call_("setNetWorkBadTip", {badNetTip}, "(Ljava/lang/String;)V")
end

-- @param animId: 
    -- -1 不使用任何动画，直接显示
    -- 0 从左往右退出
    -- 1 从上往下退出
    -- 2 360°旋转
    -- 3 从右往左推进
    -- 4 从下往上推进
    -- 其次，还允许传入外部动画，比如外部的res/anim目录下，有动画 loading ，那么这里可以传入 R.anim.loading
    -- 更多动画正在扩展中，有好的建议可以 RTX： KillaXiao 你的提议就是我的动力~~
 
function ByActivityPluginIOS:setAnimIn(animId)
    -- body
    self:call_("setAnimIn", {animId}, "(I)V")
end

-- @param animId: 
    -- -1 不使用任何动画，直接显示
    -- 0 从左往右退出
    -- 1 从上往下退出
    -- 2 360°旋转
    -- 3 从右往左推进
    -- 4 从下往上推进
    -- 其次，还允许传入外部动画，比如外部的res/anim目录下，有动画 loading ，那么这里可以传入 R.anim.loading
    -- 更多动画正在扩展中，有好的建议可以 RTX： KillaXiao 你的提议就是我的动力~~
    
function ByActivityPluginIOS:setAnimOut(animId)
    -- body
    self:call_("setAnimOut", {animId}, "(I)V")
end

-- 设置是否点击一次关闭活动中心,默认为点击两次。
function ByActivityPluginIOS:setCloseType(isClickOnceToClose)
    -- body
    self:call_("setCloseClickOnce", {isClickOnceToClose}, "(Z)V")
end

function ByActivityPluginIOS:dismiss(animId)
    -- body
    -- 退出动画默认为1
    local animId = animId or 1
    self:call_("dismiss", {animId}, "(I)V")
end

function ByActivityPluginIOS:getSetupState()
    -- body
    return self.isSetupSucc_
end

function ByActivityPluginIOS:call_(javaMethodName, javaParams, javaMethodSig)
    if device.platform == "android" then
        local ok, ret = luaj.callStaticMethod("com/boyaa/cocoslib/byactivity/ByActivityBridge", javaMethodName, javaParams, javaMethodSig)
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

return ByActivityPluginIOS

