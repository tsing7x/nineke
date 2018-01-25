--
-- Author: johnny@boomegg.com
-- Date: 2014-08-31 20:40:41
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
-- 好友列表元素
local GroupInviteListItem = class("GroupInviteListItem", bm.ui.ListItem)
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

GroupInviteListItem.WIDTH = 200
GroupInviteListItem.HEIGHT = 82

local AVATAR_SIZE = 50

function GroupInviteListItem:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    GroupInviteListItem.super.ctor(self, GroupInviteListItem.WIDTH, GroupInviteListItem.HEIGHT)
    self:setNodeEventEnabled(true)
end

function GroupInviteListItem:createContent_()
    self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id
    local con = display.newNode()
        :pos(GroupInviteListItem.WIDTH*0.5,GroupInviteListItem.HEIGHT*0.5)
        :addTo(self)

    display.newScale9Sprite("#panel_overlay.png",
       0, 0, cc.size(GroupInviteListItem.WIDTH, GroupInviteListItem.HEIGHT)):addTo(con)


    self.headBg_ = display.newSprite("#group_head_bg.png")
        :pos(-GroupInviteListItem.WIDTH*0.5+45,0)
        :addTo(con)
    self.nameLabel_ = ui.newTTFLabel({
            text = "",
            color = cc.c3b(0xdc,0xdc,0xff),
            size = 22,
            align = ui.TEXT_ALIGN_LEFT,
        })
        :pos(-GroupInviteListItem.WIDTH*0.5+80,0)
        :align(display.LEFT_CENTER)
        :addTo(con)


    self.inviteBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_green_normal.png", pressed = "#common_btn_green_pressed.png"},{scale9 = true})
        :setButtonSize(80, 50)
        :setButtonLabel(ui.newTTFLabel({text = bm.LangUtil.getText("GROUP","INVITEPOPINVITEBTN"),size = 22,color = cc.c3b(0xff, 0xff, 0xff)}))
        :align(display.RIGHT_CENTER)
        :pos(GroupInviteListItem.WIDTH/2-20,0)
        :addTo(con)
        :onButtonClicked(buttontHandler(self, function(...)
            self:dispatchEvent({name="ITEM_EVENT", type="GROUP_INVITE", data=self})
        end))
end

function GroupInviteListItem:lazyCreateContent()
    if not self.created_ then
        self.created_ = true
        self:createContent_()
    end
    if self.dataChanged_ then
        self.dataChanged_ = false
        self:setData_(self.data_)
    end
end

function GroupInviteListItem:onDataSet(dataChanged, data)
    self.dataChanged_ = true
    self.data_ = data
end

function GroupInviteListItem:setData_(data)
    self.nameLabel_:setString(data.nick)
    if data.s_picture and string.len(data.s_picture)>5 then
        local img = data.s_picture
        nk.ImageLoader:loadAndCacheImage(
            self.userAvatarLoaderId_, 
            img,
            handler(self, function(obj, success, sprite)
                if success then
                    local tex = sprite:getTexture()
                    local texSize = tex:getContentSize()
                    local con = obj.headBg_
                    con:setTexture(tex)
                    con:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
                    con:setScaleX(AVATAR_SIZE / texSize.width)
                    con:setScaleY(AVATAR_SIZE / texSize.height)
                else
                    local con = self.headBg_
                    con:setSpriteFrame(display.newSpriteFrame("common_male_avatar.png"))
                    local texSize = con:getContentSize()
                    con:setScaleX(AVATAR_SIZE / texSize.width)
                    con:setScaleY(AVATAR_SIZE / texSize.height)
                end
            end),
            nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
        )
    else
        local con = self.headBg_
        con:setSpriteFrame(display.newSpriteFrame("common_male_avatar.png"))
        local texSize = con:getContentSize()
        con:setScaleX(AVATAR_SIZE / texSize.width)
        con:setScaleY(AVATAR_SIZE / texSize.height)
    end
end

function GroupInviteListItem:onAvatarLoadComplete_(success, sprite)
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

function GroupInviteListItem:onCleanup()
    nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
    if self.loadImageHandle_ then
        scheduler.unscheduleGlobal(self.loadImageHandle_)
        self.loadImageHandle_ = nil
    end
end

return GroupInviteListItem