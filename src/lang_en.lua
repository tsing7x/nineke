-- module lang_en
-- note: 发布版本前需要认真审核一遍翻译,尤其是新增的
-- Author: Johnny Lee
-- Date: 2014-07-08 10:52:57
--

local lang = {}
local L    = lang
local T, T1

L.COMMON   = {}
L.LOGIN    = {}
L.HALL     = {}
L.ROOM     = {}
L.STORE    = {}
L.USERINFO = {}
L.FRIEND   = {}
L.RANKING  = {}
L.MESSAGE  = {}
L.SETTING  = {}
L.LOGINREWARD = {}
L.HELP     = {}
L.UPDATE   = {}
L.ABOUT    = {}
L.DAILY_TASK = {}
L.COUNTDOWNBOX = {}
L.NEWESTACT = {}
L.FEED = {}
L.ECODE = {}
L.WHEEL = {}
L.BANK = {}
L.SLOT = {}
L.UPGRADE = {}
L.TUTORIAL = {}
L.GIFT = {}
L.CRASH = {}
L.FBGUIDE = {} -- facebook登录引导
L.MATCH        = {} -- 比赛场
L.SCOREMARKET  = {} -- 积分兑换奖励

-- COMMON MODULE
L.COMMON.LEVEL = "Lv.{1}"
L.COMMON.ASSETS = "${1}"
L.COMMON.CONFIRM = "Confirm"        --确定
L.COMMON.CANCEL = "Cancel"          --取消
L.COMMON.AGREE = "Agree"            --同意
L.COMMON.REJECT = "Deny"            --拒绝
L.COMMON.RETRY = "Retry"            --重试
L.COMMON.NOTICE = "Notice"          --温馨提示
L.COMMON.BUY = "Buy"                --购买
L.COMMON.SEND = "Send"              --发送
L.COMMON.BAD_NETWORK = "Network is slow!"   --网络不给力
L.COMMON.REQUEST_DATA_FAIL = "Network is slow, please try again later!"   --网络不给力，获取数据失败，请重试！
L.COMMON.ROOM_FULL = "Audience seats are full, go to another room!"     --现在该房间旁观人数过多，请换一个房间
L.COMMON.USER_BANNED = "Your account was frozen, please contact game manager!"   --您的账户被冻结了，请你反馈或联系管理员
L.COMMON.MAX_MONEY_HISTORY = "My most capital: {1}"     --历史最高资产: {1}
L.COMMON.MAX_POT_HISTORY = "My best win-pot: {1}"       --赢得最大奖池: {1}
L.COMMON.WIN_RATE_HISTORY = "Winning rate: {1}%"      --历史胜率: {1}%
L.COMMON.BEST_CARD_TYPE_HISTORY = "Best hand:"        --历史最佳牌型:
L.COMMON.LEVEL_UP_TIP = "Succeed to level {1}, get bonus: {2}"      --恭喜你升到{1}级, 获得奖励:{2}
L.COMMON.MY_PROPS = "My items:"   --我的道具:
L.COMMON.SHARE = "Share"      --分享
L.COMMON.GET_REWARD = "Claim"   --领取奖励 

L.COMMON.BUY_CHAIP = "Buy"      --购买

L.COMMON.LOGOUT = "Logout"      --登出
L.COMMON.QUIT_DIALOG_TITLE = "Confirm to logout"  --确认退出
L.COMMON.BINDFHONE = "Excuse Me?"
L.COMMON.NULLPHONE = "Excuse Me?"
L.COMMON.NULLKEY = "Excuse Me?"
L.COMMON.DESSHOP = "Excuse Me?"

L.COMMON.QUIT_DIALOG_MSG = "Sure to logout the game? We'll miss u! \\(≧▽≦)/~"   --真的确认退出游戏吗？淫家好舍不得滴啦~
L.COMMON.QUIT_DIALOG_CONFIRM = "Still logout!"        --残忍退出！
L.COMMON.QUIT_DIALOG_CANCEL = "No, I'll stay"       --我点错了！
L.COMMON.LOGOUT_DIALOG_TITLE = "Sure to logout"       --确认退出登录
L.COMMON.LOGOUT_DIALOG_MSG = "Sure to logout?"        --真的要退出登录吗？
L.COMMON.NOT_ENOUGH_MONEY_TO_PLAY_NOW_MSG = "You need more chips to buy-in! Why not add some?" --您的筹码不足最小买入{1}，您需要补充筹码后重试。
L.COMMON.USER_SILENCED_MSG = "You are forbidden to talk, please tap Help->Feedback to contact us." --您的帐号已被禁言，您可以在帮助-反馈里联系管理员处理

-- LOGIN MODULE
L.LOGIN.FB_LOGIN = "Facebook login"     --FB账户登录
L.LOGIN.GU_LOGIN = "Guest login"      --游客账户登录
L.LOGIN.USE_DEVICE_NAME_TIP = "Do you allow us to use your device name as nick name in this game?"  --您是否允许我们使用您的设备名称\n作为游客账户的昵称并上传到游戏服务器？
L.LOGIN.REWARD_SUCCEED = "Success to get bonus"   --领取奖励成功
L.LOGIN.REWARD_FAIL = "Failed to get bonus"     --领取失败
L.LOGIN.REIGSTER_REWARD_FIRST_DAY = "1st Day"   --第一天
L.LOGIN.REGISTER_REWARD_SECOND_DAY = "2nd Day"    --第二天
L.LOGIN.REGISTER_REWARD_THIRD_DAY = "3rd Day"   --第三天
L.LOGIN.LOGINING_MSG = "Login..."         --正在登录游戏...
L.LOGIN.CANCELLED_MSG = "Login canceled"      --登录已经取消
L.LOGIN.FEED_BACK_HINT = "Please describe the problem you have in details (Login method? UID?)"
L.LOGIN.FEED_BACK_TITLE = "Feedback"
L.LOGIN.DOUBLE_LOGIN_MSG = "Your account login in other places"   -- 帐号在其它地方登录

-- HALL MODULE
L.HALL.USER_ONLINE = "Online players: {1}"      --当前在线人数{1}
L.HALL.INVITE_FRIEND = "Invite by FB +{1}"       --邀请FB好友+50000
L.HALL.DAILY_BONUS = "Login Bonus"          --登录奖励
L.HALL.DAILY_MISSION = "Daily Mission"        --每日任务
L.HALL.NEWEST_ACTIVITY = "News"     --最新活动
L.HALL.LUCKY_WHEEL = "Lucky Wheel"          --幸运转转转
L.HALL.NOTOPEN="Coming soon..."           --暂未开放 敬请期待
L.HALL.STORE_BTN_TEXT = "Store"           --商城    
L.HALL.FRIEND_BTN_TEXT = "Buddy"          --好友
L.HALL.RANKING_BTN_TEXT = "Rank"          --排行榜
L.HALL.MAX_BUY_IN_TEXT = "MAX buy-in: {1}" --最大买入{1}
L.HALL.PRE_CALL_TEXT = "Blind"          --前注
L.HALL.SEARCH_ROOM_INPUT_ROOM_NUMBER_ERROR = "Wrong room ID!"   --你输入的房间号码有误
L.HALL.SEARCH_ROOM_INPUT_ROOM_NUMBER_EMPTY = "Oh, you input nothing!"     --房间号码不能为空
L.HALL.SEARCH_ROOM_NUMBER_IS_WRONG= "Wrong input, must be 5~6 bits number!"         --你输入的房间位数不对
L.HALL.SEARCH_ROOM_INPUT_CORRECT_ROOM_NUMBER= "Please input 5~6 bits room number"         --请输入5位的房间号码
L.HALL.ROOM_LEVEL_TEXT = {
    "Fish",         --初级场
    "Shark",        --中级场
    "Whale"         --高级场
}
L.HALL.PLAYER_LIMIT_TEXT = {
    "9P",          --9\n人
    "5P"         --5\n人
}

-- ROOM MODULE
L.ROOM.OPR_TYPE = {
    "Check",          --看  牌 
    "Fold",           --弃  牌 
    "Call",           --跟  注 
    "Raise",          --加  注
}
L.ROOM.MY_MONEY = "Capital: {1} {2}"      --My money {1} {2}
L.ROOM.INFO_UID = "UID: {1}"          --UID {1}
L.ROOM.INFO_LEVEL = "Lv.{1}"          --Lv.{1}
L.ROOM.INFO_RANKING = "Rank:  {1}"        --排名:  {1} 
L.ROOM.INFO_WIN_RATE = "Winning rate:  {1}%"  --胜率:  {1}%
L.ROOM.INFO_SEND_CHIPS = "Send chips"     --赠送筹码
L.ROOM.ADD_FRIEND = "+ Buddy"         --加为好友 
L.ROOM.DEL_FRIEND = "Un-buddy"          --删除好友
L.ROOM.ADD_FRIEND_FAILED_MSG = "Failed to add buddy"  --添加好友失败
L.ROOM.DELE_FRIEND_SUCCESS_MSG = "Success to delete buddy"    --删除好友成功
L.ROOM.DELE_FRIEND_FAIL_MSG = "Failed to un-buddy"      --删除好友失败
L.ROOM.SEND_CHIP_NOT_NORMAL_ROOM_MSG = "You can't send chips here"    --只有普通场才可以赠送筹码
L.ROOM.SELF_CHIP_NO_ENOUGH_SEND_DELEAR = "Not enough chips"       --你的筹码不够多，不足给荷官小费
L.ROOM.SEND_CHIP_NOT_IN_SEAT = "Sit down to send chips!"        --坐下才可以赠送筹码
L.ROOM.SEND_CHIP_NOT_ENOUGH_CHIPS = "Not enough chips"          --钱不够啊
L.ROOM.SEND_CHIP_TOO_OFTEN = "Too many send request"          --赠送的太频繁了
L.ROOM.SEND_CHIP_TOO_MANY = "You send too much chips"         --赠送的太多了
L.ROOM.SEND_HDDJ_IN_MATCH_ROOM_MSG = "You can't use items here"     --比赛场不能发送互动道具
L.ROOM.SEND_HDDJ_NOT_IN_SEAT = "You must sit down to throw items"   --坐下才能发送互动道具
L.ROOM.SEND_HDDJ_NOT_ENOUGH = "Not enough items, buy some in store"   --您的互动道具数量不足，赶快去商城购买吧
L.ROOM.SEND_EXPRESSION_MUST_BE_IN_SEAT = "Sit down to use stickers!"  --坐下才可以发送表情
L.ROOM.CHAT_FORMAT = "{1}: {2}"
L.ROOM.ROOM_INFO = "{1} {2}/ Blind {3}"        --{1} {2}/前注{3}
L.ROOM.NO_BIG_LA_BA = "No speakers yet, buy now?"
L.ROOM.SEND_BIG_LABA_MESSAGE_FAIL = "Failed to send message by speaker" 
L.ROOM.NOT_GIVE_CHIP_MSG = "比赛场不可以赠送游戏币哦"

L.ROOM.USER_CARSH_REWARD_DESC = "{1} aid chips for you. Be careful! Only 3 chances to get bankrupt finance aid!"      --您获得了{1}筹码的破产补助，终身只有三次机会获得，且用且珍惜
L.ROOM.USER_CARSH_BUY_CHIP_DESC = "After lost, there'll be win, buy chips to win back!"   --您也可以立即购买，输赢只是转瞬的事
L.ROOM.USER_CARSH_REWARD_COMPLETE_DESC = "No financial aid any more, you can buy chips or login tomorrow to get free chips!"    --您已经领完所有破产补助，您可以去商城购买筹码，每天登录还有免费筹码赠送哦！
L.ROOM.USER_CARSH_REWARD_COMPLETE_BUY_CHIP_DESC = "Winning is waiting ahead, don't give up! Buy chips to win back!"     --输赢乃兵家常事，不要灰心，立即购买筹码，重整旗鼓。

L.ROOM.WAIT_NEXT_ROUND = "Please wait for next round"    --请等待下一局开始
L.ROOM.LOGIN_ROOM_FAIL_MSG = "Failed to login"        --登录房间失败

L.ROOM.BUYIN_ALL_POT= "Jackpot"           --全部奖池
L.ROOM.BUYIN_3QUOT_POT = "3/4\nJackpot"        --3/4奖池
L.ROOM.BUYIN_HALF_POT = "1/2\nJackpot"       --1/2奖池
L.ROOM.BUYIN_TRIPLE = "Triple\nRaise"            --3倍反加


L.ROOM.CHAT_TAB_SHORTCUT = "Fast chat"          --快捷聊天
L.ROOM.CHAT_TAB_HISTORY = "Chat record"         --聊天记录
L.ROOM.INPUT_HINT_MSG = "Click to input message"    --点击输入聊天内容
L.ROOM.CHAT_SHORTCUT = {
  "Hello, everybody!",          --大家好!
  "Nobody can beat me here!",     --初来乍到，多多关照
  "Fast, please!",            --我等到花儿都谢了
  "ALL IN!!",           --All IN他！
  "Show me your money!",      --送点钱给我吧!
  "Nice job!",            --你的牌打得太好了!
  "Be patient!",          --冲动是魔鬼，淡定!
  "Call or ALL IN!",        --求跟注，求ALL-IN!
  "What a monster!",          --哇，你抢钱啊!
  "Bad network!"          --又断线，网络太差了!
}

--买入弹框
L.ROOM.BUY_IN_TITLE = "Buy-in"        --买入筹码
L.ROOM.BUY_IN_BALANCE_TITLE = "Your Capital:"   --您的账户余额
L.ROOM.BUY_IN_MIN = "MIN buy-in"        --最低买入
L.ROOM.BUY_IN_MAX = "MAX buy-in"        --最高买入
L.ROOM.BUY_IN_AUTO = "Auto buy-in"        --筹码不足时自动买入
L.ROOM.BUY_IN_BTN_LABEL = "Buy-in & Sit down" --买入坐下

L.ROOM.BACK_TO_HALL = "Lobby"     --返回大厅
L.ROOM.CHANGE_ROOM = "Change room"    --换  桌
L.ROOM.SETTING = "Set / Help"          --设  置
L.ROOM.SIT_DOWN_NOT_ENOUGH_MONEY = "Not enough chips for MIN buy-in, change room or buy chips?" --您的筹码不足当前房间的最小携带，您可以点击自动换桌系统帮你选择房间或者补足筹码重新坐下。
L.ROOM.AUTO_CHANGE_ROOM = "Change room"         --自动换桌
L.ROOM.USER_INFO_ROOM = "Profile"     --个人信息
L.ROOM.CHARGE_CHIPS = "Buy chips"     --补充筹码
L.ROOM.ENTERING_MSG = "Strive loading ...\nYou need both courage and strategy to win!"          --正在进入，请稍候...\n有识尚需有胆方可成赢家
L.ROOM.OUT_MSG = "Logout processing ..."    --正在退出，请稍候...
L.ROOM.CHANGING_ROOM_MSG = "Change room..."         --正在更换房间..
L.ROOM.CHANGE_ROOM_FAIL = "Failed to change room, retry?"
L.ROOM.STAND_UP_IN_GAME_MSG = "You are still in round, sure to stand up?"       --您还在当前牌局中，确认站起吗？
L.ROOM.NET_WORK_PROBLEM_DIALOG_MSG = "Connection lost, re-connect?"   --与服务器的连接中断，是否尝试重新连接？
L.ROOM.RECONNECT_MSG = "Re-connecting..." --正在重新连接..
L.ROOM.OPR_STATUS = {
  "Fold",     --弃  牌
  "ALL-IN",   --ALL_IN
  "Call",     --跟  注
  "Call\n{1}",   --跟注 {1}
  "Small Blind",  --小  盲
  "Big Blind",  --大  盲
  "Check",    --看  牌
  "Raise\n{1}",    --加注 {1}
  "Raise",    --加  注
}
L.ROOM.AUTO_CHECK = "Auto Check"          --自动看牌
L.ROOM.AUTO_CHECK_OR_FOLD = "Check/Fold" --看或弃
L.ROOM.AUTO_FOLD = "Auto Fold"        --自动弃牌
L.ROOM.AUTO_CALL_ANY = "Call any"     --跟任何注
L.ROOM.FOLD = "Fold"            --弃  牌
L.ROOM.ALL_IN = "ALL IN"
L.ROOM.CALL = "Call"            --跟  注
L.ROOM.CALL_NUM = "Call{1}"        --跟注{1}
L.ROOM.SMALL_BLIND = "Small Blind"      --小盲
L.ROOM.BIG_BLIND = "Big Blind"        --大盲
L.ROOM.RAISE = "Raise"            --加  注
L.ROOM.RAISE_NUM = "Raise{1}"        --加注{1}
L.ROOM.CHECK = "Check"            --看  牌
L.ROOM.TIPS = {
    "Tips: you can change your profile picture by click your photo",    --小提示：游客用户点击自己的头像弹框或者性别标志可更换头像和性别哦
  "Tips: you will lost chips already bet in jackpot if your hands is smaller",  --小经验：当你牌比对方小的时候，你会输掉已经押上的所有筹码
  "All whales come from fishes! Success is ahead, never give up!",        --高手养成：所有的高手，在他会三公游戏之前，一定是一个三公游戏的菜鸟
  "Raise positively to control the round if you have good hands",     --有了好牌要加注，要掌握优势，主动进攻。
    "Patiently observe your opponents! Don't be cheated by them!",      --留意观察对手，不要被对手的某些伎俩所欺骗。
    "Make your opponents be afraid of you!",              --要打出气势，让别人怕你。
    "Control your emotion, win fixed rounds!",              --控制情绪，赢下该赢的牌。
    "Guest account can change your profile pictures",         --游客玩家可以自定义自己的头像。
    "Tips: set auto buy-in in Settings to save time",         --小提示：设置页可以设置进入房间是否自动买入坐下。
    "Tips: set Remind by Shake in Settings",                          --小提示：设置页可以设置是否震动提醒。
    "Keep patient to wait for chance of All-in",          --忍是为了下一次All In。
    "Impulse is demo!",                   --冲动是魔鬼，心态好，好运自然来。
    "Feel unlucky? Maybe you need change your seat position",   --风水不好时，尝试换个位置。
  "Lost of round is affordable, but lost of confidence isn't!",       --输牌并不可怕，输掉信心才是最可怕的。
    "You can't control win or lose in a round, but how many chips won/lost in all rounds",    --你不能控制输赢，但可以控制输赢的多少。
    "Throw items to the guy you hate!",       --用互动道具砸醒长时间不反应的玩家。
    "Luck is not stable, but knowledge will stay in your mind",   --运气有时好有时坏，知识将伴随你一生。
    "Bluff is a good tool, strategically use bluff to win more!", --诈唬是胜利的一大手段，要有选择性的诈唬。
    "Bet by brain, not by heart",         --下注要结合池底，不要看绝对数字。
    "Rare players can professionally use All-in"    --All In是一种战术，用好并不容易。
}
L.ROOM.SHOW_HANDCARD = "Show hands"     --亮出手牌
L.ROOM.DEALER_SPEEK_ARRAY = {
  "Good luck, {1}",   --祝您牌运亨通，{1}
  "Good job, {1}",    --祝您好运连连，{1}
  "Nice buddy, {1}",    --您人真好，{1}
  "Glad to help you, {1}",    --真高兴能为您服务，{1}
  "Thank you so much, {1}"    --衷心的感谢您，{1}
}
L.ROOM.SERVER_UPGRADE_MSG = "Server is updating, will be back soon..."    --服务器正在升级中，请稍候..
L.ROOM.USER_CRSH_POP_TITLE = "Bankrupt"   --破产了
L.ROOM.CHAT_MAIN_TAB_TEXT = {
  "Chat", 
  "Chat log"
}
L.ROOM.KICKED_BY_ADMIN_MSG = "You are kicked out by admin"
L.ROOM.KICKED_BY_USER_MSG = "You are kicked out by player {1}"
L.ROOM.TO_BE_KICKED_BY_USER_MSG = "Player {1} kick you out, you will return to lobby after this round"

T = {}
L.COMMON.CARD_TYPE = T
T1 = {}
T[1] = T1 
T[2] = "Flush"      --同花 
T[3] = "Straight"   --顺子 
T[4] = "Small Tri"    --小三公         
T[5] = "Str flush" --同花顺
T[6] = "Big Tri"    --大三公
T1[0] = "0 point"   --0点
T1[1] = "1 point"   --1点
T1[2] = "2 points"    --2点
T1[3] = "3 points"    --3点
T1[4] = "4 points"    --4点
T1[5] = "5 points"    --5点
T1[6] = "6 points"    --6点
T1[7] = "7 points"    --7点
T1[8] = "8 points"    --8点
T1[9] = "9 points"    --9点

T = {}
L.ROOM.SIT_DOWN_FAIL_MSG = T
T["IP_LIMIT"] = "You can't sit down with same IP address"   --坐下失败，同一IP不能坐下
T["SEAT_NOT_EMPTY"] = "The seat is occupied"          --坐下失败，该桌位已经有玩家坐下。
T["TOO_RICH"] = "You are too rich to be here!"          --坐下失败，这么多筹码还来新手场虐人？
T["TOO_POOL"] = "Not enough chips to stay"            --坐下失败，筹码不足无法进入非新手场房间。

L.STORE.NOT_SUPPORT_MSG = "Your account doesn't support payment"  --您的账户暂不支持支付
L.STORE.PURCHASE_SUCC_AND_DELIVERING = "Payment success, we're sending you goods" --已支付成功，正在进行发货，请稍候..
L.STORE.PURCHASE_CANCELED_MSG = "Payment canceled"    --支付已经取消
L.STORE.PURCHASE_FAILED_MSG = "Failed to pay"     --支付失败
L.STORE.DELIVERY_FAILED_MSG = "Network error"     --网络故障，系统将在您下次打开商城时重试
L.STORE.DELIVERY_SUCC_MSG = "Goods sent success!"   --发货成功，感谢您的购买。
L.STORE.TITLE_STORE = "Store"             --商城
L.STORE.TITLE_CHIP = "Chips"              --筹码
L.STORE.TITLE_PROP = "Items"              --互动道具
L.STORE.TITLE_MY_PROP = "My items"            --我的道具
L.STORE.TITLE_HISTORY = "Record"       --购买记录
L.STORE.RATE_CHIP = "1={1} chips"           --1={1}筹码
L.STORE.FORMAT_CHIP = "chip{1}"
L.STORE.REMAIN = "Remain: {1}{2}"           --剩余：
L.STORE.INTERACTIVE_PROP = "Items"            --互动道具
L.STORE.BUY = "Buy"                   --购买
L.STORE.USE = "Use"                   --使用
L.STORE.BUY_CHIPS = "Buy {1} chips"           --购买
L.STORE.RECORD_STATUS = {
  "Paid",       --已下单
  "Goods sent",     --已发货
  "Refunded"      --已退款
}
L.STORE.USE_SUCC_MSG = "Success to use items"   --道具使用成功
L.STORE.USE_FAIL_MSG = "Failed to use items"  --道具使用失败
L.STORE.BUSY_PURCHASING_MSG = "Payment processing, please wait..." --正在购买，请稍候..

-- login reward
L.LOGINREWARD.TITLE = "Everyday Bonus"    --连续登录奖励
L.LOGINREWARD.REWARD = "Today bonus: {1} chips"   --今日奖励{1}筹码 
L.LOGINREWARD.REWARD_ADD = "(Login by Facebook to get 50 000 chips)"  --(FB登录多加50000筹码)
L.LOGINREWARD.PROMPT = "The more days you login, the more bonus you can get!" --连续登录可获得更多奖励，最高每天{1}游戏币奖励
L.LOGINREWARD.DAYS = "{1} day"
L.LOGINREWARD.NO_REWARD = "You can get after you've got 3 register bonus"   --三次注册礼包领取完成后即可领取

-- USERINFO MODULE
L.USERINFO.MAX_MONEY_HISTORY = "Most capital: "  --历史最高资产: {1}
L.USERINFO.MAX_POT_HISTORY = "Best win-pot: "  --赢得最大奖池: {1}
L.USERINFO.WIN_RATE_HISTORY = "Winning rate: "  --历史胜率: {1}%
L.USERINFO.BEST_CARD_TYPE_HISTORY = "Best hands: " --历史最佳牌型:
L.USERINFO.MY_PROPS = "My items: "         --我的道具:
L.USERINFO.MY_PROPS_TIMES = "X{1} "
-- FRIEND MODULE
L.FRIEND.NO_FRIEND_TIP = "You have no buddies, invite to get more bonus!"   --暂无好友\n立即邀请好友可获得丰厚筹码赠送！
L.FRIEND.SEND_CHIP = "Send chips"     --赠送筹码
L.FRIEND.SEND_CHIP_WITH_NUM = "Send {1} chips"  --赠送{1}筹码
L.FRIEND.SEND_CHIP_SUCCESS = "Success to send {1} chips"    --您成功给好友赠送了{1}筹码
L.FRIEND.SEND_CHIP_TOO_POOR = "Not enough chips! Buy now?"    --您的筹码太少了，请去商城购买筹码后重试。
L.FRIEND.SEND_CHIP_COUNT_OUT = "You've sent chips to this buddy today"    --您今天已经给该好友赠送过筹码了，请明天再试。
L.FRIEND.INVITE_DESCRIPTION = "You can get {1} chips by each Facebook invitation. \nAfter your buddy login the game by FB, you will be rewarded {2} chips.\n\n The buddy you invited will get {3} FREE chips!"
--每邀请一位Facebook好友，可立即获赠500筹码。FaceBook好友接受邀请并成功登录游戏，您还可以额外获得50000筹码奖励，多劳多送。\n\n同时，被邀请的好友登录游戏后也可获赠150000筹码的注册礼包，赠送的筹码由系统免费发放。
L.FRIEND.INVITE_REWARD_TIP = "You've got {1} chips by invitations. To invite more friends and get more chips!"   --您已累计获得了{1}筹码的邀请奖励，多劳多得，天天都有哦！
L.FRIEND.INVITE_WITH_FB = "Facebook"    --Facebook\n邀请
L.FRIEND.INVITE_WITH_SMS = "SMS"      --短信邀请
L.FRIEND.INVITE_WITH_MAIL = "Email"       --邮件邀请
L.FRIEND.SELECT_ALL = "Select all"
L.FRIEND.DESELECT_ALL = "Select none"
L.FRIEND.SEND_INVITE = "Invite"       --邀请
L.FRIEND.INVITE_SUBJECT = "You'll love the excitement!"     --您绝对会喜欢
L.FRIEND.INVITE_CONTENT = "Hi, buddy, come and play this enjoyable and exciting poker games, 150 000 chips are FREE for you here! http://d3p32kmsr3feod.cloudfront.net/m/9kPoker.html"  --为您推荐一个既刺激又有趣的扑克游戏，我给你赠送了15万的筹码礼包，注册即可领取，快来和我一起玩吧！http:--goo.gl/gP4M0d
L.FRIEND.INVITE_CONTENT_OLDUSER = "我现在正在玩三公游戏，您有一段时间没登录了，快来和我一起玩吧！" -- trans it
L.FRIEND.INVITE_SELECT_TIP = "You've selected {1} buddies\nInvite to get {2} chips"  --您已选择了{1}位好友\n发送邀请即可获得{2}筹码的奖励
L.FRIEND.INVITE_FRIENDS_NUM_LIMIT_TIP = "50 at most each time!"   --一次邀请最多选取50位好友
L.FRIEND.INVITE_SUCC_TIP = "Success to invite, get {1} chips bonus!"  --成功发送了邀请，获得{1}筹码的奖励！
L.FRIEND.CANNOT_SEND_MAIL = "You don't have email account, set now?"        --您还没有设置邮箱账户，现在去设置吗？
L.FRIEND.CANNOT_SEND_SMS = "Sorry, SMS loading failed"      --对不起，无法调用发送短信功能！
L.FRIEND.MAIN_TAB_TEXT = {
  "My buddies",   --我的好友 
  "Invite"      --邀请好友
}
L.FRIEND.TOO_MANY_FRIENDS_TO_ADD_FRIEND_MSG = "You can have MAX 600 buddies, please delete some to add new!" --您的好友已达到600上限，请删除部分后重新添加

L.FRIEND.INVITE_OLD_USER_TIP = "您需要使用FB账号登陆才能发送邀请"  -- trans it

-- RANKING MODULE
L.RANKING.TRACE_PLAYER = "Track"    --追踪玩家
L.RANKING.MAIN_TAB_TEXT = {
  "Buddy",       --好友排行
  "Total"      --总排行榜
}
L.RANKING.SUB_TAB_TEXT_FRIEND = {
  "Rich", 
  "Level",
}
L.RANKING.SUB_TAB_TEXT_GLOBAL = {
  "Rich",      --筹码排行 
  "Level",       --等级排行
  "Winning"        --盈利排行
}

-- SETTING MODULE
L.SETTING.TITLE = "Set"     --设置
L.SETTING.NICK = "Nickname"   --昵称
L.SETTING.PLEASE_USE_FACEBOOK = '(使用Facebook登录奖励更多哦!)'
L.SETTING.LOGOUT = "Logout"   --登出
L.SETTING.SOUND_VIBRATE = "Sound & Shake" --声音和震动
L.SETTING.SOUND = "Sound"   --声音
L.SETTING.VIBRATE = "Shake"   --震动
L.SETTING.OTHER = "Other"   --其他
L.SETTING.AUTO_SIT = "Auto sit-down" --进入房间自动坐下
L.SETTING.AUTO_BUYIN = "Auto Buy-in"  --自动买入
L.SETTING.APP_STORE_GRADE = "Love this game? Give 5 stars now! Lol~" --喜欢我们，打分鼓励
L.SETTING.CHECK_VERSION = "Updates"   --检测更新
L.SETTING.CURRENT_VERSION = "Current version: V{1}"     --当前版本号：V{1}
L.SETTING.ABOUT = "About"       --关于
L.SETTING.FANS = "Fan page"    --官方粉丝页

L.HELP.TITLE = "Help"   --帮助
L.HELP.SUB_TAB_TEXT = {
  "Contact us",       --问题反馈
  "FAQ",            --常见问题
    "Guide",            --基本规则
    "Level guide"       --等级说明
}
L.HELP.FEED_BACK_HINT = "Please feel free to let us know your feedback and suggestions!"  --您在游戏中碰到的问题或者对游戏有任何意见或者建议，我们都欢迎您给我们反馈
L.HELP.NO_FEED_BACK = "No record here"              --您现在还没有反馈记录
L.HELP.FEED_BACK_SUCCESS = "Feedback sent!"           --反馈成功!
L.HELP.UPLOADING_PIC_MSG = "Picture uploading..."         --正在上传图片，请稍候..
L.HELP.MUST_INPUT_FEEDBACK_TEXT_MSG = "Input message here"    --请输入反馈内容
L.HELP.FAQ = {
  {
    "Where to get Free chips?",       
    "Login everyday, Invite friends, level up, join fans page activities!"      
  },
  {
    "How to buy chips?",
    {
      "Press the button",
      "on the amount of chips you want to buy"
    }
  },
  {
    "How to follow fan page?",
    "Click Like button in: https://www.facebook.com/9kpoker\n"
  },
  {
    "How to deal?",
    "After 2 players sit down, the dealer will deal 2 cards."
  },
  {
    "How to logout",
    "Just click logout button in the lobby"
  },
  {
    "Change profile picture",
    "Press your photo and then press change button!"
  }
}

L.HELP.RULE = {
  {
    "Terms",
    ""
  },
  {
    "Rules",
    "The best hand to win: \n(A) Hands rank: Big Triplet>Straight Flush>Small Triplet>Straight>Flush>High cards\n(B)Suit rank: Spades>Hearts>Diamonds>Clubs\n(C)Cards rank: A(biggest)-K-Q-J-10-9-8-7-6-5-4-3-2\n(D)If all remaining players bet by high-cards, the one with highest win\n(E)High-card compared by points: A-9 has value of itself, 10-K has 0 point, ONLY 1st digit will be calculated for points"
  },
  {
    "Bet",
    "Starts at winner of last round, go clock-wisely. Jackpot will be shared as main pot and edge pot"
  },
  {
    "Hands Ranking",
    "Big Triplet>Straight Flush>Small Triplet>Straight>High cards"
  },
}
L.HELP.LEVEL = {
  {
    "Play to get exp",
    "Winner will get 2 exp, loser will get only 1 exp"
  },
  {
    "Level list",
    {
      {
        "Lv", "Title", "EXP required", "Reward"
      },
      {
        "LV1", "Newbie", "0", ""
      },
      {
        "LV2", "Beginner", "25", "10,000 chips"
      },
      {
        "LV3", "Fish", "80", "20,000 chips"
      },
      {
        "LV4", "Fan club", "240", "30,000 chips"
      },
      {
        "LV5", "Professional club", "520", "50,000 chips, 10 items"
      },
      {
        "LV6", "Champion of club", "1,249", " 50,000 chips"
      },
      {
        "LV7", "Champion in town", "2,499", "50,000 chips"
      },
      {
        "LV8", "Tiny Shark", "4,277", "50,000 chips, 15 items"
      },
      {
        "LV9", "Champion in down town", "7,198", "50,000 chips"
      },
      {
        "LV10", "Skilful Shark", "10,990", "200,000 chips, 30 items"
      },
      {
        "LV11", "Champion in district", "16,003", "200,000 chips,  20 items"
      },
      {
        "LV12", "Powerful Shark", "22,466", "200,000 chips"
      },
      {
        "LV13", "Champion in city", "30,658", "200,000 chips"
      },
      {
        "LV14", "Tigher Shark", "40,931", "200,000 chips"
      },
      {
        "LV15", "Tiny Whale", "53,748", "500,000 chips"
      },
      {
        "LV16", "Champion in Macau", "69,744", "500,000 chips,  30 items"
      },
      {
        "LV17", "Skilful Whale", "89,816", "500,000 chips"
      },
      {
        "LV18", "Professional Whale", "115,264", "200,000 chips,  items"
      },
      {
        "LV19", "Monster Whale", "148,000", "500,000 chips"
      },
      {
        "LV20", "Warrior Whale", "190,877", "1,000,000 chips, 60 items"
      },
      {
        "LV21", "Pacific Champion", "248,186", "1,000,000 chips"
      },
      {
        "LV22", "Whale Bronze", "326,416", "1,000,000 chips"
      },
      {
        "LV23", "Whale Silver", "435,424", "1,000,000 chips, 60 items"
      },
      {
        "LV24", "Whale Gold", "590,214", "1,000,000  chips"
      },
      {
        "LV25", "Whale Diamond", "813,671", "5,000,000 chips, 100 items"
      },
      {
        "LV26", "3-Cards Bronze", "1,160,000", "5,000,000 chips, 200 items"
      },
      {
        "LV27", "3-Cards Silver", "1,785,000", "5,000,000 chips, 300 items"
      },
      {
        "LV28", "3-Cards Gold", "2,432,232", "8,000,000 chips, 400 items"
      },
      {
        "LV29", "3-Cards Diamond", "3,204,464", "10,000,000 chips, 500 items"
      },
      {
        "LV30", "3-Cards King", "4,146,696", "10,000,000 chips, 600 items"
      }
    }
  }
}

L.UPDATE.TITLE = "New version detected"   --发现新版本
L.UPDATE.DO_LATER = "Later"         --以后再说
L.UPDATE.UPDATE_NOW = "Update now"      --立即升级
L.UPDATE.HAD_UPDATED = "You are play the newest version"    --您已经安装了最新版本

L.ABOUT.TITLE = "About"         --关于
L.ABOUT.UID = "User ID: {1}"      --当前玩家ID: {1}
L.ABOUT.VERSION = "Version：V{1}"    --版本号：V{1}
L.ABOUT.FANS = "Fan page"      --官方粉丝页：
L.ABOUT.FANS_URL = "https://www.facebook.com/9kpoker"
L.ABOUT.FANS_OPEN = "http://d25t7ht5vi1l2.cloudfront.net/m/goFans.html?l=en"
L.ABOUT.SERVICE = "Privacy & Service Clauses"   --服务条款与隐私策略
L.ABOUT.COPY_RIGHT = "Copyright © 2014 Boomegg Interactive Co., Ltd..All Rights Reserved."

L.DAILY_TASK.GET_REWARD = "Claim Bonus"   --领取奖励
L.DAILY_TASK.HAD_FINISH = "Done"        --已完成
L.DAILY_TASK.COMPLETE_REWARD = "Congrats! Mission {1} complete!"    --恭喜你完成了任务：{1}
L.DAILY_TASK.CHIP_REWARD = "Bonus: {1} chips"             --奖励{1}筹码

-- count down box
L.COUNTDOWNBOX.TITLE = "Clock bonus"      --倒计时宝箱
L.COUNTDOWNBOX.SITDOWN = "Sit down to let clock count"    --坐下才可以继续计时。
L.COUNTDOWNBOX.FINISHED = "You've got all clock bonus today, you can get tomorrow!"   --您今天的宝箱已经全部领取，明天还有哦。
L.COUNTDOWNBOX.NEEDTIME = "Play {1}m {2}s to get {3}"     --再玩{1}分{2}秒，您将获得{3}。
L.COUNTDOWNBOX.REWARD = "Congrats, you get {1} clock bonus"     --恭喜您获得宝箱奖励{1}。

L.USERINFO.UPLOAD_PIC_NO_SDCARD = "SD card is required to upload photo"   --没有安装SD卡，无法使用头像上传功能
L.USERINFO.UPLOAD_PIC_PICK_IMG_FAIL = "Failed to get image"         --获取图像失败
L.USERINFO.UPLOAD_PIC_UPLOAD_FAIL = "Failed to upload, pls try again later" --上传头像失败，请稍后重试
L.USERINFO.UPLOAD_PIC_IS_UPLOADING = "Uploading, please wait..."      --正在上传头像，请稍候...
L.USERINFO.UPLOAD_PIC_UPLOAD_SUCCESS = "Success to upload"          --上传头像成功
L.USERINFO.EXPERIENCE_VALUE = "{1}/{2}" --经验值

L.NEWESTACT.NO_ACT = "N/A"     --暂无活动
L.NEWESTACT.TITLE = "News"    --最新活动
L.NEWESTACT.LOADING = "Loading..."      --加载中...

L.FEED.SHARE_SUCCESS = "Success to share"   --分享成功
L.FEED.SHARE_FAILED = "Failed to share"     --分享失败
L.FEED.LOGIN_REWARD = {
  name = "It's awesome! I get {1} bonus! Come and play with me!",          --太棒了!我在三公领取了{1}筹码的奖励，快来和我一起玩吧！
  caption = "Login everyday to get more bonus!",    --天天登录筹码送不停
  link = "http://d3p32kmsr3feod.cloudfront.net/m/9kPoker.html",
  picture = "http://pclptl9k02-static.boyaagame.com/static/nineke/nineke/images/feed/LOGIN_REWARD2.jpg",
  message = "",
}
L.FEED.EXCHANGE_CODE = {
  name = "I succeed to get {1} by redeem, Come to play with me!",       --我用三公粉丝页的兑换码换到了{1}的奖励，快来和我一起玩吧！
  caption = "Fans bonus everyday!",   --粉丝奖励兑换有礼
  link = "http://d3p32kmsr3feod.cloudfront.net/m/9kPoker.html",
  picture = "http://pclptl9k02-static.boyaagame.com/static/nineke/nineke/images/feed/EXCHANGE_CODE1.jpg",
  message = "",
}
L.FEED.WHEEL_ACT = {
  name = "Play Lucky Wheel with me here! Big bonus everyday!",      --快来和我一起玩开心转转转吧，每天登录就有三次机会！
  caption = "Spin! Spin! Spin!!! 100% to hit prize!",                     --开心转转转100%中奖
  link = "http://d3p32kmsr3feod.cloudfront.net/m/9kPoker.html",
  picture = "http://pclptl9k02-static.boyaagame.com/static/nineke/nineke/images/feed/WHEEL_ACT1.jpg",
  message = "",
}
L.FEED.WHEEL_REWARD = {
  name = "I win {1} in 3-Cards Lucky Wheel, come and play with me!",  --我在三公的幸运转转转获得了{1}奖励，快来和我一起玩吧！
  caption = "Spin! Spin! Spin!!! 100% to hit prize!",           --开心转转转100%中奖
  link = "http://d3p32kmsr3feod.cloudfront.net/m/9kPoker.html",
  picture = "http://pclptl9k02-static.boyaagame.com/static/nineke/nineke/images/feed/WHEEL_REWARD1.jpg",
  message = "",
}
L.FEED.UPGRADE_REWARD = {
  name = "I've reached Level {1} in 9K Poker and get {2} bonus!",
  caption = "Level-up bonus",
  link = "http://d3p32kmsr3feod.cloudfront.net/m/9kPoker.html",
  picture = "http://pclptl9k02-static.boyaagame.com/static/nineke/nineke/images/feed/levelUp/level{1}.png",
  message = "",
}
L.FEED.GIFTBOX_OPEN = {
    name = "太棒了，我刚刚在三公游戏中打开了神秘礼盒，获得了{1}. 你也赶快来开启吧",
    caption = "邀请开神秘礼盒",
    link = "http://goo.gl/IvRr4z",
    picture = "http://pclptl9k02-static.boyaagame.com/static/nineke/nineke/images/feed/giftbox_{1}.png",
    message = "",
}
L.FEED.MATCH_COMPLETE = {
    name = "我在三公{1}中获得第{2}名，赶快来一起玩吧！",
    caption = "一起来比赛！",
    link = "http://goo.gl/IvRr4z",
    picture = "http://pclptl9k02-static.boyaagame.com/static/nineke/nineke/images/feed/LOGIN_REWARD1.jpg",
    message = "",
}

-- message
L.MESSAGE.TAB_TEXT = {
  "Inbox",      --好友消息 
  "System"      --系统消息
}
L.MESSAGE.EMPTY_PROMPT = "No message here"    --您现在没有消息记录

--奖励兑换码
L.ECODE.TITLE = "Redeem Code"     --奖励兑换 
L.ECODE.EDITDEFAULT = "Please input 6-bit redeem code!"   --请输入6位数字奖励兑换码
L.ECODE.DESC = "Follow fans page to get more chips by Redeem code! We will have more exciting activities! \n\nFan page:\nhttps://www.facebook.com/9kpoker "
--关注粉丝页可免费领取奖励兑换码,我们还会不定期在官方粉丝页推出各种精彩活动,谢谢关注。\n\n粉丝页地址
L.ECODE.EXCHANGE = "Redeem"     --兑  奖
L.ECODE.SUCCESS = "Congrats, success to redeem!\nYou get {1}"       --恭喜您，兑奖成功！\n您获得了{1}
L.ECODE.ERROR_FAILED = "Wrong redeem code!"       --兑奖失败，请确认您的兑换码是否输入正确！
L.ECODE.ERROR_INVALID="Redeem code expired!"      --兑奖失败，您的兑换码已经失效。
L.ECODE.ERROR_USED = "One use for each redeem.\nYou've use {1} times" --兑奖失败，每个兑换码只能兑换一次。\n您已经兑换到了{1}
L.ECODE.ERROR_END= "No more bonus here! Be earlier next time!"    --领取失败，本次奖励已经全部领光了，关注我们下次早点来哦
L.ECODE.FANS = "Follow fan page"   --关注粉丝页

--大转盘
L.WHEEL.SHARE = "Share"       --分享
L.WHEEL.REMAIN_COUNT = "Remain spin:  "   --剩余抽奖数
L.WHEEL.TIME = " "
L.WHEEL.DESC1 = "Everyday you have 3 spins!"  --每天登录即可免费获得3次抽奖机会
L.WHEEL.DESC2_PRE = ""         --每次
L.WHEEL.DESC2_POST = "Hit prize!    "       --中奖
L.WHEEL.DESC3 = "10 million chips at most!"       --绝不落空，最高可赢取一千万筹码。
L.WHEEL.DESC4 = "Start NOW, click 'Spin' button!"     --立即开始吧，点击开始抽奖按钮！
L.WHEEL.PLAY = "Spin"        --开始\n抽奖
L.WHEEL.REWARD = {
  "Congrats!",        --中大奖了！
  "You get {1} !"     --恭喜您，中了{1}奖励
}


--银行
L.BANK.BANK_BUTTON_LABEL = "Private bank"   --银行
L.BANK.BANK_GIFT_LABEL = "My gifts"       --我的礼物
L.BANK.BANK_DROP_LABEL = "My items"       --我的道具
L.BANK.BANK_TOTAL_CHIP_LABEL = "Capital in bank"  --银行内资产
L.BANK.SAVE_BUTTON_LABEL = "Deposit"      --存钱
L.BANK.DRAW_BUTTON_LABEL = "Withdraw"     --取钱
L.BANK.CANCEL_PASSWORD_SUCCESS_TOP_TIP = "Password canceled"    --取消密码成功
L.BANK.CANCEL_PASSWORD_FAIL_TOP_TIP = "Failed to cancel password" --取消密码失败
L.BANK.EMPYT_CHIP_NUMBER_TOP_TIP = "Input number"         --请输入金额
L.BANK.USE_BANK_NO_VIP_TOP_TIP = "Only VIP/Lv 7+ players can use bank"    --你不是VIP用户不能使用保险箱功能
L.BANK.USE_BANK_SAVE_CHIP_SUCCESS_TOP_TIP = "Chips in bank!"      --存钱成功
L.BANK.USE_BANK_SAVE_CHIP_FAIL_TOP_TIP = "Failed to deposit"      --存钱失败
L.BANK.USE_BANK_DRAW_CHIP_SUCCESS_TOP_TIP = "Withdraw success!"     --取钱成功
L.BANK.USE_BANK_DRAW_CHIP_FAIL_TOP_TIP = "Withdraw failed!"       --取钱失败
L.BANK.BANK_POPUP_TOP_TITIE = "Private bank"              --个人银行
L.BANK.BANK_INPUT_TEXT_DEFAULT_LABEL = "Input password"         --请输入密码
L.BANK.BANK_CONFIRM_INPUT_TEXT_DEFAULT_LABEL = "Input password again" --请再次输入密码
L.BANK.BANK_INPUT_PASSWORD_ERROR = "Wrong input, please try again!"           --你输入的密码有误，请从新输入
L.BANK.BANK_SET_PASSWORD_TOP_TITLE = "Set password"             --设置密码
L.BANK.BANK_SET_PASSWORD_SUCCESS_TOP_TIP = "Password set!"        --设置密码成功
L.BANK.BANK_SET_PASSWORD_FAIL_TOP_TIP = "Failed to set password!"   --设置密码失败
L.BANK.BANK_LEVELS_DID_NOT_REACH = "Only VIP/Lv 7+ players can use bank"    --你的等级没有达到七级，不能使用保险箱
L.STORE.NO_PRODUCT_HINT = "Out of stock!"
L.STORE.NO_BUY_HISTORY_HINT = "No purchasing history..."
L.STORE.MY_CHIPS = "My capital {1}"
L.USERINFO.INFO_RANKING = "Rank:" 
L.BANK.BANK_CANCEL_OR_SETING_PASSWORD = "Set password"
L.BANK.BANK_CACEL_PASSWORD_BUTTON_LABEL = "Remove password"
L.BANK.BANK_SETTING_PASSWORD_BUTTON_LABEL = "Set password"
L.BANK.BANK_LABA_LABEL = "Big speaker"
L.BANK.BANK_FORGET_PASSWORD_BUTTON_LABEL = "Forget password"
L.BANK.BANK_FORGET_PASSWORD_FEEDBACK = "Please contact admin if you forget password"
L.ROOM.SERVER_STOPPED_MSG = "Sorry, under maintenance, please wait..."

--老虎机
L.SLOT.NOT_ENOUGH_MONEY = "Not enough chips for slot"
L.SLOT.SYSTEM_ERROR = "System error, failed to buy-in slot"
L.SLOT.PLAY_WIN = "You win {1} chips"
L.SLOT.TOP_PRIZE = "Player {1} win {2} chips by playing slot"
L.SLOT.FLASHBAR_TIP = "TOP prize: {1}"
L.SLOT.FLASHBAR_WIN = "You win {1}"
L.SLOT.AUTO = "Auto"

--升级弹框
L.UPGRADE.OPEN = "Open"
L.UPGRADE.SHARE = "Share"
L.UPGRADE.GET_REWARD = "Claim {1}"

--新手教程
L.TUTORIAL.HOW_TO_PLAY = "How to play?"
L.TUTORIAL.VIEW1_TITLE = "Enter Room"
L.TUTORIAL.VIEW2_TITLE = "Play Process"
L.TUTORIAL.VIEW3_TITLE = "Hand Compare"
L.TUTORIAL.VIEW4_TITLE = "Hand Compare"


-- 礼物
L.GIFT.SET_SELF_BUTTON_LABEL = "Set"
L.GIFT.BUY_TO_TABLE_GIFT_BUTTON_LABEL = "Send to allx{1}"
L.GIFT.CURRENT_SELECT_GIFT_BUTTON_LABEL = "Current gift"
L.GIFT.PRESENT_GIFT_BUTTON_LABEL = "Send"
L.GIFT.DATA_LABEL = "Day"
L.GIFT.SELECT_EMPTY_GIFT_TOP_TIP = "Please select a gift"
L.GIFT.BUY_GIFT_SUCCESS_TOP_TIP = "Success to buy!"
L.GIFT.BUY_GIFT_FAIL_TOP_TIP = "Failed to buy!"
L.GIFT.SET_GIFT_SUCCESS_TOP_TIP = "Gift is set"
L.GIFT.SET_GIFT_FAIL_TOP_TIP = "Failed to set gift"
L.GIFT.PRESENT_GIFT_SUCCESS_TOP_TIP = "Success to send!"
L.GIFT.PRESENT_GIFT_FAIL_TOP_TIP = "Failed to send"
L.GIFT.PRESENT_TABLE_GIFT_SUCCESS_TOP_TIP = "Success to send"
L.GIFT.PRESENT_TABLE_GIFT_FAIL_TOP_TIP = "Failed to send"
L.GIFT.NO_GIFT_TIP = "No gift"
L.GIFT.MY_GIFT_MESSAGE_PROMPT_LABEL = "Tap to show gift"


L.GIFT.SUB_TAB_TEXT_SHOP_GIFT = {
  "Hot", 
  "HQ",
  "Celebr",
  "Other"
}
L.GIFT.SUB_TAB_TEXT_MY_GIFT = {
  "Buy for myself", 
  "Send to buddy"
}

L.GIFT.MAIN_TAB_TEXT = {
  "Gift on sale", 
  "My gift"
} 

-- 破产
L.CRASH.PROMPT_LABEL = "You get {1} chips bankrupt aid fund. Good luck！"
L.CRASH.THIRD_TIME_LABEL = "You get the last bankrupt aid fund: {1} chips and big discount 1 time. Don't miss chance to win back!"
L.CRASH.OTHER_TIME_LABEL = "No more bankrupt aid funds. You can purchase chips in store or login tomorrow to get free chips"


-- Facebook登录引导
L.FBGUIDE.TITLE              = '推荐您使用Facebook帐号登录!'
L.FBGUIDE.LINE_1             = '1. 每日连续登录比游客帐号多领5万奖励!'
L.FBGUIDE.LINE_2             = '2. 使用Facebook邀请好友功能更可获得海量游戏币奖励!'
L.FBGUIDE.SWITCH_FB_BTN_TEXT = '切换Facebook登录'
-- 比赛场
L.MATCH.AWARDDLGDESC = "{1},恭喜您在{2}中獲得第{3}名({4}/{5})！加油！{6}"
L.MATCH.AWARDDLGBACK = "返回"
L.MATCH.AWARDDLGSHARE = "分享"
L.MATCH.AWARDDLGONEMORE = "再来一次"
L.MATCH.AWARDDLGWORD = "獲得獎勵："
L.MATCH.RANKWORD = "排名："
L.MATCH.RANKINFO = "底注：{1}  涨盲: "
L.MATCH.STARTINGTIP = "比赛将在15秒后开始，等待其他玩家入场"
L.MATCH.WAITOTHERROOMTIP = "正在等待其他桌子结束...请稍等..."

L.MATCH.NOTENOUGHGAMECOUPON = "对不起，您的比赛券不足"
L.MATCH.NOTENOUGHGOLDCOUPON = "对不起，您的金券不足"
L.MATCH.REGISTERSUCC = "报名成功"
L.MATCH.REGISTERFAIL = "报名失败"
L.MATCH.UNREGISTERSUCC = "取消报名成功"
L.MATCH.UNREGISTERFAIL = "取消报名失败"

L.MATCH.SCORE = "积分"
L.MATCH.GOLDCOUPON = "金券"
L.MATCH.GAMECOUPON = "比赛券"

L.MATCH.MATCHTEST = "比赛正在灰度测试阶段，暂时未全部开放，敬请期待~"
L.MATCH.MATCHFREE = "免费"
L.MATCH.MATCHJOINCONDITION = "入场条件："
L.MATCH.MATCHRULE = "比赛规则"
L.MATCH.REGISTER = "报名"
L.MATCH.CANCELREGISTER = "取消报名"

L.MATCH.MATCHRANK = "名次"
L.MATCH.MATCHAWARD = "比赛奖励"
L.MATCH.MATCHREGNUM = "已经报名人数：{1}"

L.MATCH.JOINMATCHTIPS = "您报名参赛的比赛已经开始，是否现在进入房间进行比赛"
L.MATCH.JOINMATCHFAILTIPS = "比赛已经开始，您来晚了，下次请记得早点来哦"
-- 积分兑换奖励
L.SCOREMARKET.TAB1 = "兑换奖品"
L.SCOREMARKET.TAB2 = "兑换记录"
L.SCOREMARKET.SUBTAB1 = "游戏道具"
L.SCOREMARKET.SUBTAB2 = "Line Coins"
L.SCOREMARKET.SUBTAB3 = "Easypay"
L.SCOREMARKET.SUBTAB4 = "实物"
L.SCOREMARKET.MYSCORE = "我的积分："
L.SCOREMARKET.COMMINGTIPS = "暂未开放，敬请期待..."
L.SCOREMARKET.NORECORD = "暂无兑奖记录..."
L.SCOREMARKET.LEFTWORD = "剩余数量：{1}"
L.SCOREMARKET.NOLEFT = "已经抢光"
L.SCOREMARKET.RECHANGENUM = "{1} 积分"
L.SCOREMARKET.NOTENOUGHTIPS = "对不起您的积分不足"
return lang
