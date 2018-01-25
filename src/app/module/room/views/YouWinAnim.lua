--
-- Author: johnny@boomegg.com
-- Date: 2014-07-28 17:38:39
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local YouWinAnim = class("YouWinAnim", function ()
    return display.newNode()
end)

function YouWinAnim:ctor()
    self.lightBatchNode_ = display.newNode():addTo(self)
    self.batchNode_ = display.newNode():addTo(self)


    self.stars_ = {}
    for i = 1, 4 do
        self.stars_[i] = display.newSprite("#room_you_win_star.png"):addTo(self.batchNode_)
    end
    self.stars_[1]:scale(1)
    self.stars_[2]:scale(0.8)
    self.stars_[3]:scale(0.6)
    self.stars_[4]:scale(0.4)
    for i = 1, 12 do
        local light = display.newSprite("#room_you_win_bg.png")
        light:setAnchorPoint(cc.p(0.5, 0))
        light:rotation((i - 1) * 30)
        light:addTo(self.lightBatchNode_)
    end
    self.icon_ = display.newSprite("#room_you_win_icon.png")
        :pos(0, 20)
        :addTo(self.batchNode_)
    self.label_ = display.newSprite("#room_you_win_label.png")
        :pos(0, -56)
        :addTo(self.batchNode_)
    self.flashs_ = {}
    for i = 1, 4 do
        self.flashs_[i] = display.newSprite("#room_you_win_flash.png"):addTo(self.batchNode_)
    end
    self.flashs_[1]:pos(2, 58)
    self.flashs_[2]:pos(-60, 12)
    self.flashs_[3]:pos(-150, -32)
    self.flashs_[4]:pos(112, -32)

    -- 打开node event
    self:setNodeEventEnabled(true)
    self.noCleanup_ = true
end

function YouWinAnim:onEnter()
    -- 添加至舞台开始动画
    -- self:scale(0.2):scaleTo(0.5, 1)
    -- self.lightBatchNode_:runAction(cc.RepeatForever:create(cc.RotateBy:create(6, 360)))
    -- for i = 1, 4 do
    --     self.flashs_[i]:runAction(cc.RepeatForever:create(transition.sequence({cc.ScaleTo:create(0, 0.9, 0.9), cc.ScaleTo:create(0.15, 1.1, 1.1), cc.ScaleTo:create(0.15, 0.9, 0.9)})))
    -- end
    -- self.stars_[1]:runAction(transition.sequence({cc.DelayTime:create(0.2), cc.MoveTo:create(0.3, cc.p(-80, 20)), cc.RotateBy:create(3, math.random(270, 360))}))
    -- self.stars_[2]:runAction(transition.sequence({cc.DelayTime:create(0.2), cc.MoveTo:create(0.3, cc.p(0  , 72)), cc.RotateBy:create(3, math.random(180, 270))}))
    -- self.stars_[3]:runAction(transition.sequence({cc.DelayTime:create(0.2), cc.MoveTo:create(0.3, cc.p(56 , 64)), cc.RotateBy:create(3, -math.random(180, 270))}))
    -- self.stars_[4]:runAction(transition.sequence({cc.DelayTime:create(0.2), cc.MoveTo:create(0.3, cc.p(88 , 40)), cc.RotateBy:create(3, math.random(90, 180))}))
    -- for i = 1, 4 do
    --     self.stars_[i]:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5 + math.random(0.1, 0.3), 0), cc.FadeTo:create(0.5 + math.random(0.1, 0.3), 255))))
    -- end
end

function YouWinAnim:onPlay()
     self:scale(0.2):scaleTo(0.5, 1)
    self.lightBatchNode_:runAction(cc.RepeatForever:create(cc.RotateBy:create(6, 360)))
    for i = 1, 4 do
        self.flashs_[i]:runAction(cc.RepeatForever:create(transition.sequence({cc.ScaleTo:create(0, 0.9, 0.9), cc.ScaleTo:create(0.15, 1.1, 1.1), cc.ScaleTo:create(0.15, 0.9, 0.9)})))
    end
    self.stars_[1]:runAction(transition.sequence({cc.DelayTime:create(0.2), cc.MoveTo:create(0.3, cc.p(-80, 20)), cc.RotateBy:create(3, math.random(270, 360))}))
    self.stars_[2]:runAction(transition.sequence({cc.DelayTime:create(0.2), cc.MoveTo:create(0.3, cc.p(0  , 72)), cc.RotateBy:create(3, math.random(180, 270))}))
    self.stars_[3]:runAction(transition.sequence({cc.DelayTime:create(0.2), cc.MoveTo:create(0.3, cc.p(56 , 64)), cc.RotateBy:create(3, -math.random(180, 270))}))
    self.stars_[4]:runAction(transition.sequence({cc.DelayTime:create(0.2), cc.MoveTo:create(0.3, cc.p(88 , 40)), cc.RotateBy:create(3, math.random(90, 180))}))
    for i = 1, 4 do
        self.stars_[i]:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5 + math.random(0.1, 0.3), 0), cc.FadeTo:create(0.5 + math.random(0.1, 0.3), 255))))
    end
end

function YouWinAnim:onExit()
    -- 从舞台移除停止动画
    self.lightBatchNode_:stopAllActions()
    for i = 1, 4 do
        self.stars_[i]:pos(0, 0):opacity(255):stopAllActions()
    end
end

function YouWinAnim:dispose()

end

return YouWinAnim