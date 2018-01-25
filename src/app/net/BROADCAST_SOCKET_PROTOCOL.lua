--
-- Author: Johnny Lee
-- Date: 2014-07-09 11:16:52
--
local T = require("boomegg.socket.PACKET_DATA_TYPE")
local P = {}


-- 客户端请求
P.CLI_LOGIN         = 0x1001      -- 登录广播server
P.CLISVR_HEART_BEAT = 0x2001      -- 广播server心跳包

-- 服务端返回
P.SVR_RETURN_SYSTEM   = 0x1002    -- 系统广播
P.SVR_RETURN_PERSONAL = 0x1003    -- 个人通知

-- personal
P.SVR_LEVEL_UP              = 0x1001    -- 个人升级
P.SVR_GOT_ACHIEVEMENT       = 0x1002    -- 个人获得成就
P.SVR_MISSION_COMPLETE      = 0x1003    -- 个人完成任务
P.SVR_ADD_SIT_EXP           = 0x1004    -- 坐下加经验
P.SVR_GOT_LOTTERY           = 0x1005    -- 个人中奖通知
P.SVR_GOT_NEW_MESSAGE       = 0x1006    -- 个人新消息
P.SVR_MODIFY_USER_ASSET     = 0x1007    -- 修改个人筹码、卡拉币、经验值、黄金币、现金币
P.SVR_NOTICE_MATCH_APPROACH = 0x1008    -- 比赛进场通知
P.SVR_INVITE_PLAY_CARDS     = 0x1009    -- 被邀请打牌
P.SVR_GOT_VIP               = 0x100A    -- 个人获取VIP
P.SVR_MODIFY_USER_SCORE     = 0x100B    -- 维护个人积分
P.SVR_DELAY_PAY             = 0x100C    -- 购买商品被延迟发货
P.SVR_PAY_SUCCESS           = 0x100D    -- 购买商品支付成功
P.SVR_DASHBOARD_MESSAGE     = 0x1013    -- dashboard消息
P.SVR_ACT_STATE             = 0x1015    -- 个人完成活动
P.SVR_GOT_SUPER_LOTTO       = 0x2007    -- 夺金岛中奖
P.SVR_SUPER_LOTTO_POOL      = 0x2008    -- 夺金岛奖池
P.SVR_SLOT_CARD_TYPE_REWARD = 0x200A    -- 老虎机牌型中奖
P.SVR_VIP_LIGHT             = 0x6003    -- vip点亮
P.SVR_DOUBLE_LOGIN          = 0x9001    -- 重复登录通知
P.SVR_OPEN_MATCH            = 0x101A    -- 打开比赛场
P.SVN_MATCH_CONFIG_CHANGE   = 0x200C    -- 比赛场配置修改
P.SVN_USER_INFO_CHANGE      = 0x200D    -- 玩家信息修改
P.SVN_TICK_INFO_CHANGE      = 0x200E    -- 门票数量更新广播
P.SVN_MATCHDAILY_INFO_CHANGE = 0x200F   -- 每日任务有可以领取奖励会广播


-- system
P.SVR_URGENCY_TIP        = 0x2001    -- 所有展示位的提示
P.SVR_TOP_TIP            = 0x2002    -- 场景顶部提示
P.SVR_BIG_SLOT_REWARD    = 0x2003    -- 老虎机大奖提示
P.SVR_ROOM_TIP           = 0x2004    -- 房间提示
P.SVR_SMALL_LABA         = 0x2005    -- 小喇叭消息
P.SVR_BIG_LABA           = 0x2006    -- 大喇叭消息
P.SVR_MATCH_LABA         = 0x200B    -- 比赛喇叭消息
P.SVR_MATCH_LABA_NEW     = 0x2010    -- P2比赛场第一名消息 P3兑换消息 新的比赛喇叭消息
P.SVR_MATCH_LABA_P0      = 0x2011    -- P0官方消息
P.SVR_MATCH_LABA_P1      = 0x2012    -- P1活动消息
P.SVR_CURRENT_NUM_PLAYER = 0x3001    -- 当前玩家人数
P.SVR_SERVER_STOP        = 0x4001    -- 服务器停服

P.CONFIG = {
--[[
    客户端包，对于空包体，可以允许不定义协议内容，将默认版本号为1，包体长度为0
]]

    [P.CLI_LOGIN] = {
        ver = 1,
        fmt = {
            {name = "uid", type = T.UINT},        --uid
            {name = "mtkey", type = T.STRING},    --mtkey
        }
    },

--[[
    服务器返回包
]]
    [P.CLISVR_HEART_BEAT] = {ver = 1},
}

P.TYPE_CONFIG = {
    -- 升级
    [P.SVR_LEVEL_UP] = {
        ver = 1,
        fmt = {
            {name = "level", type = T.UINT}    --等级
        }
    },
    -- 坐下加经验
    [P.SVR_ADD_SIT_EXP] = {
        ver = 1,
        fmt = {
            {name = "expAdded", type = T.UINT} --经验值
        }
    },
    -- 筹码、经验变化
    [P.SVR_MODIFY_USER_ASSET] = {
        ver = 1,
        fmt = {
            {name = "asset", type = T.STRING} -- json data
        }
    },
    -- 新消息
    -- content: uid(int)
    [P.SVR_GOT_NEW_MESSAGE] = {ver = 1},

    [P.SVR_ACT_STATE] = {
        ver = 1,
        fmt = {
            {name="actId", type=T.UINT}, --活动ID
            {name="actState", type=T.INT}, --活动状态  1 标示完成
        },
    },

    [P.SVR_VIP_LIGHT] = {
        ver = 1,
        fmt = {
            {name="info", type=T.STRING}, --vip消息
        },
    },

    -- 系统消息

    --停服
    [P.SVR_SERVER_STOP] = {
        ver = 1,
        fmt = {
            {name="msg", type=T.STRING}, --停服消息
        },
    },

    --老虎机大奖
    [P.SVR_BIG_SLOT_REWARD] = {
        ver = 1,
        fmt = {
            {name = "uid", type = T.UINT},
            {name = "nick", type = T.STRING},
            {name = "type", type = T.UINT},
            {name = "value1", type = T.UINT},
            {name = "value2", type = T.UINT},
            {name = "value3", type = T.UINT},
            {name = "rewardMoney", type = T.ULONG}
        }
    },

    --大喇叭
    [P.SVR_BIG_LABA] = {
        ver = 1,
        fmt = {
            {name="msg", type=T.STRING}, --消息内容
        },
    },

    --比赛喇叭
    [P.SVR_MATCH_LABA] = {
        ver = 1,
        fmt = {
            {name="msg", type=T.STRING}, --消息内容
        },
    },

    --新的比赛喇叭
    [P.SVR_MATCH_LABA_NEW] = {
        ver = 1,
        fmt = {
            {name="msgData", type=T.STRING}, --消息数据
        },
    },
    --P1活动消息
    [P.SVR_MATCH_LABA_P1] = {
        ver = 1,
        fmt = {
            {name="msgData", type=T.STRING}, --消息数据
        },
    },
    --P0官方消息
    [P.SVR_MATCH_LABA_P0] = {
        ver = 1,
        fmt = {
            {name="msgData", type=T.STRING}, --消息数据
        },
    },
    
    -- 打开比赛场
    [P.SVR_OPEN_MATCH] = {
        ver = 1,
        fmt = {
            {name="time", type=T.STRING}, --过期时间
        },
    },
    -- 比赛配置修改
    [P.SVN_MATCH_CONFIG_CHANGE] = {
        ver = 1,
        fmt = {
            {name="msg", type=T.STRING}, --消息内容
        },
    },
    -- 玩家比赛信息
    [P.SVN_USER_INFO_CHANGE] = {
        ver = 1,
        fmt = {
            {name="info", type=T.STRING}, --消息内容
        },
    },
    -- 门票数量更新广播
    [P.SVN_TICK_INFO_CHANGE] = {
        ver = 1,
        fmt = {
            {name="info", type=T.STRING}, --消息内容
        }
    },
    -- 比赛场每日任务有奖励广播
    [P.SVN_MATCHDAILY_INFO_CHANGE] = {
        ver = 1,
        fmt = {
            {name="info", type=T.STRING}, --消息内容
        }
    }
}

return P
