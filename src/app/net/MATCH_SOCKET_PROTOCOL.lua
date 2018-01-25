--
-- Author: Jonah0608@gmail.com
-- Date: 2015-06-27 10:41:33
--
local T = require("boomegg.socket.PACKET_DATA_TYPE")
local P = {}

local MATCH_SOCKET_PROTOCOL = P

P.CLI_LOGIN_HALL                = 0x116    --登录比赛场

P.CLI_REGISTER                  = 0x101    --注册
P.CLI_CANCEL_REGISTER           = 0x103    --取消注册
P.CLI_GET_COUNT                 = 0x131    --获取在线人数
P.CLI_JOIN_GAME                 = 0x113    --加入游戏

P.CLI_GET_REGED_COUNT           = 0x10B    --获取当前场次人数
P.SVR_REGED_COUNT               = 0x10C    --获取当前场次人数返回

P.SVR_LOGIN_SUCCESS_HALL        = 0x201    --登录比赛场成功
P.SVR_LOGIN_FAIL_HALL           = 0x203    --登录比赛场失败

P.SVR_REGISTER_RET              = 0x102    --报名注册返回的结果
P.SVR_CANCEL_REGISTER_RET       = 0x104    --取消报名注册返回的结果
P.SVR_GET_COUNT                 = 0x132    --获取在线人数

P.SVR_JOIN_GAME                 = 0x105    --加入游戏
P.SVR_JOIN_GAME_SUCC            = 0x210    --加入游戏成功

P.SVR_CMD_MATCH_REWARD          = 0x402    --比赛奖励

P.SVR_REGISTER_COUNT            = 0x108    --通知已经报名的人当前场次报名的人数
P.SVR_CANCEL_REGISTER           = 0x109    --只取消报名注册


P.CLI_GET_MATCH_STATUS          = 0x106    --获取已报比赛状态
P.SVR_MATCH_STATUS              = 0x107    --服务器通知比赛状态

P.CLISVR_HEART_BEAT             = 0x110    --心跳

P.UPDATE_USER_PROP              = 0x10A    --刷新道具

P.SET_PUSH_INFO                 = 0x150    --设置推送信息
P.GET_PUSH_INFO                 = 0x151    --获取推送信息
P.ON_GET_PUSH_INFO              = 0x152    --ON获取推送信息

-- 房间协议f
P.CLI_LOGIN                     = 0x1001    --登录房间
P.CLI_LOGOUT                    = 0x1002    --登出房间
P.CLI_SIT_DOWN                  = 0x1003    --坐下
P.CLI_STAND_UP                  = 0x1005    --站起
P.CLI_BET                       = 0x1004    --下注
P.CLI_SET_AUTO_SIT              = 0x1006    --请求自动坐下
P.CLI_UNSET_AUTO_SIT            = 0x1007    --请求取消自动坐下
P.CLI_SET_NEXT_STAND_UP         = 0x1011    --请求下局自动站起
P.CLI_SEND_ROOM_BROADCAST       = 0x1027    --请求送牌桌广播
P.CLI_SEND_EXPRESSION           = 0x1009    --请求发送表情
P.CLI_SEND_CHIPS                = 0x100C    --请求赠送筹码
P.CLI_SEND_GIFT                 = 0x100B    --请求赠送礼物
P.CLI_SEND_HDDJ                 = 0x100D    --请求发互动道具
P.CLI_SHOW_HAND_CARD            = 0x100A    --请求亮出手牌
P.CLI_ADD_FRIEND                = 0x100F    --请求加为牌友

-- 服务器包
P.SVR_LOGIN_SUCCESS             = 0x2001    --登录成功
P.SVR_LOGIN_FAIL                = 0x2002    --登录失败
P.SVR_LOGOUT_SUCCESS            = 0x2029    --登出成功

P.SVR_GAME_START                = 0x2007    --游戏开始
P.SVR_GAME_OVER                 = 0x200E    --游戏结束
P.SVR_SHOW_HANDCARD             = 0x2014    --亮出手牌
P.SVR_SIT_DOWN                  = 0x2005    --坐下
P.SVR_SIT_DOWN_FAIL             = 0x2004    --坐下失败
P.SVR_STAND_UP                  = 0x2006    --站起
P.SVR_BET_SUCCESS               = 0x2008    --下注成功
P.SVR_BET_FAIL                  = 0x2003    --下注失败
P.SVR_DEAL_THIRD_CARD           = 0x2009    --发第三张牌（仅限专业场）
P.SVR_TURN_TO_BET               = 0x200C    --轮到座位下注
P.SVR_POT                       = 0x200D    --奖池

P.SVR_ROOM_DEALER               = 0x2022    --广播荷官
P.SVR_ALL_TITLES                = 0x202E    --广播所有玩家称号
P.SVR_ADD_FRIEND                = 0x201A    --广播用户加牌友
P.SVR_SEND_CHIPS_SUCCESS        = 0x2016    --赠送筹码成功
P.SVR_SEND_CHIPS_FAIL           = 0x2018    --赠送筹码失败
P.SVR_SEND_HDDJ                 = 0x2017    --发送互动道具
P.SVR_SEND_EXPRESSION           = 0x2012    --发送表情
P.SVR_CMD_USER_CRASH            = 0x2013    --SVR返回破产包
P.SVR_SEND_ROOM_BROADCAST       = 0x2011    --发送牌桌广播
P.CLI_CMD_SEND_DEALER_MONEY     = 0x1014    --CLI请求给荷官送筹码
P.SVR_CMD_SEND_DEALER_CHIP_SUCC = 0x2027    --SVR通知赠送荷官筹码成功
P.SVR_CMD_SEND_DEALER_CHIP_FAIL = 0x2028    --SVR通知赠送荷官筹码失败

P.SVR_KICKED_BY_ADMIN           = 0x2032    -- 被管理员踢出房间
P.SVR_KICKED_BY_USER            = 0x2033    -- 被用户踢出房间
P.SVR_KICKED_BY_USER_MSG        = 0x2019    -- 被用户踢出房间提醒

P.SVR_CMD_SERVER_UPGRADE        = 0x2100    -- 服务器升级
P.SVR_CMD_SERVER_STOP           = 0x2101    -- 停服

P.SVR_CMD_USER_MATCH_SCORE      = 0x2307    -- 结束比赛征程
P.SVR_CMD_USER_MATCH_RISECHIP   = 0x2308    -- 倒计时 涨盲
P.SVR_CMD_USER_MATCH_RANK       = 0x230C    -- 游戏排名
P.SVR_CMD_CHANGE_ROOM           = 0x230B    -- 等待换桌

P.SVR_CMD_HUNTING               = 0x2041    -- 猎杀奖励

P.SVR_CMD_REBUYUSER             = 0x2048   -- 通知是rebuy的玩家
P.SVR_CMD_REBUY                 = 0x2047   -- rebuy通知
P.SVR_CMD_REBUYRESULT           = 0x2046   -- rebuy结果
P.CLI_CMD_REBUY                 = 0x2045   -- 客户端选择购买

P.CONFIG = {
--[[
    客户端包，对于空包体，可以允许不定义协议内容，将默认版本号为1，包体长度为0
]]
    -- 登录比赛场
    [P.CLI_LOGIN_HALL] = {
        ver = 1,
        fmt = {
            { name = "uid", type = T.UINT },   -- 用户ID
            { name = "info" , type = T.STRING } -- 用户信息，json格式
        }
    },


--[[
    服务器包
]]
    -- 登录成功
    [P.SVR_LOGIN_SUCCESS_HALL] = {
        ver = 1,
        fmt = {
            -- { name = "levelcount", type = T.UINT },
            { name = "matchlevel", type = T.UINT },
            -- { name = "matchid", type = T.STRING },
            { name = "tid", type = T.UINT },
            { name = "ip", type = T.STRING },
            { name = "port", type = T.UINT },
            { name = "time", type = T.INT},
            -- {
            --     name = "info",
            --     type = T.ARRAY,
            --     lengthType = T.INT,
            --     fmt = {
            --         { name = "matchlevel", type=T.UINT },--比赛等级
            --         { name = "matchid", type=T.STRING},--该等级是否已经报名
            --     }
            -- },
        }
    },
    -- 登录失败
    [P.SVR_LOGIN_FAIL_HALL] = {
        ver = 1,
        fmt = {
            { name = "errorCode", type = T.USHORT }
        },
    },

    [P.CLI_REGISTER] = {
        ver = 1,
        fmt = {
            { name = "matchlevel", type = T.INT },
            { name = "userinfo", type = T.STRING }
        }
    },

    [P.CLI_CANCEL_REGISTER] = {
        ver = 1,
        fmt = {
            { name = "matchlevel", type = T.INT },
            {name = "matchid", type = T.STRING}
            
        }
    },

    [P.CLI_GET_COUNT] = {
        ver = 1,
        fmt = {
            {
                name = "list",
                type = T.ARRAY,
                lengthType = T.INT,
                fmt = {
                    {name = "level",type=T.INT},
                }
            }
        }
    },

    [P.CLI_JOIN_GAME] = {
        ver = 1,
        fmt = {
            { name = "level", type = T.INT },
            {name = "matchid", type = T.STRING}
            
        }
    },

    [P.SVR_REGISTER_RET] = {
        ver = 1,
        fmt = {
            { name = "ret", type = T.INT },
            { name = "matchlevel", type = T.INT },
            { name = "matchid", type = T.STRING }
        }
    },

    [P.SVR_CANCEL_REGISTER_RET] = {
        ver = 1,
        fmt = {
            { name = "ret", type = T.INT},
            { name = "matchlevel" , type = T.INT},
            -- { name = "matchid" , type = T.STRING }
        }
    },
    
    [P.SVR_CANCEL_REGISTER] = {
        ver = 1,
        fmt = {
            { name = "matchlevel" , type = T.INT},
            { name = "matchid" , type = T.STRING },
            { name = "reason" , type = T.INT } -- (取消比赛原因，1--未入场（客户端没发113），2--人数不足（入场），3--人数不足（报名），4--未入场（客户端发了113，但是没发1001或者是超时发1001【入场时间过了】）5--系统维护退券)
        }
    },

    [P.SVR_GET_COUNT] = {
        ver = 1,
        fmt = {
            { 
                name = "levels",
                type = T.ARRAY,
                lengthType = T.INT,
                fmt = {
                    { name = "level", type=T.INT },--等级
                    { name = "usercount", type=T.INT},--接收人座位ID
                    -- { name = "registerusercount", type=T.INT},--接收人uid
                }
            },
        }
    },

    [P.SVR_JOIN_GAME] = {
        ver = 1,
        fmt = {
            { name = "joinTime", type = T.INT},
            { name = "matchlevel", type = T.INT},
            { name = "matchid", type = T.STRING},
        }
    },
    [P.SVR_JOIN_GAME_SUCC] = {
        ver = 1,
        fmt = {
            { name = "tid", type = T.INT },
            { name = "serverid", type = T.INT },
            { name = "matchlevel", type = T.INT },
            { name = "ret", type = T.INT },
            { name = "ip", type = T.STRING },
            { name = "port", type = T.INT },
            { name = "matchid", type = T.STRING }
        }
    },


    -- 房间内协议
        -- 登录房间
    [P.CLI_LOGIN] = {
        ver = 1,
        fmt = {
            {name = "tid"    , type = T.UINT}   , -- 房间ID
            {name = "matchid", type = T.STRING } ,
            {name = "uid"    , type = T.UINT}   , -- uid
            {name = "mtkey"  , type = T.STRING} , -- mtkey
            {name = "img"    , type = T.STRING} , -- 头像
            {name = "giftId" , type = T.INT}    , -- 礼物ID
            {name = "nick"   , type = T.STRING} , -- 匿名
            {name = "gender" , type = T.STRING} , -- 性别
            {name = "userInfo", type = T.STRING} , -- 扩展数据(json字符串)
        }
    },

    --坐下
    [P.CLI_SIT_DOWN] = {
        ver = 1,
        fmt = {
            {name="seatId", type=T.BYTE},        --座位ID
            {name="buyIn", type=T.ULONG},        --买入筹码
        },
    },

    --下注
    [P.CLI_BET] = {
        ver = 1,
        fmt = {
            {name="betType", type=T.BYTE},        --下注类型
            {name="betChips", type=T.ULONG},    --下注筹码数
        },
    },

    --发送牌桌广播
    [P.CLI_SEND_ROOM_BROADCAST] = {
        ver = 1,
        fmt = {
            {name="tid"     , type=T.INT}    , --tid
            {name="param"   , type=T.INT}    , --预留int
            {name="content" , type=T.STRING} , --内容
        }
    },

    --发送表情
    [P.CLI_SEND_EXPRESSION] = {
        ver = 1,
        fmt = {
            {name="expressionType", type=T.INT},--表情类型
            {name="expressionId", type=T.UINT}, --表情ID
        }
    },

    --请求赠送筹码
    [P.CLI_SEND_CHIPS] = {
        ver = 1,
        fmt = {
            {name="fromSeatId", type=T.BYTE},    --赠送人座位ID
            {name="chips", type=T.ULONG},        --赠送筹码数量
            {name="toSeatId", type=T.BYTE},        --接收人座位ID
        }
    },

    --请求赠送礼物
    [P.CLI_SEND_GIFT] = {
        ver = 1,
        fmt = {
            {name="fromSeatId", type=T.BYTE},    --赠送人座位ID
            {name="giftId", type=T.UINT},         --礼物ID
            {
                name="to",
                type=T.ARRAY,
                fmt = {
                    {name="toSeatId", type=T.BYTE},--接收人座位ID
                    {name="toUid", type=T.UINT},--接收人uid
                }
            },
        }
    },

    --请求发送互动道具
    [P.CLI_SEND_HDDJ] = {
        ver = 1,
        fmt = {
            {name="fromSeatId", type=T.BYTE},    --发送人座位ID
            {name="hddjId", type=T.UINT},         --互动道具ID
            {name="toSeatId", type=T.BYTE},     --接收人座位ID
        }
    },

    --请求加牌友
    [P.CLI_ADD_FRIEND] = {
        ver = 1,
        fmt = {
            {name="fromSeatId", type=T.BYTE},    --发送人座位ID
            {name="toSeatId", type=T.BYTE},     --接收人座位ID
        }
    },

--[[
    服务器包
]]

    -- 登录成功
    [P.SVR_LOGIN_SUCCESS] = {
        ver = 1,
        fmt = {
            {name = "blind"        , type = T.ULONG } , --盲注
            {name = "minBuyIn"     , type = T.ULONG}  , --最小携带
            {name = "maxBuyIn"     , type = T.ULONG}  , --最大携带
            {name = "roomName"     , type = T.STRING} , --房间名字
            {name = "roomType"     , type = T.UINT}   , --房间场别
            {name = "roomField"    , type = T.UINT}   , --房间级别
            {name = "userChips"    , type = T.ULONG}  , --用户带入筹码数
            {name = "betExpire"    , type = T.INT}    , --下注最大时间
            {name = "gameStatus"   , type = T.BYTE}   , --游戏状态
            {name = "seatNum"      , type = T.BYTE}   , --座位数
            {name = "roundCount"   , type = T.UINT}   , --牌局数id
            {name = "dealerSeatId" , type = T.BYTE}   , --前一局庄家座位ID
            {    --奖池
                name="pots",
                type=T.ARRAY,
                fmt = {type=T.ULONG}
            },
            {name="bettingSeatId", type=T.BYTE},--正在下注的座位ID
            {name="callChips", type=T.ULONG, depends=function(ctx, row) return ctx.bettingSeatId ~= -1 end},        --跟注需要钱数
            {name="minRaiseChips", type=T.ULONG, depends=function(ctx, row) return ctx.bettingSeatId ~= -1 end},    --加注最小钱数
            {name="maxRaiseChips", type=T.ULONG, depends=function(ctx, row) return ctx.bettingSeatId ~= -1 end},    --加注最大钱数
            {    --每个用户的信息(已经坐下的)
                name="playerList",
                type=T.ARRAY,
                fmt = {
                    {name = "seatId"    , type = T.BYTE}   , --座位ID
                    {name = "uid"       , type = T.UINT}   , --用户id
                    {name = "chips"     , type = T.ULONG}  , --用户钱数
                    {name = "exp"       , type = T.UINT}   , --用户经验
                    {name = "vip"       , type = T.BYTE}   , --VIP标识
                    {name = "nick"      , type = T.STRING} , --用户昵称
                    {name = "gender"    , type = T.STRING} , --用户性别
                    {name = "img"       , type = T.STRING} , --用户头像
                    {name = "win"       , type = T.UINT}   , --用户赢局数
                    {name = "lose"      , type = T.UINT}   , --用户输局数
                    {name = "userInfo"  , type = T.STRING} , --用户基本信息
                    {name = "exUserInfo"  , type = T.STRING} , --用户扩展信息
                    {name = "giftId"    , type = T.INT}    , --礼物ID
                    {name = "seatChips" , type = T.ULONG}  , --座位的钱数
                    {name = "betChips"  , type = T.ULONG}  , --座位的总下注数
                    {name = "betState"  , type = T.BYTE}   , --下注类型(座位状态)
                }
            },
            {name="handCardFlag", type=T.BYTE},        --是否有手牌
            {    --手牌
                name="handCards",
                type=T.ARRAY,
                depends=function(ctx) return ctx.handCardFlag == 1 end,
                fixedLength=3,
                fmt={ type=T.USHORT}
            },
            {name="cardType", type=T.BYTE, depends=function(ctx) return ctx.handCardFlag == 1 end},     --牌型
            {name="cardPoint", type=T.BYTE, depends=function(ctx) return ctx.handCardFlag == 1 end},     --牌点
            {
                name="platFlags",
                type=T.ARRAY,
                fixedLength= 5,  -- TODO:人数需要根据seatNum来配置
                fmt={type=T.UINT}
            },
            {name="roomFlag", type=T.INT},        --桌子flag（快速场等）
        }
    },

    --登录失败
    [P.SVR_LOGIN_FAIL] = {
        ver = 1,
        fmt = {
            {name="errorCode", type=T.USHORT}    --失败原因代码
        },
    },

    --登出成功
    [P.SVR_LOGOUT_SUCCESS] = { ver = 1},

    --游戏开始
    [P.SVR_GAME_START] = {
        ver = 1,
        fmt = {
            {name="roundCount", type=T.UINT},    --牌局数id
            {name="dealerSeatId", type=T.BYTE},    --庄家座位ID
            {    --每个用户的信息(在玩)
                name="playerList",
                type=T.ARRAY,
                fmt = {
                    {name="seatId", type=T.BYTE},    --座位ID
                    {name="uid", type=T.UINT},        --用户id
                    {name="seatChips", type=T.ULONG},    --座位用户钱数
                }
            },
            {name="handCard1", type=T.USHORT},        --手牌1
            {name="handCard2", type=T.USHORT},        --手牌2
            {name="handCard3", type=T.USHORT},        --手牌3
            {name="cardType", type=T.BYTE},         --牌型
            {name="cardPoint", type=T.BYTE},         --点数
            {name="userChips", type=T.ULONG},        --用户钱数
        }
    },

    --游戏结束
    [P.SVR_GAME_OVER] = {
        ver = 1,
        fmt = {
            {    --座位筹码经验变化信息
                name="seatChangeList",
                type=T.ARRAY,
                fixedLength=5,
                fmt = {
                    {name="exp", type=T.INT},        --经验变化
                    {name="seatChips", type=T.LONG},--筹码变化
                }
            },
            {    --座位牌型信息
                name="playerCardsList",
                type=T.ARRAY,
                fmt = {
                    {name="seatId", type=T.BYTE},        --座位ID
                    {name="handCard1", type=T.USHORT},    --手牌1
                    {name="handCard2", type=T.USHORT},    --手牌2
                    {name="handCard3", type=T.USHORT},    --手牌3
                    {name="cardType", type=T.BYTE},     --牌型
                    {name="cardPoint", type=T.BYTE},     --点数

                }
            },
            {    --奖池信息
                name="potsList",
                type=T.ARRAY,
                fmt={
                    {name="winChips", type=T.LONG},        --赢取筹码数
                    {name="seatId", type=T.BYTE},        --座位ID
                    {name="uid", type=T.UINT},            --用户id
                    {name="cardType", type=T.BYTE},     --牌型
                    {name="cardPoint", type=T.BYTE},     --点数
                    {name="handCard1", type=T.USHORT},    --手牌1
                    {name="handCard2", type=T.USHORT},    --手牌2
                    {name="handCard3", type=T.USHORT},    --手牌3
                }
            },
            {    name="fee", type=T.ULONG, optional=true},--台费
            {    name="lastPotIsNotWinChips", type=T.INT, optional=true}, --最后一个奖池是否真的赢钱了   -1 赢钱 other 座位ID，奖池代表收回筹码
        }
    },

    --用户坐下
    [P.SVR_SIT_DOWN] = {
        ver = 1,
        fmt = {
            {name="seatId", type=T.BYTE},        --座位ID
            {name="uid", type=T.UINT},            --用户id
            {name="nick", type=T.STRING},        --用户昵称
            {name="gender", type=T.STRING},        --用户昵称
            {name="chips", type=T.ULONG},        --总筹码数
            {name="exp", type=T.UINT},            --用户经验
            {name="vip", type=T.BYTE},            --VIP标识
            {name="img", type=T.STRING},        --用户头像
            {name="win", type=T.UINT},            --用户赢局数
            {name="lose", type=T.UINT},            --用户输局数
            {name="curPlace", type=T.STRING},    --用户所在地
            {name="homeTown", type=T.STRING},    --用户家乡
            {name="giftId", type=T.INT},        --礼物ID
            {name="seatChips", type=T.ULONG},    --买入筹码数
            {name="platFlag", type=T.INT},        --平台标识
            {name = "userInfo", type = T.STRING} , -- 扩展数据(json字符串)
        },
    },

    --坐下失败
    [P.SVR_SIT_DOWN_FAIL] = {
        ver = 1,
        fmt = {
            {name="errorCode", type=T.USHORT}    --失败原因代码
        },
    },

    --站起
    [P.SVR_STAND_UP] = {
        ver = 1,
        fmt = {
            {name="seatId", type=T.BYTE},        --座位ID
            {name="chips", type=T.ULONG},        --用户筹码
        },
    },

    --下注
    [P.SVR_BET_SUCCESS] = {
        ver = 1,
        fmt = {
            {name="seatId", type=T.BYTE},        --座位ID
            {name="betState", type=T.BYTE},        --下注类型
            {name="betChips", type=T.ULONG},    --下注筹码数
        },
    },

    --下注失败
    [P.SVR_BET_FAIL] = {
        ver = 1,
        fmt = {
            {name="errorCode", type=T.USHORT},    --错误代码
            {name="totalChips", type=T.ULONG},    --用户实时筹码数
            {name="seatId", type=T.BYTE},        --座位ID
            {name="roundBetChips", type=T.ULONG},--回合下注总筹码数
            {name="leftChips", type=T.ULONG},    --玩家实时剩余筹码数
        },
    },

    --奖池
    [P.SVR_POT] = {
        ver = 1,
        fmt = {
            {name="pots", type=T.ARRAY, fmt={type=T.ULONG}}--奖池
        },
    },

    --发第三张牌
    [P.SVR_DEAL_THIRD_CARD] = {
        ver = 1,
        fmt = {
            {name="handCard3", type=T.USHORT},    --发第三张牌
            {name="cardType", type=T.BYTE},     --牌型
            {name="cardPoint", type=T.BYTE},     --点数
        },
    },

    --亮出手牌
    [P.SVR_SHOW_HANDCARD] = {
        ver = 1,
        fmt = {
            {name="seatId", type=T.BYTE},        --座位ID
            {name="cardCount", type=T.BYTE},    --牌局结束，已经发了几张牌；2或3
            {name="handCard1", type=T.USHORT},    --手牌1
            {name="handCard2", type=T.USHORT},    --手牌2
            {name="handCard3", type=T.USHORT, depends=function(ctx) return ctx.cardCount == 3 end},    --手牌3
            {name="cardType", type=T.BYTE, depends=function(ctx) return ctx.cardCount == 3 end},    --牌型 cardType==1
            {name="pointcount", type=T.BYTE, depends=function(ctx) return ctx.cardCount == 3 end}    --点数
        },
    },

    --轮到座位下注
    [P.SVR_TURN_TO_BET] = {
        ver = 1,
        fmt = {
            {name="seatId", type=T.BYTE},        --轮到下注的座位ID
            {name="callChips", type=T.ULONG},    --跟注需要的金额
            {name="minRaiseChips", type=T.ULONG},--最小加注金额
            {name="maxRaiseChips", type=T.ULONG},--最大加注金额
        },
    },

    --荷官
    [P.SVR_ROOM_DEALER] = {    
        ver = 1,
        fmt = {
            {name="myDealerId", type=T.INT},            --我的荷官ID
            {name="roomDealerId", type=T.INT},            --当前房间荷官ID
            {name="setterUid", type=T.UINT},            --设置当前荷官的用户uid
            {name="setterName", type=T.STRING},            --设置当前荷官的用户名
            {name="bit", type=T.ULONG},                    --
            {name="lotterAutoBuy", type=T.INT},            --大乐透 -
            {name="lotterNextBuy", type=T.INT},            --大乐透 -
            {name="lotterBuyIn", type=T.ULONG, optional=true},--大乐透 -
            {name="lotterOdds1", type=T.UBYTE, optional=true},--大乐透 -
            {name="lotterOdds2", type=T.UBYTE, optional=true},--大乐透 -
            {name="lotterOdds3", type=T.UBYTE, optional=true},--大乐透 -
        }
    },

    --所有玩家称号
    [P.SVR_ALL_TITLES] = {
        ver = 1,
        fmt = function(ctx, buf) 
            buf:setPos(9)
            while buf:getAvailable() > 0 do
                ctx[#ctx + 1] = { uid = buf:readUInt(), tid = buf:readUInt() }
                --print(dump(ctx[#ctx]), buf:getAvailable())
            end
        end
    },

    --广播用户加牌友
    [P.SVR_ADD_FRIEND] = {
        ver = 1,
        fmt = {
            {name="fromSeatId", type=T.BYTE},    --发送人座位ID
            {name="toSeatId", type=T.BYTE},     --接收人座位ID
        }
    },

    --广播赠送筹码
    [P.SVR_SEND_CHIPS_SUCCESS] = {
        ver = 1,
        fmt = {
            {name="fromSeatId", type=T.BYTE},    --发送人座位ID
            {name="chips", type=T.ULONG},        --赠送筹码数额
            {name="toSeatId", type=T.BYTE},     --接收人座位ID
        },
    },

    --赠送筹码失败
    [P.SVR_SEND_CHIPS_FAIL] = {
        ver = 1,
        fmt = {
            {name="errorCode", type=T.USHORT}    --失败原因代码
        },
    },

    --发送互动道具
    [P.SVR_SEND_HDDJ] = {
        ver = 1,
        fmt = {
            {name="fromSeatId", type=T.BYTE},    --发送人座位ID
            {name="hddjId", type=T.UINT},         --互动道具ID
            {name="toSeatId", type=T.BYTE},     --接收人座位ID
            {name="uid", type=T.UINT},            --接收人用户id
        }
    },

    --发送表情
    [P.SVR_SEND_EXPRESSION] = {
        ver = 1,
        fmt = {
            {name="seatId", type=T.BYTE},        --发送表情的座位ID
            {name="expressionType", type=T.INT},--表情类型
            {name="expressionId", type=T.UINT}, --表情ID
            {name="minusChips", type=T.LONG},    --表情扣筹码数
            {name="totalChips", type=T.LONG},    --发送表情之后的筹码数
        },
    },

    --发送表情
    [P.SVR_CMD_USER_CRASH] = {
        ver = 1,
        fmt = {
            {name="times", type=T.BYTE},        --破产次数
            {name="subsidizeChips", type=T.LONG},--破产之后额外加的钱数
        },
    },


    [P.SVR_CMD_SEND_DEALER_CHIP_SUCC] = {
        ver = 1,
        fmt = {
            {name="fromSeatId", type=T.BYTE},        --赠送者ID
            {name="allChips", type=T.LONG},--总钱数
            {name="chips", type=T.LONG},--赠送的筹码数量
            {name="toSeatId", type=T.BYTE},--被接受者ID
        },
    },

    [P.SVR_CMD_SEND_DEALER_CHIP_FAIL] = {
        ver = 1, 
        fmt = {
            {name="code", type=T.SHORT},    --失败代码
        },
    },

    [P.SVR_CMD_SERVER_UPGRADE] = {ver = 1},
    [P.SVR_CMD_SERVER_STOP] = {ver = 1},

    [P.SVR_KICKED_BY_ADMIN] = {
        ver = 1,
        fmt = {
            {name="param1", type=T.INT},        --保留字段1   tid
            {name="param2", type=T.STRING},        --保留字段2
        },
    },
    [P.SVR_KICKED_BY_USER] = {
        ver = 1,
        fmt = {
            {name="param1", type=T.INT},        --保留字段1 uid
            {name="param2", type=T.INT},        --保留字段2 tid
            {name="param3", type=T.STRING},        --保留字段3 nick
        },
    },
    [P.SVR_KICKED_BY_USER_MSG] = {
        ver = 1,
        fmt = {
            {name="param1", type=T.INT},        --保留字段1 发起踢人的用户uid
            {name="param2", type=T.INT},        --保留字段2 tid
            {name="param3", type=T.STRING},        --保留字段3 发起踢人的用户nick
        },
    },
    [P.SVR_CMD_USER_MATCH_SCORE] = {
        ver = 1,
        fmt = {
            {name="totalCount", type=T.INT},
            {name="selfRank", type=T.INT},
        },
    },
    [P.SVR_CMD_USER_MATCH_RANK] = {
        ver = 1,
        fmt = {
            {name="totalCount", type=T.INT},
            {name="selfRank", type=T.INT},
            {name="maxMoney", type=T.LONG},
            {name="averMoney", type=T.LONG},
        },
    },
    [P.SVR_CMD_USER_MATCH_RISECHIP] = {
        ver = 1,
        fmt = {
            {name="times", type=T.INT},
            {name="leftTime", type=T.INT},
            {name="currentChip", type=T.ULONG},
        },
    },
    [P.SVR_CMD_MATCH_REWARD] = {
        ver = 1,
        fmt = {
            {name="type",type=T.USHORT},
            {name="info",type=T.STRING},
        },
    },    
    [P.SVR_CMD_CHANGE_ROOM] = {ver = 1},
    [P.SVR_REGISTER_COUNT] = {
        ver = 1,
        fmt = {
            {name="matchlevel", type=T.INT},
            {name="matchid", type=T.STRING},
            {name="userCount", type=T.INT},
        },
    },
    [P.SVR_CMD_HUNTING] = { --猎杀
        ver = 1,
        fmt = {
            {name="huntUid", type=T.INT},
            {name="huntReward", type=T.INT},
        },
    },
    -- 比赛状态
    [P.CLI_GET_MATCH_STATUS] = {
        ver = 1,
        fmt = {
            { name = "matchlevel", type = T.UINT },     -- 比赛等级
            -- { name = "matchid" , type = T.STRING },     -- 用户信息，json格式
        },
    },
    [P.SVR_MATCH_STATUS] = {
        ver = 1,
        fmt = {
            -- { name = "ret", type = T.UINT },
            { name = "matchlevel", type = T.UINT },
            { name = "matchid", type = T.STRING },
            { name = "status", type = T.INT },
        }
    },
    [P.UPDATE_USER_PROP] = {
        ver = 1,
        fmt = {
            {
                name = "count",
                type = T.ARRAY,
                lengthType = T.INT,
                fmt = {
                    { name = "pid", type=T.INT },--ID
                    { name = "num", type=T.UINT, depends=function(ctx,row) return row.pid ~= 4 and row.pid ~= 5 and row.pid ~= 6 end},--数量
                    { name = "money", type=T.LONG, depends=function(ctx,row) return row.pid == 4 end},--金币
                    { name = "score", type=T.LONG, depends=function(ctx,row) return row.pid == 5 end},--现金币
                    { name = "gcoins", type=T.LONG, depends=function(ctx,row) return row.pid == 6 end},--黄金币
                }
            },
        }
    },
    [P.SET_PUSH_INFO] = {
        ver = 1,
        fmt = {
            {name = "matchlevel", type = T.INT},
            {name = "open", type = T.INT},
        }
    },
    [P.GET_PUSH_INFO] = {
        ver = 1,
        fmt = {
            {name = "matchlevel", type = T.INT}
        }
    },
    [P.ON_GET_PUSH_INFO] = {
        ver = 1,
        fmt = {
            {name = "matchlevel", type = T.INT},
            {name = "open", type = T.INT},
        }
    },
    [P.CLI_GET_REGED_COUNT] = {
        ver = 1,
        fmt = {
            { name = "matchlevel", type = T.UINT },
        }
    },
    [P.SVR_REGED_COUNT] = {
        ver = 1,
        fmt = {
            {name="matchlevel", type=T.INT},
            {name="userCount", type=T.INT},
        }
    },
    [P.SVR_CMD_REBUY] = {
        ver = 1,
        fmt = {
            {name="money", type=T.LONG}, -- 买入的金币数量
            {name="time", type=T.INT},  -- 买入思考的时间
        }
    },
    [P.SVR_CMD_REBUYRESULT] = {
        ver = 1,
        fmt = {
            {name="err", type=T.INT},  -- 0 成功 其他的失败
            {name="pid", type=T.INT}, -- 消耗报名费类型
            {name="count", type=T.LONG}, -- 消耗金额
        }
    },
    [P.CLI_CMD_REBUY] = {
        ver = 1,
        fmt = {
            {name="rebuy_type", type=T.INT}, -- 买入类型  -1 : 取消rebuy  1 : 1/4人均筹码  2 : 一半人均筹码  3 : 人均筹码  4 : 2倍人均筹码
        }
    },
    [P.SVR_CMD_REBUYUSER] = {
        ver = 1,
        fmt = {
            {
                name = "rebuyList",
                type = T.ARRAY,
                lengthType = T.INT,
                fmt = {
                    {name = "uid",type=T.INT},
                }
            }
        }
    }
}

P.CONFIG[P.SVR_SEND_ROOM_BROADCAST] = P.CONFIG[P.CLI_SEND_ROOM_BROADCAST]

return MATCH_SOCKET_PROTOCOL