--
-- Author: johnny@boomegg.com
-- Date: 2014-08-24 17:16:54
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local RankingListItem = class("RankingListItem", bm.ui.ListItem)
local RankingPopupController = import(".RankingPopupController")

local HEAD_W, HEAD_H = 54, 54 --头像宽高
local BG_W, BG_H = 520, 66

local MONEY_COLOR = cc.c3b(0x7e, 0xe1, 0x00)
local NICK_COLOR = cc.c3b(0xff, 0xff, 0xff)

function RankingListItem:ctor()
    self:setNodeEventEnabled(true)
    RankingListItem.super.ctor(self, 525, 73)
    self.schedulerPool_ = bm.SchedulerPool.new()
end

function RankingListItem:createContent_()
    local posY = self.height_ * 0.5
    self.frame_ = display.newScale9Sprite("#ranking_item_frame.png", self.width_/2, posY, cc.size(BG_W, BG_H)):addTo(self)

    --头像剪裁容器
    local headImgContainer = cc.ClippingNode:create()
    local stencil = display.newScale9Sprite("#common_button_pressed_cover.png", 0, 0, cc.size(HEAD_W, HEAD_H))
    headImgContainer:setStencil(stencil)
    headImgContainer:setAlphaThreshold(0.05)
    headImgContainer:pos(98, posY)
    headImgContainer:addTo(self)

    -- 头像
    self.avatar_ = display.newSprite()
        :scale(HEAD_W / 100)
        :addTo(headImgContainer)
    self.genderIcon_ = display.newSprite()
        :pos(125, posY - 20)
        :addTo(self)
    self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id

    -- 名次图标
    local rank_x, rank_y = 35, self.height_ * 0.5
    self.rank_ = display.newSprite("#ranking_rank_frame.png")
        :pos(rank_x, rank_y)
        :addTo(self)

    -- 名次标签
    self.ranking_ = ui.newTTFLabel({text = "", size = 14, color = cc.c3b(0x39, 0x24, 0x64), align = ui.TEXT_ALIGN_CENTER})
        :pos(rank_x, rank_y)
        :addTo(self)

    -- 追踪按钮
    self.trackBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_green_normal.png", pressed = "#common_btn_green_pressed.png", disabled = "#common_btn_disabled.png"}, {scale9 = true})
        :setButtonSize(160, 55)
        :setButtonLabel("normal", ui.newTTFLabel({text = bm.LangUtil.getText("RANKING", "TRACE_PLAYER"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 24, align = ui.TEXT_ALIGN_CENTER}))
        :setButtonLabel("disabled", ui.newTTFLabel({text = bm.LangUtil.getText("RANKING", "TRACE_PLAYER"), color = styles.FONT_COLOR.DARK_TEXT, size = 24, align = ui.TEXT_ALIGN_CENTER}))
        :pos(self.width_ * 0.85 - 15, posY)
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.onTraceClick_))
    self.trackBtn_:setTouchSwallowEnabled(false)

    -- 昵称标签
    local nick_x = 137
    self.nick_ =  ui.newTTFLabel({text = "", color = NICK_COLOR, size = 24, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER, nick_x, posY + 15)
        :addTo(self)

    -- 数值
    self.rankData_ =  ui.newTTFLabel({text = "", color = MONEY_COLOR, size = 24, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER, nick_x, posY - 15)
        :addTo(self)
end

function RankingListItem:lazyCreateContent()
    if not self.created_ then
        self.created_ = true
        self:createContent_()
    end
    if self.dataChanged_ then
        self.dataChanged_ = false
        self:setData_(self.data_)
    else
        self:updateRankItemText_()
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

function RankingListItem:onItemDeactived()
    if self.created_ then
        nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
        if self.avatarLoaded_ then
            self.avatarLoaded_ = false
            self.avatar_:setSpriteFrame(display.newSpriteFrame("common_male_avatar.png"))
            self.avatar_:scale(HEAD_W / 100)
            self.avatarDeactived_ = true
            cc.Director:getInstance():getTextureCache():removeUnusedTextures()
        end
    end
end

--[[
    data = {
        nick = "Aloha", 
        img = "img.png", 
        money = 1889, 
        level = 12, 
        ip = "192.168.0.1",
        port = "9001", 
        tid = "10012"}
]]
function RankingListItem:onDataSet(dataChanged, data)
    self.dataChanged_ = self.dataChanged_ or dataChanged   
    self.data_ = data
end

function RankingListItem:updateRankItemText_()
    -- 排名数据
    if RankingPopupController.currentRankingType == 1 then
        self.rankData_:setString(bm.LangUtil.getText("COMMON", "ASSETS", bm.formatNumberWithSplit(self.data_.val or 0)))
    elseif RankingPopupController.currentRankingType == 3 then
        self.rankData_:setString(bm.LangUtil.getText("COMMON", "ASSETS", bm.formatNumberWithSplit(self.data_.money or 0)))
    elseif RankingPopupController.currentRankingType == 4 then
        self.rankData_:setString(bm.formatNumberWithSplit(self.data_.val or 0))
    end
end

function RankingListItem:setData_(data)
    --排行榜中是自己的标记，需要切换后，该标记处理多余情况
    if data.uid == nk.userData.uid then  
       self.frame_:setSpriteFrame(display.newSpriteFrame("ranking_item_own_frame.png"))
    else
       self.frame_:setSpriteFrame(display.newSpriteFrame("ranking_item_frame.png"))
    end
    self.frame_:setContentSize(cc.size(BG_W, BG_H))
    
    -- 设置名次
    self.ranking_:setString("NO." .. self.index_)
    if self.index_ <= 3 then
        if self.index_ == 1 then
            self.topRankIcon_ = display.newSprite("#ranking_gold_icon.png")
            self.rank_:hide()
            self.ranking_:hide()
        elseif self.index_ == 2 then
            self.topRankIcon_ = display.newSprite("#ranking_sliver_icon.png")
            self.rank_:hide()
            self.ranking_:hide()
        elseif self.index_ == 3 then
            self.topRankIcon_ = display.newSprite("#ranking_copper_icon.png")
            self.rank_:hide()
            self.ranking_:hide()
        end
        self.topRankIcon_:pos(35, self.height_ * 0.5):addTo(self)
    else
        if self.topRankIcon_ then
            self.topRankIcon_:removeFromParent()
        end
        self.rank_:show()
        self.ranking_:show()
    end
    
    -- 设置头像
    if data.sex == "f" then
        self.genderIcon_:setSpriteFrame(display.newSpriteFrame("ranking_sex_female.png"))
        self.avatar_:setSpriteFrame(display.newSpriteFrame("common_female_avatar.png"))
    else
        self.genderIcon_:setSpriteFrame(display.newSpriteFrame("ranking_sex_male.png"))
        self.avatar_:setSpriteFrame(display.newSpriteFrame("common_male_avatar.png"))
    end
    self.avatar_:scale(HEAD_W / 100)
    if data.img and string.len(data.img) > 5 then
        nk.ImageLoader:loadAndCacheImage(
        self.userAvatarLoaderId_, 
        data.img, 
        handler(self, self.onAvatarLoadComplete_), 
        nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
        )
    end 

    -- 设置昵称
    self.nick_:setString(nk.Native:getFixedWidthText("", 24, data.nick, 200))
    
    self:updateRankItemText_()

    -- 设置追踪按钮
    if data.ip and data.port and data.tid then
        self.trackBtn_:setButtonEnabled(true)
    else
        self.trackBtn_:setButtonEnabled(false)
    end
end

function RankingListItem:onAvatarLoadComplete_(success, sprite)
    if success then
        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()
        self.avatar_:setTexture(tex)
        self.avatar_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
        self.avatar_:setScaleX(HEAD_W / texSize.width)
        self.avatar_:setScaleY(HEAD_H / texSize.height)
        self.avatarLoaded_ = true
    end
end

function RankingListItem:onTraceClick_()
    bm.EventCenter:dispatchEvent({name = nk.eventNames.ENTER_ROOM_WITH_DATA, data = self.data_})
    nk.PopupManager:removeAllPopup()
end

function RankingListItem:onCleanup()
    nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
    self.schedulerPool_:clearAll()
end

return RankingListItem