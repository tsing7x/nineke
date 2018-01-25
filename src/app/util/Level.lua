--
-- Author: tony
-- Date: 2014-08-04 15:55:44
--

local Level = class("Level")

--等级配置
local P = {}
Level.CONFIG = P
P[1] = { title="รู้จักโป๊กเกอร์",    exp=0}
P[2] = { title="มือใหม่โป๊กเกอร์",    exp=25}
P[3] = { title="ผู้รักโป๊กเกอร์",    exp=80}
P[4] = { title="มือชมรม",            exp=240}
P[5] = { title="โปรชมรม",            exp=520}
P[6] = { title="แชมป์ชมรม",        exp=1249}
P[7] = { title="มือประจำเขต",        exp=2499}
P[8] = { title="โปรเขต",            exp=4427}
P[9] = { title="แชมป์เขต",        exp=7198}
P[10] = { title="มือประจำเมือง",    exp=10990}
P[11] = { title="โปรเมือง",        exp=16003}
P[12] = { title="แชมป์เมือง",        exp=22466}
P[13] = { title="มือประเทศ",        exp=30658}
P[14] = { title="โปรประเทศ",        exp=40931}
P[15] = { title="แชมป์ประเทศ",        exp=53748}
P[16] = { title="มือเอเชีย",        exp=69744}
P[17] = { title="โปรเอเชีย",        exp=89816}
P[18] = { title="แชมป์เอเชีย",        exp=115264}
P[19] = { title="มืออินเตอร์",        exp=148000}
P[20] = { title="โปรอินเตอร์",        exp=190877}
P[21] = { title="แชมป์อินเตอร์",    exp=248186}
P[22] = { title="มือระดับโลก",        exp=326416}
P[23] = { title="โปรระดับโลก",        exp=435424}
P[24] = { title="แชมป์โลก",        exp=590214}
P[25] = { title="ตำนานโป๊กเกอร์",    exp=813671}

function Level:ctor()
    local lastExp = 0
    local t
    for i = #P, 1, -1 do
        t = P[i]
        t.needExp = lastExp > t.exp and lastExp - t.exp or 0
        lastExp = t.exp
    end
end

--根据经验获得等级
function Level:getLevelByExp(exp)
    local t
    for i = 1, #P do
        t = P[i]
        if t.exp == exp then
            return i
        elseif P[i].exp > exp then
            if i - 1 < 1 then
                return 1
            else
                return i - 1
            end
        end
    end
    return #P
end

--根据等级获得称号
function Level:getTitleByLevel(level)
    local t = P[level]
    if t then
        return t.title
    end
    return ""
end

--根据经验获得称号
function Level:getTitleByExp(exp)
    local level = self:getLevelByExp(exp)
    return self:getTitleByLevel(level)
end

--根据经验值获得经验值升级进度 
--@return  进度百分比,升级已获得经验，升级总经验
function Level:getLevelUpProgress(exp)
    local level = self:getLevelByExp(exp)
    local nextLevel = (level + 1 <= #P and level + 1 or #P)
    if level == nextLevel then
        return 0, 0, 0
    else
        local progress = exp - P[level].exp
        local all = P[level].needExp
        return progress / all, progress, all
    end
end

return Level