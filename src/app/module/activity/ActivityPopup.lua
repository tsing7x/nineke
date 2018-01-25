--
-- Author: TsingZhang@boyaa.com
-- Modify: WebbZhang@boyaa.com
-- Date: 2017-11-23 10:23:27
-- ModifyDate：2018-1-3
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: ActivityPopup.lua Created By Tsing7x.
-- ModifyDescription：Repair Flash Back
--

local logger = bm.Logger.new("ActivityPopup")

local ActivityJumpBridge = import("app.module.activity.ActivityJumpBridge")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

local ApiUrl = "http://mvlp9kapi.boyaagame.com/?m=%s&p=%s&appid=%s&api=%s"
local isDebug = true
local appid = 9606

local ActivityPopup = class("ActivityPopup", nk.ui.Panel)

function ActivityPopup:ctor()
	-- body
	self.isSetupSucc_ = false

	if CF_DEBUG >= 5 then
		ApiUrl = "http://192.168.204.68/operating/web/index.php?m=%s&p=%s&appid=%s&api=%s"
	end

	self.layerout = display.newNode()
        :pos(0, 0)
        :addTo(self)

	self:setup()
	self:display()
end

function ActivityPopup:getApiFullUrl(m, p, api)
	-- body
    return string.format(self.apiUrl_, m, p, self.appid_, api)
end

function ActivityPopup:getBaseParams()
	-- body
	local tb = {}

    tb.mid = self.mid_
    tb.version = self.version_
    tb.sid = self.userType_
    tb.api = self.api_
    tb.appid = self.appid_
    tb.sitemid = self.sitemid_
    tb.osversion = self.osversion_
    tb.networkstate = self.networkstate_
    tb.deviceno = self.deviceno_
    
    return tb
end

function ActivityPopup:setup(callback)
	-- body
	self.apiUrl_ = ApiUrl

    local deviceInfo = nk.Native:getDeviceInfo()
    self.mid_ = nk.userData.uid
    self.sitemid_ = nk.userData.siteuid
    self.userType_ = nk.userData.lid --nk.userData["aUser.lid"]
    self.version_ = nk.Native:getAppVersion()
    self.api_ = appconfig.SID[string.upper(device.platform)] --nk.userData["aUser.sid"]
    self.appid_ = appid
    self.deviceno_ = nk.Native:getIDFA() or ""
    self.osversion_ = deviceInfo.osVersion or ""
    self.networkstate_ = deviceInfo.networkType or ""

    self.isSetupSucc_ = true

    self.jumpManager_ = ActivityJumpBridge.new()

    if callback then
    	--todo
    	callback()
    end
end

function ActivityPopup:onByActivityActionListener(jsonStr)
	-- body
	local jsonObj = json.decode(jsonStr)
	-- dump(jsonObj, "ActivityPopup:onByActivityActionListener.jsonObj :=================")

    if jsonObj then
        if self.displayCallback_ then
            self.displayCallback_(jsonObj)

            self.displayCallback_ = nil
        end
        self.jumpManager_:doJump(jsonObj)
        
        self:disposeWebView()
    else
    	dump("json.decode(jsonStr) Fail! jsonStr Param Wrong.")
    end
end

function ActivityPopup:onByActivityCloseListener(paramStr)
	-- body
	if self.closeCallBack_ then
		--todo
		self.closeCallBack_(paramStr)

		self.closeCallBack_ = nil
	end

	-- Update UsrInfo Here.
end

function ActivityPopup:display(displayCallback, closeCallback)
	--callback
	self.displayCallback_ = displayCallback
    self.closeCallBack_ = closeCallback

    if self.isSetupSucc_ then
    	local params = self:getBaseParams()
    	--初始化WebView
    	if ccexp.WebView then
    		--设置webview父容器，通过容器释放
			-- self.layerout = display.newNode()
   --      		:pos(display.width/2, display.height/2)
   --      		:addTo(nk.runningScene)

    		self.actWebView_ = ccexp.WebView:create()
        	self.layerout:addChild(self.actWebView_)
        	self.actWebView_:setVisible(true)
        	self.actWebView_:setScalesPageToFit(true)
        	self.actWebView_:setContentSize(cc.size(display.width,display.height))
        	self.actWebView_:setPosition(0,0)

        	local webViewBg = display.newSprite("activity_bg.jpg")
	            :size(display.width, display.height)
	            :addTo(self.actWebView_)
	            :pos(display.cx, display.cy)

	        self.webviewLoading_ = nk.ui.Juhua.new()
	            :addTo(self.actWebView_)
	            :pos(display.cx, display.cy)
	            :show()

	        --
	        self.actWebView_:setOnShouldStartLoading(function(sender, url)
	        	if not url or string.len(url) <= 0 then
	        		--todo
	        		dump("Wrong Url To Load.")

	        		return false
	        	end

	        	local orgUrl = string.urldecode(url)
	        	if orgUrl and string.len(orgUrl) > 0 then
	        		local matchStr = string.match(orgUrl, "%b{}")

	                if matchStr then
	                	local target = string.match(matchStr, "target")

	                	if target then
	                		--todo
	                		--self:disposeWebView()

	            			-- scheduler.performWithDelayGlobal(function()
                --             	self:onByActivityActionListener(matchStr)
                --         	end, 0.2)

                			self:onByActivityActionListener(matchStr)

                            return false
	                	else
	                		dump("Not Find Jump Param Target.")
	                	end
	                    
	                else
	                	dump("Not Find Matched Jump Param.")
	                end                
	            else
	            	dump("Wrong Start Loading Url.")
	            end

	            return true
	        end)

	        self.actWebView_:setOnDidFinishLoading(function(sender, url)
				if self.webviewLoading_ then
	                self.webviewLoading_:hide()
	            end
			end)

			self.actWebView_:setOnDidFailLoading(function(sender, url)
				if self.webviewLoading_ then
	                self.webviewLoading_:hide()
	            end
			end)

			local webUrl = self:getApiFullUrl("activities", "index", string.urlencode(json.encode(params)))
			dump(webUrl, "ActivityPopup:display.webUrl :")

			self.actWebView_:loadURL(webUrl)
        else
        	dump("ccexp.WebView Module Not Export!")
        end
    else
        dump("ByActivity Not Setup!")
    end
end

function ActivityPopup:setWebViewTimeOut(timeOut)
    -- body
    local time = timeOut or 250

    dump(time, "ActivityPopup:setWebViewTimeOut.time :==========")
end

function ActivityPopup:onWebViewModuleTouched_(evt)
	-- body
	self:disposeWebView()
end

function ActivityPopup:disposeWebView()
	-- body
	--if self.actWebView_ then
    --    self.actWebView_ = nil
    --end

    self.layerout:removeAllChildren()
    self.layerout:removeFromParent()

    self:onByActivityCloseListener(nil)

    self:close()
end

function ActivityPopup:show()
    nk.PopupManager:addPopup(self)
    return self
end

function ActivityPopup:close()
    nk.PopupManager:removePopup(self)
    return self
end

return ActivityPopup
