--
-- Author: Jonah0608@gmail.com
-- Date: 2016-09-05 10:14:10
--
local DiceChipData = class("DiceChipData")
function DiceChipData:ctor(filename,num)
    self.sprite_ = display.newSprite(filename)
    self.num_ = num
end


function DiceChipData:getSprite()
    return self.sprite_
end

function DiceChipData:getNum()
    return self.num_
end

function DiceChipData:retain()
    self.sprite_:retain()
end

function DiceChipData:release()
    self.sprite_:release()
    self.num_ = nil
end



return DiceChipData

