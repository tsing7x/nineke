--
-- Author: johnny@boomegg.com
-- Date: 2014-08-17 16:24:13
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

--[[
    bm.ui.ScrollView.new {
        viewRect = cc.rect(-480, -160, 960, 320),
        direction = bm.ui.ScrollView.DIRECTION_VERTICAL, 
        scrollContent = display.newSprite("main_hall_bg.jpg")
    }
        :addTo(self)
]]

local ScrollView = class("ScrollView", function ()
    return cc.ClippingRegionNode:create()
end)

ScrollView.DIRECTION_VERTICAL   = 1
ScrollView.DIRECTION_HORIZONTAL = 2
ScrollView.DIRECTION_UP         = 3
ScrollView.DIRECTION_DOWN       = 4
ScrollView.DIRECTION_LEFT       = 5
ScrollView.DIRECTION_RIGHT      = 6
ScrollView.OUT_TOP              = 7
ScrollView.OUT_BOTTOM           = 8
ScrollView.INSIDE               = 9
ScrollView.SCROLL_NORMAL        = 10
ScrollView.SCROLL_BACK          = 11
ScrollView.COUNT_STAY           = 12

ScrollView.SPEED_ADJUST_RATE = 50   -- 调速系数，调节松开鼠标后的移动速度
ScrollView.MAX_STAY_TIME     = 6    -- 最大停留时间
ScrollView.EASING            = 0.92 -- 缓动系数
ScrollView.MAX_SPEED         = 50   -- 最大速度
ScrollView.MIN_SPEED         = 1    -- 最小速度

ScrollView.EVENT_SCROLL_BEGIN = "ScrollView.EVENT_SCROLL_BEGIN"
ScrollView.EVENT_SCROLL_END   = "ScrollView.EVENT_SCROLL_END"
ScrollView.EVENT_SCROLLING    = "ScrollView.EVENT_SCROLLING"

ScrollView.defaultScrollBarFactory = nil -- 默认scrollBar工厂

function ScrollView:ctor(params)
    self:setNodeEventEnabled(true)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

    if params and params.viewRect then
        self:setViewRect(params.viewRect)
    end

    if params and  params.scrollLength then
        self:setScrollLength(params.scrollLength)
    end

    if params and  params.direction then
        self:setDirection(params.direction)
    else
        self:setDirection(ScrollView.DIRECTION_VERTICAL)
    end

    if params and  params.scrollContent then
        self:setScrollContent(params.scrollContent)
    end

    if params and  params.scrollBar then
        self:setScrollBar(params.scrollBar)
    else
        self:setScrollBar(ScrollView.defaultScrollBarFactory(self.direction_))
    end

    if params and params.upRefresh then
        self:setUpRefresh(params.upRefresh)
    end

    -- 当前位置
    self.currentPlace_ = 0
    self.bottomPlace_ = 0
    self.outFlag_ = ScrollView.INSIDE
    self.showScrollBar_ = true
end

function ScrollView:onTouch_(evt)
    local name, curX, curY, prevX, prevY = evt.name, evt.x, evt.y, evt.prevX, evt.prevY
    if name == "began" and not self:isTouchInViewRect_(evt) then
        return false
    end

    if name == "began" then
        -- 设置数据
        self.srcTouchX_ = curX
        self.srcTouchY_ = curY
        self.srcTime_ = bm.getTime()
        self.srcPlace_ = self.currentPlace_
        self.scrollFlag_ = ScrollView.COUNT_STAY
        self.stayTime_ = 0
        self.stayPlace_ = self.currentPlace_ + 1

        -- 开启帧频回调
        self.scrollContent_:unscheduleUpdate()
        self.scrollContent_:scheduleUpdate()

        -- 渐显滚动条
        if self.scrollBar_ and self.scrollBar_:isVisible() then
            self.scrollBar_:opacity(255)
            self.scrollBar_:stopAllActions()
        end

        -- 派发开始事件
        self:dispatchEvent({name = ScrollView.EVENT_SCROLL_BEGIN})

        return true
    elseif name == "moved" then
        -- 设置数据
        self.destTouchX_ = curX
        self.destTouchY_ = curY

        if self.direction_ == ScrollView.DIRECTION_VERTICAL then
            self.currentPlace_ = self.srcPlace_ + self.destTouchY_ - self.srcTouchY_
        elseif self.direction_ == ScrollView.DIRECTION_HORIZONTAL then
            self.currentPlace_ = self.srcPlace_ + self.destTouchX_ - self.srcTouchX_
        end

        -- 检查越界，若越界，则减速
        self:checkContentOut_()
        if self.outFlag_ ~= ScrollView.INSIDE then
            if self.direction_ == ScrollView.DIRECTION_VERTICAL then
                if self.outFlag_ == ScrollView.OUT_TOP then
                    self.currentPlace_ = self.topPlace_ + (self.currentPlace_ - self.topPlace_) * 0.25
                elseif self.outFlag_ == ScrollView.OUT_BOTTOM then
                    self.currentPlace_ = self.bottomPlace_ - (self.bottomPlace_ - self.currentPlace_) * 0.25
                end
            elseif self.direction_ == ScrollView.DIRECTION_HORIZONTAL then
                if self.outFlag_ == ScrollView.OUT_TOP then
                    self.currentPlace_ = self.topPlace_ - (self.topPlace_ - self.currentPlace_) * 0.25
                elseif self.outFlag_ == ScrollView.OUT_BOTTOM then
                    self.currentPlace_ = self.bottomPlace_ + (self.currentPlace_ - self.bottomPlace_) * 0.25
                end
            end
        end

        -- 开始滚动
        if self.currentPlace_ ~= self.srcPlace_ then
            self:startScroll_()
        end
    elseif name == "ended" or name == "cancelled" then
        -- 关闭帧频回调
        self.scrollContent_:unscheduleUpdate()

        -- 设置数据
        self.destTouchX_ = curX
        self.destTouchY_ = curY
        self.destTime_ = bm.getTime()

        -- 计算拖动时间，根据移动方向，计算速度
        local dragTime = self.destTime_ - self.srcTime_
        local dragDistance = 0
        if self.direction_ == ScrollView.DIRECTION_VERTICAL then
            dragDistance = self.destTouchY_ - self.srcTouchY_
            self.speed_ = dragDistance / (dragTime * 1000) * ScrollView.SPEED_ADJUST_RATE
            if self.speed_ > 0 then
                self.scrollDirection_ = ScrollView.DIRECTION_UP
            elseif self.speed_ < 0 then
                self.scrollDirection_ = ScrollView.DIRECTION_DOWN
            end
            self.speed_ = math.abs(self.speed_)
        elseif self.direction_ == ScrollView.DIRECTION_HORIZONTAL then
            dragDistance = self.destTouchX_ - self.srcTouchX_
            self.speed_ = dragDistance / (dragTime * 1000) * ScrollView.SPEED_ADJUST_RATE
            if self.speed_ > 0 then
                self.scrollDirection_ = ScrollView.DIRECTION_RIGHT
            elseif self.speed_ < 0 then
                self.scrollDirection_ = ScrollView.DIRECTION_LEFT
            end
            self.speed_ = math.abs(self.speed_)
        end

        -- 检查越界，若越界，则启动回移
        self:checkContentOut_()
        if self.outFlag_ ~= ScrollView.INSIDE then
            self:startBack_()
        else
            if self.stayTime_ <= ScrollView.MAX_STAY_TIME and self.speed_ ~= 0 then
                self:fixSpeed_()
                self.scrollFlag_ = ScrollView.SCROLL_NORMAL
                -- 开启帧频回调
                self.scrollContent_:scheduleUpdate()
            else
                self:startScroll_()
                -- 渐隐滚动条
                self:fadeOutScrollBar_()
            end
        end
    end
end

function ScrollView:onEnterFrame_(dt)
    if self.scrollFlag_ == ScrollView.COUNT_STAY then
        self:countStay_()
    elseif self.scrollFlag_ == ScrollView.SCROLL_NORMAL then
        self:scrollNormal_()
    elseif self.scrollFlag_ == ScrollView.SCROLL_BACK then
        self:scrollBack_()
    end
end

function ScrollView:isTouchInViewRect_(event)
    local viewRect = self:convertToWorldSpace(cc.p(self.viewRect_.x, self.viewRect_.y))
    viewRect.width = self.viewRect_.width
    viewRect.height = self.viewRect_.height

    return cc.rectContainsPoint(viewRect, cc.p(event.x, event.y))
end

function ScrollView:checkContentOut_()
    if self.direction_ == ScrollView.DIRECTION_VERTICAL then
        if self.currentPlace_ > self.topPlace_ then --向上滑动，最大偏移为scrollContent_与viewRect_高度差，正数
            self.outFlag_ = ScrollView.OUT_TOP
        elseif self.currentPlace_ < self.bottomPlace_ then --向下滑动，最大偏移为0，初始位置
            self.outFlag_ = ScrollView.OUT_BOTTOM
        else
            self.outFlag_ = ScrollView.INSIDE
        end
    elseif self.direction_ == ScrollView.DIRECTION_HORIZONTAL then
        if self.currentPlace_ < self.topPlace_ then
            self.outFlag_ = ScrollView.OUT_TOP
        elseif self.currentPlace_ > self.bottomPlace_ then
            self.outFlag_ = ScrollView.OUT_BOTTOM
        else
            self.outFlag_ = ScrollView.INSIDE
        end
    end
end

function ScrollView:countStay_()
    if self.stayPlace_ == self.currentPlace_ then
        self.stayTime_ = self.stayTime_ + 1
    else
        self.stayPlace_ = self.currentPlace_
    end
end

function ScrollView:scrollBack_()
    if self.outFlag_ == ScrollView.OUT_TOP then
        -- 上越界，改变位置，若已移到边界，则停止移动
        self:changePlace_()
        self:slowDown_()

        if (self.direction_ == ScrollView.DIRECTION_VERTICAL and self.currentPlace_ <= self.topPlace_) or 
        (self.direction_ == ScrollView.DIRECTION_HORIZONTAL and self.currentPlace_ >= self.topPlace_) then
            self.currentPlace_ = self.topPlace_
            -- 关闭帧频回调
            self.scrollContent_:unscheduleUpdate()
            -- 渐隐滚动条
            self:fadeOutScrollBar_()
            if self.upRefreshCallback_ then
                self.upRefreshCallback_()
            end
        end
        self:startScroll_()
    elseif self.outFlag_ == ScrollView.OUT_BOTTOM then
        -- 下越界，改变位置，若已移到边界，则停止移动
        self:changePlace_()
        self:slowDown_()

        if (self.direction_ == ScrollView.DIRECTION_VERTICAL and self.currentPlace_ >= self.bottomPlace_) or 
        (self.direction_ == ScrollView.DIRECTION_HORIZONTAL and self.currentPlace_ <= self.bottomPlace_) then
            self.currentPlace_ = self.bottomPlace_
            -- 关闭帧频回调
            self.scrollContent_:unscheduleUpdate()
            -- 渐隐滚动条
            self:fadeOutScrollBar_()
        end
        self:startScroll_()
    else
        -- 关闭帧频回调
        self.scrollContent_:unscheduleUpdate()
        -- 渐隐滚动条
        self:fadeOutScrollBar_()
    end
end

function ScrollView:scrollNormal_()
    -- 改变位置，检测越界
    self:changePlace_()
    self:startScroll_()
    self:checkContentOut_()

     -- 若越界，则速度下降
    if self.outFlag_ ~= ScrollView.INSIDE then
        self.speed_ = self.speed_ * 0.4
    end

     -- 若达到最小速度，则停止继续移动，否则减速移动
     if self.speed_ <= ScrollView.MIN_SPEED then
         -- 关闭帧频回调
        self.scrollContent_:unscheduleUpdate()
        
        -- 若出界，则启动回移
        if self.outFlag_ ~= ScrollView.INSIDE then
            self:startBack_()
        else
            -- 渐隐滚动条
            self:fadeOutScrollBar_()
        end
    else
        self:slowDown_()
    end
end

function ScrollView:startScroll_()
    if self.direction_ == ScrollView.DIRECTION_VERTICAL then
        -- 设置滚动容器的位置
        self.scrollContent_:setPositionY(self.currentPlace_ + self.srcContentPlace_)
        -- 设置滚动条的位置
        if self.scrollBar_ and self.scrollBar_:isVisible() then
            local posY = self.scrollBarScrollLength_ * 0.5 - self.currentPlace_ / self.scrollLength_ * self.scrollBarScrollLength_
            if posY < -self.scrollBarScrollLength_ * 0.5 then
                posY = -self.scrollBarScrollLength_ * 0.5
            elseif posY > self.scrollBarScrollLength_ * 0.5 then
                posY = self.scrollBarScrollLength_ * 0.5
            end
            self.scrollBar_:setPositionY(posY)
        end
    elseif self.direction_ == ScrollView.DIRECTION_HORIZONTAL then
        -- 设置滚动容器的位置
        self.scrollContent_:setPositionX(self.currentPlace_ + self.srcContentPlace_)
        -- 设置滚动条的位置
        if self.scrollBar_ and self.scrollBar_:isVisible() then
            local posX = -self.scrollBarScrollLength_ * 0.5 - self.currentPlace_ / self.scrollLength_ * self.scrollBarScrollLength_
            if posX < -self.scrollBarScrollLength_ * 0.5 then
                posX = -self.scrollBarScrollLength_ * 0.5
            elseif posX > self.scrollBarScrollLength_ * 0.5 then
                posX = self.scrollBarScrollLength_ * 0.5
            end
            self.scrollBar_:setPositionX(posX)
        end
    end

    -- 派发进行事件
    if not self.isNotHide_ then
        self:onScrolling()
    end
    self:dispatchEvent({name = ScrollView.EVENT_SCROLLING})
end

function ScrollView:startBack_()
    if self.direction_ == ScrollView.DIRECTION_VERTICAL then
        if self.outFlag_ == ScrollView.OUT_TOP then
            self.speed_ = (self.currentPlace_ - self.topPlace_) / 8
            self.scrollDirection_ = ScrollView.DIRECTION_DOWN
        elseif self.outFlag_ == ScrollView.OUT_BOTTOM then
            self.speed_ = (self.bottomPlace_ - self.currentPlace_) / 8
            self.scrollDirection_ = ScrollView.DIRECTION_UP
        end
    elseif self.direction_ == ScrollView.DIRECTION_HORIZONTAL then
        if self.outFlag_ == ScrollView.OUT_TOP then
            self.speed_ = (self.topPlace_ - self.currentPlace_) / 8
            self.scrollDirection_ = ScrollView.DIRECTION_RIGHT
        elseif self.outFlag_ == ScrollView.OUT_BOTTOM then
            self.speed_ = (self.currentPlace_ - self.bottomPlace_) / 8
            self.scrollDirection_ = ScrollView.DIRECTION_LEFT
        end
    end

    -- 开启帧频回调，启动回移
    self.scrollContent_:scheduleUpdate()
    self.scrollFlag_ = ScrollView.SCROLL_BACK
end

function ScrollView:changePlace_()
    if self.scrollDirection_ == ScrollView.DIRECTION_UP then
        self.currentPlace_ = self.currentPlace_ + self.speed_
    elseif self.scrollDirection_ == ScrollView.DIRECTION_DOWN then
        self.currentPlace_ = self.currentPlace_ - self.speed_
    elseif self.scrollDirection_ == ScrollView.DIRECTION_LEFT then
        self.currentPlace_ = self.currentPlace_ - self.speed_
    elseif self.scrollDirection_ == ScrollView.DIRECTION_RIGHT then
        self.currentPlace_ = self.currentPlace_ + self.speed_
    end
end

function ScrollView:fixCurrentPlace_()
    if (self.direction_ == ScrollView.DIRECTION_VERTICAL and self.currentPlace_ >= self.topPlace_) or 
    (self.direction_ == ScrollView.DIRECTION_HORIZONTAL and self.currentPlace_ <= self.topPlace_) then
        self.currentPlace_ = self.topPlace_
    end
    if (self.direction_ == ScrollView.DIRECTION_VERTICAL and self.currentPlace_ <= self.bottomPlace_) or 
    (self.direction_ == ScrollView.DIRECTION_HORIZONTAL and self.currentPlace_ >= self.bottomPlace_) then
        self.currentPlace_ = self.bottomPlace_
    end
end

function ScrollView:fixSpeed_()
    if self.speed_ < ScrollView.MIN_SPEED then
        self.speed_ = ScrollView.MIN_SPEED
    elseif self.speed_ > ScrollView.MAX_SPEED then
        self.speed_ = ScrollView.MAX_SPEED
    end
end

function ScrollView:slowDown_()
    if self.speed_ * ScrollView.EASING > ScrollView.MIN_SPEED then
        self.speed_ = self.speed_ * ScrollView.EASING
    else
        self.speed_ = ScrollView.MIN_SPEED
    end
end

-- 设置遮罩视窗尺寸
function ScrollView:setViewRect(rect)
    self:setClippingRegion(rect)
    self.viewRect_ = rect

    if SHOW_SCROLLVIEW_BORDER then
        display.newRect(rect.width, rect.height, {borderColor = cc.c4f(1.0, 0.0, 0.0, 1.0), borderWidth = 1})
            :align(display.LEFT_BOTTOM, rect.x, rect.y)
            :addTo(self)
    end
    
    return self
end

-- 设置滑动方向
function ScrollView:setDirection(direction)
    self.direction_ = direction
    return self
end

-- 设置滑动范围
function ScrollView:setScrollLength(length)
    self.scrollLength_ = length
    -- 滑动范围<0，则滑动内容尺寸小于遮罩视窗
    if self.scrollLength_ < 0 then
        self.scrollLength_ = 0
    end
    -- 计算滑动上界值
    if self.direction_ == ScrollView.DIRECTION_VERTICAL then
        self.topPlace_ = self.scrollLength_
    elseif self.direction_ == ScrollView.DIRECTION_HORIZONTAL then
        self.topPlace_ = -self.scrollLength_
    end

    return self
end

function ScrollView:setScrollContent(content)
    if self.scrollContent_ then
        if self.scrollContent_ == content then
            self:resetScrollContentCascadeBoundingBox_()
            self.scrollContent_:removeAllNodeEventListeners()
        else
            self.scrollContent_:removeFromParent()
        end
    end

    -- 设置滚动容器
    self.scrollContent_ = content
    if not self.scrollContent_:getParent() then
        self:addChild(self.scrollContent_)
    end

    local contentSize = self.scrollContent_:getContentSize() or cc.size()
    local casRect = self:getScrollContentCascadeBoundingBox_() or cc.rect()
    local useContentSize = contentSize.height > 0
    if self.direction_ == ScrollView.DIRECTION_VERTICAL then
        self.srcContentPlace_ = (self.viewRect_.height - (useContentSize and contentSize.height or casRect.height)) * 0.5
        self.scrollContent_:pos(0, self.srcContentPlace_)
    elseif self.direction_ == ScrollView.DIRECTION_HORIZONTAL then
        local contentDW = contentSize.width or 0;
        local casRectDW = casRect.wdith or 0;
        local viewDW = self.viewRect_.width or 0;
        self.srcContentPlace_ = ((useContentSize and contentDW or casRectDW) - viewDW) * 0.5
        self.scrollContent_:pos(self.srcContentPlace_, 0)
    end
    self.scrollContent_:setTouchEnabled(true)
    self.scrollContent_:setTouchSwallowEnabled(false)
    self.scrollContent_:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function (evt)
        if evt.name == "began" then
            if not self:isTouchInViewRect_(evt) then
                return false
            else
                return true
            end   
        end
    end)--修复BUG，之前不在viewRect范围内的按钮，也可以点击

    self.scrollContent_:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.onEnterFrame_))
    
    local node
    if self.touchNode_ then
        node = self.touchNode_
    else
        node = display.newNode()
        self.touchNode_ = node
        node:setTouchSwallowEnabled(true)
        node:setTouchEnabled(true)
        node:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouch_))

        self:addChild(node, -99)
    end
    node:setContentSize(self.viewRect_.width, self.viewRect_.height)
    node:setPosition(self.viewRect_.x, self.viewRect_.y)

    -- 计算可滑动范围
    if self.direction_ == ScrollView.DIRECTION_VERTICAL then
        self:setScrollLength((useContentSize and contentSize.height or casRect.height)- self.viewRect_.height)
    elseif self.direction_ == ScrollView.DIRECTION_HORIZONTAL then
        self:setScrollLength((useContentSize and contentSize.width or casRect.height) - self.viewRect_.width)
    end

    return self
end

-- 设置滚动条
function ScrollView:setScrollBar(scrollBar)
    if self.scrollBar_ and  self.scrollBar_ ~= scrollBar then
        self.scrollBar_:removeFromParent()
    end

    -- 设置滚动条
    self.scrollBar_ = scrollBar
    self.scrollBar_:opacity(0)
    if not self.scrollBar_:getParent() then
        self:addChild(self.scrollBar_, 1)
    end
    if not self.srcScrollBarSize_ then
        self.srcScrollBarSize_ = self.scrollBar_:getContentSize()
    end

    local barScale = 1
    local scrollBarSize = cc.size(self.srcScrollBarSize_.width, self.srcScrollBarSize_.height)
    if self.direction_ == ScrollView.DIRECTION_VERTICAL then
        if self.scrollLength_ and self.scrollLength_ > 0 and self.showScrollBar_ then
            -- 计算滚动条尺寸级滚动范围
            barScale = (self.viewRect_.height / self.srcScrollBarSize_.height) / (self.scrollLength_ / self.viewRect_.height + 1)
            if barScale > 1 then
                scrollBarSize.height = self.srcScrollBarSize_.height * barScale
            end
            
            self.scrollBar_:setContentSize(scrollBarSize)
            self.scrollBarScrollLength_ = self.viewRect_.height - scrollBarSize.height
            self.scrollBar_:pos(
                (self.viewRect_.width - scrollBarSize.width) * 0.5 - 2, 
                self.scrollBarScrollLength_ * 0.5
            )
            self.scrollBar_:show()
        else
            self.scrollBar_:hide()
        end
    elseif self.direction_ == ScrollView.DIRECTION_HORIZONTAL then
        if self.scrollLength_ and  self.scrollLength_ > 0 and self.showScrollBar_ then
            -- 计算滚动条尺寸级滚动范围
            barScale = (self.viewRect_.width / self.srcScrollBarSize_.width) / (self.scrollLength_ / self.viewRect_.width + 1)
            if barScale > 1 then
                scrollBarSize.width = self.srcScrollBarSize_.width * barScale
            end

            self.scrollBar_:setContentSize(scrollBarSize)
            self.scrollBarScrollLength_ = self.viewRect_.width - scrollBarSize.width
            self.scrollBar_:pos(
                -self.scrollBarScrollLength_ * 0.5, 
                -(self.viewRect_.height - scrollBarSize.height) * 0.5 + 2
            )
            self.scrollBar_:show()
        else
            self.scrollBar_:hide()
        end
    end
end

-- 渐隐滚动条
function ScrollView:fadeOutScrollBar_()
    -- 派发结束事件
    self:dispatchEvent({name = ScrollView.EVENT_SCROLL_END})

    if self.scrollBar_ and self.scrollBar_:isVisible() then
        self.scrollBar_:fadeOut(0.8)
    end
end

function ScrollView:hideScrollBar()
    self.showScrollBar_ = false

    if self.scrollBar_ then
        self.scrollBar_:hide()
    end

    return self
end

-- 滚动至指定位置
function ScrollView:scrollTo(place)
    self.currentPlace_ = self.currentPlace_ + place
    self:fixCurrentPlace_()
    self:startScroll_()

    return self
end

-- 滚动容器变化时需要更新,注意：不是帧定时器，别和2dx搞混
function ScrollView:update()
    if self.scrollContent_ then
        self:setScrollContent(self.scrollContent_)
    end
    
    if self.scrollBar_ then
        self:setScrollBar(self.scrollBar_)
    end

    -- 更新滚动容器位置
    self.currentPlace_ = 0
    self:startScroll_()
    self:setScrollContentTouchRect()
end

function ScrollView:getCurrentPlace()
    return self.currentPlace_
end

-- 设置滚动容器触摸范围，需要ScrollView添加在舞台后设置
function ScrollView:setScrollContentTouchRect()
    self.viewRectOriginPoint_ = self:convertToWorldSpace(cc.p(self.viewRect_.x, self.viewRect_.y))
    self:setScrollContentCascadeBoundingBox_(cc.rect(self.viewRectOriginPoint_.x, self.viewRectOriginPoint_.y, self.viewRect_.width, self.viewRect_.height))
end

function ScrollView:setScrollContentCascadeBoundingBox_(rect)
    self.mBoundingBox_ = rect
end

function ScrollView:getScrollContentCascadeBoundingBox_()
    if self.mBoundingBox_ then
        return self.mBoundingBox_
    end

    return self.scrollContent_:getCascadeBoundingBox()
end

function ScrollView:resetScrollContentCascadeBoundingBox_()
    self.mBoundingBox_ = nil
end

function ScrollView:setUpRefresh(upRefresh)
    self.upRefreshCallback_ = upRefresh
end

function ScrollView:onEnter()
    self:setScrollContentTouchRect()
end

function ScrollView:onExit()
    self:removeAllEventListeners()
end

function ScrollView:onScrolling()
end

function ScrollView:setNotHide(isNotHide)
    self.isNotHide_ = isNotHide
end

function ScrollView:setTouchNodeSwallowEnabled(enable)
    if self.touchNode_ then
        self.touchNode_:setTouchSwallowEnabled(enable)
    end
end

return ScrollView
