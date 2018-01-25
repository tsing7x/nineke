

local T = require("boomegg.socket.PACKET_DATA_TYPE")
local P = {}

local PDENG_SOCKET_PROTOCOL = P
P.CONFIG = {}
P.CONFIG.CLIENT = {}
P.CONFIG.SERVER = {}
local CLIENT = P.CONFIG.CLIENT
local SERVER = P.CONFIG.SERVER

  
P.CLI_LOGIN_ROOM                 = 0x1701    --登录房间
P.CLI_LOGOUT_ROOM                = 0x1702    --用户请求离开房间
P.CLI_SET_BET                    = 0x1703    --用户下注
P.CLI_SEAT_DOWN                  = 0x1704    --用户请求坐下
P.CLI_STAND_UP                   = 0x1705    --用户请求站立
P.CLI_REQUEST_GRAB_DEALER        = 0x1706    --玩家请求上庄
P.CLI_OTHER_CARD                 = 0x1707    --用户请求第三张牌
P.CLI_SEND_DEALER_MONEY          = 0x1708    --赠送荷官钱
P.CLI_ADD_FRIEND                 = 0x1709    --加好友协议
P.CLI_SEND_CHIPS                 = 0x1710    --赠送筹码协议
P.CLI_SEND_EXPRESSION            = 0x1711    --请求发表情

CLIENT[P.CLI_LOGIN_ROOM] = {
    ver = 1,
    fmt = {
        {name = "tid", type = T.INT},   --桌子ID
        {name = "uid", type = T.INT},   --用户ID
        {name = "mtkey", type = T.STRING}, --需要验证的key
        {name = "userInfo", type = T.STRING}, --用户个人信息
        {name = "ExUserInfo", type = T.STRING}, --用户个人附加信息
        {name = "reqBanker",type = T.INT}       --是否抢庄登录 0：不是 1：是
    }
}

CLIENT[P.CLI_SEAT_DOWN] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.INT},   -- 座位ID
        {name = "ante", type = T.ULONG},    -- 携带金额      
        --{name = "autoBuyin", type = T.INT}  -- 自动买入
    }
}

CLIENT[P.CLI_SET_BET] = {
    ver = 1,
    fmt = {
        {name = "bet", type = T.ULONG} --下注
    }
}

CLIENT[P.CLI_OTHER_CARD] = {
    ver = 1,
    fmt = {
        {name = "type", type = T.INT} --是否需要第三张牌，0--不需要，1--需要
    }
}

CLIENT[P.CLI_REQUEST_GRAB_DEALER]     = {
    ver = 1,
    fmt = {
        {name = "handCoin",type = T.ULONG}--携带筹码
    }
}   

CLIENT[P.CLI_ADD_FRIEND] = {
    ver = 1,
    fmt = {
        {name="fromSeatId",type=T.BYTE},
        {name="toSeatId",type=T.BYTE},
        {name="friendId",type=T.INT}
    }
}

CLIENT[P.CLI_SEND_CHIPS] = {
    ver = 1,
    fmt = {
        {name="fromSeatId",type=T.BYTE},
        {name="chips",type=T.ULONG},
        {name="toSeatId",type=T.BYTE},
        {name="toUid",type=T.INT}
    }
}

CLIENT[P.CLI_SEND_EXPRESSION] = {
    ver = 1,
    fmt = {
        {name="expressionType", type=T.INT},--表情类型
        {name="expressionId", type=T.INT}, --表情ID
    }
}

-----------------------------------------------------------
-------------------  服务端返回  --------------------------
-----------------------------------------------------------

P.SVR_LOGIN_ROOM_OK              = 0x2721    --登录房间OK
SERVER[P.SVR_LOGIN_ROOM_OK] = {
    ver = 1,
    fmt = {
        {name = "tableId", type = T.INT},--桌子ID   
        {name = "tableStatus", type = T.BYTE}, --桌子当前状态 0牌局已结束 1下注中 2等待用户获取第3张牌
        {name = "curDealSeatId", type = T.INT},--如果为发第三张牌时，为当前询问发牌的座位
        {name = "baseAnte", type = T.ULONG},--底注
        {name = "totalAnte", type = T.ULONG},--桌子上的总筹码数量
        {name = "userAnteTime", type = T.BYTE}, -- 下注等待时间
        {name = "extraCardTime", type = T.BYTE}, -- 询问发第三张牌等待时间
        {name = "maxSeatCnt", type = T.BYTE}, -- 总的座位数量
        {name = "minAnte", type = T.ULONG},--最小携带
        {name = "maxAnte", type = T.ULONG},--最大携带
        {  
            name = "playerList", type = T.ARRAY,
            lengthType = T.INT,
            fmt = {
                {name = "uid", type = T.INT},--用户ID
                {name = "seatId", type = T.INT},--用户座位ID
                {name = "userInfo", type = T.STRING},--用户信息
                {name = "seatChips", type = T.ULONG},--用户携带
                {name = "betChips", type = T.ULONG},--当次下注
                {name = "win", type = T.INT},--玩家的赢次数
                {name = "lose", type = T.INT},--玩家的输次数
                {name = "isOnline", type = T.BYTE}, --（其他用户连接状态） 0--用户掉线   1--用户在线
                {name = "isPlay", type = T.BYTE},  -- 是否在玩牌
                {name = "isOutCard", type = T.INT}, -- 1 亮牌  0 不亮牌
                {name = "cardsCount", type = T.INT}, --用户手牌数量
                {name = "card1", type = T.USHORT, depends=function(ctx, row) return row.isOutCard == 1 end},--扑克牌数值, 无为0
                {name = "card2", type = T.USHORT, depends=function(ctx, row) return row.isOutCard == 1 end},
                {name = "card3", type = T.USHORT, depends=function(ctx, row) return row.isOutCard == 1 end}               
            }
        },
        {name = "banker_threshold", type = T.ULONG},--庄家门槛
        {  
            name = "candidates", type = T.ARRAY,
            lengthType = T.INT,
            fmt = {
                {name = "uid", type = T.INT},--用户ID
                {name = "money", type = T.ULONG},--用户钱数
                {name = "userInfo", type = T.STRING},--用户信息        
            }
        },
    }
}


P.SVR_LOGIN_ROOM_FAIL            = 0x2711    --登录房间失败
SERVER[P.SVR_LOGIN_ROOM_FAIL] = {
    ver = 1,
    fmt = {
        {name = "errorCode", type = T.USHORT}
    }
}

P.SVR_LOGOUT_ROOM_OK             = 0x2712    --登出房间OK
SERVER[P.SVR_LOGOUT_ROOM_OK] = {
    ver = 1,
    fmt = {
        {name = "raeson", type = T.BYTE},
        {name = "money", type = T.ULONG}--用户金币值
    }
}

P.SVR_SET_BET                    = 0x2713    --用户请求修改底注结果
SERVER[P.SVR_SET_BET] = {
    ver = 1,
    fmt = {
        {name = "ret", type = T.INT},-- 0--成功，1--失败
    }
}

P.SVR_SELF_SEAT_DOWN_OK                  = 0x2714
SERVER[P.SVR_SELF_SEAT_DOWN_OK] = {
    ver = 1,
    fmt = {
        {name = "ret", type = T.SHORT}   --0--成功，非0--失败   
    }
}

P.SVR_STAND_UP                   = 0x2715    --用户请求站起
SERVER[P.SVR_STAND_UP] = {
    ver = 1,
    fmt = {
        {name = "ret", type = T.INT},   --0--成功，非0--失败（庄家三局之内不能站起） 
        {name = "seatId", type = T.INT},
        {name = "chips", type = T.ULONG}--金额
    }
}

P.SVR_SELF_REQUEST_BANKER_OK            = 0x2716
SERVER[P.SVR_SELF_REQUEST_BANKER_OK] = {
    ver = 1,
    fmt = {
        {name = "ret", type = T.INT}  
    }
}

P.SVR_OTHER_CARD                        = 0x2717    --用户请求第三张牌结果
SERVER[P.SVR_OTHER_CARD] = {
    ver = 1,
    fmt = {      
        {name = "card", type = T.USHORT}
    }
}

P.SVR_WILL_KICK_OUT                     = 0x2719    --提示用户连续多局没操作，将被踢出房间 (G->C)
SERVER[P.SVR_WILL_KICK_OUT] = {
    ver = 1,
    fmt = {
        {name="count",type=T.BYTE}
    }
}


P.SVR_DEAL                              = 0x2720    --发牌,通知玩家手牌
SERVER[P.SVR_DEAL] = {
    ver = 1,
    fmt = {
        {  
            name = "cards", type = T.ARRAY,
            lengthType = T.INT,
            fmt = {
                {type = T.USHORT},   --扑克牌数值          
            }
        }
    }
}





P.SVR_BET                   = 0x2733    --服务器广播玩家下注
SERVER[P.SVR_BET] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.INT},
        {name = "currBetChips", type = T.ULONG}--下注金额
    }
}

P.SVR_SEAT_DOWN            = 0x2734    --服务器广播用户坐下
SERVER[P.SVR_SEAT_DOWN] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.INT},--座位ID
        {name = "uid", type = T.INT},--用户ID
        {name = "seatChips", type = T.ULONG}, --身上的总钱数,包括携带的值    
        {name = "exp", type = T.INT}, -- 经验
        {name = "win", type = T.INT},--用户赢次数
        {name = "lose", type = T.INT},--用户输次数
        {name = "userInfo", type = T.STRING}, --用户个人信息    
        {name = "exUserInfo", type = T.STRING}, --用户个人附加信息   
        {name = "platFlag", type = T.INT},--用户终端包类型
    }
}

P.SVR_OTHER_STAND_UP             = 0x2735    --服务器广播用户站起
SERVER[P.SVR_OTHER_STAND_UP] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}, 
        {name = "seatId", type = T.INT},         
    }
}

P.SVR_OTHER_REQUEST_BANKER       = 0x2736    --向其他用户广播用户请求当庄成功，将其添加到候选人列表 (G->C)
SERVER[P.SVR_OTHER_REQUEST_BANKER] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},--用户ID
        {name = "money", type = T.ULONG},--用户钱数
        {name = "userInfo", type = T.STRING},--用户信息         
    }
}

P.SVR_OTHER_CANCEL_BANKER       = 0x2737    --向其他用户广播用户请求当庄成功，将其添加到候选人列表 (G->C)
SERVER[P.SVR_OTHER_CANCEL_BANKER] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},  
        {name = "name", type = T.STRING},           
    }
}

P.SVR_GAME_START                 = 0x2738    --服务器广播游戏开始
SERVER[P.SVR_GAME_START] = {
    ver = 1,
    fmt = {
        {  
            name = "seatChipsList", type = T.ARRAY,
            lengthType = T.INT,
            fmt = {
                {name = "seatId", type = T.INT},  --座位ID
                {name = "seatChips", type = T.ULONG} --用户携带
            }
        },
        {name = "firstSeatId", type = T.INT}, --首先发牌的座位
    }
}

P.SVR_CARD_NUM                   = 0x2739  --服务器广播发牌开始
SERVER[P.SVR_CARD_NUM] =  {
    ver = 1,
    fmt = {
        {name = "totalAnte", type = T.ULONG} --桌子上的总筹码数量
    }
}


P.SVR_SHOW_CARD                  = 0x2740    --服务器广播用户亮牌
SERVER[P.SVR_SHOW_CARD] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.INT},
        {  
            name = "cards", type = T.ARRAY,
            lengthType = T.INT,
            fmt = {
                {type = T.USHORT},   --扑克牌数值          
            }
        }        
    }
}

P.SVR_CAN_OTHER_CARD             = 0x2741    --服务器广播可以开始获取第三张牌
SERVER[P.SVR_CAN_OTHER_CARD] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.INT}       
    }
}

P.SVR_OTHER_OTHER_CARD           = 0x2747    --服务器广播其它用户操作获取第三张牌结果
SERVER[P.SVR_OTHER_OTHER_CARD] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.INT},
        {name = "type", type = T.INT} --是否需要第三张牌，0--不需要，1--需要 
    }
}

P.SVR_GAME_OVER                  = 0x2748    --服务器广播牌局结束，结算结果
SERVER[P.SVR_GAME_OVER] = {
    ver = 1,
    fmt = {
        {  
            name = "playerList", type = T.ARRAY,
            lengthType = T.INT,
            fmt = {
                {name = "uid", type = T.INT},--用户ID
                {name = "seatId", type = T.INT},--玩家座位
                {name = "trunMoney", type = T.LONG}, --用户金币变化值               
                {name = "seatChips", type = T.ULONG},--携带金额
                {name = "betChips", type = T.ULONG},--用户该局总下注金额
                {name = "getExp", type = T.INT},--变化的经验值
                {  
                    name = "cards", type = T.ARRAY,
                    lengthType = T.INT,
                    fmt = {
                        {type = T.USHORT}   --扑克牌数值          
                    }
                }
            }
        }
    }
}

P.SVR_SEND_DEALER_CHIP_SUCC     = 0x2758
SERVER[P.SVR_SEND_DEALER_CHIP_SUCC] = {
    ver = 1,
    fmt = {
        {name="fromSeatId",type=T.BYTE},
        {name="money",type=T.ULONG},
        {name="chips",type=T.ULONG},
    }
}

P.SVR_ADD_FRIEND_SUCC           = 0x2759
SERVER[P.SVR_ADD_FRIEND_SUCC] = {
    ver = 1,
    fmt = {
        {name="fromSeatId",type=T.BYTE},
        {name="toSeatId",type=T.BYTE},
        {name="fromUid",type=T.INT},
        {name="toUid",type=T.INT}
    }
}


P.SVR_SEND_CHIPS_SUCC           = 0x2760
SERVER[P.SVR_SEND_CHIPS_SUCC] = {
    ver = 1,
    fmt = {
        {name="fromSeatId",type=T.BYTE},
        {name="fromUid",type=T.INT},
        {name="chips",type=T.ULONG},
        {name="toSeatId",type=T.BYTE},
        {name="toUid",type=T.INT}
    }
}

P.SVR_SEND_EXPRESSION           = 0x2761
SERVER[P.SVR_SEND_EXPRESSION] = {
    ver = 1,
    fmt = {
        {name="seatId", type=T.INT},        --发送表情的座位ID
        {name="uid",type=T.INT},            --发表情的UID
        {name="expressionType", type=T.INT},--表情类型
        {name="expressionId", type=T.UINT}, --表情ID
        {name="minusChips", type=T.LONG},    --表情扣筹码数
        {name="totalChips", type=T.LONG},    --发送表情之后的筹码数
    }
}

P.SVR_SEND_HDDJ_SUCC           = 0x2762
SERVER[P.SVR_SEND_HDDJ_SUCC] = {
    ver = 1,
    fmt = {
        {name="fromSeatId",type=T.INT},
        {name="daojuType",type=T.INT},
        {name="toSeatId",type=T.INT},
        {name="fromUid",type=T.INT},
        {name="toUid",type=T.INT},
    }
}

return PDENG_SOCKET_PROTOCOL