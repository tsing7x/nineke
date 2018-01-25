--
-- Author: XT
-- Date: 2015-08-21 20:10:38
--
local UserInfoMatchGiftItem = class("UserInfoMatchGiftItem", bm.ui.ListItem);
UserInfoMatchGiftItem.WIDTH = 228;
UserInfoMatchGiftItem.HEIGHT = 202;
UserInfoMatchGiftItem.ROW_GAP = 5;
UserInfoMatchGiftItem.COL_GAP = 18;

function UserInfoMatchGiftItem:ctor()
    self:setNodeEventEnabled(true)

	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods();
	UserInfoMatchGiftItem.super.ctor(self, UserInfoMatchGiftItem.WIDTH + UserInfoMatchGiftItem.COL_GAP, UserInfoMatchGiftItem.HEIGHT + UserInfoMatchGiftItem.ROW_GAP);
    self.imgLoaderId_ =  nk.ImageLoader:nextLoaderId() -- 头像加载id

	local px, py = UserInfoMatchGiftItem.WIDTH*0.5, UserInfoMatchGiftItem.HEIGHT*0.5;
	-- 背景
	self.bg_ = display.newScale9Sprite("#user-info-prop-background-icon.png")
        :pos(px, py)
        :addTo(self);
    
    -- 道具标签
    self.propLabel_ = ui.newTTFLabel({text = bm.LangUtil.getText("BANK", "BANK_DROP_LABEL") , color = cc.c3b(0x27, 0x90, 0xd5), size = 26, align = ui.TEXT_ALIGN_CENTER})
        :pos(UserInfoMatchGiftItem.WIDTH * 0.5, 65)
        :addTo(self)

    -- 道具使用
    self.propUseButton_ = display.newScale9Sprite("#user-info-prop-blue-up.png", UserInfoMatchGiftItem.WIDTH * 0.5, 19, cc.size(UserInfoMatchGiftItem.WIDTH, 40)):addTo(self);
    self.btnGroup_ = cc.ui.UICheckBoxButton.new({off="#common_transparent_skin.png", on="#common_transparent_skin.png"}, {scale9 = true})
            :setButtonLabel(ui.newTTFLabel({text="", size=24, color=cc.c3b(0xb2, 0xdc, 0xff), align=ui.TEXT_ALIGN_CENTER}))
            :setButtonLabelOffset(0, -36)
            :setButtonSize(228, 202)
            :setButtonLabelAlignment(display.CENTER)
            :pos(px, py)
            -- :onButtonStateChanged(handler(self, self.buyPropHandler_))
            :addTo(self);
    self.btnGroup_:setTouchSwallowEnabled(false);
    self.btnGroup_:onButtonPressed(function(evt)
        self.btnPressedX_ = evt.x;
        self.btnClickCanceled_ = false;
    end)
    -- 
    self.btnGroup_:onButtonRelease(function(evt)
        if math.abs(evt.x - self.btnPressedX_) > 10 then
            self.btnClickCanceled_ = true;
        end
    end)
    -- 
    self.btnGroup_:onButtonClicked(function(evt)
        if not self.btnClickCanceled_ and self:getParent():getParent():getCascadeBoundingBox():containsPoint(cc.p(evt.x, evt.y)) then
            nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON);
            self:buyPropHandler_(evt);
        end
    end)

    -- 
    self.useStatus_ = display.newScale9Sprite("#gift-shop-select-icon.png", 0, 0, cc.size(228, 202)):pos(px, py):addTo(self):hide();
    -- 道具图标
    self.giftIcon_ = display.newSprite("#popup_tab_bar_bg.png"):pos(px, py + 30):addTo(self);
    -- 道具類型
    self.propType_ = ui.newTTFLabel({text = "X0" , color = styles.FONT_COLOR.GOLDEN_TEXT, size = 26, align = ui.TEXT_ALIGN_CENTER})
        :pos(UserInfoMatchGiftItem.WIDTH * 0.5, 25)
        :addTo(self);


    -- setSpriteFrame newSprite()
    -- setSpriteFrame
    -- self.propIcon_:setSpriteFrame(display.newSpriteFrame("user-info-prop-icon.png"))
end

function UserInfoMatchGiftItem:onDataSet(dataChanged, data)
	self.data_ = data;
	self:render();
	self:loadImageTexture(data);
end

function UserInfoMatchGiftItem:render()
	if not self.data_ then 
		return;
	end

	if tonumber(self.data_.expire)  > 1 then
        if self.data_.giftType == 10 then
            self.propLabel_:setString("("..self.data_.expire ..bm.LangUtil.getText("GIFT","DATA_LABEL")..")");
        else
            self.propLabel_:setString((self.data_.money or "").."("..self.data_.expire ..bm.LangUtil.getText("GIFT","DATA_LABEL")..")");
        end
    else
        if self.data_.giftType == 1 then
            self.propLabel_:setString("("..1 ..bm.LangUtil.getText("GIFT","DATA_LABEL")..")")
        else
            self.propLabel_:setString(self.data_.money.."("..self.data_.expire ..bm.LangUtil.getText("GIFT","DATA_LABEL")..")");
        end
    end

    if self.data_.giftType == 1 then
    	self.propType_:setString(bm.LangUtil.getText("GIFT","SUB_TAB_TEXT_MY_GIFT")[1]);
    elseif self.data_.giftType == 2 then
    	self.propType_:setString(bm.LangUtil.getText("GIFT","SUB_TAB_TEXT_MY_GIFT")[2]);
    elseif self.data_.giftType == 10 then
    	self.propType_:setString(bm.LangUtil.getText("GIFT","SUB_TAB_TEXT_MY_GIFT")[3]);
    end

    --判断是否为当前道具
    if nk.userData.user_gift == self.data_.id then
        self.useStatus_:show();
    else 
        self.useStatus_:hide();
    end
end

function UserInfoMatchGiftItem:loadImageTexture(data)
    if data.id then
        if data.image and string.len(data.image) > 0 then
        nk.ImageLoader:loadAndCacheImage(
            self.imgLoaderId_, 
            data.image, 
             handler(self, self.onAvatarLoadComplete_), 
              nk.ImageLoader.CACHE_TYPE_GIFT
            )
        end
    end
end

function UserInfoMatchGiftItem:onAvatarLoadComplete_(success, sprite)
    if success then
        self.giftIcon_:show()
         local tex = sprite:getTexture()
         local texSize = tex:getContentSize()
         self.giftIcon_:setTexture(tex)
         self.giftIcon_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
         -- fixme:当图片宽度比高度大相差很大时，需要更好的算法
         if texSize.width > texSize.height then
             self.giftIcon_:setScaleX(120 / texSize.width)
             self.giftIcon_:setScaleY(120 / texSize.width)
         else
            self.giftIcon_:setScaleX(90 / texSize.height)
            self.giftIcon_:setScaleY(90 / texSize.height)
         end
    end
end

function UserInfoMatchGiftItem:buyPropHandler_(evet)
    local selectGiftId = self.data_.id
    print("selectGiftId::"..selectGiftId);
	self:dispatchEvent({name="ITEM_EVENT", type="BUY_GIFT", data=selectGiftId})
end

return UserInfoMatchGiftItem;