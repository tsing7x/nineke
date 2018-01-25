--
-- Author: KevinYu
-- Date: 2017-02-20 15:28:53
-- 比赛竞猜视图
local FootballQuizMatchView = class("FootballQuizMatchView",function()
    return display.newNode()
end)

local FootballQuizMatchListItem = import(".FootballQuizMatchListItem")
local FootballQuizBetListItem 	= import(".FootballQuizBetListItem")

local WIDTH, HEIGHT

local betTitleColor = {
	cc.c3b(0xd5, 0xb0, 0x4e),
	cc.c3b(0xff, 0xff, 0xff),
	cc.c3b(0x1d, 0xac, 0x8b),
}

local moneyColor = cc.c3b(0xf8, 0xd0, 0x3a)

function FootballQuizMatchView:ctor(width, height, controller)
	self:size(width, height):align(display.CENTER)
	WIDTH, HEIGHT = width, height
	
	self.controller_ = controller

	self:setNodeEventEnabled(true)

	self:initTotalBet_()

	self:addMatchInfoNode_()

	self:addBetInfoNode_()

	self:addBottomTipsNode_()

	self.aloneBetData_ = {} --单独下注数据
	self.groupBetData_ = {} --组合下注数据

	self.curSelectedMode_ = 1
	nk.userData.footballQuizBetMode = 1 --下注模式，1：单独下注 2：组合下注
	
	self:addListener()

	self.controller_:getMatchConfig()
end

function FootballQuizMatchView:addMatchInfoNode_()
	local bg_w, bg_h = WIDTH - 45, HEIGHT * 0.455
	local bg = display.newScale9Sprite("#football_content_frame.png", 0, 0, cc.size(bg_w, bg_h))
		:align(display.TOP_CENTER, WIDTH/2, HEIGHT - 15)
		:addTo(self)

	local title_w, title_h = bg_w, 50
	local posList = {0.17, 0.36, 0.8, 1}
	local titleFrame = display.newScale9Sprite("#football_title_frame.png", 0, 0, cc.size(title_w, title_h))
		:align(display.TOP_CENTER, bg_w/2, bg_h)
		:addTo(bg)

	for i = 1, 3 do
		display.newScale9Sprite("#football_title_line.png", 0, 0, cc.size(2, title_h))
			:pos(posList[i] * title_w, 25)
			:addTo(titleFrame)
	end

	local matchTitles = bm.LangUtil.getText("FOOTBALL", "MATCH_TITLES")

	ui.newTTFLabel({text = matchTitles[1], size = 18})
        :pos(posList[1]/2 * title_w, title_h/2)
        :addTo(titleFrame)

	for i = 2, 3 do
		local x = (posList[i] + posList[i - 1])/2 * title_w
		ui.newTTFLabel({text = matchTitles[i], size = 18})
	        :pos(x, title_h/2)
	        :addTo(titleFrame)
	end

	--投注比例
	local x = (posList[4] + posList[3])/2 * title_w
	ui.newTTFLabel({text = matchTitles[4], size = 18})
        :pos(x, title_h * 0.75)
        :addTo(titleFrame)

    local line_w = (posList[4] - posList[3]) * title_w
    display.newScale9Sprite("#football_title_line.png", 0, 0, cc.size(2, line_w))
		:rotation(90)
		:pos(x, title_h/2)
		:addTo(titleFrame)

	local dir = line_w / 3
	x = posList[3] * title_w
	for i = 1, 2 do
		display.newScale9Sprite("#football_title_line.png", 0, 0, cc.size(2, title_h/2))
			:pos(x + i * dir, title_h * 0.25)
			:addTo(titleFrame)
	end

	local betTitle = bm.LangUtil.getText("FOOTBALL", "BET_TITLES")
	for i = 1, 3 do
		ui.newTTFLabel({text = betTitle[i], size = 18, color = betTitleColor[i]})
	        :pos(x + (i - 0.5) * dir, title_h * 0.25)
	        :addTo(titleFrame)
	end

	local list_w, list_h = bg_w, bg_h - title_h
	FootballQuizMatchListItem.WIDTH = list_w
	self.matchList_ = bm.ui.ListView.new(
	        {
	            viewRect = cc.rect(-list_w/2, -list_h/2, list_w, list_h)
	        }, 
	        FootballQuizMatchListItem
	    )
        :pos(list_w/2, list_h/2)
        :addTo(bg)
end

function FootballQuizMatchView:addBetInfoNode_()
	local bg_w, bg_h = WIDTH - 45, HEIGHT * 0.332
	local bg = display.newScale9Sprite("#football_content_frame.png", 0, 0, cc.size(bg_w, bg_h))
		:align(display.BOTTOM_CENTER, WIDTH/2, 70)
		:addTo(self)

	ui.newTTFLabel({text = bm.LangUtil.getText("FOOTBALL", "BET_INFO"), size = 22})
        :align(display.LEFT_BOTTOM, 12, bg_h + 5)
        :addTo(bg)

    local label_x, label_y = 155, bg_h + 5
    local label = ui.newTTFLabel({text = bm.LangUtil.getText("FOOTBALL", "TOTAL_MONEY_TITLE"), size = 20})
        :align(display.LEFT_BOTTOM, label_x, label_y)
        :addTo(bg)

   	local label_w = label:getContentSize().width

   	self.totalMoney_ = ui.newTTFLabel({text = "", color = moneyColor, size = 20})
        :align(display.LEFT_BOTTOM, label_x + label_w, label_y)
        :addTo(bg)
    
	local title_w, title_h = bg_w, 50
	local titleFrame = display.newScale9Sprite("#football_title_frame.png", 0, 0, cc.size(title_w, title_h))
		:align(display.TOP_CENTER, bg_w/2, bg_h)
		:addTo(bg)

	ui.newTTFLabel({text = bm.LangUtil.getText("FOOTBALL", "BET_MODE"), size = 22})
        :align(display.LEFT_CENTER, 12, title_h/2)
        :addTo(titleFrame)

    local betMode = bm.LangUtil.getText("FOOTBALL", "BET_MODES")
	local betModeGroup = cc.ui.UICheckBoxButtonGroup.new()
	local x = 220
	local dir = title_w - x 
	for i = 1, 2 do
		local btn = cc.ui.UICheckBoxButton.new({off="#football_bet_off.png", on="#football_bet_on.png"})
	        :setButtonLabel(ui.newTTFLabel({text = betMode[i], size=22}))
	        :setButtonLabelAlignment(display.LEFT_CENTER)
	        :setButtonLabelOffset(26, -2)
	        :align(display.LEFT_CENTER)

        betModeGroup:addButton(btn)

        local size = btn:getCascadeBoundingBox()
        dir = dir - size.width
	end

    betModeGroup:pos(x, 12):addTo(titleFrame)

    betModeGroup:setButtonsLayoutMargin(0, dir/2, 0, 0)

    -- 处理初始化默认选择
    local btn = betModeGroup:getButtonAtIndex(1)
    if btn then
        btn:setButtonSelected(true)
    end

    betModeGroup:onButtonSelectChanged(buttontHandler(self, self.onBetModeSelectChanged_))

	local list_w, list_h = bg_w, bg_h - title_h
	FootballQuizBetListItem.WIDTH = list_w
	self.betList_ = bm.ui.ListView.new(
	        {
	            viewRect = cc.rect(-list_w/2, -list_h/2, list_w, list_h)
	        }, 
	        FootballQuizBetListItem
	    )
        :pos(list_w/2, list_h/2)
        :addTo(bg)

	self.betList_:setData(data)

	self:addTouchLayer_(bg, list_w, list_h, list_w/2, list_h/2)
end

function FootballQuizMatchView:addTouchLayer_(parent, w, h, x, y)
    local node = display.newNode()
    node:pos(x, y)
    node:addTo(parent, 10)

    local rect = cc.rect(-w/2, -h/2, w, h)

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(function(touch, event)
        local pos = touch:getLocation()
        pos = node:convertToNodeSpace(pos)

        if not cc.rectContainsPoint(rect, pos) then
            bm.EventCenter:dispatchEvent({name="QUIZ_BET_EDITBOX_TOUCH", data = false})
            return true
        end

        return false
    end, cc.Handler.EVENT_TOUCH_BEGAN)

    listener:registerScriptHandler(function(touch, event)
        bm.EventCenter:dispatchEvent({name="QUIZ_BET_EDITBOX_TOUCH", data = true})
    end, cc.Handler.EVENT_TOUCH_ENDED)

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)
end

function FootballQuizMatchView:addBottomTipsNode_()
	local w, h = WIDTH, 65
	local bg = display.newScale9Sprite("#football_bottom_frame.png", 0, 0, cc.size(w, h))
		:align(display.BOTTOM_CENTER, WIDTH/2 + 1, 0)
		:addTo(self)

	local label_x, label_y = 15, h/2 + 15
    local label = ui.newTTFLabel({text = bm.LangUtil.getText("FOOTBALL", "BET_TOTAL_TITLE"), size = 20})
	    :align(display.LEFT_CENTER, label_x, label_y)
	    :addTo(bg)

	local label_w = label:getContentSize().width

	self.totalBet_ = ui.newTTFLabel({text = "", color = moneyColor, size = 20})
	    :align(display.LEFT_CENTER, label_x + label_w, label_y)
	    :addTo(bg)

	label_y = h/2 - 15
	label = ui.newTTFLabel({text = bm.LangUtil.getText("FOOTBALL", "BET_REWARD_TITLE"), size = 20})
        :align(display.LEFT_CENTER, label_x, label_y)
        :addTo(bg)

    label_w = label:getContentSize().width

    self.betReward_ = ui.newTTFLabel({text = "", color = moneyColor, size = 20})
	    :align(display.LEFT_CENTER, label_x + label_w, label_y)
	    :addTo(bg)

    self.betBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_blue_normal.png", pressed = "#common_btn_blue_pressed.png", disabled = "#common_btn_disabled.png"},{scale9 = true})
        :setButtonSize(134, 52)
        :setButtonLabel(ui.newTTFLabel({text = bm.LangUtil.getText("FOOTBALL", "CONFIRM_BET"), size = 20}))
        :onButtonClicked(buttontHandler(self, self.onConfirmBetClicked_))
        :setButtonEnabled(false) 
        :pos(w - 95, h/2)
        :addTo(bg)
end

--切换下注模式
function FootballQuizMatchView:onBetModeSelectChanged_(evt)
    local id = evt.selected
    self.curSelectedMode_ = id

    nk.userData.footballQuizBetMode = id

    self:setBetListData_()
end

--重置下注
function FootballQuizMatchView:resetBetListData_()
	local items = self.matchList_:getListItems()
	for _, item in ipairs(items) do
		item:resetCheckBoxButton()
	end

	self.aloneBetData_ = {}
	self.groupBetData_ = {}

	self:setBetListData_()
end

--设置下注清单，单独或者组合
function FootballQuizMatchView:setBetListData_()
	if self.curSelectedMode_ == 1 then
		self.betList_:setData(self.aloneBetData_)
	else
		self.betList_:setData(self.groupBetData_)
	end

	self:updateBetButtonState_()
end

--初始化下注总额统计
function FootballQuizMatchView:initTotalBet_()
	nk.userData.footballQuizBetChip = 0 --当前下注总游戏币
	nk.userData.footballQuizBetGcoins = 0 --当前下注总黄金币

	nk.userData.footballQuizBetChipReward = 0 --预计最高获得游戏币
	nk.userData.footballQuizBetGcoinsReward = 0 --预计最高获得黄金币
end

--更新下注按钮状态，并且更新下注总额信息
function FootballQuizMatchView:updateBetButtonState_()
	local items = self.betList_:getListItems()
	local enabled = true
	for _, item in ipairs(items) do
		if not item:isBetCurMatch() then
			enabled = false
			break
		end
	end

	self.betBtn_:setButtonEnabled(enabled) 

	self:updateTotalBet_()
end

--更新下注总额和奖励，更新下注按钮的时候调用
function FootballQuizMatchView:updateTotalBet_()
	local totalChip, totalGcoins = 0, 0
	local totalChipReward, totalGcoinseward = 0, 0
	local data = self.aloneBetData_
	if self.curSelectedMode_ == 2 then
		data = self.groupBetData_
	end

	for _, v in ipairs(data) do
		totalChip = totalChip + v.chip
		totalGcoins = totalGcoins + v.gcoins
		totalChipReward = totalChipReward + v.chipReward
		totalGcoinseward = totalGcoinseward + v.gcoinsReward
	end

	nk.userData.footballQuizBetChip = totalChip
	nk.userData.footballQuizBetGcoins = totalGcoins

	nk.userData.footballQuizBetChipReward = totalChipReward 
	nk.userData.footballQuizBetGcoinsReward = totalGcoinseward
end

--更新下注清单
function FootballQuizMatchView:updateBetListData_(evt)
	local data = evt.data
	if data.betType > 0 then --增加比赛下注
		self:addBetListData_(data)
		self:updateGroupBetData_()
	else --取消比赛下注
		self:removeBetListData_(data)
		self:updateGroupBetData_()
	end

	self:setBetListData_()
end

--添加比赛下注
function FootballQuizMatchView:addBetListData_(data)
	self:removeBetListData_(data)--之前已选中当前比赛，但是改了下注胜负，所以得先删除掉

	local matchStr = data.time .. "\n" .. data.hometeam .. "VS" .. data.visitors
	local betType = data.betType
	local betTitle = data.betTitle
	if betType == 1 then --主场胜
		matchStr = matchStr .. "\n" .. data.hometeam .. betTitle[betType]
	elseif betType == 2 then --平局
		matchStr = matchStr .. "\n" .. data.hometeam .. "VS" .. data.visitors .. betTitle[betType]
	else --客场胜
		matchStr = matchStr .. "\n" .. data.visitors .. betTitle[betType]
	end

	local bet = {}
	bet.match = {matchStr}
	bet.betOdds = {data.betOdds}
	bet.index = data.index
	bet.matchid = data.matchid
	bet.betType = betType
	bet.chip = 0
	bet.gcoins = 0
	bet.chipReward = 0
	bet.gcoinsReward = 0

	table.insert(self.aloneBetData_, bet)
	table.sort(self.aloneBetData_, function(a, b)
		return a.index < b.index
	end)
end

--取消比赛下注
function FootballQuizMatchView:removeBetListData_(data)
	local index = data.index
	for i, v in ipairs(self.aloneBetData_) do
		if v.index == index then
			table.remove(self.aloneBetData_, i)
			break
		end
	end
end

--更新下注组合数据
function FootballQuizMatchView:updateGroupBetData_()
	local matchList = {}
	local matchidList = {}
	local betTypeList = {}
	local betOddsList = {}

	for _,v in ipairs(self.aloneBetData_) do
		table.insert(matchList, v.match[1])
		table.insert(matchidList, v.matchid)
		table.insert(betTypeList, v.betType)
		table.insert(betOddsList, v.betOdds[1])
	end

	self.groupBetData_ = {}

	if #matchList > 0 then
		local bet = {}
		bet.match = matchList
		bet.matchid = matchidList
		bet.betType = betTypeList
		bet.betOdds = betOddsList
		bet.chip = 0
		bet.gcoins = 0
		bet.chipReward = 0
		bet.gcoinsReward = 0

		self.groupBetData_[1] = bet
	end
end

--确认下注
function FootballQuizMatchView:onConfirmBetClicked_()
	if nk.userData.footballQuizBetMode == 1 then
		self.controller_:aloneBet(self.aloneBetData_)
	else
		if #self.groupBetData_ > 0 then
			self.controller_:groupBet(self.groupBetData_[1])
		end
	end

	self:resetBetListData_()
end

function FootballQuizMatchView:setMatchListData(data)
	self.matchList_:setData(data)
end

function FootballQuizMatchView:onRefreshMoney_()
	self.totalMoney_:setString(bm.LangUtil.getText(
		"FOOTBALL", "MONEY_INFO",
		bm.formatNumberWithSplit(nk.userData.money),
		bm.formatNumberWithSplit(nk.userData.gcoins)
		))
end

function FootballQuizMatchView:onRefreshBetMoney_()
	self.totalBet_:setString(bm.LangUtil.getText(
		"FOOTBALL", "MONEY_INFO",
		bm.formatNumberWithSplit(nk.userData.footballQuizBetChip),
		bm.formatNumberWithSplit(nk.userData.footballQuizBetGcoins)
		))
end

function FootballQuizMatchView:onRefreshBetRewardMoney_()
	self.betReward_:setString(bm.LangUtil.getText("FOOTBALL", "MONEY_INFO",
		bm.formatNumberWithSplit(nk.userData.footballQuizBetChipReward),
		bm.formatNumberWithSplit(nk.userData.footballQuizBetGcoinsReward)
		))
end

function FootballQuizMatchView:addListener()
	self.updateBetListDataId_ = bm.EventCenter:addEventListener("UPDATE_BET_LIST_DATA", handler(self, self.updateBetListData_))
	self.setBetButtonEnabledId_ = bm.EventCenter:addEventListener("UPDATE_BET_BUTTON_STATE", handler(self, self.updateBetButtonState_))

	self.moneyObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "money", handler(self, self.onRefreshMoney_))
    self.gcoinsObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "gcoins", handler(self, self.onRefreshMoney_))

    self.betChipObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "footballQuizBetChip", handler(self, self.onRefreshBetMoney_))
    self.betGcoinsObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "footballQuizBetGcoins", handler(self, self.onRefreshBetMoney_))

    self.betChipRewardObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "footballQuizBetChipReward", handler(self, self.onRefreshBetRewardMoney_))
    self.betGcoinsRewardObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "footballQuizBetGcoinsReward", handler(self, self.onRefreshBetRewardMoney_))
end

function FootballQuizMatchView:removeListener()
	
	bm.EventCenter:removeEventListener(self.updateBetListDataId_)
	bm.EventCenter:removeEventListener(self.setBetButtonEnabledId_)
	
	bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "gcoins", self.gcoinsObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "money", self.moneyObserverHandle_)

    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "footballQuizBetChip", self.betChipObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "footballQuizBetGcoins", self.betGcoinsObserverHandle_)

    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "footballQuizBetChipReward", self.betChipRewardObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "footballQuizBetGcoinsReward", self.betGcoinsRewardObserverHandle_)
end

function FootballQuizMatchView:onCleanup()
	self:removeListener()
end

return FootballQuizMatchView