--
-- Author: Jonah0608@gmail.com
-- Date: 2016-08-31 17:47:06
--
local DiceViewPosition = {}
local P = DiceViewPosition
P.SeatPosition = {
    cc.p(display.cx - (display.cx + 370) /2,display.cy + 150),
    cc.p(display.cx + (display.cx + 370) /2,display.cy + 150),
    cc.p(display.cx - (display.cx + 370) /2,display.cy + 50),
    cc.p(display.cx + (display.cx + 370) /2,display.cy + 50),
    cc.p(display.cx - (display.cx + 370) /2,display.cy - 50),
    cc.p(display.cx + (display.cx + 370) /2,display.cy - 50),
    cc.p(display.cx - (display.cx + 370) /2,display.cy - 150),
    cc.p(display.cx + (display.cx + 370) /2,display.cy - 150),
    cc.p(144,53),
    cc.p(display.width - 132,display.height - 42)
}

P.BetTypePosition = {
    cc.p(display.cx - 246,display.cy - 39),  --点牌
    cc.p(display.cx,display.cy - 39),        --同花
    cc.p(display.cx + 246,display.cy - 39),  --顺子
    cc.p(display.cx - 246,display.cy - 135), --小三公
    cc.p(display.cx,display.cy - 135),       --同花顺
    cc.p(display.cx + 246,display.cy - 135), --三张
    cc.p(display.cx - 185,display.cy + 88),  --牌1赢
    cc.p(display.cx + 185,display.cy + 88)   --牌2赢
}

P.BetTypeArea = {
    cc.size(246,66),
    cc.size(246,66),
    cc.size(246,66),
    cc.size(246,66),
    cc.size(246,66),
    cc.size(246,66),
    cc.size(366,128),
    cc.size(366,128)
}

P.DealPosition = {
    cc.p(300,display.height - 70),
    cc.p(display.width - 300,display.height - 70)
}

return DiceViewPosition