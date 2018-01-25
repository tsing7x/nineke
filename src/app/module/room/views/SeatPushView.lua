
--
-- Author: thinkeras3@163.com
-- Date: 2015-09-01 20:26:50
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- 在房间里显示 召回好友 邀请

local PushMsgPopup        = import("app.module.playerback.PushMsgPopup")

local SeatPushView = class("SeatPushView", function() 
    return display.newNode()
end)

local logger = bm.Logger.new("SeatPushView")

SeatPushView.CLICKED = "SeatPushView.CLICKED"
SeatPushView.WIDTH = 108
SeatPushView.HEIGHT = 164

function SeatPushView:ctor(ctx)
	self.ctx_ = ctx
	bm.EventCenter:addEventListener(nk.eventNames.UPDATE_SEAT_PUSH_VIEW, handler(self, self.onReciveData))
    bm.HttpService.POST(
        {
            mod = "friend",
            act = "list",
            washed = 14,
            offline = 1
        },
        function(data)
            self:onGetData_(true, json.decode(data))
        end,
        function(data)
        end)
end

function SeatPushView:createNode_()
	self.background_ = display.newScale9Sprite("#room_seat_bg.png", 0, 0, cc.size(SeatPushView.WIDTH, SeatPushView.HEIGHT)):addTo(self, 2)
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
        :setButtonLabel(ui.newTTFLabel({text=bm.LangUtil.getText("PUSHMSG", "PUSH_ROOM_BTN"), size=20, color=cc.c3b(0xff, 0xff, 0xff), align=ui.TEXT_ALIGN_CENTER}))
        :addTo(self,2)
        :pos(0,-68)
        :onButtonClicked(buttontHandler(self, self.onPushClick_))
end

function SeatPushView:setViewInfo_(data)
    self.nick_:setString(nk.Native:getFixedWidthText("", 24, self.tempFriend.nick, 110))
	if string.len(data.img) > 5 then
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
function SeatPushView:userImageLoadCallback_(success, sprite)
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

function SeatPushView:onGetData_(success, friendData)
    if success then
        if #friendData == 0 then
        else
            self:createNode_()
            self.isInited = true
            self.friendData_ = friendData
        end
    end
end

function SeatPushView:changeFriend() 
    local index = checkint(math.random(#self.friendData_))
    self.tempFriend = self.friendData_[index];
    self:setViewInfo_(self.tempFriend)
end


function SeatPushView:onPushClick_()
    self:stopAll()
    PushMsgPopup.new(" ","room", true, 2):show()
end

function SeatPushView:onReciveData(evt)
	self.ctx_ = evt.data.ctx;
	local seatId = evt.data.seatId;
	local standUpSeatId = evt.data.standUpSeatId;

    --没有初始化完成，一切都是个屁
    if not self.isInited then
        return
    end
    if not self.friendData_ then
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
    self.isShow = false;
	self.inviteSeatId = nil;

    if #self.friendData_ == 0 then
        return
    end
	self.actions_ = self:schedule(function ()
		local emptySeatId = self.ctx_.seatManager:getEmptySeatId()
		if emptySeatId and self.ctx_.model:isSelfInSeat() and self.lastTid_ ~= self.ctx_.model.roomInfo.tid then
			self:show()
            self.isShow = true;
		    local seatView_ = self.ctx_.seatManager:getSeatView(emptySeatId)
		    self.inviteSeatId = emptySeatId;
		    local tempX,tempY = seatView_:getPosition()
		    self:pos(tempX,tempY)
		    self:stopAction(self.actions_)
            self:changeFriend()
            self:runTime()
		else
			self:stopAll()
		end
	end,1)
end
function SeatPushView:runTime()
    self:stopAction(self.actions_)
    self.actions_ = self:schedule(function ()
        self:changeFriend()
        self:runTime()
    end,20)
end
function SeatPushView:onCleanup()
	bm.EventCenter:removeEventListener(nk.eventNames.UPDATE_SEAT_PUSH_VIEW)
end

function SeatPushView:stopAll()
    self.inviteSeatId = nil
    self:hide()
    self.isShow = false;
    self:stopAction(self.actions_)
end

return SeatPushView