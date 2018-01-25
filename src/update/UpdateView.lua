--
-- Author: Devin
-- Date: 2014-10-09 15:34:33
-- 更新展现界面

local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local upd = require("update.init")

local UpdateView = class("UpdateView", function ()
    return display.newNode()
end)

local DOTS_NUM         = 30

local LOGO_POS_X  = display.cx - 300
local LOGO_POS_Y  = 0
local LOGO_RADIUS = 94
local LOGO_SCALE  = 1

local PRO_POS_X = display.cx * 0.5 + 20
local PRO_POS_Y = -display.cy + 133
local PRO_WIDTH = 400
local PRO_HEIGHT = 12

function UpdateView:ctor(scaleNum)
    self:setNodeEventEnabled(true)
    -- 背景
    display.newSprite("main_hall_bg.png")
        :scale(scaleNum)
        :addTo(self,0)

    --display.addSpriteFrames("update_texture.plist", "update_texture.png")
    display.addSpriteFrames("NewLogin.plist", "NewLogin.png")

    --添加桌子
    self:addTableNode_()
    
    -- 游戏logo
    self:addLogoBatchNode_()
    
    --进度条
    PRO_WIDTH = PRO_WIDTH
    self.progress = display.newScale9Sprite("#update_proBg.png")
    self.progress:addTo(self)
    self.progress:pos(PRO_POS_X,PRO_POS_Y)
    self.progress:setContentSize(cc.size(PRO_WIDTH,PRO_HEIGHT))
    self.progressBar = display.newScale9Sprite("#update_proBar.png"):addTo(self.progress)
    self.progressBar:setAnchorPoint(0,0.5)
    self.progressBar:setPosition(0,PRO_HEIGHT/2)
    self.prolight = display.newSprite("#update_Prolight.png")
    self.prolight:setAnchorPoint(0,0.5)
    self.prolight:addTo(self.progressBar)

    self.progressLabel = ui.newTTFLabel({
            text = "",
            size = 21,
            color = cc.c3b(255, 255, 255),
            align = ui.TEXT_ALIGN_CENTER,
            x = LOGO_POS_X + 94 / 2 - 50, 
            y = PRO_POS_Y + 30
        })
        self:addChild(self.progressLabel)

    self.speedLabel = ui.newTTFLabel({
            text = "",
            size = 18,
            color = cc.c3b(81, 169, 236),
            align = ui.TEXT_ALIGN_LEFT,
            x = PRO_POS_X - PRO_WIDTH/2, 
            y = PRO_POS_Y - 20
        })
        self:addChild(self.speedLabel)

    self.totalLabel = ui.newTTFLabel({
            text = "",
            size = 18,
            color = cc.c3b(81, 169, 236),
            align = ui.TEXT_ALIGN_RIGHT,
            x = PRO_POS_X + PRO_WIDTH/2, 
            y = PRO_POS_Y - 30
        })
        self:addChild(self.totalLabel)
    self:setProgress(0)

    -- poker girl
    display.addSpriteFrames("NewWomen.plist","NewWomen.png")
    
    self.pokerGirlBatchNode_ = display.newBatchNode("NewWomen.png")
        :addTo(self)
    local women = display.newSprite("#NewWomen.png")
        :addTo(self.pokerGirlBatchNode_)
        :schedule(handler(self, self.pokerGirlBlink_), 2)
    self.pokerGirlBatchNode_:pos(-0.25 * display.cx - 140, -20):scale(scaleNum)

    -- copyright
    self.copyrightLabel_ = ui.newTTFLabel({
        text = "", 
        color = cc.c3b(0x99, 0x92, 0xb0), 
        size = 18, 
        align = ui.TEXT_ALIGN_CENTER})
        :align(display.RIGHT_BOTTOM, display.cx - 60, -(display.cy - 15))
        :addTo(self)

    self:playDotsAnim()
end

--添加桌子
function UpdateView:addTableNode_()
    self.tableNode_ = display.newNode()
        :addTo(self)

    local s = display.height / 640
    local gameTable = display.newNode()
        :addTo(self.tableNode_)


    local bg = display.newSprite("#NewLogin_LoginBackGround.png")
        :addTo(gameTable)
    bg:setScaleX(0.9)
    bg:setScaleY(0.9)

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
    self.tableNode_:pos(0, 0)
end

-- 游戏logo
function UpdateView:addLogoBatchNode_()
    self.logoBatchNode_ = display.newBatchNode("NewLogin.png")
        :addTo(self.tableNode_)
    -- 圆点
    self.dots_ = {}
    for i = 1, DOTS_NUM do
        self.dots_[i] = display.newSprite("#NewLogin_dot.png")
        :pos(
                LOGO_POS_X + math.sin((i - 1) * math.pi / 15) * LOGO_RADIUS * LOGO_SCALE - 35, 
                LOGO_POS_Y + math.cos((i - 1) * math.pi / 15) * LOGO_RADIUS * LOGO_SCALE
            )
        :opacity(0)
        :addTo(self.logoBatchNode_)
    end
    
    -- 游戏logo
    local log = display.newSprite("#NewLogin_Loading.png")
        :pos(LOGO_POS_X - 35, LOGO_POS_Y)
        :addTo(self.logoBatchNode_)
        :scale(LOGO_SCALE)
    log:setScaleX(0.8)
    log:setScaleY(0.8)
end

-- poker girl眨眼动画
function UpdateView:pokerGirlBlink_()
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

function UpdateView:playLeaveScene(callback)
    self.progressLabel:setVisible(false)
    transition.moveTo(self.tableNode_, {x=display.right + display.width * 0.5, time=0.5, onComplete =callback})
end

function UpdateView:playDotsAnim()
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

function UpdateView:stopDotsAnim_()
    for _, dot in ipairs(self.dots_) do
        dot:opacity(0)
        dot:stopAllActions()
    end
    if self.dotsSchedulerHandle_ then
        scheduler.unscheduleGlobal(self.dotsSchedulerHandle_)
        self.dotsSchedulerHandle_ = nil
    end
end

function UpdateView:onCleanup()
    self:stopDotsAnim_()
    if self.dotsSchedulerHandle_ then
        scheduler.unscheduleGlobal(self.dotsSchedulerHandle_)
        self.dotsSchedulerHandle_ = nil
    end
end

--资源总大小文本框
function UpdateView:setTotalLabel(total)
    self.totalLabel:setString(upd.lang.getText("UPDATE", "DOWNLOAD_SIZE", total))
    self.totalLabel:pos(PRO_POS_X + PRO_WIDTH/2 - self.totalLabel:getContentSize().width/2,PRO_POS_Y - 20)
end

--tips文字
function UpdateView:setTipsLabel(msg)
    self.progressLabel:setVisible(true)
    self.progressLabel:setString(msg)
end

--设置版本号
function UpdateView:setVersion(version)
    if version and #(string.split(version, ".")) == 3 then
        version = version .. ".0"
    end
    local ver = upd.lang.getText("UPDATE", "COPY_RIGHT") .. "V" .. version
    self.copyrightLabel_:setString(ver)
end

--设置进度条是否可见
function UpdateView:setBarVisible(bool)
    self.progress:setVisible(bool)
    self.progressLabel:setVisible(bool)
    self.speedLabel:setVisible(bool)
    self.totalLabel:setVisible(bool)
end

local proLines = {}
--设置进度条，坐标为左对齐
local lastProNum
local lastSpeed
function UpdateView:setProgress(proNum,speed)
    if proNum > 1 then
        proNum = 1
    end
    if speed ~= lastSpeed then
        lastSpeed = speed
        if speed then
            self.speedLabel:setString(upd.lang.getText("UPDATE", "SPEED", speed))
            self.speedLabel:pos(PRO_POS_X - PRO_WIDTH/2 + self.speedLabel:getContentSize().width/2,PRO_POS_Y - 20)
        end
    end
    if lastProNum == proNum then
        return
    end
    lastProNum = proNum
    if proNum > 0 then
        self:setTipsLabel(upd.lang.getText("UPDATE", "DOWNLOAD_PROGRESS", checkint(proNum * 100)))
    else
        --self:setTipsLabel("")
    end

    local wid = PRO_WIDTH*proNum
    if proNum <= 0 then
        self.progressBar:setVisible(false)
        return
    else
        self.progressBar:setVisible(true)
        if wid <= 36 then
            self.prolight:pos(19,6)
        else
            self.prolight:pos(wid - 17,6)
        end
    end

    local curLines = checkint((wid - 15)/27)
    local lines = #proLines
    if curLines > #proLines then
        lines = curLines
    end
    for i = 1,lines do
        if curLines>=i then
            if not proLines[i] then
                proLines[i] = display.newSprite("#update_ProLines.png")
                proLines[i]:setAnchorPoint(0,0)
                proLines[i]:addTo(self.progressBar)
            end
            proLines[i]:pos(27*(i - 1) + 15, 0)
        elseif proLines[i] then
            proLines[i]:removeFromParent()
            proLines[i] = nil
        end
    end
    if wid <= 36 then
        wid = 36
    end
    self.progressBar:setContentSize(cc.size(wid,PRO_HEIGHT))
end

return UpdateView
