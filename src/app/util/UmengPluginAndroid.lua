local logger = bm.Logger.new("UmengPluginAndroid")
UmengPluginAndroid = class("UmengPluginAndroid")

function UmengPluginAndroid:ctor()
	
end

function UmengPluginAndroid:start()
    -- body
end

function UmengPluginAndroid:doCommand(args)
	if args.command == "setAppVersion" then
		-- MobClickCppForLua:setAppVersion(args.args.appVersion)
    elseif args.command == "setCrashReportEnabled" then
    	-- MobClickCppForLua:setCrashReportEnabled(args.args.value)
    elseif args.command == "setLogEnabled" then
        -- MobClickCppForLua:setLogEnabled(args.args.value)
    elseif args.command == "startWithAppkey" then
        -- args.args.channelId = args.args.channelId or 0
        -- MobClickCppForLua:startWithAppkey(args.args.appKey, args.args.channelId)
    elseif args.command == "applicationDidEnterBackground" then
        -- MobClickCppForLua:applicationDidEnterBackground()
    elseif args.command == "applicationWillEnterForeground" then
        -- MobClickCppForLua:applicationWillEnterForeground()
    elseif args.command == "end" then
        -- MobClickCppForLua:endAnalytics()
    elseif args.command == "event" then
        args.args.label = args.args.label or 0
        self:call_("event",{args.args.eventId,args.args.label},"(Ljava/lang/String;Ljava/lang/String;)V")
        -- MobClickCppForLua:event(args.args.eventId, args.args.label)
    elseif args.command == "eventCustom" then
        -- args.args.counter = args.args.counter or 0
        -- MobClickCppForLua:eventCustom(args.args.eventId, args.args.attributes, args.args.counter)
        do return end
        self:call_("eventCustom",{args.args.eventId,args.args.attributes},"(Ljava/lang/String;Ljava/lang/String;)V")
    elseif args.command == "eventValue" then
        args.args.counter = args.args.counter or 0
        -- MobClickCppForLua:eventCustom(args.args.eventId, args.args.attributes, args.args.counter)

        do return end
        self:call_("eventValue",{args.args.eventId,args.args.attributes,args.args.counter},"(Ljava/lang/String;Ljava/lang/String;I)V")

    elseif args.command == "beginEvent" then
        -- MobClickCppForLua:beginEvent(args.args.eventId)
        self:call_("beginEvent",{args.args.eventId},"(Ljava/lang/String;)V")
    elseif args.command == "endEvent" then
        -- MobClickCppForLua:endEvent(args.args.eventId)
        self:call_("endEvent",{args.args.eventId},"(Ljava/lang/String;)V")
    elseif args.command == "beginEventWithLabel" then
        -- MobClickCppForLua:beginEventWithLabel(args.args.eventId, args.args.label)
        self:call_("beginEventWithLabel",{args.args.eventId, args.args.label},"(Ljava/lang/String;Ljava/lang/String;)V")
    elseif args.command == "endEventWithLabel" then
        -- MobClickCppForLua:endEventWithLabel(args.args.eventId, args.args.label)
        self:call_("endEventWithLabel",{args.args.eventId, args.args.label},"(Ljava/lang/String;Ljava/lang/String;)V")
    elseif args.command == "beginEventWithAttributes" then
        -- MobClickCppForLua:beginEventWithAttributes(args.args.eventId, args.args.primarykey, args.args.attributes)
    elseif args.command == "endEventWithAttributes" then
        -- MobClickCppForLua:endEventWithAttributes(args.args.eventId, args.args.primarykey)
    elseif args.command == "beginLogPageView" then
        -- MobClickCppForLua:beginLogPageView(args.args.pageName)
    elseif args.command == "endLogPageView" then
        -- MobClickCppForLua:endLogPageView(args.args.pageName)
    elseif args.command == "checkUpdate" then
        -- MobClickCppForLua:checkUpdate()
    elseif args.command == "checkUpdateWithArgs" then
        -- MobClickCppForLua:checkUpdate(args.args.title, args.args.cancelTitle, args.args.otherTitle)
    elseif args.command == "setUpdateOnlyWifi" then
        -- MobClickCppForLua:setUpdateOnlyWifi(args.args.updateOnlyWifi)
    elseif args.command == "updateOnlineConfig" then
        -- MobClickCppForLua:updateOnlineConfig()
    elseif args.command == "getConfigParams" then
        -- return MobClickCppForLua:getConfigParams(args.args.key)
        return self:call_("endEvent",{args.args.key},"(Ljava/lang/String;)Ljava/lang/String;")
    elseif args.command == "setUserLevel" then
        -- MobClickCppForLua:setUserLevel(args.args.level)
    elseif args.command == "setUserInfo" then
        -- MobClickCppForLua:setUserInfo(args.args.userId, args.args.sex, args.args.age, args.args.platform)
    elseif args.command == "startLevel" then
        -- MobClickCppForLua:startLevel(args.args.level)
        self:call_("startLevel",{args.args.level},"(Ljava/lang/String;)V")
    elseif args.command == "finishLevel" then
        -- MobClickCppForLua:finishLevel(args.args.level)
        self:call_("finishLevel",{args.args.level},"(Ljava/lang/String;)V")
    elseif args.command == "failLevel" then
        -- MobClickCppForLua:failLevel(args.args.level)
        self:call_("failLevel",{args.args.level},"(Ljava/lang/String;)V")
    elseif args.command == "payCoin" then
        -- MobClickCppForLua:pay(args.args.cash, args.args.coin, args.args.source)
        self:call_("payCoin",{args.args.cash, args.args.coin, args.args.source},"(FFI)V")
    elseif args.command == "payItem" then

        -- MobClickCppForLua:pay(args.args.cash, args.args.item, args.args.number, args.args.price, args.args.source)
        self:call_("payItem",{args.args.cash, args.args.item, args.args.number, args.args.price, args.args.source},"(FLjava/lang/String;IFI)V")

    elseif args.command == "buy" then
        -- MobClickCppForLua:buy(args.args.item, args.args.number, args.args.price)
         self:call_("buy",{args.args.item, args.args.number, args.args.price},"(Ljava/lang/String;IF)V")

    elseif args.command == "use" then
        -- MobClickCppForLua:use(args.args.item, args.args.amount, args.args.price)
        self:call_("use",{args.args.item, args.args.number, args.args.price},"(Ljava/lang/String;IF)V")
    elseif args.command == "bonusCoin" then
        -- MobClickCppForLua:bonus(args.args.coin, args.args.trigger)
        self:call_("bonusCoin",{args.args.coin, args.args.trigger},"(FI)V")
    elseif args.command == "bonusItem" then
        -- MobClickCppForLua:bonus(args.args.item, args.args.amount, args.args.price, args.args.source)
         self:call_("bonusCoin",{args.args.item, args.args.num, args.args.price, args.args.trigger},"(Ljava/lang/String;IFI)V")
    elseif args.command == "beginScene" then
        -- MobClickCppForLua:beginScene(args.args.sceneName)
    elseif args.command == "endScene" then
        -- MobClickCppForLua:endScene(args.args.sceneName)
    elseif args.command == "reportError" then
        -- MobClickCppForLua:reportError(args.args.error)
        local errInfo = {}
        errInfo.errType = (args.args.errType or "Lua_Crash")
        errInfo.error = args.args.error or ""
        self:call_("reportError",{json.encode(errInfo)},"(Ljava/lang/String;)V")
    else
        printError("UmengPluginAndroid:doCommand() - not support command")
    end

end



function UmengPluginAndroid:call_(javaMethodName, javaParams, javaMethodSig)
    -- if device.platform == "android" then
    --     local ok, ret = luaj.callStaticMethod("com/boyaa/cocoslib/umeng/UmengBridge", javaMethodName, javaParams, javaMethodSig)
    --     if not ok then
    --         if ret == -1 then
    --             logger:errorf("call %s failed, -1 不支持的参数类型或返回值类型", javaMethodName)
    --         elseif ret == -2 then
    --             logger:errorf("call %s failed, -2 无效的签名", javaMethodName)
    --         elseif ret == -3 then
    --             logger:errorf("call %s failed, -3 没有找到指定的方法", javaMethodName)
    --         elseif ret == -4 then
    --             logger:errorf("call %s failed, -4 Java 方法执行时抛出了异常", javaMethodName)
    --         elseif ret == -5 then
    --             logger:errorf("call %s failed, -5 Java 虚拟机出错", javaMethodName)
    --         elseif ret == -6 then
    --             logger:errorf("call %s failed, -6 Java 虚拟机出错", javaMethodName)
    --         end
    --     end
    --     return ok, ret
    -- else
    --     logger:debugf("call %s failed, not in android platform", javaMethodName)
    --     return false, nil
    -- end
end



return UmengPluginAndroid