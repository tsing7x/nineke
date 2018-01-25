local LuckturnController = import("app.module.luckturn.LuckturnController")

local ScoreMarketController = import(".ScoreMarketController")
local ScoreMarketItemExt = import(".ScoreMarketItemExt")
local ScoreMarketRecordItemExt = import(".ScoreMarketRecordItemExt")
local LuckturnMarketItemExt = import(".LuckturnMarketItemExt")
local LuckturnPopup = import("app.module.luckturn.LuckturnPopup")
local AnimUpScrollQueueExt = import("boomegg.ui.AnimUpScrollQueueExt")

local ScoreAddressPopup = import(".ScoreAddressPopup")
local ScorePurchaseDialog = import(".ScorePurchaseDialog")
local ScoreExchangePopup = import(".ScoreExchangePopup")
local ScoreExchangePanelExt = import(".ScoreExchangePanelExt")
local ScoreExchangeSuccessPopup = import(".ScoreExchangeSuccessPopup")

local OtherUserInfoPanel = import("app.module.luckturn.view.OtherUserInfoPanel")
local MatchEventHandler = import("app.module.match.MatchEventHandler")
local ScoreRewardPopup = import(".ScoreRewardPopup")
local ScoreExchangeSuccPopup = import(".ScoreExchangeSuccPopup")
local ScoreTrackCardExchangePopup = import(".ScoreTrackCardExchangePopup")
local ScoreTrackRealExchangePopup = import(".ScoreTrackRealExchangePopup")
local ScoreMarketViewExt = class("ScoreMarketViewExt", function ()
    return display.newNode()
end)

local TYPE1 = "bag"
local TYPE2 = "12call"
local TYPE3 = "linecoins"
local TYPE6 = "real"
local TYPE7 = "sponsor"
local TYPE_REAL_LOG = "reallog"
local TYPE_ALL = ""

ScoreMarketViewExt.HOT_ICON_RESID = "#lineCoins_hot.png"
ScoreMarketViewExt.NEW_ICON_RESID = "#lineCoins_hot.png"
ScoreMarketViewExt.SALE_ICON_RESID = "#scoremarket_saleIcon1.png"
ScoreMarketViewExt.SALE_ICON_RESID2 = "#scoremarket_saleIcon2.png"

local TOP_BAR_DH = 92
local GOODS_LIST_DH = 520
local AWARD_LIST_DH = 496
local LEFT_TAB_BTN_DW = 210
local LEFT_TAB_BTN_DH = 75
local LEFT_BAR_DW = 246
local BUTTON_DW, BUTTON_DH = 136,52
local CHECKBOX_DW = 186
local CHECKBOX_DH = 48
local CHECKBOX_CAPINSET = cc.rect(CHECKBOX_DH, CHECKBOX_DH*0.5, 5, 5)
local CHECKBOX_SIZE = cc.size(CHECKBOX_DW,CHECKBOX_DH)

ScoreMarketViewExt.ISHTML5 = nk.userData.isOpenShopH5 == 1 and true or false

function ScoreMarketViewExt:ctor(subIndex, tabIndex)
    self.isShowed_ = false
    bm.EventCenter:addEventListener(nk.eventNames.SCORE_MARKET_EXCHANGE, handler(self, self.rechangeGoods))
    bm.EventCenter:addEventListener("ScoreMarketRecord_Info", handler(self, self.onRecordDetailInfo_))
    bm.EventCenter:addEventListener("ScoreMarketRecord_FOCUS", handler(self, self.onRecordFocusHandler_))
    bm.EventCenter:addEventListener("SEE_REAL_EXCHANGE_LIST", handler(self, self.onSeeRealExchangeListHandler_))
    self.ctrl_ = ScoreMarketController.new(self)
    self.ctrlLW_ = LuckturnController.new(self)
    self.prevIndex_ = nil
    self.prevSubIndex_ = nil
    self.index_ = tabIndex or 1
    self.subIndex_ = subIndex or 1

    local width, height = display.width, display.height
    self.mainContainer_ = display.newNode():addTo(self)
    self.mainContainer_:setContentSize(width,height)
    self.mainContainer_:setTouchEnabled(true)
    self.mainContainer_:setTouchSwallowEnabled(true)

	self:setNodeEventEnabled(true) -- 框架直接执行 onCleanup
	self:init_(subIndex)
    self:exchangeTabStyle_(self.index_)
end

function ScoreMarketViewExt:show(hallCtrl, viewType)
    self.hallCtrl_ = hallCtrl
    self.viewType_ = viewType
    

    local useShowAnimation = false
    nk.PopupManager:addPopup(self, true, true, false, useShowAnimation)
    if not useShowAnimation then
        self:onShowed()
    end

    self.mainContainer_:setAnchorPoint(cc.p(0.5, 0.5))

    return self
end

function ScoreMarketViewExt:init_(subIndex)
    -- 背景
    local leftDw = display.width - LEFT_BAR_DW
    local unitDw = leftDw / 3 - 20
    ScoreMarketItemExt.WIDTH = unitDw
    LuckturnMarketItemExt.WIDTH = unitDw
    ScoreMarketRecordItemExt.WIDTH = leftDw - 10

    local blurBg = display.newSprite("hall_blur_bg.png")
        :pos(display.cx, display.cy)
        :addTo(self.mainContainer_)
    local sx, sy = display.width / 96, display.height / 64
    blurBg:setScaleX(sx)
    blurBg:setScaleY(sy)
    
    self:createLeftBar_(subIndex)

    self:createTopTabs_()

    -- 创建赞助商提示
    self:createSponsored()

    self.isbigLaBaList_ =self:addUpScrollQueue()
    self.cpx_ = LEFT_BAR_DW
    local cpy = 520-30
    self.cpy_ = cpy
    cpy = cpy - 22
    if self.isbigLaBaList_ then
        self.sponsoredBar_:hide()
    end

    -- 内容背景
    self.contentBg_ = display.newScale9Sprite("#common_transparent_skin.png",0,0,cc.size(705, 480))
        :align(display.LEFT_TOP)
        :pos(self.cpx_, cpy)
        :addTo(self.mainContainer_)

    local topSz = self.topBg_:getContentSize()
    px, py = LEFT_BAR_DW + BUTTON_DW*0.5 + 12, display.height - topSz.height*0.5    

    self.addressBtn_ = cc.ui.UIPushButton.new({
            normal = "#common_btn_green_normal.png", 
            pressed = "#common_btn_green_pressed.png"}, 
            {scale9 = true})
        :setButtonSize(BUTTON_DW, BUTTON_DH)
        :setButtonLabel("normal", ui.newTTFLabel({text = bm.LangUtil.getText("SCOREMARKET", "RECEIVE_ADDRESS") or "", color = styles.FONT_COLOR.LIGHT_TEXT, size = 32, align = ui.TEXT_ALIGN_CENTER}))
        :pos(px, py)
        :onButtonClicked(handler(self, self.onOpenAddressPopup_))
        :addTo(self.mainContainer_,100)    
    if BM_UPDATE.SHOWEXCHANGE and BM_UPDATE.SHOWEXCHANGE == 0 then
        self.addressBtn_:hide()
    end

    self:createList_()
    -- 点击物品后的展示框
    py = (display.height - topSz.height)*0.5+22
    self.exhangePanel_ = ScoreExchangePanelExt.new(function()
            self:showExchangePanel(false)
        end,handler(self,self.callbackScoreExchangePanelExt)):pos(px, py):addTo(self.contentBg_):hide() 

    -- 回退按钮
    self.backBtn_ = cc.ui.UIPushButton.new({normal = "#sm_close2.png"})
        :pos(display.width - 42, display.top-42)
        :addTo(self.mainContainer_,999)
        :onButtonClicked(function()
            nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
            self:onReback()
        end)

    self:flushMyScore()
    self.isInit_ = true

    -- 真正请求数据
    self.isInit_ = false
    self.svrBroadcatBigLabaId_ = bm.EventCenter:addEventListener(nk.eventNames.SVR_BROADCAST_BIG_LABA, handler(self, self.onSvrBroadcastBigLaBaHandler_))
    if not self.scoreId_ then
        self.scoreId_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "score", handler(self,self.flushMyScore))
    end

    nk.UserInfoChangeManager:reg(nk.UserInfoChangeManager.ScoreMarket, {"score"}, handler(self, self.getTargetIconPosition_), handler(self,self.flushMyScore))
end

function ScoreMarketViewExt:createLeftBar_(subIndex)
    -- 左边 背景
    self.leftBg_ = display.newScale9Sprite(
            "#sm_left_bg.png",
            0,0,cc.size(LEFT_BAR_DW, display.top)
        )
        :align(display.BOTTOM_LEFT)
        :addTo(self.mainContainer_)
    self.leftBgTex_ = display.newTilesSprite(
            "repeat/panel_repeat_tex.png",
            cc.rect(0, 0, LEFT_BAR_DW - 3, display.top - 3)
        )
        :pos(-10, 0)
        :addTo(self.leftBg_)

    self.logo_ = display.newSprite("#sm_logo.png"):addTo(self.leftBg_)
    local sz = self.logo_:getContentSize()
    local px, py = LEFT_BAR_DW*0.5 - 10, display.top - sz.height*0.5 + 15
    self.logo_:pos(px, py)
    -- 积分展示
    local dw, dh = 32, 32
    self.scoreBg_  = display.newScale9Sprite(
            "#sm_score_ bg.png",
            px, 
            py-sz.height*0.5,
            cc.size(320, dh),
            cc.rect(dw,dh, 5, 1)
        )
        :addTo(self.leftBg_)
    self.scoreWord_ = ui.newTTFLabel({text=bm.LangUtil.getText("MATCH", "SCORE")..":", size=22, color=cc.c3b(0xff, 0xa6, 0x00)})
        :align(display.BOTTOM_LEFT)
        :addTo(self.scoreBg_)
        :pos(dw,0)
    self.score_ = ui.newTTFLabel({text=tostring(nk.userData.score), size=22, color=cc.c3b(0x93, 0xdd, 0x42)})
        :align(display.BOTTOM_LEFT)
        :addTo(self.scoreBg_)
        :pos(120,0)

    -- text为左边Tab的名称，data1为物品列表，data2为兑换记录，type为类型
    self.subTabs_ = {
        self:createSubTabsCfg(bm.LangUtil.getText("SCOREMARKET", "SUBTAB1"), TYPE1),
        self:createSubTabsCfg(bm.LangUtil.getText("SCOREMARKET", "SUBTAB2"), TYPE2),
        self:createSubTabsCfg(bm.LangUtil.getText("SCOREMARKET", "SUBTAB6"), TYPE6),
    }

    if nk.userData.mallSponsor==1 then
        local itemSubTab = self:createSubTabsCfg(bm.LangUtil.getText("SCOREMARKET", "SUBTAB7"), TYPE7, ScoreMarketViewExt.NEW_ICON_RESID)
        table.insert(self.subTabs_, itemSubTab)

        if nil == subIndex then
            self.subIndex_ = #self.subTabs_
        end
    end

    local len = #self.subTabs_ - 1
    dw,dh = LEFT_TAB_BTN_DW, LEFT_TAB_BTN_DH
    resId = "#common_transparent_skin.png"
    self.subGroup_ = cc.ui.UICheckBoxButtonGroup.new(display.TOP_TO_BOTTOM)
        :pos(115, py - 50)
        :addTo(self.leftBg_)

    -- 左边Tab选中状态
    self.selectIcon_ = display.newSprite("#sm_tab_selected.png")
        :pos(dw*0.5,dh*0.5 + 3*(dh+6))
        :addTo(self.subGroup_, 0)
    self.subGroup_:onButtonSelectChanged(handler(self, self.onSubGroupChangeHandler_))

    for i=1, #self.subTabs_ do
        local itemCfg = self.subTabs_[i]
        if nil ~= itemCfg then
            local chkBox = cc.ui.UICheckBoxButton.new({off=resId, on=resId}, {scale9 = true})
                :setButtonLabelAlignment(ui.TEXT_ALIGN_CENTER)
                :setButtonLabelOffset(0, 0)
                :setButtonSize(dw, dh+5)
                :align(display.LEFT_BOTTOM)

            local itemBg = display.newScale9Sprite("#sm_tab_unselect.png", dw*0.5, dh*0.5, cc.size(dw-10, dh-12), cc.rect(20, 32, 5, 5))
                :addTo(chkBox)

            local lbl = ui.newTTFLabel({
                    text=itemCfg.text,
                    size=28,
                    color=cc.c3b(0xa3, 0x6c, 0xb7),
                    align=ui.TEXT_ALIGN_CENTER,
                })
                :pos(dw*0.5, dh*0.5)
                :addTo(chkBox, 99)
            itemCfg.bg = itemBg
            itemCfg.lbl = lbl
            bm.fitSprteWidth(lbl, 128)

            if itemCfg.iconRes then
                itemCfg.hotIcon = display.newSprite(itemCfg.iconRes)
                    :pos(dw-0, dh*0.5)
                    :addTo(chkBox, 999)
            end

            self.subGroup_:addButton(chkBox, 2)
        end
    end

    self.subGroup_:pos(LEFT_BAR_DW*0.5 - dw*0.5, 105)

    -- 定位到当前位置
    self.selectIcon_:pos(dw*0.5,dh*0.5 + 3*(dh+6) - (self.subIndex_-1)*(dh+6))
end

function ScoreMarketViewExt:onSubGroupChangeHandler_(event)
    local dw,dh = LEFT_TAB_BTN_DW, LEFT_TAB_BTN_DH
    -- 赞助子项目
    if self.subGroup2_ then
        self.subGroup2_:hide()
    end
    self.sponsoredBar_:hide()

    if self.index_ == 2 and self.group_.currentSelectedIndex_ == 1 and self.returnBtn_:isVisible() then
        self:cleanLogBack_()
    end

    self.subIndex_ = event.selected
    self:setLeftTabStatus_(self.subIndex_)
    local px, py = dw*0.5, dh*0.5 + 3*(dh+6) - (self.subIndex_-1)*(dh+6)
    if self.isShowed_ then
        if self.isClickSubTabs_ then
            nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
        else
            self.isClickSubTabs_ = true 
        end

        self.selectIcon_:stopAllActions()
        transition.moveTo(self.selectIcon_, {
            time   = 0.22,
            x      = px,
            y      = py,
            easing = "BACKOUT",
            onComplete = function()
                self:dealShow()
                self.awardList_:update()
            end
        })
    else
        self:dealShow()
    end

    self:addCardSendTimeTips_()
end

-- 左边Tab Button选中状态的切换
function ScoreMarketViewExt:setLeftTabStatus_(index)
    local len = #self.subTabs_
    if len < index then
        return
    end

    local item
    for i=1,len do
        item = self.subTabs_[i]
        if item.bg or item.lbl then
            if i ~= index then
                item.bg:show()
                item.lbl:setTextColor(cc.c3b(0xa3, 0x6c, 0xb7))
            else
                item.bg:hide()
                item.lbl:setTextColor(styles.FONT_COLOR.LIGHT_TEXT)
            end
        end
    end
end

function ScoreMarketViewExt:createTopTabs_()
    local dw, dw
    local leftBarDw = LEFT_BAR_DW - 12
    self.topBg_ = display.newScale9Sprite(
            "#sm_top_bg.png",
            0,0,cc.size(display.width-leftBarDw, TOP_BAR_DH)
        )
        :align(display.LEFT_TOP)
        :pos(leftBarDw, display.top)
        :addTo(self.mainContainer_, 99)
    self.topBgTex_ = display.newTilesSprite(
            "repeat/panel_repeat_tex.png",
            cc.rect(0, 0, display.width-leftBarDw - 3, TOP_BAR_DH -3)
        )
        :pos(0, 5)
        :addTo(self.topBg_)
    -- 
    local goodsRes = {off = "#rounded_rect_6.png", on = "#rounded_rect_6.png"}
    local recordRes = {off = "#rounded_rect_6.png", on = "#rounded_rect_6.png"}
    dw,dh = 585 - 120,58
    local offx = 40
    if BM_UPDATE.SHOWEXCHANGE and BM_UPDATE.SHOWEXCHANGE == 0 then
        offx = 0
    end

    self.groupBg_ = display.newScale9Sprite("#sm_group_tab_bg.png", 0, 0, cc.size(dw,dh))
        :pos((display.width-leftBarDw)*0.5 + offx, TOP_BAR_DH*0.5)
        :addTo(self.topBg_)
    dw,dh = 290 - 60, 52
    self.leftTabSpr_ = display.newScale9Sprite("#sm_group_tab_btn_bg.png", 0, 0, cc.size(dw, dh))
        :pos(dw*0.5+2, dh*0.5 + 3)
        :addTo(self.groupBg_, 1)        
        :hide()
    self.rightTabSpr_ = display.newScale9Sprite("#sm_group_tab_btn_bg.png", 0, 0, cc.size(dw, dh))
        :pos(dw*1.5+2, dh*0.5 + 3)
        :addTo(self.groupBg_, 1)
    self.rightTabSpr_:setScaleX(-1)
    self.leftTabIcon_ = display.newSprite("#sm_goods1.png")
        :pos(dw*0.0+40, dh*0.5 + 3)
        :addTo(self.groupBg_, 3)
    self.rightTabIcon_ = display.newSprite("#sm_record2.png")
        :pos(dw*1.0+40, dh*0.5 + 3)
        :addTo(self.groupBg_, 3)

    self.recordRect_ = self.groupBg_:convertToWorldSpace(cc.p(self.rightTabIcon_:getPosition()))

    dw,dh = 293 - 60, 56
    local resId = "#common_transparent_skin.png"
    self.group_ = cc.ui.UICheckBoxButtonGroup.new()--display.TOP_TO_BOTTOM
        :addButton(cc.ui.UICheckBoxButton.new({off=resId, on=resId}, {scale9 = true})
            :setButtonLabel(cc.ui.UILabel.new({text = bm.LangUtil.getText("SCOREMARKET", "TAB1"), size = 28, color = cc.c3b(0xff, 0xff, 0xff)}))
            :setButtonLabelAlignment(ui.TEXT_ALIGN_CENTER)
            :setButtonLabelOffset(25, 0)
            :setButtonSize(dw,dh)
            :align(display.LEFT_CENTER))
        :addButton(cc.ui.UICheckBoxButton.new({off=resId, on=resId}, {scale9 = true})
            :setButtonLabel(cc.ui.UILabel.new({text = bm.LangUtil.getText("SCOREMARKET", "TAB2"), size = 28, color = cc.c3b(0xff, 0xff, 0xff)}))
            :setButtonLabelAlignment(ui.TEXT_ALIGN_CENTER)
            :setButtonLabelOffset(24, 0)
            :setButtonSize(dw,dh)
            :align(display.LEFT_CENTER))
        :onButtonSelectChanged(handler(self, self.onGroupSelectChanged_))
        :pos(0,-13)
        :addTo(self.groupBg_, 2)
end

-- 创建列表
function ScoreMarketViewExt:createList_()
    local listWidth  = 705 - 20 + (ScoreMarketItemExt.WIDTH - 205)*3
    GOODS_LIST_DH = GOODS_LIST_DH + (display.height - TOP_BAR_DH - GOODS_LIST_DH - 28) -- (display.height - TOP_BAR_DH - GOODS_LIST_DH - 28) 为高比屏上的修正值
    -- 创建list    
    local leftSz = self.leftBg_:getContentSize()
    local topSz = self.topBg_:getContentSize()
    local leftDw = (display.width - leftSz.width)
    local leftDh = (display.height - topSz.height)
    px, py = leftDw*0.5+0, leftDh*0.5+5
    self.goodsList_ = bm.ui.ListView.new(
            {
                viewRect = cc.rect(-listWidth * 0.5, -GOODS_LIST_DH * 0.5, listWidth, GOODS_LIST_DH)
            }, 
            ScoreMarketItemExt
        )
        :pos(px, py)
        :addTo(self.contentBg_)
    -- 
    py = py - 20
    AWARD_LIST_DH = AWARD_LIST_DH + (display.height - TOP_BAR_DH - AWARD_LIST_DH - 52)
    self.awardList_ = bm.ui.ListView.new({
                viewRect = cc.rect(-listWidth * 0.5-0, -AWARD_LIST_DH * 0.5, listWidth+0, AWARD_LIST_DH),
                upRefresh = handler(self, self.onUpRecodeList_)
            }, ScoreMarketRecordItemExt
        )
        :pos(px, py)
        :addTo(self.contentBg_)
    self.awardList_:addEventListener("ITEM_EVENT", handler(self, self.onItemEvent_))
    -- 查看全部记录复选框
    local cpx, cpy = CHECKBOX_DW*0.5 + 3, display.top - topSz.height - 12
    self.checkNode_ = display.newNode()
        :pos(cpx, cpy)
        :addTo(self.contentBg_)
    -- bg
    self.checkBox_ = display.newScale9Sprite("#sm_checkBox_up.png", 0, 0, CHECKBOX_SIZE, CHECKBOX_CAPINSET)
        :addTo(self.checkNode_)
    -- icon
    self.checkBoxIcon_ = display.newSprite("#sm_checkBoxIcon.png")
        :pos(-CHECKBOX_DW*0.5 + 26, 2)
        :addTo(self.checkNode_)
    self.checkBoxIcon_:hide()
    -- lbl
    self.checkLbl_ = ui.newTTFLabel({
            text=bm.LangUtil.getText("SCOREMARKET", "CHECKBOX_TEXT"),
            size=22,
            align=ui.TEXT_ALIGN_CENTER,
            color=cc.c3b(222, 194, 254)
        })
        :pos(21, 0)
        :addTo(self.checkNode_)
    bm.fitSprteWidth(self.checkLbl_, 138)
    bm.TouchHelper.new(self.checkNode_, handler(self, self.onCheckBoxHandler_))
    self.checkNode_:hide()
    -- 
    self.returnBtn_ = cc.ui.UIPushButton.new({normal = "#sm_back_btn.png", pressed = "#sm_back_btn_down.png"})
        :addTo(self.contentBg_,11)
        :onButtonClicked(handler(self, self.onExchangeLogBack_))
        :scale(0.9)
        :hide()
    sz = self.returnBtn_:getCascadeBoundingBox()
    self.returnBtn_:pos(26, cpy + 2)

    -- 添加“查看全部记录”
    local itemSubTab
    itemSubTab = self:createSubTabsCfg("", TYPE_ALL)
    table.insert(self.subTabs_, itemSubTab)
    -- CheckBox的选中状态
    self.checkStatus_ = false
    -- 某一个实物的兑换日志
    itemSubTab = self:createSubTabsCfg("", TYPE_REAL_LOG)
    table.insert(self.subTabs_, itemSubTab)
    -- 暂未开放
    self.commintTxt_ = ui.newTTFLabel({text=bm.LangUtil.getText("SCOREMARKET", "COMMINGTIPS"), size=34, color=cc.c3b(0xff, 0xff, 0xff),dimensions=cc.size(695,300)})
        :addTo(self.contentBg_)
        :pos(px,py)
    self.commintTxt_:setVisible(false)
    self.recordTxt_ = ui.newTTFLabel({text=bm.LangUtil.getText("SCOREMARKET", "NORECORD"), size=34, color=cc.c3b(0xff, 0xff, 0xff)})
        :addTo(self.contentBg_)
        :pos(px,py)
    self.recordTxt_:setVisible(false) 

    self.checkClickTime_ = 0
end

function ScoreMarketViewExt:onItemEvent_(evt)
    if evt.type == "ShowOtherUserDetail" then
        local evtData = evt.data
        local uid = evtData.uid
        OtherUserInfoPanel.new(self.ctrlLW_):show(uid, evtData)
    end
end

-- 设置复选框样式
function ScoreMarketViewExt:setCheckBoxSpriteFrame_(value)
    local resId = "sm_checkBox_down.png"
    if value then
        resId = "sm_checkBox_up.png"   
    end
    self.checkBox_:setSpriteFrame(display.newSpriteFrame(resId))
    self.checkBox_:setContentSize(CHECKBOX_SIZE)
    self.checkBox_:setCapInsets(CHECKBOX_CAPINSET)
end

function ScoreMarketViewExt:cancelCheckBoxStatus_()
    self.checkStatus_ = false
    self.checkBoxIcon_:setVisible(self.checkStatus_)
    self:setCheckBoxSpriteFrame_(true)
end

-- 复选框触摸事件
function ScoreMarketViewExt:onCheckBoxHandler_(obj, evtName)
    local currentTime = bm.getTime()
    if currentTime - self.checkClickTime_ > 0.5 then
        if evtName == bm.TouchHelper.TOUCH_BEGIN then
            self:setCheckBoxSpriteFrame_(false)
            self.checkBoxIcon_:setVisible(not self.checkStatus_)
        elseif evtName == bm.TouchHelper.TOUCH_END then
            self:setCheckBoxSpriteFrame_(true)
            self.checkBoxIcon_:setVisible(self.checkStatus_)
        elseif evtName == bm.TouchHelper.CLICK then
            self:setCheckBoxSpriteFrame_(true)
            self.checkStatus_ = not self.checkStatus_
            self.checkBoxIcon_:setVisible(self.checkStatus_)
            if 2 == self.index_ then
                self:dealShow(true)
                self.awardList_:update()
            end
            self.checkClickTime_ = currentTime
        end
    end
end

function ScoreMarketViewExt:openScoreExchangePopup_(goods, addressData)
    -- isExpensive 为是否昂贵的物品
    -- sendType  
    -- 0  无
    -- 1  主动联系
    -- 2  上门领取
    local isExchangeShop = 0
    if goods and goods.sendType == 2  then
        isExchangeShop = 1
    end
    ScoreExchangePopup.new(self.ctrl_, goods, addressData,  handler(self, self.onExchange_), handler(self, self.onOpenAddressPopup_), isExchangeShop):show()
end

-- 点击“兑换”弹出的确认框
function ScoreMarketViewExt:callbackScoreExchangePanelExt(goods, exchangeGoods)
    if goods.category == TYPE6 or goods.category == TYPE7 then
        self:showExchangePanel(false)
        -- 判断收货地址是否填写
        self.ctrl_:getMatchAddress1(function(params)
            self:openScoreExchangePopup_(goods)
        end)
    else
        local params = {}
        params.messageText = bm.LangUtil.getText("SCOREMARKET", "RECHANGECONFIRM",goods.score,goods.name)
        params.callback = function(type)
            if type == 2 then
                -- 请求奖励
                if self.ctrl_ then
                    self:setLoading(true)
                    local itemCfg = self.subTabs_[self.subIndex_]
                    self.ctrl_:exchangeGoods(goods, itemCfg)
                end
                self:showExchangePanel(false)
            end
        end
        ScorePurchaseDialog.new(params):show()
    end
end

-- 请求PHP兑换某一物品
function ScoreMarketViewExt:onExchange_(goods)
    local itemCfg = self.subTabs_[self.subIndex_]
    self.ctrl_:exchangeGoods(goods, itemCfg)
end

function ScoreMarketViewExt:onOpenAddressPopup_(evt, goods)
    ScoreAddressPopup.new(self.ctrl_):show(function(addressData)
        if goods then
            self:openScoreExchangePopup_(goods, addressData)
        end
    end)
end

function ScoreMarketViewExt:showExchangePanel(isShow)
    self.goodsList_:setVisible(not isShow)
    self.exhangePanel_:setVisible(isShow)
    -- 赞助商
    if self.subGroup2_ then
        self.subGroup2_:hide()
        if self.index_ == 1 and not isShow then
            local type7Index_ = nil
            for k,v in ipairs(self.subTabs_) do
                if v.type==TYPE7 then
                    type7Index_ = k
                    break
                end
            end
            if self.subIndex_==type7Index_ then
                self.subGroup2_:show()
            end
        end
    end
end

function ScoreMarketViewExt:onExchangeGoods(data,tips,goods)
    if data then
        local func = function()
            self.index_ = 2
            self.group_:getButtonAtIndex(self.index_):setButtonSelected(true)
            self:dealShow()
        end

        ScoreExchangeSuccPopup.new(data,goods,func, self.recordRect_):show()
        self:umengStatication(2, goods)

        nk.userData.money = nk.userData.money + tonumber(data.chips or 0)
        if not nk.userData.hddjNum then
            nk.userData.hddjNum = 0
        end
        nk.userData.hddjNum = tonumber(nk.userData.hddjNum) + tonumber(data.funFace or 0)
        self:flushMyScore()

        if self.subTabs_[self.subIndex_] then
            self.subTabs_[self.subIndex_].data2 = nil
        else
            
        end
    elseif tips then
        if tips.ret == -6 then
            local params = {
                messageText = tips.msg,
                hasFirstButton = false
            }
            local dialog = ScorePurchaseDialog.new(params):show()
        else
            nk.TopTipManager:showTopTip(tips.msg)
        end
    end
    self:setLoading(false)
end

function ScoreMarketViewExt:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
                :addTo(self.mainContainer_)
                :pos(display.cx+LEFT_BAR_DW*0.5 ,display.cy)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

function ScoreMarketViewExt:flushMyScore()
    if self.score_ then
        self.score_:setString(tostring(nk.userData.score))
        self:alignTxt()
        if nk.userData.changeScore and nk.userData.changeScore~=0 then
            bm.blinkTextTarget(self.score_, nk.userData.score, handler(self, self.alignTxt))
        end
    end
end

function ScoreMarketViewExt:getTargetIconPosition_(itype)
    if itype == 3 then  -- 现金币
        return self.leftBg_:convertToWorldSpace(cc.p(self.scoreBg_:getPosition()))
    else
        return self.leftBg_:convertToWorldSpace(cc.p(self.scoreBg_:getPosition()))
    end
end

function ScoreMarketViewExt:alignTxt()
    self.lastScore_ = nk.userData.score
    local size1 = self.scoreWord_:getContentSize()
    local size2 = self.score_:getContentSize()
    local size3 = self.scoreBg_:getContentSize()
    local posX, posY = self.scoreWord_:getPosition()
    local posX1,posY1 = self.score_:getPosition()
    self.score_:setPosition(posX+size1.width,posY1)
    self.scoreBg_:setContentSize(cc.size(size1.width+size2.width+38,size3.height))
end

function ScoreMarketViewExt:onGetList(type, data, retData)
    if retData then
        if retData.sponsor then
            self.sponsorList_ = retData.sponsor
        end
        if retData.tips then
            self.sponsorTips_ = retData.tips
        end
        if retData.cashcardTips then
            self.cashcardTips_ = retData.cashcardTips
        end
    end
    if data then
        local itemCfg = self:getSubTabsCfg(type)
        if itemCfg then
            itemCfg.data1 = data
        end
        self:setLoading(false)
    else
        local itemCfg = self:getSubTabsCfg(type)
        if itemCfg then
            itemCfg.data1 = {}
        end
    end

    self:resetHotIcon_(type, retData)
    self:dealShow()
end

-- 添加赞助商选项卡
function ScoreMarketViewExt:createSubGroup2(subType,data)
    local dw,dh,offSetX = 160, 35, 0
    local resId = "#common_transparent_skin.png"
    local onResId = "#rounded_rect_10.png"
    self.subGroup2_ = cc.ui.UICheckBoxButtonGroup.new()--display.TOP_TO_BOTTOM
    local len = #data
    for i=1,len do
        v = data[i]
        self.subGroup2_:addButton(cc.ui.UICheckBoxButton.new({off=resId, on=onResId}, {scale9 = true})
        :setButtonLabel(cc.ui.UILabel.new({text = v.name or "", size = 22, color = cc.c3b(0xff, 0xff, 0xff)}))
        :setButtonLabelAlignment(ui.TEXT_ALIGN_CENTER)
        :setButtonLabelOffset(offSetX, 0)
        :setButtonSize(dw,dh)
        :align(display.LEFT_CENTER))
    end

    self.subGroup2_:onButtonSelectChanged(function(event)
        if self.subGroup2Index_==event.selected then
            return
        end
        self.subGroup2Index_ = event.selected
        local theData = self:getSubTabsCfg(TYPE7)
        self:bindData(TYPE7,theData.data1,self.subGroup2Index_)
    end)
    self.subGroup2_:addTo(self.contentBg_,99,99)

    local tsz = self.topBg_:getContentSize()
    local lsz = self.leftBg_:getContentSize()
    local subGroupWidth = (dw+offSetX)*#data - offSetX
    local subGroup2Size = self.subGroup2_:getContentSize()
    local px, py
    px = (display.width-lsz.width-subGroupWidth)/2
    py = display.height-tsz.height-dh*0.5
    local offy = 0
    if len > 2 then
        offy = -19
    elseif len == 2 then
        offy = -13
    else
        offy = -5
    end

    py = py + offy

    self.subGroup2_:setPosition(px, py)
    self.subGroup2_:show()
    if not self.subGroup2Index_ then
        self.subGroup2Index_ = 1
    end
    local btn = self.subGroup2_:getButtonAtIndex(self.subGroup2Index_)
    if btn then
        btn:setButtonSelected(true)
    end
end

function ScoreMarketViewExt:bindData(type, datas, subType)
    local ret = true
    if datas~=nil then
        local tempData = datas
        if type==TYPE7 then
            if not subType then 
                subType = self.subGroup2Index_
            end
            if not subType then
                subType=1
            end
            -- 过滤
            tempData = {}
            if self.sponsorList_ then
                for k,v in pairs(datas) do
                    if v.spid==self.sponsorList_[subType].id then
                        table.insert(tempData,v)
                    end
                end
                if not self.subGroup2_ then
                    self:createSubGroup2(subType,self.sponsorList_)
                else
                    self.subGroup2_:show()
                end
                self.sponsoredTxt_:setString(self.sponsorTips_)
            end
            self.queue_:hide()
            self.floatBar_:hide()
            if self.sponsoredBar_ then
                self.sponsoredBar_:show()
            end
        else
            if self.isbigLaBaList_ then
                self.queue_:show()
                self.floatBar_:show()
            end
        end
        if #tempData<1 then
            self.goodsList_:setVisible(false)
            self.commintTxt_:setVisible(true)
            self.sponsoredBar_:hide()
        else
            local showListData = tempData
            local groupData = {}
            local temp = nil
            local i = 1
            while i <= #showListData do
                temp = {}
                temp[1] = showListData[i]
                temp[2] = showListData[i+1]
                temp[3] = showListData[i+2]
                i = i + 3             
                table.insert(groupData,temp)
            end

            self.goodsList_:setData(groupData)
            self.goodsList_:setVisible(true)
            self.commintTxt_:setVisible(false)
            self:refreshGoodsListPos_()
        end
    else
        -- 请求配置
        self:setLoading(true)
        self.ctrl_:getMatchScoreList(type)
        ret = false
    end
    return ret
end

function ScoreMarketViewExt:refreshGoodsListPos_()
    local dataList = self.goodsList_:getData()
    local len = #dataList
    local contentSize = 0
    local item,preItem
    for i=1,len do
        item = self.goodsList_:getListItem(i)
        contentSize = contentSize + item:getContentSize().height + item:getBigOffDH()
    end

    local size
    local bigOffDH
    if len > 0 then
        item = self.goodsList_:getListItem(1)
        size = item:getContentSize()
        bigOffDH = item:getBigOffDH()
        size.height = size.height + bigOffDH
        item:pos(-size.width*0.5, contentSize*0.5 - size.height - bigOffDH*0.0 + 10)
        for i=2,len do
            item = self.goodsList_:getListItem(i)
            preItem = self.goodsList_:getListItem(i-1)
            size = item:getContentSize()
            size.height = size.height + item:getBigOffDH()
            item:pos(-size.width*0.5, preItem:getPositionY() - size.height)
        end
    end

    local content = self.goodsList_["content_"]
    content:setContentSize(cc.size(content:getCascadeBoundingBox().width, contentSize))
    self.goodsList_:update()
end

function ScoreMarketViewExt:bindLuckturnLog_(retList)
    self:setLoading(false)
    self.bigWheelLog_ = retList
    if self.bigWheelLog_ then
        self.recordTxt_:setVisible(false)
        self.awardList_:setData(self.bigWheelLog_,true)
        self.awardList_:setVisible(true)
    else
        self.recordTxt_:setVisible(true)
    end
end

function ScoreMarketViewExt:onReback()
	self:close()
end

function ScoreMarketViewExt:close()
    nk.PopupManager:removePopup(self)

    return self
end

function ScoreMarketViewExt:onShowed()
    if self.goodsList_:isVisible() then
        self.goodsList_:setScrollContentTouchRect()
        self.goodsList_:update()
    end

    if self.awardList_:isVisible() then
        self.awardList_:setScrollContentTouchRect()
        self.awardList_:update()
    end
    self.ctrl_:getMatchAddress1()
    self.isShowed_ = true

    if self.hallCtrl_ then
        self.hallCtrl_.scene_:cleanAllView()
    end

    self.group_:getButtonAtIndex(self.index_):setButtonSelected(true)
    self.subGroup_:getButtonAtIndex(self.subIndex_):setButtonSelected(true)

    self:updateLeftGroupButtonState_()
end

--兑换记录显示实物选项，兑换奖品不显示实物选项
function ScoreMarketViewExt:updateLeftGroupButtonState_()
    if self.index_ == 1 then
        self.subIndex_ = 1
        if nk.userData.matchMall == 1 then
            self.subGroup_:getButtonAtIndex(2):show()
            self.subGroup_:getButtonAtIndex(3):show()
        else
            self.subGroup_:getButtonAtIndex(2):hide()
            self.subGroup_:getButtonAtIndex(3):hide()
        end
    elseif self.index_ == 2 then
        if nk.userData.showRealRecord == 0 then
            self.subGroup_:getButtonAtIndex(2):hide()
            self.subGroup_:getButtonAtIndex(3):hide()
        elseif nk.userData.showRealRecord == 1 then
            self.subGroup_:getButtonAtIndex(2):show()
            self.subGroup_:getButtonAtIndex(3):show()
        end
    end

    self.subGroup_:getButtonAtIndex(self.subIndex_):setButtonSelected(true)
end

function ScoreMarketViewExt:onCleanup()
    self.couponRecordData_ = nil
    self.bagRecordData_ = nil
    self:setLoading(false)
    if self.ctrl_ then
        self.ctrl_:dispose()
    end
    display.removeSpriteFramesWithFile("scoremarket_texture.plist", "scoremarket_texture.png")
    nk.schedulerPool:delayCall(function()
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end, 0.1)
    bm.EventCenter:removeEventListenersByEvent(nk.eventNames.SCORE_MARKET_EXCHANGE)
    bm.EventCenter:removeEventListenersByEvent("ScoreMarketRecord_FOCUS") -- 关注
    bm.EventCenter:removeEventListenersByEvent("ScoreMarketRecord_Info")
    bm.EventCenter:removeEventListenersByEvent("SEE_REAL_EXCHANGE_LIST")
    if self.svrBroadcatBigLabaId_ then
        bm.EventCenter:removeEventListener(self.svrBroadcatBigLabaId_)
    end
    -- 
    bm.EventCenter:dispatchEvent({name="OnOff_Load"})
    -- 
    nk.UserInfoChangeManager:unReg(nk.UserInfoChangeManager.ScoreMarket)

    if self.hallCtrl_ then
        local HallController = import("app.module.hall.HallController")
        if self.viewType_ == HallController.MAIN_HALL_VIEW then
            self.hallCtrl_:showMainHallView()
        elseif self.viewType_ == HallController.CHOOSE_ARENA_VIEW then 
            self.hallCtrl_:showChooseArenaRoomView()
        end        
    else
        
    end

    ScoreMarketViewExt.instance_ = nil
end

function ScoreMarketViewExt:createSponsored()
    local lsz = self.leftBg_:getContentSize()
    local leftDw = display.width - lsz.width
    local px = lsz.width + leftDw*0.5
    local py = 22
    self.sponsoredBar_ = display.newScale9Sprite("#sm_bottom_float_bg.png", px, 30, cc.size(leftDw, 42))
        :pos(px, py)
        :addTo(self.mainContainer_)
    self.sponsoredTxt_ = ui.newTTFLabel({
            text = "",
            color = styles.FONT_COLOR.GOLDEN_TEXT,
            size = 20,
            align = ui.TEXT_ALIGN_LEFT,
        })
        :pos(25,20)
        :align(display.CENTER_LEFT)
        :addTo(self.sponsoredBar_)
    self.sponsoredBar_:hide()
end

function ScoreMarketViewExt:addUpScrollQueue()
    local lsz = self.leftBg_:getContentSize()
    local leftDw = display.width - lsz.width
    local px = lsz.width + leftDw*0.5
    local py = 22
    local zindex = 9999
    self.floatBar_ = display.newScale9Sprite("#sm_bottom_float_bg.png", px, py, cc.size(leftDw, 42))
        :addTo(self.mainContainer_, zindex)

    local sz = self.leftBg_:getContentSize()
    local qDw = display.width - sz.width
    local qDh = 42
    local fontSize = 20
    local px = qDw *0.5 + sz.width
    local dt
    if nk.userData.bigLaBaList then
        dt = clone(nk.userData.bigLaBaList)
    else
        dt = {}
    end

    local params = {}
    params.lineCnt = 1
    params.contentSize = cc.size(qDw, qDh)
    params.lblSize = fontSize
    params.color = styles.FONT_COLOR.GOLDEN_TEXT
    params.align = ui.TEXT_ALIGN_CENTER
    params.offx = 10
    params.offy = 0
    params.delayTs = 2.0

    self.queue_ = AnimUpScrollQueueExt.new(params)
        :addTo(self.mainContainer_,zindex)
        :pos(px, py-0)
        :setData(dt)
        :setMaxSize(10)
        :startAnim()

    if #dt == 0 then
        self.floatBar_:hide()
    end

    return self.floatBar_:isVisible()
end

function ScoreMarketViewExt:onSvrBroadcastBigLaBaHandler_(evt)
    if self.queue_ then
        self.queue_:addMsg(evt.data)
        if not self.isbigLaBaList_ then
            local px, py = self.floatBar_:getPosition()
            self.floatBar_:show():pos(px, -60)
            transition.moveTo(self.floatBar_, {time = 0.8, y = py, delay = 0, easing = "BACKOUT", onComplete = function()
                    self.queue_:startAnim()
                end})
            self.isbigLaBaList_ = true
            self.queue_:show()
            self.floatBar_:show()
        else
            self.queue_:startAnim() 
        end
    end
end

-- 判断是否为促销商品
function ScoreMarketViewExt:resetHotIcon_(itype, retData)
    self:changeHotIconResId_(itype, retData, "sale", TYPE7, 1, ScoreMarketViewExt.SALE_ICON_RESID)
end

function ScoreMarketViewExt:changeHotIconResId_(itype, retData, key, replaceIType, equalVal, replaceResId)
    if itype == replaceIType and retData and retData.data then
        local isSale = false
        for i=1,#retData.data do
            if retData.data[i] and retData.data[i][key] and tostring(retData.data[i][key]) == tostring(equalVal) then
                isSale = true
                break
            end
        end
        -- 
        if isSale then
            for i=1,#self.subTabs_ do
                if itype == self.subTabs_[i].type and self.subTabs_[i].hotIcon then
                    local px, py = self.subTabs_[i].hotIcon:getPosition()
                    local iconParent = self.subTabs_[i].hotIcon:getParent()
                    self.subTabs_[i].hotIcon:removeFromParent()
                    self.subTabs_[i].hotIcon = display.newSprite(replaceResId)
                    self.subTabs_[i].hotIcon:setPosition(px, py)
                    self.subTabs_[i].hotIcon:addTo(iconParent)
                end
            end
        end
    end
end

-- 统计赞助物品浏览次数与兑换成功次数，itype:1为浏览，2为兑换成功
function ScoreMarketViewExt:umengStatication(itype, goods)
    if goods and (device.platform == "android" or device.platform == "ios") then
        local name = goods.zh_name or "null"
        if itype == 1 then
            cc.analytics:doCommand{command = "event",args = {eventId = "ScoreMarketItem_click",label = name}}
        elseif itype == 2 then
            cc.analytics:doCommand{command = "event",args = {eventId = "ScoreMarketItem_EX_Succ",label = name}}
        end
    end
end

-- 添加现金卡发放时间
function ScoreMarketViewExt:addCardSendTimeTips_()
    if not self.subIndex_ or not self.index_ then
        return
    end

    if self.subTabs_[self.subIndex_].type == TYPE2 and self.index_ == 1 then
        if not self.sendTimeTips_ then
            local txtTips = self.cashcardTips_ or "เวลาเพิ่มบัตรเงินสดของวันคือ 08:10 น. 13:10 น. 19:10 น.และ20:10 น."
            self.sendTimeTips_ = ui.newTTFLabel({
                    text=txtTips,
                    size=20,
                    color=styles.FONT_COLOR.GOLDEN_TEXT,
                    align=ui.TEXT_ALIGN_CENTER,
                })
                :addTo(self.topBg_)
        end
        -- 
        local offY = 6
        local bsz = self.topBg_:getContentSize()
        local lsz = self.sendTimeTips_:getContentSize()
        self.sendTimeTips_:show()
        self.sendTimeTips_:setPosition(bsz.width + lsz.width*0.5, -lsz.height*0.5 + offY)
        self.sendTimeTips_:runAction(transition.sequence({
                cc.DelayTime:create(0.5),
                cc.MoveTo:create(0.35, cc.p(lsz.width*0.5 + 15, -lsz.height*0.5 + offY)),
                cc.CallFunc:create(function(obj)
                    self.sendTimeTips_:stopAllActions()
                end)
            }))
    else
        if self.sendTimeTips_ then
            self.sendTimeTips_:hide()
        end
    end
end

function ScoreMarketViewExt:onGroupSelectChanged_(event)
    -- 赞助子项目
    if self.subGroup2_ then
        self.subGroup2_:hide()
    end
    self.sponsoredBar_:hide()

    if self.isClickTabs_ then
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    else
        self.isClickTabs_ = true
    end

    self.index_ = event.selected
    if self.exchangeLogGoods_ then
        self.returnBtn_:hide()
        self.exchangeLogGoods_ = nil
        self:dealShow(true)
    else
        self:dealShow(true) 
    end
    -- 
    self:exchangeTabStyle_(self.index_)
    self:addCardSendTimeTips_()
    if self.index_ == 2 then
        self.checkNode_:show()
    else
        self:cancelCheckBoxStatus_()
        self.checkNode_:hide()
    end

    self:updateLeftGroupButtonState_()
end

function ScoreMarketViewExt:exchangeTabStyle_(index)
    local getFrame = display.newSpriteFrame
    if index == 2 then
        self.leftTabSpr_:hide()
        self.rightTabSpr_:show()
        self.leftTabIcon_:setSpriteFrame(getFrame("sm_goods2.png"))
        self.rightTabIcon_:setSpriteFrame(getFrame("sm_record1.png"))
    else
        self.leftTabSpr_:show()
        self.rightTabSpr_:hide()
        self.leftTabIcon_:setSpriteFrame(getFrame("sm_goods1.png"))
        self.rightTabIcon_:setSpriteFrame(getFrame("sm_record2.png"))
    end
end

function ScoreMarketViewExt:rechangeGoods(data)
    local goods = data and data.data
    if goods then
        self.lastRechangeGoods_ = goods
        self.exhangePanel_:show(goods)

        self:showExchangePanel(true)

        self:umengStatication(1, goods)
    end
end

function ScoreMarketViewExt:onRecordDetailInfo_(evt)
    if evt and evt.data then
        local data = evt.data
        if data.goodsData then

        elseif data.category then
            if data.category == TYPE6 or data.category == TYPE7 then
                ScoreTrackRealExchangePopup.new(data, self.ctrl_):show()
            elseif data.category == TYPE2 or data.category == TYPE3 then
                ScoreTrackCardExchangePopup.new(data, self.ctrl_):show()
            else
                -- 构造颁奖以及物品数据
                -- local rewardData = data
                -- rewardData.tips = bm.LangUtil.getText("SHARE", "VIRTUALWORD",data.name)
                -- local goods = {
                --     id = data.id,
                --     category = data.category,
                --     name = data.name,
                --     desc = data.desc,
                --     image = data.image,
                --     rebate = ((data.pin and data.pin~="") and 0.1 or nil),
                -- }
                -- ScoreRewardPopup.new(data,goods,nil):show()
            end
        end
    end
end

-- 关注
function ScoreMarketViewExt:onRecordFocusHandler_(evt)
    local data = evt.data
    if data and data.orderId then
        self.ctrl_:setOrderPraise(data.orderId)
        self.ctrl_:setFriendPoker(data.uid)
    end
end

function ScoreMarketViewExt:dealShow(needDo)
    if not needDo and (self.isInit_ or (self.prevIndex_ == self.index_ and self.prevSubIndex_ == self.subIndex_)) then
        return false
    end

    self:showExchangePanel(false)
    self.goodsList_:hide()
    self.awardList_:hide()
    self.commintTxt_:hide()
    self.recordTxt_:hide()

    local cfg, idx = self:getSubIndexCfg()
    if self.index_==1 then  -- 兑换奖品
        -- 设置选中项
        if cfg then
            if not self:bindData(cfg.type, cfg.data1) then
                return
            end
        else
            self.commintTxt_:setVisible(true)
        end
    elseif self.index_==2 then  -- 兑换记录
        -- 如果“查看全部记录”选择， 设置选中项
        if cfg then
            if not self:bindExchangeData(cfg.type, cfg.data2) then
                return
            end
        else
            self.recordTxt_:setVisible(true)
        end
    end
    self.prevIndex_ = self.index_
    self.prevSubIndex_ = self.subIndex_
    return true
end

-- 绑定兑换数据列表
function ScoreMarketViewExt:bindExchangeData(tabType, datas)
    local ret = true
    if datas~=nil then
        if #datas<1 then
            self.recordTxt_:setVisible(true)
        else
            self.awardList_:setData(datas,true)
            self.awardList_:setVisible(true)
        end
    else
        self:getExchangeRecord(tabType,1)    
        ret = false
    end
    return ret
end

-- 拉取PHP的兑换记录
function ScoreMarketViewExt:getExchangeRecord(type, page)
    self:setLoading(true)
    local arr = string.split(type, TYPE_REAL_LOG)
    if #arr > 1 then
        if string.sub(arr[2],2) == tostring(self.exchangeLogGoods_.id) then
            self.ctrl_:getOrderByGidData(type, page, self.exchangeLogGoods_.id, self.exchangeLogGoods_)
        else
            self:setLoading(false)
        end
    else
        self.ctrl_:getExchangeRecord(type, page)
    end
end

function ScoreMarketViewExt:onGetExchangeRecord(data,tips,tabType,page)
    local recordData = nil

    local itemCfg = self:getSubTabsCfg(tabType)
    if itemCfg then
        itemCfg.data2 = itemCfg.data2 or {}
        itemCfg.data2.page = page
        if page == 0 then
            itemCfg.data2.isEnded = true
        end
        recordData = itemCfg.data2
    end

    if data then
        if #data>0 then
            table.insertto(recordData, data)
        else
            recordData.isEnded = true
        end
    elseif tips and tips.msg then
        nk.TopTipManager:showTopTip(tips.msg)
    else

    end
    self:setLoading(false)
    self:dealShow(true)
end

-- 更新兑换列表
function ScoreMarketViewExt:onUpRecodeList_()
    if self.juhua_ then 
        return 
    end

    local cfg, idx = self:getSubIndexCfg()
    if cfg then
        if not (cfg.data2 and cfg.data2.isEnded) then
            self:getExchangeRecord(cfg.type, cfg.data2.page+1)
        end
    end
end

-- 获取
function ScoreMarketViewExt:getSubIndexCfg()
    local idx, cfg
    if self.exchangeLogGoods_ then
        cfg, idx = self:getSubTabsCfg(TYPE_REAL_LOG.."_"..self.exchangeLogGoods_.id)
    elseif self.checkStatus_ then
        cfg, idx = self:getSubTabsCfg(TYPE_ALL)
    else
        cfg, idx = self.subTabs_[self.subIndex_], self.subIndex_
    end
    return cfg, idx
end

-- 查看玩家兑换实物列表
function ScoreMarketViewExt:onSeeRealExchangeListHandler_(evt)
    self.exchangeLogGoods_ = evt.data
    if not self.exchangeLogGoods_ or not self.exchangeLogGoods_.id then
        return 
    end

    -- 创建
    local key = TYPE_REAL_LOG.."_"..self.exchangeLogGoods_.id
    local cfg, idx = self:getSubTabsCfg(key)
    if not cfg then
        local itemSubTab = self:createSubTabsCfg("", key)
        table.insert(self.subTabs_, itemSubTab)
    end

    self.returnBtn_:show()

    self.index_ = 2
    self:dealShow(true) 
end

-- 兑换日志返回事件
function ScoreMarketViewExt:onExchangeLogBack_(evt)
    self:cleanLogBack_()
    self.exchangeLogGoods_ = nil
    self.index_ = 1
    self.awardList_:hide()
    self.recordTxt_:hide()
    self:rechangeGoods({data=self.lastRechangeGoods_})
end

function ScoreMarketViewExt:cleanLogBack_()
    self.index_ = 1
    self.exchangeLogGoods_ = nil
    self.returnBtn_:hide()
end

-- 获取配置信息
function ScoreMarketViewExt:getSubTabsCfg(tabType)
    for i=1,#self.subTabs_ do
        if self.subTabs_[i].type == tabType then
            return self.subTabs_[i], i
        end
    end
    return nil, nil
end

function ScoreMarketViewExt:createSubTabsCfg(text, tabType, iconRes)
    return {text=text, data1=nil, data2=nil, type=tabType, iconRes=iconRes}
end

function ScoreMarketViewExt.openHtml5Url()
    local url = "http://app.oa.com/jf_shop/index.php?"
    local key = "XA$KGCDv8EY7VHapok#2REVxT33VBmd0"
    local params = {}
    params["gameId"] = 1
    params["uid"] = nk.userData.uid
    params["version"] = BM_UPDATE and BM_UPDATE.VERSION or nk.Native:getAppVersion()
    params["device"] = "win"
    if device.platform == "android" then
        params["device"] = "android"
    elseif device.platform == "ios" then
        params["device"] = "ios"
    end
    params["sign"] = crypto.md5(params["uid"]..key)

    local paramStr = ""
    for k,v in pairs(params) do
        paramStr = paramStr..k.."="..v.."&"
    end
    local len = string.len(paramStr)
    if len > 0 then
        paramStr = string.sub(paramStr, 1, len-1)
    end

    url = url..paramStr

    if device.platform == 'ios' then
        local function start()
        end
        local function finish()
        end
        local function fail(error_info)
        end
        local function userClose()
            nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
        end
        -- webview
        local W, H = 860, 614 - 72
        local x, y = display.cx - W / 2, display.cy - H / 2
        local view, err = Webview.create(start, finish, fail, userClose)
        if view then
            view:show(x,y,W,H)
            view:updateURL(url)
        end
    elseif device.platform == "android" then
        nk.Native:openWebview(url)
    else
        device.openURL(url)
    end
end

function ScoreMarketViewExt.load(ctrl, view, leftTabIndex, topTabIndex)
    if not ScoreMarketViewExt.instance_ then
        ScoreMarketViewExt.instance_ = true
        display.addSpriteFrames("scoremarket_texture.plist", "scoremarket_texture.png", function()
            ScoreMarketViewExt.instance_ = ScoreMarketViewExt.new(leftTabIndex, topTabIndex):show(nil, view)
        end)
    end
end

return ScoreMarketViewExt