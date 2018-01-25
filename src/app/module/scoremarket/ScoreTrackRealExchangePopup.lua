--
-- Author: HLF(IdaHuang@boyaa.com)
-- Date: 2016-04-25 10:48:52
-- 实物追踪
local DisplayUtil = import("boomegg.util.DisplayUtil")
local SimpleColorLabel = import("boomegg.ui.SimpleColorLabel")
local ScoreTrackRealExchangePopup = class("ScoreTrackRealExchangePopup", nk.ui.Panel)

ScoreTrackRealExchangePopup.WIDTH = 740
ScoreTrackRealExchangePopup.HEIGHT = 480
local ICON_WIDTH = 140
local ICON_HEIGHT = 140
local AVATAR_TAG = 101
local ICON_BG_DW = 148
local ICON_BG_DH = 148
local BORDER_DH = 160
local BIG_BTN_DW = 180
local BIG_BTN_DH = 55
local SMALL_BTN_DW = 120
local SMALL_BTN_DH = 42
local BIG_BTN_OFFY = 50
local SMALL_BTN_OFFY = 64
local SMALL_BTN_SPACE = 180
local PRO_HEIGHT = 9
local PRO_UNITDW = 190
local TIP_MAX_DW = 326

local STATUS_DOT_RESLIST = {
    "sm_status_red.png",
    "sm_status_green.png",
}

function ScoreTrackRealExchangePopup:ctor(goodsData, ctrl)
	local width, height = ScoreTrackRealExchangePopup.WIDTH, ScoreTrackRealExchangePopup.HEIGHT
	ScoreTrackRealExchangePopup.super.ctor(self, {width+30, height+30})
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
    local tipsLblPY = py - sz.height - BORDER_DH*0.5 - 26
    self:addProgress_(px, py)
    -- 
    px = px + sz.width*0.5 + 26
    py = py + sz.height*0.5 - 20
    -- 物品名称
    self.nameTxt_ = ui.newTTFLabel({
    		text=self.goodsData_.name or "",
    		color=styles.FONT_COLOR.LIGHT_TEXT,
    		size=28,
    		align=ui.TEXT_ALIGN_CENTER
    	})
    	:addTo(self)
    	:pos(px, py)
    self.nameTxt_:setAnchorPoint(cc.p(0, 0.5))
    -- 获取时间
   	self.timeTxt_ = ui.newTTFLabel({
   			text=bm.LangUtil.getText("SCOREMARKET", "RECEIVER_TIME", bm.TimeUtil:getTimeSimpleString(self.goodsData_.create_time or "0", "/", true)),
   			size=22,
   			color=cc.c3b(167, 167, 167),
   			align=ui.TEXT_ALIGN_CENTER
   		})
   		:addTo(self)
    	:pos(px, py-40)
    self.timeTxt_:setAnchorPoint(cc.p(0, 0.5))
    -- 
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
    local str = bm.LangUtil.formatString(bm.LangUtil.getText("SCOREMARKET", "STATUST_TIPS")[1], self.goodsData_.name or "")
   	self.tispLbl_ = ui.newTTFLabel({
   			text=str,
   			size=20,
   			color=cc.c3b(221, 217, 167),
   			align=ui.TEXT_ALIGN_LEFT,
   			dimensions=cc.size(width-30, 0)
   		})
   		:addTo(self)
   	sz = self.tispLbl_:getContentSize()
    self.tispLbl_:pos(0, tipsLblPY-sz.height*0.5+2)
    -- 
    self.mmLbl_ = ui.newTTFLabel({
    		text=bm.LangUtil.getText("SCOREMARKET", "GM_TEL_TXT", "123456789"),
    		color=cc.c3b(142, 208, 121),
    		size=18,
    		align=ui.TEXT_ALIGN_CENTER,
    	})
    	:align(display.CENTER, 0, -height*0.5 + 10)
    	:addTo(self)

    -- 收到奖品按钮
    local receiveLbl = ui.newTTFLabel({
    		text=bm.LangUtil.getText("SCOREMARKET", "BTN_RECEIVER_TXT"), 
    		size=24, 
    		color=cc.c3b(0xff, 0xff, 0xff), 
    		align=ui.TEXT_ALIGN_CENTER})
    self.receiverBtn_ = cc.ui.UIPushButton.new({
    		normal= "#common_btn_green_normal.png",
    		pressed="#common_btn_green_pressed.png"
    	},{scale9 = true})
    	:setButtonSize(BIG_BTN_DW, BIG_BTN_DH)
        :setButtonLabel(receiveLbl)
        :onButtonClicked(buttontHandler(self, self.onReceiverClickHandler_))
        :pos(0, -height*0.5+BIG_BTN_OFFY)
        :addTo(self)
        :hide()
    bm.fitSprteWidth(receiveLbl, BIG_BTN_DW - 10)
    -- 给好评
    local goodLbl = ui.newTTFLabel({
    		text=bm.LangUtil.getText("SCOREMARKET", "BTN_GOOD_TXT"),
    		size=20,
    		color=styles.FONT_COLOR.LIGHT_TEXT,
    		align=ui.TEXT_ALIGN_CENTER
    	})
    self.goodBtn_ = cc.ui.UIPushButton.new({
    		normal="#common_toptips_button.png",
    		pressed="#common_toptips_button_pressed.png"
    	},{scale9 = true})
    	:setButtonSize(SMALL_BTN_DW, SMALL_BTN_DH)
        :setButtonLabel(goodLbl)
        :onButtonClicked(buttontHandler(self, self.onGoodClickHandler_))
        :pos(-SMALL_BTN_SPACE, -height*0.5+SMALL_BTN_OFFY)
        :addTo(self)
    bm.fitSprteWidth(goodLbl, SMALL_BTN_DW - 10)
    self.goodTips_ = ui.newTTFLabel({
    		text=bm.LangUtil.getText("SCOREMARKET", "BTN_GOOD_TIPS_TXT"),
    		size=18,
    		color=styles.FONT_COLOR.LIGHT_TEXT,
    		align=ui.TEXT_ALIGN_CENTER
    	})
    	:pos(-SMALL_BTN_SPACE, -height*0.5+SMALL_BTN_OFFY-SMALL_BTN_DH*0.5-10)
    	:addTo(self)
    bm.fitSprteWidth(self.goodTips_, TIP_MAX_DW)
    -- 上传照片
    local upPicLbl = ui.newTTFLabel({
    		text=bm.LangUtil.getText("SCOREMARKET", "BTN_UP_PIC_TXT"),
    		size=20,
    		color=styles.FONT_COLOR.LIGHT_TEXT,
    		align=ui.TEXT_ALIGN_CENTER
    	})
   	self.upPicBtn_ = cc.ui.UIPushButton.new({
   			normal="#common_red_btn_down.png",
   			pressed="#common_red_btn_up.png",
   		},{scale9=true})
   		:setButtonSize(SMALL_BTN_DW, SMALL_BTN_DH)
        :setButtonLabel(upPicLbl)
        :onButtonClicked(function()
            self:onUpPicClickHandler_()
        end)
        :pos(SMALL_BTN_SPACE, -height*0.5+SMALL_BTN_OFFY)
        :addTo(self)
    bm.fitSprteWidth(upPicLbl, SMALL_BTN_DW - 10)

    self.upPicBonus_ = display.newSprite("#login_btn_fb_reward_icon.png")
        :pos(SMALL_BTN_SPACE, -height*0.5+SMALL_BTN_OFFY+10)
        :addTo(self)
        :scale(0.5)
    self.upPicBonus_:setAnchorPoint(cc.p(0, 0))

    self.upPicTips_ = ui.newTTFLabel({
    		text="อัพโหลดรูปคู่กับรางวัล จะได้รับ 50K ชิปทันที", --bm.LangUtil.getText("SCOREMARKET", "BTN_UP_PIC_TIPS_TXT"),
    		size=18,
    		color=styles.FONT_COLOR.LIGHT_TEXT,
    		align=ui.TEXT_ALIGN_CENTER
    	})
    	:pos(SMALL_BTN_SPACE, -height*0.5+SMALL_BTN_OFFY-SMALL_BTN_DH*0.5-10)
    	:addTo(self)
    bm.fitSprteWidth(self.upPicTips_, TIP_MAX_DW)
    --  
	self:addCloseBtn()
	self:setCloseBtnOffset(10,5)
    -- 
    self:loadGoodsImg(self.goodsData_.image or "")
    self:refreshPrograss_(tostring(self.goodsData_.status or ""))
    -- 
    self:setLoading(true)
    -- wayType：1商城兑换记录，2比赛名次记录
    if self.goodsData_.logid then
        self.ctrl_:getHistoryDetail(self.goodsData_.logid, "2", handler(self, self.onCallbackHistoryDetail_))
    elseif self.goodsData_.orderId and self.goodsData_.orderId_time then
        local params = {}
        params.create_time = self.goodsData_.orderId_time
        params.source = bm.LangUtil.getText("SCOREMARKET", "GET_GOODS_WAY_LIST")[1]
        params.times = {}
        params.status = "1"
        self:onCallbackHistoryDetail_(self.goodsData_.orderId, {data=params})
    else
        self.ctrl_:getHistoryDetail(self.goodsData_.id, "1", handler(self, self.onCallbackHistoryDetail_))
    end
end
-- 
function ScoreTrackRealExchangePopup:addProgress_(px, py)
	-- 进度条
	local width, height = ScoreTrackRealExchangePopup.WIDTH, ScoreTrackRealExchangePopup.HEIGHT
    local dw, dh = width - 30, BORDER_DH + 0
    local sz = self.pgbg_:getContentSize()
    self.border_ = display.newScale9Sprite("#sm_dialog_border.png", 0, py-sz.height-10, cc.size(dw, dh))
        :addTo(self)
    -- 
    px, py = dw*0.5, dh*0.5 + 12
    local leftBar = display.newSprite("#sm_prograss_bar.png")
    	:addTo(self.border_)
    	:pos(px, py)
    local rightBar = display.newSprite("#sm_prograss_bar.png")
    	:addTo(self.border_)
    	:pos(px, py)
    rightBar:setScaleX(-1)
    leftBar:setAnchorPoint(cc.p(1, 0.5))
    rightBar:setAnchorPoint(cc.p(1, 0.5))
    sz = leftBar:getContentSize()
    -- 
    self.progressBar_ = display.newScale9Sprite("#update_proBar.png")
        :pos(px-sz.width+15, py)
        :addTo(self.border_)
        :hide()
    self.progressBar_:setAnchorPoint(0,0.5)
    -- 状态槽位置 1待确认，4待发货，2待收货，3已收货，5完成
    self.posList_ = {
    	{x=px-sz.width+17, y=py, statusID="1", statusedId="11", timekey1="confirm_time", timekey2="confirm_time"},
    	{x=px-sz.width*0.5+55, y=py, statusID="4", statusedId="12", timekey1="delivery_time", timekey2="delivery_time"},
    	{x=px+sz.width*0.5-55, y=py, statusID="2", statusedId="3", timekey1="receive_time", timekey2="receive_time"},
    	{x=px+sz.width-17, y=py, statusID="5", statusedId="5", timekey1="finish_time", timekey2="finish_time"},
    }
    -- 
    self.statusTitle_ = ui.newTTFLabel({
    		text=bm.LangUtil.getText("SCOREMARKET", "GOODS_STATUST_TITLE"),
    		size=26,
    		color=cc.c3b(0xE9, 0xD6, 0xF7),
    		align=ui.TEXT_ALIGN_CENTER
    	})
    	:pos(px, dh-24)
    	:addTo(self.border_)
    --
    self.resList_ = bm.LangUtil.getText("SCOREMARKET", "STATUST_RESLIST")
    self.statusTxts_ = bm.LangUtil.getText("SCOREMARKET", "STATUST_TXT")
    local lsz
    for _,v in ipairs(self.posList_) do
    	-- 
    	v.dot = display.newSprite("#"..STATUS_DOT_RESLIST[1])
    		:pos(v.x, v.y)
    		:addTo(self.border_)
            :hide()

    	-- 状态图标
        v.statusIcon = SimpleColorLabel.addIconText(
                {resId="#"..self.resList_[v.statusID]},
                {text=self.statusTxts_[v.statusID], color=cc.c3b(158,122,228), txtMaxDW=105},
            1)
            :pos(v.x, v.y - 36)
            :addTo(self.border_)

    	-- 状态时间
    	v.time = ui.newTTFLabel({
    			text="",--bm.TimeUtil:getTimeSimpleString(os.time(), "/", true),
    			color=cc.c3b(167, 167, 168),
    			size=20,
    			align=ui.TEXT_ALIGN_CENTER
    		})
    		:pos(v.x, v.y - 64)
    		:addTo(self.border_)
    end
end

-- statusVal 实物订单状态，1待确认，4待发货，2待收货，3已收货，5完成
function ScoreTrackRealExchangePopup:refreshPrograss_(statusVal, timelist)
    local statusList = {0, 0, 0, 0}
    local btnGrayStatus = {true, true, true, true}
    if statusVal == "1" then
        statusList = {1, 0, 0, 0}
        -- isExpensive 为是否昂贵的物品
        if self:isExpensive() then
            self.tispLbl_:setString(bm.LangUtil.formatString(bm.LangUtil.getText("SCOREMARKET", "STATUST_TIPS")[5], self.goodsData_.name or ""))
        else
            self.tispLbl_:setString(bm.LangUtil.formatString(bm.LangUtil.getText("SCOREMARKET", "STATUST_TIPS")[1], self.goodsData_.name or ""))
        end
        btnGrayStatus = {false, true, true, true}
    elseif statusVal == "4" then
        statusList = {2, 1, 0, 0}
        btnGrayStatus = {false, false, true, true}
        self.tispLbl_:setString(bm.LangUtil.formatString(bm.LangUtil.getText("SCOREMARKET", "STATUST_TIPS")[2], self.goodsData_.name or ""))
    elseif statusVal == "2" then
        statusList = {2, 2, 1, 0}
        btnGrayStatus = {false, false, false, true}
        self.tispLbl_:setString(bm.LangUtil.formatString(bm.LangUtil.getText("SCOREMARKET", "STATUST_TIPS")[3], self.goodsData_.name or ""))
    elseif statusVal == "3" then
        statusList = {2, 2, 2, 1}
        btnGrayStatus = {false, false, false, false}
        self.tispLbl_:setString(bm.LangUtil.formatString(bm.LangUtil.getText("SCOREMARKET", "STATUST_TIPS")[4], self.goodsData_.name or ""))
    elseif statusVal == "5" then
        statusList = {2, 2, 2, 2}
        btnGrayStatus = {false, false, false, false}
        self.tispLbl_:setString(bm.LangUtil.formatString(bm.LangUtil.getText("SCOREMARKET", "STATUST_TIPS")[4], self.goodsData_.name or ""))
    else
        statusList = {0, 0, 0, 0}  
    end
    -- 
    local cfg,val
    if self.posList_ then
        for i=1,#statusList do
            val = statusList[i]
            if not self.posList_[i] then
                break
            end
            cfg = self.posList_[i]
            cfg.time:setString("")
            cfg.statusIcon.setColor(2, cc.c3b(0x99, 0x99, 0x99))
            self:setGrayStatus_(cfg.statusIcon, btnGrayStatus[i])
            if val > 1 then
                cfg.statusIcon.setString(2, self.statusTxts_[cfg.statusedId or 1])
                cfg.dot:setSpriteFrame(display.newSpriteFrame(STATUS_DOT_RESLIST[2]))
                cfg.dot:show()
                -- 
                if timelist and timelist[cfg.timekey2] and tonumber(timelist[cfg.timekey2]) > 0 then
                    cfg.time:setString(bm.TimeUtil:getTimeSimpleString(timelist[cfg.timekey2], "/", true))
                    bm.fitSprteWidth(cfg.time, 120)
                end
                cfg.statusIcon.setColor(2, cc.c3b(158,122,228))
            elseif val > 0 then
                cfg.statusIcon.setString(2, self.statusTxts_[cfg.statusID])
                cfg.dot:setSpriteFrame(display.newSpriteFrame(STATUS_DOT_RESLIST[1]))
                cfg.dot:show()
                -- 
                if timelist and timelist[cfg.timekey1] and tonumber(timelist[cfg.timekey1]) > 0 then
                    -- cfg.time:setString(bm.TimeUtil:getTimeSimpleString(timelist[cfg.timekey1], "/", true))
                    cfg.time:setString("")
                    bm.fitSprteWidth(cfg.time, 120)
                end
                cfg.statusIcon.setColor(2, cc.c3b(158,122,228))
            else
                cfg.dot:hide()
            end
        end
    end
    -- 
    self:setBtnStatus_(statusVal)
    self:refreshPrograssBar_(statusVal)
end

-- 实物订单状态，1待确认，4待发货，2待收货，3已收货，5完成
function ScoreTrackRealExchangePopup:refreshPrograssBar_(statusVal)
    if statusVal == self.lastStatusVal_ then
        return
    end
    -- 
    local isAnim = true
    if not self.lastStatusVal_ then
        isAnim = false
    end
    if not self.lastProgressBarDW_ then
        self.lastProgressBarDW_ = 36
    end
    -- 
    local dw = self.lastProgressBarDW_
    self.progressBar_:hide()
    if statusVal == "1" then

    elseif statusVal == "4" then
        self.lastProgressBarDW_ = PRO_UNITDW
        -- self.progressBar_:size(self.lastProgressBarDW_, PRO_HEIGHT)
        self.progressBar_:show()
    elseif statusVal == "2" then
        self.lastProgressBarDW_ = PRO_UNITDW*2
        -- self.progressBar_:size(self.lastProgressBarDW_, PRO_HEIGHT)
        self.progressBar_:show()
    elseif statusVal == "3" then
        self.lastProgressBarDW_ = PRO_UNITDW*3
        -- self.progressBar_:size(self.lastProgressBarDW_, PRO_HEIGHT)
        self.progressBar_:show()
    elseif statusVal == "5" then
        self.lastProgressBarDW_ = PRO_UNITDW*3
        -- self.progressBar_:size(self.lastProgressBarDW_, PRO_HEIGHT)
        self.progressBar_:show()
    else

    end
    -- 
    if isAnim then 
        self:animationProgressBar_(dw, self.lastProgressBarDW_)
    else
        self.progressBar_:size(self.lastProgressBarDW_, PRO_HEIGHT)
    end
    self.lastStatusVal_ = statusVal
end
-- 
function ScoreTrackRealExchangePopup:animationProgressBar_(startDW, endDW)
    if startDW == endDW then
        return
    end
    -- 
    self:addSchedulerPool_()
end
function ScoreTrackRealExchangePopup:onLoopCall_()
    local unitDW = 2
    local sz = self.progressBar_:getContentSize()
    sz.width = sz.width + unitDW
    -- 
    if sz.width > self.lastProgressBarDW_ then
        self:removeSchedulerPool_()
        sz.width = self.lastProgressBarDW_
    end
    -- 
    self.progressBar_:size(sz)
    -- 
    return true
end
-- 
function ScoreTrackRealExchangePopup:addSchedulerPool_()
    if not self.schedulerPool_ then
        self.schedulerPool_ = bm.SchedulerPool.new()
        self.schedulerPool_:loopCall(handler(self, self.onLoopCall_), 0.02)
    end
end
-- 
function ScoreTrackRealExchangePopup:removeSchedulerPool_()
    if self.schedulerPool_ then
        self.schedulerPool_:clearAll()
        self.schedulerPool_ = nil
    end
end
-- 设置按钮显示状态
function ScoreTrackRealExchangePopup:setBtnStatus_(value)
    self.receiverBtn_:hide()
    self.goodBtn_:hide()
    self.upPicBtn_:hide()
    self.upPicBonus_:hide()
    self.upPicTips_:hide()
    self.goodTips_:hide()

    self.goodTips_:setPositionX(-SMALL_BTN_SPACE)
    self.goodBtn_:setPositionX(-SMALL_BTN_SPACE)
    self.upPicTips_:setPositionX(SMALL_BTN_SPACE)
    self.upPicBtn_:setPositionX(SMALL_BTN_SPACE)
    self.upPicBonus_:setPositionX(SMALL_BTN_SPACE)

    if value == "2" then
        self.receiverBtn_:show()
    elseif value == "3" then
        self.goodBtn_:show()
        self.upPicBtn_:show()
        self.upPicBonus_:show()
        self.upPicTips_:show()
        self.goodTips_:show()
    elseif value=="5"  then
        self.goodBtn_:show()
        self.goodTips_:show()
        self.goodBtn_:setPositionX(0)
        self.goodTips_:setPositionX(0)
    end
end
-- 
function ScoreTrackRealExchangePopup:onCleanup()
    nk.ImageLoader:cancelJobByLoaderId(self.iconLoaderId_)
    self:removeSchedulerPool_()
end
-- 
function ScoreTrackRealExchangePopup:onRemovePopup(func)
	self:onCleanup()
	func()
end
-- 
function ScoreTrackRealExchangePopup:onShowed()

end
-- 
function ScoreTrackRealExchangePopup:onClose()
	self:close()
end

function ScoreTrackRealExchangePopup:close()
	nk.PopupManager:removePopup(self)
    return self
end

function ScoreTrackRealExchangePopup:show()
	nk.PopupManager:addPopup(self)
    return self
end
----------------------
function ScoreTrackRealExchangePopup:loadGoodsImg(imgUrl)
    if not imgUrl or string.len(imgUrl) < 10 then
        return
    end
    self.icon_:hide();
    nk.ImageLoader:cancelJobByLoaderId(self.iconLoaderId_)
    nk.ImageLoader:loadAndCacheImage(self.iconLoaderId_,
        imgUrl or "",
        function(success, sprite)
            if success then
                self.logo_:hide()
                print("success===============")
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
-- "我收到奖品" 点击事件
function ScoreTrackRealExchangePopup:onReceiverClickHandler_(evt)
    if not self.retData_ then
        return 
    end
    -- 
    nk.ui.Dialog.new({
    messageText = bm.LangUtil.getText("SCOREMARKET", "CONFIRM_RECEIVER_REWARD"), 
    hasFirstButton = true,
    callback = function (type)
           if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                self:setLoading(true)
                self.ctrl_:updateOrderStatus(self.retData_.orderId, "3", "", handler(self, self.onCallbackUpdateOrderStatus_))
           end
       end
    }):show()
end
-- "给好评" 点击事件
function ScoreTrackRealExchangePopup:onGoodClickHandler_(evt)
    -- 跳转至Googleplay评分
    device.openURL(nk.userData.commentUrl)
    -- 
    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand{
            command = "event",args = {eventId = "scoremarket_GoodPraise",label = "scoremarket_GoodPraise_Real"}
        }
    end
end
-- "上传照片"
function ScoreTrackRealExchangePopup:onUpPicClickHandler_(evt)
    print("ScoreTrackRealExchangePopup:onUpPicClickHandler_(evt)")
    self:setLoading(true)

    self.imageWidth = 414
    self.imageHeight = 236

    local uploadURL = nk.userData.UPLOAD_PIC
    local orderId_ = self.retData_.orderId
    local refreshCallback = handler(self, self.refreshPrograss_)
    local function uploadPictureCallback(evt)
        if evt.name == "completed" then
            local request = evt.request
            local code = request:getResponseStatusCode()
            local ret = request:getResponseString()
            local retTable = json.decode(ret)
            if retTable and retTable.url and retTable.key and retTable.ret and tonumber(retTable.ret) == 0 then
                local imgURL = retTable.url
                bm.HttpService.POST(
                    {
                        mod="Match", act="updateOrderStatus",
                        orderId=orderId_,
                        status="5",
                        img=imgURL,
                    },
                    function(data)
                        self:setLoading(false)
                        local callData = json.decode(data)
                        if callData and callData.ret and callData.ret == 0 then
                            local t = bm.LangUtil.getText("SCOREMARKET", "UPLOAD_PIC_UPLOAD_SUCCESS")
                            nk.TopTipManager:showTopTip(t)

                            self.goodsData_.status = 5
                            self.retData_.status = 5
                            self.retData_.times.finish_time = os.time()

                            if self.goodsData_.refreshRealStatus then
                                self.goodsData_.refreshRealStatus()
                            end

                            if refreshCallback then
                                refreshCallback(tostring(self.retData_.status or ""), self.retData_.times)
                            end

                            nk.ui.Dialog.new({
                                messageText = "ยินดีด้วยค่ะ ท่านได้รับรางวัล 50K ชิป หลังทีมงานตรวจสอบเสร็จ ท่านสามารถเช็ครูปที่บันทึกการแลกได้ค่ะ ",
                                secondBtnText = bm.LangUtil.getText("COMMON", "CONFIRM"),
                                hasFirstButton = false,
                                callback = function (type)
                                       if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                                           
                                       end
                                   end
                            }):show()
                        else
                            local t = bm.LangUtil.getText("SCOREMARKET", "UPLOAD_PIC_UPLOAD_FAIL")
                            nk.TopTipManager:showTopTip(t)
                        end
                    end,
                    function()
                        local t = bm.LangUtil.getText("SCOREMARKET", "UPLOAD_PIC_UPLOAD_FAIL")
                        nk.TopTipManager:showTopTip(t)
                    end)
            else
                local msg = ""
                if retTable and retTable.msg then
                    msg = retTable.msg
                else
                    msg = bm.LangUtil.getText("SCOREMARKET", "UPLOAD_PIC_UPLOAD_FAIL")
                end
                nk.TopTipManager:showTopTip(msg)
                if self.controller_ then
                    self.controller_:onUploadImageResult(false)
                end
            end
        end
    end

    local function pickImageCallback(success, result)
        if success then
            if bm.isFileExist(result) then
                local upload_data = {
                    fileFieldName = "upload", filePath = result,
                    contentType = "image/jpeg",
                    action = "sgjact",
                    extra = {
                        {"mtkey", nk.userData.mtkey},
                        {"skey", nk.userData.skey},
                        {"uid", nk.userData.uid},
                    }
                }

                --设置上传图片
                if self.uploadPic then
                    cc.Director:getInstance():getTextureCache():removeTexture(self.uploadPic:getTexture())
                    self.uploadPic:removeFromParent()
                    self.uploadPic = nil
                end

                local setImageSize = function(width, height, sprite)
                    local sX = width / sprite:getContentSize().width
                    local sY = height/ sprite:getContentSize().height
                    local scale = math.min(sX, sY)
                    sprite:scale(scale)
                end

                self.uploadPic = display.newSprite(result)
                    :pos(self.imageWidth * 0.5, self.imageHeight * 0.5)
                    :addTo(self)
                    :hide()

                setImageSize(self.imageWidth, self.imageHeight, self.uploadPic)
                -- local cb = bm.lime.simple_curry(uploadPictureCallback, result)
                network.uploadFile(uploadPictureCallback, uploadURL, upload_data)
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("SCOREMARKET", "UPLOAD_PIC_PICK_IMG_FAIL"))
            end
        else
            if result == "nosdcard" then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("SCOREMARKET", "UPLOAD_PIC_NO_SDCARD"))
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("SCOREMARKET", "UPLOAD_PIC_PICK_IMG_FAIL"))
            end
        end
    end

    local function onUploadPicClicked()
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
        if device.platform == "android" or device.platform == "ios" then
            nk.Native:pickupPic(pickImageCallback)
        else
            pickImageCallback(true, "E:\\test.png")
        end
    end

    onUploadPicClicked()
end
-- 获取到详细信息
function ScoreTrackRealExchangePopup:onCallbackHistoryDetail_(gid, retData)
    self:setLoading(false)
    if not gid or not retData then
        return
    end
    -- 
    self.retData_ = retData.data
    if self.retData_ then
        local createTime = self.retData_.create_time or self.retData_.times["create_time"]
        self.goodsData_.sendType = self.retData_.sendType
        self.timeTxt_:setString(bm.LangUtil.getText("SCOREMARKET", "RECEIVER_TIME", bm.TimeUtil:getTimeSimpleString(createTime or "0", "/", true)))
        self:refreshPrograss_(tostring(self.retData_.status or ""), self.retData_.times)
        self.getWayTxt_:setString(bm.LangUtil.getText("SCOREMARKET", "GETWAY_TXT", " "..self.retData_.source or ""))
    end
end
-- 获取到“我收到奖品”回调
function ScoreTrackRealExchangePopup:onCallbackUpdateOrderStatus_(orderId, retData)
    self:setLoading(false)
    if not orderId or not retData or not self.retData_ then
        return
    end
    -- 
    self.retData_.status = 3
    self.goodsData_.status = 3
    self.retData_.times.receive_time = os.time()
    self:refreshPrograss_(tostring(self.retData_.status or ""), self.retData_.times)

    -- 
    if self.goodsData_.refreshRealStatus then
        self.goodsData_.refreshRealStatus()
    end
end

-- 获取到“上传照片”回调
function ScoreTrackRealExchangePopup:onCallbackUpPic_(orderId, retData)

end
-- 
function ScoreTrackRealExchangePopup:setGrayStatus_(node, value)
    if value then
        DisplayUtil.setGray(node)
    else
        DisplayUtil.removeShader(node)
    end
end
-- 
function ScoreTrackRealExchangePopup:setLoading(isLoading)
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

-- isExpensive 为是否昂贵的物品
function ScoreTrackRealExchangePopup:isExpensive()
    -- isExpensive 为是否昂贵的物品
    -- sendType  
    -- 0  无
    -- 1  主动联系
    -- 2  上门领取
    if self.goodsData_ and tostring(self.goodsData_.sendType) == "2" and tostring(self.goodsData_.src) == "20"  then
        return true
    else
        return false
    end
end

return ScoreTrackRealExchangePopup
