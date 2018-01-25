--
-- Author: hlf
-- Date: 2015-11-26 11:48:47
-- 加载、切场、换桌、进入比赛场提示文字管理类

local EnterTipsManager = class("EnterTipsManager");

-- 超过5秒换tips描写
local DEFAULT_INTERVAL_TIME = 5;

function EnterTipsManager:ctor()
	-- L.ROOM.ENTERING_MSG = "บางทีโชคดี บางทีโชคร้าย\nอยากชนะ ต้องใจร่มๆจ้า"
	-- self.tips_ = {
	-- 	"ตั๋วห้องชิงชิปเงินสดมีการกำหนดอายุการใช้งาน หากหมดอายุจะไม่สามารถใช้งานได้",
	-- 	"ในทุกๆการแข่งขันระบบจะจัดชิปให้กับทุกท่านชิปเฉพาะกิจนี้ไม่ถือเป็นชิปที่ใช้กันทั่วไปในห้องธรรมดา/ห้องมืออาชีพ หลังจบการแข่งขัน ระบบจะดึงชิปกลับคืน",
	-- 	"ชิปของผู้เล่นท่านใดเป็น 0 ก่อน จะถูกคัดออกจากเกม",
	-- 	"ระบบจะส่งรางวัลเข้าบัญชีให้โดยอัตโนมัติ",
	-- 	"ผู้เล่นที่ลงชื่อแล้วแต่ไม่ได้เข้าแข่ง ระบบจะคืนค่าลงชื่อให้อัตโนมัติ แต่ผู้เล่นที่เข้าแข่งแล้วแข่งไม่จบเกม ระบบจะไม่คืนค่าลงชื่อให้",
	-- 	"เวลาแข่งขัน หากไม่กระทำการใดๆถึง 3 ครั้ง จะถือว่ายอมแพ้ ระบบจะเตะออกจากการแข่ง",
	-- 	"การเรียงดอกจากน้อยไปมากในเก้าเกไทย ดังนี้ : ดอกจิก < ข้าวหลามตัด < โพธิ์แดง < โพธิ์ดำ",
	-- 	"ไพ่สีดอกเดียวกัน ดูแต้มไพ่สูงสุด",
	-- 	"ไพ่แต้มเดียวกัน ดูแต้มไพ่สูงสุด",
	-- 	"ไพ่ใหญ่สุดคือไพ่ A",
	-- 	"ระบบจะส่งรางวัลวงล้อนำโชคให้โดยอัตโนมัติ",
	-- 	"รางวัลจริงต่างๆที่ได้รับ ทีมงานจะจัดส่งให้ท่านตามที่อยู่ที่แจ้งมาภายใน 15 วันทำการ",
	-- 	"ทุกวันมีโอกาสเล่นห้องชิงชิปเงินสด 2 และ 5 บาทฟรีห้องละ 10 ครั้ง",
	-- 	"ผู้เล่นที่ได้รางวัลจริงสามารถกรอกข้อมูลรับรางวัลได้ตลอดเวลาที่ห้างชิปเงินสด",
	-- 	"ทุกวันระบบจะเพิ่มบัตรเติมเงินในเวลา 12:00 น. และ 20:00 น",
	-- 	"สามารถเช็ครหัส PIN ของบัตรเติมเงินได้ที่บันทึกการแลก"
	-- };

	self.loadings_ = {}
	self.schedulerPool_ = bm.SchedulerPool.new()
	self.schedulerPool_:loopCall(handler(self, self.onLoopCall_), 1)
end

-- 加载Tips Json数据
function EnterTipsManager:loadTipsJson(url)
	print("loadTipsJson.url::::"..url)
	bm.HttpService.GET_URL(
		url, 
		{}, 
		function(data)
			-- print("loadTipsJson.data::::"..data)
			local retJson = json.decode(data);
			if retJson and #retJson > 0 then
				self.tips_ = retJson;
			end
		end,
		function()
			print("error")
		end)
end

-- 随机一个Tips信息
function EnterTipsManager:getRandomTips()
	if self.tips_ then
		return self.tips_[math.random(1, #self.tips_)]
	else
		return bm.LangUtil.getText("ROOM", "ENTERING_MSG")
	end
end

-- 注册一个RoomLoading
function EnterTipsManager:reg(roomLoading)
	if not self:isExistLoading_(roomLoading) then
		local cfg = {}
		cfg.loading = roomLoading;
		cfg.time = os.time();

		table.insert(self.loadings_, #self.loadings_+1, cfg);
	end
end

-- 移除RoomLoading
function EnterTipsManager:unreg(roomLoading)
	local len = #self.loadings_;
	for i=1,len do
		if self.loadings_[i].loading == roomLoading then
			table.remove(self.loadings_, i);
			break;
		end
	end
end

-- 判断队列中RoomLoading是否存在
function EnterTipsManager:isExistLoading_(roomLoading)
	for k,v in pairs(self.loadings_) do
		if v.loading == roomLoading then
			return true;
		end
	end
	return false;
end

-- 定义处理队列中的RoomLoading换Tips信息
function EnterTipsManager:onLoopCall_()
	local time = os.time();
	for k,v in pairs(self.loadings_) do
		if (time - v.time) > DEFAULT_INTERVAL_TIME then
			v.time = time;
			if v.loading and v.loading.lbl then
				v.loading.lbl:setString(self:getRandomTips());
			end
		end
	end

	return true;
end

-- 清理定時器
function EnterTipsManager:onCleanup()
	self.schedulerPool_:clearAll()
end

return EnterTipsManager;