--
-- Author: viking@boomegg.com
-- Date: 2014-09-03 17:03:05
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local FAQListItem = import(".FAQListItem")
local LevelListItem = class("LevelListItem", FAQListItem)

function LevelListItem:ctor()
    LevelListItem.super.ctor(self)
end

function LevelListItem:foldContent()
    if self.isFolded_ then
        self.isFolded_ = false
        self.splitLine_:show()
    else
        self.isFolded_ = true
    end
    self:unscheduleUpdate()
    self:scheduleUpdate()

    if self.index_ == 1 and not self.initItem1 then
        self.initItem1 = true
        self:createItem1(self.data_)
    elseif self.index_ == 2 and not self.initItem2 then
        self.initItem2 = true
        self:createItem3(self.data_)
    -- elseif self.index_ == 3 and not self.initItem3 then
    --     self.initItem3 = true
    --     self:createItem3(self.data_)
    end    
end

function LevelListItem:onDataSet(dataChanged, data)
    if dataChanged then
        self.data_ = data
        self.title_:setString(data[1])
    end
end

function LevelListItem:createItem1(data)
    self.answerLabel:show()
    local answerLabelMarginLeft = self.titleMarginLeft
    self.answerLabel:setString(data[2])
    local answerLabelSize = self.answerLabel:getContentSize()    
    local answerLabelMarginBottom = 5
    local linePadding = 12
    local h = linePadding + answerLabelSize.height
    self.bottomBackground_:size(self.contentWidth, h)
    self.bottomBackground_:setPositionY(h * 0.5 - LevelListItem.HEIGHT * 0.5 + 4)
    self.answerLabel:pos(-LevelListItem.WIDTH/2 + answerLabelMarginLeft, h * 0.5 - LevelListItem.HEIGHT * 0.5 + answerLabelMarginBottom)
end

function LevelListItem:createItem2(data)
    local expList = data[2]

    local marginTop = 15
    local h = marginTop
    local size = LevelListItem.ANSWER_SIZE
    local color = LevelListItem.ANSWER_COLOR 
    local labelPadding = 30
    local labelHeight = 0
    local items = {}

    local dividerWidth = 692
    local dividerHeight = 2
    local padding = 5
    for i = 1, #expList do
        local expArray = expList[i]

        --需要的时间获得经验
        local timeLabel = ui.newTTFLabel({
                text = expArray[1],
                size = size,
                color = color,
                align = ui.TEXT_ALIGN_LEFT
            }):addTo(self.bottomPanel_)
        timeLabel:setAnchorPoint(cc.p(0, 0.5))

        --获得的经验
        local expLabel = ui.newTTFLabel({
                text = expArray[2],
                size = size,
                color = color,
                align = ui.TEXT_ALIGN_RIGHT
            }):addTo(self.bottomPanel_)
        expLabel:setAnchorPoint(cc.p(1, 0.5))

        --万恶的分割线
        local divider = display.newScale9Sprite("#pop_up_split_line.png"):addTo(self.bottomPanel_):size(dividerWidth, dividerHeight)

        local timeLabelSize = timeLabel:getContentSize()
        labelHeight = timeLabelSize.height
        h = h + labelHeight + dividerHeight + padding * 2

        items[i] = {timeLabel, expLabel, divider}
    end

    self.bottomBackground_:size(self.contentWidth - 4, h)
    local bottomBgMarginTop = 4
    self.bottomBackground_:setPositionY(h * 0.5 - LevelListItem.HEIGHT * 0.5 + bottomBgMarginTop)

    local y = h - LevelListItem.HEIGHT * 0.5 - marginTop + (bottomBgMarginTop + dividerHeight)
    for _, item in ipairs(items) do
        item[1]:pos(-LevelListItem.WIDTH/2 + labelPadding, y - labelHeight/2 - padding)
        item[2]:pos(LevelListItem.WIDTH/2 - labelPadding, y - labelHeight/2 - padding)
        item[3]:pos(0, y - labelHeight - dividerHeight/2 - padding * 2)
        y = y - labelHeight - dividerHeight - padding * 2
    end
end

function LevelListItem:createItem3(data)
    local levelList = data[2]

    local marginTop = 15
    local h = marginTop
    local size = LevelListItem.ANSWER_SIZE
    local color = LevelListItem.ANSWER_COLOR 
    local labelPadding = 30
    local labelHeight = 0
    local items = {}

    local dividerWidth = 692
    local dividerHeight = 2
    local padding = 5
    local bottomContainer = display.newNode():addTo(self.bottomPanel_)
    for i = 1, #levelList do
        local levelArray = levelList[i]

        --等级
        local levelLabel = ui.newTTFLabel({
                text = levelArray[1],
                size = size,
                color = color,
                align = ui.TEXT_ALIGN_LEFT
            }):addTo(bottomContainer)
        levelLabel:setAnchorPoint(cc.p(0, 0.5))

        --称号
        local pokerTitleLabel = ui.newTTFLabel({
                text = levelArray[2],
                size = size,
                color = color,
                align = ui.TEXT_ALIGN_LEFT
            }):addTo(bottomContainer)
        pokerTitleLabel:setAnchorPoint(cc.p(0, 0.5))        

        --总经验
        local sumExpLabel = ui.newTTFLabel({
                text = levelArray[3],
                size = size,
                color = color,
                align = ui.TEXT_ALIGN_LEFT
            }):addTo(bottomContainer)
        sumExpLabel:setAnchorPoint(cc.p(0, 0.5))    

        --等级奖励
        local levelRewardLabel = ui.newTTFLabel({
                text = levelArray[4],
                size = size,
                color = color,
                align = ui.TEXT_ALIGN_RIGHT
            }):addTo(bottomContainer)
        levelRewardLabel:setAnchorPoint(cc.p(1, 0.5))

        --万恶的分割线
        local divider = display.newScale9Sprite("#pop_up_split_line.png"):addTo(self.bottomPanel_):size(dividerWidth, dividerHeight)

        local levelLabelSize = levelLabel:getContentSize()
        labelHeight = levelLabelSize.height
        h = h + labelHeight + dividerHeight + padding * 2

        items[i] = {levelLabel, pokerTitleLabel, sumExpLabel, levelRewardLabel, divider}
    end

    self.bottomBackground_:size(self.contentWidth, h)
    local bottomBgMarginTop = 4
    self.bottomBackground_:setPositionY(h * 0.5 - LevelListItem.HEIGHT * 0.5 + bottomBgMarginTop)

    local y = h - LevelListItem.HEIGHT * 0.5 - marginTop + (bottomBgMarginTop + dividerHeight)
    local pokerTitleMarginLeft = 150
    local sumExpMarginLeft = 350
    for _, item in ipairs(items) do
        item[1]:pos(-LevelListItem.WIDTH/2 + labelPadding, y - labelHeight/2 - padding)
        item[2]:pos(-LevelListItem.WIDTH/2 + labelPadding + pokerTitleMarginLeft, y - labelHeight/2 - padding)
        item[3]:pos(-LevelListItem.WIDTH/2 + labelPadding + sumExpMarginLeft, y - labelHeight/2 - padding)
        item[4]:pos(LevelListItem.WIDTH/2 - labelPadding, y - labelHeight/2 - padding)
        item[5]:pos(0, y - labelHeight - dividerHeight/2 - padding * 2)
        y = y - labelHeight - dividerHeight - padding * 2
    end
end

return LevelListItem