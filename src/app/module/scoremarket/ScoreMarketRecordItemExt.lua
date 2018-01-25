--
-- Author: johnny@boomegg.com
-- Date: 2014-08-31 20:40:41
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--
local AnimationIcon             = import("boomegg.ui.AnimationIcon")
local UserAvatarPopup = import("app.module.room.views.UserAvatarPopup")
local DisplayUtil = import("boomegg.util.DisplayUtil")
local AvatarIcon          = import("boomegg.ui.AvatarIcon")
local SimpleColorLabel = import("boomegg.ui.SimpleColorLabel")
local ScoreMarketRecordItemExt = class("ScoreMarketRecordItemExt", bm.ui.ListItem)

ScoreMarketRecordItemExt.WIDTH = 675
local HEIGHT = 94
local BUTTON_DW = 100
local BUTTON_DH = 52
local ICON_WIDTH = 70
local ICON_HEIGHT = 70
local ICON_OFFX = 10
local AVATAR_TAG = 100
local DETAIL_BTN_OFFX = 5
local COPY_BTN_OFFX = 105
local AVATART_DW, AVATAR_DH = 70, 70
local LOVE_BTN_OFFX = 62

function ScoreMarketRecordItemExt:ctor()
    local WIDTH = ScoreMarketRecordItemExt.WIDTH
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    ScoreMarketRecordItemExt.super.ctor(self, WIDTH, HEIGHT)

    self:setNodeEventEnabled(true)
    -- BG
    self.rankBg_ = display.newScale9Sprite(
        '#sm_record_bg.png',
        0, 0,
        cc.size(WIDTH-10, HEIGHT-0)
    )
    :align(display.BOTTOM_LEFT)
    :addTo(self)

    -- 图标ICON
    local px, py = ICON_OFFX, HEIGHT*0.5 - ICON_HEIGHT*0.5
    self.icon_ = display.newNode()
        :size(ICON_WIDTH, ICON_HEIGHT)
        :pos(px, py)
        :addTo(self, 10, 10)

    self.animationIcon_ = AnimationIcon.new(nil, 1, 0.5, handler(self, self.onAnimationHandler_))
        :addTo(self.icon_, 0, AVATAR_TAG)
        :pos(ICON_WIDTH/2, ICON_HEIGHT/2)

    -- 名字
    px = px + ICON_WIDTH + ICON_OFFX
    py = HEIGHT*0.75
    self.name_ = ui.newTTFLabel {
            text  = '',
            color = cc.c3b(255, 255, 255),
            size  = 26,
            align = ui.TEXT_ALIGN_CENTER,
        }
        :align(display.LEFT_CENTER, px, py)
        :addTo(self)

    -- 兑换日期
    py = HEIGHT*0.25
    self.time_ = ui.newTTFLabel {
            text  = '',
            color = cc.c3b(0x9e, 0x7a, 0xe4),
            size  = 24,
            align = ui.TEXT_ALIGN_CENTER,
        }
        :align(display.LEFT_CENTER, px, py)
        :addTo(self)

    -- 激活码
    px, py = 320,6
    self.desc_ = ui.newTTFLabel {
            text  = '',
            color = cc.c3b(0xFF, 0xFF, 0xFF),
            size  = 22,
        }
        :align(display.LEFT_CENTER, px, py)
        :addTo(self)

    px, py = WIDTH - 120*0.5 - 5, HEIGHT*0.5
    self.copyKey_ = cc.ui.UIPushButton.new({normal = "#common_btn_green_normal.png", pressed = "#common_btn_green_pressed.png", disabled = "#common_btn_disabled.png"}, {scale9 = true})
        :setButtonSize(BUTTON_DW, BUTTON_DH)
        :setButtonLabel("normal", ui.newTTFLabel({text = bm.LangUtil.getText("SCOREMARKET", "COPY"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 24, align = ui.TEXT_ALIGN_CENTER}))
        :setButtonLabel("disabled", ui.newTTFLabel({text = bm.LangUtil.getText("SCOREMARKET", "COPY"), color = styles.FONT_COLOR.DARK_TEXT, size = 24, align = ui.TEXT_ALIGN_CENTER}))
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.onCopyKeyClick_))
        :pos(px, py)

    self.infoLbl_ = ui.newTTFLabel({text = bm.LangUtil.getText("SCOREMARKET", "SEE"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 24, align = ui.TEXT_ALIGN_CENTER})
    self.infoBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_blue_normal.png", pressed = "#common_btn_blue_pressed.png", disabled = "#common_btn_disabled.png"}, {scale9 = true})
        :setButtonSize(BUTTON_DW, BUTTON_DH)
        :setButtonLabel(self.infoLbl_)
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.onInfoBtnClick_))
        :pos(px, py)

    -- 爱心关注按钮
    self.loveLbl_ = ui.newTTFLabel({
            text="0",
            size=20,
            color=cc.c3b(0xff, 0xff, 0x0),
            align=ui.TEXT_ALIGN_CENTER,
        })

    self.loveBtn_ = cc.ui.UIPushButton.new({
            normal="#sm_goodStatus_up.png",
            pressed="#sm_goodStatus_down.png"
        })
        :setButtonLabel(self.loveLbl_)
        :setButtonLabelOffset(45, 0)
        :addTo(self)
        :pos(WIDTH-LOVE_BTN_OFFX, HEIGHT*0.5)
        :onButtonClicked(buttontHandler(self, self.onLoveBtnClick_))
        :hide()

    self.avatar_ = AvatarIcon.new("#common_male_avatar.png", AVATART_DW, AVATAR_DH, 6, nil, 1, 16, 0)
            :pos(px-240, HEIGHT*0.5)
            :addTo(self, 99)
            :hide()
    bm.TouchHelper.new(self.avatar_, handler(self, self.onAvatarHandler_))

    -- 实物进度状态
    self.realStatus_ = SimpleColorLabel.addIconText(
            {resId="#sm_status_1.png"},
            {text=bm.LangUtil.getText("SCOREMARKET","GOODS_STATUST_TEL"), color=cc.c3b(158,122,228)},
        3)
        :addTo(self)
        :pos(WIDTH/2 + 35, HEIGHT/2)
        :hide()

    local sz = self.time_:getContentSize()
    local tpx, tpy = self.time_:getPosition()
    local cpx = tpx + sz.width*0.5
    local leftdw = px - 120*0.5 - cpx
    self.desc_:pos(cpx + leftdw*0.5 - 58, HEIGHT*0.5-self.desc_:getContentSize().height*0.5)
    self.btnX_ = px
    self.btnY_ = HEIGHT*0.5

    self.copyKey_:setTouchSwallowEnabled(false)
    self.infoBtn_:setTouchSwallowEnabled(false)
end
-- 
function ScoreMarketRecordItemExt:onAvatarHandler_(obj, evtName)
    if evtName=="TOUCH_BEGIN" then
        local selfData = self:getData()
        if selfData and selfData.goodsData then
            self:dispatchEvent({name="ITEM_EVENT", type="ShowOtherUserDetail", data=selfData})
        end
    end
end
-- 
function ScoreMarketRecordItemExt:onAnimationHandler_()
    local selfData = self:getData()
    if selfData and selfData.goodsData and selfData.shareImg and string.len(selfData.shareImg) > 5 then
        local popData = {}
        popData.gender = "f"
        popData.img = selfData.shareImg
        UserAvatarPopup.new():show(popData, true)
    end
end
-- 
function ScoreMarketRecordItemExt:onCopyKeyClick_()
    local selfData = self:getData()
    if selfData and selfData.desc then
        nk.Native:setClipboardText(selfData.desc)
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("SCOREMARKET","COPY_SUCCESS"))
    end
end
-- 
function ScoreMarketRecordItemExt:onDataSet(dataChanged, data)
    self.desc_:setString("")
    self.copyKey_:hide()
    self.realStatus_:hide()
    self.loveBtn_:hide()
    self.avatar_:hide()
    self.infoBtn_:hide()
    self.icon_:setPositionX(ICON_OFFX)
    -- 
    self.icon_:hide()    
    if data.goodsData then
        self.loveBtn_:show()
        self.avatar_:show()
        -- self:loadGoodsImg(data.goodsData.image or "")
        self.avatar_:setSexAndImgUrl(data.uimg or "", data.uimg or "")
        -- 判断是否可以关注
        self:setFocus_()
        -- 
        self.name_:setString(data.nick or "")
        self.time_:setString(bm.TimeUtil:getTimeStampString(data.addtime,"/"))
        self.time_:scale(1)
        -- L.SCOREMARKET.FOCUS_TXT = "关注"
        self:loadGoodsImg(data.shareImg)
    else
        self.infoBtn_:show()
        self:bindNormalItem()
        self:loadGoodsImg(data.image)
    end    
end

function ScoreMarketRecordItemExt:refreshRealStatus()
    local data = self:getData()
    if data then
        local idxStr = tostring(data.status or "1")
        self.realStatus_:show()
        self.realStatus_.setString(2, bm.LangUtil.getText("SCOREMARKET", "STATUST_TXT")[idxStr])
        self.realStatus_.setIcon(bm.LangUtil.getText("SCOREMARKET", "STATUST_RESLIST")[idxStr])
    end
end

function ScoreMarketRecordItemExt:bindNormalItem()
    local data = self.data_

    local showBtns = {}    
    if "12call" == data.category or "linecoins" == data.category then
        self.desc_:setString(data.desc or "")
        data.pin = data.desc -- 外部要使用 统一在pin处理
        self.copyKey_:show()
    elseif "real" == data.category then
        data.refreshRealStatus = handler(self, self.refreshRealStatus)
        self:refreshRealStatus()
    end
    -- 
    if data.pin and string.len(data.pin) > 0 then
        self.desc_:setString(data.pin or "")
        self.copyKey_:setVisible(true)
        table.insert(showBtns,self.copyKey_)
    end
    -- 详细信息处理
    if not data.category or data.category=="" or data.category=="bag" then
        self.infoBtn_:setVisible(false)
    else
        self.infoBtn_:setVisible(true)
        table.insert(showBtns,self.infoBtn_)
    end
    -- 按钮布局
    if #showBtns==1 then
        showBtns[1]:pos(self.btnX_ - DETAIL_BTN_OFFX,self.btnY_)
    elseif #showBtns==2 then
        showBtns[1]:pos(self.btnX_ - COPY_BTN_OFFX,self.btnY_)
        showBtns[2]:pos(self.btnX_- DETAIL_BTN_OFFX,self.btnY_)
    end
    -- 
    if data.image and "" == data.image then
        self.name_:setPositionX(ICON_OFFX)
        self.time_:setPositionX(12)
    else
        self.name_:setPositionX(ICON_WIDTH + ICON_OFFX*2)
        self.time_:setPositionX(ICON_WIDTH + ICON_OFFX*2)
    end
    -- 
    self.time_:setString(bm.TimeUtil:getTimeStampString(tonumber(data.create_time),"/"))
    bm.fitSprteWidth(self.time_, 190)
    self.name_:setString(data.name or "")
end

function ScoreMarketRecordItemExt:loadGoodsImg(imgUrl)
    if not imgUrl or string.len(imgUrl) < 10 then
        return
    end
    -- 
    local iconContainer = self.icon_
    local iconSize = iconContainer:getContentSize()
    self.animationIcon_:onData(imgUrl, iconSize.width, iconSize.height, function(succ)
        iconContainer:show()
    end)
end
-- 
function ScoreMarketRecordItemExt:onCleanup()
    
end
-- 关注
function ScoreMarketRecordItemExt:onLoveBtnClick_(evt)
    bm.EventCenter:dispatchEvent({name = "ScoreMarketRecord_FOCUS", data = self:getData()})
    local data = self:getData()
    if data and data.focus and tostring(data.focus) == "1" then
        data.focused = true
        data.praise = data.praise + 1
        self:setFocus_()
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("SCOREMARKET", "FOCUS_SUCC"))
        -- 
        bm.blinkTextTarget(self.loveLbl_, data.praise)
        -- 
        local rect = self.loveBtn_:getParent():convertToWorldSpace(cc.p(self.loveBtn_:getPosition()))
        app:tip(8, {num=1, url="#sm_goodStatus_up.png"}, rect.x, rect.y, 999, 0, 18, 0)
    end
end
-- 
function ScoreMarketRecordItemExt:onInfoBtnClick_()
    local goodsData = self:getData()
    if goodsData and goodsData.uid and goodsData.id then
        bm.EventCenter:dispatchEvent({name = "ScoreMarketRecord_Info", data = goodsData})
    end
end

function ScoreMarketRecordItemExt:setFocus_()
    local data = self:getData()
    if data.focus and tostring(data.focus) == "1" and not data.focused then
        self.loveBtn_:setButtonEnabled(true)
        DisplayUtil.removeShader(self.loveBtn_)
    else
        self.loveBtn_:setButtonEnabled(false)
        DisplayUtil.setGray(self.loveBtn_)
    end
    -- 
    self.loveLbl_:setString(data.praise)
    self.loveBtn_:setButtonLabelOffset(self.loveLbl_:getContentSize().width*0.5+24, 3)
    self.loveBtn_:setPositionX(ScoreMarketRecordItemExt.WIDTH - LOVE_BTN_OFFX - self.loveLbl_:getContentSize().width*0.5)

    -- self.avatar_:setPositionX(self.loveBtn_:getPositionX() - 64)
    self.avatar_:setPositionX(ICON_OFFX+AVATART_DW*0.5)
    self.icon_:setPositionX(self.loveBtn_:getPositionX() - 80 - ICON_WIDTH*0.5)
end

return ScoreMarketRecordItemExt