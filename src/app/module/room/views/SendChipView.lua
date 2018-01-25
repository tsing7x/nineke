--
-- Author: tony
-- Date: 2014-08-05 16:49:25
--
local SendChipView = class("SendChipView", function() return display.newNode() end)

function SendChipView:ctor(chips,iscoin)
    self.batchNode_ = display.newBatchNode("room_texture.png", capacity):addTo(self)
    self.chips_ = {}
    self.bg_ = display.newSprite("#room_chip_text_bg.png")
            :addTo(self.batchNode_)

    self.label_ = ui.newTTFLabel({text = bm.formatBigNumber(chips), size = 20, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(255, 204, 0)})
            :addTo(self)

    local y, step = 28, 4
    local function createChipSprite(isEven, num)
        local sp
        if isEven then
            sp = display.newSprite("#room_chip_even_" .. num .. ".png")
        else
            sp = display.newSprite("#room_chip_odd_" .. num .. ".png")
        end
        if iscoin then
            sp = display.newSprite("#room_gcoins_icon.png")
        end
        sp:pos(0, y)
        sp:addTo(self.batchNode_)
        y = y + step
        return sp
    end

    local numStr = tostring(chips)
    local strLen = string.len(numStr)
    for i = strLen, 1, -1 do
        local isEven = ((strLen - i + 1) % 2 == 0)
        local value = tonumber(string.sub(numStr, i, i))
        if value > 5 then
            table.insert(self.chips_, createChipSprite(isEven, 5))
            value = value - 5
        end
        while value >= 2 do
            table.insert(self.chips_, createChipSprite(isEven, 2))
            value = value - 2
        end
        if value == 1 then
            table.insert(self.chips_, createChipSprite(isEven, 1))
        end
    end
end

return SendChipView