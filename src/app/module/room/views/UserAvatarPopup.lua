--
-- Author: XT
-- Date: 2015-08-25 17:37:06
--
local UserAvatarPopup = class("UserAvatarPopup", nk.ui.Panel);
-- local logger = bm.Logger.new("UserAvatarPopup");

IMG_WIDTH = 420;
IMG_HEIGHT = 420;

function UserAvatarPopup:ctor()
	UserAvatarPopup.super.ctor(self, {display.width, display.height});
	self:setNodeEventEnabled(true);
	self.background_:setOpacity(0.5);

	self.avatarBg_ = display.newScale9Sprite("#user_info_avatar_bg.png", 0, 0, cc.size(IMG_WIDTH+8, IMG_HEIGHT+8)):addTo(self);
	self.avatar_ = display.newSprite("#common_male_avatar.png"):pos(0, 0):addTo(self);
	local sz = self.avatar_:getContentSize();
	self.scale_ = IMG_WIDTH/sz.width > IMG_HEIGHT/sz.height and IMG_WIDTH/sz.width or IMG_HEIGHT/sz.height
	self.avatar_:scale(IMG_WIDTH/sz.width, IMG_HEIGHT/sz.height);
	-- 

	self.avatarLoaderId_ = nk.ImageLoader:nextLoaderId();
	self.headImgContainer_ = cc.ClippingNode:create();
	self.stencil_ = display.newScale9Sprite("#rounded_rect_10.png", 0, 0, cc.size(IMG_WIDTH, IMG_HEIGHT))
	self.headImgContainer_:setStencil(self.stencil_)
	self.headImgContainer_:pos(self.avatar_:getPositionX(), self.avatar_:getPositionY())
	self.headImgContainer_:addTo(self)
    -- common_transparent_skin
    cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#common_transparent_skin.png"}, {scale9 = true})
    :setButtonSize(display.width, display.height)
    :pos(0, 0)
    :addTo(self)
    :onButtonClicked(buttontHandler(self, function(...)
        self:onClose();
    end));
end

function UserAvatarPopup:onShowed()

end

function UserAvatarPopup:show(data, isAnimation)
	self.data_ = data;
	self.isAnimation_ = isAnimation
	self:setData();
	self:showPanel_(true, true, true, true);
end

function UserAvatarPopup:setData()
	if self.data_ then

        if string.len(self.data_.img) <= 5 then
    		if self.data_.gender == "f" or self.data_.gender == 0 then
    			self.avatar_:setSpriteFrame(display.newSpriteFrame("common_female_avatar.png"));
    		else
    			self.avatar_:setSpriteFrame(display.newSpriteFrame("common_male_avatar.png"));
    		end
		else
    		local imgurl = self.data_.img;
    	    if string.find(imgurl, "facebook") then
    	        if string.find(imgurl, "?") then
    	            imgurl = imgurl .. "&width=600&height=600"
    	        else
    	            imgurl = imgurl .. "?width=600&height=600"
    	        end
    	    end
    	    -- 
    		nk.ImageLoader:loadAndCacheImage(self.avatarLoaderId_,
    	            imgurl, 
    	            handler(self, self.imageLoadCallback_),
    	            nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG);
        end
	end
end

function UserAvatarPopup:onCleanup()
	self:cleanImageLoaderId();
end

function UserAvatarPopup:cleanImageLoaderId()
	nk.ImageLoader:cancelJobByLoaderId(self.avatarLoaderId_)
end

function UserAvatarPopup:imageLoadCallback_(success, sprite)
    if success then
        self:setImage_(sprite)
    elseif self.data_ and (self.data_.gender == "f" or self.data_.gender == "0") then
        self:setImage_(display.newSprite("#common_female_avatar.png"))
    else
        self:setImage_(display.newSprite("#common_male_avatar.png"))
    end
end

function UserAvatarPopup:setImage_(sprite)
	self.avatar_:hide()
    local img = self.headImgContainer_:getChildByTag(1)
    if img then
        img:removeFromParent()
    end
    -- 
    local maxDW = display.width - 40
    local maxDH = display.height - 40
    local spsize = sprite:getContentSize()
    self.scale_ = bm.getFitScale(maxDW, maxDH, spsize)
    sprite:scale(self.scale_)
    -- 
    self.imgTex_ = sprite:getTexture()
    -- 
    local seatSize = self:getContentSize()    
    sprite:pos(seatSize.width * 0.5, seatSize.height * 0.5):addTo(self.headImgContainer_, 1, 1)
    -- 
    local dw = spsize.width * self.scale_ + 0
    local dh = spsize.height * self.scale_ + 0
    self.avatarBg_:size(dw+6, dh+6)
    -- 
    self.stencil_:size(dw, dh)
end

function UserAvatarPopup:onRemovePopup(func)
	local avatar
    local rect
	local cloneAvatar
	if not self.imgTex_ then
		self.imgTex_ = "#common_male_avatar.png"
		rect = self.avatar_:getParent():convertToWorldSpace(cc.p(self.avatar_:getPosition()))
	else
		avatar = self.headImgContainer_:getChildByTag(1)
		rect = self.headImgContainer_:convertToWorldSpace(cc.p(avatar:getPosition()))
	end
	cloneAvatar = display.newSprite(self.imgTex_)
    	:scale(self.scale_)
    	:pos(rect.x, rect.y)
    	:addTo(nk.runningScene, 999999, 999999)
    cloneAvatar:setAnchorPoint(cc.p(0.5, 0.5))
    -- 
    local animTS = 0.3
    cloneAvatar:runAction(transition.sequence({
		cc.Spawn:create(
			cc.ScaleTo:create(animTS, self.scale_*0.3),
			cc.FadeOut:create(animTS)
		)
	}))
    -- 
    func()
end

return UserAvatarPopup;