--
-- Author: HLF(IdaHuang@boyaa.com)
-- Date: 2016-04-25 17:05:02
-- 现金卡追踪

local ScoreTrackCardExchangePopup = class("ScoreTrackCardExchangePopup", nk.ui.Panel)

ScoreTrackCardExchangePopup.WIDTH = 740
ScoreTrackCardExchangePopup.HEIGHT = 480

local ICON_WIDTH = 140
local ICON_HEIGHT = 140
local AVATAR_TAG = 101
local ICON_BG_DW = 148
local ICON_BG_DH = 148
local BORDER_DH = 160
local BIG_BTN_DW = 180
local BIG_BTN_DH = 55
local SMALL_BTN_DW = 80
local SMALL_BTN_DH = 52
local BIG_BTN_OFFY = 58
local TXT_OFFX = 46

function ScoreTrackCardExchangePopup:ctor(goodsData, ctrl)
	local width, height = ScoreTrackCardExchangePopup.WIDTH, ScoreTrackCardExchangePopup.HEIGHT
	ScoreTrackCardExchangePopup.super.ctor(self, {width+30, height+30})
	self.goodsData_ = goodsData
	self.ctrl_ = ctrl
	-- 
    self.iconLoaderId_ = nk.ImageLoader:nextLoaderId()
    -- 
	local px, py = 0, 0;
    px, py = -width*0.5 + 90, height*0.5 - ICON_BG_DH*0.5 - 15;
    self.pgbg_ = display.newSprite("#sm_good_border1.png")
        :pos(px, py)
        :addTo(self)
    local sz = self.pgbg_:getContentSize()
    local offy = 0;
    self.icon_ = display.newNode()
        :size(ICON_WIDTH,ICON_HEIGHT)
        :pos(px, py - offy)
        :addTo(self);
    -- 游戏logo
    self.logo_ = display.newSprite("#game_logo.png")
        :pos(px, py - offy)
        :addTo(self)
    -- 
    local fontSize = 20
    local offY = 8
    local tipsMsg = bm.LangUtil.getText("SCOREMARKET", "TIPS_DSC_MSG", self.goodsData_.name)
    -- 
    local tipsLblPY = py - sz.height - BORDER_DH*0.5 - 26
    self:addProgress_(px, py)
    -- 
    px = px + sz.width*0.5 + 26
    py = py + sz.height*0.5 - 20
    -- 物品名称
    self.nameTxt_ = ui.newTTFLabel({
    		text=self.goodsData_.name,
    		color=styles.FONT_COLOR.LIGHT_TEXT,
    		size=28,
    		align=ui.TEXT_ALIGN_CENTER
    	})
    	:addTo(self)
    	:pos(px, py)
    self.nameTxt_:setAnchorPoint(cc.p(0, 0.5))
    -- 获取时间
   	self.timeTxt_ = ui.newTTFLabel({
   			text=bm.LangUtil.getText("SCOREMARKET", "RECEIVER_TIME", bm.TimeUtil:getTimeSimpleString(self.goodsData_.create_time, "/", true)),
   			size=22,
   			color=cc.c3b(167, 167, 167),
   			align=ui.TEXT_ALIGN_CENTER
   		})
   		:addTo(self)
    	:pos(px, py-40)
    self.timeTxt_:setAnchorPoint(cc.p(0, 0.5))
    -- 用途
    self.getWayTxt_ = ui.newTTFLabel({
    		text=bm.LangUtil.getText("SCOREMARKET", "GETWAY_TXT", ""),
    		size=22,
    		color=cc.c3b(167, 167, 167),
    		align=ui.TEXT_ALIGN_CENTER
    	})
    	:addTo(self)
    	:pos(px, py - 80)
    self.getWayTxt_:setAnchorPoint(cc.p(0, 0.5))
   	-- 
   	self.tispLbl_ = ui.newTTFLabel({
   			text=tipsMsg,
   			size=fontSize,
   			color=cc.c3b(221, 217, 167),
   			align=ui.TEXT_ALIGN_LEFT,
   			dimensions=cc.size(width-30, 0)
   		})
   		:addTo(self)
   	sz = self.tispLbl_:getContentSize()
    self.tispLbl_:pos(0, tipsLblPY-sz.height*0.5+offY)
    -- 给好评
    local goodLbl = ui.newTTFLabel({
    		text=bm.LangUtil.getText("SCOREMARKET", "BTN_GOOD_TXT"), 
    		size=24, 
    		color=cc.c3b(0xff, 0xff, 0xff), 
    		align=ui.TEXT_ALIGN_CENTER})
    self.goodBtn_ = cc.ui.UIPushButton.new({
    		normal= "#common_btn_green_normal.png",
    		pressed="#common_btn_green_pressed.png"
    	},{scale9 = true})
    	:setButtonSize(BIG_BTN_DW, BIG_BTN_DH)
        :setButtonLabel(goodLbl)
        :onButtonClicked(buttontHandler(self, self.onGoodClickHandler_))
        :pos(0, -height*0.5+BIG_BTN_OFFY)
        :addTo(self)
    bm.fitSprteWidth(goodLbl, BIG_BTN_DW - 10)
    -- 
    self.goodTips_ = ui.newTTFLabel({
        text=bm.LangUtil.getText("SCOREMARKET", "BTN_GOOD_TIPS_TXT"),
        size=18,
        color=styles.FONT_COLOR.LIGHT_TEXT,
        align=ui.TEXT_ALIGN_CENTER
    })
    :pos(0, -height*0.5+BIG_BTN_OFFY-BIG_BTN_DH*0.5-15)
    :addTo(self)
	--  
	self:addCloseBtn()
	self:setCloseBtnOffset(10,5)
    -- 
    self:loadGoodsImg(self.goodsData_.image)
    self:setLoading(true)
    -- wayType：1商城兑换记录，2比赛名次记录
    if self.goodsData_.logid then
        self.ctrl_:getHistoryDetail(self.goodsData_.logid, "2", handler(self, self.onCallbackHistoryDetail_))
    elseif self.goodsData_.cardType and tonumber(self.goodsData_.cardType)==5 and self.goodsData_.point then  -- 流量包
        self:setLoading(false)
        self:renderTrueTips_(self.goodsData_)
        local createTime = bm.getTime()
        local source = bm.LangUtil.getText("SCOREMARKET", "GET_GOODS_WAY_LIST")[1]
         self.timeTxt_:setString(bm.LangUtil.getText("SCOREMARKET", "RECEIVER_TIME", bm.TimeUtil:getTimeSimpleString(createTime or "0", "/", true)))
        self.getWayTxt_:setString(bm.LangUtil.getText("SCOREMARKET", "GETWAY_TXT", " "..source or ""))
    elseif self.goodsData_.orderId and self.goodsData_.orderId_time then  -- 实物
        local params = {}
        params.create_time = self.goodsData_.orderId_time
        params.source = bm.LangUtil.getText("SCOREMARKET", "GET_GOODS_WAY_LIST")[1]
        params.times = {}
        params.status = "1"
        params.checkNo = self.goodsData_.checkNo
        params.expireTime = self.goodsData_.expireTime
        self:onCallbackHistoryDetail_(self.goodsData_.orderId, {data=params})
    else
        self.ctrl_:getHistoryDetail(self.goodsData_.id, "1", handler(self, self.onCallbackHistoryDetail_))
    end
end
-- 
function ScoreTrackCardExchangePopup:renderTrueTips_(retData)
    if tostring(retData.cardType) == "5" then
        local numStr = ""
        local validDay = ""
        if tostring(retData.point) == "100" then
            numStr = "1"
            validDay = "7"
        elseif tostring(retData.point) == "200" then
            numStr = "2"
            validDay = "7"
        elseif tostring(retData.point) == "500" then
            numStr = "3"
            validDay = "15"
        end 
        local tipsMsg = bm.LangUtil.getText("SCOREMARKET", "TRUE_DESC_TIPS", retData.name, numStr, validDay)
        -- fontSize = 18
        offY = 15
        local BORDER_DH_1 = BORDER_DH - 8
        self.tispLbl_:setString(tipsMsg)
        self.goodBtn_:setPositionY(self.goodBtn_:getPositionY() - 3)
        self.goodTips_:setPositionY(self.goodTips_:getPositionY() - 3)
        self.border_:setContentSize(cc.size(ScoreTrackCardExchangePopup.WIDTH-30, BORDER_DH_1))
        self.border_:setPositionY(self.border_:getPositionY() + 3)

        self.cardNumLbl_:hide()
        self.validityLbl_:hide()
    end
end
-- 
function ScoreTrackCardExchangePopup:addProgress_(px, py)
	-- 进度条
	local width, height = ScoreTrackCardExchangePopup.WIDTH, ScoreTrackCardExchangePopup.HEIGHT
    local dw, dh = width - 30, BORDER_DH
    local sz = self.pgbg_:getContentSize()
    self.border_ = display.newScale9Sprite("#sm_dialog_border.png", 0, py-sz.height-10, cc.size(dw, dh))
        :addTo(self)
    -- 
    px, py = TXT_OFFX, dh - 30
    local lbl = ui.newTTFLabel({
    		text=bm.LangUtil.getText("SCOREMARKET", "CARD_LBL"),
    		size=26,
    		color=cc.c3b(194, 178, 215),
    		align=ui.TEXT_ALIGN_CENTER,
    	})
    	:addTo(self.border_)
    lbl:setAnchorPoint(cc.p(0, 0.5))
    lbl:pos(px - TXT_OFFX + 10, py)
    -- PIN码
    py = py - 40
    self.pinCodeLbl_ = ui.newTTFLabel({
    		text=bm.LangUtil.getText("SCOREMARKET", "PIN_CODE_LBL", self.goodsData_.pin),
    		size=20,
    		color=cc.c3b(194, 178, 215),
    		align=ui.TEXT_ALIGN_CENTER,
    	})
    	:addTo(self.border_)
    self.pinCodeLbl_:setAnchorPoint(cc.p(0, 0.5))
    self.pinCodeLbl_:pos(px, py)
    -- 
    local sz = self.pinCodeLbl_:getContentSize()
    local copyLbl = ui.newTTFLabel({
    		text=bm.LangUtil.getText("SCOREMARKET", "COPY"),
    		size=20,
    		color=styles.FONT_COLOR.LIGHT_TEXT,
    		align=ui.TEXT_ALIGN_CENTER,
    	})
    self.copyBtn_ = cc.ui.UIPushButton.new({
    		normal="#common_btn_green_normal.png",
    		pressed="#common_btn_green_pressed.png",
            disabled = "#common_btn_disabled.png",
    	},{scale9=true})
    	:setButtonSize(SMALL_BTN_DW, SMALL_BTN_DH)
    	:setButtonLabel(copyLbl)
    	:onButtonClicked(buttontHandler(self, self.onCopyClickHandler_))
    	:addTo(self.border_)
    self.copyBtn_:pos(px + sz.width + SMALL_BTN_DW*0.5 + 15, py)
    bm.fitSprteWidth(copyLbl, SMALL_BTN_DW)
    -- 有效期
    self.validityLbl_ = ui.newTTFLabel({
    		text="",--bm.LangUtil.getText("SCOREMARKET", "VALIDITY_LBL", bm.TimeUtil:getTimeSimpleString(os.time(), "/", true, true)),
    		size=20,
    		color=cc.c3b(194, 178, 215),
    		align=ui.TEXT_ALIGN_CENTER,
    	})
    	:addTo(self.border_)
    self.validityLbl_:setAnchorPoint(cc.p(1, 0.5))
    self.validityLbl_:pos(width - 80, py)
    -- 卡号
    py = py - 40
    self.cardNumLbl_ = ui.newTTFLabel({
    		text=bm.LangUtil.getText("SCOREMARKET", "CARD_NUM_LBL", ""),
    		size=20,
    		color=cc.c3b(194, 178, 215),
    		align=ui.TEXT_ALIGN_CENTER,
    	})
    	:addTo(self.border_)
    self.cardNumLbl_:setAnchorPoint(cc.p(0, 0.5))
    self.cardNumLbl_:pos(TXT_OFFX, py)
end
-- 
function ScoreTrackCardExchangePopup:show()
	nk.PopupManager:addPopup(self)
	return self
end
-- 
function ScoreTrackCardExchangePopup:close()
	nk.PopupManager:removePopup(self)
	return self
end
-- 
function ScoreTrackCardExchangePopup:onClose()
	self:close()
end
-- 
function ScoreTrackCardExchangePopup:onShowed()

end

function ScoreTrackCardExchangePopup:onRemovePopup(func)
	self:onCleanup()
	func()
end
-- 
function ScoreTrackCardExchangePopup:onCleanup()
    nk.ImageLoader:cancelJobByLoaderId(self.iconLoaderId_)
end
----------------------
function ScoreTrackCardExchangePopup:loadGoodsImg(imgUrl)
    if not imgUrl or string.len(imgUrl) < 10 then
        if CF_DEBUG >= 5 then
            nk.TopTipManager:showTopTip("imgUrl::"..tostring(imgUrl))
        end
        return
    end
    self.icon_:hide();
    nk.ImageLoader:cancelJobByLoaderId(self.iconLoaderId_)
    nk.ImageLoader:loadAndCacheImage(self.iconLoaderId_,
        imgUrl or "",
        function(success, sprite)
            if success then
                self.logo_:hide()
                -- print("success===============")
                self.icon_:show();
                local tex = sprite:getTexture()
                local texSize = tex:getContentSize()
                local oldAvatar = self.icon_:getChildByTag(AVATAR_TAG)
                if oldAvatar then
                    oldAvatar:removeFromParent()
                end
                local iconSize = self.icon_:getContentSize()
                local xxScale = iconSize.width/texSize.width
                local yyScale = iconSize.height/texSize.height
                sprite:scale(xxScale<yyScale and xxScale or yyScale)
                    :addTo(self.icon_, 0, AVATAR_TAG)
                    :pos(0,0)
            else
                -- print("faile===============")
            end
        end,
        nk.ImageLoader.CACHE_TYPE_GIFT
    )
end
-- "给好评" 点击事件
function ScoreTrackCardExchangePopup:onGoodClickHandler_(evt)
    -- 跳转至Googleplay评分
    -- nk.Native:openWebview("https://play.google.com/store/apps/details?id=com.boomegg.nineke");
    device.openURL(nk.userData.commentUrl)
    -- 
    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand{
            command = "event",args = {eventId = "scoremarket_GoodPraise",label = "scoremarket_GoodPraise_Card"}
        }
    end
end
-- 复制
function ScoreTrackCardExchangePopup:onCopyClickHandler_(evt)
    if self.goodsData_ and self.goodsData_.pin then
        nk.Native:setClipboardText(self.goodsData_.pin);
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("SCOREMARKET","COPY_SUCCESS"));
    end
end

-- 获取到详细信息
function ScoreTrackCardExchangePopup:onCallbackHistoryDetail_(gid, retData)
    self:setLoading(false)
    if not gid or not retData then
        return
    end
    -- 
    self.retData_ = retData.data
    -- nk.TopTipManager:showTopTip("self.retData_.cardType::"..tostring(self.retData_.cardType))
    if self.retData_ then
        local createTime = self.retData_.create_time or self.retData_.addtime
        self.timeTxt_:setString(bm.LangUtil.getText("SCOREMARKET", "RECEIVER_TIME", bm.TimeUtil:getTimeSimpleString(createTime or "0", "/", true)))
        self.getWayTxt_:setString(bm.LangUtil.getText("SCOREMARKET", "GETWAY_TXT", " "..self.retData_.source or ""))
        self.validityLbl_:setString(bm.LangUtil.getText("SCOREMARKET", "VALIDITY_LBL", bm.TimeUtil:getTimeSimpleString(self.retData_.expireTime, "/", true, true)))
        self.cardNumLbl_:setString(bm.LangUtil.getText("SCOREMARKET", "CARD_NUM_LBL", self.retData_.checkNo))

        self:renderTrueTips_(self.retData_)
    end
end

function ScoreTrackCardExchangePopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
                :addTo(self)
                :pos(0, 0)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

return ScoreTrackCardExchangePopup