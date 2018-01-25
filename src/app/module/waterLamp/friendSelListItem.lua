--
-- Author: johnny@boomegg.com
-- Date: 2014-08-31 20:40:41
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
-- 好友列表元素
local FriendSelListItem = class("FriendSelListItem", bm.ui.ListItem)
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

local AVATAR_SIZE = 50

function FriendSelListItem:ctor()
    self:setNodeEventEnabled(true)
    FriendSelListItem.super.ctor(self, 264, 76)
end

function FriendSelListItem:createContent_()
    local posY = self.height_ * 0.5
    
    display.newSprite("#waterLampDivider.png")
        :pos(self.width_ * 0.5, 0)
        :addTo(self)

    --选择按钮
    cc.ui.UIPushButton.new({normal= "#waterLampSelBtn.png",pressed="#waterLampSelBtn.png"})
        :pos(223, 32)
        :onButtonClicked(handler(self, function()
            self.owner_.popu:modToId(self.selUid)
        end))
        :addTo(self, 100)

    -- 头像
    local avatar_x = 80
    self.avatar_ = display.newSprite("#common_male_avatar.png")
        :scale(AVATAR_SIZE / 100)
        :pos(avatar_x - 44, posY)
        :addTo(self)
    self.avatarBg_ = display.newSprite("#ranking_avatar_bg.png")
        :pos(avatar_x - 20, posY)
        :addTo(self)
        :hide()

    self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id

    -- 昵称标签
    self.nick_ =  ui.newTTFLabel({text = "", color = cc.c3b(0x73, 0x56, 0x52), size = 22, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER, 70, posY + 14)
        :addTo(self)

    -- 资产
    self.money_ =  ui.newTTFLabel({text = "", color = cc.c3b(0x73, 0x56, 0x52), size = 22, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER, 66, posY - 16)
        :addTo(self)

    local button_width = 160
    local button_height = 55
end

function FriendSelListItem:lazyCreateContent()
    if not self.created_ then
        self.created_ = true
        self:createContent_()
    end
    if self.dataChanged_ then
        self.dataChanged_ = false
        self:setData_(self.data_)
    end
    if self.avatarDeactived_ and self.data_ then
        self.avatarDeactived_ = false
        nk.ImageLoader:loadAndCacheImage(
            self.userAvatarLoaderId_, 
            self.data_.img, 
            handler(self, self.onAvatarLoadComplete_), 
            nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
        )
    end
end

function FriendSelListItem:onItemDeactived()
    if self.created_ then
        nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
        if self.avatarLoaded_ then
            self.avatarLoaded_ = false
            self.avatar_:setSpriteFrame(display.newSpriteFrame("common_male_avatar.png"))
            self.avatar_:scale(AVATAR_SIZE / 100)
            self.avatarDeactived_ = true
            cc.Director:getInstance():getTextureCache():removeUnusedTextures()
        end
    end
end

function FriendSelListItem:onDataSet(dataChanged, data)
    self.dataChanged_ = true--self.dataChanged_ or dataChanged
    self.data_ = data
end

function FriendSelListItem:setData_(data)
    -- 设置头像
    if data.sex == "f" then
        self.avatar_:setSpriteFrame(display.newSpriteFrame("common_female_avatar.png"))
    else
        self.avatar_:setSpriteFrame(display.newSpriteFrame("common_male_avatar.png"))
    end
    self.avatar_:scale(AVATAR_SIZE / 100)

    -- 设置昵称
    self.nick_:setString(bm.limitNickLength(data.nick, 20))

    -- 资产设置
    self.selUid = data.uid
    self.money_:setString("ID: " .. data.uid)

    local isDelListItem = false -- 是否是已删除好友列表
    if isset(data, "s_picture") then
        data.img = data.s_picture
        isDelListItem = true
    end

    if string.len(data.img) > 5 then
        self.loadImageHandle_ = nil
        nk.ImageLoader:loadAndCacheImage(
            self.userAvatarLoaderId_, 
            data.img, 
            handler(self, self.onAvatarLoadComplete_), 
            nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
        )
    end
end

function FriendSelListItem:onAvatarLoadComplete_(success, sprite)
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

function FriendSelListItem:onCleanup()
    nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
    if self.loadImageHandle_ then
        scheduler.unscheduleGlobal(self.loadImageHandle_)
        self.loadImageHandle_ = nil
    end
end

return FriendSelListItem