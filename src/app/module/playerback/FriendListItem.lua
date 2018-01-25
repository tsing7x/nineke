--
-- Author: johnny@boomegg.com
-- Date: 2014-08-31 20:40:41
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.

local FriendListItem = class("FriendListItem", bm.ui.ListItem)
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

function FriendListItem:ctor()
    self:setNodeEventEnabled(true)
    FriendListItem.super.ctor(self, 210, 70)

    local posY = self.height_ * 0.5
    -- 分割线
    local lineWidth = 210
    local lineHeight = 2
    local lineMarginLeft = 12
    display.newScale9Sprite("#pop_up_split_line.png")
        :pos(lineWidth/2 + lineMarginLeft, 0)
        :addTo(self)
        :size(lineWidth, lineHeight)
end

function FriendListItem:createContent_()
    local posY = self.height_ * 0.5
    -- 分割线
    local lineWidth = 210
    local lineHeight = 2
    local lineMarginLeft = 12

    -- 头像
    self.avatar_ = display.newSprite("#common_male_avatar.png")
        :scale(64 / 100)
        :pos(32, posY)
        :addTo(self)
    self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id


    -- 昵称标签
    self.nick_ =  ui.newTTFLabel({text = "", color = cc.c3b(0xC7, 0xE5, 0xFF), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER, 70, posY)
        :addTo(self)
end

function FriendListItem:lazyCreateContent()
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

function FriendListItem:onItemDeactived()
    if self.created_ then
        nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
        if self.avatarLoaded_ then
            self.avatarLoaded_ = false
            self.avatar_:setSpriteFrame(display.newSpriteFrame("common_male_avatar.png"))
            self.avatar_:scale(64 / 100)
            self.avatarDeactived_ = true
            cc.Director:getInstance():getTextureCache():removeUnusedTextures()
        end
    end
end

function FriendListItem:onDataSet(dataChanged, data)
    self.dataChanged_ = self.dataChanged_ or dataChanged
    self.data_ = data
end

function FriendListItem:setData_(data)
    self.avatar_:scale(64 / 100)

    -- 设置昵称
    self.nick_:setString(bm.limitNickLength(data.nick))

    if string.len(data.img) > 5 then
        if self.loadImageHandle_ then
            scheduler.unscheduleGlobal(self.loadImageHandle_)
            self.loadImageHandle_ = nil
        end
        
        self.loadImageHandle_ = nil
        nk.ImageLoader:loadAndCacheImage(
            self.userAvatarLoaderId_, 
            data.img, 
            handler(self, self.onAvatarLoadComplete_), 
            nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
        )
    end
end

function FriendListItem:onAvatarLoadComplete_(success, sprite)
    if success then
        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()
        self.avatar_:setTexture(tex)
        self.avatar_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
        self.avatar_:setScaleX(64 / texSize.width)
        self.avatar_:setScaleY(64 / texSize.height)
        self.avatarLoaded_ = true
    end
end


function FriendListItem:onCleanup()
    nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
    if self.loadImageHandle_ then
        scheduler.unscheduleGlobal(self.loadImageHandle_)
        self.loadImageHandle_ = nil
    end
end

return FriendListItem