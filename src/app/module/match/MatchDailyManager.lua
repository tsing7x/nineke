--
-- Author: hlf
-- Date: 2015-11-06 11:03:09
-- 比赛场每日任务管理

local MatchDailyManager = class("MatchDailyManager");

-- 需要同步比赛场每日任务列表
MatchDailyManager.EVENT_SYNCH_DAILYLIST = "EVENT_SYNCH_DAILYLIST"
-- 有新完成的每日任务，等待领取奖励
MatchDailyManager.EVENT_WAIT_DAILYREWARD = "EVENT_WAIT_DAILYREWARD"
-- 打开每日任务奖励弹出框
MatchDailyManager.EVENT_OPENDAILYREWARD = "EVENT_OPENDAILYREWARD"

MatchDailyManager.STATUS_UNFINISH = 0;
MatchDailyManager.STATUS_UNREWARD = 1;
MatchDailyManager.STATUS_FINISHED = 2;

local MATCHDAILY_COOKIE_KEY = "MATCHDAILY_COOKIE_KEY"
--[[
SVN_MATCHDAILY_INFO_CHANGE：

{
	id=0,						-- 比赛场每日任务id
	desc="在任意比赛场玩牌10",	-- 描述信息
	num=1,						-- 完成次数
	total=10,					-- 需要完成次数
	status=0,					-- 完成状态0未完成,1已完成未领取，2为已领取
								(客户端维护status这个状态，PHP拉去只返回未完成或未领取的每日任务)
}
{
			ttype: 1, // 任务类型,
			name: 'xx', // 任务名称
			step: 2, // 任务阶段
			cur: 1, // 用户当前完成进度
			task: 5, // 目标进度
			status: 0, // 0未完成，1完成，可领奖
		},
]]

function MatchDailyManager:ctor()
	self.dailyList_ = nil
	self.isDailyReward_ = false;-- 用于标记是否为有奖可领状态
	self.matchRoomEndId_ = bm.EventCenter:addEventListener(nk.eventNames.MATCH_ROOM_END, handler(self, self.onMatchRoomEndHandler_))
end

-- 处理比赛场结束，清理掉每日任务缓存数据信息
function MatchDailyManager:onMatchRoomEndHandler_(evt)
	self.dailyList_ = nil;
end

-- 拉取PHP每日任务列表
function MatchDailyManager:synchPhpDailyList()
	if not self.dailyList_ then
		bm.HttpService.POST({
				mod = "Match",
				act = "tasks" --act = "daily"
			},
			function(data)
				local retJson = json.decode(data);
				if retJson and retJson.ret == 0 then
					self:parseData_(retJson);
				end
			end,
			function()

			end
		)
	else
		self:callBackParseData_();
	end
end

function MatchDailyManager:saveSynchTime()
	local today = os.date('%Y%m%d')
	self.lastSynchTime_ = today;
end

function MatchDailyManager:isNeedSynchData()
	local save_day = self.lastSynchTime_;
	if tostring(save_day) == tostring(os.date('%Y%m%d')) then
		return false
	else
		return true
	end
end

-- 检测超过第二天需要同步数据
function MatchDailyManager:checkSynchData()
	if self:isNeedSynchData() then
		self.dailyList_ = nil;
		self:synchPhpDailyList();
	end
end

-- 解析PHP的数据
function MatchDailyManager:parseData_(retJson)
	self.dailyList_ = {}
	-- 
	local item;
	local len = #retJson.data;
	for i=1,len do
		item = retJson.data[i];
		info = {}
		info.id = item.ttype;		-- 任务类型
		info.desc = item.name;		-- 任务名称
		info.step = item.step;		-- 任务阶段
		info.status = item.status;	-- 0未完成，1完成，可领奖
		info.num = item.cur;		-- 用户当前完成进度
		info.total = item.task;		-- 目标进度

		table.insert(self.dailyList_, #self.dailyList_+1, info)
	end

	self:callBackParseData_();

	self:saveSynchTime();
end

function MatchDailyManager:callBackParseData_()
	bm.EventCenter:dispatchEvent({name=MatchDailyManager.EVENT_SYNCH_DAILYLIST})

	self:touchDailyReward();
end

-- Server同步每日任务
function MatchDailyManager:updateSvData()
	self.isDailyReward_ = true;
	bm.EventCenter:dispatchEvent({name=MatchDailyManager.EVENT_WAIT_DAILYREWARD, data=true})
end

-- 获取比赛场每日任务列表
function MatchDailyManager:getDailyList()
	return self.dailyList_;
end

-- 判断是否有已完成未领取的每日任务
function MatchDailyManager:isUnRewardState()
	local result = false;
	for idx,item in pairs(self.dailyList_) do
		if item.status == MatchDailyManager.STATUS_UNREWARD then
			result = true;
			break;
		end
	end
	return result;
end

-- 根据Id获取比赛场每日任务
function MatchDailyManager:getDailyItemById(id)
	local result = nil;
	for idx,item in pairs(self.dailyList_) do
		if item.id == id then
			result = item;
			break;
		end
	end
	return result;
end

-- 根据Id删除比赛场每日任务
function MatchDailyManager:removeDailyItemById(id)
	local item;
	local len = #self.dailyList_;
	for i=1,len do
		item = self.dailyList_[i];
		if item.id == id then
			table.remove(self.dailyList_, i);
			return item;
		end
	end
	return nil;
end

-- 根据任务ID更新任务内容
function MatchDailyManager:modifyDailyItemById_(id, item)
	local info = self:getDailyItemById(id);
	if info and item.name and item.step and item.status and item.cur and item.task then
		info.desc = item.name;		-- 任务名称
		info.step = item.step;		-- 任务阶段
		info.status = item.status;	-- 0未完成，1完成，可领奖
		info.num = item.cur;		-- 用户当前完成进度
		info.total = item.task;		-- 目标进度
	else
		info = nil;
	end
	return info;
end

-- 领取每日任务奖励
function MatchDailyManager:rewardDailyById(id, callback)
	bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="start"})
	bm.HttpService.POST({
			mod = "Match",
			act = "taskReward",
			ttype = id
		},
		function(data)
			local retJson = json.decode(data);
			if retJson and retJson.ret == 0 then
				-- 往外派发奖励数据
				if retJson.data.reward then
					local reward = retJson.data.reward;
					local info;
					local rewards = {};
					-- 比赛券
					if reward.gameCoupon then
						info={};
						info.type = 2;
						info.icon = "match_gamecoupon.png"
						info.txt = bm.LangUtil.getText("MATCH", "GAMECOUPON").." + "..tostring(reward.gameCoupon)
						info.num = reward.gameCoupon;
						info.val = reward.gameCoupon;
						table.insert(rewards, #info+1, info)
					end

					-- 筹码
					if reward.chips then
						info={};
						info.type = 1;
						info.icon = "match_chip.png"
						info.txt = bm.LangUtil.getText("MATCH", "MONEY").." + "..tostring(reward.chips)
						info.num = bm.formatBigNumber(reward.chips);
						info.val = reward.chips;
						table.insert(rewards, #info+1, info)
					end

					-- 现金币
					if reward.score then
						info={};
						info.type = 3;
						info.icon = "match_score.png"
						info.txt = bm.LangUtil.getText("MATCH", "SCORE").." + "..tostring(reward.score)
						info.num = bm.formatBigNumber(reward.score);
						info.val = reward.score;
						table.insert(rewards, #info+1, info)
					end

					-- 金券
					if reward.gold then
						info={};
						info.type = 4;
						info.icon = "match_goldcoupon.png"
						info.txt = bm.LangUtil.getText("MATCH", "GOLDCOUPON").." + "..tostring(reward.gold)
						info.num = bm.formatBigNumber(reward.gold);
						info.val = reward.gold;
						table.insert(rewards, #info+1, info)
					end

					-- 门票
					if reward.tick then
						info={};
						info.type = 5;
						info.icon = "matchTick_icon.png"
						info.txt = bm.LangUtil.getText("TICKET", "label").." + "..tostring(reward.tick)
						info.num = bm.formatBigNumber(reward.tick);
						info.val = reward.tick;
						table.insert(rewards, #info+1, info)
					end
					bm.EventCenter:dispatchEvent({name=MatchDailyManager.EVENT_OPENDAILYREWARD, data=rewards})
				end

				local minfo;
				if retJson.data.next then
					minfo = self:modifyDailyItemById_(id, retJson.data.next);			
				end

				if callback then
					callback(id, minfo);
				end

				self:touchDailyReward();

				if device.platform == "android" or device.platform == "ios" then
			        cc.analytics:doCommand{command = "event", args = {eventId = "match_dailyLogo_reward"}}
			    end
			else
				bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="end"})
			end
		end,
		function(data)
			bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="end"})
		end
	)
end

function MatchDailyManager:touchDailyReward()
	self.isDailyReward_ = self:isUnRewardState();
	bm.EventCenter:dispatchEvent({name=MatchDailyManager.EVENT_WAIT_DAILYREWARD, data=self.isDailyReward_})
end

function MatchDailyManager:isDailyReward()
	return self.isDailyReward_;
end

function MatchDailyManager:dispose()
	if self.matchRoomEndId_ then
		bm.EventCenter:removeEventListener(self.matchRoomEndId_)
		self.matchRoomEndId_ = nil;
	end
end

return MatchDailyManager;