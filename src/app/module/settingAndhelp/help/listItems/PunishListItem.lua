--
-- Author: viking@boomegg.com
-- Date: 2014-09-03 15:40:07
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local FAQListItem = import(".FAQListItem")
local PunishListItem = class("PunishListItem", FAQListItem)

function PunishListItem:ctor()
    PunishListItem.super.ctor(self)
end

function PunishListItem:foldContent()
    if self.isFolded_ then
        self.isFolded_ = false
        self.splitLine_:show()
    else
        self.isFolded_ = true
    end
    self:unscheduleUpdate()
    self:scheduleUpdate()
    
    self.initItem = true
    self:createItem(self.data_)
end

function PunishListItem:createItem(data)
    self.answerLabel:show()
    local answerLabelMarginLeft = self.titleMarginLeft
    self.answerLabel:setString(data[2])
    local answerLabelSize = self.answerLabel:getContentSize()    
    local answerLabelMarginBottom = 5
    local linePadding = 12
    local h = linePadding + answerLabelSize.height
    self.bottomBackground_:size(self.contentWidth, h)
    self.bottomBackground_:setPositionY(h * 0.5 - PunishListItem.HEIGHT * 0.5 + 4)
    self.answerLabel:pos(-PunishListItem.WIDTH/2 + answerLabelMarginLeft, h * 0.5 - PunishListItem.HEIGHT * 0.5 + answerLabelMarginBottom)
end

return PunishListItem