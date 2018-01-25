--
-- Author: KevinYu
-- Date: 2017-02-20 15:04:00
-- 投注信息item

local FootballQuizBetListItem = class("FootballQuizBetListItem", bm.ui.ListItem)

FootballQuizBetListItem.WIDTH = 540

local info_h = 62
local line_x = {0.12, 0.55, 0.69, 1}
local moneyColor = cc.c3b(0xf8, 0xd0, 0x3a)
local MIN_BET_CHIP, MIN_BET_GCOINS = 10000, 100 --游戏币最小下注，黄金币最小下注

function FootballQuizBetListItem:ctor()
	FootballQuizBetListItem.super.ctor(self, FootballQuizBetListItem.WIDTH, info_h)
	self:setNodeEventEnabled(true)

	self.setEditBoxTouchId_ = bm.EventCenter:addEventListener("QUIZ_BET_EDITBOX_TOUCH", handler(self, self.setEditBoxTouchEnabled_))
end

--比赛信息
function FootballQuizBetListItem:addContentInfo_(data)
	if self.contentNode_ then
		self.contentNode_:removeFromParent()
		self.contentNode_ = nil
	end

	local len = #data
	if len > 0 then
		local w, h = self.width_, info_h * len
		self.height_ = h
		self:setContentSize(cc.size(w, h))

		self.contentNode_ = display.newNode():addTo(self)

		local node = self.contentNode_

		self.frame_ = display.newScale9Sprite("#football_item_frame.png", w/2, h/2, cc.size(w, h))
			:addTo(node):hide()

		for i = 1, 3 do
			display.newScale9Sprite("#football_item_line.png", 0, 0, cc.size(2, h))
				:pos(line_x[i] * w, h/2)
				:addTo(node)
		end

		ui.newTTFLabel({text = bm.LangUtil.getText("FOOTBALL", "SELECTED_MATCH"), size = 18})
	        :pos(line_x[1]/2 * w, h/2)
	        :addTo(node)

	    local line_w = (line_x[2] - line_x[1]) * w
	    local x = (line_x[2] + line_x[1])/2 * w
	    for i = 1, len - 1 do
	    	display.newScale9Sprite("#football_item_line.png", 0, 0, cc.size(2, line_w))
	    		:rotation(90)
				:pos(x, info_h * i)
				:addTo(node)
	    end

		local index = len
        x = line_x[1] * w + 10
		for _, v in ipairs(data) do
			ui.newTTFLabel({text = v, size = 14})
		        :align(display.LEFT_CENTER, x, info_h/2 + (index - 1) * info_h)
		        :addTo(node)

			index = index - 1
		end

		x = (line_x[3] + line_x[2])/2 * w
		ui.newTTFLabel({text = bm.LangUtil.getText("FOOTBALL", "BET_MONEY"), size = 14})
	        :pos(x, h/2)
	        :addTo(node)

	    if nk.userData.footballQuizBetMode == 2 and len < 3 then --组合下注小于三场，不显示下注编辑框
			ui.newTTFLabel({text = bm.LangUtil.getText("FOOTBALL", "GROUP_BET_TIPS"), size = 18})
		        :pos((line_x[4] + line_x[3])/2 * w, h/2)
		        :addTo(node)

		    self.chipEdit_ = nil
			self.gcoinEdit_ = nil
		else
			x = line_x[3] * w + 15
		    self.chipEdit_ = self:createBetEditBox_(
                "#football_chip_icon.png", x, h/2 + 15,
                buttontHandler(self, self.onChipEdit_),
                bm.LangUtil.getText("FOOTBALL","MIN_BET_CHIP", bm.formatBigNumber(MIN_BET_CHIP)))
		    self.gcoinEdit_ = self:createBetEditBox_(
                "#football_gcoin_icon.png", x, h/2 - 15,
                buttontHandler(self, self.onGcoinsEdit_),
                bm.LangUtil.getText("FOOTBALL","MIN_BET_GCOINS",  bm.formatBigNumber(MIN_BET_GCOINS)))
	    end    
	end
end

--创建编辑框
function FootballQuizBetListItem:createBetEditBox_(img, x, y, callback, holder)
    local w = (line_x[4] - line_x[3]) * self.width_ - 55
    local color = cc.c3b(0x11, 0x0, 0x0)

    display.newSprite(img)
    	:align(display.LEFT_CENTER, x, y)
    	:addTo(self.contentNode_)

    local editbox = ui.newEditBox({
        size = cc.size(w, 22),
        image = "#football_input_frame.png",
        align = ui.TEXT_ALIGN_CENTER,
        listener = callback
    })
    :align(display.LEFT_CENTER, x + 30, y)
    :addTo(self.contentNode_)

    editbox:setFontName(ui.DEFAULT_TTF_FONT)
    editbox:setFontSize(16)
    editbox:setFontColor(moneyColor)
    editbox:setPlaceholderFontColor(cc.c3b(0x92, 0x8d, 0x8d))
    editbox:setPlaceHolder(holder)
    editbox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    editbox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)

    return editbox
end

--游戏币下注
function FootballQuizBetListItem:onChipEdit_(event, editbox)
    if event == "began" then
    	editbox:setText(self.chipInput_)
    elseif event == "changed" then
    elseif event == "ended" then
    elseif event == "return" then
        local str = editbox:getText()
        local inputNum = self:checkInputNumber_(str)
        if not inputNum then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","SETPOPONLYNUM"))
        else
        	local lastBet = nk.userData.footballQuizBetChip - self.chipInput_

            if inputNum >= MIN_BET_CHIP then
            	local totalBet = lastBet + inputNum
            	if totalBet <= nk.userData.money then
                    if nk.userData.footballQuizBetMode == 2 and inputNum > 1000000 then
                        inputNum = 1000000
                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("FOOTBALL","MAX_BET_CHIP"))
                    end

            		self.chipInput_ = inputNum
            		self.data_.chip = inputNum
            		self.data_.chipReward = self:getBetReward_(inputNum)
            	else
            		nk.TopTipManager:showTopTip(bm.LangUtil.getText("FOOTBALL","BET_TOTAL_MONEY_TIPS"))
            	end
            else
            	self.chipInput_ = 0
        		self.data_.chip = 0
        		self.data_.chipReward = 0
            	nk.TopTipManager:showTopTip(bm.LangUtil.getText("FOOTBALL","BET_CHIP_TIPS", MIN_BET_CHIP))
            end
        end

        editbox:setText(bm.formatNumberWithSplit(self.chipInput_))

        bm.EventCenter:dispatchEvent("UPDATE_BET_BUTTON_STATE")
    end
end

--黄金币下注
function FootballQuizBetListItem:onGcoinsEdit_(event, editbox)
    if event == "began" then
    	editbox:setText(self.gcoinInput_)
    elseif event == "changed" then
    elseif event == "ended" then
    elseif event == "return" then
        local str = editbox:getText()
        local inputNum = self:checkInputNumber_(str)
        if not inputNum then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","SETPOPONLYNUM"))
        else
        	local lastBet = nk.userData.footballQuizBetGcoins - self.gcoinInput_
        	
            if inputNum >= MIN_BET_GCOINS then
            	local totalBet = lastBet + inputNum
            	if totalBet <= nk.userData.gcoins then
            		self.gcoinInput_ = inputNum
            		self.data_.gcoins = inputNum
            		self.data_.gcoinsReward = self:getBetReward_(inputNum)
            	else
            		nk.TopTipManager:showTopTip(bm.LangUtil.getText("FOOTBALL","BET_TOTAL_MONEY_TIPS"))
            	end
            else
            	self.gcoinInput_ = 0
            	self.data_.gcoins = 0
            	self.data_.gcoinsReward = 0
            	nk.TopTipManager:showTopTip(bm.LangUtil.getText("FOOTBALL","BET_GCOINS_TIPS", MIN_BET_GCOINS))
            end
        end

        editbox:setText(bm.formatNumberWithSplit(self.gcoinInput_))

        bm.EventCenter:dispatchEvent("UPDATE_BET_BUTTON_STATE")
    end
end

--检测输入的是否为数字
function FootballQuizBetListItem:checkInputNumber_(str)
    local p1 = "^%d*$" --检测是否为数字
    local p2 = "0*(%d*)" --去掉前导0
    if string.find(str, p1) then
        local num = string.match(str, p2)
        if num == "" then --全部为0
            num = "0"
        end

        return tonumber(num)
    else
        return nil
    end
end

function FootballQuizBetListItem:onDataSet(dataChanged, data)
	self.betOdds_ = data.betOdds

    if nk.userData.footballQuizBetMode == 1 then
        MIN_BET_CHIP, MIN_BET_GCOINS = 100000, 1000
    else
        MIN_BET_CHIP, MIN_BET_GCOINS = 10000, 100
    end

	self:addContentInfo_(data.match)

	if self.index_ % 2 == 1 then
		self.frame_:show()
	else
		self.frame_:hide()
	end

	if self.chipEdit_ and data.chip ~= 0 then
		self.chipEdit_:setText(bm.formatNumberWithSplit(data.chip))
	end

	if self.gcoinEdit_ and data.gcoins ~= 0 then
		self.gcoinEdit_:setText(bm.formatNumberWithSplit(data.gcoins))
	end

	self.chipInput_ = data.chip
	self.gcoinInput_ = data.gcoins
end

--是否下注了当前比赛
function FootballQuizBetListItem:isBetCurMatch()
	return self.chipInput_ > 0 or self.gcoinInput_ > 0
end

--获取下注，猜对奖励
function FootballQuizBetListItem:getBetReward_(bet)
    local totalOdd = 1
	for _, odds in ipairs(self.betOdds_) do
		totalOdd = totalOdd * odds
	end

	return math.floor(totalOdd * bet)
end

--设置编辑框触摸
function FootballQuizBetListItem:setEditBoxTouchEnabled_(evt)
	if self.chipEdit_ then
		self.chipEdit_:setTouchEnabled(evt.data)
	end
	
	if self.gcoinEdit_ then
		self.gcoinEdit_:setTouchEnabled(evt.data)
	end
end

function FootballQuizBetListItem:onCleanup()
	bm.EventCenter:removeEventListener(self.setEditBoxTouchId_)
end

return FootballQuizBetListItem