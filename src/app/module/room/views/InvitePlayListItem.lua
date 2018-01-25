--
-- Author: KevinYu
-- Date: 2017-01-18 15:11:57
-- 邀请列表元素
local InvitePlayListItem = class("InvitePlayListItem", bm.ui.ListItem)

local ITEM_W, ITEM_H = 600, 70
local AVATAR_SIZE = 55

function InvitePlayListItem:ctor()
    InvitePlayListItem.super.ctor(self, ITEM_W, ITEM_H)
end

function InvitePlayListItem:createContent_()
    self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id

    local sx, sy = 0, ITEM_H/2
    self.avatar_ = display.newSprite("#common_male_avatar.png")
        :pos(sx + 35, sy)
        :addTo(self)

    self.sexIcon_ = display.newSprite("#pop_userinfo_sex_male.png")
        :pos(sx + 90, sy)
        :scale(0.6)
        :addTo(self)

    self.nameLabel_ = ui.newTTFLabel({
            text = "",
            color=cc.c3b(0xdc, 0xdc, 0xff),
            size = 18,
            align = ui.TEXT_ALIGN_LEFT,
        })
        :align(display.LEFT_CENTER, sx + 120, sy)
        :addTo(self)

   	display.newSprite("#chip_icon.png")
        :pos(ITEM_W/2 - 40, sy)
        :scale(0.7)
        :addTo(self)

    self.moneyLabel_ = ui.newTTFLabel({
        text = "",
        size = 18,
    })
    :align(display.LEFT_CENTER, ITEM_W/2 - 20, sy)
    :addTo(self)

    cc.ui.UIPushButton.new({normal="#common_btn_green_normal.png", pressed="#common_btn_green_pressed.png"}, {scale9 = true})
    	:setButtonSize(94, 52)
        :setButtonLabel(cc.ui.UILabel.new({text = bm.LangUtil.getText("GROUP","ROOM_INVITE_TITLE"), size = 22}))
        :pos(ITEM_W - 60, sy)
        :onButtonClicked(buttontHandler(self, self.onInviteClicked_))
        :addTo(self)
end

function InvitePlayListItem:onInviteClicked_()
    bm.EventCenter:dispatchEvent({name="ROOM_INVITE_PLAY", uid = self.data_.uid})
end

function InvitePlayListItem:lazyCreateContent()
    if not self.created_ then
        self.created_ = true
        self:createContent_()
    end

    if self.dataChanged_ then
        self.dataChanged_ = false
        self:setData_(self.data_)
    end
end

function InvitePlayListItem:onDataSet(dataChanged, data)
    self.dataChanged_ = self.dataChanged_ or dataChanged
    self.data_ = data
end

function InvitePlayListItem:setData_(data)
    if data.sex == "f" then
        self.sexIcon_:setSpriteFrame(display.newSpriteFrame("pop_userinfo_sex_female.png"))
        self.avatar_:setSpriteFrame(display.newSpriteFrame("common_female_avatar.png"))
    else
        self.sexIcon_:setSpriteFrame(display.newSpriteFrame("pop_userinfo_sex_male.png"))
        self.avatar_:setSpriteFrame(display.newSpriteFrame("common_male_avatar.png"))
    end

	-- 设置头像
    self.avatar_:scale(AVATAR_SIZE / 100)
    if data.img and string.len(data.img) > 5 then
        nk.ImageLoader:loadAndCacheImage(
        self.userAvatarLoaderId_, 
        data.img, 
        handler(self, self.onAvatarLoadComplete_), 
        nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
        )
    end

    self.nameLabel_:setString(nk.Native:getFixedWidthText("", 24, data.nick, 200))

    self.moneyLabel_:setString(bm.formatNumberWithSplit(data.money))
end

function InvitePlayListItem:onAvatarLoadComplete_(success, sprite)
    if success then
        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()
        self.avatar_:setTexture(tex)
        self.avatar_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
        self.avatar_:setScaleX(AVATAR_SIZE / texSize.width)
        self.avatar_:setScaleY(AVATAR_SIZE / texSize.height)
        self.avatarLoaded_ = true
    end
end

function InvitePlayListItem:onCleanup()
    nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
end

return InvitePlayListItem