--
-- Author: tony
-- Date: 2014-11-24 15:47:18
--

local HistoryListItem = class("HistoryListItem", bm.ui.ListItem)

HistoryListItem.PADDING_LEFT = 2
HistoryListItem.PADDING_RIGHT = 2

function HistoryListItem:ctor()
    HistoryListItem.super.ctor(self, HistoryListItem.WIDTH, HistoryListItem.HEIGHT)
    display.newScale9Sprite("#pop_up_split_line.png", HistoryListItem.WIDTH * 0.5, 0, cc.size(HistoryListItem.WIDTH - HistoryListItem.PADDING_LEFT - HistoryListItem.PADDING_RIGHT, 2))
        :addTo(self)

    self.detail_ = ui.newTTFLabel({text="", size=24, color=cc.c3b(0xBA, 0xE9, 0xFF), align=ui.TEXT_ALIGN_LEFT, dimensions=cc.size(480, 0)})
    self.detail_:setAnchorPoint(cc.p(0, 0.5))
    self.detail_:pos(16, HistoryListItem.HEIGHT * 0.5)
    self.detail_:addTo(self)

    self.status_ = ui.newTTFLabel({text="", size=24, color=cc.c3b(0xBA, 0xE9, 0xFF), align=ui.TEXT_ALIGN_CENTER})
    self.status_:setAnchorPoint(cc.p(0.5, 0.5))
    self.status_:pos(HistoryListItem.WIDTH - 90, HistoryListItem.HEIGHT * 0.5)
    self.status_:addTo(self)

    self.date_ = ui.newTTFLabel({text="", size=24, color=cc.c3b(0xBA, 0xE9, 0xFF), align=ui.TEXT_ALIGN_CENTER})
    self.date_:setAnchorPoint(cc.p(0.5, 0.5))
    self.date_:pos(HistoryListItem.WIDTH - 250, HistoryListItem.HEIGHT * 0.5)
    self.date_:addTo(self)
end

function HistoryListItem:onDataSet(dataChanged, data)
    if dataChanged then
        self.detail_:setString(bm.LangUtil.getText("STORE", "BUY_DESC",data.detail or ""))
        self.status_:setString(bm.LangUtil.getText("STORE", "RECORD_STATUS")[tonumber(data.status) or 2])
        self.date_:setString(os.date("%Y-%m-%d", data.buyTime))
    end
end

return HistoryListItem