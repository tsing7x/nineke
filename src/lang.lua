--
-- Author: Johnny Lee
-- Date: 2014-07-08 10:52:57
--

-- module lang
local L = {}
local T, T1

L.COMMON       = {}
L.LOGIN        = {}
L.HALL         = {}
L.ROOM         = {}
L.STORE        = {}
L.USERINFO     = {}
L.FRIEND       = {}
L.RANKING      = {}
L.MESSAGE      = {}
L.SETTING      = {}
L.LOGINREWARD  = {}
L.HELP         = {}
L.UPDATE       = {}
L.ABOUT        = {}
L.DAILY_TASK   = {}
L.COUNTDOWNBOX = {}

L.NEWESTACT    = {}
L.FEED         = {}
L.ECODE        = {}
L.WHEEL        = {}
L.BANK         = {}
L.SLOT         = {}
L.UPGRADE      = {}
L.GIFT         = {}
L.GIFTBOX      = {}
L.CRASH        = {}
L.FBGUIDE      = {} -- facebook登录引导
L.MATCH        = {} -- 比赛场
L.SCOREMARKET  = {} -- 积分兑换奖励
L.PLAYER_BACK  = {} -- 流失玩家回归任务
L.USERINFOMATCH = {}    --比赛场其他玩家信息面板
L.BILLDETAIL = {}
L.MixCurrent = {}
L.TICKET = {}
L.MATCHDETAIL = {}
L.SONGKRAN_ACT = {}

L.FIRST_PAY = {}
L.E2P_TIPS = {}
L.GUIDE_PAY = {}
L.HALLOWEEN = {}
L.CRAZED = {}

L.VIP = {}
L.SHARE = {}
L.PUSHREWARD = {}
L.LOTTERY = {}
L.HIGHROOMREWARD = {}
L.PLAYERBACK = {}
L.PUSHMSG = {}
L.COINROOM = {}
L.DEALERSHOP = {}
L.ROOM_4K = {}
L.POKER_ACT = {}
L.DICE = {}
L.RICHMAN = {}
L.GROUP = {}
L.CARD_ACT = {}
L.PDENG = {}
L.FOOTBALL = {}
L.SONGKRAN = {}
L.WATERLAMP = {}

-- COMMON MODULE
L.COMMON.LEVEL = "Lv.{1}"
L.COMMON.ASSETS = "${1}"
L.COMMON.CONFIRM = "确定"
L.COMMON.CANCEL = "取消"
L.COMMON.AGREE = "同意"
L.COMMON.REJECT = "拒绝"
L.COMMON.RETRY = "重连"
L.COMMON.NOTICE = "温馨提示"
L.COMMON.BUY = "购买"
L.COMMON.SEND = "发送"
L.COMMON.BAD_NETWORK = "网络连接中断，请检查您的网络连接是否正常."
L.COMMON.REQUEST_DATA_FAIL = "网络连接中断，请检查您的网络连接是否正常，点击重连按钮重新连接。"
L.COMMON.ROOM_FULL = "现在该房间旁观人数过多，请换一个房间"
L.COMMON.USER_BANNED = "您的账户被冻结了，请你反馈或联系管理员"
L.COMMON.MAX_MONEY_HISTORY = "历史最高资产: {1}"
L.COMMON.MAX_POT_HISTORY = "赢得最大奖池: {1}"
L.COMMON.WIN_RATE_HISTORY = "历史胜率: {1}%"
L.COMMON.BEST_CARD_TYPE_HISTORY = "历史最佳牌型:"
L.COMMON.LEVEL_UP_TIP = "恭喜你升到{1}级, 获得奖励:{2}"
L.COMMON.MY_PROPS = "我的道具:"
L.COMMON.SHARE = "分  享"
L.COMMON.GET_REWARD = "领取奖励"
L.COMMON.BUY_CHAIP = "购买"
L.COMMON.SYSTEM_BILLBOARD = "官方公告"
L.COMMON.DELETE = "删除"
L.COMMON.CHECK = "查看"

L.COMMON.LOGOUT = "登出"
L.COMMON.LOGOUT_DIALOG_TITLE = "确认退出登录"
L.COMMON.BINDFHONE = "恭喜你绑定手机号，通过这个号码注册/登录我们官网，可以充值获赠积分（10积分=1泰铢），兑换各种福利！"
L.COMMON.NULLPHONE = "手机号码不能为空"
L.COMMON.NULLKEY = "验证码不能为空"
L.COMMON.DESSHOP = "绑定手机号码前去官网注册，充值即可以获赠积分哟！10积分=1泰铢，官网还有各种福利等你来领取。现在绑定即可获得金币奖励！"

-- android 右键退出游戏提示
L.COMMON.QUIT_DIALOG_TITLE = "确认退出"
L.COMMON.QUIT_DIALOG_MSG = "真的确认退出游戏吗？人家好舍不得滴啦~\\(≧▽≦)/~"
L.COMMON.QUIT_DIALOG_MSG_A = "确定要退出了吗?\n明天登录还可以领取更多奖励哦。"
L.COMMON.QUIT_DIALOG_CONFIRM = "忍痛退出"
L.COMMON.QUIT_DIALOG_CANCEL = "我点错了"

L.COMMON.NOT_ENOUGH_MONEY_TO_PLAY_NOW_MSG = "您的筹码不足最小买入{1}，您需要补充筹码后重试。"
L.COMMON.USER_SILENCED_MSG = "您的帐号已被禁言，您可以在帮助-反馈里联系管理员处理"
L.COMMON.USER_NEED_RELOGIN = "操作失败，请重新登录再试，或者联系客服"

-- LOGIN MODULE
L.LOGIN.FB_LOGIN = "FB账户登录"
L.LOGIN.GU_LOGIN = "游客账户登录"
L.LOGIN.USE_DEVICE_NAME_TIP = "您是否允许我们使用您的设备名称\n作为游客账户的昵称并上传到游戏服务器？"
L.LOGIN.REWARD_SUCCEED = "领取奖励成功"
L.LOGIN.REWARD_FAIL = "领取失败"
L.LOGIN.REIGSTER_REWARD_FIRST_DAY = "第一天"
L.LOGIN.REGISTER_REWARD_SECOND_DAY = "第二天"
L.LOGIN.REGISTER_REWARD_THIRD_DAY = "第三天"
L.LOGIN.LOGINING_MSG = "正在登录游戏..."
L.LOGIN.CANCELLED_MSG = "登录已经取消"
L.LOGIN.FEED_BACK_HINT = "请详细描述您的问题，如使用哪种方式登录、UID等信息，以便我们能快速为您服务"
L.LOGIN.FEED_BACK_TITLE = "反馈"
L.LOGIN.DOUBLE_LOGIN_MSG = "您的账户在其他地方登录"


-- HALL MODULE
L.HALL.USER_ONLINE = "当前在线人数: {1}"
L.HALL.INVITE_FRIEND = "邀请好友赠送"
L.HALL.INVITE_OLDUSER_FRIEND = "召回fb好友+{1}"
L.HALL.INVITE_FAIL_SESSION = "获取Facebook信息失败，请重试"
L.HALL.DAILY_BONUS = "登录奖励"
L.HALL.DAILY_MISSION = "每日任务"
L.HALL.NEWEST_ACTIVITY = "最新活动"
L.HALL.FREE_CHIPS = "免费游戏币"

L.HALL.SLOT = "水果机"
L.HALL.LUCKY_WHEEL = "幸运转转转"
L.HALL.NOTOPEN="暂未开放 敬请期待"
L.HALL.MODIFING = "正在维护，敬请关注"
L.HALL.OPEN_BOX = "开宝箱"
L.HALL.STORE_BTN_TEXT = "商城"
L.HALL.FRIEND_BTN_TEXT = "好友"
L.HALL.RANKING_BTN_TEXT = "排行榜"
L.HALL.ACTIVITY_BTN_TEXT = "活动"
L.HALL.EXCHANGE_BTN_TEXT = "兑换"
L.HALL.ROOM_TYPE_NORMAL = "普通场"
L.HALL.ROOM_TYPE_PRO = "专业场"
L.HALL.MAX_BUY_IN_TEXT = "最大买入{1}"
L.HALL.PRE_CALL_TEXT = "前注"
L.HALL.MIN_BET_TEXT = "最小下注{1}"
L.HALL.BASE_BUY_IN_TEXT = "最小携带{1}"
L.HALL.SEARCH_ROOM_INPUT_ROOM_NUMBER_ERROR = "你输入的房间号码有误"
L.HALL.SEARCH_ROOM_INPUT_ROOM_NUMBER_EMPTY = "房间号码不能为空"
L.HALL.SEARCH_ROOM_NUMBER_IS_WRONG= "你输入的房间位数不对"
L.HALL.SEARCH_ROOM_INPUT_CORRECT_ROOM_NUMBER= "请输入5到8位的房间号码"
L.HALL.ROOM_LEVEL_TEXT = {
    "初级场",
    -- "中级场",
    "高级场",
    -- "黄金币场"
}
L.HALL.GCOIN_ROOM_LEVEL_TEXT = {
    "黄金币场"
}
L.HALL.ROOM_LEVEL_TEXT_NOCOINROOM = {
    "初级场",
    -- "中级场",
    "高级场"
}

L.HALL.ROOM_LEVEL_TEXT_ROOMTIP = {
    "初级场", ---初级场
    "中级场", ---中级场
    "高级场",----高级场
    "现金币场",----现金币场
    "黄金币场",-----黄金币场
}

L.HALL.PLAYER_LIMIT_TEXT = {
    "9\n人",
    "5\n人"
}
L.HALL.OPEN_CALLBACK_REWARD = '恭喜您打开礼包获得{1}金币!'
L.HALL.ARENA_LIMIT_TIPMSG = "进入比赛场需要等级 {1} 级!"

L.HALL.TUTORIAL_PLAYNOWCARD = "点击快速开始帮你选场坐下"
L.HALL.TUTORIAL_INVITEFRIEND = "点击邀请可立即获赠免费筹码"
L.HALL.TUTORIAL_ROOMCARD = "点击可手动选场"
L.HALL.TUTORIAL_MORECARD = "更多免费筹码和小游戏"
L.HALL.TUTORIAL_STORE = "点击可购买筹码"
L.HALL.TUTORIAL_CARDTYPE = "点击可查看牌型大小"
L.HALL.ROOM_4K_LIMIT_TIPMSG = "进入4K场需要等级 {1} 级!"
L.HALL.ROOM_5K_LIMIT_TIPMSG = "进入5K场需要等级 {1} 级!"
L.HALL.ROOM_DICE_LIMIT_TIPMSG = "进入骰子场需要等级 {1} 级"   

L.HALL.TUTORIAL_REGISTERREWARD_MSG = "{1} 游戏币新手奖励已发放到你的账号，明天登陆可以获得更多哦！！！"
L.HALL.ARENA_LIMITE_LEVEL = "等級 Lv. {1}"
L.HALL.TIP_FRI_GIFT = "你今天已达到领取上限"

-- ROOM MODULE
L.ROOM.OPR_TYPE = {
    "看  牌",
    "弃  牌",
    "跟  注",
    "加  注",
}
L.ROOM.MY_MONEY = "My money {1} {2}"
L.ROOM.INFO_UID = "ID {1}"
L.ROOM.INFO_LEVEL = "Lv.{1}"
L.ROOM.INFO_RANKING = "排名:  {1}" 
L.ROOM.INFO_WIN_RATE = "胜率:  {1}%"
L.ROOM.INFO_SEND_CHIPS = "赠送筹码"
L.ROOM.ADD_FRIEND = "关注" 
L.ROOM.DEL_FRIEND = "取消关注"
L.ROOM.ADD_FRIEND_SUCC_MSG = "添加好友成功"
L.ROOM.ADD_FRIEND_FAILED_MSG = "添加好友失败"
L.ROOM.DELE_FRIEND_SUCCESS_MSG = "删除好友成功"
L.ROOM.DELE_FRIEND_FAIL_MSG = "删除好友失败"
L.ROOM.SEND_CHIP_NOT_NORMAL_ROOM_MSG = "只有普通场才可以赠送筹码"
L.ROOM.SELF_CHIP_NO_ENOUGH_SEND_DELEAR = "你的筹码不够多，不足给荷官小费"
L.ROOM.SEND_CHIP_NOT_IN_SEAT = "坐下才可以赠送筹码"
L.ROOM.SEND_CHIP_NOT_ENOUGH_CHIPS = "钱不够啊"
L.ROOM.SEND_CHIP_TOO_OFTEN = "赠送的太频繁了"
L.ROOM.SEND_CHIP_TOO_MANY = "赠送的太多了"
L.ROOM.SEND_HDDJ_IN_MATCH_ROOM_MSG = "比赛场不能发送互动道具"
L.ROOM.SEND_HDDJ_NOT_IN_SEAT = "坐下才能发送互动道具"
L.ROOM.SEND_HDDJ_NOT_ENOUGH = "您的互动道具数量不足，赶快去商城购买吧"
L.ROOM.SEND_EXPRESSION_MUST_BE_IN_SEAT = "坐下才可以发送表情"
L.ROOM.SEND_CHAT_MUST_BE_IN_SEAT = "您还未坐下，请坐下后重试"
L.ROOM.CHAT_FORMAT = "{1}: {2}"
L.ROOM.ROOM_INFO = "{1} {2}/前注{3}"
L.ROOM.NO_BIG_LA_BA = "暂无喇叭,是否立即购买？"
L.ROOM.CLOSE_BIG_LA_BA = "喇叭功能升级中，暂不能使用"
L.ROOM.SEND_BIG_LABA_MESSAGE_FAIL = "发送大喇叭消息失败"
L.ROOM.NOT_USE_HDDJ_MSG = "比赛场不可以使用互动道具哦"


L.ROOM.USER_CARSH_REWARD_DESC = "您获得了{1}筹码的破产补助，终身只有三次机会获得，且用且珍惜"
L.ROOM.USER_CARSH_BUY_CHIP_DESC = "您也可以立即购买，输赢只是转瞬的事"
L.ROOM.USER_CARSH_REWARD_COMPLETE_DESC = "您已经领完所有破产补助，您可以去商城购买筹码，每天登录还有免费筹码赠送哦！"
L.ROOM.USER_CARSH_REWARD_COMPLETE_BUY_CHIP_DESC = "输赢乃兵家常事，不要灰心，立即购买筹码，重整旗鼓。"

L.ROOM.WAIT_NEXT_ROUND = "请等待下一局开始"
L.ROOM.LOGIN_ROOM_FAIL_MSG = "登录房间失败"

L.ROOM.BUYIN_ALL_POT= "全部奖池"
L.ROOM.BUYIN_3QUOT_POT = "3/4奖池"
L.ROOM.BUYIN_HALF_POT = "1/2奖池"
L.ROOM.BUYIN_TRIPLE = "3倍反加"


L.ROOM.CHAT_TAB_SHORTCUT = "快捷聊天"
L.ROOM.CHAT_TAB_HISTORY = "聊天记录"
L.ROOM.INPUT_HINT_MSG = "点击输入聊天内容"
L.ROOM.INPUT_ALERT = "请输入有效内容"
L.ROOM.CHAT_SHIELD = "您已成功屏蔽{1}的发言"
L.ROOM.CHAT_SHORTCUT = {
  "你们好!",
  "快点，等不了了",
  "all in",
  "淡定",
  "好厉害",
  "谁敢来比比",
  "谢谢你送我游戏币",
  "和你玩牌真有意思",
  "有游戏币任性",
  "今天有点背",
  "不要吵架",
  "有女/男朋友了吗",
  "牌不好，换房间试试",
  "多多关照"
}

--买入弹框
L.ROOM.BUY_IN_TITLE = "买入筹码"
L.ROOM.BUY_IN_BALANCE_TITLE = "您的账户余额:"
L.ROOM.BUY_IN_BALANCE_TITLE1 = "您的账户现金币:"
L.ROOM.BUY_IN_MIN = "最低买入"
L.ROOM.BUY_IN_MAX = "最高买入"
L.ROOM.BUY_IN_AUTO = "筹码不足时自动买入"
L.ROOM.BUY_IN_AUTO1 = "黄金币不足时自动买入"
L.ROOM.BUY_IN_BTN_LABEL = "买入坐下"

L.ROOM.BACK_TO_HALL = "返回大厅"
L.ROOM.CHANGE_ROOM = "换  桌"
L.ROOM.SETTING = "设  置"
L.ROOM.SIT_DOWN_NOT_ENOUGH_MONEY = "您的筹码不足当前房间的最小携带，您可以点击自动换桌系统帮你选择房间或者补足筹码重新坐下。"
L.ROOM.AUTO_CHANGE_ROOM = "自动换桌"
L.ROOM.USER_INFO_ROOM = "个人信息"
L.ROOM.CHARGE_CHIPS = "补充筹码"
L.ROOM.ENTERING_MSG = "正在进入，请稍候...\n有识尚需有胆方可成赢家"
L.ROOM.OUT_MSG = "正在退出，请稍候..."
L.ROOM.CHANGING_ROOM_MSG = "正在更换房间.."
L.ROOM.CHANGE_ROOM_FAIL = "更换房间失败，是否重试？"
L.ROOM.STAND_UP_IN_GAME_MSG = "您还在当前牌局中，确认站起吗？"
L.ROOM.RECONNECT_MSG = "正在重新连接.."
L.ROOM.OPR_STATUS = {
    "弃  牌",
    "ALL_IN",
    "跟  注",
    "跟注 {1}",
    "小  盲",
    "大  盲",
    "看  牌",
    "加注 {1}",
    "加  注",
}
L.ROOM.AUTO_CHECK = "自动看牌"
L.ROOM.AUTO_CHECK_OR_FOLD = "看或弃"
L.ROOM.AUTO_FOLD = "自动弃牌"
L.ROOM.AUTO_CALL_ANY = "跟任何注"
L.ROOM.FOLD = "弃  牌"
L.ROOM.ALL_IN = "ALL IN"
L.ROOM.CALL = "跟  注"
L.ROOM.CALL_NUM = "跟注 {1}"
L.ROOM.SMALL_BLIND = "小盲"
L.ROOM.BIG_BLIND = "大盲"
L.ROOM.RAISE = "加  注"
L.ROOM.RAISE_NUM = "加注 {1}"
L.ROOM.CHECK = "看  牌"
L.ROOM.BLIND3 = "3x大盲"
L.ROOM.BLIND4 = "4x大盲"
L.ROOM.TABLECHIPS = "1x底池"
L.ROOM.TIPS = {
    "小提示：游客用户点击自己的头像弹框或者性别标志可更换头像和性别哦",
    "小经验：当你牌比对方小的时候，你会输掉已经押上的所有筹码",
    "高手养成：所有的高手，在他会三公游戏之前，一定是一个三公游戏的菜鸟",
    "有了好牌要加注，要掌握优势，主动进攻。",
    "留意观察对手，不要被对手的某些伎俩所欺骗。",
    "要打出气势，让别人怕你。",
    "控制情绪，赢下该赢的牌。",
    "游客玩家可以自定义自己的头像。",
    "小提示：设置页可以设置进入房间是否自动买入坐下。",
    "小提示：设置页可以设置是否震动提醒。",
    "忍是为了下一次All In。",
    "冲动是魔鬼，心态好，好运自然来。",
    "风水不好时，尝试换个位置。",
    "输牌并不可怕，输掉信心才是最可怕的。",
    "你不能控制输赢，但可以控制输赢的多少。",
    "用互动道具砸醒长时间不反应的玩家。",
    "运气有时好有时坏，知识将伴随你一生。",
    "诈唬是胜利的一大手段，要有选择性的诈唬。",
    "下注要结合池底，不要看绝对数字。",
    "All In是一种战术，用好并不容易。"
}
L.ROOM.SHOW_HANDCARD = "亮出手牌"
L.ROOM.DEALER_SPEEK_ARRAY = {
    "感谢你{1}！幸运必将常伴你左右！",
    "感谢你{1}！好运即将到来！",
    "感谢好心的{1}",
}
L.ROOM.SERVER_UPGRADE_MSG = "服务器正在升级中，请稍候.."
L.ROOM.USER_CRSH_POP_TITLE = "破产了"
L.ROOM.CHAT_MAIN_TAB_TEXT = {
    "消息", 
    "消息记录"
}
L.ROOM.KICKED_BY_ADMIN_MSG = "您已被管理员踢出该房间"
L.ROOM.KICKED_BY_USER_MSG = "您被用户{1}踢出了房间"
L.ROOM.TO_BE_KICKED_BY_USER_MSG = "您被用户{1}踢出房间，本局结束之后将自动返回大厅"
L.ROOM.BET_LIMIT = "下注失败，您单局下注不能超过最大下注100M限制。"
L.ROOM.BET_LIMIT_1 = "下注失败，您单局下注不能超过最大下注{1}限制。"
T = {}
L.COMMON.CARD_TYPE = T
T1 = {}
T[1] = T1 
T[2] = "同花" 
T[3] = "顺子" 
T[4] = "小三公" 
T[5] = "同花顺"
T[6] = "大三公"
T1[0] = "0点"
T1[1] = "1点"
T1[2] = "2点"
T1[3] = "3点"
T1[4] = "4点"
T1[5] = "5点"
T1[6] = "6点"
T1[7] = "7点"
T1[8] = "8点"
T1[9] = "9点"

TT = {}
L.COMMON.PDENG_CARD_TYPE = TT
TT1 = {}

TT[1] = TT1
TT[2] = "顺子"
TT[3] = "同花顺"
TT[4] = "三黄"
TT[5] = "三张"
TT[6] = "博定"
TT1[0] = "0点"
TT1[1] = "1点"
TT1[2] = "2点"
TT1[3] = "3点"
TT1[4] = "4点"
TT1[5] = "5点"
TT1[6] = "6点"
TT1[7] = "7点"
TT1[8] = "8点"
TT1[9] = "9点"

T = {}
L.ROOM.SIT_DOWN_FAIL_MSG = T
T["IP_LIMIT"] = "坐下失败，同一IP不能坐下"
T["SEAT_NOT_EMPTY"] = "坐下失败，该桌位已经有玩家坐下。"
T["TOO_RICH"] = "坐下失败，这么多筹码还来新手场虐人？"
T["TOO_POOR"] = "坐下失败，筹码不足无法进入非新手场房间。"
T["NO_OPER"] = "您超过三次没有操作，已被自动站起，重新坐下即可重新开始"

L.ROOM.SERVER_STOPPED_MSG = "系统正在停服维护, 请耐心等候"

L.ROOM.GUIDEHEIGHT = "去{1}场可赢更多钱"
L.ROOM.GUIDEHEIGHT1 = "去{1}场可赢更多黄金币"
L.ROOM.GUIDELOW = "去{1}场可以较少损失"

L.STORE.NOT_SUPPORT_MSG = "您的账户暂不支持支付"
L.STORE.PURCHASE_SUCC_AND_DELIVERING = "已支付成功，正在进行发货，请稍候.."
L.STORE.PURCHASE_CANCELED_MSG = "支付已经取消"
L.STORE.PURCHASE_FAILED_MSG = "支付失败，请重试"
L.STORE.PURCHASE_FAILED_MSG_2 = "此卡无效或输入有误，请重试。"
L.STORE.DELIVERY_FAILED_MSG = "网络故障，系统将在您下次打开商城时重试。"
L.STORE.DELIVERY_SUCC_MSG = "发货成功，感谢您的购买。"
L.STORE.TITLE_STORE = "商城"
L.STORE.TITLE_CHIP = "筹码"
L.STORE.TITLE_PROP = "互动道具"
L.STORE.TITLE_GOLD = "黄金币"
L.STORE.TITLE_VIP = "VIP"
L.STORE.TITLE_MY_PROP = "我的道具"
L.STORE.TITLE_HISTORY = "购买记录"

L.STORE.RATE_CHIP = "1{2}={1}筹码"
L.STORE.RATE_GOLD = "1{2}={1}黄金币"
L.STORE.RATE_PROP = "1{2}={1}个道具"
L.STORE.FORMAT_CHIP = "{1} 筹码"
L.STORE.FORMAT_PROP = "{1} 道具"
L.STORE.FORMAT_GOLD = "{1} 黄金币"
L.STORE.REMAIN = "剩余：{1}{2}"
L.STORE.INTERACTIVE_PROP = "互动道具"
L.STORE.BUY = "购买"
L.STORE.USE = "使用"
L.STORE.SEE = "查看"
L.STORE.BUY_CHIPS = "购买{1}筹码"
L.STORE.BUY_DESC = "购买 {1}"
L.STORE.RECORD_STATUS = {
    "已下单",
    "已发货",
    "已退款"
}
L.STORE.USE_SUCC_MSG = "道具使用成功"
L.STORE.USE_FAIL_MSG = "道具使用失败"
L.STORE.NO_PRODUCT_HINT = "暂无商品"
L.STORE.NO_BUY_HISTORY_HINT = "暂无支付记录"
L.STORE.MY_CHIPS = "我的筹码 {1}"
L.STORE.BUSY_PURCHASING_MSG = "正在购买，请稍候.."

L.STORE.PROP_DES = "购买后可获得{1}个互动道具"
L.STORE.KICK_CARD_DES = "购买后可获得1张踢人卡"
L.STORE.E2P_TICKET_DES_1018 = "购买后可以获得1张E2P 手机赛门票"
L.STORE.E2P_TICKET_DES_1019 = "购买后可以获得1张E2P 300现金赛门票"
L.STORE.E2P_TICKET_DES_1020 = "购买后可以获得1张E2P 200现金赛门票"
L.STORE.E2P_TICKET_DES_1021 = "购买后可以获得1张E2P 黄金赛门票"

-- login reward
L.LOGINREWARD.TITLE        = "连续登录奖励"
L.LOGINREWARD.REWARD       = "今日奖励{1}筹码"
L.LOGINREWARD.REWARD_ADD   = "1. 连续登录{1}天奖励{2}游戏币"
L.LOGINREWARD.REWARD_ADD_2 = "2. FB登录多加20000筹码"
L.LOGINREWARD.REWARD_ADD_3 = " {1} "
L.LOGINREWARD.PROMPT       = "连续登录可获得更多奖励，最高每天{1}游戏币奖励"
L.LOGINREWARD.DAYS         = "{1}天"
L.LOGINREWARD.NO_REWARD    = "三次注册礼包领取完成后即可领取"

-- USERINFO MODULE
L.USERINFO.MAX_MONEY_HISTORY = "历史最高资产:"
L.USERINFO.MAX_POT_HISTORY = "赢得最大奖池:"
L.USERINFO.WIN_RATE_HISTORY = "历史胜率:"
L.USERINFO.INFO_RANKING = "排名:"  
L.USERINFO.BEST_CARD_TYPE_HISTORY = "历史最佳牌型:"
L.USERINFO.MY_PROPS = "我的道具:"
L.USERINFO.MY_PROPS_TIMES = "X{1}"
L.USERINFO.EXPERIENCE_VALUE = "{1}/{2}" --经验值
L.USERINFO.INVITE_FRIEND_COUNT = "邀请好友数:"
L.USERINFO.MY_GOODS = "我的物品"
L.USERINFO.MY_INFOS = "我的成就"
L.USERINFO.MY_MATCH = "比赛记录"
L.USERINFO.HOLIDAY_PROP = "节日道具"
L.USERINFO.USE_PROP = "去使用"
L.USERINFO.QUICK_USE_PROP = "马上使用"

L.USERINFO.SCORE_TIPS = "1.现金币用于兑换话费卡等实物\n2.成功邀请1位好友获得1泰铢现金币\n3.通过比赛场可以获得更多现金币"
L.USERINFO.SCORE_TIPS_BTN = "兑换"

-- USERINFOMATCH MODULE
L.USERINFOMATCH.OTHER_CUP = "他的奖杯"
L.USERINFOMATCH.SELF_CUP = "我的奖杯"
L.USERINFOMATCH.WINRATE = "获冠军率"
L.USERINFOMATCH.MATCHCNT = "参赛次数"

L.USERINFOMATCH.COUNT = "统计"
L.USERINFOMATCH.TOOL = "道具"
L.USERINFOMATCH.GIFT = "礼包"
L.USERINFOMATCH.RECORD = "参赛记录"
L.USERINFOMATCH.TYPE = "比赛类型"
L.USERINFOMATCH.RANDING = "名次"
L.USERINFOMATCH.REWARD = "奖励"
L.USERINFOMATCH.TIME = "时间"
L.USERINFOMATCH.FB_NOT_EDITSEX = "FB用户修改性别无效";
L.USERINFOMATCH.FB_NOT_EDITNICK = "FB用户修改昵称无效";
L.USERINFOMATCH.NOREWARD = "未获得奖励";

-- FRIEND MODULE
L.FRIEND.NO_FRIEND_TIP = "暂无好友"
L.FRIEND.SEND_CHIP = "赠送筹码"
L.FRIEND.RECALL_CHIP = "召回+{1}"
L.FRIEND.ONE_KEY_SEND_CHIP = "一键赠送"
L.FRIEND.ONE_KEY_SEND_CHIP_TOO_POOR = "您的携带筹码的一半不足全部送出，请先补充筹码后重试。"
L.FRIEND.ONE_KEY_SEND_CHIP_CONFIRM = "确定要赠你给您的{1}位好友总计{2}筹码吗？"
L.FRIEND.ADD_FULL_TIPS = "您的好友已达到{1}的上限，系统将根据玩牌情况删除长久不玩牌的好友。"
L.FRIEND.SEND_CHIP_WITH_NUM = "赠送{1}筹码"
L.FRIEND.SEND_CHIP_SUCCESS = "您成功给好友赠送了{1}筹码。"
L.FRIEND.SEND_CHIP_TOO_POOR = "您的筹码太少了，请去商城购买筹码后重试。"
L.FRIEND.SEND_CHIP_COUNT_OUT = "您今天已经给该好友赠送过筹码了，请明天再试。"
L.FRIEND.INVITE_DESCRIPTION = "每邀请一位Facebook好友，可立即获赠{1}筹码。FaceBook好友接受邀请并成功登录游戏，您还可以额外获得{2}，多劳多送。\n\n同时，被邀请的好友登录游戏后也可获赠{3}筹码的注册礼包，赠送的筹码由系统免费发放。"
L.FRIEND.INVITE_REWARD_TIP = "您已累计获得了{1}筹码的邀请奖励，多劳多得，天天都有哦！"
L.FRIEND.INVITE_CODE = "您的邀请码："
L.FRIEND.INVITE_PROFIT = "累计收益："
L.FRIEND.SCAN_DOWN = "扫描下载"
L.FRIEND.INVITE_WITH_LINE = "Line邀请"
L.FRIEND.INVITE_WITH_SMS = "短信邀请"
L.FRIEND.INVITE_WITH_MORE = "更多邀请"
L.FRIEND.SELECT_ALL = "全选"
L.FRIEND.SELECT_NUM = "选择{1}人"
L.FRIEND.DESELECT_ALL = "取消选择"
L.FRIEND.SEND_INVITE = "邀请"
L.FRIEND.INVITE_SUBJECT = "您绝对会喜欢"
L.FRIEND.INVITE_CONTENT = "为您推荐一个既刺激又有趣的扑克游戏，我给你赠送了15万的筹码礼包，注册即可领取，快来和我一起玩吧！http://goo.gl/8RJoIe"
L.FRIEND.INVITE_CONTENT_OLDUSER = "我现在正在玩三公游戏，您有一段时间没登录了，快来和我一起玩吧！"
L.FRIEND.INVITE_CONTENT_SEAT = "{1}正在玩三公游戏，邀请你一起来玩。"
L.FRIEND.INVITE_SELECT_TIP = "您已选择了{1}位好友，发送邀请即可获得{2}筹码的奖励"
L.FRIEND.INVITE_FRIENDS_NUM_LIMIT_TIP = "一次邀请最多选取50位好友"
L.FRIEND.INVITE_SUCC_TIP = "成功发送了邀请，获得{1}筹码的奖励！"
L.FRIEND.INVITE_SUCC_FULL_TIP = "成功发送邀请，今日已获得{1}邀请发送奖励。"
L.FRIEND.INVITE_FULL_TIP = "您今日已达邀请上限，请明日再发送"
L.FRIEND.RECALL_SUCC_TIP = "发送成功奖励{1}，好友上线后即可获赠{2}筹码奖励。"
L.FRIEND.RECALL_FAILED_TIP = "发送失败，请稍后重试."
L.FRIEND.INVITE_LEFT_TIP = "今天还可以邀请{1}个好友！"
L.FRIEND.CANNOT_SEND_MAIL = "您还没有设置邮箱账户，现在去设置吗？"
L.FRIEND.CANNOT_SEND_SMS = "对不起，无法调用发送短信功能！"
L.FRIEND.MAIN_TAB_TEXT = {
    "我的好友", 
    "查找用户",
    "群组"
}
L.FRIEND.INVITE_EMPTY_TIP = "请先选择好友"

L.FRIEND.TOO_MANY_FRIENDS_TO_ADD_FRIEND_MSG = "您的好友已达到{1}上限，请删除部分后重新添加"
L.FRIEND.INVITE_OLD_USER_TIP = "您需要使用FB账号登陆才能发送邀请"
L.FRIEND.RESTORE_BTN_TIP = "恢复好友"
L.FRIEND.RETURN_BTN_TIP = "返回"
L.FRIEND.RESTORE_NO_DATA = "您没有可恢复的好友"

L.FRIEND.SEARCH_FRIEND = "请输入FB好友名称"
L.FRIEND.INVITEMATCH_SELECT_TIP = "您已选择了{1}位好友，发送邀请即可获得{2}比赛券的奖励"
L.FRIEND.INVITEMATCH_CHIPCNT = "比赛券+{1}"

L.FRIEND.ALERTLBL11 = "每邀请一位好友，您可获得{1}，每天最多可获得"
L.FRIEND.ALERTLBL12 = "{1} "
L.FRIEND.ALERTLBL13 = "{1} 比赛券"
L.FRIEND.ALERTLBL14 = "在此处邀请成功一位好友，您即可额外获得双倍冠军奖励2泰铢现金币。此处最多可邀请{1}位好友，机会难得，邀请好友进游戏，领取翻倍冠军奖励吧"
L.FRIEND.ALERTLBL15 = "在此处成功邀请好友进游戏，您可获得商品的现金币返利，最高可获得{1}%的商品定价返利。此处最多可邀请三位好友，机会难得，赶紧邀请好友享受返利吧！"

L.FRIEND.INVITE_ALERTLBL21 = "邀请1位好友可获得{1} "
L.FRIEND.INVITE_ALERTLBL22 = "{1} 游戏币"
L.FRIEND.INVITE_ALERTLBL23 = ",每天最多可获得 {1} "
L.FRIEND.INVITE_ALERTLBL11 = "每成功邀请一位好友,可获得 {1} "
L.FRIEND.INVITE_ALERTLBL12 = ",好友玩牌60局再奖励 {1} "
L.FRIEND.RECALL_TITLE = "召回好友"

L.FRIEND.SEARCH = "查找"
L.FRIEND.CLEAR = "清除"
L.FRIEND.INPUT_USER_ID = "点击输入玩家ID"
L.FRIEND.INPUT_USER_ID_NO_EXIST = "您输入的ID不存在，请确认后重新输入"
L.FRIEND.NO_SEARCH_SELF = "无法查找自己的ID，请重新输入"
L.FRIEND.NO_LINE_APP = "您没有安装Line应用,请使用其他方式邀请"

-- RANKING MODULE
L.RANKING.TRACE_PLAYER = "追踪玩家"
L.RANKING.GET_REWARD_BTN = "领取"
L.RANKING.GET_REWARD_SUCCESS = "领取昨日盈利榜奖励成功"
L.RANKING.ALREADY_GET_REWARD = "昨日盈利榜排名奖励已领取"
L.RANKING.GET_REWARD_DESC = "昨日盈利榜第{1}名\n获得\n{2}"
L.RANKING.GET_REWARD_TIPS = "提示：根据盈利榜每日24点排名进行奖励\n奖励隔天重置，请及时领取。"
L.RANKING.PROFIT_REWARD_DESC = "昨日盈利榜前20名\n可获得\n{1}"
L.RANKING.REFRESH_TIPS = "刷新的太频繁了!"
L.RANKING.EXPECT_TIPS = "敬请期待"
L.RANKING.NOT_DATA_TIPS = "暂无数据"
L.RANKING.YESTERDAY_PROFIT_TITLE = "昨日盈利冠军"

L.RANKING.YESTERDAY_PROFIT = "盈利{1}"
L.RANKING.NOT_IN_CHIP_RANKING = "你未能进入榜单，当前游戏币：{1}"
L.RANKING.NOT_IN_PROFIT_RANKING = "你未能进入榜单，当前盈利：{1}"

L.RANKING.PROFIT_RANKING = "你排第{1}名，当前盈利：{2}" 
L.RANKING.CHIP_RANKING = "你排第{1}名，当前游戏币：{2}"
L.RANKING.CASH_RANKING = "你排第{1}名，当前现金币：{2}" 
 

L.RANKING.MAIN_TAB_TEXT = {
    "总排行榜",
    "好友排行",
}

L.RANKING.SUB_TAB_TEXT_FRIEND = {
    "现金币榜",
    "游戏币榜",
}

L.RANKING.SUB_TAB_TEXT_GLOBAL = {
    "今日盈利榜",
    "游戏币榜",
    --"大师积分榜"
}

-- SETTING MODULE
L.SETTING.TITLE = "设置"
L.SETTING.NICK = "昵称"
L.SETTING.PLEASE_USE_FACEBOOK = '(使用Facebook登录奖励更多哦!)'
L.SETTING.LOGOUT = "登出"
L.SETTING.SOUND_VIBRATE = "声音和震动"
L.SETTING.SOUND = "声音"
L.SETTING.BG_SOUND = "背景音效"
L.SETTING.CHATVOICE = "聊天音效"
L.SETTING.VIBRATE = "震动"
L.SETTING.OTHER = "其他"
L.SETTING.AUTO_SIT = "进入房间自动坐下"
L.SETTING.AUTO_BUYIN = "自动买入"
L.SETTING.APP_STORE_GRADE = "喜欢我们，打分鼓励"
L.SETTING.CHECK_VERSION = "检测更新"
L.SETTING.CURRENT_VERSION = "当前版本号：V{1}"
L.SETTING.ABOUT = "关于"
L.SETTING.FANS = "官方粉丝页"

L.HELP.TITLE = "帮助"
L.HELP.SUB_TAB_TEXT = {
    "问题反馈",
    "常见问题",
    "基本规则",
    "等级说明",
    "惩罚规则"
}
L.HELP.FEED_BACK_HINT = "您在游戏中碰到的问题或者对游戏有任何意见或者建议，我们都欢迎您给我们反馈"
L.HELP.NO_FEED_BACK = "您现在还没有反馈记录"
L.HELP.FEED_BACK_SUCCESS = "反馈成功!"
L.HELP.UPLOADING_PIC_MSG = "正在上传图片，请稍候.."
L.HELP.MUST_INPUT_FEEDBACK_TEXT_MSG = "请输入反馈内容"
L.HELP.VIEW_BACK_LIST = ">>反馈记录"
L.HELP.MATCH_QUESTION = "比赛问题"
L.HELP.FAQ = {
    {
        "รับชิปฟรีที่ไหนบ้าง",
        "มีโบนัสล็อกอิน โบนัสอัพเลเวล โบนัสภารกิจ โบนัสแฟนส์ โบนัสเชิญเพื่อน เป็นต้นแล้วยังมีกิจกรรมต่างๆด้วย"
    },
    {
        "ซื้อชิปอย่างไร",
        {
            "กดปุ่ม",
            "แล้วเลือกยอดชิปที่ท่านต้องการ"
        }
    },
    {
        "กลายเป็นแฟนส์อย่างไร",
        "กดปุ่ม ตั้งค่า มีช่องหน้าแฟนส์ที่ข้างล่าง\nหรือกดไลค์ลิ้งก์ https://www.facebook.com/9kThai\nทางระบบจะแจกโบนัสแฟนส์ทุกวันเลยนะ"
    },
    {
        "ห้องเกสองใบ เล่นอย่างไร",
        "ที่ห้องสู้สองใบ ระบบจะแจกใพ่คนละ2ใบ ผู้เล่นสามารถเกทับรอบแรกได้ หรือว่าเลือกผ่านก็ได้เมื่อเกทับรอบแรกเสร็จ ระบบจะแจกไพ่ใบที่3ให้ผู้เล่นแต่ละคน ผู้เล่นสามารถเกทับอีกรอบได้"
    },
    {
        "ล็อกเอาท์อย่างไร",
        "กดปุ่มตั้งค่า แล้วเลือกกด ออกระบบก็เรียบร้อยละ"
    },
    {
        "เปลี่ยนชื่อ รูป เพศอย่างไร",
        "กดรูปของตัวเองแล้วตั้งเปลี่ยนตามปุ่มที่โชว์ออกมา"
    }
}

L.HELP.RULE = {
    {
        "เงื่อนไขการพิจารณาไพ่ที่อยู่ระดับเดียวกัน",
        ""
    },
    {
        "牌的排序规则",
        "(A)单张牌排序由小至大为：2,3,4,5,6,7,8,9,10,J,Q,K,A\n(B)花色对比为：梅花<方块<红桃<黑桃\n(C)牌型由小至大为：普通牌<同花<顺子<三公<同花顺<三条"
    },
    {
        "การเดิมพัน",
        "หลังจากที่ผู้เล่นได้ทำการเปิดดูไพ่ทั้งสามใบในมือเป็นที่เรียบร้อยแล้ว ผู้เล่นมีทางเลือกดังต่อไปนื้คือ\n(1) “หมอบ” คือ ยอมแพ้ในตานี้ โดยผู้เล่นจะเสียเงินเดิมพันเริ่มต้นไป\n(2) “เกทับ” คือเพิ่มเงินเดิมพันเพิ่มเข้าไปอีก โดยไม่ต่ำกว่าเงินเดิมพันเริ่มต้น\n(3) “สู้”คือการวางเงินเดิมพันเพิ่มเข้าไป ให้เท่ากับผู้เล่นที่เกทับไปก่อนหน้านี้\n(4) “ผ่าน”คือ การไม่ลงเดิมพันเพิ่มเติม แต่ยังเล่นอยู่เหมือนเดิม"
    },
    {
        "การเปิดไพ่",
        "หลังจากที่ไม่มีผู้เล่นเพิ่มการเดิมพันแล้ว ผู้เล่นทุกคนจะต้องทำการเปิดไพ่ (ยกเว้นผู้เล่นที่หมอบไปแล้ว)เพื่อทำการเทียบไพ่ หาผลแพ้ชนะ ในกรณีที่มีผู้เล่นหมอบกันหมด แล้ว เหลีอผู้เล่นเพียงคนเดียว ผู้เล่นที่เหลือคือผู้ชนะ และสามารถเลือกได้ว่าจะทำการเปิดไพ่ให้ผู้เล่นที่เหลือได้ดูหรือไม่ก็ได้"
    },
    {
        "ไพ่ธรรมดานับแต้ม",
        "คือไพ่นับแต้มตามเลขนั้นๆ ยกเว้น 10 J Q K นับเป็น 0 แต้มที่รวมกันเกินสิบ ให้ตัดเลขหลักสิบออก เหลือแต่เลขหลักหน่วย แต้มที่มีค่ามากที่สุดคือ9แต้ม กรณีที่มีแต้มเหมือนกัน ให้ดูไพ่สูงสุดของผู้มีแต่ละคน ว่า ใครมีมากกว่ากัน ดูการเรียงไพ่จาก(A) ถ้าแต้มเท่ากันอีก ให้ดูสีของไพ่สูงสุดจาก(B)"
    },
    {
        "ไพ่สี ดอกเดียวกัน",
        "คือไพ่สามใบเป็นไพ่ที่มีดอกเดียวกัน ซึ่งในกรณีที่มีผู้เล่นสูงสุดมีไพ่ดอกเดียวกันหลายๆคน ก็ให้พิจารณาจาก สีของไพ่ โดยการเรียงดอกของไพ่ให้ดูจากข้อ(B) แล้วถ้ายังเป็นดอดเดียวกันอีก ก็ให้พิจารณาแต้มของไพ่สูงสุด โดยเทียบได้จากข้อ(A)"
    },
    {
        "ไพ่เรียง",
        "คือไพ่สามใบในมือมีเลขเรียงกัน เช่น 6,7,8 โดยการเรียงของตัวเลขให้ยึดตามข้อ(A)โดยเล่นที่เรียงกันแต่ละใบ สีดอกของไพ่อาจจะไพ่เหมือนกันก็ได้ ในการณีที่ผู้เล่นที่ มีไพ่เรียงเหมือนๆกันหลายคน ให้พิจารณาจากแต้มการเรียงก่อน ซึ่งถ้ายังเท่ากันอยู่ ก็ให้ดูจากสีของไพ่ใบสูงสุด โดยเทียบสีไพ่ได้จากข้อ(B)"
    },
    {
        "ไพ่เซียน",
        "คือ ไพ่สามใบเป็นไพ่ที่อยู่ในกลุ่ม J Q K เท่านั้น เช่น JJQ, QQK เป็นต้น กรณีที่มีไพ่เซียนเหมือนๆกันหลายคน ให้พิจารณาจากแต้มของไพ่สูงสุดก่อน ซึง ถ้ายังเท่ากันอยู่ ก็ให้ดูจากสีของไพ่สูงสุด"
    },
    {
        "ไพ่สเตรทฟลัช",
        "คือไพ่สามใบในมือเรียงกันโดยมีดอก(สี)เดียวกัน ในกรณีที่ผู้เล่นที่มีไพ่สเตรทฟลัชเหมือนๆกันหลายคน ให้พิจารณาจากสีของไพ่ก่อน โดยเทียบ สีไพ่ได้จากข้อ(B) ซึ่งถ้ายังเท่ากันอีก ให้ดูที่แต้มไพ่ใบสูงสุดของแต่ละผู้เล่น"
    },
    {
        "ไพ่ตอง",
        "คือไพ่ที่มีเลขเดียวกันทั้งสามใบ (ตอง3มีค่ามากที่สุด รองลงมาคือ ตองA) กรณีตองสู้ตอง ให้พิจารณาจากแต้มของไพ่โดยไม่ต้องดูสีของไพ่ "
    }
}
L.HELP.LEVEL = {
    {
        "เล่นไพ่ได้รับEXP",
        "ชนะจะได้เพิ่มEXP  คะแนนEXPที่ได้ = จำนวนผู้เล่นที่ชนะx2；แพ้จะถูกหักEXP1คะแนน  จำนวนคะแนน EXP ที่ได้เพิ่มมามากสุดคือวันละ 600 ค่ะเพิ่ม: ช่วงมือใหม่(Lv1- LV 3)แพ้จะไม่ถูกหักEXP"
    },
    {
        "รางวัลอัพเลเวล",
      {
            {
                "LV", "สมญา", "EXPทั้งหมด", "รางวัลเลเวล"
            },
            {
                "LV1", "รู้จักเก้าเก", "0", ""
            },
            {
                "LV2", "มือใหม่เก้าเก", "25", "10,000 ชิป"
            },
            {
                "LV3", "ผู้รักเก้าเก", "80", "20,000 ชิป"
            },
            {
                "LV4", "มือคลับ", "240", "30,000 ชิป"
            },
            {
                "LV5", "โปรคลับ", "520", "50,000 ชิปไอเทม10ครั้ง"
            },
            {
                "LV6", "แชมป์คลับ", "1,249", "    50,000 ชิป"
            },
            {
                "LV7", "มือประจำเขต", "2,499", "50,000 ชิป"
            },
            {
                "LV8", "โปรเขต", "4,277", "50,000 ชิปไอเทม15ครั้ง"
            },
            {
                "LV9", "แชมป์เขต", "7,198", "50,000 ชิป"
            },
            {
                "LV10", "มือประจำเมือง", "10,990", "200,000 ชิปไอเทม30ครั้ง"
            },
            {
                "LV11", "โปรเมือง", "16,003", "200,000 ชิปไอเทม 20ครั้ง"
            },
            {
                "LV12", "แชมป์เมือง", "22,466", "200,000 ชิป"
            },
            {
                "LV13", "มือประเทศ", "30,658", "200,000 ชิป"
            },
            {
                "LV14", "โปรประเทศ", "40,931", "200,000 ชิป"
            },
            {
                "LV15", "แชมป์ประเทศ", "53,748", "500,000 ชิป"
            },
            {
                "LV16", "มือเอเชีย", "69,744", "500,000 ชิปไอเทม 30 ครั้ง"
            },
            {
                "LV17", "โปรเอเชีย", "89,816", "500,000 ชิป"
            },
            {
                "LV18", "แชมป์เอเชีย", "115,264", "200,000 ชิปไอเทม 30ครั้ง"
            },
            {
                "LV19", "มืออินเตอร์", "148,000", "500,000 ชิป"
            },
            {
                "LV20", "โปรอินเตอร์", "190,877", "1,000,000 ชิปไอเทม60ครั้ง"
            },
            {
                "LV21", "แชมป์อินเตอร์", "248,186", "1,000,000 ชิป"
            },
            {
                "LV22", "มืออันดับโลก", "326,416", "1,000,000 ชิป"
            },
            {
                "LV23", "โปรระดับโลก", "435,424", "1,000,000  ชิปไอเทม60ครั้ง"
            },
            {
                "LV24", "แชมป์โลก", "590,214", "1,000,000  ชิป"
            },
            {
                "LV25", "ตำนานเก้าเก", "813,671", "5,000,000  ชิปไอเทม100ครั้ง"
            }
        }
    }
}

L.HELP.PUNISH = {
    {
        "规则1",
        "111111111111111"
    },
    {
        "规则2",
        "2222222222"
    },
    {
        "规则3",
        "3333333333"
    }
}

L.UPDATE.TITLE = "发现新版本"
L.UPDATE.DO_LATER = "以后再说"
L.UPDATE.UPDATE_NOW = "立即升级"
L.UPDATE.HAD_UPDATED = "您已经安装了最新版本"

L.ABOUT.TITLE = "关于"
L.ABOUT.UID = "当前玩家ID: {1}"
L.ABOUT.VERSION = "版本号：V{1}" 
L.ABOUT.FANS = "官方粉丝页："
L.ABOUT.FANS_URL = "https://www.facebook.com/9kThai"
L.ABOUT.FANS_OPEN = "https://www.facebook.com/9kThai"
L.ABOUT.SERVICE = "服务条款与隐私策略"
L.ABOUT.COPY_RIGHT = "Copyright © 2009-2016 Boyaa Interactive...All Rights Reserved."

L.DAILY_TASK.GET_REWARD = "领取奖励"
L.DAILY_TASK.HAD_FINISH = "已完成"
L.DAILY_TASK.COMPLETE_REWARD = "恭喜你完成了任务：{1}"
L.DAILY_TASK.CHIP_REWARD = "奖励{1}筹码"
L.DAILY_TASK.TAB_TEXT = {
    "任务",
    "成就"
}

-- count down box
L.COUNTDOWNBOX.TITLE = "倒计时宝箱"
L.COUNTDOWNBOX.SITDOWN = "坐下才可以继续计时。"
L.COUNTDOWNBOX.FINISHED = "您今天的宝箱已经全部领取，明天还有哦。"
L.COUNTDOWNBOX.NEEDTIME = "再玩{1}分{2}秒，您将获得{3}。"
L.COUNTDOWNBOX.REWARD = "恭喜您获得宝箱奖励{1}。"
L.COUNTDOWNBOX.TIPS = "成功邀请好友进游戏\n可以得到翻倍奖励"

L.USERINFO.UPLOAD_PIC_NO_SDCARD = "没有安装SD卡，无法使用头像上传功能"
L.USERINFO.UPLOAD_PIC_PICK_IMG_FAIL = "获取图像失败"
L.USERINFO.UPLOAD_PIC_UPLOAD_FAIL = "上传头像失败，请稍后重试"
L.USERINFO.UPLOAD_PIC_IS_UPLOADING = "正在上传头像，请稍候..."
L.USERINFO.UPLOAD_PIC_UPLOAD_SUCCESS = "上传头像成功"

L.NEWESTACT.NO_ACT = "暂无活动"
L.NEWESTACT.TITLE = "最新活动"
L.NEWESTACT.LOADING = "加载中..."
L.NEWESTACT.GET_REWARD_SUCC = "你领取了{1}"

L.FEED.SHARE_SUCCESS = "分享成功"
L.FEED.SHARE_FAILED = "分享失败"
L.FEED.SHARE_LINK = "http://goo.gl/8RJoIe"
L.FEED.LOGIN_REWARD = {
    name = "太棒了!我在三公领取了{1}筹码的奖励，快来和我一起玩吧！",
    caption = "天天登录筹码送不停",
    link = "http://goo.gl/8RJoIe",
    picture = "http://pclptl9k02-static.boyaagame.com/static/nineke/nineke/share/youwin.jpg",
    message = "",
}
L.FEED.EXCHANGE_CODE = {
    name = "我用三公粉丝页的兑换码换到了{1}的奖励，快来和我一起玩吧！",
    caption = "粉丝奖励兑换有礼",
    link = "http://goo.gl/8RJoIe",
    picture = "http://pclptl9k02-static.boyaagame.com/static/nineke/nineke/images/feed/EXCHANGE_CODE1.jpg",
    message = "",
}
L.FEED.WHEEL_ACT = {
    name = "快来和我一起玩开心转转转吧，每天登录就有三次机会！",
    caption = "开心转转转100%中奖", 
    link = "http://goo.gl/8RJoIe",
    picture = "http://pclptl9k02-static.boyaagame.com/static/nineke/nineke/images/feed/WHEEL_ACT1.jpg",
    message = "",
}
L.FEED.WHEEL_REWARD = {
    name = "我在三公的幸运转转转获得了{1}的奖励，快来和我一起玩吧！",
    caption = "开心转转转100%中奖",
    link = "http://goo.gl/8RJoIe",
    picture = "http://pclptl9k02-static.boyaagame.com/static/nineke/nineke/images/feed/WHEEL_REWARD1.jpg",
    message = "",
}
L.FEED.UPGRADE_REWARD = {
    name = "太棒了，我刚刚在三公成功升到了{1}级，领取了{2}的奖励，快来膜拜吧！",
    caption = "升级领取大礼",
    link = "http://goo.gl/8RJoIe",
    picture = "http://pclptl9k02-static.boyaagame.com/static/nineke/nineke/images/feed/levelUp/level{1}.png",
    message = "",
}
L.FEED.MATCH_COMPLETE = {
    name = "我在三公{1}中获得第{2}名，赶快来一起玩吧！",
    caption = "一起来比赛！",
    link = "http://goo.gl/8RJoIe",
    picture = "http://pclptl9k02-static.boyaagame.com/static/nineke/nineke/share/match.jpg",
    message = "",
}
L.FEED.SCORE_EXCHANGE = {
    name = "我在三公比赛获取了{1}。三公比赛，不用花钱即可赚取电话充值卡，一起来参加吧。",
    caption = "一起来比赛！",
    link = "http://goo.gl/8RJoIe",
    picture = "http://pclptl9k02-static.boyaagame.com/static/nineke/nineke/images/feed/LOGIN_REWARD1.jpg",
    message = "",
}

L.FEED.PROMOT_ACT = {
    name = "",
    caption = "",
    link = "http://goo.gl/8RJoIe",
    picture = "http://pclptl9k02-static.boyaagame.com/static/nineke/nineke/images/mobileAct/team/coalition.jpg",
    message = "",
}

L.FEED.SONGKRAN_ACT = {
    name = "集‘x,x,x’福字兑博雅三公百万大礼！欲知详情请登录游戏查看详细信息>>>",
    caption = "欢度宋干节",
    link = "http://goo.gl/8RJoIe",
    picture = "http://pclptl9k02-static.boyaagame.com/static/nineke/nineke/images/mobileAct/playCards/sgjshare.png",
    message = "",
}

L.FEED.ACHIEVEMENT_REWARD = {
    name = "我在三公完成了{1}的成就，获得了{2}的奖励，快来和我一起玩吧！",
    caption = "",
    link = "http://goo.gl/8RJoIe",
    picture = "http://pclptl9k02-static.boyaagame.com/static/nineke/nineke/images/achievement/share.png",
    message = "",
}
L.FEED.CHRISTMAS_ACT = {
    name = "",
    caption = "",
    link = "http://goo.gl/8RJoIe",
    picture = "http://pclptl9k02-static.boyaagame.com/static/nineke/nineke/share/christmas.png",
    message = "",
}
L.FEED.RANK_REWARD = {
    name = "太棒了!我昨天在三公里赢得了{1}筹码，快来和我一起玩吧!",
    caption = "",
    link = "http://goo.gl/8RJoIe",
    picture = "http://pclptl9k02-static.boyaagame.com/static/nineke/nineke/share/youwin.jpg",
    message = "",
}

L.SHARE.SUCANDCHECK = "您的截图已发送！\n客服MM正在查看\n现金币返利24小时内会发放到您的现金币账上，请注意查收"
L.SHARE.FAIL = "截图发送失败，请重新发送"
L.SHARE.FAIL_1 = "您的网络不好，请稍后重试"
L.SHARE.FAIL_2 = "您的图片太大，上传失败"
L.SHARE.SHOTANDSAVE = "截图保存"
L.SHARE.SHOTSAVESUC = "截图保存成功"
L.SHARE.SHOTSAVEFAL = "对不起,截图失败,请重新截图"
L.SHARE.DETAILINFO = "详情"
L.SHARE.UPLOAD24 = "您近两天还没兑换过奖品哦。\n兑换奖品，发送到Line或facebook分享，即可获得现金币返利\n快来参加吧！"
L.SHARE.UPLOAD24_1 = "去兑换"
L.SHARE.VIRTUALWORD = "恭喜您兑换奖品成功,得到{1}"

-- message
L.MESSAGE.TAB_TEXT = {
    "好友消息", 
    "系统消息"
}
L.MESSAGE.EMPTY_PROMPT = "您现在没有消息记录"

--奖励兑换码
L.ECODE.TITLE = "奖励兑换"
L.ECODE.EDITDEFAULT = "请输入6位奖励兑换码或8位邀请码"
L.ECODE.DESC = "关注粉丝页可免费领取奖励兑换码,我们还会不定期在官方粉丝页推出各种精彩活动,谢谢关注。\n\n粉丝页地址 https://www.facebook.com/9kThai"
L.ECODE.EXCHANGE = "兑  奖"
L.ECODE.SUCCESS = "恭喜您，兑奖成功！\n您获得了{1}"
L.ECODE.ERROR_FAILED = "兑换码或邀请码输入错误，请重新输入！"
L.ECODE.ERROR_INVALID="兑奖失败，您的兑换码已经失效。"
L.ECODE.ERROR_USED = "兑奖失败，每个兑换码只能兑换一次。\n您已经兑换到了{1}"
L.ECODE.ERROR_END= "领取失败，本次奖励已经全部领光了，关注我们下次早点来哦"
L.ECODE.FANS = "关注粉丝页"
L.ECODE.CODE = "兑换码：{1}"
L.ECODE.CODE1 = "PIN码稍后可在兑换记录中查看"
--大转盘
L.WHEEL.SHARE = "分享"
L.WHEEL.REMAIN_COUNT = "剩余抽奖数"
L.WHEEL.REMAIN_COUNT2 = "剩余抽奖数"
L.WHEEL.TIME = "次"
L.WHEEL.TIME2 = "次"
L.WHEEL.DESC1 = "游客2次"
L.WHEEL.DESC1_2 = "Facebook用户4次"

L.WHEEL.DESC2_PRE = "每次"
L.WHEEL.DESC2_POST = "中奖"
L.WHEEL.DESC3 = "绝不落空，最高可赢取一千万筹码。"
L.WHEEL.DESC4 = "立即开始吧，点击开始抽奖按钮！"
L.WHEEL.PLAY = "开始\n抽奖"
L.WHEEL.REWARD = {
    "中大奖了!",
    "恭喜您,抽中{1}的奖励。"
}
L.WHEEL.INVITE_FB = "邀请好友"
L.WHEEL.RECALL_FB = "召回好友"
L.WHEEL.NEW_DESC1 = "每天登录可获得4次抽奖机会"
L.WHEEL.NEW_DESC1_1 = "每多成功邀请一位FB好友，可获得多一次抽奖机会"
L.WHEEL.NEW_DESC1_2 = "(每日最多可获得10次机会)"
L.WHEEL.NEW_DESC2 = "每次100%中奖"
L.WHEEL.GOTO_RECORD = "查看记录"
L.WHEEL.REWARD_RECORD = "恭喜您在“幸运大转盘”中抽中了{1} "
L.WHEEL.DIALOG_CONTENT = "恭喜您获得{1}奖励"
L.WHEEL.DIALOG_KNOWN = "我知道了"
L.WHEEL.DIALOG_SEE = "查看记录"

L.WHEEL.LUCKTURN_COMFIRM_PAYFEE = "确定消耗 {1} 现金币抽奖么？"
L.WHEEL.LUCKTURN_NOT_ENOUGH_MONEY = "很抱歉，您的现金币不足"

L.WHEEL.LUCKYRANK = "好运榜"
L.WHEEL.MYRECORD = "我的记录"
L.WHEEL.NOLUCKYRANK = "暂时还没人中大奖，快去玩转盘吧。下一个中大奖就是你"
L.WHEEL.NOMYRECORD = "您还没有抽奖记录，快去玩转盘吧。下一个中大奖就是你"
L.WHEEL.NOTENOUGHMONEY = "您的筹码不足，请先购买筹码后重试。"

L.WHEEL.DOWNDUMMYPRESENT = "下载大米即可获得转盘机会2次"
L.WHEEL.DOWNDUMMYPRESENT2 = "活动中心还有好礼相送"

L.WHEEL.NOCHANCE = "今天转盘的机会不足"
L.WHEEL.NOCHANCE2 = "还没有转盘机会，马上下载大米获得机会"

--银行
L.BANK.BANK_BUTTON_LABEL = "银行"
L.BANK.BANK_GIFT_LABEL = "我的礼物"
L.BANK.BANK_DROP_LABEL = "我的道具"
L.BANK.BANK_HALLOWEEN_PROP = "南瓜灯互动道具"
L.BANK.BANK_LABA_LABEL = "喇叭"
L.BANK.SAVE_BUTTON_LABEL = "存钱"
L.BANK.DRAW_BUTTON_LABEL = "取钱"
L.BANK.CANCEL_PASSWORD_SUCCESS_TOP_TIP = "取消密码成功"
L.BANK.CANCEL_PASSWORD_FAIL_TOP_TIP = "取消密码失败"
L.BANK.EMPYT_CHIP_NUMBER_TOP_TIP = "请输入金额"
L.BANK.USE_BANK_NO_VIP_TOP_TIP = "你不是VIP用户不能使用保险箱功能"
L.BANK.USE_BANK_SAVE_CHIP_SUCCESS_TOP_TIP = "存钱成功"
L.BANK.USE_BANK_SAVE_CHIP_FAIL_TOP_TIP = "存钱失败"
L.BANK.USE_BANK_DRAW_CHIP_SUCCESS_TOP_TIP = "取钱成功"
L.BANK.USE_BANK_DRAW_CHIP_FAIL_TOP_TIP = "取钱失败"
L.BANK.BANK_POPUP_TOP_TITIE = "个人银行"
L.BANK.BANK_INPUT_TEXT_DEFAULT_LABEL = "请输入密码"
L.BANK.BANK_CONFIRM_INPUT_TEXT_DEFAULT_LABEL = "请再次输入密码"
L.BANK.BANK_INPUT_PASSWORD_ERROR = "你输入的密码有误，请从新输入"
L.BANK.BANK_SET_PASSWORD_TOP_TITLE = "设置密码"
L.BANK.BANK_SET_PASSWORD_SUCCESS_TOP_TIP = "设置密码成功"
L.BANK.BANK_SET_PASSWORD_FAIL_TOP_TIP = "设置密码失败"
L.BANK.BANK_LEVELS_DID_NOT_REACH = "你的等级没有达到五级，不能使用保险箱"
L.BANK.BANK_CANCEL_OR_SETING_PASSWORD = "取消或者设置密码"
L.BANK.BANK_FORGET_PASSWORD_FEEDBACK = "忘记密码请向管理员反馈"
L.BANK.BANK_FORGET_PASSWORD_BUTTON_LABEL = "忘记密码"
L.BANK.BANK_SETTING_PASSWORD_BUTTON_LABEL = "设置密码"
L.BANK.BANK_SETTING_RESETPASSWORD_BUTTON_LABEL = "修改密码"
L.BANK.BANK_CACEL_PASSWORD_BUTTON_LABEL = "取消密码"

L.BANK.USERINFO_BANK_TIPS = "当前保险箱处于高危状态，请尽快设置密码"
L.BANK.PROTECT_QUESTIONS = {
    "您的生日",
    "您配偶的生日",
    "您父亲的名字",
    "您母亲的名字",
    "您配偶的名字",
    "您最喜欢的明星"
}

L.BANK.MAIN_TAB_TEXT = {
    "游戏币", 
    "现金币"
}
L.BANK.MYSELFBANK="我的保险箱"
L.BANK.CARRYMONEY="我的携带"

L.BANK.PROTECT_SET = "设置密保"
L.BANK.PROTECT_UPDATE = "修改密保"
L.BANK.PROTECT_VERIFY = "验证密保"
L.BANK.PROTECT_ANSTIPS = "请输入您的答案"
L.BANK.PROTECT_TITLETIPS_SET = "首次设置密保,可获得10K游戏币"
L.BANK.PROTECT_TITLETIPS_UPDATE = "忘记密码可通过密保重置密码"
L.BANK.PROTECT_TITLETIPS_VERIFY = "正确回答以下问题重置密码"
L.BANK.PROTECT_ERRORTIPS = "请输入问题答案"
L.BANK.PROTECT_ANSERROR = "您的答案有误"
L.BANK.PROTECT_ANSSUCCESS = "验证成功，请重新设置密码或取消密码"
L.BANK.PROTECT_QUES1TITLE = "问题1:"
L.BANK.PROTECT_QUES2TITLE = "问题2:"
L.BANK.PROTECT_FEEDBACK = "联系客服"
L.BANK.PROTECT_ANSTITLE = "答案:"
L.BANK.PROTECT_SETSUCC = "密保设置成功,获得10K游戏币"
L.BANK.PROTECT_UPDATESUCC = "密保修改成功"
L.BANK.PROTECT_SETERROR = "密保设置失败"
L.BANK.PROTECT_VERIFYERROR = "密保验证失败"

--老虎机
L.SLOT.NOT_ENOUGH_MONEY = "老虎机购买失败,你的筹码不足"
L.SLOT.NOT_ENOUGH_GCOINS = "老虎机购买失败,你的黄金币不足"
L.SLOT.SYSTEM_ERROR = "老虎机购买失败，系统出现错误"
L.SLOT.PLAY_WIN = "你赢得了{1}筹码"
L.SLOT.PLAY_WIN_BYGCOIN = "你赢得了{1}黄金币"
L.SLOT.TOP_PRIZE = "玩家 {1} 玩老虎机抽中大奖，获得筹码{2}"
L.SLOT.FLASHBAR_TIP = "头奖：{1}"
L.SLOT.FLASHBAR_WIN = "你赢了：{1}"
L.SLOT.FLASHBAR_GCOINS_WIN = "你赢了：{1}"
L.SLOT.AUTO = "自动"
L.SLOT.GUIDE = "抽空玩玩老虎机哦"

--升级弹框
L.UPGRADE.OPEN = "打开"
L.UPGRADE.SHARE = "分享"
L.UPGRADE.GET_REWARD = "获得{1}"

L.GIFT.SET_SELF_BUTTON_LABEL = "设为我的礼物"
L.GIFT.BUY_TO_TABLE_GIFT_BUTTON_LABEL = "买给牌桌x{1}"
L.GIFT.CURRENT_SELECT_GIFT_BUTTON_LABEL = "你当前选择的礼物"
L.GIFT.PRESENT_GIFT_BUTTON_LABEL = "赠送"
L.GIFT.DATA_LABEL = "天"
L.GIFT.SELECT_EMPTY_GIFT_TOP_TIP = "请选择礼物"
L.GIFT.BUY_GIFT_SUCCESS_TOP_TIP = "购买礼物成功"
L.GIFT.BUY_GIFT_FAIL_TOP_TIP = "购买礼物失败"
L.GIFT.SET_GIFT_SUCCESS_TOP_TIP = "设置礼物成功"
L.GIFT.SET_GIFT_FAIL_TOP_TIP = "设置礼物失败"
L.GIFT.PRESENT_GIFT_SUCCESS_TOP_TIP = "赠送礼物成功"
L.GIFT.PRESENT_GIFT_FAIL_TOP_TIP = "赠送礼物失败"
L.GIFT.PRESENT_TABLE_GIFT_SUCCESS_TOP_TIP = "赠送牌桌礼物成功"
L.GIFT.PRESENT_TABLE_GIFT_FAIL_TOP_TIP = "赠送牌桌礼物失败"
L.GIFT.NO_GIFT_TIP = "暂时没有礼物"
L.GIFT.MY_GIFT_MESSAGE_PROMPT_LABEL = "点击选中既可在牌桌上展示才礼物"


L.GIFT.SUB_TAB_TEXT_SHOP_GIFT = {
    "热销", 
    "精品",
    "节日",
    "其他"
}
L.GIFT.SUB_TAB_TEXT_MY_GIFT = {
    "自己购买", 
    "牌友赠送",
    "特别赠送"
}

L.GIFT.MAIN_TAB_TEXT = {
    "商城礼物", 
    "我的礼物"
}

-- 破产
L.CRASH.PROMPT_LABEL = "您获得{1}筹码的破产救济金，同时还获得当日充值优惠一次，立即充值，重振雄风！"
L.CRASH.THIRD_TIME_LABEL = "您获得最后一次{1}筹码的破产救济金，同时还获得当日充值优惠一次，立即满血复活，再战江湖！"
L.CRASH.OTHER_TIME_LABEL = "您已经领完所有破产救济金了，您可以去商城购买筹码，每天登录还有免费筹码赠送哦！"
L.CRASH.TITLE = "你破产了！" 
L.CRASH.CHIPS_TIPS = "破产救济"
L.CRASH.CHIPS_TIPS_2 = "救济金"
L.CRASH.REWARD_TIPS = "破产没有关系，还有救济金可以领取"
L.CRASH.NO_REWARD_TIPS = "今日救济金已经领取完，明日再来领取"

L.CRASH.CHIPS = "{1}游戏币"
L.CRASH.CHIPS_INFO = "(N天天内仅限3次)"
L.CRASH.INVITE = "FB邀请"
L.CRASH.INVITE_INFO = "成功邀请好友"
L.CRASH.RECALL = "FB召回"
L.CRASH.RECALL_INFO = "(成功召回1个老用户回归游戏)"
L.CRASH.GET = "领取"
L.CRASH.PRODUCT = "{1}\n{2}"
L.CRASH.GET_REWARD = "获得{1}游戏币"
L.CRASH.GET_REWARD_FAIL = "领取游戏币失败"
L.CRASH.E2P_TIP = "仅限{1}"

L.CRASH.AD_TITLE = "免费游戏币"
L.CRASH.AD_INFO = "(试玩游戏10分钟即可领取)"
L.CRASH.AD_BTN_TITLE = "去玩"

L.CRASH.MATCH_TITLE = "免费玩比赛场"
L.CRASH.MATCH_INFO = "现在可以去免费玩比赛场"
L.CRASH.MATCH_BTN_TITLE = "去玩"

-- Facebook登录引导
L.FBGUIDE.TITLE              = '推荐您使用Facebook帐号登录!'
L.FBGUIDE.LINE_1             = '1. 每日连续登录比游客帐号多领5万奖励!'
L.FBGUIDE.LINE_2             = '2. 邀请好友更可获得海量游戏币奖励!'
L.FBGUIDE.SWITCH_FB_BTN_TEXT = '切换Facebook登录'

-- 比赛场
L.MATCH.AWARDDLGDESC = "{1},恭喜您在{2}中獲得第{3}名({4}/{5})！加油！{6}\n{7}"
L.MATCH.AWARDDLGDESC1 = "您在{1}中獲得第{2}名({3}/{4})"
L.MATCH.AWARDDLGDESC2 = "{1},恭喜您在{2}中獲得第{3}名({4}/{5})！历史最高排名为{6}.加油！{7}\n{8}"
L.MATCH.AWARDDLGDESC3 = "恭喜您进入前{1}名，您可获得{2}"
L.MATCH.AWARDHUNT = "本场您猎杀了{1}人，获得{2}黄金币"
L.MATCH.AWARDDLGBACK = "返回"
L.MATCH.AWARDDLGSHARE = "分享"
L.MATCH.AWARDDLGONEMORE = "再來一次"
L.MATCH.AWARDDLGWORD = "獲得獎勵："
L.MATCH.RANKWORD = "排名：  "
L.MATCH.RANKINFO = "底注：{1}    "
L.MATCH.STARTINGTIP = "比赛将在15秒后开始，等待其他玩家入场"
L.MATCH.WAITOTHERROOMTIP = "系统正在帮你重新配桌...请稍等..."
L.MATCH.RANKWORD2 = "  第{1}名  "
L.MATCH.LOGINSUCCESS = "登陆成功"
L.MATCH.PUSH = "开赛前通知我"
L.MATCH.SCORETEXT = "{1} 现金币"
L.MATCH.REALINFO = "实物介绍"

L.MATCH.NOTENOUGHGAMECOUPON = "对不起，您的比赛券不足"
L.MATCH.NOTENOUGHGOLDCOUPON = "对不起，您的金券不足"
L.MATCH.NOTENOUGHGOLDCOIN = "对不起，您的黄金币不足"
L.MATCH.NOTENOUGHCHIPS = "对不起，您的筹码不足"
L.MATCH.NOTENOUGHSCORE = "对不起，您的现金币不足"
L.MATCH.REGISTERSUCC = "报名成功"
L.MATCH.REGISTERFAIL = "报名失败"
L.MATCH.UNREGISTERSUCC = "取消报名成功"
L.MATCH.UNREGISTERFAIL = "取消报名失败"
L.MATCH.REGTICKETSFIAL1 = "对不起，您的门票已经过期，请选择其他方式报名"
L.MATCH.REGTICKETSFIAL2 = "对不起，该场次不能用门票报名，请选用其他方式报名"
L.MATCH.REGTICKETSFIAL3 = "对不起，您已经没有了 {1} 门票"

L.MATCH.SCORE = "积分"
L.MATCH.SCOREX = "{1} 积分"
L.MATCH.GOLDCOUPON = "金券"
L.MATCH.GAMECOUPON = "比赛券"
L.MATCH.GOLDCOIN = "黄金币"
L.MATCH.GAMECOUPONE2P = "E2P"
L.MATCH.MONEY = "游戏币"
L.MATCH.CHAMPION = "冠军奖励：{1}"

L.MATCH.SCORE_POOL = "目前总奖池:{{1}} 现金币"
L.MATCH.ScoreExchange_TITLE = "恭喜，您得到第{1}名，\n奖品{2}"
L.MATCH.ScoreExchange_DESC = "别忘了填写接收奖品的住址信息，工作人员会在3天内和您联系，请保持电话畅通"
L.MATCH.SCORE_RANK_DESC = "第{1}名：{2}现金币（{3}%奖池）"

L.MATCH.MATCHTEST = "即日起，您只要邀请一位好友进三公游戏，即可获得三天比赛场畅玩资格！比赛场全天免费玩，比赛场内设置海量现金卡等实物奖品免费送，超大获得概率畅玩比赛，从此话费不用自己掏钱！\r\n\r\n赶紧邀请您的FB好友进游戏，享受比赛乐趣，赢取奖励吧"

L.MATCH.MATCHFREE = "免费"
L.MATCH.MATCHJOINCONDITION = "入场条件："
L.MATCH.MATCHRULE = "比赛规则"
L.MATCH.REGISTER = "报名"
L.MATCH.CANCELREGISTER = "取消报名"
L.MATCH.MATCHNOTOPEN = "暂未开放"
L.MATCH.MATCHNOTOPENTIPS = "测试期间，{1}暂未开放。您可积累比赛券，在正式开放后参加挑战！"
L.MATCH.LOGOUTWARNING = "您正在比赛中，确定是否退出"
L.MATCH.REGISTER1 = "正在报名..."
L.MATCH.CANCELREGISTER1 = "正在取消..."

L.MATCH.MATCHRANK = "名次"
L.MATCH.MATCHAWARD = "比赛奖励"
L.MATCH.MATCHREGNUM = "已经报名人数：{1}"

L.MATCH.JOINMATCHTIPS = "您报名参赛的比赛已经开始准备，是否现在进入房间进行比赛"
L.MATCH.JOINMATCHFAILTIPS = "比赛已经开始，您来晚了，下次请记得早点来哦"

L.MATCH.NOTICE = "尊敬的三公用户，恭喜您获得了比赛场的测试体验资格。欢迎向我们反馈问题和提出建议，一旦问题或建议被采纳，您可获得50000游戏币奖励"

L.MATCH.FEEDBACK = "问题反馈"
L.MATCH.FEEDBACK_TYPE = "问题类型"
L.MATCH.FEEDBACK_DESC = "问题描述"

L.MATCH.MATCHSERVERCLOSETIPS = "您已经与比赛断开连接，请重新进入比赛"

L.MATCH.FEEDBACK_TYPE_LIST = {
    "报名失败",
    "登陆进场问题",
    "开赛问题",
    "比赛中问题",
    "奖励问题",
    "兑换问题",
    "其他类型",
    "建议"
}
L.MATCH.FEED_BACK_HINT = "您在游戏中碰到的问题或者对游戏有任何意见或者建议，我们都欢迎您给我们反馈"

L.MATCH.LOGIN_ROOM_FAIL = "比赛已经开始，请重新报名"

L.MATCH.JOINGAME_COUNT = "入场倒计时:{1}"

L.MATCH.CHANGING_ROOM_MSG = "正在等待其他桌子结束"

L.MATCH.REGISTER_RET1 = "重复报名比赛"
L.MATCH.REGISTER_RET2 = "用户不存在"
L.MATCH.REGISTER_RET3 = "比赛状态错误"
L.MATCH.REGISTER_RET4 = "报名人数已满"
L.MATCH.REGISTER_RET5 = "比赛劵不足"

L.MATCH.RULES_TILE = "常见问题"
L.MATCH.RULES_LIST = {
    {
        "1.门票和比赛券的区别",
        "都可以用来报名比赛场，不同的门票只能报对应场次的比赛，而且有有效期，过期后不能再使用，比赛券通用，无有效期限制。"
    },
    {
        "2.比赛券的获取和使用",
        "在比赛场的免费赛和中级赛玩牌，进入奖励圈即可获得相应的比赛券，也可以在商城购买获得。比赛券可以用来报名中级赛和高级赛。"
    },
    {
        "3.金券的获取和使用",
        "在比赛场的免费赛，中级赛，高级赛玩牌，进入前三名即可获得相应的金券，不可以在商城购买。金券可用来报名高级赛。"
    },
    {
        "4.积分的获取和使用",
        "在比赛场的免费赛，中级赛和高级赛玩牌，进入前三名即可获得一定的积分，积分可用来兑换礼物。"
    }
}
L.MATCH.CANCELTIP1 = "当前参赛人数过少，比赛已取消，您的参赛报名费已经返还，请注意查收"
L.MATCH.CANCELTIP2 = "您报名参加的{1}{2}已经取消，您的报名费已返还账户，请注意查收"
L.MATCH.CANCELREASON1 = "因您的网络太慢"
L.MATCH.CANCELREASON2 = "因报名参赛人数过少"

L.MATCH.TIMESTART = "{1} 开赛"
L.MATCH.LEFTTIMESTART = "距离开赛:{1}"
L.MATCH.REGED = "已报名"
L.MATCH.EVALMONEY = " (约等价于{1}泰铢)"
L.MATCH.CONDITION1 = "开赛条件："
L.MATCH.CONDITION2 = "开赛时间："
L.MATCH.CONDITION3 = "奖励方案"
L.MATCH.CONDITION4 = "比赛规则"
L.MATCH.CONDITION5 = "参赛记录"
L.MATCH.ONLY_SHOW = "只显示最近100个用户"
L.MATCH.GOT_REWARD_MATCH = "已获奖用户"
L.MATCH.MY_MATCH_REWARD = "我的记录"
L.MATCH.BESTRECORD = "最佳战绩：第{1}名，{2}"
L.MATCH.MATCHTIME = "时间"
L.MATCH.MATCHRANK = "名次"
L.MATCH.MATCHREWARD = "奖励"
L.MATCH.MATCHACT = "操作"
L.MATCH.MATCHDETAIL = "查看详情"
L.MATCH.REWARD_TIPS = "恭喜您获得了{1} "
L.MATCH.REWARD_E2P_TIPS = "请填写您的手机号码，奖励稍后将发送到您的手机上!"
L.MATCH.REWARD_E2P_ERROR = "提交前请注意核对手机号码，确保无误!"
L.MATCH.REWARD_CUP_TIPS = "冠军奖杯"
L.MATCH.NO_RECORD = "暂无比赛记录"

L.MATCH.AVERAGE_TIME = "目前平均开赛时间{1}秒"
L.MATCH.LEFT_TIME = "大约还有{1}秒开赛"
L.MATCH.ALERTTIPS1 = "报名条件：{1}"
L.MATCH.ALERTTIPS2 = "获取途径：{1}"
L.MATCH.MATCHTIPSCANCEL = "不再提示"
L.MATCH.INVITE_BUBBLETIP = "邀请一位好友进游戏，你即可畅玩比赛场"
L.MATCH.RESULT_VITEFRIEND_TIPS1 = "恭喜您已获得本场比赛冠军，在此处邀请好友可获得额外的冠军奖励！"
L.MATCH.RESULT_VITEFRIEND_TIPS2 = "恭喜您获得第二名，在此处邀请，您即可获得与冠军相同的奖励！"
L.MATCH.SCORE_VITEFRIEND_TIPS = "在此处邀请好友进游戏，即可获得现金币返利，最高可获得商品的{1}%返利"
L.MATCH.LEFTPLAYTIMES = "今日还有{1}次免费玩机会"
L.MATCH.LEFTPLAYTIMES_1 = "剩余：{1}次,   {2}后可获得 1 次"
L.MATCH.NOTIMESTIPS = "每天有{1}次免费玩{2}的机会，您今日的次数已用完。消耗{3}游戏币可兑换{4}次机会，确认是否兑换？"
L.MATCH.NOTIMESTIPS_1 = "每天有{1}次免费玩{2}的机会，您今日的次数已用完。{3}后可免费获得一次机会"
L.MATCH.NOTIMESTIPS_2 = "不，我要花费{1}游戏币立即兑换{2}次机会"
L.MATCH.NOTIMESBUY = "对不起，您的筹码不足，请先去补充筹码。现在就去商城？"
L.MATCH.NOTIMESEXFIAL = "兑换失败，请重新尝试"
L.MATCH.ROOMDEFEND = "当前场次正在维护，请稍后报名"
L.MATCH.ROOMDEFEND1 = "对不起，暂时没有该场比赛的信息，请继续关注！"

L.MATCH.REBUYTITLE = "重新购买"
L.MATCH.REBUYTIPS = "tips: 买入的筹码只是用于当前比赛的筹码，并不是真实筹码"
L.MATCH.REBUYAVERAGE = "当前比赛中人均筹码{1}，请选择筹码重新买入"
L.MATCH.REBUYTIME = "您还有   {1}   秒的考虑时间"
-- 积分兑换奖励
L.SCOREMARKET.TAB1 = "兑换奖品"
L.SCOREMARKET.TAB2 = "兑换记录"
L.SCOREMARKET.SUBTAB1 = "游戏礼包"
L.SCOREMARKET.SUBTAB2 = "现金卡"
L.SCOREMARKET.SUBTAB3 = "Line Coins"
L.SCOREMARKET.SUBTAB4 = "实物"
L.SCOREMARKET.SUBTAB5 = "幸运大转盘"
L.SCOREMARKET.SUBTAB6 = "实物"
L.SCOREMARKET.SUBTAB7 = "特别赞助"
L.SCOREMARKET.COPY = "复制"
L.SCOREMARKET.COPY_SUCCESS = "复制成功！"
L.SCOREMARKET.SEE = "查看"

L.SCOREMARKET.MYSCORE = "我的积分："
L.SCOREMARKET.COMMINGTIPS = "尊敬的用户，商品正在准备中，敬请期待"
L.SCOREMARKET.NORECORD = "暂无兑奖记录..."
L.SCOREMARKET.LEFTWORD = "剩余数量：{1}"
L.SCOREMARKET.NOLEFT = "已经抢光"
L.SCOREMARKET.GOODSFULL = "奖品充足"
L.SCOREMARKET.RECHANGENUM = "{1} 积分"
L.SCOREMARKET.NOTENOUGHTIPS = "对不起，您的积分不足"
L.SCOREMARKET.RECHANGECONFIRM = "您确认要使用{1}积分兑换{2}"
L.SCOREMARKET.JOIN_LUCKTURN = "我要參加"
L.SCOREMARKET.RECEIVE_ADDRESS = "收货地址"
L.SCOREMARKET.RECEIVE_INFOS = "收货信息"
L.SCOREMARKET.SAVE_ADDRESS = "保存"
L.SCOREMARKET.USER_NAME = "你的姓名"
L.SCOREMARKET.USER_SEX = "您的性别"
L.SCOREMARKET.MOBEL_TEL = "手机号码"
L.SCOREMARKET.DETAIL_ADDRESS = "详细地址"
L.SCOREMARKET.EMAIL = "电子邮箱"
L.SCOREMARKET.FEMALE = "女士"
L.SCOREMARKET.MAN = "男士"
L.SCOREMARKET.SAVEADDRESS_FAIL = "保存收货地址失败"
L.SCOREMARKET.SAVEADDRESS_SUCCESS = "保存收货地址成功"

L.SCOREMARKET.CONSUME_SCORE = "您将花费 {1} 积分兑换"
L.SCOREMARKET.CONFIRM_ADDRESS_TIP = "请确认收货信息，确保无误！"
L.SCOREMARKET.CONFIRM_EXCHANGE = "确认兑换"
L.SCOREMARKET.EXCHANGE = "兑换"
L.SCOREMARKET.MODIFY_INFO = "修改信息>>"
L.SCOREMARKET.EXCHANGE_CONDITION = "兑换条件"
L.SCOREMARKET.EXCHANGE_CONDITION_DESC = "消耗 {1} 现金币可获得"
L.SCOREMARKET.EXCHANGE_LEFT_CNT = "剩余数量:{1}"
L.SCOREMARKET.NOTENOUGH_SCORE = "您的现金币不足，快去参加比赛赢取现金币吧"
L.SCOREMARKET.NOTENOUGH_GOODS = "已被抢完，我们会尽快添加库存！"
L.SCOREMARKET.NOTENOUGH_LEFT_CNT = "已被抢光"
L.SCOREMARKET.EXCHANGE_SUCCESS_DESC = "恭喜您 {1} 兑换成功，我们的客服将于3个工作日内与您联系，请你保持手机畅通"
L.SCOREMARKET.EXCHANGE_SUCCESS_TIP = "兑换成功！"
L.SCOREMARKET.EXCHANGE_CONFIRM = "确认"
L.SCOREMARKET.ALERT_WRITEADDRESS = "请填写 {1}"
L.SCOREMARKET.CITY = {
    "กรุงเทพฯ",
    "บุรีรัมย์",
    "ชัยภูมิ",
    "จันทบุรี",
    "เชียงใหม่",
    "เชียงราย",
    "ชลบุรี",
    "ชุมพร",
    "หาดใหญ่",
    "หัวหิน",
    "กำแพงเพชร", 
    "ลำปาง", 
    "เลย",
    "ลพบุรี",
    "นครนายก",
    "นครปฐม",
    "นครราชสีมา",
    "นครสวรรค์",
    "หนองคาย",
    "พัทยา",
    "ประจวบคีรีขันธ์",
    "ระยอง",
    "พิษณุโลก", 
    "ภูเก็ต",
    "สุโขทัย",
    "ระนอง",
    "สามพราน",
    "สระบุรี",
    "สงขลา",
    "สุพรรณบุรี",
    "ตาก",
    "อุดรธานี",
    "ตรัง"
}

L.SCOREMARKET.CONFIRM_RECEIVER_REWARD = "我已确认收到奖品"
L.SCOREMARKET.UPDATE_ORDER_STATUS_FAIL = "更新兑换订单状态失败:{1}"
L.SCOREMARKET.EXCHANGE_NUM_TXT = "{1}人兑换"
L.SCOREMARKET.RECEIVER_TIME = "获取时间: {1}"
L.SCOREMARKET.GETWAY_TXT = "获取途径: {1}"
L.SCOREMARKET.BTN_GOOD_TXT = "给好评"
L.SCOREMARKET.CARD_LBL = "卡信息"
L.SCOREMARKET.PIN_CODE_LBL = "PIN码：{1}"
L.SCOREMARKET.CARD_NUM_LBL = "卡 号：{1}"
L.SCOREMARKET.VALIDITY_LBL = "有效期：{1}"
L.SCOREMARKET.TIPS_DSC_MSG = "您已获得{1}。温馨提示：充值时请复制上面PIN码，请注意在有效期前使用哦"
L.SCOREMARKET.GOODS_STATUST_TITLE = "奖品状态"
L.SCOREMARKET.GOODS_STATUST_TEL = "待电话确认"
L.SCOREMARKET.GOODS_STATUST_TELED = "已电话确认"
L.SCOREMARKET.GOODS_STATUST_DELIVER = "待发货"
L.SCOREMARKET.GOODS_STATUST_DELIVERED = "已发货"
L.SCOREMARKET.GOODS_STATUST_RECEIVE = "待收货"
L.SCOREMARKET.GOODS_STATUST_RECEIVED = "已收货"
L.SCOREMARKET.GOODS_STATUST_SUCC = "完成"
L.SCOREMARKET.GM_TEL_TXT = "客服电话:{1}"
L.SCOREMARKET.BTN_RECEIVER_TXT = "我已收到奖品"
L.SCOREMARKET.BTN_UP_PIC_TXT = "上传照片"
L.SCOREMARKET.BTN_GOOD_TIPS_TXT = "您的支持是我们的动力"
L.SCOREMARKET.BTN_UP_PIC_TIPS_TXT = "上传照片，让更多牌友认识你"
L.SCOREMARKET.EXCHANGE_INFO_LBL = "已经有{1}人兑换"
L.SCOREMARKET.SEE_BTN_LBL = "查看"
L.SCOREMARKET.CHECKBOX_TEXT = "查看全部记录"
L.SCOREMARKET.FOCUS_SUCC = "关注成功！"
L.SCOREMARKET.FOCUS_TXT = "关注"
L.SCOREMARKET.MATCH_REAL_ALERT_TIPS = "恭喜您得到了{1}，请在三个工作日内和客服取得联系确认收货地址，联系电话........"
L.SCOREMARKET.MARKET_REAL_ALERT_TIPS = "你好，次商品为贵重物品，要带有效证件来公司领取，否则视为弃权，您确定要兑换吗"

L.SCOREMARKET.STATUST_TIPS = {
    "您已获得{1}奖品，为保证奖品顺利到您手上，客服MM会在3个工作日内与您电话联系，确认信息，请您保持手机畅通",
    "已与您确认好信息，奖品正准备打包邮寄",
    "您的奖品已寄出，现在在路上，请保持手机畅通，等待收货哦",
    "恭喜您收到奖品！三公游戏，感谢您的支持！",
    "恭喜您兑换了{1}，请在三个工作日内和客服确定领取日期，并带有效证件来公司领取，谢谢",
}
L.SCOREMARKET.STATUST_TXT = {
    ["1"]=L.SCOREMARKET.GOODS_STATUST_TEL,
    ["2"]=L.SCOREMARKET.GOODS_STATUST_RECEIVE,
    ["3"]=L.SCOREMARKET.GOODS_STATUST_RECEIVED,
    ["4"]=L.SCOREMARKET.GOODS_STATUST_DELIVER,
    ["5"]=L.SCOREMARKET.GOODS_STATUST_SUCC,

    ["11"]=L.SCOREMARKET.GOODS_STATUST_TELED,
    ["12"]=L.SCOREMARKET.GOODS_STATUST_DELIVERED,
}
L.SCOREMARKET.STATUST_RESLIST = {
    ["1"]="sm_status_1.png",
    ["2"]="sm_status_3.png",
    ["3"]="sm_status_5.png",
    ["4"]="sm_status_2.png",
    ["5"]="sm_status_4.png",

    ["11"]="sm_status_1.png",
    ["12"]="sm_status_3.png",
}
L.SCOREMARKET.UPLOAD_PIC_NO_SDCARD = "没有安装SD卡，无法使用头像上传功能"
L.SCOREMARKET.UPLOAD_PIC_PICK_IMG_FAIL = "获取图像失败"
L.SCOREMARKET.UPLOAD_PIC_UPLOAD_FAIL = "上传头像失败，请稍后重试"
L.SCOREMARKET.UPLOAD_PIC_IS_UPLOADING = "正在上传头像，请稍候..."
L.SCOREMARKET.UPLOAD_PIC_UPLOAD_SUCCESS = "上传头像成功"

L.SCOREMARKET.GET_GOODS_WAY_LIST = {"比赛场", "商城兑换"}
L.SCOREMARKET.NIL_EXCHANGE_TIP = "暂时无人兑换"
L.SCOREMARKET.BIG_EXCHANGE_SUCC_MSG = "{1}人兑换"

L.SCOREMARKET.LINE_COIN_BTN_LBL = "使用方法"
L.SCOREMARKET.LINE_COIN_DESC = "PIN CODE Line Free Coins ใช้อย่างไร?"
L.SCOREMARKET.LINE_COIN_TITLE = "วิธีใช้ PIN CODE Line Free Coins"
L.SCOREMARKET.LINE_COIN_DESC_LIST = {    
    "1.ล็อกอินบัญชี Line ของท่านที่เว็บไซต์ ",
    "2.กด [เติมเงิน] เพื่อเข้าสู่หน้าเติมเงิน",
    "3.กดเลือก [LINE GIFT CODE] แล้วเลือก [ต่อไป]",
    "4.กรอก PIN CODE ของท่าน แล้วกด [เติมเงิน]",
    "5.เติมเงินสำเร็จ"
}

L.SCOREMARKET.TRUE_FLOW_SEE_DESC = "点击查看使用说明"
L.SCOREMARKET.TRUE_DESC_TITLE = "{1}M TRUE流量包 使用说明："
L.SCOREMARKET.TRUE_DESC_LIST = {"1.获得PIN码后，拨打*799*5*10位数PIN码*{1}#", "2.有效期为拨打电话激活后 {1} 天内有效"}
L.SCOREMARKET.TRUE_DESC_TIPS = "คุณได้รับแพ็คเกจเสริมเน็ตทรู {1} กรุณาเติมเน็ตโดยกด *799*5* ตามด้วยรหัส PIN 10 หลัก กด *{2}# แล้วโทรออก หลังเปิดใช้งานแล้ว กรุณาใช้ให้หมดภายใน {3} วันค่ะ"

-- 流失玩家回归任务
-- 未完成 补做
L.PLAYER_BACK.TITLE           = '连续5天登录奖励'
L.PLAYER_BACK.N_DAY           = '第{1}天'
L.PLAYER_BACK.GOTO            = '去完成'
L.PLAYER_BACK.GET_REWARD      = '领奖'
L.PLAYER_BACK.GOT_REWARD      = '已领奖'
L.PLAYER_BACK.GOT_REWARD_NEXT = '您已经领取了今天的任务奖励,明天再来吧!'
L.PLAYER_BACK.GOT_A_REWARD    = '您已经领取了奖励,祝您游戏愉快!'
L.PLAYER_BACK.COME_LATER_N    = '请{1}天后再来做任务领取奖励吧!'
L.PLAYER_BACK.CANNOT_DO       = '很遗憾，任务已过期!'
L.PLAYER_BACK.GET_REWARD_SUCC = "领取奖励成功"

L.PLAYER_BACK.TASK_NAME_1     = '牌局首胜'
L.PLAYER_BACK.TASK_NAME_2     = '两小无猜'
L.PLAYER_BACK.TASK_NAME_3     = '好友互动'
L.PLAYER_BACK.TASK_NAME_4     = '同台竞技'
L.PLAYER_BACK.TASK_NAME_5     = '人品爆棚'
L.PLAYER_BACK.TASK_NAME_6     = '大满贯'

L.PLAYER_BACK.TASK_DESC_1     = '当日在普通场/专业场赢牌1局'
L.PLAYER_BACK.TASK_DESC_2     = '添加一个异性玩家为好友'
L.PLAYER_BACK.TASK_DESC_3     = '在房间内向好友使用一次互动道具'
L.PLAYER_BACK.TASK_DESC_4     = '和好友在同一房间内玩牌10局'
L.PLAYER_BACK.TASK_DESC_5     = '当日在普通场/专业场赢牌10局'
L.PLAYER_BACK.TASK_DESC_6     = '连续完成前5天的回流任务'



L.FIRST_PAY.BTN_TEXT = "立即抢购"
L.FIRST_PAY.TITLE_SUPPLY = "游戏币不足，需要补充游戏币"
L.FIRST_PAY.PRICE_TIPS = "点击抢购将从话费中扣除 {1}THB（不含7%增值税）,每人仅限一次"
L.E2P_TIPS.SMS_SUCC = "短信已发送成功,正在充值 请稍等."
L.E2P_TIPS.NOT_SUPPORT = "你的手机暂时无法完成easy2pay充值,请选择其他渠道充值"
L.E2P_TIPS.NOT_OPERATORCODE = "easy2pay暂时不支持你的手机运营商,请选择其他渠道充值"
L.E2P_TIPS.SMS_SENT_FAIL = "短信发送失败,请检查你的手机余额是否足额扣取"
L.E2P_TIPS.SMS_TEXT_EMPTY = "短信内容为空,请选择其他渠道充值并联系官方"
L.E2P_TIPS.SMS_ADDRESS_EMPTY = "没有发送目标,请选择其他渠道充值并联系官方"
L.E2P_TIPS.SMS_NOSIM = "没有SIM卡,无法使用easy2pay渠道充值,请选择其他渠道充值"
L.E2P_TIPS.SMS_NO_PRICEPOINT = "没有发送目标,请选择其他渠道充值并联系官方"
L.E2P_TIPS.PURCHASE_TIPS = "您将要购买{1}，共花费{2}铢（不含7%增值税），将会从您的话费里扣除"
L.E2P_TIPS.BANK_PURCHASE_TIPS = "您将要购买{1}，共花费{2}铢（不含7%增值税），将会从您的银行卡里扣除"

L.GUIDE_PAY.TITLE_SUPPLY = "您的游戏币不足最小买入{1}"
L.GUIDE_PAY.TITLE__MATCH_SUPPLY = "报名需要{1}游戏币"
L.GUIDE_PAY.MORE_PAY_METHOD = "更多支付方式"
L.GUIDE_PAY.ENTER_ROOM_WATCH = "进入房间旁观>>"
L.GUIDE_PAY.TIPS_PAY_METHOD = "提示：以上订单只支持{1}支付方式"
L.GUIDE_PAY.TITLE_DISCOUNT_COUNTDOWN = "限时特价游戏币，赶快抢购"
L.GUIDE_PAY.PRICE_ORIGAL_TIPS = "(原价:{1})"
L.GUIDE_PAY.TITLE_GCOINS_SUPPLY = "您的黄金币不足最小买入{1}"
L.GUIDE_PAY.TITLE_GCOINS_MATCH_SUPPLY = "报名需要{1}黄金币"

L.HALLOWEEN.TIPS1 = "现在前往{1}以上盲注场玩牌{2}局，获得即可获得比赛场门票及现金币等丰厚大奖！"
L.HALLOWEEN.TIPS2 = "在当前盲注场连续玩牌{1}局即可获得比赛门票及游戏币、现金币奖励哦！"
L.HALLOWEEN.TIPS3 = "你已完成本盲注房间连续玩牌{1}局的活动条件，现在前往活动中心即可领取奖励！"
L.HALLOWEEN.GOPLAY = "立即去玩"
L.HALLOWEEN.GOMATCH = "立即去比赛场"
L.HALLOWEEN.NOT_ENOUGH_PROP = "您还没有这个节日限定道具,快接着玩牌获得吧！"
L.HALLOWEEN.NAUGHTY_UTTERS = {
    "万圣节快乐",
    "不给玫瑰,就捣蛋,嘻嘻",
    "一起来砸南瓜灯吧"
}

--疯狂宝箱
L.CRAZED.TITLE = "疯狂的宝箱"
L.CRAZED.QUESTION = "怎么开启宝箱?" 
L.CRAZED.TIME = "倒计时:"
L.CRAZED.TOMORROW = "明天再来"
L.CRAZED.COST_50K = "使用5W游戏币"
L.CRAZED.COST_500K = "使用50W游戏币"
L.CRAZED.ANSWER = {
    "1.铜宝箱需要在线15分钟可开启1次(每日限1次)",--
    "2.银宝箱需要消耗5W游戏币可开启1次(每日不限次数)",
    "3.金宝箱需要消耗50W游戏币可开启1次(每日不限次数)"
}
L.CRAZED.NOT_OPEN_BOX_TIPS = {
    "你的在线时长还不足15分钟，请稍后重试！",
    "你的游戏币不足5W，无法开启银宝箱！",
    "你的游戏币不足50W，无法开启金宝箱！",
}
L.CRAZED.GET_COPPER_REWARD = "恭喜你打开铜宝箱，获得 {1}!"
L.CRAZED.GET_SILVER_REWARD = "恭喜你打开银宝箱，获得 {1}!"
L.CRAZED.GET_GLOD_REWARD = "恭喜你打开金宝箱，获得 {1}!"

L.CRAZED.COPPER_TIPS = "铜宝箱奖励内容:\n{1}"
L.CRAZED.SILVER_TIPS = "银宝箱奖励内容:\n{1}"
L.CRAZED.GLOD_TIPS = "金宝箱奖励内容:\n{1}"

L.VIP.ROOM_SEND_EXPRESSIONS_FAILED = "您的场外筹码不足5000，暂时无法使用VIP表情"
L.VIP.ROOM_SEND_EXPRESSIONS_TIPS = "你当前还不是VIP用户，需要消耗{1}筹码？"
L.VIP.PDENG_SEND_EXP_TIPS = "您还不是VIP，是否立即成为VIP？"
L.VIP.OPEN_VIP = "开通VIP免费使用"

L.VIP.REWARD_TITLE_LIST = {
    "立即开通",
    "踢人卡",
    "VIP表情",
    "破产优惠",
    "经验",
    "登录返还",
    "筹码",
}

L.VIP.NOT_VIP = "未开通"
L.VIP.AVAILABLE_DAYS = "剩余{1}天"
L.VIP.PAY_AGAIN = "续费"
L.VIP.BROKE_REWARD = "多送{1}% 每天{2}次"
L.VIP.ALREADY_IS_TIPS = "您已经是{1}，重复购买将只享受新购买的VIP，不可叠加享受优惠。"
L.VIP.LOGINREWARD = "{1}*31天"

L.VIP.KICK_CARD = "踢人卡"
L.VIP.KICK_SUCC = "踢人成功，玩家将在本局结束后被提出牌桌。"
L.VIP.KICK_FAILED = "踢人失败,请稍后重试"
L.VIP.KICKED_TIP = "抱歉，您被玩家{1}踢出牌局，将在本局结束后离开此牌桌。"
L.VIP.KICKER_TOO_MUCH = "您当天的使用次数已达到上限，请遵守牌桌秩序，严禁恶意踢人。"
L.VIP.KICKED_ENTER_AGAIN = "您已被踢出此房间，20分钟内无法进入，你可以选择其他房间或者重新快速开始"
L.VIP.COUPON = "VIP优惠卡"

L.PUSHREWARD.TITLE = "感恩有你，门票免费派送！"
L.PUSHREWARD.GET_REWARD = "你获得了 {1}"
L.PUSHREWARD.EXPIRE_TIME = "过期时间:{1}"
L.PUSHREWARD.BTN_CHECK_TICKET = "查看门票"
L.PUSHREWARD.BTN_GO_MATCH = "立即报名"

L.LOTTERY.TITLE = "福彩中心"
L.LOTTERY.RULE = "中奖规则（游戏币/现金币同）：\n一等奖： 购彩数值与中奖数值完全一样     竞猜奖金：{1}\n二等奖：5组中奖数值中有一组数值和所购买彩票数值一样  竞猜奖金：{2}\n三等奖：10组中奖数值中有一组数值和所购买彩票数值一样  竞猜奖金：{3}\n四等奖：50组中奖数值中有一组数值和所购买彩票数值一样  竞猜奖金：{4}\n五等奖：100组中奖数值中有一组数值和所购买彩票数值一样  竞猜奖金：{5}\n特别奖：与一等奖前五位相同且尾数相邻   竞猜奖金：{6}\n六等奖：转动两次，其中一次数值和所购买彩票数值数值前3位一模一样， 竞猜奖金：{7}\n七等奖：转动两次，其中一次数值和所购买彩票数值数值后3位一模一样， 竞猜奖金：{8}\n八等奖：转动1次，所购买彩票数值后2位和滚箱数值一模一样，   竞猜奖金：{9}"
L.LOTTERY.TIMETIPS = "本期开奖时间"
L.LOTTERY.RESULT_CHECK = "上期中奖结果查询"
L.LOTTERY.TAB_BUY = "购票"
L.LOTTERY.TAB_RULE = "规则"
L.LOTTERY.TAB_RECORD = "记录"
L.LOTTERY.BUY_TIPS1 = "选择一张彩票"
L.LOTTERY.BUY_TIPS2 = "限购一张"
L.LOTTERY.CASH_BUY = "{1}现金币"
L.LOTTERY.COIN_BUY = "{1}游戏币"
L.LOTTERY.CASH_BUY_TIPS = "只可在现金币奖池领奖"
L.LOTTERY.COIN_BUY_TIPS = "只可在游戏币奖池领奖"
L.LOTTERY.TICKET_BUY_NUMBERS = "已购买{1}张"
L.LOTTERY.PRE_COIN_TOTAL = "本期预发售游戏币彩票：{1}张"
L.LOTTERY.COIN_TOTAL = "游戏币总奖池：{1}"
L.LOTTERY.PRE_CASH_TOTAL = "本期预发售现金币彩票：{1}张"
L.LOTTERY.CASH_TOTAL = "现金币总奖池：{1}"
L.LOTTERY.RECORD_TITLE1 = "竞猜时间"
L.LOTTERY.RECORD_TITLE2 = "竞猜数字"
L.LOTTERY.RECORD_TITLE3 = "购买彩金"
L.LOTTERY.RECORD_TITLE4 = "竞猜结果"
L.LOTTERY.RESULT_WIN_LEVEL = "{1}等奖"
L.LOTTERY.RESULT_WIN_NONE = "未中奖"
L.LOTTERY.RESULT_WIN_GOT = "已领取"
L.LOTTERY.RESULT_NOT_OPEN = "未开奖"
L.LOTTERY.NUMBER_SOLD = "很抱歉，当前号码已卖出，请重新选择"
L.LOTTERY.NUMBER_TYPE1_SOLD_OUT = "游戏币彩票已卖完，请用现金币购买"
L.LOTTERY.NUMBER_TYPE2_SOLD_OUT = "现金币彩票已卖完，请用游戏币购买"
L.LOTTERY.NUMBER_SOLD_OUT = "当期彩票已卖完，请下期购买"
L.LOTTERY.REWARD_TIPS = "恭喜您获得了{1} "
L.LOTTERY.COINS_OUT_TIPS = "你的游戏币不足{1}，请充值！"
L.LOTTERY.CASH_OUT_TIPS = "你的现金币不足{1}个，请去比赛场赢取现金币！"
L.LOTTERY.BUY_SUCC_TIPS = "购买成功！"
L.LOTTERY.BUY_STOP_TIPS = "当期彩票已截止购买！"
L.LOTTERY.BUY_CONFIRM_TIPS = "你确定要使用{1}购买1张彩票吗？"


L.PUSHMSG.PUSH_POPUP_TITLE = "推送邀请离线好友"
L.PUSHMSG.SEND_CHIP_MSG = "你已成功赠送{1}游戏币给{2} ,是否要使用推送消息告知他上线领取?"
L.PUSHMSG.MSG_TO = "通知他"
L.PUSHMSG.POPUP_TITLE = "推送消息"
L.PUSHMSG.PUSH_ROOM_BTN = "邀请好友"
L.PUSHMSG.ROOM_PUSH = "{1} 快来一起玩牌吧！——来自{2}"
L.PUSHMSG.SENDCHIP_PUSH = "{1} 赠送了10K游戏币给你，快来领取吧！"
L.PUSHMSG.MATCH_WIN = "我玩三公比赛拿到第一名啦，拿到得{1}。一起来玩啊，送奖品呢！"
L.PUSHMSG.PUSH_MATCH = "告诉好友"

L.PLAYERBACK.TITLE = "老用户回归福利"
L.PLAYERBACK.TASK_TIPS = {
    "老用户回归奖",
    "普通场玩牌1局",
    "比赛场玩牌1局",
    "召回老朋友"
}

L.PLAYERBACK.OLD_CONTENT = "亲爱的老用户，新的一年感谢有你的陪伴！我们已为你准备了50000游戏币！你可以立即领取！"
L.PLAYERBACK.NORMAL_PLAY = "前往普通场任意盲注玩牌1局即可领取比赛场10THB定人赛门票1张！"
L.PLAYERBACK.MATCH_PLAY = "使用门票前往比赛场报名并参赛，可立即领取5现金币(等同5泰铢)！"
L.PLAYERBACK.RECALL = "你的召回码为:{1}\n把你的奖励码告知给你的流失好友，他们登录游戏在此页面输入你的召回码，你们都可以获得5现金币。"
L.PLAYERBACK.GET_REWARD = "立即领取"
L.PLAYERBACK.GOT_REWARD = "已领取"
L.PLAYERBACK.PLAY_NOW = "立即玩牌"
L.PLAYERBACK.GET_TICKET = "领取门票"
L.PLAYERBACK.CHECK_TICKET = "查看门票"
L.PLAYERBACK.INMATCH_NOW = "立即参赛"
L.PLAYERBACK.COIN_SUGGEST = "了解现金币"
L.PLAYERBACK.CHECK_FIRENDS = "查看符合资格的好友"
L.PLAYERBACK.INPUT_HINT_MSG = "输入好友的召回码"
L.PLAYERBACK.GET_COIN = "领取5现金币"
L.PLAYERBACK.RECALL_CODE = "你的召回码为:{1}"
L.PLAYERBACK.RECALL_CODE_DESC = "把你的召回码告知给你的流失好友，他们在登录游戏在此页面输入你的召回码，你们都可以获得5现金币。"
L.PLAYERBACK.FRIENDLIST_TITLE = "符合资格的好友"
L.PLAYERBACK.GET_REWARD_SUCC = "领取奖励成功"
L.PLAYERBACK.GET_REWARD_FAIL = "领取奖励失败"
L.PLAYERBACK.NOT_INPUT_FUID_ERROR = "请先输入好友的召回码"

L.PLAYERBACK.GOT_REWARD_ERROR = "已领取过奖励了"
L.PLAYERBACK.TASK_NOT_START = "先完成上一个任务吧"

L.BILLDETAIL.NO_RECORDLOG = "无相关明细"
L.BILLDETAIL.TITLE_TIME = "时间"
L.BILLDETAIL.TITLE_WAY = "途径"
L.BILLDETAIL.TITLE_CHANGE = "变化"
L.BILLDETAIL.TITLE_LEFT = "剩余"
L.BILLDETAIL.TITLE_STR = "最近7天账单查询"
L.BILLDETAIL.TAB_TYPES = {
    "现金币",
    "黄金币",
    "比赛券"
}

L.MixCurrent.MIX_TITLE = "合成炉"
L.MixCurrent.MIX_DESC = "每天最多可完成{1}次合成，您当前还有{2}次"
L.MixCurrent.MIX_BTNLBL = "合成"
L.MixCurrent.MIX_T1 = "所需物品"
L.MixCurrent.MIX_T2 = "已有数量"
L.MixCurrent.MIX_T3 = "所需数量"
L.MixCurrent.MIX_T4 = "หลอมเป็น {1}"
L.MixCurrent.MIX_NOT_ENOUGH_CON = "您条件不足，无法合成"
L.MixCurrent.MIX_NOT_ENOUGH_NUM = "您今天的合成次数已用完"
L.MixCurrent.MIX_DESC_MSG = "您将消耗 {1} 合成{2}，确定合成？"

L.TICKET.label = "比赛场门票"
L.TICKET.ALERT_INROOM_MSG = "房间内不能使用门票！"
L.TICKET.APPLY_LABLE = " 立即报名"
L.TICKET.OVERDUE_LABLE = "已过期"
L.TICKET.FORMAT_DATE = "{3}年{1}月{2}日前有效"
L.TICKET.REGED_SUCC_ALERT = "使用 {1} 报名 {2} 成功!"
L.TICKET.REGED_FAIL_ALERT = "您已经报名过 {1} "
L.TICKET.ERROR_OVERDATE = "门票过期！"
L.TICKET.TICKET_NEXTOVERDATE = "您有门票即将到期"
L.TICKET.MONTHS = {
    "一月",
    "二月",
    "三月",
    "四月",
    "五月",
    "六月",
    "七月",
    "八月",
    "九月",
    "十月",
    "十一月",
    "十二月",
};

L.TICKET.TITLE_DESC1 = "门票提示"
L.TICKET.TITLE_DESC = "比赛场门票到期提醒"
L.TICKET.TIP_LBL1 = "温馨提醒，您有以下门票即将到期，请尽快使用！"
L.TICKET.TIP_TITLE1 = "门票"
L.TICKET.TIP_TITLE2 = "到期时间"
L.TICKET.TIP_TITLE3 = "剩余量"
L.TICKET.BUTTON_TEXT = "立即使用"

L.HALL.GOLD_DESC = "金券: ใช้ลงชื่อห้องแข่งรายสัปดาห์และรายเดือน ฯลฯ รับฟรีหากชนะติดอันดับในห้องแข่ง ไม่จำกัดอายุการใช้"
L.HALL.COUPON_DESC = "比赛券: ใช้ลงชื่อเพื่อเข้าห้องแข่ง ซื้อได้ที่ห้างหรือรับฟรีโดยเล่นที่ห้องธรรมดา ไม่จำกัดอายุการใช้ "
L.HALL.SCORE_DESC = "现金币: ใช้แลกรางวัลต่างๆที่ห้าง รับฟรีโดยเล่นที่ห้องธรรมดา/ชนะติดอันดับในห้องแข่ง ไม่จำกัดอายุการใช้"
L.HALL.CHIP_DESC = "筹码: บัตรทองสามารถนำมาลงชื่อเข้าห้องชิงรางวัลจริงรายสัปดาห์และรายเดือนที่จะเปิดในเร็วๆนี้ได้"
L.HALL.GOLDCOIN_DESC = "提示：比赛券更换为黄金币，可以用于报名参加比赛"

L.MATCHDETAIL.CRANK_LBL_STR = "当前排名："
L.MATCHDETAIL.CCHIP_LBL_STR = "当前盲注："
L.MATCHDETAIL.NCHIP_LBL_STR = "下一轮盲注："
L.MATCHDETAIL.MAXCHIP_LBL_STR = "最大筹码："
L.MATCHDETAIL.ACHIP_LBL_STR = "平均筹码："
L.MATCHDETAIL.ONLINE_LBL_STR = "参赛人数："
L.MATCHDETAIL.MATHC_DETAIL = "赛事详情"
L.MATCHDETAIL.MATHC_REWARD = "奖励 "

L.COINROOM.SCORE = "黄金币"
L.COINROOM.BUY_IN_TITLE = "买入黄金币"
L.COINROOM.BUY_IN_DESC = "游戏开始扣除{1}黄金币为服务费"
L.COINROOM.SELF_CHIP_NO_ENOUGH_SEND_DELEAR = "你的黄金币不足，无法赠送荷官小费"
L.COINROOM.NOT_ENOUGH_MONEY_TO_PLAY_NOW_MSG = "你持有黄金币不足最小买入{1}，你可前往比赛场参赛获得！"

L.SONGKRAN_ACT.NUMBER_TEXT = "当前拥有数量：{1}"
L.SONGKRAN_ACT.CARD1_TEXT = "2000盲注以上场玩牌获得"
L.SONGKRAN_ACT.CARD2_TEXT = "参加一场比赛（除免费场）"
L.SONGKRAN_ACT.CARD3_TEXT = "分享出的帖子获赞50以上100%获得"
L.SONGKRAN_ACT.CARD1_TIPS = "前往前注2000及以上场次玩牌20局即可获得1次领奖机会"
L.SONGKRAN_ACT.CARD2_TIPS = "参赛完成一场比赛，即可领奖（免费场2泰铢场除外）"
L.SONGKRAN_ACT.GOMATCH = "立即去比赛场"
L.SONGKRAN_ACT.CARD2_FINISH_TIPS = "你已完成宋干节新年任务活动， 可前往活动界面领取奖励"
L.SONGKRAN_ACT.CARD3_UPLOAD = "上传截图"
L.SONGKRAN_ACT.CARD3_UPLOAD_HINT = "请先选择截图"
L.SONGKRAN_ACT.UPLOAD_PIC_IS_UPLOADING = "正在上传截图，请稍候..."
L.SONGKRAN_ACT.CARD3_UPLOAD_SUCCESS = "截图上传成功，正在审核中"
L.SONGKRAN_ACT.CARD3_PENDING = "审核中"
L.SONGKRAN_ACT.CARD3_REJECTED = "审核未通过"
L.SONGKRAN_ACT.CARD3_REJECTED_REASON = "因上传的图片不符合要求（上传图片非本活动分享图片或低于50个赞），审核不通过！"
L.SONGKRAN_ACT.CARD_REWARD = "领奖"
L.SONGKRAN_ACT.GOT_REWARD = "已领奖"
L.SONGKRAN_ACT.CARD_SEND = "赠送"
L.SONGKRAN_ACT.CARD_SEND_TITLE = "赠送给好友"
L.SONGKRAN_ACT.CARD_SEND_BUTTON = "赠送1个"
L.SONGKRAN_ACT.CARD_SEND_NOT_ENOUGH = "你的{1}字不足"
L.SONGKRAN_ACT.CARD_SEND_SUCCESS = "{1}赠送成功"
L.SONGKRAN_ACT.CARD_SEND_FAILED = "赠送失败"
L.SONGKRAN_ACT.CARD_EXCHANGE = "兑换"
L.SONGKRAN_ACT.CARD_EXCHANGE_TEXT = '需要消耗"新""年""好"三个字，总限一次'
L.SONGKRAN_ACT.CARD_EXCHANGE_TIPS = "你将消耗1个X字，1个XX字，1个XXX字兑换1个新年豪华礼包？"
L.SONGKRAN_ACT.PART1_TEXT = "完成新年任务抽取幸运奖励"
L.SONGKRAN_ACT.PART2_TEXT = "齐集字领取新年大礼包"
L.SONGKRAN_ACT.PART3_TEXT = "此活动最终解释权归博雅三公所有"
L.SONGKRAN_ACT.HELP_TEXTS = {
    "活动规则：\n一、关于活动集字:\n    途径1：完成指定的活动条件即可获得1次抽奖机会，抽奖获得新年福字。",
    "1.去玩牌：前往前注2000及以上场次玩牌20局即可获得1次领奖机会（牌局跨天不累计）。",
    "2.去比赛：参赛完成一场比赛（免费场2泰铢和5泰铢场除外），即可获得1次领奖机会。",
    "3.去分享：分享活动截图到的个人FB主页，并且上传该分享点赞50次以上的截图，通过官方人工审核后即可获得1次领奖机会（必得福字）。  注：截图审核周期自上传时间起48小时之内完成。",
    "途径2：你可以把自己的福字赠送给好友或向好友索要福字（将会扣除自己或好友福字的数量）",
    "二、关于新年大礼包\n    当你集齐“x””x””x”3个福字后，消耗对应的福字数量即可兑换新年大礼包（每个ID仅限兑换1次）"
}

--荷官商城
L.DEALERSHOP.EXPIRY_DATE = "有效期{1}天"
L.DEALERSHOP.PRICE = "{1}游戏币"
L.DEALERSHOP.BUY_TIPS = "确定花费{1}使用此荷官么？"
L.DEALERSHOP.SETTING = "设为我的荷官"
L.DEALERSHOP.STATE_DESC = {
    "免费",
    "已购买({1}天)",
    "未购买"
}

L.ROOM_4K.TIPS = {
    "请点击选中需要丢弃的两张牌",
    "请点击选择需要丢弃的第二张牌",
    "请点击丢牌按钮确认丢弃选中的两张牌",
    "等待其他玩家丢牌"
}

L.ROOM_4K.BTN_DROP = "丢牌"
L.ROOM_4K.BTN_FOLD = "弃牌"

L.POKER_ACT.TIME_TITLE = "任务倒计时"
L.POKER_ACT.TASK_TITLE = "{1}盲注玩牌{2}局"
L.POKER_ACT.TASK_REWARD = "勇者奖励{1}游戏币"
L.POKER_ACT.TASK_REWARD_GCOIN = "勇者奖励{1}黄金币"
L.POKER_ACT.TASK_REWARD_COIN = "勇者奖励{1}现金币"
L.POKER_ACT.TASK_GET = "领取任务"
L.POKER_ACT.TASK_PROGRESS = "挑战进行中"
L.POKER_ACT.TASK_GIVEUP = "放弃挑战"
L.POKER_ACT.TASK_GIVEUP_TIPS = "注意：放弃任务将会清空已玩牌局数哦！"

L.DICE.HELP_TITLE = "玩法规则"
L.DICE.CURR_USER_COUNT = "当前房间共有{1}人"
L.DICE.USERINFO_CHIPS = "游戏币:{1}"
L.DICE.NO_OPER_TIPS = "超过10次未投注，您被请出此房间"
L.DICE.MONEY_NOT_ENOUGH = "您的游戏币不足10万，不能继续在此房间玩牌，请先充值或玩其他房间"
L.DICE.BET_FAIL = "您的游戏币不够  下注失败"
L.DICE.KICK_OFF = "您已经多次未下注，如果下一局不下注，系统将自动请您退出房间"
L.DICE.TO_HALL_CONFIRM = "确定要退出房间么？"

L.DICE.ERROR_TIP_MONEY_NOT_ENOUGH = "由于【游戏币不够】进房间失败"
L.DICE.ERROR_TIP_ROOM_FULL = "由于【人数满了】进房间失败"
L.DICE.AUTO_BUYIN = "系统帮你自动买入了{1}筹码"
L.DICE.ROOM_ID = "房间 {1}"
L.DICE.BET_DOUBLE = "加倍"
L.DICE.BET_LAST = "重复上局"
L.DICE.NOT_ENOUGH_MONEY = "您的筹码不足{1}，请先补充筹码或者选择别的场次玩牌"

L.RICHMAN.COUNTDOWN = "距离开奖还有："
L.RICHMAN.TITLETABLE = {
    "名次",
    "排名奖励",
    "用户名",
    "积分总额",
    "昨日积分变化"
}

L.RICHMAN.RANKTAG = "排名:"
L.RICHMAN.NEXT_PAGE = "下一页"
L.RICHMAN.PRE_PAGE = "上一页"
L.RICHMAN.NOT_IN_RANK = "未入榜"
L.RICHMAN.RANK = "排名为"
L.RICHMAN.MY_SCORE = "您的积分为"
L.RICHMAN.RULE_TITLE = "活动积分规则"

L.GROUP.ACTWORD = "活跃度:{1}"
L.GROUP.OWNERREBATE = "充值返利:{1}"
L.GROUP.MEMBERNUM = "群成员:{1}/{2}"

L.GROUP.MSG = "群消息"
L.GROUP.LOGOUT = "退 群"
L.GROUP.JOINSET = "加群设置"
L.GROUP.JOINLIST = "申请列表"
L.GROUP.CHANGEBTN = "转让群"
L.GROUP.KICKEDOUTBTN = "踢出群"
L.GROUP.ADDFRIENDBTN = "查看信息"
L.GROUP.TRACEBTN = "跟踪进房间"

L.GROUP.OUTCONFIRM = "确定要退出群组么？"
L.GROUP.CHANGECONFIRM = "您确定要转让群组，您将失去群的控制权，请谨慎！！"
L.GROUP.KICKEDOUTCONFIRM = "您确定要将玩家踢出群么？"
L.GROUP.CHANGEFAIL0 = "操作失败~~"
L.GROUP.CHANGEFAIL1 = "你当前是群主，无法退群，把群主转移给其他群成员才可以退群~"

L.GROUP.INVITENEW = "邀请新成员"
L.GROUP.TOTALACT = "总活跃值"
L.GROUP.TODAYACT = "今日活跃"
L.GROUP.ROOMOWNER_BET = "≥{1} 盲注(黄金币)"
L.GROUP.CREATROOM = "创建房间"
L.GROUP.JOINROOM = "加入"

L.GROUP.JOINGROUP = "加入"
L.GROUP.SEARCHGROUP = "搜索群组"
L.GROUP.CREATGROUP = "创建群组"
L.GROUP.BACKGROUP = "返回群组"
L.GROUP.CREATGROUPTIPS = "你确认消耗{1}黄金币创建群组吗？"
L.GROUP.LEVELENOUGH = "你的等级不足{1}，创建群组失败！" -- 5
L.GROUP.GCOINENOUGH = "你的黄金币余额不足{1}，创建群组失败！" -- 500
L.GROUP.ONLYONE = "对不起您已经拥有一个群！要先退出才能加入别的群！！"
L.GROUP.CREATGROUPFAIL = "创建群组失败！！！"
L.GROUP.INPUTINVITECODE = "请输入群验证码:"
L.GROUP.GROUPFULLTIPS = "申请加群失败，该群成员已达上限"
L.GROUP.CODEERRORTIPS = "申请加群失败，你输入的群验证码有误"
L.GROUP.REVIEWTIPS = "申请已经发出，等待群主审核！！"
L.GROUP.REVIEWTIPS1 = "申请加入成功！！"
L.GROUP.GROUPGNTIPS = "Tips:创建或加入群组您可以拥有自己的私密玩牌圈,享受私人房、商城折扣及群成员充值返利等。"
L.GROUP.MOREBTN = "了解更多"
L.GROUP.GROUPCATEGORY = {
    "附近群组",
    "热门群组"
}
L.GROUP.ROOMPSWERROR = "密码错误！！！！！"
L.GROUP.ENTERROOMFAIL = "进入群组房间失败！！！！！"
L.GROUP.ENTERROOMFAIL1= "该玩家暂未登陆游戏，赶紧喊他来玩游戏吧"
L.GROUP.ENTERROOMFAIL2= "该玩家当前不在房间玩牌！！"
L.GROUP.ENTERROOMFAIL3= "该房间已经删除，正在重新刷新列表"

L.GROUP.CANDYINFO = "来自{1}的糖果（内含随机 {2} 黄金币）"
L.GROUP.CANDYAWARD = "恭喜您抢得糖果奖励{1}"
L.GROUP.CANDYNULL = "糖果已被其他人抢走了！！"

L.GROUP.CHECKPOPTITLE = "申请入群列表"
L.GROUP.CHECKPOPNAME = "用户名"
L.GROUP.CHECKPOPMONEY = "黄金币"
L.GROUP.CHECKPOPACTION = "操作"
L.GROUP.CHECKPOPFULL = "群成员已达上限，无法再添加新成员"
L.GROUP.CHECKPOPAGREE = "同意"
L.GROUP.CHECKPOPREFUSE = "拒绝"

L.GROUP.ROOM_PLAY_CARD = "一起玩牌"
L.GROUP.ENTER_ROOM_PLAY = "进入房间"
L.GROUP.ROOM_INVITE_TITLE = "邀请"
L.GROUP.ROOM_INVITE_TEXT = "请输入好友ID"
L.GROUP.ROOM_INVITE_HOLDER = "输入好友ID"
L.GROUP.ROOM_INVITE_SEARCH = "搜索"
L.GROUP.ROOM_INVITE_SEARCH_ERR = "您输入的ID不在当前列表，请确认后重新输入"
L.GROUP.INVITE_SUCC = "邀请成功！！！"
L.GROUP.INVITE_ERROR = "被邀请人已不在当前群！！！"
L.GROUP.INVITE_FAIL = "邀请失败！！！"

L.GROUP.CROOMPOPTITLE = "创建群组房间"
L.GROUP.ROOM_TYPE = "场次类型"
L.GROUP.ROOM_PLAY_TYPE_TITLE = "房间玩法"
L.GROUP.ROOM_PLAY_TYPE = "专业场"
L.GROUP.ROOM_PLAY_TYPE_CHIP = "游戏币"
L.GROUP.ROOM_PLAY_TYPE_GCOIN = "黄金币"
L.GROUP.CROOMPOPNUMWORD = "桌子类型"
L.GROUP.CROOMPOPNUM5 = "5人桌"
L.GROUP.CROOMPOPNUM9 = "9人桌"
L.GROUP.CROOMPOPBETWORD = "房间盲注"
L.GROUP.CROOMPOPPWD = "设置密码"
L.GROUP.CROOMPOPPWDNULL = "无"
L.GROUP.CROOMPOPPWDNUM = "输入4位数字"
L.GROUP.CROOMPOPCREATE = "创  建"
L.GROUP.CROOMPOPERROR1 = "一人同时只能创建一个房间！！！！"
L.GROUP.CROOMPOPERROR2 = "您的群活跃值不够100,无法创建房间！！！！"
L.GROUP.CROOMPOPERROR3 = "创建群组房间失败！！！！！"
L.GROUP.CROOMPOPERROR4 = "房间密码必须为4为数字！！！"
L.GROUP.CROOMPOPNOPASSTIPS = "你确定要创建无密码的房间么？"

L.GROUP.INTRPOPTITLE = "群组说明"
L.GROUP.INTRPOP1 = "1.群组活跃度是什么?\n   a.群组活跃度是判断当前群组等级的唯一依据，群组活跃度越高的群组享受的群组福利就越多\n   b.群组活跃度分为群组个人活跃度和群组总活跃度,其中群组总活跃度为当前群组所有群组成员个人活跃度之和\n\n2.群组活跃度怎么获得?\n   a.群组成员每日登陆游戏获得1点群组个人活跃度和群组总活跃度\n   b.群组成员每日在当前指定的盲注区间玩牌1局增加1点活跃度,每日限前50局(注:指定的盲注区间在当前群组私人房列表上方可见)\n   c.群组成员每日充值1美金(购买黄金币)增加1点活跃度,并且群组会获得对应的黄金币返利(注:因汇率变化活跃值增加会存在轻微的误差)\n\n3.群组邀请码\n   a.每个群成员在群组邀请界面都会有一个独立的群组邀请码\n   b.群组邀请码发给未注册游戏的新用户并且群组审核通过加群成功,邀请人将会获得30黄金币\n   c.群组邀请码发给未加入群组的老用户,邀请人不会获得邀请奖励\n\n4.群组总活跃度奖励"
L.GROUP.INTRPOP2 = {
    {"群组活跃奖励","群成员奖励内容（每人每天限1单）"},
    {"1000","群成员充值黄金币加赠5%"},
    {"10000","群成员充值黄金币加赠10%"},
    {"100000","群成员充值黄金币加赠15%"},
    {"500000","群成员充值黄金币加赠20%"},
    {"1000000","群成员充值黄金币加赠25%"},
}
L.GROUP.INTRPOP3 = "\n5.群组私人房:群成员总活跃贡献达到100时可以创建群组私人房,群主可以无视活跃值限制创建群组私人房(每个人同时只能创建1个群组私人房,空闲的私人房将会在24小时后自动回收)\n\n6.群组成员通过游戏内欺诈支付获得的活跃度,将在查实后清零欺诈支付用户的个人群组活跃度并扣除其所在的当前群组总活跃度"

L.GROUP.INVITEPOPTITLE = "邀请新成员"
L.GROUP.INVITEPOPCODE = "告诉你的好友群邀请码：{1}"
L.GROUP.INVITEPOPINVITEBTN = "邀请"
L.GROUP.INVITPOPRESULT1 = "接受邀请成功,等待群主审核！！"
L.GROUP.INVITPOPRESULT2 = "接受邀请失败,该群成员已达上限！！"
L.GROUP.INVITPOPRESULT3 = "接受邀请成功,您已进群,请打开群组查看！！"

L.GROUP.MSGPOPTITLE = "群消息"

L.GROUP.PWDPOPTITLE = "**请输入密码**"
L.GROUP.PWDPOPINPUT = "请输入密码"
L.GROUP.PWDPOPCONFIRM = "确认"

L.GROUP.SETPOPTITLE = "加群设置"
L.GROUP.SETPOPCONDITION = "加群条件:"
L.GROUP.SETPOPALLOWALL = "允许任何人加入"
L.GROUP.SETPOPLEVEL = "等级"
L.GROUP.SETPOPPROPERTY = "黄金币"
L.GROUP.SETPOPREVIEW = "加群审核:"
L.GROUP.SETPOPAUTOIN = "不审核默认加入"
L.GROUP.SETPOPREVIEWIN = "审核加入"
L.GROUP.SETPOPCONFIRM = "应  用"
L.GROUP.SETPOPSETSUCC = "设置成功~~"
L.GROUP.SETPOPSETFAIL = "设置失败！！"
L.GROUP.SETPOPONLYNUM = "请输入纯数字！！"
L.GROUP.SETPOPROPERTY10Y = "资产不能大于10亿！！"
L.GROUP.SETPOPLEVEL30 = "等级不能大于30！！"
L.GROUP.INTRODUCTION_TITLE = "群简介:"
L.GROUP.INTRODUCTION_HINT = "点击输入群组简介，不得超过{1}字"

L.GROUP.JOINLEVELERROR = "你的等级不足，无法加入该群组！"
L.GROUP.JOINLEVELERROR_1 = "你邀请的朋友等级不足，无法加入该群组！"
L.GROUP.JOINGCOINERROR = "你的黄金币不足，无法加入该群组！"
L.GROUP.JOINGCOINERROR_1 = "你邀请的朋友黄金币不足，无法加入该群组！"
L.GROUP.JOINMONEYERROR = "你的游戏币不足，无法加入该群组！"
L.GROUP.JOINMONEYERROR_1 = "你邀请的朋友游戏币不足，无法加入该群组！"

L.CARD_ACT.TITLE = "邀请召回活动"
L.CARD_ACT.ACT_TIME = "活动时间:{1}"
L.CARD_ACT.INPUT_CODE = "输入邀请码"
L.CARD_ACT.ENTER_CODE = "确认"
L.CARD_ACT.REWARD_COUNT = "累计收益:{1}"
L.CARD_ACT.INVITE_NUM = "新玩家邀请人数"
L.CARD_ACT.RECALL_NUM = "老玩家邀请人数"
L.CARD_ACT.REWARD_DESC = "额外福利大放送"
L.CARD_ACT.PAY_REWARD = "储值加赠:"
L.CARD_ACT.PLAY_REWARD = "玩牌加赠:"
L.CARD_ACT.GET_REWARD = "领取"
L.CARD_ACT.GOTO_FINISH = "去完成"
L.CARD_ACT.RULE = "活动规则"
L.CARD_ACT.NOTICE = "注意:"
L.CARD_ACT.BIND_ERROR = "绑定失败"
L.CARD_ACT.MONEY = "游戏币"
L.CARD_ACT.REWARD_FAIL = "领取失败"
L.CARD_ACT.CHECK = "查看"

L.CARD_ACT.BIND_ERROR_MORE = "绑定对方已经满15人"
L.CARD_ACT.BIND_SUCC = "你已成功绑定好友关系！"
L.CARD_ACT.BIND_ERROR_CODE = "邀请码错误，请重新输入！"
L.CARD_ACT.BIND_ERROR_BINDED = "你已经使用过邀请码兑换奖励！"
L.CARD_ACT.BIND_ERROR_SELF = "不能输入自己邀请兑换奖励！"

L.CARD_ACT.REWARD_DESC_NEW = "说明"
L.CARD_ACT.GOTO_USE = "去使用"

L.PDENG.GET_POKER = "要牌"
L.PDENG.NOT_GET_POKER = "不要牌"
L.PDENG.AUTO_GET_POKER = "自动要牌"
L.PDENG.AUTO_NOT_GET_POKER = "自动不要牌"
L.PDENG.GRAB_DEALER = "上庄"
L.PDENG.DROP_DEALER = "下庄"
L.PDENG.WAIT_OTHER_BET = "等待闲家下注"
L.PDENG.BET_TIPS = "请点击筹码下注"
L.PDENG.GET_CARD_TIPS = "请选择是否要牌"
L.PDENG.BET_LIMIT_TIPS = "您的下注已达到本场的下注上限"
L.PDENG.GRAB_DEALER_SUCCESS = "抢庄成功，您将在下局开始后自动上庄"
L.PDENG.GRAB_DEALER_SUCCESS_WAIT = "抢庄成功，您将在当前庄家下庄后自动上庄"
L.PDENG.GRAB_DEALER_SUCCESS_WAIT_X = "抢庄成功，您前面还有{1}位正在排队等待上庄"
L.PDENG.GRAB_DEALER_SUCCESS_WAIT_NEXT = "抢庄成功,正在等待本局结束......"
L.PDENG.GRAB_DEALER_FAILED = "抢庄失败"
L.PDENG.GRAB_DEALER_FAILED_MONEY_LIMIT = "抢庄失败，您的筹码不足"
L.PDENG.GRAB_DEALER_FAILED_ALREADY = "您已经请求上庄"
L.PDENG.GRAB_DEALER_FAILED_FULL = "抢庄失败，候选人太多"
L.PDENG.WAIT_GRAB_DEALER = "等待上庄中"
L.PDENG.DEALER_CANDIDATE_TITLE = "候选人列表"
L.PDENG.BACK_TIPS_IN_GAME = "退出成功，您将在本局结束后退出"
L.PDENG.STAND_TIPS_IN_GAME = "站起成功，您将在本局结束后站起"
L.PDENG.DROP_DEALER_TIPS_IN_GAME = "下庄成功，您将在本局结束后自动下庄"
L.PDENG.BACK_ERROR_IN_THREE = "退出失败，庄家在3局之内不能退出"
L.PDENG.STAND_ERROR_IN_THREE = "站起失败，庄家在3局之内不能站起"
L.PDENG.DROP_DEALER_ERROR_IN_THREE = "下庄失败，庄家在3局之内不能下庄"
L.PDENG.BACK_TIPS_WHEN_NO_OPR = "您连续{1}局未操作，如果还未操作，将在本局结束后退出房间"
L.PDENG.DROP_DEALER_TIPS_WHEN_POOR = "您的资产已不足最低上庄限制，已被强制下庄"

L.FOOTBALL.RULE_DESC ={
    "1.什么是足球竞猜?\n系统会从时下主流赛事中选择优质的比赛场次开放给广大玩家进行投注竞猜,比赛结束后系统会同步比赛结果,竞猜正确的用户根据最终赔率获得竞猜奖金;",
    "\n\n2.什么是赔率?\n赔率是根据科学公式实时浮动，最终的竞猜奖金=投注金额*最终赔率(比赛停止下注时的赔率)",
    "\n\n3.怎么竞猜下注?\n竞猜方式分为单独下注和组合下注两种方式，其中组合下注需要至少选择3场比赛才可以进行竞猜且所选比赛全部猜中才能获得竞猜奖金(假设a,b,c3场比赛且猜中，最终的竞猜奖金=投注金额*a比赛的最终赔率*b比赛的最终赔率*c比赛的最终赔率)",
    "\n\n4.什么时间竞猜开奖?\n所选比赛结束后的第一个工作日系统会同步比赛结果并按照最终的赔率发放竞猜奖励。\n球赛问题需在10天内反馈"
}

L.FOOTBALL.MATCH_TITLES = 
{
    "开赛时间",
    "主队VS客队",
    "赔率(实时变动)",
    "投注比例"
}

L.FOOTBALL.BET_TITLES =
{
    "胜",
    "平",
    "负"
}

L.FOOTBALL.BET_MODES =
{
    "单独下注",
    "组合下注"
}

L.FOOTBALL.RECORD_TITLES ={
    "投注方式",
    "开赛时间",
    "主队VS客队",
    "已投竞猜",
    "全场比分",
    "状态\n(赔率)",
}

L.FOOTBALL.REWARD_STATE ={
    "未开赛",
    "未猜中",
    "领奖",
    "已领奖"
}

L.FOOTBALL.BET_INFO = "投注信息"
L.FOOTBALL.BET_MODE = "投注方式"
L.FOOTBALL.BET_TOTAL_TITLE = "当前下注总额: "
L.FOOTBALL.BET_REWARD_TITLE = "按当前赔率预计最高获得: "
L.FOOTBALL.TOTAL_MONEY_TITLE = "总资产(不含保险箱): "
L.FOOTBALL.MONEY_INFO = "{1}游戏币, {2}黄金币"
L.FOOTBALL.CONFIRM_BET = "确认投注"
L.FOOTBALL.SELECTED_MATCH = "已选比赛"
L.FOOTBALL.BET_MONEY = "投注金额"
L.FOOTBALL.GROUP_BET_TIPS = "至少选择3场\n才可以投注"
L.FOOTBALL.BET_CHIP_TIPS = "游戏币投注不能小于{1}"
L.FOOTBALL.BET_GCOINS_TIPS = "黄金币投注不能小于{1}"
L.FOOTBALL.MIN_BET_CHIP = "最低投注 {1} 游戏币"
L.FOOTBALL.MIN_BET_GCOINS = "最低投注 {1} 黄金币"
L.FOOTBALL.MAX_BET_CHIP = "单笔组合下注不能超过1M游戏币"
L.FOOTBALL.BET_TOTAL_MONEY_TIPS = "下注总额度不能超过身上携带资产数"
L.FOOTBALL.ALONE_TITLE = "单独"
L.FOOTBALL.GROUP_TITLE = "组合"
L.FOOTBALL.BET_SUCC_TIPS = "投注成功"
L.FOOTBALL.BET_TIMEOUT_TIPS = "所选比赛已到截止时间,请重新选择下注"
L.FOOTBALL.BET_FAIL_TIPS = "投注失败，请重新投注"
L.FOOTBALL.GET_REWARD_SUCC_TIPS = "领奖成功"
L.FOOTBALL.GET_REWARD_FAIL_TIPS = "领奖失败,请重新领取"
L.FOOTBALL.BET_ODDS = "({1})"

L.SONGKRAN.CUR_WATER_VALUE = "当前蓄水值({1}/1000)"
L.SONGKRAN.TASK_REWARD = "{1}蓄水值"
L.SONGKRAN.TASK_PROGRESS = "({1}/{2})"
L.SONGKRAN.LABBER_NUM = "{1}次"
L.SONGKRAN.NOT_ENOUGH_MONEY = "身上携带钱不足，请充值后再进行抽奖"
L.SONGKRAN.LABBER_ERROR_TIPS = "选择好友才可以泼水"
L.SONGKRAN.SELECTED_FRIEND_TIPS = "最多选择三个好友"
L.SONGKRAN.NO_RANKING = "未上榜"
L.SONGKRAN.GO_TO_BTN = "立即前往"
L.SONGKRAN.NOT_ENOUGH_PROP = "节日道具数量不足,请通过节日活动获取"
L.SONGKRAN.USE_PROP_FAIL = "使用道具失败,请重试"

L.WATERLAMP.BLESSING1 = "水灯节快乐"
L.WATERLAMP.BLESSING2 = "希望好运到来"
L.WATERLAMP.BLESSING3 = "希望每个人都幸福"

L.WATERLAMP.BLESSING21 = "水灯节快乐"
L.WATERLAMP.BLESSING22 = "希望今年只有好事发生，不好的事随水飘走"
L.WATERLAMP.BLESSING23 = "希望只遇见好事情，每件事都成功"
L.WATERLAMP.BLESSING24 = "希望能够幸福安康"

L.WATERLAMP.WATER_LAMP_PROP = "水灯道具"

L.WATERLAMP.BLESSING_SUCCESS = "成功发送祝福"

L.WATERLAMP.NO_MONEY_TIP = "您的金币不足，请充值金币后再来吧"

L.WATERLAMP.DEFAULT_ID_TIP = "朋友的ID"
L.WATERLAMP.DEFAULT_BLESSING_TIP = "可自己输入祝福语或选择已有祝福语"

L.WATERLAMP.INPUT_ID_TIP = "提示：请先选择朋友ID"
L.WATERLAMP.INPUT_BLESSING_TIP = "提示：还没写/选择祝福语哦"

return L
