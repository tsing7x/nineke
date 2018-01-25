-- 计算必须数据
local timerCountdown    = 0 -- 倒计时秒数
local angularVelocity   = 0 -- 角速度
local colorVelocity     = 0 -- 颜色变换速度
local totalFrames       = 0
local RADIUS = 0 --旋转半径

local function setCountdown(second)
    if second == timerCountdown then return end
    -- 设置countdown，计算角速度
    timerCountdown = second

    totalFrames = math.round(second / cc.Director:getInstance():getAnimationInterval())
    percentVelocity = 100 / totalFrames --每帧进度变化

    angularVelocity = 360.0 / totalFrames -- 得到旋转的角速度
end

local ClockProgressTimer = class("ClockProgressTimer", function()
    return display.newNode()
end)

function ClockProgressTimer:ctor(countdown)
    -- 打开node event
    self:setNodeEventEnabled(true)

    -- 根据countdown计算必须数据
    setCountdown(countdown)

    -- 添加帧事件
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.onEnterFrame))
end

function ClockProgressTimer:onEnter()
    self.frameCount_ = 0
    self.countStartTime_ = bm.getTime()

    self.percent_ = 0

    self.progress_ = display.newProgressTimer("#room_naozhong_around_light.png", display.PROGRESS_TIMER_RADIAL)
    self.progress_:addTo(self)

    self.progress_:setReverseDirection(true)
    self.progress_:setPercentage(100)

    local size = self.progress_:getContentSize()

    RADIUS = size.width/2 - 2

    self.curAngle_ = -90
    self.light_tail = display.newSprite("#room_naozhong_around_light_tail.png")
        :pos(RADIUS, 0)
        :addTo(self, 2)

    self:scheduleUpdate()
end

function ClockProgressTimer:onEnterFrame(evt, isFastForward)
    self.frameCount_ = self.frameCount_ + 1

    self.percent_ = self.percent_ + percentVelocity
    self.progress_:setPercentage(100 - self.percent_)

    self.curAngle_ = self.curAngle_ + angularVelocity
    local x = RADIUS * math.cos(math.rad(self.curAngle_))
    local y = RADIUS * math.sin(math.rad(self.curAngle_))

    self.light_tail:pos(x, y)

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

return ClockProgressTimer