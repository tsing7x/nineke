--
-- Author: tony
-- Date: 2014-07-23 19:02:52
--
local RoomImageButton = {}

local function exportMethods(target)
    for k, v in pairs(RoomImageButton) do
        if k ~= "create" then
            target[k] = v
        end
    end
    return target
end

function RoomImageButton.create(filename)
    return exportMethods(display.newSprite(filename, x, y, params)):ctor()
end

function RoomImageButton:ctor()
    self.touchHelper_ = bm.TouchHelper.new(self, self.onHelperTouch_)
    self.touchHelper_:enableTouch()
    self:setOpacity(128)
    self.isFlashing_ = false
    return self
end

function RoomImageButton:onClick(handler)
    self.clickHandler_ = handler
    return self
end

function RoomImageButton:onHelperTouch_(evt, isTouchInSprite)
    if evt == bm.TouchHelper.CLICK then
        if self.clickHandler_ then
            self.clickHandler_(self)
        end
        self:setOpacity(128)
        if self.isFlashing_ then
            self:flash(self.flashTimes_)
        end
    elseif evt == bm.TouchHelper.TOUCH_BEGIN then
        self:setOpacity(255)
        self:stopAllActions()
    elseif evt == bm.TouchHelper.TOUCH_MOVE then
        if isTouchInSprite then
            self:setOpacity(255)
        else
            self:setOpacity(128)
        end
    elseif evt == bm.TouchHelper.TOUCH_END then
        self:setOpacity(128)
        if self.isFlashing_ then
            self:flash(self.flashTimes_)
        end
    end
end

function RoomImageButton:flash(times)
    times = times or 10
    if times == -1 then
        self.isFlashing_ = true
        self.flashTimes_ = -1
        self:runAction(cc.RepeatForever:create(transition.sequence({
            cc.FadeTo:create(0.5, 255),
            cc.FadeTo:create(0.5, 128),
        })))
    elseif times > 0 then
        self.isFlashing_ = true
        self.flashTimes_ = times
        transition.execute(self, cc.Repeat:create(
            transition.sequence({
                cc.FadeTo:create(0.5, 255),
                cc.FadeTo:create(0.5, 128),
            }), times), {onComplete=function() self.isFlashing_ = false end})
    else
        self.isFlashing_ = false
    end
    return self
end

function RoomImageButton:stopFlash()
    self.isFlashing_ = false
    self:stopAllActions()
    self:setOpacity(128)
    return self
end

return RoomImageButton