--
-- Author: HLF(IdaHuang@boyaa.com)
-- Date: 2016-03-31 09:44:23

local ScoreMarketViewExt = import("app.module.scoremarket.ScoreMarketViewExt")
local OtherUserInfoPanel = import("app.module.luckturn.view.OtherUserInfoPanel")
local LuckWheelSharePopup = import("app.module.luckturn.view.LuckWheelSharePopup")
local DisplayUtil = import("boomegg.util.DisplayUtil")
local BubbleButton = import("boomegg.ui.BubbleButton")
local SimpleColorLabel = import("boomegg.ui.SimpleColorLabel")
local HallController = import("app.module.hall.HallController")
local LuckturnController = import("app.module.luckturn.LuckturnController")
local LuckWheelRecordItem = import("app.module.luckturn.view.LuckWheelRecordItem")

local LuckWheelFreePopup = class("LuckWheelFreePopup", function()
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
local ICON_WIDTH = 60
local ICON_HEIGHT = 60
local AVATAR_TAG = 101
local FEECNTLBL_OFFX = 98

local PLAY_BTN_RES = {
	{"turn_playBtn_up.png", "turn_playBtn_down.png", "turn_playBtn_go.png", "turn_playBtn_99.png"},
}

function LuckWheelFreePopup:ctor(hallCtrl, viewType)
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
	local width, height = display.width, display.height
	self.mainContainer_ = display.newNode()
		:addTo(self)
	self.mainContainer_:setContentSize(width, height)
	self.mainContainer_:setTouchEnabled(true)
	self.mainContainer_:setTouchSwallowEnabled(true)

	self.imgLoaders_ = {}
	self:faultView_()
	self:addTopPart_()
	self:addBottomPart_()
	self:addMiddlePart_()

	self:getConfig()
	self:addScheduler_()
	self:addListener()
end

-- 当hallCtrl_为nil时，添加一个默认背景图片
function LuckWheelFreePopup:faultView_()
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
function LuckWheelFreePopup:addTopPart_()
	self.topPartNode_ = display.newNode()
		:pos(display.width*0.5, display.height + 80)
		:addTo(self.mainContainer_, 3)

	-- 返回
    local scaleVal = 1
    local BUTTON_DW, BUTTON_DH = 102,75
    px, py = -display.width*0.5 + BUTTON_DW*1.0 - 35, -BUTTON_DH*0.8
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

   	local titleEff = display.newSprite("#turn_title_light2.png"):addTo(self.topPartNode_, 1)
   	local titleSpr = display.newSprite("#turn_title_3.png"):addTo(self.topPartNode_, 2)
   	local sz = titleSpr:getContentSize()
   	titleSpr:setPositionY(-sz.height*0.5)
   	local scaleVal = 3
   	titleEff:setScale(scaleVal)
   	sz = titleEff:getContentSize()
   	titleEff:setPositionY(-sz.height*0.5*scaleVal)
   	self.titleSpr_ = titleSpr
   	DisplayUtil.setGray(self.titleSpr_)
end

-- 中部
function LuckWheelFreePopup:addMiddlePart_()
	self.middlePartNode_ = display.newNode()
		:pos(display.width*0.5, display.height*0.5 + 26)
		:addTo(self.mainContainer_, 200)

	self.luckTurnNode_ = display.newNode()
		:pos(-display.width*0.5, 0)
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
	DisplayUtil.setGray(self.circleSpr_)

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

	self.playNode_ = display.newNode():addTo(self.luckTurnNode_)
	display.newSprite("#turn_playBg.png"):pos(0, 19):addTo(self.playNode_, 0)

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
	self.playGo_ = display.newSprite("#"..PLAY_BTN_RES[1][3]):addTo(self.playNode_, 12)
	self.play99_ = display.newSprite("#"..PLAY_BTN_RES[1][4]):addTo(self.playNode_, 13):hide()

	bm.TouchHelper.new(self.playBtn_, handler(self, self.onPlayBtnHandler_))

	self:addRecordBtn_()

	self:setPowerPrograss_(0)
end

-- 右边转盘记录按钮
function LuckWheelFreePopup:addRecordBtn_()
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

function LuckWheelFreePopup:onRecordBtnTouch_(obj, evtName)
	if self.isBtnAnim_ then
		return
	end

	local idx = self.idxStatus_ and 1 or 2
	local item = self.btnIcons_[idx]
	if evtName == bm.TouchHelper.TOUCH_BEGIN then
		if item.downRes then
			item.icon:setSpriteFrame(display.newSpriteFrame(item.downRes))
		end
	elseif evtName == bm.TouchHelper.TOUCH_END then
		if item.upRes then
			item.icon:setSpriteFrame(display.newSpriteFrame(item.upRes))
		end
	elseif evtName == bm.TouchHelper.CLICK then
		self.isBtnAnim_ = true

		nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
		if item.upRes then
			item.icon:setSpriteFrame(display.newSpriteFrame(item.upRes))
		end

		local sz = self.recordBar_:getContentSize()
		local item1 = self.btnIcons_[idx]
		local item2 = self.btnIcons_[idx%2+1]
		item1.icon:show()
		item2.icon:show()
		item2.icon:moveTo(0.15, sz.width*0.5 + 3, sz.height*0.5)
		item1.icon:moveTo(0.15, sz.width*1.5 + 3, sz.height*0.5)
		self.idxStatus_ = not self.idxStatus_
		self:middleAnimation_(item1.type)

		self:performWithDelay(function()
			self.isBtnAnim_ = false
		end, MIDDLE_NEEDTS)
	end
end

function LuckWheelFreePopup:middleAnimation_(itype)
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
				self:getFreeWheelRecord()
			end)
		}))
		self.luckTurnNode_:moveTo(needTs, -csz.width*0.5+15, 18)
	else
		self.recordBarNode_:runAction(transition.sequence({
			cc.Spawn:create(cc.FadeOut:create(needTs), cc.MoveTo:create(needTs, cc.p(animX, 0))),
			cc.CallFunc:create(function()
				self.recordBarNode_:stopAllActions()
				self:addScheduler_()
				self.recordBarNode_:hide()
			end)
		}))
		self.luckTurnNode_:moveTo(needTs, 0, 0)
	end
end

-- 转盘记录面板
function LuckWheelFreePopup:addRecordBar_()
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
	local titleLbl = ui.newTTFLabel({
			text=bm.LangUtil.getText("WHEEL", "LUCKYRANK"),
			color=styles.FONT_COLOR.GOLDEN_TEXT,
			size=26,
			align=ui.TEXT_ALIGN_CENTER,
		})
		:addTo(self.recordBarNode_)
	local sz = titleLbl:getContentSize()
	titleLbl:pos(0, dh*0.5 - sz.height*0.5 - 9)
	bm.fitSprteWidth(titleLbl, 160)

	local LIST_DW = RECORD_BAR_DW - 20
	local LIST_DH = RECORD_BAR_DH - 20 - offY
	LuckWheelRecordItem.WIDTH = LIST_DW
	self.recordList_ = bm.ui.ListView.new(
		{
			viewRect = cc.rect(-LIST_DW * 0.5, -LIST_DH * 0.5, LIST_DW, LIST_DH),
		},
		LuckWheelRecordItem
	)
	:pos(0, -offY*0.5 + 5)
	:addTo(self.recordBarNode_)
	self.recordList_:addEventListener("ITEM_EVENT", handler(self, self.onItemEvent_))
	-- 暂时还没人中大奖，快去玩转盘吧。下一个中大奖就是你
	self.commintTips_ = ui.newTTFLabel({
		text=bm.LangUtil.getText("WHEEL", "NOLUCKYRANK"),
		size=28,
		color=styles.FONT_COLOR.LIGHT_TEXT,
		dimensions=cc.size(320, 0)
	})
	:pos(0, 0)
	:addTo(self.recordBarNode_)
end

function LuckWheelFreePopup:onItemEvent_(evt)
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

function LuckWheelFreePopup:updateTouchRect_()
	if self.recordList_ then
        self.recordList_:setScrollContentTouchRect()
    end
end

-- 下面桌子
function LuckWheelFreePopup:addBottomPart_()
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
	-- 剩余次数
	local px = display.width*0.5
	local py = self.tableSz_.height*0.5+10
	self.resBg_ = display.newScale9Sprite("#turn_resBg.png", px, py, cc.size(RES_BG_DW+8, RES_BG_DH), cc.rect(38,20,5,5))
		:addTo(self.tableNode_)
	sz = self.resBg_:getContentSize()
	local msg = bm.LangUtil.getText("WHEEL", "REMAIN_COUNT").."{0}"..bm.LangUtil.getText("WHEEL", "TIME")
	self.feeCntLbl_ = SimpleColorLabel.html(msg, styles.FONT_COLOR.GOLDEN_TEXT, styles.FONT_COLOR.LIGHT_TEXT, 32, 1)
    	:pos(px, py)
        :addTo(self.tableNode_, 10)
    local desc = "Tips:บัญชีนักเที่ยวหมุนฟรีวันละ {2} ครั้ง บัญชี FB หมุนฟรีวันละ {1} ครั้ง"
    local descLbl1 = SimpleColorLabel.html(desc, cc.c3b(0x8d, 0x8c, 0xbd), cc.c3b(0xff, 0xae, 0x70), 22, 1)
    	:addTo(self.tableNode_):pos(display.width*0.5, 30)
end

function LuckWheelFreePopup:getPlayTimes()
    self:setPlayTimesLoading(true)
    self.ctrl_:getPlayTimes(function(isSucc, data, fbIntviteCount)
        if isSucc then
            -- 邀请好友成功赠送的次数 fbIntviteCount
            self:refreshPlayTimes_(data)
        end
        self:setPlayTimesLoading(false)
    end)
end

-- 刷新显示次数 btnEnable  最后一次不停止
function LuckWheelFreePopup:refreshPlayTimes_(data,btnEnable)
	if data < 0 then
		data = 0
	end

	self.playTimes_ = data
    self.feeCntLbl_.setString(2, " "..data.." ")
	local dw = RES_BG_DW - 15
	if self.feeCntLbl_.width > dw then
		local scaleVal = dw/self.feeCntLbl_.width
		self.feeCntLbl_:setScale(scaleVal)
	else
		self.feeCntLbl_:setScale(1)		
	end
	self.feeCntLbl_:setPositionX(display.width*0.5)

    if not self.isRenderPlayBtnStyles_ then
    	self:renderPlayBtnStyles_(true)
    	self.isRenderPlayBtnStyles_ = true
	end
end

-- 转动按钮根据剩余次数改变样式
function LuckWheelFreePopup:renderPlayBtnStyles_(value)
	if not self.playTimes_ or self.playTimes_ < 1 then
		self.lastIdx_ = nil
		self.isPayModel = true
		self:setPlayBtnStyles(1)
		-- 判断是否显示为筹码够吗
		if not self.isCoinBuyChance_ then
			if value then
				DisplayUtil.removeShader(self.circleSpr_)
				DisplayUtil.removeShader(self.titleSpr_)
			else
				self:showCoinBuyChanceEffect_()
			end
			self.isCoinBuyChance_ = true
		end
	else
		self:setPlayBtnStyles(1)
	end
end

function LuckWheelFreePopup:showCoinBuyChanceEffect_()
	local ts1 = 0.12
	local ts2 = 0.5
	local num = 10
	local list = {}
    local circleSpr
	for i=1,num do
		circleSpr = display.newSprite("#turn_circle_1.png"):addTo(self.luckTurnNode_):scale(3):opacity(255*0.2)
		circleSpr:runAction(transition.sequence({
			cc.DelayTime:create(ts1*i),
			cc.ScaleTo:create(0.5, 1),
		}))
		list[i] = circleSpr
	end

	self:performWithDelay(function ()
        for i=1,num do
        	list[i]:removeFromParent()
        end
        list = nil
        DisplayUtil.removeShader(self.circleSpr_)
        DisplayUtil.removeShader(self.titleSpr_)
    end, ts1*num)	
end

function LuckWheelFreePopup:setPlayBtnStyles(idx)
	local resId
	if self.isPayModel then
		if self.lastIdx_ ~= idx then
			resId = PLAY_BTN_RES[1][idx]
			self.playBtn_:setSpriteFrame(display.newSpriteFrame(resId))
		end

		self.playGo_:pos(0, 8)
		self.play99_:pos(0, -16):show()

		self.lastBtnType_ = 2
	else
		if self.lastIdx_ ~= idx then
			resId = PLAY_BTN_RES[1][idx]
			self.playBtn_:setSpriteFrame(display.newSpriteFrame(resId))
		end

		self.playGo_:pos(0, 0)
		self.play99_:hide()

		self.lastBtnType_ = 1
	end 
	self.lastIdx_ = idx
end

-- 获取普通转盘配置信息
function LuckWheelFreePopup:getConfig()
    self.ctrl_:getFreeConfig(function(isSucc, data)
        if isSucc then
            self.configs_ = data
            self:renderConfig_()
        end
    end)
end

-- 呈现普通转盘配置项
function LuckWheelFreePopup:renderConfig_()
	if self.isPlayAnimEnd_ and self.configs_ then
		-- 清理
		if self.slices_ then
			for _,v in pairs(self.slices_) do
				if v.lbl then
					v.lbl:removeFromParent()
					v.lbl = nil
				end

				if v.icon then
					v.icon:stopAllActions()
					v.icon:removeFromParent()
					v.icon = nil
				end
				if v.node then
					v.icon:stopAllActions()
					v.icon:removeFromParent()
					v.icon = nil
				end
			end
		end

		self.slices_ = {}
	    for i,v in ipairs(self.configs_) do
	        local node = display.newNode():addTo(self.turnArenaNode_)
	        local lbl = ui.newTTFLabel({
	        		text=v.desc,
	        		color=(i%2 == 0) and cc.c3b(0xfe, 0xd1, 0x4e) or cc.c3b(0xff, 0xaa, 0x61),
	        	})
	        	:pos(0, 190)
	        	:addTo(node, 1, 1)
	        local icon = display.newNode()
	        	:size(ICON_WIDTH, ICON_HEIGHT)
	        	:pos(0, 130)
	        	:addTo(node, 2, 2)

	        node:setRotation((i-1)*45 + 22.5)
			local ts = 0.2
			lbl:setOpacity(0)
			if not self.imgLoaders_[i] then
				self.imgLoaders_[i] = nk.ImageLoader:nextLoaderId()
			end
			local iconLoaderId = self.imgLoaders_[i]
			nk.ImageLoader:cancelJobByLoaderId(iconLoaderId)
			nk.ImageLoader:loadAndCacheImage(iconLoaderId,
	            v.url,
	            function(success, sprite)
	                if sprite and type(sprite) ~= "string" and type(sprite~="number") then
	                    local tex = sprite:getTexture()
	                    local texSize = tex:getContentSize()
	                    if icon then
		                    local oldAvatar = icon:getChildByTag(AVATAR_TAG)
		                    if oldAvatar then
		                        oldAvatar:removeFromParent()
		                    end
		                    
		                    local xxScale = ICON_WIDTH/texSize.width
		                    local yyScale = ICON_HEIGHT/texSize.height
		                    local scaleVal = xxScale<yyScale and xxScale or yyScale
		                    sprite:addTo(icon, 0, AVATAR_TAG)

		                    sprite:setScale(0.2)
		                    sprite:pos(0, -80)
		                    sprite:runAction(cc.Sequence:create(
		                        cc.MoveTo:create(ts, cc.p(0, 0)),
		                        cc.ScaleTo:create(ts, scaleVal)
		                    ))
		                    
		                    lbl:runAction(cc.FadeTo:create(ts*2, 255))
		                end
	                end
	            end
	        )

			table.insert(self.slices_, {node=node, lbl=lbl, icon=icon})
	    end
	end
end

-- 显示
function LuckWheelFreePopup:onShowed()
	if self.hallCtrl_ then
        self.hallCtrl_.scene_:cleanAllView()
        self.hallCtrl_.scene_:onLuckturnGirl()        
    end

    self:playShowAnim()
    self:getPlayTimes()

    self:addRecordBar_()
    self:updateTouchRect_()
end

function LuckWheelFreePopup:show()
	bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, 0)
	nk.PopupManager:addPopup(self,true,true,false,false)
    self.mainContainer_:setAnchorPoint(cc.p(0.5, 0.5))

    self:onShowed()
    return self
end

function LuckWheelFreePopup:onRemovePopup(func)
    func()
end

function LuckWheelFreePopup:close()
	nk.PopupManager:removePopup(self)
	return self
end

-- 播放开始动画
function LuckWheelFreePopup:playShowAnim()
	local ts = 0.25
	self.topPartNode_:moveTo(ts, display.width*0.5, display.height + 0)
	self.bottomPartNode_:moveTo(ts, 0, 0)
	self.luckTurnNode_:moveTo(ts, 0, 0)
	self:performWithDelay(function()
		self.isPlayAnimEnd_ = true
		self:renderConfig_()
	end, ts*2)
end

-- 播放关闭动画
function LuckWheelFreePopup:playHideAnim(delayVal)
	local val = 0.25
	delayVal = delayVal or 0
	transition.execute(self.topPartNode_, cc.MoveTo:create(val, cc.p(display.width*0.5, display.height + 80)), {delay = delayVal})
	transition.execute(self.bottomPartNode_, cc.MoveTo:create(val, cc.p(0, -self.tableSz_.height*1.0)), {delay = delayVal})
	transition.execute(self.luckTurnNode_, cc.MoveTo:create(val, cc.p(0, -display.width*0.5)), {delay = delayVal})
end

-- 返回按钮
function LuckWheelFreePopup:onReback()
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

function LuckWheelFreePopup:onDelayClose_()
	self:close()

	local gotoScoreMarketData = self.gotoScoreMarketData_
	if gotoScoreMarketData then
		local schedulerPool = bm.SchedulerPool.new()
		schedulerPool:delayCall(function()
			local topTabIndex = 1
			local leftTabIndex = 1
			if gotoScoreMarketData.type == "shop" then
				local StorePopup = import("app.module.newstore.StorePopup")
				StorePopup.new():showPanel()
			elseif gotoScoreMarketData.type == "real" then
				topTabIndex = 2
				leftTabIndex = 3
				ScoreMarketViewExt.load(self.hallCtrl_, self.viewType_, leftTabIndex, topTabIndex)
			elseif gotoScoreMarketData.type == "score" then
				topTabIndex = 2
				leftTabIndex = 2
				ScoreMarketViewExt.load(self.hallCtrl_, self.viewType_, leftTabIndex, topTabIndex)
			end
			
			schedulerPool:clearAll()
		end, 0.5)
	end
end

-- 添加定时器
function LuckWheelFreePopup:addScheduler_()
	if not self.schedulerPool_ then
		self.schedulerPool_ = bm.SchedulerPool.new()
	end
	self.schedulerId_ = self.schedulerPool_:loopCall(handler(self, self.onLoopCall_), FRAME_TS)
end

-- 移除定时器
function LuckWheelFreePopup:removeScheduler_()
	if self.schedulerId_ and self.schedulerPool_ then
		self.schedulerPool_:clear(self.schedulerId_)
		self.schedulerId_ = nil
	end
end

-- 设置力度进度条
function LuckWheelFreePopup:setPowerPrograss_(val)
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
function LuckWheelFreePopup:onPlayFreeNow()
	self.id_ = nil
	self.ctrl_:playFreeNow(handler(self, self.callbackPlayFreeNow_))
end

-- 转盘结果返回值
function LuckWheelFreePopup:callbackPlayFreeNow_(isSucc, data)
	if isSucc then
        self:refreshPlayTimes_(self.playTimes_ - 1,true)
        self.commonAward = 0
        self.needrecord = 0 
       	if data.retluckywheel then
       		self.commonAward = tonumber(data.retluckywheel)
       		-- 1 谢谢惠顾
       		-- 2 再来一次
       		-- 3 门票 是门票
       	end
        self.id_ = data.id
       	if data.needrecord then
       		self.needrecord = tonumber(data.needrecord)
       	end
        self:setDestDegreeById(self.id_)
	else
		local id_ = -1
		self.commonAward = 0
		self.needrecord = 0
		for k,v in pairs(self.configs_) do
			if v.baseReward and tonumber(v.baseReward)==1 then
				id_ = v.id
				break
			end
		end
		self.id_ = id_
		self:refreshPlayTimes_(self.playTimes_ - 1,true)
		self.commonAward = 2
		self:setDestDegreeById(self.id_)
	end
end

-- 根据奖品ID获取角度
function LuckWheelFreePopup:setDestDegreeById(id)
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

-- 判断是否有足够筹码购买转盘次数
function LuckWheelFreePopup:isEnoughMoney()
	if nk.userData.money >= nk.userData.buyLuckWheelChanceMoney then
		return true
	end
	return false
end

function LuckWheelFreePopup:alertGotoShop_()
	nk.ui.Dialog.new({
        messageText = bm.LangUtil.getText("WHEEL", "NOTENOUGHMONEY"),
        hasFirstButton = doRequest,
        closeWhenTouchModel = not doRequest,
        callback = function (type)
            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
            	self.gotoScoreMarketData_ = {}
				self.gotoScoreMarketData_.type = "shop"
				self.gotoScoreMarketData_.data = nil
				self:onReback()
            end
        end
    }):show()
end

-- “开始转动” 按下与抬起状态
function LuckWheelFreePopup:onPlayBtnHandler_(obj, evtName, ...)
	-- 最后一次转动
	local lastValue = false
	if not self.lastPlayTimes_ or self.lastPlayTimes_<1 then
		lastValue = true
	end

	--购买次数
	if not self.configs_ or ((not self.playTimes_ or self.playTimes_<1) and lastValue) then
		if evtName == bm.TouchHelper.TOUCH_BEGIN then
			if self:isEnoughMoney() then
				if self.playTimes_ < 1 and not self.isPlay_ then
					self.id_ = -1--如果购买失败，不为nil，会显示上次中奖结果
					self.ctrl_:buyChance()
					return
				end
			else
				self:alertGotoShop_()
				self:setPlayBtnStyles(1)
				self:callbackPlayFreeNow_(false)
				self.isStop_ = true
				return
			end
		end
	end

    if self.ctrl_:isAllReady() then
        if self.isPlayBtnEnable_ or self.status_ == STATUS_PRESSED then
			if self.status_ == STATUS_UP or self.isPlay_ then
				self:setPlayBtnStyles(1)
				return
			end

			if evtName == bm.TouchHelper.CLICK then
				self.isPlay_ = true
				self.status_ = STATUS_UP
				self:setPlayBtnStyles(1)
			elseif evtName == bm.TouchHelper.TOUCH_END then
				self.isPlay_ = true
				self.status_ = STATUS_UP
				self:setPlayBtnStyles(1)
			elseif evtName == bm.TouchHelper.TOUCH_BEGIN then
				self:startPlay()
			end
		end
    end
end

function LuckWheelFreePopup:startPlay()
	local currentTime = os.time()
	if currentTime - self.playTime_ > 1 then
		self.lastPlayTimes_ = self.playTimes_
		nk.SoundManager:playSound(nk.SoundManager.WHEEL_START)

		self.rotatVal_ = 16 -- 给转盘一个初始化力
		self.id_ = nil
		if not self.isPlay_ then
			self.status_ = STATUS_PRESSED
		end
		
		self:onPlayFreeNow()

		self.isStopTurnLight_ = true
        self.soundId = nk.SoundManager:playSound(nk.SoundManager.WHEEL_LOOP, false)
        self.turnLightNode_:hide()
        self.playTime_ = currentTime
    end
    self:setPlayBtnStyles(2)
end

-- 转盘光效转动
function LuckWheelFreePopup:turnLightEffect_()
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

		local angle = self.turnLightIdx_ * 45 - 22
		self.turnLightNode_:setRotation(angle)
		self.turnLightIdx_ = self.turnLightIdx_ + 1
	end
end

-- 循环
function LuckWheelFreePopup:onLoopCall_()
	if self.isStop_ then
		return
	end

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
function LuckWheelFreePopup:animOverCallback_()
	self.turnLightNode_:stopAllActions()
    self.turnLight2_:setBlendFunc(GL_DST_COLOR, GL_ONE)
    self.turnLight2_:show()
    self.turnLight2_:setRotation(self.turnLight1_:getRotation())
    self.turnLight2_:setScaleY(1)

    local ts1, ts2 = 0.2, 0.1
    self.turnLight2_:runAction(cc.RepeatForever:create(transition.sequence({cc.FadeOut:create(ts1), cc.FadeIn:create(ts2)})))
    self.turnLight1_:runAction(cc.RepeatForever:create(transition.sequence({cc.FadeOut:create(ts2), cc.FadeIn:create(ts1)})))
    self:performWithDelay(handler(self, self.onTurnLightCallback_), 0.32)
end

function LuckWheelFreePopup:onTurnLightCallback_()
	self.turnLight1_:stopAllActions()
	self.turnLight2_:stopAllActions()
	self.turnLight2_:hide()

	self:performWithDelay(function ()
		self.lastPlayTimes_ = nil
        self.isPlay_ = nil
		self.playTime_ = 0
		self:refreshPlayTimes_(self.playTimes_ or 0)

		self:renderPlayBtnStyles_()
    end, 0.01)

	self.countLoop_ = 0
	-- 停止播放转动声音
    if self.soundId then
    	audio.stopSound(self.soundId)
    end

    if self.id_ == -1 then
    	if self.commonAward==2 then
			self:refreshPlayTimes_(self.playTimes_ + 1)
		end
    	nk.TopTipManager:showTopTip("เน็ตของท่านไม่เสถียร รอสักครู่ค่อยลองใหม่นะคะ")
    	return
    end

    -- 播放转盘结束声音
    nk.SoundManager:playSound(nk.SoundManager.WHEEL_END)
	nk.SoundManager:playSound(nk.SoundManager.WHEEL_WIN)

	local item = nil
	if self.commonAward==3 then
		nk.userData.isShowed = true
		LuckWheelFreePopupGetTick = true -- 全局获取自动报名
		local MatchTickOverduePopup = import("app.module.match.MatchTickOverduePopup")
        MatchTickOverduePopup.new():show()
        local particleNode = display.newNode():pos(display.cx, display.cy):addTo(display.getRunningScene(), 9999)
		for i=0,14 do
			local filename = "Particle/luckturn/fx_caidai"..string.format("%02d", i)..".plist"
			local emitter = cc.ParticleSystemQuad:create(filename):addTo(particleNode)
			emitter:setAutoRemoveOnFinish(true)
		end
	else
		item = self:findItemById(self.id_)
		LuckWheelSharePopup.new(item):show()
	end

	-- 本地添加玩家转盘日志
	if self.needrecord==1 then -- 需要记录
		self:addSelfRecordLog_(item)
	end
	if self.commonAward==2 then
		self:refreshPlayTimes_(self.playTimes_ + 1)
	end
end

-- 查找转盘配置信息
function LuckWheelFreePopup:findItemById(id)
    return self.configs_[id + 1]
end

-- 添加监听
function LuckWheelFreePopup:addListener()
	if not self.GetFreeLkWheelRecordId_ then
    	self.GetFreeLkWheelRecordId_ = bm.EventCenter:addEventListener(LuckturnController.GetFreeLkWheelRecord_Event, handler(self, self.onGetFreeLkWheelRecordHandler_))
    end

    if not self.buyChanceId_ then
    	self.buyChanceId_ = bm.EventCenter:addEventListener(LuckturnController.BuyChance_Event, handler(self, self.onBuyChanceHandler_))
    end
end

-- 移除监听
function LuckWheelFreePopup:removeListener()
    if self.GetFreeLkWheelRecordId_ then
		bm.EventCenter:removeEventListener(self.GetFreeLkWheelRecordId_)
		self.GetFreeLkWheelRecordId_ = nil
	end

	if self.buyChanceId_ then
		bm.EventCenter:removeEventListener(self.buyChanceId_)
		self.buyChanceId_ = nil
	end
end

-- 获取到转盘日志数据
function LuckWheelFreePopup:getFreeWheelRecord()
	if not self.recordData_ then
		self:setRecordLoading(true)
		self.ctrl_:getFreeWheelRecord()
		self:updateTouchRect_()
	else
		self:updateTouchRect_()
	end
end

-- 本地添加玩家转盘日志
function LuckWheelFreePopup:addSelfRecordLog_(cfg)
	if not self.recordData_ then
		self.recordData_ = {}
	end
	local item = {}
	item.time = os.time()
	item.uid = nk.userData.uid
	item.nick = nk.userData.nick
	item.sex = nk.userData.sex
	item.img = nk.userData.s_picture

	item.giftResId = cfg.url
	item.reward = cfg.desc

	table.insert(self.recordData_, 1, item)
	self.recordList_:setData(self.recordData_)
	self:refreshCommitTips_()
end

-- 返回转盘日志数据
function LuckWheelFreePopup:onGetFreeLkWheelRecordHandler_(evt)
	self:setRecordLoading(false)
	self.recordData_ = evt.data
	self.recordList_:setData(self.recordData_)
	self:refreshCommitTips_()
end

-- 购买转盘次数回调
function LuckWheelFreePopup:onBuyChanceHandler_(evt)
	local retData = evt.data
	if tostring(retData.code) == "1" then
		local rect = self.playBtn_:getParent():convertToWorldSpace(cc.p(self.playBtn_:getPosition()))
		app:tip(1, -nk.userData.buyLuckWheelChanceMoney, rect.x - 40, rect.y, 9999)

		self:startPlay()
	elseif tostring(retData.code) == "-2" then
		self:alertGotoShop_()
	else		
		nk.TopTipManager:showTopTip(retData.msg)
	end
end

-- 如果日志列表数据为空，则显示提示信息
function LuckWheelFreePopup:refreshCommitTips_()
	if self.recordData_ and #self.recordData_ > 0 then
		self.commintTips_:hide()
	else
		self.commintTips_:show()
	end
end

-- 清理转盘日志数据
function LuckWheelFreePopup:cleanRecordData_()
	self.recordData_ = nil
end      

function LuckWheelFreePopup:setPlayTimesLoading(isLoading)
    if isLoading then
        if not self.juhuaTimes_ then
            self.juhuaTimes_ = nk.ui.Juhua.new()
                :addTo(self.resBg_)
                :pos(142, 20)
            self.juhuaTimes_:setScale(0.6)
        end
    else
        if self.juhuaTimes_ then
            self.juhuaTimes_:removeFromParent()
            self.juhuaTimes_ = nil
        end
    end
end

function LuckWheelFreePopup:setRecordLoading(isLoading)
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
function LuckWheelFreePopup:onCleanup()
	self:removeScheduler_()
	self:removeListener()
	LuckWheelFreePopup.instance_ = nil

	display.removeSpriteFramesWithFile("luckturn_new_texture.plist", "luckturn_new_texture.png")
    nk.schedulerPool:delayCall(function()
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end, 0.1)
    LuckWheelFreePopupGetTick =  nil
end

function LuckWheelFreePopup.load(ctrl, view)
	if not LuckWheelFreePopup.instance_ then
		LuckWheelFreePopup.instance_ = true
		display.addSpriteFrames("luckturn_new_texture.plist", "luckturn_new_texture.png", function()
			LuckWheelFreePopup.instance_ = LuckWheelFreePopup.new(ctrl, view):show()
		end)
	end
end


return LuckWheelFreePopup