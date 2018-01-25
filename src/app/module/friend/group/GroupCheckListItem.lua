--
-- Author: johnny@boomegg.com
-- Date: 2014-08-31 20:40:41
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
-- 申请列表元素
local GroupCheckListItem = class("GroupCheckListItem", bm.ui.ListItem)
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

GroupCheckListItem.WIDTH = 200
GroupCheckListItem.HEIGHT = 56

local AVATAR_SIZE = 50

function GroupCheckListItem:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:setNodeEventEnabled(true)
    GroupCheckListItem.super.ctor(self, GroupCheckListItem.WIDTH, GroupCheckListItem.HEIGHT)
end

function GroupCheckListItem:createContent_()
    self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id
    local con = display.newNode()
        :pos(GroupCheckListItem.WIDTH*0.5,GroupCheckListItem.HEIGHT*0.5)
        :addTo(self)
    self.headBg_ = display.newSprite("#group_head_bg.png")
        :pos(-GroupCheckListItem.WIDTH*0.5+35,0)
        :addTo(con)
    self.nameLabel_ = ui.newTTFLabel({
            text = "",
            color=cc.c3b(0xdc,0xdc,0xff),
            size = 22,
            align = ui.TEXT_ALIGN_LEFT,
        })
        :pos(-GroupCheckListItem.WIDTH*0.5+70,0)
        :align(display.LEFT_CENTER)
        :addTo(con)

    self.moneyLabel_ = ui.newTTFLabel({
            text = "",
            color=cc.c3b(0xff,0xd8,0x00),
            size = 22,
        })
        :pos(0,0)
        :addTo(con)

    self.agreeBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_green_normal.png", pressed = "#common_btn_green_pressed.png"},{scale9 = true})
        :setButtonSize(80, 50)
        :setButtonLabel(ui.newTTFLabel({text = bm.LangUtil.getText("GROUP","CHECKPOPAGREE"),size = 22,color = cc.c3b(0xff, 0xff, 0xff)}))
        :align(display.RIGHT_CENTER)
        :pos(GroupCheckListItem.WIDTH/3-10,0)
        :addTo(con)
        :onButtonClicked(buttontHandler(self, function(...)
            self:dispatchEvent({name="ITEM_EVENT", type="GROUP_AGREE_IN", data=self})
        end))

    self.refuseBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_blue_normal.png", pressed = "#common_btn_blue_pressed.png"},{scale9 = true})
        :setButtonSize(80, 50)
        :setButtonLabel(ui.newTTFLabel({text = bm.LangUtil.getText("GROUP","CHECKPOPREFUSE"),size = 22,color = cc.c3b(0xff, 0xff, 0xff)}))
        :align(display.LEFT_CENTER)
        :pos(GroupCheckListItem.WIDTH/3+10,0)
        :addTo(con)
        :onButtonClicked(buttontHandler(self, function(...)
            self:dispatchEvent({name="ITEM_EVENT", type="GROUP_REFUSE_IN", data=self})
        end))

    local line = display.newScale9Sprite("#group_dividing_line.png",
        0, -GroupCheckListItem.HEIGHT*0.5, cc.size(GroupCheckListItem.WIDTH-4, 2))
        :addTo(con)
end

function GroupCheckListItem:lazyCreateContent()
    if not self.created_ then
        self.created_ = true
        self:createContent_()
    end

    if self.dataChanged_ then
        self.dataChanged_ = false
        self:setData_(self.data_)
    end
end

function GroupCheckListItem:onDataSet(dataChanged, data)
    self.dataChanged_ = true
    self.data_ = data
end

function GroupCheckListItem:setData_(data)
    self.nameLabel_:setString(nk.Native:getFixedWidthText("", 22, (data.nick or ""), 200))
    self.moneyLabel_:setString(bm.formatNumberWithSplit(data.gcoins or 0))
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
                    con:setDisplayFrame(display.newSpriteFrame("common_male_avatar.png"))
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

function GroupCheckListItem:onAvatarLoadComplete_(success, sprite)
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

function GroupCheckListItem:onCleanup()
    nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
    if self.loadImageHandle_ then
        scheduler.unscheduleGlobal(self.loadImageHandle_)
        self.loadImageHandle_ = nil
    end
end

return GroupCheckListItem