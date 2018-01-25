--
-- Author: hlf
-- Date: 2015-11-04 11:50:45
-- 比赛场每日任务详细列表

local DailyMatchListPopup = class("DailyMatchListPopup", function()
	return display.newNode()
end)

DailyMatchListPopup.WIDTH = 442
DailyMatchListPopup.HEIGHT = 10
DailyMatchListPopup.ITEM_WIDTH = 430
DailyMatchListPopup.ITEM_HEIGHT = 45

function DailyMatchListPopup:ctor(list)
	self.rightPX_ = display.right+DailyMatchListPopup.WIDTH*0.5
	self.leftPX_ = display.right-DailyMatchListPopup.WIDTH*0.5-100
	self.time_ = 0.2

	local width, height = DailyMatchListPopup.WIDTH, DailyMatchListPopup.HEIGHT
	self.mainContainer_ = display.newNode():addTo(self)
    self.mainContainer_:setContentSize(width, height)

    self.mainContainer_:setTouchSwallowEnabled(true)

    self.arrow1_ = display.newSprite("#user-info-desc-bank-frame-arrow.png")
    		:pos(width * 0.5+3, 0)
    		:addTo(self.mainContainer_)
   	self.arrow1_:setRotation(90)
    self.arrow2_ = display.newSprite("#user-info-desc-bank-frame-arrow.png")
    		:pos(width * 0.5+3, 0)
    		:addTo(self.mainContainer_)
    self.arrow2_:setRotation(90)

    self.bg_ = display.newScale9Sprite("#dailytasksMatch_dialog_bg3.png", 0, 0, cc.size(width, height), cc.rect(22, 22, 2, 2))
		:addTo(self.mainContainer_)

	self.closeBtn_ = cc.ui.UIPushButton.new({normal = "#panel_black_close_btn_up.png", pressed="#panel_black_close_btn_down.png"})
        :pos(-width * 0.5-5, height * 0.5 )
        :onButtonClicked(function()
                nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
                self:hide_()
            end)
        :addTo(self.mainContainer_, 999, 999)
    	:hide()    

	self.grapDH_ = DailyMatchListPopup.ITEM_HEIGHT + 16
	self.list_ = list
	self:renderList()
end

-- 刷新对齐
function DailyMatchListPopup:alignList()
	local width, height = DailyMatchListPopup.WIDTH, DailyMatchListPopup.HEIGHT
	local len = #self.itemList_
	local py = 0.5 * len*self.grapDH_ - self.grapDH_*1 + 6

	self.closeBtn_:setPositionY(py + 58)

	local item
	for i=1,len,1 do
		item = self.itemList_[i]
		item.content:pos(0, py)
		item.line:show()
		py = py - self.grapDH_
	end

	if item then
		item.line:hide()
	end

	local offVal = self.grapDH_*len + 10
	self.mainContainer_:setContentSize(width, offVal)

	self.bg_:setContentSize(width, offVal)

	if self.backgroundTex_ then
		self.backgroundTex_:removeFromParent()
	end

	self.backgroundTex_ = display.newTilesSprite(
            "repeat/panel_repeat_tex.png",
            cc.rect(0, 0, width - 3, offVal - 3)
        )
        :pos(0, 0)
        :addTo(self.bg_)
end

function DailyMatchListPopup:hide_()
	self:close()
end

function DailyMatchListPopup:createItem(info, isAddLine)
	local px, py
	local dw = DailyMatchListPopup.ITEM_WIDTH
	local dh = DailyMatchListPopup.ITEM_HEIGHT
	local item = {}
	item.data = info
	item.content = display.newNode():size(dw, dh)
	item.desc = ui.newTTFLabel({
			text = info.desc,
			color = cc.c3b(0x95,0x99,0xa2),
			size = 20
		}):addTo(item.content)

	local sz = item.desc:getContentSize()
	px, py = -dw*0.5 + sz.width*0.5 + 8, dh*0.5
	item.desc:pos(px, py)
	-- progress
	local pdw = 129
	px = dw*0.5 - pdw*0.5 - 4
	item.proContent = display.newNode():addTo(item.content):pos(px, py)
    display.newScale9Sprite("#dailytasksMatch_progressBg.png", 0, 0, cc.size(pdw, 42), cc.rect(8, 21, 2,2)):addTo(item.proContent)
    item.fill = display.newProgressTimer("#dailytasksMatch_progess.png", display.PROGRESS_TIMER_BAR):addTo(item.proContent)
    item.fill:pos(0,1)
    item.fill:setMidpoint(cc.p(0, 0.5))
    item.fill:setBarChangeRate(cc.p(1.0, 0))
    item.fill:setPercentage(info.num/info.total*100)

    item.numTxt = ui.newTTFLabel({
    		text = info.num.."/"..info.total,
    		color = cc.c3b(255,255,255),
    		size = 22
    	})
    	:addTo(item.proContent)

	local buttonDW, buttonDH = 110, 48
	item.btnContent = display.newNode():addTo(item.content):pos(px, py)
	display.newScale9Sprite("#dailytasksMatch_btn2.png", 0, 0, cc.size(110, 48), cc.rect(9, 20, 2, 2))
        :addTo(item.btnContent)

    --领奖
    ui.newTTFLabel({text="รับรางวัล", color=cc.c3b(0x6b, 0x3a, 0x00), size=28})
    	:pos(0, 0)
    	:addTo(item.btnContent)
    cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_6.png"}, {scale9 = true})
        :setButtonSize(buttonDW, buttonDH)
        :pos(0, 0)
        :addTo(item.btnContent)
        :onButtonClicked(function(evt)
        	self:onRewardItemClick_(item.data)
        end)

    item.line = display.newSprite("#dailytasksMatch_line.png")
		:pos(0, -8)
		:addTo(item.content)

    return item
end

-- 更新Item
function DailyMatchListPopup:updateItemById_(id, item, info)
	local px, py
	local dw = DailyMatchListPopup.ITEM_WIDTH
	local dh = DailyMatchListPopup.ITEM_HEIGHT
	-- 任务名称
	item.desc:setString(info.desc)

	local sz = item.desc:getContentSize()
	px, py = -dw*0.5 + sz.width*0.5 + 10, dh*0.5
	item.desc:pos(px, py)
	-- 任务进度
	item.fill:setPercentage(info.num/info.total*100) -- 7

	item.numTxt:setString(info.num.."/"..info.total)

	if item.data.status == 1 then
		item.proContent:hide()
		item.btnContent:show()
	else
		item.proContent:show()
		item.btnContent:hide()
	end 
end

-- 呈现列表
function DailyMatchListPopup:renderList()
	local len = #self.list_
	local item
	self.itemList_ = {}
	for i=1,len,1 do
		item = self:createItem(self.list_[i], true)
		item.content:addTo(self.mainContainer_)
		if item.data.status == 1 then
			item.proContent:hide()
			item.btnContent:show()
		else
			item.proContent:show()
			item.btnContent:hide()
		end

		table.insert(self.itemList_, #self.itemList_+1, item)
	end

	self:alignList()
end

-- 领取奖励
function DailyMatchListPopup:onRewardItemClick_(objInfo)
	nk.MatchDailyManager:rewardDailyById(objInfo.id, handler(self, self.onRewardItemClickCallback_))
end

-- onopenEndPopupCallback:调用打开任务完成弹出框
-- onCloseCallbck:关闭弹出框回调函数
function DailyMatchListPopup:show(onopenEndPopupCallback, onCloseCallbck)
	self.onopenEndPopupCallback_ = onopenEndPopupCallback
    self.onCloseCallbck_ = onCloseCallbck
    nk.PopupManager:addPopup(self)
    return self
end

function DailyMatchListPopup:showAnimation(py, onopenEndPopupCallback, onCloseCallbck)
	self.onopenEndPopupCallback_ = onopenEndPopupCallback
    self.onCloseCallbck_ = onCloseCallbck

    nk.PopupManager:addPopup(self, true, false, true, false, "#transparent.png")
    self:pos(self.rightPX_, py)
    transition.moveTo(self, {
    	time=self.time_, 
    	x=self.leftPX_, 
    	easing = "BACKOUT",
    })
    return self
end

-- 根据Id查找任务项
function DailyMatchListPopup:findItemById_(id)
	local item
	local len = #self.itemList_
	for i=1,len do
		item = self.itemList_[i]
		if item.data.id == id then
			return item
		end
	end

	return nil
end

-- 根据Id移除任务项
function DailyMatchListPopup:removeItemById_(id)
	local item
	local len = #self.itemList_
	for i=1,len do
		item = self.itemList_[i]
		if item.data.id == id then
			table.remove(self.itemList_, i)
			item.content:removeFromParent()
			return true
		end
	end

	return false
end

-- 移除所有的每日任务项
function DailyMatchListPopup:removeAllItem_()
	local item
	local len = #self.itemList_
	for i=1,len do
		item = self.itemList_[i]
		if item then
			item.content:removeFromParent()
		end
	end
	self.itemList_ = {}
end

-- 领取每日任务奖励回调
function DailyMatchListPopup:onRewardItemClickCallback_(id, info)
	local item = self:findItemById_(id)
	if item and info then
		self:updateItemById_(id, item, info)
	else
		self:removeItemById_(id)
		self:alignList()
	end

	if #self.itemList_ == 0 then
		self:onClose()

		if self.onopenEndPopupCallback_ then
			self.onopenEndPopupCallback_()
		end
	end
end

function DailyMatchListPopup:onClose()
    self:close()
end

function DailyMatchListPopup:close()
    nk.PopupManager:removePopup(self)
    return self
end

function DailyMatchListPopup:onRemovePopup(func)
	if self.onCloseCallbck_ then
    	self.onCloseCallbck_()
    end

	transition.moveTo(self, {
		time=self.time_, 
		x=self.rightPX_, 
		easing = "BACKOUT",
		onComplete=function()
			if func then
				func()
			end
		end})
end

return DailyMatchListPopup