--
-- Author: HLF(IdaHuang@boyaa.com)
-- Date: 2015-12-29 09:33:34
--
local ScrollLabel = import("boomegg.ui.ScrollLabel")
local TitleBtnGroup = require("app.module.room.views.TitleBtnGroup")
local RoomPopupTabBar = import("app.module.room.views.RoomPopupTabBar")

local MatchDetailPanel = class("MatchDetailPanel", function()
	return display.newNode()
end)

MatchDetailPanel.WIDTH = 265
MatchDetailPanel.HEIGHT = 320

function MatchDetailPanel:ctor(matchData, matchInfo, rankInfo, seatData)
    local totalCount = nk.MatchRecordManager:getMatchOnlineCount()
    self.cfg_ = {}
    self.cfg_.matchName = matchData.name
    self.cfg_.rank = rankInfo.selfRank -- 排名
    self.cfg_.fee = matchInfo.currentChip -- 当前盲注：
    self.cfg_.nextfee = tonumber(matchInfo.currentChip)*2 -- 下一轮盲注：
    self.cfg_.maxchip = rankInfo.maxMoney or seatData.seatChips -- 最大筹码：
    self.cfg_.averChip = rankInfo.averMoney or seatData.seatChips -- 平均筹码：
    self.cfg_.onlineCnt = totalCount or rankInfo.totalCount -- 参赛人数：
    self.cfg_.total = rankInfo.totalCount -- 参赛人数：
    self.cfg_.rewards = {}
    for i=1,#matchData.reward do
        table.insert(self.cfg_.rewards, #self.cfg_.rewards+1, i.."、"..matchData.reward[i])
    end

	self.time_ = 0.2

    local width, height = MatchDetailPanel.WIDTH, MatchDetailPanel.HEIGHT
	self.mainContainer_ = display.newNode():addTo(self)
    self.mainContainer_:setContentSize(width, height)
    self.mainContainer_:setTouchEnabled(true)
    self.mainContainer_:setTouchSwallowEnabled(true)

	self.bg_ = display.newScale9Sprite("#room_pop_bg.png", 0, 0, cc.size(width+12, height+12)):addTo(self.mainContainer_)
	self.bg_:setTouchEnabled(true)
	self.bg_:setTouchSwallowEnabled(true)
    display.newScale9Sprite("#panel_overlay.png", 0, 0, cc.size(MatchDetailPanel.WIDTH, MatchDetailPanel.HEIGHT))
        :addTo(self.mainContainer_)

	self.bgTex_ = display.newTilesSprite(
            "repeat/panel_repeat_tex.png",
            cc.rect(0, 0, width - 3, height - 3)
        )
        :pos(-width*0.5, -height*0.5)
        :addTo(self.mainContainer_)

    self.titleDW_ = 62

    local offDW = 2
    local offDH = self.titleDW_ + 2
    self.borderDH_ = height - offDH
    self.bpx_ = 0
    self.bpy_ = -offDH*0.5 + 3

    self.mainTabBar_ = RoomPopupTabBar.new(
        {
            popupWidth = MatchDetailPanel.WIDTH+46, 
            iconOffsetX = 10, 
            yOffset = -10,
            btnText = {bm.LangUtil.getText("MATCHDETAIL", "MATHC_DETAIL"), bm.LangUtil.getText("MATCHDETAIL", "MATHC_REWARD")}
        }
    )
        :pos(0, 132)
        :addTo(self)
    self.mainTabBar_:onTabChange(handler(self, self.onGroupSelectChanged_))
    self.mainTabBar_:gotoTab(2)

    self.mainContainer_:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onContainerTouchHandler_))
end

function MatchDetailPanel:onTopMatchClick_(evt)
    self:close()
end

function MatchDetailPanel:onGroupSelectChanged_(evt)
	self.index_ = self.mainTabBar_.selectedTab_
	if self.isShowed_ then
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    end

    if self.panel1_ then
    	self.panel1_:hide()
    end
    if self.panel2_ then
    	self.panel2_:hide()
    end

    if self.index_ == 1 then
        self:showPanel1_()
    else
        self:showPanel2_()
    end

    self.isShowed_ = true

    -- 比赛场大厅消耗流水图标点击次数
    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand{command = "event",
                    args = {eventId = "Match_DetailPanel_TYPE", label = "TYPE:"..self.index_}}
    end
end

function MatchDetailPanel:showPanel1_()
	if not self.panel1_ then
        local cfg = self.cfg_
        local sz
        local dw = MatchDetailPanel.WIDTH
        local fontSize = 22
        local lblColor = styles.FONT_COLOR.LIGHT_TEXT
        local txtColor = cc.c3b(0xff, 0xd1, 0x0)
		self.panel1_ = display.newNode()
			:pos(self.bpx_, self.bpy_)
			:addTo(self.mainContainer_)
        local px = 0
        local py = self.borderDH_*0.5 - 23
		local titleLbl = ui.newTTFLabel({
				text=cfg.matchName,
				color=styles.FONT_COLOR.LIGHT_TEXT,
				size=26,
				align=ui.TEXT_ALIGN_CENTER,
			})
			:pos(px, py-5)
			:addTo(self.panel1_)
        bm.fitSprteWidth(titleLbl, dw - 12)

        -- 当前排名
        local offy = 35
        py = py - offy
        local crankLbl = ui.newTTFLabel({
                text=bm.LangUtil.getText("MATCH", "RANKWORD"),
                color=lblColor,
                size=fontSize,
                align=ui.TEXT_ALIGN_CENTER,
            })
            :addTo(self.panel1_)
        sz = crankLbl:getContentSize()
        px = -dw * 0.5 + sz.width * 0.5 + 10
        crankLbl:pos(px, py)
        px = px + sz.width * 0.5

        local crankTxt = ui.newTTFLabel({
                text=(cfg.rank or "0").."/"..(cfg.total or "0"),
                color=txtColor,
                size=fontSize,
                align=ui.TEXT_ALIGN_CENTER,
            })
            :addTo(self.panel1_)
        sz = crankTxt:getContentSize()
        px = px + sz.width * 0.5 + 0
        crankTxt:pos(px, py)

        -- 当前盲注
        py = py - offy
        local cchipLbl = ui.newTTFLabel({
                text=bm.LangUtil.getText("MATCHDETAIL", "CCHIP_LBL_STR"),
                color=lblColor,
                size=fontSize,
                align=ui.TEXT_ALIGN_CENTER,
            })
            :addTo(self.panel1_)
        sz = cchipLbl:getContentSize()
        px = -dw * 0.5 + sz.width * 0.5 + 10
        cchipLbl:pos(px, py)
        px = px + sz.width * 0.5

        local cchipTxt = ui.newTTFLabel({
                text=cfg.fee or "200",
                color=txtColor,
                size=fontSize,
                align=ui.TEXT_ALIGN_CENTER,
            })
            :addTo(self.panel1_)
        sz = cchipTxt:getContentSize()
        px = px + sz.width * 0.5 + 0
        cchipTxt:pos(px, py)

        -- 下一轮盲注
        py = py - offy
        local nchipLbl = ui.newTTFLabel({
                text=bm.LangUtil.getText("MATCHDETAIL", "NCHIP_LBL_STR"),
                color=lblColor,
                size=fontSize,
                align=ui.TEXT_ALIGN_CENTER,
            })
            :addTo(self.panel1_)
        sz = nchipLbl:getContentSize()
        px = -dw * 0.5 + sz.width * 0.5 + 10
        nchipLbl:pos(px, py)
        px = px + sz.width * 0.5

        local nchipTxt = ui.newTTFLabel({
                text=cfg.nextfee or "200",
                color=txtColor,
                size=fontSize,
                align=ui.TEXT_ALIGN_CENTER,
            })
            :addTo(self.panel1_)
        sz = nchipTxt:getContentSize()
        px = px + sz.width * 0.5 + 0
        nchipTxt:pos(px, py) 

        -- 最大筹码
        py = py - offy
        local maxchipLbl = ui.newTTFLabel({
                text=bm.LangUtil.getText("MATCHDETAIL", "MAXCHIP_LBL_STR"),
                color=lblColor,
                size=fontSize,
                align=ui.TEXT_ALIGN_CENTER,
            })
            :addTo(self.panel1_)
        sz = maxchipLbl:getContentSize()
        px = -dw * 0.5 + sz.width * 0.5 + 10
        maxchipLbl:pos(px, py)
        px = px + sz.width * 0.5

        local maxchipTxt = ui.newTTFLabel({
                text=cfg.maxchip,
                color=txtColor,
                size=fontSize,
                align=ui.TEXT_ALIGN_CENTER,
            })
            :addTo(self.panel1_)
        sz = maxchipTxt:getContentSize()
        px = px + sz.width * 0.5 + 0
        maxchipTxt:pos(px, py) 

        -- 平均筹码
        py = py - offy
        local achipLbl = ui.newTTFLabel({
                text=bm.LangUtil.getText("MATCHDETAIL", "ACHIP_LBL_STR"),
                color=lblColor,
                size=fontSize,
                align=ui.TEXT_ALIGN_CENTER,
            })
            :addTo(self.panel1_)
        sz = achipLbl:getContentSize()
        px = -dw * 0.5 + sz.width * 0.5 + 10
        achipLbl:pos(px, py)
        px = px + sz.width * 0.5

        local achipTxt = ui.newTTFLabel({
                text=cfg.averChip,
                color=txtColor,
                size=fontSize,
                align=ui.TEXT_ALIGN_CENTER,
            })
            :addTo(self.panel1_)
        sz = achipTxt:getContentSize()
        px = px + sz.width * 0.5 + 0
        achipTxt:pos(px, py) 

        -- 参赛人数
        py = py - offy
        local onlineLbl = ui.newTTFLabel({
                text=bm.LangUtil.getText("MATCHDETAIL", "ONLINE_LBL_STR"),
                color=lblColor,
                size=fontSize,
                align=ui.TEXT_ALIGN_CENTER,
            })
            :addTo(self.panel1_)
        sz = onlineLbl:getContentSize()
        px = -dw * 0.5 + sz.width * 0.5 + 10
        onlineLbl:pos(px, py)
        px = px + sz.width * 0.5

        local onlineTxt = ui.newTTFLabel({
                text=cfg.onlineCnt,
                color=txtColor,
                size=fontSize,
                align=ui.TEXT_ALIGN_CENTER,
            })
            :addTo(self.panel1_)
        sz = onlineTxt:getContentSize()
        px = px + sz.width * 0.5 + 0
        onlineTxt:pos(px, py)
	end
	self.panel1_:show()
end

function MatchDetailPanel:showPanel2_()
	if not self.panel2_ then
        local cfg = self.cfg_
        -- cfg.matchName = "5泰铢现金币争霸赛"
        -- cfg.rewards = {
        --     "第一名：5现金币+1金券+1铜奖杯+5M游戏币!!!!!!!!",
        --     "第二名：2现金币+3M游戏币",
        --     "第三名：1现金币+2M游戏币",
        -- }

        local sz
        local dw = MatchDetailPanel.WIDTH
        local fontSize = 20
        local lblColor = styles.FONT_COLOR.LIGHT_TEXT
        local txtColor = cc.c3b(0xff, 0xd1, 0x0)

        self.panel2_ = display.newNode()
            :pos(self.bpx_, self.bpy_)
            :addTo(self.mainContainer_)
        local px = 0
        local py = self.borderDH_*0.5 - 23
        local titleLbl = ui.newTTFLabel({
                text=cfg.matchName,
                color=styles.FONT_COLOR.LIGHT_TEXT,
                size=26,
                align=ui.TEXT_ALIGN_CENTER,
            })
            :pos(px, py-5)
            :addTo(self.panel2_)
        bm.fitSprteWidth(titleLbl, dw - 12)

        -- 当前排名
        local LIST_WIDTH = MatchDetailPanel.WIDTH-15
        local LIST_HEIGHT = 208
        self.awardList_ = ScrollLabel.new(
            {
                text  = '',
                color = txtColor,
                size  = fontSize,
                align = ui.TEXT_ALIGN_LEFT,
                valign = ui.TEXT_VALIGN_TOP,
                dimensions=cc.size(LIST_WIDTH, LIST_HEIGHT)
            },
            {
                viewRect = cc.rect(-LIST_WIDTH * 0.5, -LIST_HEIGHT * 0.5, LIST_WIDTH, LIST_HEIGHT)
            })
        :pos(6, LIST_HEIGHT * 0.5-120)
        :addTo(self.panel2_)

        local awardStr = table.concat(cfg.rewards, "\n\r")
        self.awardList_:setString(awardStr)
    end
    self.panel2_:show()
end 

function MatchDetailPanel:onContainerTouchHandler_(evt)
	local name, x, y, prevX, prevY = evt.name, evt.x, evt.y, evt.prevX, evt.prevY
    if evt.name == 'began' then
        return true
    elseif name == "moved" then

    elseif name == "ended"  or name == "cancelled" then 
    	self:close()
	end
end

-- onopenEndPopupCallback:调用打开任务完成弹出框
-- onCloseCallbck:关闭弹出框回调函数
function MatchDetailPanel:show(onopenEndPopupCallback, onCloseCallbck)
	self.onopenEndPopupCallback_ = onopenEndPopupCallback
    self.onCloseCallbck_ = onCloseCallbck
    nk.PopupManager:addPopup(self)

    return self
end

function MatchDetailPanel:showAnimation(px, py, onopenEndPopupCallback, onCloseCallbck)
    self.offy_ = py or 100
    self.topPY_ = display.top + MatchDetailPanel.HEIGHT * 0.5
    self.bottomPY_ = display.top - MatchDetailPanel.HEIGHT * 0.5 - self.offy_

	self.onopenEndPopupCallback_ = onopenEndPopupCallback
    self.onCloseCallbck_ = onCloseCallbck
    nk.PopupManager:addPopup(self, true, false, true, false, "#transparent.png")


    self:pos(px, self.topPY_)
    transition.moveTo(self, {
    	time=self.time_, 
    	y=self.bottomPY_, 
    	easing = "BACKOUT",
    	onComplete = handler(self, self.onShowed)
    })

    return self
end

function MatchDetailPanel:onShowed()
	if self.onopenEndPopupCallback_ then
		self.onopenEndPopupCallback_()
	end
    if self.awardList_ then
        self.awardList_:update()
    end
end

function MatchDetailPanel:hide_()
	self:close()
end

function MatchDetailPanel:onClose()
	self:close()
end

function MatchDetailPanel:close()
	nk.PopupManager:removePopup(self)
    return self
end

function MatchDetailPanel:onRemovePopup(func)
	if self.onCloseCallbck_ then
    	self.onCloseCallbck_()
    end

	transition.moveTo(self, {
		time = self.time_, 
		y = self.topPY_, 
		easing = "BACKOUT",
		onComplete = function()
			if func then
				func()
			end
		end}
    )
end

return MatchDetailPanel