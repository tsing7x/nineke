--
-- Author: hlf
-- Date: 2015-11-04 14:12:29
-- 比赛场图标

local DailyMatchListPopup = import("app.module.match.dailyMatch.DailyMatchListPopup");
local DailyMatchEndPopup = import("app.module.match.dailyMatch.DailyMatchEndPopup");
local BoxRewardAnimation = import("app.module.match.dailyMatch.BoxRewardAnimation")
local DailyMatchRewardPopup = import("app.module.match.dailyMatch.DailyMatchRewardPopup");
local BubbleButton = import("boomegg.ui.BubbleButton");
local DailyMatchLogo = class("DailyMatchLogo", function()
	return display.newNode();
end)

function DailyMatchLogo:ctor(px, py)
	self.px_ = px;
	self.py_ = py;
	self.playStatus_ = false;
	self.isLoading_ = true;
	self:setNodeEventEnabled(true)
	self.contain_ = display.newNode():pos(px, py):addTo(self)
	-- 判断每日任务开关状态
	if nk.userData.task == 0 then
		self.contain_:hide();
	end
	display.addSpriteFrames("dailytasksMatch.plist", "dailytasksMatch.png", handler(self, self.init_))
end

function DailyMatchLogo:init_()
	self.isLoading_ = false;
	self.lightBatchNode_ = display.newBatchNode("dailytasksMatch.png"):addTo(self.contain_, 9999)
    self.lightBatchNode_:pos(0,0)

	self.lightBg_ = display.newSprite("#dailytasksMatch_light.png")
                    :pos(0, 0)
                    :addTo(self.lightBatchNode_)

	self.bubbleBtn_ = BubbleButton.new({
            image = "#dailytasksMatch_egg.png",
            offX = 0,
            offY = 0,
            size = cc.size(30, 30),
            text = "",
            fontSize = 16,
            prepare = handler(self, self.prepare_),
            listener = handler(self, self.onClick_),
        })
		:addTo(self.lightBatchNode_);

	-- 星星坐标
	self.posList_ = {
		{px=0, py=-10},
		{px=-32, py=0},
		{px=32, py=0},
		{px=20, py=26},
		{px=-20, py=-26},
		{px=-20, py=26},
		{px=26, py=-26},
	}
    self.flashs_ = {}
    for i = 1, #self.posList_ do
    	local item = self.posList_[i]
        self.flashs_[i] = display.newSprite("#flash_star.png")
            :pos(item.px, item.py)
            :addTo(self.lightBatchNode_)
    end

    self:visibleStar(false);
    self.lightBg_:hide();

	self:addListener();

	if nk.MatchDailyManager:isDailyReward() then
		self:play_();
	end

	nk.MatchDailyManager:checkSynchData();
	return self;
end

function DailyMatchLogo:addListener()
	-- 更新每日任务列表
	self.synchDailyListId_ = bm.EventCenter:addEventListener(nk.MatchDailyManager.EVENT_SYNCH_DAILYLIST, handler(self, self.onSynchDailyHandler_))
	-- 等待领取奖励
	self.waitDailyRewardId_ = bm.EventCenter:addEventListener(nk.MatchDailyManager.EVENT_WAIT_DAILYREWARD, handler(self,self.onWaitDailyRewardHandler_))	
	-- 打开每日任务弹出框
	self.openDailyRewardId_ = bm.EventCenter:addEventListener(nk.MatchDailyManager.EVENT_OPENDAILYREWARD, handler(self, self.openDailyRewardHandler_))
end

-- 比赛场有已完成未领取触发
function DailyMatchLogo:onWaitDailyRewardHandler_(evt)
	local status = evt.data;
	if status then
		self:playAnimation();
	else
		self:stopAnimation();
	end
end

-- 打开每日任务弹出框
function DailyMatchLogo:openDailyRewardHandler_(evt)
	if evt and evt.data then
		BoxRewardAnimation.new(BoxRewardAnimation.ANIMATION_TYPE2, evt.data, self.iconPosFunc_):show();
	end
end

-- 比赛场每日任务获取成功后
function DailyMatchLogo:onSynchDailyHandler_(evt)
	self:setLoading(false);
	if self.callback_ then
		self.callback_();
	end

	local dailyList = nk.MatchDailyManager:getDailyList();
	if not dailyList or #dailyList == 0 then
		self:openMatchEndPopup_();
		return
	end

	if not self.dailyMatchListId_ and nk.userData.task ~= 0 then
		local dailyList = nk.MatchDailyManager:getDailyList();
		self.dailyMatchListId_ = DailyMatchListPopup.new(dailyList):showAnimation(self.py_, handler(self, self.openMatchEndPopup_), handler(self, self.onDailyListCloseCallback_))
	end
end

-- 关闭每日任务回调
function DailyMatchLogo:onDailyListCloseCallback_()
	self.dailyMatchListId_ = nil;
end

-- 移除监听
function DailyMatchLogo:removeListener()
	if self.synchDailyListId_ then
		bm.EventCenter:removeEventListener(self.synchDailyListId_)
		self.synchDailyListId_ = nil;
	end

	if self.waitDailyRewardId_ then
		bm.EventCenter:removeEventListener(self.waitDailyRewardId_)
		self.waitDailyRewardId_ = nil;
	end

	if self.openDailyRewardId_ then
		bm.EventCenter:removeEventListener(self.openDailyRewardId_)
		self.openDailyRewardId_ = nil;
	end
end

-- 每日任务Logo单击事件
function DailyMatchLogo:onClick_(evt)
	self:setLoading(true)
	nk.MatchDailyManager:synchPhpDailyList();
	-- 统计比赛场每日任务图标点击次数
	local eventId;
	if self.py_ > display.height*0.5 then
		eventId = "match_dailyLogo_hall"
	else
		eventId = "match_dailyLogo_room"
	end

	if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand{command = "event",
                    args = {eventId = eventId}, label = "Click"..tostring(nk.userData.uid)}
    end
end

-- 打开任务完成框
function DailyMatchLogo:openMatchEndPopup_()
	DailyMatchEndPopup.new():show();
end

-- 设置Click回调
function DailyMatchLogo:onButtonClicked(callback)
	self.callback_ = callback;
	return self;
end

function DailyMatchLogo:prepare_()

end

function DailyMatchLogo:play_()
	if not self.playStatus_ then
		self.playStatus_ = true;

		self:visibleStar(true);
	    self.lightBg_:show();

	    self.lightBg_:runAction(cc.RepeatForever:create(transition.sequence({
	    		cc.FadeIn:create(1.2),
	    		cc.FadeOut:create(0.6)
	    	})))

	    -- 添加至舞台开始动画
	    for i = 1, #self.flashs_ do
	        self.flashs_[i]:runAction(cc.RepeatForever:create(
	            transition.sequence({cc.ScaleTo:create(0, 0.9, 0.9), cc.ScaleTo:create(0.15, 1.1, 1.1), cc.ScaleTo:create(0.15, 0.9, 0.9)})
	        ))
	    end
	end
   	return self;
end

function DailyMatchLogo:stopAnimation()
	if self.playStatus_ then
		self:visibleStar(false);
	    self.lightBg_:hide();
		self.lightBg_:stopAllActions()
		for i=1,4 do
	        self.flashs_[i]:stopAllActions();
	    end

	    self.playStatus_ = false;
	end
	return false;
end

-- 播放动画
function DailyMatchLogo:playAnimation()
	if not self.isLoading_ then
		self:play_();
	end
	return self;
end

function DailyMatchLogo:visibleStar(value)
	for i=1,#self.flashs_ do
		if value then
			self.flashs_[i]:show();
		else
			self.flashs_[i]:hide();
		end
	end
end

-- 图标的位置
function DailyMatchLogo:setIconPosFunc(func)
	self.iconPosFunc_ = func
end

function DailyMatchLogo:onCleanup()
    self:stopAnimation();
    self:removeListener();
end

function DailyMatchLogo:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
        	local currentScene = display.getRunningScene()
            self.juhua_ = nk.ui.Juhua.new()
                :addTo(currentScene, 999, 999)
                :pos(self.px_, self.py_)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

return DailyMatchLogo;