--
-- Author: Jonah0608@gmail.com
-- Date: 2016-09-18 14:57:21
--
local UserInfoOtherDialog = import(".UserInfoOtherDiceDialog")
local UserInfoPopup = import("app.module.userInfo.UserInfoPopup")
local UserInfoItem = class("UserInfoItem",function()
    return display.newNode()
end)


function UserInfoItem:ctor(ctx,seatId,data,exdata)
    self.ctx = ctx
    self.data_ = data
    self.exData_ = exdata
    self.data_.seatId = seatId
    self:setupView()
end

function UserInfoItem:setupView()
    self.bg_ = display.newScale9Sprite("#dice_userinfo_item_bg.png",0,0,cc.size(216,99))
        :addTo(self)
        
    self.avatar_ = nk.ui.CircleIcon.new():addTo(self):pos(-60,0)
    if self.exData_ and self.exData_.img and string.len(self.exData_.img) > 5 then
        self.avatar_:setSexAndImgUrl(self.data_.gender,self.exData_.img)
    else
        self.avatar_:setSexAndImgUrl(self.data_.gender,self.data_.img)
    end

    local l_x = -10
    self.labelId_ = ui.newTTFLabel({text = "ID:" .. self.data_.uid, color = cc.c3b(0x76, 0x80, 0xCF), size = 18, align = ui.TEXT_ALIGN_LEFT}):pos(l_x, 20):addTo(self)
    self.labelId_:setAnchorPoint(cc.p(0,0.5))
    self.labelCoin_ = ui.newTTFLabel({text = bm.LangUtil.getText("DICE","USERINFO_CHIPS",bm.formatBigNumber(self.data_.money or self.data_.chips)), color = cc.c3b(0x76, 0x80, 0xCF), size = 18, align = ui.TEXT_ALIGN_LEFT}):pos(l_x, -20):addTo(self)
    self.labelCoin_:setAnchorPoint(cc.p(0,0.5))
    self.btn_ = cc.ui.UIPushButton.new({normal = "#transparent.png", pressed = "#transparent.png"}, {scale9 = true})
        :setButtonSize(216,99)
        :onButtonClicked(handler(self,self.onClickHead))
        :addTo(self)
    self.btn_:setTouchSwallowEnabled(false)
end

function UserInfoItem:onClickHead()
    if self.data_ then
        if self.data_.uid == nk.userData.uid then
            UserInfoPopup.new():show(false,nil,true)
        else
            UserInfoOtherDialog.new(self.ctx):show(self.data_)
        end
    else
        return
    end
end

return UserInfoItem