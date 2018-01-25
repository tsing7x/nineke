
local LotteryRecordListItem = class("LotteryRecordListItem", bm.ui.ListItem)

function LotteryRecordListItem:ctor()
    LotteryRecordListItem.super.ctor(self, 560, 45)
    self:createContent_()
end

function LotteryRecordListItem:createContent_()
    local posY = self.height_ * 0.5

    self.bg1_ = display.newScale9Sprite("#pop_lottery_record_item1.png", self.width_ * 0.5, self.height_ * 0.5, cc.size(self.width_, self.height_))
        :addTo(self)
    self.bg2_ = display.newScale9Sprite("#pop_lottery_record_item2.png", self.width_ * 0.5, self.height_ * 0.5, cc.size(self.width_, self.height_))
        :addTo(self)

    self.time_ = ui.newTTFLabel({text = "", color = textColor, size = 16, align = ui.TEXT_ALIGN_CENTER})
        :pos(70, posY)
        :addTo(self)
    self.number_ = ui.newTTFLabel({text = "", color = textColor, size = 18, align = ui.TEXT_ALIGN_CENTER})
        :pos(210, posY)
        :addTo(self)
    self.buy_ = ui.newTTFLabel({text = "", color = textColor, size = 18, align = ui.TEXT_ALIGN_CENTER})
        :pos(350, posY)
        :addTo(self)

    self.rewards_ = cc.ui.UIPushButton.new({normal="#pop_lottery_record_win.png"}, {scale9=true})
    self.rewards_:onButtonClicked(function(evt)
        local thisTime = bm.getTime()
        if not buyBtnLastClickTime or math.abs(thisTime - buyBtnLastClickTime) > 2 then
            buyBtnLastClickTime = thisTime
            nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
            self:getReward()
        end
    end)
    self.rewards_:setButtonSize(130, 36)
    self.rewards_:pos(490, posY)
    self.rewards_:addTo(self)
    self.rewards_:hide()

    self.win_ = ui.newTTFLabel({text = "", color = textColor, size = 18, align = ui.TEXT_ALIGN_CENTER})
        :pos(490, posY)
        :addTo(self)

end

function LotteryRecordListItem:modifyTHDate(date_)
    local year = string.sub(date_, 1, 4)
    local other = string.sub(date_, 5)
    local yearTh = tonumber(year) + 543
    local result = other .. yearTh
    return result
end

function LotteryRecordListItem:onDataSet(dataChanged, data)
    if dataChanged then
        self.data_ = data
        local index = self:getIndex()
        if index and index%2 == 1 then
            self.bg1_:show()
            self.bg2_:hide()
        else
            self.bg1_:hide()
            self.bg2_:show()
        end
        self.time_:setString(self:modifyTHDate(data.date))
        self.number_:setString(data.number)

        local buymoney_ = ""
        local remoney_ = ""
        if tonumber(data.type) == 1 then
            buymoney_ = bm.LangUtil.getText("LOTTERY", "COIN_BUY", bm.formatBigNumber(data.money))
            remoney_ = bm.LangUtil.getText("LOTTERY", "COIN_BUY", bm.formatBigNumber(data.remoney or 0))
        else
            buymoney_ = bm.LangUtil.getText("LOTTERY", "CASH_BUY", data.money)
            remoney_ = bm.LangUtil.getText("LOTTERY", "CASH_BUY", bm.formatNumberWithSplit(data.remoney or 0))
        end
        self.buy_:setString(buymoney_)
        self.win_:setSystemFontSize(18)

        if data.results and tonumber(data.results) > 0 then
            if tonumber(data.isreceive) == 0 and data.remoney and tonumber(data.remoney) > 0 then
                if tonumber(data.results) > 5 then
                    self.win_:setString(remoney_)
                else
                    self.win_:setSystemFontSize(16)
                    self.win_:setString(bm.LangUtil.getText("LOTTERY", "RESULT_WIN_LEVEL", data.results) .. "\n" .. remoney_)
                end
                self.rewards_:show()
            else
                self.win_:setString(bm.LangUtil.getText("LOTTERY", "RESULT_WIN_GOT"))
                self.rewards_:hide()
            end
        elseif tonumber(data.results) == -1 then
            self.win_:setString(bm.LangUtil.getText("LOTTERY", "RESULT_NOT_OPEN"))
            self.rewards_:hide()
        else
            self.win_:setString(bm.LangUtil.getText("LOTTERY", "RESULT_WIN_NONE"))
            self.rewards_:hide()
        end
    end
end

function LotteryRecordListItem:getReward()
    bm.HttpService.POST({mod="Lottery", act="receiveTicket", date=self.data_.date, type=self.data_.type, number=self.data_.number},
        function(data)
            local callData = json.decode(data)
            if callData and callData.ret and callData.ret > 0 then
                self.data_.isreceive = 1
                self.win_:setSystemFontSize(18)
                self.win_:setString(bm.LangUtil.getText("LOTTERY", "RESULT_WIN_GOT"))
                self.rewards_:hide()
                local remoney_ = ""
                if tonumber(self.data_.type) == 1 then
                    remoney_ = bm.LangUtil.getText("LOTTERY", "COIN_BUY", bm.formatBigNumber(self.data_.remoney or 0))
                else
                    remoney_ = bm.LangUtil.getText("LOTTERY", "CASH_BUY", self.data_.remoney or 0)
                end
                if self.data_.remoney and tonumber(self.data_.remoney) > 0 then 
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("LOTTERY", "REWARD_TIPS", remoney_))
                end
            end
        end, function()
    end)
end

function LotteryRecordListItem:onTraceClick_()
    nk.PopupManager:removeAllPopup()
end

function LotteryRecordListItem:onCleanup()
end

return LotteryRecordListItem