--
-- Author: viking@boomegg.com
-- Date: 2014-11-27 21:13:16
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--
local Handler = class("Handler", function()
    return display.newNode()
end)

local function spawn(actions)
    if #actions < 1 then return end
    if #actions < 2 then return actions[1] end

    local prev = actions[1]
    for i = 2, #actions do
        prev = cc.Spawn:create(prev, actions[i])
    end
    return prev
end

local ballTop = 90
local ballBottom = -90
local handlerTop = 0
local handlerBottom = 0
local touchWidth = 60
local touchHeight = 180 * 2

function Handler:ctor(completeCallback)
    self.callback_ = completeCallback
    self.schedulerPool_ = bm.SchedulerPool.new()

    --触摸区域
    self.touchNode_ = display.newScale9Sprite("#transparent.png"):size(touchWidth, touchHeight):addTo(self)
    self.touchNode_:setTouchEnabled(true)
    self.touchNode_:setTouchSwallowEnabled(true)
    self.touchNode_:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouchListner_))

    --底座
    local handlerBaseWidth = 38
    local handlerBaseHeight = 81
    display.newSprite("#slot_handler_base.png"):addTo(self)

    --杆
    local handlerWidth = 38
    local handlerHeight = 81
    local handlerPadding = 20
    local handlerMarginTop = handlerBaseHeight - handlerPadding * 2
    handlerTop = handlerMarginTop
    handlerBottom = -handlerPadding * 2
    local handlerMarginRight = -2
    self.handler_ = display.newSprite("#slot_handler_shake.png"):addTo(self):pos(handlerMarginRight, handlerMarginTop)
    self.handlerMirror_ = display.newSprite("#slot_handler_shake.png"):addTo(self):pos(handlerMarginRight, 0):hide()
    self.handlerMirror_:setScaleY(0)

    --球
    local ballWidth = 59
    local ballHeight = 59
    local ballMarginTop = 90
    ballTop = ballMarginTop
    ballBottom = -ballMarginTop
    local ballMarginRight = 16

    self.ballbg = display.newSprite("#slot_handler_ball_blink.png"):scale(0.6):addTo(self):pos(ballMarginRight, ballMarginTop)
    self.ballbg:setVisible(false)
    self.ball_ = display.newSprite("#slot_handler_ball.png"):addTo(self):pos(ballMarginRight, ballMarginTop)
    -- self.ball_:setTouchEnabled(true)
    -- self.ball_:setTouchSwallowEnabled(true)
    -- self.ball_:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouchListner_))
    --水纹
    local waterWaveBottom = 10
    local waterWaveRight = 15
    self.waterWaveNode_ = display.newBatchNode("slot_texture.png"):addTo(self):pos(waterWaveRight, waterWaveBottom):hide()
    local waterWavePadding = 8
    local waterWaveWidth = 56
    local waterWaveHeight = 29
    local waterWave1 = display.newSprite("#slot_handler_light_water.png"):addTo(self.waterWaveNode_):pos(0, waterWaveHeight * 2/2 + waterWavePadding * 2)
    local waterWave2 = display.newSprite("#slot_handler_light_water.png"):addTo(self.waterWaveNode_):pos(0, waterWaveHeight * 1/2 + waterWavePadding)
    local waterWave3 = display.newSprite("#slot_handler_light_water.png"):addTo(self.waterWaveNode_)
    local waterWave4 = display.newSprite("#slot_handler_light_water.png"):addTo(self.waterWaveNode_):pos(0, -waterWaveHeight * 1/2 - waterWavePadding)
    local waterWave5 = display.newSprite("#slot_handler_light_water.png"):addTo(self.waterWaveNode_):pos(0, -waterWaveHeight * 2/2 - waterWavePadding * 2)
    self.waterWaves = {waterWave1, waterWave2, waterWave3, waterWave4, waterWave5}

    self:waterWave()
end

function Handler:waterWave()
    self.waterWaveNode_:show()
    local alpha1 = 1.0
    local alpha2 = 0.75
    local alpha3 = 0.50
    local alpha4 = 0.25
    local alpha5 = 0.0
    local step = 0.25 * 255
    local minOpaque = 0.01 * 255
    local transparent = 0.0 * 255
    local opacity = 1.0 * 255
    self.loopWaterWaveId = self.schedulerPool_:loopCall(function()
        if not self.waterWaves then
            return false
        end
        self.waterWaves[1]:opacity(alpha1)
        self.waterWaves[2]:opacity(alpha1)
        self.waterWaves[3]:opacity(alpha1)
        self.waterWaves[4]:opacity(alpha1)
        self.waterWaves[5]:opacity(alpha1)

        alpha1 = alpha1 + step
        if (alpha1 - opacity) > minOpaque then
            alpha1 = transparent
        end

        -- alpha2 = alpha2 + step
        -- if (alpha2 - opacity) > minOpaque then
        --     alpha2 = transparent
        -- end

        -- alpha3 = alpha3 + step
        -- if (alpha3 - opacity) > minOpaque then
        --     alpha3 = transparent
        -- end

        -- alpha4 = alpha4 + step
        -- if (alpha4 - opacity) > minOpaque then
        --     alpha4 = transparent
        -- end

        -- alpha5 = alpha5 + step
        -- if (alpha5 - opacity) > minOpaque then
        --     alpha5 = transparent
        -- end
        return true
    end, 0.2)
end

function Handler:stopWaterWave()
    self.waterWaveNode_:hide()
    if self.loopWaterWaveId then
        self.schedulerPool_:clear(self.loopWaterWaveId)
    end
end

function Handler:showBallBg()
    self.ballbg:setVisible(true)
    self.ballbg:runAction(cc.RepeatForever:create(transition.sequence({cc.FadeIn:create(0.3),cc.FadeOut:create(0.3)})))
end

function Handler:hideBallBg()
    self.ballbg:stopAllActions()
    self.ballbg:setVisible(false)
end

function Handler:onTouchListner_(event)
    local name, x, y = event.name, event.x, event.y
    local isTouchInSprite = self.touchNode_:getCascadeBoundingBox():containsPoint(cc.p(x, y))
    -- print("Handler:onTouchListner_", name, y, isTouchInSprite)

    if name == "began" then
        if not isTouchInSprite then 
            return false 
        end
        self:hideBallBg()
        self:stopWaterWave()
        self.startY = y
        self.touchInY = y
        return true
    elseif name == "moved" then
        self.currentY = y
        if isTouchInSprite then
            self:notifyTouchChanged(event)
            return true
        else
            return false 
        end
    elseif name == "cancelled" then
        self.currentY = y    
    elseif name == "ended" then
        self.currentY = y
        if self.currentY > self.touchInY then
            return true
        end
        if isTouchInSprite then
            if self.currentY == self.startY then--click
                self:autoHandle()
                self:setEnabled(false)
            else
                self:setEnabled(false)
                self.callback_()
                self:handleBack()
            end
            return true
        else
            self:setEnabled(false)
            self.callback_()
            self:handleBack()
            return false 
        end                                        
    end
end

function Handler:notifyTouchChanged(evt)
    local distance = self.currentY - self.startY
    local ball_ = self.ball_
    local handler_ = self.handler_
    local handlerMirror_ = self.handlerMirror_
    local ballY = ball_:getPositionY()
    local handlerY = handler_:getPositionY()
    local mirrorY = handlerMirror_:getPositionY()
    local ratio = 2

    if ballY >= 0  and ballY <= ballTop then
        ball_:setPositionY(ballY + distance)
        self:handlerOrMirrorVisible(true)
        handlerY =  handlerY + distance/ratio
        handler_:setPositionY(handlerY)
        handler_:setScaleY(handlerY/handlerTop)
    elseif ballY < 0 and ballY >= ballBottom then
        ball_:setPositionY(ballY + distance)
        self:handlerOrMirrorVisible(false)
        mirrorY = mirrorY + distance/ratio
        handlerMirror_:setPositionY(mirrorY)
        handlerMirror_:setScaleY(-mirrorY/handlerBottom)
    end

    if ballY > ballTop then
        ball_:setPositionY(ballTop)
        self:handlerOrMirrorVisible(true)
        handler_:setPositionY(handlerTop)
        handler_:setScaleY(1)
    elseif ballY < ballBottom then
        ball_:setPositionY(ballBottom)
        self:handlerOrMirrorVisible(false)
        handlerMirror_:setPositionY(handlerBottom)
        handlerMirror_:setScaleY(-1)
    end
    self.startY = self.currentY
end

local GO_ANIM = 0.2
function Handler:autoHandle()
    self:stopWaterWave()
    transition.moveTo(self.ball_, {time = GO_ANIM, y = ballBottom})
    local handlerX = self.handler_:getPositionX()
    local spawn = spawn({
            transition.sequence({
                cc.ScaleTo:create(GO_ANIM/2, 1, 0),
                cc.CallFunc:create(function()
                    self:continueHandler()
                end),
            }),
                cc.MoveTo:create(GO_ANIM/2, cc.p(handlerX, 0)),
        })
    self.handler_:runAction(spawn)
end

function Handler:continueHandler()
    self:handlerOrMirrorVisible(false)
    local handlerX = self.handlerMirror_:getPositionX()
    local sequence = transition.sequence({
        spawn({
            cc.ScaleTo:create(GO_ANIM/2, 1, -1),
                cc.MoveTo:create(GO_ANIM/2, cc.p(handlerX, handlerBottom)),
        }), 
        cc.CallFunc:create(function()
            self:onAutoHandleComplete()
        end),
        })
    self.handlerMirror_:runAction(sequence)    
end

local BACK_ANIM = 0.1
function Handler:handleBack(isAuto)
    transition.moveTo(self.ball_, {time = BACK_ANIM, y = ballTop})
    if self.ball_:getPositionY() < 0 then
        self:handlerOrMirrorVisible(false)
        local handlerX = self.handlerMirror_:getPositionX()
        local animTime = isAuto and BACK_ANIM/4 or BACK_ANIM/4
        local sequence = transition.sequence({
                 spawn({
                    cc.ScaleTo:create(animTime, 1, 0),
                        cc.MoveTo:create(animTime, cc.p(handlerX, 0)),
                }),
                cc.CallFunc:create(function()
                    self:continueHandleBack(isAuto)
                end),
            })
        self.handlerMirror_:runAction(sequence)
    else
        self:continueHandleBack(isAuto)
    end
end

function Handler:continueHandleBack(isAuto)
    self:handlerOrMirrorVisible(true)
    local handlerX = self.handler_:getPositionX()
    local animTime = isAuto and BACK_ANIM/2 or BACK_ANIM/2
    local spawn = spawn({
            cc.ScaleTo:create(animTime, 1, 1),
                cc.MoveTo:create(animTime, cc.p(handlerX, handlerTop)),
        })
    self.handler_:runAction(spawn)
end

function Handler:onAutoHandleComplete()
    self.callback_()
    self:handleBack(true)
end

function Handler:handlerOrMirrorVisible(isHandler)
    self.handler_:setVisible(isHandler)
    self.handlerMirror_:setVisible(not isHandler)
end

function Handler:setEnabled(isEnabled)
    self.touchNode_:setTouchEnabled(isEnabled)
    if isEnabled then
        self:showBallBg()
    else
        self:hideBallBg()
    end
end

function Handler:loopAutoHandler(delay)
    self:stopLoopAutoHandler()
    self.loopAutoId = self.schedulerPool_:delayCall(function()
        self:autoHandle()
    end, delay or 2)
end

function Handler:stopLoopAutoHandler()
    if self.loopAutoId then
        self.schedulerPool_:clear(self.loopAutoId)
    end
end

function Handler:dispose()
    self:stopWaterWave()
    self.ball_:stopAllActions()
    self.handler_:stopAllActions()
    self.handlerMirror_:stopAllActions()
end

return Handler