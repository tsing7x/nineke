--
-- Author: HLF(IdaHuang@boyaa.com)
-- Date: 2016-04-25 09:41:29
--
local AnimationIcon          = import("boomegg.ui.AnimationIcon")
local ScoreExchangeSuccPopup = class("ScoreExchangeSuccPopup", nk.ui.Panel)
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

ScoreExchangeSuccPopup.WIDTH = 450
ScoreExchangeSuccPopup.HEIGHT = 240
local AVATAR_TAG = 101
local ICON_WIDTH = 305
local ICON_HEIGHT = 155

function ScoreExchangeSuccPopup:ctor(rewardData, goodsData, callback, aimPos)
	local width, height = ScoreExchangeSuccPopup.WIDTH, ScoreExchangeSuccPopup.HEIGHT
	ScoreExchangeSuccPopup.super.ctor(self, {width+30, height+30})
	self.goodsData_ = goodsData
	self.callback_ = callback
	self.aimPos_ = aimPos
	-- 
	self.titleBg_ = display.newSprite("#sm_exchangeTitle_bg.png")
		:pos(0, height*0.5 + 28)
		:addTo(self)
    -- 
	-- self:addCloseBtn()
	-- self:setCloseBtnOffset(10,5)
	display.newScale9Sprite("#pop_common_listitem_bg.png", 0, 0, cc.size(410, 160)):addTo(self)
	-- 
	-- 中间的图片
    self.icon_ = display.newNode()
        :size(ICON_WIDTH,ICON_HEIGHT)
        :addTo(self)
	-- 
    self:setLoading(true)
    self.animationIcon_ = AnimationIcon.new("#game_logo.png", 1, 1)
        :addTo(self.icon_, 0, AVATAR_TAG)
    self.animationIcon_:onData(self.goodsData_.image, ICON_WIDTH, ICON_HEIGHT, function(succ, tex)
        self.imgTex_ = tex
        self.delayCloseHandle_ = scheduler.performWithDelayGlobal(function ()
            self:flyAnimation_()
        end, 5)
        self:setLoading(false)
        self.xxScale_ = 1
        self.yyScale_ = 1
    end)
    -- 
    self.nameTxt_ = ui.newTTFLabel({
		text=self.goodsData_.name,
		color=styles.FONT_COLOR.LIGHT_TEXT,
		size=26,
		align=ui.TEXT_ALIGN_CENTER
	})
	:pos(0, -height*0.5+20)
	:addTo(self)
	-- 
	-- self.delayCloseHandle_ = scheduler.performWithDelayGlobal(function ()
 --        self:onClose()
 --    end, 5)
end

function ScoreExchangeSuccPopup:onCallbackImageLoader_(success, sprite)
    self:setLoading(false)
    if success then
        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()
        local oldAvatar = self.icon_:getChildByTag(AVATAR_TAG)
        if oldAvatar then
            oldAvatar:removeFromParent()
        end
        local iconSize = self.icon_:getContentSize()
        self.xxScale_ = iconSize.width/texSize.width
        self.yyScale_ = iconSize.height/texSize.height
        sprite:scale(self.xxScale_<self.yyScale_ and self.xxScale_ or self.yyScale_)
            :addTo(self.icon_, 0, AVATAR_TAG)
        -- 
        self.delayCloseHandle_ = scheduler.performWithDelayGlobal(function ()
	        self:flyAnimation_()
	    end, 3)

        self.imgTex_ = tex
    end
end
-- 
function ScoreExchangeSuccPopup:flyAnimation_()
	local avatar = self.icon_:getChildByTag(AVATAR_TAG)
    local rect = self.icon_:convertToWorldSpace(cc.p(avatar:getPosition()))
	local cloneAvatar
    -- 
    if self.imgTex_ then
        cloneAvatar = display.newSprite(self.imgTex_)
        cloneAvatar:scale(self.xxScale_<self.yyScale_ and self.xxScale_ or self.yyScale_)
    else
        cloneAvatar = ui.newTTFLabel({
            text=self.goodsData_.name,
            color=styles.FONT_COLOR.LIGHT_TEXT,
            size=26,
            align=ui.TEXT_ALIGN_CENTER
        })
    end
    -- 
    cloneAvatar:pos(rect.x, rect.y)
        :addTo(nk.runningScene, 999999, 999999)
    cloneAvatar:setAnchorPoint(cc.p(0.5, 0.5))
	avatar:hide()
	-- 
	local animTS = 0.3;
	local animPos = cc.p(self.aimPos_.x + 10, self.aimPos_.y)
	local startNode = display.newNode()
		:addTo(nk.runningScene, 999999, 999999)
        :pos(animPos.x, animPos.y)
        :hide()
    for i = 1, 4 do
        display.newSprite("#sm_flash_star.png")
            :pos(0, 0)
            :addTo(startNode)
    end
    -- 
    transition.moveTo(cloneAvatar, {time=animTS, x=animPos.x, y=animPos.y})
	cloneAvatar:runAction(transition.sequence({
        cc.Spawn:create(
            cc.ScaleTo:create(animTS, 0.02),
            cc.RotateTo:create(animTS, 360*3)
        ),
        cc.CallFunc:create(function(obj)
            cloneAvatar:stopAllActions()
        	cloneAvatar:removeFromParent();
        	startNode:show()
            startNode:runAction(transition.sequence({
                    cc.Spawn:create(
                        cc.RotateTo:create(0.2, 360*2),
                        cc.ScaleTo:create(0.2, 1.5)
                    ),
                    cc.Spawn:create(
                        cc.RotateTo:create(0.2, 360*2),
                        cc.ScaleTo:create(0.2, 0.1)
                    ),
                    cc.CallFunc:create(function()
                        startNode:removeFromParent();
                        -- self:onClose()
                    end)
                }))
        	
        end)
    }));
    self:onClose()
end
-- 
function ScoreExchangeSuccPopup:onCleanup()
	if self.delayCloseHandle_ then
        scheduler.unscheduleGlobal(self.delayCloseHandle_)
        self.delayCloseHandle_ = nil        
    end
    -- 查看日志记录
    -- if self.callback_ then
    -- 	self.callback_()
    -- 	self.callback_ = nil
    -- end
end

function ScoreExchangeSuccPopup:onRemovePopup(func)
	self:onCleanup()
	func()
end

function ScoreExchangeSuccPopup:onShowed()

end

function ScoreExchangeSuccPopup:onClose()
	self:close()
end

function ScoreExchangeSuccPopup:close()
    nk.PopupManager:removePopup(self)
    return self
end

function ScoreExchangeSuccPopup:show()
    nk.PopupManager:addPopup(self)
    self:playRewardParticle_()
    return self
end

function ScoreExchangeSuccPopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
                :addTo(self)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

function ScoreExchangeSuccPopup:playRewardParticle_()
	local particleNode = display.newNode()
		:pos(0, ScoreExchangeSuccPopup.HEIGHT*0.5)
		:addTo(self)
	for i=0,14 do
		local filename = "Particle/luckturn/fx_caidai"..string.format("%02d", i)..".plist"
		local emitter = cc.ParticleSystemQuad:create(filename)
			:addTo(particleNode)
		emitter:setAutoRemoveOnFinish(true)
	end
end

return ScoreExchangeSuccPopup