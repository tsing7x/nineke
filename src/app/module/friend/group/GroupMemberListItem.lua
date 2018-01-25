--
-- Author: johnny@boomegg.com
-- Date: 2014-08-31 20:40:41
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
-- 群成员列表元素
local GroupMemberListItem = class("GroupMemberListItem", bm.ui.ListItem)
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

GroupMemberListItem.WIDTH = 200
GroupMemberListItem.HEIGHT = 60

GroupMemberListItem.admin_uid = 0

local AVATAR_SIZE = 50

function GroupMemberListItem:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:setNodeEventEnabled(true)
    GroupMemberListItem.super.ctor(self, GroupMemberListItem.WIDTH, GroupMemberListItem.HEIGHT)
end

function GroupMemberListItem:createContent_()
    self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id
    local con = display.newNode()
        :pos(GroupMemberListItem.WIDTH*0.5,GroupMemberListItem.HEIGHT*0.5)
        :addTo(self)
    self.headBg_ = display.newSprite("#group_head_bg.png")
        :pos(-GroupMemberListItem.WIDTH*0.5+35,0)
        :addTo(con)
    self.onlineIcon_ = display.newScale9Sprite("#modal_texture.png",0, 0, cc.size(AVATAR_SIZE, AVATAR_SIZE))
        :pos(-GroupMemberListItem.WIDTH*0.5+35,0)
        :addTo(con)
    self.onlineIcon_:hide()

    --在线标记
    self.smallLineIcon_ = display.newSprite("#friend_state_online.png")
        :pos(-GroupMemberListItem.WIDTH*0.5+6, 0)
        :addTo(con)
    self.smallLineIcon_:setScale(0.3)

    self.nameLabel_ = ui.newTTFLabel({
        text = "",
        color=cc.c3b(0xdc, 0xdc, 0xff),
        size = 18,
        align = ui.TEXT_ALIGN_LEFT,
    })
    :pos(-GroupMemberListItem.WIDTH*0.5+70,0)
    :align(display.LEFT_CENTER)
    :addTo(con)

    self.ownerIcon_ = display.newScale9Sprite("#group_owner_icon.png",0, 0, cc.size(40, 24))
        :pos(60, 0)
        :addTo(con)
        :hide()

    self.zongHuoyueLabel_ = ui.newTTFLabel({
        text = "",
        color=cc.c3b(0xdc, 0xdc, 0xff),
        size = 18,
    })
    :pos(60, 0)
    :addTo(con)

    self.jinHuoyueLabel_ = ui.newTTFLabel({
        text = "",
        color=cc.c3b(0xb0, 0xc4, 0xff),
        size = 18,
        align = ui.TEXT_ALIGN_RIGHT,
    })
    :pos(GroupMemberListItem.WIDTH*0.5-20,0)
    :align(display.RIGHT_CENTER)
    :addTo(con)

    bm.TouchHelper.new(self, function(obj,evtName,isTouchInSprite,evt)
        if evtName==bm.TouchHelper.TOUCH_BEGIN then
            self.beginY_ = evt.y
            self.canDisEvt_ = true
        elseif evtName==bm.TouchHelper.TOUCH_MOVE then
            if self.canDisEvt_ then
                if math.abs(evt.y-self.beginY_)>5 then
                    self.canDisEvt_ = false
                end
            end
        elseif evtName==bm.TouchHelper.CLICK then
            if self.canDisEvt_ then
                self:dispatchEvent({name="ITEM_EVENT", type="ITEM_CLICK", data=self,x=evt.x,y=evt.y})
            end
        end
    end)
    self:setTouchSwallowEnabled(false)
end

function GroupMemberListItem:lazyCreateContent()
    if not self.created_ then
        self.created_ = true
        self:createContent_()
    end
    if self.dataChanged_ then
        self.dataChanged_ = false
        self:setData_(self.data_)
    end
end

function GroupMemberListItem:onDataSet(dataChanged, data)
    self.dataChanged_ = true
    self.data_ = data
end

function GroupMemberListItem:setData_(data)
    -- id : "40"
    -- uid : "10641"
    -- active : "0"
    -- create_time : "1476762696"
    -- status : "1"
    -- gid : "16"
    -- invite_type : "0"
    -- from_uid : "0"
    -- act : 0
    -- tid : 0    用tid判断，tid>0，表示在线
    -- nick : "123123"
    -- s_picture : "1"
    -- online 1 在线 0 不在线
    -- self.nameLabel_:setString(data.nick or "name")
    if tonumber(data.uid)==nk.userData.uid then
        data.online = 1
    end

    self.nameLabel_:setString(nk.Native:getFixedWidthText("", 22, (data.nick or "name"), 130))
    self.zongHuoyueLabel_:setString(data.active or "0")
    local size = self.zongHuoyueLabel_:getContentSize()
    if size.width>50 then
        if size.width>80 then
            self.ownerIcon_:setContentSize(80,36)
            bm.fitSprteWidth(self.zongHuoyueLabel_, 80)
        else
            self.ownerIcon_:setContentSize(size.width,size.width*0.45)
            bm.fitSprteWidth(self.zongHuoyueLabel_, size.width)
        end
    else
        self.ownerIcon_:setContentSize(40,24)
        bm.fitSprteWidth(self.zongHuoyueLabel_, 40)
    end

    if data.online and tonumber(data.online)==1 then
        self.onlineIcon_:hide()
        self.smallLineIcon_:setSpriteFrame(display.newSpriteFrame("friend_state_online.png"))
    else
        self.onlineIcon_:show()
        self.smallLineIcon_:setSpriteFrame(display.newSpriteFrame("friend_state_offline.png"))
    end

    self.jinHuoyueLabel_:setString(data.act or "0")
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
        
    if tonumber(GroupMemberListItem.admin_uid)==tonumber(data.uid) then
        self.ownerIcon_:show()
    else
        self.ownerIcon_:hide()
    end
end

function GroupMemberListItem:onCleanup()
    nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
end

return GroupMemberListItem