--
-- Author: Jonah0608@gmail.com
-- Date: 2016-09-18 14:57:21
--
local AvatarIcon          = import("boomegg.ui.AvatarIcon")
local ArenaUserInfoDetailPopup = import(".ArenaUserInfoDetailPopup")
local ArenaUserInfoItem = class("ArenaUserInfoItem",function()
    return display.newNode()
end)


function ArenaUserInfoItem:ctor(data)
    self.data_ = data
    self:setupView()
end

function ArenaUserInfoItem:setupView()
    self.bg_ = display.newSprite("#matchreg_user_list_bg.png")
        :addTo(self)

    self.avatar_ = AvatarIcon.new("#common_male_avatar.png", 55, 55, 1, {resId="#transparent.png", size=cc.size(55,55)}, 1, 0,0)
        :pos(-75, 0)
        :addTo(self)

    self.avatar_:setSexAndImgUrl("f",self.data_.img)
    
    local l_x = -35
    self.labelId_ = ui.newTTFLabel({text = nk.Native:getFixedWidthText("", 18, self.data_.nick or "", 150), color = cc.c3b(0x76, 0x80, 0xCF), size = 18, align = ui.TEXT_ALIGN_LEFT}):pos(l_x, 20):addTo(self)
    self.labelId_:setAnchorPoint(cc.p(0,0.5))
    self.labelCoin_ = ui.newTTFLabel({text = bm.TimeUtil:getTimeStampString(self.data_.time,"/"), color = cc.c3b(0x76, 0x80, 0xCF), size = 18, align = ui.TEXT_ALIGN_LEFT}):pos(l_x, -20):addTo(self)
    self.labelCoin_:setAnchorPoint(cc.p(0,0.5))
    self.btn_ = cc.ui.UIPushButton.new({normal = "#transparent.png", pressed = "#transparent.png"}, {scale9 = true})
        :setButtonSize(237,82)
        :onButtonClicked(handler(self,self.onClickHead))
        :addTo(self)
    self.btn_:setTouchSwallowEnabled(false)
end

function ArenaUserInfoItem:onClickHead()
    if self.data_.uid == nk.userData.uid then
    else
        ArenaUserInfoDetailPopup.new():show(self.data_.uid)
    end
end

return ArenaUserInfoItem