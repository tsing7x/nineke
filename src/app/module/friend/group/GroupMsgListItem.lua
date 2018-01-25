--
-- Author: johnny@boomegg.com
-- Date: 2014-08-31 20:40:41
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
-- 好友列表元素
local GroupMsgListItem = class("GroupMsgListItem", bm.ui.ListItem)
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

GroupMsgListItem.WIDTH = 200
GroupMsgListItem.HEIGHT = 82

local AVATAR_SIZE = 50

function GroupMsgListItem:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:setNodeEventEnabled(true)
    GroupMsgListItem.super.ctor(self, GroupMsgListItem.WIDTH, GroupMsgListItem.HEIGHT)
end

function GroupMsgListItem:createContent_()
    local con = display.newNode()
        :pos(GroupMsgListItem.WIDTH*0.5,GroupMsgListItem.HEIGHT*0.5)
        :addTo(self)

    display.newScale9Sprite("#panel_overlay.png",
       0, 0, cc.size(GroupMsgListItem.WIDTH, GroupMsgListItem.HEIGHT)):addTo(con)

    self.nameLabel_ = ui.newTTFLabel({
            text = "",
            color=cc.c3b(0xdc,0xdc,0xff),
            size = 22,
            align = ui.TEXT_ALIGN_LEFT,
            dimensions=cc.size(GroupMsgListItem.WIDTH-40, GroupMsgListItem.HEIGHT)
        })
        :align(display.LEFT_CENTER, -GroupMsgListItem.WIDTH*0.5+20, 0)
        :addTo(con)

    -- self.inviteBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_blue_normal.png", pressed = "#common_btn_blue_pressed.png"},{scale9 = true})
    --     :setButtonSize(80, 50)
    --     :setButtonLabel(ui.newTTFLabel({text = "忽略",size = 22,color = cc.c3b(0xff, 0xff, 0xff)}))
    --     -- :setButtonLabelAlignment(display.RIGHT_CENTER)
    --     -- :setButtonLabelOffset(-18, 0)
    --     :align(display.RIGHT_CENTER)
    --     :pos(GroupMsgListItem.WIDTH/2-20,0)
    --     :addTo(con)
    --     :onButtonClicked(buttontHandler(self, function(...)
    --         self:dispatchEvent({name="ITEM_EVENT", type="DELETE_GROUP_INFO", data=self})
    --     end))
end

function GroupMsgListItem:lazyCreateContent()
    if not self.created_ then
        self.created_ = true
        self:createContent_()
    end
    if self.dataChanged_ then
        self.dataChanged_ = false
        self:setData_(self.data_)
    end
    if self.avatarDeactived_ and self.data_ then
        -- self.avatarDeactived_ = false
        -- nk.ImageLoader:loadAndCacheImage(
        --     self.userAvatarLoaderId_, 
        --     self.data_.img, 
        --     handler(self, self.onAvatarLoadComplete_), 
        --     nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
        -- )
    end
end

function GroupMsgListItem:onDataSet(dataChanged, data)
    self.dataChanged_ = true--self.dataChanged_ or dataChanged
    self.data_ = data
end

function GroupMsgListItem:setData_(data)
    local date = os.date("*t",data.create_time)
    local year = tonumber(date.year)
    local month = tonumber(date.month) if month<10 then month = ("0"..month) end
    local day = tonumber(date.day) if day<10 then day = ("0"..day) end
    local hour = tonumber(date.hour) if hour<10 then hour = ("0"..hour) end
    local min = tonumber(date.min) if min<10 then min = ("0"..min) end

    self.nameLabel_:setString(string.format("%s_%s_%s  %s:%s    %s",year,month,day,hour,min,data.msg))
    -- self.nameLabel_:setString(string.format("%d_%d_%d  %s",year,month,day,data.msg))
end

function GroupMsgListItem:onAvatarLoadComplete_(success, sprite)
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

function GroupMsgListItem:onCleanup()
    nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
    if self.loadImageHandle_ then
        scheduler.unscheduleGlobal(self.loadImageHandle_)
        self.loadImageHandle_ = nil
    end
end

return GroupMsgListItem