--
-- Author: HLF(IdaHuang@boyaa.com)
-- Date: 2016-07-04 15:53:23
--
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

local TextureLoader = class("TextureLoader")

-- resList 数据结构：{{***.plist, ***.png}, {***.plist, ***.png}}
-- callback 回调函数
function TextureLoader:ctor(resList, callback, delayTime, callbackDelayTime)
	self.resList_ = resList or {}
	self.callback_ = callback
	self.delayTime_ = delayTime or -1
	self.callbackDelayTime_ = callbackDelayTime or -1
	self.index_ = 1

	self:loadnext_()
end

function TextureLoader:loadnext_()
	self:cleanScheduleId_()
	if self.index_ > #self.resList_ then
		if self.callbackDelayTime_ > 0 then
			self.handle_ = scheduler.performWithDelayGlobal(handler(self, self.excuteCallback_), self.callbackDelayTime_)
		else
			self:excuteCallback_()
		end		
	else
		local arr = self.resList_[self.index_]
		if self.index_ > 1 and self.delayTime_ > 0  then
		    self.handle_ = scheduler.performWithDelayGlobal(function()
		        display.addSpriteFrames(arr[1], arr[2], handler(self, self.loadnext_))
		    end, self.delayTime_)
		else
			display.addSpriteFrames(arr[1], arr[2], handler(self, self.loadnext_))
		end
		self.index_ = self.index_ + 1
	end
end

function TextureLoader:excuteCallback_()
	if self.callback_ then
		self.callback_()
	end
	self:cleanScheduleId_()
end

function TextureLoader:cleanScheduleId_()
	if self.handle_ then
		scheduler.unscheduleGlobal(self.handle_)
		self.handle_ = nil
	end
end

return TextureLoader