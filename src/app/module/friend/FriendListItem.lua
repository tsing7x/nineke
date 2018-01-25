--
-- Author: johnny@boomegg.com
-- Date: 2014-08-31 20:40:41
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
-- 好友列表元素
local DeleteFriendPopUp = import(".DeleteFriendPopUp")
local FriendListItem = class("FriendListItem", bm.ui.ListItem)
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

local AVATAR_SIZE = 50

function FriendListItem:ctor()
    self:setNodeEventEnabled(true)
    FriendListItem.super.ctor(self, 720, 76)
end

function FriendListItem:createContent_()
    local posY = self.height_ * 0.5

    display.newScale9Sprite("#pop_friend_content_bg.png", 0, 0, cc.size(self.width_, self.height_ - 12))
        :pos(self.width_ * 0.5, posY)
        :addTo(self)

    --在线标记
    self.onLineIcon_ = display.newSprite("#friend_state_online.png")
        :pos(15, posY)
        :addTo(self)

    -- 头像
    local avatar_x = 80
    self.avatar_ = display.newSprite("#common_male_avatar.png")
        :scale(AVATAR_SIZE / 100)
        :pos(avatar_x - 24, posY)
        :addTo(self)
    self.avatarBg_ = display.newSprite("#ranking_avatar_bg.png")
        :pos(avatar_x, posY)
        :addTo(self)
        :hide()
    self.genderIcon_ = display.newSprite("#pop_common_male.png")
        :pos(avatar_x + 20, posY + 14)
        :addTo(self)
 
    self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id

    -- 触摸头像 弹出删除好友弹窗
    self.deleteFriendButton = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#common_transparent_skin.png"}, {scale9 = true})
        :setButtonSize(100, 82)
        :onButtonClicked(handler(self, self.deleteFriendHandler))
        :pos(avatar_x, posY)
        :addTo(self)

    -- 昵称标签
    self.nick_ =  ui.newTTFLabel({text = "", color = cc.c3b(0xC7, 0xE5, 0xFF), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER, 125, posY + 14)
        :addTo(self)

    -- 资产
    self.money_ =  ui.newTTFLabel({text = "", color = cc.c3b(0x3E, 0xA2, 0xEE), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER, 96, posY - 16)
        :addTo(self)

    local button_width = 160
    local button_height = 55

    -- 赠送按钮
    self.sendBtnNormalLabel_ = ui.newTTFLabel({text = bm.LangUtil.getText("FRIEND", "SEND_CHIP"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})
    self.sendBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_blue_normal.png", pressed = "#common_btn_blue_pressed.png", disabled = "#common_btn_disabled.png"}, {scale9 = true})
        :setButtonSize(button_width, button_height)
        :setButtonLabel("normal", self.sendBtnNormalLabel_)
        :pos(470, posY)
        :onButtonClicked(buttontHandler(self, self.onSendClick_))
        :addTo(self)
    self.sendBtn_:setTouchSwallowEnabled(false)

    -- 追踪按钮
    self.trackBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_green_normal.png", pressed = "#common_btn_green_pressed.png", disabled = "#common_btn_disabled.png"}, {scale9 = true})
        :setButtonSize(button_width, button_height)
        :setButtonLabel("normal", ui.newTTFLabel({text = bm.LangUtil.getText("RANKING", "TRACE_PLAYER"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER}))
        :pos(632, posY)
        :onButtonClicked(buttontHandler(self, self.onTraceClick_))
        :addTo(self)
    self.trackBtn_:setTouchSwallowEnabled(false)

    --召回按钮
    self.recallBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_yellow_normal.png", pressed = "#common_btn_yellow_pressed.png", disabled = "#common_btn_disabled.png"}, {scale9 = true})
        :setButtonSize(button_width, button_height)
        :setButtonLabel("normal", ui.newTTFLabel({text = bm.LangUtil.getText("FRIEND", "RECALL_CHIP", nk.userData.recallBackChips), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER}))
        :pos(632, posY)
        :onButtonClicked(buttontHandler(self, self.onRecallClick_))
        :addTo(self)
        :hide()
    self.recallBtn_:setTouchSwallowEnabled(false)

    -- 恢复按钮
    self.restoreBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_blue_normal.png", pressed = "#common_btn_blue_pressed.png", disabled = "#common_btn_disabled.png"}, {scale9 = true})
        :setButtonSize(button_width, button_height)
        :setButtonLabel("normal", ui.newTTFLabel({text = bm.LangUtil.getText("FRIEND", "RESTORE_BTN"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER}))        
        :pos(632, posY)
        :onButtonClicked(buttontHandler(self, self.onRestoreClick_))
        :addTo(self)
        :hide()       
    self.restoreBtn_:setTouchSwallowEnabled(false)
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
            self.avatar_:scale(AVATAR_SIZE / 100)
            self.avatarDeactived_ = true
            cc.Director:getInstance():getTextureCache():removeUnusedTextures()
        end
    end
end

function FriendListItem:onDataSet(dataChanged, data)
    self.dataChanged_ = true--self.dataChanged_ or dataChanged
    self.data_ = data
end

function FriendListItem:setData_(data)
    -- 设置头像
    if data.sex == "f" then
        self.genderIcon_:setSpriteFrame(display.newSpriteFrame("pop_common_female.png"))
        self.avatar_:setSpriteFrame(display.newSpriteFrame("common_female_avatar.png"))
    else
        self.genderIcon_:setSpriteFrame(display.newSpriteFrame("pop_common_male.png"))
        self.avatar_:setSpriteFrame(display.newSpriteFrame("common_male_avatar.png"))
    end
    self.avatar_:scale(AVATAR_SIZE / 100)

    -- 设置昵称
    self.nick_:setString(bm.limitNickLength(data.nick, 20))

    -- 资产设置
    self.money_:setString(bm.LangUtil.getText("COMMON", "ASSETS", bm.formatNumberWithSplit(data.money)))

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

    if not isDelListItem then
        -- 设置赠送按钮
        if nk.userData.isSendChips and nk.userData.isSendChips == 0 then
            self.sendBtn_:hide()
        else
            self.sendBtn_:show()
            if data.send > 0 then
                self.sendBtn_:setButtonEnabled(true)
                self.sendBtnNormalLabel_:setString(bm.LangUtil.getText("FRIEND", "SEND_CHIP_WITH_NUM", bm.formatBigNumber(data.sdchip)))
            else
                self.sendBtn_:setButtonEnabled(false)
            end
        end

        -- 设置追踪按钮
        if data.ip and data.port and data.tid then
            self.trackBtn_:setButtonEnabled(true)
        else
            self.trackBtn_:setButtonEnabled(false)
        end

        if data.isRecall == 1 then --0不需要召回 1需要召回
            self.recallBtn_:show()
            self.trackBtn_:hide()

            if data.isCanRecall == 0 then --每天只能点击一次召回  0不可点击 1可以点击
                self.recallBtn_:setButtonEnabled(false)
            else
                self.recallBtn_:setButtonEnabled(true)
            end
        else
            self.recallBtn_:hide()
            self.trackBtn_:show()
        end

        if data.isOnline == 0 then --0不在线 1在线
            self.onLineIcon_:setSpriteFrame(display.newSpriteFrame("friend_state_offline.png"))
        else
            self.onLineIcon_:setSpriteFrame(display.newSpriteFrame("friend_state_online.png"))
        end
    else
        self.sendBtn_:hide()
        self.trackBtn_:hide()
        self.recallBtn_:hide()
        self.restoreBtn_:show()
        self.deleteFriendButton:hide()
        self.onLineIcon_:hide()
    end
end

function FriendListItem:onAvatarLoadComplete_(success, sprite)
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

function FriendListItem:onSendClick_()
    self.owner_.controller_:sendChip(self)
end

function FriendListItem:onSendChipSucc()
    nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "SEND_CHIP_SUCCESS", bm.formatNumberWithSplit(self.data_.sdchip)))
    nk.pushMsg(self.data_.uid," ", bm.LangUtil.getText("PUSHMSG","SENDCHIP_PUSH",nk.userData.nick), true, 1)
    self.data_.send = self.data_.send - 1
    if self.data_.send <= 0 then
        self.sendBtn_:setButtonEnabled(false)
    end
end

function FriendListItem:onTraceClick_()
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    bm.EventCenter:dispatchEvent({name = nk.eventNames.ENTER_ROOM_WITH_DATA, data = self.data_, isTrace = true})
    nk.PopupManager:removeAllPopup()
end

function FriendListItem:onRecallClick_()
    local lastLoginType = nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE)
    local data = {}
    table.insert(data, self.data_)
    if lastLoginType ==  "FACEBOOK" then
        if self.data_.isFb == 1 then --只能是FB -> FB之间才发FB消息 其他情况发推送
            self.owner_.controller_:recallFriend(data)
        else
            self.owner_.controller_:sendPushNews(self.data_.uid)
        end
    elseif lastLoginType == "GUEST" then
        self.owner_.controller_:sendPushNews(self.data_.uid)
    end

    self.recallBtn_:setButtonEnabled(false) --每次打开界面，获取数据设置是否可以召回，只能点击一次，方便提醒玩家知道哪些已经召回
end

function FriendListItem:onRestoreClick_()   
    self.owner_.controller_:restoreFriend(self)
end

function FriendListItem:onCleanup()
    nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
    if self.loadImageHandle_ then
        scheduler.unscheduleGlobal(self.loadImageHandle_)
        self.loadImageHandle_ = nil
    end
end

function FriendListItem:deleteFriendHandler()
    local deletefriend = DeleteFriendPopUp.new()
    deletefriend:show(self.data_,self, self.owner_.controller_)
end

return FriendListItem