--
-- Author: KevinYu
-- Date: 2017-01-18 11:21:37
-- 邀请好友或者群友进入房间
--SeatInvitePlayView

local SeatInvitePlayView = class("SeatInvitePlayView", function() 
    return display.newNode()
end)

local logger = bm.Logger.new("SeatInvitePlayView")
local InvitePlayPopup = import("app.module.room.views.InvitePlayPopup")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

local WIDTH, HEIGHT = 108, 164
local friendDataGlobal
local requestRetryTimes

function SeatInvitePlayView:ctor(ctx)
	self.ctx_ = ctx
    self:hide()
    requestRetryTimes = 3
	bm.EventCenter:addEventListener(nk.eventNames.UPDATE_SEAT_INVITE_PLAY_VIEW, handler(self, self.onReciveData))
	if ctx.model:isGroupRoom() then
        self:getGroupMemberData_()
    else
        self.friendDataPage_ = 1
        friendDataGlobal = {}
        self:getFriendsData_()
    end
end

function SeatInvitePlayView:getFriendsData_()
    bm.HttpService.POST(
        {
            mod = "friend",
            act = "list",
            new = 1,
            page = self.friendDataPage_
        },
        function(data)
            local retData = json.decode(data)
            local friendData = retData.flist or {}
            if #friendData == 0 then
                self:handlerFriendsData_()
            else
                table.insertto(friendDataGlobal, friendData)
                self.friendDataPage_ = self.friendDataPage_ + 1
                self:getFriendsData_()
            end  
        end,
        function()
            if requestRetryTimes > 0 then
                requestRetryTimes = requestRetryTimes - 1
                scheduler.performWithDelayGlobal(handler(self, self.getFriendsData_), 1)
            else --如果没获取完全部好友，显示当前获取到的
                self:handlerFriendsData_()
            end
        end
    )
end

function SeatInvitePlayView:handlerFriendsData_()
    local inviteData = {}
    for _, v in ipairs(friendDataGlobal) do
        local data = {
            img = v.img,
            sex = v.sex,
            nick = v.nick,
            money = v.money,
            isOnline = v.isOnline,
            uid = v.uid
        }
        
        table.insert(inviteData, data)
    end

    table.sort(inviteData, function(a, b)
        return a.isOnline > b.isOnline
    end)
    self:onGetData_(inviteData)
end

function SeatInvitePlayView:getGroupMemberData_()
    bm.HttpService.POST(
        {
            mod = "Group",
            act = "getGroupInfo",
            group_id = nk.userData.groupId,
            type = 2,
            room = 1
        },
        function (data)
            local retData = json.decode(data)
            local inviteData = {}
            for _, v in ipairs(retData.data) do
                local data = {}
                local data = {
                    img = v.s_picture,
                    sex = v.sex,
                    nick = v.nick,
                    money = v.money,
                    uid = v.uid
                }
                table.insert(inviteData, data)
            end
            self:onGetData_(inviteData)
        end,
        function()
            if requestRetryTimes > 0 then
                requestRetryTimes = requestRetryTimes - 1
                scheduler.performWithDelayGlobal(handler(self, self.getGroupMemberData_), 1)
            end
        end
    )
end

function SeatInvitePlayView:createNode_()
	self.background_ = display.newScale9Sprite("#room_seat_bg.png", 0, 0, cc.size(WIDTH, HEIGHT)):addTo(self, 2)
    self.image_ = display.newNode():add(display.newSprite("#common_male_avatar.png"), 1, 1):pos(0, 0)

    --4 用户头像剪裁节点
    self.clipNode_ = cc.ClippingNode:create()

    local stencil = display.newDrawNode()
    local pn = {{-50, -50}, {-50, 50}, {50, 50}, {50, -50}}  
    local clr = cc.c4f(255, 0, 0, 255)  
    stencil:drawPolygon(pn, clr, 1, clr)

    self.clipNode_:setStencil(stencil)
    self.clipNode_:addChild(self.image_, 2, 2)
    self.clipNode_:addTo(self, 4, 4)

    self.nick_ = ui.newTTFLabel({text = "", size = 24, align = ui.TEXT_ALIGN_CENTER, color=cc.c3b(0xff, 0xd1, 0x00)})
        :pos(0, 66)
        :addTo(self, 7, 7)

    cc.ui.UIPushButton.new({normal = "#common_green_btn_up.png", pressed = "#common_green_btn_down.png"}, {scale9 = true})
        :setButtonSize(106, 36)
        :setButtonLabel(ui.newTTFLabel({text=bm.LangUtil.getText("GROUP","ROOM_PLAY_CARD"), size=20, color=cc.c3b(0xff, 0xff, 0xff), align=ui.TEXT_ALIGN_CENTER}))
        :addTo(self,2)
        :pos(0,-68)
        :onButtonClicked(buttontHandler(self, self.onInvitePlayClick_))
end

function SeatInvitePlayView:setViewInfo_(data)
    if data.nick then
        self.nick_:setString(nk.Native:getFixedWidthText("", 24, data.nick, 110))
    end

	if data.img and string.len(data.img) > 5 then
	    local imgurl = data.img
	    if string.find(imgurl, "facebook") then
		    if string.find(imgurl, "?") then
		        imgurl = imgurl .. "&width=200&height=200"
		    else
		        imgurl = imgurl .. "?width=200&height=200"
		    end
		end
		self.seatImageLoaderId_ = nk.ImageLoader:nextLoaderId()
	    nk.ImageLoader:loadAndCacheImage(self.seatImageLoaderId_,
	        imgurl, 
	        handler(self,self.userImageLoadCallback_),
	        nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
	    )
	end
end

function SeatInvitePlayView:userImageLoadCallback_(success, sprite)
    if success and self.image_ then
        local img = self.image_:getChildByTag(1)
        if img then
            img:removeFromParent()
        end
        local spsize = sprite:getContentSize()
        if spsize.width > spsize.height then
            sprite:scale(100 / spsize.width)
        else
            sprite:scale(100 / spsize.height)
        end
        spsize = sprite:getContentSize()
        local seatSize = self:getContentSize()
        
        sprite:pos(seatSize.width * 0.5, seatSize.height * 0.5):addTo(self.image_, 1, 1)
    end
end

function SeatInvitePlayView:onGetData_(data)
    if #data == 0 then
    else
        self:createNode_()
        self.isInited = true
        self.allFriendData_ = data
        if self.evt_ then --可能出现数据还没获取到，就调用onReciveData，导致显示在左下角，这里主动刷新一次
            self:onReciveData(self.evt_)
        end
    end
end

--过滤房间已在房间内的玩家数据
function SeatInvitePlayView:filterFriendData_()
    local _, uidList = self.ctx_.model:getTableAllUid()
    local friendData = {}
    local filterList = {}
    for _, v in ipairs(uidList) do
        filterList[v] = true
    end

    for _, v in ipairs(self.allFriendData_) do
        local index = tonumber(v.uid)
        if not filterList[index] then
            table.insert(friendData, v)
        end
    end

    return friendData
end

function SeatInvitePlayView:changeFriend()
    local index = checkint(math.random(#self.filterData_))
    if index <= #self.filterData_ and index > 0 then
        self:setViewInfo_(self.filterData_[index])
    end
end

function SeatInvitePlayView:onInvitePlayClick_()
    self:stopAll()
    self.lastTid_ = self.ctx_.model.roomInfo.tid
    InvitePlayPopup.new(self.ctx_.model.roomInfo, self.filterData_):show()
end

function SeatInvitePlayView:onReciveData(evt)
	local seatId = evt.data.seatId
	local standUpSeatId = evt.data.standUpSeatId

    if not self.isInited then
        self.evt_ = evt
        return
    end

    self.evt_ = nil

    if not self.allFriendData_ then
        return
    end

    self.filterData_ = self:filterFriendData_() --必须在这过滤，这里每次坐下站起调用

    if #self.filterData_ == 0 then
        return
    end

	--如果已经已经有显示出ui，并且不等于新坐下的玩家ID，不操作
	if seatId and self.isShow and seatId ~= self.inviteSeatId then
		return
	end

	--如果有人站起，并且ui已经显示出来，不操作
	if standUpSeatId and self.isShow and self.ctx_.model:isSelfInSeat() then
		return
	end

	self:stopAction(self.actions_)
	self:hide()
    self.isShow = false
	self.inviteSeatId = nil

	self.actions_ = self:schedule(function ()
		local emptySeatId = self.ctx_.seatManager:getEmptySeatId()
		if emptySeatId and self.ctx_.model:isSelfInSeat() and self.lastTid_ ~= self.ctx_.model.roomInfo.tid then
            self:show()
            self.isShow = true
		    local seatView_ = self.ctx_.seatManager:getSeatView(emptySeatId)
		    self.inviteSeatId = emptySeatId
		    local tempX,tempY = seatView_:getPosition()
		    self:pos(tempX,tempY)
		    self:stopAction(self.actions_)
            self:changeFriend()
            self:runTime()
		else
			self:stopAll()
		end
	end, 1)
end

function SeatInvitePlayView:runTime()
    self:stopAction(self.actions_)
    self.actions_ = self:schedule(function ()
        self:changeFriend()
        self:runTime()
    end, 20)
end

function SeatInvitePlayView:onCleanup()
	bm.EventCenter:removeEventListenersByEvent(nk.eventNames.UPDATE_SEAT_INVITE_PLAY_VIEW)
end

function SeatInvitePlayView:stopAll()
    self.inviteSeatId = nil
    self:hide()
    self.isShow = false
    self:stopAction(self.actions_)
end

return SeatInvitePlayView