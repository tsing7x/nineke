--
-- Author: Jonah0608@gmail.com
-- Date: 2016-07-18 10:35:05
--
local action
local timeStr

local Clock = class("Clock",function()
    return display.newNode()
end)

function Clock:ctor()
    self:setupView()
end

function Clock:setupView()
    self.clock_bg = display.newSprite("#clock_bg.png"):addTo(self)
    self.clock_front = display.newSprite("#clock_front.png"):addTo(self):pos(0,-2)
    self.clocklabel_ = ui.newTTFLabel({text = "",font="font/clock.fnt", color = cc.c3b(236, 142, 67), size = 20, align = ui.TEXT_ALIGN_CENTER})
        :pos(0, 2)
        :addTo(self)
end

function Clock:startCountDown(countdown,timeoutcallback)
    self.countdown_ = countdown
    self.timeoutcallback_ = timeoutcallback
    self.clocklabel_:setString(tostring(self.countdown_) or "")
    if action then 
        self:stopAction(action)
    end
    action = self:schedule(function()
        self:countFunc()
        end,1)
end

function Clock:stop()
    if action then
        self:stopAction(action)
        action = nil
        self.clock_front:stopAllActions()
        self.clock_front:setRotation(0)
    end
end

function Clock:countFunc()
    self.countdown_ = self.countdown_ - 1
    self:showTime()
    if self.countdown_ <=0 then
        self:stop()
        self.isBlink = false
        if self.timeoutcallback_ then
            self.timeoutcallback_()
        end
    end
end

function Clock:showTime()
    timeStr = self.countdown_ >= 0 and tostring(self.countdown_) or ""
    if self.clocklabel_ then
        self.clocklabel_:setString(timeStr)
    end
end

function Clock:startShake()
    if self.isshake_ then
        return
    else
        self.isshake_ = true
        self:shakeWarn()
    end
end

function Clock:stopShake()
    self.isshake_ = false
    self.clock_front:stopAllActions()
end

function Clock:shakeWarn()
    self.clock_front:runAction(cc.RepeatForever:create(
        cc.Sequence:create(cc.RotateTo:create(0.1,10),cc.RotateTo:create(0.1,-10))))
end

return Clock