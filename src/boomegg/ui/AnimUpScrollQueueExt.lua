--
-- Author: HLF
-- Date: 2015-09-21 15:00:02
--
--[[
local dt = {};
table.insert(dt, #dt+1, "Testing1.......");
table.insert(dt, #dt+1, "Testing2.......");
table.insert(dt, #dt+1, "Testing3.......");
table.insert(dt, #dt+1, "Testing4.......");
table.insert(dt, #dt+1, "Testing5.......");
self.index_ = 2;
local params = {}
params.lineCnt = 3;
params.contentSize = cc.size(360, 32*3);
params.lblSize = 22;
params.color = cc.c3b(255, 0, 0);
params.align = ui.TEXT_ALIGN_LEFT;
params.offx = 10;
params.offy = 0;
self.queue_ = AnimUpScrollQueueExt.new(params):addTo(self);
self.queue_:pos(display.cx, display.cy - 100);
self.queue_:setData(dt);
self.queue_:setMaxSize(10)
self.queue_:startAnim();
self:addOnClick(self.queue_, handler(self, self.onClick_))
]]

local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

local AnimUpScrollQueueExt = class("AnimUpScrollQueueExt", function()
	return display.newNode();
end)

local LABEL_X_GAP = 0;
local MAX_SIZE = 10;

function AnimUpScrollQueueExt:ctor(params)
	self.index_ = 1;
	self.lblIdx_ = 1;
	self.isPlay_ = false;
	self.isAction_ = false;
	self.size_ = MAX_SIZE;
	--
	self.lineCnt_ = params.lineCnt or 1;
	if self.lineCnt_ < 1 then
		self.lineCnt_ = 1;
	end
	-- 
	self.contentSize_ = params.contentSize;
	self.lblSize_ = params.lblSize or 16;
	self.color_ = params.color or cc.c3b(255, 255, 255);
	self.align_ = params.align or ui.TEXT_ALIGN_CENTER;
	self.offx_ = params.offx or 0;
	self.offy_ = params.offy or 0;
	self.delayTs_ = params.delayTs or 3.0;
	-- 
	self.unitDH_ = self.contentSize_.height/self.lineCnt_;
	self.topY_ = self.contentSize_.height*0.5;
	self.centy_ = self.contentSize_.height * 0.5;
	self.queue_ = {}
	-- 
	self.clipNode_ = cc.ClippingNode:create():addTo(self);
	self.stencil_ = display.newDrawNode();
	self.stencil_:drawPolygon({
		{-self.contentSize_.width * 0.5 + LABEL_X_GAP, -self.contentSize_.height * 0.5}, 
        {-self.contentSize_.width * 0.5 + LABEL_X_GAP,  self.contentSize_.height * 0.5}, 
        { self.contentSize_.width * 0.5 - LABEL_X_GAP,  self.contentSize_.height * 0.5}, 
        { self.contentSize_.width * 0.5 - LABEL_X_GAP, -self.contentSize_.height * 0.5}
	});
	self.clipNode_:setStencil(self.stencil_);
	-- 
	-- self.bg_ = display.newScale9Sprite("bg.png", 0, 0, cc.size(self.contentSize_.width, self.contentSize_.height)):addTo(self.clipNode_);
	-- -- 
	self.lbls_ = {};
	self.offy_ = self.unitDH_*0.5;
	local dh = self.contentSize_.height/self.lineCnt_;
	local py = self.contentSize_.height*0.5;
	for i=1,self.lineCnt_+1 do
		local lbl = ui.newTTFLabel({
			text = "",--"lbl"..i.."....",
			color = self.color_,
			size = self.lblSize_,
			align = self.align_,
			dimensions=cc.size(self.contentSize_.width, 0)
		})
		:addTo(self.clipNode_);
		local sz = lbl:getContentSize();
		lbl:pos(0, self.centy_+self.offy_-self.unitDH_*i);
		py = py - dh;

		table.insert(self.lbls_, #self.lbls_+1, lbl);
	end
end

-- 设置队列
function AnimUpScrollQueueExt:setData(values)
	self.data_ = values;
	return self;
end
-- 添加一条新记录
function AnimUpScrollQueueExt:addMsg(msg)
	if nil == self.data_ then
		self.data_ = {};
	else
		if #self.data_ >= self.size_ then
			table.remove(self.data_, 1);
			self.index_ = self.index_ - 1;
			if self.index_ < 1 then
				self.index_ = 1;
			end
		end
	end
	-- 
	table.insert(self.data_, #self.data_+1, msg);
end

-- 设置队列大小
function AnimUpScrollQueueExt:setMaxSize(value)
	self.size_ = value or 1;
	if self.size_ < 1 then
		self.size_ = 1;
	end

	return self;
end
-- 开始播放动画
function AnimUpScrollQueueExt:startAnim()
	self.isPlay_ = true;
	if not self.isAction_ then
		self:playerNext_();
	end
	return self;
end
-- 停止播放动画
function AnimUpScrollQueueExt:stopAnim()
	self.isPlay_ = false;
end
-- 
function AnimUpScrollQueueExt:playerNext_()
	if nil == self.data_ or 0 == #self.data_ then
		return;
	end

	self.isAction_ = true;
	-- 把最后一条滚出显示区域 self.centy_+self.offy_-self.unitDH_*i
	local lbl;
	if #self.queue_ >= self.lineCnt_ then
		lbl = table.remove(self.queue_, 1);
		lbl:runAction(transition.sequence({
			cc.Spawn:create(
                cc.MoveTo:create(0.5, cc.p(0, self.centy_ + self.offy_ * 1)),
                cc.FadeOut:create(0.5)
            )
		}));
	end
	--
	local py;
	local len = #self.queue_;
	-- print("len::"..len)
	for i=1,len do
		lbl = self.queue_[i];
		py = self.centy_ + self.offy_ - self.unitDH_ * (i + (self.lineCnt_ - len - 1));
		transition.moveTo(lbl, {time=0.5, y=py});-- transition.moveBy(self.label_, {time=0.5, easing="OUT", y=72, onComplete=function() end})
	end
	-- 
	lbl = self.lbls_[self.lblIdx_];
	lbl:setString(self.data_[self.index_]);
	table.insert(self.queue_, #self.queue_ + 1, lbl);
	-- 
	py = self.centy_ + self.offy_ - self.unitDH_ * (self.lineCnt_ + 1);
	lbl:pos(0, py)
	py = self.centy_ + self.offy_ - self.unitDH_ * (self.lineCnt_ + 0);
	lbl:runAction(transition.sequence({
		cc.Spawn:create(
            cc.MoveTo:create(0.5, cc.p(0, py)),
            cc.FadeIn:create(0.8)
        ),
		cc.DelayTime:create(self.delayTs_),
		cc.CallFunc:create(handler(self, self.callbackPlayerNext_))
	}));
	-- 
	
	self.lblIdx_ = (self.lblIdx_)%#self.lbls_ + 1;
	-- 
	self.index_ = self.index_+1;
	if self.index_ > self.size_ or self.index_ > #self.data_ then
		self.index_ = 1;
	end
end

function AnimUpScrollQueueExt:callbackPlayerNext_()
	self.isAction_ = false;
	if self.isPlay_ then
		local lbl;
		for i=1,#self.lbls_ do
			lbl = self.lbls_[i];
			lbl:setOpacity(255);
		end
		self:playerNext_();
	end
end

function AnimUpScrollQueueExt:getIdleLbl()
	if nil == self.lastLbl_ then
		return self.lbl1_;
	end
	-- 
	if self.lastLbl_ == self.lbl1_ then
		return self.lbl2_;
	else
		return self.lbl1_;
	end
end

return AnimUpScrollQueueExt;