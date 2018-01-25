local L = {}

--- 命名约定
-- http错误的，使用ERROR_
-- 返回值或返回格式错误，使用EXCEPTION_

L.TIPS = {

    -- mod = "invite", act = "getInviteID"
    ERROR_INVITE_FRIEND = '邀请好友失败',

    -- mod = "task", act = "reward",
    ERROR_TASK_REWARD = '领取任务奖励失败',

    -- mod = "friend", act = "giveChipsNew",
    ERROR_SEND_FRIEND_CHIP = '送朋友给筹码失败',
    EXCEPTION_SEND_FRIEND_CHIP = '送朋友给筹码异常',

    -- mod = "recall", act = "getRecallID"
    --ERROR_RECALL_GETID = '获取召回ID失败'

    -- mod = "gift", act = "buyTo",
    ERROR_BUY_GIFT = '赠送礼物失败',

    -- mod = "Mysterybag", act = "lotteryDraw",
    ERROR_LOTTER_DRAW = '神秘礼盒领奖失败',
    EXCEPTION_LOTTER_DRAW = '砸金蛋剩余次数不够',

    -- hall controller
    ERROR_LOGIN_MATCH_FAIL = '登录比赛场失败',
    ERROR_LOGIN_ROOM_FAIL = '登录房间失败',
    ERROR_LOGIN_FACEBOOK = 'FaceBook登录失败',

    -- appconfig.LOGIN_SERVER_URL
    -- 向上面的url发送http请求失败、超时，会使用本提示语
    ERROR_LOGIN_FAILED = '登录失败',

    -- mod = "table", act = "quickIn"
    ERROR_QUICK_IN = '获取房间信息失败',
    EXCEPTION_QUICK_IN = '获取房间信息异常',

    -- feedback 登录界面的反馈弹窗
    -- mod = "feedback", act = "setNew",

    ERROR_SEND_FEEDBACK = '服务器错误或网络链接超时，发送反馈失败！',
    -- 这个提示的意义真心不大，服务器错误……
    ERROR_FEEDBACK_SERVER_ERROR = '服务器错误,发送反馈失败',

    -- mod = "Feedback", act = "match",
    -- ？? 待确认：这种网络错误统一格式成
    -- 服务器出错啦或无法连接+具体的失败操作？
    ERROR_MATCH_FEEDBACK = '反馈比赛场错误失败',

    -- mod="act", act="list"
    -- 加载数据类，不是用户通过用户操作按钮反馈的，
    -- 暂时不给提示啦，以后再做优化
    EXCEPTION_ACT_LIST = '服务器错误，加载活动数据失败',

    -- 商店模块的错误都比较严重，测试的也比较多
    -- 应该比较少了；综上，统一去掉。

    -- mod='bank', act = 'bankCheckpsw'
    EXCEPTION_BACK_CHECK_PWD = '校验密码：服务器错误',
    ERROR_BACK_CHECK_PWD = '服务器错误或网络链接超时，校验密码失败',

    FEEDBACK_UPLOAD_PIC_FAILED = '反馈图片上传失败！',

    -- mod = "level", act = "levelUpReward",
    ERROR_LEVEL_UP_REWARD = '服务器错误或网络超时，领取升级奖励失败',

}

return L
