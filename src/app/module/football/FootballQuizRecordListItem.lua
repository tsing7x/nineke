--
-- Author: KevinYu
-- Date: 2017-02-20 15:00:46
-- 竞猜记录item
local FootballQuizRecordListItem = class("FootballQuizRecordListItem", bm.ui.ListItem)

FootballQuizRecordListItem.WIDTH = 540

local line_x = {0.12, 0.22, 0.44, 0.75, 0.86, 1} --分割线坐标
local keys = {"time", "match", "quiz", "score", "state"}
local info_h = 58 --一条信息的高度，一个item可以包含多条信息
local txtColor = {
	cc.c3b(0xd2, 0xbe, 0xff),
	cc.c3b(0xd2, 0xbe, 0xff),
	cc.c3b(0xd2, 0xbe, 0xff),
	cc.c3b(0xf8, 0xd0, 0x3a),
	cc.c3b(0xff, 0xff, 0xff),
}

local REWARD_STATE

function FootballQuizRecordListItem:ctor()
	FootballQuizRecordListItem.super.ctor(self, FootballQuizRecordListItem.WIDTH, info_h)
end

function FootballQuizRecordListItem:addContentInfo_(data)
	local len = #data
	if len > 0 then
		local w, h = self.width_, info_h * len
		self.height_ = h
		self:setContentSize(cc.size(w, h))
		self.frame_ = display.newScale9Sprite("#football_item_frame.png", w/2, h/2, cc.size(w, h))
			:addTo(self):hide()

		for i = 1, 5 do
			display.newScale9Sprite("#football_item_line.png", 0, 0, cc.size(2, h))
				:pos(line_x[i] * w, h/2)
				:addTo(self)
		end

		if len == 1 then
			ui.newTTFLabel({text = bm.LangUtil.getText("FOOTBALL", "ALONE_TITLE"), color = txtColor[1], size = 14})
		        :pos(line_x[1]/2 * w, h/2)
		        :addTo(self)
		else
			ui.newTTFLabel({text = bm.LangUtil.getText("FOOTBALL", "GROUP_TITLE"), color = txtColor[1], size = 14})
		        :pos(line_x[1]/2 * w, h/2)
		        :addTo(self)

		    local line_w = (line_x[5] - line_x[1]) * w
		    local x = (line_x[5] + line_x[1])/2 * w
		    for i = 1, len - 1 do
		    	display.newScale9Sprite("#football_item_line.png", 0, 0, cc.size(2, line_w))
		    		:rotation(90)
					:pos(x, info_h * i)
					:addTo(self)
		    end
		end
		
		local betMoney = bm.LangUtil.getText("FOOTBALL", "MONEY_INFO",
			bm.formatNumberWithSplit(self.betmoney_),
			bm.formatNumberWithSplit(self.betgcoins_))
		
		local index = 1
		for _, v in ipairs(data) do
			for i = 2, 5 do
				local x = (line_x[i] + line_x[i - 1])/2 * w
				local str = v[keys[i - 1]]
				if i == 4 then
					str = betMoney .. "\n" .. str
				end

				ui.newTTFLabel({text = str, color = txtColor[i], size = 14, align = ui.TEXT_ALIGN_CENTER})
			        :pos(x, info_h/2 + (index - 1) * info_h)
			        :addTo(self)
			end

			index = index + 1
		end

		local x, y = (line_x[6] + line_x[5])/2 * w, h/2
		if self.state_ == 2 then
			local name = REWARD_STATE[3] .. "\n" .. bm.LangUtil.getText("FOOTBALL", "BET_ODDS", self.betrate_)
			cc.ui.UIPushButton.new("#football_reward_btn.png")
		        :setButtonLabel(ui.newTTFLabel({text = name, size = 14, align = ui.TEXT_ALIGN_CENTER}))
		        :onButtonClicked(buttontHandler(self, self.onGetRewardClick_))
		        :pos(x, y)
		        :addTo(self)
		else
			local str = self:getStateString_()
			ui.newTTFLabel({text = str, color = cc.c3b(0x81, 0x80, 0x84), size = 14, align = ui.TEXT_ALIGN_CENTER})
		        :pos(x, y)
		        :addTo(self)
		end
	end
end

function FootballQuizRecordListItem:getStateString_()
	local str = ""
	local state = self.state_
	if state == 0 then
		str = REWARD_STATE[1]
	elseif state == 1 then
		str = REWARD_STATE[2]
	elseif state == 3 then
		str = REWARD_STATE[4]
	end

	return str .. "\n" .. bm.LangUtil.getText("FOOTBALL", "BET_ODDS", self.betrate_)
end

function FootballQuizRecordListItem:onGetRewardClick_(evt)
	local btn = evt.target
	btn:setTouchEnabled(false)

	local succCallback = function ()
		bm.LangUtil.getText("FOOTBALL", "GET_REWARD_SUCC_TIPS")

		local x, y = btn:getPosition()
		btn:hide()
		self.state_ = 3
		local str = self:getStateString_()
		ui.newTTFLabel({text = str, color = cc.c3b(0x81, 0x80, 0x84), size = 16, align = ui.TEXT_ALIGN_CENTER})
	        :pos(x, y)
	        :addTo(self)
	end

	local failCallback = function ()
		bm.LangUtil.getText("FOOTBALL", "GET_REWARD_FAIL_TIPS")
		btn:setTouchEnabled(true)
	end

	bm.EventCenter:dispatchEvent({name = "GET_FOOTBALL_BET_REWARD",
		data = {id = self.data_.id, succCallback = succCallback, failCallback = failCallback}})
end

function FootballQuizRecordListItem:onDataSet(dataChanged, data)
	REWARD_STATE = bm.LangUtil.getText("FOOTBALL", "REWARD_STATE")
	self.state_ = data.state --领奖状态，0:未开赛，1：未押中，2：可领奖，3：已领奖
	self.betgcoins_ = data.betgcoins
	self.betmoney_ = data.betmoney
	self.betrate_ = data.betrate --总赔率

	self:addContentInfo_(data.info)

	if self.index_ % 2 == 1 then
		self.frame_:show()
	else
		self.frame_:hide()
	end
end

return FootballQuizRecordListItem