--
-- Author: KevinYu
-- Date: 2017-01-19 18:38:44
-- 已加入的群信息

local GroupInfoView = class("GroupInfoView", function ()
    return display.newNode()
end)

local GroupMemberListItem       = import(".GroupMemberListItem")
local GroupRoomListItem         = import(".GroupRoomListItem")
local GroupInfoListItem         = import(".GroupInfoListItem")
local SimpleColorLabel 			= import("boomegg.ui.SimpleColorLabel")
local GroupIntroductionPopup 	= import(".GroupIntroductionPopup")
local GroupInvitePopup 			= import(".GroupInvitePopup")
local GroupCreateRoomPopup 		= import(".GroupCreateRoomPopup")
local GroupMsgPopup 			= import(".GroupMsgPopup")
local GroupCheckPopup 			= import(".GroupCheckPopup")
local GroupSettingPopup 		= import(".GroupSettingPopup")
local GroupPassWordPopup 		= import(".GroupPassWordPopup")
local AddFriendPopup 			= import("app.module.newranking.AddFriendPopup")

local WIDTH, HEIGHT = 810, 400
local AVATAR_SIZE = 50

function GroupInfoView:ctor(delegate, data)
	display.addSpriteFrames("group_texture.plist", "group_texture.png")
	self:setNodeEventEnabled(true)

	self:setContentSize(WIDTH, HEIGHT)
	self:align(display.CENTER)

	bm.TouchHelper.new(self, function(obj, evtName)
		if self.menuNode_ and evtName == bm.TouchHelper.TOUCH_BEGIN then
			self.menuNode_:hide()
		end
	end)

	self.this_ = self
	self.delegate_ = delegate
	self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id

	self:initData_(data)

	self:addTopInfoNode_()

	self:addMemberListNode_()

	self:addRoomListNode_()

	self.groupMemberList_:setData(self.groupMemberInfo_)
	self:setGroupRoomListData_(self.groupRoomInfo_)
end

function GroupInfoView:initData_(data)
	self.group_id_ = nk.userData.groupId

	self.groupInfoBase_ = data.info
	self.groupMemberInfo_ = data.members
	self.groupRoomInfo_ = data.rooms
	self.dis_ = data.dis   --是否已获得加赠  1是，0 否

	if self.dis_ and tonumber(self.dis_)==1 then
		self.groupInfoBase_.dis = 0
	end

	GroupMemberListItem.admin_uid = self.groupInfoBase_.admin_uid
	self.groupMemberPages_ = 1  -- 翻页控制
	self.groupRoomListPages_ = 1  -- 翻页控制

	self:getInnerGroupId()
end

function GroupInfoView:getInnerGroupId()
	if self.innerGroupId_ then return end

	if not self.groupMemberInfo_ then return end

	for k,v in pairs(self.groupMemberInfo_) do
		if tonumber(v.uid)==tonumber(nk.userData.uid) then
			self.innerGroupId_ = v.id
			break
		end
	end
end

-- 群组信息标题
function GroupInfoView:addTopInfoNode_()
	local w, h = 800, 74

	local node = display.newNode()
		:size(w, h)
		:align(display.CENTER, WIDTH/2, HEIGHT - 40)
		:addTo(self)

	display.newScale9Sprite("#group_top_bg.png", 0, 0, cc.size(w/2, h))
		:align(display.RIGHT_CENTER, w/2, h/2)
		:addTo(node)
		
	display.newScale9Sprite("#group_top_bg.png", 0, 0, cc.size(w/2, h))
		:align(display.RIGHT_CENTER, w/2, h/2)
		:addTo(node)
		:setScaleX(-1)

   	local sx, sy = 40, h/2
   	self.groupHead_ = display.newSprite("#group_head_bg.png")
   		:pos(sx, sy)
   		:addTo(node)

   	bm.TouchHelper.new(self.groupHead_, function(target,evtName)
		if self.menuNode_ then
			self.menuNode_:hide()
		end

		if evtName == bm.TouchHelper.CLICK then
			if self:checkIsAdmin_() then
				nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
				self:onGroupHeadClecked_()
			end
		end
	end)

   	--头像
   	self.cameraIcon_ = display.newSprite("#group_camera_icon.png")
   		:align(display.RIGHT_BOTTOM, sx + 26, sy - 26)
   		:addTo(node)
   		:hide()

   	--群名字
   	local x, y = sx + 35, h/2 + 13
   	self.groupNameLabel_ = ui.newTTFLabel({
            text = "",
            size = 22,
            align = ui.TEXT_ALIGN_LEFT,
        })
    	:align(display.LEFT_CENTER, x, y)
    	:addTo(node)

    if self:checkIsAdmin_() then
		self.nameEdit_  = ui.newEditBox({
			image = "#transparent.png",
			listener = handler(self, self.onNameEdit_),
			size = cc.size(250, 40)})
		    :align(display.LEFT_CENTER, x, y)
		    :addTo(node)
		self.nameEdit_:setFont(ui.DEFAULT_TTF_FONT, 22)
		self.nameEdit_:setPlaceholderFont(ui.DEFAULT_TTF_FONT, 22)
		self.nameEdit_:setMaxLength(15)
		self.nameEdit_:setPlaceholderFontColor(cc.c3b(0xEE, 0xEE, 0xEE))
		self.nameEdit_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		self.nameEdit_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)

		nk.EditBoxManager:addEditBox(self.nameEdit_, 1)

    	display.newSprite("#pop_userinfo_edit.png"):pos(sx + 280, y):addTo(node)
    end

    --群活跃
    self.groupActiveLabel_ = ui.newTTFLabel({ 
            text = "",
            size = 22,
            align = ui.TEXT_ALIGN_LEFT,
        })
    	:align(display.LEFT_CENTER, x, 22)
    	:addTo(node)

  	self.groupFanliLabel_ = SimpleColorLabel.addMultiLabel(bm.LangUtil.getText("GROUP","OWNERREBATE"), 22, cc.c3b(0xa8,0xfc,0xff), cc.c3b(0xff,0xd8,0x00), cc.c3b(0xff,0xd8,0x00))
  	self.groupFanliLabel_.addTo(node)
  	self.groupFanliLabel_.node:pos(w/2, 22)

  	-- 商城按钮
  	local btn_y = h/2
    self.storeBtn_ = cc.ui.UIPushButton.new({normal = "#group_shop_normal.png", pressed = "#group_shop_down.png"})
		:pos(w - 240, btn_y)
    	:addTo(node)
        :onButtonClicked(buttontHandler(self, function()
        	-- 全局折扣
        	Global_isInGroupShop = 1
        	Global_inGroupShopDis = self.groupInfoBase_.dis
        	
        	self:onBtnHandler()
            local StorePopup = require("app.module.newstore.StorePopup")
            StorePopup.new(3):showPanel()
        end))

    -- 充值折扣
    self.storeGiftIcon_ = display.newSprite("#group_store_gift.png")
    	:pos(-15, 15)
    	:scale(0.6)
    	:addTo(self.storeBtn_)
   	 	
    self.storeGiftLabel_ = ui.newTTFLabel({
        text = "",
        size = 22,
    })
	:pos(30, 30)
	:addTo(self.storeGiftIcon_)

	cc.ui.UIPushButton.new("#group_look.png")
		:pos(w - 170, btn_y)
    	:addTo(node)
        :onButtonClicked(buttontHandler(self, function()
        	self.delegate_:createNearbyInfo()
        end))

    cc.ui.UIPushButton.new({normal = "#group_set_normal.png", pressed = "#group_set_down.png"})
		:pos(w - 100, btn_y)
    	:addTo(node)
        :onButtonClicked(buttontHandler(self, function()
        	if self.menuNode_ then
        		if self.menuNode_:isVisible() then
        			self:onBtnHandler()
        			return
        		end
        	end

        	--- 管理员
        	if self:checkIsAdmin_() then
        		self:createMoreBtn(4)
        	else
        		self:createMoreBtn(2)
        	end
        end))

	cc.ui.UIPushButton.new({normal = "#group_help_normal.png", pressed = "#group_help_down.png"})
		:pos(w - 35, btn_y)
    	:addTo(node)
        :onButtonClicked(buttontHandler(self, function()
        	self:onBtnHandler()
            GroupIntroductionPopup.new():show()
        end))

	local line_x = w - 65
	for i = 1, 3 do
		display.newSprite("#group_btn_dividing_line.png")
   		:pos(line_x - (i - 1) * 70, btn_y)
   		:addTo(node)
	end
end

function GroupInfoView:createMoreBtn(num)
	if self.menuNode_ then
		self.menuNode_:removeFromParent()
        self.menuNode_ = nil
	end

	local itemWidth, itemHeight = 190, 60
	local w, h = itemWidth, itemHeight*num

	self.menuNode_ = display.newScale9Sprite("#group_help_panel_bg.png", 0, 0, cc.size(w, h))
		:align(display.TOP_CENTER, WIDTH - itemWidth/2, HEIGHT - 75)
		:addTo(self)

	self.menuNode_:setTouchEnabled(true)
	self.menuNode_:setTouchSwallowEnabled(true)

	local btns = {}
	if num == 2 then
		table.insert(btns,{"moreMsgBtn_",bm.LangUtil.getText("GROUP","MSG")})
		table.insert(btns,{"moreOutBtn_",bm.LangUtil.getText("GROUP","LOGOUT")})
	else
		table.insert(btns,{"moreJoinSetBtn_",bm.LangUtil.getText("GROUP","JOINSET")})
		table.insert(btns,{"moreJoinMsgBtn_",bm.LangUtil.getText("GROUP","JOINLIST")})
		table.insert(btns,{"moreMsgBtn_",bm.LangUtil.getText("GROUP","MSG")})
		table.insert(btns,{"moreOutBtn_",bm.LangUtil.getText("GROUP","LOGOUT")})
	end

	for k,v in ipairs(btns) do
		self[v[1]] = cc.ui.UIPushButton.new({normal = "#transparent.png"},{scale9 = true})
			:setButtonSize(itemWidth, itemHeight)
        	:setButtonLabel(ui.newTTFLabel({text = v[2],size = 22}))
			:align(display.TOP_CENTER, w/2, h - itemHeight * (k - 1))
        	:addTo(self.menuNode_)
	        :onButtonClicked(buttontHandler(self, function()
	            self:onBtnHandler(self[v[1]])
	        end))

	    if k ~= num then  -- 创建分割线
	    	display.newScale9Sprite("#group_dividing_line.png",0,0, cc.size(itemWidth - 2, 2))
	    		:pos(w/2, h - itemHeight*k)
       			:addTo(self.menuNode_)
	    end
	end
end

function GroupInfoView:onGroupHeadClecked_()
	local uploadURL = nk.userData.iconUrl
   	-- http://mvlpuswp01.boyaagame.com/updateiconnk.php
   	-- http:\/\/nineke-th-demo.boyaa.com\/updateiconnk.php
	-- 返回图片地址，创建群组，编辑群组时，将地址上报到对应接口
   	local function uploadPictureCallback(result, evt)
        if evt.name == "completed" then
            local request = evt.request
            local code = request:getResponseStatusCode()
            local ret = request:getResponseString()
            logger:debugf("REQUEST getResponseStatusCode() = %d", code)
            logger:debugf("REQUEST getResponseHeadersString() =\n%s", request:getResponseHeadersString())
            logger:debugf("REQUEST getResponseDataLength() = %d", request:getResponseDataLength())
            logger:debugf("REQUEST getResponseString() =\n%s", ret)
            local retTable = json.decode(ret)
            if retTable and retTable.code == 1 and retTable.iconname then
                local imgURL = retTable.iconname
                bm.HttpService.CANCEL(self.updateGroupPhotoId_)
                self.delegate_:setLoading(true)
                self.updateGroupPhotoId_ = bm.HttpService.POST(
	                {
	                    mod = "Group",
	                    act = "updateGroupConfig",
	                    group_id = self.groupInfoBase_.id,
	                    uid = nk.userData.uid,
	                    group_name = self.groupInfoBase_.group_name,  -- 设置群名字
	                    image_url = imgURL,  -- 设置群头像
	                    level = self.groupInfoBase_.level,      -- 入群等级限制
	                    money = self.groupInfoBase_.money,    -- 入群金币限制
	                    is_check = self.groupInfoBase_.is_check,   -- 是否需要审核 0： 需要   1：不需要
	                    description = self.groupInfoBase_.description
	                },
	                function (data)
	                    if self.this_ then
	                    	self.delegate_:setLoading(false)
	                        local retData = json.decode(data)
	                        if retData and retData.ret==1 and retData.data then
	                        	local t = bm.LangUtil.getText("USERINFO", "UPLOAD_PIC_UPLOAD_SUCCESS")
	                        	nk.TopTipManager:showTopTip(t)
	                        	self.groupInfoBase_.image_url = retData.data.image_url
	                        	self:flushGroupInfo()
	                        else
	                        	local t = bm.LangUtil.getText("USERINFO", "UPLOAD_PIC_UPLOAD_FAIL")
	                        	nk.TopTipManager:showTopTip(t)
	                        end
	                    end
	                end,
	                function ()
	                    if self.this_ then
	                        self.delegate_:setLoading(false)
	                        local t = bm.LangUtil.getText("USERINFO", "UPLOAD_PIC_UPLOAD_FAIL")
	                        nk.TopTipManager:showTopTip(t)
	                    end
	                end
	            )
            else
                local msg = ""
                if retTable and retTable.msg then
                    msg = retTable.msg
                else
                    msg = bm.LangUtil.getText("USERINFO", "UPLOAD_PIC_UPLOAD_FAIL")
                end
                nk.TopTipManager:showTopTip(msg)
            end
            os.remove(result)
        elseif evt.name == 'cancelled' then
        elseif evt.name == 'failed' then
        elseif evt.name == 'unknown' then
        else
        end
    end

   	local function pickImageCallback(success, result)
        logger:debug("nk.Native:pickImage callback ", success, result)
        if success then
            if bm.isFileExist(result) then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "UPLOAD_PIC_IS_UPLOADING"))
                local sid = appconfig.SID[string.upper(device.platform)] or 1
                local time = os.time()
                local iconKey = "~#kevin&^$xie$&boyaa"
                local sig = crypto.md5(nk.userData.uid .. "|" .. sid .. "|" .. time .. iconKey)

                local upload_data = {
                    fileFieldName = "upload", filePath = result,
                    contentType = "image/png",
                    extra = {
                        {uid, nk.userData.uid},
                        {"sid", sid},
                        {"time", time},
                        {"sig", sig},
                    }
                }
                if appconfig.LOGIN_SERVER_URL == "http://nineke-th-demo.boyaa.com/mobile.php?demo=1" then
                    table.insert(upload_data.extra,{"demo", 1})
                end
                local cb = bm.lime.simple_curry(uploadPictureCallback, result)
                network.uploadFile(cb, uploadURL,upload_data)
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "UPLOAD_PIC_PICK_IMG_FAIL"))
            end
        else
            if result == "nosdcard" then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "UPLOAD_PIC_NO_SDCARD"))
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "UPLOAD_PIC_PICK_IMG_FAIL"))
            end
        end
    end

    nk.Native:pickImage(pickImageCallback)
end

function GroupInfoView:flushGroupInfo()
	if self.this_ and self.groupInfoBase_ then
		self.groupNameLabel_:setString(self.groupInfoBase_.group_name)
		self.groupActiveLabel_:setString(bm.LangUtil.getText("GROUP","ACTWORD",self.groupInfoBase_.active))
		self.groupRoomTitleLabel_:setString(bm.LangUtil.getText("GROUP","ROOMOWNER_BET",self.groupInfoBase_.sb or 50))
		-- rebate  群主返利比值
		-- admin_rebate  群主返利最终值
		-- dis 群成员充值返利
		self.groupFanliLabel_.setString(self.groupInfoBase_.admin_rebate)
		self.groupMemberTitleLabel_:setString(bm.LangUtil.getText("GROUP","MEMBERNUM",self.groupInfoBase_.pnum,self.groupInfoBase_.num))
		if tonumber(self.groupInfoBase_.dis)>0 then
			self.storeGiftLabel_:setString(string.format("%+d%%", tonumber(self.groupInfoBase_.dis) * 100))
			self.storeGiftIcon_:show()
		else
			self.storeGiftIcon_:hide()
		end

		local imageUrl = self.groupInfoBase_.image_url
		if imageUrl and string.len(imageUrl)>5 then
			nk.ImageLoader:loadAndCacheImage(
	            self.userAvatarLoaderId_, 
	            imageUrl,
	            handler(self, function(obj, success, sprite)
	            	if self.this_ and obj.groupHead_ then
	                	if success then
		                    local tex = sprite:getTexture()
		                    local texSize = tex:getContentSize()
		                    local con = obj.groupHead_
		                    con:setTexture(tex)
		                    con:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
		                    con:setScaleX(AVATAR_SIZE / texSize.width)
		                    con:setScaleY(AVATAR_SIZE / texSize.height)
	                    else
	                    	local con = self.groupHead_
				      		con:setSpriteFrame(display.newSpriteFrame("common_male_avatar.png"))
				      		local texSize = con:getContentSize()
				      		con:setScaleX(AVATAR_SIZE / texSize.width)
				            con:setScaleY(AVATAR_SIZE / texSize.height)
	                    end
	                end
	            end),
	            nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
	        )
	   else
      		local con = self.groupHead_
      		con:setSpriteFrame(display.newSpriteFrame("common_male_avatar.png"))
      		local texSize = con:getContentSize()
      		con:setScaleX(AVATAR_SIZE / texSize.width)
            con:setScaleY(AVATAR_SIZE / texSize.height)
	   end

	   if self:checkIsAdmin_() then
	   		self.cameraIcon_:show()
			self.groupFanliLabel_.node:show()
	   else
	   		self.cameraIcon_:hide()
	   		self.groupFanliLabel_.node:hide()
	   end
	end
end

function GroupInfoView:onNameEdit_(event, editbox)
    if event == "began" then
    	nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    	local text = self.groupNameLabel_:getString()
        editbox:setText(text)
        self.groupNameLabel_:setString("")
    elseif event == "changed" then
    elseif event == "ended" then
    elseif event == "return" then
    	local text = editbox:getText()
    	local filteredText = nk.keyWordFilter(text)
        self.groupNameLabel_:setString(filteredText)
        self:updateGroupName_(filteredText)
        editbox:setText("")
    end
end

-- 群成员列表
function GroupInfoView:addMemberListNode_()
	local frame_w, frame_h = 368 + 25, 310
	local frame = display.newScale9Sprite("#panel_overlay.png", 0, 0, cc.size(frame_w, frame_h))
		:align(display.RIGHT_CENTER, WIDTH/2 - 6, HEIGHT/2 - 35)
		:addTo(self)

   	display.newScale9Sprite("#group_dividing_line.png",
       frame_w/2, frame_h - 44, cc.size(frame_w - 4, 2)):addTo(frame)

   	local label_y = frame_h - 24
	self.groupMemberTitleLabel_ = ui.newTTFLabel({
            text = "",
            color=cc.c3b(0xdc,0xdc,0xff),
            size = 20,
            align = ui.TEXT_ALIGN_LEFT,
        })
    	:align(display.LEFT_CENTER, 10, label_y)
    	:addTo(frame)

    cc.ui.UIPushButton.new({normal = "#group_invite_normal.png", pressed = "#group_invite_down.png"})
    	:setButtonLabel(ui.newTTFLabel({text = bm.LangUtil.getText("GROUP","INVITENEW"),align = ui.TEXT_ALIGN_RIGHT,size = 18,color=cc.c3b(0x73,0xcc,0xe3)}))
    	:setButtonLabelAlignment(display.RIGHT_CENTER)
    	:setButtonLabelOffset(-22, 0)
		:pos(frame_w - 23, label_y)
    	:addTo(frame)
        :onButtonClicked(buttontHandler(self, function()
        	self:onBtnHandler()
            GroupInvitePopup.new(self.group_id_):show()
        end))

    -- 小标题
    local subTitleNode = display.newScale9Sprite("#modal_texture.png",
    	frame_w/2, frame_h - 56, cc.size(frame_w - 4, 24)):addTo(frame)

    ui.newTTFLabel({
        text = bm.LangUtil.getText("GROUP","TOTALACT"),
        color=cc.c3b(0x7a,0x7e,0xca),
        size = 16,
    })
	:pos(240,12)
	:addTo(subTitleNode)

	ui.newTTFLabel({
        text = bm.LangUtil.getText("GROUP","TODAYACT"),
        color=cc.c3b(0x7a,0x7e,0xca),
        size = 16,
        align = ui.TEXT_ALIGN_RIGHT,
    })
	:align(display.RIGHT_CENTER, frame_w-5, 12)
	:addTo(subTitleNode)

	local list_w, list_h = frame_w, frame_h - 80
	GroupMemberListItem.WIDTH = list_w
    self.groupMemberList_ = bm.ui.ListView.new(
        {
            viewRect = cc.rect(-list_w/2, -list_h/2, list_w, list_h),
            upRefresh = handler(self, self.onGroupMemberUpFrefresh_)
        }, 
        GroupMemberListItem
    )
    :pos(frame_w/2, frame_h/2 - 30)
    :addTo(frame)

    self.groupMemberList_:addEventListener("ITEM_EVENT",handler(self,self.onGroupMemberListItemEvent))
end

function GroupInfoView:onGroupMemberUpFrefresh_()
	if self.groupMemberPages_=="end" then return end
	self:setMemberLoading(true)
	bm.HttpService.CANCEL(self.groupInfoMemberId_)
	local page = self.groupMemberPages_ + 1
	self.groupInfoMemberId_ = bm.HttpService.POST(
		{
			mod = "Group",
			act = "getGroupInfo",
			group_id = self.group_id_,
			type = 2,
			page = page,
		},
        function (data)
            if self.this_ then
 				self:setMemberLoading(false)
 				local retData = json.decode(data)
 				if retData and retData.ret==1 and retData.data then
 					local memberList = retData.data
 					if #memberList<1 then
 						self.groupMemberPages_ = "end"
 					else
 						self.groupMemberPages_ = page
 						local allMemberList = self.groupMemberInfo_
 						table.insertto(allMemberList,memberList)
						self.groupMemberList_:setData(allMemberList,true)
 					end
 				else

 				end
 			end
        end,
        function ()
        	if self.this_ then
        		self:setMemberLoading(false)
        	end
        end
    )
end

function GroupInfoView:onGroupMemberListItemEvent(evt)
	if evt.type=="ITEM_CLICK" then
		if not self.groupInfoBase_ then return end
		if tonumber(evt.data.data_.uid)==tonumber(nk.userData.uid) then return end
		if self:checkIsAdmin_() then  -- 管理员
    		self:createUserControl(1,evt)
    	else
    		self:createUserControl(2,evt)
    	end
	end
end

function GroupInfoView:createUserControl(type,evt)
	if self.menuNode_ then
		self.menuNode_:removeFromParent()
        self.menuNode_ = nil
	end

	local btns = {}
	if type==1 then
		table.insert(btns,{"addFriendBtn_",bm.LangUtil.getText("GROUP","ADDFRIENDBTN")})
		table.insert(btns,{"followInBtn_",bm.LangUtil.getText("GROUP","TRACEBTN")})
		table.insert(btns,{"transferBtn_",bm.LangUtil.getText("GROUP","CHANGEBTN")})
		table.insert(btns,{"kickOutBtn_",bm.LangUtil.getText("GROUP","KICKEDOUTBTN")})
	else
		table.insert(btns,{"addFriendBtn_",bm.LangUtil.getText("GROUP","ADDFRIENDBTN")})
		table.insert(btns,{"followInBtn_",bm.LangUtil.getText("GROUP","TRACEBTN")})
	end

	local num = #btns
	local itemWidth, itemHeight = 190, 60
	local w, h = itemWidth, itemHeight*num
	local pos = self:convertToNodeSpace(cc.p(evt.x, evt.y))
	self.menuNode_ = display.newScale9Sprite("#group_help_panel_bg.png", 0, 0, cc.size(w, h))
		:align(display.LEFT_CENTER, pos.x, pos.y)
		:addTo(self)

	self.menuNode_:setTouchEnabled(true)
	self.menuNode_:setTouchSwallowEnabled(true)

	for k,v in ipairs(btns) do
		self[v[1]] = cc.ui.UIPushButton.new({normal = "#transparent.png"},{scale9 = true})
			:setButtonSize(itemWidth, itemHeight)
        	:setButtonLabel(ui.newTTFLabel({text = v[2],size = 22}))
			:align(display.TOP_CENTER, w/2, h - itemHeight * (k - 1))
        	:addTo(self.menuNode_)
	        :onButtonClicked(buttontHandler(self, function()
	            self:onBtnHandler(self[v[1]])
	        end))

	    if k ~= num then  -- 创建分割线
	    	display.newScale9Sprite("#group_dividing_line.png",0,0, cc.size(itemWidth - 2, 2))
	    		:pos(w/2, h - itemHeight*k)
       			:addTo(self.menuNode_)
	    end
	end

	if pos.y < h/2 then -- 超出了边界
		self.menuNode_:align(display.LEFT_BOTTOM, pos.x, pos.y)
	end

	self.controlMember_ = evt.data.data_
end

function GroupInfoView:addRoomListNode_()
	local frame_w, frame_h = 368 + 25, 310
	local frame = display.newScale9Sprite("#panel_overlay.png", 0, 0, cc.size(frame_w, frame_h))
		:align(display.LEFT_CENTER, WIDTH/2 + 6, HEIGHT/2 - 35)
		:addTo(self)

   	display.newScale9Sprite("#group_dividing_line.png",
       frame_w/2, frame_h - 44, cc.size(frame_w - 4, 2)):addTo(frame)

   	local label_y = frame_h - 22
   	self.groupRoomTitleLabel_ = ui.newTTFLabel({
            text = "",
            size = 20,
        })
    	:align(display.LEFT_CENTER, 5, label_y)
    	:addTo(frame)

    cc.ui.UIPushButton.new({normal = "#group_createroom_normal.png", pressed = "#group_createroom_down.png"})
    	:setButtonLabel(ui.newTTFLabel({text = bm.LangUtil.getText("GROUP","CREATROOM"),align = ui.TEXT_ALIGN_RIGHT,size = 18,color = cc.c3b(0xff, 0xff, 0),}))
    	:setButtonLabelAlignment(display.RIGHT_CENTER)
    	:setButtonLabelOffset(-22, 0)
		:pos(frame_w - 23, label_y)
    	:addTo(frame)
        :onButtonClicked(buttontHandler(self, function()
        	self:onBtnHandler()
            GroupCreateRoomPopup.new(self.group_id_, self):show()
        end))

    local list_w, list_h = frame_w, frame_h - 68
    GroupRoomListItem.WIDTH = list_w

    self.groupRoomList_ = bm.ui.ListView.new(
        {
            viewRect = cc.rect(-list_w/2, -list_h/2, list_w, list_h),
            upRefresh = handler(self, self.onGroupRoomFrefresh_)
        }, 
        GroupRoomListItem
    )
    :pos(frame_w/2, frame_h/2 - 20)
    :addTo(frame)

    self.groupRoomList_:setTouchNodeSwallowEnabled(false)
    self.groupRoomList_:addEventListener("ITEM_EVENT",handler(self,self.onJoinGroupRoom))
end

function GroupInfoView:onBtnHandler(btn)
	if self.menuNode_ then
		self.menuNode_:hide()
	end

	if btn~=nil then
		if btn==self.moreMsgBtn_ then
			GroupMsgPopup.new(self.group_id_):show()
		elseif btn==self.moreJoinMsgBtn_ then
			GroupCheckPopup.new(self.group_id_):show()
		elseif btn==self.moreJoinSetBtn_ then
			GroupSettingPopup.new(self.group_id_,self.groupInfoBase_):show()
		elseif btn==self.moreOutBtn_ then
			-- 确认是否退群
			nk.ui.Dialog.new({
                messageText = bm.LangUtil.getText("GROUP","OUTCONFIRM"),
                callback = function (type)
                    if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                        self:quiteGroup(1)
                    end
                end
            }):show()
        elseif btn==self.transferBtn_ then
        	nk.ui.Dialog.new({
                messageText = bm.LangUtil.getText("GROUP","CHANGECONFIRM"),
                callback = function (type)
                    if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                        self:quiteGroup(3,self.controlMember_)
                    end
                end
            }):show()
        elseif btn==self.kickOutBtn_ then
        	nk.ui.Dialog.new({
                messageText = bm.LangUtil.getText("GROUP","KICKEDOUTCONFIRM"),
                callback = function (type)
                    if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                        self:quiteGroup(2,self.controlMember_)
                    end
                end
            }):show()
        elseif btn==self.addFriendBtn_ then
        	if self.controlMember_ then
	        	bm.HttpService.POST({
					mod = "user",
					act = "othermain",
					puid = self.controlMember_.uid},
					function(data)
					    local jsonData = json.decode(data)
					    local friendData = {
					    	isFriend = jsonData.fri,
					    	uid = self.controlMember_.uid,
					    	money = jsonData.money,
					    	exp = jsonData.experience,
					    	win = jsonData.win,
					    	lose = jsonData.lose,
					    	sex = jsonData.sex,
					    	img = jsonData.img,
					    	nick = jsonData.nick,
					    	viplevel = jsonData.viplevel,
					    	rankMoney = jsonData.rankMoney
						}
					   	AddFriendPopup.new(friendData):show(friendData)
					end,
					function()
					end)
	        end
        elseif btn==self.followInBtn_ then  -- 跟踪进房间  有无密码呢？
        	if not self.controlMember_ then
        		nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","ENTERROOMFAIL1"))
       		else
       			if tonumber(self.controlMember_.online)==1 then
       				if self.controlMember_.tid and tonumber(self.controlMember_.tid)>0 then
       					self:enterGroupRoom(nil,self.controlMember_.tid,"",true)
       				else
       					nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","ENTERROOMFAIL2"))
       				end
       			else
       				nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","ENTERROOMFAIL1"))
       			end
        	end
		end
	end
end

function GroupInfoView:onGroupRoomFrefresh_()
	if self.groupRoomListPages_=="end" then return end
	self:setRoomLoading(true)
	bm.HttpService.CANCEL(self.groupInfoRoomId_)
	local page = self.groupRoomListPages_ + 1
	self.groupInfoRoomId_ = bm.HttpService.POST(
		{
			mod = "Group",
			act = "getGroupInfo",
			group_id = self.group_id_,
			type = 3,
			page = page,
		},
        function (data)
            if self.this_ then
 				self:setRoomLoading(false)
 				local retData = json.decode(data)
 				if retData and retData.ret==1 and retData.data then
 					local roomList = retData.data
 					if #roomList<1 then
 						self.groupRoomListPages_ = "end"
 						if self.needReflushRoomListPage_ then
 							local allRoomList = self.groupRoomInfo_
 							self:setGroupRoomListData_(allRoomList, true)
 							self.needReflushRoomListPage_ = nil
 						end
 					else
 						self.groupRoomListPages_ = page
 						local allRoomList = self.groupRoomInfo_
 						table.insertto(allRoomList,roomList)
						self:setGroupRoomListData_(allRoomList, true)
						self.needReflushRoomListPage_ = nil
 					end
 				else
 					
 				end
 			end
        end,
        function ()
        	if self.this_ then
            	self:setRoomLoading(false)
            end
        end
    )
end

function GroupInfoView:onJoinGroupRoom(evt)
	if evt.type=="ITEM_CLICK" then
		self.enterRoomData_ = evt.data.data_
		if self.enterRoomData_ and tonumber(self.enterRoomData_.psword)==1 then
			--- 密码框
			GroupPassWordPopup.new(self.enterRoomData_.id,self.enterRoomData_.tid,self):show()
		else
			self:enterGroupRoom(self.enterRoomData_.id,self.enterRoomData_.tid,"")
		end
	end
end

function GroupInfoView:quiteGroup(type,opData)
	self.delegate_:setLoading(true)
	bm.HttpService.CANCEL(self.quiteGroupId_)
    self.quiteGroupId_ = bm.HttpService.POST(
        {
            mod = "Group",
            act = "changeGroup",
            uid = nk.userData.uid,
			type = type,    -- int(1主动退出群，2群主踢出op_uid，3转让群给op_uid)
			group_id = self.group_id_,  -- int(群组id)
			op_uid = opData and opData.uid or nil,  -- int(被操作的玩家uid)
			mid = opData and opData.id or self.innerGroupId_,-- 群内部IDint(群成员表id)
        },
        function (data)
            if data then
            	if self.this_ then
	        		self.delegate_:setLoading(false)
	        	end

    	       	local retData = json.decode(data)
    	       	if retData and retData.ret==1 then
    	       		if type==1 then
	    	       		self.group_id_ = nil
	    	       		self.innerGroupId_ = nil
	    	       		if nk.userData.groupConfig then
	    	       			nk.userData.groupId = nil
	    	       		end

	    	       		if self.this_ then -- 重新拉去附近的群组
	    	       			self.delegate_:requestGroupConfig()
	    	       		end
	    	       	elseif type==2 then
	    	       		for k,v in ipairs(self.groupMemberInfo_) do
	    	       			if v==opData then
	    	       				table.remove(self.groupMemberInfo_,k,1)
	    	       				break
	    	       			end
	    	       		end
	    	       		self.groupMemberList_:setData(self.groupMemberInfo_,true)
	    	       	elseif type==3 then
	    	       		if self.groupInfoBase_ then
	    	       			self.groupInfoBase_.admin_uid = (opData and opData.uid or nil)
	    	       			GroupMemberListItem.admin_uid = self.groupInfoBase_.admin_uid or 0
	    	       		end
	    	       		-- 更新列表中的所有项
	    	       		self.groupMemberList_:setData(self.groupMemberInfo_,true)
	    	       		self.cameraIcon_:hide()
	    	       	end
	    	    elseif retData and retData.ret==-4 then
	    	    	if self.this_ then -- 被转移成了群主，要重新拉去
	    	    		local t = bm.LangUtil.getText("GROUP", "CHANGEFAIL1")
                    	nk.TopTipManager:showTopTip(t)
    	       			self.delegate_:requestGroupConfig()
    	       		end
    	       	else
    	       		if self.this_ then -- 其他错误  被提出的玩家已经主动退群了
    	       			local t = bm.LangUtil.getText("GROUP", "CHANGEFAIL0")
                    	nk.TopTipManager:showTopTip(t)
    	       			self.delegate_:requestGroupConfig()
    	       		end
    	       	end
	        end
        end,
        function ()
        	if self.this_ then
        		self.delegate_:setLoading(false)
        	end
        end
    )
end

function GroupInfoView:enterGroupRoom(room_id,tid,pass_word,reshowPassWordPopup)
	bm.HttpService.CANCEL(self.enterGroupRoomId_)
	self.delegate_:setLoading(true)
	self.enterGroupRoomId_ = bm.HttpService.POST(
		{
			mod = "Group",
			act = "quickIn",
			uid = nk.userData.uid,
			room_id = room_id,
			tid = reshowPassWordPopup and tid or nil, -- 不进入server流程，直接在PHP验证密码
			psword = pass_word,
		},
		function (data)
            if self.this_ then
            	self.delegate_:setLoading(false)
	 			local retData = json.decode(data)
	 			if retData and tonumber(retData.ret)==1 and retData.data and retData.data.ip then
	 				-- //请求进入群房间
				    bm.EventCenter:dispatchEvent({name = nk.eventNames.ENTER_ROOM_WITH_DATA, data = {
				        ip = retData.data.ip,
				        port = retData.data.port,
				        tid = tid,
				        privateType = retData.data.privateType,
				        psword = pass_word or "",
				        isPlayNow = false,
				        isGroupRoom = true
				    }, isTrace = reshowPassWordPopup})
	 			else
	 				if retData and tonumber(retData.ret)==-4 then
	 					if reshowPassWordPopup then  -- 跟踪进入房间
	 						--- 密码框   第一次请求IP PORT 去人进入的是否是私人房间，是否有密码，有则提示输入密码
							GroupPassWordPopup.new(room_id,tid,self):show()
	 					else
	 						nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","ROOMPSWERROR"))
	 					end
	 				elseif retData and tonumber(retData.ret)==-1 then
	 					nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","ENTERROOMFAIL3"))
	 					-- 重新拉去
	 					self.needReflushRoomListPage_ = true
	 					self.groupRoomListPages_ = 0
						self.groupRoomInfo_ = {}
						self:onGroupRoomFrefresh_()
	 				else
	 					nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","ENTERROOMFAIL"))
	 				end
	 			end
	 		end
        end,
        function ()
        	if self.this_ then
        		self.delegate_:setLoading(false)
        		nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","ENTERROOMFAIL"))
        	end
        end
	)
end

--是否为管理员
function GroupInfoView:checkIsAdmin_()
	if self.groupInfoBase_ and (nk.userData.uid == tonumber(self.groupInfoBase_.admin_uid)) then
		return true
	end

	return false
end

function GroupInfoView:setGroupRoomListData_(data, scroll)
	table.sort(data, function(a, b)
		return a.player > b.player
	end)

	self.groupRoomList_:setData(data, scroll)
end

function GroupInfoView:setMemberLoading(isLoading)
    if isLoading then
        if not self.Memberjuhua_ then
            self.Memberjuhua_ = nk.ui.Juhua.new()
                :pos(190, HEIGHT/2 - 30)
                :addTo(self)
        end
    else
        if self.Memberjuhua_ then
            self.Memberjuhua_:removeFromParent()
            self.Memberjuhua_ = nil
        end
    end
end

function GroupInfoView:setRoomLoading(isLoading)
    if isLoading then
        if not self.Roomjuhua_ then
            self.Roomjuhua_ = nk.ui.Juhua.new()
                :pos(WIDTH - 190, HEIGHT/2 - 30)
                :addTo(self)
        end
    else
        if self.Roomjuhua_ then
            self.Roomjuhua_:removeFromParent()
            self.Roomjuhua_ = nil
        end
    end
end

function GroupInfoView:updateGroupName_(name)
	self.delegate_:setLoading(true)
	bm.HttpService.POST(
        {
            mod = "Group",
            act = "updateGroupConfig",
            group_id = self.groupInfoBase_.id,
            uid = nk.userData.uid,
            group_name = name,  -- 设置群名字
            image_url = self.groupInfoBase_.image_url,  -- 设置群头像
            level = self.groupInfoBase_.level,      -- 入群等级限制
            money = self.groupInfoBase_.money,    -- 入群金币限制
            is_check = self.groupInfoBase_.is_check,   -- 是否需要审核 0： 需要   1：不需要
            description = self.groupInfoBase_.description
        },
        function(data)
        	if self.this_ then
        		self.delegate_:setLoading(false)
        		local retData = json.decode(data)
                if retData and retData.ret == 1 and retData.data then
                	nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP", "SETPOPSETSUCC"))
                	self.groupInfoBase_.group_name = retData.data.group_name
                else
                	nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP", "SETPOPSETFAIL"))
                end
        	end
        end,
        function()
        	if self.this_ then
        		self.delegate_:setLoading(false)
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP", "SETPOPSETFAIL"))
        	end
        end)
end

function GroupInfoView:onCleanup()
	nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
	bm.HttpService.CANCEL(self.createGroupRequestId_)
	bm.HttpService.CANCEL(self.createGroupConfigId_)
	bm.HttpService.CANCEL(self.groupInfoBaseId_)
	bm.HttpService.CANCEL(self.groupInfoMemberId_)
	bm.HttpService.CANCEL(self.groupInfoRoomId_)
	bm.HttpService.CANCEL(self.groupInfoAllId_)
	
	bm.HttpService.CANCEL(self.quiteGroupId_)
	bm.HttpService.CANCEL(self.updateGroupPhotoId_)
	bm.HttpService.CANCEL(self.groupTangGuoId_)
	bm.HttpService.CANCEL(self.enterGroupRoomId_)

	Global_isInGroupShop = nil
	Global_inGroupShopDis = nil

	if self.nameEdit_ then
        nk.EditBoxManager:removeEditBox(self.nameEdit_)
    end
end

return GroupInfoView
