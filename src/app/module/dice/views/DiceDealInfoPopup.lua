--
-- Author: Jonah0608@gmail.com
-- Date: 2016-09-12 10:08:57
--

local WIDTH = 670
local HEIGHT = 332
local LEFT = -WIDTH * 0.5
local TOP = HEIGHT * 0.5
local RIGHT = WIDTH * 0.5
local BOTTOM = -HEIGHT * 0.5
local LEFTOFFSET_X = 92
-- 4个赠送筹码 按钮赠送的数量，本变量用来控制显示和数值
local SEND_CHIP_1_AMOUNT = 100
local SEND_CHIP_2_AMOUNT = 500
local SEND_CHIP_3_AMOUNT = 1000
local SEND_CHIP_4_AMOUNT = 10000
local SEND_CHIP_5_AMOUNT = 50000

local SEND_CHIP_3_AMOUNT_TXT = '1K' -- 限制长度，方便显示
local SEND_CHIP_4_AMOUNT_TXT = '10K'
local SEND_CHIP_5_AMOUNT_TXT = '50K'

local TEXT_COLOR = cc.c3b(0xEE, 0xEE, 0xEE)

local StorePopup = import("app.module.newstore.StorePopup")
local DiceDealInfoPopup = class("DiceDealInfoPopup", function()
    return nk.ui.Panel.new({WIDTH, HEIGHT})
end)


function DiceDealInfoPopup:ctor(ctx,dealId)
    self.ctx = ctx
    self.dealId_ = dealId
    self:setupView()
end


function DiceDealInfoPopup:setupView()
    local frame = "dice_silver_deal.png"
    if self.dealId_ == 2 then
        frame = "dice_gold_deal.png"
    end
    self.avatar_ = nk.ui.CircleIcon.new():addTo(self):pos(-243,110)
    self.avatar_:setSpriteFrame(frame)
    local left_offset_x = LEFTOFFSET_X
    local send_chips_pos_y = -60
    --赠送筹码背景
    self.sendChipsBg_ = display.newScale9Sprite("#room_pop_userinfo_other_send_chips_bg.png", LEFT + left_offset_x + 4+124, TOP + send_chips_pos_y, cc.size(118, 44)):addTo(self)

    --赠送筹码标签
    self.sendChipLabel_ = ui.newTTFLabel({text=bm.LangUtil.getText("ROOM", "INFO_SEND_CHIPS"),size=24, color=cc.c3b(0xce, 0xe8, 0xff)})
    self.sendChipLabel_:pos(LEFT + left_offset_x+124, TOP + send_chips_pos_y)
    self.sendChipLabel_:addTo(self)

    --绿色筹码按钮1
    local labelOff_x, labelOff_y = -1, 0
    self.sendChipBtn1_ = cc.ui.UIPushButton.new("#chip_big_green.png")
        :setButtonLabel(ui.newTTFLabel({
            text=SEND_CHIP_1_AMOUNT,
            size=24, color=cc.c3b(0xca, 0xea, 0xd3)}))
        :setButtonLabelOffset(-2, 0)
        :onButtonPressed(function(event) end)
        :onButtonRelease(function(event) end)
        :onButtonClicked(function(event)
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                self:sendChipClicked_(SEND_CHIP_1_AMOUNT)
            end)
        :pos(LEFT + 220+77+30, TOP + send_chips_pos_y)
        :scale(0.8)
        :addTo(self)

    --绿色筹码按钮2
    self.sendChipBtn2_ = cc.ui.UIPushButton.new("#chip_big_green.png")
        :setButtonLabel(ui.newTTFLabel({
            text=SEND_CHIP_2_AMOUNT,
            size=24, color=cc.c3b(0xca, 0xea, 0xd3)}))
        :setButtonLabelOffset(-1, 0)
        :onButtonPressed(function(event) end)
        :onButtonRelease(function(event) end)
        :onButtonClicked(function(event)
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                self:sendChipClicked_(SEND_CHIP_2_AMOUNT)
            end)
        :pos(LEFT + 220 + 82+77+20, TOP + send_chips_pos_y)
        :scale(0.8)
        :addTo(self)

    --红色筹码按钮1
    self.sendChipBtn3_ = cc.ui.UIPushButton.new("#chip_big_red.png")
        :setButtonLabel(ui.newTTFLabel({
            text=SEND_CHIP_3_AMOUNT_TXT,
            size=24, color=cc.c3b(0xfd, 0xe5, 0xe4)}))
        :onButtonPressed(function(event) end)
        :onButtonRelease(function(event) end)
        :onButtonClicked(function(event)
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                self:sendChipClicked_(SEND_CHIP_3_AMOUNT)
            end)
        :pos(LEFT + 220 + 82 * 2+77+10, TOP + send_chips_pos_y)
        :scale(0.8)
        :addTo(self)

    --红色筹码按钮2
    self.sendChipBtn4_ = cc.ui.UIPushButton.new("#chip_big_red.png")
        :setButtonLabel(ui.newTTFLabel({
            text=SEND_CHIP_4_AMOUNT_TXT,
            size=24, color=cc.c3b(0xfd, 0xe5, 0xe4)}))
        :setButtonLabelOffset(-1, 0)
        :onButtonPressed(function(event) end)
        :onButtonRelease(function(event) end)
        :onButtonClicked(function(event)
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                self:sendChipClicked_(SEND_CHIP_4_AMOUNT)
            end)
        :pos(LEFT + 220 + 82 * 3+77, TOP + send_chips_pos_y)
        :scale(0.8)
        :addTo(self)
    self.sendChipBtn5_ = cc.ui.UIPushButton.new("#chip_big_green.png")
        :setButtonLabel(ui.newTTFLabel({
            text=SEND_CHIP_5_AMOUNT_TXT,
            size=24, color=cc.c3b(0xfd, 0xe5, 0xe4)}))
        :setButtonLabelOffset(-1, 0)
        :onButtonPressed(function(event) end)
        :onButtonRelease(function(event) end)
        :onButtonClicked(function(event)
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                self:sendChipClicked_(SEND_CHIP_5_AMOUNT)
            end)
        :pos(LEFT + 220 + 82 * 4+77, TOP + send_chips_pos_y)
        :scale(0.8)
        :addTo(self)

    self.isShowChip_ = nk.userData.isSendChips and nk.userData.isSendChips == 0
        
    -- ios 审核 isSendChips 为0 是下掉，isSendChips 为1 是打开
    if self.isShowChip_ then
        self.sendChipsBg_:opacity(0)
        self.sendChipLabel_:opacity(0)
        self.sendChipBtn1_:opacity(0)
        self.sendChipBtn2_:opacity(0)
        self.sendChipBtn3_:opacity(0)
        self.sendChipBtn4_:opacity(0)
    end
    self:addHddjList()
end

function DiceDealInfoPopup:addHddjList()
    local x, y = LEFT + LEFTOFFSET_X - 8, BOTTOM + 172
    for i = 1, 2 do
        for j = 1, 5 do
            local id = (i - 1) * 5 + j
            local btn = cc.ui.UIPushButton.new({normal = "#pop_userinfo_my_bank_number_bg.png",pressed="#pop_userinfo_my_bank_number_pressed_bg.png"}, {scale9=true})
                :setButtonSize(90, 72)
                :onButtonClicked(function()
                        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                        self:sendHddjClicked_(id)
                    end)
                :pos(x, y)
                :addTo(self)
            if id == 1 then
                btn:setButtonLabel(display.newSprite("#hddj_egg_icon.png"))
            elseif id == 10 then
                btn:setButtonLabel(display.newSprite("#hddj_tissue_icon.png"):scale(1.1))
            elseif id == 4 then
                btn:setButtonLabel(display.newSprite("#hddj_kiss_lip_icon.png"):scale(1.3))
            elseif id == 5 then
                btn:setButtonLabel(display.newSprite("#hddj_" .. id .. ".png"):scale(0.75))
            elseif id == 6 then
                btn:setButtonLabel(display.newSprite("#hddj_" .. id .. ".png"):scale(0.5))
            elseif id == 7 then
                btn:setButtonLabel(display.newSprite("#hddj_" .. id .. ".png"):scale(1.4))
            elseif id == 8 then
                btn:setButtonLabel(display.newSprite("#hddj_" .. id .. ".png"):scale(0.9))
            else
                btn:setButtonLabel(display.newSprite("#hddj_" .. id .. ".png"):scale(0.6))
            end
            x = x + 124
        end
        x = LEFT + LEFTOFFSET_X - 8
        y = y - 102
    end
end

function DiceDealInfoPopup:sendChipClicked_(chips)
    nk.socket.HallSocket:setDealChipsDice(self.dealId_, chips)
    self:hide()
end

function DiceDealInfoPopup:sendHddjClicked_(hddjId)
    self.sendHddjId_ = hddjId
    if nk.userData.hddjNum then
        self:doSendHddj()
    else
        self.hddjNumObserverId_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "hddjNum", handler(self, self.doSendHddj))
        bm.EventCenter:dispatchEvent(nk.eventNames.ROOM_LOAD_HDDJ_NUM)
    end
end

function DiceDealInfoPopup:doSendHddj()
    if nk.userData.hddjNum then
        if self.hddjNumObserverId_ then
            bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "hddjNum", self.hddjNumObserverId_)
            self.hddjNumObserverId_ = nil
        end

        if nk.userData.hddjNum > 0 then
            self:sendHddjAndHide_()
        else
            bm.HttpService.POST({mod="user", act="getUserFun"}, function(ret)
                local num = tonumber(ret)
                if num then
                    nk.userData.hddjNum = num
                    if num > 0 then
                        self:sendHddjAndHide_()
                    else
                        self:showHddjNotEnoughDialog_()
                    end
                end
            end,
            function()
                if times > 0 then
                    request(times - 1)
                else
                    self:showHddjNotEnoughDialog_()
                end
            end)
        end
    end
end

function DiceDealInfoPopup:sendHddjAndHide_()
    nk.userData.hddjNum = nk.userData.hddjNum - 1
    bm.HttpService.POST({mod="user", act="useUserFun", hddjId=self.sendHddjId_, selfSeatId=self.ctx.model:selfSeatId(), receiverSeatId=self.dealId_,toUid=self.dealId_},
        function(ret)
            --返回2成功
            print("use hddj ret -> ".. ret)
        end, function()
            print("use hddj fail")
        end)
    self:hide()
end

function DiceDealInfoPopup:showHddjNotEnoughDialog_()
    nk.ui.Dialog.new({
        messageText = bm.LangUtil.getText("ROOM", "SEND_HDDJ_NOT_ENOUGH"), 
        firstBtnText = bm.LangUtil.getText("COMMON", "CANCEL"),
        secondBtnText = bm.LangUtil.getText("COMMON", "BUY"), 
        callback = function (type)
            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                self:hide()
                StorePopup.new(2):showPanel()
            end
        end
    }):show()
end

function DiceDealInfoPopup:show()
    self:showPanel_(true, true, true, true)
end

function DiceDealInfoPopup:hide()
    if self.hddjNumObserverId_ then
        bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "hddjNum", self.hddjNumObserverId_)
        self.hddjNumObserverId_ = nil
    end
    self:hidePanel_()
end

return DiceDealInfoPopup