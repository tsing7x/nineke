--
-- Author: Jonah0608@gmail.com
-- Date: 2015-08-21 12:00:50
--

local StorePopup = import("app.module.newstore.StorePopup")

local DealerHddjDialog = class("DealerHddjDialog", function()
    return display.newNode()
end)

function DealerHddjDialog:ctor(ctx)
    self.ctx = ctx
    display.addSpriteFrames("hddjd/hddjd.plist", "hddjd/hddjd.png")
    display.newSprite("#hddjd_bg.png"):pos(0, 160):addTo(self):setTouchEnabled(true)

    --荷官互动道具的图片,位置x,位置y,道具编号信息
    local hddjd_const = {}
    -- hddjd_const[1] = {"#hddjd_egg_icon.png", -137, 215, 1}
    hddjd_const[1] = {"#hddjd_hammer_icon.png", -137, 215, 8}
    
    hddjd_const[2] = {"#hddjd_water_icon.png", -124, 140, 2}

    -- hddjd_const[3] = {"#hddjd_rose_icon.png", -75, 83, 3}
    hddjd_const[3] = {"#hddjd_egg_icon.png", -75, 83, 1}

    -- hddjd_const[4] = {"#hddjd_kiss_icon.png", 0, 60, 4}
    hddjd_const[4] = {"#hddjd_tomato_icon.png", 0, 60, 6}

    -- hddjd_const[5] = {"#hddjd_tomato_icon.png", 75, 83, 6}
    hddjd_const[5] = {"#hddjd_rose_icon.png", 75, 83, 3}

    -- hddjd_const[6] = {"#hddjd_dog_icon.png", 124, 140, 7}
    hddjd_const[6] = {"#hddjd_beer_icon.png", 124, 140, 5}

    -- hddjd_const[7] = {"#hddjd_bomb_icon.png", 137, 215, 9}
    hddjd_const[7] = {"#hddjd_kiss_icon.png", 137, 215, 4}

    for k, v in pairs(hddjd_const) do
        cc.ui.UIPushButton.new({normal=v[1]}):pos(v[2], v[3])
                :onButtonClicked(function()
                        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                        self:sendHddjClicked_(v[4])
                    end)
                :addTo(self)
    end

    self:pos(display.cx, display.cy)
end

function DealerHddjDialog:sendHddjClicked_(hddjId)
    if self.ctx.model:isSelfInSeat() then
        self.sendHddjId_ = hddjId
        if nk.userData.hddjNum then
            self:doSendHddj()
        else
            self.hddjNumObserverId_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "hddjNum", handler(self, self.doSendHddj))
            bm.EventCenter:dispatchEvent(nk.eventNames.ROOM_LOAD_HDDJ_NUM)
        end
    else
        --不在座位不能发送互动道具
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SEND_HDDJ_NOT_IN_SEAT"))
    end
end

function DealerHddjDialog:doSendHddj()
    if nk.userData.hddjNum then
        if self.hddjNumObserverId_ then
            bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "hddjNum", self.hddjNumObserverId_)
            self.hddjNumObserverId_ = nil
        end

        if nk.userData.hddjNum > 0 then
            self:sendHddjAndHide_()
        else
            bm.HttpService.POST({mod="user", act="getUserFun"}, function(ret)
                local num = tonumber(ret)
                if num then
                    nk.userData.hddjNum = num
                    if num > 0 then
                        self:sendHddjAndHide_()
                    else
                        self:showHddjNotEnoughDialog_()
                    end
                end
            end,
            function()
                if times > 0 then
                    request(times - 1)
                else
                    self:showHddjNotEnoughDialog_()
                end
            end)
        end
    end
end


function DealerHddjDialog:sendHddjAndHide_()
    nk.userData.hddjNum = nk.userData.hddjNum - 1
    print("UserInfoOtherDialog:sendHddjAndHide_::::::")
    print("hddjId="..self.sendHddjId_)
    print("selfSeatId="..self.ctx.model:selfSeatId())
    bm.HttpService.POST({mod="user", act="useUserFun", hddjId=self.sendHddjId_, selfSeatId=self.ctx.model:selfSeatId(), receiverSeatId=10},
        function(ret)
            --返回2成功
            print("use hddj ret -> ".. ret)
        end, function()
            print("use hddj fail")
        end)
    --nk.socket.RoomSocket:sendSendHddj(self.ctx.model:selfSeatId(), self.data_.seatId, self.sendHddjId_)
    self.ctx.animManager:playHddjAnimation(self.ctx.model:selfSeatId(), 10, self.sendHddjId_)
    self:hide()
end

function DealerHddjDialog:showHddjNotEnoughDialog_()
    nk.ui.Dialog.new({
        messageText = bm.LangUtil.getText("ROOM", "SEND_HDDJ_NOT_ENOUGH"), 
        firstBtnText = bm.LangUtil.getText("COMMON", "CANCEL"),
        secondBtnText = bm.LangUtil.getText("COMMON", "BUY"), 
        callback = function (type)
            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                self:hide()
                StorePopup.new(2):showPanel()
            end
        end
    }):show()
end


function DealerHddjDialog:show()
    -- nk.PopupManager:addPopup(self)
    nk.PopupManager:addPopup(self, isModal ~= false, false, closeWhenTouchModel ~= false, false)
    return self
end

function DealerHddjDialog:onShowed()
end

function DealerHddjDialog:hide()
    nk.PopupManager:removePopup(self)
    return self
end

return DealerHddjDialog