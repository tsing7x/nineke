--
-- Author: johnny@boomegg.com
-- Date: 2014-08-31 20:40:41
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
-- 房间列表元素
local GroupRoomListItem = class("GroupRoomListItem", bm.ui.ListItem)
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

GroupRoomListItem.WIDTH = 200
GroupRoomListItem.HEIGHT = 60

local AVATAR_SIZE = 50

function GroupRoomListItem:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:setNodeEventEnabled(true)
    GroupRoomListItem.super.ctor(self, GroupRoomListItem.WIDTH, GroupRoomListItem.HEIGHT)
end

function GroupRoomListItem:createContent_()
    self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id

    local sx = -GroupRoomListItem.WIDTH*0.5
    local con = display.newNode()
        :pos(GroupRoomListItem.WIDTH*0.5,GroupRoomListItem.HEIGHT*0.5)
        :addTo(self)

    self.headBg_ = display.newSprite("#group_head_bg.png")
        :pos(sx + 35, 0)
        :addTo(con)

    self.lockIcon_ =  display.newSprite("#group_room_lock.png")
        :pos(sx + 80, 0)
        :addTo(con)

    self.blindLabel_ = ui.newTTFLabel({
            text = "",
            color=cc.c3b(0xdc,0xdc,0xff),
            size = 18,
        })
        :pos(sx + 110, 0)
        :addTo(con)

    self.blindIcon_ =  display.newSprite("#chip_icon.png")
        :pos(sx + 145, 0)
        :addTo(con)
    
    --进度
    local progress_width = 120
    self.progress_ = nk.ui.ProgressBar.new(
        "#pop_common_progress_bg.png", 
        "#pop_common_progress_img.png", 
        {
            bgWidth = progress_width, 
            bgHeight = 26, 
            fillWidth = 34, 
            fillHeight = 20
        }
    )
    :align(display.RIGHT_CENTER, -progress_width*0.5 + 30,0)
    :addTo(con)
    :setValue(0)

    self.onlineLabel_ = ui.newTTFLabel({
        text = "",
        size = 18,
    })
    :pos(30,0)
    :addTo(con)

    self.joinBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_green_normal.png", pressed = "#common_btn_green_pressed.png"},{scale9 = true})
        :setButtonSize(110, 52)
        :setButtonLabel(ui.newTTFLabel({text = bm.LangUtil.getText("GROUP","JOINROOM"),size = 28,color = cc.c3b(0xff, 0xff, 0xff)}))
        :align(display.RIGHT_CENTER, GroupRoomListItem.WIDTH*0.5 - 10, 0)
        :scale(0.7)
        :addTo(con)
        :onButtonClicked(buttontHandler(self, function()
            self.joinBtn_:setTouchEnabled(false)
            self:dispatchEvent({name="ITEM_EVENT", type="ITEM_CLICK", data=self})
            nk.schedulerPool:delayCall(function()
                if self.joinBtn_ then
                    self.joinBtn_:setTouchEnabled(true)
                end
            end, 1)
        end))
end

function GroupRoomListItem:lazyCreateContent()
    if not self.created_ then
        self.created_ = true
        self:createContent_()
    end

    if self.dataChanged_ then
        self.dataChanged_ = false
        self:setData_(self.data_)
    end
end

function GroupRoomListItem:onDataSet(dataChanged, data)
    self.dataChanged_ = true
    self.data_ = data
end

function GroupRoomListItem:setData_(data)
    -- data:
    -- id  :   私人房表id
    -- tid :   桌子id
    -- uid :   创建离间玩家id
    -- gid :   群id
    -- sb  :   盲注
    -- pc  :   人数
    -- player: 在玩人数
    -- psword: 是否有密码
    -- s_picture： 头像地址
    
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

    if tonumber(data.psword) == 1 then
        self.lockIcon_:show()
    else
        self.lockIcon_:hide()
    end

    self.blindLabel_:setString(bm.formatBigNumber(data.sb))

    if tonumber(data.flag) == 2 then --游戏币底注
        self.blindIcon_:setSpriteFrame("chip_icon.png")
        self.blindIcon_:scale(0.5)
    else --黄金币底注
        self.blindIcon_:setSpriteFrame("common_gcoin_icon.png")
        self.blindIcon_:scale(0.65)
    end

    if data.player == 0 then
        self.progress_.fill_:hide()
    else
        self.progress_:setValue(data.player/data.pc)
    end

    self.onlineLabel_:setString(data.player.."/"..data.pc)
end

function GroupRoomListItem:onAvatarLoadComplete_(success, sprite)
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

function GroupRoomListItem:onCleanup()
    nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
    if self.loadImageHandle_ then
        scheduler.unscheduleGlobal(self.loadImageHandle_)
        self.loadImageHandle_ = nil
    end
end

return GroupRoomListItem