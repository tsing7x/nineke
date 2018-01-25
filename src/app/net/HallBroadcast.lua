--
-- Author: Jonah0608@gmail.com
-- Date: 2016-01-13 15:03:16
--
local HallController = import("app.module.hall.HallController")
local PROTOCOL = import(".HALL_SOCKET_PROTOCOL")
local MessageData = import("app.module.hall.message.MessageData")
local UpgradePopup = import("app.module.upgrade.UpgradePopup")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local HallBroadcast = class("HallBroadcast")

function HallBroadcast:ctor()
    self.canReceiveMatchLaBa = true
    self.isFirstShowMatchLaBa = true
    self:addListener()
end

function HallBroadcast:onProcessPacket(pack)
    -- dump(pack, "HallBroadcast:onProcessPacket.pack :============")

    local P = PROTOCOL
    local cmd = pack.cmd
    if cmd == P.BROADCAST_PERSON then
        PBPT = P.BROADCAST_PERSON_TYPE
        local info = json.decode(pack.info)
        if pack.type == PBPT.SVR_ADD_SIT_EXP then
            bm.EventCenter:dispatchEvent({
                name=nk.eventNames.SVR_BROADCAST_ADD_EXP,
                exp= info and info.exp or 0
            })
        elseif pack.type == PBPT.SVR_GOT_NEW_MESSAGE then
            MessageData.hasNewMessage = true
            bm.DataProxy:setData(nk.dataKeys.NEW_MESSAGE, MessageData.hasNewMessage)
        elseif pack.type == PBPT.SVR_MODIFY_USER_ASSET then
            if info then
                self:moneyChange_(info)
            end
        elseif pack.type == PBPT.BROAD_CAST_PROP_FUNFACE then
            if info then
                if info.id == 2 then
                    nk.UserInfoChangeManager:updateHddjChange(info.count)
                elseif info.id == 5 then
                    nk.UserInfoChangeManager:updateKickChange(info.count)
                end
            end
        elseif pack.type == PBPT.SVR_ACT_STATE then
            bm.EventCenter:dispatchEvent({
                name=nk.eventNames.SVR_BROADCAST_ACT_STATE,
                actId=info.actId or 0,
                actState=info.actState or 0,
                actTarget=info.actTarget or 0
            })
        elseif pack.type == PBPT.SVR_USER_INFO_CHANGE then
            if info then
                nk.UserInfoChangeManager:userInfoChange(info)
            end
        elseif pack.type == PBPT.SVR_TICK_INFO_CHANGE then
            if info then
                nk.MatchTickManager:updateSvData(info)
            end
        elseif pack.type == PBPT.SVR_MATCHDAILY_INFO_CHANGE then
            nk.MatchDailyManager:updateSvData()
        elseif pack.type == PBPT.SVR_VIP_LIGHT then
            local info = json.decode(pack.info)
            if info and info.awardmsg and info.awardmsg.code == 0 and info.awardmsg.msg then 
                self:vipLight(info.awardmsg.msg)
            end
            -- 刷新onoff
            app:loadOnOffData()
        elseif pack.type == PBPT.SVR_TASK_REWARD_CHANGE then
            if info and info.num and info.num > 0 then
                bm.DataProxy:setData(nk.dataKeys.NEW_REWARD_TASK, true)
            end
        elseif pack.type == PBPT.SVR_CHANGE_GIFT then
            local info = json.decode(pack.info)
            if info and info.id then
                if info.type == 1 then
                    nk.TopTipManager:showTopTip("ยินดีด้วยค่ะ คุณได้รับของขวัญวันฮาโลวีนประดับรูปประจำตัว")
                end
                nk.userData.user_gift = info.id
                if nk.socket.HallSocket.isRoomEntered_ then
                    nk.socket.HallSocket:sendUserInfoChanged()
                end
            end
        elseif pack.type == PBPT.GROUP_PUSH_AWARD then  -- 群组福利哦
            local info = json.decode(pack.info)
            if info and info.msg then
                local GroupAwardPopup = require("app.module.friend.group.GroupAwardPopup")
                GroupAwardPopup.new(info):show()
            end
        elseif pack.type == PBPT.SVR_INVITE_PLAY then  -- 收到邀请进入房间玩牌
            local info = json.decode(pack.info)
            nk.TopTipManager:showTopTip(info.msg, {text = bm.LangUtil.getText("GROUP", "ENTER_ROOM_PLAY"), callback = function ()
                    local roomData = {
                        ip = info.ip,
                        port = info.port,
                        tid = info.tid,
                        isPlayNow = false,
                        psword = info.password,
                    }
                    
                    nk.userData.groupId = info.group_id
                    bm.EventCenter:dispatchEvent({name = nk.eventNames.ENTER_ROOM_WITH_DATA, data = roomData, isTrace = false})
            end})
        elseif pack.type == PBPT.SVR_NEW_YEAR_ACT then
            local info = json.decode(pack.info)
            if info then
                if info[1] == 1000 then
                    self:preGetMarketData()
                    bm.EventCenter:dispatchEvent({name="getNewStoreInfo", data=info[1]})
                elseif info[1] == 1001 then
                    nk.userData.vipcoupon = 1
                elseif info[1] == 999 then
                    nk.userData.vipcoupon = 0
                 elseif info[1] == 1002 then
                    nk.userData.vipcoupon = 0
                    app:loadOnOffData()
                end
            end
        elseif pack.type == PBPT.SVR_PAY_INFO then
            local info = json.decode(pack.info)
            if info then
                nk.AdSdk:report(consts.AD_TYPE.AD_PAY,{uid =tostring(nk.userData.uid),payMoney=info.paymoney,currencyCode="THB",orderId=info.order_id or ""})
            end
        elseif pack.type == PBPT.HALLOWEENACT_REWARD then
            --todo
            local info = json.decode(pack.info)
            -- dump(info, "HallBroadcast:onProcessPacket[BROADCAST_PERSON.HALLOWEENACT_REWARD].data->info :===============")

            if info then
                --todo
                local popupRewData = {}
                popupRewData.gameRound = info.poker_num
                popupRewData.chipNum = info.money
                popupRewData.giftId = info.gift
                popupRewData.giftExpire = info.giftExpire
                popupRewData.HDDJNum = info.pompkin

                local pumpActPopup = import("app.module.act.HalwnPumpActPopup")
                local actPopup = pumpActPopup.new(popupRewData)
                nk.PopupManager:addPopup(actPopup, true, true, false, false)
            end
        end
    elseif cmd == P.BROADCAST_SYSTEM then
        PBST = P.BROADCAST_SYSTEM_TYPE
        local info = json.decode(pack.info)
        if info and info.type then
            if info.type == PBST.SVR_BIG_SLOT_REWARD then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("SLOT", "TOP_PRIZE", info.nick or "", bm.formatBigNumber(tonumber(info.addmoney or 0))))
            elseif info.type == PBST.SVR_SERVER_STOP then
                local curScene = display.getRunningScene()
                if curScene.name == "HallScene" then
                    bm.EventCenter:dispatchEvent({name=nk.eventNames.SERVER_STOPPED})
                end
            elseif info.type == PBST.SVR_MATCH_CONFIG_CHANGE then
                nk.needReloadMatchConfig = true
                -- 是否有增加场次 有则要关闭当前连接
                local retData = json.decode(pack.msg)
                if retData and retData.addMatch then
                    nk.needReConnectMatch = true
                end
            elseif info.type == PBST.SVR_CHARMRANK then
                --魅力值排行榜
                local info = json.decode(pack.msg)
                if info and info.msg then 
                    nk.TopTipManager:showTopTip(info.msg)
                end
            elseif info.type == PBST.SVR_GAME_BROADCAST_P0 then  --P0官方消息
                self:pushGameLabaMessage_(info)
            elseif info.type == PBST.SVR_GAME_BROADCAST_P1 then  --P1活动消息
                self:pushGameLabaMessage_(info)
            elseif info.type == PBST.SVR_MATCH_BROADCAST then  --新的比赛喇叭消息，增加消息类型
                self:pushGameLabaMessage_(info)
            elseif info.type == PBST.SVR_BIG_LABA then
                -- 
            elseif info.type == PBST.SVR_MATCH_LABA then
                -- 
            end
        end
    end
end

function HallBroadcast:moneyChange_(retData)
    local userData = nk.userData
    nk.UserInfoChangeManager:updateMoneyChange(retData)
    if retData.exp then
        retData.exp = tonumber(retData.exp)
        if retData.exp and retData.exp > 0 then
            userData.experience = retData.exp
            userData.level = nk.Level:getLevelByExp(retData.exp) or userData.level
            userData.title = nk.Level:getTitleByExp(retData.exp) or userData.title
        end
    end
    if userData.money > userData.maxmoney then
        userData.maxmoney = userData.money
    end
end

function HallBroadcast:preGetMarketData()
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
                nk.userData.marketData = tb

                --提前初始化支付管理，主要检测手机是否支持JMT，在这里检测可以是商城打开快些
                local PurchaseServiceManager = import("app.module.newstore.PurchaseServiceManager")
                local manager = PurchaseServiceManager:getInstance()

                local payTypeAvailable = {}
                for i, p in ipairs(tb.payTypes) do
                    p.id = tonumber(p.id)
                    if manager:isServiceAvailable(p.id) then
                        payTypeAvailable[#payTypeAvailable + 1] = p
                    end
                end
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

function HallBroadcast:vipLight(msg)
    nk.MatchTickManager:synchPhpTickList()
end

function HallBroadcast:pushBigLaBaMsg_(msg)
    if not nk.userData.bigLaBaList then
        nk.userData.bigLaBaList = {};
    end
    -- 
    local list = nk.userData.bigLaBaList;
    if #list >= 10 then
        table.remove(list, 1);
    end
    for i=1,#list do
        if list[i] == msg then
            return;
        end
    end
    table.insert(list, #list+1, msg);
    bm.EventCenter:dispatchEvent({name=nk.eventNames.SVR_BROADCAST_BIG_LABA, data=msg});
end

--广播消息start---------------------------------------------------------------------------------------------
local GAME_LABA_DELAY = 5*60
-- 把游戏广播压入待播放对象中
function HallBroadcast:pushGameLabaMessage_(info)
    if self.isPause_ then
        table.insert(self.stack_, #self.stack_+1, info);
        return;
    end
    -- 
    local priorityVal = 0
    if info.type == PBST.SVR_GAME_BROADCAST_P0 then  --P0官方消息
        priorityVal = 16
    elseif info.type == PBST.SVR_GAME_BROADCAST_P1 then  --P1活动消息
        priorityVal = 8
    elseif info.type == PBST.SVR_MATCH_LABA then  --新的比赛喇叭消息，增加消息类型
        priorityVal = 4
    elseif info.type == PBST.SVR_MATCH_BROADCAST then  --新的比赛喇叭消息，增加消息类型
        priorityVal = 2
    end
    -- 
    if not self.waitLabaQueues_ then
        self.waitLabaQueues_ = {priority=priorityVal, data=info}
    else
        if priorityVal < self.waitLabaQueues_.priority then
            return 
        end
        self.waitLabaQueues_ = {priority=priorityVal, data=info}
    end
    -- 
    self:sendNextGameLabaMessage_()
end

-- 发送游戏广播消息
function HallBroadcast:sendGameLabaMessage_()
    -- 判断玩家如果在登录界面不提示广播消息
    local viewStatus = bm.DataProxy:getData(nk.dataKeys.CURRENT_HALL_VIEW)
    if viewStatus == HallController.LOGIN_GAME_VIEW then
        self.waitLabaQueues_ = nil
        return
    end
    -- 
    if not self.waitLabaQueues_ then
        return
    end
    -- 
    local icon_ = nil
    local retData = self.waitLabaQueues_.data.info
    self.waitLabaQueues_ = nil
    -- 
    if not retData then
        return
    end
    -- 
    if retData.type then
        if retData.type == "bcExchange" then
            icon_ = display.newSprite("#common_toast_speaker.png")
        elseif retData.type == "bcChampion" then
            icon_ = display.newSprite("#common_toast_match.png")
        end
    end
    -- 
    if not icon_ then
        nk.TopTipManager:showTopTip({animType=nk.TopTipManager.ANIM_TYPE_HOR, text = retData.msg})
    else
        nk.TopTipManager:showTopTip({animType=nk.TopTipManager.ANIM_TYPE_HOR, text = retData.msg, image = icon_})
    end
    -- 
    self.lastShowTime_ = os.time()
    -- 延迟一秒播放下一条
    scheduler.performWithDelayGlobal(handler(self, self.sendNextGameLabaMessage_), GAME_LABA_DELAY)
end

function HallBroadcast:sendNextGameLabaMessage_()
    -- 两条消息间隔要超过5分钟
    if not self.lastShowTime_ then
        self:sendGameLabaMessage_()
    elseif os.time() - self.lastShowTime_ >= GAME_LABA_DELAY then
        self:sendGameLabaMessage_()
    else
        
    end
end

-- 添加监听
function HallBroadcast:addListener()
    self.stack_ = {}
    self.isPause_ = false
    -- 处理大转盘转动实物，导致系统广播消息立即显示
    self.boxRewardAnimationId_ = bm.EventCenter:addEventListener("Player_BoxRewardAnimation", handler(self, self.onBoxRewardAnimation_))
end

-- 移除监听
function HallBroadcast:removeListener()
    if self.boxRewardAnimationId_ then
        bm.EventCenter:removeEventListener(self.boxRewardAnimationId_)
        self.boxRewardAnimationId_ = nil;
    end
end

-- 控制播放BoxRewardAnimation动画与属性实现播放动画的同步
function HallBroadcast:onBoxRewardAnimation_(evt)
    if evt.data == "start" then
        self.isPause_ = true;
    elseif evt.data == "end" then
        self.isPause_ = false;
        self:refreshStack_(false);
    elseif evt.data == "Wheel_start" then
        self.isPause_ = true;
    elseif evt.data == "Wheel_end" then
        self.isPause_ = false;
        self:refreshStack_(true);
    end     
end

-- 刷新积压的堆栈数据列表
function HallBroadcast:refreshStack_()
    while #self.stack_ > 0 do
        self:pushGameLabaMessage_(self.stack_[1]);
        table.remove(self.stack_, 1)
    end
end

function HallBroadcast:testNotify()
    local info = {}
    info.type = PBST.SVR_GAME_BROADCAST_P0
    info.info = {}
    -- info.info.type = "bcExchange"
    -- info.info.msg = "P0官方消息"
    info.info.msg = "nk.socket.HallSocket.hallBroadcast_:testNotify()P0官方消息"
    self:pushGameLabaMessage_(info)
end
--广播消息end---------------------------------------------------------------------------------------------
return HallBroadcast