--
-- Author: viking@boomegg.com
-- Date: 2014-08-30 15:55:36
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local FeedbackListItem = class("FeedbackListItem", bm.ui.ListItem)

FeedbackListItem.WIDTH  = 0
FeedbackListItem.HEIGHT = 70

function FeedbackListItem:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

    FeedbackListItem.super.ctor(self, FeedbackListItem.WIDTH, FeedbackListItem.HEIGHT)

    self.iconOriginX = 30

    self.container = display.newNode():addTo(self)

    --问题图标
    self.icon = display.newSprite("#help_question_icon.png"):addTo(self.container)
    self.iconSize = self.icon:getContentSize()
        self.icon:pos(self.iconOriginX + self.iconSize.width/2, FeedbackListItem.HEIGHT/2 + self.iconSize.height/2)

    local labelSize = 20
    local questionLabelColor = cc.c3b(0x64, 0x9a, 0xc9)
    local answerLabelColor = cc.c3b(0x27, 0x90, 0xd5)
    local labelSizePadding = 80

    --问题
    local label_h = 0
    self.questionLabel = ui.newTTFLabel({
            size = labelSize,
            color = questionLabelColor,
            align = ui.TEXT_ALIGN_LEFT,
            valign = ui.TEXT_VALIGN_TOP,
            dimensions = cc.size(FeedbackListItem.WIDTH - labelSizePadding, label_h)
        })
        :addTo(self.container)

    --回答
    self.answerLabel = ui.newTTFLabel({
            size = labelSize,
            color = answerLabelColor,
            align = ui.TEXT_ALIGN_LEFT,
            valign = ui.TEXT_VALIGN_TOP,
            dimensions = cc.size(FeedbackListItem.WIDTH - labelSizePadding, label_h)
        })
        :addTo(self.container)
end

function FeedbackListItem:onDataSet(dataChanged, data)
    if dataChanged then
        self.questionLabel:setString(data.content)
        
        local questionLabelSize = self.questionLabel:getContentSize()
        local questionLabelMarginLeft = 12

        self.answerLabel:setString(data.answer)
        
        local answerLabelMarginTop = questionLabelSize.height + 8
        local answerLabelSize = self.answerLabel:getContentSize()

        local padding = 5
        local lineSpacing = 10
        local h = padding * 2 + lineSpacing
        h = h + self.questionLabel:getContentSize().height
        h = h + self.answerLabel:getContentSize().height
        self:setContentSize(cc.size(FeedbackListItem.WIDTH, h))

        self.icon:pos(self.iconOriginX + self.iconSize.width/2, h - self.iconSize.height/2)
        self.questionLabel:pos(self.iconOriginX + self.iconSize.width + questionLabelMarginLeft + questionLabelSize.width/2, 
                    h  - questionLabelSize.height/2)
        self.answerLabel:pos(self.iconOriginX + answerLabelSize.width/2, h - answerLabelSize.height/2 - answerLabelMarginTop)    
    end
end

return FeedbackListItem