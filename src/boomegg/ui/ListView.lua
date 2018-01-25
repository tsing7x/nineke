--
-- Author: johnny@boomegg.com
-- Date: 2014-08-17 16:28:28
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

--[[
    bm.ui.ListView.new(
        {
            viewRect = cc.rect(-240, -160, 480, 320),
            direction = bm.ui.ScrollView.DIRECTION_HORIZONTAL
        }, 
        ItemClass -- 继承于ListItem
    )
        :setData({1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,})
        :addTo(self)
]]

local ScrollView = import(".ScrollView")
local ListView = class("ListView", ScrollView)

function ListView:ctor(params, itemClass)
    ListView.super.ctor(self, params)

    -- 滚动容器
    self.content_ = display.newNode()

    self:setScrollContent(self.content_)
    self:setItemClass(itemClass)
end

function ListView:onScrolling()
    if self.items_ and self.viewRectOriginPoint_ then
        if self.direction_ == ScrollView.DIRECTION_VERTICAL then
            for _, item in ipairs(self.items_) do
                local tempWorldPt = self.content_:convertToWorldSpace(cc.p(item:getPosition()))
                if tempWorldPt.y > self.viewRectOriginPoint_.y + self.viewRect_.height or tempWorldPt.y < self.viewRectOriginPoint_.y - item.height_ then
                    item:hide()
                    if item.onItemDeactived then
                        if tempWorldPt.y - (self.viewRectOriginPoint_.y + self.viewRect_.height) > self.viewRect_.height or self.viewRectOriginPoint_.y - item.height_ - tempWorldPt.y > self.viewRect_.height then
                            item:onItemDeactived()
                        end
                    end
                else
                    item:show()
                    if item.lazyCreateContent then
                        item:lazyCreateContent()
                    end
                end
            end
        elseif self.direction_ == ScrollView.DIRECTION_HORIZONTAL then
            for _, item in ipairs(self.items_) do
                local tempWorldPt = self.content_:convertToWorldSpace(cc.p(item:getPosition()))
                if tempWorldPt.x > self.viewRectOriginPoint_.x + self.viewRect_.width or tempWorldPt.x < self.viewRectOriginPoint_.x - item.width_ then
                    item:hide()
                    if item.onItemDeactived then
                        if tempWorldPt.x - (self.viewRectOriginPoint_.x + self.viewRect_.width) > self.viewRect_.width or self.viewRectOriginPoint_.x - item.width_ - tempWorldPt.x > self.viewRect_.width then
                            item:onItemDeactived()
                        end
                    end
                else
                    item:show()
                    if item.lazyCreateContent then
                        item:lazyCreateContent()
                    end
                end
            end
        end
    end
end

-- 设置数据
function ListView:setData(data,scroll)
    local curP = self.currentPlace_
    self.data_ = data
    local oldItemNum = self.itemNum_ or 0
    self.itemNum_ = self.data_ and #self.data_ or 0

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
    if self.direction_ == ScrollView.DIRECTION_VERTICAL then
        self.contentSize_ = 0
        local onePageNum = 8
        if self.isDynamicSetData_ and self.itemNum_ > 0 then
            if self.itemNum_ > onePageNum then
                local num = self.itemNum_
                self.itemNum_ = onePageNum
                self:dynamicSetVerticalData_(1, onePageNum)
                self.delaySchedulerId_ = nk.schedulerPool:delayCall(function ()
                    self.itemNum_ = num
                    self:dynamicSetVerticalData_(onePageNum + 1, self.itemNum_)
                    self.delaySchedulerId_ = nil
                end, 0.5)
            else
                self:dynamicSetVerticalData_(1, self.itemNum_)
            end
            self.isDynamicSetData_ = false
        else
            self:dynamicSetVerticalData_(1, self.itemNum_)
        end

    elseif self.direction_ == ScrollView.DIRECTION_HORIZONTAL then
        local contentSize = 0
        local itemResizeHandler = handler(self, self.onItemResize_)
        local itemEventHandler = handler(self, self.onItemEvent_)
        for i = 1, self.itemNum_ do
            if not self.items_[i] then
                self.items_[i] = self.itemClass_.new()
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
            self.items_[i]:setData(self.data_[i])
            self.items_[i]:setOwner(self)
            contentSize = contentSize + self.items_[i]:getContentSize().width
        end
        
        -- 先定第一个item的位置，再设置其他item位置
        if self.itemNum_ > 0 then
            local size = self.items_[1]:getContentSize()
            self.items_[1]:pos(-contentSize * 0.5, -size.height * 0.5)
            for i = 2, self.itemNum_ do
                local prevSize = size
                size = self.items_[i]:getContentSize()
                self.items_[i]:pos(self.items_[i - 1]:getPositionX() + prevSize.width, -size.height * 0.5)
            end
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

--动态设置数据开关
function ListView:setDynamicSetDatasetEnabled(isDynamicSetData)
    self.isDynamicSetData_ = isDynamicSetData
    return self
end

--清除动态设置数据定时器
function ListView:clearDynamicSetDataset()
    if self.delaySchedulerId_ then
        nk.schedulerPool:clear(self.delaySchedulerId_)
        self.delaySchedulerId_ = nil
    end
end

--防止一次数据过多出现卡顿，其实只需要显示前面几条数据，其他的数据延时设置
function ListView:dynamicSetVerticalData_(startIndex, endIndex)
    local itemResizeHandler = handler(self, self.onItemResize_)
    local itemEventHandler = handler(self, self.onItemEvent_)
    for i = startIndex, endIndex do
        if not self.items_[i] then
            self.items_[i] = self.itemClass_.new()
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
        self.items_[i]:setData(self.data_[i])
        self.items_[i]:setOwner(self)
        self.contentSize_ = self.contentSize_ + self.items_[i]:getContentSize().height
    end

    -- 先定第一个item的位置，再设置其他item位置
    if self.itemNum_ > 0 then
        local size = self.items_[1]:getContentSize()
        self.items_[1]:pos(-size.width * 0.5, self.contentSize_ * 0.5 - size.height)
        for i = 2, endIndex do
            size = self.items_[i]:getContentSize()
            self.items_[i]:pos(-size.width * 0.5, self.items_[i - 1]:getPositionY() - size.height)
        end
    end
    self.content_:setContentSize(cc.size(self.content_:getCascadeBoundingBox().width, self.contentSize_))

    self:update()
end

function ListView:getData()
    return self.data_
end

function ListView:onItemResize_()
    -- 创建item
    local curP = self.currentPlace_
    local contentSize = 0
    if self.direction_ == ScrollView.DIRECTION_VERTICAL then
        for i = 1, self.itemNum_ do
            contentSize = contentSize + self.items_[i]:getContentSize().height
        end
        --self.content_:setContentSize(cc.size(self.content_:getContentSize().width, contentSize))
        -- 先定第一个item的位置，再设置其他item位置
        local size = self.items_[1]:getContentSize()
        self.items_[1]:pos(-size.width * 0.5, contentSize * 0.5 - size.height)
        local pX, pY = -size.width * 0.5, contentSize * 0.5 - size.height
        for i = 2, self.itemNum_ do
            size = self.items_[i]:getContentSize()
            pY = pY - size.height
            self.items_[i]:pos(pX, pY)
        end
        self.content_:setContentSize(cc.size(self.content_:getCascadeBoundingBox().width, contentSize))
    elseif self.direction_ == ScrollView.DIRECTION_HORIZONTAL then
        for i = 1, self.itemNum_ do
            contentSize = contentSize + self.items_[i]:getContentSize().width
        end
        self.content_:setContentSize(cc.size(contentSize, self.content_:getContentSize().height))
        -- 先定第一个item的位置，再设置其他item位置
        local size = self.items_[1]:getContentSize()
        self.items_[1]:pos(-contentSize * 0.5, -size.height * 0.5)
        local pX, pY = -contentSize * 0.5, -size.height * 0.5
        for i = 2, self.itemNum_ do
            size = self.items_[i]:getContentSize()
            pX = pX + size.width
            self.items_[i]:pos(pX, pY)
        end
        self.content_:setContentSize(cc.size(contentSize, self.content_:getCascadeBoundingBox().height))
    end

    -- 更新滚动容器
    self:update()
    self:scrollTo(curP)
    return self
end

function ListView:onItemEvent_(evt)
    self:dispatchEvent(evt)
end

function ListView:getListItem(index)
    if self.items_ then
        return self.items_[index]
    end
end

function ListView:getListItems()
    if self.items_ then
        return self.items_
    end
end

function ListView:setItemClass(class)
    self.itemClass_ = class

    return self
end

--设置所有item深度，在setData之后调用
function ListView:setItemsZorder(isIncrease)
    local len = #self.items_

    --递增
    if isIncrease then
        for i = 1, len do
            self.items_[i]:setLocalZOrder(i)
        end
    else
        local z = 1
        for i = len, 1, -1 do
            self.items_[i]:setLocalZOrder(z)
            z = z + 1
        end
    end

    return self
end

return ListView