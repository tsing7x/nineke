--
-- Author: KevinYu
-- Date: 2017-02-20 15:27:20
-- 竞猜记录视图
-- 
local FootballQuizRecordView = class("FootballQuizRecordView",function()
    return display.newNode()
end)

local FootballQuizRecordListItem = import(".FootballQuizRecordListItem")

function FootballQuizRecordView:ctor(width, height, controller)
	self.controller_ = controller
	self:setNodeEventEnabled(true)

	local bg = display.newScale9Sprite("#football_content_frame.png", 0, 0, cc.size(width, height))
		:addTo(self)

	local posList = {0.12, 0.22, 0.44, 0.75, 0.86, 1} --分割线坐标
	local title_h = 50
	local titleFrame = display.newScale9Sprite("#football_title_frame.png", 0, 0, cc.size(width, title_h))
		:align(display.TOP_CENTER, width/2, height)
		:addTo(bg)

	for i = 1, 5 do
		display.newScale9Sprite("#football_title_line.png", 0, 0, cc.size(2, title_h))
			:pos(posList[i] * width, title_h/2)
			:addTo(titleFrame)
	end

	local titleColor = cc.c3b(0xd6, 0xc9, 0xf7)
	local titles = bm.LangUtil.getText("FOOTBALL", "RECORD_TITLES")
	ui.newTTFLabel({text = titles[1], color = titleColor, size = 16})
        :pos(posList[1]/2 * width, title_h/2)
        :addTo(titleFrame)

	for i = 2, 6 do
		local x = (posList[i] + posList[i - 1])/2 * width
		ui.newTTFLabel({text = titles[i], color = titleColor, size = 16, align = ui.TEXT_ALIGN_CENTER})
	        :pos(x, title_h/2)
	        :addTo(titleFrame)
	end

	local list_w, list_h = width, height - title_h
	FootballQuizRecordListItem.WIDTH = list_w
	self.list_ = bm.ui.ListView.new(
	        {
	            viewRect = cc.rect(-list_w/2, -list_h/2, list_w, list_h)
	        }, 
	        FootballQuizRecordListItem
	    )
        :pos(list_w/2, list_h/2)
    	:addTo(bg)

	self.controller_:getBetRecord()

	self.getBetRewardId_ = bm.EventCenter:addEventListener("GET_FOOTBALL_BET_REWARD", handler(self, self.getBetReward_))
end

function FootballQuizRecordView:setRecordListData(data)
	self.list_:setData(data)
end

function FootballQuizRecordView:getBetReward_(evt)
	local data = evt.data
	self.controller_:getBetReward(data.id, data.succCallback, data.failCallback)
end

function FootballQuizRecordView:updateListView()
	self.list_:setScrollContentTouchRect()
	self.list_:update()
end

function FootballQuizRecordView:onCleanup()
	bm.EventCenter:removeEventListener(self.getBetRewardId_)
end

return FootballQuizRecordView