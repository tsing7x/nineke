--
-- Author: TsingZhang@boyaa.com
-- Date: 2017-10-20 12:07:14
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: HalwnPumpActPopup.lua Created By Tsing7x.
--

local LoadGiftControl = import("app.module.gift.LoadGiftControl")

local HalwnPumpActPopup = class("HalwnPumpActPopup", function()
	-- body
	return display.newNode()
end)

function HalwnPumpActPopup:ctor(rewData, rewCallback)
	-- body
	self.isAnimEnd_ = false
	self.secondStageAnimPlayed_ = false
	self.fristStageAnimPlayed_ = false

	self.effect_ = dragonbones.new({
		skeleton="dragonbones/fla_pumpAct/skeleton.xml", 
        texture="dragonbones/fla_pumpAct/texture.xml",
        skeletonName="fla_pumpAct",
        armatureName="fla_pumpAct"})
	:addTo(self)

	self.effect_:registerAnimationEventHandler(handler(self, self.onAnimEvtHandler_))

	-- local anNiuBoneNode = self.effect_:getArmature():getCCSlot("xinshoulb_AnNiu")
 --    anNiuBoneNode:getCCDisplay():addChild(self.pumpAnimNode_)

	local pumpActBgPosXShift = 45
	self.pumpActPopupBg_ = display.newSprite("activity/pump/pump_bgActPanel.png")
		:pos(- pumpActBgPosXShift, 0)
		:addTo(self)
		:hide()

	self.pumpActPopupBg_:setTouchEnabled(true)
	-- self.pumpActPopupBg_:setTouchSwallowEnabled(true)

	local pumpActBgSize = self.pumpActPopupBg_:getContentSize()

	local pumpActGiftImgPosAdj = {
		x = 35,
		y = 30
	}
	self.pumpActGiftRewImg_ = display.newSprite()
		:pos(pumpActBgSize.width / 2 + pumpActGiftImgPosAdj.x, pumpActBgSize.height / 2 + pumpActGiftImgPosAdj.y)
		:addTo(self.pumpActPopupBg_)

	local gameRound = rewData and rewData.gameRound or 0
	local rewChipNum = rewData and rewData.chipNum or 0
	local rewGiftExpire = rewData and rewData.giftExpire or 1
	local rewHDDJPumpNum = rewData and rewData.HDDJNum or 0

	self.giftId_ = rewData and rewData.giftId or 0
	-- self.giftId_ = 1265
	self.pumpGiftImgLoaderId_ = nk.ImageLoader:nextLoaderId()

	self.getRewCallback_ = rewCallback
	self.reqGiftUrlId_ = LoadGiftControl:getInstance():getGiftUrlById(self.giftId_, function(giftUrl)
		-- body
		self.reqGiftUrlId_ = nil
		if giftUrl and string.len(giftUrl) then
			--todo
			nk.ImageLoader:loadAndCacheImage(self.pumpGiftImgLoaderId_,	giftUrl, handler(self, self.onGiftImageLoadCallback_), nk.ImageLoader.CACHE_TYPE_GIFT)
		end
	end)

	local labelParam = {
		fontSize = 0,
		color = display.COLOR_BLACK
	}

	labelParam.fontSize = 26
	labelParam.color = cc.c3b(100, 198, 237)

	local rewGameRoundLblPosAdj = {
		x = 60,
		y = 110
	}
	self.rewGameRound_ = display.newTTFLabel({text = tostring(gameRound), size = labelParam.fontSize, color = labelParam.color, align = ui.TEXT_ALIGN_CENTER})
		:pos(pumpActBgSize.width / 2 + rewGameRoundLblPosAdj.x, pumpActBgSize.height / 2 + rewGameRoundLblPosAdj.y)
		:addTo(self.pumpActPopupBg_)

	local rewChipNumLblPosAdj = {
		x = - 200,
		y = - 70
	}
	self.rewChipNum_ = display.newTTFLabel({text = bm.formatNumberWithSplit(rewChipNum), size = labelParam.fontSize, color = labelParam.color, align = ui.TEXT_ALIGN_CENTER})
		:pos(pumpActBgSize.width / 2 + rewChipNumLblPosAdj.x, pumpActBgSize.height / 2 + rewChipNumLblPosAdj.y)
		:addTo(self.pumpActPopupBg_)

	local rewGiftExpireLblPosAdj = {
		x = 12,
		y = - 70
	}
	self.rewGiftExpire_ = display.newTTFLabel({text = tostring(rewGiftExpire), size = labelParam.fontSize, color = labelParam.color, align = ui.TEXT_ALIGN_CENTER})
		:pos(pumpActBgSize.width / 2 + rewGiftExpireLblPosAdj.x, pumpActBgSize.height / 2 + rewGiftExpireLblPosAdj.y)
		:addTo(self.pumpActPopupBg_)

	local rewHDDJNumLblPosAdj = {
		x = 215,
		y = - 70
	}
	self.rewHDDJNum_ = display.newTTFLabel({text = tostring(rewHDDJPumpNum), size = labelParam.fontSize, color = labelParam.color, align = ui.TEXT_ALIGN_CENTER})
		:pos(pumpActBgSize.width / 2 + rewHDDJNumLblPosAdj.x, pumpActBgSize.height / 2 + rewHDDJNumLblPosAdj.y)
		:addTo(self.pumpActPopupBg_)

	local actionBtnMagrinCntVect = 140
	local actionBtnMagrinCntHoriz = 35
	self.actionBtn_ = cc.ui.UIPushButton.new({normal = "activity/pump/pump_btnConfirm.png", pressed = "activity/pump/pump_btnConfirm.png", disabled = "activity/pump/pump_btnConfirm.png"},
		{scale9 = false})
		:onButtonClicked(buttontHandler(self, self.onBtnConfirmCallBack_))
		:pos(pumpActBgSize.width / 2 + actionBtnMagrinCntHoriz, pumpActBgSize.height / 2 - actionBtnMagrinCntVect)
		:addTo(self.pumpActPopupBg_)
	
	self:playPumpAnim()
end

function HalwnPumpActPopup:playPumpAnim()
	-- body
	nk.SoundManager:playSound(nk.SoundManager.PUMP_JUMP)

	-- self:onAnimEvtHandler_({type = 7, animationName = "end"})
 	self.effect_:getAnimation():gotoAndPlay("play")
end

function HalwnPumpActPopup:onGiftImageLoadCallback_(isSucc, sprite)
	-- body
	if isSucc then
        local texture = sprite:getTexture()
        local texSize = texture:getContentSize()
        
        local giftShownSize = {
			width = 98,
			height = 98
		}

		if self and self.pumpActGiftRewImg_ then
			--todo
			self.pumpActGiftRewImg_:setTexture(texture)
			self.pumpActGiftRewImg_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
	        self.pumpActGiftRewImg_:setScaleX(giftShownSize.width / texSize.width)
	        self.pumpActGiftRewImg_:setScaleY(giftShownSize.height / texSize.height)
		end
    end
end

function HalwnPumpActPopup:setPumpDataLoadingState(state)
	-- body
	-- if state then
	-- 	--todo
	-- 	local pumpActBgSize = self.pumpActPopupBg_:getContentSize()

	-- 	if not self.pumpDataLoadingBar_ then
	-- 		--todo
	-- 		self.pumpDataLoadingBar_ = nk.ui.Juhua.new()
	-- 			:pos(pumpActBgSize.width / 2, pumpActBgSize.height / 2)
	-- 			:addTo(self.pumpActPopupBg_)
	-- 	end
	-- else
	-- 	if self.pumpDataLoadingBar_ then
	-- 		--todo
	-- 		self.pumpDataLoadingBar_:removeFromParent()
	-- 		self.pumpDataLoadingBar_ = nil
	-- 	end
	-- end
end

function HalwnPumpActPopup:onAnimEvtHandler_(evt)
	-- body
	if evt.type == 7 then  --7 == "complete"
		if evt.animationName == "play" then

			self.fristStageAnimPlayed_ = true

		elseif evt.animationName == "dierduan" then
			self:cleanPumpAnim()
			self.pumpActPopupBg_:show()
			self.isAnimEnd_ = true
		end
	end
end

function HalwnPumpActPopup:cleanPumpAnim()
	-- body
	self.effect_:removeFromParent()
    self.effect_ = nil

	dragonbones.unloadData({
		skeleton="dragonbones/fla_pumpAct/skeleton.xml", 
        texture="dragonbones/fla_pumpAct/texture.xml"
    })
end

function HalwnPumpActPopup:onBtnConfirmCallBack_(evt)
	-- body
	nk.PopupManager:removePopup(self)
end

function HalwnPumpActPopup:onRemovePopup(removePopupFunc)
	-- body
	if self.isAnimEnd_ then
		--todo
		removePopupFunc()
	else
		if self.effect_ and self.fristStageAnimPlayed_ and not self.secondStageAnimPlayed_ then
			--todo
			nk.SoundManager:playSound(nk.SoundManager.PUMP_POUNCH)
			self.effect_:getAnimation():gotoAndPlay("dierduan")
			self.secondStageAnimPlayed_ = true
		end
	end
end

function HalwnPumpActPopup:onEnter()
	-- body
end

function HalwnPumpActPopup:onExit()
	-- body
	if self.getRewCallback_ then
		--todo
		self.getRewCallback_()
	end

	nk.ImageLoader:cancelJobByLoaderId(self.pumpGiftImgLoaderId_)

	if self.reqGiftUrlId_ then
        LoadGiftControl:getInstance():cancel(self.reqGiftUrlId_)
    end

    -- self.effect_:unregisterAnimationEventHandler()
end

function HalwnPumpActPopup:onCleanup()
	-- body
end

return HalwnPumpActPopup