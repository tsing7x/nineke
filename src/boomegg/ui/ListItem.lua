--
-- Author: johnny@boomegg.com
-- Date: 2014-08-18 13:23:34
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local ListItem = class("ListItem", function ()
    return display.newNode()
end)

function ListItem:ctor(w, h)
    self:setContentSize(cc.size(w, h))
    self.width_ = w
    self.height_ = h
end

function ListItem:setData(data)
    local dataChanged = (self.data_ ~= data)
    self.data_ = data
    if self.onDataSet then
        self:onDataSet(dataChanged, data)
    end
    return self
end

function ListItem:getData()
    return self.data_
end

function ListItem:setIndex(index)
    self.index_ = index
    return self
end

function ListItem:getIndex()
    return self.index_
end

function ListItem:setOwner(owner)
    self.owner_ = owner
    return self
end

function ListItem:getOwner()
    return self.owner_
end

return ListItem