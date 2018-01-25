--
-- Author: johnny@boomegg.com
-- Date: 2014-08-09 17:27:11
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

--- 选择骰子房间界面的筹码按钮
local ChooseDiceRoomChip = class("ChooseDiceRoomChip", function ()
    return display.newNode()
end)

function ChooseDiceRoomChip:ctor(chipId, textColor)
    self.chipId_ = chipId
    self.coinId_ = chipId
    self.chip_ = display.newSprite("#choose_room_dice_chip_".. chipId ..".png")
        :addTo(self)
        
    self.chip_:setTouchEnabled(true)
    self.chip_:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouch_))

    self.preCallLabel_= ui.newTTFLabel({text = "", color = cc.c3b(0xcf, 0xd4, 0xed), size = 20, align = ui.TEXT_ALIGN_CENTER})
        :pos(0, -72)
        :addTo(self)
    
    self.playerCountBg_ = display.newScale9Sprite("#choose_room_dice_num_bg.png", 0, 0, cc.size(180, 30))
        :pos(0, -172)
        :addTo(self)

    self.preCallLabelText_= ui.newTTFLabel({text = "", color = cc.c3b(0x37, 0x88, 0x1c), size = 22, align = ui.TEXT_ALIGN_CENTER})
        :pos(0, -172)
        :addTo(self)

    -- 在玩人数
    local pos_y = -100
    self.playerCountBg_ = display.newSprite("#choose_room_dice_num_bg.png")
        :pos(0, pos_y)
        :addTo(self)

    self.playerCountIcon_ = display.newSprite("#choose_room_dice_num_" .. chipId .. ".png")
        :align(display.LEFT_CENTER, -36, pos_y)
        :addTo(self)
    self.playerCountLabel_ = ui.newTTFLabel({text = "", color = cc.c3b(0xA7, 0xF2, 0xB0), size = 18, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER, -2, pos_y)
        :addTo(self)

    self:setPlayerCount(0)

end

function ChooseDiceRoomChip:onTouch_(evt)
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
function ChooseDiceRoomChip:setPlayerCount(count)
    if count >= 0 then
        self.playerCountLabel_:setString(bm.formatNumberWithSplit(count))
    end
end

function ChooseDiceRoomChip:setIsCoin(isCoin)
    self.isCoin_ = isCoin
end

--- 设置当前房间的前注筹码数量
function ChooseDiceRoomChip:setPreCall(val,maxbuy,basebuy)
    if val > 0 then
        self.preCall_ = val
        -- self.preCallLabel_:setString(bm.formatBigNumber(val))
        local maxbuytext = val * 200
        if maxbuy then
            maxbuytext = tonumber(maxbuy)
        end
        if basebuy then
            basebuytext = tonumber(basebuy)
            self.preCallLabelText_:setString(bm.LangUtil.getText("HALL", "BASE_BUY_IN_TEXT", bm.formatBigNumber(basebuytext)))
        end
        self.preCallLabel_:setString(bm.LangUtil.getText("HALL", "MIN_BET_TEXT",bm.formatBigNumber(val)))
    end
end

--- 筹码的点击事件
function ChooseDiceRoomChip:onChipClick(callback)
    assert(type(callback) == "function", "callback should be a function")
    self.callback_ = callback
    return self
end

return ChooseDiceRoomChip
