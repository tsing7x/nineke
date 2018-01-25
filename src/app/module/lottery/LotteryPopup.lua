--
-- Author: KevinLiang@boyaa.com
-- Date: 2015-12-09 11:57:54

local LotteryPopup = class("LotteryPopup", function()
    return display.newNode()
end)
local LotteryRecordListItem = import(".LotteryRecordListItem")

local LIST_WIDTH = 560
local LIST_HEIGHT = 300
local TAB_COLOR = cc.c3b(0x9d, 0xe6, 0x43)
local TAB_COLOR_SELECT = cc.c3b(0xfe, 0xfe, 0xfe)
local BUTTON_BUY_COLOR = cc.c3b(0x20, 0x5f, 0x5f)
local TEXT_COLOR = cc.c3b(0xEE, 0xEE, 84)


function LotteryPopup:ctor()
    self:setNodeEventEnabled(true)
    self:loadConfigData()
    self:setupView()
end

function LotteryPopup:setupView()

	local node, width, height = cc.uiloader:load('lottery_1.ExportJson')
    if node then
    	node:setAnchorPoint(cc.p(0.5, 0.5))
        node:addTo(self)
    end

    bm.TouchHelper.new(cc.uiloader:seekNodeByTag(self, 8)):enableTouch()

	--关闭按钮
	local closeButton = cc.uiloader:seekNodeByTag(self, 104)
	closeButton:onButtonClicked(function(event)
		self:onCloseBtnListener_()
	end)

	-- 时间
	local timeText = cc.uiloader:seekNodeByTag(self, 21)
	timeText:setString(bm.LangUtil.getText("LOTTERY", "TIMETIPS"))

    -- 时间数组
    self.timeArray = {}
    self.timeArray[1] = cc.uiloader:seekNodeByTag(self, 24)
    self.timeArray[2] = cc.uiloader:seekNodeByTag(self, 28)
    self.timeArray[3] = cc.uiloader:seekNodeByTag(self, 30)
    self.timeArray[4] = cc.uiloader:seekNodeByTag(self, 32)
    self.timeArray[5] = cc.uiloader:seekNodeByTag(self, 34)
    self.timeArray[6] = cc.uiloader:seekNodeByTag(self, 36)
    self.timeArray[7] = cc.uiloader:seekNodeByTag(self, 38)
    self.timeArray[8] = cc.uiloader:seekNodeByTag(self, 40)

	-- 查看结果
	self.getResultButton = cc.uiloader:seekNodeByTag(self, 43)
    self.getResultButton:setButtonLabelOffset(-12, 0)
    self.getResultButton:setButtonLabel(ui.newTTFLabel({text = bm.LangUtil.getText("LOTTERY", "RESULT_CHECK"), color = cc.c3b(0x0a, 0x0a, 0x0a), size = 16, align = ui.TEXT_ALIGN_CENTER}))
    self.getResultBg = cc.uiloader:seekNodeByTag(self, 76)
    self.lastResultText = cc.uiloader:seekNodeByTag(self, 225)
    self.lastResultText:setSystemFontSize(22)
	self.getResultButton:onButtonClicked(function(event)
        if self.getResultBg:isVisible() then
            self.getResultBg:hide()
        else
    		self.getResultBg:show()
            self:getLastResult()
        end
	end)
    bm.TouchHelper.new(cc.uiloader:seekNodeByTag(self, 8), function(target,evtName)
        if evtName==bm.TouchHelper.CLICK then
            self.getResultBg:hide()
        end
    end)


    -- tab
    -- 大厅
    self.mainTab = cc.uiloader:seekNodeByTag(self, 48)
    self.mainTabSelected = cc.uiloader:seekNodeByTag(self, 53)
    bm.TouchHelper.new(self.mainTab, function(target,evtName)
        if evtName==bm.TouchHelper.CLICK then
            self:updateTab(1)
        end
    end)
    self.mainTabText = cc.uiloader:seekNodeByTag(self, 161)
    self.mainTabText:setString(bm.LangUtil.getText("LOTTERY", "TAB_BUY"))

    -- 规则
    self.ruleTab = cc.uiloader:seekNodeByTag(self, 50)
    self.ruleTabSelected = cc.uiloader:seekNodeByTag(self, 54)
    bm.TouchHelper.new(self.ruleTab, function(target,evtName)
        if evtName==bm.TouchHelper.CLICK then
            self:updateTab(2)
        end
    end)
    self.ruleTabText = cc.uiloader:seekNodeByTag(self, 166)
    self.ruleTabText:setString(bm.LangUtil.getText("LOTTERY", "TAB_RULE"))

    -- 记录
    self.recordTab = cc.uiloader:seekNodeByTag(self, 52)
    self.recordTabSelected = cc.uiloader:seekNodeByTag(self, 55)
    bm.TouchHelper.new(self.recordTab, function(target,evtName)
        if evtName==bm.TouchHelper.CLICK then
            self:updateTab(3)
        end
    end)
    self.recordTabText = cc.uiloader:seekNodeByTag(self, 167)
    self.recordTabText:setString(bm.LangUtil.getText("LOTTERY", "TAB_RECORD"))


    -- 购票界面
	self.mainView = cc.uiloader:seekNodeByTag(self, 56)
    --
    local numbertips = cc.uiloader:seekNodeByTag(self, 57)
    numbertips:setString(bm.LangUtil.getText("LOTTERY", "BUY_TIPS1"))
    self.numbers = cc.uiloader:seekNodeByTag(self, 60)
    self.numbers:setSystemFontSize(72)
    self.numbertips2 = cc.uiloader:seekNodeByTag(self, 61)
    self.numbertips2:hide()

    self.nextNumber = cc.uiloader:seekNodeByTag(self, 59)
    bm.TouchHelper.new(self.nextNumber, function(target,evtName)
        if evtName==bm.TouchHelper.CLICK then
            self:getAnotherNumber()
        end
    end)

    -- 现金币购买
    self.cashBuyButton = cc.uiloader:seekNodeByTag(self, 62)
    self.cashBuyButton:setButtonLabelOffset(20, 0)
    self.cashBuyButton:pos(self.cashBuyButton:getPositionX(), self.cashBuyButton:getPositionY() + 8)
    self.cashBuyButton:onButtonClicked(function(event)
        local thisTime = bm.getTime()
        if not buyBtnLastClickTime or math.abs(thisTime - buyBtnLastClickTime) > 2 then
            buyBtnLastClickTime = thisTime
            nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
            self:buy(2)
        end
        
    end)

    -- 游戏币购买
    self.coinBuyButton = cc.uiloader:seekNodeByTag(self, 66)
    self.coinBuyButton:setButtonLabelOffset(10, 0)
    self.coinBuyButton:pos(self.coinBuyButton:getPositionX(), self.coinBuyButton:getPositionY() + 8)
    self.coinBuyButton:onButtonClicked(function(event)
        local thisTime = bm.getTime()
        if not buyBtnLastClickTime2 or math.abs(thisTime - buyBtnLastClickTime2) > 2 then
            buyBtnLastClickTime2 = thisTime
            nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
            self:buy(1)
        end
    end)

    self.cashBuyText = cc.uiloader:seekNodeByTag(self, 200)
    self.cashBuyText:setString(bm.LangUtil.getText("LOTTERY", "CASH_BUY_TIPS"))
    self.cashBuyText:pos(self.cashBuyText:getPositionX(), self.cashBuyText:getPositionY() + 10)
    self.cashBuyNumber = ui.newTTFLabel({text = "" , color = TEXT_COLOR, size = 18, align = ui.TEXT_ALIGN_CENTER})
        :pos(self.cashBuyText:getPositionX(), self.cashBuyText:getPositionY() - 18)
        :addTo(self.cashBuyText:getParent())

    self.coinBuyText = cc.uiloader:seekNodeByTag(self, 201)
    self.coinBuyText:setString(bm.LangUtil.getText("LOTTERY", "COIN_BUY_TIPS"))
    self.coinBuyText:pos(self.coinBuyText:getPositionX(), self.coinBuyText:getPositionY() + 10)
    self.coinBuyNumber = ui.newTTFLabel({text = "" , color = TEXT_COLOR, size = 18, align = ui.TEXT_ALIGN_CENTER})
        :pos(self.coinBuyText:getPositionX(), self.coinBuyText:getPositionY() - 18)
        :addTo(self.coinBuyText:getParent())

    self.coinTotalNumberText = cc.uiloader:seekNodeByTag(self, 70)
    self.coinTotalText = cc.uiloader:seekNodeByTag(self, 72)
    self.cashTotalNumberText = cc.uiloader:seekNodeByTag(self, 73)
    self.cashTotalText = cc.uiloader:seekNodeByTag(self, 74)

    -- 规则界面
    self.ruleView = cc.uiloader:seekNodeByTag(self, 172)
    self.ruleContent = cc.uiloader:seekNodeByTag(self, 202)
    self.ruleContent:setSystemFontSize(15)

    -- 记录界面
    self.recordView = cc.uiloader:seekNodeByTag(self, 173)
    cc.uiloader:seekNodeByTag(self, 216):setString(bm.LangUtil.getText("LOTTERY", "RECORD_TITLE1"))
    cc.uiloader:seekNodeByTag(self, 218):setString(bm.LangUtil.getText("LOTTERY", "RECORD_TITLE2"))
    cc.uiloader:seekNodeByTag(self, 219):setString(bm.LangUtil.getText("LOTTERY", "RECORD_TITLE3"))
    cc.uiloader:seekNodeByTag(self, 220):setString(bm.LangUtil.getText("LOTTERY", "RECORD_TITLE4"))


	self.list_ = bm.ui.ListView.new(
	        {
	            viewRect = cc.rect(-LIST_WIDTH * 0.5, -LIST_HEIGHT * 0.5, LIST_WIDTH, LIST_HEIGHT)
	        }, 
	        LotteryRecordListItem
	    )
        :pos(590, 228)
    	:addTo(self.recordView)

    self:updateTab(1)
end

function LotteryPopup:updateTab(index_)
    self.tabIndex_ = index_
    if index_ == 1 then
        self.mainTabSelected:show()
        self.mainTabText:setTextColor(TAB_COLOR_SELECT)
        self.mainView:show()

        self.ruleTabSelected:hide()
        self.ruleTabText:setTextColor(TAB_COLOR)
        self.ruleView:hide()

        self.recordTabSelected:hide()
        self.recordTabText:setTextColor(TAB_COLOR)
        self.recordView:hide()
    elseif index_ == 2 then
        self.mainTabSelected:hide()
        self.mainTabText:setTextColor(TAB_COLOR)
        self.mainView:hide()

        self.ruleTabSelected:show()
        self.ruleTabText:setTextColor(TAB_COLOR_SELECT)
        self.ruleView:show()

        self.recordTabSelected:hide()
        self.recordTabText:setTextColor(TAB_COLOR)
        self.recordView:hide()
        self:getRule()
    else
        self.mainTabSelected:hide()
        self.mainTabText:setTextColor(TAB_COLOR)
        self.mainView:hide()

        self.ruleTabSelected:hide()
        self.ruleTabText:setTextColor(TAB_COLOR)
        self.ruleView:hide()

        self.recordTabSelected:show()
        self.recordTabText:setTextColor(TAB_COLOR_SELECT)
        self.recordView:show()
        self:getRecord()
    end

    if self.getResultBg:isVisible() then
        self.getResultBg:hide()
    end
end

function LotteryPopup:updateTime(time_)
    for i = 1, 8 do
        self.timeArray[i]:setString(string.sub(time_, i, i))
    end
end

function LotteryPopup:updateNumber(number)
    local ss = number
    self.currentNumber = ss
    local tt = "  "
    for i = 1, 6 do
        tt = tt .. string.sub(ss, i, i) .. "  "
    end
    self.numbers:setString(tt)
end

function LotteryPopup:modifyTHDate(date_)
    local year = string.sub(date_, 1, 4)
    local other = string.sub(date_, 5)
    local yearTh = tonumber(year) + 543
    local result = other .. yearTh
    return result
end

function LotteryPopup:buy(type_)
    if self.currentNumber then
        if type_ == 1 and nk.userData.money < self.Data_.buynum1 then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("LOTTERY", "COINS_OUT_TIPS", bm.formatBigNumber(self.Data_.buynum1)))
            return
        elseif type_ == 2 and nk.userData.score < self.Data_.buynum2 then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("LOTTERY", "CASH_OUT_TIPS", self.Data_.buynum2))
            return
        end
        local tips = ""
        if type_ == 1 then
            tips = bm.LangUtil.getText("LOTTERY", "BUY_CONFIRM_TIPS", bm.LangUtil.getText("LOTTERY", "COIN_BUY", bm.formatBigNumber(self.Data_.buynum1)))
        else
            tips = bm.LangUtil.getText("LOTTERY", "BUY_CONFIRM_TIPS", bm.LangUtil.getText("LOTTERY", "CASH_BUY", self.Data_.buynum2))
        end
        self.buyConfirmDialog = nk.ui.Dialog.new({
                            messageText = tips, 
                            secondBtnText = "ยืนยัน",
                            hasCloseButton = false,
                            callback = function (type)
                                    if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                                        self:buyTicket(type_, self.currentNumber)
                                    end
                               end
                            }):show()
    end
end

function LotteryPopup:buyTicket(type_, ticket_)
    local money_ = self.Data_.buynum2
    if type_ == 1 then
        money_ = self.Data_.buynum1
    else
        money_ = self.Data_.buynum2
    end
    bm.HttpService.POST({mod="Lottery", act="buyTicket", number=ticket_, type=type_, money=money_},
        function(data)
            local callData = json.decode(data)
            if callData and callData.ret then
                if callData.ret > 0 then
                    if type_ == 1 then
                        self.coinBuyCount = self.coinBuyCount + 1
                    elseif type_ == 2 then
                        self.cashBuyCount = self.cashBuyCount + 1
                    end
                    self.cashBuyNumber:setString(bm.LangUtil.getText("LOTTERY", "TICKET_BUY_NUMBERS", self.cashBuyCount))
                    self.coinBuyNumber:setString(bm.LangUtil.getText("LOTTERY", "TICKET_BUY_NUMBERS", self.coinBuyCount))
                    
                    self.buyTicketed = true
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("LOTTERY", "BUY_SUCC_TIPS"))
                elseif callData.ret == -4 or callData.ret == -14 then
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("LOTTERY", "NUMBER_SOLD"))
                elseif callData.ret == -7 then
                    if type_ == 1 then
                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("LOTTERY", "NUMBER_TYPE1_SOLD_OUT"))
                        self.coinBuyButton:setButtonEnabled(false)
                        self.currentBuyType = 2
                    else
                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("LOTTERY", "NUMBER_TYPE2_SOLD_OUT"))
                        self.cashBuyButton:setButtonEnabled(false)
                        self.currentBuyType = 1
                    end
                elseif callData.ret == -8 then   --截止购买
                    self.coinBuyButton:setButtonEnabled(false)
                    self.cashBuyButton:setButtonEnabled(false)
                    self.numbertips2:setString(bm.LangUtil.getText("LOTTERY", "BUY_STOP_TIPS"))
                    self.numbertips2:show()
                end
            end
            if not self.coinBuyButton:isButtonEnabled() and not self.cashBuyButton:isButtonEnabled() then
                self.nextNumber:hide()
            end
        end, function()
        end)
end

function LotteryPopup:updateUIFromJson()
    if self.Data_ then
        self:updateTime(self:modifyTHDate(self.Data_.date))

        self.coinTotalNumberText:setString(bm.LangUtil.getText("LOTTERY", "PRE_COIN_TOTAL", bm.formatBigNumber(self.Data_.maxnum1)))
        self.coinTotalText:setString(bm.LangUtil.getText("LOTTERY", "COIN_TOTAL", bm.formatBigNumber(self.Data_.allmoney1)))
        self.cashTotalNumberText:setString(bm.LangUtil.getText("LOTTERY", "PRE_CASH_TOTAL", bm.formatBigNumber(self.Data_.maxnum2)))
        self.cashTotalText:setString(bm.LangUtil.getText("LOTTERY", "CASH_TOTAL", bm.formatBigNumber(self.Data_.allmoney2)))

        self.cashBuyButton:setButtonLabel(ui.newTTFLabel({text = bm.LangUtil.getText("LOTTERY", "CASH_BUY", self.Data_.buynum2), color = BUTTON_BUY_COLOR, size = 28, align = ui.TEXT_ALIGN_CENTER}))
        self.coinBuyButton:setButtonLabel(ui.newTTFLabel({text = bm.LangUtil.getText("LOTTERY", "COIN_BUY", bm.formatBigNumber(self.Data_.buynum1)), color = BUTTON_BUY_COLOR, size = 27, align = ui.TEXT_ALIGN_CENTER}))

        if self.Data_.randticket and self.Data_.randticket ~= "" then 
            self:updateNumber(self.Data_.randticket)
            self.currentBuyType = self.Data_.randtickettype
        else
            if self.currentBuyType == 1 then 
                self.coinBuyButton:setButtonEnabled(false)
                self.currentBuyType = 2
            else
                self.cashBuyButton:setButtonEnabled(false)
                self.currentBuyType = 1
            end
        end

        if self.Data_.nownum1 >= self.Data_.maxnum1 then
            self.coinBuyButton:setButtonEnabled(false)
            self.currentBuyType = 2
        end

        if self.Data_.nownum2 >= self.Data_.maxnum2 then
            self.cashBuyButton:setButtonEnabled(false)
            self.currentBuyType = 1
        end

        if self.Data_.nownum1 >= self.Data_.maxnum1 and self.Data_.nownum2 >= self.Data_.maxnum2 then
            self.coinBuyButton:setButtonEnabled(false)
            self.cashBuyButton:setButtonEnabled(false)
            self.numbertips2:setString(bm.LangUtil.getText("LOTTERY", "NUMBER_SOLD_OUT"))
            self.numbertips2:show()
        elseif self.Data_.isbuy and self.Data_.isbuy < 0 then --截止购买
            self.coinBuyButton:setButtonEnabled(false)
            self.cashBuyButton:setButtonEnabled(false)
            self.numbertips2:setString(bm.LangUtil.getText("LOTTERY", "BUY_STOP_TIPS"))
            self.numbertips2:show()
        else
            self.numbertips2:hide()
        end

        self.cashBuyCount = 0
        self.coinBuyCount = 0
        if self.Data_.tickets then
            for _,v in pairs(self.Data_.tickets) do
                if self.Data_.date == v.date then 
                    if v.type then
                        if tonumber(v.type) == 1 then
                            self.coinBuyCount = self.coinBuyCount + 1
                        elseif tonumber(v.type) == 2 then
                            self.cashBuyCount = self.cashBuyCount + 1
                        end
                    end
                end
            end
        end
        self.cashBuyNumber:setString(bm.LangUtil.getText("LOTTERY", "TICKET_BUY_NUMBERS", self.cashBuyCount))
        self.coinBuyNumber:setString(bm.LangUtil.getText("LOTTERY", "TICKET_BUY_NUMBERS", self.coinBuyCount))

        if not self.coinBuyButton:isButtonEnabled() and not self.cashBuyButton:isButtonEnabled() then
            self.nextNumber:hide()
        end
    end
end

function LotteryPopup:loadConfigData()
    if nk.userData.score > 5 then
        self.currentBuyType = 2
    else
        self.currentBuyType = 1
    end
    bm.HttpService.POST({mod="Lottery", act="showTicket", type=self.currentBuyType},
        function(data)
            local callData = json.decode(data)
            if callData and callData.ret and callData.ret > 0 then
                    self.Data_ = callData
                    if not self.Data_.buynum1 then
                        self.Data_.buynum1 = 50000
                    end
                    if not self.Data_.buynum2 then
                        self.Data_.buynum2 = 5
                    end
                    if self.isShowed then
                        self:updateUIFromJson()
                    end
            end
        end, function()
        end)
end

function LotteryPopup:getAnotherNumber()
    bm.HttpService.POST({mod="Lottery", act="randTicket", type=self.currentBuyType},
        function(data)
            local callData = json.decode(data)
            if callData and callData.ret and callData.ret > 0 then
                    if callData.ticket and callData.ticket ~= "" then
                        self:updateNumber(callData.ticket)
                        self.numbertips2:hide()
                    else
                        if self.currentBuyType == 1 then 
                            nk.TopTipManager:showTopTip(bm.LangUtil.getText("LOTTERY", "NUMBER_TYPE1_SOLD_OUT"))
                            self.coinBuyButton:setButtonEnabled(false)
                            self.currentBuyType = 2
                        else
                            nk.TopTipManager:showTopTip(bm.LangUtil.getText("LOTTERY", "NUMBER_TYPE2_SOLD_OUT"))
                            self.cashBuyButton:setButtonEnabled(false)
                            self.currentBuyType = 1
                        end
                    end

                    if not self.coinBuyButton:isButtonEnabled() and not self.cashBuyButton:isButtonEnabled() then
                        self.nextNumber:hide()
                    end
            end
        end, function()
        end)
end


function LotteryPopup:getRecord()
    if self.recordData_ and not self.buyTicketed then
        self.list_:setData(self.recordData_.tickets)
    else
        bm.HttpService.POST({mod="Lottery", act="getUserTicket"},
        function(data)
            local callData = json.decode(data)
            if callData and callData.ret and callData.ret > 0 then
                if callData.tickets then
                    table.sort(callData.tickets, function(o1, o2)
                        return o1.time > o2.time
                    end)
                    self.recordData_ = callData
                    self.list_:setData(callData.tickets)
                end
                self.buyTicketed = false
            end
        end, function()
        end)
    end
end

function LotteryPopup:getRule()
    if self.ruleData_ then
        self:updateRule()
    else
        bm.HttpService.POST({mod="Lottery", act="getTicketRule"},
        function(data)
            local callData = json.decode(data)
            if callData and callData.ret and callData.ret > 0 then
                self.ruleData_ = callData
                if callData.list then
                    self:updateRule()
                end
            end
        end, function()
        end)
    end
end

function LotteryPopup:updateRule()
    if self.ruleData_ then
        local reward = {}
        for k,v in pairs(self.ruleData_.list) do
            reward[tonumber(k)] = bm.LangUtil.getText("LOTTERY", "COIN_BUY", bm.formatBigNumber(v[1])) .. "/" ..
                        bm.LangUtil.getText("LOTTERY", "CASH_BUY", bm.formatNumberWithSplit(v[2]))
        end
        self.ruleContent:setString(bm.LangUtil.getText("LOTTERY", "RULE", reward[1], reward[2], reward[3], reward[4], reward[5], reward[6], reward[7], reward[8], reward[9]))
    end
end

function LotteryPopup:getLastResult()
    bm.HttpService.POST({mod="Lottery", act="getLastTermTicket"},
        function(data)
            local callData = json.decode(data)
            if callData and callData.ret and callData.ret > 0 then
                self.lastResultData_ = callData
                local str = bm.LangUtil.getText("LOTTERY", "RESULT_WIN_LEVEL", 1)
                local level_ = 0
                local number_ = ""
                local win_ = ""
                local reward_ = ""
                local date_ = ""
                for _,v in pairs(self.lastResultData_.list) do 
                    number_ = v[4]
                    date_ = self:modifyTHDate(v[2])
                    level_ = v[1]
                    if tonumber(v[3]) == 1 then
                        win_ = bm.LangUtil.getText("LOTTERY", "COIN_BUY", bm.formatBigNumber(v[5] or 0))
                    else
                        win_ = bm.LangUtil.getText("LOTTERY", "CASH_BUY", bm.formatNumberWithSplit(v[5] or 0))
                    end
                    reward_ = reward_ .. "\n" .. win_
                end
                if date_ and date_ ~= "" then
                    self.lastResultText:setString(date_ .. "\n" .. bm.LangUtil.getText("LOTTERY", "RESULT_WIN_LEVEL", level_) .. "\n" .. number_ .. "\n" .. reward_)
                else
                    self.lastResultText:setString(bm.LangUtil.getText("LOTTERY", "RESULT_NOT_OPEN"))
                end
            end
        end,
        function()
        end)
end

function LotteryPopup:onCloseBtnListener_()
    self:hide()
end

function LotteryPopup:onShowed()
	if self.Data_ then
		self:updateUIFromJson()
    end
    self.isShowed = true

    -- 延迟设置，防止list出现触摸边界的问题
    self.list_:setScrollContentTouchRect()
    self.list_:update()
end

function LotteryPopup:show()
    nk.PopupManager:addPopup(self)
    return self
end

function LotteryPopup:hide()
    nk.PopupManager:removePopup(self)
    return self
end

function LotteryPopup:onCleanup()

end

return LotteryPopup