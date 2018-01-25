-- 大厅界面
-- Author: KevinYu
-- Date: 2016-1-13 14:24:56

local MainHallView = class("MainHallView", function ()
    return display.newNode()
end)

local UserInfoPopup       = import("app.module.userInfo.UserInfoPopup")
local StorePopup          = import("app.module.newstore.StorePopup")
local FriendPopup         = import("app.module.friend.FriendPopup")
local FriendData          = import("app.module.friend.FriendData")
local RankingPopup        = import("app.module.newranking.RankingPopup")
local SettingAndHelpPopup = import("app.module.settingAndhelp.SettingAndHelpPopup")
local MessageView         = import("app.module.hall.message.MessageView")
local DailyTasksPopup     = import("app.module.dailytasks.DailyTasksPopup")
local InvitePopup         = import("app.module.friend.InvitePopup")
local MessageData         = import("app.module.hall.message.MessageData")
local ExchangeCodePop     = import("app.module.exchangecode.ExchangeCode")
local TutorialButton      = import("app.module.tutorial.TutorialButton")
local CrazedBoxPopup      = import("app.module.crazedbox.CrazedBoxPopup")
local PlayerbackPopup     = import("app.module.playerback.PlayerbackPopup")
local PushMsgPopup        = import("app.module.playerback.PushMsgPopup")
local PlayerbackModel     = import("app.module.playerback.PlayerbackModel")
local UserCrash           = import("app.module.room.userCrash.UserCrash")
local NewUserCrash        = import("app.module.room.userCrash.NewUserCrash")
local BubbleButton        = import("boomegg.ui.BubbleButton")
local LotteryPopup        = import("app.module.lottery.LotteryPopup")
local AvatarIcon          = import("boomegg.ui.AvatarIcon")
local CardActPopup        = import("app.module.newestact.CardActPopup")
local CardActPopupNew     = import("app.module.newestact.CardActPopupNew")
local ChooseRoomView      = import("app.module.hall.ChooseRoomView")
local ChooseLotteryView   = import("app.module.hall.ChooseLotteryView")

local ActivityCenterPopup = import("app.module.newestact.ActivityCenterPopup")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

MainHallView.TABLE_POS_TOP    = 1 -- 顶部
MainHallView.TABLE_POS_BOTTOM = 2 -- 底部

local MORE_CHIP_PANEL_HEIGHT = 186 -- 含义已经改变，是“砖块”的高度
local BRICK_WIDTH            = 179
local BRICK_HEIGHT           = 219

local BOTTOM_USER_INFO_WIDTH = 300 * nk.widthScale --个人信息按钮宽度

local BOTTOM_PANEL_HEIGHT    = 98
local AVATAR_TAG             = 100 -- 获取子节点时， 通过此tag查找 替换贴图
local BRICK_DISTANCE         = (display.width - BRICK_WIDTH * 4) * 2 / 5 / 3 + BRICK_WIDTH + 15

function MainHallView:ctor(controller, tablePos)
    self.controller_ = controller
    self.controller_:setDisplayView(self)
    self.tablePos_ = tablePos

    self:setNodeEventEnabled(true)
    nk.userData.dealerId = 1 --test
    self.controller_:getCurDealerId()

    --添加顶部操作区域
    self:addHalfTopNode_()

    -- 桌子
    local bgScale = self.controller_:getBgScale()

    self.pokerTable_ = display.newNode():addTo(self):scale(bgScale)
    local tableLeft = display.newSprite("#main_hall_table.png"):addTo(self.pokerTable_)
    tableLeft:setAnchorPoint(cc.p(1, 0.5))
    tableLeft:pos(2, 0)
    local tableRight = display.newSprite("#main_hall_table.png"):addTo(self.pokerTable_)
    tableRight:setScaleX(-1)
    tableRight:setAnchorPoint(cc.p(1, 0.5))
    tableRight:pos(-2, 0)

    --底部结点
    self.halfBottomNode_ = display.newNode()
        :addTo(self)

    --添加中间四个选项
    self:addMiddleOptionsNode_()

    -- 底部裁剪区域（显示更多筹码展开panel）
    local stencil = display.newDrawNode()
    stencil:drawPolygon({
            {-display.width * 0.5, -display.height * 0.5 + MORE_CHIP_PANEL_HEIGHT},
            {-display.width * 0.5, -display.height * 0.5},
            { display.width * 0.5, -display.height * 0.5},
            { display.width * 0.5, -display.height * 0.5 + MORE_CHIP_PANEL_HEIGHT}
        })
    self.panelClipNode_ = cc.ClippingNode:create()
        :addTo(self.halfBottomNode_, 3)
    self.panelClipNode_:setStencil(stencil)

    -- 底部背景
    self.bottomPanelNode_ = display.newNode()
        :addTo(self.halfBottomNode_)
    display.newScale9Sprite("#bottom_panel_bg.png", 0, 0, cc.size(display.width, BOTTOM_PANEL_HEIGHT))
        :pos(0, -display.cy + BOTTOM_PANEL_HEIGHT * 0.5)
        :addTo(self.bottomPanelNode_)
    display.newTilesSprite("repeat/panel_repeat_tex.png", cc.rect(0, 0, display.width, BOTTOM_PANEL_HEIGHT))
        :pos(-display.cx, -display.cy)
        :addTo(self.bottomPanelNode_)

    --添加用户信息结点
    self:addUserInfoNode_()

    --添加底部选项(商城，兑换，好友，排行榜)
    self:addBottomOptionsNode_()

    --比赛分享，暂时去掉
    -- self:createMatchShareAct()

    -- 头像加载id
    self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId()

    -- PlayerbackModel.getTaskData(function(data)
    --     if data then
    --         self:showPlayerBackBtn()
    --     end
    -- end)
    -- 
    self:addAnimationEffect_()

    -- 添加数据观察器
    self:addPropertyObservers()

     -- init analytics
    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:start("analytics.UmengAnalytics")
    end
    self:onTimerStart()
    --self:getActivityInfo()
end

--启动调度器
function MainHallView:onTimerStart()
    self.timer = scheduler.scheduleGlobal(function()
            self:onTimer()
        end,600.0)
end
--调度器执行函数
function MainHallView:onTimer()
    bm.HttpService.POST(
        {
            mod = "Online" ,
            act = "onlineCount"
         },
        function (data)
            local callData = json.decode(data)
            if callData.code == 1 then
                self.userOnline_:setString(bm.LangUtil.getText("HALL", "USER_ONLINE", callData.data.count))
            end
        end,
        function (data)
        end
        )
end
--关闭调度器
function MainHallView:onTimerEnd()
    -- body
    scheduler.unscheduleGlobal(self.timer)
end

function MainHallView:addAnimationEffect_()
    if not self.hallEffctMgr_ then
        self.allCardconfigs_ = {
            {"fla_zhujiemian_huodongA", "fla_zhujiemian_zipai_ADDITIVE", self.moreOptionsNode_},
            {nil, "fla_zhujiemian_hongpai_ADDITIVE", self.arenaCardNode_},
            {"fla_zhujiemian_lanpuke", "fla_zhujiemian_lanpai_ADDITIVE", py1 = - 5, py2 = - 2, scale1=1.0, self.ordinaryBtn_},
            {"fla_zhujiemian_lvpaiB", "fla_zhujiemian_lvpai_ADDITIVE", self.playNowNode_},
        }

        self.otherConfigs_ = {
            {armatureName="fla_zhujiemian_shangcheng_ADDITIVE", parent=self.storeNode_, py=5},
            {armatureName="fla_zhujiemian_haoyoui_ADDITIVE", parent=self.inviteBtn_, scale=1.11, py=10},
            -- {armatureName="fla_zhujiemian_free", parent=self.activityButton_, scale=1.1, py=-2--[[, func=handler(self, self.onNewActivity)]]},
        }
        self.hallEffctMgr_ = import("app.module.hall.HallEffectManager")
        self.hallEffctMgr_:addHallEffect(self.allCardconfigs_, self.otherConfigs_)
    end
end

function MainHallView:onEnter()
    nk.SoundManager:playBgMusic()
    nk.userData.inHall_ = true
end

function MainHallView:onExit()
    nk.SoundManager:stopBgMusic()
    nk.userData.inHall_ = false
end

function MainHallView:updateCrashBtn()
    if self.crashBtn_ then
        if nk.userData.money + nk.userData.bank_money >= appconfig.CRASHMONEY then
            self.crashBtn_:hide()
        else
            self.crashBtn_:show()
        end
        -- loginRewardStep为1标识有登录奖励可以领取，应隐藏破产补助图标
        if nk.userData.loginRewardStep and tostring(nk.userData.loginRewardStep) == "1" then
            self.crashBtn_:hide()
        end
    end
end

-- 入场动画
function MainHallView:playShowAnim(isAnimation)
    local animTime = self.controller_.getAnimTime()

    -- 桌子
    if self.tablePos_ == MainHallView.TABLE_POS_TOP then
        self.pokerTable_:pos(0, -55)
    else
        self.pokerTable_:pos(0, -(display.cy + 320))
    end

    -- 方块panel
    local posY = -(MORE_CHIP_PANEL_HEIGHT + BRICK_HEIGHT + 80)
    local posE_Y = -80
    local delayTime = 0.2
    local baseDelayTime = 0.05
    self.moreOptionsNode_:setPositionY(posY)
    self.ordinaryNode_:setPositionY(posY)
    self.arenaCardNode_:setPositionY(posY)
    self.playNowNode_:setPositionY(posY)
    -- 底部panel
    self.bottomPanelNode_:pos(0, -BOTTOM_PANEL_HEIGHT)
    -- 顶部panel
    self.halfTopNode_:pos(0, 240)

    if isAnimation then
        transition.moveTo(self.pokerTable_, {time = animTime, y = -(display.cy + 150)})
        transition.moveTo(self.moreOptionsNode_, {time = animTime, y = posE_Y, delay = delayTime + baseDelayTime * 2, easing = "BACKOUT"})
        transition.moveTo(self.ordinaryNode_, {time = animTime, y = posE_Y, delay = delayTime + baseDelayTime * 1, easing = "BACKOUT"})
        transition.moveTo(self.arenaCardNode_, {time = animTime, y = posE_Y, delay = delayTime + baseDelayTime * 0, easing = "BACKOUT"})
        transition.moveTo(self.playNowNode_, {time = animTime, y = posE_Y, delay = delayTime + baseDelayTime * 3, easing = "BACKOUT"})
        transition.moveTo(self.bottomPanelNode_, {time = animTime, y = 0, delay = delayTime})
        transition.moveTo(self.halfTopNode_, {time = animTime, y = 0, delay = delayTime, onComplete = handler(self, self.onPlayShowAnimCallBack)})
    end
    -- 推荐比赛
    self:recommendMatch()--暂时屏蔽
end

-- 出场动画
function MainHallView:playHideAnim()
    local animTime = self.controller_.getAnimTime()

    self.pokerTable_:removeFromParent()

    transition.moveTo(self.halfTopNode_, {time = animTime, y = 240})
    transition.moveTo(self.halfBottomNode_, {
        time = animTime * 0.5,
        y = -(MORE_CHIP_PANEL_HEIGHT + BRICK_HEIGHT),
        onComplete = handler(self, function (obj)
            obj:removeFromParent()
        end)
    })
    -- 移除汽包
    self:removeBubbleBtn()
end

-- 出场动画结束回调
function MainHallView:onPlayHideAnimCallBack()
    self.isPlayAnim_ = nil
end

-- 入场动画结束回调
function MainHallView:onPlayShowAnimCallBack()
    self.isPlayAnim_ = true
    --添加气泡
    -- self:addBubbleBtn()--暂时屏蔽
    self:addDailyLuckturnBtn()
    self:addBigRAddressBtn_()

    if self.hallEffctMgr_ then
        self.hallEffctMgr_:isOpenArenaLock()
    end

    -- if nk.PopupManager:isHasPopup() then
    if (nk.userData.loginReward and nk.userData.loginReward.ret and nk.userData.loginReward.ret == 1) or (nk.userData.loginRewardStep and nk.userData.loginRewardStep > 0) or nk.PopupManager:isHasPopup() then
        self.pengdingEndId_ = bm.EventCenter:addEventListener("PengdingPopup_End", handler(self, self.onPengdingPopupEndHandler_))
    else
        nk.schedulerPool:delayCall(function()
            nk.TutorialManager:startHallScene(self)
        end, 0.2)
    end
end
-- 
function MainHallView:onPengdingPopupEndHandler_()
    if self.pengdingEndId_ then
        bm.EventCenter:removeEventListener(self.pengdingEndId_)
    end
    -- 
    nk.schedulerPool:delayCall(function()
        nk.TutorialManager:startHallScene(self)
    end, 0.2)
end
-- 添加大R用户信息收集图标
function MainHallView:addBigRAddressBtn_()
    if nk.userData.isOpenBigR == 1 and nil == self.bigRBtn_ then
        local px, py = display.cx - 150, display.cy - 88 -70
        self.bigRBtn_ = BubbleButton.createCommonBtn({            
                iconNormalResId="bigR_ICON.png",
                parent=self.halfTopNode_,
                x=px,
                y=py,
                -- strokeColor=styles.FONT_COLOR.LIGHT_TEXT,
                onClick=function()
                    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                    local BigRAddressPopup = import("app.module.vip.BigRAddressPopup")
                    BigRAddressPopup.new():show()
                end,
            })
    end

    self:addOpenQuestBtn_()
    self:addCardActivityBtn_()
end
-- 检测大R
function MainHallView:checkBigRBtnStatus_()
    if nk.userData.isOpenBigR == 0 and self.bigRBtn_ then
        self.bigRBtn_:removeFromParent()
        self.bigRBtn_ = nil
    end
end
-- 添加大R用户信息收集图标
function MainHallView:addOpenQuestBtn_()
    if nk.userData.openQuestion == 1 and nil == self.questionBtn_ then
        local px, py = display.cx - 150 - 100, display.cy - 88 -70
        if self.bigRBtn_ then
            px = px + 100
        end
        self.questionBtn_ = BubbleButton.createCommonBtn({            
                iconNormalResId="Questionnaire_Icon.png",
                parent=self.halfTopNode_,
                x=px,
                y=py,
                -- strokeColor=styles.FONT_COLOR.LIGHT_TEXT,
                onClick=function()
                    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                    local QuestionnairePopup = import("app.module.questionnaire.QuestionnairePopup")
                    QuestionnairePopup.new():show()
                end,
            })
    end
end

-- 添加大R用户信息收集图标
function MainHallView:addCardActivityBtn_()
    if nk.userData.switchAct == 1 and nil == self.cardActivityBtn_ then
        display.addSpriteFrames("cardactivity_texture.plist","cardactivity_texture.png")
        local px, py = display.cx - 150 - 100, display.cy - 88 -70;
        if self.bigRBtn_ then
            px = px + 100
        end
        self.cardActivityBtn_ = BubbleButton.createCommonBtn({            
                iconNormalResId="#card_activity_start.png",
                parent=self.halfTopNode_,
                x=px,
                y=py,
                onClick=function()
                    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                    CardActPopup.new():show()
                end,
            })
    end
    if nk.userData.switchAct == 2 and nil == self.cardActivityBtn_ then
        display.addSpriteFrames("cardactivity_texture.plist","cardactivity_texture.png")
        local px, py = display.cx - 150 - 100, display.cy - 88 -70;
        if self.bigRBtn_ then
            px = px + 100
        end
        self.cardActivityBtn_ = BubbleButton.createCommonBtn({            
                iconNormalResId="#card_activity_start_new.png",
                parent=self.halfTopNode_,
                x=px,
                y=py,
                onClick=function()
                    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                    CardActPopupNew.new():show()
                end,
            })
    end
    if nk.userData.switchAct == 0 then
        if self.cardActivityBtn_ then
            self.cardActivityBtn_:hide()
        end
    end
end

-- 添加每日转盘图标
function MainHallView:addDailyLuckturnBtn()
    local isPlayDailyLuck = nk.OnOff:isPlayDailyLuck()
    if isPlayDailyLuck and self.dailyLuckturnBtn_ == nil then
        local px, py = BRICK_WIDTH + 10, 20
        self.dailyLuckturnBtn_ = BubbleButton.createCommonBtn({            
                iconNormalResId="#DailyLuckturn_Icon.png",
                parent=self.arenaCard_,
                x=px,
                y=py,
                -- strokeColor=styles.FONT_COLOR.LIGHT_TEXT,
                onClick=buttontHandler(self, self.onOpenDailyLuckturnPopup_),
            })
    end
end

function MainHallView:checkDailyLuckBtnStatus_()
    if not nk.OnOff:isPlayDailyLuck() and self.dailyLuckturnBtn_ then
        self.dailyLuckturnBtn_:removeFromParent()
    end
end

-- 筹码、黄金币变化
function MainHallView:onAddMoneyAnimation(evt)
    -- itype, value
    local evtData = evt.data
    if not evtData or not evtData.itype or not evtData.num or evtData.num == 0 then
        return
    end
    -- 
    local fontSize = 20
    local rect = self:getTargetIconPosition_(evtData.itype)
    app:tip(evtData.itype, evtData.num, rect.x, rect.y-20, 999, 0, fontSize, 0)
end

function MainHallView:onOpenDailyLuckturnPopup_()
    display.addSpriteFrames("luckturn_texture.plist", "luckturn_texture.png", function()
        local DailyLuckturnPopup = import("app.module.luckturn.DailyLuckturnPopup")
        DailyLuckturnPopup.new():show()
    end)
end

-- 添加汽包
function MainHallView:addBubbleBtn()
    if self.isPlayAnim_ and self.isOnOffLoad_ then
        if nk.MatchTickManager:getTickData() then
            self:onAddBubbleBtnCallback_()
        else
            self.onSynchTickId_ = bm.EventCenter:addEventListener(nk.MatchTickManager.EVENT_SYNCH_TICK, handler(self, self.onAddBubbleBtnCallback_))
        end
    end
end

function MainHallView:onAddBubbleBtnCallback_()
    if self.onSynchTickId_ then
        bm.EventCenter:removeEventListener(self.onSynchTickId_)
        self.onSynchTickId_ = nil
    end

    --添加气泡
    local tickList = nk.MatchTickManager:getOverdueTickList()
    if nk.userData.nextExpireTickets and nk.userData.nextExpireTickets > 0 and not self.bubbleBtn_ and not nk.userData.isShowed and tickList and #tickList > 0 then
        local px, py = self.playNowCard_:getPosition()
        self.bubbleBtn_ = BubbleButton.new({
            image = "#bubble_bg.png",
            color = styles.FONT_COLOR.GOLDEN_TEXT,
            outcolor = cc.c3b(0,0,0),
            outlineWidth = 1,
            x = px - 5,
            y = py + 150,
            lblOffDw = 30,
            offX = 10,
            offY = 4,
            size = cc.size(240, 90),
            scale9 = true,
            capInsets = cc.rect(35, 35, 5, 5),
            text = bm.LangUtil.getText("TICKET", "TICKET_NEXTOVERDATE"),
            fontSize = 24,
            prepare = function()

            end,
            listener = function()
                self:onOpenNextExpiredTickPopup()
            end,
        }):addTo(self.arenaCardNode_)
 
        self.bubbleBtn_:runAction(cc.RepeatForever:create(transition.sequence({
            cc.MoveBy:create(1.0, cc.p(0, 10)),
            cc.MoveBy:create(1.0, cc.p(0, -10)),
        })))
    else
        self:removeBubbleBtn()
    end
end

function MainHallView:onOpenNextExpiredTickPopup()
    nk.userData.isShowed = true 
    local MatchTickOverduePopup = import("app.module.match.MatchTickOverduePopup")
    MatchTickOverduePopup.new():show()

    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand{
            command = "eventCustom",
            args = {
                eventId = "hallBubble_tickoverdue_click",
                attributes = "type,hallBubble_tickoverdue",
                counter = 1
            }
        }
    end
    -- 移除气泡
    self:removeBubbleBtn()
end

-- 移除汽包
function MainHallView:removeBubbleBtn()
    if self.bubbleBtn_ then
        self.bubbleBtn_:stopAllActions()
        self.bubbleBtn_:removeFromParent()
        self.bubbleBtn_ = nil
    end
end

function MainHallView:onInviteBtnClick()
    bm.EventCenter:dispatchEvent({name=nk.TutorialManager.EVENT_CLICK_NAME, data=nk.TutorialManager.INVITE_FRIEND_TAG})

    self.inviteBtn_:setButtonEnabled(false)
    nk.schedulerPool:delayCall(function()
        self.inviteBtn_:setButtonEnabled(true)
    end, 0.5)
    self:openInvitePopup_()  
end

function MainHallView:openInvitePopup_()
    nk.reportClickEvent(8)
    InvitePopup.new():show()
    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand {
            command = "event",
            args = {eventId = "hall_Invite_friends"},
            label = "user hall_Invite_friends"
        }
     end
end

function MainHallView:onArenaClick()


    nk.reportClickEvent(3)
    bm.EventCenter:dispatchEvent({name=nk.TutorialManager.EVENT_CLICK_NAME, data=nk.TutorialManager.ARENACARD_TAG})

    if nk.userData.openMatch and tonumber(nk.userData.openMatch)==1 then
        self.controller_:onEnterMatch()
        -- -- 上报召回用户进入竞技场的统计事件
        if device.platform == "android" or device.platform == "ios" then
            if self.playedMatchGuideAnim then
                self.playedMatchGuideAnim = false
                cc.analytics:doCommand {
                    command = "event",
                    args = {eventId = "recall_guide_to_match_enter"},
                    label = "recall_guide_to_match_enter"
                }
            end
        end

        if device.platform == "android" or device.platform == "ios" then
            cc.analytics:doCommand{
                command = "event",
                args = {eventId = "hall_click_match"},
                label = "user hall_click_match"
            }
        end
    else
        nk.ui.Dialog.new({
            messageText = bm.LangUtil.getText("ROOM", "SERVER_UPGRADE_MSG"),
            hasFirstButton = false,
        }):show()
    end
end

-- 普通场 (竞技场房间和两张场房间)
function MainHallView:onOrdinaryHallClick()
    print("paipaiapanskjfsk")
    if self.chooseRoomModal_ then
        self.chooseRoomModal_:removeFromParent()
        self.chooseRoomModal_ = nil
        if self.chooseRoomPanelNode_ then
            self.chooseRoomPanelNode_:removeFromParent()
            self.chooseRoomPanelNode_ = nil
        end
        for i = 1, #self.middleNodes do 
            transition.moveTo(self.middleNodes[i], {time = 0.08, y = -80})
        end
    else
        self:addChooseRoomOptionsView_()
    end
    bm.EventCenter:dispatchEvent({name=nk.TutorialManager.EVENT_CLICK_NAME, data=nk.TutorialManager.ROOMCARD_TAG})

    nk.reportClickEvent(4)
end

-- 快速开始
function MainHallView:onPlayNowClick()
    bm.EventCenter:dispatchEvent({name=nk.TutorialManager.EVENT_CLICK_NAME, data=nk.TutorialManager.PLAYNOWCARD_TAG})
    nk.reportClickEvent(5)
    self.controller_:getEnterRoomData(nil, true)
    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand{
            command = "event",
            args = {eventId = "play_now_enter_room"},
            label = "user play_now_enter_room"
        }
    end
end

function MainHallView:onModalTouch_(target, evt)
    if evt == bm.TouchHelper.CLICK then
        if self.moreChipModal_ then
            nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
            self.moreChipModal_:removeFromParent()
            self.moreChipModal_ = nil

            if self.moreChipPanelNode_ then
                self.moreChipPanelNode_:removeFromParent()
                self.moreChipPanelNode_ = nil
            end
        end
    end
end

function MainHallView:onModal2Touch_(target, evt)
    if evt == bm.TouchHelper.CLICK then
        if self.chooseRoomModal_ then
            nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
            self.chooseRoomModal_:removeFromParent()
            self.chooseRoomModal_ = nil
            if self.chooseRoomPanelNode_ then
                self.chooseRoomPanelNode_:removeFromParent()
                self.chooseRoomPanelNode_ = nil
            end
            for i = 1, #self.middleNodes do 
                transition.moveTo(self.middleNodes[i], {time = 0.08, y = -80})
            end
        end
    end
end

--宝箱点击
function MainHallView:onCrazedBoxClick(target, evt)
    if evt == bm.TouchHelper.TOUCH_BEGIN then
        self.crazedBoxPressed_:show()
    elseif evt == bm.TouchHelper.TOUCH_END then
        self.crazedBoxPressed_:hide()
    elseif evt == bm.TouchHelper.CLICK then
        self.crazedBoxPressed_:hide()
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
        CrazedBoxPopup.new():show()
        if self.moreChipModal_ then
            self.moreChipModal_:removeFromParent()
            self.moreChipModal_ = nil
            self.moreChipPanelNode_:removeFromParent()
        end
    end
end

-- 奖励兑换
function MainHallView:onExchangeClick(target, evt)
    if evt == bm.TouchHelper.TOUCH_BEGIN then
        self.exchangePressed_:show()
    elseif evt == bm.TouchHelper.TOUCH_END then
        self.exchangePressed_:hide()
    elseif evt == bm.TouchHelper.CLICK then
        self.exchangePressed_:hide()
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
        nk.PopupManager:addPopup(ExchangeCodePop.new())
        if self.moreChipModal_ then
            self.moreChipModal_:removeFromParent()
            self.moreChipModal_ = nil
            self.moreChipPanelNode_:removeFromParent()
        end
    end
end

-- 彩票
function MainHallView:onLotteryClick(target, evt)
    if evt == bm.TouchHelper.TOUCH_BEGIN then
        self.lotteryPressed_:show()
    elseif evt == bm.TouchHelper.TOUCH_END then
        self.lotteryPressed_:hide()
    elseif evt == bm.TouchHelper.CLICK then
        self.lotteryPressed_:hide()
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
        ChooseLotteryView.new():showPanel()
        if self.moreChipModal_ then
            self.moreChipModal_:removeFromParent()
            self.moreChipModal_ = nil
            self.moreChipPanelNode_:removeFromParent()
        end
    end
end

-- 幸运转盘
function MainHallView:onLuckyWheelClick(target, evt)
    if evt == bm.TouchHelper.TOUCH_BEGIN then
        self.luckyWheelPressed_:show()
    elseif evt == bm.TouchHelper.TOUCH_END then
        self.luckyWheelPressed_:hide()
    elseif evt == bm.TouchHelper.CLICK then
        self.luckyWheelPressed_:hide()
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
        
        local HallController = import("app.module.hall.HallController")
        local LuckWheelFreePopup = import("app.module.luckturn.LuckWheelFreePopup")
        LuckWheelFreePopup.load(self.controller_, HallController.MAIN_HALL_VIEW)
        -- 
        if self.moreChipModal_ then
            self.moreChipModal_:removeFromParent()
            self.moreChipModal_ = nil
            self.moreChipPanelNode_:removeFromParent()
        end
    end
end

--老虎机
function MainHallView:onSlotClick(target, evt)
    if evt == bm.TouchHelper.TOUCH_BEGIN then
        self.slotPressed_:show()
    elseif evt == bm.TouchHelper.TOUCH_END then
        self.slotPressed_:hide()
    elseif evt == bm.TouchHelper.CLICK then
        self.slotPressed_:hide()
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)

        self.controller_:showSlotPopup()

        if self.moreChipModal_ then
            self.moreChipModal_:removeFromParent()
            self.moreChipModal_ = nil
            self.moreChipPanelNode_:removeFromParent()
        end
    end
end

function MainHallView:addPropertyObservers()
    if not self.onAddMoneyAnimationId_ then
        self.onAddMoneyAnimationId_ =  bm.EventCenter:addEventListener("onAddMoneyAnimationEvent", handler(self, self.onAddMoneyAnimation))
    end

    self.dailyLuckDrawId_ = bm.EventCenter:addEventListener("DailyLuckDraw", handler(self, self.checkDailyLuckBtnStatus_))
    self.playChipChangeAnimationId_ = bm.EventCenter:addEventListener("Play_ChipChangeAnimation", handler(self, self.onPlayChipChangeAnimation_))

    self.nickObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "nick", handler(self, function (obj, nick)
        obj.nick_:setString(nk.Native:getFixedWidthText("", 24, nick, 200))
    end))

    self.avatarUrlObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "s_picture", handler(self, function (obj, s_picture)
        if not s_picture or string.len(s_picture) <= 5 then
            if nk.userData.sex == "f" then
                self.avatarIcon_:setSpriteFrame("common_female_avatar.png")
            else
                self.avatarIcon_:setSpriteFrame("common_male_avatar.png")
            end
        else
            local imgurl = s_picture
            if string.find(imgurl, "facebook") then
                if string.find(imgurl, "?") then
                    imgurl = imgurl .. "&width=200&height=200"
                else
                    imgurl = imgurl .. "?width=200&height=200"
                end
            end
            self.avatarIcon_:loadImage(imgurl)
        end

    end))
    self.userOnlineObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "USER_ONLINE", handler(self, function (obj, userOnline)
        obj.userOnline_:setString(bm.LangUtil.getText("HALL", "USER_ONLINE", bm.formatNumberWithSplit(userOnline)))
    end))

    self.onNewMessageDataObserver = bm.DataProxy:addDataObserver(nk.dataKeys.NEW_MESSAGE, handler(self, self.messagePoint))

    self.onNewFriendDataObserver = bm.DataProxy:addDataObserver(nk.dataKeys.NEW_FRIEND_DATA, handler(self, self.friendPoint))

    if not self.onOffLoadId_ then
        self.onOffLoadId_ = bm.EventCenter:addEventListener("OnOff_Load", handler(self, self.onOffLoadCallback_))
    end
    -- 添加事件监听
    nk.UserInfoChangeManager:reg(nk.UserInfoChangeManager.MainHall, {"money","score", "gameCoupon", "goldCoupon","hddj", "gcoins", "kick"}, handler(self, self.getTargetIconPosition_), handler(self,self.onRefreshMoney_))
    self:onRefreshMoney_()

    self.moneyObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "money", handler(self, function(obj, userMoney)
        self:onRefreshMoney_()
    end))

    self.scoreObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "score", handler(self, function(obj, userScore)
        self:onRefreshMoney_()
    end))

    self.bigRObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "isOpenBigR", handler(self, function(obj, userMoney)
        self:checkBigRBtnStatus_()
    end))

    self.onNewRewardTaskObserver = bm.DataProxy:addDataObserver(nk.dataKeys.NEW_REWARD_TASK, handler(self, self.onNewRewardTask))
    self.onNewRewardAchieveObserver = bm.DataProxy:addDataObserver(nk.dataKeys.NEW_REWARD_ACHIEVE, handler(self, self.onNewRewardTask))

    self.onNewAcvitityObserver = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "newActReward", handler(self, self.onNewActivity))

    self.onGotoOrdinaryHallEvent = bm.EventCenter:addEventListener("onGotoOrdinaryHallEvent", handler(self, self.onOrdinaryHallClick))
    self.onGotoActivityCenterEvent = bm.EventCenter:addEventListener("onGotoActivityCenterEvent", handler(self, self.onOpenActivityClick_))
end

function MainHallView:getActivityInfo()
    local retryTimes = 3

    local getInofo = function()
        -- body
        bm.HttpService.POST(
        {
            --请求是否活动弹窗
        },
        function (data)
            local callData = json.decode(data)
            if callData then 
                if callData.code == 1 then
                    self:onGotoActivityCenter(callData.data.image,callData.data.text)--未绑定显示绑定界面
                end
            end
        end,
        function (data)
            retryTimes = retryTimes - 1
            if retryTimes > 0 then
                getInofo()
            end
        end
        )
    end
    
    getInofo()
end

function MainHallView:onGotoActivityCenter(image,text)
    local activityTitle = import("app.module.activity.ActivityTitle")
    activityTitle.new(image,text):show()
end

function MainHallView:onNewRewardTask(hasNewRewardTask)
    if self.dailyTaskButton_ then
        if hasNewRewardTask then
            local light_node = self.dailyTaskButton_.light
            if not light_node then
                light_node = display.newSprite("#daily_task_btn_new.png"):pos(0, 4):addTo(self.dailyTaskButton_)
                self.dailyTaskButton_.light = light_node
            end
            light_node:stopAllActions()
            light_node:show()
            light_node:setScale(1.1)
            light_node:runAction(cc.RepeatForever:create(transition.sequence({
                    cc.FadeOut:create(0.6),
                    cc.FadeIn:create(0.6),
                })))
        else
            local light_node = self.dailyTaskButton_.light
            if light_node then
                light_node:stopAllActions()
                light_node:hide()
            end
        end
    end
end

function MainHallView:onNewActivity()
    if self.activityButton_ then
        if nk.userData.newActReward and nk.userData.newActReward == 0 then
            local light_node = self.activityButton_.light
            if not light_node then
                light_node = display.newSprite("#new_activity_btn_new.png"):pos(0, 4):addTo(self.activityButton_)
                self.activityButton_.light = light_node
            end
            light_node:stopAllActions()
            light_node:show()
            light_node:setScale(1.1)
            light_node:runAction(cc.RepeatForever:create(transition.sequence({
                    cc.FadeOut:create(0.6),
                    cc.FadeIn:create(0.6),
                })))
        else
            local light_node = self.activityButton_.light
            if light_node then
                light_node:stopAllActions()
                light_node:hide()
            end
        end
    end
end

function MainHallView:onNewActPopTip()
    -- body
    if self.actCenterPopBtn_ then
        if nk.userData.newActTip and nk.userData.newActTip == 0 then
            local light_node = self.actCenterPopBtn_.light
            if not light_node then
                light_node = display.newSprite("#hall_btnActivityCenterPop_hili.png"):pos(0, 4):addTo(self.actCenterPopBtn_)
                self.actCenterPopBtn_.light = light_node
            end
            light_node:stopAllActions()
            light_node:show()
            light_node:setScale(1.1)
            light_node:runAction(cc.RepeatForever:create(transition.sequence({
                    cc.FadeOut:create(0.6),
                    cc.FadeIn:create(0.6),
                })))
        else
            local light_node = self.actCenterPopBtn_.light
            if light_node then
                light_node:stopAllActions()
                light_node:hide()
            end
        end
    end
end

function MainHallView:messagePoint(hasNewMessage)
    if hasNewMessage then
        self.newMessagePoint:show()
    else
        self.newMessagePoint:hide()
    end
end

function MainHallView:friendPoint(hasNewMessage)
    if hasNewMessage then
        self.newFriendPoint:show()
    else
        self.newFriendPoint:hide()
    end
end

function MainHallView:onUserInfoBtnClicked()
    if self.isUserInfoClick_ then
        return
    end
    self.isUserInfoClick_ = true
    nk.schedulerPool:delayCall(function()
        self.isUserInfoClick_ = false
    end, 0.5)
    UserInfoPopup.new():show(false)
end

function MainHallView:onPlayerbackClick()
    PlayerbackPopup.new(function(action)
            if action == "playnow" then
                self.controller_:getEnterRoomData(param, true)
            elseif action == "gotoChoseRoomView" then
                self.controller_:showChooseRoomView(param)
            elseif action == "gotoArenaRoomView" then
                self.controller_:onEnterMatch()
            elseif action == "gotoCheckMatchTicket" then
                self:openUserInfoMatchTicket(param)
            elseif action == "openExchange" then
                self:onExchangeBtnClicked()
            end
        end):show()
end

function MainHallView:openUserInfoMatchTicket()
    local pop = UserInfoPopup.new()
    pop:onOpenPropClick_()
    pop:onItemEvent_({name="ITEM_EVENT", type="SEE_PROP"})
    pop:show(false)
end

function MainHallView:onOpenActivityClick_()
    print("点击了")
    -- if nk.ByActivity then
    --     nk.ByActivity:display()
    -- end

    --local activityPopup = import("app.module.activity.ActivityPopup")
    --activityPopup.new():show()

    local activityPopup = import("app.module.login.plugins.ByActivityPlugin").new()
    activityPopup:display()
end

function MainHallView:onDailyTaskClick()
    DailyTasksPopup.new():show()
    nk.reportClickEvent(7)
end

--旧版活动中心，对性能有所影响，反正不用了暂时注释掉
--[[function MainHallView:onActCenterPopClk_()
    -- body
    ActivityCenterPopup.new():show()
    
    nk.reportClickEvent(6)
    nk.reportToDAdmin("activitycenter", "activitycenter=1")
end]]--

function MainHallView:onStoreBtnClicked()
    bm.EventCenter:dispatchEvent({name=nk.TutorialManager.EVENT_CLICK_NAME, data=nk.TutorialManager.STORE_TAG})
    StorePopup.new():showPanel()
    nk.reportClickEvent(9)
end

function MainHallView:processCrash_(times, subsidizeChips, phpCrashChips,waitTime)
    local userCrash = UserCrash.new(times,subsidizeChips,phpCrashChips,waitTime)
    userCrash:show()
end

function MainHallView:onUserCrashBtnClicked()
    bm.HttpService.POST({mod="Broke", act="check",
            uphillPouring = 0, 
            playground = 0},
            function(data)
                local jsonData = json.decode(data)  

                if jsonData.newbie and jsonData.newbie == 1 then 
                    self:newCrashHandle_(jsonData)
                else
                    if jsonData and jsonData.money and jsonData.waiteTime then
                        self:processCrash_(times, 0, jsonData.money,jsonData.waiteTime)
                    else
                        self:processCrash_(times, 0, 0 ,0)
                    end
                end
            end,
            function()
                self:processCrash_(times, 0, 0)
            end)
end

--新版破产处理
function MainHallView:newCrashHandle_(data)
    if data.ret == 1 then --可以领取
        NewUserCrash.new(1, data.reward):show()
    elseif data.ret == -1 then --已经超过3次
        NewUserCrash.new(2, nk.userData.inviteBackReward):show()
    end
end

function MainHallView:onFriendBtnClicked()
    bm.EventCenter:dispatchEvent({name=nk.TutorialManager.EVENT_CLICK_NAME, data=nk.TutorialManager.FRIEND_TAG})
    FriendPopup.new():show()
    nk.reportClickEvent(11)
end

function MainHallView:onRankingBtnClicked()
    bm.EventCenter:dispatchEvent({name=nk.TutorialManager.EVENT_CLICK_NAME, data=nk.TutorialManager.RANK_TAG})

    self.controller_:reportCurTotalMoney()
    self.rankingRewardPoint:hide()

    nk.reportToDAdmin("RankList", "rankingClicked=count")
    RankingPopup.new():show()
    nk.reportClickEvent(12)  
end

function MainHallView:onExchangeBtnClicked()
    bm.EventCenter:dispatchEvent({name=nk.TutorialManager.EVENT_CLICK_NAME, data=nk.TutorialManager.EXCHANGE_TAG})

    local HallController = import("app.module.hall.HallController")
    local ScoreMarketView = import("app.module.scoremarket.ScoreMarketViewExt")
    ScoreMarketView.load(self.controller_, HallController.MAIN_HALL_VIEW)
    nk.reportClickEvent(10)
end

--更多按钮点击
function MainHallView:onMoreOptionsClicked_()
    bm.EventCenter:dispatchEvent({name=nk.TutorialManager.EVENT_CLICK_NAME, data=nk.TutorialManager.MORECARD_TAG})
    -- 
    if self.moreChipModal_ then
        self.moreChipModal_:removeFromParent()
        self.moreChipModal_ = nil
        if self.moreChipPanelNode_ then
            self.moreChipPanelNode_:removeFromParent()
            self.moreChipPanelNode_ = nil
        end
        if self.chooseRoomPanelNode_ then
            self.chooseRoomPanelNode_:removeFromParent()
            self.chooseRoomPanelNode_ = nil
        end
    else
        --添加更多选项视图
        self:addMoreOptionsView_()
        nk.reportClickEvent(2)
        if device.platform == "android" or device.platform == "ios" then
            cc.analytics:doCommand{
                command = "event",
                args = {eventId = "hall_click_free"},
                label = "user hall_click_free"
            }
        end
    end
end

--添加更多选项视图
function MainHallView:addMoreOptionsView_()
    -- 更多筹码模态
    self.moreChipModal_ = display.newScale9Sprite("#modal_texture.png", 0, 0, cc.size(display.width, display.height))
        :addTo(self.halfBottomNode_, 2)
    bm.TouchHelper.new(self.moreChipModal_, handler(self, self.onModalTouch_))

    -- 操作栏移出动画
    self.moreChipPanelNode_ = display.newNode()
        :pos(0, - display.cy + MORE_CHIP_PANEL_HEIGHT * 1.5)
        :addTo(self.panelClipNode_)
    self.moreChipPanelNode_:setTouchEnabled(true)
    self.moreChipPanelNode_:moveTo(0.08, display.left, - display.cy + MORE_CHIP_PANEL_HEIGHT * 0.5)

    self.moreOptionsNode_:setLocalZOrder(1)
    self.ordinaryNode_:setLocalZOrder(1)

    -- 背景
    local h = 120
    local arrow_W = 47 --箭头图片宽度
    display.newScale9Sprite("#hall_more_panel_bg.png", 0, 0, cc.size(display.width, h))
        :pos(0, -45)
        :addTo(self.moreChipPanelNode_)

    display.addSpriteFrames("crazed_box_texture.plist", "crazed_box_texture.png")

    local index = {0, 1, 2, 3, 4}
    local optionsNum = 5
    local isAddExchangeBtn = true

    if BM_UPDATE.SHOWEXCHANGE and BM_UPDATE.SHOWEXCHANGE == 0 then
        isAddExchangeBtn = false
        index = {0, 1, 1, 2, 3}
        optionsNum = optionsNum - 1
    end

    local dis = 20 --距离最左边的间隔
    local touch_w = (display.width - dis * 2) / optionsNum --更多选项中 按钮的宽度
    self.touchSize_ = cc.size(touch_w, 120) --更多选项中 按钮的大小
    self.more_options_item_x = -display.cx + self.touchSize_.width * 0.5 + dis --按钮起始位置

    --宝箱奖励
    self.crazedBoxPressed_ = self:createButton_(
        "#copper_box_icon.png",
        bm.LangUtil.getText("HALL", "OPEN_BOX"),
        index[1], handler(self, self.onCrazedBoxClick), true, -22)

    --彩票
    self.lotteryPressed_ = self:createButton_(
        "#boyaa_lottery_icon.png", 
        bm.LangUtil.getText("LOTTERY", "TITLE"),
        index[2], handler(self, self.onLotteryClick), true, -22)    

    --奖励兑换
    if isAddExchangeBtn then
        self.exchangePressed_ = self:createButton_(
            "#daily_bonus_icon.png",
            bm.LangUtil.getText("ECODE", "TITLE"),
            index[3], handler(self, self.onExchangeClick), true, -22)
    end
        
    --老虎机
    local slot_X = self.more_options_item_x + touch_w * index[4]
    self.slotPressed_ = self:createButton_(
        "#hall_slot_btn.png", 
        bm.LangUtil.getText("HALL", "SLOT"),
        index[4], handler(self, self.onSlotClick), true, -22) 
    display.newSprite("#hall_more_btn_new.png")
            :pos(slot_X - 64, 12 - 22)
            :addTo(self.moreChipPanelNode_) 

    --幸运转盘
    self.luckyWheelPressed_ = self:createButton_(
        "#lucky_wheel_icon.png", 
        bm.LangUtil.getText("HALL", "LUCKY_WHEEL"),
        index[5], handler(self, self.onLuckyWheelClick), true, -22)
end

--添加房间类型选项视图
function MainHallView:addChooseRoomOptionsView_()
    -- 更多筹码模态
    self.chooseRoomModal_ = display.newScale9Sprite("#modal_texture.png", 0, 0, cc.size(display.width, display.height))
        :addTo(self.halfBottomNode_, 2)
    bm.TouchHelper.new(self.chooseRoomModal_, handler(self, self.onModal2Touch_))

    -- 操作栏移出动画
    self.chooseRoomPanelNode_ = display.newNode()
        :pos(0, - display.cy - MORE_CHIP_PANEL_HEIGHT * 1.5)
        :addTo(self.panelClipNode_)
    self.chooseRoomPanelNode_:setTouchEnabled(true)
    self.chooseRoomPanelNode_:moveTo(0.08, display.left, - display.cy + MORE_CHIP_PANEL_HEIGHT * 0.5)

    self.moreOptionsNode_:setLocalZOrder(1)
    self.ordinaryNode_:setLocalZOrder(3)

    for i = 1, #self.middleNodes do 
        transition.moveTo(self.middleNodes[i], {time = 0.08, y = -20})
    end

    -- 背景
    local bg_ = display.newSprite("#hall_choose_room_panel_bg.png")
        :pos(0, 0)
        :addTo(self.chooseRoomPanelNode_)
    bg_:setScaleX(display.width/960)

    

    local itemContent = {
        {index = 4, img = "#hall_choose_room_img_normal.png",id = self.controller_.CHOOSE_NOR_VIEW},
        {index = 5, img = "#hall_choose_room_img_pro.png",id = self.controller_.CHOOSE_PRO_VIEW},
        {index = 3, img = "#hall_choose_room_img_4k.png",id = self.controller_.CHOOSE_4K_VIEW},
        {index = 2, img = "#hall_choose_room_img_5k.png",id = self.controller_.CHOOSE_5K_VIEW},
        {index = 1, img = "#hall_choose_room_img_coin_room.png",id = self.controller_.CHOOSE_PRO_VIEW,isCoin = true},
    }

    local dis = 0 --距离最左边的间隔
    local touch_w = (display.width - dis * 2) / #itemContent --更多选项中 按钮的宽度
    local options_item_x = -display.cx + touch_w * 0.5 + dis --按钮起始位置
    local offset_y = -16
    local buttons  = {}
    for i = 1,#itemContent do 
        buttons[i] = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#hall_choose_room_img_pressed.png"}, {scale9 = true})
            :setButtonSize(touch_w, 164)
            :pos(options_item_x + touch_w * (itemContent[i].index - 1), offset_y)
            :addTo(self.chooseRoomPanelNode_)
            :onButtonClicked(function(evt)
                    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                    self:onHallChooseRoomClick(itemContent[i].id,itemContent[i].isCoin)
                end)
        display.newSprite(itemContent[i].img):pos(0, 4):addTo(buttons[i])
        if itemContent[i].index ~= #itemContent then
            display.newSprite("#hall_choose_room_panel_divide.png"):pos(touch_w * 0.5, 0):addTo(buttons[i])
        end
        buttons[i]:setTouchSwallowEnabled(false)
    end

    if nk.userData.level < 1 then
        self:getMaskNode(nk.userData.fourlevel):addTo(buttons[3])
        buttons[3]:removeEventListenersByEvent("CLICKED_EVENT")
        buttons[3]:onButtonClicked(function(evt)
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL", "ROOM_4K_LIMIT_TIPMSG", nk.userData.fourlevel))
            end)
    end

    if nk.userData.level < nk.userData.fivelevel then
        self:getMaskNode(nk.userData.fivelevel):pos(10,0):addTo(buttons[4])
        buttons[4]:removeEventListenersByEvent("CLICKED_EVENT")
        buttons[4]:onButtonClicked(function(evt)
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL", "ROOM_5K_LIMIT_TIPMSG", nk.userData.fivelevel))
            end)
    end

    -- buttons[5]:removeEventListenersByEvent("CLICKED_EVENT")
    -- buttons[5]:onButtonClicked(function(evt)
    --         self.controller_:getEnterDiceData(self)
    --     end)

    if nk.userData.level < nk.userData.dicelevel then
        self:getMaskNode(nk.userData.dicelevel):pos(10,0):addTo(buttons[5])
        buttons[5]:removeEventListenersByEvent("CLICKED_EVENT")
        buttons[5]:onButtonClicked(function(evt)
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL", "ROOM_DICE_LIMIT_TIPMSG", nk.userData.dicelevel))
            end)
    end

    if nk.userData.diceOnoff and nk.userData.diceOnoff == 0 then
        self:getMaskNode(-1):pos(10,0):addTo(buttons[5])
        buttons[5]:removeEventListenersByEvent("CLICKED_EVENT")
        buttons[5]:onButtonClicked(function(evt)
            nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL", "MODIFING"))
        end)
    end
end

function MainHallView:getMaskNode(level)
    local maskNode = display.newNode()
    display.newSprite("#levle_lock.png"):pos(-8,20):addTo(maskNode):setScale(0.6)
    if level == -1 then
        return maskNode
    end
    local leveltitle = display.newSprite("#level_lblBG.png")
    local leveltext = display.newSprite("#level_" .. tonumber(level) .. ".png")
    local bgwidth = leveltitle:getContentSize().width + leveltext:getContentSize().width + 20
    local levelbg = display.newScale9Sprite("#level_bg.png", 0, 0, cc.size(bgwidth, 36))
        :pos(-8,-32)
        :addTo(maskNode)
    levelbg:setScale(0.8)
    leveltitle:pos(leveltitle:getContentSize().width /2 + 10,levelbg:getContentSize().height / 2):addTo(levelbg)
    leveltext:pos(levelbg:getContentSize().width - leveltext:getContentSize().width -3,levelbg:getContentSize().height/2 ):addTo(levelbg)
    return maskNode
end

-- 普通场 (竞技场房间和两张场房间)
function MainHallView:onHallChooseRoomClick(type_,isCoin)
    self.controller_:showChooseRoomView(type_ or nk.userData.lastChooseRoomType or self.controller_.CHOOSE_PRO_VIEW,nil,isCoin)
    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand{
            command = "event",
            args = {eventId = "nor_enter_room"}, label = "user nor_enter_room"
        }
    end
    if type_ == self.controller_.CHOOSE_NOR_VIEW then
        nk.reportClickEvent(13)
    elseif type_ == self.controller_.CHOOSE_PRO_VIEW then
        nk.reportClickEvent(14)
    elseif type_ == self.controller_.CHOOSE_4K_VIEW then
        nk.reportClickEvent(15)
    elseif type_ == self.controller_.CHOOSE_5K_VIEW then
        nk.reportClickEvent(16)
    end

    if self.chooseRoomModal_ then
        self.chooseRoomModal_:removeFromParent()
        self.chooseRoomModal_ = nil
        self.chooseRoomPanelNode_:removeFromParent()

        for i = 1, #self.middleNodes do 
            transition.moveTo(self.middleNodes[i], {time = 0.08, y = -80})
        end
    end
end

function MainHallView:createButton_(image, text, index, callback, isHaveLine, offset_y)
    local touchSize = self.touchSize_
    local x = self.more_options_item_x + touchSize.width * index
    local pressed = display.newSprite("#act_button_pressed.png", x, -26 + offset_y):addTo(self.moreChipPanelNode_):hide()
    local icon = display.newSprite(image):pos(x, -18 + offset_y):addTo(self.moreChipPanelNode_)
    local touch = display.newScale9Sprite("#transparent.png", x, -18 + offset_y, touchSize):addTo(self.moreChipPanelNode_)
    local size = icon:getContentSize()

    bm.TouchHelper.new(touch, callback)
   
    ui.newTTFLabel({text = text, color = styles.FONT_COLOR.LIGHT_TEXT, size = 24, align = ui.TEXT_ALIGN_CENTER})
            :pos(x, -57 + offset_y)
            :addTo(self.moreChipPanelNode_)

    if index > 0 then
        display.newSprite("#panel_more_split_line.png")
            :pos(0, touchSize.height/2)
            :addTo(touch)
    end
    
    return pressed
end

function MainHallView:onMessageBtnClicked()
    MessageView.new():show()
end

function MainHallView:onSettingBtnClicked()
    local thisTime = bm.getTime()
    if not buyBtnLastClickTime or math.abs(thisTime - buyBtnLastClickTime) > 1 then
        buyBtnLastClickTime = thisTime
        SettingAndHelpPopup.new():show()
    end
end

function MainHallView:onOffCallback()
end

function MainHallView:removePropertyObservers()
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "isOpenBigR", self.bigRObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "nick", self.nickObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "money", self.moneyObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "score", self.scoreObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "s_picture", self.avatarUrlObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "USER_ONLINE", self.userOnlineObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "__user_discount", self.discountObserverHandle_)
    bm.DataProxy:removeDataObserver(nk.dataKeys.NEW_MESSAGE, self.onNewMessageDataObserver)
    bm.DataProxy:removeDataObserver(nk.dataKeys.NEW_REWARD_TASK, self.onNewRewardTaskObserver)
    bm.DataProxy:removeDataObserver(nk.dataKeys.NEW_REWARD_ACHIEVE, self.onNewRewardAchieveObserver)
    bm.DataProxy:removeDataObserver(nk.dataKeys.USER_DATA, "newActReward", self.onNewAcvitityObserver)
    bm.DataProxy:removeDataObserver(nk.dataKeys.NEW_FRIEND_DATA, self.onNewFriendDataObserver)

    bm.EventCenter:removeEventListener(self.dailyLuckDrawId_)
    bm.EventCenter:removeEventListener(self.playChipChangeAnimationId_)
    bm.EventCenter:removeEventListener(self.onAddMoneyAnimationId_)
    -- 

    if self.onOffLoadId_ then
        bm.EventCenter:removeEventListener(self.onOffLoadId_)
        self.onOffLoadId_ = nil
    end
end

function MainHallView:onCleanup()
    self:onTimerEnd()
    nk.SoundManager:stopBgMusic()
    nk.TutorialManager:clean()
    self:removePropertyObservers()
    nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
    nk.UserInfoChangeManager:unReg(nk.UserInfoChangeManager.MainHall)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "sex", self.sexObserverHandle_)
    if self.recommendMatchLoaderId_ then
        nk.ImageLoader:cancelJobByLoaderId(self.recommendMatchLoaderId_)
        self.recommendMatchLoaderId_ = nil
    end
    -- 
    if self.hallEffctMgr_ then
        self.hallEffctMgr_:clean()
        self.hallEffctMgr_ = nil
    end
    
end

function MainHallView:onOffLoadCallback_()
    --是否显示昨日冠军奖励提示
    if nk.userData.yesterdayReward and nk.userData.yesterdayReward > 0 then
        self.rankingRewardPoint:show()
    else
        self.rankingRewardPoint:hide()
    end

    self.isOnOffLoad_ = true
    -- self:addBubbleBtn()
    if nk.userData.fourk == 1 and self.icon_4k then
        self.icon_4k:show()
    end

    nk.config.HALLOWEEN_ENABLED = nk.OnOff:check("conduct")
    nk.config.SONGKRAN_ACTIVITY_ENABLED = nk.OnOff:check("sgjact")
    nk.config.FIVE_ANNIVERSARY_ACTIVITY = nk.OnOff:check("five_anniversary_act")
    nk.config.POKER_ACTIVITY_ENABLED = nk.OnOff:check("playact")
    nk.config.RICHMAN_SCORE = nk.OnOff:check("billions")

    if nk.config.POKER_ACTIVITY_ENABLED then
        display.addSpriteFrames("poker_activity_texture.plist", "poker_activity_texture.png",function()
            end)
    end

    if nk.config.RICHMAN_SCORE then
        display.addSpriteFrames("richman_score_texture.plist","richman_score_texture.png")
        display.addSpriteFrames("richman_score_other_texture.plist","richman_score_other_texture.png")
    end

    -- self:createMatchShareAct()

    --yk 新版VIP以后，不需要调用了
    if self:isSynchPhpTickList_() then
        nk.MatchTickManager:synchPhpTickList()
    end

    self.avatarIcon_:renderVIP()
    self:addBigRAddressBtn_()

    -- 推荐比赛
    self:recommendMatch()
end

--yk
function MainHallView:isSynchPhpTickList_()
    local isVip = false
    local vipconfig = nk.OnOff:getConfig('vipmsg')
    local vipconfig_2 = nk.OnOff:getConfig('newvipmsg')

    if vipconfig_2 and vipconfig_2.newvip == 1 then
        return false
    end

    if vipconfig and vipconfig.awardmsg and vipconfig.awardmsg.msg and vipconfig.awardmsg.code == 0 and not vipconfig.showed then
        return true
    end

    return false
end

function MainHallView:showPlayerBackBtn()
    if self.playerbackBtn then
        self.playerbackBtn:show()
    else
        self.playerbackBtn = cc.ui.UIPushButton.new({normal = "plaerback_icon.png"})
            :pos(display.cx - 60,0)
            :onButtonClicked(buttontHandler(self,self.onPlayerbackClick))
            :addTo(self.halfTopNode_)
    end
end

function MainHallView:createMatchShareAct()
    if nk.userData.openMatchShareAct==1 and not self.scoreAwardShareBtn_ then
        self.scoreAwardShareBtn_ = cc.ui.UIPushButton.new({normal = "share_score_award_btn.png"})
            :addTo(self.halfTopNode_)
            :pos(display.cx - 150, display.cy - 88 -70)
            :onButtonClicked(function(evt)
                    nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
                    display.addSpriteFrames("matchShareAct.plist", "matchShareAct.png", function()
                        local MatchShareActPop = import 'app.module.match.MatchShareActPop'
                        MatchShareActPop.new():show()
                    end
                    )
                end)
        nk.setScaleBtn(self.scoreAwardShareBtn_)
    end
end

function MainHallView:getTargetIconPosition_(itype)
    local rect
    if itype == 1 then      -- 筹码
        rect = self.bottomPanelNode_:convertToWorldSpace(cc.p(self.moneyIcon_:getPosition()))
    elseif itype == 9 then  -- 黄金币
        rect = self.scoreIcon_:getParent():convertToWorldSpace(cc.p(self.scoreIcon_:getPosition()))
    elseif itype == 7 then  -- 互动道具
        rect = self.avatarIcon_:getParent():convertToWorldSpace(cc.p(self.avatarIcon_:getPosition()))
    else
        rect = self.avatarIcon_:getParent():convertToWorldSpace(cc.p(self.avatarIcon_:getPosition()))
    end

    return rect
end

function MainHallView:onRefreshMoney_(itype)
    if not self.lastMoney_ or tonumber(self.lastMoney_) == tonumber(nk.userData.money) then
        self.money_:setString(bm.formatNumberWithSplit(nk.userData.money))
    else
        bm.blinkTextTarget(self.money_, bm.formatNumberWithSplit(nk.userData.money))
    end

    if not self.lastGold_ or tonumber(self.lastGold_) == tonumber(nk.userData.gcoins) then
        self.gold_:setString(bm.formatNumberWithSplit(nk.userData.gcoins))
    else
        bm.blinkTextTarget(self.gold_, bm.formatNumberWithSplit(nk.userData.gcoins))
    end

    self.lastMoney_ = nk.userData.money
    self.lastGold_ = nk.userData.gcoins

    self:updateCrashBtn()
end

function MainHallView:recommendMatch()
    if not nk.userData.popup then
        return
    end

    local img = nk.userData and nk.userData.sponsor and nk.userData.sponsor.img
    if not img or img=="" then
        return
    end

    local index = string.find(img,"http://")
    local index1 = string.find(img,"https://")
    if not index and not index1 then
        img = (nk.userData.cdn or "")..""..img
    end

    local width,height = 100,100
    local halfWidth,halfHeight = width/2,height/2
    if not self.recommendMatchBtn_ then
        self.recommendMatchBtn_ = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png"},{scale9 = true})
            :setButtonSize(width, height)
            :addTo(self.halfTopNode_)
            :pos(display.cx - 60 - 80,display.cy - 80 - 80)
            :onButtonClicked(function(evt)
                    nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
                    local MatchActivityPopup = import("app.module.match.MatchActivityPopup")
                    MatchActivityPopup.new():show()

                    if device.platform == "android" or device.platform == "ios" then
                        cc.analytics:doCommand{command = "event",
                                    args = {eventId = "RecommandMatchIcon_Click_Count"}, label = tostring(nk.userData.uid or 0)}
                    end
                end)
        nk.setScaleBtn(self.recommendMatchBtn_)

        local posX,posY = halfWidth,halfHeight
        local rect = self.recommendMatchBtn_:convertToWorldSpace(cc.p(0,0))

        self.recommendMatchIcon_ = display.newNode()
            -- :size(width,height)
            :addTo(self.recommendMatchBtn_)
            :pos(0, 0)

        self.defaultMatchIcon_ = display.newSprite("#NewLogin_Loading.png")
            :addTo(self.recommendMatchIcon_)
        local texSize = self.defaultMatchIcon_:getContentSize()
        local xxScale = width/texSize.width
        local yyScale = height/texSize.height
        self.defaultMatchIcon_:scale(xxScale<yyScale and xxScale or yyScale)
    end
    if img then
        nk.ImageLoader:cancelJobByLoaderId(self.recommendMatchLoaderId_)
        self.recommendMatchLoaderId_ = nk.ImageLoader:nextLoaderId()
        local iconContainer = self.recommendMatchIcon_
        local defaultIcon = self.defaultMatchIcon_
        local iconLoader = self.recommendMatchLoaderId_
        nk.ImageLoader:loadAndCacheImage(iconLoader,
            img,
            function(success, sprite)
                if success then
                    local tex = sprite:getTexture()
                    local texSize = tex:getContentSize()
                    local oldAvatar = iconContainer:getChildByTag(999)
                    if oldAvatar then
                        oldAvatar:removeFromParent()
                    end
                    local iconSize = iconContainer:getContentSize()
                    local xxScale = iconSize.width/texSize.width
                    local yyScale = iconSize.height/texSize.height
                    sprite:scale(xxScale<yyScale and xxScale or yyScale)
                        :addTo(iconContainer, 0, 999)
                    
                    iconContainer:show()
                    defaultIcon:hide()
                else
                    
                end
            end,
            nk.ImageLoader.CACHE_TYPE_GIFT
        )
    end
end

function MainHallView:onPlayChipChangeAnimation_(evt)
    if evt.data then
        if tostring(evt.data) == "3" then
        else
            if self.avatarChangeAnimation_ then
                self.avatarChangeAnimation_:show()
                self:performWithDelay(function ()
                    self.avatarChangeAnimation_:hide()
                end, 1.2)
            end
        end
    else
    end
end

function MainHallView:addHalfTopNode_()
    self.halfTopNode_ = display.newNode()
        :addTo(self)

    local x = display.cx - 180

    -- 在线人数
    self.userOnline_ = ui.newTTFLabel({text = bm.LangUtil.getText("HALL", "USER_ONLINE", "9,999"), color = cc.c3b(0xb3, 0xca, 0xff), size = 26, align = ui.TEXT_ALIGN_CENTER})
        :pos(x, display.cy - 30)
        :addTo(self.halfTopNode_)

    -- 邀请好友
    self.inviteBtn_ = cc.ui.UIPushButton.new({normal = "#invite_btn_normal.png", pressed = "#invite_btn_pressed.png"}, {scale9 = true})
        :pos(x, display.cy - 80)
        :onButtonClicked(buttontHandler(self, self.onInviteBtnClick))
        :addTo(self.halfTopNode_, 1, nk.TutorialManager.INVITE_FRIEND_TAG)

    local titleX = -95
    local inviteTitle = ui.newTTFLabel({
            text = bm.LangUtil.getText("HALL", "INVITE_FRIEND"),
            size = 20,
            color = cc.c3b(0xff, 0xf7, 0xdd)
        }):align(display.LEFT_CENTER, titleX, 0):addTo(self.inviteBtn_)
    bm.fitSprteWidth(inviteTitle, 256)

    local titileSize = inviteTitle:getContentSize()

    if nk.OnOff:check("fbInviteDoubleReward") then
        --todo
        local inviteRewardIcon = display.newSprite("#invite_icRewAdd.png")
        inviteRewardIcon:pos(titileSize.width + titleX + inviteRewardIcon:getContentSize().width / 2 + 10, 0)
            :addTo(self.inviteBtn_)
    else
        local inviteReward = ui.newTTFLabel({
            text = nk.userData.inviteBackReward,
            size = 20,
            color = cc.c3b(0xff, 0xcd1, 0x4b)
            }):align(display.LEFT_CENTER, titileSize.width + titleX + 5, 0):addTo(self.inviteBtn_)
        bm.fitSprteWidth(inviteReward, 256)
    end

    --添加最新动态
    self:addNewInformationNode_()

    --新手教程
    if nk.config.TUTORIAL_ENABLED then
        local tutorialMarginTop = display.cy - 88 - 36
        TutorialButton.new():addTo(self.halfTopNode_):pos(display.cx - 150, tutorialMarginTop - 64/2)
    end
end

--添加最新动态
function MainHallView:addNewInformationNode_()
    local frame = display.newScale9Sprite("#transparent.png", 0, 0, cc.size(300, 130))
        :align(display.LEFT_CENTER, - display.cx + 35, display.cy - 88)
        :addTo(self.halfTopNode_)

    local size = frame:getContentSize()
    -- local txtWidth = 100

    --以下代码为老版活动中心，现摒弃采用公司统一接口
    --local px, py = size.width * 0.84, size.height * 0.5
    
    --[[self.actCenterPopBtn_ = BubbleButton.createCommonBtn({            
        iconNormalResId = "#hall_btnActivityCenterPop_nor.png",
        parent = frame,
        x = px,
        y = py,
        isBtnScale9 = true, 
        -- txtString=bm.LangUtil.getText("HALL", "FREE_CHIPS"),
        -- strokeColor=styles.FONT_COLOR.LIGHT_TEXT,
        onClick = buttontHandler(self, self.onActCenterPopClk_)
    })]]--

    --self.actCenterPopBtn_:setVisible(false)

    local px, py = size.width * 0.5, size.height*0.5

    self.dailyTaskButton_ = BubbleButton.createCommonBtn({            
            iconNormalResId = "#daily_task_btn_normal.png",
            parent = frame,
            x = px,
            y = py,
            isBtnScale9 = true, 
            -- fontSize=18,
            -- txtString=bm.LangUtil.getText("HALL", "DAILY_MISSION"),
            -- strokeColor=styles.FONT_COLOR.LIGHT_TEXT,
            onClick = buttontHandler(self, self.onDailyTaskClick),
            isSave = true
        })

    px, py = size.width * 0.16, size.height * 0.5

    self.activityButton_ = BubbleButton.createCommonBtn({            
            iconNormalResId = "#new_activity_btn_normal.png",
            parent = frame,
            x = px,
            y = py,
            isBtnScale9 = true, 
            -- txtString=bm.LangUtil.getText("HALL", "FREE_CHIPS"),
            -- strokeColor=styles.FONT_COLOR.LIGHT_TEXT,
            onClick = buttontHandler(self, self.onMoreOptionsClicked_)
        })

    self:onNewActivity()
end


--添加中间四个选项
function MainHallView:addMiddleOptionsNode_()
    local bgY = display.cy * 0.23
    local offset_w, offset_h = 0, 0
    -- 更多选项 小游戏大转盘，宝箱，兑换码等 替代以前下方的活动按钮
    local bgX = BRICK_DISTANCE * -1.5
    self.moreOptionsNode_ = display.newNode():pos(bgX, -bgY):addTo(self.halfBottomNode_, 3, nk.TutorialManager.MORECARD_TAG)
    local btn = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png",pressed = "#rounded_rect_10.png"},{scale9 = true})
        :setButtonSize(BRICK_WIDTH + offset_w, BRICK_HEIGHT + offset_h)
        :addTo(self.moreOptionsNode_)
        :onButtonClicked(buttontHandler(self, self.onOpenActivityClick_))
    self.moreCard_ = display.newSprite("#more_options_brick_btn_bg.png"):addTo(btn, -200)

    -- 比赛场
    bgX = bgX + BRICK_DISTANCE
    self.arenaCardNode_ = display.newNode():pos(bgX, -bgY):addTo(self.halfBottomNode_, 1, nk.TutorialManager.ARENACARD_TAG)
    btn = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
        :setButtonSize(BRICK_WIDTH + offset_w, BRICK_HEIGHT + offset_h)
        :addTo(self.arenaCardNode_)
        :onButtonClicked(buttontHandler(self, self.onArenaClick))
    self.arenaCard_ = display.newSprite("#arena_room_brick_btn_bg.png"):pos(0, -2):addTo(btn, -200)

    -- 普通场 (竞技场房间和两张场房间)
    bgX = bgX + BRICK_DISTANCE
    self.ordinaryNode_ = display.newNode():pos(bgX, -bgY):addTo(self.halfBottomNode_, 1, nk.TutorialManager.ROOMCARD_TAG)
    self.ordinaryBtn_ = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
        :setButtonSize(BRICK_WIDTH + offset_w, BRICK_HEIGHT + offset_h)
        :addTo(self.ordinaryNode_)
        :onButtonClicked(buttontHandler(self, self.onOrdinaryHallClick))
    self.roomCard_ = display.newSprite("#ordinary_room_brick_btn_bg.png"):pos(0, -2):addTo(self.ordinaryBtn_, -200)
    local sz = self.roomCard_:getContentSize()
    self.icon_4k = display.newSprite("#ordinary_room_brick_btn_icon.png")
        :align(display.LEFT_TOP, -0.5*sz.width + 13, 0.5*sz.height - 15)
        :addTo(self.ordinaryBtn_,99)
        :hide()
    if nk.userData.fourk == 1 then
        self.icon_4k:show()
    end

    -- 快速开始
    bgX = bgX + BRICK_DISTANCE
    self.playNowNode_ = display.newNode():pos(bgX, -bgY):addTo(self.halfBottomNode_, 1, nk.TutorialManager.PLAYNOWCARD_TAG)
    btn = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
        :setButtonSize(BRICK_WIDTH + offset_w, BRICK_HEIGHT + offset_h)
        :addTo(self.playNowNode_)
        :onButtonClicked(buttontHandler(self, self.onPlayNowClick))
    self.playNowCard_ = display.newSprite("#play_now_brick_btn_bg.png"):addTo(btn, -200)

    self.diceBtn_ = cc.ui.UIPushButton.new({normal = "#hall_choose_room_img_hilo_icon.png", pressed = "#hall_choose_room_img_hilo_icon.png"})
        :pos(display.cx - 60, display.cy - 80 - 80)
        :addTo(self.halfTopNode_)
        :onButtonClicked(function(evt)
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                if self.chooseOpen_ then
                    return
                end
                self.chooseOpen_ = true
                nk.schedulerPool:delayCall(function()
                    self.chooseOpen_ = false
                end, 0.3)
                self:onHallChooseRoomClick(self.controller_.CHOOSE_DICE_VIEW)
            end)

    cc.ui.UIPushButton.new({normal = "#hall_choose_room_img_pdeng_icon.png", pressed = "#hall_choose_room_img_pdeng_icon.png"})
        :pos(display.cx - 150, display.cy - 80 - 80)
        :addTo(self.halfTopNode_)
        :onButtonClicked(function(evt)
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                if self.chooseOpen_ then
                    return
                end
                self.chooseOpen_ = true
                nk.schedulerPool:delayCall(function()
                    self.chooseOpen_ = false
                end, 0.3)
                self:onHallChooseRoomClick(self.controller_.CHOOSE_PDENG_VIEW)
            end)

    if nk.userData.homeluckwheel and nk.userData.homeluckwheel == 1 then
        display.addSpriteFrames("newWheel.plist", "newWheel.png", function()
            --新转盘
            local newWheelBtn = cc.ui.UIPushButton.new({normal = "#icon.png", pressed = "#icon.png"})
                :pos(display.cx - 240, display.cy - 80 - 80)
                :addTo(self.halfTopNode_)
                :onButtonClicked(function(evt)
                        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                        if self.chooseOpen_ then
                            return
                        end
                        self.chooseOpen_ = true
                        nk.schedulerPool:delayCall(function()
                            self.chooseOpen_ = false
                        end, 0.3)
                                        
                        local HallController = import("app.module.hall.HallController")
                        local HallWheelPopup = import("app.module.luckturn.view.HallWheelPopup")
                        HallWheelPopup.load(self.controller_, HallController.MAIN_HALL_VIEW)
                    end)

            local iconLight = display.newSprite("#light.png"):pos(-1.5, 5.5):addTo(newWheelBtn)
            iconLight:setAnchorPoint(cc.p(0.5, 0.5))
            iconLight:runAction(cc.RepeatForever:create(transition.sequence({
                    cc.FadeIn:create(0.1),
                    cc.DelayTime:create(1),
                    cc.FadeOut:create(0.1),
                    cc.DelayTime:create(1),
                })))
        end)
    end

    if nk.userData.waterLampProps and nk.userData.waterLampProps == 1 then
        display.addSpriteFrames("waterLamp/waterLamp_texture.plist", "waterLamp/waterLamp_texture.png", function()
            --新转盘
            local newWheelBtn = cc.ui.UIPushButton.new({normal = "#waterLampIcon1.png", pressed = "#waterLampIcon1.png"})
                :pos(display.cx - 260, display.cy - 160)
                :addTo(self.halfTopNode_)
                :onButtonClicked(function(evt)
                        local waterLampPopup = import("app.module.waterLamp.waterLampPopup")
                        waterLampPopup.new():show()
                    end)

            local iconLight = display.newSprite("#waterLampIcon2.png"):addTo(newWheelBtn)
            iconLight:setAnchorPoint(cc.p(0.5, 0.5))
            iconLight:runAction(cc.RepeatForever:create(transition.sequence({
                    cc.FadeIn:create(0.1),
                    cc.DelayTime:create(1),
                    cc.FadeOut:create(0.1),
                    cc.DelayTime:create(1),
                })))
        end)
    end

    nk.setScaleBtn(self.diceBtn_)
    self.middleNodes = {self.moreOptionsNode_, self.arenaCardNode_, self.ordinaryNode_, self.playNowNode_}
end

--添加用户信息结点
function MainHallView:addUserInfoNode_()
    -- 用户信息按钮
    self.userInfoBtn_ = cc.ui.UIPushButton.new({
            normal = "#common_transparent_skin.png",
            pressed = "#bottom_panel_pressed_bg.png"}, {scale9 = true})
        :setButtonSize(BOTTOM_USER_INFO_WIDTH, BOTTOM_PANEL_HEIGHT - 2)
        :pos(-display.cx + BOTTOM_USER_INFO_WIDTH * 0.5, -display.cy + BOTTOM_PANEL_HEIGHT * 0.5 - 3)
        :addTo(self.bottomPanelNode_)
        :onButtonClicked(buttontHandler(self, self.onUserInfoBtnClicked))

    -- 默认头像
    local idw, idh = 82, 82
    local px, py = -display.cx + 12 + idw * 0.5, -display.cy + BOTTOM_PANEL_HEIGHT * 0.5 - 2
    self.avatarIcon_ = AvatarIcon.new("#common_male_avatar.png", idw, idh, 6, nil, 1, 16)
        :align(display.LEFT_CENTER, px, py)
        :addTo(self.bottomPanelNode_, 0, AVATAR_TAG)
    self.avatarChangeAnimation_ = display.newSprite("#buyin-action-yellowbackground.png")
        :align(display.LEFT_CENTER, px-50, py-0)
        :addTo(self.bottomPanelNode_, 999, 999)
    self.avatarChangeAnimation_:hide()

    px, py = -display.cx + 110, -display.cy + BOTTOM_PANEL_HEIGHT - 24
    self.genderIcon_ = display.newSprite("#pop_userinfo_sex_male.png")
        :scale(0.75)
        :align(display.LEFT_CENTER, px + 2, py)
        :addTo(self.bottomPanelNode_)
        
    -- 昵称
    local offx = 35
    px = px + offx
    self.nick_ = ui.newTTFLabel({text = "", color = styles.FONT_COLOR.LIGHT_TEXT, size = 24, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER, px, py)
        :addTo(self.bottomPanelNode_)

    -- 筹码
    px, py = -display.cx + 110, -display.cy + BOTTOM_PANEL_HEIGHT - 55

    self.moneyIcon_ = display.newSprite("#chip_icon.png")
        :align(display.LEFT_CENTER, px, py + 1)
        :scale(0.78)
        :addTo(self.bottomPanelNode_)
    px = px + offx
    self.money_ = ui.newTTFLabel({text = "", color = cc.c3b(0xff, 0xc9, 0x50), size = 24, align = ui.TEXT_ALIGN_CENTER})

        :align(display.LEFT_CENTER, px, py)
        :addTo(self.bottomPanelNode_)
    self.chipChangeAnimation_ = display.newSprite("#buyin-action-yellowbackground.png")
        :align(display.LEFT_CENTER, px, py)
        :addTo(self.bottomPanelNode_, 99, 99)
    self.chipChangeAnimation_:hide()

    -- 黄金币
    py = py - 29
    px = -display.cx + 111
    self.scoreIcon_ = display.newSprite("#common_gcoin_icon.png")
        :scale(0.85)
        :align(display.LEFT_CENTER, px - 2, py)
        :addTo(self.bottomPanelNode_)
    px = px + offx
    self.gold_ = ui.newTTFLabel({
            text=bm.formatNumberWithSplit(nk.userData.gcoins),
            color=cc.c3b(0xc5, 0x44, 0x54),
            size=24,
        })

        :align(display.LEFT_CENTER, px, py)
        :addTo(self.bottomPanelNode_)
    self.scoreChangeAnimation_ = display.newSprite("#buyin-action-yellowbackground.png")
        :align(display.LEFT_CENTER, px, py)
        :addTo(self.bottomPanelNode_, 99, 99)
    self.scoreChangeAnimation_:hide()

    self.crashBtn_ = cc.ui.UIPushButton.new(
            {
                normal = "#common_transparent_skin.png"
            },
            { scale9 = true}
        )
        :setButtonSize(80, 86)
        :pos(-display.cx + 104 + 150, -display.cy + BOTTOM_PANEL_HEIGHT - 56)
        :addTo(self.bottomPanelNode_)
        :onButtonClicked(buttontHandler(self, self.onUserCrashBtnClicked))
        :hide()
    display.newSprite("#hall_user_crash_btn.png")
        :scale(0.6)
        :addTo(self.crashBtn_)
    self:updateCrashBtn()

    -- 性别
    self.sexObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "sex", function (sex)
        if sex == "f" then
            self.selectedGender_ = "f"
            self.genderIcon_:setSpriteFrame(display.newSpriteFrame("pop_userinfo_sex_female.png"))
        else
            self.selectedGender_ = "m"
            self.genderIcon_:setSpriteFrame(display.newSpriteFrame("pop_userinfo_sex_male.png"))
        end
    end)
end

--添加底部选项(商城，兑换，好友，排行榜)
function MainHallView:addBottomOptionsNode_()
    local mcy = -display.cy + BOTTOM_PANEL_HEIGHT * 0.5 + 5
    local BOTTOM_RIGHT_BTN_BLANK = 32 * nk.widthScale --消息按钮与左边 间隔空白区域宽度
    local BOTTOM_RIGHT_BTN_BOX_W = 50 -- 消息 设置 按钮的大小 与给的图片宽度一样

    -- 判读是否隐藏兑换商城
    local index = {0, 1, 2, 3} --按钮位置
    local btnNum = 4
    local isAddExchangeBtn = true
    if BM_UPDATE.MATCHMALL and BM_UPDATE.MATCHMALL == 0 then
        isAddExchangeBtn = false
        btnNum = 3
        index = {0, 0, 1, 2}
    end

    -- 中间添加按钮 可用宽度
    local last_w = display.width - BOTTOM_USER_INFO_WIDTH - BOTTOM_RIGHT_BTN_BOX_W * 3.5 - BOTTOM_RIGHT_BTN_BLANK
    self.bottmBtnWidth_ = last_w / btnNum
    self.bottmBtnS_x = -display.cx + BOTTOM_USER_INFO_WIDTH + self.bottmBtnWidth_ * 0.5
    local text_color = cc.c3b(0x7e, 0x7a, 0x7a)
    
    -- 商城按钮 transparent.png
    self.storeNode_ = self:addBottomOptionButton_(
        "#store_btn_up.png", 
        "#store_btn_down.png",
        "#bottom_panel_pressed_bg.png",
        bm.LangUtil.getText("HALL", "STORE_BTN_TEXT"),
        cc.c3b(0xff, 0xf8, 0xc0),
        index[1],
        nk.TutorialManager.STORE_TAG,
        buttontHandler(self, self.onStoreBtnClicked))

    -- 判读是否隐藏兑换商城
    if isAddExchangeBtn then
        --兑换按钮
        self:addBottomOptionButton_(
            "#hall_exchange_btn_up.png",
            "#hall_exchange_btn_down.png",
            "#bottom_panel_pressed_bg.png",
            bm.LangUtil.getText("HALL", "EXCHANGE_BTN_TEXT"),
            text_color,
            index[2],
            nk.TutorialManager.EXCHANGE_TAG,
            buttontHandler(self, self.onExchangeBtnClicked))
    end

    -- 好友按钮
    self:addBottomOptionButton_(
        "#friend_btn_up.png",
        "#friend_btn_down.png",
        "#bottom_panel_pressed_bg.png",
        bm.LangUtil.getText("HALL", "FRIEND_BTN_TEXT"),
        text_color,
        index[3],
        nk.TutorialManager.FRIEND_TAG,
        buttontHandler(self, self.onFriendBtnClicked))

    --有新好友数据标记
    local friBtnX = self.bottmBtnS_x + self.bottmBtnWidth_ * index[3]
    self.newFriendPoint = display.newSprite(nk.userData.motherDayRedNodePath)
        :pos(friBtnX + 38, mcy + 25)
        :addTo(self.bottomPanelNode_, 1)
    if FriendData.hasNewMessage then
        self.newFriendPoint:show()
    else
        self.newFriendPoint:hide()
    end

    -- 排行按钮
    local rankBtnX = self.bottmBtnS_x + self.bottmBtnWidth_ * index[4]
    self:addBottomOptionButton_(
        "#ranking_btn_up.png",
        "#ranking_btn_down.png",
        "#bottom_panel_pressed_bg.png",
        bm.LangUtil.getText("HALL", "RANKING_BTN_TEXT"),
        text_color,
        index[4],
        nk.TutorialManager.RANK_TAG,
        buttontHandler(self, self.onRankingBtnClicked))

    --有奖励标记
    self.rankingRewardPoint = display.newSprite(nk.userData.motherDayRedNodePath)
        :pos(rankBtnX + 38, mcy + 25)
        :hide()
        :addTo(self.bottomPanelNode_, 1)

    -- 消息按钮
    local left_border = display.width / 2
    
    local mx2 = left_border - BOTTOM_RIGHT_BTN_BOX_W * 3 + 10
    local my2 = mcy - 5
    local settingBg = display.newScale9Sprite("#bottom_setting_message_bg.png", left_border - BOTTOM_RIGHT_BTN_BOX_W * 2, my2, cc.size(160, 71))
        :addTo(self.bottomPanelNode_)

    display.newScale9Sprite("#panel_split_line.png", 80, 35, cc.size(2, 35)):addTo(settingBg)

    cc.ui.UIPushButton.new({normal = "#message_btn_up.png", pressed = "#message_btn_down.png"})
        :pos(mx2, my2)
        :onButtonClicked(buttontHandler(self, self.onMessageBtnClicked))
        :addTo(self.bottomPanelNode_)

    --有新消息标记
    self.newMessagePoint = display.newSprite(nk.userData.motherDayRedNodePath)
        :pos(mx2 + 38, my2 + 25)
        :addTo(self.bottomPanelNode_)
    if MessageData.hasNewMessage then
        self.newMessagePoint:show()
    else
        self.newMessagePoint:hide()
    end

    -- 设置按钮
    local mx3 = left_border - BOTTOM_RIGHT_BTN_BOX_W - 10
    cc.ui.UIPushButton.new({normal = "#setting_btn_up.png", pressed = "#setting_btn_down.png"})
        :pos(mx3, my2)
        :onButtonClicked(buttontHandler(self, self.onSettingBtnClicked))
        :addTo(self.bottomPanelNode_)
end

--添加底部选项
function MainHallView:addBottomOptionButton_(normalImg, pressedImg, bgImg, btnName, color, index, tag, callback)  
    local x = self.bottmBtnS_x + index * self.bottmBtnWidth_
    local node_ = display.newNode():addTo(self.bottomPanelNode_, 1, tag):pos(x, -display.cy + BOTTOM_PANEL_HEIGHT * 0.5 + 5)
    local bg, split, store_bg
    local btn = cc.ui.UIPushButton.new({normal = normalImg, pressed = pressedImg})
        :onButtonPressed(function()
            bg:show()
            if split then
                split:hide()
            end

            if store_bg then
                store_bg:hide()
            end

            if node_.effect then
                node_.effect:hide()
            end
        end)
        :onButtonRelease(function()
            bg:hide()
            if split then
                split:show()
            end

            if store_bg then
                store_bg:show()
            end

            if node_.effect then
                node_.effect:show()
            end
        end)
        :onButtonClicked(function()
            local thisTime = bm.getTime()
            if not LastClickTime or math.abs(thisTime - LastClickTime) > 1 then
                LastClickTime = thisTime
                callback()
            end
        end)
        

    local size = btn:getCascadeBoundingBox().size

    bg = display.newScale9Sprite(bgImg, 0, -8, cc.size(self.bottmBtnWidth_ + 2, BOTTOM_PANEL_HEIGHT - 2))
        :addTo(node_)
        :hide()
    btn:addTo(node_)

    ui.newTTFLabel({
        text = btnName,
        color = color,
        size = 28,
        align = ui.TEXT_ALIGN_CENTER})
        :pos(0, -40)
        :addTo(btn)

    --加了分割线，按钮和分割线组成的区域就是 点击范围  这是quick的优化
    split = display.newScale9Sprite("#panel_split_line.png", 0, 0, cc.size(2, 50))
        :pos(self.bottmBtnWidth_ * 0.5 + 1, 0)
        :addTo(btn)

    if index == 0 then
        display.newScale9Sprite("#panel_split_line.png", 0, 0, cc.size(2, 50))
            :pos(-self.bottmBtnWidth_ * 0.5, 0)
            :addTo(btn)
    end

    return node_
end

function MainHallView:getTutorialNode(tag)
    local node = self.halfBottomNode_:getChildByTag(tag)
    if node then
        return node
    end

    node = self.bottomPanelNode_:getChildByTag(tag)
    if node then
        return node
    end

    node = self.halfTopNode_:getChildByTag(tag)
    if node then
        return node
    end

    return nil
end

return MainHallView