--
-- Author: KevinYu
-- Date: 2017-02-15 15:47:25
-- 足球竞猜弹窗

local FootballQuizRecordView 		= import(".FootballQuizRecordView")
local FootballQuizMatchView 		= import(".FootballQuizMatchView")
local FootballQuizRuleView 			= import(".FootballQuizRuleView")
local FootballQuizPopupController 	= import(".FootballQuizPopupController")


local FootballQuizPopup = class("FootballQuizPopup", function()
    return display.newNode()
end)

local tableName = {
	{"football_quiz_match_off.png", "football_quiz_match_on.png"},
	{"football_quiz_record_off.png", "football_quiz_record_on.png"},
	{"football_quiz_about_off.png", "football_quiz_about_on.png"}
}

function FootballQuizPopup:ctor()
	self:setTouchEnabled(true)

	self:setNodeEventEnabled(true)

	self.controller_ = FootballQuizPopupController.new(self)

	self.tableTitle_ = {}

	self.selectedTab_ = 1

	self:addTopNode_()

	self:addTableNode_()

	self:addContentsNode_()
end

function FootballQuizPopup:addTopNode_()
	local w, h = display.width, 70
	local bg = display.newScale9Sprite("#football_title_bg.png", 0, 0, cc.size(w, h))
		:align(display.TOP_CENTER, 0, display.cy)
		:addTo(self, 5)

	local size = bg:getContentSize()

	display.newSprite("#football_title.png")
		:pos(w/2, h/2)
		:addTo(bg)

	cc.ui.UIPushButton.new({normal = "#pop_common_close_normal.png", pressed = "#pop_common_close_pressed.png"})
        :onButtonClicked(buttontHandler(self, self.hidePanel_))
        :pos(w - 45, h/2)
        :addTo(bg)
end

function FootballQuizPopup:addTableNode_()
	local w, h = 184, display.height - 68
	local bg = display.newScale9Sprite("#football_left_bg.png", 0, 0, cc.size(w, h))
		:align(display.BOTTOM_LEFT, -display.cx, -display.cy)
		:addTo(self, 4)

	display.newScale9Sprite("#football_left_bg2.png", 0, 0, cc.size(21, h))
		:align(display.LEFT_CENTER, w - 1, h/2)
		:addTo(bg)

	local btnGroup = nk.ui.CheckBoxButtonGroup.new()

	local sy = h
	local btn_w, btn_h = 184, 74
	
	for i = 1, 3 do
		local frame = display.newNode()
            :size(btn_w, btn_h)
            :align(display.TOP_CENTER, w/2, sy)
            :addTo(bg)

        display.newSprite("#football_table_off.png")
	        :pos(btn_w/2, btn_h/2)
	        :addTo(frame)

		local btn = cc.ui.UICheckBoxButton.new({
            on="#football_table_on.png",
            off="#transparent.png",
            }, {scale9 = true})
		:setButtonSize(btn_w, btn_h)
		:pos(btn_w/2, btn_h/2)
        :addTo(frame)

        self.tableTitle_[i] =  display.newSprite("#" .. tableName[i][1])
	        :pos(btn_w/2, btn_h/2)
	        :addTo(frame)

        btnGroup:addButton(btn)

        sy = sy - btn_h
	end
	
	self.tableTitle_[1]:setSpriteFrame(tableName[1][2])
    btnGroup:getButtonAtIndex(1):setButtonSelected(true)
    btnGroup:onButtonSelectChanged(buttontHandler(self, self.onSelectChanged_))
end

function FootballQuizPopup:onSelectChanged_(evt)
    local id = evt.selected
    self.selectedTab_ = id
    for i, v in ipairs(self.tableTitle_) do
    	if i == id then
    		v:setSpriteFrame(tableName[i][2])
    	else
    		v:setSpriteFrame(tableName[i][1])
    	end
    end

    self:addContentsNode_()
end

--当下注时，超过截止时间，刷新比赛信息
function FootballQuizPopup:updateMatchInfo()
	self:addContentsNode_()
end

function FootballQuizPopup:addContentsNode_()
	local selected = self.selectedTab_
	local w, h = display.width - 204, display.height - 68
	if not self.rightBg_ then
		self.rightBg_ = display.newScale9Sprite("#football_right_bg.png", 0, 0, cc.size(w + 1, h))
			:align(display.BOTTOM_RIGHT, display.cx, -display.cy)
			:addTo(self, 3)
	end
	
	if self.matchView_ then
		self.matchView_:removeFromParent()
		self.matchView_ = nil
	end

	if self.recordView_ then
		self.recordView_:removeFromParent()
		self.recordView_ = nil
	end

	if self.ruleView_ then
		self.ruleView_:removeFromParent()
		self.ruleView_ = nil
	end

	if selected == 1 then
		self.matchView_ = FootballQuizMatchView.new(w, h, self.controller_)
			:pos(w/2, h/2)
			:addTo(self.rightBg_)
	elseif selected == 2 then
		self.recordView_ = FootballQuizRecordView.new(w - 45, h - 55, self.controller_)
			:pos(w/2, h/2)
			:addTo(self.rightBg_)
	elseif selected == 3 then
		self.ruleView_ = FootballQuizRuleView.new(w - 45, h - 55)
			:pos(w/2, h/2)
			:addTo(self.rightBg_)
	end
end


function FootballQuizPopup:setMatchViewData(data)
	if self.matchView_ then
		self.matchView_:setMatchListData(data)
	end
end

function FootballQuizPopup:setRecordViewData(data)
	if self.recordView_ then
		self.recordView_:setRecordListData(data)
	end
end

function FootballQuizPopup:setLoading(isLoading)
	local w, h = display.width - 204, display.height - 68
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
            	:pos(w/2, h/2)
            	:addTo(self.rightBg_)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

function FootballQuizPopup:showPanel()
	nk.PopupManager:addPopup(self, true, true, true, true)
end

function FootballQuizPopup:hidePanel_()
	nk.PopupManager:removePopup(self)
end

function FootballQuizPopup:onCleanup()
	display.removeSpriteFramesWithFile("football_quiz_texture.plist", "football_quiz_texture.png")
	self.controller_:dispose()
end

return FootballQuizPopup
