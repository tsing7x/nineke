--
-- Author: johnny@boomegg.com
-- Date: 2014-08-26 21:26:45
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local HallController = class("HallController")


local logger                = bm.Logger.new("HallController")
local RegisterRewardPopup   = import("app.login.RegisterRewardPopup")
local LoginRewardView       = import("app.module.loginreward.LoginRewardView")
local StorePopup            = import("app.module.newstore.StorePopup")
local MessageData           = import("app.module.hall.message.MessageData")
local FriendData            = import("app.module.friend.FriendData")
local LoadGiftControl       = import("app.module.gift.LoadGiftControl")
local CallbackGiftView      = import 'app.module.hall.CallbackGiftView'
local LoadMatchControl      = import("app.module.match.LoadMatchControl")
local SlotPopup             = import("app.module.slot.SlotPopup")
local FbGuidePopup          = import('app.module.FacebookGuide.FbGuidePopup')
local MatchStartPopup       = import("app.module.match.MatchStartPopup")
local GuidePayPopup         = import("app.module.firstpay.GuidePayPopup")
local FirstPayPopup         = import("app.module.firstpay.FirstPayPopup")
local PlayerbackModel       = import("app.module.playerback.PlayerbackModel")

-- 系统公告
local BillboardPopup = import 'app.module.billboard.BillboardPopup'
local BillboardController = import('app.module.billboard.BillboardController')

-- 视图类型
HallController.FIRST_OPEN      = 0
HallController.LOGIN_GAME_VIEW = 1
HallController.MAIN_HALL_VIEW  = 2
HallController.CHOOSE_NOR_VIEW = 3
HallController.CHOOSE_PRO_VIEW = 4
HallController.CHOOSE_ARENA_VIEW = 5
HallController.CHOOSE_4K_VIEW = 6
HallController.CHOOSE_5K_VIEW = 7
HallController.CHOOSE_DICE_VIEW = 8
HallController.CHOOSE_PDENG_VIEW = 9

-- 事件TAG
HallController.ENTER_ROOM_WITH_DATA_EVENT_TAG = 100
HallController.LOGIN_ROOM_SUCC_EVENT_TAG = 101
HallController.LOGIN_ROOM_FAIL_EVENT_TAG = 102
HallController.HALL_LOGOUT_SUCC_EVENT_TAG = 103
HallController.SERVER_STOP_EVENT_TAG = 104
HallController.DOUBLE_LOGIN_EVENT_TAG = 105
HallController.APP_ENTER_FOREGROUND_TAG = 106
HallController.SVR_ERROR_EVENT_TAG = 107

HallController.LOGIN_MATCH_SUCC_EVENT_TAG = 200
HallController.LOGIN_MATCH_FAIL_EVENT_TAG = 201
HallController.MATCH_STARTING_EVENT_TAG = 202
HallController.MATCH_JOIN_ERROR_EVENT_TAG = 203
HallController.LOGIN_MATCH_ROOM_FAIL = 204

HallController.LOGIN_DICE_SUCC_EVENT_TAG = 301
HallController.LOGIN_DICE_FAIL_EVENT_TAG = 302
HallController.LOGIN_PDENG_SUCC_EVENT_TAG = 401
HallController.LOGIN_PDENG_FAIL_EVENT_TAG = 402
-- 动画时间
HallController.ANIM_TIME = 0.5

JSON_PARSE_ERROR_KEY = "JSON_PARSE_ERROR_KEY"
reportJsonData = {}

function HallController:ctor(scene)
    self.scene_ = scene
    self:dealMatchConfigUpdate()
    -- 绑定事件
    bm.EventCenter:addEventListener(nk.eventNames.ENTER_ROOM_WITH_DATA, handler(self, self.onEnterRoom_), HallController.ENTER_ROOM_WITH_DATA_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.eventNames.LOGIN_ROOM_SUCC, handler(self, self.onLoginRoomSucc_), HallController.LOGIN_ROOM_SUCC_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.eventNames.LOGIN_ROOM_FAIL, handler(self, self.onLoginRoomFail_), HallController.LOGIN_ROOM_FAIL_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.eventNames.SERVER_STOPPED, handler(self, self.onServerStop_), HallController.SERVER_STOP_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.eventNames.SVR_ERROR, handler(self, self.onServerFail_), HallController.SVR_ERROR_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.eventNames.HALL_LOGOUT_SUCC, handler(self, self.handleLogoutSucc_), HallController.HALL_LOGOUT_SUCC_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.eventNames.DOUBLE_LOGIN_LOGINOUT, handler(self, self.handleDoubleLogin_), HallController.DOUBLE_LOGIN_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.eventNames.APP_ENTER_FOREGROUND, handler(self, self.onEnterForeground_), HallController.APP_ENTER_FOREGROUND_TAG)

    -- 比赛场事件
    bm.EventCenter:addEventListener(nk.eventNames.LOGIN_MATCH_SUCC, handler(self, self.onLoginMatchSucc_), HallController.LOGIN_MATCH_SUCC_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.eventNames.LOGIN_MATCH_FAIL, handler(self, self.onLoginMatchFail_), HallController.LOGIN_MATCH_FAIL_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.eventNames.MATCH_STARTING, handler(self, self.onStartMatch_), HallController.MATCH_STARTING_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.eventNames.MATCH_JOIN_ERROR, handler(self, self.onJoinMatchError_), HallController.MATCH_JOIN_ERROR_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.eventNames.LOGIN_MATCH_ROOM_FAIL,handler(self, self.onJoinMatchFail_), HallController.LOGIN_MATCH_ROOM_FAIL)


    bm.EventCenter:addEventListener(nk.eventNames.LOGIN_DICE_SUCC, handler(self, self.onLoginDiceSucc_), HallController.LOGIN_DICE_SUCC_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.eventNames.LOGIN_DICE_FAIL, handler(self, self.onLoginDiceFail_), HallController.LOGIN_DICE_FAIL_EVENT_TAG)
    
    bm.EventCenter:addEventListener(nk.eventNames.LOGIN_PDENG_SUCC, handler(self, self.onLoginPdengSucc_), HallController.LOGIN_PDENG_SUCC_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.eventNames.LOGIN_PDENG_FAIL, handler(self, self.onLoginPdengFail_), HallController.LOGIN_PDENG_FAIL_EVENT_TAG)

    --登录是否正在处理 -1 未登陆，1 正在登陆  2 已经登陆
    self.isLoginInProgress_ = -1

    --登陆后的弹框需要一个一个的弹，此处先缓冲要弹的框
    self.PendingPopup = {}
end

function HallController:dealMatchConfigUpdate()
    if nk.needReConnectMatch then
        nk.needReConnectMatch = nil
        nk.socket.MatchSocket:disconnect()
    end
    if nk.needReloadMatchConfig then -- 场景切换
        nk.needReloadMatchConfig = nil
        LoadMatchControl:getInstance():deleteInstance()
    end
end

function HallController:onEnterRoom_(evt)
    local data = evt.data
    nk.userData.tableFlag = data.tableFlag
    nk.userData.tableType = data.tableType
    if data.dice == 1 and nk.userData.dicelevel then
        if nk.userData.level < nk.userData.dicelevel then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL", "ROOM_DICE_LIMIT_TIPMSG", nk.userData.dicelevel))
            return
        end
    end
    -- 添加加载loading
    self.roomLoading_ = nk.ui.RoomLoading.new(bm.LangUtil.getText("ROOM", "ENTERING_MSG"))
        :addTo(self.view_, 100)
    if data.dice == 1 then
        self:startConnectDice(data.ip, data.port, data.tid)
    elseif data.dice == 2 then
        self:startConnectPdeng(data.ip, data.port, data.tid)
    else
        self:startConnectRoom(data.ip, data.port, data.tid, data.isPlayNow, data.psword, evt.isTrace)
    end
end

function HallController:checkNeedEnterRoomInLoginData()
    if nk.userData.tid and nk.userData.ip and nk.userData.port then
        -- 添加加载loading
        self.roomLoading_ = nk.ui.RoomLoading.new(bm.LangUtil.getText("ROOM", "ENTERING_MSG"))
            :addTo(self.view_, 100)
        if nk.userData.dice == 1 then
            self:startConnectDice(nk.userData.ip, nk.userData.port, nk.userData.tid)
        elseif nk.userData.dice == 2 then
            self:startConnectPdeng(nk.userData.ip, nk.userData.port, nk.userData.tid)
        else
            self:startConnectRoom(nk.userData.ip, nk.userData.port, nk.userData.tid, false)
        end
    end
end

function HallController:loginWithGuest()
    if self.isLoginInProgress_ > 0 then
        return
    end
    self.isLoginInProgress_ = 1
    local lastLoginType = nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE)
    local isLoginedDevice = (lastLoginType and lastLoginType ~= "")
    nk.userDefault:setStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE, "GUEST")
    nk.userDefault:flush()

    -- 登录动画
    self.view_:playLoginAnim()

    nk.schedulerPool:delayCall(function ()
        self:startGuestLogin_("")
    end, HallController.ANIM_TIME)
end

function HallController:checkAutoLogin()
    self:getJsonTab()
    self:reportJsonTab()
    local lastLoginType = nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE)
    if lastLoginType == "GUEST" then
        self:loginWithGuest()
    elseif lastLoginType == "FACEBOOK" then
        local accessToken = nk.userDefault:getStringForKey(nk.cookieKeys.FACEBOOK_ACCESS_TOKEN, "")
        if accessToken and accessToken ~= "" then
            local accessTokenTbl = string.split(accessToken, "#")
            if #accessTokenTbl > 1 and accessTokenTbl[2] then
                self:loginFacebookWithAccessTokenAndMtkey_(accessTokenTbl[1], accessTokenTbl[2])
            else
                self:loginFacebookWithAccessToken_(accessToken)
            end
        end
    end
end

-- 确定奖励类型,用以弹出相应的提示
function HallController:getQuitTipInfo()
    local tip_str

    local k = nk.cookieKeys.QT_NEXT_DAY_CHIPS_TYPE
    local tip_type = nk.userDefault:getStringForKey(k)
    if tip_type == 'new_user_register_reward' or tip_type == 'daily_login_reward' then
        tip_str = bm.LangUtil.getText("COMMON", "QUIT_DIALOG_MSG_A")
    else
        tip_str = bm.LangUtil.getText("COMMON", "QUIT_DIALOG_MSG")
    end
    k = nk.cookieKeys.QT_NEXT_DAY_CHIPS_REWARD
    local v = nk.userDefault:getStringForKey(k, '')
    local r = bm.LangUtil.formatString(tip_str, v)
    logger:info('quit tip: ', r)
    return r
end

function HallController:checkFbGuide()
    if nk.userDefault:getBoolForKey(nk.cookieKeys.GTF_GUIDE_TO_FACEBOOK, false) then
        return false
    end

    local one_day = 60 * 60 * 24 -- 一天的秒数
    local now_time = os.time()

    local check_time_key = nk.cookieKeys.GTF_CHECK_TODAY
    local last_check_time = nk.userDefault:getStringForKey(check_time_key, '_')
    if last_check_time == '_' then
        nk.userDefault:setStringForKey(check_time_key, tostring(now_time))
        return false
    else
        last_check_time = tonumber(last_check_time)
        if math.abs(os.difftime(now_time, last_check_time)) > one_day then
            -- 处理情况: 保存下来的时间不一定比当前时间早: 可能用户调整时钟了
            nk.userDefault:setStringForKey(check_time_key, tostring(now_time))
        else
            return false
        end
    end

    local c = nk.userDefault:getIntegerForKey(nk.cookieKeys.GTF_LOGIN_COUNT, 1)

    -- note: 运营说将来可能会从服务器读取 次数
    local GUIDE_WHEN = 4
    if c < GUIDE_WHEN then
        nk.userDefault:setIntegerForKey(nk.cookieKeys.GTF_LOGIN_COUNT, c + 1)
        return false
    elseif c == GUIDE_WHEN then
        nk.userDefault:setBoolForKey(nk.cookieKeys.GTF_GUIDE_TO_FACEBOOK, true)
        return true
    else
        return false
    end
end

function HallController:startGuestLogin_(deviceName)
    local currentVersion = nk.Native:getAppVersion()
    currentVersion = BM_UPDATE and BM_UPDATE.VERSION or currentVersion
    currentVersion = string.sub(currentVersion, 5, 5)
    currentVersion = tonumber(currentVersion)

    --密匙针对版本进行区分
    local secret = "dZk=[fI&^83@#K)4DE" --2.6.1.0
    if currentVersion == 0 then 
        secret = "qWM[-*8zY)m@#H0Ch2" --2.6.0.0
    end

    local loginToken = nk.Native:getLoginToken()
    local deviceInfo = nk.Native:getDeviceInfo()

    bm.HttpService.POST_URL(appconfig.LOGIN_SERVER_URL,
        {
            mobile_request = loginToken,
            device = (device.platform == "windows" and nk.TestUtil.simuDevice or device.platform),
            pay = (device.platform == "windows" and nk.TestUtil.simuDevice or device.platform),
            osVersion = "1.0.0",
            version = BM_UPDATE and BM_UPDATE.VERSION or nk.Native:getAppVersion(),
            deviceId = deviceInfo.deviceId,
            deviceName = deviceInfo.deviceName,
            deviceModel = deviceInfo.deviceModel,
            installInfo = deviceInfo.installInfo,
            cpuInfo = deviceInfo.cpuInfo,
            ramSize = deviceInfo.ramSize,
            simNum = deviceInfo.simNum,
            networkType = deviceInfo.networkType,
            phoneNumbers = deviceInfo.phoneNumbers,
            location = deviceInfo.location,
            macAddr = nk.Native:getMacAddr(),
            idfa = nk.Native:getIDFA(),
            mtkey = "",
            udid = crypto.md5(nk.Native:getIDFA()) or "",
            channel_id = string.split(nk.Native:getByChannelId(),"-")[1] or "",
            sid = appconfig.SID[string.upper(device.platform)],
            m_os = string.split(deviceInfo.deviceModel,"|")[-1] or "",
            m_network = deviceInfo.networkType,
            sign = crypto.md5(loginToken..secret),
            gpLogined = 1,
            isPrisonBag = IS_PRISONBAG
        },
        handler(self, self.onLoginSucc_),
        handler(self, self.onLoginError_)
    )
end

function HallController:loginWithFacebook(loginBtn, guestLoginBtn)
    if self.isLoginInProgress_ > 0 then
        return
    end
    self.loginBtn = loginBtn
    self.guestLoginBtn = guestLoginBtn
    self.isLoginInProgress_ = 1
    nk.userDefault:setStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE, "FACEBOOK")
    nk.userDefault:flush()
    if nk.Facebook then
        nk.Facebook:login(function(success, result)
            logger:debug(success, result)
            if success then
                self:loginFacebookWithAccessToken_(result)
            else
                if self.loginBtn then
                    self.loginBtn:setButtonEnabled(true)
                end
                if self.guestLoginBtn then
                    self.guestLoginBtn:setButtonEnabled(true)
                end

                self.isLoginInProgress_ = -1
                if result == "canceled" then
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("LOGIN", "CANCELLED_MSG"))
                    self:reportLoginResult_(nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE), "5", "authorization cancelled")
                else
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("TIPS", "ERROR_LOGIN_FACEBOOK"))
                    self:reportLoginResult_(nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE), "6", "authorization failed")
                end
            end
        end)
    end
end

function HallController:loginFacebookWithAccessToken_(accessToken)
    nk.Facebook.setAccessToken(accessToken)
    nk.Facebook.getId(function(data)
        local idsTbl = json.decode(data)
        if type(idsTbl) == "table" and idsTbl.id then
            local id = idsTbl.id
            local mtkey = nk.userDefault:getStringForKey(nk.cookieKeys.LOGIN_MTKEY..id, "")
            self:loginFacebookWithAccessTokenAndMtkey_(accessToken, mtkey)
        else
            self:loginFacebookWithAccessTokenAndMtkey_(accessToken, "")
        end
    end, function()
        self:loginFacebookWithAccessTokenAndMtkey_(accessToken, "")
    end)
end

function HallController:loginFacebookWithAccessTokenAndMtkey_(accessToken, mtkey)
    self.view_:playLoginAnim()
    -- 开始登录
    self.facebookAccessToken_ = accessToken
    nk.userDefault:setStringForKey(nk.cookieKeys.FACEBOOK_ACCESS_TOKEN, accessToken.."#"..mtkey)
    nk.userDefault:flush()
    local deviceInfo = nk.Native:getDeviceInfo()

    bm.HttpService.POST_URL(appconfig.LOGIN_SERVER_URL,
        {
            mobile_request = nk.Native:getLoginToken(),
            signed_request = accessToken,
            device = (device.platform == "windows" and nk.TestUtil.simuDevice or device.platform),
            pay = (device.platform == "windows" and nk.TestUtil.simuDevice or device.platform),
            osVersion = "1.0.0",
            version = BM_UPDATE and BM_UPDATE.VERSION or nk.Native:getAppVersion(),
            deviceId = deviceInfo.deviceId,
            deviceName = deviceInfo.deviceName,
            deviceModel = deviceInfo.deviceModel,
            installInfo = deviceInfo.installInfo,
            cpuInfo = deviceInfo.cpuInfo,
            ramSize = deviceInfo.ramSize,
            simNum = deviceInfo.simNum,
            networkType = deviceInfo.networkType,
            phoneNumbers = deviceInfo.phoneNumbers,
            location = deviceInfo.location,
            macAddr = nk.Native:getMacAddr(),
            idfa = nk.Native:getIDFA(),
            mtkey = mtkey,
			udid = crypto.md5(nk.Native:getIDFA()) or "",
            channel_id = string.split(nk.Native:getByChannelId(),"-")[1] or "",
            sid = appconfig.SID[string.upper(device.platform)],
            isPrisonBag = IS_PRISONBAG
        },
        handler(self, self.onLoginSucc_),
        handler(self, self.onLoginError_)
    )
end

function HallController:onLoginSucc_(data)
    self.isLoginInProgress_ = 2

    local retData = json.decode(data)
    -- dump(retData, "HallController:onLoginSucc_.retData :==================")

    if type(retData) == "table" and retData.uid and tonumber(retData.uid) > 0 then
        self.isEnteringRoom_ = false
        self:processUserData(retData)

        local lastLoginType = nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE)
        -- 设置比赛相关数据
        retData.score = 0
        retData.goldCoupon = 0
        retData.gameCoupon = 0
        retData.gameCouponE2P = 0
        -- 设置为全局数据
        bm.DataProxy:setData(nk.dataKeys.USER_DATA, retData, true)
        -- 设置玩家登陆时等级
        nk.userDefault:setStringForKey(nk.cookieKeys.LOGIN_USER_LEVEL, nk.userData.level)
        nk.userDefault:flush()

        -- 设置http请求的默认参数
        bm.HttpService.setDefaultURL(retData.CGI_ROOT)

        bm.HttpService.setDefaultParameter("mtkey", retData.mtkey)
        bm.HttpService.setDefaultParameter("skey", retData.skey)
        bm.HttpService.setDefaultParameter("uid", retData.uid)
        bm.HttpService.setDefaultParameter("macid",nk.Native:getMacAddr() or "")
        bm.HttpService.setDefaultParameter("version", BM_UPDATE and BM_UPDATE.VERSION or nk.Native:getAppVersion())
        bm.HttpService.setDefaultParameter("device", (device.platform == "windows" and nk.TestUtil.simuDevice or device.platform))
        bm.HttpService.setDefaultParameter("channel", retData.channel)
        bm.HttpService.setDefaultParameter("sid", appconfig.SID[string.upper(device.platform)] or 1)
        bm.HttpService.setDefaultParameter("udid", crypto.md5(nk.Native:getIDFA()) or "")
        bm.HttpService.setDefaultParameter("channel_id", string.split(nk.Native:getByChannelId(),"-")[1] or "")
        bm.HttpService.setDefaultParameter("isPrisonBag", IS_PRISONBAG)
 
        -- 指引
        nk.TutorialManager = import("app.module.tutorial.TutorialManager").new()

        if lastLoginType ==  "FACEBOOK" then
            bm.HttpService.setDefaultParameter("lid", 1)
            nk.userData.lid = 1
            nk.userData.showRecall = true
        elseif lastLoginType == "GUEST" then
            bm.HttpService.setDefaultParameter("lid", 2)
            nk.userData.lid = 2
            nk.userData.showRecall = false
        end

        -- if not nk.userData.autoShowInvite then
        --     nk.userData.autoShowInvite = false
        --     if lastLoginType == "FACEBOOK" and nk.userData.dailyFirstin == 1 then
        --         if nk.userData.level < 8 then
        --             if nk.userData.money + nk.userData.bank_money < 1000000 then
        --                 nk.userData.autoShowInvite = true
        --             end
        --         end
        --     end
        -- end

        if nk.ByActivity then
            nk.ByActivity:setup()
            -- if appconfig.LOGIN_SERVER_URL == "http://nineke-th-demo.boyaa.com/mobile.php?demo=1" then
            --     nk.ByActivity:switchServer(1)
            -- else
            --     nk.ByActivity:switchServer(0)
            -- end
        end
        -- if nk.AdSceneSdk then
        --     nk.AdSceneSdk:loadAdData(nk.userData.uid)
        -- end

        if nk.userData.broke_money and tonumber(nk.userData.broke_money) ~= 0 then
            appconfig.CRASHMONEY = tonumber(nk.userData.broke_money)
        end
        if nk.userData.broke_gcoins and tonumber(nk.userData.broke_gcoins) ~= 0 then
            appconfig.CRASHGCOINS = tonumber(nk.userData.broke_gcoins)
        end
        -- 加载开关
        self:removeOnOffLoadListener();
        self.onOffLoadId_ = bm.EventCenter:addEventListener("OnOff_Load", handler(self, self.onOffLoadCallback_))
        nk.OnOff.isFirst = true
        app:loadOnOffData();

        -- 加载比赛场门票
        nk.MatchTickManager:synchPhpTickList();
        nk.MatchDailyManager:synchPhpDailyList();

        -- 派发登录成功事件
        bm.EventCenter:dispatchEvent(nk.eventNames.HALL_LOGIN_SUCC)
        -- 
        self:proLoginedPopup_()
        -- 推送注册
        if nk.Push then
            nk.Push:register(function(success, result)
                if success then
                    bm.HttpService.POST({
                        mod="mobile", act="pushToken", token=result
                    })
                end
            end)
        end
        if nk.GcmPush then
            nk.GcmPush:register(function(success, result)
                if success then
                    bm.HttpService.POST({
                        mod="Push", act="pushToken", token=result, 
                        key=crypto.md5(nk.userData.uid .. appconfig.SID[string.upper(device.platform)] .. result .. "_boyaa")
                    })
                end
            end)
        end
        -- 上报广告平台 注册和登录
        -- 第一次登录上报注册信息
        if nk.userData.firstin ~= nil and nk.userData.firstin == 1 then
            nk.userData.gameCount = 0
            nk.AdSdk:report(consts.AD_TYPE.AD_REG,{uid =tostring(nk.userData.uid),userType = lastLoginType })
        end
        -- 超过7天没有登录 上报召回信息
        if tonumber(nk.userData.today) ~= nil and tonumber(nk.userData.lasttime) ~= nil and
            (tonumber(nk.userData.today) - tonumber(nk.userData.lasttime)  > 604800 ) then
            nk.AdSdk:report(consts.AD_TYPE.AD_RECALL,{uid = tostring(nk.userData.siteuid)})
        end
        -- 上报登录信息
        nk.AdSdk:report(consts.AD_TYPE.AD_LOGIN,{uid = tostring(nk.userData.siteuid)})

        local proxyList = self:getProxyListFromUserData_(retData)

        --设置代理
        nk.socket.ProxySelector.setProxyList(proxyList)

        --代理测速
        --取消代理测试,由于代理机器在同一机房测速意义不大
        --require("app.module.login.ProxySpeedTest").new(proxyList)

	    -- 连接大厅server
        local ip,port = string.match(nk.userData.HallServer[1], "([%d%.]+):(%d+)")
        nk.socket.HallSocket:connectDirect(ip, port, true)

        -- 拉取消息
        self.onGetMessage()

        --预拉取商城数据
        self.preGetMarketData()


        self:reportLoginResult_(lastLoginType, "0", "login success")
        if lastLoginType ==  "FACEBOOK" then
            retData.canEditAvatar = false
            -- 设置FB好友为牌友
            bm.HttpService.POST({mod="friend", act="setFriends", access_token=self.facebookAccessToken_},
                function(ret)
                    print("set facebook friends ret -> ", ret)
                end,
                function()
                    print("set facebook friends fail")
                end)
            -- update apprequest
            nk.Facebook:updateAppRequest()
            -- 上报能邀请的好友数量
            self:reportInvitableFriends_()

            -- facebook 保存mtkey用于快速登录
            nk.userDefault:setStringForKey(nk.cookieKeys.LOGIN_MTKEY..nk.userData.siteuid, retData.mtkey)
            nk.userDefault:flush()

        elseif lastLoginType == "GUEST" then
            retData.canEditAvatar = true

            -- 正常登录完成后, 检查是否符合弹窗条件, 弹窗
            -- 用户如果不接受引导,则可以继续玩
            if self:checkFbGuide() then
                self.scene_:performWithDelay(function ()
                    FbGuidePopup.new():showPopup()
                end, HallController.ANIM_TIME + 0.3)
            end
        end

        --更新折扣率
        self:updateUserMaxDiscount()

        --缓存礼物
        if nk.config.GIFT_SHOP_ENABLED and retData.GIFT_JSON then
            LoadGiftControl:getInstance():loadConfig(retData.GIFT_JSON)
        end

        self:reportLoginAccountCount_(retData.uid)

        -- 加载比赛相关数据
        LoadMatchControl:getInstance():loadConfig("",function(success, data)
                if success then
                    -- 检测比赛报名情况 连接比赛服务器
                    local matchStatus = nk.userDefault:getIntegerForKey(nk.cookieKeys.IS_JOIN_MATCH..nk.userData.uid,0)
                    -- matchStatus = 1
                    if matchStatus==1 then
                        self:startConnectMatch("127.0.0.1", 8081,true)
                    end
                end
            end)

        -- 显示推送弹窗
        local startType = -1
        if nk and nk.Native and nk.Native.getStartType then
            startType = nk.Native:getStartType()
        end
        if startType<1 then
            startType = self.scene_.lastStartType or -1
        end
        if startType>0 and self.scene_ and self.scene_.showPushView then
            self.scene_:showPushView(startType,true)
        end
        -- 快速开始规则
        if not nk.userData.sbGuide then
            bm.HttpService.POST({
                    mod = "Table",
                    act = "sbGuide"
                },
                function(data)
                    nk.userData.sbGuide = json.decode(data)
                end,
                function()
                    
                end)
        end
        nk.userData.sbGuideHight = 0
        nk.userData.sbGcoinsGuideHight = 0
    else
        if not retData then
            if #reportJsonData < 10 then
                table.insert(reportJsonData,{errordata = data})
            end
            self:reportJsonTab()
            self:reportLoginResult_(nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE), "1", "json parse error")
            local deviceInfo = nk.Native:getDeviceInfo()
            bm.HttpService.POST_URL(appconfig.LOGIN_SERVER_URL, {
                report = "true",
                cli_err_type = "json parse error",
                cli_receive_pack = data,
                version = BM_UPDATE and BM_UPDATE.VERSION or nk.Native:getAppVersion(),
                deviceId = deviceInfo.deviceId,
                deviceName = deviceInfo.deviceName,
                deviceModel = deviceInfo.deviceModel,
                installInfo = deviceInfo.installInfo,
                cpuInfo = deviceInfo.cpuInfo,
                ramSize = deviceInfo.ramSize,
                simNum = deviceInfo.simNum,
                macAddr = nk.Native:getMacAddr(),
                idfa = nk.Native:getIDFA(),
				udid = crypto.md5(nk.Native:getIDFA()) or "",
				channel_id = string.split(nk.Native:getByChannelId(),"-")[1] or "",
                device = (device.platform == "windows" and nk.TestUtil.simuDevice or device.platform),
            })
        elseif retData.ret == -100 then
            --被封号
            self:reportLoginResult_(nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE), "7", "user banned")
            nk.ui.Dialog.new({
                messageText = retData.msg,
                closeWhenTouchModel = false,
                hasFirstButton = false,
                hasCloseButton = false,
            }):show()
            self.view_:playLoginFailAnim()
        elseif retData.ret == -9999 then
            self:reportLoginResult_(nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE), "2", "server stopped")
            --停服处理
            nk.ui.Dialog.new({
                messageText = retData.msg,
                closeWhenTouchModel = false,
                hasFirstButton = false,
                hasCloseButton = false,
            }):show()
            self.view_:playLoginFailAnim()
            return
        elseif retData.uid <= 0 then
            logger:error("uid is", retData.uid)
            local lastLoginType = nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE)
            self:reportLoginResult_(lastLoginType, "3", "uid<0;" .. data)
            if lastLoginType ==  "FACEBOOK" then
                if nk.Facebook then
                    nk.Facebook:logout()
                end
            end
        end
        self:onLoginError_()
    end
end

function HallController:getProxyListFromUserData_(userData)
    local ret = {}
    if userData.proxyAddr_array then
        for _, proxyAddr in ipairs(userData.proxyAddr_array) do
            local proxyArr = string.split(proxyAddr, ":")
            local proxyIp = proxyArr[1]
            local proxyPort = checkint(proxyArr[2])
            if proxyIp and string.len(proxyIp) > 0 and proxyPort > 0 then
                table.insert(ret, {ip=proxyIp, port=proxyPort})
            end
        end
    end
    return ret
end

-- 上报可邀请的好友数量
function HallController:reportInvitableFriends_()
    if device.platform == "android" or device.platform == "ios" then
        local date = nk.userDefault:getStringForKey(nk.cookieKeys.DALIY_REPORT_INVITABLE)
        nk.Facebook:getInvitableFriends(nk.userData.newInviteFbNum, function(success, friendData)
            if success then
                if date ~= os.date("%Y%m%d") then
                    local count = #friendData
                    nk.userDefault:setStringForKey(nk.cookieKeys.DALIY_REPORT_INVITABLE, os.date("%Y%m%d"))
                    -- 能够邀请的facebook好友数
                    cc.analytics:doCommand{
                        command = "eventCustom",
                        args = {
                            eventId = "invitable_facebook_friends",
                            attributes = "type,invitable",
                            counter = count
                        }
                    }

                    -- 已不能邀请好友的用户数
                    if count == 0 then
                        cc.analytics:doCommand{
                            command = "event",args = {eventId = "disabled_invite_users",label = "disabled_invite_users"}
                        }
                    end

                    -- 新用户能够邀请的好友数
                    if nk.userData.loginRewardStep == 1 then
                        cc.analytics:doCommand{
                            command = "eventCustom",
                            args = {
                                eventId = "new_user_invitable_fb",
                                attributes = "type,invitable",
                                counter = count
                            }
                        }
                    end
                end
            end
        end)
    end
end

function HallController:processUserData(userData)
    --未返回的数字初始化一个值
    userData.win = userData.win and tonumber(userData.win) or 0
    userData.lose = userData.lose and tonumber(userData.lose) or 0
    userData.maxmoney = userData.maxmoney and tonumber(userData.maxmoney) or 0
    userData.s_picture = userData.s_picture or ""
    userData.m_picture = userData.m_picture or ""
    userData.b_picture = userData.b_picture or ""
end

function HallController:onRewardPopup()
    if nk.userData.loginRewardStep ~= nil and nk.userData.loginRewardStep > 0 then
        display.addSpriteFrames("register_reward.plist", "register_reward.png", handler(self, self.onLoadRegisterTextureComplete))
    end
end

function HallController:onLoadRegisterTextureComplete()
    if nk.userData.loginRewardStep ~= nil and nk.userData.loginRewardStep > 0 then
        table.insert(self.PendingPopup, function(data)
            local view_ = RegisterRewardPopup.new():setCloseCallback(handler(self, self.checkPendingPupop))
            nk.PopupManager:addPopup(view_, true, true, false, false)
            self.showPendingPopup = true
            view_:onShowed()
        end)
        if not self.showPendingPopup then
            self:checkPendingPupop()
        end
    end
end

function HallController:onLoginError_()
    if self.loginBtn then
        self.loginBtn:setButtonEnabled(true)
    end
    if self.guestLoginBtn then
        self.guestLoginBtn:setButtonEnabled(true)
    end

    nk.userDefault:setStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE, "")
    nk.userDefault:flush()

    self.isLoginInProgress_ = -1
    self:reportLoginResult_(nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE), "4", "connection problem")
    -- 视图处理登录失败
    self.view_:playLoginFailAnim()
    -- 通知网络错误
    nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
end

function HallController:doLogout()
    -- 上报广告平台 登出
    nk.AdSdk:report(consts.AD_TYPE.AD_LOGOUT,{uid =tostring(nk.userData.uid)})
    nk.userData.gameCount = nil
    nk.userData.marketData = nil
    nk.userData.firstpayData = nil
    nk.OnOff.onoff_ = {}
    nk.OnOff:clearTimer(nk.OnOff.onsaleCountDownTimerId)
    nk.userData.onsaleCountDownTime = -1
    nk.userDefault:setStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE, "")
    nk.userDefault:flush()
    if nk.AdSceneSdk then
        nk.AdSceneSdk:clearAll()
    end
    PlayerbackModel.clearData()
    if nk.Facebook then
        nk.Facebook:logout()
        nk.userDefault:setStringForKey(nk.cookieKeys.FACEBOOK_ACCESS_TOKEN, "")
        nk.userDefault:flush()
    end
    nk.MatchRecordManager:dispose()
    nk.socket.HallSocket:disconnect()
    nk.socket.MatchSocket:disconnect()
    nk.match.MatchModel:setCancelRegistered()
    nk.needReloadMatchConfig = nil
    nk.needReConnectMatch = nil
    LoadMatchControl:getInstance():deleteInstance()
    bm.HttpService.clearDefaultParameters()
end

function HallController:doBackFromRoom()
    self.scene_:performWithDelay(handler(self, self.handleBackFromRoom), 1.0)
end

function HallController:handleBackFromRoom()
    bm.HttpService.POST({
            mod="PreferentialOrder",
            act="recommend",
        },
        function(data)
            local retData = json.decode(data)
            -- showbox :1,显示优惠订单 
            -- box: 1,149THB  2,99THB   3,49THB    4,限时优惠
            if retData and retData.showbox and retData.showbox == 1 then
                if retData.box and retData.box > 0 and retData.goods then 
                    local time_ = retData.jmttimes
                    if time_ and time_ > 0 then
                        nk.OnOff:startDownTime(nk.OnOff.onsaleCountDownTimerId, time_)
                        nk.userData.onsaleCountDownTime = time_
                    end

                    retData.goodsInfo = retData.goods
                    nk.userData.onsaleData = retData
                    GuidePayPopup.new(5 + retData.box * 2, nil, retData):show()
                end
            end
        end)
end

function HallController:handleLogoutSucc_()
    self.isLoginInProgress_ = -1
    self:doLogout()
    -- 设置视图
    self.scene_:onLogoutSucc()
end

function HallController:handleDoubleLogin_()
    self.isLoginInProgress_ = -1
    nk.TopTipManager:showTopTip(bm.LangUtil.getText("LOGIN", "DOUBLE_LOGIN_MSG"))
    self:doLogout()
    self.scene_:onLogoutSucc()
end

function HallController:showChooseArenaRoomView()
    if LoadMatchControl:getInstance().isConfigLoaded_ then
        if self.matchLoading_ then
            self.matchLoading_:removeFromParent()
            self.matchLoading_ = nil
        end
        self.scene_:onShowChooseArenaRoomView()
    else -- 加载配置
        LoadMatchControl:getInstance():loadConfig("",function(success, data)
                if success then
                    if self.matchLoading_ then
                        self.matchLoading_:removeFromParent()
                        self.matchLoading_ = nil
                    end
                    self.scene_:onShowChooseArenaRoomView()
                else
                    if self.matchLoading_ then
                        self.matchLoading_:removeFromParent()
                        self.matchLoading_ = nil
                    end
                end
            end
            )
    end
    self:needShowRecommendBar(0)
end

function HallController:showChooseRoomView(viewType, tabIndex,isCoin)
    -- 设置视图
    self.scene_:onShowChooseRoom(viewType, tabIndex,isCoin)
    self:needShowRecommendBar(0)
end

function HallController:showMainHallView()
    -- 设置视图
    self.scene_:onShowMainHall()
    self:needShowRecommendBar(1)
end

function HallController:showMainHallViewByBottom()
    -- 设置视图
    self.scene_:onShowMainHallByBottom()
    self:needShowRecommendBar(1)
end

-- 获取一个房间数据, 在post请求的回调中继续 连接房间 (回调) 创建房间场景的流程
function HallController:getEnterRoomData(args, isPlaynow)
    if self.isEnteringRoom_==true then return end
    self.isEnteringRoom_ = true -- 坑
    -- 添加加载loading
    self.roomLoading_ = nk.ui.RoomLoading.new(bm.LangUtil.getText("ROOM", "ENTERING_MSG"))
        :addTo(self.view_, 100)

    -- 请求数据
    local params = {mod = "table", act = "quickIn"}
    if args then table.merge(params, args) end
    self.roomDataRequestId_ = bm.HttpService.POST(params, function (data)
        local retData = json.decode(data)
        -- dump(retData, "HallController:getEnterRoomData[table.quickIn].retData :=============")

        if retData.ret == 0 then
            nk.userData.tableFlag = retData.tableFlag
            nk.userData.tableType = retData.tableType
            if retData.showBox == 1 then
                -- 移除加载loading
                if self.roomLoading_ then
                    self.roomLoading_:removeFromParent()
                    self.roomLoading_ = nil
                end

                --骰子场入场门槛有后端传入
                local minBuy = (retData.dice_min_bring and bm.formatBigNumber(retData.dice_min_bring)) or (args and bm.formatBigNumber(args.sb * 5)) or nk.userData.limitMin
                retData.minBuy = minBuy
                if retData.box == 3 then
                    FirstPayPopup.new(retData):show()
                    -- nk.ui.Dialog.new({
                    --         messageText = bm.LangUtil.getText("COMMON", "NOT_ENOUGH_MONEY_TO_PLAY_NOW_MSG", minBuy),
                    --         hasCloseButton = false,
                    --         callback = function (type)
                    --             if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                    --                 FirstPayPopup.new(retData):show()
                    --             end
                    --         end
                    --     }):show()
                elseif retData.box > 3 then
                    if retData.box < 10 then
                        GuidePayPopup.new(2, nil, retData):show()
                    elseif retData.box == 11 then
                        GuidePayPopup.new(102, nil, retData):show()
                    end
                else
                    if params.isgcoin then
                        nk.ui.Dialog.new({
                            messageText = bm.LangUtil.getText("COINROOM", "NOT_ENOUGH_MONEY_TO_PLAY_NOW_MSG", minBuy),
                            hasCloseButton = false,
                            callback = function (type)
                                if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                                    self:onEnterMatch()
                                end
                            end
                        }):show()
                    else
                        nk.ui.Dialog.new({
                            messageText = bm.LangUtil.getText("COMMON", "NOT_ENOUGH_MONEY_TO_PLAY_NOW_MSG", args and bm.formatBigNumber(args.sb * 5) or nk.userData.limitMin),
                            hasCloseButton = false,
                            callback = function (type)
                                if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                                    StorePopup.new():showPanel()
                                end
                            end
                        }):show()
                    end
                end
                self.isEnteringRoom_ = false
                app:dealEnterMatch()
            else
                nk.userData.tableFlag = retData.tableFlag
                nk.userData.tableType = retData.tableType

                if retData.dice and retData.dice == 1 then
                    self:startConnectDice(retData.ip, retData.port, retData.tid)
                elseif retData.dice == 2 then
                    self:startConnectPdeng(retData.ip, retData.port, retData.tid)
                else
                    self:startConnectRoom(retData.ip, retData.port, retData.tid, isPlaynow)
                end
            end
        elseif retData.ret == - 103 then
            -- 移除加载loading
            if self.roomLoading_ then
                self.roomLoading_:removeFromParent()
                self.roomLoading_ = nil
            end
            nk.ui.Dialog.new({
                messageText = bm.LangUtil.getText("COMMON", "NOT_ENOUGH_MONEY_TO_PLAY_NOW_MSG", args and bm.formatBigNumber(args.sb * 5) or nk.userData.limitMin),
                hasCloseButton = false,
                callback = function (type)
                    if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                        StorePopup.new():showPanel()
                    end
                end
            }):show()
            self.isEnteringRoom_ = false
            app:dealEnterMatch()
        else
            -- 移除加载loading
            if self.roomLoading_ then
                self.roomLoading_:removeFromParent()
                self.roomLoading_ = nil
            end
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("TIPS", "EXCEPTION_QUICK_IN"))
            self.isEnteringRoom_ = false
            app:dealEnterMatch()
        end
    end, function(errData)
        -- 移除加载loading
        dump(errData, "HallController:getEnterRoomData[table.quickIn].errData :=============")

        if self.roomLoading_ then
            self.roomLoading_:removeFromParent()
            self.roomLoading_ = nil
        end
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("TIPS", "ERROR_QUICK_IN"))
        self.isEnteringRoom_ = false
        app:dealEnterMatch()
    end)
end

-- 开始连接房间
function HallController:startConnectRoom(ip, port, tid, isPlayNow, psword, isTrace)
    self.isEnteringRoom_ = true
    self.loadedRoomTexture_ = false
    self.loginRoomSucc_ = false

    -- 连接房间服务器socket
    self.connectStartTime_ = bm.getTime()
    self.connectInfo_ = {ip=ip, port=port, tid=tid, isPlayNow=isPlayNow, psword=psword, isTrace=isTrace}
    nk.socket.RoomSocket:connectToRoom(ip, port, tid, isPlayNow, psword)
    nk.socket.RoomSocket:pause()

    -- 预加载房间纹理
    self.loadRoomTextureNum_ = 0
    self:onLoadedRoomTexture_()
end

-- 加载房间纹理完成
function HallController:onLoadedRoomTexture_()
    self.loadRoomTextureNum_ = self.loadRoomTextureNum_ + 1
    if self.loadRoomTextureNum_ == 1 then
        display.addSpriteFrames("room_texture.plist", "room_texture.png", handler(self, self.onLoadedRoomTexture_))
    elseif self.loadRoomTextureNum_ == 2 then
        if self.loginRoomSucc_ then
            app:enterRoomScene()
        end
        self.loadedRoomTexture_ = true
    end
end

-- 登录房间成功
function HallController:onLoginRoomSucc_()
    if self.loadedRoomTexture_ then
        app:enterRoomScene()
    end
    self.loginRoomSucc_ = true
    if self.connectInfo_ and self.connectStartTime_ then
        bm.HttpService.POST({
            mod="mobileTj",
            act="hallToRoomSocket",
            succ="true",
            time=math.round((bm.getTime()-self.connectStartTime_)*1000),
            ip=self.connectInfo_.ip,
            port=self.connectInfo_.port,
            tid=self.connectInfo_.tid,
            isPlayNow=(not not self.connectInfo_.isPlayNow),
        })
        self.connectStartTime_ = nil
        self.connectInfo_ = nil
    end
end

-- 登录房间失败
function HallController:onLoginRoomFail_(evt)
    -- 移除加载loading
    if self.roomLoading_ then
        self.roomLoading_:removeFromParent()
        self.roomLoading_ = nil
    end

    -- 清除房间纹理
    display.removeSpriteFramesWithFile("room_texture.plist", "room_texture.png")
    self.loadedRoomTexture_ = false
    -- 群组房间密码错误
    if evt and evt.pswError==true then
        self.isEnteringRoom_ = false
        -- 群组外部跟踪好友密码错误再次弹窗输入进入 只弹一次
        if self.connectInfo_ and self.connectInfo_.isTrace==true then
            self.connectInfo_.isTrace = nil

            local delegate = {}
            delegate.enterGroupRoom = function(obj,room_id,tid,pass_word,reshowPassWordPopup)
                bm.HttpService.CANCEL(self.enterGroupRoomId_)
                self.enterGroupRoomId_ = bm.HttpService.POST(
                    {
                        mod = "Group",
                        act = "quickIn",
                        uid = nk.userData.uid,
                        tid = tid,
                        psword = pass_word,
                    },
                    function(data)
                        local retData = json.decode(data)
                        if retData and tonumber(retData.ret)==1 and retData.data and retData.data.ip then
                            -- //请求进入群房间
                            bm.EventCenter:dispatchEvent({name = nk.eventNames.ENTER_ROOM_WITH_DATA, data = {
                                ip = retData.data.ip,
                                port = retData.data.port,
                                tid = tid,
                                privateType = retData.data.privateType,
                                psword = pass_word or "",
                                isPlayNow = false
                            }})
                        else
                            nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","ROOMPSWERROR"))
                        end
                    end,
                    function()
                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","ROOMPSWERROR"))
                    end
                )
            end

            --- 密码框
            local GroupPassWordPopup = require("app.module.friend.group.GroupPassWordPopup")
            GroupPassWordPopup.new(nil,self.connectInfo_.tid,delegate):show()
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","ROOMPSWERROR"))
        end
        return;
    end

    if not evt or not evt.silent then
        local t = bm.LangUtil.getText("TIPS", "ERROR_LOGIN_ROOM_FAIL")
        nk.TopTipManager:showTopTip(t)
    end

    if self.connectInfo_ and self.connectStartTime_ then
        bm.HttpService.POST({
            mod="mobileTj",
            act="hallToRoomSocket",
            succ="false",
            ip=self.connectInfo_.ip,
            port=self.connectInfo_.port,
            tid=self.connectInfo_.tid,
            isPlayNow=(not not self.connectInfo_.isPlayNow),
        })
        self.connectStartTime_ = nil
        self.connectInfo_ = nil
    end
    self.isEnteringRoom_ = false
    app:dealEnterMatch() -- 坑啊
end


-- 获取一个房间数据, 在post请求的回调中继续 连接房间 (回调) 创建房间场景的流程
function HallController:getEnterDiceData(view, args)
    self.typePanel_ = view
    if self.isEnteringRoom_==true then return end
    self.isEnteringRoom_ = true -- 坑
    -- 添加加载loading
    self.roomLoading_ = nk.ui.RoomLoading.new(bm.LangUtil.getText("ROOM", "ENTERING_MSG"))
        :addTo(view, 100)

    -- 请求数据
    local params = {mod = "table", act = "quickIn"}
    if args then table.merge(params, args) end
    self.roomDataRequestId_ = bm.HttpService.POST(
        params,
        function (data)
            local retData = json.decode(data)
            if retData.ret == 0 then
                if retData.showBox == 1 then
                    -- 移除加载loading
                    if self.roomLoading_ then
                        self.roomLoading_:removeFromParent()
                        self.roomLoading_ = nil
                    end

                    local minBuy = (retData.dice_min_bring and bm.formatBigNumber(retData.dice_min_bring)) or bm.formatBigNumber(args.sb * 10)
                    retData.minBuy = minBuy
                    if retData.box == 3 then
                        --FirstPayPopup.new(retData):show()
                        nk.ui.Dialog.new({
                                messageText = bm.LangUtil.getText("COMMON", "NOT_ENOUGH_MONEY_TO_PLAY_NOW_MSG", minBuy),
                                hasCloseButton = false,
                                callback = function (type)
                                    if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                                        FirstPayPopup.new(retData):show()
                                    end
                                end
                            }):show()
                    elseif retData.box > 3 then
                        if retData.box < 10 then
                            GuidePayPopup.new(2, nil, retData,true):show()
                        elseif retData.box == 11 then
                            GuidePayPopup.new(102, nil, retData,true):show()
                        end
                    else
                        if params.isgcoin then
                            nk.ui.Dialog.new({
                                messageText = bm.LangUtil.getText("COINROOM", "NOT_ENOUGH_MONEY_TO_PLAY_NOW_MSG", minBuy),
                                hasCloseButton = false,
                                callback = function (type)
                                    if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                                        self:onEnterMatch()
                                    end
                                end
                            }):show()
                        else
                            nk.ui.Dialog.new({
                                messageText = bm.LangUtil.getText("COMMON", "NOT_ENOUGH_MONEY_TO_PLAY_NOW_MSG", minBuy),
                                hasCloseButton = false,
                                callback = function (type)
                                    if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                                        StorePopup.new():showPanel()
                                    end
                                end
                            }):show()
                        end
                    end
                    -- 坑啊
                    self.isEnteringRoom_ = false
                    app:dealEnterMatch()
                else
                    self:startConnectDice(retData.ip, retData.port, retData.tid)
                end
            elseif retData.ret == -103 then
                -- 移除加载loading
                if self.roomLoading_ then
                    self.roomLoading_:removeFromParent()
                    self.roomLoading_ = nil
                end
                nk.ui.Dialog.new({
                    messageText = bm.LangUtil.getText("COMMON", "NOT_ENOUGH_MONEY_TO_PLAY_NOW_MSG", args and bm.formatBigNumber(args.sb * 10) or nk.userData.limitMin),
                    hasCloseButton = false,
                    callback = function (type)
                        if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                            StorePopup.new():showPanel()
                        end
                    end
                }):show()
                -- 坑啊
                self.isEnteringRoom_ = false
                app:dealEnterMatch()
            else
                -- 移除加载loading
                if self.roomLoading_ then
                    self.roomLoading_:removeFromParent()
                    self.roomLoading_ = nil
                end
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("TIPS", "EXCEPTION_QUICK_IN"))
                -- 坑啊
                self.isEnteringRoom_ = false
                app:dealEnterMatch()
            end
        end,
        function ()
            -- 移除加载loading
            if self.roomLoading_ then
                self.roomLoading_:removeFromParent()
                self.roomLoading_ = nil
            end
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("TIPS", "ERROR_QUICK_IN"))
            -- 坑啊
            self.isEnteringRoom_ = false
            app:dealEnterMatch()
        end
    )
end

function HallController:startConnectDice(ip,port,tid)
    self.isEnteringRoom_ = true
    self.loadedDiceTexture_ = false
    self.loginDiceSucc_ = false

    -- 连接骰子服务器socket
    -- self.connectStartTime_ = bm.getTime()
    -- self.connectInfo_ = {ip=ip, port=port, tid=tid, isPlayNow=isPlayNow}

    nk.socket.HallSocket:connectToDice(ip, port, tid)
    nk.socket.HallSocket:pause()
    -- 预加载房间纹理
    self.loadDiceTextureNum_ = 0
    self:onLoadedDiceTexture_()
end

function HallController:onLoadedDiceTexture_()
    self.loadDiceTextureNum_ = self.loadDiceTextureNum_ + 1
    if self.loadDiceTextureNum_ == 1 then
        display.addSpriteFrames("dice_texture.plist", "dice_texture.png", handler(self, self.onLoadedDiceTexture_))
    elseif self.loadDiceTextureNum_ == 2 then
        display.addSpriteFrames("room_texture.plist", "room_texture.png", handler(self, self.onLoadedDiceTexture_))
    elseif self.loadDiceTextureNum_ == 3 then
        if self.loginDiceSucc_ then
            self:cleanTypePanel()
            app:enterDiceScene()
        end
        self.loadedDiceTexture_ = true
    end
end

function HallController:onLoginDiceSucc_(evt)
    if self.loadedDiceTexture_ then
        self:cleanTypePanel()
        app:enterDiceScene()
    end
    self.loginDiceSucc_ = true
end

function HallController:cleanTypePanel()
    if self.typePanel_ then
        -- self.typePanel_:close_()
    end
end

function HallController:onLoginDiceFail_(evt)
    -- 移除加载loading
    if self.roomLoading_ then
        self.roomLoading_:removeFromParent()
        self.roomLoading_ = nil
    end
    self.typePanel_ = nil

    -- 清除骰子场纹理
    display.removeSpriteFramesWithFile("dice_texture.plist", "dice_texture.png")
    display.removeSpriteFramesWithFile("room_texture.plist", "room_texture.png")
    if not evt or not evt.silent then
        local t = bm.LangUtil.getText("TIPS", "ERROR_LOGIN_ROOM_FAIL")
        nk.TopTipManager:showTopTip(t)
    end
    self.isEnteringRoom_ = false
    app:dealEnterMatch()
end

-- 获取一个房间数据, 在post请求的回调中继续 连接房间 (回调) 创建房间场景的流程
function HallController:getEnterPdengData(args, isGrabDealer)
    if self.isEnteringRoom_==true then return end
    self.isEnteringRoom_ = true
    -- 添加加载loading
    self.roomLoading_ = nk.ui.RoomLoading.new(bm.LangUtil.getText("ROOM", "ENTERING_MSG"))
        :addTo(self.view_, 100)

    -- 请求数据
    local params = {mod = "table", act = "quickIn"}
    if args then table.merge(params, args) end
    -- dump(params, "HallController:getEnterPdengData[table.quickIn].params :=============")

    self.roomDataRequestId_ = bm.HttpService.POST(params, function (data)
        local retData = json.decode(data)

        -- dump(retData, "HallController:getEnterPdengData[table.quickIn].retData :=============")
        if retData.ret == 0 then
            nk.userData.tableFlag = retData.tableFlag
            nk.userData.tableType = retData.tableType
            if retData.showBox == 1 then
                -- 移除加载loading
                if self.roomLoading_ then
                    self.roomLoading_:removeFromParent()
                    self.roomLoading_ = nil
                end

                --骰子场入场门槛有后端传入
                local minBuy = (retData.bd_min_bring and bm.formatBigNumber(retData.bd_min_bring)) or (args and bm.formatBigNumber(args.sb * 10)) or nk.userData.limitMin
                retData.minBuy = minBuy
                if retData.box == 3 then
                    --FirstPayPopup.new(retData):show()
                    nk.ui.Dialog.new({
                            messageText = bm.LangUtil.getText("COMMON", "NOT_ENOUGH_MONEY_TO_PLAY_NOW_MSG", minBuy),
                            hasCloseButton = false,
                            callback = function (type)
                                if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                                    FirstPayPopup.new(retData):show()
                                end
                            end
                        }):show()
                elseif retData.box > 3 then
                    if retData.box < 10 then
                        GuidePayPopup.new(2, nil, retData):show()
                    elseif retData.box == 11 then
                        GuidePayPopup.new(102, nil, retData):show()
                    end
                else
                    if params.isgcoin then
                        nk.ui.Dialog.new({
                            messageText = bm.LangUtil.getText("COINROOM", "NOT_ENOUGH_MONEY_TO_PLAY_NOW_MSG", minBuy),
                            hasCloseButton = false,
                            callback = function (type)
                                if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                                    self:onEnterMatch()
                                end
                            end
                        }):show()
                    else
                        nk.ui.Dialog.new({
                            messageText = bm.LangUtil.getText("COMMON", "NOT_ENOUGH_MONEY_TO_PLAY_NOW_MSG", args and bm.formatBigNumber(args.sb * 10) or nk.userData.limitMin),
                            hasCloseButton = false,
                            callback = function (type)
                                if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                                    StorePopup.new():showPanel()
                                end
                            end
                        }):show()
                    end
                end
                self.isEnteringRoom_ = false
                app:dealEnterMatch()
            else
                nk.userData.tableFlag = retData.tableFlag
                nk.userData.tableType = retData.tableType
                if retData.dice and retData.dice == 1 then
                    self:startConnectDice(retData.ip, retData.port, retData.tid)
                else
                    self:startConnectPdeng(retData.ip, retData.port, retData.tid, isGrabDealer)
                end
            end
        elseif retData.ret == -103 then
            -- 移除加载loading
            if self.roomLoading_ then
                self.roomLoading_:removeFromParent()
                self.roomLoading_ = nil
            end
            nk.ui.Dialog.new({
                messageText = bm.LangUtil.getText("COMMON", "NOT_ENOUGH_MONEY_TO_PLAY_NOW_MSG", args and bm.formatBigNumber(args.sb * 10) or nk.userData.limitMin),
                hasCloseButton = false,
                callback = function (type)
                    if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                        StorePopup.new():showPanel()
                    end
                end
            }):show()
            self.isEnteringRoom_ = false
            app:dealEnterMatch()
        else
            -- 移除加载loading
            if self.roomLoading_ then
                self.roomLoading_:removeFromParent()
                self.roomLoading_ = nil
            end
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("TIPS", "EXCEPTION_QUICK_IN"))
            self.isEnteringRoom_ = false
            app:dealEnterMatch()
        end
    end, function(errData)
        -- 移除加载loading
        dump(errData, "HallController:getEnterPdengData[table.quickIn].errData :=============")

        if self.roomLoading_ then
            self.roomLoading_:removeFromParent()
            self.roomLoading_ = nil
        end
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("TIPS", "ERROR_QUICK_IN"))
        self.isEnteringRoom_ = false
        app:dealEnterMatch()
    end)
end

function HallController:startConnectPdeng(ip,port,tid,isGrabDealer)
    self.isEnteringRoom_ = true
    self.loadedPdengTexture_ = false
    self.loginPdengSucc_ = false

    nk.socket.HallSocket:connectToPdeng(ip, port, tid, isGrabDealer)
    nk.socket.HallSocket:pause()
    -- 预加载房间纹理
    self.loadPdengTextureNum_ = 0
    self:onLoadedPdengTexture_()
end

function HallController:onLoadedPdengTexture_()
    self.loadPdengTextureNum_ = self.loadPdengTextureNum_ + 1
    if self.loadPdengTextureNum_ == 1 then
        display.addSpriteFrames("pdeng_texture.plist", "pdeng_texture.png", handler(self, self.onLoadedPdengTexture_))
    elseif self.loadPdengTextureNum_ == 2 then
        display.addSpriteFrames("room_texture.plist", "room_texture.png", handler(self, self.onLoadedPdengTexture_))
    elseif self.loadPdengTextureNum_ == 3 then
        if self.loginPdengSucc_ then
            app:enterPdengScene()
        end
        self.loadedPdengTexture_ = true
    end
end

function HallController:onLoginPdengSucc_(evt)
    if self.loadedPdengTexture_ then
        app:enterPdengScene()
    end
    self.loginPdengSucc_ = true
end

function HallController:onLoginPdengFail_(evt)
    -- 移除加载loading
    if self.roomLoading_ then
        self.roomLoading_:removeFromParent()
        self.roomLoading_ = nil
    end

    -- 清除骰子场纹理
    display.removeSpriteFramesWithFile("pdeng_texture.plist", "pdeng_texture.png")
    display.removeSpriteFramesWithFile("room_texture.plist", "room_texture.png")
    if not evt or not evt.silent then
        local t = bm.LangUtil.getText("TIPS", "ERROR_LOGIN_ROOM_FAIL")
        nk.TopTipManager:showTopTip(t)
    end
    self.isEnteringRoom_ = false
    app:dealEnterMatch() -- 坑啊
end



function HallController:onServerFail_(evt)    
    --连接失败
    if evt.data == consts.SVR_ERROR.ERROR_CONNECT_FAILURE then       
        -- self:showErrorByDialog_(("服务器连接失败"))
        print("服务器连接失败")
        self:showErrorByDialog_("")
    --心跳包超时
    elseif evt.data == consts.SVR_ERROR.ERROR_HEART_TIME_OUT then       
        -- self:showErrorByDialog_(("服务器响应超时"))
        print("服务器响应超时")
        self:showErrorByDialog_("")
    --登录超时
    elseif evt.data == consts.SVR_ERROR.ERROR_LOGIN_TIME_OUT then       
        -- self:showErrorByDialog_(("服务器登录超时"))   
        print("服务器响应超时")
        self:showErrorByDialog_("")
    end
end

function HallController:showErrorByDialog_(msg)
    local ip,port = string.match(nk.userData.HallServer[1], "([%d%.]+):(%d+)")
    nk.socket.HallSocket:connectDirect(ip, port, true) 
    -- nk.ui.Dialog.new({
    --     messageText = msg, 
    --     secondBtnText = bm.LangUtil.getText("COMMON", "RETRY"), 
    --     titleText = bm.LangUtil.getText("COMMON", "NOTICE"),
    --     closeWhenTouchModel = false,
    --     hasFirstButton = false,
    --     hasCloseButton = false,
    --     callback = function (type)
    --         if type == nk.ui.Dialog.SECOND_BTN_CLICK then
    --             local ip,port = string.match(nk.userData.HallServer[1], "([%d%.]+):(%d+)")
    --             nk.socket.HallSocket:connectDirect(ip, port, true) 
    --         end
    --     end,
    -- }):show()
end

function HallController:onServerStop_()
    -- 移除加载loading
    if self.roomLoading_ then
        self.roomLoading_:removeFromParent()
        self.roomLoading_ = nil
    end

    -- 清除房间纹理
    display.removeSpriteFramesWithFile("room_texture.plist", "room_texture.png")

    nk.ui.Dialog.new({
        messageText = bm.LangUtil.getText("ROOM", "SERVER_STOPPED_MSG"),
        secondBtnText = bm.LangUtil.getText("COMMON", "LOGOUT"),
        closeWhenTouchModel = false,
        hasFirstButton = false,
        hasCloseButton = false,
        callback = function (type)
            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                self:handleLogoutSucc_()
            end
        end,
    }):show()
end

-- 进入比赛相关界面
function HallController:onEnterMatch()
    if nk.userData.level < nk.userData.arenaLimiteLevel then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL", "ARENA_LIMIT_TIPMSG", nk.userData.arenaLimiteLevel))
        return
    end
    self:dealMatchConfigUpdate()

    if self.view_ then
        local isShowIp = nk.userData.isShowMatchIp == 1 and true or false;
        self.matchLoading_ = nk.ui.RoomLoading.new(bm.LangUtil.getText("ROOM", "ENTERING_MSG"),isShowIp)
            :addTo(self.view_, 100)
    end

    LoadMatchControl:getInstance():loadConfig("",function(success, data)
            if self and self.startConnectMatch then
                if success then
                    self:showChooseArenaRoomView()
                    -- self:startConnectMatch("127.0.0.1", 8081, true)
                else
                    if self.matchLoading_ then
                        self.matchLoading_:removeFromParent()
                        self.matchLoading_ = nil
                    end
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
                end
            end
        end
    )
end

function HallController:startConnectMatch(ip, port,isAuto)
    self.isAutoEnterMatch_ = isAuto
    self.loadedMatchTexture_ = false
    self.loginMatchSucc_ = false

    -- 连接比赛场服务器socket
    if nk.socket.MatchSocket.isConnected_ and nk.socket.MatchSocket.isLoginned_ then
        print("开始进入HallController:startConnectMatch==")
        if not self.isAutoEnterMatch_ then
            self:showChooseArenaRoomView()
        else
            print("开始进入HallController:startConnectMatch==失败")
        end
    elseif nk.socket.MatchSocket.isConnected_ then
        local userInfo = {nick = nk.userData.nick,img = nk.userData.s_picture,mtkey = nk.userData.mtkey}
        nk.socket.MatchSocket:sendLoginHall({
            uid    = nk.userData.uid,
            info   = json.encode(userInfo)
        })
    else
        LoadMatchControl:getInstance():loadConfig("",function(success, data)
                if success then
                    self:onLoadMatchControlStartLoadCallBack_()
                else
                    if self.matchLoading_ then
                        self.matchLoading_:removeFromParent()
                        self.matchLoading_ = nil
                    end
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
                end
            end
            )
    end
end

function HallController:onLoadMatchControlStartLoadCallBack_()
    self.isEnteringRoom_ = false
    local tempIP = LoadMatchControl:getInstance().matchIP_ or "127.0.0.1"
    local tempPort = LoadMatchControl:getInstance().matchPort_ or 8081
    nk.socket.MatchSocket:connectToMatch(tempIP, tempPort)
    nk.socket.MatchSocket:pause()

    self:dispatchRoomLoading_("1")
end
function HallController:dispatchRoomLoading_(sign)
    local tempIP = LoadMatchControl:getInstance().matchIP_ or "127.0.0.1"
    local tempPort = LoadMatchControl:getInstance().matchPort_ or 8081

    local evtData = {}
    evtData.ip = tempIP;
    evtData.port = tempPort;
    evtData.src = sign;
    bm.EventCenter:dispatchEvent({name="update_matchIpPort_roomLoading", data=evtData})
end
-- 登录比赛场成功
function HallController:onLoginMatchSucc_()
    -- if self.loadedMatchTexture_ then
    --     app:showChooseArenaRoomView()
    -- end
    -- self.loginMatchSucc_ = true
    print("开始进入HallController:onLoginMatchSucc_=="..tostring(self.isAutoEnterMatch_))
    if not self.isAutoEnterMatch_ then
        self:showChooseArenaRoomView()
    else
        if bm.DataProxy:getData(nk.dataKeys.CURRENT_HALL_VIEW)==HallController.CHOOSE_ARENA_VIEW then
            if self.matchLoading_ then
                self.matchLoading_:removeFromParent()
                self.matchLoading_ = nil
                -- 有loading的时候 主动连接
                local t = bm.LangUtil.getText("MATCH", "LOGINSUCCESS")
                nk.TopTipManager:showTopTip(t)
            end
            nk.socket.MatchSocket:resume()
        else -- 如果没有报名自动关闭连接 降低服务器负载
            local matchStatus = nk.userDefault:getIntegerForKey(nk.cookieKeys.IS_JOIN_MATCH..nk.userData.uid,0)
            if matchStatus~=1 then
                nk.socket.MatchSocket:disconnect(true)
            end
            -- 
            self:dispatchRoomLoading_("4")
        end
    end
    nk.socket.MatchSocket:sendGetOnlineCount(nk.match.MatchModel.openMatchIds)
end

-- 登录比赛场失败
function HallController:onLoginMatchFail_(evt)
    -- 移除加载loading
    if self.matchLoading_ then
        self.matchLoading_:removeFromParent()
        self.matchLoading_ = nil
    end

    if not evt or not evt.silent then
        local t = ""
        if evt and evt.isHasNetwork then
            t = bm.LangUtil.getText("TIPS", "ERROR_LOGIN_MATCH_FAIL")
        else
            t = bm.LangUtil.getText("COMMON", "BAD_NETWORK")
        end
        nk.TopTipManager:showTopTip(t)
    end
    -- 进入场景后断线
    local viewStatus = bm.DataProxy:getData(nk.dataKeys.CURRENT_HALL_VIEW)
    if viewStatus == HallController.CHOOSE_ARENA_VIEW then
        -- self.controller_:startConnectMatch("127.0.0.1", 8081,true)
        -- 系统弹窗直接引导 重新连接
        nk.ui.Dialog.new({
            messageText = bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"), 
            secondBtnText = bm.LangUtil.getText("COMMON", "RETRY"),
            closeWhenTouchModel = false,
            hasCloseButton = false,
            callback = function (type)
                if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                    nk.socket.MatchSocket:disconnect(true)
                    self.matchLoading_ = nk.ui.RoomLoading.new(
                            bm.LangUtil.getText("ROOM", "ENTERING_MSG"))
                        :addTo(self.view_, 100)
                    self:startConnectMatch("127.0.0.1", 8081, true)
                    -- nk.socket.MatchSocket:sendJoinGame({matchlevel = pack.matchlevel,matchid = pack.matchid})
                end
            end
        }):show()
    end
end

-- 比赛开始
function HallController:onStartMatch_(evt)
    if not app.immediateDealMatch then return end
    -- 场景还未切换回来 又有下一场比赛开始了
    local curScene = display.getRunningScene()
    if curScene.name == "HallScene" or not curScene.name then  -- 切场景已经成功
        local pack = evt.data
        if pack and pack.matchlevel and pack.matchid then
            if not self.isEnteringRoom_ then
                self.isEnteringRoom_ = true -- 同时进入比赛场和普通场的BUG
                nk.socket.MatchSocket:sendJoinGame({matchlevel = pack.matchlevel,matchid = pack.matchid})
            end
        end
    else
        
    end
    -- MatchStartPopup.new({
    --     messageText = bm.LangUtil.getText("MATCH", "JOINMATCHTIPS"),
    --     hasCloseButton = false,
    --     time = evt.data.joinTime,
    --     callback = function (type)
    --         if type == nk.ui.Dialog.SECOND_BTN_CLICK then
    --             nk.socket.MatchSocket:sendJoinGame({matchlevel = nk.match.MatchModel.matchlevel_,matchid = nk.match.MatchModel.matchid_})
    --         end
    --     end
    -- }):show()
end

-- 请求进入比赛失败
function HallController:onJoinMatchError_(evt)
    local pack = evt.data
    local matchid = pack.matchid
    if not matchid or matchid==0 or matchid=="" then
        matchid = nk.match.MatchModel.regList and nk.match.MatchModel.regList[pack.matchlevel]
    end
    if not matchid or matchid==0 or matchid=="" then
        pack.ret = 2
    end
    if pack.ret==0 then
    -- elseif pack.ret==1 then --房间不存在
    -- elseif pack.ret==2 then --用户已经在房间
    -- elseif pack.ret==3 then --房间人数已满
    -- else
    --[[
    fmt = {
        { name = "tid", type = T.INT },
        { name = "serverid", type = T.INT },
        { name = "matchlevel", type = T.INT },
        { name = "ret", type = T.INT }
    }
    --]]
        local extData = {}
        extData.vip = 0

        local isVip, vipconfig = self:checkIsVip_()
        if isVip then
            extData.vip = vipconfig.vip.level
        end

        nk.socket.MatchSocket:sendLogin({
                tid    = pack.tid,
                matchlevel = pack.matchlevel,
                matchid = matchid,
                uid    = nk.userData.uid,
                mtkey  = nk.userData.mtkey,
                img    = nk.userData.s_picture,
                giftId = nk.userData.user_gift, 
                nick   = nk.userData.nick,
                gender = nk.userData.sex,
                extData = extData
            })
        return
    end
    self.isEnteringRoom_ = false
    -- 移除加载loading
    if self.matchLoading_ then
        self.matchLoading_:removeFromParent()
        self.matchLoading_ = nil
    end
    nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "JOINMATCHFAILTIPS"))
    -- 取消当前报名
    nk.match.MatchModel:setCancelRegistered(pack.matchlevel,true)
    if pack.ret==1 then--房间不存在

    elseif pack.ret==2 then--用户已经在房间

    elseif pack.ret==3 then--房间人数已满

    else

    end
    app:dealEnterMatch() -- 坑啊
end

--yk
function HallController:checkIsVip_()
    local isVip = false
    local config
    local vipconfig = nk.OnOff:getConfig('vipmsg')
    local vipconfig_2 = nk.OnOff:getConfig('newvipmsg')

    if vipconfig_2 and vipconfig_2.newvip == 1 then
      isVip = true
      config = vipconfig_2
    else
      if vipconfig and vipconfig.isvip == 1 and vipconfig.vip and vipconfig.vip.light and vipconfig.vip.light == 1 then
        isVip = true
        config = vipconfig
      else
        config = vipconfig_2
      end
    end

    return isVip, config
end

-- 获取在玩人数
function HallController:onJoinMatchFail_(evt)
    self.isEnteringRoom_ = false
    -- 移除加载loading
    if self.matchLoading_ then
        self.matchLoading_:removeFromParent()
        self.matchLoading_ = nil
    end
    app:dealEnterMatch() -- 坑啊
end
-- 获取在玩人数
function HallController:getPlayerCountData(roomType, field)
    bm.HttpService.CANCEL(self.playerCountRequestId_)
    if roomType == 3 or roomType == 4 then
        field = field - 1
    end
    
    self.playerCountRequestId_ = bm.HttpService.POST({mod = "table", act = "list", tt = roomType, fld = field}, function(data)
        local retData = json.decode(data)
        if retData and retData.ret == 0 then
            if self.view_ and self.view_.onGetPlayerCountData then
                self.view_:onGetPlayerCountData(retData, field)
            end
        else
            logger:info("table_list get error, ret ", data)
        end
    end, function(errData)
        if self and self.view_ then
            --todo
            self.view_:performWithDelay(handler(self, self.getPlayerCountData), 2)
        end
    end)
end

-- 设置当前视图
function HallController:setDisplayView(view)
    self.view_ = view
end

-- 获取背景缩放系数
function HallController:getBgScale()
    return self.scene_:getBgScale()
end

-- 获取动画时间
function HallController:getAnimTime()
    return HallController.ANIM_TIME
end

-- 清理实例
function HallController:dispose()
    -- 移除请求
    bm.HttpService.CANCEL(self.roomDataRequestId_)
    bm.HttpService.CANCEL(self.playerCountRequestId_)
    bm.HttpService.CANCEL(self.enterGroupRoomId_)
    -- 移除事件
    bm.EventCenter:removeEventListenersByTag(HallController.ENTER_ROOM_WITH_DATA_EVENT_TAG)
    bm.EventCenter:removeEventListenersByTag(HallController.LOGIN_ROOM_SUCC_EVENT_TAG)
    bm.EventCenter:removeEventListenersByTag(HallController.LOGIN_ROOM_FAIL_EVENT_TAG)
    bm.EventCenter:removeEventListenersByTag(HallController.HALL_LOGOUT_SUCC_EVENT_TAG)
    bm.EventCenter:removeEventListenersByTag(HallController.SERVER_STOP_EVENT_TAG)
    bm.EventCenter:removeEventListenersByTag(HallController.DOUBLE_LOGIN_EVENT_TAG)
    bm.EventCenter:removeEventListenersByTag(HallController.APP_ENTER_FOREGROUND_TAG)

    -- 比赛场事件
    bm.EventCenter:removeEventListenersByTag(HallController.LOGIN_MATCH_SUCC_EVENT_TAG)
    bm.EventCenter:removeEventListenersByTag(HallController.LOGIN_MATCH_FAIL_EVENT_TAG)
    bm.EventCenter:removeEventListenersByTag(HallController.MATCH_STARTING_EVENT_TAG)
    bm.EventCenter:removeEventListenersByTag(HallController.MATCH_JOIN_ERROR_EVENT_TAG)

    bm.EventCenter:removeEventListenersByTag(HallController.LOGIN_MATCH_ROOM_FAIL) 

    bm.EventCenter:removeEventListenersByTag(HallController.LOGIN_DICE_SUCC_EVENT_TAG) 
    bm.EventCenter:removeEventListenersByTag(HallController.LOGIN_DICE_FAIL_EVENT_TAG) 

    bm.EventCenter:removeEventListenersByTag(HallController.LOGIN_PDENG_SUCC_EVENT_TAG) 
    bm.EventCenter:removeEventListenersByTag(HallController.LOGIN_PDENG_FAIL_EVENT_TAG) 

    self:removeOnOffLoadListener();
end

function HallController:removeOnOffLoadListener()
    if self.onOffLoadId_ then
        bm.EventCenter:removeEventListener(self.onOffLoadId_);
        self.onOffLoadId_ = nil
    end
end

function HallController:onOffLoadCallback_()
    -- 设置视图
    self.scene_:onLoginSucc()
    
    self:removeOnOffLoadListener();

    -- 判斷配置是否弹出比赛场活动提示框
    self:checkMatchActivityPopup()

    self:needShowRecommendBar(1)
    self.scene_:onOffCallback()
    nk.userData.firstPay = nk.OnOff:check("firstPayLuckybag")
    if nk.userData.firstPay then
        --请求首冲商品
        bm.HttpService.POST({
                mod = "Payment",
                act = "getFirstPaygoods"
            },
            function(data)
                local jsnData = json.decode(data)
                if jsnData and #jsnData > 0 then
                    nk.userData.firstpayData = jsnData
                end
            end,
            function()
            end)
    end

    local time_ = nk.OnOff:getConfig("jmttimes")
    if time_ and time_ > 0 then
        nk.OnOff:startDownTime(nk.OnOff.onsaleCountDownTimerId, time_)
        nk.userData.onsaleCountDownTime = time_
        --请求特价商品
        bm.HttpService.POST({
                mod = "PreferentialOrder",
                act = "jmtinfo"
            },
            function(data)
                local jsnData = json.decode(data)
                if jsnData then
                    jsnData.goodsInfo = jsnData.goods
                    nk.userData.onsaleData = jsnData
                end
            end,
            function()
            end)
    end
    display.addSpriteFrames("first_pay_texture.plist", "first_pay_texture.png")
end

-- 检查接下来的弹框
function HallController:checkPendingPupop()
    self.showPendingPopup = false
    if self.PendingPopup and self.PendingPopup[1] then
        local cb_ = table.remove(self.PendingPopup, 1)
        if cb_ then
            cb_()
            self.showPendingPopup = false
        end
    else
        self.haveExchangeCode_ = nil
        bm.EventCenter:dispatchEvent({name="PengdingPopup_End"})
    end
    -- nk.TopTipManager:showTopTip("onMovementHandler_:::")
end

function HallController:checkBillboardPopup()
    -- 
    local k1 = nk.cookieKeys.SB_BILLBOARD_SHOW_DATE
    local today = os.date('%Y%m%d')
    local saved_day = nk.userDefault:getStringForKey(k1, '')
    -- if true then -- note: 直接测试系统公告时打开此注释
    if saved_day ~= today then
        nk.userDefault:setStringForKey(k1, today)

        BillboardController.loadDataFromServer(function (json_response)
            local notice -- 从hash表取出一个值
            for k, v in pairs(json_response) do
                if type(v) == 'table' then
                    notice = v
                    break
                end
            end
            if notice and notice.content then
                table.insert(self.PendingPopup, function(data)
                        local billboardPopup = BillboardPopup.new(notice)
                        billboardPopup:setCloseCallback(handler(self, self.checkPendingPupop))
                        billboardPopup:showPanelEx_()
                        self.showPendingPopup = true
                    end)
                if not self.showPendingPopup then
                    self:checkPendingPupop()
                end
            else
                print('notice data error, do nothing')
            end
        end)
    end
end

function HallController:checkMatchActivityPopup()
    -- 判斷配置是否弹出比赛场活动提示框
    if nk.userData.popup then
        table.insert(self.PendingPopup, function(data)
                local MatchActivityPopup = import("app.module.match.MatchActivityPopup")
                local view_ = MatchActivityPopup.new():setCloseCallback(handler(self, self.checkPendingPupop))
                view_:show()
                self.showPendingPopup = true
            end)
        if not self.showPendingPopup then
            self:checkPendingPupop()
        end
    end
end

-- 打开大厅老虎机
function HallController:showSlotPopup()
    display.addSpriteFrames("slot_texture.plist", "slot_texture.png", function()
               local slotPopup = SlotPopup.new(false):show()
               slotPopup:setPreBlind(self:getSlotConfig(tonumber(nk.userData.money)))
        end)
end

function HallController:getSlotConfig(money)
    local k = 1000
    local m = k * k
    if money < 10 * k then
        return {100,200,500}
    elseif money >= 10*k and money < 100*k then
        return {k,2*k, 5*k}
    elseif money >= 100*k and money < 500*k then
        return {2*k,5*k,10*k}
    elseif money >= 500*k and money <= 5*m then
        return {10*k,20*k,50*k}
    elseif money >5 * m then
        return {100*k,200*k,m}
    end
end

-- 显示登陆奖励
function HallController:showLoginReward()
    -- nk.TestUtil.simuLogrinRewardJust = true
    if nk.TestUtil.simuLogrinRewardJust then
        nk.TestUtil.simuLoginReward()
    end
    
    if nk.userData.loginReward.ret == 1 then
        table.insert(self.PendingPopup, function(data)
            local view_ = LoginRewardView.new(true):setCloseCallback(handler(self, self.checkPendingPupop))
            nk.PopupManager:addPopup(view_,true, true, false, true)
            self.showPendingPopup = true
        end)
        if not self.showPendingPopup then
            self:checkPendingPupop()
        end
    end
end

function HallController:checkShuiDeng()
    if nk.userData.festivalRwd and nk.userData.festivalRwd.code == 1 then
        table.insert(self.PendingPopup, function(data)
            ShuiDengPopup.new():show()
        end)
        if not self.showPendingPopup then
            self:checkPendingPupop()
        end
    end
end

-- 推送兑奖码
function HallController:showExchangeCodePop()
    if self.haveExchangeCode_ then
        return
    end
    self.haveExchangeCode_ = true
    local ExchangeCodePop = import("app.module.exchangecode.ExchangeCode")
    table.insert(self.PendingPopup, function(data)
        local code = nil
        -- 获取推送码
        if nk and nk.Native and nk.Native.getPushCode then
            code = nk.Native:getPushCode()
        end
        local view_ = ExchangeCodePop.new(code):setCloseCallback(handler(self, self.checkPendingPupop))
        nk.PopupManager:addPopup(view_)
        self.showPendingPopup = true
        return view_
    end)
    if not self.showPendingPopup then
        self:checkPendingPupop()
    end
end
function HallController:getActReward()
    bm.HttpService.POST({
            mod = "act",
            act = "isGetReward"
        },
        function(data)
            nk.userData.newActReward = tonumber(data or "1") or 1
        end,
        function()
        end)
end

function HallController:toastGuide()
    bm.HttpService.POST({
            mod = "Table",
            act = "toastGuide"
        },
        function(data)
            local jsnData = json.decode(data)
            if jsnData and jsnData.ret == 0 then
                nk.TopTipManager:showTopTip({text = jsnData.flag, image = display.newSprite("#common_toast_speaker.png")}, {text=bm.LangUtil.getText("HALLOWEEN","GOPLAY"),callback = function()
                        local roomData = {}
                        roomData.ip = jsnData.ip
                        roomData.port = jsnData.port
                        roomData.tid = jsnData.tid
                        roomData.isPlayNow = false
                        bm.EventCenter:dispatchEvent({name = nk.eventNames.ENTER_ROOM_WITH_DATA, data = roomData})
                    end})
            end
        end,
        function()
        end)
end

function HallController:onLoadLgTextureComplete(str, texture)
    nk.PopupManager:addPopup(LoginRewardView.new(true),true, true, true, true)
end

-- get message
function HallController:onGetMessage()
    MessageData.new()
    FriendData.new()
end

-- pre get market data
function HallController:preGetMarketData()
    local retryTimes = 3
    local loadPayConfig
    loadPayConfig = function ()
        bm.HttpService.POST({
            mod = "Payment",
            act = "getAllPayList",
        },
        function(data)            
            local tb = json.decode(data)
            if tb and tb.ret >= 0 then --请求成功
                logger:debug("loadPayConfig complete")
                nk.userData.marketData = tb
                dump(tb)

                --提前初始化支付管理，主要检测手机是否支持JMT，在这里检测可以是商城打开快些
                local PurchaseServiceManager = import("app.module.newstore.PurchaseServiceManager")

                dump("PurchaseServiceManager import!")
                local manager = PurchaseServiceManager:getInstance()
                dump("PurchaseServiceManager:getInstance Succ!")

                local payTypeAvailable = {}

                for i, p in ipairs(tb.payTypes) do
                    p.id = tonumber(p.id)
                    if manager:isServiceAvailable(p.id) then
                        payTypeAvailable[#payTypeAvailable + 1] = p
                    end
                end
                
                dump(payTypeAvailable, "payTypeAvailable :==================")
                dump("start init PurchaseServiceManager")
                manager:init(payTypeAvailable)
            else
                nk.userData.marketData = nil
                retryTimes = retryTimes - 1 --请求失败后， 重试次数，3次以后还失败，就关闭商城界面
                if retryTimes > 0 then
                    loadPayConfig()
                end
            end
        end,
        function()
            nk.userData.marketData = nil
            retryTimes = retryTimes - 1
            if retryTimes > 0 then
                loadPayConfig()
            end
        end)
    end
    loadPayConfig()
end

function HallController:reportLoginResult_(loginType, code, detail)
     if device.platform == "android" or device.platform == "ios" then
         local eventName
         if loginType == "FACEBOOK" then
             eventName = "login_result_facebook"
         elseif loginType == "GUEST" then
             eventName = "login_result_guest"
         end
         if eventName then
            cc.analytics:doCommand{
                command = "event",
                args = {
                    eventId = eventName,
                    label = "[" .. code .. "]" .. detail,
                },
            }
        end
    end
end

-- 登录账号数上报 用于统计一个设备同时玩几个号
function HallController:reportLoginAccountCount_(uid)
    if device.platform ~= "android" and device.platform ~= "ios" then
        return
    end
    uid = tostring(uid)
    local uids = nk.userDefault:getStringForKey(nk.cookieKeys.LOGIN_UIDS, "")
    local count = 0
    if uids == "" then
        uids = uids..uid
        nk.userDefault:setStringForKey(nk.cookieKeys.LOGIN_UIDS, uids)
        nk.userDefault:flush()
        count = 1
    else
        local uidsTbl = string.split(uids, "#")
        if table.indexof(uidsTbl, uid) == false then
            uids = uids .. "#" .. uid
            nk.userDefault:setStringForKey(nk.cookieKeys.LOGIN_UIDS, uids)
            nk.userDefault:flush()
            count = #uidsTbl + 1
        end
    end
    if count > 0 then
        cc.analytics:doCommand{
            command = "eventCustom",
            args = {
                eventId = "login_account_count",
                attributes = "type,account",
                counter = count
            }
        }
    end
end

--- 更新折扣率
-- 通过web服务接口向支付中心获取折扣信息
function HallController:updateUserMaxDiscount()
    local userData = nk.userData
    if not userData then return end

    local requestMaxDiscount
    local maxretry = 4
    requestMaxDiscount = function()
        bm.HttpService.POST({
                mod="Payment",
                act="getMaxDiscount",
            },
            function(retData)
                local retJson = json.decode(retData)
                if retJson and retJson.ret == 0 then
                    userData.__user_discount = tonumber(retJson.discount) or 1
                else
                    maxretry = maxretry - 1
                    if maxretry > 0 then
                        requestMaxDiscount()
                    end
                end
            end,
            function()
                maxretry = maxretry - 1
                if maxretry > 0 then
                    requestMaxDiscount()
                end
            end)
    end
    requestMaxDiscount()
end

function HallController:onEnterForeground_()
    self.isLoginInProgress_ = -1
     local viewStatus = bm.DataProxy:getData(nk.dataKeys.CURRENT_HALL_VIEW)
    if viewStatus == HallController.MAIN_HALL_VIEW then
        self:needShowRecommendBar(1)
    end
end

function HallController:checkCallbackRewardPopup_()
    -- mobile.php的响应中alertPushReward = 1才弹窗
    if nk.userData.alertPushReward ~= 1 then return end

    -- 一次登录, 领取过召回奖励之后, 清除标志
    nk.userData.alertPushReward = 0

    local k1 = nk.cookieKeys.RN_HAVEAUTORECALL
    if nk.userDefault:getBoolForKey(k1, false) then
        -- 处理后清除状态 (不考虑此时又收到一个通知消息,同步写的极端情况)
        nk.userDefault:setBoolForKey(k1, false)

        local k2 = nk.cookieKeys.RN_AUTORECALL_MSG
        local msg = json.decode(nk.userDefault:getStringForKey(k2, '{}'))

        -- 消息中chip数量大于0才会有奖励
        if msg and msg.chip > 0 then
            local args = {
                key   = msg.key,
                chips = msg.chip,
            }
            local view = CallbackGiftView.new(args)
            display.getRunningScene():addChild(view, 1000)
        else
            print 'not found last remote notice msg! or chip <= 0'
        end
    else
        print 'nk.cookieKeys.RN_HAVEAUTORECALL false!'
    end
end

function HallController:needShowRecommendBar(isShow)
    local isAdSceneOpen = nk.OnOff:check("unionAd")
    if isAdSceneOpen and nk.AdSceneSdk then
        nk.AdSceneSdk:setShowRecommendBar(isShow)
    end
end

function HallController:umengEnterHallTimeUsage()
    if device.platform ~= "android" and device.platform ~= "ios" then
        return
    end

    local g = global_statistics_for_umeng

    -- 一次进程启动只算作一次
    if g.first_enter_hall_checked then return end

    g.first_enter_hall_checked = true

    local delta = math.abs(os.difftime(os.time(), g.run_main_timestamp))

    -- 60秒以上的,只统计为60秒
    if delta > 60 then delta = 60 end

    cc.analytics:doCommand {
        command = 'eventCustom',
        args = {
            eventId    = 'boot_to_hall_time_usage',
            attributes = 'boot_time,' .. delta,
            counter    = 1, -- 自定义属性的数量, 默认为0
        },
    }
end

--上报当前总资产,用于更新 资产排行榜
function HallController:reportCurTotalMoney()
    local totalMoney = nk.userData.bank_money + nk.userData.money
    local time_ = os.time()
    bm.HttpService.POST(
        {
            mod="Ranklist",
            act="report",
            money = totalMoney,
            time = time_,
            sign = crypto.md5(time_ .. "1e2c206269c42354c6dae040bca194c8f")
        },
        function ()
            print("HallController:reportCurTotalMoney()")
        end,
        function ()
        end)
end


function HallController:getJsonTab()
    local str = nk.userDefault:getStringForKey(JSON_PARSE_ERROR_KEY, '')
    local data = json.decode(str)
    if data then
        reportJsonData = data
    end
end

function HallController:writeJsonTab()
    nk.userDefault:setStringForKey(JSON_PARSE_ERROR_KEY, json.encode(reportJsonData))
end

function HallController:reportJsonTab()
    if #reportJsonData > 0 then
        local feedBackUrl = BM_UPDATE.FEEDBACK_URL or ""
        if string.len(feedBackUrl) > 5 then
                bm.HttpService.POST_URL(feedBackUrl,
                {
                    mod = "Feedback",
                    act = "LoginError",
                    sid = appconfig.SID[string.upper(device.platform)] or 1,
                    errordata = json.encode(reportJsonData),
                },
                function(data)
                    local jsnData = json.decode(data)
                    if jsnData and jsnData.ret == 0 then
                        reportJsonData = {}
                        self:writeJsonTab()
                    else
                        self:writeJsonTab()
                    end
                end,
                function()
                    self:writeJsonTab()
                end
            )
        end
    end
end

function HallController:getCurDealerId()
    bm.HttpService.POST(
        {
            mod = "Croupier",
            act = "info",
         },
        function (data)
            local retData = json.decode(data)
            if retData and retData.code == 0 then
                local list = retData.list
                for i = 1, #list do
                    local dealerData = list[i]
                    if dealerData.status == 1 then
                        nk.userData.dealerId = dealerData.id
                        break
                    end
                end
            else
                nk.userData.dealerId = 1
            end
        end,
        function (data)
            nk.userData.dealerId = 1
        end)
end

function HallController:proLoginedPopup_()
    -- 优先检查召回宝箱弹框
    -- 因为流失用户 已经流失,所以假定 不是以 enter fore ground的方式进入游戏
    -- 的,一定会有一个完整的 启动-热更新-登录-进入大厅的流程 只在这里检查一次
    -- self.view_:performWithDelay(handler(self, self.checkCallbackRewardPopup_), 0.5)

    -- 登陆成功之后 检查 新用户注册奖励弹框 登录奖励弹框, 两者不会同时出现
    --[[
    self.view_:performWithDelay(handler(self, self.onRewardPopup), 1.2)
    self.view_:performWithDelay(handler(self, self.showLoginReward), 1.2)
    self.view_:performWithDelay(handler(self, self.getActReward), 1.0)
    self.view_:performWithDelay(handler(self, self.toastGuide), 15.0)

    -- 检查今日的系统公告 刚好系统公告弹在登录奖励前面
    self:checkBillboardPopup()

    -- 检查是否需要重新连入房间
    self.view_:performWithDelay(function()
        --缓存脏话库
        nk.cacheKeyWordFile()
        nk.SoundManager:preload("commonSounds")
        self:checkNeedEnterRoomInLoginData()
    end, 2.5)
    ]]--

    self.view_:performWithDelay(function()
        self:checkBillboardPopup()
        self:getActReward()
        self:onRewardPopup()
        self:showLoginReward()
        self:toastGuide()
    end, 1.6)

    -- 检查是否需要重新连入房间
    self.view_:performWithDelay(function()
        --缓存脏话库
        nk.cacheKeyWordFile()
        nk.SoundManager:preload("commonSounds")
        self:checkNeedEnterRoomInLoginData()
    end, 2.5)
end

return HallController
