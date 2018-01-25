--
-- Author: Tom
-- Date: 2014-11-26 14:44:23
-- 礼物列表元素
local GiftListItem = class("GiftListItem", bm.ui.ListItem)
local LoadGiftControl = import(".LoadGiftControl")
local AnimationIcon   = import("boomegg.ui.AnimationIcon")
local giftGroup = {}

local ITEM_DISTANCE = 154
local ITEM_TEXT_POS_Y = -40
local ITEM_TEXT_COLOR = cc.c3b(0xff, 0xfd, 0x68)

function GiftListItem:ctor(uid,useIdArray,toUidArr)
    self:setNodeEventEnabled(true)
    GiftListItem.super.ctor(self, 780, 120)

    local posY = self.height_ * 0.5
    self.btnGroups = {}
    self.giftIcons = {}
    self.hotIcons = {}
    self.newIcons = {}

    for i = 1, 5 do
        self.btnGroups[i] = cc.ui.UICheckBoxButton.new({off="#pop_gift_item_bg.png", on="#pop_gift_item_bg_selected.png"})
                :setButtonLabel(ui.newTTFLabel({text="", size=24, color=cc.c3b(0xb2, 0xdc, 0xff), align=ui.TEXT_ALIGN_CENTER}))
                :setButtonLabelOffset(0, -40)
                :setButtonLabelAlignment(display.CENTER)
                :pos(80 + ITEM_DISTANCE * (i - 1), posY)
                :onButtonStateChanged(handler(self, self.selectChangeListener))
                :addTo(self)
                :hide()
        self.btnGroups[i]:setTouchSwallowEnabled(false)

        self.giftIcons[i] = AnimationIcon.new(nil, 0.7, 0.5)
            :pos(0, 14)
            :addTo(self.btnGroups[i])

        self.hotIcons[i] = display.newSprite("#store_label_hot2.png")
            :pos(-42, 28)
            :addTo(self.btnGroups[i])
            :hide()
            
        self.newIcons[i] = display.newSprite("#store_label_new2.png")
            :pos(-42, 28)
            :addTo(self.btnGroups[i])
            :hide()
    end
end


function GiftListItem:setData(data, btnGroup, args)
    local dataChanged = (self.data_ ~= data)
    self.data_ = data
    if self.onDataSet then
        self:onDataSet(dataChanged, data, btnGroup, args)
    end
    return self
end

function GiftListItem:onDataSet(dataChanged, data, btnGroup, args)
    for i = 1, 5 do
        if #data >= i then
            btnGroup:addButton(self.btnGroups[i]:show(), data[i].id)
        else
            self.btnGroups[i]:hide()
        end
    end
    -- 加载礼物纹理
    self:loadImageTexture(data)
    -- 加载礼物价格
    self:loadGiftPrice(data)

    -- 加载礼物ID
    self:loadGiftId(data)

end

function GiftListItem:loadGiftId(data)
    for i = 1, #data do
        self.btnGroups[i].ID = data[i].id 
        self.btnGroups[i].positionId = 1
    end
end

function GiftListItem:loadGiftPrice(data)
    local lblStr
    local lbl
    for i = 1, #data do
        if tonumber(data[i].expire) > 1 then
            if data[i].giftType == 10 then
                lblStr = "("..data[i].expire ..bm.LangUtil.getText("GIFT","DATA_LABEL")..")"
            else
                lblStr = bm.formatBigNumber(data[i].money or 0).."("..data[i].expire ..bm.LangUtil.getText("GIFT","DATA_LABEL")..")"
            end
        else
            local moneyStr = bm.formatBigNumber(data[i].money or 0)
            if data[i].giftType == 1 then
                lblStr = bm.formatBigNumber(data[i].money or 0).."(".. 1 ..bm.LangUtil.getText("GIFT","DATA_LABEL")..")"
            else
                lblStr = bm.formatBigNumber(data[i].money or 0).."("..data[i].expire ..bm.LangUtil.getText("GIFT","DATA_LABEL")..")"
            end
        end
        lbl = ui.newTTFLabel({text= lblStr, size=22, color=ITEM_TEXT_COLOR, align=ui.TEXT_ALIGN_CENTER})
        self.btnGroups[i]:setButtonLabel("off", lbl)
        bm.fitSprteWidth(lbl, 130)

        if data[i].ext_property then
            if data[i].ext_property == "1" then
                self.hotIcons[i]:show()
            elseif data[i].ext_property == "2" then
                self.newIcons[i]:show()
            else
                self.hotIcons[i]:hide()
                self.newIcons[i]:hide()
            end
        end
    end
end

function GiftListItem:loadImageTexture(data)
    for i = 1, #data do
        if data[i].image and string.len(data[i].image) > 0 then
            self.giftIcons[i]:onData(data[i].image, 130, 80, nil, 12)
        end
    end
end

function GiftListItem:selectChangeListener(event)
    if event.target:isButtonSelected()  then
        local selectGiftId = event.target.ID
        local selectGiftName = event.target.name
        local positionId = event.target.positionId
        bm.EventCenter:dispatchEvent({name = nk.eventNames.GET_CUR_SELECT_GIFT_ID, data = {giftId = selectGiftId}})
    else
        
    end
end


function GiftListItem:resetStatus()
     self.group:setButtonImage("off","#pop_gift_item_bg.png")
end

return GiftListItem