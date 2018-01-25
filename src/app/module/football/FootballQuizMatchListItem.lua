--
-- Author: KevinYu
-- Date: 2017-02-20 15:04:41
-- 比赛列表item

local FootballQuizMatchListItem = class("FootballQuizMatchListItem", bm.ui.ListItem)

FootballQuizMatchListItem.WIDTH = 540

local betTitleColor = {
	cc.c3b(0xd5, 0xb0, 0x4e),
	cc.c3b(0xff, 0xff, 0xff),
	cc.c3b(0x1d, 0xac, 0x8b),
}

local item_w
local item_h = 56
local line_x = {0.16, 0.36, 0.8, 1}

function FootballQuizMatchListItem:ctor()
	item_w = FootballQuizMatchListItem.WIDTH
	FootballQuizMatchListItem.super.ctor(self, item_w, item_h)

	self.frame_ = display.newScale9Sprite("#football_item_frame.png", item_w/2, item_h/2, cc.size(item_w, item_h))
		:addTo(self):hide()

	local posx = {}
	posx[1] = line_x[1]/2 * item_w
	posx[2] = (line_x[2] + line_x[1])/2 * item_w

    self.time_ = ui.newTTFLabel({text = "", size = 16})
        :pos(posx[1], item_h/2)
        :addTo(self)

    self.match_ = ui.newTTFLabel({text = "", size = 14, align = ui.TEXT_ALIGN_CENTER})
        :pos(posx[2], item_h/2)
        :addTo(self)

   	self:addOddsInfo_()

   	self:addBettingRatioInfo_()

   	self.curSelectedId_ = 0
end

--赔率
function FootballQuizMatchListItem:addOddsInfo_()
	local dir = (line_x[3] - line_x[2]) * item_w / 3
	local sx = line_x[2] * item_w
	local btn_y = item_h * 0.75
	local odds_y = item_h * 0.25
	local btn_w, btn_h = dir, item_h/2
	self.oddsList_ = {}
	self.checkBtnList_ = {}
	self.betTitleList_ = {}

	display.newScale9Sprite("#football_item_frame.png", 0, 0, cc.size(dir * 3, item_h))
		:align(display.LEFT_CENTER, sx, item_h/2)
		:addTo(self)

	for i = 1, 3 do
		local x = sx + (i - 0.5) * dir
		display.newScale9Sprite("#football_bet_button.png", 0, 0, cc.size(btn_w, btn_h))
			:pos(x, btn_y)
			:addTo(self, 1)

		self.checkBtnList_[i] = cc.ui.UICheckBoxButton.new({off="#transparent.png", on="#football_bet_button_on.png"}, {scale9 = true})
	        :onButtonClicked(buttontHandler(self, self.onBetSelectClicked_))
	        :setButtonSize(btn_w, btn_h)
	        :pos(x, btn_y)
	        :addTo(self, 1, i)

	    self.betTitleList_[i] = ui.newTTFLabel({text = "", size = 14, color = betTitleColor[i]})
	        :pos(x, btn_y)
	        :addTo(self, 1)    

	    self.oddsList_[i] = ui.newTTFLabel({text = "", size = 18, color = betTitleColor[i]})
	        :pos(x, odds_y)
	        :addTo(self, 1)
	end
end

--投注比例
function FootballQuizMatchListItem:addBettingRatioInfo_()
	local dir = (line_x[4] - line_x[3]) * item_w / 3
	local sx = line_x[3] * item_w
	self.bettingRatio_ = {} 
	for i = 1, 3 do
	    self.bettingRatio_[i] = ui.newTTFLabel({text = "", size = 18, color = betTitleColor[i]})
	        :pos(sx + (i - 0.5) * dir, item_h/2)
	        :addTo(self)
	end
end

function FootballQuizMatchListItem:onBetSelectClicked_(evt)
	local target = evt.target
	local tag = target:getTag()

	if self.curSelectedId_ == tag then
		self.curSelectedId_ = 0
	else
		self.curSelectedId_ = tag
		for _, btn in ipairs(self.checkBtnList_) do
			if btn ~= target then
				btn:setButtonSelected(false)
			end
		end
	end

	self.data_.betType = self.curSelectedId_
	self.data_.index = self.index_
	self.data_.betOdds = self.data_.odds[self.curSelectedId_] or 0

	bm.EventCenter:dispatchEvent({name="UPDATE_BET_LIST_DATA", data = self.data_})
end

function FootballQuizMatchListItem:resetCheckBoxButton()
	for _, btn in ipairs(self.checkBtnList_) do	
		btn:setButtonSelected(false)	
	end

	self.curSelectedId_ = 0
end

function FootballQuizMatchListItem:onDataSet(dataChanged, data)
	if self.index_ % 2 == 1 then
		self.frame_:show()
	else
		self.frame_:hide()
	end

	self.time_:setString(data.time)
	self.match_:setString(data.match)

	for i = 1, 3 do
		self.oddsList_[i]:setString(data.odds[i])
		self.bettingRatio_[i]:setString(data.bettingRatio[i])
		self.betTitleList_[i]:setString(data.betTitle[i])
	end
end

return FootballQuizMatchListItem