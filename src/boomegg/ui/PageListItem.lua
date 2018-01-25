--
-- Author: johnny@boomegg.com
-- Date: 2014-08-18 13:23:34
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local ListItem = import(".ListItem")

local PageListItem = class("PageListItem", ListItem)

function PageListItem:ctor(w, h, param,type,pageView)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    PageListItem.super.ctor(self, w, h)
    -- 类型
    self.type_ = type
    self.pageView_ = pageView
    -- 坐标配置哦
    self.rows_ = param.rows
    self.columns_ = param.columns
    self.rowsPadding_ = param.rowsPadding
    self.columnsPadding_ = param.columnsPadding
    self.itemList_ = {}
    -- 测试
    -- self.blackBg_ = display.newColorLayer(ccc4(0, 0, 0, 255))
    -- self.blackBg_:setContentSize(cc.size(w,h))
    -- self.blackBg_:addTo(self)
    -- self.blackBg_:pos(-w/2,-h/2)
    -- 容器
    self.container_ = display.newNode()
    self.container_:addTo(self)
                    :pos(w/2,h/2)
end

function PageListItem:setData(data,startIndex,itemClass)

    local count = self.rows_*self.columns_
    local width = itemClass.WIDTH*self.columns_+self.columnsPadding_*(self.columns_-1)
    local height = itemClass.HEIGHT*self.rows_+self.rowsPadding_*(self.rows_-1)

    -- 居中显示哦
    local startX = -width*0.5 + itemClass.WIDTH*0.5
    local startY = height*0.5 - itemClass.HEIGHT*0.5

    local item = nil
    local curRow = 0
    local curColumns = 0
    for i=1,count do
        item = self.itemList_[i]
        if not item then
            item = itemClass.new(startIndex+i-1,self.pageView_)
                :addTo(self.container_)
            self.itemList_[i] = item
            curRow = math.ceil(i/self.columns_) - 1  -- 行数
            curColumns = (i%self.columns_) - 1
            if curColumns==-1 then
                curColumns = self.columns_ - 1
            end
            item:pos(startX + curColumns*(self.columnsPadding_+itemClass.WIDTH), startY - curRow*(self.rowsPadding_+itemClass.HEIGHT))
            local itemEventHandler = handler(self, self.onItemEvent_)
            if item.addEventListener then
                item:addEventListener("ITEM_EVENT", itemEventHandler)
            end
        end
        if not data[startIndex+(i-1)] then
            item:setVisible(false)
        else
            item:setVisible(true)
            -- 每个子项目重塞数据
            item:setData(data[startIndex+(i-1)])
        end
    end
    return self
end

function PageListItem:onItemEvent_(evt)
    self:dispatchEvent(evt)
end

function PageListItem:getItemList()
    return self.itemList_
end

function PageListItem:refresh()
    local item = nil
    for i=1,#self.itemList_ do
        item = self.itemList_[i]
        if item and item.refresh then
            item:refresh()
        end
    end
end

return PageListItem