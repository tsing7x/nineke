--
-- Author: Jonah0608@gmail.com
-- Date: 2015-07-28 09:55:21
--

local DropDownListPanel = import(".DropDownListPanel")
local DropDownList = class("DropDownList", function()
    return display.newNode()
end)

function DropDownList:ctor(params)
    self:setNodeEventEnabled(true)
    self.width_ = params.width or 380
    self.height_ = params.height or 40
    self.posX_ = params.posX or display.cx
    self.posY_ = params.posY or display.cy
    if params and params.listData then
        self.listData_ = params.listData
    end
    self.inputBg_ = cc.ui.UIPushButton.new({normal = "#invite_friend_inputback.png", pressed = "#invite_friend_inputback.png"}, {scale9 = true})
        :setButtonSize(self.width_, self.height_)
        :onButtonClicked(handler(self, self.showPanel_))
        :pos(0, 0)
        :addTo(self)
    self.text_ = ui.newTTFLabel({text = "", color = styles.FONT_COLOR.DARK_TEXT, size = 24, dimensions=cc.size(self.width_,self.height_), align = ui.TEXT_ALIGN_LEFT})
        :pos(5,0)
        :addTo(self)
    self.btn_ = cc.ui.UIPushButton.new({normal = "#dropdown_list_button.png", pressed = "#dropdown_list_button.png"}, {scale9 = true})
        :setButtonSize(40, self.height_)
        :onButtonClicked(handler(self, self.showPanel_))
        :pos(self.width_ / 2 - 20, 0)
        :addTo(self)
    if params and params.selected then
        self:initWithSelected_(params.selected)
    else
        self:initWithSelected_(1)
    end
end

function DropDownList:initWithSelected_(id)
    if id > #self.listData_ or id <= 0  then
        return
    end
    self.id_ = id
    self.text_:setString(self.listData_[id])
end

function DropDownList:showPanel_()
    if self.listData_ then
        DropDownListPanel.new({width=self.width_,posX = self.posX_, posY = self.posY_},self.listData_,handler(self,self.changeSelected_)):show()
    end
end

function DropDownList:changeSelected_(id)
    if id > #self.listData_ or id <= 0  then
        return
    end
    self.id_ = id
    self.text_:setString(self.listData_[id])
end

function DropDownList:getId()
    if self.id_ then
        return self.id_
    end
end

return DropDownList