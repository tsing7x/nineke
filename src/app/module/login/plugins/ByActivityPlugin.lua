--
-- Author: TsingZhang@boyaa.com
-- Modify: WebbZhang@boyaa.com
-- Date: 2017-11-23 10:23:27
-- ModifyDate：2018-1-3
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: ByActivityPlugin.lua Created By Tsing7x.
-- ModifyDescription：Repair Flash Back
--

local logger = bm.Logger.new("ByActivityPlugin")

local ByActivityJumpManager = import("..ByActivityJumpManager")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

local appid = 9606

local ByActivityPlugin = class("ByActivityPlugin")

function ByActivityPlugin:ctor()
	-- body
    --设置webview父容器，通过容器释放
    self.layerout = display.newNode()
        :pos(display.width/2, display.height/2)
        :addTo(nk.runningScene)

    local ActivityServerUrl = {
        { name="内网测试",url="http://192.168.204.68/operating/web/index.php?m=%s&p=%s&appid=%s&api=%s"},
        { name="线上测试",url="http://mvlp9kapi.boyaagame.com/?m=%s&p=%s&appid=%s&api=%s"},
        { name="正式环境",url="http://mvlp9kapi.boyaagame.com/?m=%s&p=%s&appid=%s&api=%s"}
    }

    self:setup()
    self.apiUrl_ = ActivityServerUrl[1].url    
    print(self.apiUrl_)
end

function ByActivityPlugin:getApiFullUrl(m, p, api)
	-- body
    return string.format(self.apiUrl_, m, p, self.appid_, api)
end

function ByActivityPlugin:getBaseParams()
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

function ByActivityPlugin:setup()
	-- body
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

    self.jumpManager_ = ByActivityJumpManager.new()
end

function ByActivityPlugin:onByActivityActionListener(jsonStr)
	-- body
	local jsonObj = json.decode(jsonStr)
	-- dump(jsonObj, "ByActivityPlugin:onByActivityActionListener.jsonObj :=================")

    if jsonObj then
        self.jumpManager_:doJump(jsonObj)        
    else
    	dump("json.decode(jsonStr) Fail! jsonStr Param Wrong.")
    end
end

function ByActivityPlugin:display()        
    --初始化WebView
    if ccexp.WebView then
    		
    	self.actWebView_ = ccexp.WebView:create()
        self.actWebView_:setVisible(true)
        self.actWebView_:setScalesPageToFit(true)
        self.actWebView_:setContentSize(cc.size(display.width,display.height))
        self.actWebView_:setPosition(0,0)
        self.layerout:addChild(self.actWebView_)

        --是否跳转回调
        self.actWebView_:setOnShouldStartLoading(function(sender, url)
			return self:loadJump(sender, url)
        end)

        self.actWebView_:setOnDidFinishLoading(function(sender, url)                
            --self.layerout:addChild(self.actWebView_)
        end)

        local params = self:getBaseParams()
        self.webUrl = self:getApiFullUrl("activities", "index", string.urlencode(json.encode(params)))
		self.actWebView_:loadURL(self.webUrl)
        --self.actWebView_:reload()

    else
        dump("ccexp.WebView Module Not Export!")
    end
end

--判断是跳转回客户端还是页内跳转
function  ByActivityPlugin:loadJump(sender, url)
	if not url or string.len(url) <= 0 then
	    --todo
	    dump("Wrong Url To Load.")
	    return false
	end

	local orgUrl = string.urldecode(url)

	--取出字符串判断是否有跳转的标签
	if orgUrl and string.len(orgUrl) > 0 then
		local matchStr = string.match(orgUrl, "%b{}")
		local jumpStr = nil

		if matchStr then
	    	local target = string.match(matchStr, "target")

	    	if target then

	    		jumpStr = matchStr

                self:disposeWebView()
	    		--本地跳转
	    		--注意关闭Webview
                scheduler.performWithDelayGlobal(function()
                    self:onByActivityActionListener(jumpStr)
                end, 0.2)
            	return true
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
end

--释放Webview
function ByActivityPlugin:disposeWebView()

    self.layerout:removeAllChildren()
    self.layerout:removeFromParent()
end

return ByActivityPlugin
