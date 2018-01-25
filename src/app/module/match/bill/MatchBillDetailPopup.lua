--
-- Author: HLF(IdaHuang@boyaa.com)
-- Date: 2015-12-30 11:46:39
-- 新增物品消耗流水功能
local MatchBillDetailController = import(".MatchBillDetailController")
local MatchBillDetailItem = import(".MatchBillDetailItem")
local MatchBillDetailPopup = class("MatchBillDetailPopup", nk.ui.Panel)

MatchBillDetailPopup.WIDTH = 750
MatchBillDetailPopup.HEIGHT = 480

local PANEL_CLOSE_BTN_Z_ORDER = 99

function MatchBillDetailPopup:ctor(billData)
    MatchBillDetailPopup.super.ctor(self, {MatchBillDetailPopup.WIDTH+30, MatchBillDetailPopup.HEIGHT+30})
    --修改背景框
    self:setBackgroundStyle1()

	self.billData_ = billData
	self:initView_()
    self:addCloseBtn()
    self:setCloseBtnOffset(0,-15)
end

function MatchBillDetailPopup:initView_()
	local width, height = MatchBillDetailPopup.WIDTH, MatchBillDetailPopup.HEIGHT
	self.mainContainer_ = display.newNode():addTo(self)
    self.mainContainer_:setContentSize(width,height)

    self.mainContainer_:setTouchSwallowEnabled(true)
    self.ctrl_ = MatchBillDetailController.new(self)
    self.daysKey_, self.days_ = self.ctrl_:getDays()
    -- 背景
    local px, py = 0, 0
    self.titleBgDH_ = 55
    local dw = width - 8
    local dh = self.titleBgDH_
    py = height*0.5-dh*0.5

    self.barBgDH_ = 40
    px = 0
    py = height*0.5 - self.titleBgDH_ - 24
    dw = width - 40
    dh = self.barBgDH_

    self.subTabDays_ = nk.ui.TabBarWithIndicator.new(
            {
                background = "#popup_sub_tab_bar_bg.png", 
                indicator = "#popup_sub_tab_bar_indicator.png"
            }, 
            self.days_, 
            {
            	selectedText = {color = styles.FONT_COLOR.LIGHT_TEXT, size = 22},
            	defaltText = {color = styles.FONT_COLOR.LIGHT_TEXT, size = 22}
            }, true, true)
    		:pos(px, 111)
    		:addTo(self.mainContainer_,1)
    self.subTabDays_:setTabBarSize(dw, dh)
    self.subTabDays_:gotoTab(1, true)

    dh = 366
    px = 0
    py = -self.titleBgDH_ - self.barBgDH_ + 50    
    self.borderBg_ = display.newScale9Sprite("#panel_overlay.png", px, py, cc.size(dw+15, dh), cc.rect(16,17,1,1))
    	:pos(px, py)
    	:addTo(self.mainContainer_)

    py = py + dh*0.5 - 26
    dw = 320
    dh = 42

    local tabLang = bm.LangUtil.getText("BILLDETAIL", "TAB_TYPES")
    tabLang = clone(tabLang)
    if nk.userData.gcoinsLog~=1 then
        table.remove(tabLang,2)
    end
    -- 一级tab bar
    self.mainTabBar_ = nk.ui.CommonPopupTabBar.new(
            {
                popupWidth = 600,
                iconOffsetX = 10, 
                btnText = tabLang,
            }
        )
        :pos(px, 185)
        :addTo(self.mainContainer_, 10)
    self:addTopDivide(nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5)

    py = 0 - dh - 24
    dh = 306
    dw = width - 40
    self.listBgPY_ = py
    self.listBg_ = display.newScale9Sprite("#pop_userinfo_info_bg.png", px, py, cc.size(dw, dh))
    	:addTo(self.mainContainer_)

    py = py + dh*0.5 - 15
    dh = 29
  	self.listTitleBg_ = display.newScale9Sprite("#setting_content_up_pressed.png", px, py, cc.size(dw, dh))
  		:addTo(self.mainContainer_)

  	self:createListTitle_(py, dw)
  	self:createListView_(dw, px, self.listBgPY_ - dh)

    self.bgTex_ = display.newTilesSprite(
            "repeat/panel_repeat_tex.png",
            cc.rect(0, 0, width + 10, height + 10)
        )
        :pos(0, 0)
        :addTo(self.mainContainer_)

    self:addListenerEvent()
    self:setTabDaySelectedStatus_(1, true)
end

function MatchBillDetailPopup:createListTitle_(py, width)
	local fontSize = 22
	local lblcolor = cc.c3b(0xff, 0xc9, 0xfb)
	local dw = 70
	local px = -width*0.5 + dw
	local lastDW = dw
	self.tlblTime_ = ui.newTTFLabel({
			text=bm.LangUtil.getText("BILLDETAIL", "TITLE_TIME"),
			color=lblcolor,
			size=fontSize,
			align=ui.TEXT_ALIGN_CENTER
		})
		:pos(px, py)
		:addTo(self.mainContainer_, 1)

	dw = 320
	px = -100
	lastDW = dw
	self.tlblWay_ = ui.newTTFLabel({
			text=bm.LangUtil.getText("BILLDETAIL", "TITLE_WAY"),
			color=lblcolor,
			size=fontSize,
			align=ui.TEXT_ALIGN_CENTER
		})
		:pos(px, py)
		:addTo(self.mainContainer_, 1)

	dw = 120
	px = 120
	lastDW = dw
	self.tlblChange_ = ui.newTTFLabel({
			text=bm.LangUtil.getText("BILLDETAIL", "TITLE_CHANGE"),
			color=lblcolor,
			size=fontSize,
			align=ui.TEXT_ALIGN_CENTER
		})
		:pos(px, py)
		:addTo(self.mainContainer_, 1)

	dw = 150
	px = 280
	lastDW = dw
	self.tlblLeft_ = ui.newTTFLabel({
			text=bm.LangUtil.getText("BILLDETAIL", "TITLE_LEFT"),
			color=lblcolor,
			size=fontSize,
			align=ui.TEXT_ALIGN_CENTER
		})
		:pos(px, py)
		:addTo(self.mainContainer_, 1)
end

-- 创建列表
function MatchBillDetailPopup:createListView_(dw, px, py)
    self.noRecordLogLbl_ = ui.newTTFLabel({
            text=bm.LangUtil.getText("BILLDETAIL", "NO_RECORDLOG"),
            color=styles.FONT_COLOR.SLIVER,
            size = 28,
            align=ui.TEXT_ALIGN_CENTER
        })
        :pos(px, py)
        :addTo(self.mainContainer_)

    local LIST_WIDTH = dw
    local LIST_HEIGHT = 276
    MatchBillDetailItem.WIDTH = LIST_WIDTH
    MatchBillDetailItem.HEIGHT = 45
    px = px + LIST_WIDTH*0.0 - 0
    py = py + 15
    self.listDW_ = LIST_WIDTH
    self.list_ = bm.ui.ListView.new(
            {
                viewRect = cc.rect(-LIST_WIDTH * 0.5, -LIST_HEIGHT * 0.5, LIST_WIDTH, LIST_HEIGHT*1),
                upRefresh = handler(self, self.onUpRecodeList_)
            }, 
            MatchBillDetailItem
        )
        :pos(px, py)
        :addTo(self.mainContainer_)
    self.list_:setNotHide(true)
end

function MatchBillDetailPopup:show(callback)
	self.callback_ = callback
	nk.PopupManager:addPopup(self)
    return self
end

function MatchBillDetailPopup:onShowed()
	if self.list_ then
        self.list_:setScrollContentTouchRect()
    end

    self:refreshData()
end

function MatchBillDetailPopup:onClose()
	self:close()
end

function MatchBillDetailPopup:close()
	nk.PopupManager:removePopup(self)
	return self
end

function MatchBillDetailPopup:onRemovePopup(func)
	if self.callback_ then
		self.callback_()
	end
    self:setLoading(false)
    self:removeListenerEvent()
    self.ctrl_:dispose()
	func()
end

function MatchBillDetailPopup:addListenerEvent()
    self.matchPropLogEventId_ = bm.EventCenter:addEventListener("Match_PropLog", handler(self, self.onBindListView_))

    self.mainTabBar_:onTabChange(handler(self, self.refreshData))
    self.subTabDays_:onTabChange(handler(self, self.refreshData))
end

function MatchBillDetailPopup:removeListenerEvent()
    if self.matchPropLogEventId_ then
        bm.EventCenter:removeEventListener(self.matchPropLogEventId_)
        self.matchPropLogEventId_ = nil
    end
end

function MatchBillDetailPopup:setTabDaySelectedStatus_(idx, isSelected)
    if isSelected then
        local dayData = self.daysKey_[idx]
        local months = bm.LangUtil.getText("TICKET", "MONTHS")
        local str = dayData.day.." "..months[dayData.month]
        self.subTabDays_.labels_[idx]:setString(str)
        self.subTabDays_.labels_[idx]:setTextColor(cc.c3b(0xff, 0xd1, 0x0))
    else
        self.subTabDays_.labels_[idx]:setString(self.days_[idx])
        self.subTabDays_.labels_[idx]:setTextColor(styles.FONT_COLOR.LIGHT_TEXT)
    end
end

function MatchBillDetailPopup:refreshData()
    if self.lastDayIdx_ then
        self:setTabDaySelectedStatus_(self.lastDayIdx_, false)
    end

    self.lastDayIdx_ = self.subTabDays_.selectedTab_
    self.lastTypeIdx_ = self.mainTabBar_.selectedTab_
    self:setTabDaySelectedStatus_(self.lastDayIdx_, true)

    self:setLoading(true)
    local daykey = self.daysKey_[self.lastDayIdx_].key
    local toolType = 0
    if nk.userData.gcoinsLog==1 then
        if self.lastTypeIdx_==1 then
            toolType = 1
        elseif self.lastTypeIdx_==2 then
            toolType = 10
        elseif self.lastTypeIdx_==3 then
            toolType = 3
        end
    else
        if self.lastTypeIdx_==1 then
            toolType = 1
        else
            toolType = 3
        end
    end

    self.ctrl_:getBillDetailLog(daykey, toolType)

    -- 比赛场大厅消耗流水图标点击次数
    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand{command = "event",
                    args = {eventId = "Match_BillDetailPanel_TYPE", label = "TYPE:"..toolType}}
    end
end

function MatchBillDetailPopup:onUpRecodeList_()
    self:refreshData()
end

function MatchBillDetailPopup:onBindListView_(evt)
    local data = evt.data.data
    self.list_:setData(data, true)
    self:setLoading(false)
    if #data == 0 then
        self.noRecordLogLbl_:show()
    else
        self.noRecordLogLbl_:hide()
    end
end

function MatchBillDetailPopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            local runScene = display.getRunningScene()
            self.juhua_ = nk.ui.Juhua.new()
                :pos(display.cx, display.cy)
                :addTo(runScene, 9999, 9999)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

return MatchBillDetailPopup