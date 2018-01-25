--
-- Author: Johnny Lee
-- Date: 2014-07-10 17:09:59
--

-- 计时器数据
local TIMER_BORDER_WIDTH     = 116
local TIMER_BORDER_HEIGHT    = 172
local TIMER_BORDER_THICKNESS = 4
local TIMER_CORNER_RADIUS    = 10
local POSITION_OFFSET        = 2

-- 移动区间标志
local STOP                = 0
local TOP_RIGHT           = 1
local TOP_RIGHT_CORNER    = 2
local RIGHT               = 3
local BOTTOM_RIGHT_CORNER = 4
local BOTTOM              = 5
local BOTTOM_LEFT_CORNER  = 6
local LEFT                = 7
local TOP_LEFT_CORNER     = 8
local TOP_LEFT            = 9

-- 转角坐标
local temp1 = TIMER_BORDER_WIDTH * 0.5 - TIMER_CORNER_RADIUS - POSITION_OFFSET
local temp2 = TIMER_BORDER_HEIGHT * 0.5 - TIMER_CORNER_RADIUS - POSITION_OFFSET
local TOP_RIGHT_CORNER_POINT    = cc.p(display.cx + temp1, display.cy + temp2)
local BOTTOM_RIGHT_CORNER_POINT = cc.p(display.cx + temp1, display.cy - temp2)
local BOTTOM_LEFT_CORNER_POINT  = cc.p(display.cx - temp1, display.cy - temp2)
local TOP_LEFT_CORNER_POINT     = cc.p(display.cx - temp1, display.cy + temp2)

-- 颜色变换标记
local GREEN_TO_YELLOW = 1
local YELLOW_TO_RED   = 2

-- 计算必须数据
local timerCountdown        = 0 -- 倒计时秒数
local timerBorderPerimeter  = (TIMER_BORDER_WIDTH - TIMER_CORNER_RADIUS * 2 - TIMER_BORDER_THICKNESS + TIMER_BORDER_HEIGHT - TIMER_CORNER_RADIUS * 2 - TIMER_BORDER_THICKNESS) * 2 + 0.5 * math.pi * TIMER_CORNER_RADIUS * 4 -- 计时器周长
local lineVelocity          = 0 -- 线速度
local angularVelocity       = 0 -- 角速度
local colorVelocity         = 0 -- 颜色变换速度
local totalFrames             = 0

local function setCountdown(second)
    if second == timerCountdown then return end
    -- 设置countdown，计算线速度与角速度
    timerCountdown = second
    lineVelocity = timerBorderPerimeter * cc.Director:getInstance():getAnimationInterval() / timerCountdown -- 周长除以帧数，得到每帧的位移量
    angularVelocity = 90 / (0.5 * math.pi * TIMER_CORNER_RADIUS / lineVelocity); -- 得到每帧的角度偏移量（经过一个90度的角度）
    
    -- 计算颜色变化速率
    colorVelocity = 255 * cc.Director:getInstance():getAnimationInterval() / (timerCountdown * 0.25)
    totalFrames = math.round(second / cc.Director:getInstance():getAnimationInterval())
end

local SeatProgressTimer = class("SeatProgressTimer", function()
    return cc.RenderTexture:create(display.width, display.height)
end)

function SeatProgressTimer:ctor(countdown)
    self.isVisting_ = false

    -- 打开node event
    self:setNodeEventEnabled(true)

    -- 根据countdown计算必须数据
    setCountdown(countdown - 1)

    -- 添加帧事件
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.onEnterFrame))
end

function SeatProgressTimer:onEnter()
    -- 添加至舞台开始渲染
    self.frameCount_ = 0
    self.countStartTime_ = bm.getTime()

    -- 设置当前动画阶段，颜色变化阶段
    self.animationPhrase_ = TOP_RIGHT
    self.colorPhase_      = GREEN_TO_YELLOW

    -- 设置初始颜色
    self.redColor_        = 0
    self.greenColor_      = 255

    -- 创建橡皮擦并retain
    self.erase_ = display.newSprite("room_seat_timer_brush.png")
    self.erase_:retain()
    self.erase_:setBlendFunc(0, 0)
    self.eraseX_ = display.cx
    self.eraseY_ = display.cy + TIMER_BORDER_HEIGHT * 0.5 - POSITION_OFFSET
    self.eraseR_ = 0

    -- 渲染到画布上
    self:clear(0, 0, 0, 0)
    self:begin()
    display.newSprite("room_seat_timer_canvas.png"):pos(display.cx, display.cy):visit()
    self:endToLua()
    self:getSprite():setColor(cc.c3b(self.redColor_, self.greenColor_, 0))
    self:getSprite():getTexture():setAntiAliasTexParameters()

    self:scheduleUpdate()
end

function SeatProgressTimer:onEnterFrame(evt, isFastForward)
    self.frameCount_ = self.frameCount_ + 1

    local tanValue       = 0
    local offsetX        = 0
    local offsetY        = 0
    local eraseX         = self.eraseX_
    local eraseY         = self.eraseY_
    local eraseR         = self.eraseR_
    local redColor       = self.redColor_
    local greenColor     = self.greenColor_
    local colorPhase     = self.colorPhase_
    local animationPhase = self.animationPhrase_

    -- 颜色变换
    if animationPhase >= BOTTOM_RIGHT_CORNER then
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

    -- 位置变换
    if animationPhase == TOP_RIGHT then -- TOP_RIGHT phase
        eraseX = eraseX + lineVelocity
        if eraseX >= TOP_RIGHT_CORNER_POINT.x then
            eraseX = TOP_RIGHT_CORNER_POINT.x
            animationPhase = TOP_RIGHT_CORNER
        end
    elseif animationPhase == TOP_RIGHT_CORNER then -- TOP_RIGHT_CORNER phase
        eraseR = eraseR + angularVelocity
        if eraseR < 90 then
            tanValue = math.tan(math.rad(eraseR))
            offsetY = TIMER_CORNER_RADIUS / (math.sqrt(1 + tanValue * tanValue))
            offsetX = offsetY * tanValue
            eraseX = TOP_RIGHT_CORNER_POINT.x + offsetX
            eraseY = TOP_RIGHT_CORNER_POINT.y + offsetY
        else
            eraseX = TOP_RIGHT_CORNER_POINT.x + TIMER_CORNER_RADIUS
            eraseY = TOP_RIGHT_CORNER_POINT.y
            eraseR = 90
            animationPhase = RIGHT
        end
    elseif animationPhase == RIGHT then -- RIGHT phase
        eraseY = eraseY - lineVelocity
        if eraseY <= BOTTOM_RIGHT_CORNER_POINT.y then
            eraseY = BOTTOM_RIGHT_CORNER_POINT.y
            animationPhase = BOTTOM_RIGHT_CORNER
        end
    elseif animationPhase == BOTTOM_RIGHT_CORNER then -- BOTTOM_RIGHT_CORNER phase
        eraseR = eraseR + angularVelocity
        if eraseR < 180 then
            tanValue = math.tan(math.rad(eraseR - 90))
            offsetX = TIMER_CORNER_RADIUS / (math.sqrt(1 + tanValue * tanValue))
            offsetY = offsetX * tanValue
            eraseX = BOTTOM_RIGHT_CORNER_POINT.x + offsetX
            eraseY = BOTTOM_RIGHT_CORNER_POINT.y - offsetY
        else
            eraseX = BOTTOM_RIGHT_CORNER_POINT.x
            eraseY = BOTTOM_RIGHT_CORNER_POINT.y - TIMER_CORNER_RADIUS
            eraseR = 180
            animationPhase = BOTTOM
        end
    elseif animationPhase == BOTTOM then -- BOTTOM phase
        eraseX = eraseX - lineVelocity
        if eraseX <= BOTTOM_LEFT_CORNER_POINT.x then
            eraseX = BOTTOM_LEFT_CORNER_POINT.x
            animationPhase = BOTTOM_LEFT_CORNER
        end
    elseif animationPhase == BOTTOM_LEFT_CORNER then -- BOTTOM_LEFT_CORNER phase
        eraseR = eraseR + angularVelocity
        if eraseR < 270 then
            tanValue = math.tan(math.rad(eraseR - 180))
            offsetY = TIMER_CORNER_RADIUS / (math.sqrt(1 + tanValue * tanValue))
            offsetX = offsetY * tanValue
            eraseX = BOTTOM_LEFT_CORNER_POINT.x - offsetX
            eraseY = BOTTOM_LEFT_CORNER_POINT.y - offsetY
        else
            eraseX = BOTTOM_LEFT_CORNER_POINT.x - TIMER_CORNER_RADIUS
            eraseY = BOTTOM_LEFT_CORNER_POINT.y
            eraseR = 270
            animationPhase = LEFT
        end
    elseif animationPhase == LEFT then -- LEFT phase
        eraseY = eraseY + lineVelocity
        if eraseY >= TOP_LEFT_CORNER_POINT.y then
            eraseY = TOP_LEFT_CORNER_POINT.y
            animationPhase = TOP_LEFT_CORNER
        end
    elseif animationPhase == TOP_LEFT_CORNER then -- TOP_LEFT_CORNER phase
        eraseR = eraseR + angularVelocity
        if eraseR < 360 then
            tanValue = math.tan(math.rad(eraseR - 270))
            offsetX = TIMER_CORNER_RADIUS / (math.sqrt(1 + tanValue * tanValue))
            offsetY = offsetX * tanValue
            eraseX = TOP_LEFT_CORNER_POINT.x - offsetX
            eraseY = TOP_LEFT_CORNER_POINT.y + offsetY
        else
            eraseX = TOP_LEFT_CORNER_POINT.x
            eraseY = TOP_LEFT_CORNER_POINT.y + TIMER_CORNER_RADIUS
            eraseR = 360
            animationPhase = TOP_LEFT
        end
    elseif animationPhase == TOP_LEFT then -- TOP_LEFT phase
        eraseX = eraseX + lineVelocity
        if eraseX >= display.cx then
            eraseX = display.cx
            animationPhase = STOP

            -- 结束动画时从舞台移除
            self:unscheduleUpdate()
            print("SeatProgressTimer:onEnterFrame(evt, isFastForward) end")
            -- self:removeFromParent()
            return
        end
    end

    -- 设置阶段
    self.animationPhrase_ = animationPhase
    self.colorPhase_      = colorPhase

    -- 设置橡皮擦的位置，旋转角度
    self.eraseX_ = eraseX
    self.eraseY_ = eraseY
    self.eraseR_ = eraseR
    self.erase_:pos(self.eraseX_, self.eraseY_):setRotation(self.eraseR_)

    -- 开始擦除
    self.isVisting_ = true
    self:begin()
    self.erase_:visit()
    self:endToLua()
    self.isVisting_ = false

    -- 设置颜色
    self.redColor_ = redColor
    self.greenColor_ = greenColor
    self:getSprite():setColor(cc.c3b(self.redColor_, self.greenColor_, 0))

    if not isFastForward then
        --掉帧处理
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

function SeatProgressTimer:remove()
    if not self.removeing_ then--防止重复删除
        self.removeing_ = true
        self:unscheduleUpdate()
        nk.schedulerPool:delayCall(function()
            self:removeFromParent()
        end, 0.1)
    end
end

-- 重置计时器（移除舞台时自动调用）
function SeatProgressTimer:onExit()
    self.erase_:release()
end

return SeatProgressTimer