--
-- Author: johnny@boomegg.com
-- Date: 2014-08-09 17:27:11
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

--- 选择房间界面的筹码按钮
local ChooseRoomChip = class("ChooseRoomChip", function ()
    return display.newNode()
end)

function ChooseRoomChip:ctor(chipId, textColor)
    self.chipId_ = chipId
    self.coinId_ = chipId
    self.chip_ = display.newSprite("#choose_room_chip_".. chipId ..".png")
        :addTo(self)
    self.chip_:setTouchEnabled(true)
    self.chip_:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouch_))

    --现金币场
    self.preCallLabel2_ = ui.newTTFLabel({text = "", color = cc.c3b(133,82,36),size = 36, align = ui.TEXT_ALIGN_CENTER})
        :pos(0,25)
        :addTo(self)
        :hide()
    self.preCallLabelText2_= ui.newTTFLabel({text = bm.LangUtil.getText("HALL", "PRE_CALL_TEXT"), color = cc.c3b(133,82,36), size = 18, align = ui.TEXT_ALIGN_CENTER})
        :pos(0, 0)
        :addTo(self)

    self.preCallLabel_= ui.newTTFLabel({text = "", color = textColor, size = 36, align = ui.TEXT_ALIGN_CENTER})
        :pos(0, 20)
        :addTo(self)
    
    self.preCallLabelText_= ui.newTTFLabel({text = bm.LangUtil.getText("HALL", "PRE_CALL_TEXT"), color = textColor, size = 18, align = ui.TEXT_ALIGN_CENTER})
        :pos(0, -6)
        :addTo(self)

    -- 在玩人数
    self.playerCountBg_ = display.newSprite("#choose_room_count_bg.png")
        :align(display.LEFT_CENTER, -28, -25)
        :addTo(self)
        :hide()

    self.playerCountIcon2_ = display.newSprite("#choose_room_count_icon.png")
        :align(display.LEFT_CENTER, -20, -25)
        :addTo(self)
        :hide()

    local iconY = -34
    self.playerCountIcon_ = display.newSprite("#player_count_icon.png")
        :align(display.LEFT_CENTER, 0, -34)
        :addTo(self)
        :hide()
    self.playerCountLabel_ = ui.newTTFLabel({text = "", color = cc.c3b(0xA7, 0xF2, 0xB0), size = 18, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER, 0, -34)
        :addTo(self)
        :hide()
    self.playerCountLabel_:setAnchorPoint(cc.p(0, 0.5))
    self:setPlayerCount(0)

    -- 最大买入
    local bgPosY = -(self.chip_:getContentSize().height * 0.5 + 16)
    display.newScale9Sprite("#player_count_bg.png", 0, 0, cc.size(148, 32))
        :pos(0, bgPosY)
        :addTo(self)
    self.maxBuyInLabel_ = ui.newTTFLabel({text = "", color = cc.c3b(0x6C, 0xAA, 0x34), size = 18, align = ui.TEXT_ALIGN_CENTER})
        :pos(0, bgPosY)
        :addTo(self)
end

function ChooseRoomChip:onTouch_(evt)
    self.touchInSprite_ = self.chip_:getCascadeBoundingBox():containsPoint(cc.p(evt.x, evt.y))
    if evt.name == "began" then
        self:scaleTo(0.05, 0.9)
        self.clickCanced_ = false
        return true
    elseif evt.name == "moved" then
        if not self.touchInSprite_ and not self.clickCanced_ then
            self:scaleTo(0.05, 1)
            self.clickCanced_ = true
        end
    elseif evt.name == "ended" or name == "cancelled" then
        if not self.clickCanced_ then
            nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
            self:scaleTo(0.05, 1)
            if self.callback_ then
                self.callback_(self.preCall_, self.isCoin_)
            end
        end
    end
end

--- 设置当前房间的玩家数量
function ChooseRoomChip:setPlayerCount(count)
    if count >= 0 then
        self.playerCountLabel_:setString(bm.formatNumberWithSplit(count))
        if self.isCoin_ then
            self.playerCountIcon_:hide()
            self.playerCountIcon2_:show()
            self.playerCountBg_:show()
            self.playerCountLabel_:show()
            self.playerCountLabel_:setTextColor(cc.c3b(0xff,0xff,0xff))
            self.playerCountLabel_:pos(0,-25)
            self.preCallLabelText_:hide()
            self.preCallLabelText2_:show()
        else
            self.playerCountIcon_:show()
            self.playerCountIcon2_:hide()
             self.playerCountBg_:hide()
            self.playerCountLabel_:show()
            self.playerCountLabel_:setTextColor(cc.c3b(0xA7, 0xF2, 0xB0))
            self.playerCountLabel_:pos(0,-34)
            self.preCallLabelText_:show()
            self.preCallLabelText2_:hide()
        end
    end
end

function ChooseRoomChip:setIsCoin(isCoin)
    self.isCoin_ = isCoin
    if isCoin then
        self.playerCountIcon_:hide()
        self.playerCountIcon2_:show()
        self.playerCountLabel_:setTextColor(cc.c3b(0xff,0xff,0xff))
        self.playerCountLabel_:pos(0,-25)
        self.preCallLabelText_:hide()
        self.preCallLabelText2_:show()
    else
        self.playerCountIcon_:show()
        self.playerCountIcon2_:hide()
        self.playerCountLabel_:setTextColor(cc.c3b(0xA7, 0xF2, 0xB0))
        self.playerCountLabel_:pos(0,-34)
        self.preCallLabelText_:show()
        self.preCallLabelText2_:hide()
    end
end

--- 设置当前房间的前注筹码数量
function ChooseRoomChip:setPreCall(val,maxbuy,basebuy)
    if val > 0 then
        self.preCall_ = val
        local maxbuytext = val * 200
        if maxbuy then
            maxbuytext = tonumber(maxbuy)
        end

        if basebuy then
            basebuytext = tonumber(basebuy)
            self.preCallLabelText2_:setString(bm.LangUtil.getText("HALL", "BASE_BUY_IN_TEXT", bm.formatBigNumber(basebuytext)))
            self.preCallLabelText_:setString(bm.LangUtil.getText("HALL", "BASE_BUY_IN_TEXT", bm.formatBigNumber(basebuytext)))
            self.preCallLabelText2_:setSystemFontSize(14)
            self.preCallLabelText_:setSystemFontSize(14)
        end
        
        self.maxBuyInLabel_:setString(bm.LangUtil.getText("HALL", "MAX_BUY_IN_TEXT", bm.formatBigNumber(maxbuytext)))
        local iconWidth = self.playerCountIcon_:getContentSize().width
        local labelWidth = self.playerCountLabel_:getContentSize().width
        local conductConfig = nk.OnOff:getConfig('conductConfig')
        if self.isCoin_ then
            self.chip_:setSpriteFrame(display.newSpriteFrame("choose_room_gcoins.png"))
            self.preCallLabel2_:show()
            self.preCallLabel2_:setString(bm.formatBigNumber(val))
            self.preCallLabel_:hide()

            self.playerCountIcon_:hide()
            self.playerCountLabel_:show()
            self.playerCountLabel_:setTextColor(cc.c3b(0xff,0xff,0xff))
            self.playerCountLabel_:pos(0,-25)

            self.preCallLabelText_:hide()
        else
            self.chip_:setSpriteFrame(display.newSpriteFrame("choose_room_chip_".. self.chipId_ ..".png"))
            self.preCallLabel_:show()
            self.preCallLabel_:setString(bm.formatBigNumber(val))
            if self.preCallLabel2_ then
                self.preCallLabel2_:hide()
            end

            self.playerCountIcon_:show()
            self.playerCountIcon_:pos(-30, -34)

            self.playerCountLabel_:show()
            self.playerCountLabel_:setTextColor(cc.c3b(0xA7, 0xF2, 0xB0))
            self.playerCountLabel_:pos(0,-34)

            self.preCallLabelText_:show()
        end
    end
end

--- 筹码的点击事件
function ChooseRoomChip:onChipClick(callback)
    assert(type(callback) == "function", "callback should be a function")
    self.callback_ = callback
    return self
end

return ChooseRoomChip
