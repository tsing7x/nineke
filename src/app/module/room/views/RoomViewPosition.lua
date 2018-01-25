--
-- Author: tony
-- Date: 2014-07-08 20:11:05
--
local RoomViewPosition = {}
local P = RoomViewPosition

local paddingLeft = (display.width - 928) * 0.5 -- 928为设计布局宽度
local paddingBottom = (display.height - (528 + 72 + 8)) * 0.5 + (72 + 8) -- 528为设计布局高度，72为底部操作按钮高度，8为底部操作按钮与屏幕边缘的间隙
-- 座位位置
P.SeatPosition = {
    cc.p(690 + paddingLeft, 446 + paddingBottom), 
    cc.p(866 + paddingLeft, 386 + paddingBottom), 
    cc.p(866 + paddingLeft, 162 + paddingBottom), 
    cc.p(698 + paddingLeft, 82  + paddingBottom), 
    cc.p(464 + paddingLeft, 82  + paddingBottom), 
    cc.p(230 + paddingLeft, 82  + paddingBottom), 
    cc.p(62  + paddingLeft, 162 + paddingBottom), 
    cc.p(62  + paddingLeft, 386 + paddingBottom), 
    cc.p(238 + paddingLeft, 446 + paddingBottom), 
    cc.p(226 + 238 + paddingLeft, 446 + paddingBottom)
}

local paddingLeft = (display.width - 720) * 0.5 -- 720为设计布局宽度
-- 下注位置
P.BetPosition = {
    cc.p(570 + paddingLeft, P.SeatPosition[1].y - 136), 
    cc.p(682 + paddingLeft, P.SeatPosition[2].y - 104), 
    cc.p(630 + paddingLeft, P.SeatPosition[3].y + 68 ), 
    cc.p(578 + paddingLeft, P.SeatPosition[4].y + 104), 
    cc.p(460 + paddingLeft, P.SeatPosition[5].y + 70 ), 
    cc.p(142 + paddingLeft, P.SeatPosition[6].y + 104), 
    cc.p(90  + paddingLeft, P.SeatPosition[7].y + 68 ), 
    cc.p(38  + paddingLeft, P.SeatPosition[8].y - 104), 
    cc.p(150 + paddingLeft, P.SeatPosition[9].y - 136)
}

local paddingLeft = (display.width - 440) * 0.5 -- 432为设计布局宽度
-- 奖池位置
P.PotPosition = {
    cc.p(220 + paddingLeft, P.SeatPosition[2].y - 128), 
    cc.p(128 + paddingLeft, P.SeatPosition[2].y - 128), 
    cc.p(312 + paddingLeft, P.SeatPosition[2].y - 128), 
    cc.p(36  + paddingLeft, P.SeatPosition[2].y - 128), 
    cc.p(404 + paddingLeft, P.SeatPosition[2].y - 128), 
    cc.p(174 + paddingLeft, P.SeatPosition[1].y - 160), 
    cc.p(266 + paddingLeft, P.SeatPosition[1].y - 160), 
    cc.p(82  + paddingLeft, P.SeatPosition[1].y - 160), 
    cc.p(358 + paddingLeft, P.SeatPosition[1].y - 160)
}

-- 发牌位置（10号位为荷官发牌位置）
P.DealCardPosition = {
    cc.p(P.SeatPosition[1].x + 40 , P.SeatPosition[1].y - 32), 
    cc.p(P.SeatPosition[2].x + 40 , P.SeatPosition[2].y - 32), 
    cc.p(P.SeatPosition[3].x + 40 , P.SeatPosition[3].y - 32), 
    cc.p(P.SeatPosition[4].x + 40 , P.SeatPosition[4].y - 32), 
    cc.p(P.SeatPosition[5].x + 40 , P.SeatPosition[5].y - 32), 
    cc.p(P.SeatPosition[6].x - 40 , P.SeatPosition[6].y - 32), 
    cc.p(P.SeatPosition[7].x - 40 , P.SeatPosition[7].y - 32), 
    cc.p(P.SeatPosition[8].x - 40 , P.SeatPosition[8].y - 32), 
    cc.p(P.SeatPosition[9].x - 40 , P.SeatPosition[9].y - 32), 
    cc.p(display.cx               , P.SeatPosition[1].y - 104)
}

-- dealer位置
P.DealerPosition = {
    cc.p(P.SeatPosition[1].x - 76, P.SeatPosition[1].y - 68 ), 
    cc.p(P.SeatPosition[2].x - 24, P.SeatPosition[2].y - 104), 
    cc.p(P.SeatPosition[3].x - 76, P.SeatPosition[3].y + 68 ), 
    cc.p(P.SeatPosition[4].x + 40, P.SeatPosition[4].y + 104), 
    cc.p(P.SeatPosition[5].x - 76, P.SeatPosition[5].y + 68 ), 
    cc.p(P.SeatPosition[6].x - 40, P.SeatPosition[6].y + 104), 
    cc.p(P.SeatPosition[7].x + 76, P.SeatPosition[7].y + 68 ), 
    cc.p(P.SeatPosition[8].x + 24, P.SeatPosition[8].y - 104), 
    cc.p(P.SeatPosition[9].x + 76, P.SeatPosition[9].y - 68 )
}

return RoomViewPosition