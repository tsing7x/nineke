--
-- Author: tony
-- Date: 2014-08-14 18:25:51
--
local CheckBoxButtonGroup = class("CheckBoxButtonGroup")

CheckBoxButtonGroup.BUTTON_SELECT_CHANGED = "BUTTON_SELECT_CHANGED"

function CheckBoxButtonGroup:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self.buttons_ = {}
    self.buttonId_ = {}
    self.currentSelectedIndex_ = 0
end

function CheckBoxButtonGroup:addButton(button, id)
    self.buttons_[#self.buttons_ + 1] = button
    if id then
        self.buttonId_[#self.buttonId_ + 1] = id
    end
    button:onButtonClicked(buttontHandler(self, self.onButtonStateChanged_))
    button:onButtonStateChanged(handler(self, self.onButtonStateChanged_))
    return self
end

function CheckBoxButtonGroup:getButtonById(id)
    for i, v in pairs(self.buttonId_) do
        if tostring(v) == tostring(id) then
            return self.buttons_[i]
        end
    end
end

function CheckBoxButtonGroup:reset()
    self:removeAllEventListeners()
    while self:getButtonsCount() > 0 do
        self:removeButtonAtIndex(self:getButtonsCount())
    end
end

function CheckBoxButtonGroup:removeButtonAtIndex(index)
    assert(self.buttons_[index] ~= nil, "CheckBoxButtonGroup:removeButtonAtIndex() - invalid index")

    local button = self.buttons_[index]
    button:removeSelf()
    table.remove(self.buttons_, index)
    table.remove(self.buttonId_, index)

    if self.currentSelectedIndex_ == index then
        self:updateButtonState_(nil)
    elseif index < self.currentSelectedIndex_ then
        self:updateButtonState_(self.buttons_[self.currentSelectedIndex_ - 1])
    end
    return self
end

function CheckBoxButtonGroup:getButtonAtIndex(index)
    return self.buttons_[index]
end

function CheckBoxButtonGroup:getButtonsCount()
    return #self.buttons_
end

function CheckBoxButtonGroup:addButtonSelectChangedEventListener(callback)
    return self:addEventListener(CheckBoxButtonGroup.BUTTON_SELECT_CHANGED, callback)
end

function CheckBoxButtonGroup:onButtonSelectChanged(callback)
    self:addButtonSelectChangedEventListener(callback)
    return self
end

function CheckBoxButtonGroup:onButtonStateChanged_(event)
    if event.name == cc.ui.UICheckBoxButton.STATE_CHANGED_EVENT and event.target:isButtonSelected() == false then
        return
    end
    self:updateButtonState_(event.target)
end

function CheckBoxButtonGroup:updateButtonState_(clickedButton)
    local currentSelectedIndex = 0
    for index, button in ipairs(self.buttons_) do
        if button == clickedButton then
            currentSelectedIndex = index
            if not button:isButtonSelected() then
                button:setButtonSelected(true)
            end
        else
            if button:isButtonSelected() then
                button:setButtonSelected(false)
            end
        end
    end
    if self.currentSelectedIndex_ ~= currentSelectedIndex then
        local last = self.currentSelectedIndex_
        self.currentSelectedIndex_ = currentSelectedIndex
        self:dispatchEvent({name = CheckBoxButtonGroup.BUTTON_SELECT_CHANGED, selected = currentSelectedIndex, last = last})
    end
end


return CheckBoxButtonGroup