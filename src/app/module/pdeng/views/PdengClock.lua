
local action
local progress_action

local PdengClock = class("PdengClock",function()
    return display.newNode()
end)

function PdengClock:ctor()
    self:setupView()
end

function PdengClock:setupView()
    local bg = display.newScale9Sprite("#pdeng_room_count_down_bg.png", 0, 0, cc.size(320, 73), cc.rect(55, 0, 1, 1))
        :addTo(self)
    
    self.timeProgBar_ = nk.ui.ProgressBar.new(
            "#pdeng_room_count_down_progress_bg.png",
            "#pdeng_room_count_down_progress_fg.png",
            {
                bgWidth = 300,
                bgHeight = 20,
                fillWidth = 24,
                fillHeight = 16
            }
        )
        :pos(-160, -12)
        :addTo(self)
        :setValue(1)
    self.clock_ = display.newSprite("#pdeng_room_clock.png"):addTo(self):pos(-150, 0)
    self.clocklabel_ = ui.newTTFLabel({text = "", size = 20, align = ui.TEXT_ALIGN_CENTER})
        :pos(0, 12)
        :addTo(self)
end

function PdengClock:startCountDown(countdown, tips, timeoutcallback)
    self.countdown_ = countdown
    self.origCountDown = countdown
    self.progCountDown = countdown
    self.timeoutcallback_ = timeoutcallback
    self.clocklabel_:setString(tostring(tips) or "")
    if action then 
        self:stopAction(action)
    end
    self:startShake()
    action = self:schedule(function()
        self:countFunc()
        end,1)

    if progress_action then 
        self:stopAction(progress_action)
    end
    progress_action = self:schedule(function()
        self:countFunc2()
        end, 0.03)
end

function PdengClock:stop()
    if action then
        self:stopAction(action)
        action = nil
        -- self:stopAllActions()
        -- self:setRotation(0)
        self.isshake_ = false
        self.isshakefast_ = false
        -- self.clock_:stopAllActions()
        -- self.clock_:setRotation(0)
    end
    if progress_action then
        self:stopAction(progress_action)
        progress_action = nil
    end
end

function PdengClock:countFunc()
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

function PdengClock:countFunc2()
    self.progCountDown = self.progCountDown - 0.03
    if self.timeProgBar_ then
        self.timeProgBar_:setValue(self.progCountDown / self.origCountDown)
    end
end

function PdengClock:showTime()
    local timeStr = self.countdown_ >= 0 and tostring(self.countdown_) or ""
    -- if self.clocklabel_ then
    --     self.clocklabel_:setString(timeStr)
    -- end
end

function PdengClock:startShake(fast)
    if self.isshake_ then
        return
    else
        self.isshake_ = true
        if fast then
            self.isshakefast_ = true
            self:shakeWarnFast()
        else
            self:shakeWarn()
        end
    end
end

function PdengClock:stopShake()
    self.isshake_ = false
    -- self.clock_:stopAllActions()
end

function PdengClock:shakeWarn()

end

function PdengClock:shakeWarnFast()

end

return PdengClock