--
-- Author: KevinYu
-- Date: 2017-01-19 18:24:35
-- 群组相关节点
local GroupMainNode = class("GroupMainNode", function ()
    return display.newNode()
end)

local GroupListView = import("app.module.friend.group.GroupListView")
local GroupInfoView = import("app.module.friend.group.GroupInfoView")

local logger = bm.Logger.new("GroupMainNode")

function GroupMainNode:ctor(controller,data)
	self:setNodeEventEnabled(true)
	self.this_ = self
	self:requestGroupConfig()
end

function GroupMainNode:requestGroupConfig()
	self:setLoading(true)
	bm.HttpService.CANCEL(self.createGroupConfigId_)
	if nk.userData.groupConfig then
		self:createMainUI_()
		return
	end

    self.createGroupConfigId_ = bm.HttpService.POST(
        {
            mod = "Group",
            act = "getConfig",
            type = "create",
        },
        function (data)
            if data then
            	local retData = json.decode(data)
            	nk.userData.groupConfig = retData
            	nk.userData.groupId = retData.group_id
            end

            if not nk.userData.groupConfig or not nk.userData.groupConfig.level then
            	nk.userData.groupConfig = {
            		level = 20,			--int(大于等于此等级)
            		gcoins = 500,		--int(需要消耗的黄金币)
            		group_id = nil,		-- 群组 ID
            		privateRoom = 0,    
            	}
            end

            self:createMainUI_()
        end,
        function ()
        	if self.this_ then
        		self:requestGroupConfig()
        	end
        end)
end

function GroupMainNode:createMainUI_()
	self:setLoading(false)
	self.group_id_ = nk.userData.groupId
	if self.group_id_ and self.group_id_~=0 then
		self:getGroupInfo()
    else
    	self:createNearbyInfo()
   	end
end

--获取自己加入的群信息
function GroupMainNode:getGroupInfo()
	self:setLoading(true)
	bm.HttpService.CANCEL(self.groupInfoAllId_)
	self.groupInfoAllId_ = bm.HttpService.POST(
		{
			mod = "Group",
			act = "getGroupInfo",
			group_id = self.group_id_,
			type = 4,
		},
		function (data)
            if self.this_ then
	 			local retData = json.decode(data)
	 			if retData and retData.data then
 					self:setLoading(false)
 					self:createGroupInfo(retData.data)

 					self:getGroupTangGuo()		
	 			end
	 		end
        end,
        function ()
        	if self.this_ then
        		self:getGroupInfo()
        	end
        end
	)
end

function GroupMainNode:getGroupTangGuo(type,page,callback)
	-- 请求糖果奖励列表 
	if not GroupTangGuo then  -- 全局变量
		bm.HttpService.CANCEL(self.groupTangGuoId_)
		self.groupTangGuoId_ = bm.HttpService.POST(
			{
				mod = "Group",
				act = "getRedList",
				group_id = self.group_id_,
				uid = nk.userData.uid,
			},
			function (data)
	            if self.this_ then
		 			local retData = json.decode(data)
		 			if retData and retData.data then
		 				GroupTangGuo = retData.data
		 				if #GroupTangGuo > 0 then
		 					local GroupAwardPopup = import("app.module.friend.group.GroupAwardPopup")
            				GroupAwardPopup.new(table.remove(GroupTangGuo,1),self.group_id_):show()
		 				end
		 			end
		 		end
	        end,
	        function ()
	        end
		)
	end
end

function GroupMainNode:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
                :addTo(self)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

--已加入群信息
function GroupMainNode:createGroupInfo(data)
	self.groupInfoView_ = GroupInfoView.new(self, data):pos(0, -50):addTo(self)
	self.groupInfoView_:flushGroupInfo()

	if self.groupListView_ then
		self.groupListView_:removeFromParent()
		self.groupListView_ = nil
	end
end

--附近的群信息
function GroupMainNode:createNearbyInfo()
	self.groupListView_ = GroupListView.new(self):addTo(self):pos(0, -30)
	self.groupListView_:flushGroupList()

	if self.groupInfoView_ then
		self.groupInfoView_:removeFromParent()
		self.groupInfoView_ = nil
	end
end

function GroupMainNode:onCleanup()
	bm.HttpService.CANCEL(self.createGroupConfigId_)
	bm.HttpService.CANCEL(self.groupInfoAllId_)
	
	bm.HttpService.CANCEL(self.groupTangGuoId_)
end

return GroupMainNode