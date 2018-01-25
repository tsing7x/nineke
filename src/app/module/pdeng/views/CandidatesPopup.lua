

local CandidatesPopup = class("CandidatesPopup", nk.ui.Panel)

local POPUP_WIDTH = 520
local POPUP_HEIGHT = 420
local ITEM_WIDTH = POPUP_WIDTH - 80
local ITEM_HEIGHT = 64
local AVATAR_SIZE = 50

function CandidatesPopup:ctor(data)
    CandidatesPopup.super.ctor(self, {POPUP_WIDTH, POPUP_HEIGHT})
    self:setNodeEventEnabled(true)

    self.data = data
    self:setupView()
end

function CandidatesPopup:setupView()
    self:addCloseBtn()
    self:addTitle(bm.LangUtil.getText("PDENG", "DEALER_CANDIDATE_TITLE"))

    for i=1, #self.data do
        self:createItem_(self.data[i]):pos(-self.width_ * 0.5, self.height_ * 0.5 - (i + 1) * ITEM_HEIGHT)
    end
end

function CandidatesPopup:createItem_(data)
    local item_node = display.newNode():addTo(self)
    display.newScale9Sprite("#pop_friend_content_bg.png", 0, 0, cc.size(ITEM_WIDTH, ITEM_HEIGHT - 4))
        :pos(ITEM_WIDTH * 0.5 + 40, 0)
        :addTo(item_node)

    --自己标记
    if data.uid == nk.userData.uid then
        display.newSprite("#friend_state_online.png")
            :pos(80, 0)
            :addTo(item_node)
    end

    -- 头像
    local avatar_x = 160
    self.avatar_ = display.newSprite("#common_male_avatar.png")
        :scale(AVATAR_SIZE / 100)
        :pos(avatar_x - 24, 0)
        :addTo(item_node)

    self.genderIcon_ = display.newSprite("#pop_common_male.png")
        :pos(avatar_x + 20, 14)
        :addTo(item_node)

    if data.userInfo.gender == "f" then
        self.genderIcon_:setSpriteFrame(display.newSpriteFrame("pop_common_female.png"))
        self.avatar_:setSpriteFrame(display.newSpriteFrame("common_female_avatar.png"))
    end
 
    self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id

    if string.len(data.userInfo.img) > 5 then
        self.loadImageHandle_ = nil
        nk.ImageLoader:loadAndCacheImage(
            self.userAvatarLoaderId_, 
            data.userInfo.img, 
            handler(self, self.onAvatarLoadComplete_), 
            nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
        )
    end

    -- 昵称标签
    self.nick_ =  ui.newTTFLabel({text = data.userInfo.nick, color = cc.c3b(0xC7, 0xE5, 0xFF), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER, 205, 14)
        :addTo(item_node)

    -- 资产
    self.money_ =  ui.newTTFLabel({text = data.money, color = cc.c3b(0x3E, 0xA2, 0xEE), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER, 176, -16)
        :addTo(item_node)

    return item_node
end

function CandidatesPopup:onAvatarLoadComplete_(success, sprite)
    if success then
        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()
        self.avatar_:setTexture(tex)
        self.avatar_:setTextureRect(CCRect(0, 0, texSize.width, texSize.height))
        self.avatar_:setScaleX(AVATAR_SIZE / texSize.width)
        self.avatar_:setScaleY(AVATAR_SIZE / texSize.height)
        self.avatarLoaded_ = true
    end
end

function CandidatesPopup:onCleanup()
    nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
    if self.loadImageHandle_ then
        scheduler.unscheduleGlobal(self.loadImageHandle_)
        self.loadImageHandle_ = nil
    end
end

function CandidatesPopup:show()
    self:showPanel_()
end

function CandidatesPopup:hide()
    self:hidePanel_()
end


return CandidatesPopup