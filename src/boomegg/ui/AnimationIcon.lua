--
-- Author: HLF(IdaHuang@boyaa.com)
-- Date: 2016-05-18 18:18:47
--
-- require(cc.PACKAGE_NAME..".cocos2dx.DragonBonesEx")

local AnimationIcon = class("AnimationIcon", function()
	local node = display.newNode()
	node:setNodeEventEnabled(true)
	return node
end)

local ICON_TAG = 10
local TEXTURE_XML = "texture.xml"
local SKELETON_XML = "skeleton.xml"
local TEXTURE_PNG = "texture.png"
local DRAGONBONE_FILES = {"texture.png", "texture.xml", "skeleton.xml"}

AnimationIcon.MAX_GIFT_DW = 160
AnimationIcon.MAX_GIFT_DH = 160
--[[
loadingImg:为默认加载图片资源
imgScale:为加载图片资源缩放值
animScale:为龙骨动画加载完成后的缩放值
clickCallback:为Click事件
]]--
function AnimationIcon:ctor(loadingImg, imgScale, animScale, clickCallback, btnDW, btnDH, loadingImgScale)
	self.loadingImg_ = loadingImg
	self.imgScale_ = imgScale or 0.5
	self.animScale_ = animScale or 0.5
	self.loadingImgScale_ = loadingImgScale or 1
	self.btnDW_ = btnDW or 60
	self.btnDH_ = btnDH or 60
	-- 
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	-- 
	if self.loadingImg_ and string.len(self.loadingImg_) > 5 then
		self.loading_ = display.newSprite(self.loadingImg_)
			:addTo(self)
			:scale(self.loadingImgScale_)
	end
	-- 
	if clickCallback then
		bm.TouchHelper.new(self, function(target, evtName)
			if evtName==bm.TouchHelper.CLICK then
		        clickCallback()
		    end
		end)
		-- cc.ui.UIPushButton.new({normal="#modal_texture.png"}, {scale9=true})
		-- 	:addTo(self)
		-- 	:setButtonSize(self.btnDW_, self.btnDH_)
		-- 	:onButtonClicked(function()
		-- 		clickCallback()
		-- 	end)
	end
	-- 
	self:getNextLoaderId_()
end
-- 
function AnimationIcon:onData(imgUrl, maxDW, maxDH, callback, diffVal)
	self.imgUrl_ = imgUrl
	self.maxDW_ = maxDW
	self.maxDH_ = maxDH
	self.diffVal_ = diffVal or 0
	self.callback_ = callback
	self.lastImgScale_ = self.imgScale_
	-- 
	if not self.imgUrl_ then
		if self.loading_ then
			self.loading_:show()
		end
		self:removeTAG_()
		self.lastImgUrl_ = nil
		return
	end
	-- 
	if self.imgUrl_ ~= self.lastImgUrl_ then
		if self.loading_ then
			self.loading_:show()
		end
		self:loadImage_(self.imgUrl_)
		self.lastImgUrl_ = self.imgUrl_
	else
		if self.callback_ then
	    	self.callback_(true, nil)
	    end
	end
end

function AnimationIcon:getNextLoaderId_()
	self.loaderId_ = nk.ImageLoader:nextLoaderId()
end

function AnimationIcon:cancelLoaderId()
	if self.loaderId_ then
		nk.ImageLoader:cancelJobByLoaderId(self.loaderId_)
		self.loaderId_ = nil
	end
end

function AnimationIcon:loadImage_(imgUrl)
	nk.ImageLoader:cancelJobByLoaderId(self.loaderId_)
	if nk.userData.isUseAnimation == 1 then
		local params = bm.getFileNameByFilePath(imgUrl)
		if params then
			if params["extension"] == "zip" then
				nk.ImageLoader:loadAndCacheAnimation(
					DRAGONBONE_FILES,
					self.loaderId_,
					imgUrl,
					handler(self, self.onAnimationLoadCallback_),
					nk.ImageLoader.CACHE_TYPE_ANIMATION
				)
			elseif params["extension"] == "zgaf" then
				local filename = params["name"]
				local files = {filename..".png", filename..".gaf"}
				nk.ImageLoader:loadAndCacheAnimation(
					files,
					self.loaderId_,
					imgUrl,
					handler(self, self.onGAFLoadCallback_),
					nk.ImageLoader.CACHE_TYPE_ANIMATION
				)
			else
				nk.ImageLoader:loadAndCacheImage(self.loaderId_,
					imgUrl,
					handler(self, self.onGiftImageLoadCallback_),
					nk.ImageLoader.CACHE_TYPE_GIFT
				)
			end
		end
	else
		nk.ImageLoader:loadAndCacheImage(self.loaderId_,
			imgUrl,
			handler(self, self.onGiftImageLoadCallback_),
			nk.ImageLoader.CACHE_TYPE_GIFT
		)
	end
end
-- 
function AnimationIcon:onGAFLoadCallback_(success, params, loaderId)
	if success then
		if self.loading_ then
			self.loading_:hide()
		end
		-- 
		self:removeTAG_()
		-- 
		local animationName = params["name"]
		local animationScale = params["scale"] or 1 -- scale 动画缩放比例
		local actionName = params["action"] or "play" -- action 为播放的标签名称
		local delay = params["delay"] or -1 -- delay 延迟多久播放动画，-1为不延迟播放动画
		local speed = params["speed"] or 1 	-- speed 为动画播放用时
		local offx = params["offx"] or 0 	-- offx 为x坐标的偏移量
		local offy = params["offy"] or 0 	-- offy 为y坐标的偏移量
		local loop = params["loop"] or 0 	-- loop 为播放次数，0为无限播放
		local dVal = params["dVal"] or 0 	-- dVal 为最大宽度、高度的偏差值
		local path = device.writablePath.."cache/animation/"..tostring(animationName).."/"

		local file = path..animationName..".gaf"
	    local asset = GAFAsset:create(file)
	    local animation = asset:createObject()
	    animation:addTo(self, ICON_TAG, ICON_TAG)
	    animation:setScale(animationScale)	    
	    animation:pos(offx, offy)
	    animation:setLooped(true)
	    animation:start() --animation:startOnce()

	    self.animScale_ = animationScale
	end
	-- 
    if self.callback_ then
    	local tex = nil
    	self.callback_(success, tex)
    end
end
function AnimationIcon:onAnimationLoadCallback_(success, params, loaderId)
	if success then
		if self.loading_ then
			self.loading_:hide()
		end
		-- 
		self:removeTAG_()
		-- 
		local animationName = params["name"]
		local animationScale = params["scale"] or 1 -- scale 动画缩放比例
		local actionName = params["action"] or "play" -- action 为播放的标签名称
		local delay = params["delay"] or -1 -- delay 延迟多久播放动画，-1为不延迟播放动画
		local speed = params["speed"] or -1	-- speed 为动画播放用时
		local offx = params["offx"] or 0 	-- offx 为x坐标的偏移量
		local offy = params["offy"] or 0 	-- offy 为y坐标的偏移量
		local loop = params["loop"] or 0 	-- loop 为播放次数，0为无限播放
		local path = device.writablePath.."cache/animation/"..tostring(animationName).."/"
	    self._db = dragonbones.new({
	        skeleton=path..DRAGONBONE_FILES[3],
	        texture=path..DRAGONBONE_FILES[2],
	        armatureName=string.lower(animationName),
	        aniName="",
	        skeletonName=string.lower(animationName)
	    })
	    :addTo(self, ICON_TAG, ICON_TAG)-- :addMovementScriptListener(handler(self, self._onMovement))
	    self._db:getAnimation():gotoAndPlay(actionName, delay, speed, loop)
	    -- 
	    if self.maxDW_ and self.maxDH_ then
        	local sz = self._db:getCascadeBoundingBox()
    		local fitScale = bm.getFitScale(self.maxDW_+self.diffVal_, self.maxDH_+self.diffVal_, sz)
    		if fitScale < animationScale then
    			animationScale = fitScale
    		end
    		offy = offy - self.diffVal_*0.5
    	end
    	self._db:scale(animationScale)
    	self._db:pos(offx, offy)

	    self.animScale_ = animationScale
	end
	-- 
    if self.callback_ then
    	local tex = nil
    	self.callback_(success, tex)
    end
end
-- self.maxDW_ = maxDW
-- 	self.maxDH_ = maxDH
function AnimationIcon:_onMovement(evtType, movId)
	if evtType == cc.DragonBonesNode.EVENTS.START then
		self:dispatchEvent({name = "start", mov = movId})
	elseif evtType == cc.DragonBonesNode.EVENTS.COMPLETE then
		self:dispatchEvent({name = "end", mov = movId})
		if self.onComplete then
			self.onComplete()
		end
	end
end
-- 
function AnimationIcon:onGiftImageLoadCallback_(success, sprite, loaderId)
    if success then
    	if self.loading_ then
			self.loading_:hide()
		end
		-- 
    	self:removeTAG_()
        sprite:addTo(self, ICON_TAG, ICON_TAG)
        if self.maxDW_ and self.maxDH_ then
        	local sz = sprite:getContentSize()
    		local scaleVal = bm.getFitScale(self.maxDW_, self.maxDH_, sz)
    		if self.lastImgScale_ > scaleVal then
    			self.lastImgScale_ = scaleVal
    		end
    	end
        sprite:scale(self.lastImgScale_)
        self.animScale_ = self.lastImgScale_
    end
    -- 
    if self.callback_ then
    	local tex = nil
    	if sprite then
    		tex = sprite:getTexture()
    	end
    	self.callback_(success, tex)
    end
end
-- 移除Icon
function AnimationIcon:removeTAG_()
	local oldIcon = self:getChildByTag(ICON_TAG)
	if oldIcon then
		oldIcon:removeFromParent()
	end

	local oldAvatar = self:getChildByTag(ICON_TAG)
    if oldAvatar then
        oldAvatar:removeFromParent()
    end
end

function AnimationIcon:play()
	if self._db then
		self._db:getAnimation():gotoAndPlay("play", -1, 1, 0)
	end
end

function AnimationIcon:onCleanup()
	self:cancelLoaderId()
end

return AnimationIcon