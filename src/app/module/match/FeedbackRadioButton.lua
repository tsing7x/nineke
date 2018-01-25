--
-- Author: Jonah0608@gmail.com
-- Date: 2015-07-13 11:50:39
--
local FeedbackRadioButton = class("FeedbackRadioButton", function()
    return display.newNode()
end)

FeedbackRadioButton.ON_STATE = "ON_STATE"
FeedbackRadioButton.OFF_STATE = "OFF_STATE"



function FeedbackRadioButton:ctor(images, tag, btnText)
    self.onImage_ = images["on"]
    self.offImage_ = images["off"]
    self.state_ = FeedbackRadioButton.OFF_STATE
    self.tag_ = tag
    self.bgBtn_ = cc.ui.UIPushButton.new({normal = images["bg_normal"], pressed = images["bg_pressed"]}, {scale9 = true})
                :setButtonSize(160,56)
                :pos(0,0)
                :addTo(self)
                :onButtonClicked(buttontHandler(self, self.btnSelected_))
    self.stateImg_ = display.newSprite()
                :pos(-60,0)
                :addTo(self)
    self.stateImg_:setSpriteFrame(display.newSpriteFrame(self.offImage_))
    self.text_ = cc.ui.UILabel.new({text = btnText, color = display.COLOR_WHITE})
                :align(display.LEFT_CENTER,-45, 0)
                :addTo(self)
end

function FeedbackRadioButton:getState()
    return (self.state_ == FeedbackRadioButton.ON_STATE)
end

function FeedbackRadioButton:setState(state)
    if state and self.state_ == FeedbackRadioButton.ON_STATE then
        return
    end
    if state then
        self.state_ = FeedbackRadioButton.ON_STATE
    else
        self.state_ = FeedbackRadioButton.OFF_STATE
    end
    self:changeStateImage(self.state_)
end

function FeedbackRadioButton:getTag()
    return self.tag_
end

function FeedbackRadioButton:setTag(tag)
    self.tag_ = tag
end

function FeedbackRadioButton:onButtonSelectChanged(callback)
    self.callback_ = callback
end

function FeedbackRadioButton:btnSelected_()
    if self.state_ == FeedbackRadioButton.ON_STATE then
        return
    else 
        self.state_ = FeedbackRadioButton.ON_STATE
        self:changeStateImage(self.state_)
        if self.callback_ then
            self.callback_(self.tag_)
        end
    end
end

function FeedbackRadioButton:changeStateImage(state)
    if state == FeedbackRadioButton.ON_STATE then
        self.stateImg_:setSpriteFrame(display.newSpriteFrame(self.onImage_))
    else
        self.stateImg_:setSpriteFrame(display.newSpriteFrame(self.offImage_))
    end
end

return FeedbackRadioButton