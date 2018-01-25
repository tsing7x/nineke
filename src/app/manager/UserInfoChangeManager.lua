--
-- Author: hlf
-- Date: 2015-12-01 10:07:50
-- 处理玩家属性发生变化后动画效果
local BoxRewardAnimation = import("app.module.match.dailyMatch.BoxRewardAnimation")
local RoomViewPosition = import("app.module.room.views.RoomViewPosition")

local UserInfoChangeManager = class("UserInfoChangeManager");
UserInfoChangeManager.ChooseArenaRoom = "ChooseArenaRoomView";
UserInfoChangeManager.MatchRoomScene = "MatchRoomSceneView";
UserInfoChangeManager.RoomScene = "RoomSceneView"
UserInfoChangeManager.PdengScene = "PdengSceneView"
UserInfoChangeManager.ScoreMarket = "ScoreMarketView";
UserInfoChangeManager.MainHall = "MainHallView";
UserInfoChangeManager.LuckWheelScorePopup = "LuckWheelScorePopup";

function UserInfoChangeManager:ctor()
	self.cfgs_ = {}
	self.isPause_ = false;
	self.stack_ = {}
	-- 播放宝箱掉落物品事件
	self.boxRewardAnimationId_ = bm.EventCenter:addEventListener("Player_BoxRewardAnimation", handler(self, self.onBoxRewardAnimation_))
	-- 比赛场结束事件--弹出奖励框
	self.matchRoomEndId_ = bm.EventCenter:addEventListener(nk.eventNames.MATCH_ROOM_END, handler(self, self.onMatchRoomEnd_))
	-- P.SVR_CMD_USER_MATCH_SCORE      = 0x2307    -- 结束比赛征程
	-- 比赛场结束事件
	self.svrCmdUserMatchScoreId_ = bm.EventCenter:addEventListener(nk.eventNames.SVR_CMD_USER_MATCH_SCORE, handler(self, self.onSvrCmdUserMatchScore_))
	-- 开始比赛
	self.loginMatchRoomSuccId_ = bm.EventCenter:addEventListener(nk.eventNames.LOGIN_MATCH_ROOM_SUCC, handler(self, self.onLoginMatchRoomSucc_))
	-- 颁奖界面关闭后触发的事件
	self.matchRewardPopupEndId_ = bm.EventCenter:addEventListener(nk.eventNames.MATCH_REWARDPOPUP_END, handler(self, self.onMatchRewardPopupEnd_));
	-- 比赛场大厅进场动画播放完成后的事件
	self.chooseArenaPlayShowAnimId_ = bm.EventCenter:addEventListener(nk.eventNames.CHOOSEARENA_PLAY_SHOW_ANIM, handler(self, self.onChooseArenaPlayShowAnim_))
	-- 
	
	self.changeSchedulerPool_ = bm.SchedulerPool.new()
	self.isNeedRewardPopupId_ = false;
	self.isNeedRewardPopupId_ = -1;
end

-- 比赛场大厅进场动画播放完成后的事件
function UserInfoChangeManager:onChooseArenaPlayShowAnim_(evt)
	self.isNeedRewardPopupId_ = self.isNeedRewardPopupId_ - 1;
	if self.isNeedRewardPopupId_ == 0 then
		self.isPause_ = false;
		self:refreshStack_(true);
		self.isNeedRewardPopupId_ = -1;
	end
end
-- 颁奖界面关闭后触发的事件
function UserInfoChangeManager:onMatchRewardPopupEnd_(evt)
	self.isNeedRewardPopupId_ = self.isNeedRewardPopupId_ - 1;
	local curScene = display.getRunningScene()
    if curScene.name ~= "MatchRoomScene" or self.isNeedRewardPopupId_ == 0 then
    	self.isPause_ = false;
		self:refreshStack_(true);
    end 
end
-- 比赛场开始 清理掉暂停状态
function UserInfoChangeManager:onLoginMatchRoomSucc_(evt)
	self.isPause_ = false;
	-- self:refreshStack_(true);
end
-- 比赛场结束事件--弹出奖励框
function UserInfoChangeManager:onSvrCmdUserMatchScore_(evt)
	self.isPause_ = true;
	self.isNeedRewardPopupId_ = 2;
	-- self:refreshStack_(true);
end
-- 比赛场结束事件
function UserInfoChangeManager:onMatchRoomEnd_(evt)
	self.isPause_ = true;
end
-- 控制播放BoxRewardAnimation动画与属性实现播放动画的同步
function UserInfoChangeManager:onBoxRewardAnimation_(evt)
	if evt.data == "start" then
		self.isPause_ = true;
	elseif evt.data == "end" then
		self.isPause_ = false;
		self:refreshStack_(false);
	elseif evt.data == "Wheel_start" then
		self.isPause_ = true;
	elseif evt.data == "Wheel_end" then
		self.isPause_ = false;
		self:refreshStack_(true);
    elseif evt.data == "slot_start" then
        self.isPause_ = true
        self.enableSubMoney_ = true
    elseif evt.data == "slot_end" then
        self.isPause_ = false
        self.enableSubMoney_ = false
        self:refreshStack_(true)
	end		
end
-- 刷新积压的堆栈数据列表
function UserInfoChangeManager:refreshStack_(isUpdate)
	while #self.stack_ > 0 do
		local item = self.stack_[1];
		if item.type == 1 then
			self:updateMoneyChange(item.value, isUpdate);
		elseif item.type == 2 then
			self:updateUserProp(item.value, isUpdate);
		elseif item.type == 3 then
			self:userInfoChange(item.value, isUpdate);
		elseif item.type == 4 then
			self:updateHddjChange(item.value, isUpdate)
		elseif item.type == 5 then
			if item.value and type(item.value) == "function" then
				item.value()
			end
		elseif item.type == 11 then
			self:updateKickChange(item.value, isUpdate)
		end
		-- 
		table.remove(self.stack_, 1)
	end
end

-- 筹码发生变化属性变化
function UserInfoChangeManager:updateMoneyChange(retData, isUpdate)
    local needCache = true
    if self.enableSubMoney_ then
        if tonumber(retData.money) < nk.userData.money then
            needCache = false
        end
    end
	if self.isPause_ and needCache then
		local item = {}
		item.type = 1;
		item.value = retData;
		table.insert(self.stack_, #self.stack_+1, item);
        return
	end
	-- 
	if isUpdate == nil then
		isUpdate = true;
	end
	-- 
	local updateKeys = {}
	if retData.money then -- 游戏币
	    nk.userData.changeMoney = tonumber(retData.money) - nk.userData.money; -- 金币动画
	    if nk.userData.changeMoney ~= 0 then
		    table.insert(updateKeys, #updateKeys+1, {key="money", value=nk.userData.changeMoney})
		    nk.userData.money = tonumber(retData.money)
		end
		nk.userData.changeMoney = nil
	end
	if retData.gcoins then-- 黄金币
		nk.userData.changeGcoins = tonumber(retData.gcoins) - tonumber(nk.userData.gcoins)
		if nk.userData.changeGcoins ~= 0 then
		    table.insert(updateKeys, #updateKeys+1, {key="gcoins", value=nk.userData.changeGcoins})
		    nk.userData.gcoins = tonumber(retData.gcoins)
		end
		nk.userData.changeGcoins = nil
	end
	if retData.coins then -- 现金币
		nk.userData.changeScore = tonumber(retData.coins) - tonumber(nk.userData.score)
        if nk.userData.changeScore ~= 0 then
        	table.insert(updateKeys, #updateKeys+1, {key="score", value=nk.userData.changeScore})
        	nk.userData.score = tonumber(retData.coins)
        end
        nk.userData.changeScore = nil
	end
    if #updateKeys > 0 and isUpdate then
    	self:update_(updateKeys)
    end
end
-- 
function UserInfoChangeManager:updateOtherMethod(callback)
	if not callback then
		return
	end

	if self.isPause_ then
		local item = {}
		item.type = 5;
		item.value = callback;
		table.insert(self.stack_, #self.stack_+1, item);
		return;
	end
	-- 
	if callback then
		callback()
	end
end
-- 变化的幅度
function UserInfoChangeManager:updateUserProp_change(list, isUpdate)
	local prop = nil
	for i=1,#list,1 do
		prop = list[i]
		if prop.pid==2 then -- 金券
			prop.num = tonumber(nk.userData.goldCoupon)+tonumber(prop.count)
		elseif prop.pid==3 then -- 比赛券
			prop.num = tonumber(nk.userData.gameCoupon)+tonumber(prop.count)
		elseif prop.pid==4 then -- 游戏币
			prop.money = tonumber(nk.userData.money)+tonumber(prop.count)
		elseif prop.pid==5 then -- 现金币
			prop.score = tonumber(nk.userData.score)+tonumber(prop.count)
		elseif prop.pid==6 then -- 黄金币
			prop.gcoins = tonumber(nk.userData.gcoins)+tonumber(prop.count)
		end
	end
	self:updateUserProp(list,isUpdate)
end
-- 用户属性发生变化属性变化
function UserInfoChangeManager:updateUserProp(list, isUpdate)
	if self.isPause_ then
		local item = {}
		item.type = 2;
		item.value = list;
		table.insert(self.stack_, #self.stack_+1, item);
		return;
	end
	-- 
	if not list then
		return;
	end
	-- 
	if isUpdate == nil then
		isUpdate = true;
	end
	-- 
	local updateKeys = {}
	local prop = nil
    for i=1,#list,1 do
        prop = list[i]
        if prop.pid==2 then -- 金券
            nk.userData.changeGoldCoupon = tonumber(prop.num) - tonumber(nk.userData.goldCoupon)
            if nk.userData.changeGoldCoupon ~= 0 then
            	table.insert(updateKeys, #updateKeys+1, {key="goldCoupon", value=nk.userData.changeGoldCoupon})
            	nk.userData.goldCoupon = prop.num
            end
            nk.userData.changeGoldCoupon = nil
        elseif prop.pid==3 then -- 比赛券
            nk.userData.changeGameCoupon = tonumber(prop.num) - tonumber(nk.userData.gameCoupon)
            if nk.userData.changeGameCoupon ~= 0 then
            	table.insert(updateKeys, #updateKeys+1, {key="gameCoupon", value=nk.userData.changeGameCoupon})
            	nk.userData.gameCoupon = prop.num
            end
            nk.userData.changeGameCoupon = nil
        elseif prop.pid==4 then -- 游戏币
            nk.userData.changeMoney = tonumber(prop.money) - tonumber(nk.userData.money)
            if nk.userData.changeMoney ~= 0 then
            	table.insert(updateKeys, #updateKeys+1, {key="money", value=nk.userData.changeMoney})
            	prop.num = prop.money
            	nk.userData.money = prop.num
            end
            prop.num = prop.money
            nk.userData.changeMoney = nil
        elseif prop.pid==5 then -- 现金币
        	nk.userData.changeScore = tonumber(prop.score) - tonumber(nk.userData.score)
            if nk.userData.changeScore ~= 0 then
            	table.insert(updateKeys, #updateKeys+1, {key="score", value=nk.userData.changeScore})
            	nk.userData.score = prop.score
            end
            nk.userData.changeScore = nil
        elseif prop.pid==6 then -- 黄金币
        	nk.userData.changeGcoins = tonumber(prop.gcoins) - tonumber(nk.userData.gcoins)
        	if nk.userData.changeGcoins ~= 0 then
            	table.insert(updateKeys, #updateKeys+1, {key="gcoins", value=nk.userData.changeGcoins})
            	nk.userData.gcoins = prop.gcoins
            end
            nk.userData.changeGcoins = nil
        end
    end
    -- 
    if #updateKeys > 0 and isUpdate then
    	self:update_(updateKeys)
    end
end
-- 监听玩家信息变化
function UserInfoChangeManager:userInfoChange(info, isUpdate)
	if self.isPause_ then
		local item = {}
		item.type = 3;
		item.value = info;
		table.insert(self.stack_, #self.stack_+1, item);
		return;
	end
	-- 
	if isUpdate == nil then
		isUpdate = true;
	end
	-- 
	local updateKeys = {}
	if info.score then
        nk.userData.changeScore = tonumber(info.score) - tonumber(nk.userData.score)
        if nk.userData.changeScore ~= 0 then
        	table.insert(updateKeys, #updateKeys+1, {key="score", value=nk.userData.changeScore})
        	nk.userData.score = info.score
        end
        nk.userData.changeScore = nil
    end
    -- 
    if info.gameCoupon then
        nk.userData.changeGameCoupon = tonumber(info.gameCoupon) - tonumber(nk.userData.gameCoupon)
        if nk.userData.changeGameCoupon ~= 0 then
        	table.insert(updateKeys, #updateKeys+1, {key="gameCoupon", value=nk.userData.changeGameCoupon})
        	nk.userData.gameCoupon = info.gameCoupon
        end
        nk.userData.changeGameCoupon = nil
    end
    -- 
    if info.goldCoupon then
        nk.userData.changeGoldCoupon = tonumber(info.goldCoupon) - tonumber(nk.userData.goldCoupon)
        if nk.userData.changeGoldCoupon ~= 0 then
        	table.insert(updateKeys, #updateKeys+1, {key="goldCoupon", value=nk.userData.changeGoldCoupon})
        	nk.userData.goldCoupon = info.goldCoupon
        end
        nk.userData.changeGoldCoupon = nil
    end
    -- 
    if #updateKeys > 0 and isUpdate then
    	self:update_(updateKeys)
    end
end

-- 互动道具更新
function UserInfoChangeManager:updateHddjChange(info, isUpdate)
	-- self:updateHddjChange({key="hddj", url=url, num=num});
	if self.isPause_ then
		local item = {}
		item.type = 4;
		item.value = info;
		table.insert(self.stack_, #self.stack_+1, item);
		return;
	end
	-- 
	if not info then
		return;
	end
	-- 
	if isUpdate == nil then
		isUpdate = true;
	end
	-- 
	local updateKeys = {}
	table.insert(updateKeys, #updateKeys+1, {key="hddj", value=info})
    -- 
    if #updateKeys > 0 and isUpdate then
    	self:update_(updateKeys)
    end
end

-- 踢人卡更新
function UserInfoChangeManager:updateKickChange(info, isUpdate)
	if self.isPause_ then
		local item = {}
		item.type = 11;
		item.value = info;
		table.insert(self.stack_, #self.stack_+1, item);
		return;
	end
	-- 
	if not info then
		return;
	end
	-- 
	if isUpdate == nil then
		isUpdate = true;
	end
	-- 
	local updateKeys = {}
	table.insert(updateKeys, #updateKeys+1, {key="kick", value=info})
    -- 
    if #updateKeys > 0 and isUpdate then
    	self:update_(updateKeys)
    end
end

--  更新属性
function UserInfoChangeManager:update_(keys)
	if #self.cfgs_ > 0 then
		local len = #self.cfgs_
		local cfg = self.cfgs_[len]
		local sameKeys = self:findSameKeys_(keys, cfg.keys)
		if sameKeys and #sameKeys > 0 then
			self:updateKeys_(cfg, sameKeys)
		end
		-- 处理其他场景监听函数
		for i=1,len-1 do
			cfg = self.cfgs_[i]
			sameKeys = self:findSameKeys_(keys, cfg.keys)
			if sameKeys and #sameKeys > 0 then
				if cfg.callback then
					cfg.callback();
				end
			end
		end
	end
end

-- 找出keys1在keys2中存在的相同key
function UserInfoChangeManager:findSameKeys_(updateKeys, keys)
	local result = {}
	for _,item in pairs(updateKeys) do
		for _,key in pairs(keys) do
			if item.key == key then
				table.insert(result, #result+1, item)
				break;
			end
		end
	end
	-- 
	return result;
end
-- 根据sceneView查找配置
function UserInfoChangeManager:findCfgByView(sceneView)
	local result = nil;
	for _,cfg in pairs(self.cfgs_) do
		if cfg.sceneView == sceneView then
			result = cfg;
			break;
		end
	end
	
	return result;
end
-- 
function UserInfoChangeManager:findLastView()
	local result = nil;
	if self.cfgs_ and #self.cfgs_ > 0 then
		local len = #self.cfgs_
		result = self.cfgs_[len]
	end
	return result;
end
-- 更新动画
function UserInfoChangeManager:updateKeys_(cfg, updateKeys)
	local item;
	for i=1,#updateKeys do
		local itype;
		local rect;
		item = updateKeys[i]
		if item.key == "money" then -- 筹码
			itype = 1;
		elseif item.key == "score" then --现金币
			itype = 3;
		elseif item.key == "gameCoupon" then -- 比赛券
			itype = 2;
		elseif item.key == "goldCoupon" then -- 金券
			itype = 4;
		elseif item.key == "hddj" then
			itype = 7;
		elseif item.key == "gcoins" then -- 黄金币
			itype = 9
		elseif item.key == "kick" then -- 踢人卡
			itype = 11
		end

		if itype then
			if cfg.targetIconPosFunc then
				rect = cfg.targetIconPosFunc(itype)
			else
				rect = RoomViewPosition.SeatPosition[5];
			end
			-- 
			-- if CF_DEBUG >= 5 then
				-- 如果是普通场大厅，显示 ChangeChipAnim
				if cfg.sceneView == UserInfoChangeManager.MainHall then
					bm.EventCenter:dispatchEvent({name="Play_ChipChangeAnimation"})
					app:tip(itype, item.value, rect.x, rect.y, 9999, 0, 32)
					-- nk.ui.ChangeChipAnim.new(9999):addTo(display.getRunningScene())
				else
					app:tip(itype, item.value, rect.x, rect.y, 9999)
				end
			-- end
		end
	end
	-- 
	if cfg.callback then
		cfg.callback();
	end
end
------------------------------------------------------------------------
-- sceneView:注册的场景
-- keys:需要监听的关键字"money"、"score"、"gameCoupon"、"goldCoupon"
-- targetIconPosFunc:为
function UserInfoChangeManager:reg(sceneView, keys, targetIconPosFunc, callback)
	local _, cfg = self:getCfgBySceneView_(sceneView);
	if not cfg then
		cfg = {}
		cfg.sceneView = sceneView;
		cfg.keys = keys or {};
		cfg.callback = callback;
		cfg.targetIconPosFunc = targetIconPosFunc;
		-- 
		table.insert(self.cfgs_, #self.cfgs_+1, cfg);
	else
		if keys then
			for _,key1 in pairs(keys) do
				for _,key2 in pairs(cfg.keys) do
					if key1 ~= key2 then
						table.insert(cfg.keys, #cfg.keys+1, key1);
						break;
					end
				end
			end
		end
		-- 
		if targetIconPosFunc then
			cfg.targetIconPosFunc = targetIconPosFunc;
		end
		-- 
		if callback then
			cfg.callback = callback;
		end
	end
end

-- 移除注册
function UserInfoChangeManager:unReg(sceneView)
	local idx, cfg = self:getCfgBySceneView_(sceneView);
	if idx then
		table.remove(self.cfgs_, idx)
	end
end

-- 判断sceneView场景是否存在注册
function UserInfoChangeManager:getCfgBySceneView_(sceneView)
	local len = #self.cfgs_;
	for i=1,len do
		if self.cfgs_[i].sceneView == sceneView then
			return i, self.cfgs_[i];
		end
	end

	return nil, nil;
end

function UserInfoChangeManager:refreshSceneUserInfoChangeCallback(sceneView)
	local idx,cfg
	if sceneView then
		idx,cfg = self:getCfgBySceneView_(sceneView);
	else
		cfg = self:findLastView();
	end
	if cfg then 
		cfg.callback()
	end
end

-- 清理
function UserInfoChangeManager:onCleanup()
	if self.loginMatchRoomSuccId_ then
		bm.EventCenter:removeEventListener(self.loginMatchRoomSuccId_)
		self.loginMatchRoomSuccId_ = nil;
	end
	if self.svrCmdUserMatchScoreId_ then
		bm.EventCenter:removeEventListener(self.svrCmdUserMatchScoreId_)
		self.svrCmdUserMatchScoreId_ = nil;
	end
	if self.matchRoomEndId_ then
		bm.EventCenter:removeEventListener(self.matchRoomEndId_)
		self.matchRoomEndId_ = nil;
	end
	if self.boxRewardAnimationId_ then
		bm.EventCenter:removeEventListener(self.boxRewardAnimationId_)
		self.boxRewardAnimationId_ = nil;
	end
	if self.matchRewardPopupEndId_ then
		bm.EventCenter:removeEventListener(self.matchRewardPopupEndId_)
		self.matchRewardPopupEndId_ = nil;
	end
	if self.chooseArenaPlayShowAnimId_ then
		bm.EventCenter:removeEventListener(self.chooseArenaPlayShowAnimId_)
		self.chooseArenaPlayShowAnimId_ = nil;
	end
	if self.changeSchedulerPool_ then
		self.changeSchedulerPool_:clearAll()
		self.changeSchedulerPool_ = nil;
	end
end
-- 
function UserInfoChangeManager:playWheelFlyAnimationByType(itype, rect, num, scaleVal, isWheelEnd, isHddj)
	local url
    if itype == 2 then -- 比赛券
        url = "match_gamecoupon.png"
    elseif itype == 1 then -- 筹码
        url = "match_chip.png"
    elseif itype == 3 then --现金币
        url = "match_score.png"
    elseif itype == 4 then -- 金券
        url = "match_goldcoupon.png"
        info.txt = sign..tostring(num)
    elseif itype == 5 then -- 门票
        url = "matchTick_icon.png"
    elseif itype == 7 then -- 互动道具
    	url = "#prop_hddj_icon.png"
    elseif itype == 8 then -- 互动道具
    	url = "#user-info-prop-icon.png"
    elseif itype == 9 then -- 黄金币
    	url = "match_gcoins.png"
    end
    self:playWheelFlyChipAnimation(nil, rect, itype, num, url, scaleVal, isWheelEnd, isHddj);
end
----nk.UserInfoChangeManager:playWheelFlyChipAnimation(icon, rect, itype, num, item.url);
-- nk.UserInfoChangeManager:playWheelFlyChipAnimation(icon, rect, itype, num, "#"..item.url);
function UserInfoChangeManager:playWheelFlyChipAnimation(icon, rect, itype, num, url, scaleVal, isWheelEnd, isHddj)
    local runScene = display.getRunningScene()
    local cfg = self:findLastView() -- self:findCfgByView(UserInfoChangeManager.MainHall)
    if runScene == nil or nil == rect or nil == cfg then
        bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="Wheel_end"})
    else
        local ts = 0.2;
        -- itype = 7;
        local rt = cfg.targetIconPosFunc(itype)
        local px, py = rt.x or 15, rt.y or 51;
        scaleVal = scaleVal or 1;
        isWheelEnd = isWheelEnd or true;
        if nil == icon then
        	icon = display.newSprite(url)
        end
        icon:pos(rect.x, rect.y):addTo(runScene, 99999, 99999);
        icon:setScale(scaleVal)
        -- itype:7为30的互动道具，8为15的互动道具, 5为门票
        if itype == 7 or itype == 8 or itype == 5 or itype == 4 or itype == 3 or itype == 2 then
        	-- 添加互动道具更新
        	if nil == isHddj then
        		self:updateHddjChange({key="hddj", url=url, num=num});
        	end
        	-- 
        	px = px + 45;
			icon:runAction(transition.sequence({
	        	cc.MoveBy:create(0.3, cc.p(0, 60)),
				cc.RotateBy:create(ts, 360*2),
				-- cc.DelayTime:create(0.1),
				cc.MoveTo:create(ts, cc.p(px, py)),
				cc.CallFunc:create(function(obj)
					if isWheelEnd then
						bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="Wheel_end"})
					end
					bm.EventCenter:dispatchEvent({name="Play_ChipChangeAnimation", data=itype})
					icon:removeFromParent();
				end)
			}))
		else
			icon:runAction(transition.sequence({
	        	cc.MoveBy:create(0.3, cc.p(0, 60)),
				cc.RotateBy:create(ts, 360*2),
				cc.DelayTime:create(0.1),
				cc.MoveTo:create(ts, cc.p(px, py)),
				cc.CallFunc:create(function(obj)
					bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="Wheel_end"})
					icon:removeFromParent();
				end)
			}))
		end
    end
end

function UserInfoChangeManager:playWheelFlyTicketAnimation(ticketValue, rect, itype, num, url, scaleVal, isWheelEnd, isHddj)
	local tickSprite = nk.MatchTickManager:createTicketSprite(ticketValue)
    self:playWheelFlyChipAnimation(tickSprite, rect, itype, num, tickSprite:getTexture(), scaleVal, isWheelEnd, isHddj)
end

function UserInfoChangeManager:playBoxRewardAnimation(sceneView, data, isAutoClose)
	sceneView = sceneView or UserInfoChangeManager.MainHall;
	local cfg = self:findCfgByView(sceneView)
	if cfg then
		BoxRewardAnimation.new(BoxRewardAnimation.ANIMATION_TYPE2, data, cfg.targetIconPosFunc, cfg.sceneView, isAutoClose):show();
	else
		print("playBoxRewardAnimation-->sceneView is not exist")
	end
end

-- 手动
function UserInfoChangeManager:manualFlyAnimt(itype, num, sceneView)
    if itype and num and type(num) == "number" and num > 0 then
    	-- 
	    local cfg
	    if sceneView then
	    	cfg = self:findCfgByView(sceneView)
	    else
	    	cfg = self:findLastView()
	    end
	    --
	    local rect = cfg.targetIconPosFunc(itype)
	    -- 
	    app:tip(itype, num, rect.x, rect.y, 999, 0, 22, 0)
    end    
end

return UserInfoChangeManager;
