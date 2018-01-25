--
-- Author: tony
-- Date: 2014-08-19 16:37:53
--
local ChatMsgHistoryListItem = class("ChatMsgHistoryListItem", bm.ui.ListItem)

--need to be set before creating new instances
ChatMsgHistoryListItem.WIDTH = 0
ChatMsgHistoryListItem.HEIGHT = 0

local label_x_offset = 8

function ChatMsgHistoryListItem:ctor()
    ChatMsgHistoryListItem.super.ctor(self, ChatMsgHistoryListItem.WIDTH, ChatMsgHistoryListItem.HEIGHT)
    self.label_ = ui.newTTFLabel({text="", size=20, color=cc.c3b(0x92, 0x97, 0xb5),dimensions=cc.size(ChatMsgHistoryListItem.WIDTH, 0), align=ui.TEXT_ALIGN_LEFT})
        :pos(ChatMsgHistoryListItem.WIDTH * 0.5 + label_x_offset, ChatMsgHistoryListItem.HEIGHT * 0.5)
        :addTo(self)
    -- display.newScale9Sprite("#room_pop_chat_divide.png", ChatMsgHistoryListItem.WIDTH * 0.5, 0, cc.size(ChatMsgHistoryListItem.WIDTH, 2)):addTo(self)
end

function ChatMsgHistoryListItem:onDataSet(dataChanged, data)
    if dataChanged then
        self.label_:setString(data.messageContent or "")
        if data.mtype == 1 then
            -- 大喇叭
            self.label_:setTextColor(cc.c3b(0xe0, 0x86, 0x1a))
        elseif data.mtype == 2 then
            -- 普通聊天消息
            self.label_:setTextColor(cc.c3b(0x72, 0x7f, 0x89))
        end
        local msg = data.messageContent or ""
        if string.find(msg, "@") then
            self.label_:setTextColor(cc.c3b(0x2b, 0x4a, 0xaa))
        end
        local csize = self.label_:getContentSize()
        self.label_:pos(ChatMsgHistoryListItem.WIDTH * 0.5 + label_x_offset, csize.height * 0.5)
        self:setContentSize(cc.size(ChatMsgHistoryListItem.WIDTH, self.label_:getContentSize().height + 12))
    end
end

return ChatMsgHistoryListItem