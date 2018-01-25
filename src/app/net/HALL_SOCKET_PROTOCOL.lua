--
-- Author: Jonah0608@gmail.com
-- Date: 2016-01-11 15:39:49
--
local T = require("boomegg.socket.PACKET_DATA_TYPE")
local PDENG_SOCKET_PROTOCOL = import(".PDENG_SOCKET_PROTOCOL")
local P = {}


local HALL_SOCKET_PROTOCOL = P
P.CONFIG = {}

-- 大厅协议
P.HALL_CLI_LOGIN                = 0x701    --登录大厅
P.HALL_SVR_LOGIN_OK             = 0x702    --登录大厅成功
P.HALL_CLI_LOGIN_ROOM           = 0x711    --登录房间
P.HALL_SVR_LOGIN_ROOM_RESULT    = 0x712    --登录房间成功

-- 广播协议
P.BROADCAST_PERSON              = 0x40A    --个人广播
P.BROADCAST_SYSTEM              = 0x40B    --系统广播

P.HALL_SVR_DOUBLELOGIN          = 0x203    --重复登录


-- 房间内协议
-- 客户端请求
P.CLI_LOGIN                     = 0x1001    --登录房间
P.CLI_LOGOUT                    = 0x1002    --登出房间
P.CLI_SIT_DOWN                  = 0x1003    --坐下
P.CLI_STAND_UP                  = 0x1005    --站起
P.CLI_BET                       = 0x1004    --下注
P.CLI_SET_AUTO_SIT              = 0x1006    --请求自动坐下
P.CLI_UNSET_AUTO_SIT            = 0x1007    --请求取消自动坐下
P.CLI_SET_NEXT_STAND_UP         = 0x1011    --请求下局自动站起
P.CLI_SEND_ROOM_BROADCAST       = 0x1027    --请求发送牌桌广播
P.CLI_SEND_EXPRESSION           = 0x1009    --请求发送表情
P.CLI_SEND_CHIPS                = 0x100C    --请求赠送筹码
P.CLI_SEND_GIFT                 = 0x100B    --请求赠送礼物
P.CLI_SEND_HDDJ                 = 0x100D    --请求发互动道具
P.CLI_SHOW_HAND_CARD            = 0x100A    --请求亮出手牌
P.CLI_ADD_FRIEND                = 0x100F    --请求加为牌友

P.CLI_MODIFY_USERINFO           = 0x1028    --客户端请求更换个人信息

P.CLI_DROP_CARD_4K              = 0x1101    --请求弃牌
P.CLI_FOLD_CARD_4K              = 0x1102    --折叠剩余的牌

P.CLI_LOGIN_DICE                = 0x1501    -- 请求登录骰子场
P.CLI_LOGOUT_DICE               = 0x1502    -- 用户请求登出
P.CLI_BET_DICE                  = 0x1503    --用户请求下注
P.CLI_GET_HISTORY               = 0x1029    --请求历史数据
P.CLI_GET_ALL_USERINFO          = 0x1030    --请求所有玩家信息
P.CLI_SEND_DEALER_MONEY_DICE    = 0x1015    --赠送荷官钱
P.CLI_ADD_FRIEND_DICE           = 0x120F    --加好友协议
P.CLI_SEND_CHIPS_DICE           = 0x1031    --赠送筹码协议
P.CLI_SEND_EXPRESSION_DICE      = 0x1039    --DICE请求发表情
P.CLI_GET_COUNT                 = 0x1040    --获取当前人数

--博定
P.CLI_PDENG_LOGIN_ROOM           = 0x1701    --登录房间
P.CLI_PDENG_LOGOUT_ROOM          = 0x1702    --用户请求离开房间
P.CLI_PDENG_SET_BET              = 0x1703    --用户下注
P.CLI_PDENG_SEAT_DOWN            = 0x1704    --用户请求坐下
P.CLI_PDENG_STAND_UP             = 0x1705    --用户请求站立
P.CLI_PDENG_REQUEST_GRAB_DEALER  = 0x1706    --玩家请求上庄
P.CLI_PDENG_OTHER_CARD           = 0x1707    --用户请求第三张牌
P.CLI_PDENG_SEND_DEALER_MONEY    = 0x1708    --赠送荷官钱
P.CLI_PDENG_ADD_FRIEND           = 0x1709    --加好友协议
P.CLI_PDENG_SEND_CHIPS           = 0x1710    --赠送筹码协议
P.CLI_PDENG_SEND_EXPRESSION      = 0x1711    --请求发表情

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
P.SVR_SEND_EXPRESSION_DICE      = 0x2412    -- Dice表情
P.SVR_KICKED_BY_ADMIN           = 0x2032    -- 被管理员踢出房间
P.SVR_KICKED_BY_USER            = 0x2033    -- 被用户踢出房间
P.SVR_KICKED_BY_USER_MSG        = 0x2019    -- 被用户踢出房间提醒
P.SVR_KICKED_BY_USER_NEW        = 0x2035    -- 新的踢人命令，踢人者和被踢者都可以收到此命令

P.SVR_CMD_SERVER_UPGRADE        = 0x2100    -- 服务器升级
P.SVR_CMD_SERVER_STOP           = 0x2101    -- 停服
P.SVR_MODIFY_USERINFO           = 0x202A    -- 服务器广播用户更新个人信息


P.SVR_GAME_START_4K             = 0x2401    --4k场游戏开始
P.SVR_BRO_FOLD_START_4K         = 0x2402    --4k场用户选牌
P.SVR_BRO_FOLD_CARD_SUCC_4K     = 0x2403    --广播用户弃牌成功
P.SVR_USER_FOLD_CARD_RET_4K     = 0x2404    --返回用户弃牌结果
P.SVR_LOGIN_SUCCESS_4K          = 0x2411    --登录成功

P.SVR_LOGIN_SUCCESS_DICE        = 0x2501    --登录骰子场成功
P.SVR_LOGIN_FAIL_DICE           = 0x2502    --登录骰子场失败
P.SVR_BET_SUCC_DICE             = 0x2503    --服务器回复用户下注
P.SVR_BRO_USER_SIT_DICE         = 0x2601    --广播坐下用户登录成功
P.SVR_BRO_GAME_START_DICE       = 0x2602    --服务器广播游戏开始
P.SVR_BRO_START_BET_DICE        = 0x2603    --服务器广播开始下注
P.SVR_BRO_SITUSER_BET_DICE      = 0x2604    --服务器广播坐下用户下注结果
P.SVR_BRO_OTHER_BET_DICE        = 0x2605    --服务器广播旁观位用户下注结果
P.SVR_GAME_RESULT_DICE          = 0x2606    --发送牌局结果
P.SVR_BRO_USER_EXIT_DICE        = 0x2608    --广播坐下用户退出成功
P.SVR_LOGOUT_SUCC_DICE          = 0x2029    --服务器回复退出成功
P.SVR_GET_HISTORY               = 0x2030    --请求历史数据
P.SVR_GET_ALL_USERINFO          = 0x2607    --所有玩家信息
P.SVR_SEND_DEALER_CHIP_SUCC_DICE = 0x2127   --赠送荷官钱
P.SVR_ADD_FRIEND_SUCC_DICE      = 0x201B    --加好友成功
P.SVR_SEND_CHIPS_SUCC_DICE      = 0x2036    --赠送成功
P.SVR_SEAT_ERROR                = 0x2504    --坐下失败
P.SVR_SEND_HDDJ_SUCC            = 0x2117    --骰子场互动道具
P.SVR_USER_COUNT                = 0x2050    --当前人数
P.SVR_WILL_KICK_OUT             = 0x2200


--博定
P.SVR_PDENG_LOGIN_ROOM_OK              = 0x2721    --登录房间OK
P.SVR_PDENG_LOGIN_ROOM_FAIL            = 0x2711    --登录房间失败
P.SVR_PDENG_LOGOUT_ROOM_OK             = 0x2712    --登出房间OK
P.SVR_PDENG_SET_BET                    = 0x2713    --用户请求修改底注结果
P.SVR_PDENG_SELF_SEAT_DOWN_OK          = 0x2714
P.SVR_PDENG_STAND_UP                   = 0x2715    --用户请求站起
P.SVR_PDENG_SELF_REQUEST_BANKER_OK     = 0x2716
P.SVR_PDENG_OTHER_CARD                 = 0x2717    --用户请求第三张牌结果
P.SVR_PDENG_WILL_KICK_OUT              = 0x2719    --提示用户连续多局没操作，将被踢出房间 (G->C)
P.SVR_PDENG_DEAL                       = 0x2720    --发牌,通知玩家手牌
P.SVR_PDENG_BET                        = 0x2733    --服务器广播玩家下注
P.SVR_PDENG_SEAT_DOWN                  = 0x2734    --服务器广播用户坐下
P.SVR_PDENG_OTHER_STAND_UP             = 0x2735    --服务器广播用户站起
P.SVR_PDENG_OTHER_REQUEST_BANKER       = 0x2736    --向其他用户广播用户请求当庄成功，将其添加到候选人列表 (G->C)
P.SVR_PDENG_OTHER_CANCEL_BANKER        = 0x2737    --向其他用户广播用户请求当庄成功，将其添加到候选人列表 (G->C)
P.SVR_PDENG_GAME_START                 = 0x2738    --服务器广播游戏开始
P.SVR_PDENG_CARD_NUM                   = 0x2739    --服务器广播发牌开始
P.SVR_PDENG_SHOW_CARD                  = 0x2740    --服务器广播用户亮牌
P.SVR_PDENG_CAN_OTHER_CARD             = 0x2741    --服务器广播可以开始获取第三张牌
P.SVR_PDENG_OTHER_OTHER_CARD           = 0x2747    --服务器广播其它用户操作获取第三张牌结果
P.SVR_PDENG_GAME_OVER                  = 0x2748    --服务器广播牌局结束，结算结果
P.SVR_PDENG_SEND_DEALER_CHIP_SUCC      = 0x2758
P.SVR_PDENG_ADD_FRIEND_SUCC            = 0x2759
P.SVR_PDENG_SEND_CHIPS_SUCC            = 0x2760
P.SVR_PDENG_SEND_EXPRESSION            = 0x2761
P.SVR_PDENG_SEND_HDDJ_SUCC             = 0x2762




P.CLISVR_HEART_BEAT             = 0x0110    --心跳

P.SVR_CMD_BROADCAST_FEE         = 0x2020

-- 房间内赠送筹码到总账户
P.CLI_SEND_CHIPS_1              = 0x101C    --赠送筹码
P.SVR_SEND_CHIPS_SUCC_1         = 0x203C    --赠送筹码结果

P.BROADCAST_SYSTEM_TYPE = {}
PBST = P.BROADCAST_SYSTEM_TYPE
PBST.SVR_BIG_SLOT_REWARD        = 0x4002    --老虎机抽中大奖
PBST.SVR_BIG_LABA               = 0x500E
PBST.SVR_SERVER_STOP            = 0x5010    --停服
PBST.SVR_MATCH_LABA             = 0x200B
PBST.SVR_MATCH_CONFIG_CHANGE    = 0x200C    --比赛场配置修改
PBST.SVR_CHARMRANK              = 0x6004    --魅力值排行榜玩家第一名上线

PBST.SVR_MATCH_BROADCAST        = 0x2010    -- P2比赛场第一名消息 P3兑换消息 新的比赛喇叭消息
PBST.SVR_GAME_BROADCAST_P0      = 0x2011    -- P0官方消息
PBST.SVR_GAME_BROADCAST_P1      = 0x2012    -- P1活动消息


P.BROADCAST_PERSON_TYPE = {}
PBPT = P.BROADCAST_PERSON_TYPE
PBPT.SVR_ADD_SIT_EXP            = 0x5001    --坐下加经验
PBPT.SVR_GOT_NEW_MESSAGE        = 0x5008    --新消息
PBPT.SVR_MODIFY_USER_ASSET      = 0x500B    --筹码经验变化
PBPT.SVR_ACT_STATE              = 0x500F    --通知活动状态更新
PBPT.BROAD_CAST_PROP_FUNFACE    = 0x2013    --互动道具广播

PBPT.SVR_USER_INFO_CHANGE       = 0x200D    -- 玩家信息修改
PBPT.SVR_TICK_INFO_CHANGE       = 0x200E    -- 门票数量更新广播
PBPT.SVR_MATCHDAILY_INFO_CHANGE = 0x200F    -- 每日任务有可以领取奖励会广播
PBPT.SVR_VIP_LIGHT              = 0x6003    -- vip点亮
PBPT.SVR_TASK_REWARD_CHANGE     = 0x2014    -- 每日任务有可以领取奖励会广播
PBPT.SVR_CHANGE_GIFT            = 0x2016    -- php直接更换礼物广播
PBPT.SVR_NEW_YEAR_ACT           = 0x2017    -- 元旦活动
PBPT.SVR_PAY_INFO               = 0x2018    -- 个人支付信息

PBPT.GROUP_PUSH_AWARD           = 0x5011    -- 群组奖励通知
PBPT.SVR_INVITE_PLAY            = 0x5012    -- 被邀请打牌

PBPT.HALLOWEENACT_REWARD        = 0x6005    -- 万圣节活动奖励

P.CONFIG = {
    [P.HALL_CLI_LOGIN] = {
        ver = 1,
        fmt = {
            {name = "uid", type = T.INT},
            {name = "uinfo", type = T.STRING}
        }
    },

    -- 大厅登陆房间
    [P.HALL_CLI_LOGIN_ROOM] = {
        ver = 1,
        fmt = {
            {name = "ip", type = T.STRING}, --ip
            {name = "port", type = T.INT}
        }
    },

    -- 大厅登陆房间结果
    [P.HALL_SVR_LOGIN_ROOM_RESULT] = {
        ver = 1,
        fmt = {
            {name = "ret", type = T.INT}
        }
    },
    -- 登录房间
    [P.CLI_LOGIN] = {
        ver = 1,
        fmt = {
            {name = "tid"    , type = T.UINT}   , -- 房间ID
            {name = "uid"    , type = T.UINT}   , -- uid
            {name = "mtkey"  , type = T.STRING} , -- mtkey
            {name = "img"    , type = T.STRING} , -- 头像
            {name = "giftId" , type = T.INT}    , -- 礼物ID
            {name = "ver"    , type = T.BYTE},
            {name = "userInfo", type = T.STRING},
            {name = "ExUserInfo", type = T.STRING},
            {name = "psword", type = T.STRING},  -- 群组房间密码
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

    [P.CLI_MODIFY_USERINFO] = {
        ver = 1,
        fmt = {
            {name = "exUserInfo", type = T.STRING},
        }
    },
    [P.CLI_SEND_CHIPS_DICE] = {
        ver = 1,
        fmt = {
            {name="fromSeatId",type=T.BYTE},
            {name="chips",type=T.ULONG},
            {name="toSeatId",type=T.BYTE},
            {name="toUid",type=T.INT}
        }
    },
    --发送表情
    [P.CLI_SEND_EXPRESSION_DICE] = {
        ver = 1,
        fmt = {
            {name="expressionType", type=T.INT},--表情类型
            {name="expressionId", type=T.UINT}, --表情ID
        }
    },

--[[
    服务器包
]]

    --登陆大厅成功
    [P.HALL_SVR_LOGIN_OK] = {
        ver = 1,
        fmt = {
            {name = "ret", type = T.INT}--结果0：成功
        }
    },

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
                fixedLength=9,
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
            {name="roundCount", type=T.UINT},    --牌局数id   已废弃
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
                fixedLength=9,
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
            {name="userInfo", type = T.STRING}, --用户基本信息
            {name="exUserInfo", type = T.STRING}, --用户扩展信息
            {name="giftId", type=T.INT},        --礼物ID
            {name="seatChips", type=T.ULONG},    --买入筹码数
            {name="platFlag", type=T.INT},        --平台标识
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
    [P.SVR_KICKED_BY_USER_NEW] = {
        ver = 1,
        fmt = {
            {name="kickerUid", type=T.INT},        --踢人者uid
            {name="kickerNick", type=T.STRING},    --踢人者nick
            {name="kickedUid", type=T.INT},        --被踢者uid
            {name="kickedNick", type=T.STRING},    --被踢者nick
        },
    },

    --广播协议
    [P.BROADCAST_PERSON] = {
        ver = 1,
        fmt = {
            {name = "type", type = T.SHORT},
            {name = "info", type = T.STRING}
        }
    },
    [P.BROADCAST_SYSTEM] = {
        ver = 1,
        fmt = {
            {name = "info", type = T.STRING}
        }
    },
    [P.SVR_CMD_BROADCAST_FEE] = {
        ver = 1,
        fmt = {
            {name = "uid", type = T.UINT},
            {name = "seatId", type = T.BYTE},
            {name = "venue", type = T.LONG},
            {name = "curCoins", type = T.LONG},
            {name = "coins", type = T.LONG}
        }
    },
    [P.SVR_MODIFY_USERINFO] = {
        ver = 1,
        fmt = {
            {name="tid",type = T.UINT},
            {name="uid",type = T.UINT},
            {name="exUserInfo",type = T.STRING},
        }
    },

    [P.CLI_DROP_CARD_4K] = {
        ver = 1,
        fmt = {
            {
                name="holdcards",
                type=T.ARRAY,
                lengthType = T.BYTE,
                fmt={
                    {type=T.SHORT}
                }
            },
            {
                name="foldcards",
                type=T.ARRAY,
                lengthType = T.BYTE,
                fmt={
                    {type=T.SHORT}
                }
            },
        }
    },

    [P.SVR_GAME_START_4K] = {
        ver = 1,
        fmt = {
            {name="roundCount", type=T.UINT},    --牌局数id   已废弃
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
            {
                name="handCards",
                type=T.ARRAY,
                fmt = {type=T.SHORT}
            },
            {name="userChips", type=T.ULONG},        --用户钱数
        }
    },

    [P.SVR_BRO_FOLD_START_4K] = {
        ver = 1,
        fmt = {
            {name="timeout",type=T.UINT}
        }
    },

    [P.SVR_BRO_FOLD_CARD_SUCC_4K] = {
        ver = 1,
        fmt = {
            {name="status",type=T.BYTE},
            {name="seatId",type=T.BYTE},
            {name="uid",type=T.UINT},
            {name="tropnum",type=T.UINT}
        }
    },

    [P.SVR_USER_FOLD_CARD_RET_4K] = {
        ver = 1,
        fmt = {
            {name="ret",type=T.UINT},
            {
                name="holdCards", 
                type=T.ARRAY, 
                depends=function(ctx) return ctx.ret == 0 end,
                fmt = {
                        {type=T.SHORT},
                    },
            },
            {name="cardType",type=T.BYTE,depends=function(ctx) return ctx.ret == 0 end},
            {name="cardPoint",type=T.BYTE,depends=function(ctx) return ctx.ret == 0 end},
        }
    },

    [P.SVR_LOGIN_SUCCESS_4K] = {
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
            {name="card4", type=T.USHORT,depends=function(ctx) return ctx.handCardFlag == 1 end},
            {name="card5", type=T.USHORT,depends=function(ctx) return ctx.handCardFlag == 1 end},
            {name="timeout", type=T.UINT,depends=function(ctx) return ctx.handCardFlag == 2 end},
            {
                name="selectCards", 
                type=T.ARRAY, 
                depends=function(ctx) return ctx.handCardFlag == 2 end,
                fmt = {
                        {type=T.SHORT},
                    },
            },
            {
                name="platFlags",
                type=T.ARRAY,
                fixedLength=9,
                fmt={type=T.UINT}
            },
            {name="roomFlag", type=T.INT},        --桌子flag（快速场等）
        }
    },

    [P.CLI_LOGIN_DICE] = {
        ver = 1,
        fmt = {
            {name="tid",type=T.INT},
            {name="uid",type=T.INT},
            {name="mtkey",type=T.STRING},
            {name="userInfo",type=T.STRING},
            {name="userInfoEx",type=T.STRING}
        }
    },

    [P.CLI_BET_DICE] = {
        ver = 1,
        fmt = {
            {name="betType",type=T.INT},
            {name="betChip",type=T.ULONG}
        }
    },

    [P.CLI_GET_ALL_USERINFO] = {
        ver = 1,
        fmt = {
            {name="index",type=T.INT},
            {name="showSize",type=T.INT}
        }
    },
    [P.CLI_SEND_DEALER_MONEY_DICE] = {
        ver = 1,
        fmt = {
            {name="receiverID",type=T.INT},
            {name="money",type=T.ULONG}
        }
    },
    [P.CLI_ADD_FRIEND_DICE] = {
        ver = 1,
        fmt = {
            {name="fromSeatId",type=T.BYTE},
            {name="toSeatId",type=T.BYTE},
            {name="friendId",type=T.INT}
        }
    },
    [P.SVR_LOGIN_SUCCESS_DICE] = {
        ver = 1,
        fmt = {
            {name="basechip",type=T.ULONG},
            {name="minbuy",type=T.ULONG},
            {name="maxbuy",type=T.ULONG},
            {name="roomType",type=T.INT},
            {name="maxnum", type=T.BYTE},
            {
                name="typeArr", 
                type=T.ARRAY,
                lengthType = T.INT,
                fmt = {
                    {name="cardType",type=T.INT},
                    {name="typeRate",type=T.INT},
                }
            },
            {name="state",type=T.BYTE},
            {name="timeout",type=T.INT},
            {name="money",type=T.ULONG},
            {name="winTimes",type=T.INT},
            {name="loseTimes",type=T.INT},
            {name="exp",type=T.INT},
            {name="userInfo",type=T.STRING},
            {name="userInfoEx",type=T.STRING},
            {name="curChips",type=T.ULONG},
            {
                name="betState",
                type=T.ARRAY,
                lengthType = T.INT,
                fmt = {
                    {name="type",type=T.INT},
                    {name="betChip",type=T.ULONG}
                }
            },
            {
                name="playerList",
                type=T.ARRAY,
                fmt = {
                    {name="uid",type=T.INT},
                    {name="seatId",type=T.BYTE},
                    {name="money",type=T.ULONG},
                    {name="winTimes",type=T.INT},
                    {name="loseTimes",type=T.INT},
                    {name="exp",type=T.INT},
                    {name="userInfo",type=T.STRING},
                    {name="userInfoEx",type=T.STRING},
                    {name="curChips",type=T.ULONG},
                }
            },
            {
                name="typeBet",
                type=T.ARRAY,
                lengthType = T.INT,
                fmt = {
                    {name="type",type=T.INT},
                    {name="betChip",type=T.ULONG}
                }
            }
        }
    },
    [P.SVR_LOGIN_FAIL_DICE] = {
        ver = 1,
        fmt = {
            {name="errorCode",type=T.USHORT}
        }
    },
    [P.SVR_BET_SUCC_DICE] = {
        ver = 1,
        fmt = {
            {name="ret",type=T.INT},
            {name="betType",type=T.INT,depends=function(ctx) return ctx.ret == 0 end},
            {name="betChip",type=T.ULONG,depends=function(ctx) return ctx.ret == 0 end},
            {name="curChip",type=T.ULONG,depends=function(ctx) return ctx.ret == 0 end},
            {name="maxBetChip",type=T.ULONG,depends=function(ctx) return ctx.ret == 2 end},
        }
    },

    [P.SVR_BRO_USER_SIT_DICE] = {
        ver = 1,
        fmt = {
            {name="uid",type=T.INT},
            {name="seatId",type=T.BYTE},
            {name="money",type=T.ULONG},
            {name="winTimes",type=T.INT},
            {name="loseTimes",type=T.INT},
            {name="exp",type=T.INT},
            {name="userInfo",type=T.STRING},
            {name="userInfoEx",type=T.STRING},
            {name="curChips",type=T.ULONG},
        }
    },

    [P.SVR_BRO_START_BET_DICE] = {
        ver = 1,
        fmt = {
            {name="timeout",type=T.INT}
        }
    },

    [P.SVR_BRO_SITUSER_BET_DICE] = {
        ver = 1,
        fmt = {
            {name="uid",type=T.INT},
            {name="seatId",type=T.INT},
            {name="betType",type=T.INT},
            {name="betChip",type=T.ULONG},
            {name="curChip",type=T.ULONG},
            {name="money",type=T.ULONG}
        }
    },

    [P.SVR_BRO_OTHER_BET_DICE] = {
        ver = 1,
        fmt = {
            {
                name="otherBet",
                type=T.ARRAY,
                lengthType = T.INT,
                fmt = {
                    {name="betType",type=T.INT},
                    {name="betChip",type=T.ULONG}
                }
            },
            {
                name="sitBet",
                type=T.ARRAY,
                lengthType = T.INT,
                fmt = {
                    {name="uid",type=T.INT},
                    {
                        name="betData",
                        type=T.ARRAY,
                        lengthType = T.INT,
                        fmt = {
                            {name="betType",type=T.INT},
                            {name="betChip",type=T.ULONG}
                        }
                    },
                }
            }
        }
    },
    [P.SVR_GAME_RESULT_DICE] = {
        ver = 1,
        fmt = {
            {name="card11",type=T.SHORT},
            {name="card12",type=T.SHORT},
            {name="card13",type=T.SHORT},
            {name="type1",type=T.INT},
            {name="card21",type=T.SHORT},
            {name="card22",type=T.SHORT},
            {name="card23",type=T.SHORT},
            {name="type2",type=T.INT},
            {name="res",type=T.BYTE},
            {
                name="betresult",
                type=T.ARRAY,
                lengthType = T.INT,
                fmt = {
                    {name="type",type=T.INT},
                    {name="betChip",type=T.ULONG},
                    {name="winChip",type=T.ULONG}
                }
            },
            -- {name="winType1",type=T.INT},
            -- {name="Type1Chips",type=T.ULONG},
            -- {name="winType2",type=T.INT},
            -- {name="Type2Chips",type=T.ULONG},
            {
                name="winresult",
                type=T.ARRAY,
                lengthType = T.INT,
                fmt = {
                    {name="type",type=T.INT},
                    {name="chips",type=T.ULONG},
                }
            },
            {name="turnChip",type=T.LONG},
            {name="curChips",type=T.ULONG},
            {name="winTime",type=T.INT},
            {name="loseTime",type=T.INT},
            {name="trunExp",type=T.INT},
            {name="exp",type=T.INT},
            {
                name="playerList",
                type=T.ARRAY,
                lengthType=T.INT,
                fmt = {
                    {name="uid",type=T.INT},
                    {name="seatId",type=T.INT},
                    {
                        name = "betresult",
                        type = T.ARRAY,
                        lengthType = T.INT,
                        fmt = {
                            {name="type",type=T.INT},
                            {name="betChip",type=T.ULONG},
                            {name="winChip",type=T.ULONG}
                        }
                    },
                    {name="turnChip",type=T.ULONG},
                    {name="curChips",type=T.ULONG},
                    {name="winTime",type=T.INT},
                    {name="loseTime",type=T.INT},
                    {name="trunExp",type=T.INT},
                    {name="exp",type=T.INT},
                }
            }

        }
    },
    [P.SVR_BRO_USER_EXIT_DICE] = {
        ver = 1,
        fmt = {
            {name="uid",type=T.UINT},
            {name="seatId",type=T.UINT}
        }
    },
    [P.SVR_GET_HISTORY] = {
        ver = 1,
        fmt = {
            {
                name = "history",
                type = T.ARRAY,
                lengthType = T.INT,
                fmt = {
                    {name="card11",type=T.SHORT},
                    {name="card12",type=T.SHORT},
                    {name="card13",type=T.SHORT},
                    {name="type1",type=T.INT},
                    {name="card21",type=T.SHORT},
                    {name="card22",type=T.SHORT},
                    {name="card23",type=T.SHORT},
                    {name="type2",type=T.INT},
                    {
                        name="wintypes",
                        type=T.ARRAY,
                        lengthType = T.INT,
                        fmt = {
                            {name="wintype",type=T.INT},
                        }
                    },
                    {name="res",type=T.BYTE},
                }
            }
        }
    },
    [P.SVR_GET_ALL_USERINFO] = {
        ver = 1,
        fmt = {
            {name="index",type=T.INT},
            {
                name="pageUser",
                type=T.ARRAY,
                lengthType = T.INT,
                fmt = {
                    {name="uid",type=T.INT},
                    {name="money",type=T.ULONG},
                    {name="userInfo",type=T.STRING},
                    {name="userInfoEx",type=T.STRING},
                }
            }
        }
    },
    [P.SVR_LOGOUT_SUCC_DICE] = {
        ver = 1,
        fmt = {
            {name="ret",type=T.BYTE},
            {name="money",type=T.ULONG}
        }
    },
    [P.SVR_SEND_DEALER_CHIP_SUCC_DICE] = {
        ver = 1,
        fmt = {
            {name="fromSeatId",type=T.BYTE},
            {name="fromUid",type=T.INT},
            {name="money",type=T.ULONG},
            {name="chips",type=T.ULONG},
            {name="receiverID",type=T.BYTE}
        }
    },
    [P.SVR_SEND_CHIPS_SUCC_DICE] = {
        ver = 1,
        fmt = {
            {name="fromSeatId",type=T.BYTE},
            {name="fromUid",type=T.INT},
            {name="chips",type=T.ULONG},
            {name="toSeatId",type=T.BYTE},
            {name="toUid",type=T.INT}
        }
    },
    [P.SVR_ADD_FRIEND_SUCC_DICE] = {
        ver = 1,
        fmt = {
            {name="fromSeatId",type=T.BYTE},
            {name="toSeatId",type=T.BYTE},
            {name="fromUid",type=T.INT},
            {name="toUid",type=T.INT}
        }
    },
    [P.SVR_SEND_HDDJ_SUCC] = {
        ver = 1,
        fmt = {
            {name="fromSeatId",type=T.BYTE},
            {name="daojuType",type=T.INT},
            {name="toSeatId",type=T.BYTE},
            {name="fromUid",type=T.INT},
            {name="toUid",type=T.INT},
        }
    },
    [P.SVR_SEND_EXPRESSION_DICE] = {
        ver = 1,
        fmt = {
            {name="seatId", type=T.BYTE},        --发送表情的座位ID
            {name="uid",type=T.INT},            --发表情的UID
            {name="expressionType", type=T.INT},--表情类型
            {name="expressionId", type=T.UINT}, --表情ID
            {name="minusChips", type=T.LONG},    --表情扣筹码数
            {name="totalChips", type=T.LONG},    --发送表情之后的筹码数
        }
    },
    [P.SVR_SEAT_ERROR] = {
        ver = 1,
        fmt = {
            {name="errorCode", type=T.USHORT}
        }
    },
    [P.SVR_USER_COUNT] = {
        ver = 1,
        fmt = {
            {name="seatnum",type=T.INT},
            {name="looknum",type=T.INT}
        }
    },
    [P.SVR_WILL_KICK_OUT] = {
        ver = 1,
        fmt = {
            {name="count",type=T.BYTE}
        }
    },
    [P.SVR_BRO_GAME_START_DICE] = {
        ver = 1,
        fmt = {
            {name="uid",type=T.UINT},
            {name="chips",type=T.ULONG},
            {name="money",type=T.ULONG},
            {
                name="seatInfo",
                type=T.ARRAY,
                lengthType = T.BYTE,
                fmt = {
                    {name="seatId",type=T.BYTE},
                    {name="uid",type=T.INT},
                    {name="chips",type=T.ULONG},
                    {name="money",type=T.ULONG}
                }
            }
        }
    }
    -- --新的比赛喇叭
    -- [P.SVR_MATCH_BROADCAST] = {
    --     ver = 1,
    --     fmt = {
    --         {name="info", type = T.STRING}, --消息数据
    --     },
    -- },
    -- --P1活动消息
    -- [P.SVR_GAME_BROADCAST_P1] = {
    --     ver = 1,
    --     fmt = {
    --         {name="info", type = T.STRING}, --消息数据
    --     },
    -- },
    -- --P0官方消息
    -- [P.SVR_GAME_BROADCAST_P0] = {
    --     ver = 1,
    --     fmt = {
    --         {name="info", type = T.STRING}, --消息数据
    --     },
    -- },
}

P.CONFIG[P.SVR_SEND_ROOM_BROADCAST] = P.CONFIG[P.CLI_SEND_ROOM_BROADCAST]
P.CONFIG[P.CLI_SEND_CHIPS_1] = P.CONFIG[P.CLI_SEND_CHIPS_DICE]
P.CONFIG[P.SVR_SEND_CHIPS_SUCC_1] = P.CONFIG[P.SVR_SEND_CHIPS_SUCC_DICE]

table.merge(P.CONFIG, PDENG_SOCKET_PROTOCOL.CONFIG.CLIENT)
table.merge(P.CONFIG, PDENG_SOCKET_PROTOCOL.CONFIG.SERVER)

return HALL_SOCKET_PROTOCOL