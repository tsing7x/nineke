-- 比赛场 选场界面
--
-- Author: davidxifeng@gmail.com
-- Date: 2015-06-26 16:21:35
local LoadMatchControl      = import("app.module.match.LoadMatchControl")
local FirstPayPopup         = import("app.module.firstpay.FirstPayPopup")
local GuidePayPopup         = import("app.module.firstpay.GuidePayPopup")
local UserInfoPopup         = import('app.module.userInfo.UserInfoPopup')
local ArenaRoomChip         = import ('.ArenaRoomChip')
local ArenaApplyPopup       = import ('app.module.hall.arena.ArenaApplyPopup')
local InvitePopup           = import("app.module.friend.InvitePopup")
local AvatarIcon            = import("boomegg.ui.AvatarIcon")
local MatchModel            = import ('app.module.match.MatchModel')
local MatchManager          = import ('app.module.match.MatchManager')
local MatchEventHandler     = import("app.module.match.MatchEventHandler")
local MatchBillDetailPopup  = import("app.module.match.bill.MatchBillDetailPopup")
local TitleBtnGroup         = import("app.module.room.views.TitleBtnGroup")
local BubbleButton          = import("boomegg.ui.BubbleButton")
local ScrollAnimationIcons  = import("boomegg.ui.ScrollAnimationIcons")
local HallController        = import("app.module.hall.HallController")
local LuckWheelScorePopup   = import("app.module.luckturn.LuckWheelScorePopup")

local ChooseArenaRoomView = class("ChooseArenaRoomView", function ()
    return display.newNode()
end)

local TOP_BUTTOM_WIDTH   = 78
local TOP_BUTTOM_HEIGHT  = 64
local TOP_BUTTOM_PADDING = 8

local AVATAR_TAG             = 100 -- 获取子节点时， 通过此tag查找 替换贴图
local CHIP_Y = display.cy - 110
local CHIP_GAP_X = 300 * nk.widthScale
local AVATART_DW, AVATAR_DH = 50, 50
local INIT_AVATAR_PX = 30
local TOP_PARTDW, TOP_PARTDH = 360, 107 -- 两边的宽度、高

function ChooseArenaRoomView:onCleanup()
    self:cleanQuestContent_()    
    self.matchManager_:onExitMatch()
    if self.onlineListenerId_ then
        bm.EventCenter:removeEventListener(self.onlineListenerId_)
        self.onlineListenerId_ = nil
    end
    if self.cancelRegMatchId_ then
        bm.EventCenter:removeEventListener(self.cancelRegMatchId_)
        self.cancelRegMatchId_ = nil
    end
    if self.matchTimeChangeId_ then
        bm.EventCenter:removeEventListener(self.matchTimeChangeId_)
        self.matchTimeChangeId_ = nil
    end
    -- 
    if self.regListenerId_ then
        bm.EventCenter:removeEventListener(self.regListenerId_)
        self.regListenerId_ = nil
    end

    if self.useTickId_ then
        bm.EventCenter:removeEventListener(self.useTickId_)
        self.useTickId_ = nil
    end
    
    if self.onClickRealEntityId_ then
        bm.EventCenter:removeEventListener(self.onClickRealEntityId_)
        self.onClickRealEntityId_ = nil
    end

    if self.avatarUrlObserverHandle_ then
        bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "s_picture", self.avatarUrlObserverHandle_)
    end

    if self.timeSchedulerId_ then
        nk.schedulerPool:clear(self.timeSchedulerId_)
        self.timeSchedulerId_ = nil
    end

    self.data1_ = nil
    self.data2_ = nil
    self.data3_ = nil

    -- 移除监听
    self:removeListenerEvent()
    LoadMatchControl:getInstance():clearCountdown()
    -- 
    nk.UserInfoChangeManager:unReg(nk.UserInfoChangeManager.ChooseArenaRoom)
    self:removePropertyObservers()
end

function ChooseArenaRoomView:onTimeChange()
    if self.roomList_ then
        self.roomList_:refresh()
    end
end

function ChooseArenaRoomView:ctor(controller)
    self.allOnLineCount_ = 0

    self:setNodeEventEnabled(true)
    self.controller_ = controller
    -- 下面的调用把 self也传给控制器, 控制器中会有以下调用, 比赛场视图情况
    -- 特殊,不需要设置
    -- self.view_:playLoginFailAnim() in onLoginError_
    -- 获取到房间数据时给当前view添加 loading弹窗...
    -- 等等
    -- note: 缺少此调用的话, 有些情况下会把loginview调出来,因为ctl的view_没有
    -- 更新
    self.controller_:setDisplayView(self)
    -- 
    self.matchModel_ = nk.match.MatchModel
    self.matchManager_ = MatchManager.new(self.matchModel_,self)

    self.middle_part = display.newNode():pos(-display.cx, -display.cy):addTo(self, 9)
    self.middle_part:setCascadeOpacityEnabled(true)
    -- 
    self.delayOverDueTickId_ = nk.schedulerPool:delayCall(function()
        self:onCheckOverDueTick()
    end, 1.2)

    -- 创建列表
    self:createList()

    self:createTablePart_()

    self:createTopPart_()

    self:createTabBarPart_()

    self:createBottomPart_()

    self:addInfoPanelTouch_()

    -- 添加事件监听
    nk.UserInfoChangeManager:reg(nk.UserInfoChangeManager.ChooseArenaRoom, {"money", "score", "gameCoupon", "goldCoupon", "gcoins", "hddj"}, handler(self, self.getTargetIconPosition_), handler(self,self.alignInfo))

    --添加监听
    self:addListenerEvent()

    -- 配置修改重新
    LoadMatchControl:getInstance():dealServerTime()

    self:addPropertyObservers()
end
-- 背景桌子
function ChooseArenaRoomView:createTablePart_()
    -- 背景桌子
    local px, py = -display.width*0.5, -display.height*0.5 - 50
    local tableParet = display.newNode()
        :pos(px, py)
        :addTo(self)
        :scale(self.controller_:getBgScale()+ 0.1)
    self.tableParet_ = tableParet

    local table_bg_left = display.newSprite('#main_hall_table.png')
        :align(display.CENTER_RIGHT, display.cx+2, display.cy)
        :addTo(tableParet)
    self.table_bg_sz_ = table_bg_left:getContentSize()
    local table_bg_right = display.newSprite('#main_hall_table.png')
        :align(display.CENTER_RIGHT, display.cx-2, display.cy)
        :addTo(tableParet)
    table_bg_right:setScaleX(-1)

    tableParet:setPositionY(-display.height)
    transition.moveTo(tableParet, {
        time = 0.5,
        y    = py+5,
        -- easing = "BACKOUT"
    })
end

-- 被HallScene调用的接口 （与普通场/专业场选择房间一样）
function ChooseArenaRoomView:playShowAnim()
    -- 请求在线人数
    self.allOnLineCount_ = 0
    -- print '播放入场动画'
    -- 入场动画两种形式：
    -- > 淡入
    -- > 移动
    --
    -- 4个部分：
    -- 1》顶部的向下移入
    -- 2》左侧的向右移入
    -- 3》底部的向上移入
    -- 4》中间的淡入
    -- 5》三个场次按钮的特殊移动
    local anim_time   = self.controller_.getAnimTime()
    local middle_part   = self.middle_part

    -- 暂定设计方案 设置动画元素的 起始位置
    -- 这样就算不调用播放动画,UI元素的初始位置也是正确的-)
    local _, topPY = self.topBarArena_:getPosition()
    self.topBarArena_:setPositionY(topPY + 460)
    transition.moveTo(self.topBarArena_, {
        delay = anim_time,
        time  = anim_time,
        y     = topPY,
        easing = "exponentialInOut"
    })
    -- 
    local _, bPY = self.bottomBarArena_:getPosition()
    self.bottomBarArena_:setPositionY(bPY-80)
    transition.moveTo(self.bottomBarArena_, {
        delay  = anim_time,--+ 0.05 * 10,
        time = anim_time,
        y     = -display.height/2+28,
        -- easing = "BACKOUT"
        -- easing = "exponentialInOut"
    })    
    
    -- pageview动画
    local curPage = self.roomList_:getCurrentPage()
    local item = self.roomList_:getListItem(curPage)
    if item then
        local list = item:getItemList()
        if list then
            for i=1,#list do
                local x,y = list[i]:getPosition()
                list[i]:pos(x,y-460)
                transition.moveTo(list[i], {
                    delay  = anim_time + 0.05 * ((i+1)%2+1 + 0),
                    time   = anim_time,
                    y      = y,
                    -- x      = x,
                    easing = "BACKOUT"
                })
            end
        end
    end
    --[[
    -- 淡入淡出类动画比较特殊, opacity属性不能直接传递给children节点,
    -- cocos从v2.1后提供了node:setCascadeOpacityEnabled(true/false)
    -- 方法来实现此需求,但是需要注意此属性并不能递归处理所有子节点
    -- 所以在层次深的时候需要多次设置
    -- July 3, 2015 DavidFeng
    --]]
    transition.fadeIn(middle_part, {
        delay   = anim_time + 0.05 * 10,
        time    = anim_time,
        opacity = 255,
        onComplete = handler(self, self.onPlayShowAnimCallback_),
    })
    -- 比赛先关要resume
    nk.match.MatchModel:startDelayResume()
end

function ChooseArenaRoomView:createBottomPart_()
    local dw, dh = display.width, 56
    local px, py = 0, -display.height*0.5 + dh*0.5
    local bottomBarArena = display.newNode()
        :pos(px, py - 70)
        :addTo(self, 21)
    self.bottomBarArena_ = bottomBarArena

    px, py = 0, 0
    local bg = display.newScale9Sprite("#arena/arena_bar_bottom.png", px, py, cc.size(dw, dh), cc.rect(18,24, 1, 1))
        :addTo(bottomBarArena)

    -- 用户头像的pos和size
    px, py = -display.width*0.5 + INIT_AVATAR_PX, 0
    self.userAvatar_ = AvatarIcon.new("#common_male_avatar.png", AVATART_DW, AVATAR_DH, 6, nil, 1, 8)
        :pos(px, py - 2)
        :addTo(bottomBarArena)

    self.headClick_ = display.newScale9Sprite("#common_transparent_skin.png", px, py, cc.size(80, 80))
        :addTo(bottomBarArena)

    py = py - 5
    -- 筹码
    self.imoney_ = display.newSprite("#chip_icon.png")
        :pos(px, py)
        :addTo(bottomBarArena)
    self.tmoney_ = ui.newTTFLabel({
            text=bm.formatNumberWithSplit(nk.userData.money),
            color=cc.c3b(0xff, 0xc9, 0x50),
            size=20,
        })
        :pos(px, py)
        :addTo(bottomBarArena)

    -- 现金币
    self.iscore_ = display.newSprite("#icon_score.png")
        :pos(px, py)
        :addTo(bottomBarArena)
    self.tscore_ = ui.newTTFLabel({
            text=bm.formatNumberWithSplit(nk.userData.score),
            color=cc.c3b(0xc5, 0x44, 0x54),
            size=20,
        })
        :pos(px, py)
        :addTo(bottomBarArena)

    -- 金券
    self.igold_ = display.newSprite("#icon_goldcoupon.png")
        :pos(px, py)
        :addTo(bottomBarArena)
    self.tgold_ = ui.newTTFLabel({
            text=bm.formatNumberWithSplit(nk.userData.goldCoupon),
            color=cc.c3b(0xff, 0xb9, 0x40),
            size=20,
        })
        :pos(px, py)
        :addTo(bottomBarArena)

    -- 比赛券
    self.icoupon_ = display.newSprite("#icon_gamecoupon.png")
        :pos(px, py)
        :addTo(bottomBarArena)
    self.tcoupon_ = ui.newTTFLabel({
            text=bm.formatNumberWithSplit(nk.userData.gameCoupon),
            color=cc.c3b(0xff, 0xff, 0xff),
            size=20,
        })
        :pos(px, py)
        :addTo(bottomBarArena)

    -- 黄金币
    self.igcoin_ = display.newSprite("#common_gcoin_icon.png")
        :pos(px,py-1)
        :addTo(bottomBarArena)
    self.tgcoin_ = ui.newTTFLabel({
            text=bm.formatNumberWithSplit(nk.userData.gcoins),
            color=cc.c3b(0xff, 0xff, 0xff),
            size=20,
        })
        :pos(px, py)
        :addTo(bottomBarArena)

    self:alignUserPorp_()

    self:loadHead()

    if BM_UPDATE.MATCHMALL and BM_UPDATE.MATCHMALL == 0 then
    else
    local scaleVal = 0.8
    local resList = {
            {
                iconNormal="#arena/arena_menuIcon_mix_up.png",
                iconOver="#arena/arena_menuIcon_mix_down.png",
                btnNormal="#arena/match_ballBg.png",
                btnLightResId="#arena/match_ballLight.png",
                scaleVal=scaleVal,
                iy=1,
                isBtnScale9=false,
                onClick=handler(self, self.onMixExchangeClick_),
            },
            {
                iconNormal="#arena/arena_menuIcon_bill_up.png",
                iconOver="#arena/arena_menuIcon_bill_down.png",
                btnNormal="#arena/match_ballBg.png",
                btnLightResId="#arena/match_ballLight.png",
                scaleVal=scaleVal,
                iy=2,
                isBtnScale9=false,
                onClick=handler(self, self.onBillClickHandler_),
            },
        }

        local gotoResId = {
            iconNormal="#arena/match_upArrow_up.png",
            iconOver="#arena/match_upArrow_down.png",
            btnNormal="#arena/match_ballBg.png",
            btnLightResId="#arena/match_ballLight.png"
        }

        local backResId = {
            iconNormal="#arena/match_close_up.png",
            iconOver="#arena/match_close_down.png",
            btnNormal="#arena/match_ballBg.png",
            btnLightResId="#arena/match_ballLight.png"
        }

        self.scrollAnim_ = ScrollAnimationIcons.new(resList, gotoResId, backResId, ScrollAnimationIcons.DIRECTION_VERTICAL, 68)
            :pos(display.width*0.5 - 35, 5)
            :addTo(bottomBarArena)
        if not nk.userData.matchWheel or nk.userData.matchWheel==1 then
            local resId = {
                iconNormal="#arena/arena_luckturn_up.png",
                iconOver="#arena/arena_luckturn_down.png",
                btnNormal="#arena/arena_luckturn_up.png",
                btnLightResId="#arena/arena_luckturn_down.png",
                scaleVal=1,
                iy=2,
                isBtnScale9=false,
                onClick=handler(self, self.onLuckTurnClickHandler_),
            }

            local icon = BubbleButton.createCommonBtn({
                iconNormalResId=resId.iconNormal,
                iconOverResId=resId.iconOver,
                btnNormalResId=resId.btnNormal,
                btnOverResId=resId.btnOver,
                iconScale=resId.iconScale,
                btnScale=resId.btnScale,
                parent=bottomBarArena,
                isBtnScale9=resId.isBtnScale9,
                x=display.width*0.5 - 35 - (2-1)*70,
                y=5,
                scaleVal=resId.bgScalVal or 0.96,
                onClick=resId.onClick,
            })
        end
    end
end

function ChooseArenaRoomView:onLuckTurnClickHandler_(evt)
    LuckWheelScorePopup.load(self.controller_, HallController.CHOOSE_ARENA_VIEW)
end

function ChooseArenaRoomView:onMixExchangeClick_(evt)
    local callback = function()        
        nk.MixCurrentManager:openMixListPopup()    
    end	
    if self.scrollAnim_ then
		self.scrollAnim_:play(callback)
	else
		callback()
	end
end

function ChooseArenaRoomView:onBillClickHandler_()
    local callback = function()
        MatchBillDetailPopup.new():show()
    end
    if self.scrollAnim_ then
        self.scrollAnim_:play(callback)
	else
		callback()
	end
    nk.userDefault:setStringForKey(nk.userData.uid.."billBubble_status", "1")
    -- 比赛场大厅消耗流水图标点击次数
    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand{command = "event",
                    args = {eventId = "Match_BilldetailIcon_Click", label = "USER UID::"..nk.userData.uid}}
    end
end

function ChooseArenaRoomView:alignUserPorp_()
    local mixDW = 120
    local sz,lsz
    local px
    sz = self.imoney_:getContentSize()
    lsz = self.tmoney_:getContentSize()
    px = -display.width*0.5 + INIT_AVATAR_PX + AVATART_DW + 10
    self.imoney_:setPositionX(px)
    px = px+sz.width*0.5+lsz.width*0.5+5
    self.tmoney_:setPositionX(px)

    if lsz.width > mixDW then
        px = px + lsz.width*0.5 + 10
    else
        px = px + mixDW*0.5 + 1 
    end

    sz = self.iscore_:getContentSize()
    lsz = self.tscore_:getContentSize()
    px = px + sz.width*0.5
    self.iscore_:setPositionX(px)
    px = px+sz.width*0.5+lsz.width*0.5+5
    self.tscore_:setPositionX(px)

    if lsz.width > mixDW then
        px = px + lsz.width*0.5 + 10
    else
        px = px + mixDW*0.5 + 1 
    end

    sz = self.igcoin_:getContentSize()
    lsz = self.tgcoin_:getContentSize()
    px = px + sz.width*0.5
    self.igcoin_:setPositionX(px)
    px = px+sz.width*0.5+lsz.width*0.5+5
    self.tgcoin_:setPositionX(px)

    if lsz.width > mixDW then
        px = px + lsz.width*0.5 + 10
    else
        px = px + mixDW*0.5 + 1 
    end

    sz = self.icoupon_:getContentSize()
    lsz = self.tcoupon_:getContentSize()
    px = px + sz.width*0.5
    self.icoupon_:setPositionX(px)
    px = px+sz.width*0.5+lsz.width*0.5+5
    self.tcoupon_:setPositionX(px)

    if lsz.width > mixDW then
        px = px + lsz.width*0.5 + 10
    else
        px = px + mixDW*0.5 + 1 
    end

    sz = self.igold_:getContentSize()
    lsz = self.tgold_:getContentSize()
    px = px + sz.width*0.5
    self.igold_:setPositionX(px)
    px = px+sz.width*0.5+lsz.width*0.5+5
    self.tgold_:setPositionX(px)
end

function ChooseArenaRoomView:alignInfo()
    if not self.tcoupon_ then return end

    if not self.lastGameCoupon_ or self.lastGameCoupon_ == nk.userData.gameCoupon then
        self.tcoupon_:setString(bm.formatNumberWithSplit(nk.userData.gameCoupon))
        self:alignUserPorp_()
    else
        bm.blinkTextTarget(self.tcoupon_, bm.formatNumberWithSplit(nk.userData.gameCoupon), handler(self, self.alignUserPorp_))
    end

    if not self.lastGoldCoupon_ or self.lastGoldCoupon_ == nk.userData.goldCoupon then
        self.tgold_:setString(bm.formatNumberWithSplit(nk.userData.goldCoupon))
        self:alignUserPorp_()
    else
        bm.blinkTextTarget(self.tgold_, bm.formatNumberWithSplit(nk.userData.goldCoupon), handler(self, self.alignUserPorp_))
    end

    if not self.lastMoney_ or self.lastMoney_ == nk.userData.money then
        self.tmoney_:setString(bm.formatNumberWithSplit(nk.userData.money))
        self:alignUserPorp_()
    else
        bm.blinkTextTarget(self.tmoney_, bm.formatNumberWithSplit(nk.userData.money), handler(self, self.alignUserPorp_))
    end

    if not self.lastScore_ or self.lastScore_ == nk.userData.score then
        self.tscore_:setString(bm.formatNumberWithSplit(nk.userData.score))
        self:alignUserPorp_()
    else
        bm.blinkTextTarget(self.tscore_, bm.formatNumberWithSplit(nk.userData.score), handler(self, self.alignUserPorp_))
    end

    if not self.lastGcoins_ or self.lastGcoins_==nk.userData.gcoins then
        self.tgcoin_:setString(bm.formatNumberWithSplit(nk.userData.gcoins))
        self:alignUserPorp_()
    else
        bm.blinkTextTarget(self.tgcoin_, bm.formatNumberWithSplit(nk.userData.gcoins), handler(self, self.alignUserPorp_))
    end

    self.lastGameCoupon_ = nk.userData.gameCoupon
    self.lastGoldCoupon_ = nk.userData.goldCoupon
    self.lastMoney_ = nk.userData.money
    self.lastScore_ = nk.userData.score
    self.lastGcoins_ = nk.userData.gcoins
end

function ChooseArenaRoomView:createTopPart_()
    -- 600px为中间Tab区域的宽度
    local px, py
    local dw, dh = TOP_PARTDW, TOP_PARTDH -- 两边的宽度、高
    local idw, idh = 148, TOP_PARTDH
    self.leftDW_ = display.width - dw*2
    -- 容器
    local topBarArena = display.newNode()
        :pos(0, display.cy - dh*0.5) -- 480, 450
        :addTo(self)
    self.topBarArena_ = topBarArena

    -- 在玩人数
    self.onlineNode_ = display.newScale9Sprite("#common_transparent_skin.png", 0, 0, cc.size(100, 50))
        :pos(0,-75)
        :addTo(topBarArena)
        :hide()
    self.playerCount_ = display.newSprite("#player_count_icon.png")
        :addTo(self.onlineNode_)
    local playerCountSize = self.playerCount_:getContentSize()
    self.userOnline_ = ui.newTTFLabel({
        text = bm.LangUtil.getText("HALL", "USER_ONLINE", 0),
        color = cc.c3b(0xa5, 0xef, 0xaf),
        size = 24, align = ui.TEXT_ALIGN_LEFT})
        :align(display.CENTER_LEFT,15,0)
        :addTo(self.onlineNode_)

    -- 时间
    self:createTime_(self.onlineNode_) 

    -- 返回
    local scaleVal = 1
    local BUTTON_DW, BUTTON_DH = 102,75
    px, py = -display.width*0.5 + BUTTON_DW*0.5 + 15, 5
    px = px - 15
    BubbleButton.createCommonBtn({
            iconNormalResId="#top_return_btn_normal.png",
            iconOverResId="#top_return_btn_pressed.png",
            btnNormalResId="#common_btn_bg_normal.png",
            btnOverResId="#common_btn_bg_pressed.png",
            parent=topBarArena,
            x=px,
            y=py,
            isBtnScale9=false,
            scaleVal=scaleVal,
            onClick=buttontHandler(self, self.onReturnClick_),
        })

    -- 反馈
    px = px + BUTTON_DW
    BubbleButton.createCommonBtn({
            iconNormalResId="#arena/arena_feed_normal.png",
            iconOverResId="#arena/arena_feed_pressed.png",
            btnNormalResId="#common_btn_bg_normal.png",
            btnOverResId="#common_btn_bg_pressed.png",
            parent=topBarArena,
            x=px,
            y=py,
            scaleVal=scaleVal,
            isBtnScale9=false,
            onClick=buttontHandler(self, self.onFeedbackClick_),
        })

    px = display.width*0.5 - BUTTON_DW*0.5
    self.marketX_,self.marketY_ = px,py
    self:updateStoreIcon()

    px = px - BUTTON_DW
    -- 商城
    self.exchangeBtn_ = BubbleButton.createCommonBtn({
            iconNormalResId="#arena/arena_market_normal.png",
            iconOverResId="#arena/arena_market_pressed.png",
            btnNormalResId="#common_btn_bg_normal.png",
            btnOverResId="#common_btn_bg_pressed.png",
            parent=topBarArena,
            x=px,
            y=py,
            scaleVal=scaleVal,
            isBtnScale9=false,
            onClick=buttontHandler(self, self.onConvertClick_),
        })

    -- 判读是否隐藏兑换商城
    if BM_UPDATE.MATCHMALL == 0 then
        self.exchangeBtn_:hide()    
    end
end

function ChooseArenaRoomView:createTime_(parent)
    self.timeNode_ = display.newNode()
        :pos(215, 0)
        :addTo(parent or self.topBarArena_)

    self.timeIcon_ = display.newSprite("#arena/arena_timeIcon.png")
        :addTo(self.timeNode_)
    self.timeLbl_ = ui.newTTFLabel({
            text="00:00",
            size=20,
            color=cc.c3b(0xa5, 0xef, 0xaf),
            aling=ui.TEXT_ALIGN_CENTER,
        })
        :addTo(self.timeNode_)
    local isz = self.timeIcon_:getContentSize()
    local lsz = self.timeLbl_:getContentSize()
    local mdw = isz.width + lsz.width
    self.timeIcon_:setPositionX(-mdw*0.5 + isz.width*0.5)
    self.timeLbl_:setPositionX(-mdw*0.5 + isz.width*0.5 + lsz.width*0.5 + 15)
    self.isTimeSplitStr = true
    self:refreshTime_()
    self.timeSchedulerId_ = nk.schedulerPool:loopCall(handler(self, self.refreshTime_), 1.0)
end

-- 刷新时间
function ChooseArenaRoomView:refreshTime_()
    local date = os.date("*t",os.time())
    local hour = date.hour
    if tonumber(hour)<10 then
        hour = "0"..hour
    end
    local min = date.min
    if tonumber(min)<10 then
        min = "0"..min
    end

    local splitStr = self.isTimeSplitStr and ":" or " "
    self.timeLbl_:setString(hour..splitStr..min)
    self.isTimeSplitStr = not self.isTimeSplitStr
    return true
end

function ChooseArenaRoomView:createTabBarPart_()
    self.tabList_ = LoadMatchControl:getInstance():getMatchTabList()
    if not self.tabList_ or #self.tabList_ == 0 then
        local openMatches = LoadMatchControl:getInstance().openList_
        self.roomList_:setData(openMatches)
        if self.roomList_.btnContain_ then
            self.roomList_.btnContain_:setPositionY(-self.roomList_.recHeight_*0.5+30)
        end
        return
    end
    -- 容器
    local len = #self.tabList_
    local bdh = 74
    local dh = 52
    local offVal = (self.leftDW_ - 240)/len - 25
    local dw = 163+offVal
    local px, py = 0, 5
    local tabBarArena = display.newNode()
        :pos(px, py) -- 480, 450
        :addTo(self.topBarArena_, 999)
    self.tabBarArena_ = tabBarArena

    local offx = 0
    if len > 3 then
        offx = 28
        len = 4 -- 最多支持4个标签
    end

    px, py = 0, 0
    local newIndex = nil
    local hotIndex = nil
    local btnText = {}
    for i=1,len do
        table.insert(btnText,self.tabList_[i].name)
        if self.tabList_[i].icon==1 then
            newIndex = i
        elseif self.tabList_[i].icon==2 then
            hotIndex = i
        end
    end

    local width = display.width - TOP_PARTDW*2 + 300
    if #btnText<2 then
        return
    end

    self.mainTabBar_ = nk.ui.TabBarWithIndicator.new(
            {
                background = "#choose_room_level_tab_bar_bg.png",
                indicator = "#choose_room_level_tab_bar_indicator.png"
            },
            btnText,
            {
            selectedText = {color = styles.FONT_COLOR.LIGHT_TEXT, size = 28},
            defaltText = {color = cc.c3b(0x78, 0x76, 0x85), size = 28}
            },
            true,
            true)
        :setTabBarSize(width, 69, -8, -8)
        :pos(0, -45)
        :addTo(tabBarArena)
    self.mainTabBar_:onTabChange(function(selectedTab)
        LAST_SHOW_MATCH_TYPE = selectedTab
        self:tableSelectedChange(selectedTab)
        self:showOnLine()
    end)

    -- 全局
    if not LAST_SHOW_MATCH_TYPE then
        LAST_SHOW_MATCH_TYPE = 1
    elseif LAST_SHOW_MATCH_TYPE>#btnText then
        LAST_SHOW_MATCH_TYPE = 1
    end

    self.mainTabBar_:gotoTab(LAST_SHOW_MATCH_TYPE,true)

    local itemLength = width/len
    local startX = (-width+itemLength)/2

    -- 最新
    if newIndex then
        self.newTabIcon_ = display.newSprite("#arena/arena_newIcon.png")
            :pos(startX + (newIndex - 1)*itemLength, 0)
            :addTo(tabBarArena)
    end

    -- 热销
    if hotIndex then
        self.hotTabIcon_ = display.newSprite("#arena/arena_hotIcon.png")
            :pos(startX + (hotIndex - 1)*itemLength, 0)
            :addTo(tabBarArena)
    end
end

function ChooseArenaRoomView:tableSelectedChange(tab, isSelected, cfg)
    local data = self.tabList_[tab]
    self.roomList_:setData(data.list)
    if self.roomList_.btnContain_ then
        self.roomList_.btnContain_:setPositionY(-self.roomList_.recHeight_*0.5+16)
    end
    return true
end

function ChooseArenaRoomView:onCancelSelectedCallback_(evt)
end

function ChooseArenaRoomView:createList()
    local LIST_WIDTH = 850
    local LIST_HEIGHT = 490
    local rows = 3
    local columns = 2
    local pageParam = {}
    self.roomList_ = bm.ui.PageView.new(
            {
                viewRect = cc.rect(-LIST_WIDTH * 0.5, -LIST_HEIGHT * 0.5, LIST_WIDTH, LIST_HEIGHT),
                direction = bm.ui.ScrollView.DIRECTION_HORIZONTAL,
                rows = rows,
                columns = columns,
                rowsPadding = 8,
                columnsPadding = 8,
            }, 
            ArenaRoomChip,
            pageParam
        )
        :addTo(self.middle_part)
        :pos(display.cx,display.cy-40)

    self.roomList_:addEventListener("ITEM_EVENT",handler(self,self.itemSelect))
    self.roomList_:addEventListener("MOVE_COMPLETE",handler(self,self.dealMoveBtn))
    local offWidth = (display.width - LIST_WIDTH)/4
    -- 左右滑动按钮#common_transparent_skin.png
    local offx = 10
    self.toLeftBtn_ = cc.ui.UIPushButton.new({normal="#common_transparent_skin.png"}, {scale9 = true})
        :setButtonSize(60, 60)
        :pos(display.cx-LIST_WIDTH*0.5-offWidth + offx, display.cy-40)
        :onButtonClicked(function()
            nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
            local page = self.roomList_:getCurrentPage()
            page = page - 1
            self.roomList_:gotoPage(page)
        end)
        :addTo(self.middle_part)

    display.newSprite("#arena/arena_arrowIcon.png")
        :addTo(self.toLeftBtn_)

    self.toRightBtn_ = cc.ui.UIPushButton.new({normal="#common_transparent_skin.png"},{scale9 = true})
        :setButtonSize(60, 60)
        :pos(display.cx+LIST_WIDTH*0.5+offWidth - offx, display.cy-40)
        :onButtonClicked(function()
            nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
            local page = self.roomList_:getCurrentPage()
            page = page + 1
            self.roomList_:gotoPage(page)
        end)
        :addTo(self.middle_part)

    local rightBtn = display.newSprite("#arena/arena_arrowIcon.png")
        :addTo(self.toRightBtn_)

    rightBtn:setScale(-1)
    local num = self.roomList_.itemNum_ or 0
    if num<2 then
        self.toLeftBtn_:hide()
        self.toRightBtn_:hide()
    else
        self.toLeftBtn_:hide()
        self.toRightBtn_:show()
        -- 优先返回当前场的退场的
        local currPage = nil
        if nk.socket.MatchSocket.currentRoomMatchLevel then
            local index = nil
            for i=1,#openMatches do
                if openMatches[i].id==nk.socket.MatchSocket.currentRoomMatchLevel then
                    index = i
                    break
                end
            end
            if index then
                if index%(rows*columns)==0 then
                    currPage = index/(rows*columns)
                else
                    currPage = math.ceil(index/(rows*columns))
                end
                if currPage and currPage>1 and currPage<=num then
                    self.roomList_:gotoPage(currPage,true)
                end
            end
            nk.socket.MatchSocket.currentRoomMatchLevel = nil
        end

        -- 找到上一次翻页处
        if not currPage then
            currPage = nk.userDefault:getIntegerForKey(nk.cookieKeys.LAST_SHOW_MATCH_PAGE,1)
            if currPage and currPage>1 and currPage<=num then
                self.roomList_:gotoPage(currPage,true)
            end
        end
    end
end

function ChooseArenaRoomView:onClickRealEntityHandler_(evt)
    local data = evt.data
    if data and data.first and data.first.real then
        local ArenaSponsorPopup = import("app.module.hall.arena.ArenaSponsorPopup")
        ArenaSponsorPopup.new():show(data)

        if device.platform == "android" or device.platform == "ios" then
            cc.analytics:doCommand{command = "event",
                args = {eventId = "count_sponsorIcon_Click", label=data.name}}
        end
    end
end

function ChooseArenaRoomView:dealMoveBtn(evt)
    local num = self.roomList_.itemNum_ or 0
    if num<2 then
        self.toLeftBtn_:hide()
        self.toRightBtn_:hide()
        return
    end
    local page = self.roomList_:getCurrentPage()
    if page<2 then
        self.toLeftBtn_:hide()
        self.toRightBtn_:show()
    elseif page>=num then
        self.toLeftBtn_:show()
        self.toRightBtn_:hide()
    else
        self.toLeftBtn_:show()
        self.toRightBtn_:show()
    end
    nk.userDefault:setIntegerForKey(nk.cookieKeys.LAST_SHOW_MATCH_PAGE,page)
    nk.userDefault:flush()
end

function ChooseArenaRoomView:itemSelect(evt)
    local item = evt.data
    local matchData = item:getData()
    local matchid = self.matchModel_.regList and self.matchModel_.regList[matchData.id]
    local isReg = false
    if matchid~=nil and matchid~=0 and matchid~="" then
        isReg = true
    end
    display.addSpriteFrames("matchreg.plist", "matchreg.png", function()
        ArenaApplyPopup.new(matchData.id, 1, isReg,function()
                self:onRegClicked_(matchData.id)
            end,matchData):showPopupPanel(self)
    end
    )
end

function ChooseArenaRoomView:loadHead(...)
    local imgurl = nk.userData.s_picture
    if not imgurl or string.len(imgurl) <= 5 then
        if nk.userData.sex == "f" then
            self.userAvatar_:setSpriteFrame("common_female_avatar.png")
        else
            self.userAvatar_:setSpriteFrame("common_male_avatar.png")
        end
    else
        self.userAvatar_:loadImage(imgurl)
    end
end

-- 个人档点击事件
function ChooseArenaRoomView:onUserInfoBtnClicked()
    if self.isUserInfoClick_ then
        return
    end
    self.isUserInfoClick_ = true
    nk.schedulerPool:delayCall(function()
        self.isUserInfoClick_ = false
    end, 0.5)
    UserInfoPopup.new():show(false)
end

function ChooseArenaRoomView:getTargetIconPosition_(itype)
    if itype == 1 then      -- 筹码
        return self.bottomBarArena_:convertToWorldSpace(cc.p(self.imoney_:getPosition()))
    elseif itype == 2 then  -- 比赛券
        return self.bottomBarArena_:convertToWorldSpace(cc.p(self.icoupon_:getPosition()))
    elseif itype == 3 then  -- 现金币
        return self.bottomBarArena_:convertToWorldSpace(cc.p(self.iscore_:getPosition()))
    elseif itype == 4 then  -- 金券
        return self.bottomBarArena_:convertToWorldSpace(cc.p(self.igold_:getPosition()))
    elseif itype == 5 then  -- 门票
        return self.bottomBarArena_:convertToWorldSpace(cc.p(self.userAvatar_:getPosition()))
    elseif itype == 9 then  -- 黄金币
        return self.bottomBarArena_:convertToWorldSpace(cc.p(self.igcoin_:getPosition()))
    else
        return self.bottomBarArena_:convertToWorldSpace(cc.p(self.userAvatar_:getPosition()))
    end
end

--添加邀请奖励图标
function ChooseArenaRoomView:addInvitRewardIcon_(image, x, y, num, s)
    local icon = display.newSprite(image)
        :pos(x, y)
        :scale(s or 1)
        :addTo(self.inviteBtn_)
    local size = icon:getContentSize()

    ui.newTTFLabel({
        text = "x" .. num,
        color = styles.FONT_COLOR.GOLDEN_TEXT,
        size = 20
    })
    :align(display.LEFT_CENTER, x + size.width/2, 0)
    :addTo(self.inviteBtn_)
end

function ChooseArenaRoomView:setOnline_(evt)
    local list = evt.data
    if not list then return end
    if not self.allOnLineCount_ then
        self.allOnLineCount_ = 0
    end

    if self.roomList_ then
        self.roomList_:refresh()
    end
    self:showOnLine()
end

function ChooseArenaRoomView:showOnLine()
    local count = 0
    if self.roomList_ and self.roomList_.data_ then
        local list = nk.match.MatchModel.online
        local curList = self.roomList_.data_
        for i=1, #list do
            for k,v in ipairs(curList) do
                if list[i].level == tonumber(v.id) then
                    count = count + list[i].usercount
                    break
                end
            end
        end
    end

    self.userOnline_:setString(bm.LangUtil.getText("HALL", "USER_ONLINE", count))
    local textSize = self.userOnline_:getContentSize()
    local nodeSize = self.onlineNode_:getContentSize()
    local x, y = self.userOnline_:getPosition()
    if self.timeNode_ then
        self.timeNode_:setPositionX(x+textSize.width+45+12)
    end

    self.onlineNode_:setContentSize(textSize.width+100,nodeSize.height)
end

function ChooseArenaRoomView:onPlayShowAnimCallback_()
    bm.EventCenter:dispatchEvent({name = nk.eventNames.CHOOSEARENA_PLAY_SHOW_ANIM})
    -- 拉取socket数据
    if nk.socket.MatchSocket.isConnected_ then
        self.matchManager_:getAllLevelCount()
    else
        if self.controller_ and self.controller_.startConnectMatch then
            -- 必须为true 因为在大厅pause了
            self.controller_:startConnectMatch("127.0.0.1", 8081, true)
        end
    end
    self:showOnLine()
    self.onlineNode_:show()
end

-- 被HallScene调用的接口 （与普通场/专业场选择房间一样）
function ChooseArenaRoomView:playHideAnim()
    self:removeFromParent()
end

--- UI交互事件
function ChooseArenaRoomView:onRegClicked_(matchlevel)
    if nk.socket.MatchSocket:isConnected() then
        self.matchManager_:reg(matchlevel)
    else
        if self.controller_ and self.controller_.onLoginMatchFail_ then
            self.controller_:onLoginMatchFail_()
        end
    end
end

function ChooseArenaRoomView:onReturnClick_()
    self.matchManager_:onExitMatch()
    self.controller_:showMainHallView()
end

function ChooseArenaRoomView:onConvertClick_()
    local HallController = import("app.module.hall.HallController")
    local ScoreMarketView = import("app.module.scoremarket.ScoreMarketViewExt")
    ScoreMarketView.load(self.controller_, HallController.CHOOSE_ARENA_VIEW)
end

function ChooseArenaRoomView:onStoreClick_()
    local StorePopup      = require('app.module.newstore.StorePopup')
    nk.buyMatchCardFrom = "MatchPay_Hall"
    StorePopup.new():showPanel()
end

function ChooseArenaRoomView:onFeedbackClick_()
    local MatchFeedback = import("app.module.match.MatchFeedback")
    MatchFeedback.new():show()
end

-- 添加监听
function ChooseArenaRoomView:addListenerEvent()
    if not self.onOffLoadId_ then
        self.onOffLoadId_ = bm.EventCenter:addEventListener("OnOff_Load", handler(self, self.onOffLoadCallback_))
    end

    if not self.onOpenInviteMatchPopupId_ then
        self.onOpenInviteMatchPopupId_ = bm.EventCenter:addEventListener("On")
    end

    if not self.onlineListenerId_ then
        self.onlineListenerId_ = bm.EventCenter:addEventListener(MatchEventHandler.ONLINE_COUNT_CHANGED, handler(self,self.setOnline_))
    end

    if not self.matchTimeChangeId_ then
        self.matchTimeChangeId_ = bm.EventCenter:addEventListener(nk.eventNames.MATCH_TIME_CHANGE, handler(self,self.onTimeChange))
    end

    if not self.useTickId_ then
        self.useTickId_ = bm.EventCenter:addEventListener(nk.MatchTickManager.EVENT_USE_TICK_MATCH, handler(self, self.onUseTickMatch_))
        bm.EventCenter:dispatchEvent({name=nk.MatchTickManager.EVENT_OPENED_CHOOSEARENAROOMVIEW})
    end
    if not self.regListenerId_ then
        self.regListenerId_ = bm.EventCenter:addEventListener(MatchEventHandler.REGISTER_STATE_CHANGED, handler(self, self.onRegisterStateChangedHandler_))
    end

    if not self.cancelRegMatchId_ then
        self.cancelRegMatchId_ = bm.EventCenter:addEventListener("CancelRegMatch", handler(self, self.onCancelRegMatchHandler_))
    end

    if not self.onClickRealEntityId_ then
        self.onClickRealEntityId_ = bm.EventCenter:addEventListener("ON_CLICK_REAL_ENTITY", buttontHandler(self,self.onClickRealEntityHandler_))
    end
end

function ChooseArenaRoomView:onCancelRegMatchHandler_(evt)
    local matchLevel = evt.data
    if matchLevel then
        self:onRegClicked_(matchLevel)
    end
end

-- 移除监听
function ChooseArenaRoomView:removeListenerEvent()
    if self.onOffLoadId_ then
        bm.EventCenter:removeEventListener(self.onOffLoadId_)
        self.onOffLoadId_ = nil
    end
    if self.delayOverDueTickId_ then
        nk.schedulerPool:clear(self.delayOverDueTickId_)
        self.delayOverDueTickId_ = nil
    end
end

-- easy2Pay购买请求，当关闭StorePopup需要调用拉去比赛券请求
function ChooseArenaRoomView:onOffLoadCallback_()
    self:alignInfo()
end

-- 监听“报名状态变化”事件
function ChooseArenaRoomView:onRegisterStateChangedHandler_(evt)
    if self.roomList_ then
        self.roomList_:refresh()
    end

    if evt.data and self.lastMatchLevel_ == evt.data.matchlevel then
        if evt.data.isReg and self.onUseTickMatchCallback_ then
            self.onUseTickMatchCallback_(evt.data.matchlevel)
        end
        self.lastMatchLevel_ = nil
        self.onUseTickMatchCallback_ = nil
    end
end

-- 使用门票报名比赛
function ChooseArenaRoomView:onUseTickMatch_(evt)
    local tickData = evt.data
    local matchLevel = tickData.level
    local matchid = self.matchModel_.regList and self.matchModel_.regList[matchLevel]
    local isReg = false
    if matchid~=nil and matchid~=0 and matchid~="" then
        isReg = true
    end

    local openMatches = LoadMatchControl:getInstance().openList_
    local matchData
    for i,v in ipairs(openMatches) do
        if v.id == matchLevel then
            matchData = v
            break
        end
    end

    if not matchData then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("TICKET", "ERROR_OVERDATE"))
        return
    end

    if isReg then
        nk.ui.Dialog.new({
            messageText = bm.LangUtil.formatString(bm.LangUtil.getText("TICKET", "REGED_FAIL_ALERT"), matchData.name),
            hasFirstButton = false,
            callback = function (type)
                if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                    
                end
            end
        }):show()
        return
    end

    nk.match.MatchModel:regLevel(matchLevel, function()
        if matchData then
            self.lastMatchLevel_ = matchLevel
            self.onUseTickMatchCallback_ = function(value)
                if value == matchLevel then
                    if tickData.name and matchData.name then
                    nk.ui.Dialog.new({
                        messageText = bm.LangUtil.formatString(bm.LangUtil.getText("TICKET", "REGED_SUCC_ALERT"), tickData.name, matchData.name),
                        hasFirstButton = false,
                        callback = function (type)
                            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                                
                            end
                        end
                    }):show()
                    end

                    nk.MatchTickManager:markTickUsedByMatchLevel(matchLevel)

                    self:anchorFitPage_(matchLevel)
                end
            end
        end
    end)
end

-- 定位matchLevel 所在 PageView 的页下标
function ChooseArenaRoomView:anchorFitPage_(matchLevel)
    local params = self.roomList_:getParams()
    local openList = self.roomList_:getData()
    local total = params.rows * params.columns
    local len = #openList
    local item
    for i=1,10 do
        item = openList[i]
        if item.id == matchLevel then
            local pageIndex = math.ceil(i/total)
            self.roomList_:gotoPage(pageIndex, false)
            break
        end
    end
end

--添加触摸监听
function ChooseArenaRoomView:addInfoPanelTouch_()
    -- 注册touch事件处理函数
    self.bottomBarArena_:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onInfoPanelTouchHandler_))
    self.bottomBarArena_:setTouchEnabled(true)
    self.bottomBarArena_:setNodeEventEnabled(true)
    self.bottomBarArena_:setTouchSwallowEnabled(true)
    self.bottomBarArena_.onCleanup = handler(self, function()
        self.bottomBarArena_:removeNodeEventListenersByEvent(cc.NODE_TOUCH_EVENT)
    end)
end

-- 监听处理事件
function ChooseArenaRoomView:onInfoPanelTouchHandler_(evt)
    local name, x, y, prevX, prevY = evt.name, evt.x, evt.y, evt.prevX, evt.prevY
    if evt.name == 'began' then
        local rect
        local offY = -6
        if bm.containPointByNode(x, y + offY, self.headClick_) then -- 个人档
            self:onUserInfoBtnClicked()
        elseif bm.containPointByNode(x, y + offY, self.igold_, self.tgold_) then
            rect = self.igold_:getParent():convertToWorldSpace(cc.p(self.igold_:getPosition()))
            self:onQuestBtnClicked_(rect, bm.LangUtil.getText("HALL", "GOLD_DESC"))
        elseif bm.containPointByNode(x, y + offY, self.icoupon_, self.tcoupon_) then
            rect = self.icoupon_:getParent():convertToWorldSpace(cc.p(self.icoupon_:getPosition()))
            self:onQuestBtnClicked_(rect, bm.LangUtil.getText("HALL", "COUPON_DESC"))
        elseif bm.containPointByNode(x, y + offY, self.iscore_, self.tscore_) then
            rect = self.iscore_:getParent():convertToWorldSpace(cc.p(self.iscore_:getPosition()))
            self:onQuestBtnClicked_(rect, bm.LangUtil.getText("HALL", "SCORE_DESC"))
        elseif bm.containPointByNode(x, y + offY, self.imoney_, self.tmoney_) then
            rect = self.imoney_:getParent():convertToWorldSpace(cc.p(self.imoney_:getPosition()))
            self:onQuestBtnClicked_(rect, bm.LangUtil.getText("HALL", "CHIP_DESC"))
        elseif bm.containPointByNode(x, y + offY, self.igcoin_, self.tgcoin_) then
            rect = self.igcoin_:getParent():convertToWorldSpace(cc.p(self.igcoin_:getPosition()))
            self:onQuestBtnClicked_(rect, bm.LangUtil.getText("HALL", "GOLDCOIN_DESC"))
        end
    end

    return true
end

-- 金券疑问号点击弹出框
function ChooseArenaRoomView:onQuestBtnClicked_(pt, msg)
    local px, py = pt.x, pt.y
    if not self.questContent_ then
        local runScene = display.getRunningScene()
        if runScene == nil then
            return
        end

        local index = 9999
        self.modal_ = display.newScale9Sprite("#transparent.png", 0, 0, cc.size(display.width, display.height))
            :pos(display.cx, display.cy)
            :addTo(runScene, index, index)
        self.modal_:setTouchEnabled(true)
        self.modal_:setTouchSwallowEnabled(false)
        self.modal_:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onQuestBtnModalTouch_))
        self.modal_.onCleanup = handler(self, function()
            self.modal_:removeNodeEventListenersByEvent(cc.NODE_TOUCH_EVENT)
        end)

        local dw = 280
        self.questContent_ = display.newNode()
            :addTo(runScene, index)

        local lbl = ui.newTTFLabel({
                text=msg,
                size=18,
                color=cc.c3b(0x66, 0x0, 0x33),
                dimensions=cc.size(dw-34, 0)
            })
            :addTo(self.questContent_, 2)
        local sz = lbl:getCascadeBoundingBox() 
        if (sz.height+18)<46 then
            sz.height = 46 - 18
        end

        local bg = display.newScale9Sprite("paopao.png", 0, 0, cc.size(sz.width+10, sz.height+18), cc.rect(38,23,1,1)) -- 45*46
            :pos(-3, -6)
            :addTo(self.questContent_, 1)
        sz = bg:getContentSize()
        self.questContent_:setCascadeOpacityEnabled(true)
        self.questContent_:pos(px+sz.width*0.42, py + sz.height*0.5 + 18)

        self.isShowQuest_ = false
    end

    self:onShowQuestContent_()
end

-- 金券疑问号点击弹出框渐变显示
function ChooseArenaRoomView:onShowQuestContent_()
    if not self.isShowQuest_ then
        self.isShowQuest_ = true
        self.modal_:show()
        self.questContent_:setOpacity(0)
        transition.fadeIn(self.questContent_, {time=0.2, onComplete = function()

        end})
    end
end

-- 金券疑问号点击弹出框渐变 隐藏
function ChooseArenaRoomView:onQuestBtnModalTouch_()
    self.modal_:hide()
    transition.fadeOut(self.questContent_, {time=0.2, onComplete = handler(self, self.cleanQuestContent_)})
end

-- 移除 金券疑问号点击弹出框渐变 显示
function ChooseArenaRoomView:cleanQuestContent_()
    self.isShowQuest_ = false

    if self.modal_ then
        self.modal_:removeFromParent()
    end

    if self.questContent_ then
        self.questContent_:removeFromParent()
    end

    self.modal_ = nil
    self.questContent_ = nil
end

-- 添加
function ChooseArenaRoomView:onCheckOverDueTick()
    -- 判断是否有过期门票
    if not nk.userData.isShowed and nk.userData.nextExpireTickets > 0 then
        nk.userData.isShowed = true
        local tickList = nk.MatchTickManager:getOverdueTickList()
        -- 判断快过期门票个数是否大于0
        if tickList and #tickList > 0 then
            local MatchTickOverduePopup = import("app.module.match.MatchTickOverduePopup")
            MatchTickOverduePopup.new():show()
        end
    end
end

function ChooseArenaRoomView:onbillNodeTouchHandler_(evt)
    local name, x, y, prevX, prevY = evt.name, evt.x, evt.y, evt.prevX, evt.prevY
    if evt.name == 'began' then
        if bm.containPointByNode(x, y, self.billIcon_, self.billBubbleIcon_) then -- 个人档
            self.billNode_:setScale(0.9)
            self:onBillClickHandler_()
        end
        return true
    elseif name == "moved" then

    elseif name == "ended"  or name == "cancelled" then 
        self.billNode_:setScale(1)
    end
    return true
end

function ChooseArenaRoomView:updateStoreIcon()
    -- 商城
    if self.storeNode_ then
        self.storeNode_:removeAllChildren()
    else
        self.storeNode_ = display.newNode()
        self.storeNode_:pos(self.marketX_, self.marketY_)
            :addTo(self.topBarArena_)
    end
    local onsaletime_ = nk.OnOff:getCurrentTime(nk.OnOff.onsaleCountDownTimerId)
    if onsaletime_ and onsaletime_ > 0 then
        cc.ui.UIPushButton.new({normal = {"#guidepay_discount_normal.png"}, pressed = {"#guidepay_discount_pressed.png"}})
            :addTo(self.storeNode_)
            :onButtonClicked(buttontHandler(self, self.onSaleGoodsPayClick_))

        ui.newTTFLabel({text="+50%", size=18, color = cc.c3b(0xff, 0xed, 0x23)})
            :pos(0, 15)
            :addTo(self.storeNode_)

        self.onsaleTimeText_ = ui.newTTFLabel({text = "", size = 20, align = ui.TEXT_ALIGN_CENTER})
            :pos(0, -20)
            :addTo(self.storeNode_)
            
        self.onsaleTimeText_:runAction((cc.RepeatForever:create(transition.sequence({
            cc.CallFunc:create(function()
                local onsaletime_ = nk.OnOff:getCurrentTime(nk.OnOff.onsaleCountDownTimerId)
                if onsaletime_ > 0 then
                    self.onsaleTimeText_:setString(bm.TimeUtil:getTimeString(onsaletime_))
                else
                    self.onsaleTimeText_:stopAllActions()
                    self:updateStoreIcon()
                end
            end),
            cc.DelayTime:create(1.0)
        }))))
    elseif nk.userData.firstPay then
        cc.ui.UIPushButton.new({normal = "#common_first_pay_normal.png", pressed = "#common_first_pay_pressed.png"})
            :addTo(self.storeNode_)
            :onButtonClicked(buttontHandler(self, self.onFirstPayClick_))    
    else
        cc.ui.UIPushButton.new({normal = {"#common_btn_bg_normal.png","#top_store_btn_normal.png"}, pressed = {"#common_btn_bg_pressed.png","#top_store_btn_pressed.png"}})
            :addTo(self.storeNode_)
            :onButtonClicked(buttontHandler(self, self.onStoreClick_))
    end
end

function ChooseArenaRoomView:onFirstPayClick_()
    FirstPayPopup.new():show()
end

function ChooseArenaRoomView:onSaleGoodsPayClick_()
    if nk.userData.onsaleData then
        GuidePayPopup.new(13, nil, nk.userData.onsaleData):show()
    else
        --请求特价商品
        bm.HttpService.POST({
                mod = "PreferentialOrder",
                act = "jmtinfo"
            },
            function(data)
                local jsnData = json.decode(data)
                if jsnData and jsnData.goods then
                    jsnData.goodsInfo = jsnData.goods
                    nk.userData.onsaleData = jsnData
                    GuidePayPopup.new(13, nil, nk.userData.onsaleData):show()
                else
                    nk.OnOff:clearTimer(nk.OnOff.onsaleCountDownTimerId)
                    nk.userData.onsaleCountDownTime = -1
                end
            end,
            function()
                nk.OnOff:clearTimer(nk.OnOff.onsaleCountDownTimerId)
                nk.userData.onsaleCountDownTime = -1
            end)
    end
end

function ChooseArenaRoomView:addPropertyObservers()
    self.firstPayObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "firstPay", handler(self, function (obj, firstPay)
        self:updateStoreIcon()
    end))

    self.onsaleCountDownTimeObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "onsaleCountDownTime", handler(self, function (obj, onsaleCountDownTime)
        self:updateStoreIcon()
    end))

    -- 加载头像
    self.avatarUrlObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "s_picture", handler(self, self.loadHead))

    self.moneyObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "money", handler(self,self.alignInfo))
    self.scoreObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "score", handler(self,self.alignInfo))
end

function ChooseArenaRoomView:removePropertyObservers()
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "money", self.moneyObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "score", self.scoreObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "firstPay", self.firstPayObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "onsaleCountDownTime", self.onsaleCountDownTimeObserverHandle_)
end

return ChooseArenaRoomView
