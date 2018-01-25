--
-- Author: HLF(IdaHuang@boyaa.com)
-- Date: 2015-12-31 09:37:39

local PRE_DAYS = 7;
local requestRetryTimes_ = 3;
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local MatchBillDetailController = class("MatchBillDetailController");

function MatchBillDetailController:ctor(view)
	self.view_ = view;
	self.cacheLogs_ = {}
end

-- 获取最近七天日期列表
function MatchBillDetailController:getDays()
	local daysData = self:getLatelyDays_(PRE_DAYS);
	local key;
	local days = {};
	local daysKey = {}
	for i=1,#daysData do
		table.insert(days, #days+1, daysData[i].day);
		local dayStr = tostring(daysData[i].day);
		local monthStr = tostring(daysData[i].month);
		dayStr = string.len(dayStr) == 1 and "0"..dayStr or dayStr;
		monthStr = string.len(monthStr) == 1 and "0"..monthStr or monthStr;
		key = tostring(daysData[i].year)..monthStr..dayStr
		daysData[i].key = key;
	end
	return daysData, days;
end

-- 获取日志
-- day 查询的日期
-- type 1是现金币，3是比赛券
function MatchBillDetailController:getBillDetailLog(day, type)
	local isload = false;
	local page = 1;
	local key = day.."_"..type;
	if not self.cacheLogs_[key] then
		isload = true;
	elseif not self.cacheLogs_[key].isEnded then
		isload = true;
		page = self.cacheLogs_[key].page + 1;
	end

	if isload then
		self.propLogRequestId_ = bm.HttpService.POST(
				{
					mod="Match",
					act="propLog",
					day=day,
					toolId=type,
					p=page,
					limit=10
				},
				function(data)
					if data then
						local retData = json.decode(data);
						if retData and retData.ret == 0 then
							local cfg;
							if not self.cacheLogs_[key] then
								cfg = {};
								cfg.data = {}
								self.cacheLogs_[key] = cfg;
							end
							cfg = self.cacheLogs_[key];
							cfg.page = page;
							table.insertto(cfg.data, retData.data);
							if #retData.data == 0 then
								cfg.isEnded = true;
							else
								cfg.isEnded = false;
							end
						end
					end
					self:dispatchPropLogEvent(key)
				end,
				function()
					self:dispatchPropLogEvent(key)
				end
			)
	else
		self:dispatchPropLogEvent(key)
	end	
end

function MatchBillDetailController:dispatchPropLogEvent(key)
	bm.EventCenter:dispatchEvent({name="Match_PropLog", data=self.cacheLogs_[key]})
end

function MatchBillDetailController:dispose()
	bm.HttpService.CANCEL(self.propLogRequestId_);
end

-- 获取最近preDays天日期，不要超过一个月
function MatchBillDetailController:getLatelyDays_(preDays)
    local curTimestamp = os.time();
    local curDay = bm.TimeUtil:getDay(curTimestamp);
    local preMonthTime = curTimestamp - curDay*3600*24;
    local preDay = bm.TimeUtil:getDay(preMonthTime);

    local item;
    local list = {}
    for i=1,preDays do
        if curDay > 0 then
        	item = {
        		year=bm.TimeUtil:getYear(curTimestamp),
        		month=bm.TimeUtil:getMonth(curTimestamp),
        		day=curDay
        	}
        	curDay = curDay - 1;
        elseif preDay > 0 then
        	item = {
        		year=bm.TimeUtil:getYear(preMonthTime),
        		month=bm.TimeUtil:getMonth(preMonthTime),
        		day=preDay
        	}
        	preDay = preDay - 1;
        end
        table.insert(list, #list+1, item);
    end
    return list;
end

return MatchBillDetailController;