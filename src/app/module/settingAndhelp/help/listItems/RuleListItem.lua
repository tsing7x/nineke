--
-- Author: viking@boomegg.com
-- Date: 2014-09-03 15:40:07
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local FAQListItem = import(".FAQListItem")
local RuleListItem = class("RuleListItem", FAQListItem)

function RuleListItem:ctor()
    RuleListItem.super.ctor(self)
end

function RuleListItem:foldContent()
    if self.isFolded_ then
        self.isFolded_ = false
        self.splitLine_:show()
    else
        self.isFolded_ = true
    end
    self:unscheduleUpdate()
    self:scheduleUpdate()

    if self.index_  ~= 1 and not self.initItem then
        self.initItem = true
        self:createItem(self.data_)
    end    
end

function RuleListItem:onDataSet(dataChanged, data)
    if dataChanged then
        self.data_ = data
        self.title_:setString(data[1])

        if self.index_ == 1 then 
            --游戏规则图片
            local rulePic = display.newSprite("help_rule_pic.png"):addTo(self.bottomPanel_):scale(0.8)
            local padding = 10
            local h = rulePic:getContentSize().height - padding * 2

            self.bottomBackground_:size(self.contentWidth, h)
            self.bottomBackground_:setPositionY(h * 0.5 - RuleListItem.HEIGHT * 0.5 + 4)
            rulePic:pos(0, h * 0.5 - RuleListItem.HEIGHT * 0.5)
        end
    end
end

function RuleListItem:createItem(data)
    self.answerLabel:show()
    local answerLabelMarginLeft = self.titleMarginLeft
    self.answerLabel:setString(data[2])
    local answerLabelSize = self.answerLabel:getContentSize()    
    local answerLabelMarginBottom = 5
    local linePadding = 12
    local h = linePadding + answerLabelSize.height
    self.bottomBackground_:size(self.contentWidth, h)
    self.bottomBackground_:setPositionY(h * 0.5 - RuleListItem.HEIGHT * 0.5 + 4)
    self.answerLabel:pos(-RuleListItem.WIDTH/2 + answerLabelMarginLeft, h * 0.5 - RuleListItem.HEIGHT * 0.5 + answerLabelMarginBottom)
end

return RuleListItem