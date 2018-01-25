--
-- Author: viking@boomegg.com
-- Date: 2014-08-30 15:55:36

local MatchFeedListItem = class("MatchFeedListItem", bm.ui.ListItem)
local FeedbackCommon = import("app.module.feedback.FeedbackCommon")

MatchFeedListItem.WIDTH  = 0
MatchFeedListItem.HEIGHT = 70

function MatchFeedListItem:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

    MatchFeedListItem.super.ctor(self, MatchFeedListItem.WIDTH, MatchFeedListItem.HEIGHT)

    self.iconOriginX = 30

    self.container = display.newNode():addTo(self)

    local labelSize = 24
    local questionLabelColor = cc.c3b(0xFF, 0xFF, 0xFF)
    local answerLabelColor = cc.c3b(0x27, 0x90, 0xd5)
    local labelSizePadding = 10

    --问题
    self.questionLabel = ui.newTTFLabel({
            size = labelSize,
            color = questionLabelColor,
            align = ui.TEXT_ALIGN_LEFT,
            valign = ui.TEXT_VALIGN_TOP,
            dimensions = cc.size(MatchFeedListItem.WIDTH - labelSizePadding, 0)
        })
        :addTo(self.container)

    --回答
    self.answerLabel = ui.newTTFLabel({
            size = labelSize,
            color = answerLabelColor,
            align = ui.TEXT_ALIGN_LEFT,
            valign = ui.TEXT_VALIGN_TOP,
            dimensions = cc.size(MatchFeedListItem.WIDTH - 2*self.iconOriginX, 0)
        })
        :addTo(self.container)
end

function MatchFeedListItem:onDataSet(dataChanged, data)
    if dataChanged then
        data.content = data.content
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
        self:setContentSize(cc.size(MatchFeedListItem.WIDTH, h))

        self.questionLabel:pos(questionLabelSize.width/2, 
                    h  - questionLabelSize.height/2)
        self.answerLabel:pos(self.iconOriginX + answerLabelSize.width/2, h - answerLabelSize.height/2 - answerLabelMarginTop)    
        if data.answer~="" and tonumber(data.closed)==0 then -- 关闭
            local pram = {}
            pram.fid = data.fid
            pram.solved = 1
            FeedbackCommon.closeTicket(pram)
        end
    end
end

return MatchFeedListItem