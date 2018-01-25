-- module lang_vn
-- 越南语资源
-- note: 发布版本前需要认真审核一遍翻译,尤其是新增的

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
L.GIFT = {}
L.CRASH = {}
L.FBGUIDE = {} -- facebook登录引导
L.MATCH = {} -- 比赛场
L.SCOREMARKET  = {} -- 积分兑换奖励

-- COMMON MODULE
L.COMMON.LEVEL = "Lv.{1}"
L.COMMON.ASSETS = "${1}"
L.COMMON.CONFIRM = "Xác nhận"--确定
L.COMMON.CANCEL = "Hủy bỏ"--取消
L.COMMON.AGREE = "Yes"--同意
L.COMMON.REJECT = "No"--拒绝
L.COMMON.RETRY = "thử lại"--重试
L.COMMON.NOTICE = "Nhắc nhở"--温馨提示
L.COMMON.BUY = "mua"--购买
L.COMMON.SEND = "gửi"--发送
L.COMMON.BAD_NETWORK = "mạng yếu"--网络不给力
L.COMMON.REQUEST_DATA_FAIL = "mạng yếu, vui lòng kiểm tra lại mạng hoặc thử lại sau!"--网络不给力，获取数据失败，请重试！
L.COMMON.ROOM_FULL = "Bây giờ khán giả của phòng quá nhiều,bạn vui lòng đổi phòng khác!"--现在该房间旁观人数过多，请换一个房间
L.COMMON.USER_BANNED = "Tài khoản của bạn bị khóa, vui lòng phản hồi hoặc liên lạc với admin!"--您的账户被冻结了，请你反馈或联系管理员
L.COMMON.MAX_MONEY_HISTORY = "Tài sản cao nhất trong lịch sử: {1} "--历史最高资产: {1}
L.COMMON.MAX_POT_HISTORY = "Thắng được nhiều nhất: {1}"--赢得最大奖池: {1}
L.COMMON.WIN_RATE_HISTORY = "Tỷ lệ thắng trong : {1}%"--历史胜率: {1}%
L.COMMON.BEST_CARD_TYPE_HISTORY = "kiểu bài mạnh nhất:"--历史最佳牌型:
L.COMMON.LEVEL_UP_TIP = "chúc mừng bạn đã thăng cấp đến cấp{1}, nhận thưởng:{2} "--恭喜你升到{1}级, 获得奖励:{2}
L.COMMON.MY_PROPS = "Đạo cụ của tôi:"--我的道具:
L.COMMON.SHARE = "chia sẻ"--分  享
L.COMMON.GET_REWARD = "Nhận"--领取奖励

L.COMMON.BUY_CHAIP = "mua xu"---购买筹码

L.COMMON.LOGOUT = "đăng xuất"--登出
L.COMMON.QUIT_DIALOG_TITLE = "xác nhận thoát ra"--确认退出
L.COMMON.BINDFHONE = "ยินดีด้วยค่ะ คุณผูกเบอร์สำเร็จ ใช้เบอร์นี้ลงทะเบียน/ล็อกอินเวปหลักของเรา.เติมชิปรับคะแนนสะสมฟรี (10 คะแนน=1 บาท) ของดีรอแลกฟรี!"--绑定手机
L.COMMON.NULLPHONE = "จำเป็นต้องกรอกเบอร์มือถือ"
L.COMMON.NULLKEY = "จำเป็นต้องกรอกรหัสยืนยัน"
L.COMMON.DESSHOP = "ผูกเบอร์มือถือเสร็จแล้วไปลงทะเบียนในเวปหลัก เติมชิปรับคะแนนสะสมฟรี 10 คะแนน=1 บาท ยังไม่พอ รางวัลพิเศษเพียบ รอคุณมารับกลับบ้านฟรี!ผูกเบอร์มือถือรับรางวัลชิปฟรี!"

L.COMMON.QUIT_DIALOG_MSG = "Bạn có xác nhận thoát ra game ko? game quý bạn lắm đấy!"--真的确认退出游戏吗？淫家好舍不得滴啦~\\(≧▽≦)/~
L.COMMON.QUIT_DIALOG_CONFIRM = "chịu đau thoát ra"--忍痛退出
L.COMMON.QUIT_DIALOG_CANCEL = "nhấn sai"--我点错了
L.COMMON.LOGOUT_DIALOG_TITLE = "xác nhận thoát ra"--确认退出登录
L.COMMON.LOGOUT_DIALOG_MSG = "Bạn có thật muốn thoát ra ko?"--真的要退出登录吗？
L.COMMON.NOT_ENOUGH_MONEY_TO_PLAY_NOW_MSG = "Xu của bạn ko đủ để chơi nữa, bạn vui lòng bổ sung xu và thử lại sau!"--您的筹码不足最小买入{1}，您需要补充筹码后重试.
L.COMMON.USER_SILENCED_MSG = "Bạn đã bị khóa chat, vui lòng phản hồi lại cho admin" --您的帐号已被禁言，您可以在帮助-反馈里联系管理员处理

-- LOGIN MODULE
L.LOGIN.FB_LOGIN = "Facebook\nđăng nhập"--FB账户登录
L.LOGIN.GU_LOGIN = "Du khách\nđăng nhập"--游客账户登录
L.LOGIN.USE_DEVICE_NAME_TIP = "Bạn có cho phép chúng tôi sử dụng tên thiết bị của bạn làm tên game ko?"--您是否允许我们使用您的设备名称\n作为游客账户的昵称并上传到游戏服务器？
L.LOGIN.REWARD_SUCCEED = "Nhận thưởng thành công"--领取奖励成功
L.LOGIN.REWARD_FAIL = "Nhận thưởng thất bại"--领取失败
L.LOGIN.REIGSTER_REWARD_FIRST_DAY = "ngày 1"--第一天
L.LOGIN.REGISTER_REWARD_SECOND_DAY = "ngày 2"--第二天
L.LOGIN.REGISTER_REWARD_THIRD_DAY = "ngày 3"--第三天
L.LOGIN.LOGINING_MSG = "đang đăng nhập trò chơi"--正在登录游戏...
L.LOGIN.CANCELLED_MSG = "đăng nhập đã hủy bỏ"--登录已经取消
L.LOGIN.FEED_BACK_HINT = "Vui lòng cung cấp thông tin cụ thể của bạn, ví dụ như đăng nhập bằng cách nào、UID game vv"
L.LOGIN.FEED_BACK_TITLE = "phản hồi"
L.LOGIN.DOUBLE_LOGIN_MSG = "Đăng nhập tài khoản của bạn ở những nơi khác"   -- 帐号在其它地方登录

-- HALL MODULE
L.HALL.USER_ONLINE = "Số người online:{1}"--当前在线人数{1}
L.HALL.INVITE_FRIEND = "Rủ bạn bè FB+{1}"--邀请FB好友+50000
L.HALL.DAILY_BONUS = "Thưởng đăng nhập"--登录奖励                                         
L.HALL.DAILY_MISSION = "Nhiệm vụ"--每日任务
L.HALL.NEWEST_ACTIVITY = "Sự kiện"--最新活动
L.HALL.LUCKY_WHEEL = "ĐQMM"--幸运转转转
L.HALL.NOTOPEN="Tạm thời chưa ra mắt..."--暂未开放 敬请期待
L.HALL.STORE_BTN_TEXT = "Shop"--商城
L.HALL.FRIEND_BTN_TEXT = "Bạn bè"--好友
L.HALL.RANKING_BTN_TEXT = "Xếp hạng"--排行榜
L.HALL.MAX_BUY_IN_TEXT = "tối đa{1}"--最大买入{1}
L.HALL.PRE_CALL_TEXT = "cược"
L.HALL.ROOM_LEVEL_TEXT = {
    "sân sơ cấp", --初级场
    "sân trung cấp",--中级场 
    "sân cao cấp"--高级场
}
L.HALL.PLAYER_LIMIT_TEXT = {
    "9\nMax", 
    "5\nMax"
}
L.HALL.SEARCH_ROOM_INPUT_ROOM_NUMBER_ERROR = "Số phòng bạn nhập ko đúng"
L.HALL.SEARCH_ROOM_INPUT_ROOM_NUMBER_EMPTY = "Số phòng ko thể để trắng"
L.HALL.SEARCH_ROOM_NUMBER_IS_WRONG= "Số phòng bạn nhập ko đúng"
L.HALL.SEARCH_ROOM_INPUT_CORRECT_ROOM_NUMBER= "Xin nhập vào 5~6 chữ số phòng"

-- ROOM MODULE
L.ROOM.OPR_TYPE = {
    "Xem bài", --看  牌
    "Bỏ bài", --弃  牌
    "Theo cược", --跟  注
    "Thêm cược",--加  注 
}
L.ROOM.MY_MONEY = "My money {1} {2}"
L.ROOM.INFO_UID = "UID {1}"
L.ROOM.INFO_LEVEL = "Lv.{1}"
L.ROOM.INFO_RANKING = "xếp hạng:  {1}" --排名:  {1}
L.ROOM.INFO_WIN_RATE = "tỷ lệ thắng: {1}%"--胜率:  {1}%
L.ROOM.INFO_SEND_CHIPS = "tặng xu"--赠送筹码
L.ROOM.ADD_FRIEND = "kết bạn" --加为好友
L.ROOM.DEL_FRIEND = "xóa bạn"--删除好友
L.ROOM.ADD_FRIEND_FAILED_MSG = "thêm bạn thất bại"--添加好友失败
L.ROOM.DELE_FRIEND_SUCCESS_MSG = "xóa bạn thành công"--删除好友成功
L.ROOM.DELE_FRIEND_FAIL_MSG = "xóa bạn thất bại"--删除好友失败
L.ROOM.SEND_CHIP_NOT_NORMAL_ROOM_MSG = "sân phổ thông mới có thể tặng xu được"---只有普通场才可以赠送筹码
L.ROOM.SEND_CHIP_NOT_IN_SEAT = "ngồi xuống mới có thể tặng xu được"--坐下才可以赠送筹码
L.ROOM.SEND_CHIP_NOT_ENOUGH_CHIPS = "xu ko đủ"--钱不够啊
L.ROOM.SEND_CHIP_TOO_OFTEN = "số lần tặng quá nhiều"--赠送的太频繁了
L.ROOM.SEND_CHIP_TOO_MANY = "số lượng tặng quá nhiều"--赠送的太多了
L.ROOM.SEND_HDDJ_IN_MATCH_ROOM_MSG = "sân thi đấu ko thể dùng đcgl"--比赛场不能发送互动道具
L.ROOM.SEND_HDDJ_NOT_IN_SEAT = "ngồi xuống mới có thể dùng được đcgl"--坐下才能发送互动道具
L.ROOM.SEND_HDDJ_NOT_ENOUGH = "đcgl của bạn đã hết, mau đi shop mua đi!"--您的互动道具数量不足，赶快去商城购买吧
L.ROOM.SEND_EXPRESSION_MUST_BE_IN_SEAT = "ngồi xuống mới dùng biểu tượng được"--坐下才可以发送表情
L.ROOM.CHAT_FORMAT = "{1}: {2}"
L.ROOM.ROOM_INFO = "{1} {2}/cược{3}"
L.ROOM.NO_BIG_LA_BA = "Tạm thời chưa có loa, mua ngay ko?"
L.ROOM.SEND_BIG_LABA_MESSAGE_FAIL = "Gửi tin loa thất bại" 
L.ROOM.NOT_GIVE_CHIP_MSG = "比赛场不可以赠送游戏币哦"


L.ROOM.USER_CARSH_REWARD_DESC = "Bạn nhận được hỗ trợ phá sản{1} xu, chỉ có 3 lần cơ hội thôi nhé! "--您获得了{1}筹码的破产补助，终身只有三次机会获得，且用且珍惜
L.ROOM.USER_CARSH_BUY_CHIP_DESC = "Bạn cũng có thể mua ngay."--您也可以立即购买，输赢只是转瞬的事
L.ROOM.USER_CARSH_REWARD_COMPLETE_DESC = "Bạn đã dùng hết 3 lần cơ hội hỗ trợ phá sản, bây giờ bạn có thể đi shop mua xu, mỗi ngày đăng nhập cũng có xu miền phí!"--您已经领完所有破产补助，您可以去商城购买筹码，每天登录还有免费筹码赠送哦！
L.ROOM.USER_CARSH_REWARD_COMPLETE_BUY_CHIP_DESC = "Thắng thua là việc bình thường, ko nản lòng, mua xu ngay để chiến luôn!"--输赢乃兵家常事，不要灰心，立即购买筹码，重整旗鼓。

L.ROOM.WAIT_NEXT_ROUND = "vui lòng chờ đợi ván sau"--请等待下一局开始
L.ROOM.LOGIN_ROOM_FAIL_MSG = "vào phòng thất bại"--登录房间失败

L.ROOM.BUYIN_ALL_POT= "cả gà"--全部奖池
L.ROOM.BUYIN_3QUOT_POT = "3/4 gà"--3/4奖池
L.ROOM.BUYIN_HALF_POT = "1/2 gà"--1/2奖池
L.ROOM.BUYIN_TRIPLE = "thêm 3 lần"--3倍反加


L.ROOM.CHAT_TAB_SHORTCUT = "Chat ngay"--快捷聊天
L.ROOM.CHAT_TAB_HISTORY = "Lịch sử chat"--聊天记录
L.ROOM.INPUT_HINT_MSG = "Nhập vào nội dung"--点击输入聊天内容
L.ROOM.CHAT_SHORTCUT = {
  "chào các bạn",--大家好!
  "Mình là lính mới, làm quen nhé!",--初来乍到，多多关照
  "Xin lỗi bạn quá đen! ",--你运气也太差了
  "Nhanh lên nhé!",--我等到花儿都谢了 
  "All in ! Bạn theo đi!",--ALL IN 他!!
  "Bạn đánh bài quá tốt!",--你的牌打得太好了!
  "Bình tĩnh, tự tin bạn nhé!",--冲动是魔鬼，淡定!
  "Tặng tiền mình! Cảm ơn!",--送点钱给我吧!
  "Bạn định cướp tiền à!",--哇，你抢钱啊!
  "Các bạn chơi may mắn!",--祝你好运！
  "Lại mất mạng, mạng yếu thế nhỉ!",--又断线，网络太差了!
}

--买入弹框
L.ROOM.BUY_IN_TITLE = "Mua vào ngồi xuống"--买入筹码
L.ROOM.BUY_IN_BALANCE_TITLE = "số dư của bạn:"--您的账户余额:
L.ROOM.BUY_IN_MIN = "Tối thiểu"--最低买入
L.ROOM.BUY_IN_MAX = "Tối đa"--最高买入
L.ROOM.BUY_IN_AUTO = "Xu ko đủ thì mua vào tự động"--筹码不足时自动买入
L.ROOM.BUY_IN_BTN_LABEL = "mua vào"--买入坐下

L.ROOM.BACK_TO_HALL = "Trở về"--返回大厅
L.ROOM.CHANGE_ROOM = "Đổi bàn"--换  桌
L.ROOM.SETTING = "Thiết lập"--设  置
L.ROOM.SIT_DOWN_NOT_ENOUGH_MONEY = "Xu của bạn ko đủ vào phòng này, bạn có thể chọn đổi bàn tự động hoặc bổ sung xu để ngồi xuống lại!"--您的筹码不足当前房间的最小携带，您可以点击自动换桌系统帮你选择房间或者补足筹码重新坐下。
L.ROOM.AUTO_CHANGE_ROOM = "Đổi bàn"--自动换桌
L.ROOM.USER_INFO_ROOM = "Cá nhân" 
L.ROOM.CHARGE_CHIPS = "Bổ sung xu"--补充筹码
L.ROOM.ENTERING_MSG = "đang vào phòng, vui lòng chờ đợi..."--正在进入，请稍候...\n有识尚需有胆方可成赢家
L.ROOM.OUT_MSG = "đang thoát ra, vui lòng chờ đợi..."--正在退出，请稍候...
L.ROOM.CHANGING_ROOM_MSG = "đang đổi phòng..."--正在更换房间..
L.ROOM.CHANGE_ROOM_FAIL = "Đổi phòng thất bại, có thử lại ko?"
L.ROOM.STAND_UP_IN_GAME_MSG = "Bạn đang chơi bài, có xác nhận đứng dậy ko?"--您还在当前牌局中，确认站起吗？
L.ROOM.NET_WORK_PROBLEM_DIALOG_MSG = "Kết nối máy chủ bị gián đoạn, bạn có muốn kết nối lại ko?"--与服务器的连接中断，是否尝试重新连接？
L.ROOM.RECONNECT_MSG = "đang kết nối lại..."--正在重新连接..
L.ROOM.OPR_STATUS = {
  "Bỏ bài",--弃  牌
  "All in",--ALL_IN
  "Theo cược",--跟  注
  "Theo cược {1}",--跟注 {1}
  "Small blind",--小  盲
  "Big blind",--大  盲
  "Xem bài",--看  牌
  "Thêm cược {1}",--加注 {1}
  "Thêm cược",--加  注
}
L.ROOM.AUTO_CHECK = "Tự động\nxem bài"--自动看牌
L.ROOM.AUTO_CHECK_OR_FOLD = "Xem / Bỏ"--看或弃
L.ROOM.AUTO_FOLD = "Tự động\nbỏ bài"--自动弃牌
L.ROOM.AUTO_CALL_ANY = "Theo mọi\ncược"--跟任何注
L.ROOM.FOLD = "Bỏ bài"--弃  牌
L.ROOM.ALL_IN = "All in"--ALL IN
L.ROOM.CALL = "Theo cược"--跟  注
L.ROOM.CALL_NUM = "Theo cược\n{1}"--跟注 {1}
L.ROOM.SMALL_BLIND = "Small blind"--小盲
L.ROOM.BIG_BLIND = "Big blind"--大盲
L.ROOM.RAISE = "Thêm cược"--加  注
L.ROOM.RAISE_NUM = "Thêm cược\n{1} "--加注 {1}
L.ROOM.CHECK = "Xem bài"--看  牌
L.ROOM.TIPS = {
    "Nhắc nhở: tài khoản du khách nhấn vào avatar của mình có thể đổ avatar hoặc giới tính nhé!",--小提示：游客用户点击自己的头像弹框或者性别标志可更换头像和性别哦
  "kinh nghiệm nhỏ: khi bài của bạn nhỏ hơn đối thủ, bạn sẽ thua xu đã đặt cược nhé!",--小经验：当你牌比对方小的时候，你会输掉已经押上的所有筹码
  "làm nên cao thủ: tất cả cao thủ, trước khi bạn ấy biết chơi liêng, đều là chim non của game liêng",--高手养成：所有的高手，在他会三公游戏之前，一定是一个三公游戏的菜鸟
  "có bài tốt thì phải thêm cược, phải nắm được ưu thế, tấn công chủ động",--有了好牌要加注，要掌握优势，主动进攻。
    "chú ý quan sát đối thủ, ko thể bị đối thủ lừa nhé!",--留意观察对手，不要被对手的某些伎俩所欺骗。
    "phải có khí thế, để bạn khác sợ bạn",--要打出气势，让别人怕你。
    "Bạn nên biết khống chế cảm xúc, thắng được bài thì nên thắng.",--控制情绪，赢下该赢的牌。
    "Du khách có thể tự thiết lập avatar của mình",--游客玩家可以自定义自己的头像。
    "Nhắc nhở: trang thiết lập có thể thiết lập có tự động múa vào ngồi xuống hay ko.",--小提示：设置页可以设置进入房间是否自动买入坐下。
    "Nhắc nhở: trang thiết lập có thể thiết lập có nhắc đứng dậy hay ko.",--提示：设置页可以设置是否震动提醒。
    "chịu là vì all in lần sau",--忍是为了下一次All In。
    "xung đột là ma quỷ, có tâm trạng tốt, mới có vận may",--冲动是魔鬼，心态好，好运自然来。
    "khi có vận rủi ro, đổi chỗ thử",--风水不好时，尝试换个位置。
    "Thua bài ko sợ đâu, thua niềm tin là sợ nhất",--输牌并不可怕，输掉信心才是最可怕的。
    "Bạn ko thể không chế được thắng thua, nhưng mà bạn có thể không chế được thắng thua bao nhiêu",--你不能控制输赢，但可以控制输赢的多少。
    "Dùng đcgl để đập tỉnh bạn chơi chậm",--用互动道具砸醒长时间不反应的玩家。
    "Vận khí có khi tốt có khi ko tốt, trí thức sẽ ở bên bạn một đời",--运气有时好有时坏，知识将伴随你一生。
    "Đánh lừa là một thủ đoạn để thắng",--诈唬是胜利的一大手段，要有选择性的诈唬。
    "Đặt cược phải kết hợp với gà thưởng, ko thể xem số tuyệt đối!",--下注要结合池底，不要看绝对数字。
    "All in là một chiến thuật, dùng cho tốt là một việc ko dễ."--All In是一种战术，用好并不容易。
}
L.ROOM.SHOW_HANDCARD = "cho xem bài tay"--亮出手牌
L.ROOM.DEALER_SPEEK_ARRAY = {
  "chúc bạn thắng được nhiều,{1}",--祝您牌运亨通，{1}
  "chúc bạn có vận may liên tục,{1}",--祝您好运连连，{1}
  "bạn thật là một người tốt,{1}",--您人真好，{1}
  "rất vui có thể phục vụ cho bạn,{1}",--真高兴能为您服务，{1}
  "cảm ơn bạn nhiều lắm，{1}"--衷心的感谢您，{1}
}
L.ROOM.SELF_CHIP_NO_ENOUGH_SEND_DELEAR = "Xu của bạn ko đủ để cho tiền cho nhà cái"--你的筹码不够多，不足给荷官小费
L.ROOM.USER_CRSH_POP_TITLE = "ôi, bạn phá sản rồi!"--破产了
L.ROOM.SERVER_UPGRADE_MSG = "Server đang thăng cấp, bạn vui lòng chờ đợi...."
L.ROOM.SERVER_STOPPED_MSG = "Hệ thống đang tạm thời dừng phục vụ, vui lòng chờ đợi"
L.ROOM.CHAT_MAIN_TAB_TEXT = {
  "Chat", 
  "Lịch sử chat"
}

T = {}
L.COMMON.CARD_TYPE = T
T1 = {}
T[1] = T1 
T[2] = "đồng hoa" --同花
T[3] = "liêng"    --顺子
T[4] = "đĩ"       --小三公
T[5] = "sảnh thông"--同花顺
T[6] = "sáp"--大三公
T1[0] = "0 điểm"--0点
T1[1] = "1 điểm"--1点
T1[2] = "2 điểm"--2点
T1[3] = "3 điểm"--3点
T1[4] = "4 điểm"--4点
T1[5] = "5 điểm"--5点
T1[6] = "6 điểm"--6点
T1[7] = "7 điểm"--7点
T1[8] = "8 điểm"--8点
T1[9] = "9 điểm"--9点

T = {}
L.ROOM.SIT_DOWN_FAIL_MSG = T
T["IP_LIMIT"] = "ngồi xuống thất bại, một IP ko thể ngồi xuống được 2 tài khoản trong 1 bàn"--坐下失败，同一IP不能坐下
T["SEAT_NOT_EMPTY"] = "ngồi xuống thất bại, chỗ này đã có bạn chơi ngồi xuống."--坐下失败，该桌位已经有玩家坐下。
T["TOO_RICH"] = "ngồi xuống thất bại, có nhiều xu thế mà còn đến sân lính mới bắt nạt lính mới hả?"--坐下失败，这么多筹码还来新手场虐人？
T["TOO_POOL"] = "ngồi xuống thất bại, xu ko đủ để vào phòng này đi lính mới"--坐下失败，筹码不足无法进入非新手场房间。

L.STORE.NOT_SUPPORT_MSG = "tài khoản của bạn tạm thời ko thế thanh toán được..."--您的账户暂不支持支付
L.STORE.PURCHASE_SUCC_AND_DELIVERING = "đã thanh toán thành công, đang tiến hành phát hàng, vui lòng chờ đợi...."--已支付成功，正在进行发货，请稍候.
L.STORE.PURCHASE_CANCELED_MSG = "thanh toán đã hủy bỏ"--支付已经取消
L.STORE.PURCHASE_FAILED_MSG = "thanh toán thất bại"--支付失败
L.STORE.DELIVERY_FAILED_MSG = "mạng yếu, hệ thống sẽ thử lại sau khi bạn lần sau vào shop."--网络故障，系统将在您下次打开商城时重试。
L.STORE.DELIVERY_SUCC_MSG = "phát hàng thành công, cảm ơn chúc bạn may mắn"--发货成功，感谢您的购买。
L.STORE.TITLE_STORE = "Shop"--商城
L.STORE.TITLE_CHIP = "Xu"--筹码
L.STORE.TITLE_PROP = "Đạo cụ"--道具
L.STORE.TITLE_MY_PROP = "Đạo cụ của tôi"--我的道具
L.STORE.TITLE_HISTORY = "Lịch sử"--购买记录
L.STORE.RATE_CHIP = "1{2}={1}xu"--1={1}--筹码
L.STORE.FORMAT_CHIP = "xu{1}"
L.STORE.REMAIN = "còn thừa：{1}{2}"--剩余：{1}{2}
L.STORE.INTERACTIVE_PROP = "Đcgl"--互动道具
L.STORE.BUY = "mua"--购买
L.STORE.USE = "sử dụng"--使用
L.STORE.BUY_CHIPS = "Mua {1} xu "--购买{1}筹码
L.STORE.RECORD_STATUS = {
  "đã đặt đơn",--已下单
  "đã phát hàng",--已发货
  "đã hoàn lại tiền"--已退款
}
L.STORE.USE_SUCC_MSG = "đạo cụ sử dụng thàng công"--道具使用成功
L.STORE.USE_FAIL_MSG = "đạo cụ sử dụng thất bại"--道具使用失败
L.STORE.NO_PRODUCT_HINT = "chưa có hàng hóa"
L.STORE.NO_BUY_HISTORY_HINT = "chưa có kỷ lục giao dịch"
L.STORE.MY_CHIPS = "xu tôi {1}" --我的筹码 {1}
L.STORE.BUSY_PURCHASING_MSG = "đang mua, vui lòng chờ đợi..." --正在购买，请稍候..

-- login reward
L.LOGINREWARD.TITLE = "Giải thưởng đăng nhập liên tục"--连续登录奖励
L.LOGINREWARD.REWARD = "Giải thưởng hôm nay {1} xu"--今日奖励{1}筹码
L.LOGINREWARD.REWARD_ADD = "(FB đăng nhập +50000)"--(FB登录多加50000筹码)
L.LOGINREWARD.PROMPT = "Đăng nhập liên tục có thể nhận được thưởng cao nhất mỗi ngày {1} xu"--连续登录可获得更多奖励，最高每天{1}游戏币奖励
L.LOGINREWARD.DAYS = "{1}ngày"--{1}天
L.LOGINREWARD.NO_REWARD = "sau khi lĩnh thưởng đăng ký ba lần thì có thể nhận được thưởng này"--三次注册礼包领取完成后即可领取

-- USERINFO MODULE
L.USERINFO.MAX_MONEY_HISTORY = "Tài sản nhiều nhất:"--历史最高资产: {1}
L.USERINFO.MAX_POT_HISTORY = "Thắng nhiều nhất:"--赢得最大奖池: {1}
L.USERINFO.WIN_RATE_HISTORY = "Tỷ lệ thắng:"--历史胜率: {1}%
L.USERINFO.INFO_RANKING = "xếp hạng:" 
L.USERINFO.BEST_CARD_TYPE_HISTORY = "Kiểu bài tốt nhất:"--历史最佳牌型:
L.USERINFO.MY_PROPS = "Đạo cụ của tôi"--我的道具:
L.USERINFO.MY_PROPS_TIMES = "X{1}"--次
L.USERINFO.EXPERIENCE_VALUE = "{1}/{2}" --经验值
-- FRIEND MODULE
L.FRIEND.NO_FRIEND_TIP = "tạm thời chưa có bạn bè\n rủ bạn ngay có thể nhận được nhiều xu miễn phí!"--暂无好友\n立即邀请好友可获得丰厚筹码赠送！
L.FRIEND.SEND_CHIP = "tặng xu"--赠送筹码
L.FRIEND.SEND_CHIP_WITH_NUM = "tặng{1}xu"--赠送{1}筹码
L.FRIEND.SEND_CHIP_SUCCESS = "Bạn đã tặng {1} xu cho bạn thành công."--您成功给好友赠送了{1}筹码。
L.FRIEND.SEND_CHIP_TOO_POOR = "Xu của bạn ít quá, vào shop mua và thử lại sau nhé!"--您的筹码太少了，请去商城购买筹码后重试。
L.FRIEND.SEND_CHIP_COUNT_OUT = "Hôm nay bạn đã tặng xu cho bạn này rồi, vui lòng thử lại ngày mai."--您今天已经给该好友赠送过筹码了，请明天再试。
L.FRIEND.INVITE_DESCRIPTION = "Rủ được một bạn facebook, bạn sẽ nhận thưởng {1} xu ngay. Bạn này tiếp nhận sử rủ và đăng nhập game thành công, bạn còn có thể nhận thêm {2} xu.\n Đồng thời, bạn được rủ sẽ nhận được gói quà đăng ký {3} xu."--每邀请一位Facebook好友，可立即获赠500筹码。FaceBook好友接受邀请并成功登录游戏，您还可以额外获得50000筹码奖励，多劳多送。\n\n同时，被邀请的好友登录游戏后也可获赠150000筹码的注册礼包，赠送的筹码由系统免费发放。
L.FRIEND.INVITE_REWARD_TIP = "Bạn đã nhận được thưởng rủ {1}xu, gửi lời rủ càng nhiều được xu càng nhiều!"--您已累计获得了{1}筹码的邀请奖励，多劳多得，天天都有哦！
L.FRIEND.INVITE_WITH_FB = "Rủ qua FB"--Facebook\n邀请
L.FRIEND.INVITE_WITH_SMS = "Rủ qua SMS"--短信邀请
L.FRIEND.INVITE_WITH_MAIL = "Rủ qua Email"--邮件邀请
L.FRIEND.SELECT_ALL = "Chọn tất cả"
L.FRIEND.DESELECT_ALL = "Hủy bỏ"
L.FRIEND.SEND_INVITE = "rủ"--邀请
L.FRIEND.INVITE_SUBJECT = "bạn chắc chắn sẽ thích"--您绝对会喜欢
L.FRIEND.INVITE_CONTENT = "Đề nghị cho bạn một game poker thú vị và hấp dẫn, mình đã tặng cho bạn gói quà 150000 xu, đăng ký thì có thể nhận ngay, nhanh đi chơi với tôi đi!http://d1qjotbaoki2mk.cloudfront.net/m/9kvn.html"--为您推荐一个既刺激又有趣的扑克游戏，我给你赠送了15万的筹码礼包，注册即可领取，快来和我一起玩吧！http://goo.gl/IvRr4z
L.FRIEND.INVITE_CONTENT_OLDUSER = "我现在正在玩三公游戏，您有一段时间没登录了，快来和我一起玩吧！" -- trans it
L.FRIEND.INVITE_SELECT_TIP = "Bạn đã chọn {1} bạn bè\n gửi sự rủ thì có thể nhận được {2} xu."--您已选择了{1}位好友\1{2}筹码的奖励
L.FRIEND.INVITE_SUCC_TIP = "Gửi lời mời thành công, nhận được thưởng {1} xu!"--成功发送了邀请，获得{1}筹码的奖励！
L.FRIEND.CANNOT_SEND_MAIL = "Bạn chưa thiết lập tài khoản email, bây giờ đi thiết lập ko?"--您还没有设置邮箱账户，现在去设置吗？
L.FRIEND.CANNOT_SEND_SMS = "xin lỗi, bạn ko thể dùng được chức năng gửi sms!"--对不起，无法调用发送短信功能！
L.FRIEND.MAIN_TAB_TEXT = {
  "Bạn bè", --我的好友
  "Rủ bạn"--邀请好友
}
L.FRIEND.INVITE_FRIENDS_NUM_LIMIT_TIP = "Mỗi lần tối đa rủ được 50 bạn"
L.FRIEND.TOO_MANY_FRIENDS_TO_ADD_FRIEND_MSG = "Bạn bè của bạn đã đạt đến 600, bạn vui lòng xoa một số  mới có thể kết bạn nữa."
L.FRIEND.INVITE_OLD_USER_TIP = "您需要使用FB账号登陆才能发送邀请"  -- trans it

-- RANKING MODULE
L.RANKING.TRACE_PLAYER = "theo"--追踪玩家
L.RANKING.MAIN_TAB_TEXT = {
  "Xếp hạng bạn bè", --好友排行
  "Bảng xếp hạng"--总排行榜
}
L.RANKING.SUB_TAB_TEXT_FRIEND = {
  "Xu", --筹码排行
  "Cấp bậc",--等级排行
}
L.RANKING.SUB_TAB_TEXT_GLOBAL = {
  "Xu",--筹码排行 
  "Cấp bậc",--等级排行
  "Xu thắng"--盈利排行
}

-- SETTING MODULE
L.SETTING.TITLE = "Thiết lập"--设置
L.SETTING.NICK = "Tên"--昵称
L.SETTING.PLEASE_USE_FACEBOOK = '(使用Facebook登录奖励更多哦!)'
L.SETTING.LOGOUT = "đăng xuất"--登出
L.SETTING.SOUND_VIBRATE = "Âm thanh và dung động"--声音
L.SETTING.SOUND = "Music"--声音
L.SETTING.VIBRATE = "Rung động"--震动
L.SETTING.OTHER = "Khác"--其他
L.SETTING.AUTO_SIT = "Vào phòng và tự động ngồi xuống"--进入房间自动坐下
L.SETTING.AUTO_BUYIN = "Tự động mua vào"--自动买入
L.SETTING.APP_STORE_GRADE = "Thích chúng tôi, đánh giá điểm cao nhé!"--喜欢我们，打分鼓励
L.SETTING.CHECK_VERSION = "Kiểm tra thăng cấp"--检测更新
L.SETTING.CURRENT_VERSION = "Số phiên bản hiện nay V{1}"--当前版本号：V{1}
L.SETTING.ABOUT = "Về"--关于
L.SETTING.FANS = "Trang fans"--官方粉丝页

L.HELP.TITLE = "Trợ giúp"--帮助
L.HELP.SUB_TAB_TEXT = {
  "Phản hồi",--问题反馈
  "Vấn đề hot",--常见问题
    "Quy tắc",--基本规则
    "Cấp bậc"--等级说明
}
L.HELP.FEED_BACK_HINT = "Bạn gặp vấn đề gì trong game hoặc có ý kiến gì về game, hoan nghênh bạn phản hồi cho chúng tôi"--您在游戏中碰到的问题或者对游戏有任何意见或者建议，我们都欢迎您给我们反馈
L.HELP.NO_FEED_BACK = "Bây giờ bạn vẫn chưa có kỷ lục phản hồi"--您现在还没有反馈记录
L.HELP.FEED_BACK_SUCCESS = "phản hồi thành công"--反馈成功!
L.HELP.UPLOADING_PIC_MSG = "đang tải lên ảnh, vui lòng chờ đợi..."--正在上传图片，请稍候..
L.HELP.MUST_INPUT_FEEDBACK_TEXT_MSG = "xin nhập vào nội dung phản hồi"--请输入反馈内容
L.HELP.FAQ = {
  {
    "Tôi quên két rương và két game thì làm như thế nào?",
    "Bạn có thể cung cấp xu két và xu ngoài trong phản hồi của bạn, chúng tôi sẽ xử lý cho bạn nhanh.chúc bạn chơi vui!"
  },
  {
    "Tôi hết xu nhưng vẫn muốn chơi thì làm như thế nào?",
    {
      "Bạn có thể click",
      "đi mua xu, hoặc tham gia sự kiện và làm nhiệm vụ để kiếm được xu miễn phí. chúc bạn chơi vui!"
    }
  },
  {
    "Xu của tôi bị mất phải làm như thế nào?",
    "Bạn vui lòng phản hồi cho chúng tôi, chúng tôi sẽ xử lý nhanh cho bạn.Chúc bạn chơi vui!"
  },
  {
    "Tôi hoàn thành nhiệm vụ mà ko có thưởng là sao?",
    "Bạn vui lòng chú ý sự biến đổi xu của bạn, nếu bạn thật có hoàn thành nhiệm vụ, hệ thống chắc chắn đã giao thưởng cho bạn rồi nhé!Chúc bạn chơi vui!"
  },
  {
    "Tại sao tôi không đăng nhập vào game được?",
    "Xin bạn vui lòng kiểm tra mạng của bạn, và thử lại sau.Chúc bạn chơi vui!"
  }
  ,
  {
    "Tôi lấy mã đổi thưởng như thế nào?",
    "Bạn vui lòng thích trang fans chúng tôi, chúng tôi sẽ phát mã đổi thưởng mỗi ngày. Địa chỉ trang fans:https://www.facebook.com/liengvn"
  }
  ,
  {
    "Tại sao tôi thường bị đẩy ra?",
    "Bạn vui lòng kiểm tra mạng của bạn.Chúc bạn chơi vui!"
  }
  ,
  {
    "Tôi nạp xu mà ko được xu là vì sao?",
    "Thông thường bạn nạp xong hệ thống sẽ tự động phát hàng cho bạn. Đôi khi có chậm trệ, bạn vui long chờ đợi 2 tiếng. Nếu vẫn chưa được, bạn vui long phản hồi cho chúng tôi, chúng tôi sẽ xử lý nhanh cho bạn, chúc bạn chơi vui!"
  }
}

L.HELP.RULE = {
  {
    "Quy tắc so bài",
    ""
  },
  {
    "Quy tắc cơ bản",
    "Thứ tự lớn bé: 2<3<4<5<6<7<8<9<10<J<Q<K<A\nThứ tự chất: Tép< Cơ< Rô < bích\nKiểu bài lớn bé: Bài điểm < Đồng hoa< Liêng< Đĩ< Sảnh thông<Sáp"
  },
  {
    "Đặt cược",
    "Sân phổ thông: Mỗi bạn chơi đặt cược vòng thứ nhất trước khi phát bài, sau khi phát 3 bài xong bạn chơi có thể đặt cược vòng thứ hai. Xu đặt cược ko có hạn chế.\nSân thách thức: Các bạn chơi đặt cược khi mỗi bạn đã phát được 2 lá bài, phát 3 lá bài xong, bạn chơi có thể đặt cược vòng thứ 2.\nCăn cứ vào bài tay so sánh lớn bé, người thắng thì lấy được gà thưởng."
  }
  
}
L.HELP.LEVEL = {
  {
    "Cách được EXP",
    "1.Thắng 1 ván bài được thêm 2 EXP\n2.Tích lũy chơi 10   ván bài được thêm 10 EXP\n   Tích lũy chơi 20   ván bài được thêm 10 EXP\n   Tích lũy chơi 50   ván bài được thêm 30 EXP\n   Tích lũy chơi 100 ván bài được thêm 50 EXP\n   Tích lũy chơi 200 ván bài được thêm 50 EXP\n3.Lưu ý: Hàng ngày tối đa có thể được thêm EXP 600."
  },
  {
    "Về cấp bậc",
    {
      {
        "Lv","Xưng hô","EXP","Giải thưởng"
      },
      {
        "LV1", "Nô lệ", "0", ""
      },
      {
        "LV2", "Ăn xin", "25", "100,000xu"
      },
      {
        "LV3", "Giúp việc", "80", "200,000xu"
      },
      {
        "LV4", "Nông dân", "240", "300,000xu"
      },
      {
        "LV5", "Địa chủ", "520", "500,000xu10đcgl"
      },
      {
        "LV6", "Bá hộ", "1,249", "  500,000xu"
      },
      {
        "LV7", "Hương cống", "2,499", "500,000xu"
      },
      {
        "LV8", "Lý trưởng", "4,277", "500,000xu15đcgl"
      },
      {
        "LV9", "Huyện thừa ", "7,198", "500,000xu"
      },
      {
        "LV10", "Tri huyện ", "10,990", "2,000,000 xu 30đcgl"
      },
      {
        "LV11", "Phủ doãn", "16,003", "2,000,000 xu 20đcgl"
      },
      {
        "LV12", "Tri phủ", "22,466", "2,000,000 xu "
      },
      {
        "LV13", "Tuần phủ", "30,658", "2,000,000 xu "
      },
      {
        "LV14", "Tổng đốc", "40,931", "2,000,000 xu "
      },
      {
        "LV15", "Thái thú", "53,748", "5,000,000 xu "
      },
      {
        "LV16", "Thứ sử", "69,744", "5,000,000 xu  30đcgl"
      },
      {
        "LV17", "Ngự sử ", "89,816", "5,000,000 xu "
      },
      {
        "LV18", "Đại học sĩ", "115,264", "2,000,000 xu  30đcgl"
      },
      {
        "LV19", "Thái úy", "148,000", "5,000,000 xu "
      },
      {
        "LV20", "Thái sư", "190,877", "10,000,000 xu 60đcgl"
      },
      {
        "LV21", "Thượng thư", "248,186", "10,000,000 xu "
      },
      {
        "LV22", "Thừa tướng", "326,416", "10,000,000 xu "
      },
      {
        "LV23", "Nam tước", "435,424", "10,000,000 xu 60đcgl"
      },
      {
        "LV24", "Tử tước", "590,214", "10,000,000 xu "
      },
      {
        "LV25", "Bá tước", "813,671", "50,000,000 xu 100đcgl"
      },
      {
        "LV26", "Hầu tước", "1,160,000", "50,000,000xu 200đcgl"
      },
      {
        "LV27", "Quận công", "1,785,000", "50,000,000xu 300đcgl"
      },
      {
        "LV28", "Quốc công", "2,432,232", "80,000,000xu 400đcgl"
      },
      {
        "LV29", "Vương gia", "3,204,464", "100,000,000xu 500đcgl"
      },
      {
        "LV30", "Nhà vua", "4,146,696", "100,000,000xu 600đcgl"
      }
    }
  }
}

L.UPDATE.TITLE = "Kiểm tra đến phiên bản mới"--发现新版本
L.UPDATE.DO_LATER = "Nhắc lại sau"--以后再说
L.UPDATE.UPDATE_NOW = "Thăng cấp ngay"--立即升级
L.UPDATE.HAD_UPDATED = "Bạn đã cài đặt phiên bản mới nhất"--您已经安装了最新版本

L.ABOUT.TITLE = "Về"--关于
L.ABOUT.UID = "ID của bạn chơi: {1}"--当前玩家ID: {1}
L.ABOUT.VERSION = "Số phiên bản:V{1}"--版本号：V{1}
L.ABOUT.FANS = "Trang fans cuả game:"--官方粉丝页：
L.ABOUT.FANS_URL = "https://www.facebook.com/liengvn"
L.ABOUT.FANS_OPEN = "http://d25t7ht5vi1l2.cloudfront.net/m/goFans.html?l=vn"
L.ABOUT.SERVICE = "điều khoản phục vụ và chiếm lược bí ẩm"--服务条款与隐私策略
L.ABOUT.COPY_RIGHT = "Copyright © 2014 Boomegg Interactive Co., Ltd..All Rights Reserved."

L.DAILY_TASK.GET_REWARD = "Nhận"--领取奖励
L.DAILY_TASK.HAD_FINISH = "đã hoàn thành"--已完成
L.DAILY_TASK.COMPLETE_REWARD = "chúc mừng bạn đã hoàn thành nhiệm vụ:{1}"--恭喜你完成了任务：{1}
L.DAILY_TASK.CHIP_REWARD = "thưởng {1}xu"--奖励{1}筹码

-- count down box
L.COUNTDOWNBOX.TITLE = "Hòm báu"--倒计时宝箱
L.COUNTDOWNBOX.SITDOWN = "Ngồi xuống mới có thể tính thời gian tiếp"--坐下才可以继续计时。
L.COUNTDOWNBOX.FINISHED = "Hòm báu của bạn đã lĩnh xong, ngày mai vẫn có nhé!"--您今天的宝箱已经全部领取，明天还有哦。
L.COUNTDOWNBOX.NEEDTIME = "Chơi {1}:{2} phút nữa nhận thưởng {3}."--再玩{1}分{2}秒，您将获得{3}。
L.COUNTDOWNBOX.REWARD = "Chúc mừng bạn nhận được thưởng hòm báu{1}."--恭喜您获得宝箱奖励{1}。

L.USERINFO.UPLOAD_PIC_NO_SDCARD = "Bạn chưa lắp đặt card SD, ko thể sử dùng được chức năng tải ảnh lên."--没有安装SD卡，无法使用头像上传功能
L.USERINFO.UPLOAD_PIC_PICK_IMG_FAIL = "tải ảnh thất bại"--获取图像失败
L.USERINFO.UPLOAD_PIC_UPLOAD_FAIL = "tải lên ảnh thất bại,bạn vui lòng thử lại sau"--上传头像失败，请稍后重试
L.USERINFO.UPLOAD_PIC_IS_UPLOADING = "đang tải ảnh lên, vui lòng chờ đợi..."--正在上传头像，请稍候...
L.USERINFO.UPLOAD_PIC_UPLOAD_SUCCESS = "tải ảnh lên thành công"--上传头像成功

L.NEWESTACT.NO_ACT = "chưa có"--暂无活动
L.NEWESTACT.TITLE = "Sự kiện mới nhất"--最新活动
L.NEWESTACT.LOADING = "đang tải..."--加载中...

L.FEED.SHARE_SUCCESS = "chia sẻ thành công"--分享成功
L.FEED.SHARE_FAILED = "chia sẻ thất bại"--分享失败
L.FEED.LOGIN_REWARD = {
  name = "Giỏi quá! Tôi đã lĩnh thưởng {1} xu tại game nineke, nhanh đi chơi với mình đi!！",--太棒了!我在三公领取了{1}筹码的奖励，快来和我一起玩吧！http://goo.gl/IvRr4z
  caption = "Mỗi ngày đăng nhập, xu tặng tận tay",--天天登录筹码送不停
  link = "http://d1qjotbaoki2mk.cloudfront.net/m/9kvn.html",
  picture = "http://pclptl9k02-static.boyaagame.com/static/nineke/nineke/images/feed/LOGIN_REWARD2.jpg",
  message = "",
}

L.FEED.EXCHANGE_CODE = {
  name = "Tôi dùng mã đổi thưởng của trang fans liêng phú ông đổi được thưởng {1}, mau đi chơi với mình đi!",--我用三公粉丝页的兑换码换到了{1}的奖励，快来和我一起玩吧！http://goo.gl/IvRr4z
  caption = "đổi thưởng fans có lễ bao",--粉丝奖励兑换有礼
  link = "http://d1qjotbaoki2mk.cloudfront.net/m/9kvn.html",
  picture = "http://pclptl9k02-static.boyaagame.com/static/nineke/nineke/images/feed/EXCHANGE_CODE1.jpg",
  message = "",
}
L.FEED.WHEEL_ACT = {
  name = "Nhanh đi chơi đồng quay may mắn với mình đi, mỗi ngày đăng nhập có 3 lần cơ hội nhé!! ",
  caption = "Đồng quay may mắn 100% trúng giải", 
  link = "http://d1qjotbaoki2mk.cloudfront.net/m/9kvn.html",
  picture = "http://pclptl9k02-static.boyaagame.com/static/nineke/nineke/images/feed/WHEEL_ACT1.jpg",
  message = "",
}
L.FEED.WHEEL_REWARD = {
  name = "Tôi nhận được thưởng {1} trong ĐQMM của Liêng Phú Ông, nhanh đi chơi với mình nhé!",
  caption = "Đồng quay may mắn 100% trúng giải",
  link = "http://d1qjotbaoki2mk.cloudfront.net/m/9kvn.html",
  picture = "http://pclptl9k02-static.boyaagame.com/static/nineke/nineke/images/feed/WHEEL_REWARD1.jpg",
  message = "",
}
L.FEED.UPGRADE_REWARD = {
  name = "Giỏi quá, tôi vừa thắng cấp đến cấp {1} trong liêng phú ông, nhận được thưởng {2}, nhanh đi so tài với cao thủ khác nào !",
  caption = "Gói quà thăng cấp",
  link = "http://d1qjotbaoki2mk.cloudfront.net/m/9kvn.html",
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
  "Tin bạn bè", --好友消息
  "Tin hệ thống"--系统消息
}
L.MESSAGE.EMPTY_PROMPT = "Bạn bây giờ ko có tin tức"--您现在没有消息记录


--奖励兑换码Mã đổi thưởng
L.ECODE.TITLE = "Đổi thưởng"--奖励兑换
L.ECODE.EDITDEFAULT = "xin nhập vào mã đổi thưởng"--请输入6位数字奖励兑换码
L.ECODE.DESC = "Thích trang fans có thể lấy được mã đổi thưởng, cảm ơn ủng hộ của bạn.\n\nLink trang fans:\nhttps://www.facebook.com/liengvn"--关注粉丝页可免费领取奖励兑换码,我们还会不定 期在官方粉丝页推出各种精彩活动,谢谢关注。
L.ECODE.EXCHANGE = "Đổi thưởng"--兑  奖
L.ECODE.SUCCESS = "Chúc mừng bạn đã đổi thưởng thành công, \nbạn nhận được{1} "--恭喜您，兑奖成功！\n您获得了{1}
L.ECODE.ERROR_FAILED = "Đổi thưởng thất bại, bạn vui lòng kiểm tra mã đổi thưởng của bạn!"--兑奖失败，请确认您的兑换码是否输入正确！
L.ECODE.ERROR_INVALID="Đổi thưởng thất bại, mã đổi thưởng của bạn đã qua thời hạn."--兑奖失败，您的兑换码已经失效。
L.ECODE.ERROR_USED = "Đổi thưởng thất bại, mỗi mã đổi thưởng chỉ có thể đổi 1 lần.\n bạn đã được đổi {1}."--兑奖失败，每个兑换码只能兑换一次。\n您已经兑换到了{1}
L.ECODE.ERROR_END= "Nhận thưởng thất bại, thưởng lần này đã lấy hết rồi, chúc bạn lần sau may mắn nhé!"--领取失败，本次奖励已经全部领光了，关注我们下次早点来哦
L.ECODE.FANS = "Thích trang fans"--关注粉丝页

--大转盘
L.WHEEL.SHARE = "Chia sẻ"
L.WHEEL.REMAIN_COUNT = "Còn có "
L.WHEEL.TIME = " Lần"
L.WHEEL.DESC1 = "Mỗi ngày có 3 lần cơ hộ quay ĐQMM"
L.WHEEL.DESC2_PRE = ""
L.WHEEL.DESC2_POST = "Trúng giải   "
L.WHEEL.DESC3 = "Cao nhất đạt đến 10M Xu"
L.WHEEL.DESC4 = "Bạn còn đợi gì, chơi ngay đi!"
L.WHEEL.PLAY = "Bắt đầu\n quay"
L.WHEEL.REWARD = {
  "Trúng tưởng lớn!!",
  "Chúc mừng bạn trúng được thưởng {1}"
}

--银行
L.BANK.BANK_BUTTON_LABEL = "Két"
L.BANK.BANK_GIFT_LABEL = "Quà tôi"
L.BANK.BANK_DROP_LABEL = "Đạo cụ"
L.BANK.BANK_LABA_LABEL = "loa"
L.BANK.BANK_TOTAL_CHIP_LABEL = "Xu trong két"
L.BANK.SAVE_BUTTON_LABEL = "Gửi"
L.BANK.DRAW_BUTTON_LABEL = "Rút"
L.BANK.CANCEL_PASSWORD_SUCCESS_TOP_TIP = "Hủy bỏ mật khẩu thành công"
L.BANK.CANCEL_PASSWORD_FAIL_TOP_TIP = "Hủy bỏ mật khẩu thất bại"
L.BANK.EMPYT_CHIP_NUMBER_TOP_TIP = "Xin nhập vào số xu"
L.BANK.USE_BANK_NO_VIP_TOP_TIP = "Bạn ko phải là VIP, ko sử dụng két được"
L.BANK.USE_BANK_SAVE_CHIP_SUCCESS_TOP_TIP = "Gửi xu thành công"
L.BANK.USE_BANK_SAVE_CHIP_FAIL_TOP_TIP = "Gửi xu thất bại"
L.BANK.USE_BANK_DRAW_CHIP_SUCCESS_TOP_TIP = "Rút xu thành công"
L.BANK.USE_BANK_DRAW_CHIP_FAIL_TOP_TIP = "Rút xu thất bại"
L.BANK.BANK_POPUP_TOP_TITIE = "Két"
L.BANK.BANK_INPUT_TEXT_DEFAULT_LABEL = "Xin nhập vào mật khẩu"
L.BANK.BANK_CONFIRM_INPUT_TEXT_DEFAULT_LABEL = "Xin nhập vào mật khẩu lại"
L.BANK.BANK_INPUT_PASSWORD_ERROR = "Bạn nhập mật khẩu sai, vui lòng nhập lại"
L.BANK.BANK_SET_PASSWORD_TOP_TITLE = "Thiết lập mật khẩu"
L.BANK.BANK_SET_PASSWORD_SUCCESS_TOP_TIP = "Thiết lập thành công"
L.BANK.BANK_SET_PASSWORD_FAIL_TOP_TIP = "Thiết lập thất bại"
L.BANK.BANK_LEVELS_DID_NOT_REACH = "Cấp bậc của bạn chưa đạt đến lv7, ko sử dụng két được"
L.BANK.BANK_FORGET_PASSWORD_BUTTON_LABEL = "Quên MK"
L.BANK.BANK_CACEL_PASSWORD_BUTTON_LABEL = "Hủy MK"
L.BANK.BANK_SETTING_PASSWORD_BUTTON_LABEL = "Thiết lập MK"
L.BANK.BANK_FORGET_PASSWORD_FEEDBACK = "Vui lòng phản hồi"
L.BANK.BANK_CANCEL_OR_SETING_PASSWORD = "Bạn có thể hủy mật khẩu hoặc thiết lập mật khẩu."

--老虎机
L.SLOT.NOT_ENOUGH_MONEY = "Xu của bạn ko đủ để chơi máy slot"
L.SLOT.SYSTEM_ERROR = "Hệ thống lỗi, bây giờ ko chơi máy slot được."
L.SLOT.PLAY_WIN = "Bạn thắng được{1}xu"
L.SLOT.TOP_PRIZE = "Bạn {1} trúng thưởng lớn khi chơi máy slot, nhận xu{2}"
L.SLOT.FLASHBAR_TIP = "Giải đầu:{1}"
L.SLOT.FLASHBAR_WIN = "Bạn thắng:{1}"
L.SLOT.AUTO = "Tự động"

--升级弹框
L.UPGRADE.OPEN = "Nhận thưởng"
L.UPGRADE.SHARE = "chia sẻ"
L.UPGRADE.GET_REWARD = "Nhận được{1} "

L.GIFT.SET_SELF_BUTTON_LABEL = "Thiết lập thành quà tôi"
L.GIFT.BUY_TO_TABLE_GIFT_BUTTON_LABEL = "Mua cho bàn x{1}"
L.GIFT.CURRENT_SELECT_GIFT_BUTTON_LABEL = "Quà đã chọn"
L.GIFT.PRESENT_GIFT_BUTTON_LABEL = "Tặng"
L.GIFT.DATA_LABEL = "Ngày"
L.GIFT.SELECT_EMPTY_GIFT_TOP_TIP = "Chọn quà"
L.GIFT.BUY_GIFT_SUCCESS_TOP_TIP = "Mua quà thành công"
L.GIFT.BUY_GIFT_FAIL_TOP_TIP = "Mua quà thất bại"
L.GIFT.SET_GIFT_SUCCESS_TOP_TIP = "Thiết lập thành công"
L.GIFT.SET_GIFT_FAIL_TOP_TIP = "Thiết lập thành công"
L.GIFT.PRESENT_GIFT_SUCCESS_TOP_TIP = "Tặng quà thành công"
L.GIFT.PRESENT_GIFT_FAIL_TOP_TIP = "Tặng quà thành công"
L.GIFT.PRESENT_TABLE_GIFT_SUCCESS_TOP_TIP = "Tặng quà cho bàn thành công"
L.GIFT.PRESENT_TABLE_GIFT_FAIL_TOP_TIP = "Tặng quà cho bàn thất bại"
L.GIFT.NO_GIFT_TIP = "Không có món quà"
L.GIFT.MY_GIFT_MESSAGE_PROMPT_LABEL = "点击选中既可在牌桌上展示才礼物"


L.GIFT.SUB_TAB_TEXT_SHOP_GIFT = {
  "Hợt", 
  "Tinh phẩm",
  "Ngày lễ",
  "Khác"
}
L.GIFT.SUB_TAB_TEXT_MY_GIFT = {

  "Bạn bài tặng", 
  "Tự mua"
}

L.GIFT.MAIN_TAB_TEXT = {
  "Tự mua", 
  "Quà tôi"
}

-- 破产
L.CRASH.PROMPT_LABEL = "您获得{1}筹码的破产救济金，同时还获得当日充值优惠一次，立即充值，重振雄风！"
L.CRASH.THIRD_TIME_LABEL = "您获得最后一次{1}筹码的破产救济金，同时还获得当日充值优惠一次，立即满血复活，再战江湖！"
L.CRASH.OTHER_TIME_LABEL = "您已经领完所有破产救济金了，您可以去商城购买筹码，每天登录还有免费筹码赠送哦！"

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
