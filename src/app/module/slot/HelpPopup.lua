--
-- Author: viking@boomegg.com
-- Date: 2014-12-01 10:37:48
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--
local HelpPopup = class("HelpPopup", function()
    return display.newNode()
end)

local HelpPopupItem = import(".HelpPopupItem")

HelpPopup.WIDTH = 612
HelpPopup.HEIGHT = 402

local configTable = {
    {{"A", "A", "A"}, "1000"}, {{"B", "B", "B"}, "100"},
    {{"C", "C", "C"}, "50"},  {{"D", "D", "D"}, "20"},
    {{"E", "E", "E"}, "10"},   {{"F", "F", "F"}, "8"},
    {{"G", "G", "G"}, "8"},      {{"H", "H", "H"}, "5"},
    {{"I", "I", "I"}, "5"},   {{"J", "J", "J"}, "5"},
    {{"A", "A", "X"}, "3"},   {{"B", "B", "X"}, "3"},
    {{"C", "C", "X"}, "3"},   {{"X", "A", "A"}, "3"},
    {{"X", "B", "B"}, "3"},   {{"X", "C", "C"}, "3"},
    {{"A", "X", "A"}, "3"},   {{"B", "X", "B"}, "3"},
    {{"C", "X", "C"}, "3"},   {{"Y", "Y", "X"}, "2"},
    {{"X", "Y", "Y"}, "2"},   {{"Y", "X", "Y"}, "2"}
}

function HelpPopup:ctor(blind, config, isGcoins)
    self.blind_ = blind
    self.config = config
    self.isGcoins_ = isGcoins
    self:setupView()
end

function HelpPopup:getConfigData(cardtype,index)
    local txt = ""
    for k,v in ipairs(cardtype) do
        txt = txt .. v
    end
    if self.config then
        for k,v in ipairs(self.config) do
            if txt == v[1] then
                return v[2]
            end
        end
    end
    return configTable[index][2]
end

function HelpPopup:setupView()
    --背景
    display.newSprite("#slot_help_bg.png"):addTo(self):setTouchEnabled(true)

    --标题
    local titleWidth = 212
    local titleHeight = 33
    local titleMarginTop = 5
    local posY = HelpPopup.HEIGHT/2
    display.newSprite("#slot_help_title.png"):addTo(self):pos(0, posY - titleHeight/2 - titleMarginTop)

    --奖励计算描述
    local tips1Width = 222
    local tips1Height = 19
    local tips1MarginTop = 5
    local tips2Width = 172
    local tips2Height = 23
    local tips2MarginTop = 5
    posY = posY - titleHeight - titleMarginTop
    display.newSprite("#slot_help_tips1.png"):addTo(self):pos(0, posY - tips1Height/2 - tips1MarginTop)
    posY = posY - tips1Height - tips1MarginTop
    if self.isGcoins_ then
        display.newSprite("#slot_help_tips3.png"):addTo(self):pos(0, posY - tips2Height/2 - tips2MarginTop)
    else
        display.newSprite("#slot_help_tips2_new.png"):addTo(self):pos(0, posY - tips2Height/2 - tips2MarginTop)
    end

    local blind = bm.formatBigNumber(self.blind_) .. " * "

    --大条目
    posY = posY - tips2Height - tips2MarginTop
    local helpBigItemPadding = 16
    local helpBigItemMarginTop = 4
    HelpPopupItem.new(configTable[1][1], blind .. self:getConfigData(configTable[1][1],1), true):addTo(self)
        :pos(-HelpPopupItem.BIG_WIDTH/2 - helpBigItemPadding, posY - HelpPopupItem.BIG_HEIGHT/2 - helpBigItemMarginTop)
    HelpPopupItem.new(configTable[2][1], blind .. self:getConfigData(configTable[2][1],2), true):addTo(self)
        :pos(HelpPopupItem.BIG_WIDTH/2 + helpBigItemPadding, posY - HelpPopupItem.BIG_HEIGHT/2 - helpBigItemMarginTop)

    --小条目
    posY = posY - HelpPopupItem.BIG_HEIGHT - helpBigItemMarginTop
    local helpSmallItemPadding = 16
    local helpSmallItemMarginTop = 4
    for i = 3, 18, 3 do
        HelpPopupItem.new(configTable[i][1], blind .. self:getConfigData(configTable[i][1],i)):addTo(self)
            :pos(-HelpPopupItem.SMALL_WIDTH * 2/2 - helpSmallItemPadding, posY - HelpPopupItem.SMALL_HEIGHT/2 - helpSmallItemMarginTop)
        HelpPopupItem.new(configTable[i + 1][1], blind .. self:getConfigData(configTable[i + 1][1],i+1)):addTo(self)
            :pos(0, posY - HelpPopupItem.SMALL_HEIGHT/2 - helpSmallItemMarginTop)
        HelpPopupItem.new(configTable[i + 2][1], blind .. self:getConfigData(configTable[i + 2][1],i+2)):addTo(self)
            :pos(HelpPopupItem.SMALL_WIDTH * 2/2 + helpSmallItemPadding, posY - HelpPopupItem.SMALL_HEIGHT/2 - helpSmallItemMarginTop)    
        posY = posY - HelpPopupItem.SMALL_HEIGHT - helpSmallItemMarginTop
    end
    HelpPopupItem.new(configTable[21][1], blind .. self:getConfigData(configTable[21][1],21)):addTo(self)
        :pos(-HelpPopupItem.SMALL_WIDTH * 2/2 - helpSmallItemPadding, posY - HelpPopupItem.SMALL_HEIGHT/2 - helpSmallItemMarginTop)
    HelpPopupItem.new(configTable[22][1], blind .. self:getConfigData(configTable[22][1],22)):addTo(self)
        :pos(0, posY - HelpPopupItem.SMALL_HEIGHT/2 - helpSmallItemMarginTop)

    --关闭按钮
    local closeBtnWidth = 58
    local closeBtnHeight = 59
    local closeBtnPadding = 5
    cc.ui.UIPushButton.new({normal = "#panel_black_close_btn_up.png", pressed = "#panel_black_close_btn_down.png"})
        :onButtonClicked(buttontHandler(self, self.onCloseBtnListener_))
        :addTo(self)
        :pos(HelpPopup.WIDTH/2, HelpPopup.HEIGHT/2)
end

function HelpPopup:onCloseBtnListener_()
    self:hide()
end

function HelpPopup:show(inRoom)
    if not inRoom then
        nk.PopupManager:addPopup(self,true,true,true,true,nil,1.3)
    else
        nk.PopupManager:addPopup(self)
    end
end

function HelpPopup:hide()
    nk.PopupManager:removePopup(self)
end

return HelpPopup