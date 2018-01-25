
local HighRoomRewardListItem = class("HighRoomRewardListItem", bm.ui.ListItem)

function HighRoomRewardListItem:ctor()
    HighRoomRewardListItem.super.ctor(self, 700, 37)
    self:createContent_()
end

local SB_COLOR = cc.c3b(0xff, 0xd2, 0x00)
local CONTENT_COLOR = cc.c3b(0xff, 0xff, 0xff)

function HighRoomRewardListItem:createContent_()
    local posY = self.height_ * 0.5

    self.sb_ = ui.newTTFLabel({text = "", color = SB_COLOR, size = 20, align = ui.TEXT_ALIGN_CENTER})
        :pos(54, posY)
        :addTo(self)
    self.reward_ = ui.newTTFLabel({text = "", color = CONTENT_COLOR, size = 17, align = ui.TEXT_ALIGN_CENTER})
        :pos(248, posY)
        :addTo(self)
    self.progress_ = ui.newTTFLabel({text = "", color = CONTENT_COLOR, size = 20, align = ui.TEXT_ALIGN_CENTER})
        :pos(456, posY)
        :addTo(self)

    self.rewards_ = cc.ui.UIPushButton.new({normal = "#pop_room_high_list_button.png"}, {scale9=true})
    self.rewards_:onButtonClicked(function(evt)
        local thisTime = bm.getTime()
        if not buyBtnLastClickTime or math.abs(thisTime - buyBtnLastClickTime) > 2 then
            buyBtnLastClickTime = thisTime
            nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
            self:onRewardClick_()
        end
    end)
    self.rewards_:setButtonSize(130, 36)
    self.rewards_:pos(624, posY)
    self.rewards_:addTo(self)
    self.rewards_:hide()

    self.status_ = ui.newTTFLabel({text = "", color = CONTENT_COLOR, size = 20, align = ui.TEXT_ALIGN_CENTER})
        :pos(624, posY)
        :addTo(self)
end

function HighRoomRewardListItem:onDataSet(dataChanged, data)
    if dataChanged then
        self.data_ = data
        self.sb_:setString(data.sb)
        self.reward_:setString(data.tips)
        self.progress_:setString(data.nums)

        if data.status == 1 then
            self.status_:setString(bm.LangUtil.getText("PLAYER_BACK", "GET_REWARD"))
            self.rewards_:show()
        elseif data.status == 3 then
            self.status_:setString(bm.LangUtil.getText("LOTTERY", "RESULT_WIN_GOT"))
            self.rewards_:hide()
        elseif data.status == 2 then
            self.status_:setString(bm.LangUtil.getText("HALLOWEEN", "GOPLAY"))
            self.rewards_:show()
        end
    end
end

function HighRoomRewardListItem:onRewardClick_()
    if self.data_.status == 2 then
        self:gotoHighRoom(self.data_.sb)
        self:onTraceClick_()
    elseif self.data_.status == 1 then
        self:getReward()
    end
end

function HighRoomRewardListItem:getReward()
    bm.HttpService.POST({mod="RecordNum", act="getReward", sb=self.data_.sb},
        function(data)
            local callData = json.decode(data)
            if callData and callData.code and callData.code > 0 then
                self.data_.status = 3
                self.status_:setString(bm.LangUtil.getText("LOTTERY", "RESULT_WIN_GOT"))
                self.rewards_:hide()
                if callData.tips then 
                    nk.TopTipManager:showTopTip(callData.tips)
                end
                self:updateGameNumber()
            end
        end, function()
    end)
end

function HighRoomRewardListItem:updateGameNumber()
    local curScene = display.getRunningScene()
    if curScene.name == "RoomScene" and curScene.controller then
        curScene.controller:checkReportGameNumber(0)
    end
end

function HighRoomRewardListItem:gotoHighRoom(sb_)
    local curScene = display.getRunningScene()
    if curScene.name == "RoomScene" then
        curScene:onChangeRoom_(false, false, sb_)
    end
end

function HighRoomRewardListItem:onTraceClick_()
    nk.PopupManager:removeAllPopup()
end

function HighRoomRewardListItem:onCleanup()
end

return HighRoomRewardListItem