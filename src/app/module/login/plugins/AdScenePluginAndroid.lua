local logger = bm.Logger.new("AdScenePluginAndroid")


local AdScenePluginAndroid = class("AdScenePluginAndroid")

function AdScenePluginAndroid:ctor()

	-- self.sureListener_ = handler(self, self.onSureListener)
	-- self.cancelListener_ = handler(self, self.onCancelListener)
	-- self.closeListener_ = handler(self,self.onCloseListener)
 --    self.returnListener_ = handler(self,self.onReturnListener)
 --    -- self.getRewardListener_ = handler(self,self.onGetRewardListener)
	-- self:call_("setSureListener",{self.sureListener_},"(I)V")
	-- self:call_("setCancelListener",{self.cancelListener_},"(I)V")
	-- self:call_("setCloseListener",{self.closeListener_},"(I)V")
 --    self:call_("setReturnListener",{self.returnListener_},"(I)V")
    --self:call_("setGetRewardListener",{self.getRewardListener_},"(I)V")
	--test

	-- local appid = "196613001440388153"
 --    local appsec = "$2Y$10$VOH4CEYLH8CXAB0LBZRV5OD7X"
 --    local channelname = nk.Native:getChannelId()
	self:setup()
end

function AdScenePluginAndroid:setup()
    local appid = "196613001440388153"
    local appsec = "$2Y$10$VOH4CEYLH8CXAB0LBZRV5OD7X"
    local channelname = nk.Native:getChannelId()
	self:call_("setup",{appid,appsec,channelname},"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
end

function AdScenePluginAndroid:loadAdData(uid)
    self:call_("loadAdData",{uid,true},"(Ljava/lang/String;Z)V")
end

function AdScenePluginAndroid:showInterstitialAdDialog(leftTextId,rightTextId,callback)
	self.onReturnCallback_ = callback
	if leftTextId and rightTextId then
		self:call_("showInterstitialAdDialog2",{leftTextId,rightTextId},"(II)V")
	else
		self:call_("showInterstitialAdDialog1",{},"()V")
	end
end

function AdScenePluginAndroid:setShowRecommendBar(isShow)
    self:call_("setShowRecommendBar",{isShow},"(I)V")
end

function AdScenePluginAndroid:showInterstitialAdDialog(isFloat)
    self:call_("showInterstitialAdDialog",{isShow},"(Z)V")
end

function AdScenePluginAndroid:showSudokuDialog(isFloat)
    self:call_("showSudokuDialog",{isShow},"(Z)V")
end

function AdScenePluginAndroid:showRewardDialog(isFloat)
    self:call_("showRewardDialog",{isShow},"(Z)V")
end

function AdScenePluginAndroid:clearAll()
	self:call_("clearData",{},"()V")
end

function AdScenePluginAndroid:call_(javaMethodName, javaParams, javaMethodSig)
    if device.platform == "android" then
        local ok, ret = luaj.callStaticMethod("com/boomegg/cocoslib/adscene/AdSceneBridge", javaMethodName, javaParams, javaMethodSig)
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


return AdScenePluginAndroid
