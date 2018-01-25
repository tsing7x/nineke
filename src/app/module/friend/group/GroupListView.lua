--
-- Author: KevinYu
-- Date: 2017-01-19 18:24:35
-- 群列表视图，附近的群和热门的群
local GroupListView = class("GroupListView", function ()
    return display.newNode()
end)

local GroupIntroductionPopup = import(".GroupIntroductionPopup")
local GroupInfoListItem = import(".GroupInfoListItem")


local WIDTH, HEIGHT = 796, 390
local location0 = "22.5700847444,113.9277961850"--公司
local location1 = "13.719171454000715,100.52985988898314"--泰国公司
location0 = location1

function GroupListView:ctor(delegate)
	self:setNodeEventEnabled(true)

	self:setContentSize(WIDTH, HEIGHT)
	self:align(display.CENTER)

	self.groupListData_ = {}
	self.this_ = self
	self.delegate_ = delegate

	self:addTopNode_()

	self:addTipsNode_()

	self:addListsNode_()
end

--顶部输入框结点
function GroupListView:addTopNode_()
	local sx, sy = 30, HEIGHT- 40

	local label_ = ui.newTTFLabel({
        text = bm.LangUtil.getText("GROUP","INPUTINVITECODE"),
        color=cc.c3b(0xed, 0xda, 0xde),
        size = 24,
        align = ui.TEXT_ALIGN_LEFT,
    })
	:align(display.LEFT_CENTER, sx, sy)
	:addTo(self)

    local size = label_:getContentSize()

    -- 输入邀请码
    self.codeEdit_ = ui.newEditBox({
    		listener = handler(self, self.onCodeEdit_), 
    		size = cc.size(200, 50),
    		image = "#common_input_bg.png",
        	imagePressed="#common_input_bg_down.png",
    	})
        :align(display.LEFT_CENTER, sx + size.width + 5, sy)
        :addTo(self)

    self.codeEdit_:setFont(ui.DEFAULT_TTF_FONT, 26)
    self.codeEdit_:setPlaceholderFont(ui.DEFAULT_TTF_FONT, 26)
    self.codeEdit_:setAnchorPoint(cc.p(0, 0.5))
    self.codeEdit_:setPlaceholderFontColor(cc.c3b(0xca, 0xca, 0xca))
    self.codeEdit_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.codeEdit_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)

    nk.EditBoxManager:addEditBox(self.codeEdit_, 1)

	cc.ui.UIPushButton.new({normal = "#common_btn_blue_normal.png", pressed = "#common_btn_blue_pressed.png"},{scale9 = true})
        :setButtonSize(100, 55)
        :setButtonLabel(ui.newTTFLabel({text = bm.LangUtil.getText("GROUP","SEARCHGROUP"),size = 22,color = cc.c3b(0xff, 0xff, 0xff)}))
        :align(display.RIGHT_CENTER, WIDTH - 140, sy)
        :addTo(self)
        :onButtonClicked(buttontHandler(self, function()
            self:joinGroup(1, self.editCode_)
        end))

    local groupId = nk.userData.groupId
	if groupId and groupId ~= 0 then
		cc.ui.UIPushButton.new({normal = "#common_btn_yellow_normal.png", pressed = "#common_btn_yellow_pressed.png"},{scale9 = true})
	        :setButtonSize(100, 55)
	        :setButtonLabel(ui.newTTFLabel({text = bm.LangUtil.getText("GROUP","BACKGROUP"),size = 22,color = cc.c3b(0xff, 0xff, 0xff)}))
	        :align(display.RIGHT_CENTER, WIDTH - 30, sy)
	        :addTo(self)
	        :onButtonClicked(buttontHandler(self, self.onBackGroupClicked_))
	else
		cc.ui.UIPushButton.new({normal = "#common_btn_yellow_normal.png", pressed = "#common_btn_yellow_pressed.png"},{scale9 = true})
	        :setButtonSize(100, 55)
	        :setButtonLabel(ui.newTTFLabel({text = bm.LangUtil.getText("GROUP","CREATGROUP"),size = 22,color = cc.c3b(0xff, 0xff, 0xff)}))
	        :align(display.RIGHT_CENTER, WIDTH - 30, sy)
	        :addTo(self)
	        :onButtonClicked(buttontHandler(self, self.onCreateGroupClicked_))
	end
end

function GroupListView:onCodeEdit_(event, editbox)
	local text = editbox:getText()
    if event == "began" then
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
        editbox:setText(text)
    elseif event == "changed" then
        self.editCode_ = string.trim(text)
    elseif event == "ended" then
        editbox:setText(text)
    elseif event == "return" then
        editbox:setText(text)
    end
end

function GroupListView:onCreateGroupClicked_()
	if nk.userData.groupConfig and nk.userData.groupConfig.level and nk.userData.level<nk.userData.groupConfig.level then
		nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","LEVELENOUGH",nk.userData.groupConfig.level or 20))
		return
	end

	if nk.userData.groupConfig and nk.userData.groupConfig.gcoins and nk.userData.gcoins<nk.userData.groupConfig.gcoins then
		nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","GCOINENOUGH",nk.userData.groupConfig.gcoins or 10000))
		return
	end

	local createFun = function()
		self:setLoading(true)
        bm.HttpService.CANCEL(self.createGroupRequestId_)
	    self.createGroupRequestId_ = bm.HttpService.POST(
	        {
	            mod = "Group",
	            act = "createGroup",
	            uid = nk.userData.uid,
	            group_name = nk.userData.nick or nk.userData.uid,
	            image_url = nk.userData.s_picture or "",
	        },
	        function (data)
				-- 1:创建成功 -1:黄金币不足 -2:等级不足 -3:已经在群组中了 -4:扣黄金币失败 -5:未知错误
				if self.this_ then
					local retData = json.decode(data)
					if retData and retData.ret==1 then
						if nk.userData.groupConfig and retData.data.info and retData.data.info.id then
                            nk.userData.groupId = tonumber(retData.data.info.id)
		 				end

		 				self:setLoading(false)
						self.delegate_:createGroupInfo(retData.data)
					elseif retData and retData.ret==-1 then
						nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","GCOINENOUGH",nk.userData.groupConfig.gcoins or 500))
					elseif retData and retData.ret==-2 then
						nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","LEVELENOUGH",nk.userData.groupConfig.level or 20))
					elseif retData and retData.ret==-3 then--已进入其他群，界面还没刷新，开始创建
							nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","ONLYONE"))
							nk.userData.groupConfig = nil
							self.delegate_:requestGroupConfig()
					else
						nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","CREATGROUPFAIL"))
					end
				end
	        end,
	        function ()
	        	if self.this_ then
	            	nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","CREATGROUPFAIL"))
	            end
	        end
	    )
	end

	-- 二次确认框
	nk.ui.Dialog.new({
        messageText = bm.LangUtil.getText("GROUP","CREATGROUPTIPS",nk.userData.groupConfig.gcoins or 500),
        callback = function (type)
            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                createFun()
            end
        end
    }):show()
end

function GroupListView:onBackGroupClicked_()
	self.delegate_:getGroupInfo()
end

--提示信息结点
function GroupListView:addTipsNode_()
	local sy = HEIGHT - 75
	self.tipsLabel_ = ui.newTTFLabel({
    		text="", 
    		size=18, 
    		color=cc.c3b(0xbc, 0xa8, 0xdd), 
    		align=ui.TEXT_ALIGN_LEFT, 
    		valign=ui.TEXT_VALIGN_TOP,
    		dimensions=cc.size(WIDTH - 40, 0)
    	})
        :align(display.TOP_LEFT, 30, sy)
        :addTo(self)

    local tips = bm.LangUtil.getText("GROUP","GROUPGNTIPS")
    self.tipsLabel_:setString(tips)

   	local moreBtn = cc.ui.UIPushButton.new({normal = "#transparent.png", pressed = "#transparent.png"},{scale9 = true})
        :setButtonSize(100, 25)
        :setButtonLabel(ui.newTTFLabel({text = bm.LangUtil.getText("GROUP","MOREBTN"),size = 18,color = cc.c3b(0xff, 0xff, 0xff)}))
        :align(display.BOTTOM_RIGHT, WIDTH - 30, sy - 50)
        :addTo(self)
        :onButtonClicked(buttontHandler(self, function()
            GroupIntroductionPopup.new():show()
        end))

   	local moreLabel = ui.newTTFLabel({
    		text="___________", 
    		size=18, 
    		color=cc.c3b(0xff, 0xff, 0xff), 
    		valign=ui.TEXT_VALIGN_BOTTOM,
    	})
   		:align(display.BOTTOM_CENTER, -50, 0)
   		:addTo(moreBtn)
end

--群列表结点
function GroupListView:addListsNode_()
	local sx, sy = WIDTH/2, HEIGHT/2 + 50
	self.subTabBarGlobal_ = nk.ui.TabBarWithIndicator.new({
            background = "#popup_sub_tab_bar_bg.png", 
            indicator = "#popup_sub_tab_bar_indicator.png"    
        }, 
        bm.LangUtil.getText("GROUP","GROUPCATEGORY"),
        {
            selectedText = {color = cc.c3b(0xff, 0xff, 0xff), size = 22},
            defaltText = {color = cc.c3b(0xa3, 0x8a, 0xce), size = 22}
        }, true, true)
        :pos(sx, sy)
        :addTo(self)
    self.subTabBarGlobal_:setTabBarSize(300, 44, -10, -10)
    self.subTabBarGlobal_:onTabChange(handler(self, self.onSubTabChange_))
    self.subTabBarGlobal_:gotoTab(1, true)

    local listWidth, listHeight = WIDTH - 40, HEIGHT - 160
    GroupInfoListItem.WIDTH = listWidth

    self.groupInfoList_ = bm.ui.ListView.new(
        {
            viewRect = cc.rect(-listWidth * 0.5, -listHeight * 0.5, listWidth, listHeight),
            upRefresh = handler(self, self.onGroupListUpFrefresh_)
        }, 
        GroupInfoListItem
    )
    :pos(sx, sy - 142)
    :addTo(self)

    if self.groupInfoList_.scrollContent_ then
    	self.groupInfoList_.scrollContent_:setTouchSwallowEnabled(false)
    end

    self.groupInfoList_:addEventListener("ITEM_EVENT",handler(self,self.onGroupInfoListItemEvent))
end

function GroupListView:onGroupInfoListItemEvent(evt)
	if evt.type=="JOIN_GROUP_INFO" then
		local data = evt.data
		if tonumber(data.pnum)>=tonumber(data.num) then
			nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","GROUPFULLTIPS"))
		else
			self:joinGroup(2, data and data.id or nil, data)
		end
	end
end

-- 申请加入群组
function GroupListView:joinGroup(type,data,exData)
	if not data or data=="" then
		return
	end

	bm.HttpService.CANCEL(self.joinGroupId_)
    self.joinGroupId_ = bm.HttpService.POST(
        {
            mod = "Group",
            act = "joinGroup",
            type = type,
            group_id = data,
           	code = data,
           	uid = nk.userData.uid,
        },
        function (data)
            if self.this_ then
            	local retData = json.decode(data)
            	if retData and (retData.ret==-1 or retData.ret==-2) then
            		nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","CODEERRORTIPS"))
            	elseif retData and retData.ret==-3 then
            		nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","ONLYONE"))
            	elseif retData and retData.ret==-4 then
            		nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","GROUPFULLTIPS"))
            	elseif retData and retData.ret==-5 then  -- 已经申请加入此群了
            		nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","REVIEWTIPS"))
            	elseif retData and retData.ret==-6 then
            		nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","JOINLEVELERROR"))
            	elseif retData and retData.ret==-7 then
            		nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","JOINGCOINERROR"))
            	elseif retData and retData.ret==1 then
            		-- 需要审核，不需要审核的不一样
            		if retData.data and retData.data.status==1 then
            			nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","REVIEWTIPS1"))
            			nk.userData.groupConfig = nil
            			self.delegate_:requestGroupConfig()
            		else
            			nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","REVIEWTIPS"))
            		end
            	else
            		nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","REVIEWTIPS"))
            	end
            end
        end,
        function ()
        	if self.this_ then
        		nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","REVIEWTIPS"))
        	end
        end
    )
end

function GroupListView:flushGroupList(index, page)
	self:getGroupInfo_(index, page)
end

function GroupListView:getGroupInfo_(index, page)
	if not index then
		index = 1
	end

	if not page then
		page = 1
	end

	local location = nk.Native:getDeviceInfo().location
	if not location or location=="" then
		location = location0
	end

	self:setLoading(true)
	bm.HttpService.CANCEL(self.groupNearbyId_)
	self.groupNearbyId_ = bm.HttpService.POST(
		{
			mod = "Group",
			act = "getGroupList",
			type = index,
			uid = nk.userData.uid,
			location = location,
			page = page,
		},
		function (data)
            if self.this_ then
	 			self:setLoading(false)
	 			local retData = json.decode(data)
 				if retData and retData.ret==1 and retData.data then
 					if not self.groupListData_[index] then
 						self.groupListData_[index] = {}
 					end

 					local list = self.groupListData_[index]

 					if #retData.data < 1 then
 						list.page = "end"
 						return
 					end

 					if list.page and list.page >= page then  -- 重复拉取
 						return
 					end

 					list.page = page

 					-- 每一页10个，显示有点问题,如果最后一个不是刚好填充满，重新计算填充
 					local start = 1
 					local step = 2
 					local temp = list[#list]
 					if temp and #temp~=0 and #temp~=step then
 						table.remove(list,#list)

 						temp = clone(temp)  -- 确保刷新
 						local len = step - #temp
 						for i = 1, len do
 							table.insert(temp, retData.data[i])
 						end

 						table.insert(list,temp)
 						start = start + len
 					end
 					
 					for i = start, #retData.data, step do
 						local temp = {}
 						for j = 1, step do
 							temp[j] = retData.data[i + j - 1]
 						end

 						table.insert(list,temp)
 					end

 					if self:getSelectedTab()==index then
						self.groupInfoList_:setData(list, true)
 					end
 				end
	 		end
        end,
        function ()
        	if self.this_ then
        		self:getGroupInfo_(index, page)
        	end
        end
	)
end

function GroupListView:onGroupListUpFrefresh_()
	local index = self:getSelectedTab()
	local list = self.groupListData_[index]
	if not list or list.page=="end" then return end
	self:getGroupInfo_(index, list.page + 1)
end

function GroupListView:onSubTabChange_(selectedTab)
	local index = selectedTab
	local list = self.groupListData_[index]
	if list then
		self.groupInfoList_:setData(list)
	else
		self:getGroupInfo_(index, 1)
	end
end

function GroupListView:setLoading(isLoading)
    if isLoading then
        if not self.Nearbyjuhua_ then
            self.Nearbyjuhua_ = nk.ui.Juhua.new()
                :pos(WIDTH/2, HEIGHT/2 - 80)
                :addTo(self, 2)
        end
    else
        if self.Nearbyjuhua_ then
            self.Nearbyjuhua_:removeFromParent()
            self.Nearbyjuhua_ = nil
        end
    end
end

function GroupListView:getSelectedTab()
	local index = 1
	if self.subTabBarGlobal_ then
		index = self.subTabBarGlobal_:getSelectedTab()
	end

	return index
end

function GroupListView:onCleanup()
	bm.HttpService.CANCEL(self.joinGroupId_)
	bm.HttpService.CANCEL(self.groupNearbyId_)
	bm.HttpService.CANCEL(self.createGroupRequestId_)

	if self.codeEdit_ then
        nk.EditBoxManager:removeEditBox(self.codeEdit_)
    end
end

return GroupListView