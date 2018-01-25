--
-- Author: Jonah0608@gmail.com
-- Date: 2015-07-28 15:26:35
--
local ListViewHeight = 45

local DropDownListItem = import(".DropDownListItem")

local DropDownListPanel = class("DropDownListPanel",function()
    return display.newNode()
end)

function DropDownListPanel:ctor(params,data,callback)
    self.callback_ = callback
    self.listData_ = data
    self.width_ = params.width
    self.height_ = #self.listData_ * ListViewHeight
    self.background_ = display.newScale9Sprite("#invite_friend_inputback.png", 0, 0, cc.size(self.width_, self.height_ - 45)):addTo(self)
    self.background_:setTouchEnabled(true)
    self.background_:setTouchSwallowEnabled(true)

    local contentWidth = self.width_
    local contentHeight = self.height_
    self.list_ = bm.ui.ListView.new({viewRect = cc.rect(-0.5 * contentWidth, -0.5 * contentHeight, contentWidth, contentHeight), 
        direction = bm.ui.ListView.DIRECTION_VERTICAL}, DropDownListItem):addTo(self)
        :pos(0,5)

    local data = {}
    for i = 1,#self.listData_ do
        data[i] = {}
        data[i].id = i
        data[i].selected = false
        data[i].title = self.listData_[i]
    end

    self.list_:setData(data)
    self.list_:addEventListener("ITEM_EVENT", handler(self, self.onItemEvent_))

    local posX, posY = params.posX, params.posY
    if CONFIG_SCREEN_AUTOSCALE == "FIXED_HEIGHT" then
        posX = posX * display.width / CONFIG_SCREEN_WIDTH
    end

    if CONFIG_SCREEN_AUTOSCALE == "FIXED_WIDTH" then
        posY = posY * display.height / CONFIG_SCREEN_HEIGHT
    end

    self:pos(posX, posY)
end

function DropDownListPanel:onItemEvent_(evt)
    if evt.type == "DROPDOWN_LIST_SELECT" then
        if self.callback_ then
            self.callback_(evt.selectid)
        end
    end
    self:hide()
end

function DropDownListPanel:showPanel_(isModal, isCentered, closeWhenTouchModel, useShowAnimation)
    nk.PopupManager:addPopup(self, isModal ~= false, false, closeWhenTouchModel ~= false, false)
    nk.schedulerPool:delayCall(function()
        if self.list_ then
            self.list_:setScrollContentTouchRect()
        end
    end, 0.2)

    return self
end

function DropDownListPanel:hidePanel_()
    nk.PopupManager:removePopup(self)
    
    return self
end

function DropDownListPanel:onClose()
    self:hidePanel_()
end

function DropDownListPanel:show()
    self:showPanel_()
end

function DropDownListPanel:hide()
    self:hidePanel_()
end


return DropDownListPanel