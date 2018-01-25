--
-- Author: Johnny Lee
-- Date: 2014-07-08 12:47:00
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local HallScene = class("HallScene", function()
    return display.newScene("HallScene")
end)

local HallController = import("app.module.hall.HallController")
local LoginGameView  = import("app.module.hall.LoginGameView")
local MainHallView   = import("app.module.hall.MainHallView")
local ChooseRoomView = import("app.module.hall.ChooseRoomView")
local LoginFeedBack  = import("app.module.hall.LoginFeedBack")

local logger = bm.Logger.new("HallScene")

local BACKGROUND_ZORDER  = 0
local LOGIN_GAME_ZORDER  = 1
local POKER_GIRL_ZORDER  = 2
local CHOOSE_ROOM_ZORDER = 3
local MAIN_HALL_ZORDER   = 4

local Girl_Pos_Login_X = display.cx * 0.75 --女孩登录界面的位置
local Girl_Pos_Hall_X = display.cx * 0.9 --女孩大厅界面的位置
local Girl_Pos_Y = display.cy --女孩Y轴位置

-- 大厅场景
-- @number viewType 默认为 first_open
-- @params action 进入大厅场景的动作
function HallScene:ctor(viewType, action,isCoin)
    -- 比赛相关
    --display.addSpriteFrames("NewLogin.plist", "NewLogin.png")
    nk.socket.RoomSocket = nk.socket.RealRoomSocket
    nk.match.MatchModel:setCurrentView(self)
    self.viewType_ = viewType or HallController.FIRST_OPEN
    self.controller_ = HallController.new(self)
    self.animTime_ = self.controller_:getAnimTime()

    -- 背景缩放系数
    if display.width > 1140 and display.height == 640 then
        self.bgScale_ = display.width / 1140
    elseif display.width == 960 and display.height > 640 then
        self.bgScale_ = display.height / 640
    else
        self.bgScale_ = 1
    end

    -- 背景
    self.bg_ = display.newSprite("main_hall_bg.png")
        :scale(self.bgScale_)
        :pos(display.cx, display.cy)
        :addTo(self, BACKGROUND_ZORDER)


    -- poker girl
    display.addSpriteFrames("NewWomen.plist", "NewWomen.png")
    self.pokerGirlBatchNode_ = display.newBatchNode("NewWomen.png")
        :addTo(self, POKER_GIRL_ZORDER)
    local women = display.newSprite("#NewWomen.png")
        :addTo(self.pokerGirlBatchNode_)
        :schedule(handler(self, self.pokerGirlBlink_), 2)

    --添加反馈和版权
    self:addCopyrightAndFeedback_()
    if self.viewType_ == HallController.FIRST_OPEN then
        self.pokerGirlBatchNode_:pos(Girl_Pos_Login_X - 140, Girl_Pos_Y - 20):scale(self.bgScale_)
        self.loginView_ = LoginGameView.new(self.controller_)
            :pos(display.cx, display.cy)
            :addTo(self, LOGIN_GAME_ZORDER)
        self.loginView_:setShowState()
        self:showCopyrightNode_()
        
        -- self:setGrayNodes_()
    elseif self.viewType_ == HallController.LOGIN_GAME_VIEW then
        self.pokerGirlBatchNode_:pos(Girl_Pos_Hall_X, Girl_Pos_Y):scale(self.bgScale_)
    elseif self.viewType_ == HallController.MAIN_HALL_VIEW then
        self.pokerGirlBatchNode_:pos(Girl_Pos_Hall_X, Girl_Pos_Y):scale(self.bgScale_)
    elseif self.viewType_ == HallController.CHOOSE_NOR_VIEW then
        self.pokerGirlBatchNode_:pos(Girl_Pos_Hall_X, Girl_Pos_Y):scale(self.bgScale_)
    elseif self.viewType_ == HallController.CHOOSE_PRO_VIEW then
        self.pokerGirlBatchNode_:pos(Girl_Pos_Hall_X, Girl_Pos_Y):scale(self.bgScale_)
    elseif self.viewType_ == HallController.CHOOSE_4K_VIEW then
        self.pokerGirlBatchNode_:pos(Girl_Pos_Hall_X, Girl_Pos_Y):scale(self.bgScale_)
    elseif self.viewType_ == HallController.CHOOSE_5K_VIEW then
        self.pokerGirlBatchNode_:pos(Girl_Pos_Hall_X, Girl_Pos_Y):scale(self.bgScale_)
    elseif self.viewType_ == HallController.CHOOSE_ARENA_VIEW then
        self.pokerGirlBatchNode_:pos(Girl_Pos_Hall_X, Girl_Pos_Y):scale(self.bgScale_)
    end
    if self.viewType_ == HallController.CHOOSE_PRO_VIEW  then
        self.iscoin_ = isCoin
    end

    -- 根据视图类型加载纹理
    if self.viewType_ == HallController.FIRST_OPEN then
        -- 首次进入场景，加载大厅纹理与共用纹理
        self:onLoadTextureComplete()
        cc.FileUtils:getInstance():addSearchPath("res/ccs/")
        self.viewType_ = HallController.LOGIN_GAME_VIEW
    else
        self:showHallView_()
    end

    self:setupAndroidBackKey_() -- android 返回键

    self.action_ = action
    if action == "logout" then
        self.controller_:doLogout()
    elseif action == "doublelogin" then
        self.controller_:doLogout(bm.LangUtil.getText("LOGIN", "DOUBLE_LOGIN_MSG"))
    elseif action == "backFromRoom" then
        self.controller_:doBackFromRoom()
    end
end

-- android返回键处理
function HallScene:setupAndroidBackKey_()
    if device.platform ~= 'android' then
        return
    end

    local function on_keypad_event(event)
        if event.key == "back" then
            if not nk.PopupManager:removeTopPopupIf() then
                local currentHallView = bm.DataProxy:getData(nk.dataKeys.CURRENT_HALL_VIEW)
                if currentHallView == HallController.MAIN_HALL_VIEW then
                    -- 从大厅界面退出登录, 返回到登录场景,也弹出提示
                    if self.loginoutDialog then
                        self.loginoutDialog:onClose()
                        self.loginoutDialog = nil
                    else
                        self.loginoutDialog = nk.ui.Dialog.new({
                            titleText = bm.LangUtil.getText("COMMON", "LOGOUT_DIALOG_TITLE"),
                            messageText = self.controller_:getQuitTipInfo(), 
                            firstBtnText = bm.LangUtil.getText("COMMON", "CANCEL"),
                            secondBtnText = bm.LangUtil.getText("COMMON", "LOGOUT"),
                            hasCloseButton = false,
                            callback = function (type)
                                    if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                                       -- 派发登出成功事件
                                        bm.EventCenter:dispatchEvent(nk.eventNames.HALL_LOGOUT_SUCC)
                                    end
                                    self.loginoutDialog = nil
                               end
                            }):show()
                    end
                elseif currentHallView == HallController.CHOOSE_NOR_VIEW
                    or currentHallView == HallController.CHOOSE_PRO_VIEW 
                    or currentHallView == HallController.CHOOSE_ARENA_VIEW 
                    or currentHallView == HallController.CHOOSE_4K_VIEW
                    or currentHallView == HallController.CHOOSE_5K_VIEW then
                    self.controller_:showMainHallView()
                else
                    -- 登录界面退出 弹 确认关闭对话框
                    local quit_tip = self.controller_:getQuitTipInfo()
                    if self.quitDialog then
                        self.quitDialog:onClose()
                        self.quitDialog = nil
                    else
                        self.quitDialog = nk.ui.Dialog.new({
                            titleText = bm.LangUtil.getText("COMMON", "QUIT_DIALOG_TITLE"),
                            messageText = quit_tip, 
                            firstBtnText = bm.LangUtil.getText("COMMON", "QUIT_DIALOG_CONFIRM"),
                            secondBtnText = bm.LangUtil.getText("COMMON", "QUIT_DIALOG_CANCEL"),
                            hasCloseButton = false,
                            callback = function (type)
                                    if type == nk.ui.Dialog.FIRST_BTN_CLICK then
                                        nk.app:exit()
                                    else
                                        self.quitDialog = nil
                                    end
                               end
                            }):show()
                    end
                end
            end
        end
    end

    local touchLayer_ = display.newLayer()
    touchLayer_:addNodeEventListener(cc.KEYPAD_EVENT, on_keypad_event)
    touchLayer_:setKeypadEnabled(true)
    self:addChild(touchLayer_)
end

function HallScene:onLoadTextureComplete()
    self:showHallView_()
    -- 把这里算作 大厅进入完成, 是最准确的
    self.controller_:umengEnterHallTimeUsage()

    self.controller_:checkAutoLogin()
end

function HallScene:showHallView_()
    if self.viewType_ == HallController.LOGIN_GAME_VIEW then
        -- 展示登录游戏界面
        self:showLoginView_()
    elseif self.viewType_ == HallController.MAIN_HALL_VIEW then
        -- 展示主大厅界面
        self:showMainHallView_(MainHallView.TABLE_POS_BOTTOM)
    elseif self.viewType_ == HallController.CHOOSE_NOR_VIEW then
        -- 展示选择普通房间界面
        self:showChooseRoomView_(HallController.CHOOSE_NOR_VIEW)
    elseif self.viewType_ == HallController.CHOOSE_PRO_VIEW then
        -- 展示选择专业房间界面
        self:showChooseRoomView_(HallController.CHOOSE_PRO_VIEW,nil,self.iscoin_)
    elseif self.viewType_ == HallController.CHOOSE_4K_VIEW then
        -- 展示选择4K房间界面
        self:showChooseRoomView_(HallController.CHOOSE_4K_VIEW)
    elseif self.viewType_ == HallController.CHOOSE_5K_VIEW then
        -- 展示选择5K房间界面
        self:showChooseRoomView_(HallController.CHOOSE_5K_VIEW)
    elseif self.viewType_ == HallController.CHOOSE_DICE_VIEW then
        -- 展示选择dice房间界面
        self:showChooseRoomView_(HallController.CHOOSE_DICE_VIEW)
    elseif self.viewType_ == HallController.CHOOSE_PDENG_VIEW then
        -- 展示选择pdeng房间界面
        self:showChooseRoomView_(HallController.CHOOSE_PDENG_VIEW)
    elseif self.viewType_ == HallController.CHOOSE_ARENA_VIEW then
        if self.isShowingArena_ then
            return
        end
        local LoadMatchControl = import("app.module.match.LoadMatchControl")
        LoadMatchControl:getInstance():loadConfig("",function(success, data)
                if success then
                    self:showChooseArenaRoomView()
                else
                    -- 显示主界面
                    self.viewType_ = HallController.MAIN_HALL_VIEW
                    self:showMainHallView_(MainHallView.TABLE_POS_BOTTOM)
                end
            end
            )
    end
end

-- 显示登录视图
function HallScene:showLoginView_()
    self.isShowingArena_ = false
    -- 登录视图
    if not self.loginView_ then
        self.loginView_ = LoginGameView.new(self.controller_)
            :pos(display.cx, display.cy)
            :addTo(self, LOGIN_GAME_ZORDER)
    end

    -- 动画
    self.pokerGirlBatchNode_:moveTo(self.animTime_, Girl_Pos_Login_X, Girl_Pos_Y - 20)
    self.loginView_:playShowAnim()
    self:showCopyrightNode_()

    -- 设置当前场景类型全局数据
    bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.LOGIN_GAME_VIEW)
    -- self:setGrayNodes_()
end

-- 显示主界面视图
function HallScene:showMainHallView_(tablePos)
    -- 主界面视图
    self.mainHallView_ = MainHallView.new(self.controller_, tablePos)
        :pos(display.cx, display.cy)
        :addTo(self, MAIN_HALL_ZORDER)

    -- 动画
    self.mainHallView_:playShowAnim()
    self.pokerGirlBatchNode_:scale(self.bgScale_):moveTo(self.animTime_, Girl_Pos_Hall_X + 30, Girl_Pos_Y - 20)
    
    self:hideCopyrightNode_()

    -- 设置当前场景类型全局数据
    bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.MAIN_HALL_VIEW)

    -- 更新折扣率
    self.controller_:updateUserMaxDiscount()

    nk.schedulerPool:delayCall(function()
        self.mainHallView_:playShowAnim(true)
    end,0.25)

    -- self:resumedGrayNodes_()
end

-- 显示选择房间视图
function HallScene:showChooseRoomView_(viewType, tabIndex,isCoin)
    -- 选房间视图
    self.chooseRoomView_ = ChooseRoomView.new(self.controller_, viewType, tabIndex,isCoin)
        :pos(display.cx, display.cy)
        :addTo(self, CHOOSE_ROOM_ZORDER)

    -- 动画
    self.chooseRoomView_:playShowAnim()

    -- 设置当前场景类型全局数据
    bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, viewType)
end

-- 显示比赛场 选场界面
function HallScene:showChooseArenaRoomView()
    self.isShowingArena_ = true

    local ChooseArenaRoomView = import 'app.module.hall.ChooseArenaRoomView'
    self.chooseArenaRoomView_ = ChooseArenaRoomView.new(self.controller_)
        :pos(display.cx, display.cy)
        :addTo(self, CHOOSE_ROOM_ZORDER)

    -- 动画
    local px = self.pokerGirlBatchNode_:getPositionX()
    if math.abs(display.cx - px) < 10 then
        self.pokerGirlBatchNode_:scaleTo(self.animTime_, self.bgScale_ * 0.7)
    else
        self.pokerGirlBatchNode_:scale(self.bgScale_ * 0.7):moveTo(self.animTime_, Girl_Pos_Hall_X, Girl_Pos_Y - 20)
    end
    self.chooseArenaRoomView_:playShowAnim()
    -- 设置当前场景类型全局数据
    bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_ARENA_VIEW)
end

function HallScene:leaveLuckWheelView()
    self.pokerGirlBatchNode_:scale(self.bgScale_):moveTo(self.animTime_, Girl_Pos_Hall_X, Girl_Pos_Y - 20)
end

function HallScene:onLoginSucc()
    self:cleanLoginView()
    
    self:showMainHallView_(MainHallView.TABLE_POS_BOTTOM)
end

function HallScene:onLogoutSucc()
    self:cleanChooseRoomView()
    self:cleanChooseArenaRoomView()
    self:cleanMainHallView()
    self:showLoginView_()
    self.pokerGirlBatchNode_:stopAllActions()
    self.pokerGirlBatchNode_:scale(self.bgScale_):moveTo(self.animTime_, Girl_Pos_Login_X - 140, Girl_Pos_Y - 20)
    nk.PopupManager:removeAllPopup()
    local isAdSceneOpen = nk.OnOff:check("unionAd")
    if isAdSceneOpen and nk.AdSceneSdk then
        nk.AdSceneSdk:setShowRecommendBar(0)
    end
end

function HallScene:onLuckturnGirl()
    self.pokerGirlBatchNode_:scale(self.bgScale_):moveTo(self.animTime_, display.left+192, Girl_Pos_Y - 20)
end

function HallScene:onShowChooseArenaRoomView()
    if self.isShowingArena_ then
        return
    end
    self.isShowingArena_ = true
    local viewStatus = bm.DataProxy:getData(nk.dataKeys.CURRENT_HALL_VIEW)
    if viewStatus == HallController.MAIN_HALL_VIEW then
        self:cleanMainHallView()
    elseif viewStatus == HallController.CHOOSE_NOR_VIEW or viewStatus == HallController.CHOOSE_PRO_VIEW then
        self:cleanChooseRoomView()
    else
        self:cleanMainHallView()
        self:cleanChooseRoomView()
    end
    -- self:cleanAllView()
    self:showChooseArenaRoomView()
end

function HallScene:onShowChooseRoom(viewType, tabIndex,isCoin)
    self.isShowingArena_ = false
    if self.mainHallView_ then
        self:cleanMainHallView()
        self.pokerGirlBatchNode_:scaleTo(self.animTime_, self.bgScale_ * 0.7)
    end
    self:showChooseRoomView_(viewType, tabIndex,isCoin)
end

function HallScene:onShowMainHall()
    self.isShowingArena_ = false
    self:cleanChooseRoomView()
    self:cleanChooseArenaRoomView()
    self:showMainHallView_(MainHallView.TABLE_POS_TOP)
end

function HallScene:onShowMainHallByBottom()
    self.isShowingArena_ = false
    self:cleanChooseRoomView()
    self:cleanChooseArenaRoomView()
    self:showMainHallView_(MainHallView.TABLE_POS_BOTTOM)
end

function HallScene:cleanAllView()
    self.isShowingArena_ = false
    -- 
    self:cleanChooseRoomView()
    self:cleanChooseArenaRoomView()
    self:cleanMainHallView()
    self:cleanLoginView()
end

function HallScene:cleanChooseRoomView()
    if self.chooseRoomView_ and self.chooseRoomView_.playHideAnim then
        self.chooseRoomView_:playHideAnim()
        self.chooseRoomView_ = nil
    end
end

function HallScene:cleanChooseArenaRoomView()
    if self.chooseArenaRoomView_ and self.chooseArenaRoomView_.playHideAnim then
        self.chooseArenaRoomView_:playHideAnim()
        self.chooseArenaRoomView_ = nil
    end
end

function HallScene:cleanMainHallView()
    if self.mainHallView_ and self.mainHallView_.playHideAnim then
        self.mainHallView_:playHideAnim()
        self.mainHallView_ = nil
    end
end

function HallScene:cleanLoginView()
    if self.loginView_ and self.loginView_.playHideAnim then
        self.loginView_:playHideAnim()
        self.loginView_ = nil
    end
end

function HallScene:getBgScale()
    return self.bgScale_ or 1
end

-- poker girl眨眼动画
function HallScene:pokerGirlBlink_()
    local blinkSpr = display.newSprite("#NewWomen_blink_half.png")
        :pos(27,217)
        :addTo(self.pokerGirlBatchNode_)
    blinkSpr:performWithDelay(function ()
        blinkSpr:setSpriteFrame(display.newSpriteFrame("NewWomen_blink_all.png"))
    end, 0.05)
    blinkSpr:performWithDelay(function ()
        blinkSpr:setSpriteFrame(display.newSpriteFrame("NewWomen_blink_half.png"))
    end, 0.15)
    blinkSpr:performWithDelay(function ()
        blinkSpr:removeFromParent()
    end, 0.20)
end

function HallScene:onCleanup()
    -- 清除大厅纹理（保留共用纹理）
    display.removeSpriteFramesWithFile("hall_texture.plist", "hall_texture.png")

    -- 清理控制器
    self.controller_:dispose()
    local isAdSceneOpen = nk.OnOff:check("unionAd")
    if isAdSceneOpen and nk.AdSceneSdk then
        nk.AdSceneSdk:setShowRecommendBar(0)
    end
    app:dealEnterMatch()
end

function HallScene:onOffCallback()
    if self.mainHallView_ and self.mainHallView_["onOffCallback"] then
        self.mainHallView_:onOffCallback()
    end
end

function HallScene:onEnter()
    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand{command = "beginScene",
                    args = {sceneName = "HallScene"}}
    end
    if self.action_ == "doublelogin" and self.viewType_ == HallController.LOGIN_GAME_VIEW then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("LOGIN", "DOUBLE_LOGIN_MSG"))
        self.action_ = " "
    end
    nk.match.MatchModel:startDelayResume()
end

-- 比赛相关处理
function HallScene:onEnterBackground()
    nk.socket.MatchSocket:disconnect(true)
end

function HallScene:onEnterForeground(startType)
    -- 检测比赛报名情况 连接比赛服务器
    local matchStatus = 0;
    if nk.userData then
        matchStatus = nk.userDefault:getIntegerForKey(nk.cookieKeys.IS_JOIN_MATCH..nk.userData.uid,0)
    end
    -- matchStatus = 1
    -- 比赛重练处理
    if matchStatus==1 then
        self.controller_:startConnectMatch("127.0.0.1", 8081,true)
    else
        local viewStatus = bm.DataProxy:getData(nk.dataKeys.CURRENT_HALL_VIEW)
        if viewStatus == HallController.CHOOSE_ARENA_VIEW then
            self.controller_:startConnectMatch("127.0.0.1", 8081,true)
        end
    end
    -- 启动处理
    if startType and startType>0 then
        if self.loginView_~=nil then
            self.lastStartType = startType -- 因为获取一次之后下次就获取不到了 
        else
            self.lastStartType = -1
            local func = nil

            local LuckWheelScorePopup = import("app.module.luckturn.LuckWheelScorePopup")
            if LuckWheelScorePopup.instance_ and LuckWheelScorePopup.instance_.onReback then
                LuckWheelScorePopup.instance_.hallCtrl_ = nil
                self.controller_.view_ = nil
                func = function()
                    LuckWheelScorePopup.instance_:onReback()
                end
            end

            local ScoreMarketView = import("app.module.scoremarket.ScoreMarketViewExt")
            if ScoreMarketView.instance_ and ScoreMarketView.instance_.onReback then
                ScoreMarketView.instance_.hallCtrl_ = nil
                self.controller_.view_ = nil
                func = function()
                    ScoreMarketView.instance_:onReback()
                end
            end

            local LuckWheelFreePopup = import("app.module.luckturn.LuckWheelFreePopup")
            if LuckWheelFreePopup.instance_ and LuckWheelFreePopup.instance_.onReback then
                LuckWheelFreePopup.instance_.hallCtrl_ = nil
                self.controller_.view_ = nil
                func = function()
                    LuckWheelFreePopup.instance_:onReback()
                end
            end
    
            if startType==1
            or startType==2
            or (startType==3 and (viewStatus~=HallController.CHOOSE_ARENA_VIEW or func)) then
                if func then
                    nk.schedulerPool:delayCall(func,0.1) -- 不延迟报错
                end
                self:showPushView(startType)
            end
        end
    end
end
function HallScene:showPushView(startType,delay)
    if startType==1 then            --1兑奖码
        if delay then
            nk.schedulerPool:delayCall(function()
                self.controller_:showExchangeCodePop()
            end,1) -- 小于1.2秒 务必第一个弹出
        else
            nk.schedulerPool:delayCall(function()
                self.controller_:showExchangeCodePop()
            end,0.1)
        end
    elseif startType == 2 then        --2活动
        nk.schedulerPool:delayCall(function()
            local activityPopup = import("app.module.login.plugins.ByActivityPlugin").new()
            activityPopup:display()
        end, 0.1)-- 不延迟报错
    elseif startType==3 then        --3比赛
        if delay then
            nk.schedulerPool:delayCall(function()
                self.controller_:onEnterMatch()
            end,1)
        else
            nk.schedulerPool:delayCall(function()
                self.controller_:onEnterMatch()
            end,0.1)-- 不延迟报错
        end
    end
end

function HallScene:dealMatchLaba(msg, icon_)
    -- 2000 比赛信息
    nk.TopTipManager:showTopTip({text = msg, messageType = 2000, image = icon_})
end

function HallScene:onExit()
    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand{command = "endScene",
                    args = {sceneName = "HallScene"}}
    end

    if device.platform == "android" then
        device.cancelAlert()
    end
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end

--添加反馈和版权
function HallScene:addCopyrightAndFeedback_()
    -- 版权所有
    self.copyrightNode_ = display.newNode():addTo(self, POKER_GIRL_ZORDER)
    local node = self.copyrightNode_

    self.copyright_ = ui.newTTFLabel({
        text = bm.LangUtil.getText("ABOUT", "COPY_RIGHT") .. "V" .. BM_UPDATE.VERSION,
        color = cc.c3b(0x99, 0x92, 0xb0), 
        size = 18, 
        align = ui.TEXT_ALIGN_CENTER})
        :align(display.RIGHT_BOTTOM, display.width - 60, 15)
        :addTo(node)

    --display.addSpriteFrames("NewLogin.plist", "NewLogin.png")
    --反馈
    local feedback = display.newSprite("#NewLogin_HelpBg.png")
        :align(display.LEFT_BOTTOM, 0, 0)
        :addTo(node)
    local btn = cc.ui.UIPushButton.new({normal = "#NewLogin_Help.png",pressed = "#NewLogin_HelpHigh.png"})
        :pos(30, 30)
        :onButtonClicked(buttontHandler(self, self.loginFeedBackHandler_))
        :onButtonPressed(function(event)
            feedback:setSpriteFrame(display.newSpriteFrame("NewLogin_HelpBgHigh.png"))
        end)
        :onButtonRelease(function(event)
            feedback:setSpriteFrame(display.newSpriteFrame("NewLogin_HelpBg.png"))
        end)
        :addTo(node)
  
    --增加触摸范围
    display.newScale9Sprite("#common_transparent_skin.png", 0, 0, cc.size(50, 50))
        :addTo(btn)
end

function HallScene:showCopyrightNode_()
    self.copyrightNode_:stopAllActions()
    transition.moveTo(self.copyrightNode_, {
        time = 0.5, 
        y = 0, 
    })
end

function HallScene:hideCopyrightNode_()
    self.copyrightNode_:stopAllActions()
    transition.moveTo(self.copyrightNode_, {
        time = 0.5, 
        y = -150, 
    })
end

function HallScene:loginFeedBackHandler_()
    LoginFeedBack.new():show()
end

--设置变灰结点
function HallScene:setGrayNodes_()
    bm.DisplayUtil.setGray(self.bg_)
    bm.DisplayUtil.setGray(self.pokerGirlBatchNode_)
    bm.DisplayUtil.setGray(self.copyrightNode_)
    bm.DisplayUtil.setGray(self.loginView_)
    self.copyright_:setTextColor(cc.c3b(0x6d, 0x6d, 0x6d))
end

--恢复变灰的结点
function HallScene:resumedGrayNodes_()
    bm.DisplayUtil.removeShader(self.bg_)
    bm.DisplayUtil.removeShader(self.pokerGirlBatchNode_)
    bm.DisplayUtil.removeShader(self.copyrightNode_)
end

return HallScene
