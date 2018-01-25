local L = {}

--- 命名约定
-- http错误的，使用ERROR_
-- 返回值或返回格式错误，使用EXCEPTION_

L.TIPS = {

    -- mod = "invite", act = "getInviteID"
    ERROR_INVITE_FRIEND = 'เชิญเพื่อนล้มเหลว',

    -- mod = "task", act = "reward",
    ERROR_TASK_REWARD = 'รับรางวัลภารกิจล้มเหลว',

    -- mod = "friend", act = "giveChipsNew",
    ERROR_SEND_FRIEND_CHIP = 'ส่งชิปให้เพื่อนล้มเหลว',
    EXCEPTION_SEND_FRIEND_CHIP = 'ส่งชิปให้เพื่อนล้มเหลว',

    -- mod = "recall", act = "getRecallID"  废弃
    --ERROR_RECALL_GETID = 'การเรียก ID ผู้เล่นเก่าล้มเหลว'

    -- mod = "gift", act = "buyTo",
    ERROR_BUY_GIFT = 'ส่งของขวัญล้มเหลว',

    -- mod = "Mysterybag", act = "lotteryDraw",
    ERROR_LOTTER_DRAW = 'รับกล่องรางวัลลึกลับล้มเหลว',
    EXCEPTION_LOTTER_DRAW = 'โอกาสทุบไข่ไม่พอค่ะ',

    -- hall controller
    ERROR_LOGIN_MATCH_FAIL = 'ล็อกอินเข้าห้องแข่งขันล้มเหลว กรุณาลองใหม่ทีค่ะ',--登录比赛场失败,请重试
    ERROR_LOGIN_ROOM_FAIL = 'เข้าห้องล้มเหลว กรุณาลองใหม่ทีค่ะ',--进入房间失败,请重试
    ERROR_LOGIN_FACEBOOK = 'ล็อกอินบัญชีเฟสบุ๊คล้มเหลว กรุณาลองใหม่ทีค่ะ',--FaceBook登录失败,请重试

    -- appconfig.LOGIN_SERVER_URL
    -- 向上面的url发送http请求失败、超时，会使用本提示语
    ERROR_LOGIN_FAILED = 'ล็อกอินเข้าเกมล้มเหลว',--登录失败

    -- mod = "table", act = "quickIn"
    ERROR_QUICK_IN = 'เชื่อมต่ออินเตอร์เน็ตขัดข้อง กรุณาตรวจเช็คเน็ตของท่านก่อนค่ะ',--网络连接中断，请检查您的网络连接是否正常
    EXCEPTION_QUICK_IN = 'หาห้องนี้ไม่เจอ กรุณาลองใหม่อีกทีค่ะ',--没有找到房间，请重试

    -- feedback 登录界面的反馈弹窗
    -- mod = "feedback", act = "setNew",

    ERROR_SEND_FEEDBACK = '服务器错误或网络超时，发送反馈失败！',
    -- 这个提示的意义真心不大，服务器错误……
    ERROR_FEEDBACK_SERVER_ERROR = 'เซิร์ฟเวอร์ผิดปกติ ส่งฟีดแบคล้มเหลว',

    -- mod = "Feedback", act = "match",
    -- ？? 待确认：这种网络错误统一格式成
    -- 服务器出错啦或无法连接+具体的失败操作？
    ERROR_MATCH_FEEDBACK = 'ส่งฟีดแบคการแข่งขันล้มเหลว',

    -- mod="act", act="list"
    -- 加载数据类，不是用户通过用户操作按钮反馈的，
    -- 暂时不给提示啦，以后再做优化
    EXCEPTION_ACT_LIST = 'เซิร์ฟเวอร์ผิดปกติ โหลดข้อมูลกิจกรรมล้มเหลว',

    -- 商店模块的错误都比较严重，测试的也比较多
    -- 应该比较少了；综上，统一去掉。

    -- mod='bank', act = 'bankCheckpsw'
    EXCEPTION_BACK_CHECK_PWD = 'ผลการตรวจสอบ:  เซิร์ฟเวอร์ผิดปกติ',
    ERROR_BACK_CHECK_PWD = 'การเชื่อมต่อเซิร์ฟเวอร์ผิดปกติหรือนานเกินเวลา การตรวจสอบรหัสล้มเหลว',

    FEEDBACK_UPLOAD_PIC_FAILED = 'อัพโหลดรูปล้มเหลว！',

    -- mod = "level", act = "levelUpReward",
    ERROR_LEVEL_UP_REWARD = 'การเชื่อมต่อเซิร์ฟเวอร์ผิดปกติหรือนานเกินเวลา รับรางวัลอัพ LV ล้มเหลว',

}

return L

