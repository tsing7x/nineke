--
-- Author: tony
-- Date: 2014-08-15 10:34:21
--
local Juhua = class("Juhua", function(filename)
        return display.newSprite(filename or "#juhua.png")
    end)

function Juhua:ctor(filename)
    self:setNodeEventEnabled(true)
    self:setAnchorPoint(cc.p(0.5, 0.5))
end

function Juhua:onEnter()
    self:runAction(cc.RepeatForever:create(cc.RotateBy:create(100, 36000)))
end

function Juhua:onExit()
    self:stopAllActions()
end

return Juhua
