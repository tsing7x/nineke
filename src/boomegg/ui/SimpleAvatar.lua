--
-- Author: KevinYu
-- Date: 2017-03-29 17:06:36
-- 普通头像,默认正方形
local SimpleAvatar  = class("SimpleAvatar", function ()
    return display.newNode()
end)

local AVATAR_SIZE

function SimpleAvatar:ctor(shapeImg, frameImg, size)
	self:setNodeEventEnabled(true)

	AVATAR_SIZE = size or 64

	local headImgContainer = cc.ClippingNode:create()
    local stencil = display.newSprite(shapeImg)
    headImgContainer:setStencil(stencil)
    headImgContainer:setAlphaThreshold(0.05)
    headImgContainer:addTo(self)

    -- 头像
    self.avatar_ = display.newSprite("#common_male_avatar.png")
        :scale(AVATAR_SIZE / 100)
        :addTo(headImgContainer)

    if frameImg and frameImg ~= "" then
    	display.newSprite(frameImg)
        	:addTo(self)
    end

    self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id
end

function SimpleAvatar:loadImage(imgUrl)
	nk.ImageLoader:loadAndCacheImage(
		self.userAvatarLoaderId_,
		imgUrl,
		handler(self, self.onAvatarLoadComplete_),
		nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
	)
end

function SimpleAvatar:onAvatarLoadComplete_(success, sprite)
    if success then
        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()
        self.avatar_:setTexture(tex)
        self.avatar_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
        self.avatar_:setScaleX(AVATAR_SIZE/texSize.width)
        self.avatar_:setScaleY(AVATAR_SIZE/texSize.height)
    end
end

-- 设置性别
function SimpleAvatar:setSex(sexStr)
	if not sexStr or string.len(sexStr) < 1 then
	return
	end

	if sexStr == "f" then
	  self.avatar_:setSpriteFrame("common_female_avatar.png")
	else
	  self.avatar_:setSpriteFrame("common_male_avatar.png")
	end

	return self
end

-- 设置性别和头像
function SimpleAvatar:setSexAndImgUrl(sexStr, imgUrl)
	if not imgUrl or string.len(imgUrl) <= 5 then
	  self:setSex(sexStr)
	else
	  self:loadImage(imgUrl)
	end

	return self
end

function SimpleAvatar:onCleanup()
	nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
end

return SimpleAvatar