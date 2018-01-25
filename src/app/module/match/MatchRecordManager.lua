--
-- Author: hlf
-- Date: 2015-11-18 18:51:33
-- 管理比赛场参赛记录(用于缓存比赛记录，当比赛场比赛结束后做相应的清理工作)

local logger = bm.Logger.new("ArenaSponsorPopup")
local MatchRecordManager = class("MatchRecordManager")

function MatchRecordManager:ctor()
	-- 玩家个人档参赛记录
	self.matchLogList_ = nil;
	-- 玩家个人档统计数据
	self.matchStats_ = nil;
	-- 比赛场大厅相应比赛场的参赛记录
	self.hallMatchLogList_ = {};
	-- 监听比赛场结束事件
	self.matchRoomEndId_ = bm.EventCenter:addEventListener(nk.eventNames.MATCH_ROOM_END, handler(self, self.onMatchRoomEndHandler_))
end

-- 处理比赛场结束，清理掉每日任务缓存数据信息
function MatchRecordManager:onMatchRoomEndHandler_(evt)
	self.matchStats_ = nil;
	self.matchLogList_ = nil;

	logger:info("MatchRecordManager:onMatchRoomEndHandler_::::::"..tostring(evt.data))
	local matchLevel = tonumber(evt.data)
	self.hallMatchLogList_[matchLevel] = nil;

	self:cleanMatchOnlineCount();
end

-- 同步个人档参赛记录
function MatchRecordManager:asyncMatchLog()
	if not self.matchLogList_ then
		self.setMatchLogRequestId_ = bm.HttpService.POST(
	        {
	            mod="Match",
	            act="log",
	        },
	        function (data)
	        	logger:info("MatchRecordManager:asyncMatchLog", data)
	            local callBackData =  json.decode(data)
	            -- Response: { "ret":0, "data":[ { id:11, // 场次：11免费场，21中级场，31高级场 name: 免费场, rank: 1, // 名次 reward: { giftId: 1049, // 礼物，1047金杯,1048银杯,1049铜杯 score: 100, // 积分 goldCoupon: 100, // 金券 gameCoupon: 100, // 比赛券 }, time: 1440128260, // 参赛时间 }, ] } ```
	            if callBackData and callBackData.ret == 0 then
	                self.matchLogList_ = callBackData.data;
	                self:dispatchMatchLog_();
	            end
	        end, 
	        function ()
	            
	        end
	    );
	else
		self:dispatchMatchLog_();
	end
end
-- 派发个人当参赛记录
function MatchRecordManager:dispatchMatchLog_()
	bm.EventCenter:dispatchEvent({name=nk.eventNames.MATCH_ASYNC_RECORD_LOG, data=self.matchLogList_})
end

-- 同步比赛场大厅相应比赛场的参赛记录
function MatchRecordManager:asyncHallMatchLog(matchLevel, page)
	local isload = false;
	if not self.hallMatchLogList_[matchLevel] then
		isload = true;
	elseif not self.hallMatchLogList_[matchLevel].isEnded and self.hallMatchLogList_[matchLevel].page < page then
		isload = true;
	end

	if isload then
		bm.HttpService.POST(
			{
				mod="Match",
				act="rankLog",
				level=matchLevel,
				p=page,
			},
			function(data)
				logger:info("MatchRecordManager:asyncHallMatchLog", data)

				local callBackData = json.decode(data);
				if callBackData and callBackData.ret then
					local cfg;
					if not self.hallMatchLogList_[matchLevel] then
						cfg = {};
						cfg.data = {};
						self.hallMatchLogList_[matchLevel] = cfg;
					else
						cfg = self.hallMatchLogList_[matchLevel];
					end

					for k,v in pairs(callBackData.data) do
						if v.reward and v.reward.real then
							v.reward.real.img = nk.userData.cdn .. v.reward.real.img;
							v.reward.real.image = v.reward.real.img;
						end
					end

					-- id: 1,
					-- name: xxxx,
					-- type: 1, // 1实物弹地址，2现金卡弹PIN码，3暂定E2P奖励
					-- pin: 00000, // 如果是type=2才会返回
					-- img: aaa.png, // 奖品图片
					
					cfg.page = page;
					cfg.rank = callBackData.best.rank;
					cfg.time = callBackData.best.time;
					table.insertto(cfg.data, callBackData.data)
					if #callBackData.data == 0 then
						cfg.isEnded = true;
					else
						cfg.isEnded = false;
					end

					self:dispatchHallMatchLog_(matchLevel);
				end
			end,
			function()

			end
		);
	else
		self:dispatchHallMatchLog_(matchLevel);
	end
end

-- 派发比赛场大厅相应比赛场的参赛记录
function MatchRecordManager:dispatchHallMatchLog_(matchLevel)
	bm.EventCenter:dispatchEvent({name=nk.eventNames.MATCH_ASYNC_HALL_RECORD_LOG, data=self.hallMatchLogList_[matchLevel]})
end

-- 玩家个人档统计数据
function MatchRecordManager:asyncMatchStat()
	if not self.matchStats_ then
		self.matchStatsId_ = bm.HttpService.POST(
				{
					mod="Match",
					act="stat",
				},
				function(data)
					logger:info("MatchRecordManager:asyncMatchStat", data)
					local callBackData = json.decode(data);
					if callBackData and callBackData.ret == 0 then
						self.matchStats_ = callBackData.data;
						self:dispatchMatchStat_();
					else
						
					end
				end
			)
	else
		self:dispatchMatchStat_();
	end
end

-- 派发玩家个人档统计数据
function MatchRecordManager:dispatchMatchStat_()
	bm.EventCenter:dispatchEvent({name=nk.eventNames.MATCH_ASYNC_STAT_LOG, data=self.matchStats_})
end

function MatchRecordManager:dispose()
	-- 玩家个人档参赛记录
	self.matchLogList_ = nil;
	-- 玩家个人档统计数据
	self.matchStats_ = nil;
	-- 比赛场大厅相应比赛场的参赛记录
	self.hallMatchLogList_ = {};
	
	if self.matchRoomEndId_ then
		bm.EventCenter:removeEventListener(self.matchRoomEndId_)
		self.matchRoomEndId_ = nil;
	end
	if self.setMatchLogRequestId_ then
		bm.HttpService:CANCEL(self.setMatchLogRequestId_);
		self.setMatchLogRequestId_ = nil;
	end
end

-- 清理比赛场同时在线人数
function MatchRecordManager:cleanMatchOnlineCount()
	nk.userDefault:setIntegerForKey("MatchRoom_Online_Count", 0);
end

-- 保存比赛场同时在线人数
function MatchRecordManager:saveMatchOnlineCount(cnt)
	local totalOnline = nk.userDefault:getIntegerForKey("MatchRoom_Online_Count", 0);
	if totalOnline == 0 then
		nk.userDefault:setIntegerForKey("MatchRoom_Online_Count", cnt);
	end
end

-- 获取比赛场同时在线人数
function MatchRecordManager:getMatchOnlineCount()
	return nk.userDefault:getIntegerForKey("MatchRoom_Online_Count", 0);
end

return MatchRecordManager;