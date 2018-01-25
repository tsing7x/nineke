--
-- Author: johnny@boomegg.com
-- Date: 2014-08-31 20:40:41
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
-- 好友列表元素
local GroupInfoListItem = class("GroupInfoListItem", bm.ui.ListItem)
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

GroupInfoListItem.WIDTH = 200
GroupInfoListItem.HEIGHT = 120

local AVATAR_SIZE = 82
local SUB_ITEM_COUNT = 2

function GroupInfoListItem:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:setNodeEventEnabled(true)
    GroupInfoListItem.super.ctor(self, GroupInfoListItem.WIDTH, GroupInfoListItem.HEIGHT)
end

function GroupInfoListItem:createSubItem(itemWidth,itemHeight,callBack,index)
    local node = display.newNode()
    local sx = -itemWidth/2
    node.index = index
    node.callBack = callBack
    node.bg = display.newScale9Sprite("#panel_overlay.png", 0, 0, cc.size(itemWidth, itemHeight))
        :addTo(node)

    node.head = display.newSprite("#group_head_bg.png")
        :pos(sx + 50, 0)
        :addTo(node)

    local label_x = sx + 100
    node.name = ui.newTTFLabel({
        text = "",
        color=cc.c3b(0xed, 0xda, 0xde), 
        size = 16,
        align = ui.TEXT_ALIGN_LEFT,
    })
    :align(display.LEFT_CENTER, label_x, 38)
    :addTo(node)

    node.introduction = ui.newTTFLabel({
        text = "",
        color=cc.c3b(0xc0, 0xc4, 0xde), 
        size = 14,
        align = ui.TEXT_ALIGN_LEFT,
        dimensions = cc.size(260, 40)
    })
    :align(display.LEFT_CENTER, label_x, 8)
    :addTo(node)

    node.huoyue = ui.newTTFLabel({
        text = "",
        color=cc.c3b(0xc0, 0xc4, 0xde), 
        size = 14,
        align = ui.TEXT_ALIGN_LEFT,
    })
    :align(display.LEFT_CENTER, label_x, -18)
    :addTo(node)

    node.member = ui.newTTFLabel({
        text = "",
        color=cc.c3b(0xc0, 0xc4, 0xde), 
        size = 14,
        align = ui.TEXT_ALIGN_LEFT,
    })
    :align(display.LEFT_CENTER, label_x, -35)
    :addTo(node)

    node.btn = cc.ui.UIPushButton.new({normal = "#group_join_normal.png", pressed = "#group_join_down.png"})
        :setButtonLabel(ui.newTTFLabel({text = bm.LangUtil.getText("GROUP","JOINGROUP"), size = 18, color = cc.c3b(0xff, 0xff, 0xff)}))
        :setButtonLabelOffset(5, 0)
        :align(display.RIGHT_BOTTOM, -sx, -itemHeight*0.5)
        :addTo(node)
        :onButtonClicked(buttontHandler(self, function()
            if node.callBack then
                node.callBack(node.index)
            end
        end))

    return node
end

function GroupInfoListItem:removeLoad()
    nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId1_)
    nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId2_)
    nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId3_)
end

function GroupInfoListItem:createContent_()
    self.userAvatarLoaderId1_ = nk.ImageLoader:nextLoaderId()
    self.userAvatarLoaderId2_ = nk.ImageLoader:nextLoaderId()
    self.userAvatarLoaderId3_ = nk.ImageLoader:nextLoaderId()

    local space = 10

    local itemWidth = (GroupInfoListItem.WIDTH - space)/SUB_ITEM_COUNT
    local itemHeight = GroupInfoListItem.HEIGHT - 7

    local con = display.newNode()
        :pos(GroupInfoListItem.WIDTH*0.5,GroupInfoListItem.HEIGHT*0.5)
        :addTo(self)

    self.list_ = {}
    local callBack = function(index)
        self:dispatchEvent({name="ITEM_EVENT", type="JOIN_GROUP_INFO", data=self.data_[index]})
    end

    local node = nil
    for i = 1, SUB_ITEM_COUNT do
        node = self:createSubItem(itemWidth, itemHeight, callBack, i)
        node:addTo(con)
        node:pos(-GroupInfoListItem.WIDTH*0.5 + itemWidth*0.5 + (i-1)*(itemWidth+space), 0)
        self.list_[i] = node
    end
end

function GroupInfoListItem:lazyCreateContent()
    if not self.created_ then
        self.created_ = true
        self:createContent_()
    end

    if self.dataChanged_ then
        self.dataChanged_ = false
        self:setData_(self.data_)
    end
end

function GroupInfoListItem:onDataSet(dataChanged, data)
    self.dataChanged_ = true
    self.data_ = data
end

function GroupInfoListItem:setData_(data)
    self:removeLoad()
    for i = 1, SUB_ITEM_COUNT do
        if data[i] then
            local node = self.list_[i]
            node:show()
            node.name:setString(data[i].group_name)

            node.introduction:setString(data[i].description or "")

            node.huoyue:setString(bm.LangUtil.getText("GROUP","ACTWORD", data[i].active))

            node.member:setString(data[i].pnum.."/"..data[i].num)

            if data[i].image_url and string.len(data[i].image_url) > 5 then
                local img = data[i].image_url
                nk.ImageLoader:loadAndCacheImage(
                    self["userAvatarLoaderId"..i.."_"], 
                    img,
                    handler(self, function(obj, success, sprite)
                        if success then
                            local tex = sprite:getTexture()
                            local texSize = tex:getContentSize()
                            local con = obj.list_[i].head
                            con:setTexture(tex)
                            con:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
                            con:setScaleX(AVATAR_SIZE / texSize.width)
                            con:setScaleY(AVATAR_SIZE / texSize.height)
                        else
                            local con = self.list_[i].head
                            con:setSpriteFrame(display.newSpriteFrame("common_male_avatar.png"))
                            local texSize = con:getContentSize()
                            con:setScaleX(AVATAR_SIZE / texSize.width)
                            con:setScaleY(AVATAR_SIZE / texSize.height)
                        end
                    end),
                    nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
                )
            else
                local con = self.list_[i].head
                con:setSpriteFrame(display.newSpriteFrame("common_male_avatar.png"))
                local texSize = con:getContentSize()
                con:setScaleX(AVATAR_SIZE / texSize.width)
                con:setScaleY(AVATAR_SIZE / texSize.height)
            end
        else
            self.list_[i]:hide()
        end
    end
end

function GroupInfoListItem:onAvatarLoadComplete_(success, sprite)
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

function GroupInfoListItem:onCleanup()
    self:removeLoad()
    if self.loadImageHandle_ then
        scheduler.unscheduleGlobal(self.loadImageHandle_)
        self.loadImageHandle_ = nil
    end
end

return GroupInfoListItem