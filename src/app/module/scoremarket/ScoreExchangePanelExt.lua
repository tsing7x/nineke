--
-- Author: HLF
-- Date: 2015-09-29 16:22:57
--
local AnimationIcon    = import("boomegg.ui.AnimationIcon")
local SimpleColorLabel = import("boomegg.ui.SimpleColorLabel")
local ScoreLineCoinsPopup = import(".ScoreLineCoinsPopupExt")
local ScoreExchangePanelExt = class("ScoreExchangePanelExt", function()
	return display.newNode()
end)

ScoreExchangePanelExt.WIDTH = 670
ScoreExchangePanelExt.HEIGHT = 360
local ICON_WIDTH = 140
local ICON_HEIGHT = 140
local AVATAR_TAG = 101
local ICON_BG_DW = 148
local ICON_BG_DH = 148
local DEFAULT_BG_DW = 190
local DEFAULT_BG_DH = 36
local DEFAULT_BG_SIZE = cc.size(DEFAULT_BG_DW, DEFAULT_BG_DH)
local DEFAULT_BG_CAPINS = cc.rect(18, 21, 5, 5)
local DESC_DW = 425

function ScoreExchangePanelExt:ctor(callbackFun, callbackExchangeFun)
    self:setNodeEventEnabled(true)

	self.callbackFun_ = callbackFun
	self.callbackExchangeFun_ = callbackExchangeFun

	local pdw, pdh = ScoreExchangePanelExt.WIDTH, ScoreExchangePanelExt.HEIGHT
	local px, py = 0, 0
    self.exhangePanel_ = display.newNode():pos(px, py):addTo(self)
    self.mainContainer_ = self.exhangePanel_

    -- 背景框
    self.border_ = display.newScale9Sprite("#sm_see_dialog_border.png", 0, 0, cc.size(pdw, pdh))
        :addTo(self.exhangePanel_)

    px, py = -pdw*0.5 + 110, pdh*0.5 - ICON_BG_DH*0.5 - 20
    self.pgbg_ = display.newSprite("#sm_good_border1.png")
        :pos(px, py)
        :addTo(self.exhangePanel_)

    local offy = 0
    self.icon_ = display.newNode()
        :size(ICON_WIDTH,ICON_HEIGHT)
        :pos(px, py - offy)
        :addTo(self)

    -- 游戏logo
    self.animationIcon_ = AnimationIcon.new("#game_logo.png", 1, 1)
        :pos(px, py - offy)
        :addTo(self)

    local offx = 56
    px, py = -50, pdh*0.5 - 38
    self.eNameBg_ = display.newScale9Sprite("#sm_goodname_bg.png", px, py, DEFAULT_BG_SIZE, DEFAULT_BG_CAPINS)
    	:addTo(self.exhangePanel_)

    -- 兑换物品名称
    self.eName_ = ui.newTTFLabel({
		text = "", 
		color = styles.FONT_COLOR.LIGHT_TEXT,
		size = 26, 
		align = ui.TEXT_ALIGN_CENTER
	}):pos(px, py):addTo(self)

    self.desc_ = ui.newTTFLabel({
		text = "",
		color = styles.FONT_COLOR.GOLDEN_TEXT,
		size = 22,
		align = ui.TEXT_ALIGN_LEFT,
		valign = ui.TEXT_VALIGN_TOP,
		dimensions = cc.size(DESC_DW,0)
	})
    :align(display.CENTER_TOP, px+15, py-30)
    :addTo(self)

    local sz = self.desc_:getContentSize()
    self.desc_:pos(px+sz.width*0.5 - offx, py - sz.height*0.5 - 22)

    py = -32
    self.conditionBg_ = display.newScale9Sprite("#sm_goodname_bg.png", px, py, DEFAULT_BG_SIZE, DEFAULT_BG_CAPINS)
    	:addTo(self.exhangePanel_)

    -- 兑换条件
    self.condition_ = ui.newTTFLabel({
		text = bm.LangUtil.getText("SCOREMARKET","EXCHANGE_CONDITION"), 
		color = styles.FONT_COLOR.LIGHT_TEXT,
		size = 26, 
		align = ui.TEXT_ALIGN_CENTER
	}):pos(px, py):addTo(self)

    self.conditionDesc_ = ui.newTTFLabel({
		text = bm.LangUtil.getText("SCOREMARKET","EXCHANGE_CONDITION_DESC"),
		color = styles.FONT_COLOR.GOLDEN_TEXT,
		size = 22,
		align = ui.TEXT_ALIGN_LEFT,
		valign = ui.TEXT_VALIGN_TOP,
		dimensions = cc.size(DESC_DW,0)
	}):pos(px+15, py-30):addTo(self)

    sz = self.conditionDesc_:getContentSize()
    self.conditionDesc_:pos(px+sz.width*0.5 - offx, py - sz.height*0.5 - 30)

    self.px_, self.py_ = px, py
    self.leftCnt_ = ui.newTTFLabel({
		text = bm.LangUtil.getText("SCOREMARKET","EXCHANGE_LEFT_CNT"),
		color = styles.FONT_COLOR.GREY_TEXT,
        size = 22,
        align = ui.TEXT_ALIGN_CENTER,
	}):pos(px+15, py-60):addTo(self)

    sz = self.leftCnt_:getContentSize()
    self.leftCnt_:pos(px+sz.width*0.5 - offx, py - sz.height*0.5 - 30*2)

    self.leftTips_ = ui.newTTFLabel({
        text = bm.LangUtil.getText("SCOREMARKET", "NOTENOUGH_LEFT_CNT"),
        size = 22,
        color = cc.c3b(0x9a, 0, 0),
        align = ui.TEXT_ALIGN_CENTER,
    }):addTo(self):hide()

    sz = self.leftTips_:getContentSize()
    self.leftTips_:pos(px+sz.width*0.5 - offx, py - sz.height*0.5 - 30*2)

    self.alertTip_ = ui.newTTFLabel({
        text = bm.LangUtil.getText("SCOREMARKET","NOTENOUGH_SCORE"),
        color = cc.c3b(0x9a, 0, 0),
        size = 22,
        align = ui.TEXT_ALIGN_CENTER
    }):pos(0, py - 110):addTo(self)

    -- 兑换
    local buttonDw, buttonDh = 210,64
    px, py = 0, -pdh*0.5 - buttonDh*0.0 + 10
    self.exchangeBtn_ = cc.ui.UIPushButton.new({
            normal = "#common_btn_yellow_normal.png", 
            pressed = "#common_btn_yellow_pressed.png"}, 
            {scale9 = true})
        :setButtonSize(buttonDw, buttonDh)
        :setButtonLabel("normal", ui.newTTFLabel({text = bm.LangUtil.getText("SCOREMARKET","EXCHANGE") or "", color = styles.FONT_COLOR.LIGHT_TEXT, size = 42, align = ui.TEXT_ALIGN_CENTER}))
        :pos(px, py)
        :onButtonClicked(buttontHandler(self, self.onExchange_))
        :addTo(self)

    self.returnBtn_ = cc.ui.UIPushButton.new({normal = "#sm_back_btn.png", pressed = "#sm_back_btn_down.png"})
        :addTo(self,11)
        :onButtonClicked(handler(self, self.onback_))
        :pos(-pdw*0.5 - sz.width*0.0, pdh*0.5+sz.height*0.0)

    self.lightBatchNode_ = display.newBatchNode("common_texture.png"):addTo(self,9999)
    self.lightBatchNode_:pos(-200,110)
    self.flashs_ = {}
    for i = 1, 4 do
        self.flashs_[i] = display.newSprite("#sm_flash_star.png")
            :pos(0, 0)
            :addTo(self.lightBatchNode_)
    end

    self:playAnim()
    self.lightBatchNode_:hide()

    self:addLinkUrl_()
end

function ScoreExchangePanelExt:playAnim()
    -- 添加至舞台开始动画
    for i = 1, 4 do
        self.flashs_[i]:runAction(cc.RepeatForever:create(
            transition.sequence({cc.ScaleTo:create(0, 0.9, 0.9), cc.ScaleTo:create(0.15, 1.1, 1.1), cc.ScaleTo:create(0.15, 0.9, 0.9)})
        ))
        self.flashs_[i]:runAction(cc.RepeatForever:create(cc.RotateBy:create(100, 360*1.5)))
    end
end

function ScoreExchangePanelExt:stopAnim()
    for i=1,4 do
        self.flashs_[i]:stopAllActions()
    end
end

function ScoreExchangePanelExt:onCleanup()
    self:stopAnim()
end

function ScoreExchangePanelExt:onback_()
    nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
	if self.callbackFun_ then
		self.callbackFun_()
	end

    self:removeLineCoinNode_()
end

function ScoreExchangePanelExt:onExchange_()
	if self.callbackExchangeFun_ then
		self.callbackExchangeFun_(self.goods_, self.exchangeGoods_)
	end
end

function ScoreExchangePanelExt:show(goods, exchangeGoods)
    self.lightBatchNode_:hide()
	self.goods_ = goods
    self.exchangeGoods_ = exchangeGoods

    self:addRealExchangeInfo_()
    self:isShowLinkUrlLbl_()
    self:addLineCoinsInfo_()

    local sz
    self.eName_:setString(self.goods_.name)
    sz = self.eName_:getContentSize()
    if sz.width > DEFAULT_BG_DW then
        self.eNameBg_:setContentSize(sz.width+10, DEFAULT_BG_DH)
        self.eNameBg_:setPositionX(-50 + (sz.width+10-DEFAULT_BG_DW)*0.5)
        self.eName_:setPositionX(-50 + (sz.width+10-DEFAULT_BG_DW)*0.5)
    else
        self.eNameBg_:setContentSize(DEFAULT_BG_DW, DEFAULT_BG_DH)
        self.eNameBg_:setPositionX(-50)
        self.eName_:setPositionX(-50)
    end

    local offx = 70
    self.desc_:setString(self.goods_.desc)
    sz = self.desc_:getContentSize()
    self.desc_:setPositionX(self.px_+sz.width*0.5 - offx)

    self.conditionDesc_:setString(bm.LangUtil.getText("SCOREMARKET", "EXCHANGE_CONDITION_DESC", self.goods_.score))
    self.leftCnt_:setString(bm.LangUtil.getText("SCOREMARKET","EXCHANGE_LEFT_CNT", self.goods_.lastCount))

    sz = self.conditionDesc_:getContentSize()
    self.conditionDesc_:pos(self.px_+sz.width*0.5 - offx, self.py_ - sz.height*0.5 - 30*1)
    
    sz = self.leftCnt_:getContentSize()
    self.leftCnt_:pos(self.px_+sz.width*0.5 - offx, self.py_ - sz.height*0.5 - 30*2)
    self.leftCnt_:show()
    self.leftTips_:hide()

    if self.goods_.lastCount < 1 then
        self.alertTip_:setString(bm.LangUtil.getText("SCOREMARKET","NOTENOUGH_GOODS"))
        self.alertTip_:show()
        self.exchangeBtn_:hide()
    else
        if nk.userData.score < self.goods_.score then
            self.leftTips_:hide()
            self.alertTip_:setString(bm.LangUtil.getText("SCOREMARKET","NOTENOUGH_SCORE"))
            self.alertTip_:show()
            self.exchangeBtn_:hide()
        else
            self.alertTip_:hide()
            self.exchangeBtn_:show()
        end
    end

    local iconContainer = self.icon_
    local pgbg = self.pgbg_
    local iconSize = iconContainer:getContentSize()
    self.animationIcon_:onData(self.goods_.image, iconSize.width, iconSize.height, function(succ)
        self.lightBatchNode_:show()
    end)
end

function ScoreExchangePanelExt:addLineCoinsInfo_()
    if self.goods_.cardType then
        if self.goods_.cardType == 3 or self.goods_.cardType == 5 then
            local desc = bm.LangUtil.getText("SCOREMARKET", "LINE_COIN_DESC")
            if self.goods_.cardType == 5 then
                desc = bm.LangUtil.getText("SCOREMARKET", "TRUE_DESC_TITLE", self.goods_.point or 100)
            end
            self:addLineCoinsNode_(desc)
        end
    else
        local idx = string.find(string.lower(self.goods_.desc), string.lower("Coins"))
        if idx ~= nil and idx ~= -1 then
            self:addLineCoinsNode_(bm.LangUtil.getText("SCOREMARKET", "LINE_COIN_DESC"))
        end            
    end
end

function ScoreExchangePanelExt:addLineCoinsNode_(desc)
    local topSz = self.conditionBg_:getContentSize()
    local px, py = self.conditionBg_:getPosition()
    py = py + topSz.height*1.0 + 0
    px = px + 286
    self.lineCoinsNode_ = display.newNode()
        :align(display.CENTER_LEFT)
        :pos(px, py)
        :addTo(self.exhangePanel_)

    local lbl = ui.newTTFLabel({
            text =desc,
            color = styles.FONT_COLOR.LIGHT_TEXT,
            size = 18,
            align = ui.TEXT_ALIGN_CENTER
        })
        :addTo(self.lineCoinsNode_)

    local bdw, bdh = 94, 34    
    local btn = cc.ui.UIPushButton.new({normal = "#common_green_btn_up.png", pressed = "#common_green_btn_down.png"}, {scale9=true})
        :setButtonSize(bdw, bdh)
        :pos(-bdw*0.5, 0)
        :setButtonLabel("normal", ui.newTTFLabel({
            text = bm.LangUtil.getText("SCOREMARKET", "LINE_COIN_BTN_LBL"), 
            color = styles.FONT_COLOR.LIGHT_TEXT, 
            size = 22, 
            align = ui.TEXT_ALIGN_CENTER
        }))
        :addTo(self.lineCoinsNode_)
        :onButtonClicked(buttontHandler(self, self.onLineCoinClickHandler_))

    local lsz = lbl:getContentSize()
    lbl:pos(-bdw - lsz.width*0.5, 0)
end

function ScoreExchangePanelExt:removeLineCoinNode_()
    if self.lineCoinsNode_ then
        self.lineCoinsNode_:removeFromParent()
        self.lineCoinsNode_ = nil
    end
end

function ScoreExchangePanelExt:onLineCoinClickHandler_()
    local titleMsg, descList, isUrl
    if self.goods_.cardType == 3 then
        titleMsg = bm.LangUtil.getText("SCOREMARKET", "LINE_COIN_TITLE")
        descList = bm.LangUtil.getText("SCOREMARKET", "LINE_COIN_DESC_LIST")
        isUrl = true
    elseif self.goods_.cardType == 5 then
        titleMsg = bm.LangUtil.getText("SCOREMARKET", "TRUE_DESC_TITLE", self.goods_.point or 100)
        descList = clone(bm.LangUtil.getText("SCOREMARKET", "TRUE_DESC_LIST"))
        if tostring(self.goods_.point) == "100" then
            descList[1] = bm.LangUtil.formatString(descList[1], "1")
            descList[2] = bm.LangUtil.formatString(descList[2], "7", self.goods_.point or 100)
        elseif tostring(self.goods_.point) == "200" then
            descList[1] = bm.LangUtil.formatString(descList[1], "2")
            descList[2] = bm.LangUtil.formatString(descList[2], "7", self.goods_.point or 100)
        elseif tostring(self.goods_.point) == "500" then
            descList[1] = bm.LangUtil.formatString(descList[1], "3")
            descList[2] = bm.LangUtil.formatString(descList[2], "15", self.goods_.point or 100)
        end  
    end

    if titleMsg and descList then
        ScoreLineCoinsPopup.new(titleMsg, descList, isUrl):show() 
    end
end

function ScoreExchangePanelExt:addLinkUrl_()
    local px, py = self.border_:getPosition()
    local sz = self.border_:getContentSize()
    py = py - sz.height*0.5
    px = px + sz.width*0.5
    self.linkUrl_ = display.newNode()
        :pos(px, py)
        :addTo(self.mainContainer_)

    local lbl = ui.newTTFLabel({
        text="เช็ครายละเอียด>>", -- 查看该奖品更多信息
        color=cc.c3b(0xff, 0xff, 0xff),
        size=18,
        align=ui.TEXT_ALIGN_LEFT,
    })
    :addTo(self.linkUrl_)

    sz = lbl:getContentSize()
    px = -sz.width*0.5
    py = -sz.height*0.5
    lbl:pos(px, py)

    local btn = cc.ui.UIPushButton.new({normal = "#transparent.png", pressed = "#transparent.png"}, {scale9=true})
        :setButtonSize(sz.width, sz.height)
        :pos(px, py)
        :addTo(self.linkUrl_)
        :onButtonClicked(buttontHandler(self, self.onlinkUrlTouchHandler_))

    local splitLine = display.newScale9Sprite(
            "#user-info-desc-button-background-up-line.png",
            px, py-12,
            cc.size(sz.width, 2)
        )
        :addTo(self.linkUrl_)
    splitLine:setColor(cc.c3b(0xff, 0xff, 0xff))
end

function ScoreExchangePanelExt:isShowLinkUrlLbl_()
    if self.goods_.link and string.len(self.goods_.link)>0 then
        self.linkUrl_:show()
    else
        self.linkUrl_:hide() 
    end
end

function ScoreExchangePanelExt:onlinkUrlTouchHandler_(evt)
    if self.goods_.link and string.len(self.goods_.link)>0 then
        local url = self.goods_.link
        local sign = self.goods_.name
        nk.OnOff:openSponsorWebView(sign, url)
    end
end

-- 添加查看实物兑换记录显示信息
function ScoreExchangePanelExt:addRealExchangeInfo_()
    local BUTTON_DW, BUTTON_DH = 120, 42
    local leftDH = display.height - 90 - ScoreExchangePanelExt.HEIGHT
    local leftDW = display.width - 240

    local px = leftDW*0.5 - BUTTON_DW*0.5 - 20
    local py = -ScoreExchangePanelExt.HEIGHT*0.5 - leftDH*0.5 + 22
    if not self.exchangeLbl_ then        
        self.exchangeLbl_ = SimpleColorLabel.html(bm.LangUtil.getText("SCOREMARKET", "EXCHANGE_INFO_LBL"), cc.c3b(0xff, 0xff, 0xff), cc.c3b(0xff, 0xff, 0x0), 28):addTo(self.mainContainer_, 1, 1)
        local exchangeLbl = ui.newTTFLabel({
                text=bm.LangUtil.getText("SCOREMARKET", "SEE_BTN_LBL"),
                size=22,
                color=styles.FONT_COLOR.LIGHT_TEXT,
                align=ui.TEXT_ALIGN_CENTER
            })

        self.exchangeSeeBtn_ = cc.ui.UIPushButton.new({
                normal="#common_toptips_button.png",
                pressed="#common_toptips_button_pressed.png",
            },{scale9=true})
            :setButtonLabel(exchangeLbl)
            :setButtonSize(BUTTON_DW, BUTTON_DH)
            :onButtonClicked(buttontHandler(self, self.onExchangeSeeClick_))
            :addTo(self.mainContainer_)
            :pos(px, py)

        bm.fitSprteWidth(exchangeLbl, BUTTON_DW-10)
    end

    if self.goods_.category == "real" then
        self.exchangeLbl_.setString(2,self.goods_.exchanged or "0")
        self.exchangeLbl_:pos(px-self.exchangeLbl_.width - BUTTON_DW*0.5 - 5, py)
        self.exchangeSeeBtn_:pos(px, py)
        self.exchangeSeeBtn_:show()
        self.exchangeLbl_:show()
    else
        self.exchangeSeeBtn_:hide()
        self.exchangeLbl_:hide()
    end
end

function ScoreExchangePanelExt:onExchangeSeeClick_(evt)
    bm.EventCenter:dispatchEvent({name="SEE_REAL_EXCHANGE_LIST", data=self.goods_})
end

return ScoreExchangePanelExt