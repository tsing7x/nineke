--
-- Author: Jonah0608@gmail.com
-- Date: 2016-12-12 18:16:39
--

-- 颜色变换标记
local STOP = 0
local GREEN_TO_YELLOW = 1
local YELLOW_TO_RED   = 2

-- 计算必须数据
local timerCountdown    = 0
local colorVelocity     = 0
local totalFrames       = 0
local percentVelocity   = 0

local function setCountdown(second)
    if second == timerCountdown then return end
    -- 设置countdown，计算线速度与角速度
    timerCountdown = second
    -- 计算颜色变化速率
    colorVelocity = 255 * cc.Director:getInstance():getAnimationInterval() / (timerCountdown * 0.25)
    totalFrames = math.round(second / cc.Director:getInstance():getAnimationInterval())
    percentVelocity = 100 / totalFrames
end

local SeatProgressTimer = class("SeatProgressTimer",function()
    return display.newNode()
end)

function SeatProgressTimer:ctor(countdown)
    self:setNodeEventEnabled(true)
    setCountdown(countdown - 1)
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.onEnterFrame))
end

function SeatProgressTimer:onEnter()
    -- 添加至舞台开始渲染
    self.frameCount_ = 0
    self.countStartTime_ = bm.getTime()
    self.redColor_ = 0
    self.greenColor_ = 255
    self.percent_ = 0

    self.progress_ = display.newProgressTimer("#room_seat_timer_canvas.png",display.PROGRESS_TIMER_RADIAL)
    self.progress_:addTo(self)
    self.progress_:setColor(cc.c3b(self.redColor_,self.greenColor_,0x00))
    self.progress_:setReverseDirection(true)
    self.progress_:setPercentage(100)
    self.percentage_ = 100
    self:scheduleUpdate()
end

function SeatProgressTimer:onEnterFrame(evt, isFastForward)
    self.frameCount_ = self.frameCount_ + 1
    local redColor = self.redColor_
    local greenColor = self.greenColor_

    -- 颜色变换
    if self.percent_ >= 75 then
        if colorPhase == GREEN_TO_YELLOW then -- GREEN_TO_YELLOW phase
            redColor = redColor + colorVelocity
            if redColor >= 255 then
                redColor = 255
                colorPhase = YELLOW_TO_RED
            end
        elseif colorPhase == YELLOW_TO_RED then -- YELLOW_TO_RED phase
            greenColor = greenColor - colorVelocity
            if greenColor <= 0 then
                greenColor = 0
                colorPhase = STOP
            end
        end
    end

    self.percent_ = self.percent_ + percentVelocity
    self.progress_:setPercentage(100 - self.percent_)
    self.redColor_ = redColor
    self.greenColor_ = greenColor
    self.progress_:setColor(cc.c3b(self.redColor_, self.greenColor_, 0))

    if not isFastForward then
        local curFrame = math.round((bm.getTime() - self.countStartTime_) * totalFrames / timerCountdown)
        if curFrame > self.frameCount_ then
            for i = 1, curFrame - self.frameCount_ do
                self:onEnterFrame(nil, true)
                if not self:getParent() then
                    break
                end
            end
        end
    end
end

return SeatProgressTimer