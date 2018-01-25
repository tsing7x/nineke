--
-- Author: Jonah0608@gmail.com
-- Date: 2015-07-28 11:52:58
--
local DropDownListItem = class("DropDownListItem",  bm.ui.ListItem)

function DropDownListItem:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:setNodeEventEnabled(true)
    DropDownListItem.super.ctor(self,0,40)
    self.itemBtnName_ = cc.ui.UIPushButton.new({normal= "#invite_friend_inputback.png", pressed = "#invite_friend_inputback.png"},{scale9 = true})
        :setButtonSize(400, 45)
        :pos(0,0)
        :setButtonLabel(ui.newTTFLabel({text="", size=24, color=cc.c3b(0x00, 0x00, 0x00), align=ui.TEXT_ALIGN_LEFT}))
        :setButtonLabelAlignment(display.LEFT_CENTER)
        :setButtonLabelOffset(-150,0)
        :onButtonClicked(function()
                self:dispatchEvent({name="ITEM_EVENT", type="DROPDOWN_LIST_SELECT", selectid=self.id_})
            end)
        :addTo(self)
        
    self.itemBtnName_:setTouchSwallowEnabled(false)
end

function DropDownListItem:setData(data)
    self.id_ = data.id
    self.selected_ = data.select
    if self.itemBtnName_ then
        if self.selected_ then
            self.itemBtnName_:setState("pressed")
        end
        self.itemBtnName_:setButtonLabelString(data.title)
    end
end

return DropDownListItem