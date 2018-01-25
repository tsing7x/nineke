--
-- Author: HLF(IdaHuang@boyaa.com)
-- Date: 2016-04-11 15:48:01
-- 幸运转盘记录
local AvatarIcon = import("boomegg.ui.AvatarIcon")
local LuckWheelRecordItem = class("LuckWheelRecordItem", bm.ui.ListItem)

LuckWheelRecordItem.WIDTH = 376
LuckWheelRecordItem.HEIGHT = 60
LuckWheelRecordItem.ROW_GAP = 4
LuckWheelRecordItem.COL_GAP = 6

local CARD_NUM_TAG = 12
local ICON_DH = 26
local AVATART_DW, AVATAR_DH = 50, 50;
local DESC_DW = 215

function LuckWheelRecordItem:ctor()
    self.giftLoaderId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods();
	local width, height = LuckWheelRecordItem.WIDTH, LuckWheelRecordItem.HEIGHT;
	LuckWheelRecordItem.super.ctor(self, width + LuckWheelRecordItem.COL_GAP, height + LuckWheelRecordItem.ROW_GAP);
    self:setNodeEventEnabled(true)
    -- 
    local offX = 3
    local sz
    local px, py = width*0.5 + offX, height*0.5
    display.newScale9Sprite("#rounded_rect_10.png", px, py, cc.size(width, height - 0))
        :addTo(self)
    -- 
    px = AVATART_DW * 0.5 + 10 + offX
    self.avatar_ = AvatarIcon.new("#common_male_avatar.png", AVATART_DW, AVATAR_DH, 6, nil, 1, 8, 0)
        :pos(px, py)
        :addTo(self)
    -- 
    local ICON_PX = 86
    py = height*0.5 + 14
    px = ICON_PX
    self.genderIcon_ = display.newSprite("#pop_common_male.png")
        :pos(px, py)
        :addTo(self)
    -- 
    sz = self.genderIcon_:getContentSize()
    px = px + sz.width*0.5 + 10
    self.namelbl_ = ui.newTTFLabel({
    		text="",
    		size=20,
    		color=styles.FONT_COLOR.LIGHT_TEXT,
            align=ui.TEXT_ALIGN_CENTER,
    	})
    	:pos(px, py)
    	:addTo(self)
    self.namelbl_:setAnchorPoint(cc.p(0, 0.5))
    local nameLblPX = px
    --
    py = height*0.5 - 15
    px = ICON_PX
    local url = "#wheel_reward_7.png"
    self.giftIcon_ = display.newSprite(url)
        :pos(px, py)
        :addTo(self)
    sz = self.giftIcon_:getContentSize()
    local scaleVal = ICON_DH/sz.height
    self.giftIcon_:setScale(scaleVal)
    -- 
    px = px + 50
    self.giftDesc_ = ui.newTTFLabel({
            text="",
            color=styles.FONT_COLOR.GOLDEN_TEXT,
            size=20,
            align=ui.TEXT_ALIGN_CENTER,
        })
        :pos(nameLblPX, py-2)
        :addTo(self)
    self.giftDesc_:setAnchorPoint(cc.p(0, 0.5))
    self.giftDescX_ = self.giftDesc_:getPositionX()
    self.giftDescY_ = self.giftDesc_:getPositionY()
    -- 
    self.timeLbl_ = ui.newTTFLabel({
            text="",
            color=styles.FONT_COLOR.GREY_TEXT,
            size=18,
            align=ui.TEXT_ALIGN_CENTER,
        })
        :pos(width*1.0 - 90, py-2)
        :addTo(self)
    self.timeLbl_:setAnchorPoint(cc.p(0, 0.5))
    -- 
    bm.TouchHelper.new(self.avatar_, handler(self, self.onAvatorHandler_))

    self.infoBtn_ = cc.ui.UIPushButton.new({normal = "#common_dark_blue_btn_up.png", pressed = "#common_dark_blue_btn_down.png"},{scale9 = true})
        :setButtonLabel(ui.newTTFLabel({
             text = bm.LangUtil.getText("SCOREMARKET", "SEE"),
             size = 18,
             color = cc.c3b(255, 255, 255),
             align = ui.TEXT_ALIGN_CENTER
        }))
        :setButtonSize(95, 38)
        :addTo(self)
        :pos(317,40)
        :onButtonPressed(function(evt) 
                    self.btnPressedY_ = evt.y
                    self.btnClickCanceled_ = false
                end)
        :onButtonRelease(function(evt)
                    if math.abs(evt.y - self.btnPressedY_) > 8 then
                        self.btnClickCanceled_ = true
                    end
                end)
        :onButtonClicked(buttontHandler(self, function(obj)
            if not self.btnClickCanceled_ then
                if self.data_.reward_type=="real" then
                    self:dispatchEvent({name="ITEM_EVENT", type="ScoreMarketViewExt_Real", data=self.data_})
                elseif self.data_.reward_type=="score" then
                    self:dispatchEvent({name="ITEM_EVENT", type="ScoreMarketViewExt_Score", data=self.data_})
                end
            end
        end))
    self.infoBtn_:setTouchSwallowEnabled(false)
    self.infoBtn_:hide()
end
-- 
function LuckWheelRecordItem:onAvatorHandler_(obj, evtName)
    if evtName == bm.TouchHelper.CLICK then
        self:dispatchEvent({name="ITEM_EVENT", type="ShowOtherUserDetail", data=self.data_})
    end
end
-- 
function LuckWheelRecordItem:onDataSet(dataChanged, data)
	self.data_ = data
	self:render_()
end

function LuckWheelRecordItem:render_()
    self.infoBtn_:hide()
    if self.data_.isSelf then
        self.avatar_:hide()
        self.genderIcon_:hide()
        self.namelbl_:hide()

        self.timeLbl_:setPositionX(8)
        self.giftDesc_:setPositionX(8)
        self.giftDesc_:setPositionY(40)
        self.infoBtn_:setPosition(317,28)

        self.giftDesc_:setString(nk.Native:getFixedWidthText("",20,"+"..self.data_.reward,DESC_DW+50))
        self.timeLbl_:setString(bm.TimeUtil:getTimeSimpleString(self.data_.time, "/"))
        bm.fitSprteWidth(self.timeLbl_, 90)
    else
        self.avatar_:show()
        self.genderIcon_:show()
        self.namelbl_:show()
        self.timeLbl_:setPositionX(LuckWheelRecordItem.WIDTH- 90)
        self.giftDesc_:setPositionX(self.giftDescX_)
        self.giftDesc_:setPositionY(self.giftDescY_)

        self.infoBtn_:setPosition(317,40)


        -- if self.data_.uid == nk.userData.uid then
        --     self.avatar_:renderVIP()
        -- else
        --     -- 其他人的Vip
        --     local vipconfig =  self.data_.vipinfo or {}
        --     local isVip = self:checkIsVip_(vipconfig)
        --     if isVip then     
        --         self.avatar_:renderOtherVIP(tonumber(vipconfig.vip.level))
        --     end
        -- end
        self.namelbl_:setString(nk.Native:getFixedWidthText("", 24, self.data_.nick or "", 200))
        self.giftDesc_:setString(nk.Native:getFixedWidthText("",20,"+"..self.data_.reward,DESC_DW-50))
        self.timeLbl_:setString(bm.TimeUtil:getTimeSimpleString(self.data_.time, "/"))
        bm.fitSprteWidth(self.timeLbl_, 90)
        -- 性别
        if self.data_.sex ~= "m" then
            self.genderIcon_:setSpriteFrame(display.newSpriteFrame("pop_common_female.png"))
        else
            self.genderIcon_:setSpriteFrame(display.newSpriteFrame("pop_common_male.png"))
        end
        -- 头像
        local imgurl = self.data_.img
        if not imgurl or string.len(imgurl) <= 5 then
            if self.data_.sex == "f" then
                self.avatar_:setSpriteFrame("common_female_avatar.png")
            else
                self.avatar_:setSpriteFrame("common_male_avatar.png")
            end
        else
            if string.find(imgurl, "facebook") then
                if string.find(imgurl, "?") then
                    imgurl = imgurl .. "&width=200&height=200"
                else
                    imgurl = imgurl .. "?width=200&height=200"
                end
            end
            self.avatar_:loadImage(imgurl)
        end
        if self.numlbl_ then
            self.numlbl_:removeFromParent()
            self.numlbl_ = nil
        end
    end
    -- 小图标
    if self.data_.isSelf then
        self.giftIcon_:hide()
        if self.data_.reward_type=="real" or self.data_.reward_type=="score" then
            self.infoBtn_:show()
        end
    else
        -- 实物~~~
        if self.data_.uid == nk.userData.uid and (self.data_.type == "real" or self.data_.type == "score") then
            self.data_.reward_type = self.data_.type
            self.infoBtn_:show()
        end
        self.giftDesc_:setPositionX(self.giftDescX_)
        self.giftIcon_:show()
        if self.data_.giftImg then
            if self.data_.type == "fun_face" then
                -- 互动道具
                self.giftIcon_:setSpriteFrame(display.newSpriteFrame("prop_hddj_icon.png"))
            elseif self.data_.type == "score" then
                -- 积分现金卡
                self.giftIcon_:setSpriteFrame(display.newSpriteFrame("turn_reward_card.png"))
                self.numlbl_ = ui.newTTFLabel({
                    text = self.data_.num, 
                    color = cc.c3b(0xa0,0x0,0x0),
                    size = 32, align = ui.TEXT_ALIGN_CENTER})
                :pos(33, 33)
                :addTo(self.giftIcon_, CARD_NUM_TAG)
                local isz = self.giftIcon_:getContentSize()
                local iscale = ICON_DH/isz.height
                self.giftIcon_:setScale(iscale)
                -- 
                local len = string.len(tostring(self.data_.num))
                if len == 1 then
                    bm.fitSprteWidth(self.numlbl_, 12)
                elseif len == 2 then
                    bm.fitSprteWidth(self.numlbl_, 20)
                elseif len == 3 then
                    bm.fitSprteWidth(self.numlbl_, 30)
                else
                    bm.fitSprteWidth(self.numlbl_, 40)
                end
            elseif self.data_.type == "game_coupon" then
                -- 比赛券
                self.giftIcon_:setSpriteFrame(display.newSpriteFrame("icon_gamecoupon.png"))
                self.giftIcon_:setScale(1.0)
            elseif self.data_.type == "chips" then
                local res;
                if self.data_.num < 800 then
                    res = "wheel_reward_6.png";
                elseif self.data_.num < 1500 then
                    res = "wheel_reward_5.png";
                elseif self.data_.num < 4000 then
                    res = "wheel_reward_4.png";
                elseif self.data_.num < 70000 then
                    res = "wheel_reward_3.png";
                elseif self.data_.num < 500000 then
                    res = "wheel_reward_2.png";
                else
                    res = "wheel_reward_1.png";
                end
                -- 
                self.giftIcon_:setSpriteFrame(display.newSpriteFrame(res))
                self.giftIcon_:setScale(0.65)
            elseif self.data_.type == "ticket" or self.data_.type == "real" then
                nk.ImageLoader:cancelJobByLoaderId(self.giftLoaderId_)
                nk.ImageLoader:loadAndCacheImage(
                    self.giftLoaderId_,
                    self.data_.giftImg,
                    handler(self, self.onAvatarLoadComplete_),
                    nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
                )
            end
        end
    end
    -- 物品图标  免费转盘
    if self.data_.giftResId then
        nk.ImageLoader:cancelJobByLoaderId(self.giftLoaderId_)
        nk.ImageLoader:loadAndCacheImage(
            self.giftLoaderId_,
            self.data_.giftResId,
            handler(self, self.onAvatarLoadComplete_),
            nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
        )
    end
    -- 
end

--yk
function LuckWheelRecordItem:checkIsVip_(vipconfig)
    if vipconfig.newvip == 1 then
        return true
    end

    if vipconfig.isvip == 1 and vipconfig.vip and vipconfig.vip.light and vipconfig.vip.light == 1 then
        return true
    end

    return false
end

function LuckWheelRecordItem:onAvatarLoadComplete_(success, sprite)
    if success then
        local tex = sprite:getTexture();
        local texSize = tex:getContentSize();
        self.giftIcon_:setTexture(tex)
        self.giftIcon_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height));
        
        local DH = 32
        local xxScale = DH/texSize.width
        local yyScale = DH/texSize.height
        local scaleVal = xxScale<yyScale and xxScale or yyScale;
        self.giftIcon_:setScale(scaleVal);
    end
end
-- 
function LuckWheelRecordItem:onCleanup()
    if self.giftLoaderId_ then
        nk.ImageLoader:cancelJobByLoaderId(self.giftLoaderId_)
    end
end

return LuckWheelRecordItem