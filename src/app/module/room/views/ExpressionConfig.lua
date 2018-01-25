--
-- Author: tony
-- Date: 2014-08-08 10:39:19
--

local ExpressionConfig = class("ExpressionConfig")

function ExpressionConfig:ctor()
    self.config_ = {}

    local d3 = 1 / 3
    self:addConfig_(1,    2,    -5,    0)
    self:addConfig_(2,    2,    4,    8)
    self:addConfig_(3,    2,    10,    6)
    self:addConfig_(4,    2,    0,    8)
    self:addConfig_(5,    4,    6,    6)
    self:addConfig_(6,    2,    0,    4)
    self:addConfig_(7,    3,    0,    2)
    self:addConfig_(8,    3,    0,    2)
    self:addConfig_(9,    3,    0,    4)
    self:addConfig_(10,    4,    0,    6)
    self:addConfig_(11,    2,    8,    0)
    self:addConfig_(12,    2,    0,    0)
    self:addConfig_(13,    2,    2,    6)
    self:addConfig_(14,    4,    -4,    4)
    self:addConfig_(15,    2,    1,    2)
    self:addConfig_(16,    2,    1,    4)
    self:addConfig_(17,    2,    1,    10)
    self:addConfig_(18,    2,    11,    10)
    self:addConfig_(19,    2,    -2,    6)
    self:addConfig_(20,    2,    14,    4)
    self:addConfig_(21,    2,    4,    4)
    self:addConfig_(22,    2,    6,    0)
    self:addConfig_(23,    11,    0,    0)
    self:addConfig_(24,    4,    0,    0)
    self:addConfig_(25,    2,    0,    0)
    self:addConfig_(26,    2,    12,    2)
    self:addConfig_(27,    3,    0,    0)

    self:addConfig_(1001,  11,    0,    0)
    self:addConfig_(1002,  8,    0,    0)
    self:addConfig_(1003,  3,    0,    0)
    self:addConfig_(1004,  3,    0,    -8)
    self:addConfig_(1005,  9,    -8,    -15)
    self:addConfig_(1006,  7,    0,    0)
    self:addConfig_(1007,  3,    0,    -22)
    self:addConfig_(1008,  8,    0,    -22)
    self:addConfig_(1009,  5,    0,    -22)

    self:addConfig_(2001,  3,    0,    0)
    self:addConfig_(2002,  2,    0,    0)
    self:addConfig_(2003,  5,    0,    0)
    self:addConfig_(2004,  3,    0,    0)
    self:addConfig_(2005,  11,    0,    0)
    self:addConfig_(2006,  2,    0,    0)
    self:addConfig_(2007,  10,    0,    0)
    self:addConfig_(2008,  2,    0,    0)
    self:addConfig_(2009,  4,    0,    0)
    self:addConfig_(2010,  2,    0,    0)
    self:addConfig_(2011,  3,    0,    0)
    self:addConfig_(2012,  4,    0,    0)
    self:addConfig_(2013,  4,    0,    0)
    self:addConfig_(2014,  12,    0,    0)
    self:addConfig_(2015,  2,    0,    0)
    self:addConfig_(2016,  6,    0,    0)
    self:addConfig_(2017,  9,    0,    0)
    self:addConfig_(2018,  8,    0,    0)
    self:addConfig_(2019,  2,    0,    0)
    self:addConfig_(2020,  7,    0,    0)


    for i=1,37,1 do
        self:addConfig_(100+i, 1, 0, 0, 0.5)
    end  
    -- 修正
    self:addConfig_(107, 1, 0, 0, 0.4)
    self:addConfig_(111, 1, 0, 0, 0.4)
    self:addConfig_(115, 1, 0, 0, 0.46)
    self:addConfig_(130, 1, 0, 0, 0.46)
    self:addConfig_(133, 1, 0, 0, 0.35)

    self:addConfig_(615,  45,    0,    0)
    self:addConfig_(1202, 40,    0,    0)
    self:addConfig_(1293,  6,    0,    0)
end

function ExpressionConfig:getConfig(id)
    return self.config_[id]
end

function ExpressionConfig:addConfig_(id, frameNum, adjustX, adjustY, scale)
    local config = {}
    config.id = id
    config.frameNum = frameNum
    config.adjustX = adjustX
    config.adjustY = adjustY
    config.scale = scale
    self.config_[id] = config
end

return ExpressionConfig