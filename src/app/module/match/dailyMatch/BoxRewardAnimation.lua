--
-- Author: hlf
-- Date: 2015-11-13 14:57:35
-- 宝箱领取奖励

local RoomViewPosition = import("app.module.room.views.RoomViewPosition")
local BoxRewardAnimation = class("BoxRewardAnimation", function()
	return display.newNode();
end)

BoxRewardAnimation.ANIMATION_TYPE1 = 1;
BoxRewardAnimation.ANIMATION_TYPE2 = 2;

local POS_LIST = {
	{0},
	{-70, 70},
	{-140, 0, 140},
	{-140, -70, 70, 140},
	{-280, -140, 0, 140, 280},
}

function BoxRewardAnimation:ctor(aniType, params, iconPosFunc, sceneview, isAutoClose)
	self.step_ = 0;
	if isAutoClose then
		self.step_ = 2
	end
	self.aniType_ = aniType;
	self.params_ = params;
	self.iconPosFunc_ = iconPosFunc;
	self.sceneview_ = sceneview;
	self:setNodeEventEnabled(false);
	display.addSpriteFrames("upgrade_texture.plist", "upgrade_texture.png", handler(self, self.initView_))
end

function BoxRewardAnimation:initView_()
	self.container_ = display.newNode():addTo(self);
	self.container_:setTouchEnabled(false)
end

function BoxRewardAnimation:playAnimation_()
	if self.aniType_ == BoxRewardAnimation.ANIMATION_TYPE1 then
		self:animationType1_();
	else
		self:animationType2_();
	end
end

function BoxRewardAnimation:animationType1_()
	--关闭宝箱时的背景
    self.closeBg_ = display.newSprite("#upgrade_bg_closed.png"):addTo(self.container_)
    --打开宝箱之后的背景
    self.openBg_ = display.newSprite("#upgrade_bg_opened.png"):addTo(self.container_)
    self.openBg_:setOpacity(0)

    self.boxSpr_ = display.newSprite("#upgrade_treasure_closed.png"):addTo(self.container_)
    			:pos(0,display.height*0.5)
    self.boxOpenSpr_ = display.newSprite("#upgrade_treasure_opened.png"):addTo(self.container_)
    			:pos(0,0)
    self.boxOpenSpr_:setOpacity(0)

    transition.moveTo(self.boxSpr_, {
    	time=0.2, 
    	y=0, 
    	easing = "BACKOUT",
    	onComplete=handler(self, self.callbackOnComplete1_)
    });
end

function BoxRewardAnimation:animationType2_()
	--关闭宝箱时的背景
    self.closeBg_ = display.newSprite("#upgrade_bg_closed.png"):addTo(self.container_)
    --打开宝箱之后的背景
    self.openBg_ = display.newSprite("#upgrade_bg_opened.png"):addTo(self.container_)
    self.openBg_:setOpacity(0)

    self.boxSpr_ = display.newNode():addTo(self.container_)
    			:pos(0,display.height*1)
    local pos
    if #self.params_>#POS_LIST then
    	pos = POS_LIST[#POS_LIST]
    else
    	pos = POS_LIST[#self.params_]
    end

	local px;
	self.cfgs_ = {}
	for i=1,#self.params_ do
		if i <= #pos then
			px = pos[i]
			info = self.params_[i];
			local cfg = self:createRewardItem_(self.boxSpr_, info, 1.2)
			cfg.contain:setPositionX(px)

			table.insert(self.cfgs_, #self.cfgs_+1, cfg)
		end
	end

    transition.moveTo(self.boxSpr_, {
    	time=0.25, 
    	y=0, 
    	easing = "BACKOUT",

    	onComplete=handler(self, self.callbackOnComplete2_)
    });
end

-- fadeOpenBg_
function BoxRewardAnimation:callbackOnComplete1_()
	self:fadeOpenBg_(self.openBg_, self.openBg_, handler(self, self.onCallBackFadeOpenBg_))
	self:BubbleAnimation_();
end

function BoxRewardAnimation:callbackOnComplete2_()
	self:fadeOpenBg_(self.openBg_, self.openBg_, handler(self, self.onCallBackFadeOpenBg_))
end

function BoxRewardAnimation:BubbleAnimation_()
	local button = self.boxSpr_;
    local function zoom1(offset, time, onComplete)
	    local x, y = button:getPosition()
	    local size = button:getContentSize()

	    local scaleX = button:getScaleX() * (size.width + offset) / size.width
	    local scaleY = button:getScaleY() * (size.height - offset) / size.height

	    transition.moveTo(button, {y = y - offset, time = time})
	    transition.scaleTo(button, {
	        scaleX     = scaleX,
	        scaleY     = scaleY,
	        time       = time,
	        onComplete = onComplete,
	    })
	end

	local function zoom2(offset, time, onComplete)
	    local x, y = button:getPosition()
	    local size = button:getContentSize()

	    transition.moveTo(button, {y = y + offset, time = time / 2})
	    transition.scaleTo(button, {
	        scaleX     = 1.0,
	        scaleY     = 1.0,
	        time       = time,
	        onComplete = onComplete,
	    })
	end

	button:setTouchEnabled(false);

	zoom1(40, 0.08, function()
	    zoom2(40, 0.09, function()
	        self:showRewardAnimation_();
	    end)
	end)
end

function BoxRewardAnimation:fadeOpenBg_(bg1, bg2, callback)
	bg1:runAction(transition.sequence({
    		cc.FadeOut:create(0.5)
    	}))

    bg2:runAction(transition.sequence({
    		cc.FadeIn:create(0.5),
    		cc.CallFunc:create(function()
    			if callback then
    				callback();
    			end
    		end);
    	}))    
end

function BoxRewardAnimation:onCallBackFadeOpenBg_()
	if self.step_ == 2 then
		self.step_ = 1;
		self:hide();
	else
		self.step_ = 1;
	end
end

function BoxRewardAnimation:showRewardAnimation_()
 	self:fadeOpenBg_(self.boxSpr_, self.boxOpenSpr_)
 	self:rewardAnimation_();
end

function BoxRewardAnimation:rewardAnimation_()
	local cfg;
	local info;
	local pos = {-215, -360}
	local px;
	for i=1,#self.params_ do
		if i <= #pos then
			px = pos[i]
			info = self.params_[i];
			cfg = self:createRewardItem_(self.container_, info, 0.2)
			self:createBezierAnimation_(cfg.contain, cc.p(px, -50), cc.p(-150, 320), cc.p(-150, 320))
		end
	end
end

function BoxRewardAnimation:createBezierAnimation_(mc, endpt, ctrpt1, ctrpt2)
	local bconfig = {ctrpt1, ctrpt2, endpt}
	local ts = 0.3
	mc:runAction(transition.sequence({
			cc.EaseInOut:create(cc.BezierTo:create(ts, bconfig), 1),
			cc.ScaleTo:create(ts, 1)
		}))
end

function BoxRewardAnimation:createRewardItem_(parentContain, info, scaleVal)
	local cfg = {}
	cfg.data = info;
	cfg.contain = display.newNode():addTo(parentContain);--
	cfg.icon = display.newSprite(info.icon)
			:pos(0, 0)
			:addTo(cfg.contain)
	local sz = cfg.icon:getContentSize();

	cfg.txt = ui.newTTFLabelWithOutline({
			text = info.txt,
			color = styles.FONT_COLOR.GOLDEN_TEXT,
			size = 22,
			align = ui.TEXT_ALIGN_CENTER,
		})
		:pos(0, -sz.height*0.5 - 5)
		:addTo(cfg.contain)
	
	cfg.contain:setScale(scaleVal);

	return cfg;
end

function BoxRewardAnimation:show()
	nk.PopupManager:addPopup(self);
	self:performWithDelay(handler(self, self.playAnimation_), 0.2)
	return self;
end

function BoxRewardAnimation:showed()
end

function BoxRewardAnimation:hide()
	nk.PopupManager:removePopup(self);
	return self;
end

function BoxRewardAnimation:onCleanup()
    display.removeSpriteFramesWithFile("upgrade_texture.plist", "upgrade_texture.png")
end

function BoxRewardAnimation:onRemovePopup(func)
	if self.step_ ~= 1 then
		self.step_ = 2;
		return;
	end
	self.step_ = 2;
	local cfg;
	local px, py;
	local ts = 0.2;
	self.index_ = 1;
	for i=1,#self.cfgs_ do
		cfg = self.cfgs_[i];
		if cfg then
			local rect1 = self:getTargetPosByType(cfg.data)
			local rect2 = self.boxSpr_:convertToNodeSpace(cc.p(rect1.x, rect1.y))
			px = rect2.x;
			py = rect2.y;
			cfg.contain:runAction(transition.sequence({
				cc.ScaleTo:create(ts, 0.3),
				cc.RotateBy:create(ts, 360),
				cc.MoveTo:create(ts, cc.p(px, py)),
				cc.DelayTime:create(ts),
				cc.CallFunc:create(function(obj)
					local info = self.cfgs_[self.index_]
					if info then
						info.contain:hide();
						info.contain:stopAllActions();
						local rt = self:getTargetPosByType(cfg.data)
						local lblSz
						if self.sceneview_ == "MainHallView" then
							lblSz = 32;
							bm.EventCenter:dispatchEvent({name="Play_ChipChangeAnimation"})
							bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="Wheel_end"})
						else
							app:tip(info.data.type, info.data.val, rt.x, rt.y+20, 9999, 0, lblSz)
						end
						self.index_ = self.index_ + 1;
					end
				end)
			}))

			ts = ts + 0.05
		end
	end

	self.closeBg_:hide();
	transition.fadeOut(self.openBg_, {time=ts, delay=0.0})
    transition.fadeOut(self, {time=2.0, onComplete = function()
    	self:stopAllActions_();
    	bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="end"})
    	if func then
			func();
			func = nil;
		end
    end})
end

function BoxRewardAnimation:stopAllActions_()
	for i=1,#self.cfgs_ do
		cfg = self.cfgs_[i];
		if cfg then
			cfg.contain:stopAllActions();
		end
	end
end

-- 根据type获取目标坐标 (比赛场大厅 type 1:筹码 2:比赛券 3:现金币 4:金券 其他为玩家头像)
function BoxRewardAnimation:getTargetPosByType(info)
	if not info or not self.iconPosFunc_ then
		-- 设置玩家座位
		local pt = cc.p(RoomViewPosition.SeatPosition[5].x, RoomViewPosition.SeatPosition[5].y)
		pt.y = pt.y + 38;
		return pt;
	else
		return self.iconPosFunc_(info.type);
	end
end

return BoxRewardAnimation;