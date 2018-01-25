--
-- Author: Jonah0608@gmail.com
-- Date: 2015-07-10 16:38:12
--
local MatchFeedList = class("MatchFeedList", nk.ui.Panel)
local FeedbackCommon = import("app.module.feedback.FeedbackCommon")
local MatchFeedListItem = import(".items.MatchFeedListItem")
local WIDTH = 750
local HEIGHT = 480
local TOP = HEIGHT*0.5
local BOTTOM = -HEIGHT*0.5
local LEFT = -WIDTH*0.5
local RIGHT = WIDTH*0.5
local TOP_HEIGHT = 30
local PADDING = 15

function MatchFeedList:ctor()
    MatchFeedList.super.ctor(self, {WIDTH+30, HEIGHT+30})
    self:addBgLight()
    self:setNodeEventEnabled(true)
    self.title_ = ui.newTTFLabel({text=bm.LangUtil.getText("MATCH", "FEEDBACK"), size=36, color=cc.c3b(0xfb, 0xd0, 0x0a), align=ui.TEXT_ALIGN_CENTER})
        :pos(0, TOP - 25)
        :addTo(self)
    self:addCloseBtn()
    local x,y = self.closeBtn_:getPosition()
    self.closeBtn_:pos(x+6,y+6)
    self:createFeedList()
    self.noMsg_ = ui.newTTFLabel({text=bm.LangUtil.getText("MESSAGE", "EMPTY_PROMPT"), size=34, color=cc.c3b(0xd7, 0xf6, 0xff), align=ui.TEXT_ALIGN_CENTER})
        :addTo(self)
    self.noMsg_:hide()
end

function MatchFeedList:createFeedList()
    local feedBgWidth = WIDTH - PADDING * 2
    local feedBgHeight = HEIGHT - PADDING * 2 - TOP_HEIGHT
    local feedBgContent = display.newScale9Sprite("#panel_overlay.png", 
                0, - TOP_HEIGHT / 2 , cc.size(feedBgWidth, feedBgHeight))
        feedBgContent:addTo(self)
    self.feedListContainer_ = feedBgContent
    self.feedListContainer_:setVisible(true)

    local feedbackListWidth,feedbackListHeight = feedBgWidth-10,feedBgHeight-10
    MatchFeedListItem.WIDTH = feedbackListWidth
    self.feedbackList_ = bm.ui.ListView.new({viewRect = cc.rect(-0.5 * feedbackListWidth, -0.5 * feedbackListHeight, feedbackListWidth, feedbackListHeight), 
                                direction = bm.ui.ListView.DIRECTION_VERTICAL}, MatchFeedListItem):addTo(self.feedListContainer_)
                        :pos(feedbackListWidth*0.5+5,feedbackListHeight*0.5)
end

function MatchFeedList:onShowed()
    if self.feedbackList_ then
        self.feedbackList_:update()
    end
end

function MatchFeedList:show(data)
    self:showPanel_(true, true, true)
    data = nil
    if data then
        if #data>0 then
            self.feedbackList_:setData(data)
        else
            self.noMsg_:show()
        end
    else
        FeedbackCommon.getFeedbackList(function(succ,feedbackRetData)
            if succ then
                local localData = {}
                for i = 1, #feedbackRetData.data do
                    table.insert(localData,feedbackRetData.data[i])
                end
                table.sort(localData,function(a,b) return a.mtime > b.mtime end)
                if #localData>0 then
                    self.feedbackList_:setData(localData)
                else
                    self.noMsg_:show()
                end
            end
        end)
    end
    return self
end

return MatchFeedList
