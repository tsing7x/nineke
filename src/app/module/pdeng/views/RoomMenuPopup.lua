--
-- Author: tony
-- Date: 2014-08-26 15:01:15
--
local RoomMenuPopup = class("RoomMenuPopup", function() return display.newNode() end)


local WIDTH = 226
local HEIGHT = 244
local ITEM_HEIGHT = HEIGHT / 3 - 2
local ITEM_WIDTH = WIDTH - 16
local TOP = HEIGHT * 0.5
local LEFT = WIDTH * -0.5
local BUTTON_TEXT_SIZE = 24

function RoomMenuPopup:ctor(callback)
    self.background_ = display.newScale9Sprite("#room_pop_menu_bg.png", 0, 0, cc.size(WIDTH, HEIGHT + 8)):pos(0, 0)
    self.background_:addTo(self)
    self.background_:setTouchEnabled(true)
    self.background_:setTouchSwallowEnabled(true)

    self:pos(WIDTH * 0.5 + 8, display.top + HEIGHT * 0.5)

    self.backToHallBtn_ = cc.ui.UIPushButton.new({normal="#transparent.png", pressed="#room_pop_menu_item_pressed.png"}, {scale9=true})
        :setButtonSize(ITEM_WIDTH, ITEM_HEIGHT)
        :onButtonPressed(function() 
                self.backToHallIcon_:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("room_pop_menu_back_pressed.png"))
            end)
        :onButtonRelease(function()
                self.backToHallIcon_:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("room_pop_menu_back.png"))
            end)
        :onButtonClicked(function()
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                self:hidePanel(true)
                if callback then
                    callback(1)
                end
            end)
        :setButtonLabel("normal", ui.newTTFLabel({size=BUTTON_TEXT_SIZE, color=cc.c3b(0x8b, 0xa7, 0xc0), align=ui.TEXT_ALIGN_CENTER}))
        :setButtonLabel("pressed", ui.newTTFLabel({size=BUTTON_TEXT_SIZE, color=cc.c3b(0xd7, 0xe5, 0xf5), align=ui.TEXT_ALIGN_CENTER}))
        :setButtonLabelString(bm.LangUtil.getText("ROOM", "BACK_TO_HALL"))
        :setButtonLabelOffset(32, 0)
        :pos(0, TOP - ITEM_HEIGHT * 0.5 - 2)
        :addTo(self)

    self.backToHallIcon_ = display.newSprite("#room_pop_menu_back.png"):pos(LEFT + 48, self.backToHallBtn_:getPositionY()):addTo(self)

    self.split1_ = display.newSprite("#room_pop_menu_divide.png", 0, TOP - ITEM_HEIGHT - 2):addTo(self)
    self.split1_:setScaleX((WIDTH - 10) / 20)

    self.settingUserinfoBtn_ = cc.ui.UIPushButton.new({normal="#transparent.png", pressed="#room_pop_menu_item_pressed.png"}, {scale9=true})
        :setButtonSize(ITEM_WIDTH, ITEM_HEIGHT)
        :onButtonPressed(function() 
                self.userInforIcon_:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("room_pop_menu_userinfo_pressed.png"))
            end)
        :onButtonRelease(function()
                self.userInforIcon_:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("room_pop_menu_userinfo.png"))
            end)
        :onButtonClicked(function()
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                self:hidePanel()
                if callback then
                    callback(4)
                end
            end)
        :setButtonLabel("normal", ui.newTTFLabel({size=BUTTON_TEXT_SIZE, color=cc.c3b(0x8b, 0xa7, 0xc0), align=ui.TEXT_ALIGN_CENTER}))
        :setButtonLabel("pressed", ui.newTTFLabel({size=BUTTON_TEXT_SIZE, color=cc.c3b(0xd7, 0xe5, 0xf5), align=ui.TEXT_ALIGN_CENTER}))
        :setButtonLabelString(bm.LangUtil.getText("ROOM","USER_INFO_ROOM"))
        :setButtonLabelOffset(32, 0)
        :pos(0, TOP - ITEM_HEIGHT * 1.5 - 2)
        :addTo(self)


    self.userInforIcon_ = display.newSprite("#room_pop_menu_userinfo.png"):pos(LEFT + 48, self.settingUserinfoBtn_:getPositionY()):addTo(self)

    self.split2_ = display.newSprite("#room_pop_menu_divide.png", 0, TOP - ITEM_HEIGHT * 2 - 2):addTo(self)
    self.split2_:setScaleX((WIDTH - 10) / 20)

    self.settingBtn_ = cc.ui.UIPushButton.new({normal="#transparent.png", pressed="#room_pop_menu_item_pressed.png"}, {scale9=true})
        :setButtonSize(ITEM_WIDTH, ITEM_HEIGHT)
        :onButtonPressed(function() 
                self.settingIcon_:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("room_pop_menu_setting_pressed.png"))
            end)
        :onButtonRelease(function()
                self.settingIcon_:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("room_pop_menu_setting.png"))
            end)
        :onButtonClicked(function()
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                self:hidePanel()
                if callback then
                    callback(3)
                end
            end)
        :setButtonLabel("normal", ui.newTTFLabel({size=BUTTON_TEXT_SIZE, color=cc.c3b(0x8b, 0xa7, 0xc0), align=ui.TEXT_ALIGN_CENTER}))
        :setButtonLabel("pressed", ui.newTTFLabel({size=BUTTON_TEXT_SIZE, color=cc.c3b(0xd7, 0xe5, 0xf5), align=ui.TEXT_ALIGN_CENTER}))
        :setButtonLabelString(bm.LangUtil.getText("ROOM", "SETTING"))
        :setButtonLabelOffset(32, 0)
        :pos(0, TOP - ITEM_HEIGHT * 2.5 - 2)
        :addTo(self)

    self.settingIcon_ = display.newSprite("#room_pop_menu_setting.png"):pos(LEFT + 48, self.settingBtn_:getPositionY()):addTo(self)

    self.split3_ = display.newSprite("#room_pop_menu_divide.png", 0, TOP - ITEM_HEIGHT * 3 - 2):addTo(self)
    self.split3_:setScaleX((WIDTH - 10) / 20)
    
end

function RoomMenuPopup:showPanel()
    nk.PopupManager:addPopup(self, true, false, true, false)
end

function RoomMenuPopup:hidePanel(immediatlyClose)
    self.immediatlyClose_ = immediatlyClose
    nk.PopupManager:removePopup(self)
end

function RoomMenuPopup:onShowPopup()
    self:stopAllActions()
    transition.moveTo(self, {time=0.2, y=display.top - HEIGHT * 0.5 - 8, easing="OUT", onComplete=function()
        if self.onShow then
            self:onShow()
        end
    end})
end

function RoomMenuPopup:onRemovePopup(removeFunc)
    self:stopAllActions()
    if self.immediatlyClose_ then
        removeFunc()
    else
        transition.moveTo(self, {time=0.2, y=display.top + HEIGHT * 0.5, easing="OUT", onComplete=function() 
            removeFunc()
        end})
    end
end

return RoomMenuPopup