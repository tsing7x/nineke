--
-- Author: HLF
-- Date: 2015-09-21 15:00:02
--
--[[
local dt = {};
table.insert(dt, #dt+1, "Testing1.......");
table.insert(dt, #dt+1, "Testing2.......");
self.index_ = 2;
self.queue_ = AnimUpScrollQueue.new(cc.size(360, 46), 32, cc.c3b(255, 0, 0), ui.TEXT_ALIGN_CENTER):addTo(self);
self.queue_:pos(display.cx, display.cy - 100);
self.queue_:setData(dt);
self.queue_:setMaxSize(3)
self.queue_:startAnim();
self:addOnClick(self.queue_, handler(self, self.onClick_))
]]

local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

local AnimUpScrollQueue = class("AnimUpScrollQueue", function()
	return display.newNode();
end)

local LABEL_X_GAP = 0;
local MAX_SIZE = 10;

function AnimUpScrollQueue:ctor(contentSize, lblSize, color, align, offx, offy)
	self.index_ = 1;
	self.isPlay_ = false;
	self.isAction_ = false;
	self.size_ = MAX_SIZE;
	-- 
	self.contentSize_ = contentSize;
	self.lblSize_ = lblSize or 16;
	self.color_ = color or cc.c3b(255, 255, 255);
	self.align_ = align or ui.TEXT_ALIGN_CENTER;
	self.offx_ = offx or 0;
	self.offy_ = offy or 0;
	self.clipNode_ = cc.ClippingNode:create():addTo(self);
	self.stencil_ = display.newDrawNode();
	self.stencil_:drawPolygon({
		{-contentSize.width * 0.5 + LABEL_X_GAP, -contentSize.height * 0.5}, 
        {-contentSize.width * 0.5 + LABEL_X_GAP,  contentSize.height * 0.5}, 
        { contentSize.width * 0.5 - LABEL_X_GAP,  contentSize.height * 0.5}, 
        { contentSize.width * 0.5 - LABEL_X_GAP, -contentSize.height * 0.5}
	});
	self.clipNode_:setStencil(self.stencil_);

	-- self.bg_ = display.newScale9Sprite("#sm_bottom_float_bg.png", 0, 0, cc.size(contentSize.width, contentSize.height)):addTo(self.clipNode_);
	-- -- 
	self.lbl1_ = ui.newTTFLabel({
		text = "",
		color = self.color_,
		size = self.lblSize_,
		align = self.align_,
		dimensions=cc.size(contentSize.width, 0)
	})
	:pos(self.offx_, self.offy_)
	:addTo(self.clipNode_);
	-- 
	self.lbl2_ = ui.newTTFLabel({
		text = "",
		color = self.color_,
		size = self.lblSize_,
		align = self.align_,
		dimensions=cc.size(contentSize.width, 0)
	})
	:pos(self.offx_, self.offy_)
	:addTo(self.clipNode_);
end

-- 设置队列
function AnimUpScrollQueue:setData(values)
	self.data_ = values;
	return self;
end
-- 添加一条新记录
function AnimUpScrollQueue:addMsg(msg)
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
function AnimUpScrollQueue:setMaxSize(value)
	self.size_ = value or 1;
	if self.size_ < 1 then
		self.size_ = 1;
	end

	return self;
end
-- 开始播放动画
function AnimUpScrollQueue:startAnim()
	self.isPlay_ = true;
	if not self.isAction_ then
		self:playerNext_();
	end
	return self;
end
-- 停止播放动画
function AnimUpScrollQueue:stopAnim()
	self.isPlay_ = false;
end
-- 
function AnimUpScrollQueue:playerNext_()
	if nil == self.data_ or 0 == #self.data_ then
		return;
	end

	self.isAction_ = true;
	-- 把最后一条滚出显示区域
	local offY = self.contentSize_.height;
	if self.lastLbl_ then
		self.lastLbl_:runAction(transition.sequence({
			cc.Spawn:create(
                cc.MoveTo:create(0.5, cc.p(self.offx_, offY)),
                cc.FadeOut:create(0.5)
            )
		}));
	end

	local lbl = self:getIdleLbl();
	lbl:setString(self.data_[self.index_]);
	lbl:pos(self.offx_, -offY);
	lbl:runAction(transition.sequence({
		cc.Spawn:create(
            cc.MoveTo:create(0.5, cc.p(self.offx_, self.offy_)),
            cc.FadeIn:create(0.8)
        ),
		cc.DelayTime:create(3.0),
		cc.CallFunc:create(handler(self, self.callbackPlayerNext_))
	}));

	self.index_ = self.index_+1;
	if self.index_ > self.size_ or self.index_ > #self.data_ then
		self.index_ = 1;
	end
end

function AnimUpScrollQueue:callbackPlayerNext_()
	self.isAction_ = false;
	if self.isPlay_ then
		self.lbl1_:setOpacity(255);
		self.lbl2_:setOpacity(255);
		self.lastLbl_ = self:getIdleLbl();
		self.lastLbl_:pos(self.offx_, self.offy_)
		self:playerNext_();
	end
end

function AnimUpScrollQueue:getIdleLbl()
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

return AnimUpScrollQueue;