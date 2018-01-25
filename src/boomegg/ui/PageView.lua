--
-- Author: johnny@boomegg.com
-- Date: 2014-08-17 16:28:28
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

--[[
    bm.ui.PageView.new(
        {
            viewRect = cc.rect(-240, -160, 480, 320),
            direction = bm.ui.ScrollView.DIRECTION_HORIZONTAL,
            rows = 1, 行数
            columns = 1,   列数
            rowsPadding = 1,  行间距
            columnsPadding = 1,  列间距
        }, 
        ItemClass, -- 继承于ListItem 必须要有 ItemClass.WIDTH,ItemClass.HEIGHT | 在PageListItem里头需要计算
        {
            move = 80,  移动速率  在移动，  否则为 半屏
            speed = 10,  最大移动速度  最大为50 
            btnNormal = "1.png", 普通
            btnSelect = "2.png",  选中
        },
    )
        :setData({1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,})
        :addTo(self)
]]
local PageListItem = import(".PageListItem")
local ListView = import(".ListView")
local ScrollView = import(".ScrollView")
local PageView = class("PageView", ListView)
PageView.SCROLL = 10001
--[[
    params：在原来List的基础上添加 rows|columns|rowsPadding|columnsPadding
    itemClass：类
    pageParams：翻页相关参数  只要有这个参数就当做是Page，默认当做List
        move：翻屏系数  默认为60
        speed: 最大移动速度 默认为全屏的1/5
        res：资源
--]]
function PageView:ctor(params, itemClass, pageParams)
    PageView.super.ctor(self, params)
    self.params = params
    if not params.rows then params.rows = 1 end
    if not params.columns then params.columns = 1 end
    if not params.rowsPadding then params.rowsPadding = 0 end
    if not params.columnsPadding then params.columnsPadding = 0 end
    if not itemClass.WIDTH then itemClass.WIDTH = 100 end
    if not itemClass.HEIGHT then itemClass.HEIGHT = 100 end
    self.recWidth_ = params.viewRect.width
    self.recHeight_ = params.viewRect.height
    if pageParams~=nil then
        self.isPage_ = 1
        self.move_ = pageParams.move or 60
        self.speed__ = pageParams.speed
        if not self.speed__ then
            if params.direction == ScrollView.DIRECTION_HORIZONTAL then
                self.speed__ = self.recWidth_*0.2
            else
                self.speed__ = self.recHeight_*0.2
            end
        end
        self.btnNormal_ = pageParams.btnNormal or "#page_btn_normal.png"
        self.btnSelect_ = pageParams.btnSelect or "#page_btn_select.png"
    end
    -- 滚动容器
    self.content_ = display.newNode()

    self:setScrollContent(self.content_)
    self:setItemClass(itemClass)
end

-- 设置数据
function PageView:setData(data,scroll)
    local count = self.params.rows*self.params.columns
    local curP = self.currentPlace_
    self.data_ = data
    local oldItemNum = self.itemNum_ or 0
    self.itemNum_ = math.ceil((self.data_ and #self.data_ or 0)/count)

    -- 如果已创建items，移除多余的item
    if self.items_ then
        if oldItemNum > self.itemNum_ then
            for i = self.itemNum_ + 1, oldItemNum do
                table.remove(self.items_):removeFromParent()
            end
        end
    else
        self.items_ = {}
    end

    -- 创建item
    local contentSize = 0
    local itemResizeHandler = handler(self, self.onItemResize_)
    local itemEventHandler = handler(self, self.onItemEvent_)
    if self.direction_ == ScrollView.DIRECTION_VERTICAL then
        for i = 1, self.itemNum_ do
            if not self.items_[i] then
                self.items_[i] = PageListItem.new(self.recWidth_,self.recHeight_,self.params,1,self)
                    :addTo(self.content_)
                if self.items_[i].addEventListener then
                    self.items_[i]:addEventListener("RESIZE", itemResizeHandler)
                    self.items_[i]:addEventListener("ITEM_EVENT", itemEventHandler)
                end
            end
            if self.isNotHide_ then
                self.items_[i]:show()
            end
            self.items_[i]:setIndex(i)
            self.items_[i]:setData(self.data_,(i-1)*count+1,self.itemClass_)
            self.items_[i]:setOwner(self)
            -- contentSize = contentSize + self.items_[i]:getContentSize().height
            contentSize = contentSize + self.recHeight_
        end

        for i=1, self.itemNum_ do
            self.items_[i]:pos(-self.recWidth_ * 0.5,-contentSize * 0.5 + (self.itemNum_ - i)*self.recHeight_)
        end
        self.content_:setContentSize(cc.size(self.content_:getCascadeBoundingBox().width, contentSize))
    elseif self.direction_ == ScrollView.DIRECTION_HORIZONTAL then
        for i = 1, self.itemNum_ do
            if not self.items_[i] then
                self.items_[i] = PageListItem.new(self.recWidth_,self.recHeight_,self.params,2,self)
                    :addTo(self.content_)
                if self.items_[i].addEventListener then
                    self.items_[i]:addEventListener("RESIZE", itemResizeHandler)
                    self.items_[i]:addEventListener("ITEM_EVENT", itemEventHandler)
                end
            end
            if self.isNotHide_ then
                self.items_[i]:show()
            end
            self.items_[i]:setIndex(i)
            self.items_[i]:setData(self.data_,(i-1)*count+1,self.itemClass_)
            self.items_[i]:setOwner(self)
            -- contentSize = contentSize + self.items_[i]:getContentSize().width
            contentSize = contentSize + self.recWidth_
        end
        
        for i = 1, self.itemNum_ do
            self.items_[i]:pos(-contentSize * 0.5 + (i-1)*self.recWidth_,-self.recHeight_*0.5)
        end
        self.content_:setContentSize(cc.size(contentSize, self.content_:getCascadeBoundingBox().height))
    end

    -- 更新滚动容器
    self:update()
    if scroll then
        self:scrollTo(curP)
    end
    return self
end

function PageView:getData()
    return self.data_
end

function PageView:getParams()
    return self.params;
end


function PageView:onTouch_(evt)
    if self.isPage_ ~= 1 then
        return PageView.super.onTouch_(self,evt)        
    end
    -- 翻页效果
    local name, curX, curY, prevX, prevY = evt.name, evt.x, evt.y, evt.prevX, evt.prevY
    if name == "began" and not self:isTouchInViewRect_(evt) then
        return false
    end

    if name == "began" then
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
                local shang1 = math.ceil(self.currentPlace_/self.recWidth_)
                if self.speed_>0 then
                    self.scrollDirection_ = ScrollView.DIRECTION_LEFT
                    self.isSmaller_ = true -- 变小变大
                    self.purpose_ = shang1*self.recWidth_
                else
                    self.scrollDirection_ = ScrollView.DIRECTION_RIGHT
                    self.isSmaller_ = false -- 变大
                    self.purpose_ = (shang1-1)*self.recWidth_
                end
                if self.purpose_>0 then
                    self.purpose_ = 0
                elseif self.purpose_<self.topPlace_ then
                    self.purpose_ = self.topPlace_
                end

                self.stopIndex_ = math.abs(self.purpose_)/self.recWidth_+1
            else -- 以屏大的为参考
                local shang = self.currentPlace_/self.recWidth_
                local shang1 = math.ceil(self.currentPlace_/self.recWidth_)
                if (shang1 - shang) < 0.5 then  -- 前进
                    self.scrollDirection_ = ScrollView.DIRECTION_RIGHT
                    self.purpose_ = shang1*self.recWidth_
                    self.speed_ = (self.purpose_-self.currentPlace_)/(dragTime * 1000) * ScrollView.SPEED_ADJUST_RATE
                    self.isSmaller_ = false -- 变大
                    self.stopIndex_ = math.abs(self.purpose_)/self.recWidth_+1
                else -- 回退
                    self.scrollDirection_ = ScrollView.DIRECTION_LEFT
                    self.purpose_ = (shang1-1)*self.recWidth_
                    self.speed_ = (self.purpose_-self.currentPlace_)/(dragTime * 1000) * ScrollView.SPEED_ADJUST_RATE
                    self.isSmaller_ = true -- 变小
                    self.stopIndex_ = math.abs(self.purpose_)/self.recWidth_+1
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

function PageView:scrollNormal_()
    if self.isPage_~=1 then
        PageView.super.scrollNormal_(self)
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

function PageView:onEnterFrame_(dt)
    if self.scrollFlag_ == ScrollView.COUNT_STAY then
        self:countStay_()
    elseif self.scrollFlag_ == ScrollView.SCROLL_NORMAL then
        self:scrollNormal_()
    elseif self.scrollFlag_ == ScrollView.SCROLL_BACK then
        self:scrollBack_()
    elseif self.scrollFlag_ == PageView.SCROLL then
        self:scrollPurpose_()
    end
end

function PageView:scrollBack_()
    -- print("PageView:scrollBack_"..self.speed_)
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

function PageView:scrollPurpose_()
    -- print("fuck==============111111111=="..self.speed_)
    if self.purposeOutFlag_ == ScrollView.OUT_TOP then
        -- 上越界，改变位置，若已移到边界，则停止移动
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

function PageView:startBackPurpose_()
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
    self.scrollFlag_ = PageView.SCROLL
end

function PageView:checkMoveOutPurpose()
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

function PageView:checkContentOut_()
    PageView.super.checkContentOut_(self)
    if self.isPage_==1 then
        if self.outFlag_~=ScrollView.INSIDE then
            self.purpose_ = nil
        end
    end
end
-- 设置滚动条
function PageView:setScrollBar(scrollBar)
    if self.isPage_~=1 then
        PageView.super.setScrollBar(self,scrollBar)
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
function PageView:update()
    if self.isPage_~=1 then
        PageView.super.update(self)
        return
    end
    PageView.super.update(self)
    if not self.itemNum_ or self.itemNum_ < 2 then
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
        -- self.btnContain_ = display.newColorLayer(ccc4(0, 0, 0, 255))
        -- self.btnContain_:setContentSize(cc.size(10,10))
        self.btnContain_:addTo(self)
        if self.direction_ == ScrollView.DIRECTION_VERTICAL then
            self.btnContain_:pos(self.recWidth_*0.5,0)
        elseif self.direction_ == ScrollView.DIRECTION_HORIZONTAL then
            self.btnContain_:pos(0,-self.recHeight_*0.5)
        end
    end
    self.btnContain_:show()
    if not self.btns_ then
        self.btns_ = {}
    end
    local item = nil
    local length = #self.btns_
    length = length > self.itemNum_ and length or self.itemNum_
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
        if i>self.itemNum_ then
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
            width = size.height*(2*self.itemNum_ - 1)
            startPos = width * 0.5 - size.height * 0.5
            for i=1,self.itemNum_ do
                item = self.btns_[i]
                item:pos(-size.width*0.5,startPos - (i-1)*size.height*2)
            end
            self.selectIcon_:pos(-size.width*0.5,startPos)
        elseif self.direction_ == ScrollView.DIRECTION_HORIZONTAL then
            width = size.width*(2*self.itemNum_ - 1)
            startPos = -width * 0.5 + size.width * 0.5
            for i=1,self.itemNum_ do
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

function PageView:gotoPage(page,isDirect)
    if self.isPage_~=1 or not page or page<1 or page>self.itemNum_ or page==self.stopIndex_ then
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
            self.purpose_ = (-page+1)*self.recWidth_
            self.speed_ = (self.purpose_-self.currentPlace_)/(dragTime * 1000) * ScrollView.SPEED_ADJUST_RATE
            self.isSmaller_ = false -- 变大
            self.stopIndex_ = math.abs(self.purpose_)/self.recWidth_+1
        else -- 回退
            self.scrollDirection_ = ScrollView.DIRECTION_LEFT
            self.purpose_ = (-page+1)*self.recWidth_
            self.speed_ = (self.purpose_-self.currentPlace_)/(dragTime * 1000) * ScrollView.SPEED_ADJUST_RATE
            self.isSmaller_ = true -- 变小
            self.stopIndex_ = math.abs(self.purpose_)/self.recWidth_+1
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

function PageView:getCurrentPage()
    return self.stopIndex_ or 1
end

function PageView:onCleanup()
    if self.selectIcon_ then
        self.selectIcon_:release()
    end
end

function PageView:updateBtns(index)
    if self.isPage_==1 and self.itemNum_>1 and self.showIndex_~=index then
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
-- 简单刷新 数据内部变化 子项必须要有refresh接口
function PageView:refresh()
    if self.itemNum_ then
        local item = nil
        for i=1,self.itemNum_ do
            item = self.items_[i]
            if item and item.refresh then
                item:refresh()
            end
        end
    end
end

return PageView