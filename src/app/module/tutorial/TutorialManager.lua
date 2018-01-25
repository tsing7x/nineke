--
-- Author: HLF(IdaHuang@boyaa.com)
-- Date: 2016-08-05 10:19:57
--
local TutorialManager = class("TutorialManager")
-- 大厅 更多奖励
TutorialManager.MORECARD_TAG = 1
-- 大厅 比赛场
TutorialManager.ARENACARD_TAG = 2
-- 大厅 房间
TutorialManager.ROOMCARD_TAG = 3
-- 大厅 快速开始
TutorialManager.PLAYNOWCARD_TAG = 4
-- 大厅商店
TutorialManager.STORE_TAG = 5
-- 大厅兑换商店
TutorialManager.EXCHANGE_TAG = 6
-- 大厅好友
TutorialManager.FRIEND_TAG = 7
-- 大厅排行帮
TutorialManager.RANK_TAG = 8
-- FB邀请好友
TutorialManager.INVITE_FRIEND_TAG = 9 
-- 房间牌型
TutorialManager.CARDTYPE_TAG = 10

TutorialManager.EVENT_CLICK_NAME = "EVENT_CLICK_NAME"

TutorialManager.TutorialAnimationEnd_Event = "TutorialAnimationEnd_Event"

TutorialManager.Tutorial_UserDefault = "Tutorial_UserDefault"

TutorialManager.HALL_IDX = 1

TutorialManager.ROOM_IDX = 2

TutorialManager.STEP_1 = 1
TutorialManager.STEP_2 = 2

function TutorialManager:ctor()
	self.configs_ = self:getConfig()
	local jsonStr = self:getUserDefaultData(TutorialManager.Tutorial_UserDefault) or ""
	self.cfgJsonData_ = {}
	if jsonStr and jsonStr ~= "" then
		local viewArr = string.split(jsonStr, "|")
		for _,v in pairs(viewArr) do
			local arr = string.split(v, "_")
			if arr and #arr == 3 then
				local viewIdx = tonumber(arr[1])
				local step = tonumber(arr[2])
				local tag = tonumber(arr[3])
				if not self.cfgJsonData_[viewIdx] then
					self.cfgJsonData_[viewIdx] = {}
				end
				-- 
				if not self.cfgJsonData_[viewIdx][step] then
					self.cfgJsonData_[viewIdx][step] = {}
				end
				self.cfgJsonData_[viewIdx][step][tag] = 1
			end
		end
	end
	-- 
	self.panel_ = import("app.module.tutorial.TutorialInfoPanel").new()
	self.eventId_ = bm.EventCenter:addEventListener(TutorialManager.EVENT_CLICK_NAME, handler(self, self.onEventHandler_))
	self.endId_ = bm.EventCenter:addEventListener(TutorialManager.TutorialAnimationEnd_Event, handler(self, self.onTutorialEndHandler_))
end
-- 
function TutorialManager:getConfig()
	local config = {
		{
			{
				{tag=TutorialManager.PLAYNOWCARD_TAG, py=92, msg=bm.LangUtil.getText("HALL", "TUTORIAL_PLAYNOWCARD")}
			},
			{
				{tag=TutorialManager.PLAYNOWCARD_TAG, isAuto=1, py=92, msg=bm.LangUtil.getText("HALL", "TUTORIAL_PLAYNOWCARD")},
				{tag=TutorialManager.INVITE_FRIEND_TAG, isAuto=1, py=-10, isPullDown=1, msg=bm.LangUtil.getText("HALL", "TUTORIAL_INVITEFRIEND")},
				{tag=TutorialManager.ROOMCARD_TAG, isAuto=1, py=92, msg=bm.LangUtil.getText("HALL", "TUTORIAL_ROOMCARD")},
				{tag=TutorialManager.MORECARD_TAG, isAuto=1, py=92, msg=bm.LangUtil.getText("HALL", "TUTORIAL_MORECARD")},
				{tag=TutorialManager.STORE_TAG, isAuto=1, py=12, msg=bm.LangUtil.getText("HALL", "TUTORIAL_STORE")},
			}
		},
		{
			{
				{tag=TutorialManager.CARDTYPE_TAG, px=55, py=16, arrowOffX=-46, msg=bm.LangUtil.getText("HALL", "TUTORIAL_CARDTYPE")},
			}
		}
	}
	return config
end
-- 
function TutorialManager:getTagsByView(view, step)
	local cfgs = self.configs_[view][step]
	if not cfgs then
		return nil
	end
	local tags = {}
	for i=1,#cfgs do
		table.insert(tags, cfgs[i].tag)
	end
	return tags
end

function TutorialManager:findConfigByTag(view, step, tag)
	local cfgs = self.configs_[view][step]
	for _,v in ipairs(cfgs) do
		if v.tag == tag then
			return v
		end
	end
	return nil
end
-- 
function TutorialManager:onTutorialEndHandler_(data)
	self.tutorialNode_ = nil
	-- if data.name == TutorialManager.TutorialAnimationEnd_Event then
		self:nextStep_()
	-- end
end
-- 
function TutorialManager:onEventHandler_(data)
	local status
	if data.name == TutorialManager.EVENT_CLICK_NAME then
		if data.data and self.view_ and self.step_ then
			self:saveUserConfig(self.view_, self.step_, data.data)
		end
		-- if self.tutorialNode_ then
		-- 	self.tutorialNode_:playHide()
		-- end
		self:stopAllTutorial()
	end
end
--
function TutorialManager:stopAllTutorial()
	self.tags_ = nil
	self:removeTutorialNode()
end
-- 保存步骤数据
function TutorialManager:saveUserConfig(viewIdx, step, tag)
	if not self.cfgJsonData_ then
		return
	end

	if not self.cfgJsonData_[viewIdx] then
		self.cfgJsonData_[viewIdx] = {}
	end
	-- 
	if not self.cfgJsonData_[viewIdx][step] then
		self.cfgJsonData_[viewIdx][step] = {}
	end
	-- 
	if self.cfgJsonData_[viewIdx][step][tag] then
		return
	end
	self.cfgJsonData_[viewIdx][step][tag] = 1
	-- 
	local tb = {}
	for viewIdx,cfgs in pairs(self.cfgJsonData_) do
		for step,cfg in pairs(cfgs) do
			for tag,val in pairs(cfg) do
				table.insert(tb, tostring(viewIdx.."_"..step.."_"..tag))
			end
		end
	end
	local jsonStr = table.concat(tb, "|")
	self:updateUserDefaultData(TutorialManager.Tutorial_UserDefault, jsonStr)
end
-- 判断步骤数据是否存在
function TutorialManager:getUserConfigByTag(viewIdx, step, tag)
	if tag then
		if self.cfgJsonData_[viewIdx] and self.cfgJsonData_[viewIdx][step] and self.cfgJsonData_[viewIdx][step][tag] then
			return true
		end
	else
		if self.cfgJsonData_[viewIdx] and self.cfgJsonData_[viewIdx][step] then
			return true
		end
	end
	
	return false
end
-- 判断步骤数据是否存在
function TutorialManager:getUserConfigByIdx(viewIdx, step, idx)
	if tag then
		local cfgs = self.configs_[viewIdx][step]
		if cfgs then
			for _,v in ipairs(cfgs) do
				if self:getUserConfigByTag(viewIdx, step, v.tag) then
					return true
				end
			end
		end
	else
		if self.cfgJsonData_[viewIdx] and self.cfgJsonData_[viewIdx][step] then
			return true
		end
	end
	
	return false
end
-- 
function TutorialManager:startHallScene(view)
	if nk.userData.level < nk.userData.arenaLimiteLevel then
		self.currentView_ = view
		self.view_ = TutorialManager.HALL_IDX
		self.step_ = TutorialManager.STEP_1
		if self:getUserConfigByTag(self.view_, self.step_) then
			self.step_ = TutorialManager.STEP_2
		end
		self.tags_ = self:getTagsByView(self.view_, self.step_)
		self:nextStep_()
	end
end
-- 
function TutorialManager:startRoomScene(view)
	if nk.userData.level < nk.userData.arenaLimiteLevel then
		self.currentView_ = view
		self.view_ = TutorialManager.ROOM_IDX
		self.step_ = TutorialManager.STEP_1
		if self:getUserConfigByTag(self.view_, self.step_) then
			self.step_ = TutorialManager.STEP_2
		end
		self.tags_ = self:getTagsByView(self.view_, self.step_)
		self:nextStep_()
	end
end
-- 
function TutorialManager:nextStep_()
	if self.tags_ and #self.tags_ > 0 then
		local tag = table.remove(self.tags_, 1)
		local isComplete = self:getUserConfigByTag(self.view_, self.step_, tag)
		if not isComplete then
			local cfg = self:findConfigByTag(self.view_, self.step_, tag)
			if cfg then
				self.currentNode_ = self:getTutorialViewNode(cfg)
			end
		else
			self:nextStep_()
		end
	end
end
-- 
function TutorialManager:getTutorialViewNode(cfg)
	if self.currentView_ and self.currentView_["getTutorialNode"] then
		local px = cfg.px or 0
		local py = cfg.py or 0
		local node = self.currentView_:getTutorialNode(cfg.tag)
		if node then
			local runScene = display.getRunningScene()
			local rect = node:getParent():convertToWorldSpace(cc.p(node:getPosition()))
			self.tutorialNode_ = self.panel_:createArrowView(cfg)
			:addTo(runScene, 99)
			:pos(rect.x + px, rect.y + py)
			-- 
			if cfg.isAuto then
				self.tutorialNode_:autoShowAndHide()
			else
				self.tutorialNode_:playShow()
			end
		end
		return node
	end
	return nil
end
-- 
function TutorialManager:removeTutorialNode()
	if self.tutorialNode_ then
		self.tutorialNode_:removeFromParent()
		self.tutorialNode_ = nil
	end
end
-- 
function TutorialManager:clean()
	self:removeTutorialNode()
end
-- 获取保存本地数据
function TutorialManager:getUserDefaultData(key)
	key = nk.userData.uid..key
    return nk.userDefault:getStringForKey(key);
end

-- 把dataStr保存到本地
function TutorialManager:updateUserDefaultData(key, dataStr)
	key = nk.userData.uid..key
    nk.userDefault:setStringForKey(key, dataStr);
    nk.userDefault:flush();
end

return TutorialManager