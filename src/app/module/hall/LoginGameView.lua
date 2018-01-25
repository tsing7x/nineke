--
-- Author: johnny@boomegg.com
-- Date: 2014-08-05 16:24:49
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
-- 登录视图

local LoginGameView = class("LoginGameView", function ()
    return display.newNode()
end)

local LoginFeedBack = import("app.module.hall.LoginFeedBack")
local DebugPopup = import("app.module.debugtools.DebugPopup")
-- local DebugTstPopup = import("app.module.debugtools.DebugTstPopup")
local logger = bm.Logger.new("LoginGameView")

local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

local DOTS_NUM         = 30
local LOGIN_BTN_WIDTH  = 338
local LOGIN_BTN_HEIGHT = 92
local LOGIN_BTN_GAP    = 20
local PANEL_WIDTH      = 394
local PANEL_HEIGHT     = 320

local LOGO_POS_X = display.cx - 260
local LOGO_POS_Y = 176
local LOGO_RADIUS = 94
local LOGO_SCALE  = 1

function LoginGameView:ctor(controller)
    self:setNodeEventEnabled(true)
    self.controller_ = controller
    self.controller_:setDisplayView(self)

    --左侧漂浮的扑克牌
    self:addPokerBatchNodeTest()
    
    --添加桌子
    self:addTableNode_()
    
    -- 游戏logo
    --self:addLogoBatchNode_()
    
    if DEBUG >= 5 then
        cc.ui.UIPushButton.new({normal = "#float_poker_2.png", pressed = "#float_poker_2.png"}, {scale9 = true})
            :pos(display.cx - 40, display.cy - 40 )
            :addTo(self)
            :onButtonClicked(buttontHandler(self, self.onPhpSelector_))

        cc.ui.UIPushButton.new({normal = "#float_poker_2.png", pressed = "#float_poker_2.png"}, {scale9 = true})
            :pos(display.cx - 40, display.cy - 100 )
            :addTo(self)
            :onButtonClicked(buttontHandler(self, self.onDebugTst_))
    end

    ----添加登录按钮
    self:addLoginButtons_()
end

--添加会飞的扑克牌
function LoginGameView:addPokerBatchNodeTest()
    print("zhixingle")
    self.pokerBatchNode_ = display.newBatchNode("NewLogin.png")
        :pos(0, 0)
        :addTo(self)
    local animTime = 10

    --右上角扑克
    local poker1 = display.newSprite("#Poker1.png")
        :pos(200, 110)
        :addTo(self.pokerBatchNode_)
    poker1:runAction(cc.RepeatForever:create(transition.sequence({
        cc.MoveTo:create(animTime * 0.8, cc.p(display.width/2 + 72, display.height/2 + 72)), 
        cc.CallFunc:create(function()
            poker1:pos(200, 110)
        end)
    })))

    --右下角扑克
    local poker2 = display.newSprite("#Poker2.png")
        :pos(0, -display.height/2 - 69)
        :addTo(self.pokerBatchNode_)
    poker2:runAction(cc.RepeatForever:create(transition.sequence({
        cc.MoveTo:create(animTime * 1.1, cc.p(display.width/2 + 72, 0)), 
        cc.CallFunc:create(function()
            poker2:pos(0, -display.height/2 - 69)
        end)
    })))

    --中间扑克
    local poker3 = display.newSprite("#Poker3.png")
        :pos(-250, -150)
        :addTo(self.pokerBatchNode_)
    poker3:runAction(cc.RepeatForever:create(transition.sequence({
        cc.MoveTo:create(animTime * 0.9, cc.p(200, 110)), 
        cc.CallFunc:create(function()
            poker3:pos(-250, -150)
        end)
    })))

    --左下角扑克
    local poker4 = display.newSprite("#Poker4.png")
        :pos(-250, -display.height/2 - 60)
        :addTo(self.pokerBatchNode_)
    poker4:runAction(cc.RepeatForever:create(transition.sequence({
        cc.MoveTo:create(animTime, cc.p(-display.width/2 - 70, -100)), 
        cc.CallFunc:create(function()
            poker4:pos(-250, -display.height/2 - 60)
        end)
    })))
end

--左侧漂浮的扑克牌
-- function LoginGameView:addPokerBatchNode_()
--     self.pokerBatchNode_ = display.newBatchNode("update_texture.png")
--         :pos(-display.cx - 300, 0)
--         :addTo(self)
--     local animTime = 32
--     local poker1 = display.newSprite("#float_poker_1.png")
--         :pos(260, 122)
--         :addTo(self.pokerBatchNode_)
--     poker1:runAction(cc.RepeatForever:create(transition.sequence({
--         cc.MoveTo:create(animTime, cc.p(-40, 122)), 
--         cc.MoveTo:create(animTime, cc.p(260, 122))
--     })))
--     local poker2 = display.newSprite("#float_poker_3.png")
--         :pos(140, -20)
--         :addTo(self.pokerBatchNode_)
--     poker2:runAction(cc.RepeatForever:create(transition.sequence({
--         cc.MoveTo:create(animTime * 0.8, cc.p(292, -20)), 
--         cc.MoveTo:create(animTime * 0.8, cc.p(-60, -20))
--     })))
--     local poker3 = display.newSprite("#float_poker_5.png")
--         :pos(124, -132)
--         :addTo(self.pokerBatchNode_)
--     poker3:setScaleX(-1)
--     poker3:runAction(cc.RepeatForever:create(transition.sequence({
--         cc.MoveTo:create(animTime * 0.7, cc.p(-76, -132)), 
--         cc.MoveTo:create(animTime * 0.7, cc.p(284, -132))
--     })))
--     local poker4 = display.newSprite("#float_poker_4.png")
--         :pos(64, -220)
--         :addTo(self.pokerBatchNode_)
--     poker4:runAction(cc.RepeatForever:create(transition.sequence({
--         cc.MoveTo:create(animTime * 0.8, cc.p(244, -220)), 
--         cc.MoveTo:create(animTime * 0.8, cc.p(-64, -220))
--     })))
--     local poker5 = display.newSprite("#float_poker_5.png")
--         :pos(100, 64)
--         :addTo(self.pokerBatchNode_)
--     poker5:runAction(cc.RepeatForever:create(transition.sequence({
--         cc.MoveTo:create(animTime * 1.2, cc.p(256, 64)), 
--         cc.MoveTo:create(animTime * 1.2, cc.p(-76, 64))
--     })))
-- end

--添加桌子
function LoginGameView:addTableNode_()
    self.tableNode_ = display.newNode()
        :addTo(self)

    local s = display.height / 640
    local gameTable = display.newNode()
        :addTo(self.tableNode_)

    local tableWidth = 730
    local tab_x = tableWidth/2 - display.cx * 0.24
    if display.width * 0.75 > tableWidth then
        self.visibleTableWidth_ = tableWidth
        gameTable:pos(tab_x, 0)
    else
        self.visibleTableWidth_ = display.width * 0.75
        LOGO_POS_X = display.cx - 200
        gameTable:pos(tab_x, 0)
    end
    self.tableNode_:pos(self.visibleTableWidth_, 0)
end

-- 游戏logo
function LoginGameView:addLogoBatchNode_()
    self.logoBatchNode_ = display.newBatchNode("NewLogin.png")
        :addTo(self.tableNode_)
    -- 圆点
    self.dots_ = {}
    for i = 1, DOTS_NUM do
        self.dots_[i] = display.newSprite("#NewLogin_dot.png")
        :pos(
                LOGO_POS_X + math.sin((i - 1) * math.pi / 15) * LOGO_RADIUS * LOGO_SCALE - 15, 
                LOGO_POS_Y + math.cos((i - 1) * math.pi / 15) * LOGO_RADIUS * LOGO_SCALE - 30
            )
        :opacity(0)
        :addTo(self.logoBatchNode_)
    end
    
    -- 游戏logo
    local log = display.newSprite("#NewLogin_Loading.png")
        :pos(LOGO_POS_X - 15, LOGO_POS_Y - 30)
        :addTo(self.logoBatchNode_)
        :scale(LOGO_SCALE)
    log:setScaleX(0.8)
    log:setScaleY(0.8)
end

--添加登录按钮
function LoginGameView:addLoginButtons_()
    --display.addSpriteFrames("NewLogin.plist", "NewLogin.png")
    -- 按钮栏背景
    self.btnNode_ = display.newNode()
        :addTo(self.tableNode_)

    self.logoBatchNode_ = display.newBatchNode("NewLogin.png")
        :addTo(self.tableNode_)
    -- 圆点
    self.dots_ = {}
    for i = 1, DOTS_NUM do
        self.dots_[i] = display.newSprite("#NewLogin_dot.png")
        :pos(
                730/2 - display.cx * 0.24 + math.sin((i - 1) * math.pi / 15) * LOGO_RADIUS * LOGO_SCALE, 
                LOGO_POS_Y + math.cos((i - 1) * math.pi / 15) * LOGO_RADIUS * LOGO_SCALE - 30
            )
        :opacity(0)
        :addTo(self.logoBatchNode_)
    end
    
    -- 游戏logo
    local log = display.newSprite("#NewLogin_Loading.png")
        :pos(730/2 - display.cx * 0.24, LOGO_POS_Y - 30)
        :addTo(self.logoBatchNode_)
        :scale(LOGO_SCALE)
    log:setScaleX(0.8)
    log:setScaleY(0.8)



    local panelPosY =  LOGO_POS_Y - PANEL_HEIGHT * 0.5 - 120

    self.btnPanel_ = display.newSprite("#NewLogin_LoginBackGround.png")
        :pos(730/2 - display.cx * 0.24,0)
        :addTo(self.btnNode_)
    self.btnPanel_:setScaleX(0.9)
    self.btnPanel_:setScaleY(0.9)

    -- FB登录按钮
    local btn_w, btn_h = 342, 100
    self.fbLoginBtn = self:createButton_(
        "#NewLogin_Facebook.png",
        bm.LangUtil.getText("LOGIN", "FB_LOGIN"),
        cc.c3b(0x0, 0xff, 0xff),
        PANEL_WIDTH/2 + 125, PANEL_HEIGHT/2 + 110,
        buttontHandler(self, self.onFacebookBtnClick_))
    self.fbLoginBtn:setButtonSize(500, 110)

    self.facebookBonusBackground_ = display.newSprite("#NewLogin_Reward.png")
            :pos(btn_w/2 + 35, btn_h/2 - 30)
            :addTo(self.fbLoginBtn)
            :hide()

    -- 游客登录按钮
    self.guestLoginBtn = self:createButton_(
        "#NewLogin_Visitor.png",
        bm.LangUtil.getText("LOGIN", "GU_LOGIN"),
        cc.c3b(0x0, 0xff, 0x6a),
        PANEL_WIDTH/2 + 125, PANEL_HEIGHT/2 - 30,
        buttontHandler(self, self.onGuestBtnClick_))
    self.guestLoginBtn:setButtonSize(500, 110)


    local bonus = BM_UPDATE.FACEBOOK_BONUS    
    if bonus and bonus > 0 then
        self.facebookBonusBackground_:show()
    else
        self.facebookBonusBackground_:hide()
    end

    self:playDotsAnimInNormal_()
end

--创建登录按钮
function LoginGameView:createButton_(image, text, color,  x, y, callback)
    local btn = cc.ui.UIPushButton.new({normal= image,pressed=image})
        :pos(x, y)
        :onButtonPressed(function(event)
            event.target:setColor(color)
        end)
        :onButtonRelease(function(event)
            event.target:setColor(cc.c3b(0xff,0xff, 0xff))
        end)
        :onButtonClicked(callback)
        :addTo(self.btnPanel_)
        
    return btn    
end

function LoginGameView:onEnter()
    local g = global_statistics_for_umeng
    g.umeng_view = g.Views.login
end

function LoginGameView:onExit()
    local g = global_statistics_for_umeng
    g.umeng_view = g.Views.other
end

function LoginGameView:playShowAnim()
    local animTime = self.controller_:getAnimTime()

    --transition.moveTo(self.pokerBatchNode_, {time = animTime, x = -display.cx})
    transition.moveTo(self.tableNode_, {time = animTime, x = 0})
end

function LoginGameView:setShowState()
    local animTime = self.controller_:getAnimTime()
    --self.pokerBatchNode_:setPositionX(-display.cx)
    transition.moveTo(self.tableNode_, {time = animTime, x = 0})
end

function LoginGameView:playHideAnim()
    local animTime = self.controller_:getAnimTime()

    --transition.moveTo(self.pokerBatchNode_, {time = animTime, x = -display.cx - 300})
    transition.moveTo(self.tableNode_, {
        time = animTime, 
        x = self.visibleTableWidth_, 
        onComplete = handler(self, function (obj)
            obj:removeFromParent()
        end)
    })
end

function LoginGameView:onFacebookBtnClick_()
    -- FB登录
    self.fbLoginBtn:setButtonEnabled(false)
    self.guestLoginBtn:setButtonEnabled(false)
    self.controller_:loginWithFacebook(self.fbLoginBtn, self.guestLoginBtn)
end

function LoginGameView:onGuestBtnClick_()
    -- 游客登录
    self.controller_:loginWithGuest()
end

function LoginGameView:playLoginAnim()
    self:playDotsAnimInLogin_()
    local animTime = self.controller_:getAnimTime()
    self.logoBatchNode_:stopAllActions()
    self.btnNode_:stopAllActions()
    if self.loadingLabel_ then
        self.loadingLabel_:removeFromParent()
        self.loadingLabel_ = nil
    end
    transition.moveTo(self.logoBatchNode_, {
        time = animTime, 
        y = -LOGO_POS_Y, 
    })
    transition.moveTo(self.btnNode_, {
        time = animTime, 
        x = display.cx + PANEL_WIDTH * 0.5, 
        onComplete = handler(self, function (obj)
            obj.loadingLabel_ = ui.newTTFLabel({text = bm.LangUtil.getText("LOGIN", "LOGINING_MSG"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 28, align = ui.TEXT_ALIGN_CENTER})
                :pos(LOGO_POS_X - display.width/15, LOGO_POS_Y - 264 * nk.heightScale - 50)
                :addTo(obj.tableNode_)
        end)
    })
end

function LoginGameView:playLoginFailAnim()
    self:playDotsAnimInNormal_()
    local animTime = self.controller_:getAnimTime()
    self.logoBatchNode_:stopAllActions()
    self.btnNode_:stopAllActions()
    transition.moveTo(self.logoBatchNode_, {
        time = animTime, 
        y = 0, 
    })
    transition.moveTo(self.btnNode_, {
        time = animTime, 
        x = 0, 
    })
    if self.loadingLabel_ then
        self.loadingLabel_:removeFromParent()
        self.loadingLabel_ = nil 
    end
end

function LoginGameView:playDotsAnimInLogin_()
    self:stopDotsAnim_()
    self.firstDotId_ = 1
    self.dotsSchedulerHandle_ = scheduler.scheduleGlobal(handler(self, function (obj)
        obj.dots_[obj.firstDotId_]:runAction(transition.sequence({
                cc.FadeTo:create(0.3, 255), 
                cc.FadeTo:create(0.3, 32),
            })
        )
        local secondDotId = obj.firstDotId_ + DOTS_NUM * 0.5
        if secondDotId > DOTS_NUM then
            secondDotId = secondDotId - DOTS_NUM
        end
        obj.dots_[secondDotId]:runAction(transition.sequence({
                cc.FadeTo:create(0.3, 255), 
                cc.FadeTo:create(0.3, 32), 
            })
        )
        obj.firstDotId_ = obj.firstDotId_ + 1
        if obj.firstDotId_ > DOTS_NUM then
            obj.firstDotId_ = 1
        end
    end), 0.05)
end

function LoginGameView:playDotsAnimInNormal_()
    self:stopDotsAnim_()
    for _, dot in ipairs(self.dots_) do
        dot:runAction(cc.RepeatForever:create(cc.Sequence:create(--create
                    cc.FadeTo:create(1, 128), 
                    cc.FadeTo:create(1, 0)
                )
            )
        )
    end
end

function LoginGameView:stopDotsAnim_()
    for _, dot in ipairs(self.dots_) do
        dot:opacity(0)
        dot:stopAllActions()
    end
    if self.dotsSchedulerHandle_ then
        scheduler.unscheduleGlobal(self.dotsSchedulerHandle_)
        self.dotsSchedulerHandle_ = nil
    end
end

function LoginGameView:loginFeedBackHandler_()
    LoginFeedBack.new():show()
end

function LoginGameView:onCleanup()
    if self.dotsSchedulerHandle_ then
        scheduler.unscheduleGlobal(self.dotsSchedulerHandle_)
        self.dotsSchedulerHandle_ = nil
    end
end

function LoginGameView:onPhpSelector_()
    DebugPopup.new():show()
end

function LoginGameView:onDebugTst_()
    -- DebugTstPopup.new():show()
end

return LoginGameView
