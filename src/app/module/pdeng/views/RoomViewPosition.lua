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
    cc.p(826 + paddingLeft, 162 + paddingBottom), 
    cc.p(698 + paddingLeft, 82  + paddingBottom), 
    cc.p(464 + paddingLeft, 12  + paddingBottom), 
    cc.p(230 + paddingLeft, 82  + paddingBottom), 
    cc.p(102 + paddingLeft, 162 + paddingBottom), 
    cc.p(62  + paddingLeft, 386 + paddingBottom), 
    cc.p(238 + paddingLeft, 446 + paddingBottom), 
    cc.p(226 + 238 + paddingLeft, 446 + paddingBottom),
    cc.p(226 + 238 + paddingLeft - 90 , 446 + paddingBottom +20)--这只是那个星星的位置
                                                                --抢庄场没有荷官了
                                                                --但是产品同学想保留赠送筹码的功能
                                                                --所以新增了一个动画的位置。。
}

P.SelfSeatPosition = {
    clone(P.SeatPosition[5]),
    cc.p(80, 80), 
}

P.SeatPositionForDealer = clone(P.SeatPosition)

P.SeatPositionForSelf = {
    clone(P.SeatPosition[6]), 
    clone(P.SeatPosition[7]),
    clone(P.SeatPosition[8]),  
    clone(P.SeatPosition[9]),  
    clone(P.SeatPosition[10]), 
    clone(P.SeatPosition[1]), 
    clone(P.SeatPosition[2]), 
    clone(P.SeatPosition[3]),
    clone(P.SeatPosition[4]),  
    cc.p(P.SeatPosition[5].x, P.SeatPosition[5].y + 40),
    clone(P.SeatPosition[11]),
}

local paddingLeft = (display.width - 720) * 0.5 -- 720为设计布局宽度
-- 下注位置
P.BetPosition = {
    cc.p(140 + display.cx, 120 + display.cy), 
    cc.p(780 - 480 + display.cx, 410 - 320 + display.cy), 
    cc.p(780 - 480 + display.cx, 310 - 320 + display.cy), 
    cc.p(650 - 480 + display.cx, 275 - 320 + display.cy), 
    cc.p(480 - 480 + display.cx, 275 - 390 + display.cy), 
    cc.p(300 - 480 + display.cx, 275 - 320 + display.cy), 
    cc.p(170 - 480 + display.cx, 310 - 320 + display.cy), 
    cc.p(170 - 480 + display.cx, 410 - 320 + display.cy), 
    cc.p(330 - 480 + display.cx, 440 - 320 + display.cy),

    cc.p(480 - 480 + display.cx, 120 + display.cy)
}

local paddingLeft = (display.width - 440) * 0.5 -- 432为设计布局宽度
-- 奖池位置
P.PotPosition = {
    clone(P.BetPosition[10]), 
    clone(P.BetPosition[5]), 
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

    cc.p(P.SeatPosition[10].x + 32         , P.SeatPosition[10].y - 80)    
}

--发牌开始位置
P.DealCardStartPosition = {
    cc.p(685 - 480 + display.cx, 425 - 320 + display.cy), 
    cc.p(805 - 480 + display.cx, 400 - 320 + display.cy), 
    cc.p(805 - 480 + display.cx, 340 - 320 + display.cy), 
    cc.p(695 - 480 + display.cx, 280 - 320 + display.cy), 
    cc.p(490 - 480 + display.cx, 280 - 320 + display.cy),
    cc.p(260 - 480 + display.cx, 280 - 320 + display.cy),
    cc.p(150 - 480 + display.cx, 340 - 320 + display.cy),
    cc.p(150 - 480 + display.cx, 400 - 320 + display.cy),
    cc.p(270 - 480 + display.cx, 425 - 320 + display.cy),
    cc.p(display.cx               , P.SeatPosition[1].y - 104)
}

-- dealer位置（10号位为荷官位置）
P.DealerPosition = {
    cc.p(715 - 480 + display.cx, 425 - 320 + display.cy), 
    cc.p(775 - 480 + display.cx, 400 - 320 + display.cy), 
    cc.p(775 - 480 + display.cx, 340 - 320 + display.cy), 
    cc.p(725 - 480 + display.cx, 280 - 320 + display.cy), 
    cc.p(460 - 480 + display.cx, 280 - 320 + display.cy),
    cc.p(230 - 480 + display.cx, 280 - 320 + display.cy),
    cc.p(180 - 480 + display.cx, 340 - 320 + display.cy),
    cc.p(180 - 480 + display.cx, 400 - 320 + display.cy),
    cc.p(240 - 480 + display.cx, 425 - 320 + display.cy),
    cc.p(display.cx - 35         , P.SeatPosition[1].y - 100)
}

return RoomViewPosition