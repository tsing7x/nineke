--
-- Author: HLF(IdaHuang@boyaa.com)
-- Date: 2016-03-31 09:44:23
--
local ScoreMarketViewExt = import("app.module.scoremarket.ScoreMarketViewExt")
local ScoreAddressPopup = import("app.module.scoremarket.ScoreAddressPopup")
local ScoreExchangePopup = import("app.module.scoremarket.ScoreExchangePopup")
local ScoreMarketController = import("app.module.scoremarket.ScoreMarketController")
local OtherUserInfoPanel = import("app.module.luckturn.view.OtherUserInfoPanel")
local LuckWheelSharePopup = import("app.module.luckturn.view.LuckWheelSharePopup")
local DisplayUtil = import("boomegg.util.DisplayUtil")
local BubbleButton = import("boomegg.ui.BubbleButton")
local SimpleColorLabel = import("boomegg.ui.SimpleColorLabel")
local HallController = import("app.module.hall.HallController")
local LuckturnController = import("app.module.luckturn.LuckturnController")
local LuckWheelRecordItem = import("app.module.luckturn.view.LuckWheelRecordItem")

local LuckWheelScorePopup = class("LuckWheelScorePopup", function()
	return display.newNode()
end)

local RECORD_BAR_DW, RECORD_BAR_DH = 385, 450
local RES_BG_DW = 212
local RES_BG_DH = 42
local MIDDLE_NEEDTS = 0.2
local PROG_ICT = 0.05
local MAX_ROTATE_SPEED = 20+8
local FRAME_TS = 1/30 	-- 定时器的帧率
local STATUS_IDLE = "idle" -- 停下
local STATUS_PRESSED = "pressed" -- 按下
local STATUS_UP = "up" -- 松开
local LuckTurnNode_OFFY = 5
local ICON_WIDTH = 85
local ICON_HEIGHT = 85
local AVATAR_TAG = 101
local LAST_CONFIG_KEY = "LAST_CONFIG_KEY"
local BTN_DEFAULT_SCALE = 1
local BTN_SELECT_SCALE = 0.85

local PLAY_BTN_RES = {
	{"turn_playBtn_up.png", "turn_playBtn_down.png", "turn_playBtn_go.png", "turn_playBtn_99.png"},
}

function LuckWheelScorePopup:ctor(hallCtrl, viewType)
	self.hallCtrl_ = hallCtrl
	self.viewType_ = viewType

	self:setNodeEventEnabled(true)
	self.rotatVal_ = 0
	self.progBarVal_ = 0
	self.currentRotatVal_ = 0
	self.status_ = STATUS_IDLE
	self.isPlayBtnEnable_ = true
	self.countLoop_ = 0
	self.playTime_ = 0
	self.ctrl_ = LuckturnController.new(self)
	self.controller_ = ScoreMarketController.new(self)
	local width, height = display.width, display.height
	self.mainContainer_ = display.newNode()
		:addTo(self)
	self.mainContainer_:setContentSize(width, height)
	self.mainContainer_:setTouchEnabled(true)
	self.mainContainer_:setTouchSwallowEnabled(true)

	self:faultView_()
	self:addTopPart_()
	self:addBottomPart_()
	self:addMiddlePart_()
	self:addScheduler_()
	self:addListener()
end

-- 当hallCtrl_为nil时，添加一个默认背景图片
function LuckWheelScorePopup:faultView_()
	if not self.hallCtrl_ then
		local bg = display.newSprite("main_hall_bg.png")
			:center()
			:addTo(self.mainContainer_, 0)
		local sz = bg:getContentSize()
		if sz.height > display.height then
			bg:scale(display.height/sz.height)
		end
	end
end

-- 返回按钮、标题图标
function LuckWheelScorePopup:addTopPart_()
	self.topPartNode_ = display.newNode()
		:pos(display.width*0.5, display.height + 80)
		:addTo(self.mainContainer_, 3)

	-- 返回
    local scaleVal = 1;
    local BUTTON_DW, BUTTON_DH = 102,75;
    px, py = -display.width*0.5 + BUTTON_DW*1.0 - 35, -BUTTON_DH*0.8;
    BubbleButton.createCommonBtn({
            iconNormalResId="#top_return_btn_normal.png",
            btnNormalResId="#common_btn_bg_normal.png",
            btnOverResId="#common_btn_bg_pressed.png",
            parent=self.topPartNode_,
            x=px,
            y=py,
            isBtnScale9=false,
            scaleVal=scaleVal,
            onClick=buttontHandler(self, self.onReback),
        })

   	local titleEff = display.newSprite("#turn_title_light1.png")
   		:addTo(self.topPartNode_, 1)
   	local titleSpr = display.newSprite("#turn_title_1.png")
   		:addTo(self.topPartNode_, 2)
   	local sz = titleSpr:getContentSize()
   	titleSpr:setPositionY(-sz.height*0.5)
   	local scaleVal = 3
   	titleEff:setScale(scaleVal)
   	sz = titleEff:getContentSize()
   	titleEff:setPositionY(-sz.height*0.5*scaleVal)
end

-- 中部
function LuckWheelScorePopup:addMiddlePart_()
	self.middlePartNode_ = display.newNode()
		:pos(display.width*0.5, display.height*0.5 + 26)
		:addTo(self.mainContainer_, 200)

	self.luckTurnNode_ = display.newNode()
		:pos(-display.width*0.5, LuckTurnNode_OFFY)
		:addTo(self.middlePartNode_, 10)

	-- 转动区域
	self.turnArenaNode_ = display.newNode()
		:addTo(self.luckTurnNode_)

	self.sliceNode_ = display.newNode()
		:addTo(self.turnArenaNode_)
	for i=1,4 do
		local sliceBg = display.newSprite("#turn_slice.png")
			:addTo(self.sliceNode_)
		sliceBg:setAnchorPoint(cc.p(1,0))
		sliceBg:rotation((i-1)*90)
		if i == 2 then
			sliceBg:pos(0, -1.0)
		elseif i == 3 then
			sliceBg:pos(-0.5, -0.5)
		elseif i == 4 then
			sliceBg:pos(-0.0, 0.0)
		else
			sliceBg:pos(0.5, -0.5)
		end
	end

	-- 转盘边框
	self.circleSpr_ = display.newSprite("#turn_circle_1.png")
		:addTo(self.luckTurnNode_)

	-- 转盘旋转光圈
	self.turnLightNode_ = display.newNode()
		:addTo(self.turnArenaNode_)

	self.turnLight1_ = display.newSprite("#turn_light.png")
		:addTo(self.turnLightNode_)
	self.turnLight1_:setAnchorPoint(cc.p(0.5, 0.0))

	self.turnLight2_ = display.newSprite("#turn_light.png")
		:addTo(self.turnLightNode_)
	self.turnLight2_:setAnchorPoint(cc.p(0.5, 0.0))
	self.turnLight2_:setScaleY(-1)
	self.turnLightNode_:setRotation(23)

	self.playNode_ = display.newNode()
		:addTo(self.luckTurnNode_)

	display.newSprite("#turn_playBg.png")
		:pos(0, 19)
		:addTo(self.playNode_, 0)

	self.powerStencil_ = display.newDrawNode()
	self.powerClipNode_ = cc.ClippingNode:create()
		:addTo(self.playNode_, 8)

	self.powerClipNode_:setStencil(self.powerStencil_)
	self.turnPower_ = display.newSprite("#turn_power.png")
		:addTo(self.powerClipNode_)

	self.powerDotNode_ = display.newNode()
		:addTo(self.playNode_, 16)

	self.powerDot_ = display.newSprite("#turn_pot.png")
		:pos(-70, 0)
		:addTo(self.powerDotNode_)

	-- 开始按钮
	self.playBtn_ = display.newSprite("#"..PLAY_BTN_RES[1][1]):addTo(self.playNode_, 11)
	self.playBtnClone_ = display.newSprite("#"..PLAY_BTN_RES[1][2]):addTo(self.playNode_, 12):hide()
	self.playGo_ = display.newSprite("#"..PLAY_BTN_RES[1][3]):addTo(self.playNode_, 13)
	self.playBtnClone_:setNodeEventEnabled(false)
	bm.TouchHelper.new(self.playBtn_, handler(self, self.onPlayBtnHandler_))

	self:addRecordBtn_()

	self:setPowerPrograss_(0)
end

-- 右边转盘记录按钮
function LuckWheelScorePopup:addRecordBtn_()
	self.recordBtnNode_ = display.newNode()
		:addTo(self.middlePartNode_, 8)

	self.recordBar_ = display.newSprite("#turn_rightBtn.png")
		:addTo(self.recordBtnNode_)
	local sz = self.recordBar_:getContentSize()
	self.recordBtnNode_:pos(display.width*0.5-sz.width*0.5, 0)

	self.btnIcons_ = {}
	local icon = display.newSprite("#turn_recordUp.png")
		:pos(sz.width*0.5 + 3, sz.height*0.5)
		:addTo(self.recordBar_)
	table.insert(self.btnIcons_, {type=1, icon=icon, upRes="turn_recordUp.png", downRes="turn_recordDown.png"})
	self.recordIcon_ = icon
	icon = display.newSprite("#top_return_btn_normal.png")
		:pos(sz.width*1.5 + 3, sz.height*0.5)
		:addTo(self.recordBar_)
	icon:setScaleX(-1)
	table.insert(self.btnIcons_, {type=2, icon=icon, upRes="top_return_btn_normal.png", downRes="top_return_btn_pressed.png"})

	self.isBtnAnim_ = false
	self.idxStatus_ = true
	bm.TouchHelper.new(self.recordBar_, handler(self, self.onRecordBtnTouch_))
end

function LuckWheelScorePopup:onRecordBtnTouch_(obj, evtName)
	if self.isBtnAnim_ then
		return
	end

	local idx = self.idxStatus_ and 1 or 2
	local item = self.btnIcons_[idx]
	if evtName == bm.TouchHelper.TOUCH_BEGIN then
		item.icon:setSpriteFrame(display.newSpriteFrame(item.downRes))
	elseif evtName == bm.TouchHelper.TOUCH_END then
		item.icon:setSpriteFrame(display.newSpriteFrame(item.upRes))
	elseif evtName == bm.TouchHelper.CLICK then
		self.isBtnAnim_ = true
		local sz = self.recordBar_:getContentSize()
		nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
		item.icon:setSpriteFrame(display.newSpriteFrame(item.upRes))

		local item1 = self.btnIcons_[idx]
		local item2 = self.btnIcons_[idx%2+1]
		item1.icon:show()
		item2.icon:show()
		item2.icon:moveTo(0.15, sz.width*0.5 + 3, sz.height*0.5)
		item1.icon:moveTo(0.15, sz.width*1.5 + 3, sz.height*0.5)
		self:middleAnimation_(item1.type)

		if self.idxStatus_ and self.currentCfgId_ ~= self.currentRecordCfgId_ then
			self:delayGetWheelRecord_()
		end

		self.idxStatus_ = not self.idxStatus_

		self:performWithDelay(function()
			self.isBtnAnim_ = false
		end, MIDDLE_NEEDTS)
	end
end

function LuckWheelScorePopup:middleAnimation_(itype)
	self:removeScheduler_()
	local needTs = MIDDLE_NEEDTS
	local csz = self.circleSpr_:getContentSize()
	self.recordBarNode_:stopAllActions()
	self.luckTurnNode_:stopAllActions()
	local animX = display.width - RECORD_BAR_DW*0.5 - 36
	if itype == 1 then
		self.recordBarNode_:setPositionX(animX)
		self.recordBarNode_:show()
		self.recordBarNode_:runAction(transition.sequence({
			cc.Spawn:create(cc.FadeIn:create(needTs), cc.MoveTo:create(needTs, cc.p(RECORD_BAR_DW*0.5 + 36, 0))),
			cc.CallFunc:create(function()
				self.recordBarNode_:stopAllActions()
				self:addScheduler_()
				if self.recordList_ then
					self.recordList_:setScrollContentTouchRect()
				end
			end)
		}))
		self.luckTurnNode_:moveTo(needTs, -csz.width*0.5+15, LuckTurnNode_OFFY + 18)
	else
		self.recordBarNode_:runAction(transition.sequence({
			cc.Spawn:create(cc.FadeOut:create(needTs), cc.MoveTo:create(needTs, cc.p(animX, 0))),
			cc.CallFunc:create(function()
				self.recordBarNode_:stopAllActions()
				self:addScheduler_()
				self.recordBarNode_:hide()
			end)
		}))
		self.luckTurnNode_:moveTo(needTs, 0, LuckTurnNode_OFFY)
	end
end

-- 转盘记录面板
function LuckWheelScorePopup:addRecordBar_()
	self.recordBarNode_ = display.newNode()
		:addTo(self.middlePartNode_, 10)
	self.recordBarNode_:setCascadeOpacityEnabled(true)

	local dw, dh = RECORD_BAR_DW, RECORD_BAR_DH
	local offDW = 38
	display.newScale9Sprite("#turn_boader.png", 0, 0, cc.size(dw, dh))
		:addTo(self.recordBarNode_)
	local eff = display.newSprite("#turn_boader_light.png")
		:addTo(self.recordBarNode_)
		:pos(-dw*0.5+10, dh*0.5-10)
	eff:setAnchorPoint(cc.p(0, 1))

	eff = display.newSprite("#turn_boader_light.png")
		:addTo(self.recordBarNode_)
		:pos(dw*0.5-5, -dh*0.5+10)
		:rotation(180)
	eff:setAnchorPoint(cc.p(0, 1))

	display.newScale9Sprite("#turn_side.png", 0, dh*0.5-3, cc.size(dw-offDW, 5))
		:addTo(self.recordBarNode_)
	display.newScale9Sprite("#turn_side.png", 0, -dh*0.5+10, cc.size(dw-offDW, 5))
		:addTo(self.recordBarNode_)
	display.newScale9Sprite("#turn_side.png", -dw*0.5+5, 0, cc.size(dh-offDW, 5))
		:addTo(self.recordBarNode_)
		:rotation(90)
	display.newScale9Sprite("#turn_side.png", dw*0.5-5, 0, cc.size(dh-offDW, 5))
		:addTo(self.recordBarNode_)
		:rotation(90)
	self.recordBarNode_:setOpacity(0)
	self.recordBarNode_:hide()

	local offY = 36
	display.newScale9Sprite("#setting_content_up_pressed.png", 0, 0, cc.size(dw-18, offY))
		:pos(0, dh*0.5 - offY*0.5 - 5)
		:addTo(self.recordBarNode_)

	local LIST_DW = RECORD_BAR_DW - 20
	local LIST_DH = RECORD_BAR_DH - 20 - offY
	LuckWheelRecordItem.WIDTH = LIST_DW
	self.recordList_ = bm.ui.ListView.new(
		{
			viewRect = cc.rect(-LIST_DW * 0.5, -LIST_DH * 0.5, LIST_DW, LIST_DH),
			upRefresh = handler(self, self.onUpRecodeList_)
		},
		LuckWheelRecordItem
	)
	:pos(0, -offY*0.5 + 5)
	:addTo(self.recordBarNode_)
	self.recordList_:addEventListener("ITEM_EVENT", handler(self, self.onItemEvent_))

	-- 暂时还没人中大奖，快去玩转盘吧。下一个中大奖就是你
	self.commintTips_ = ui.newTTFLabel({
		text="",
		size=28,
		color=styles.FONT_COLOR.LIGHT_TEXT,
		dimensions=cc.size(320, 0)
	})
	:pos(0, 0)
	:addTo(self.recordBarNode_)

	local offResId = "#transparent.png"
	local onResId = "#common_input_bg.png"
	dw = RECORD_BAR_DW * 0.5 - 8
	dh = 38

	local lbl1 = ui.newTTFLabel({
			text=bm.LangUtil.getText("WHEEL", "LUCKYRANK"),
			size=26,
			color=styles.FONT_COLOR.GOLDEN_TEXT
		})
	local lbl2 = ui.newTTFLabel({
			text=bm.LangUtil.getText("WHEEL", "MYRECORD"),
			size=26,
			color=styles.FONT_COLOR.GOLDEN_TEXT
		})
	self.groupRecord_ = cc.ui.UICheckBoxButtonGroup.new()
        :addButton(cc.ui.UICheckBoxButton.new({off=offResId, on=onResId}, {scale9 = true})
            :setButtonLabel(lbl1)
            :setButtonLabelAlignment(ui.TEXT_ALIGN_CENTER)
            :setButtonSize(dw,dh)
            )
        :addButton(cc.ui.UICheckBoxButton.new({off=offResId, on=onResId}, {scale9 = true})
            :setButtonLabel(lbl2)
            :setButtonLabelAlignment(ui.TEXT_ALIGN_CENTER)
            :setButtonSize(dw,dh)
            )
        :onButtonSelectChanged(function(event)
            self:setRecordLoading(true)
            self.groupRecordIndex_ = event.selected
            if self.groupRecordIndex_==2 then
            	self.ctrl_:getSelfWheelRecord(self.currentCfgId_)
            else
            	self.ctrl_:getScoreWheelRecord(self.currentCfgId_)
            end
        end)
        :pos(-184,172)
        :addTo(self.recordBarNode_, 100)
    bm.fitSprteWidth(lbl1, 150)
    bm.fitSprteWidth(lbl2, 150)

   	self.groupRecordIndex_ = nil
end

function LuckWheelScorePopup:onUpRecodeList_()
	if self.groupRecordIndex_==2 then
		if self.curSelfShowData_ and not self.curSelfShowData_.isEnd then
			self:setRecordLoading(true)
			self.ctrl_:getSelfWheelRecord(self.currentCfgId_,true)
		end
	end
end

function LuckWheelScorePopup:onItemEvent_(evt)
	if evt.type == "ShowOtherUserDetail" then
		local evtData = evt.data
		local uid = evtData.uid
		OtherUserInfoPanel.new(self.ctrl_):show(uid, evtData)
	elseif evt.type == "ScoreMarketViewExt_Real" then
		self.gotoScoreMarketData_ = {}
		self.gotoScoreMarketData_.type = "real"
		self.gotoScoreMarketData_.data = evt.data
		self:onReback()
	elseif evt.type == "ScoreMarketViewExt_Score" then
		self.gotoScoreMarketData_ = {}
		self.gotoScoreMarketData_.type = "score"
		self.gotoScoreMarketData_.data = evt.data
		self:onReback()
	end
end

function LuckWheelScorePopup:updateTouchRect_()
	if self.recordList_ then
        self.recordList_:setScrollContentTouchRect()
    end
end

-- 下面桌子
function LuckWheelScorePopup:addBottomPart_()
	self.bottomPartNode_ = display.newNode()
		:addTo(self.mainContainer_, 1)

	self.tableNode_ = display.newNode()
		:addTo(self.bottomPartNode_, 2)
	self.tableLeft_ = display.newSprite("#turn_table.png")
		:addTo(self.tableNode_)	
	local sz = self.tableLeft_:getContentSize()
	self.tableLeft_:setAnchorPoint(cc.p(1, 0.5))
	self.tableLeft_:pos(display.width*0.5, sz.height*0.5)

	self.tableRight_ = display.newSprite("#turn_table.png")
		:addTo(self.tableNode_)
	self.tableRight_:setAnchorPoint(cc.p(1, 0.5))
	self.tableRight_:pos(display.width*0.5, sz.height*0.5)
	self.tableRight_:setScaleX(-1)

	self.tableSz_ = sz
	self.bottomPartNode_:pos(0, -sz.height*1.0)

	self.tableEff_ = display.newSprite("#turn_tableLight.png")
		:addTo(self.bottomPartNode_, 1)
	local scaleVal = 1.5
	self.tableEff_:setScale(scaleVal)
	sz = self.tableEff_:getContentSize()
	self.tableEff_:pos(display.width*0.5, sz.height*0.5*scaleVal)
	-- 添加现金币图标
	self:addScoreNode_()
	self:alignTxt()
end

function LuckWheelScorePopup:addScoreNode_()
	-- 积分展示
	local dw, dh = 32, 32;
	local px, py = display.width*0.5, self.tableSz_.height*0.5+37
    self.scoreBg_  = display.newScale9Sprite(
            "#turn_score_ bg.png",
            px, 
            py,
            cc.size(220, dh),
            cc.rect(dw,dh, 5, 1)
        )
        :addTo(self.tableNode_);
    local fontSize = 22;
    self.scoreWord_ = ui.newTTFLabel({text=bm.LangUtil.getText("MATCH", "SCORE")..":", size=fontSize, color=cc.c3b(0xff, 0xa6, 0x00)})
        :align(display.BOTTOM_LEFT)
        :addTo(self.scoreBg_)
        :pos(dw,0);
    self.score_ = ui.newTTFLabel({text=tostring(nk.userData.score), size=fontSize, color=cc.c3b(0x93, 0xdd, 0x42)})
        :align(display.BOTTOM_LEFT)
        :addTo(self.scoreBg_)
        :pos(120,0);
end

function LuckWheelScorePopup:getTargetIconPosition_(itype)
    if itype == 3 then  -- 现金币
        return self.scoreBg_:getParent():convertToWorldSpace(cc.p(self.scoreBg_:getPosition()))
    else
        return self.scoreBg_:getParent():convertToWorldSpace(cc.p(self.scoreBg_:getPosition()))
    end
end

function LuckWheelScorePopup:alignTxt()
    self.lastScore_ = nk.userData.score;
    local size1 = self.scoreWord_:getContentSize()
    local size2 = self.score_:getContentSize()
    local size3 = self.scoreBg_:getContentSize()
    local posX, posY = self.scoreWord_:getPosition()
    local posX1,posY1 = self.score_:getPosition()
    self.score_:setPosition(posX+size1.width,posY1)
    self.scoreBg_:setContentSize(cc.size(size1.width+size2.width+38,size3.height))
end

function LuckWheelScorePopup:flushMyScore()
    if self.score_ then
        self.score_:setString(tostring(nk.userData.score))
        self:alignTxt();
        if nk.userData.changeScore and nk.userData.changeScore~=0 then
            bm.blinkTextTarget(self.score_, nk.userData.score, handler(self, self.alignTxt));
        end
    end
end

-- true 移除灰色着色器  false添加灰色着色器
function LuckWheelScorePopup:setPlayBtnEnabled_(value)
	if self.isPlayBtnEnable_ == value then
		return
	end

	if not value then
		DisplayUtil.setGray(self.playBtn_)
		DisplayUtil.setGray(self.playGo_)
		self.playBtnClone_:hide()
	else
		DisplayUtil.removeShader(self.playBtn_)
		DisplayUtil.removeShader(self.playGo_)
		self.playBtnClone_:hide()
	end

	self.isPlayBtnEnable_ = value
end

-- 显示
function LuckWheelScorePopup:onShowed()
	if self.hallCtrl_ then
        self.hallCtrl_.scene_:cleanAllView()
        self.hallCtrl_.scene_:onLuckturnGirl()        
    end

    self:playShowAnim()
    self:addRecordBar_()
    self:updateTouchRect_()

    self.ctrl_:getScoreWheelBtnCfg()
end

function LuckWheelScorePopup:show()
	nk.PopupManager:addPopup(self,true,true,false,false)
    self.mainContainer_:setAnchorPoint(cc.p(0.5, 0.5))

    self:onShowed()
    return self
end

function LuckWheelScorePopup:onRemovePopup(func)
    func()
end

function LuckWheelScorePopup:close()
	nk.PopupManager:removePopup(self)
	return self
end

-- 播放开始动画
function LuckWheelScorePopup:playShowAnim()
	local ts = 0.25
	self.topPartNode_:moveTo(ts, display.width*0.5, display.height + 0)
	self.bottomPartNode_:moveTo(ts, 0, 0)
	self.luckTurnNode_:moveTo(ts, 0, LuckTurnNode_OFFY)
	self:performWithDelay(function()
		self.isPlayAnimEnd_ = true
		self:renderConfig_()
	end, ts*2)
end

-- 播放关闭动画
function LuckWheelScorePopup:playHideAnim(delayVal)
	local val = 0.25
	delayVal = delayVal or 0
	transition.execute(self.topPartNode_, cc.MoveTo:create(val, cc.p(display.width*0.5, display.height + 80)), {delay = delayVal})
	transition.execute(self.bottomPartNode_, cc.MoveTo:create(val, cc.p(0, -self.tableSz_.height*1.0)), {delay = delayVal})
	transition.execute(self.luckTurnNode_, cc.MoveTo:create(val, cc.p(0, -display.width*0.5)), {delay = delayVal})
end

-- 返回按钮
function LuckWheelScorePopup:onReback()
	
	local val = 0
	if not self.idxStatus_ then
		val = MIDDLE_NEEDTS
		self:middleAnimation_(2)
		self:playHideAnim(val*1.5)
	else
		self:playHideAnim()
	end

	self:performWithDelay(handler(self, self.onDelayClose_), 0.25+val)

	if self.hallCtrl_ then
	    if self.viewType_ == HallController.MAIN_HALL_VIEW then
	        self.hallCtrl_:showMainHallViewByBottom()
	    elseif self.viewType_ == HallController.CHOOSE_ARENA_VIEW then 
	        self.hallCtrl_:showChooseArenaRoomView()
	    end
	end
    self.hallCtrl_ = nil
end

function LuckWheelScorePopup:onDelayClose_()
	self:close()

	local gotoScoreMarketData = self.gotoScoreMarketData_
	if gotoScoreMarketData then
		local schedulerPool = bm.SchedulerPool.new()
		schedulerPool:delayCall(function()
			local topTabIndex = 1
			local leftTabIndex = 1
			if gotoScoreMarketData.type == "real" then
				topTabIndex = 2
				leftTabIndex = 3
			else
				topTabIndex = 2
				leftTabIndex = 2
			end
			ScoreMarketViewExt.load(self.hallCtrl_, self.viewType_, leftTabIndex, topTabIndex)
			schedulerPool:clearAll()
		end, 0.5)
	end
end

-- 添加定时器
function LuckWheelScorePopup:addScheduler_()
	if not self.schedulerPool_ then
		self.schedulerPool_ = bm.SchedulerPool.new()
	end
	self.schedulerId_ = self.schedulerPool_:loopCall(handler(self, self.onLoopCall_), FRAME_TS)
end

-- 移除定时器
function LuckWheelScorePopup:removeScheduler_()
	if self.schedulerId_ and self.schedulerPool_ then
		self.schedulerPool_:clear(self.schedulerId_)
		self.schedulerId_ = nil
	end
end

-- 设置力度进度条
function LuckWheelScorePopup:setPowerPrograss_(val)
	if val > 360 then
		val = val % 360
	end

	self.powerDotNode_:setRotation(val+90)

	val = math.pi*2 * val / 360
	local pots = {}
	table.insert(pots, {0, 0})
	if val > 0 then
		for i=0, val+0.1, 0.1 do
			local px = math.sin(i)*90
			local py = math.cos(i)*90
			table.insert(pots, {px, py})
		end
	else
		table.insert(pots, {0, 0})
	end
	self.powerStencil_:clear()
	self.powerStencil_:drawPolygon(pots)
	self.powerValue_ = val
end

-- 向PHP拉取转盘转动结果
function LuckWheelScorePopup:onPlayNow()
	self:setConfigBtnTouch(false)

	bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="Wheel_start"})
	self.id_ = nil

	local idx, cfg, _ = self:getBtnCfg_(self.currentCfgId_)
	-- 模拟假的
	local score = cfg.condition.score
	if not self.playList then
		self.playList = {}
	end
	table.insert(self.playList,score)
	nk.UserInfoChangeManager:userInfoChange({score=nk.userData.score-score});
	bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="Wheel_end"})

	self.ctrl_:playNow(self.currentCfgId_, handler(self, self.callbackPlayFreeNow_))
end

-- 转盘结果返回值
function LuckWheelScorePopup:callbackPlayFreeNow_(isSucc, data)
	if isSucc then
        self.id_ = data.pos
        self.needrecord = 0
        if data.needrecord then
        	self.needrecord = tonumber(data.needrecord)
        end
        self:setDestDegreeById(self.id_)
	else
        self.id_ = -1
        self.needrecord = 0
        self.destDegree_ = 0
        self:setDestDegreeById(self.id_)
	end
end

-- 根据奖品ID获取角度
function LuckWheelScorePopup:setDestDegreeById(id)
	math.randomseed(tostring(os.time()):reverse():sub(1, 6))
	local randDegree = 0
    local offsetDegree = 5
    if id==-1 then
		offsetDegree = -90
		self.destDegree_ = 360 - offsetDegree
		return
	end
    id = id or 0
    if id == 0 then
        randDegree = math.random(-20 + offsetDegree, 20 - offsetDegree)
    else
        local min = 20 + 3 + 45 * (id - 1) + offsetDegree
        local max = min - 3 + 45 - offsetDegree * 2
        randDegree = math.random(min, max)
    end
    self.destDegree_ = 360 - randDegree - 22
end

-- “开始转动” 按下与抬起状态
function LuckWheelScorePopup:onPlayBtnHandler_(obj, evtName, ...)
    if self.isPlayBtnEnable_ or self.status_ == STATUS_PRESSED then
		if self.status_ == STATUS_UP or self.isPlay_ then
			return
		end

		if evtName == bm.TouchHelper.CLICK then
			self.isPlay_ = true
			self.status_ = STATUS_UP
			self.playBtnClone_:hide()
		elseif evtName == bm.TouchHelper.TOUCH_END then
			self.isPlay_ = true
			self.status_ = STATUS_UP
			self.playBtnClone_:hide()
		elseif evtName == bm.TouchHelper.TOUCH_BEGIN then
			local currentTime = os.time()
			if currentTime - self.playTime_ > 1 then
				if self:isPlayNow() then
					nk.SoundManager:playSound(nk.SoundManager.WHEEL_START)
					self.rotatVal_ = 16 -- 给转盘一个初始化力
					self.id_ = nil
					self.status_ = STATUS_PRESSED
					self.playBtnClone_:show()
					self:onPlayNow()

					self.isStopTurnLight_ = true
			        self.soundId = nk.SoundManager:playSound(nk.SoundManager.WHEEL_LOOP, false)
			        self.turnLightNode_:hide()

			        self.playTime_ = currentTime
			    else
			    	nk.TopTipManager:showTopTip(bm.LangUtil.getText("WHEEL", "LUCKTURN_NOT_ENOUGH_MONEY"));
			    end
			end
		end
	end
end

-- 判断是否可以转动转盘
function LuckWheelScorePopup:isPlayNow()
	local result = false
	if not self.currentCfgId_ then
		return result
	end

	local idx, cfg, _ = self:getBtnCfg_(self.currentCfgId_)
	if not cfg then
		return result
	end

	if nk.userData.score >= cfg.condition.score then
		result = true
	end
	self:setPlayBtnEnabled_(result)
	return result
end

-- 转盘光效转动
function LuckWheelScorePopup:turnLightEffect_()
	if self.isStopTurnLight_ then
		return
	end
	-- 光效计数
	if not self.loopCnt_ then
		self.loopCnt_ = 0
	end

	self.loopCnt_ = self.loopCnt_ + 1
	if self.loopCnt_%5 == 0 then
		if not self.turnLightIdx_ then
			self.turnLightIdx_ = 1
		end
		-- 
		local angle = self.turnLightIdx_ * 45 - 22
		self.turnLightNode_:setRotation(angle)
		self.turnLightIdx_ = self.turnLightIdx_ + 1
	end
end

-- 循环
function LuckWheelScorePopup:onLoopCall_()
	if self.status_ == STATUS_IDLE then
		self:turnLightEffect_()
		return true
	end

	self.countLoop_ = self.countLoop_ + 1
	if self.status_ == STATUS_PRESSED or self.id_ == nil or self.countLoop_ < 10 then
		self.progBarVal_ = self.progBarVal_ + PROG_ICT*0.2

		self.rotatVal_ = self.rotatVal_ + PROG_ICT*20		
		if self.rotatVal_ > MAX_ROTATE_SPEED then
			self.rotatVal_ = self.rotatVal_%5 + MAX_ROTATE_SPEED
		end
	elseif self.status_ == STATUS_UP then
		self.progBarVal_ = self.progBarVal_ - PROG_ICT*0.1

		self.rotatVal_ = self.rotatVal_ + PROG_ICT*2		
		if self.rotatVal_ > MAX_ROTATE_SPEED then
			self.rotatVal_ = self.rotatVal_%5 + MAX_ROTATE_SPEED
		end
	end

	if self.progBarVal_ < 0 then
		self.progBarVal_ = 0
		self.rotatVal_ = 0
		self.status_ = STATUS_IDLE
		self:setPowerPrograss_(0)
		self.turnArenaNode_:setRotation(self.destDegree_)

		self.turnLightNode_:show()
		local degree = self.id_ * 45 + 22
		if -1 == self.id_ then
			degree = -90
		end
		self.turnLightNode_:setRotation(degree)
		self.turnLight2_:hide()

		local sequence = transition.sequence({
	        cc.RotateBy:create(0.5, 360*2),
	        cc.CallFunc:create(function()
	            if self.soundId then
	                audio.stopSound(self.soundId)
	            end
	            self:animOverCallback_()
	        end),
	    })
	    self.turnLightNode_:runAction(sequence)
		return true
	elseif self.progBarVal_ > 1 then
		self.progBarVal_ = 1
	end

	self:setPowerPrograss_(self.progBarVal_*360)
	self.currentRotatVal_ = (self.currentRotatVal_ + self.rotatVal_)%360
	self.turnArenaNode_:setRotation(self.currentRotatVal_)
	return true
end

-- 转盘转动结束  谢谢惠顾不弹窗口
function LuckWheelScorePopup:animOverCallback_()
	self.turnLightNode_:stopAllActions()
    self.turnLight2_:setBlendFunc(GL_DST_COLOR, GL_ONE);
    self.turnLight2_:show()
    self.turnLight2_:setRotation(self.turnLight1_:getRotation())
    self.turnLight2_:setScaleY(1)
    local ts1 = 0.2;
    local ts2 = 0.1;
    self.turnLight2_:runAction(cc.RepeatForever:create(transition.sequence({cc.FadeOut:create(ts1), cc.FadeIn:create(ts2)})));
    self.turnLight1_:runAction(cc.RepeatForever:create(transition.sequence({cc.FadeOut:create(ts2), cc.FadeIn:create(ts1)})));
    self:performWithDelay(handler(self, self.onTurnLightCallback_), 0.32)
end

-- 转盘转动结束
function LuckWheelScorePopup:onTurnLightCallback_()
	self.turnLight1_:stopAllActions()
	self.turnLight2_:stopAllActions()
	self.turnLight2_:hide()

	self.countLoop_ = 0
	-- 停止播放转动声音
    if self.soundId then
          audio.stopSound(self.soundId)
    end
    if self.id_ == -1 then
    	-- 模拟假的
		local score = nil
		if self.playList then
			score = table.remove(self.playList,1)
		end
		if score then
			nk.UserInfoChangeManager:userInfoChange({score=nk.userData.score+score});
		end
		nk.TopTipManager:showTopTip("เน็ตของท่านไม่เสถียร รอสักครู่ค่อยลองใหม่นะคะ")
    	bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="Wheel_end"})
    else
    	-- 播放转盘结束声音
	    nk.SoundManager:playSound(nk.SoundManager.WHEEL_END)

		nk.SoundManager:playSound(nk.SoundManager.WHEEL_WIN)

		local item = self:findItemById(self.id_)
		if item.type == "real" then -- or item.type == "score" then
			self:gotoShowGoods_(item)
		else
			LuckWheelSharePopup.new(item):show()
		end

		bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="Wheel_end"})
		self:isPlayNow()
		-- 本地添加玩家转盘日志
		if not item.isRecord or item.isRecord == "1" then 
			self:addSelfRecordLog_(item)
		end
    end

    self:performWithDelay(function ()
        self.isPlay_ = nil
		self.playTime_ = 0
    end, 0.01)

    self:setConfigBtnTouch(true)
end

-- 查找转盘配置信息
function LuckWheelScorePopup:findItemById(id)
    return self.configs_[id + 1]
end

-- 添加监听
function LuckWheelScorePopup:addListener()
	if not self.GetScoreLkWheelRecordId_ then
    	self.GetScoreLkWheelRecordId_ = bm.EventCenter:addEventListener(LuckturnController.GetScoreLkWheelRecord_Event, handler(self, self.onGetScoreLkWheelRecordHandler_))
    end
    if not self.GetScoreWheelBtnCfgId_ then
    	self.GetScoreWheelBtnCfgId_ = bm.EventCenter:addEventListener(LuckturnController.GetScoreWheelBtnCfg_Event, handler(self, self.onGetScoreWheelBtnCfgHandler_))
    end
    if not self.GetScoreWheelConfigId_ then
    	self.GetScoreWheelConfigId_ = bm.EventCenter:addEventListener(LuckturnController.GetScoreWheelConfig_Event, handler(self, self.onGetScoreWheelConfigHandler_))
    end
    if not self.GetSelfWheelConfigId_ then
    	self.GetSelfWheelConfigId_ = bm.EventCenter:addEventListener(LuckturnController.GetSelfWheelRecord_Event,handler(self, self.onGetSelfWheelConfigHandler_))
  	end

    nk.UserInfoChangeManager:reg(nk.UserInfoChangeManager.LuckWheelScorePopup, {"score"}, handler(self, self.getTargetIconPosition_), handler(self,self.flushMyScore))
end

-- 移除监听
function LuckWheelScorePopup:removeListener()
    if self.GetScoreLkWheelRecordId_ then
		bm.EventCenter:removeEventListener(self.GetScoreLkWheelRecordId_)
		self.GetScoreLkWheelRecordId_ = nil;
	end

	if self.GetScoreWheelBtnCfgId_ then
		bm.EventCenter:removeEventListener(self.GetScoreWheelBtnCfgId_)
		self.GetScoreWheelBtnCfgId_ = nil;
	end

	if self.GetScoreWheelConfigId_ then
		bm.EventCenter:removeEventListener(self.GetScoreWheelConfigId_)
		self.GetScoreWheelConfigId_ = nil;
	end

	if self.GetSelfWheelConfigId_ then
		bm.EventCenter:removeEventListener(self.GetSelfWheelConfigId_)
		self.GetSelfWheelConfigId_ = nil
	end

	nk.UserInfoChangeManager:unReg(nk.UserInfoChangeManager.LuckWheelScorePopup)
end

-- 获取到转盘日志数据
function LuckWheelScorePopup:getScoreWheelRecord()
	self:setRecordLoading(true)
	if self.groupRecordIndex_==nil then
		self.groupRecord_:getButtonAtIndex(1):setButtonSelected(true)
	else
		if self.groupRecordIndex_==2 then
			self.ctrl_:getSelfWheelRecord(self.currentCfgId_)
		else
			self.ctrl_:getScoreWheelRecord(self.currentCfgId_)
		end
	end
	self:updateTouchRect_()
end

-- 本地添加玩家转盘日志
function LuckWheelScorePopup:addSelfRecordLog_(cfg)
	if not self.recordData_ then
		self.recordData_ = {}
	end
	local item = {}
	item.time = os.time()
	item.uid = nk.userData.uid
	item.nick = nk.userData.nick
	item.sex = nk.userData.sex
	item.img = nk.userData.s_picture

	item.giftImg = cfg.img
	item.reward = cfg.name
	item.type = cfg.type
	item.num = cfg.num
	item.reward_type = cfg.type
	if self.groupRecordIndex_== 2 then
		item.isSelf = true
		table.insert(self.recordData_, 1, item)
		self.recordList_:setData(self.recordData_, self.recordData_.isDown)
	else
		-- 务必加入自己列表
		self.ctrl_:addSelfRecord(self.currentCfgId_,item)
		if self.needrecord==1 then
			table.insert(self.recordData_, 1, item)
			self.recordList_:setData(self.recordData_)
		else
			return
		end
	end

	self:refreshCommitTips_()
end

-- 返回转盘日志数据
function LuckWheelScorePopup:onGetScoreLkWheelRecordHandler_(evt)
	self:setRecordLoading(false)
	self.currentRecordCfgId_ = evt.data[1]
	self.recordData_ = evt.data[2]
	self.recordList_:setData(self.recordData_)
	self:refreshCommitTips_()
end

-- 刷新个人记录
function LuckWheelScorePopup:onGetSelfWheelConfigHandler_(evt)
	local data = evt.data
	local types = data and data[1]
	if self.groupRecordIndex_==2 and self.currentCfgId_==types then
		self:setRecordLoading(false)
		if not data or not data[2] or #data[2]<1 then
			self.recordList_:hide()
			self.commintTips_:show()
			if self.groupRecordIndex_==2 then
				self.commintTips_:setString(bm.LangUtil.getText("WHEEL","NOMYRECORD"))
			else
				self.commintTips_:setString(bm.LangUtil.getText("WHEEL","NOLUCKYRANK"))
			end
		else
			self.recordList_:show()
			self.commintTips_:hide()
			-- 设置数据 移动到最后一行
			self.recordData_ = data[2]
			self.recordList_:setData(self.recordData_, self.recordData_.isDown)
		end
		-- 当前显示的哦
		self.curSelfShowData_ = data[2]
	end
end

-- 如果日志列表数据为空，则显示提示信息
function LuckWheelScorePopup:refreshCommitTips_()
	if self.recordData_ and #self.recordData_ > 0 then
		self.commintTips_:hide()
		self.recordList_:show()
	else
		self.commintTips_:setString(bm.LangUtil.getText("WHEEL","NOLUCKYRANK"))
		self.commintTips_:show()
		self.recordList_:hide()
	end
end

-- 清理转盘日志数据
function LuckWheelScorePopup:cleanRecordData_()
	self.recordData_ = nil
end

-- 获取转盘配置信息
function LuckWheelScorePopup:onGetScoreWheelConfigHandler_(evt)
	self.configs_ = evt.data
	self:renderConfig_()
end

-- 呈现普通转盘配置项
function LuckWheelScorePopup:renderConfig_()
	if self.isPlayAnimEnd_ and self.configs_ then
		-- 清理
		if self.slices_ then
			for i,v in pairs(self.slices_) do
				if self["txt_"..i] then
					self["txt_"..i]:stopAllActions()
				end
				if self["icon_"..i] then
					self["icon_"..i]:stopAllActions()
				end
        		if self["iconLoaderId_"..i] then
        			nk.ImageLoader:cancelJobByLoaderId(self["iconLoaderId_"..i])
        		end
				v:removeFromParent()
			end
		end

		self.slices_ = {}
	    for i,v in ipairs(self.configs_) do
	    	local color = (i%2 == 0) and cc.c3b(0xfe, 0xd1, 0x4e) or cc.c3b(0xff, 0xaa, 0x61)
	        local node = display.newNode():addTo(self.turnArenaNode_)
	        self:addSliceItem(i, node, v, color)
	        node:setRotation((i-1)*45 + 22.5)
			table.insert(self.slices_, node)
	    end
	end
end

-- 添加每一份扇区配置
function LuckWheelScorePopup:addSliceItem(index, sliceNode, cfg, lblColor)
	if not cfg then
		return;
	end

    local fontSize = 18;
    local px, py = 0, 0;
    local cfgName = cfg.name;
    local txt = ui.newTTFLabel({
            text = cfgName, 
            color = lblColor,
            size = fontSize, 
            align = ui.TEXT_ALIGN_CENTER,
        })
    :pos(px, 190)
    :addTo(sliceNode)
    bm.fitSprteWidth(txt, 120)
    self["txt_"..index] = txt;
    local icon
    local ts = 0.16
	if cfg.type == "fun_face" then
        -- 互动道具
		icon = display.newSprite("#prop_hddj_icon.png"):pos(px, 0):addTo(sliceNode);
		icon:setScale(0.2);        
        icon:runAction(cc.Sequence:create(
            cc.MoveTo:create(ts, cc.p(px, 136)),
            cc.ScaleTo:create(ts, 1.0)
        ));
        self["icon_"..index] = icon;

        txt:runAction(cc.FadeTo:create(ts*2, 255));
	elseif cfg.type == "score" then
        -- 积分现金卡
		icon = display.newSprite("#turn_reward_card.png"):pos(px, 0):addTo(sliceNode);
		local numlbl = ui.newTTFLabel({
            text = cfg.num, 
            color = cc.c3b(0xa0,0x0,0x0),
            size = 32, align = ui.TEXT_ALIGN_CENTER})
        :pos(33, 33)
        :addTo(icon)

        bm.fitSprteWidth(numlbl, 30)

        icon:setScale(0.2);        
        icon:runAction(cc.Sequence:create(
            cc.MoveTo:create(ts, cc.p(px, 135)),
            cc.ScaleTo:create(ts, 1)
        ));
        self["icon_"..index] = icon;
        txt:runAction(cc.FadeTo:create(ts*2, 255));
	elseif cfg.type == "game_coupon" then
        -- 比赛券
		icon = display.newSprite("match_gamecoupon.png"):pos(px, 0):addTo(sliceNode);
        icon:setScale(0.1);        
        icon:runAction(cc.Sequence:create(
            cc.MoveTo:create(ts, cc.p(px, 135)),
            cc.ScaleTo:create(ts, 0.5)
        ));
        self["icon_"..index] = icon;
        txt:runAction(cc.FadeTo:create(ts*2, 255));
    elseif cfg.type == "chips" then
        local res;
        if cfg.num < 800 then
            res = "act-task-reward-chip-icon-1.png";
        elseif cfg.num < 1500 then
            res = "act-task-reward-chip-icon-2.png";
        elseif cfg.num < 4000 then
            res = "act-task-reward-chip-icon-3.png";
        elseif cfg.num < 70000 then
            res = "act-task-reward-chip-icon-4.png";
        elseif cfg.num < 500000 then
            res = "act-task-reward-chip-icon-5.png";
        else
            res = "act-task-reward-chip-icon-6.png";
        end

        icon = display.newSprite("#"..res):pos(px, 0):addTo(sliceNode);
        icon:setScale(0.2);        
        icon:runAction(cc.Sequence:create(
            cc.MoveTo:create(ts, cc.p(px, 138)),
            cc.ScaleTo:create(ts, 1.0)
        ));
        self["icon_"..index] = icon;

        txt:runAction(cc.FadeTo:create(ts*2, 255));
    elseif cfg.type == "ticket" or cfg.type == "real" then
        local iconContainer = display.newNode():pos(px, 130):size(ICON_WIDTH, ICON_HEIGHT):addTo(sliceNode);
        local iconLoaderId = nk.ImageLoader:nextLoaderId();
        local defaultIcon = display.newSprite("#transparent.png"):addTo(iconContainer, AVATAR_TAG, AVATAR_TAG)
        defaultIcon:setScale(0.4)

        self["icon_"..index] = iconContainer;
        self["iconLoaderId_"..index] = iconLoaderId;
        self["defaultIcon"..index] = defaultIcon;
        txt:setOpacity(0)

        nk.ImageLoader:cancelJobByLoaderId(iconLoaderId)
        nk.ImageLoader:loadAndCacheImage(iconLoaderId,
            cfg.img,
            function(success, sprite)
                if sprite and type(sprite) ~= "string" then
                    local tex = sprite:getTexture()
                    local texSize = tex:getContentSize()
                    if iconContainer then
	                    local oldAvatar = iconContainer:getChildByTag(AVATAR_TAG)
	                    if oldAvatar then
	                        oldAvatar:removeFromParent()
	                    end

	                    local iconSize = iconContainer:getContentSize()
	                    local xxScale = iconSize.width/texSize.width
	                    local yyScale = iconSize.height/texSize.height
	                    local scaleVal = xxScale<yyScale and xxScale or yyScale;
	                    sprite:addTo(iconContainer, 0, AVATAR_TAG)

	                    sprite:setScale(0.2);
	                    sprite:pos(0, -80);
	                    sprite:runAction(cc.Sequence:create(
	                        cc.MoveTo:create(ts, cc.p(0, 0)),
	                        cc.ScaleTo:create(ts, scaleVal)
	                    ));

	                    txt:runAction(cc.FadeTo:create(ts*2, 255));
	                end
                end
            end
        )
    end
end

function LuckWheelScorePopup:onGetScoreWheelBtnCfgHandler_(evt)
	self.btnCfgs_ = evt.data

	if self.btns_ then
		for _,v in ipairs(self.btns_) do
			v:removeFromParent()
		end
	end

	self.btns_ = {}
	local btn
	local cfg
	local selectCfgId
	local len = #self.btnCfgs_
    local uintDw = display.width*0.13
    local px, py = display.cx - uintDw*len*0.5 - 60, self.tableSz_.height*0.5 - 32
    local lastCfgId = tonumber(self.ctrl_:getUserDefaultData(LAST_CONFIG_KEY) or 0)
    for i=1,len do
    	cfg = self.btnCfgs_[i]
    	px = px + uintDw
	    btn = BubbleButton.createCommonBtn({
            iconNormalResId="#transparent.png",
            btnNormalResId="#turn_btn"..i..".png",
            parent=self.tableNode_,
            x=px,
            y=py,
            iy=15,
            isBtnScale9=false,
            txtString=cfg.name,
            txtWidth=92,
            txtSize=28,
            txtOffY=-6,
            txtColor=cc.c3b(0xff, 0xcc, 0x0), 
            imgParams={url=cfg.realImg, width=60, height=60,offY=25},
            onClick=function()
            	self:getConfig(self.btnCfgs_[i].id)
            end,
        })
        btn:scale(BTN_DEFAULT_SCALE)
        print("cfg.realImg:::"..tostring(cfg.realImg))
        display.newScale9Sprite("#common_button_pressed_cover.png", 0, -8, cc.size(96, 22))
        	:addTo(btn,6)

        table.insert(self.btns_, btn)
        if cfg.condition and cfg.condition.score < nk.userData.score then
        	selectCfgId = cfg.id
        end

        if lastCfgId and lastCfgId == cfg.id and cfg.condition.score > nk.userData.score then
        	lastCfgId = nil
        end
    end

    if lastCfgId then
    	selectCfgId = lastCfgId
    end

    if not selectCfgId then
    	selectCfgId = self.btnCfgs_[1].id
    end

    self:getConfig(selectCfgId)
end

--转动过程中禁止切换
function LuckWheelScorePopup:setConfigBtnTouch(enable)
	for _, v in ipairs(self.btns_) do
		v.btn:setTouchEnabled(enable)
	end
end

-- 获取按钮配置信息
function LuckWheelScorePopup:getBtnCfg_(cfgId)
	local cfg
	local len = #self.btnCfgs_
	for i=1,len do
		cfg = self.btnCfgs_[i]
		if cfg.id == cfgId then
			return i, cfg, self.btns_[i]
		end
	end
	return nil, nil, nil
end

-- 获取普通转盘配置信息
function LuckWheelScorePopup:getConfig(cfgId)
	if self.currentCfgId_ == cfgId then
		return
	end

	local idx, cfg, btn
	if self.currentCfgId_ then
		-- 移除选中按钮特效状态
		idx, cfg, btn = self:getBtnCfg_(self.currentCfgId_)
		self:removeSelectedBtn_(btn)
	end

	if btn then
	    local orbitAction = cc.OrbitCamera:create(0.15, 1, 0, -90, 90, 0, 0)
        local callback = cc.CallFunc:create(handler(self, self.onFrontActionComplete_))
        local array = {
	        orbitAction,
	        callback
	    }
        self.flipFrontAction_ = cc.Sequence:create(array)

        self.luckTurnNode_:runAction(self.flipFrontAction_)
	end

	-- 获取转盘配置
	self.currentCfgId_ = cfgId
	self.ctrl_:updateUserDefaultData(LAST_CONFIG_KEY, self.currentCfgId_)
    self.ctrl_:getScoreWheelConfig(cfgId)

    -- 添加选中按钮特效状态
    idx, cfg, btn = self:getBtnCfg_(self.currentCfgId_)
    self:setSelectedBtn_(btn)

    -- 如果日志面板打开，则拉去日志列表
    if self.recordBarNode_:isVisible() then
    	self:delayGetWheelRecord_()
    end

    -- 判断转盘状态
    self:isPlayNow()
end

-- 延迟加载日志
function LuckWheelScorePopup:delayGetWheelRecord_()
	self:performWithDelay(function()
    	self:cleanRecordData_()
    	self:getScoreWheelRecord()
    end, 0.5)
end

function LuckWheelScorePopup:onFrontActionComplete_()
	self.luckTurnNode_:stopAllActions()
end

function LuckWheelScorePopup:gotoShowGoods_(itemCfg)
    local goods = {}
    goods.name= itemCfg.name
    goods.image = itemCfg.img
    goods.score = itemCfg.num
    goods.category = itemCfg.type
    goods.type = "luckturn"

    self:callbackScoreExchangePanelExt(goods)
end

-- 点击“兑换”弹出的确认框
function LuckWheelScorePopup:callbackScoreExchangePanelExt(goods, exchangeGoods)
    if goods.category == "real" or goods.category == "score" then
        -- 判断收货地址是否填写
        self.controller_:getMatchAddress1(function(params)
            self:openScoreExchangePopup_(goods);
        end)
    end
end

function LuckWheelScorePopup:openScoreExchangePopup_(goods, addressData)
	display.addSpriteFrames("scoremarket_texture.plist", "scoremarket_texture.png")
    ScoreExchangePopup.new(self.controller_, goods, addressData,  handler(self, self.onExchange_), handler(self, self.onOpenAddressPopup_)):show()
end

-- 请求PHP兑换某一物品
function LuckWheelScorePopup:onExchange_(goods)
    self.controller_:exchangeGoods(goods, cfg)
end

function LuckWheelScorePopup:onOpenAddressPopup_(evt, goods)
    ScoreAddressPopup.new(self.controller_):show(function(addressData)
        if goods then
            self:openScoreExchangePopup_(goods, addressData);
        end
    end)
end

-- 添加选中状态
function LuckWheelScorePopup:setSelectedBtn_(btn)
	if btn then
		DisplayUtil.setIce(btn)
	    btn:scale(BTN_SELECT_SCALE)

	    if btn.imageNode then
		    btn.imageNode:runAction(cc.RepeatForever:create(transition.sequence({
		        cc.MoveBy:create(1.0, cc.p(0, 10)),
		        cc.MoveBy:create(1.0, cc.p(0, -10)),
		    })))
		end
	end
end

-- 移除选中状态
function LuckWheelScorePopup:removeSelectedBtn_(btn)
	if btn then
		DisplayUtil.removeShader(btn)
		btn:scale(BTN_DEFAULT_SCALE)

		if btn.imageNode then
			btn.imageNode:stopAllActions()
			btn.imageNode:pos(0, 0)
		end
	end
end

function LuckWheelScorePopup:setRecordLoading(isLoading)
    if isLoading then
        if not self.juhuaRecord_ then
            self.juhuaRecord_ = nk.ui.Juhua.new()
                :addTo(self.recordBarNode_)
                :pos(0, 0)
        end
    else
        if self.juhuaRecord_ then
            self.juhuaRecord_:removeFromParent()
            self.juhuaRecord_ = nil
        end
    end
end

-- 清理
function LuckWheelScorePopup:onCleanup()
	self:removeScheduler_()
	self:removeListener()

	for i=1,8 do
		if self["iconLoaderId_"..i] then
			nk.ImageLoader:cancelJobByLoaderId(self["iconLoaderId_"..i])
		end
	end

	LuckWheelScorePopup.instance_ = nil

	bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="Wheel_end"})

	display.removeSpriteFramesWithFile("luckturn_new_texture.plist", "luckturn_new_texture.png")
    nk.schedulerPool:delayCall(function()
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end, 0.1)
  	self.ctrl_:dispose()
end

function LuckWheelScorePopup.load(ctrl, view)
	if not LuckWheelScorePopup.instance_ then
		LuckWheelScorePopup.instance_ = true
		display.addSpriteFrames("luckturn_new_texture.plist", "luckturn_new_texture.png", function()
			LuckWheelScorePopup.instance_ = LuckWheelScorePopup.new(ctrl, view):show()
		end)
	end
end

return LuckWheelScorePopup