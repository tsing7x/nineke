--
-- Author: Jonah0608@gmail.com
-- Date: 2015-12-29 10:03:53
--
local PushMsgListItem = class("PushMsgListItem", bm.ui.ListItem)

function PushMsgListItem:ctor()
    self:setNodeEventEnabled(true)
    PushMsgListItem.super.ctor(self, 560, 84)
end

function PushMsgListItem:createContent_()
    local posY = self.height_ * 0.5
    -- 背景
    display.newScale9Sprite("#pushmsg_listitem_bg.png", 0, 0, cc.size(550, 80),cc.rect(4, 13, 2, 2))
        :pos(280,43)
        :addTo(self)

    -- 头像
    self.avatar_ = display.newSprite("#common_male_avatar.png")
        :scale(75 / 100)
        :pos(48, posY)
        :addTo(self)

    self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id

    -- 昵称标签
    self.nick_ =  ui.newTTFLabel({text = "", color = cc.c3b(0xC7, 0xE5, 0xFF), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER, 100, posY)
        :addTo(self)

    -- 追踪按钮
    self.pushBtn_ = cc.ui.UIPushButton.new({normal = "#pushmsg_btn.png", pressed = "#pushmsg_btn.png", disabled = "#pushmsg_btn.png"}, {scale9 = true})
        :setButtonSize(160, 50)
        :setButtonLabel(ui.newTTFLabel({text = bm.LangUtil.getText("PUSHMSG","MSG_TO"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER}))
        :pos(470, posY)
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.onPushClick_))
    self.pushBtn_:setTouchSwallowEnabled(false)
end

function PushMsgListItem:lazyCreateContent()
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

function PushMsgListItem:onItemDeactived()
    if self.created_ then
        nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
        if self.avatarLoaded_ then
            self.avatarLoaded_ = false
            self.avatar_:setSpriteFrame(display.newSpriteFrame("common_male_avatar.png"))
            self.avatar_:scale(75 / 100)
            self.avatarDeactived_ = true
            cc.Director:getInstance():getTextureCache():removeUnusedTextures()
        end
    end
end

function PushMsgListItem:onDataSet(dataChanged, data)
    self.dataChanged_ = self.dataChanged_ or dataChanged
    self.data_ = data
end

function PushMsgListItem:setData_(data)
    -- 设置头像
    self.avatar_:scale(75 / 100)

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

function PushMsgListItem:onAvatarLoadComplete_(success, sprite)
    if success then
        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()
        self.avatar_:setTexture(tex)
        self.avatar_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
        self.avatar_:setScaleX(75 / texSize.width)
        self.avatar_:setScaleY(75 / texSize.height)
        self.avatarLoaded_ = true
    end
end

function PushMsgListItem:onPushClick_()
    self.owner_.controller_:pushMsg(self)
end

function PushMsgListItem:onCleanup()
    nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
    if self.loadImageHandle_ then
        scheduler.unscheduleGlobal(self.loadImageHandle_)
        self.loadImageHandle_ = nil
    end
end


return PushMsgListItem