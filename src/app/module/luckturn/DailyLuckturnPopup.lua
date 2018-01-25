--
-- Author: HLF(IdaHuang@boyaa.com)
-- Date: 2016-02-26 10:32:32

local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local LuckturnController = import(".LuckturnController")
local DailyLuckturnPopup = class("DailyLuckturnPopup", function()
	return display.newNode()
end)

DailyLuckturnPopup.WIDTH = 400
DailyLuckturnPopup.HEIGHT = 400

local SCALE_VALUE = 1.5
local PANEL_CLOSE_BTN_Z_ORDER = 99
local AVATAR_TAG = 101
local ICON_WIDTH = 85
local ICON_HEIGHT = 85

function DailyLuckturnPopup:ctor()
	self.controller_ = LuckturnController.new(self)

	self.batchNode_ = display.newBatchNode("luckturn_texture.png"):addTo(self)
	self.batchNode_:setTouchEnabled(true)
	self.lcircleBg_ = display.newSprite("#luckTurn_circle_Bg.png"):addTo(self.batchNode_)
	self.rcircleBg_ = display.newSprite("#luckTurn_circle_Bg.png"):addTo(self.batchNode_)
	self.rcircleBg_:flipX(true)
	local csz = self.lcircleBg_:getContentSize()
	self.lcircleBg_:setAnchorPoint(cc.p(1, 0.5))
	self.rcircleBg_:setAnchorPoint(cc.p(0, 0.5))
	self.lcircleBg_:pos(1, 2)
	self.rcircleBg_:pos(0, 2)

	-- 添加光点
	local px, py, pot
	local radius = 182
	self.bigPots_ = {}
	self.smallPots_ = {}
	self.allPots_ = {}
	for i=0,360,30 do
		px, py = math.sin(i*math.pi/180)*radius, math.cos(i*math.pi/180)*radius
		pot = display.newSprite("#luckTurn_smallpot_Bg.png"):pos(px, py):addTo(self.batchNode_)
		table.insert(self.smallPots_, #self.smallPots_+1, pot)
		table.insert(self.allPots_, #self.allPots_+1, pot)

		px, py = math.sin((i+15)*math.pi/180)*radius, math.cos((i+15)*math.pi/180)*radius
		pot = display.newSprite("#luckTurn_bigpot_Bg.png"):pos(px, py):addTo(self.batchNode_)
		table.insert(self.bigPots_, #self.bigPots_+1, pot)
		table.insert(self.allPots_, #self.allPots_+1, pot)
	end

	self:addSliceBar()

	self.playBtn_ = cc.ui.UIPushButton.new({normal = "#luckTurn_start_btn_up.png", pressed = "#luckTurn_start_btn_down.png", disabled = "#luckTurn_start_btn_disabled.png"})
        :addTo(self, 9999)
        :pos(0, 0)
        :onButtonClicked(handler(self, self.onPlayBtnListener_))
        :onButtonRelease(function()

        end)
        :setButtonLabel(ui.newTTFLabel({
                 text = bm.LangUtil.getText("WHEEL", "PLAY"),
                 size = 32,
                 color = styles.FONT_COLOR.GOLDEN_TEXT,
                 align = ui.TEXT_ALIGN_CENTER
            }))
        :setButtonLabelOffset(0, -18)

    self.playBtn_:setButtonEnabled(nk.OnOff:isPlayDailyLuck())
    self:addListener()
end

function DailyLuckturnPopup:addSliceBar()
	-- 添加转盘资源
	local slice
	local imgRes
	self.wheel_ = display.newNode():addTo(self)
	self.wheel_:setTouchEnabled(true)
	self.sliceItems_ = {}
	for i=1,8 do
		if i%2 == 1 then
			imgRes = "#luckTurn_yellow_slice.png"
		else
			imgRes = "#luckTurn_purple_slice.png"
		end
		slice = display.newSprite(imgRes):addTo(self.wheel_)
        -- 保存Slice尺寸
        if not self.sliceSZ_ then
            self.sliceSZ_  = slice:getContentSize() 
        end
		slice:setAnchorPoint(cc.p(0.5, 0))
		slice:rotation(45*(i-1))

		table.insert(self.sliceItems_, #self.sliceItems_+1, slice)
	end
end

function DailyLuckturnPopup:onCleanup()
    if self.delayId_ then
        scheduler.unscheduleGlobal(self.delayId_)
        self.delayId_ = nil        
    end

    self:removeListener()

	self.controller_:dispose()

	self:stopDotsAnim_()

    nk.schedulerPool:delayCall(function()
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end, 0.1)

    for i=1,8 do
        if self["iconLoaderId_"..i] then
            nk.ImageLoader:cancelJobByLoaderId(self["iconLoaderId_"..i])
        end

        if self["txt_"..i] then
            self["txt_"..i]:stopAllActions()
        end

        if self["icon_"..i] then
            self["icon_"..i]:getChildByTag(AVATAR_TAG):stopAllActions()
        end
    end
end

function DailyLuckturnPopup:show(callback)
    self:render()
	nk.PopupManager:addPopup(self, true, true, true, true, nil, SCALE_VALUE)
	return self
end

function DailyLuckturnPopup:onShowed()
    self.controller_:getDailyBigWheel()
end

function DailyLuckturnPopup:onClose()
	self:close()
end

function DailyLuckturnPopup:close()
	nk.PopupManager:removePopup(self)
	return self
end

function DailyLuckturnPopup:onRemovePopup(func)
    self:onCleanup()
    func()
end

function DailyLuckturnPopup:addListener()
	if not self.synchDailyBigWheelId_ then
    	self.synchDailyBigWheelId_ = bm.EventCenter:addEventListener(LuckturnController.GetDailyBigWheel_Event, handler(self, self.onSynchDailyBigWheelHandler_))
    end

    if not self.synchDailyLuckDrawId_ then
    	self.synchDailyLuckDrawId_ = bm.EventCenter:addEventListener(LuckturnController.DailyLuckDraw_Event, handler(self, self.onSynchDailyLuckDrawHandler_))
    end
end

function DailyLuckturnPopup:removeListener()
    if self.synchDailyBigWheelId_ then
		bm.EventCenter:removeEventListener(self.synchDailyBigWheelId_)
		self.synchDailyBigWheelId_ = nil
	end

	if self.synchDailyLuckDrawId_ then
		bm.EventCenter:removeEventListener(self.synchDailyLuckDrawId_)
		self.synchDailyLuckDrawId_ = nil
	end
end

function DailyLuckturnPopup:render()

end

function DailyLuckturnPopup:onSynchDailyBigWheelHandler_(evt)
	self.cfgs_ = evt.data
	local count = #self.cfgs_
	local cfg
	local lblColor
	local sliceItem
	local len = #self.sliceItems_
	for i=1,len do
		if i > count then
			break
		end
		if i%2 == 1 then
			lblColor = cc.c3b(0x73, 0x16, 0xb9)
		else
			lblColor = cc.c3b(0xff, 0xff, 0xff)
		end
		-- 保存Slice尺寸
        if not self.sliceSZ_ then
            self.sliceSZ_  = slice:getContentSize() 
        end
		cfg = self.cfgs_[i]
		sliceItem = self.sliceItems_[i]
        sliceItem:removeAllChildren()
		self:addSliceItem(i, sliceItem, cfg, lblColor)
	end
end

function DailyLuckturnPopup:onSynchDailyLuckDrawHandler_(evt)
    if evt.data == nil then
        return
    end

	local data = evt.data
	local index = data.pos
    local tid = data.id
    self:playDotsAnimInNormal_()
    self:setDestDegreeById(index)
    self:startRotation(function()
    	index = index + 1
        local item = self:findItemById(index)
        self:performWithDelay(function()
            nk.SoundManager:playSound(nk.SoundManager.WHEEL_WIN)
            self:stopDotsAnimInNormal_()
        end, 0.5)
        nk.SoundManager:playSound(nk.SoundManager.WHEEL_END)

        -- 飞出动画效果
        bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="Wheel_start"})
        local iconContainer = self["icon_"..index]
        local oldAvatar = iconContainer:getChildByTag(AVATAR_TAG)
        local rect = oldAvatar:getParent():convertToWorldSpace(cc.p(oldAvatar:getPosition()))
        local num = data.num or 1
        local itype = 5
        local scaleVal = 1.0
        local sz = oldAvatar:getContentSize()
	    local cloneAvatar = bm.cloneNode(oldAvatar, sz, 0, 0)
        nk.UserInfoChangeManager:playWheelFlyChipAnimation(cloneAvatar, rect, itype, num, cloneAvatar:getTexture(), scaleVal)

        if nk.OnOff:isPlayDailyLuck() then
        	self.playBtn_:setButtonEnabled(true)
        end

        self.delayId_ = scheduler.performWithDelayGlobal(function ()
            self:onCheckOverDueTick(tid)
        end, 1.5)
    end)
end

function DailyLuckturnPopup:addSliceItem(index, sliceNode, cfg, lblColor)
	----type:: 1互动道具  2现金卡  3比赛劵 4金券 5为最高筹码(wheel_reward_1.png) 
	-- 6为最高筹码(wheel_reward_2.png) 7为最高筹码(wheel_reward_3.png) 8为最高筹码(wheel_reward_4.png) 
	-- 9为最高筹码(wheel_reward_5.png) 10为最高筹码(wheel_reward_6.png)
	if not cfg then
		return
	end

    local fontSize = 16
    local px, py = self.sliceSZ_.width*0.5, 0
    local cfgName = cfg.name

    local txt = ui.newTTFLabel({
            text = cfgName, 
            color = lblColor,
            size = fontSize, 
            align = ui.TEXT_ALIGN_CENTER,
        })
    :pos(px, 153)
    :addTo(sliceNode)
    bm.fitSprteWidth(txt, 120)
    self["txt_"..index] = txt

	if cfg.type == "fun_face" then
        -- 互动道具
		display.newSprite("#prop_hddj_icon.png"):pos(px, 118):addTo(sliceNode)
		ui.newTTFLabel({
            text = cfg.num, color = cc.c3b(0xff,0xff,0),
            size = 24, align = ui.TEXT_ALIGN_CENTER})
        :pos(80, 102)
        :addTo(sliceNode)

        py = 150
	elseif cfg.type == "score" then
        -- 积分现金卡
		display.newSprite("#luckTurn_reward_card.png"):pos(px, 115):addTo(sliceNode)
		ui.newTTFLabel({
            text = cfg.num, color = cc.c3b(0xa0,0x4e,0x02),
            size = 16, align = ui.TEXT_ALIGN_CENTER})
        :pos(65, 123)
        :addTo(sliceNode)

        py = 150
	elseif cfg.type == "game_coupon" then
        -- 比赛券
		display.newSprite("match_gamecoupon.png"):pos(px, 115):addTo(sliceNode)

        py = 150
        ui.newTTFLabel({
            text = cfg.num, color = cc.c3b(0xff,0xff,0),
            size = 24, align = ui.TEXT_ALIGN_CENTER})
        :pos(80, 102)
        :addTo(sliceNode)
    elseif cfg.type == "chips" then
        local res
        if cfg.num < 800 then
            res = "act-task-reward-chip-icon-1.png"
        elseif cfg.num < 1500 then
            res = "act-task-reward-chip-icon-2.png"
        elseif cfg.num < 4000 then
            res = "act-task-reward-chip-icon-3.png"
        elseif cfg.num < 70000 then
            res = "act-task-reward-chip-icon-4.png"
        elseif cfg.num < 500000 then
            res = "act-task-reward-chip-icon-5.png"
        else
            res = "act-task-reward-chip-icon-6.png"
        end

        display.newSprite(res):pos(px, 108):addTo(sliceNode)

        py = 150
    elseif cfg.type == "real" then
    elseif cfg.type == "ticket" then
        local iconContainer = display.newNode():pos(px, 118):size(ICON_WIDTH, ICON_HEIGHT):addTo(sliceNode)
        local iconLoaderId = nk.ImageLoader:nextLoaderId()
        local defaultIcon = display.newSprite("#transparent.png"):addTo(iconContainer, AVATAR_TAG, AVATAR_TAG)
        defaultIcon:setScale(0.4)

        self["icon_"..index] = iconContainer
        self["iconLoaderId_"..index] = iconLoaderId
        self["defaultIcon"..index] = defaultIcon
        txt:setOpacity(0)

        nk.ImageLoader:cancelJobByLoaderId(iconLoaderId)
        nk.ImageLoader:loadAndCacheImage(iconLoaderId,
            cfg.img,
            function(success, sprite)
                if sprite and type(sprite) ~= "string" then
                    local tex = sprite:getTexture()
                    local texSize = tex:getContentSize()
                    local oldAvatar = iconContainer:getChildByTag(AVATAR_TAG)
                    if oldAvatar then
                        oldAvatar:removeFromParent()
                    end

                    local iconSize = iconContainer:getContentSize()
                    local xxScale = iconSize.width/texSize.width
                    local yyScale = iconSize.height/texSize.height
                    local scaleVal = xxScale<yyScale and xxScale or yyScale
                    sprite:addTo(iconContainer, 0, AVATAR_TAG)

                    sprite:setScale(0.2)
                    sprite:pos(0, -80)
                    local ts = 0.16
                    sprite:runAction(cc.Sequence:create(
                        cc.MoveTo:create(ts, cc.p(0, 0)),
                        cc.ScaleTo:create(ts, scaleVal)
                    ))

                    txt:runAction(cc.FadeTo:create(ts*2, 255))
                end
            end
        )
        py = 150
    end
end

function DailyLuckturnPopup:onPlayBtnListener_(evt)
	self.playBtn_:setButtonEnabled(false)
	if nk.OnOff:isPlayDailyLuck() then
		self:playNow()		
	end

    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand {
            command = "event",
            args = {eventId = "match_Dailyluckturn_play"},
            label = "luckturn play"
        }
    end
end

function DailyLuckturnPopup:playNow()
    self.controller_:onDailyLuckDraw()
end

function DailyLuckturnPopup:playDotsAnimInNormal_()
    self:stopDotsAnim_()
    local dts = 0.1
    for _, dot in ipairs(self.bigPots_) do
        dot:runAction(cc.RepeatForever:create(transition.sequence({
                    cc.FadeTo:create(dts, 255), 
                    cc.DelayTime:create(dts),
                    cc.FadeTo:create(dts, 0),
                    cc.DelayTime:create(dts)
                })
            )
        )
    end

    for _, dot in ipairs(self.smallPots_) do
        dot:runAction(cc.RepeatForever:create(transition.sequence({
        			cc.FadeTo:create(dts, 0),
        			cc.DelayTime:create(dts),
                    cc.FadeTo:create(dts, 255),
                    cc.DelayTime:create(dts)
                })
            )
        )
    end
end

function DailyLuckturnPopup:setDestDegreeById(id)
	math.randomseed(tostring(os.time()):reverse():sub(1, 6))
	local randDegree = 0
    local offsetDegree = 5
    if id == 0 then
        randDegree = math.random(-20 + offsetDegree, 20 - offsetDegree)
    else
        local min = 20 + 3 + 45 * (id - 1) + offsetDegree
        local max = min - 3 + 45 - offsetDegree * 2
        randDegree = math.random(min, max)
    end

    self.destDegree_ = 360 - randDegree
end

function DailyLuckturnPopup:startRotation(callback)
    self.animOverflushMyScore_ = callback
    if self.soundId then
          audio.stopSound(self.soundId)
    end
    self.soundId = nk.SoundManager:playSound(nk.SoundManager.WHEEL_LOOP, false)
    self:rotationByAccelerate()
end

function DailyLuckturnPopup:rotationByAccelerate()
    self.wheel_:stopAllActions()
    local sequence = transition.sequence({
        cc.EaseIn:create(cc.RotateBy:create(1, 360), 2.5),
        cc.CallFunc:create(function()
            self:rotationByDefault()
        end),
    })
    self.wheel_:runAction(sequence)
end

function DailyLuckturnPopup:rotationByDefault()
    self.wheel_:setRotation(self.destDegree_)
    local sequence = transition.sequence({
        cc.RotateBy:create(0.5, 360),
        cc.CallFunc:create(function()
            self:rotationByDecelerate()
        end),
    })
    self.wheel_:runAction(sequence)
end

function DailyLuckturnPopup:rotationByDecelerate()
    local sequence = transition.sequence({
        cc.EaseOut:create(cc.RotateBy:create(3, 360), 2.5),
        cc.CallFunc:create(function()
            if self.soundId then
                audio.stopSound(self.soundId)
            end
            if self.animOverflushMyScore_ then
                self.animOverflushMyScore_()
            end
        end),
    })
    self.wheel_:runAction(sequence)
end

function DailyLuckturnPopup:stopDotsAnimInNormal_()
	for _, dot in ipairs(self.allPots_) do
        dot:setOpacity(255)
    end

    self:stopDotsAnim_()
end

function DailyLuckturnPopup:stopDotsAnim_( ... )
	for _, dot in ipairs(self.allPots_) do
        dot:stopAllActions()
    end
end

function DailyLuckturnPopup:findItemById(id)
	return self.cfgs_[id+1]
end

function DailyLuckturnPopup:onCheckOverDueTick(tid)
    local params = {}
    params.title = "คำเตือนสำหรับตั๋ว"
    params.ticketId = tid
    local MatchTickOverduePopup = import("app.module.match.MatchTickOverduePopup")
    MatchTickOverduePopup.new(params):show()

    self:close()
end

return DailyLuckturnPopup