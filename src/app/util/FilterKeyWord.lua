--
-- Author: hlf
-- Date: 2015-08-19 14:29:37
--过滤聊天敏感字
local FilterKeyWord = class("FilterKeyWord");

FilterKeyWord.Keys = {
	'เซง','ควย','ไอ้สัส','มัน','จิ๋ม','จรวย','จังไร','ดอกทอง','แตด','ส้นตีน','ตีน','กรูส์','กรู','กู','เยส','เย็ด','มึง','มรึง','อีหมา','แม่มึง','พ่อมึง','เชี้ย','อี','สัด','สาด','สัตว์','หอย','หี','ร่าน','ตอแหล','อิดอก','กระหรี่','ยัดแม่','สาส','การค้าขาย','การมอบให้','การโอน','การซื้อขายชิป','การซื้อขาย','ราคา','โกงชิประบบ','การจ่าย','การแลกเปลี่ยน','รับของค่อยจ่ายเงิน','การจำหน่าย',
	'เหี้ย','หัวควย','เบอร์ติดต่อ','เบอรติดต่อ','video','วีดีโอ','ขายด่วน','ขาย','แท็กซัสไทย','โอน','เติมเงินซื้อชิป','เติมเงินซื้อชิบ','เติมเงินซื้อชิบ ไพ่ป๊อกเด้ง คลิกที่นี่','สัส','สาส','แมร่ง','ขายชิป','เบอร์โทร','ควาย',
	'แม่ง','ถุ้ยไพ่','ไอ้สาส','ไอ้ควาย','รับซื้อ','ขายเอม','ขายเอ็ม','ขายM'
};

function FilterKeyWord:ctor()
	-- 针对数组进行排序
	table.sort(FilterKeyWord.Keys, function(a, b)
		return string.len(a)>string.len(b);
	end);

	self:readScheme();
	-- FilterKeyWord.Keys = bm.LangUtil.getText("CHAT","KEYS");
end

function FilterKeyWord:readScheme()
	self.wordArr_ = {};
	self.friendNameArr_ = {};
	-- 
	local str;
	local word;
	local idx;
	local items;
	for i=1,#FilterKeyWord.Keys do
		str = FilterKeyWord.Keys[i];
		word =  string.sub(str, 1, 1);
		if not self.friendNameArr_[word] then
			idx = #self.wordArr_+1;
			self.friendNameArr_[word] = idx;

			items = {};
			table.insert(items, #items+1, str);
			table.insert(self.wordArr_, idx, items);
		else
			idx = self.friendNameArr_[word];
			items = self.wordArr_[idx];
			table.insert(items, #items+1, str);
		end
	end
end

function FilterKeyWord:checkWord(msg)
	if not msg then
		return "";
	end
	-- 
	local idx;
	local word;
	local result = msg;
	local msgArr = self:stringToChar2_(msg);
	for i=1,#msgArr do
		word = msgArr[i];
		idx = self.friendNameArr_[word];
		if idx then
			result = self:deepCheck_(msg, msgArr, idx)
		end
	end
	return result;
end

function FilterKeyWord:deepCheck_(checkMsg, arr, idx)
	local deepWordArr = self.wordArr_[idx];
	local replaceStr;
	local len = 0;
	for i=1,#deepWordArr do
		checkMsg = string.gsub(checkMsg, deepWordArr[i], "***");
	end
	return checkMsg;
end

-- 拆分出单个字符
function FilterKeyWord:stringToChar_(str)
    local list = {}
    local len = string.len(str)
    local i = 1 
    while i <= len do
        local c = string.byte(str, i)
        local shift = 1
        if c > 0 and c <= 127 then
            shift = 1
        elseif (c >= 192 and c <= 223) then
            shift = 2
        elseif (c >= 224 and c <= 239) then
            shift = 3
        elseif (c >= 240 and c <= 247) then
            shift = 4
        end
        local char = string.sub(str, i, i+shift-1)
        i = i + shift
        table.insert(list, char)
    end
	return list, len
end

function FilterKeyWord:stringToChar2_(str)
    local list = {}
    local len = string.len(str)
    for i=1,len do
    	table.insert(list, #list+1, string.sub(str, i, i));
    end
	return list, len
end

return FilterKeyWord;