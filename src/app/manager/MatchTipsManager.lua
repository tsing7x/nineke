--
-- Author: johnny@boomegg.com
-- Date: 2014-07-31 16:47:47
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

--[[
    用法：
    1. 纯文本：nk.MatchTipsManager:showTopTip("我就是我，不一样的烟火")
    2. 文本加图标：nk.MatchTipsManager:showTopTip({text = "我就是我，不一样的花朵", image = display.newSprite("top_tip_icon.png")})
]]

local MatchTipsManager = class("MatchTipsManager")
local SimpleColorLabel = import("boomegg.ui.SimpleColorLabel")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local DEFAULT_STAY_TIME = 3
local X_GAP = 150
local Y_GAP = 0
local TIP_HEIGHT = 45
local LABEL_X_GAP = 16
local ICON_SIZE = 56
local LABEL_ROLL_VELOCITY = 80
local BG_CONTENT_SIZE = cc.size(display.width - X_GAP * 2, TIP_HEIGHT)
local Z_ORDER = 1001

function MatchTipsManager:ctor()
    -- 视图容器
    self.container_ = display.newNode()
    self.container_:retain()
    self.container_:setNodeEventEnabled(true)
    self.container_.onCleanup = handler(self, function (obj)
        -- 移除图标
        if obj.currentData_ and obj.currentData_.image and type(obj.currentData_.image) == "userdata" then
            obj.currentData_.image:release()
            obj.currentData_.image:removeFromParent()
        end
        -- 移除定时器
        if obj.delayScheduleHandle_ then
            scheduler.unscheduleGlobal(obj.delayScheduleHandle_)
            obj.delayScheduleHandle_ = nil
        end
        -- 移除延时影藏
        if obj.delayHideCancel_ then
            scheduler.unscheduleGlobal(obj.delayHideCancel_)
            obj.delayHideCancel_ = nil
        end
        -- 延迟一秒播放下一条
        scheduler.performWithDelayGlobal(function ()
            obj:playNext_()
        end, 1)
        print("container removed")
    end)

    -- 等待队列
    self.waitQueue_ = {}
    self.isPlaying_ = false
end

function MatchTipsManager:onBgTouch_(bg,evtName, ...)
    if evtName=="TOUCH_BEGIN" or evtName=="CLICK" then
        if self.currentData_.messageType==2000 then
            if self.delayHideCancel_ then
                scheduler.unscheduleGlobal(self.delayHideCancel_)
                self.delayHideCancel_ = nil
            end
            self.cancelBtn_:setVisible(true)
            self.delayHideCancel_ = scheduler.performWithDelayGlobal(handler(self, self.hideCancelBtn), 5)
        end
    end
end

function MatchTipsManager:onCancel_()
    -- nk.socket.BroadcastSocket.canReceiveMatchLaBa = false
    nk.socket.HallSocket.hallBroadcast_.canReceiveMatchLaBa = false
    self.waitQueue_ = {}
    self:onHideComplete_()
    self.cancelBtn_:onButtonClicked(handler(self,self.onCancel_))
end

function MatchTipsManager:clean()
    self.waitQueue_ = {}
    self:onHideComplete_()
end

function MatchTipsManager:hideCancelBtn()
    if self.delayHideCancel_ then
        scheduler.unscheduleGlobal(self.delayHideCancel_)
        self.delayHideCancel_ = nil
    end
    self.cancelBtn_:setVisible(false)
end

function MatchTipsManager:showTopTip(topTipData)
    assert(type(topTipData) == "table" or type(topTipData) == "string", "topTipData should be a table")
    if not self.tipBg_ then
        -- 背景
        self.tipBg_ = display.newScale9Sprite("#top_tip_bg.png", 0, 0, BG_CONTENT_SIZE)
            :addTo(self.container_)
        self.tipBg_:setVisible(false) -- 无用
        -- 内容
        self.content_ = display.newScale9Sprite("#top_tip_bg.png", 0, 0, BG_CONTENT_SIZE)
        self.content_:setOpacity(80) -- 半透明
        -- 添加事件
        bm.TouchHelper.new(self.content_, handler(self, self.onBgTouch_))
        -- 交互按钮
        self.cancelBtn_ = cc.ui.UIPushButton.new({normal= "#common_input_bg.png",pressed="#common_input_bg_down.png"},{scale9 = true})
            :setButtonSize(102, 36)
            :setButtonLabel(ui.newTTFLabel({text=bm.LangUtil.getText("MATCH", "MATCHTIPSCANCEL"), size=24, color=cc.c3b(0xff, 0xff, 0xff), align=ui.TEXT_ALIGN_CENTER}))
            :pos((BG_CONTENT_SIZE.width+102)/2-115,-(TIP_HEIGHT+36)/2)
            :addTo(self.container_)
        self.cancelBtn_:setVisible(false)

        -- 小的裁剪模板（文本 + 图标）
        self.smallStencil_ = display.newDrawNode()
        self.smallStencil_:drawPolygon({
            {-BG_CONTENT_SIZE.width * 0.5 + LABEL_X_GAP * 2 + ICON_SIZE, -BG_CONTENT_SIZE.height * 0.5}, 
            {-BG_CONTENT_SIZE.width * 0.5 + LABEL_X_GAP * 2 + ICON_SIZE,  BG_CONTENT_SIZE.height * 0.5}, 
            { BG_CONTENT_SIZE.width * 0.5 - LABEL_X_GAP,  BG_CONTENT_SIZE.height * 0.5}, 
            { BG_CONTENT_SIZE.width * 0.5 - LABEL_X_GAP, -BG_CONTENT_SIZE.height * 0.5}
        })
        self.smallStencil_:retain()

        -- 大的裁剪模板（文本）
        self.bigStencil_ = display.newDrawNode()
        self.bigStencil_:drawPolygon({
            {-BG_CONTENT_SIZE.width * 0.5 + LABEL_X_GAP, -BG_CONTENT_SIZE.height * 0.5}, 
            {-BG_CONTENT_SIZE.width * 0.5 + LABEL_X_GAP,  BG_CONTENT_SIZE.height * 0.5}, 
            { BG_CONTENT_SIZE.width * 0.5 - LABEL_X_GAP,  BG_CONTENT_SIZE.height * 0.5}, 
            { BG_CONTENT_SIZE.width * 0.5 - LABEL_X_GAP, -BG_CONTENT_SIZE.height * 0.5}
        })
        self.bigStencil_:retain()

        -- 裁剪容器
        self.clipNode_ = cc.ClippingNode:create():addTo(self.container_)
        self.clipNode_:setStencil(self.bigStencil_)

        self.content_:addTo(self.clipNode_)
        -- 文本
        self.label_ = ui.newTTFLabel({text = "", size = 28, align = ui.TEXT_ALIGN_CENTER})
            :addTo(self.content_)
    end

    if type(topTipData) == "string" then
        -- 过滤重复的消息
        if self.currentData_ and self.currentData_.text == topTipData then
            return
        end
        for _, v in pairs(self.waitQueue_) do
            if v.text == topTipData then
                return
            end
        end
        table.insert(self.waitQueue_, {text = topTipData})
    else
        -- 过滤重复的消息
        if self.currentData_ and self.currentData_.text == topTipData.text then
            return
        end
        for _, v in pairs(self.waitQueue_) do
            if v.text == topTipData.text then
                return
            end
        end
        if topTipData.image and type(topTipData.image) == "userdata" then
            topTipData.image:retain()
        end
        table.insert(self.waitQueue_, topTipData)
    end
    
    if not self.isPlaying_ then
        self:playNext_()
    end
end

function MatchTipsManager:playNext_()
    if self.waitQueue_[1] then
        self.currentData_ = table.remove(self.waitQueue_, 1)
    else
        -- 播放完毕
        self.isPlaying_ = false
        return
    end
    -- 重新设置事件
    self.cancelBtn_:onButtonClicked(handler(self,self.onCancel_))
    -- 设置文本和图标
    local topTipData = self.currentData_
    local scrollTime = 0
    if topTipData.text then
        self.label_:setString(topTipData.text)
        local labelWidth,labelHeight = self.label_:getContentSize().width,self.label_:getContentSize().height
        local startXPos = 0
        local endXPos = 0
        if topTipData.image and type(topTipData.image) == "userdata" then
            topTipData.image:pos(ICON_SIZE * 0.5 , TIP_HEIGHT*0.5):addTo(self.content_)
            -- 设置对应的裁剪模板
            self.clipNode_:setStencil(self.smallStencil_)
            -- 计算文本滚屏时间
            scrollTime = (labelWidth - (BG_CONTENT_SIZE.width - LABEL_X_GAP * 2 - LABEL_X_GAP - ICON_SIZE)) / LABEL_ROLL_VELOCITY
            if scrollTime>0 then
                -- scrollTime = scrollTime + (BG_CONTENT_SIZE.width - LABEL_X_GAP * 2 - LABEL_X_GAP - ICON_SIZE)/LABEL_ROLL_VELOCITY
                -- endXPos = labelWidth * 0.5 - BG_CONTENT_SIZE.width * 0.5 + LABEL_X_GAP*2 + ICON_SIZE - (labelWidth - (BG_CONTENT_SIZE.width - LABEL_X_GAP * 2 - LABEL_X_GAP - ICON_SIZE))
            else
                -- scrollTime = (BG_CONTENT_SIZE.width - LABEL_X_GAP * 2 - LABEL_X_GAP - ICON_SIZE - labelWidth)/LABEL_ROLL_VELOCITY
                -- endXPos = labelWidth * 0.5 - BG_CONTENT_SIZE.width * 0.5 + LABEL_X_GAP*2 + ICON_SIZE
            end
            self.content_:size(cc.size(labelWidth + ICON_SIZE,TIP_HEIGHT))

            scrollTime = (BG_CONTENT_SIZE.width + labelWidth)/LABEL_ROLL_VELOCITY
            endXPos = - BG_CONTENT_SIZE.width * 0.5 - labelWidth*0.5 + ICON_SIZE

            startXPos = labelWidth * 0.5 + BG_CONTENT_SIZE.width * 0.5 - LABEL_X_GAP
            self.content_:pos(startXPos, 0)
            self.label_:pos(labelWidth*0.5+ICON_SIZE,TIP_HEIGHT*0.5)
            transition.execute(self.content_, cc.MoveTo:create(scrollTime, cc.p(endXPos, 0)),{
                            onComplete = function ()
                                self:delayCallback_()
                            end
                        })
            --[[
            scrollTime = (labelWidth - (BG_CONTENT_SIZE.width - LABEL_X_GAP * 2 - LABEL_X_GAP - ICON_SIZE)) / LABEL_ROLL_VELOCITY
            if scrollTime > 0 then
                startXPos = labelWidth * 0.5 - BG_CONTENT_SIZE.width * 0.5 + LABEL_X_GAP + LABEL_X_GAP + ICON_SIZE
                self.label_:pos(startXPos, 0)
                transition.execute(self.label_, cc.MoveTo:create(scrollTime, cc.p(-startXPos + LABEL_X_GAP + ICON_SIZE, 0)), {delay = 1.5})
            else
                scrollTime = 0
                self.label_:pos((LABEL_X_GAP * 2 + ICON_SIZE) * 0.5, 0)
            end
            --]]
        else
            -- 设置对应的裁剪模板
            self.clipNode_:setStencil(self.bigStencil_)
            scrollTime = (labelWidth - (BG_CONTENT_SIZE.width - LABEL_X_GAP * 2)) / LABEL_ROLL_VELOCITY
            if scrollTime>0 then
                -- scrollTime = scrollTime + (BG_CONTENT_SIZE.width - LABEL_X_GAP * 2)/LABEL_ROLL_VELOCITY
                -- endXPos = - BG_CONTENT_SIZE.width * 0.5 + LABEL_X_GAP + labelWidth * 0.5 - (labelWidth - (BG_CONTENT_SIZE.width - LABEL_X_GAP * 2))
            else
                -- scrollTime = (BG_CONTENT_SIZE.width - LABEL_X_GAP * 2 - labelWidth)/LABEL_ROLL_VELOCITY
                -- endXPos = - BG_CONTENT_SIZE.width * 0.5 + LABEL_X_GAP + labelWidth * 0.5 + 10
            end
            self.content_:size(cc.size(labelWidth,TIP_HEIGHT))
            scrollTime = (BG_CONTENT_SIZE.width + labelWidth)/LABEL_ROLL_VELOCITY
            endXPos = - BG_CONTENT_SIZE.width * 0.5 - labelWidth*0.5

            startXPos = labelWidth * 0.5 + BG_CONTENT_SIZE.width * 0.5 - LABEL_X_GAP
            -- self.label_:pos(startXPos, 0)
            self.content_:pos(startXPos, 0)
            self.label_:pos(labelWidth*0.5,TIP_HEIGHT*0.5)
            transition.execute(self.content_, cc.MoveTo:create(scrollTime, cc.p(endXPos, 0)),{
                            onComplete = function ()
                                self:delayCallback_()
                            end
                        })
            -- 计算文本滚屏时间
            --[[
            scrollTime = (labelWidth - (BG_CONTENT_SIZE.width - LABEL_X_GAP * 2)) / LABEL_ROLL_VELOCITY
            if scrollTime > 0 then
                startXPos = labelWidth * 0.5 - BG_CONTENT_SIZE.width * 0.5 + LABEL_X_GAP
                self.label_:pos(startXPos, 0)
                transition.execute(self.label_, cc.MoveTo:create(scrollTime, cc.p(-startXPos, 0)), {delay = DEFAULT_STAY_TIME * 0.5})
            else
                scrollTime = 0
                self.label_:pos(0, 0)
            end
            --]]
        end
    end    

    -- 下滑动画
    self.isPlaying_ = true
    self.container_:pos(display.cx, display.cy+70)
        :addTo(nk.runningScene, Z_ORDER)
     transition.fadeIn(self.container_, {
            time = 0.3
        })

    -- 移除tip定时器
    -- self.delayScheduleHandle_ = scheduler.performWithDelayGlobal(handler(self, self.delayCallback_), 0.3 + DEFAULT_STAY_TIME + scrollTime)

    local getFrame = display.newSpriteFrame
    if topTipData.messageType == 1000 then
        self.label_:setTextColor(cc.c3b(0xff, 0xae, 0x70))
        self.tipBg_:setSpriteFrame(getFrame("common-da-laba-top-tip-icon.png"))
        self.tipBg_:setContentSize(display.width - X_GAP * 2, TIP_HEIGHT)
        self.tipBg_:setVisible(false)
    else
        self.label_:setTextColor(cc.c3b(0xff, 0xff, 0xff))
        self.tipBg_:setSpriteFrame(getFrame("top_tip_bg.png"))
        self.tipBg_:setContentSize(display.width - X_GAP * 2, TIP_HEIGHT)
        self.tipBg_:setVisible(false)
    end
    if topTipData.messageType==2000 then--and nk.socket.BroadcastSocket.isFirstShowMatchLaBa then
        -- nk.socket.BroadcastSocket.isFirstShowMatchLaBa = false
        nk.socket.HallSocket.hallBroadcast_.isFirstShowMatchLaBa = false
        self:onBgTouch_(nil,"CLICK")
        self.tipBg_:setTouchEnabled(true)
        self.tipBg_:setTouchSwallowEnabled(true)
    else
        self.cancelBtn_:setVisible(false)
        self.tipBg_:setTouchEnabled(false)
        self.tipBg_:setTouchSwallowEnabled(false)
    end
end

function MatchTipsManager:delayCallback_()
    self.delayScheduleHandle_ = nil
    if self.container_:getParent() then
        transition.fadeOut(self.container_, {
                time = 0.3,
                onComplete = handler(self, self.onHideComplete_),
            })

        -- transition.moveTo(self.container_, {
        --     x = display.cx, 
        --     y = display.top + TIP_HEIGHT * 0.5, 
        --     time = 0.3, 
        --     onComplete = handler(self, self.onHideComplete_), 
        -- })
    else
        self.container_:pos(display.cx, display.top + TIP_HEIGHT * 0.5)
        self:onHideComplete_()
    end
end

function MatchTipsManager:onHideComplete_()
    self.currentData_ = nil
    self.container_:removeFromParent()
end

return MatchTipsManager