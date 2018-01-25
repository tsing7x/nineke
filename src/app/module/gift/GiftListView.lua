--
-- Author: Tom
-- Date: 2014-12-19 16:36:58
-- 礼物列表视图

local ScrollView = import("boomegg.ui.ScrollView")
local  GiftListView = class("GiftListView", bm.ui.ListView)

function GiftListView:ctor(...)
    GiftListView.super.ctor(self, ...)
    self.btnGroup_ = nk.ui.CheckBoxButtonGroup.new()
end

function GiftListView:onButtonSelectChanged(callback)
    self.onButtonSelectChangedCallback_ = callback
end

function GiftListView:selectGiftById(id)
    if id then
        local btn = self.btnGroup_:getButtonById(id)
        if btn then
            btn:setButtonSelected(true)
        end
    end
end

function GiftListView:selectGiftByIndex(index)
    local btn = self.btnGroup_:getButtonAtIndex(index)
    if btn then
        btn:setButtonSelected(true)
    end
end

function GiftListView:onButtonSelectChanged_(...)
    if self.onButtonSelectChangedCallback_ then
        self.onButtonSelectChangedCallback_(self.btnGroup_, ...)
    end
end

function GiftListView:setData(data, args)
    print("GiftListView:setData", #data, args, self.direction_)
    self.data_ = data
    self.btnGroup_:reset()
    self.btnGroup_ = nk.ui.CheckBoxButtonGroup.new()
    self.btnGroup_:onButtonSelectChanged(handler(self, self.onButtonSelectChanged_))
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
    local contentSize = 0
    local itemResizeHandler = handler(self, self.onItemResize_)
    local itemEventHandler = handler(self, self.onItemEvent_)
    if self.direction_ == ScrollView.DIRECTION_VERTICAL then
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
            self.items_[i]:setData(self.data_[i], self.btnGroup_, args)
            self.items_[i]:setOwner(self)
            contentSize = contentSize + self.items_[i]:getContentSize().height
        end

        -- 先定第一个item的位置，再设置其他item位置
        if self.itemNum_ > 0 then
            local size = self.items_[1]:getContentSize()
            self.items_[1]:pos(-size.width * 0.5, contentSize * 0.5 - size.height)
            for i = 2, self.itemNum_ do
                size = self.items_[i]:getContentSize()
                self.items_[i]:pos(-size.width * 0.5, self.items_[i - 1]:getPositionY() - size.height)
            end
        end
        self.content_:setContentSize(cc.size(self.content_:getCascadeBoundingBox().width, contentSize))
    elseif self.direction_ == ScrollView.DIRECTION_HORIZONTAL then
        for i = 1, self.itemNum_ do
            if not self.items_[i] then
                self.items_[i] = self.itemClass_.new()
                    :addTo(self.content_)
            end
            if self.isNotHide_ then
                self.items_[i]:show()
            end
            self.items_[i]:setIndex(i)
            self.items_[i]:setData(self.data_[i], self.btnGroup_, args)
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
    else
        
    end
    -- 更新滚动容器
    self:update()

    return self
end

return GiftListView