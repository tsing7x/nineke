
--
-- Author: thinkeras3@163.com
-- Date: 2015-09-01 20:26:50
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- 在房间里显示 召回好友 邀请

local SeatInviteView = class("SeatInviteView", function() 
    return display.newNode()
end)

local logger = bm.Logger.new("SeatInviteView")

SeatInviteView.CLICKED = "SeatInviteView.CLICKED"
SeatInviteView.WIDTH = 108
SeatInviteView.HEIGHT = 164

function SeatInviteView:ctor(ctx)
	self.ctx_ = ctx

	bm.EventCenter:addEventListener(nk.eventNames.UPDATE_SEAT_INVITE_VIEW, handler(self, self.onReciveData))

    local lastLoginType = nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE)
    
    if lastLoginType ==  "FACEBOOK" then
        if nk.Facebook then
             bm.HttpService.POST(
                {
                    mod = "recall",
                    act = "list"
                },
                function(data)

                    self:onGetData_(true, json.decode(data))
                end,
                function(data)
                end)
         else
            self:stopAll()
         end
    else
        self:stopAll()
    end 
end

function SeatInviteView:createNode_()
	self.background_ = display.newScale9Sprite("#room_seat_bg.png", 0, 0, cc.size(SeatInviteView.WIDTH, SeatInviteView.HEIGHT)):addTo(self, 2)
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

    self.cover_ = display.newRect(100, 100, {fill=true, fillColor=ccc4f(0, 0, 0, 0.6)}):addTo(self, 5, 5):hide()
    self.nick_ = ui.newTTFLabel({text = "", size = 24, align = ui.TEXT_ALIGN_CENTER, color=cc.c3b(0xff, 0xd1, 0x00)})
    :pos(0, 66)
    :addTo(self, 7, 7)

    cc.ui.UIPushButton.new({normal = "#common_green_btn_up.png", pressed = "#common_green_btn_down.png"}, {scale9 = true})
        :setButtonSize(106, 36)
        :setButtonLabel(ui.newTTFLabel({text=bm.LangUtil.getText("FRIEND", "RECALL_TITLE"), size=20, color=cc.c3b(0xff, 0xff, 0xff), align=ui.TEXT_ALIGN_CENTER}))
        :addTo(self,2)
        :pos(0,-68)
        :onButtonClicked(buttontHandler(self, self.onInviteClick_))
end

function SeatInviteView:setViewInfo_(data)
    self.nick_:setString(nk.Native:getFixedWidthText("", 24, self.tempFriend.name, 110))
	if string.len(data.url) > 5 then
	    local imgurl = data.url
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
function SeatInviteView:userImageLoadCallback_(success, sprite)
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

function SeatInviteView:onGetData_(success, friendData, filterStr)
    if success then
    	if #friendData == 0 then

    	else
            self:createNode_()
            self.isInited = true

            -- 排除今日邀请过的
            local invitedNames = nk.userDefault:getStringForKey(nk.cookieKeys.FACEBOOK_INVITED_NAMES, "")
            local yesterdayInvitedNames = nk.userDefault:getStringForKey(nk.cookieKeys.YESTERDAY_INVITED_NAMES, "")
            logger:debug("invitedNames:" .. invitedNames)
            self.pageNum_ = checkint(nk.userDefault:getStringForKey(nk.cookieKeys.FACEBOOK_INVITED_PAGE, 0))
            local yesterday = os.date("%Y%m%d",os.time() - 86400)
            local needYesterday = #friendData > 200
            local yesterdayInvitedNames = ""

            if yesterdayInvitedNames ~= "" then
                local yesterdayNamesTable = string.split(yesterdayInvitedNames, "#")
                if yesterdayNamesTable[1] ~=  yesterday then
                    nk.userDefault:setStringForKey(nk.cookieKeys.YESTERDAY_INVITED_NAMES, "")
                    yesterdayInvitedNames = ""
                end
            end

            if invitedNames ~= "" then
                local namesTable = string.split(invitedNames, "#")
                if namesTable[1] == yesterday then
                    nk.userDefault:setStringForKey(nk.cookieKeys.YESTERDAY_INVITED_NAMES, invitedNames)
                    nk.userDefault:setStringForKey(nk.cookieKeys.FACEBOOK_INVITED_NAMES, "")
                    yesterdayInvitedNames = invitedNames
                    invitedNames = ""
                elseif namesTable[1] ~= os.date("%Y%m%d") then
                    nk.userDefault:setStringForKey(nk.cookieKeys.FACEBOOK_INVITED_NAMES, "")
                    invitedNames = ""
                end
            end

            if invitedNames ~= "" then
                local namesTable = string.split(invitedNames, "#")
                table.remove(namesTable, 1)
                for _, name in pairs(namesTable) do
                    local i, max = 1, #friendData
                    while i <= max do
                        if friendData[i].name == name then
                            logger:debug("remove invited name -> ", name)
                            table.remove(friendData, i)
                            i = i - 1
                            max = max - 1
                        end
                        i = i + 1
                    end
                end
            end

            if needYesterday and yesterdayInvitedNames ~= "" then
                local yesterdayNamesTable = string.split(yesterdayInvitedNames, "#")
                table.remove(yesterdayNamesTable, 1)
                for _, name in pairs(yesterdayNamesTable) do
                    local i, max = 1, #friendData
                    while i <= max do
                        if friendData[i].name == name then
                            logger:debug("remove invited name -> ", name)
                            table.remove(friendData, i)
                            i = i - 1
                            max = max - 1
                        end
                        i = i + 1
                    end
                end
            end

            if filterStr and filterStr ~= "" then
                print("string.lower(filterStr):" .. string.lower(filterStr))
                local tmpData = {}
                for k, v in pairs(friendData) do
                    if (string.find(string.lower(v.name),string.lower(filterStr)) ~= nil) then
                        table.insert(tmpData,v)
                    end
                end
                friendData = tmpData
            end

            self.friendData_ = friendData;
	    end
    end
end

function SeatInviteView:changeFriend() 
    local index = checkint(math.random(#self.friendData_))
    self.tempFriend = self.friendData_[index];
    self:setViewInfo_(self.tempFriend)
end


function SeatInviteView:onInviteClick_()
	local toIds = ""
    local names = ""
	local toIdArr = {}
    local nameArr = {}
    self.clickedData = self.tempFriend;
    self.lastTid_ = self.ctx_.model.roomInfo.tid;

    self:stopAll()
    table.insert(toIdArr, self.clickedData.id)
    table.insert(nameArr, self.clickedData.name)
    toIds = table.concat(toIdArr, ",")
    names = table.concat(nameArr, "#")

    local typeVal = nil

    if device.platform == "ios" or device.platform == "android" then
        cc.analytics:doCommand{
            command = "event",args = {eventId = "room_seat_invite_click",label = "room_seat_invite_click"}
        }
    end

    -- 发送邀请
    if toIds ~= "" then
        bm.HttpService.POST(
            {
                mod = "recall", 
                act = "getRecallID"
            }, 
            function (data)
                local retData = json.decode(data)
                local requestData
                if retData.ret and retData.ret == 0 then
                    requestData = "u:"..retData.u..";id:"..retData.id..";sk:"..retData.sk
                else
                    return
                end

                nk.Facebook:sendInvites(
                    "oldUserRecall" .. requestData, 
                    toIds, 
                    bm.LangUtil.getText("FRIEND", "INVITE_SUBJECT"), 
                    bm.LangUtil.getText("FRIEND", "INVITE_CONTENT_OLDUSER"), 
                    function (success, result)
                        if success then

                            -- 去掉最后一个逗号
                            if result.toIds then
                                local idLen = string.len(result.toIds)
                                if idLen > 0 and string.sub(result.toIds, idLen, idLen) == "," then
                                    result.toIds = string.sub(result.toIds, 1, idLen - 1)
                                end
                            end
                            -- 上报php，领奖
                            local postData = {
                                mod = "recall", 
                                act = "report", 
                                data = requestData, 
                                requestid = result.requestId, 
                                list = result.toIds, 
                                sig = crypto.md5(result.toIds .. "ab*&()[cae!@+?>#5981~.,-zm"),
                                source = "recall",
                                type = "recall"
                            }
                            bm.HttpService.POST(
                                postData, 
                                function (data)
                                    local retData = json.decode(data)
                                    if retData and retData.ret == 0 and retData.money and retData.money > 0 then
                                        local historyVal = nk.userDefault:getIntegerForKey(nk.cookieKeys.FACEBOOK_INVITE_MONEY, 0)
                                        historyVal = historyVal + retData.money
                                        nk.userDefault:setIntegerForKey(nk.cookieKeys.FACEBOOK_INVITE_MONEY, historyVal)
                                        -- 给出提示
                                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "INVITE_SUCC_TIP", retData.money))
                                    end
                                end
                            )
                        end
                    end
                )
            end, 
            function ()
            end)
    end
                
end

function SeatInviteView:onReciveData(evt)
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
function SeatInviteView:runTime()
    self:stopAction(self.actions_)
    self.actions_ = self:schedule(function ()
        self:changeFriend()
        self:runTime()
    end,20)
end
function SeatInviteView:onCleanup()
	bm.EventCenter:removeEventListener(nk.eventNames.UPDATE_SEAT_INVITE_VIEW)
end

function SeatInviteView:stopAll()
            self.inviteSeatId = nil
            self:hide()
            self.isShow = false;
            self:stopAction(self.actions_)
end

return SeatInviteView