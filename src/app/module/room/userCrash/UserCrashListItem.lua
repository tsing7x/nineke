--
-- Author: KevinYu
-- Date: 2016-11-03
--
local UserCrashListItem = class("UserCrashListItem", bm.ui.ListItem)

local action

local w, h = 800, 110

function UserCrashListItem:ctor()
    UserCrashListItem.super.ctor(self, w, h)

    self:setNodeEventEnabled(true)

    local line_w, line_x = 38, -5
    for i = 1, 22 do
        display.newSprite("#crash_split_line.png")
            :align(display.LEFT_BOTTOM, line_x + (i - 1) * line_w, 0)
            :addTo(self)
    end
end

function UserCrashListItem:createContent_()
    local posY = h/2
    self.icon = display.newSprite()
        :pos(55, posY)
        :addTo(self)

    self.title = ui.newTTFLabel({text="", size=24, color=cc.c3b(0xff, 0xff, 0xff)})
        :align(display.LEFT_CENTER, 120, posY + 15)
        :addTo(self)

    self.chips = ui.newTTFLabel({text="", size=24, color=cc.c3b(0xff, 0xde, 0x46)})
        :align(display.LEFT_CENTER, 120, posY - 15)
        :addTo(self)
    
    self.info = ui.newTTFLabel({text="", size=20, color=cc.c3b(0xc9, 0x80, 0xff)})
        :addTo(self)

    self.actionBtn = cc.ui.UIPushButton.new({normal= "#common_btn_green_normal.png", pressed = "#common_btn_green_pressed.png",disabled = "#common_btn_disabled.png"},{scale9 = true})
        :setButtonSize(160, 52)
        :setButtonLabel(ui.newTTFLabel({text="", size=24, color=cc.c3b(0xff, 0xff, 0xff), align=ui.TEXT_ALIGN_CENTER}))
        :onButtonClicked(handler(self, self.userCrashItemClicked_))
        :pos(w - 100, posY)
        :addTo(self)
end

function UserCrashListItem:lazyCreateContent()
    if not self.created_ then
        self.created_ = true
        self:createContent_()
    end

    if self.dataChanged_ then
        self.dataChanged_ = false
        self:setData_(self.data_)
    end
end

function UserCrashListItem:setData_(data)
    self.remainTime = 0

    self.icon:setSpriteFrame(display.newSpriteFrame(data.img))
    self.title:setString(data.title)

    if data.chips and data.chips > 0 then
        self.chips:setString(bm.LangUtil.getText("CRASH", "CHIPS", data.chips))
    else
        self.chips:setString("")
    end

    local tmpWidth = self.chips:getContentSize().width
    self.info:setString(data.info)
    self.info:align(display.LEFT_CENTER, 120 + tmpWidth, h/2 - 13)

    if data.remainTime and data.remainTime ~= 0 then
        self.remainTime = data.remainTime
        local timeStr = (self.remainTime > 0 and bm.TimeUtil:getTimeString(self.remainTime)) or ""
        self.actionBtn:setButtonEnabled(false)
        self.actionBtn:setButtonLabelString(timeStr)
        self:startCount()
    else
        self.actionBtn:setButtonLabelString(data.btnTitle)
    end
end

function UserCrashListItem:onDataSet(dataChanged, data)
    self.dataChanged_ = self.dataChanged_ or dataChanged
    self.data_ = data
end

function UserCrashListItem:userCrashItemClicked_()
    self.owner_.owner_:itemClicked_(self.data_.type)
end

function UserCrashListItem:setButtonText(time)
    if self.actionBtn then
        local timeStr = (self.remainTime > 0 and bm.TimeUtil:getTimeString(self.remainTime)) or ""
        self.actionBtn:setButtonLabelString(timeStr)
    end
end

function UserCrashListItem:setButtonEnable()
    if self.actionBtn then
        self.actionBtn:setButtonLabelString(self.data_.btnTitle)
        self.actionBtn:setButtonEnabled(true)
    end
end

function UserCrashListItem:countsFunc()
    self.remainTime = self.remainTime - 1
    if self.remainTime <= 0 then
        self:stopAction(action)
        self:setButtonEnable()
    else
        self:setButtonText(self.remainTime)
    end
end

function UserCrashListItem:startCount()
    if action then
        self:stopAction(action)
    end

    action = self:schedule(function()
        self:countsFunc()
    end, 1)
end

return UserCrashListItem