--
-- Author: Jonah0608@gmail.com
-- Date: 2016-09-02 15:03:36
--
local action
local timeStr

local DiceClock = class("DiceClock",function()
    return display.newNode()
end)

function DiceClock:ctor()
    self:setupView()
end

function DiceClock:setupView()
    self.clock_left = display.newSprite("#dice_clock_right.png"):addTo(self):pos(-8,7)
    self.clock_left:setScaleX(-1)
    self.clock_left:setAnchorPoint(cc.p(0,0))
    self.clock_right = display.newSprite("#dice_clock_right.png"):addTo(self):pos(8,7)
    self.clock_right:setAnchorPoint(cc.p(0,0))
    self.clock_front = display.newSprite("#dice_clock_main.png"):addTo(self)
    self.clocklabel_ = ui.newTTFLabel({text = "", size = 20, align = ui.TEXT_ALIGN_CENTER})
        :pos(0, 0)
        :addTo(self)
end

function DiceClock:startCountDown(countdown,timeoutcallback)
    self.countdown_ = countdown
    self.timeoutcallback_ = timeoutcallback
    self.clocklabel_:setString(tostring(self.countdown_) or "")
    if action then 
        self:stopAction(action)
    end
    self:startShake()
    action = self:schedule(function()
        self:countFunc()
        end,1)
end

function DiceClock:stop()
    if action then
        self:stopAction(action)
        action = nil
        self.isshake_ = false
        self.isshakefast_ = false
        self.clock_left:stopAllActions()
        self.clock_left:setRotation(0)
        self.clock_right:stopAllActions()
        self.clock_right:setRotation(0)
    end
end

function DiceClock:countFunc()
    self.countdown_ = self.countdown_ - 1
    self:showTime()
    if self.countdown_ <= 7 and not self.isshakefast_ then
        self:stopShake()
        self:startShake(true)
    end
    if self.countdown_ <=0 then
        nk.SoundManager:playSound(nk.SoundManager.DICE_CLOCK)
        self:stop()
        self.isBlink = false
        if self.timeoutcallback_ then
            self.timeoutcallback_()
        end
    end
end

function DiceClock:showTime()
    timeStr = self.countdown_ >= 0 and tostring(self.countdown_) or ""
    if self.clocklabel_ then
        self.clocklabel_:setString(timeStr)
    end
end

function DiceClock:startShake(fast)
    if self.isshake_ then
        return
    else
        self.isshake_ = true
        if fast then
            self.isshakefast_ = true
        end
    end
end

function DiceClock:stopShake()
    self.isshake_ = false
    self.clock_left:stopAllActions()
    self.clock_right:stopAllActions()
end

return DiceClock