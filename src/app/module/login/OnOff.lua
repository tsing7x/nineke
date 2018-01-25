-- 开关控制
-- Author: LeoLuo
-- Date: 2015-06-12 16:30:43
--
local OnOff = class("OnOff")
local logger = bm.Logger.new("OnOff")

function OnOff:ctor()
    self.onoff_ = {}
    self.version_ = {}
end

function OnOff:load(callBack)
    -- 各种比赛显示依赖的数据
    nk.userData.isShowMatchIp = 1
    nk.userData.openMatch = 1
    nk.userData.nextExpireTickets = 0
    nk.userData.isOpenDailyLuck = 0
    nk.userData.opensbguide = 0
    nk.userData.cdn = ""
    nk.openFeedWord = 1
    nk.userData.arenaLimiteLevel = 2
    nk.userData.fourlevel = 3
    nk.userData.fivelevel = 5
    nk.userData.buyLuckWheelChanceMoney = 9900 -- 9900购买一次转盘次数费用

    -- 添加回调
    self.loadCallback_ = callBack

    self.retryTimes_ = 3

    local isInstalled = 0
    if nk.Native:isAppInstalled("com.boyaa.pokdeng") then
        isInstalled = 1
    end

    bm.HttpService.POST({
        mod="Gameserver",
        act="getOnOffAndVersion",
        isAppInstalled = isInstalled
    },
    function(retData)
        local retJson = json.decode(retData)
        -- dump(retJson, "bm.HttpService.POST[Gameserver.getOnOffAndVersion] :===================")
        if retJson and type(retJson)=="table" and retJson.ret == 0 then
            self.onoff_ = retJson.onofflist
            self.version_ = retJson.versionlist
            self:checkVipExpire()

            nk.userData.activityTj = retJson.onofflist.activityTj
            nk.userData.reportMoneyRanking = retJson.onofflist.ranklistReportNum
            nk.userData.yesterdayReward = retJson.onofflist.yesterdayCheckUser
            nk.userData.isOpenBigR = retJson.onofflist.bigrAddress or 0 -- 是否显示大R用户图片
            nk.userData.isNewScoreAddress = retJson.onofflist.isNewScoreAddress or 0
            nk.userData.verifyThirdPay = retJson.onofflist.verifyThirdPay or 0--1不屏蔽第三方支付，0屏蔽
            nk.userData.fourk = retJson.onofflist.fourk or 0 --是否显示4K场入口
            nk.userData.fourktable = retJson.onofflist.fourktable or 0 --1表示只开5人场，2表示只开9人场，3都开
            nk.userData.fourlevel = retJson.onofflist.fourlevel or 3
            nk.userData.fivelevel = retJson.onofflist.fivelevel or 5
            nk.userData.opensbguide = retJson.onofflist.sbguide or 0 --房间内强制升级换桌
            
            nk.userData.newInviteType = retJson.onofflist.newinvite_type or 1 --1关闭 2邀请筛选新规则 3邀请筛选老规则
            nk.userData.newInviteNum = retJson.onofflist.newinvite_num or 50 --客户端选择按钮，选择人数类型 0全选 其他数字表示具体人数
            nk.userData.inviteRewardLimit = retJson.onofflist.newinvite_maxmoney or 50000 --当日邀请奖励上限
            nk.userData.newInviteDays = retJson.onofflist.newinvite_days or 1 --邀请好友显示间隔天数

            nk.userData.isConfirmFirstpay = retJson.onofflist.isConfirmFirstpay or 1 --首冲是否弹出确认框
            nk.userData.isConfirmSmsPay = retJson.onofflist.isSmsPay or 1 --短信是否弹出确认框
            
            nk.userData.halloweenGift = retJson.onofflist.halloweenGift or 0
            nk.userData.switchAct = retJson.onofflist.switchAct or 0
            nk.userData.christmasAct = retJson.onofflist.christmasAct or 0
            nk.userData.vipcoupon = retJson.onofflist.vipcoupon or 0

            nk.userData.songkranProps = 0--retJson.onofflist.songkranProps or 0 --泼水节活动道具开关
            nk.userData.waterLampProps = retJson.onofflist.waterfallAct or 0 --水灯节开关
            
            nk.userData.homeluckwheel = retJson.onofflist.homeluckwheel or 0    --是否显示桌面大转盘

            nk.userData.showRealRecord = retJson.onofflist.showRealHistory or 0 --兑换商城中，是否显示实物奖励兑换记录
            nk.userData.motherDayRedNode = retJson.onofflist.motherDayRedNode
            if retJson.onofflist.motherDayRedNode == 1 then
                nk.userData.motherDayRedNodePath = "pop_messagecenter_red_point_mom.png"
            else
                nk.userData.motherDayRedNodePath = "#pop_messagecenter_red_point.png"
            end            
        end

        -- 加载比赛信息
        self:getMatchInfo()
    end,
    function()
        -- 加载比赛信息
        self:getMatchInfo()
    end)

    self:getSysInfo()
end

function OnOff:getSysInfo()
    bm.HttpService.POST({
        mod="Gameserver",
        act="getSysConf"
    },function(retData)
        local retJson = json.decode(retData)
        if retJson and type(retJson)=="table" and retJson.ret == 0 then
            nk.userData.isfollowfriend = retJson.onofflist.isfollowfriend or 0
        end
    end,function()
    end)
end

function OnOff:getMatchInfo()
    bm.HttpService.POST(
        {
            mod="Match",
            act="init",
        },
        function(retData)
            local retJson = json.decode(retData)
            if retJson and retJson.ret == 0 then
                local onoff_ = retJson.onofflist
                nk.userData.isShowMatchIp = retJson.showMatchIp or 1
                nk.userData.cdn = retJson.cdn
                nk.userData.popup = retJson.popup -- 
                nk.userData.sponsor = retJson.sponsor -- 赞助商
                nk.userData.tipsUrl = nk.userData.cdn..onoff_.tips -- 切场提示信息
                nk.userData.isMix = onoff_.mix or 0--合成炉是否开启
                nk.userData.mallSponsor = onoff_.mallSponsor or 0 -- 赞助物品兑换

                nk.userData.matchMall = onoff_.matchMall or 0 -- 实物兑换
                nk.userData.matchWheel = onoff_.matchWheel or 0 -- 实物转盘

                nk.userData.openMatchNotice = onoff_ and onoff_.openMatchNotice or 0
                nk.userData.matchNotice = onoff_ and onoff_.matchNotice or ""
                nk.userData.openSharePhoto = onoff_ and onoff_.openSharePhoto or 0
                nk.userData.isShowBill = onoff_ and onoff_.isShowBill or 1 -- 是否显示账单查询
                nk.userData.isMatchDetail = onoff_ and onoff_.isMatchDetail or 0 -- 是否显示比赛场详细信息
                nk.userData.scoreMarketGifts = onoff_ and onoff_.scoreMarketGifts or "" -- 是否显示比赛场详细信息
                nk.userData.nextExpireTickets = onoff_ and onoff_.nextExpireTickets or 0 -- 快过期标志
                nk.userData.isOpenShopH5 = onoff_ and onoff_.isOpenShopH5 or 0 -- 是否打开HTML5商城
                nk.openFeedWord = onoff_ and onoff_.openFeedWord or 1 -- 是否打开feed分享文字
                nk.userData.openQuestion = onoff_.openQuestion or 0 -- 是否显示调查问卷
                nk.userData.questionUrl = onoff_.questionUrl    -- 问卷调查url地址
                nk.userData.questionTitle = onoff_.questionTitle    -- 问卷调查title
                nk.userData.questionDesc = onoff_.questionDesc    -- 问卷调查desc
                nk.userData.isOpenDailyLuck = onoff_ and onoff_.isOpenDailyLuck or 0 -- 是否显示每日转盘
                nk.userData.sendCardTimeTips = onoff_ and onoff_.sendCardTimeTips -- 商城添加发放时间
                nk.userData.isUseAnimation = onoff_ and onoff_.isUseAnimation or 1 -- 是否使用礼物动画功能
                nk.userData.arenaLimiteLevel = onoff_ and onoff_.arenaLimiteLevel or 2 -- 比赛场开启限制等级
                nk.userData.buyLuckWheelChanceMoney = onoff_ and onoff_.buyLuckWheelChanceMoney or 9900 -- 购买一次转盘次数费用
                nk.userData.gcoinsLog = (onoff_ and onoff_.gcoinsLog) and onoff_.gcoinsLog or 1 -- 开启黄金币详细日志

                local matchUserInfo = onoff_ and onoff_.matchUserInfo
                if matchUserInfo then
                    nk.userData.bank_score = tonumber(matchUserInfo.bankscore or 0)
                    nk.userData.score = tonumber(matchUserInfo.score or 0)
                    nk.userData.goldCoupon = tonumber(matchUserInfo.goldCoupon or 0)
                    nk.userData.gameCoupon = tonumber(matchUserInfo.gameCoupon or 0)
                    nk.userData.rate = tonumber(matchUserInfo.rate or 0.5)
                    nk.userData.rate = 0 -- 强制关闭

                    if onoff_ then
                        nk.userData.inviteMatchChips = onoff_.inviteMatchChips or 10
                        nk.userData.inviteSendMatchChips = nk.userData.inviteMatchChips
                        nk.userData.inviteMatchCnt = onoff_.inviteMatchCnt or 10
                        nk.userData.inviteMatchLimitCnt = onoff_.inviteMatchLimitCnt or 20
                        nk.userData.inviteMatchScore = onoff_.inviteMatchScore or 1
                        nk.userData.task = onoff_.task or 0 -- 比赛场每日任务
                    end
                end

                nk.EnterTipsManager:loadTipsJson(nk.userData.tipsUrl)
            end

            if self.loadCallback_ then
                self.loadCallback_()
            end

            self.loadCallback_ = nil
        end,
        function()
            self.retryTimes_=self.retryTimes_-1
            if self.retryTimes_ > 0 then
                self:getMatchInfo()
            end
        end
    )
end

function OnOff:checkVipExpire()
    local vipconfig = self:getConfig('vipmsg')
    if vipconfig and vipconfig.isvip == 1 and vipconfig.vip and vipconfig.vip.light == 1 and vipconfig.vip.surplus then
        if vipconfig.vip.surplus > 0 and  vipconfig.vip.surplus < 86400 then
            if self.vipExpireDelayUpdateId_ then
                nk.schedulerPool:clear(self.vipExpireDelayUpdateId_)
            end
            self.vipExpireDelayUpdateId_ = nk.schedulerPool:delayCall(function()
                app:loadOnOffData()
            end, vipconfig.vip.surplus + 2)
        end
    end
end

function OnOff:check(name)
    return isset(self.onoff_, name) and tonumber(self.onoff_[name]) == 1
end

function OnOff:getConfig(name)
    local r
    r = self.onoff_[name]
    logger:debugf('getConfig %s = %s from OnOff: ', name, tostring(r))
    return r
end

function OnOff:checkVersion(name, version)
    return isset(self.version_, name) and self.version_[name] == version
end

-- 判断是否为商城兑换的礼物， true为商城兑换的
function OnOff:isScoreMarketSaleGift(giftId)
    if not giftId or tostring(giftId) == 0 then
        return false
    end

    local defaultGiftIds
    if not nk.userData.scoreMarketGifts or nk.userData.scoreMarketGifts == "" then
        defaultGiftIds = "1054,1053,1052,1051,1050,16,15,14,13,12,11,"
    else
        defaultGiftIds = nk.userData.scoreMarketGifts 
    end

    if string.sub(defaultGiftIds, -1) ~= "," then
        defaultGiftIds = defaultGiftIds .. ","
    end

    local key = giftId..","
    local idx,_ = string.find(defaultGiftIds, key)
    if idx then
        return true
    else
        return false 
    end
end

function OnOff:openSponsorWebView(sign, url, dw, dh, eventIdKey)
    if url and string.len(url) > 0 then
        if device.platform == 'ios' then
            local function start()
            end
            local function finish()
            end
            local function fail(error_info)
            end
            local function userClose()
                nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
            end

            local W, H = dw, dh - 72
            local x, y = display.cx - W / 2, display.cy - H / 2
            local view, err = Webview.create(start, finish, fail, userClose)
            if view then
                view:show(x,y,W,H)
                view:updateURL(url)
            end
        elseif device.platform == "android" then
            local glview = cc.Director:getInstance():getOpenGLView()
            local size = glview:getFrameSize()
            local w = size.width
            local h = size.height
            nk.Native:openWebview(url, nil, w, h, "", 1, 1)
        else
            device.openURL(url)
        end
    end

    if device.platform == "android" or device.platform == "ios" then
        local eventId = eventIdKey or "goto_sponsorUrl_Click"
        cc.analytics:doCommand{command = "event",
            args = {eventId = eventId, label=sign.."::"..url}}
    end
end

-- 保存每日转盘次数
function OnOff:saveDailyLuckCount(num)
    local date = os.date("%Y%m%d")
    local keyValue = tostring(nk.userData.uid).."|"..tostring(date).."|"..tostring(num)
    local key = "DailyLuckDraw_Count"..tostring(nk.userData.uid)
    nk.userDefault:setStringForKey(key, keyValue) 
end

-- 判断是否转动
function OnOff:isPlayDailyLuck()
    if nk.userData.isOpenDailyLuck == 0 then
        return false
    end

    local result = true
    local date = os.date("%Y%m%d")
    local key = "DailyLuckDraw_Count"..tostring(nk.userData.uid)
    local dataStr = nk.userDefault:getStringForKey(key, "")
    local arr = string.split(dataStr, "|")
    if dataStr ~= "" and tostring(arr[1]) == tostring(nk.userData.uid) and tostring(arr[2]) == tostring(date) and tonumber(arr[3]) < 1 then
        result = false
    end 
    return result
end

OnOff.onsaleCountDownTimerId = 1

function OnOff:startDownTime(timerId, time)
    if not self.timers then
        self.timers = {}
    end
    if self.timers[timerId] and self.timers[timerId].id then
        nk.schedulerPool:clear(self.timers[timerId].id)
    else
        self.timers[timerId] = {}
    end
    self.timers[timerId].counttime_ = time
    self.timers[timerId].id = nk.schedulerPool:delayCall(function() 
        self:countFunc(timerId)
    end, 1)
end

function OnOff:countFunc(timerId)
    if self.timers and self.timers[timerId] then
        self.timers[timerId].counttime_ = self.timers[timerId].counttime_ - 1
        if self.timers[timerId].counttime_ <= 0 then
            self.timers[timerId].counttime_ = -1
        else
            nk.schedulerPool:delayCall(function() 
                self:countFunc(timerId)
            end, 1)
        end
    end
end

function OnOff:getCurrentTime(timerId)
    if self.timers and self.timers[timerId] then
        return self.timers[timerId].counttime_
    end
    return nil
end

function OnOff:clearTimer(timerId)
    if self.timers and self.timers[timerId] and self.timers[timerId].id then
        nk.schedulerPool:clear(self.timers[timerId].id)
        self.timers[timerId].counttime_ = -1
        self.timers[timerId] = nil
    end
end

return OnOff
