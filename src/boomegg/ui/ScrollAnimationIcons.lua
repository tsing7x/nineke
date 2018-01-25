--
-- Author: HLF(IdaHuang@boyaa.com)
-- Date: 2016-01-26 19:53:18
--
local BubbleButton = import(".BubbleButton")

local ScrollAnimationIcons = class("ScrollAnimationIcons", function()
	return display.newNode();
end);

ScrollAnimationIcons.EVENT_GOTO_FINISH = "EVENT_GOTO_FINISH";
ScrollAnimationIcons.EVENT_BACK_FINISH = "EVENT_BACK_FINISH";
ScrollAnimationIcons.EVENT_GOTO_CLICK = "EVENT_GOTO_CLICK";
ScrollAnimationIcons.EVENT_BACK_CLICK = "EVENT_BACK_CLICK";

ScrollAnimationIcons.DIRECTION_VERTICAL   = 1
ScrollAnimationIcons.DIRECTION_HORIZONTAL = 2
local unitTS = 0.11;
local rotationVal = 90*1;
local unitRotationVal = 360*1.0;

function ScrollAnimationIcons:ctor(resList, gotoResId, backResId, direction, gap)
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods();
	self.resList_ = resList;
	self.gotoResId_ = gotoResId;
	self.backResId_ = backResId;
	self.gap_ = gap or 0;
	self.direction_ = direction or ScrollAnimationIcons.DIRECTION_HORIZONTAL;
	self:init_();
end

function ScrollAnimationIcons:init_()
	if not self.resList_ or #self.resList_ == 0 then
		return;
	end
	-- 
	local sz;
	local resId;
	local px = 0;
	local py = 0;
	local len = #self.resList_; 
	local icon;
	self.iconList_ = {}
	for i=1,len do
		resId = self.resList_[i];
		-- 
		icon = BubbleButton.createCommonBtn({
            iconNormalResId=resId.iconNormal,
            iconOverResId=resId.iconOver,
            btnNormalResId=resId.btnNormal,
            btnOverResId=resId.btnOver,
            iconScale=resId.iconScale,
            btnScale=resId.btnScale,
            isBtnScale9=resId.isBtnScale9 or false,
            ix=resId.ix or 0,
            iy=resId.iy or 0,
            parent=self,
            parentIndex=3,
            x=0,
            y=0,
            scaleVal=resId.bgScalVal or 0.96,
            onClick=resId.onClick,
        })
        -- 
		px = px - self.gap_;
		py = py + self.gap_;
		-- 
		if self.direction_  == ScrollAnimationIcons.DIRECTION_VERTICAL then
			icon:pos(0, py)
		else
			icon:pos(px, 0)
		end
		icon:hide();
		table.insert(self.iconList_, {icon=icon,px=px,py=py});
	end
	-- 
	self.gotoBtn_ = BubbleButton.createCommonBtn({
            iconNormalResId=self.gotoResId_.iconNormal,
            iconOverResId=self.gotoResId_.iconOver,
            btnNormalResId=self.gotoResId_.btnNormal,
            btnOverResId=self.gotoResId_.btnOver,
            isBtnScale9=self.gotoResId_.isBtnScale9 or false,
            parent=self,
            parentIndex=2,
            x=0,
            y=0,
            onClick=buttontHandler(self, self.onGotoBtnClickHandler_),
        })
	-- 
	self.backBtn_ = BubbleButton.createCommonBtn({
            iconNormalResId=self.backResId_.iconNormal,
            iconOverResId=self.backResId_.iconOver,
            btnNormalResId=self.backResId_.btnNormal,
            btnOverResId=self.backResId_.btnOver,
            isBtnScale9=self.gotoResId_.isBtnScale9 or false,
            parent=self,
            parentIndex=2,
            x=0,
            y=0,
            onClick=buttontHandler(self, self.onBackBtnClickHandler_),
        })
	self.backBtn_:hide();
	-- 
	self.status_ = true;
	self.isPlay = false;
end

function ScrollAnimationIcons:onGotoBtnClickHandler_(target, evtName, ...)
	self:dispatchEvent({name=ScrollAnimationIcons.EVENT_GOTO_CLICK});
	self:play();
end

function ScrollAnimationIcons:onBackBtnClickHandler_(target, evtName, ...)
	self:dispatchEvent({name=ScrollAnimationIcons.EVENT_BACK_CLICK});
		self:play();
end

function ScrollAnimationIcons:play(callback)
	if self.isPlay then
		return;
	end
	self.isPlay = true;
	self.playCallback_ = callback;
	if self.status_ then
		self:goto();
	else
		self:back();		
	end
	self.status_ = not self.status_;
end
-- 滚出
function ScrollAnimationIcons:goto()
	local len = #self.iconList_;
	local item = self.iconList_[len];
	local icon = item.icon;
	local animTS = len * unitTS;
	local px = item.px;
	local py = item.py;
	self.gotoBtn_:hide();
	self.backBtn_:show();
	self.backBtn_:runAction(transition.sequence({
		cc.RotateBy:create(animTS, -rotationVal)
	}));
	-- 
	self.cloneIconList_ = clone(self.iconList_);
	self:addEnterFrameEvent();
	icon:show();
	if self.direction_  == ScrollAnimationIcons.DIRECTION_VERTICAL then
		icon:setPositionY(0)
		icon:runAction(transition.sequence({
			cc.Spawn:create(
	            cc.MoveTo:create(animTS, cc.p(0, py)),
	            cc.RotateBy:create(animTS, -unitRotationVal*len)
	        ),
			cc.CallFunc:create(handler(self, self.onGotoCallBack_))
		}));
	else
		icon:setPositionX(0)
		icon:runAction(transition.sequence({
			cc.Spawn:create(
	            cc.MoveTo:create(animTS, cc.p(px, 0)),
	            cc.RotateBy:create(animTS, -unitRotationVal*len)
	        ),
			cc.CallFunc:create(handler(self, self.onGotoCallBack_))
		}));
	end	
end
-- 
function ScrollAnimationIcons:onGotoCallBack_()
	self:dispatchEvent({name=ScrollAnimationIcons.EVENT_GOTO_FINISH})
	self:onCallback_();
end
-- 滚入
function ScrollAnimationIcons:back()
	local len = #self.iconList_;
	local item = self.iconList_[len];
	local icon = item.icon;
	local animTS = len * unitTS;
	local px = 0;
	local py = 0;
	self.gotoBtn_:hide();
	self.backBtn_:show();
	self.backBtn_:runAction(transition.sequence({
		cc.RotateBy:create(animTS, rotationVal)
	}));
	-- 
	self.cloneIconList_ = clone(self.iconList_);
	self:addEnterFrameEvent();
	
	-- 
	if self.direction_  == ScrollAnimationIcons.DIRECTION_VERTICAL then
		icon:runAction(transition.sequence({
			cc.Spawn:create(
	            cc.MoveTo:create(animTS, cc.p(0, py)),
	            cc.RotateBy:create(animTS, unitRotationVal*len)
	        ),
			cc.CallFunc:create(handler(self, self.onBackCallback_))
		}));
	else
		icon:runAction(transition.sequence({
			cc.Spawn:create(
	            cc.MoveTo:create(animTS, cc.p(px, 0)),
	            cc.RotateBy:create(animTS, unitRotationVal*len)
	        ),
			cc.CallFunc:create(handler(self, self.onBackCallback_))
		}));
	end
	-- print("icon:isHide()-->"..tostring(icon:isVisible()))
end
-- 
function ScrollAnimationIcons:onBackCallback_()
	self:dispatchEvent({name=ScrollAnimationIcons.EVENT_BACK_FINISH});
	self:onCallback_();
	self.iconList_[#self.iconList_].icon:hide();
	self.gotoBtn_:show();
	self.backBtn_:hide();
end

function ScrollAnimationIcons:onCallback_()
	self:removeEnterFrameEvent();
	self.isPlay = false;
	-- 
	if self.playCallback_ then
		self.playCallback_();
		self.playCallback_ = nil;
	end
end

function ScrollAnimationIcons:onEnterFrame_(dt)
	local item;
	local len = #self.cloneIconList_;
	local px,py = self.cloneIconList_[len].icon:getPosition();
	if self.status_ then
		for i=1,len-1 do
			item = self.cloneIconList_[i];
			-- 
			if self.direction_  == ScrollAnimationIcons.DIRECTION_VERTICAL then
				if py < item.py then
					table.remove(self.cloneIconList_, i)
					item.icon:hide();
					break;
				end
			else
				if px > item.px then
					table.remove(self.cloneIconList_, i)
					item.icon:hide();
					break;
				end
			end
		end
	else
		for i=1,len-1 do
			item = self.cloneIconList_[i];
			-- 
			if self.direction_  == ScrollAnimationIcons.DIRECTION_VERTICAL then
				if py > item.py then
					table.remove(self.cloneIconList_, i)
					item.icon:show();
					break;
				end
			else
				if px < item.px then
					table.remove(self.cloneIconList_, i)
					item.icon:show();
					break;
				end
			end
		end
	end
end

function ScrollAnimationIcons:addEnterFrameEvent()
	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.onEnterFrame_))
	self:scheduleUpdate()
end

function ScrollAnimationIcons:removeEnterFrameEvent()
	self:removeNodeEventListenersByEvent(cc.NODE_ENTER_FRAME_EVENT)
	self:unscheduleUpdate()
end

function ScrollAnimationIcons:onCleanup()
	self:removeEnterFrameEvent();
end

return ScrollAnimationIcons;