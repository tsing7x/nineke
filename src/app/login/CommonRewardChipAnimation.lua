--
-- Author: Tom
-- Date: 2014-09-02 15:37:36
--


-- local Panel = nk.ui.Panel
-- local Amimation = class("Amimation", Panel)

local CommonRewardChipAnimation = class("CommonRewardChipAnimation", function ()
    return display.newNode()
end)


local LEFT = display.c_left + 130
local BOTTOM = display.c_bottom  + 50

local DISTENCE_X = 180
local DISTENCE_Y = 180

function CommonRewardChipAnimation:ctor(callback, px, py)
    -- 主要处理ChangeChipAnim添加display.getRunningScene() 
    if px and py then
        LEFT = px
        BOTTOM = py
    end

    self.pokerBatchNode_ = display.newBatchNode("common_texture.png")
        :addTo(self)

        
    self.chipTabel_1 = {}
    self.chipTabel_2 = {}
    self.chipTabel_3 = {}

    self.chipTabel_4 = {}
    self.chipTabel_5 = {}
    self.chipTabel_6 = {}
    self.chipTabel_7 = {}


    for i=1,2 do
        self.chip1_ = display.newSprite("#act-task-reward-chip-icon-1.png")
        :pos(0+ math.random()*DISTENCE_X, math.random()*DISTENCE_Y + 0)
        :addTo(self.pokerBatchNode_)
        self.chipTabel_1[i] = self.chip1_

        self.chip2_ = display.newSprite("#act-task-reward-chip-icon-2.png")
        :pos(0+ math.random()*DISTENCE_X, math.random()*DISTENCE_Y + 0)
        :addTo(self.pokerBatchNode_)
        self.chipTabel_2[i] = self.chip2_


        self.chip3_ = display.newSprite("#act-task-reward-chip-icon-3.png")
        :pos(0+ math.random()*DISTENCE_X, math.random()*DISTENCE_Y + 0)
        :addTo(self.pokerBatchNode_)
        self.chipTabel_3[i] = self.chip3_



        self.chip4_ = display.newSprite("#act-task-reward-chip-icon-4.png")
        :pos(0+ math.random()*DISTENCE_X, math.random()*DISTENCE_Y + 0)
        :addTo(self.pokerBatchNode_)
        self.chipTabel_4[i] = self.chip4_


        self.chip5_ = display.newSprite("#act-task-reward-chip-icon-5.png")
        :pos(0+ math.random()*DISTENCE_X, math.random()*DISTENCE_Y + 0)
        :addTo(self.pokerBatchNode_)
        self.chipTabel_5[i] = self.chip5_


        self.chip6_ = display.newSprite("#act-task-reward-chip-icon-6.png")
        :pos(0+ math.random()*DISTENCE_X, math.random()*DISTENCE_Y + 0)
        :addTo(self.pokerBatchNode_)
        self.chipTabel_6[i] = self.chip6_


        self.chip7_ = display.newSprite("#act-task-reward-chip-icon-7.png")
        :pos(0+ math.random()*DISTENCE_X, math.random()*DISTENCE_Y + 0)
        :addTo(self.pokerBatchNode_)
        self.chipTabel_7[i] = self.chip7_


    end


    local animTime = math.round((6*math.random() - 0.499999)) * 0.1
    local delayAnimTime = 0.2

    for _, dot in ipairs(self.chipTabel_1) do
        transition.moveTo(dot, {time = 0.3 + 0.4 * math.random(), x = LEFT,y = BOTTOM ,delay = delayAnimTime, rotation = 120, onComplete = handler(self, function (obj) dot:opacity(0) end)})
        dot:runAction(cc.RepeatForever:create(transition.sequence({
            cc.RotateTo:create(delayAnimTime, 180), 
            cc.RotateTo:create(delayAnimTime, 360)
        })))
    end

    for _, dot in ipairs(self.chipTabel_2) do
        transition.moveTo(dot, {time = 0.3 + 0.4 * math.random(), x = LEFT,y = BOTTOM ,delay = delayAnimTime, rotation = 120, onComplete = handler(self, function (obj) dot:opacity(0) end)})
        dot:runAction(cc.RepeatForever:create(transition.sequence({
            cc.RotateTo:create(delayAnimTime, 180), 
            cc.RotateTo:create(delayAnimTime, 360)
        })))
    end

    for _, dot in ipairs(self.chipTabel_3) do
        transition.moveTo(dot, {time = 0.3 + 0.4 * math.random(), x = LEFT,y = BOTTOM ,delay = delayAnimTime, rotation = 120, onComplete = handler(self, function (obj) dot:opacity(0) end)})
        dot:runAction(cc.RepeatForever:create(transition.sequence({
            cc.RotateTo:create(delayAnimTime, 180), 
            cc.RotateTo:create(delayAnimTime, 360)
        })))
    end

    for _, dot in ipairs(self.chipTabel_4) do
        transition.moveTo(dot, {time = 0.3 + 0.4 * math.random(), x = LEFT,y = BOTTOM ,delay = delayAnimTime, rotation = 120, onComplete = handler(self, function (obj) dot:opacity(0) end)})
        dot:runAction(cc.RepeatForever:create(transition.sequence({
            cc.RotateTo:create(delayAnimTime, 180), 
            cc.RotateTo:create(delayAnimTime, 360)
        })))
    end

    for _, dot in ipairs(self.chipTabel_5) do
        transition.moveTo(dot, {time = 0.3 + 0.4 * math.random(), x = LEFT,y = BOTTOM ,delay = delayAnimTime, rotation = 120, onComplete = handler(self, function (obj) dot:opacity(0) end)})
        dot:runAction(cc.RepeatForever:create(transition.sequence({
            cc.RotateTo:create(delayAnimTime, 180), 
            cc.RotateTo:create(delayAnimTime, 360)
        })))
    end

    for _, dot in ipairs(self.chipTabel_6) do
        transition.moveTo(dot, {time = 0.3 + 0.4 * math.random(), x = LEFT,y = BOTTOM ,delay = delayAnimTime, rotation = 120, onComplete = handler(self, function (obj) dot:opacity(0) end)})
        dot:runAction(cc.RepeatForever:create(transition.sequence({
            cc.RotateTo:create(delayAnimTime, 180), 
            cc.RotateTo:create(delayAnimTime, 360)
        })))
    end

    for _, dot in ipairs(self.chipTabel_7) do
        transition.moveTo(dot, {time = 0.3 + 0.4 * math.random(), x = LEFT,y = BOTTOM ,delay = delayAnimTime, rotation = 120, onComplete = handler(self, function (obj) dot:opacity(0) end)})
        dot:runAction(cc.RepeatForever:create(transition.sequence({
            cc.RotateTo:create(delayAnimTime, 180), 
            cc.RotateTo:create(delayAnimTime, 360)
        })))
    end

    self:performWithDelay(function()
        if callback then
            callback()
        end
    end, 0.3 + 0.4)

    nk.SoundManager:playSound(nk.SoundManager.CHIP_DROP)
    
end

return CommonRewardChipAnimation