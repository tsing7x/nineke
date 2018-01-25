--
-- Author: tony
-- Date: 2014-08-19 15:24:19
--
local ChatMsgShortcutListItem = class("ChatMsgShortcutListItem", bm.ui.ListItem)

--need to be set before creating instances
ChatMsgShortcutListItem.WIDTH = 0
ChatMsgShortcutListItem.HEIGHT = 0
ChatMsgShortcutListItem.ON_ITEM_CLICKED_LISTENER = nil

function ChatMsgShortcutListItem:ctor()
    ChatMsgShortcutListItem.super.ctor(self, ChatMsgShortcutListItem.WIDTH, ChatMsgShortcutListItem.HEIGHT)
    self.btn_ = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png" , pressed = "#rounded_rect_10.png"}, {scale9=true})
            :setButtonLabel(cc.ui.UILabel.new({text="", size=20, color=cc.c3b(0x92, 0x97, 0xb5)}))
            :setButtonSize(ChatMsgShortcutListItem.WIDTH, 64)
            :onButtonPressed(function(evt) 
                    self.btnPressedY_ = evt.y
                    self.btnClickCanceled_ = false
                end)
            :onButtonRelease(function(evt)
                    if math.abs(evt.y - self.btnPressedY_) > 5 then
                        self.btnClickCanceled_ = true
                    end
                end)
            :onButtonClicked(function(evt)
                    if not self.btnClickCanceled_ and ChatMsgShortcutListItem.ON_ITEM_CLICKED_LISTENER and self:getParent():getParent():getCascadeBoundingBox():containsPoint(cc.p(evt.x, evt.y)) then
                        ChatMsgShortcutListItem.ON_ITEM_CLICKED_LISTENER(self.data_)
                    end
                end)
    self.btn_:setTouchSwallowEnabled(false)
    self.btn_:pos(ChatMsgShortcutListItem.WIDTH * 0.5, 64 * 0.5)
    self.btn_:addTo(self)
    display.newScale9Sprite("#room_pop_chat_divide.png", ChatMsgShortcutListItem.WIDTH * 0.5, 0, cc.size(ChatMsgShortcutListItem.WIDTH, 2)):addTo(self)
end

function ChatMsgShortcutListItem:onDataSet(dataChanged, data)
    if dataChanged then
        self.btn_:setButtonLabelString(data)
    end
end

return ChatMsgShortcutListItem