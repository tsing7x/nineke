--
-- Author: johnny@boomegg.com
-- Date: 2014-07-18 17:21:23
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local ChipData = class("ChipData")

function ChipData:ctor(filename, oddOrEven, key)
    self.sprite_ = display.newSprite(filename)
    self.oddOrEven_ = oddOrEven
    self.key_ = key
end

function ChipData:getSprite()
    return self.sprite_
end

function ChipData:getOddOrEven()
    return self.oddOrEven_
end

function ChipData:getKey()
    return self.key_
end

function ChipData:retain()
    self.sprite_:retain()
end

function ChipData:release()
    self.sprite_:release()
    self.oddOrEven_ = nil
    self.key_ = nil
end

return ChipData