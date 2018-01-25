local ScrollView = import(".ScrollView")
local PageScrollView = class("PageScrollView", ScrollView)
PageScrollView.SCROLL = 10002


function PageScrollView:ctor(params, pageParams)
    PageScrollView.super.ctor(self, params)
    self.params = params
    self.recWidth_ = params.viewRect.width
    self.recHeight_ = params.viewRect.height
    if pageParams~=nil then
        self.isPage_ = 1
        self.move_ = pageParams.move or 60
        self.speed__ = pageParams.speed
        self.pageNum_ = pageParams.pageNum
        self.pageScroll_ = pageParams.pageScroll or self.recWidth_
        if not self.speed__ then
            if params.direction == ScrollView.DIRECTION_HORIZONTAL then
                self.speed__ = self.pageScroll_*0.2
            else
                self.speed__ = self.recHeight_*0.2
            end
        end
        self.btnNormal_ = pageParams.btnNormal or "#page_btn_normal.png"
        self.btnSelect_ = pageParams.btnSelect or "#page_btn_select.png"
    end
    self:update()
end

function PageScrollView:getParams()
    return self.params;
end


function PageScrollView:onTouch_(evt)
    if self.isPage_ ~= 1 then
        return PageScrollView.super.onTouch_(self,evt)        
    end
    -- 翻页效果
    local name, curX, curY, prevX, prevY = evt.name, evt.x, evt.y, evt.prevX, evt.prevY
    if name == "began" and not self:isTouchInViewRect_(evt) then
        return false
    end

    if name == "began" then
        self:fadeOutButtons()
        self.purpose_ = nil
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
        self.purpose_ = nil
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
            if math.abs(self.speed_)>=self.move_ then
                local shang1 = math.ceil(self.currentPlace_/self.recHeight_)
                if self.speed_>0 then
                    self.scrollDirection_ = ScrollView.DIRECTION_UP
                    self.isSmaller_ = false -- 变大
                    self.purpose_ = shang1*self.recHeight_
                else
                    self.scrollDirection_ = ScrollView.DIRECTION_DOWN
                    self.purpose_ = (shang1-1)*self.recHeight_
                    self.isSmaller_ = true -- 变小
                end
                if self.purpose_<0 then
                    self.purpose_ = 0
                elseif self.purpose_>self.topPlace_ then
                    self.purpose_ = self.topPlace_
                end
                self.stopIndex_ = math.abs(self.purpose_)/self.recHeight_+1
            else
                local shang = self.currentPlace_/self.recHeight_
                local shang1 = math.ceil(self.currentPlace_/self.recHeight_)
                if (shang1 - shang) < 0.5 then  -- 前进
                    self.scrollDirection_ = ScrollView.DIRECTION_UP
                    self.purpose_ = shang1*self.recHeight_
                    self.speed_ = (self.purpose_-self.currentPlace_)/(dragTime * 1000) * ScrollView.SPEED_ADJUST_RATE
                    self.isSmaller_ = false -- 变大
                    self.stopIndex_ = math.abs(self.purpose_)/self.recHeight_+1
                else -- 回退
                    self.scrollDirection_ = ScrollView.DIRECTION_DOWN
                    self.purpose_ = (shang1-1)*self.recHeight_
                    self.speed_ = (self.purpose_-self.currentPlace_)/(dragTime * 1000) * ScrollView.SPEED_ADJUST_RATE
                    self.isSmaller_ = true -- 变小
                    self.stopIndex_ = math.abs(self.purpose_)/self.recHeight_+1
                end
            end
            self.speed_ = math.abs(self.speed_)
            -- if self.speed_ > 0 then
            --     self.scrollDirection_ = ScrollView.DIRECTION_UP
            -- elseif self.speed_ < 0 then
            --     self.scrollDirection_ = ScrollView.DIRECTION_DOWN
            -- end
            -- self.speed_ = math.abs(self.speed_)
        elseif self.direction_ == ScrollView.DIRECTION_HORIZONTAL then
            dragDistance = self.destTouchX_ - self.srcTouchX_
            self.speed_ = dragDistance / (dragTime * 1000) * ScrollView.SPEED_ADJUST_RATE
            if math.abs(self.speed_)>=self.move_ then
                local shang1 = math.ceil(self.currentPlace_/self.pageScroll_)
                if self.speed_>0 then
                    self.scrollDirection_ = ScrollView.DIRECTION_LEFT
                    self.isSmaller_ = true -- 变小变大
                    self.purpose_ = shang1*self.pageScroll_
                else
                    self.scrollDirection_ = ScrollView.DIRECTION_RIGHT
                    self.isSmaller_ = false -- 变大
                    self.purpose_ = (shang1-1)*self.pageScroll_
                end
                if self.purpose_>0 then
                    self.purpose_ = 0
                elseif self.purpose_<self.topPlace_ then
                    self.purpose_ = self.topPlace_
                end

                self.stopIndex_ = math.abs(self.purpose_)/self.pageScroll_+1
            else -- 以屏大的为参考
                local shang = self.currentPlace_/self.pageScroll_
                local shang1 = math.ceil(self.currentPlace_/self.pageScroll_)
                if (shang1 - shang) < 0.5 then  -- 前进
                    self.scrollDirection_ = ScrollView.DIRECTION_RIGHT
                    self.purpose_ = shang1*self.pageScroll_
                    self.speed_ = (self.purpose_-self.currentPlace_)/(dragTime * 1000) * ScrollView.SPEED_ADJUST_RATE
                    self.isSmaller_ = false -- 变大
                    self.stopIndex_ = math.abs(self.purpose_)/self.pageScroll_+1
                else -- 回退
                    self.scrollDirection_ = ScrollView.DIRECTION_LEFT
                    self.purpose_ = (shang1-1)*self.pageScroll_
                    self.speed_ = (self.purpose_-self.currentPlace_)/(dragTime * 1000) * ScrollView.SPEED_ADJUST_RATE
                    self.isSmaller_ = true -- 变小
                    self.stopIndex_ = math.abs(self.purpose_)/self.pageScroll_+1
                end
            end
            self.speed_ = math.abs(self.speed_)
        end
        if self.speed_>self.speed__ then
            self.speed_ = self.speed__
        end
        -- 检查越界，若越界，则启动回移
        self:checkContentOut_()
        if self.outFlag_ ~= ScrollView.INSIDE then
            self:startBack_()
        else
            self:fixSpeed_()
            self.scrollFlag_ = ScrollView.SCROLL_NORMAL
            -- 开启帧频回调
            self.scrollContent_:scheduleUpdate()
        end
    end
end

function PageScrollView:scrollNormal_()
    if self.isPage_~=1 then
        PageScrollView.super.scrollNormal_(self)
        return
    end
    -- 改变位置，检测越界
    self:changePlace_()
    self:startScroll_()
    self:checkContentOut_()

     -- 若越界，则速度下降
    if self.outFlag_ ~= ScrollView.INSIDE then
        self.speed_ = self.speed_ * 0.4
        self.scrollContent_:unscheduleUpdate()
        self:startBack_()
    else
        -- 界面内 判断是否到达目的地
        if self.purpose_ then
            self:checkMoveOutPurpose()
            if self.purposeOutFlag_ ~= ScrollView.INSIDE then
                self.speed_ = self.speed_ * 0.4
                self.scrollContent_:unscheduleUpdate()
                self:startBackPurpose_()
            end
        end
    end
end

function PageScrollView:onEnterFrame_(dt)
    if self.scrollFlag_ == ScrollView.COUNT_STAY then
        self:countStay_()
    elseif self.scrollFlag_ == ScrollView.SCROLL_NORMAL then
        self:scrollNormal_()
    elseif self.scrollFlag_ == ScrollView.SCROLL_BACK then
        self:scrollBack_()
    elseif self.scrollFlag_ == PageScrollView.SCROLL then
        self:scrollPurpose_()
    end
end

function PageScrollView:scrollBack_()
    if self.outFlag_ == ScrollView.OUT_TOP then
        self:changePlace_()
        self:slowDown_()

        if (self.direction_ == ScrollView.DIRECTION_VERTICAL and self.currentPlace_ <= self.topPlace_) or 
        (self.direction_ == ScrollView.DIRECTION_HORIZONTAL and self.currentPlace_ >= self.topPlace_) then
            self.currentPlace_ = self.topPlace_
            self.scrollContent_:unscheduleUpdate()
            self:fadeOutScrollBar_()
            if self.upRefreshCallback_ then
                self.upRefreshCallback_()
            end
            if self.isPage_==1 then
                self:updateBtns(self.stopIndex_)
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
            if self.isPage_==1 then
                self:updateBtns(self.stopIndex_)
            end
        end
        self:startScroll_()
    else
        -- 关闭帧频回调
        self.scrollContent_:unscheduleUpdate()
        -- 渐隐滚动条
        self:fadeOutScrollBar_()
    end
end

function PageScrollView:scrollPurpose_()
    if self.purposeOutFlag_ == ScrollView.OUT_TOP then
        self:changePlace_()
        self:slowDown_()

        if (self.direction_ == ScrollView.DIRECTION_VERTICAL and self.currentPlace_ <= self.purpose_) or 
        (self.direction_ == ScrollView.DIRECTION_HORIZONTAL and self.currentPlace_ >= self.purpose_) then
            self.currentPlace_ = self.purpose_
            -- 关闭帧频回调
            self.scrollContent_:unscheduleUpdate()
            -- 渐隐滚动条
            self:fadeOutScrollBar_()
            if self.upRefreshCallback_ then
                self.upRefreshCallback_()
            end
            self:updateBtns(self.stopIndex_)
        end
        self:startScroll_()
    elseif self.purposeOutFlag_ == ScrollView.OUT_BOTTOM then
        -- 下越界，改变位置，若已移到边界，则停止移动
        self:changePlace_()
        self:slowDown_()

        if (self.direction_ == ScrollView.DIRECTION_VERTICAL and self.currentPlace_ >= self.purpose_) or 
        (self.direction_ == ScrollView.DIRECTION_HORIZONTAL and self.currentPlace_ <= self.purpose_) then
            self.currentPlace_ = self.purpose_
            -- 关闭帧频回调
            self.scrollContent_:unscheduleUpdate()
            -- 渐隐滚动条
            self:fadeOutScrollBar_()
            self:updateBtns(self.stopIndex_)
        end
        self:startScroll_()
    else
        -- 关闭帧频回调
        self.scrollContent_:unscheduleUpdate()
        -- 渐隐滚动条
        self:fadeOutScrollBar_()
    end
end

function PageScrollView:startBackPurpose_()
    if self.direction_ == ScrollView.DIRECTION_VERTICAL then
        if self.purposeOutFlag_ == ScrollView.OUT_TOP then
            self.speed_ = (self.currentPlace_ - self.purpose_) / 8
            self.scrollDirection_ = ScrollView.DIRECTION_DOWN
        elseif self.purposeOutFlag_ == ScrollView.OUT_BOTTOM then
            self.speed_ = (self.purpose_ - self.currentPlace_) / 8
            self.scrollDirection_ = ScrollView.DIRECTION_UP
        end
    elseif self.direction_ == ScrollView.DIRECTION_HORIZONTAL then
        if self.purposeOutFlag_ == ScrollView.OUT_TOP then
            self.speed_ = (self.purpose_ - self.currentPlace_) / 8
            self.scrollDirection_ = ScrollView.DIRECTION_RIGHT
        elseif self.purposeOutFlag_ == ScrollView.OUT_BOTTOM then
            self.speed_ = (self.currentPlace_ - self.purpose_) / 8
            self.scrollDirection_ = ScrollView.DIRECTION_LEFT
        end
    end
    -- 开启帧频回调，启动回移
    self.scrollContent_:scheduleUpdate()
    self.scrollFlag_ = PageScrollView.SCROLL
end

function PageScrollView:checkMoveOutPurpose()
    if self.direction_ == ScrollView.DIRECTION_VERTICAL then
        if self.isSmaller_==false and self.currentPlace_>self.purpose_ then
            self.purposeOutFlag_ = ScrollView.OUT_TOP
        elseif self.isSmaller_==true and self.currentPlace_<self.purpose_ then
            self.purposeOutFlag_ = ScrollView.OUT_BOTTOM
        else
            self.purposeOutFlag_ = ScrollView.INSIDE
        end
    elseif self.direction_ == ScrollView.DIRECTION_HORIZONTAL then
        if self.isSmaller_==true and self.currentPlace_ < self.purpose_ then
            self.purposeOutFlag_ = ScrollView.OUT_TOP
        elseif self.isSmaller_==false and self.currentPlace_ > self.purpose_ then
            self.purposeOutFlag_ = ScrollView.OUT_BOTTOM
        else
            self.purposeOutFlag_ = ScrollView.INSIDE
        end
    end
end

function PageScrollView:checkContentOut_()
    PageScrollView.super.checkContentOut_(self)
    if self.isPage_==1 then
        if self.outFlag_~=ScrollView.INSIDE then
            self.purpose_ = nil
        end
    end
end
-- 设置滚动条
function PageScrollView:setScrollBar(scrollBar)
    if self.isPage_~=1 then
        PageScrollView.super.setScrollBar(self,scrollBar)
        return
    end
    if self.scrollBar_ and  self.scrollBar_ ~= scrollBar then
        self.scrollBar_:removeFromParent()
    end
    self.scrollBar_ = nil
    if scrollBar then
        scrollBar:removeFromParent()
    end
end
-- 滚动容器变化时需要更新
function PageScrollView:update()
    if self.isPage_~=1 then
        PageScrollView.super.update(self)
        return
    end
    PageScrollView.super.update(self)
    if not self.pageNum_ or self.pageNum_ < 2 then
        if self.btnContain_ then
            self.btnContain_:hide()
        end
        self.stopIndex_ = 1
        self.showIndex_ = 1
        self:updateBtns(1)
        return
    end
    if not self.btnContain_ then
        self.btnContain_ = display.newNode()
        self.btnContain_:setCascadeOpacityEnabled(true)
        -- self.btnContain_ = display.newColorLayer(ccc4(0, 0, 0, 255))
        -- self.btnContain_:setContentSize(cc.size(10,10))
        self.btnContain_:addTo(self)
        if self.direction_ == ScrollView.DIRECTION_VERTICAL then
            self.btnContain_:pos(self.recWidth_*0.5,0)
        elseif self.direction_ == ScrollView.DIRECTION_HORIZONTAL then
            self.btnContain_:pos(0,-self.recHeight_*0.5 + 70)
        end
    end
    self.btnContain_:show()
    if not self.btns_ then
        self.btns_ = {}
    end
    local item = nil
    local length = #self.btns_
    length = length > self.pageNum_ and length or self.pageNum_
    for i=1,length do
        item = self.btns_[i]
        if not item then
            item = display.newSprite(self.btnNormal_)
                :addTo(self.btnContain_)
            self.btns_[i] = item
            bm.TouchHelper.new(item, function(target,evtName)
                if evtName==bm.TouchHelper.CLICK then
                    if self.stopIndex_~=i then
                        self:gotoPage(i)
                    end
                -- elseif evtName==bm.TouchHelper.TOUCH_BEGIN then
                -- elseif evtName==bm.TouchHelper.TOUCH_MOVE then
                end
            end)
        end
        if i>self.pageNum_ then
            item:hide()
        else
            item:show()
        end
    end
    if not self.selectIcon_ then
        self.selectIcon_ = display.newSprite(self.btnSelect_)
            :addTo(self.btnContain_)
        self.selectIcon_:retain()
    end
    if self.selectIcon_:getParent() then
        self.selectIcon_:removeFromParent()
    end
    self.btnContain_:addChild(self.selectIcon_)
    item = self.btns_[1]
    if item then
        local size = item:getContentSize()
        local width = 0
        local startPos = 0
        if self.direction_ == ScrollView.DIRECTION_VERTICAL then
            width = size.height*(2*self.pageNum_ - 1)
            startPos = width * 0.5 - size.height * 0.5
            for i=1,self.pageNum_ do
                item = self.btns_[i]
                item:pos(-size.width*0.5,startPos - (i-1)*size.height*2)
            end
            self.selectIcon_:pos(-size.width*0.5,startPos)
        elseif self.direction_ == ScrollView.DIRECTION_HORIZONTAL then
            width = size.width*(2*self.pageNum_ - 1)
            startPos = -width * 0.5 + size.width * 0.5
            width = size.width*(2*self.pageNum_ - 1)
            for i=1,self.pageNum_ do
                item = self.btns_[i]
                item:pos(startPos + (i-1)*size.width*2,size.height*0.5)
            end
            self.selectIcon_:pos(startPos,size.height*0.5)
        end
        self.iconStartPos_ = startPos
        self.iconSize_ = size
    end
    self.stopIndex_ = 1
    self.showIndex_ = 1
    self:updateBtns(1)
end

function PageScrollView:gotoPage(page,isDirect)
    if self.isPage_~=1 or not page or page<1 or page>self.pageNum_ or page==self.stopIndex_ then
        return
    end
    -- 关闭帧频回调
    self.scrollContent_:unscheduleUpdate()

    -- 计算拖动时间，根据移动方向，计算速度
    local dragTime = 1
    local dragDistance = 0
    if self.direction_ == ScrollView.DIRECTION_VERTICAL then
        if page>self.stopIndex_ then  -- 前进
            self.scrollDirection_ = ScrollView.DIRECTION_UP
            self.purpose_ = (page-1)*self.recHeight_
            self.speed_ = (self.purpose_-self.currentPlace_)/(dragTime * 1000) * ScrollView.SPEED_ADJUST_RATE
            self.isSmaller_ = false -- 变大
            self.stopIndex_ = math.abs(self.purpose_)/self.recHeight_+1
        else -- 回退
            self.scrollDirection_ = ScrollView.DIRECTION_DOWN
            self.purpose_ = (page-1)*self.recHeight_
            self.speed_ = (self.purpose_-self.currentPlace_)/(dragTime * 1000) * ScrollView.SPEED_ADJUST_RATE
            self.isSmaller_ = true -- 变小
            self.stopIndex_ = math.abs(self.purpose_)/self.recHeight_+1
        end
        self.speed_ = math.abs(self.speed_)
    elseif self.direction_ == ScrollView.DIRECTION_HORIZONTAL then
        if page<self.stopIndex_ then  -- 前进
            self.scrollDirection_ = ScrollView.DIRECTION_RIGHT
            self.purpose_ = (-page+1)*self.pageScroll_
            self.speed_ = (self.purpose_-self.currentPlace_)/(dragTime * 1000) * ScrollView.SPEED_ADJUST_RATE
            self.isSmaller_ = false -- 变大
            self.stopIndex_ = math.abs(self.purpose_)/self.pageScroll_+1
        else -- 回退
            self.scrollDirection_ = ScrollView.DIRECTION_LEFT
            self.purpose_ = (-page+1)*self.pageScroll_
            self.speed_ = (self.purpose_-self.currentPlace_)/(dragTime * 1000) * ScrollView.SPEED_ADJUST_RATE
            self.isSmaller_ = true -- 变小
            self.stopIndex_ = math.abs(self.purpose_)/self.pageScroll_+1
        end
        self.speed_ = math.abs(self.speed_)
    end
    if self.speed_>self.speed__ then
        self.speed_ = self.speed__
    end
    if isDirect==true then
        self.currentPlace_ = self.purpose_
        if self.direction_ == ScrollView.DIRECTION_VERTICAL then
            -- 设置滚动容器的位置
            self.scrollContent_:setPositionY(self.currentPlace_ + self.srcContentPlace_)
        elseif self.direction_ == ScrollView.DIRECTION_HORIZONTAL then
            -- 设置滚动容器的位置
            self.scrollContent_:setPositionX(self.currentPlace_ + self.srcContentPlace_)
        end
        -- 渐隐滚动条
        self:fadeOutScrollBar_()
        -- if self.upRefreshCallback_ then
        --     self.upRefreshCallback_()
        -- end
        self:updateBtns(self.stopIndex_)
        return
    end
    -- 检查越界，若越界，则启动回移
    self:checkContentOut_()
    if self.outFlag_ ~= ScrollView.INSIDE then
        self:startBack_()
    else
        self:fixSpeed_()
        self.scrollFlag_ = ScrollView.SCROLL_NORMAL
        -- 开启帧频回调
        self.scrollContent_:scheduleUpdate()
    end
end

function PageScrollView:getCurrentPage()
    return self.stopIndex_ or 1
end

function PageScrollView:onCleanup()
    if self.selectIcon_ then
        self.selectIcon_:release()
    end
end

function PageScrollView:updateBtns(index)
    self:fadeInButtons()
    if self.isPage_==1 and self.pageNum_>1 and self.showIndex_~=index then
        local offIndex = math.abs(index - self.showIndex_)
        self.showIndex_ = index
        if self.direction_ == ScrollView.DIRECTION_VERTICAL then
            transition.moveTo(self.selectIcon_, {
                time   = 0.05*offIndex,
                y      = self.iconStartPos_ - (index-1)*self.iconSize_.height*2,
            })
        elseif self.direction_ == ScrollView.DIRECTION_HORIZONTAL then
            transition.moveTo(self.selectIcon_, {
                time   = 0.05*offIndex,
                x      = self.iconStartPos_ + (index-1)*self.iconSize_.width*2,
            })
        end
    end
    self:dispatchEvent({name="MOVE_COMPLETE",data=self})
end

function PageScrollView:fadeOutButtons()
    if self.btnContain_ then
        self.btnContain_:fadeOut(0.2)
    end
end

function PageScrollView:fadeInButtons()
    if self.btnContain_ then
        self.btnContain_:fadeIn(0.2)
    end
end

return PageScrollView