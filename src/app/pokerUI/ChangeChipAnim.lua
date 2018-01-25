--
-- Author: Tom
-- Date: 2014-09-04 15:06:16
--
local LEFT = display.c_left + 190
local BOTTOM = display.c_bottom  + 40

local chipNumber


local ChangeChipAnim = class("ChangeChipAnim", function ()
    return display.newNode()
end)

function ChangeChipAnim:ctor(chip, callback, px, py)
    -- 主要处理ChangeChipAnim添加display.getRunningScene() 
    if px and py then
        LEFT = px
        BOTTOM = py
    end

    chipNumber = chip
    self.chipChangeAnimation_ = display.newSprite("#buyin-action-yellowbackground.png")
        :pos(LEFT, BOTTOM)
        :addTo(self)

    self.chipChangeLabel_ = ui.newTTFLabel({text = "+"..chipNumber, color = cc.c3b(0xf4, 0xcd, 0x56), size = 32, align = ui.TEXT_ALIGN_CENTER})
        :pos(LEFT, BOTTOM)
        :addTo(self)

    transition.moveTo(self.chipChangeLabel_, {
        time = 1, 
        x = LEFT,
        y = BOTTOM + 60 ,
        delay = delayAnimTime, 
        rotation = 120, 
        onComplete = handler(self, function (obj) 
            self.chipChangeAnimation_:opacity(0) 
            self.chipChangeLabel_:opacity(0)
            if callback then
                callback();
            end
        end)})

    self:performWithDelay(function ()
        self.chipChangeAnimation_:opacity(0)
    end, 10)

end

return ChangeChipAnim