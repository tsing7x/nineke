--
-- Author: viking@boomegg.com
-- Date: 2014-09-01 10:22:00
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local FAQListItem = class("FAQListItem", bm.ui.ListItem)

FAQListItem.WIDTH = 0
FAQListItem.HEIGHT = 66

FAQListItem.ANSWER_SIZE = 20
FAQListItem.ANSWER_COLOR = cc.c3b(0x64, 0x9a, 0xc9)

local itemPadding = 10 --每个元素之间间隔 列表元素 高66 实际背景框高 56 上下间隔为5 2个元素之间的间隔就为10

local bottomPanelMinHeight_ = 10 --底部面板最小高度

function FAQListItem:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    FAQListItem.super.ctor(self, FAQListItem.WIDTH, FAQListItem.HEIGHT + 2)

    self.contentWidth = FAQListItem.WIDTH - 4
    self.isFolded_ = true

    --触摸层
    self.touchBtn_ = cc.ui.UIPushButton.new("#common_transparent_skin.png", {scale9 = true})
    self.touchBtn_:setTouchSwallowEnabled(false)
    self.touchBtn_:onButtonPressed(function(evt)
        self.btnPressedY_ = evt.y
        self.btnClickCanceled_ = false
    end)
    self.touchBtn_:onButtonRelease(function(evt)
        if math.abs(evt.y - self.btnPressedY_) > 10 then
            self.btnClickCanceled_ = true
        end
    end)
    self.touchBtn_:onButtonClicked(function(evt)
        if not self.btnClickCanceled_ and self:getParent():getParent():getCascadeBoundingBox():containsPoint(cc.p(evt.x, evt.y)) then
            self:foldContent()
        end
    end)
    self.touchBtn_:setButtonSize(FAQListItem.WIDTH, FAQListItem.HEIGHT)
    self.touchBtn_:pos(FAQListItem.WIDTH * 0.5, FAQListItem.HEIGHT * 0.5)
    self.touchBtn_:addTo(self)

    --内容容器
    self.contentContainer_ = display.newNode():addTo(self):pos(FAQListItem.WIDTH * 0.5, FAQListItem.HEIGHT * 0.5)

    self.heightExtra_ = 0

    --底部详情面板
    self.bottomPanel_ = cc.ClippingNode:create()
        :pos(0, -bottomPanelMinHeight_/2)--设置位置偏移，使拼接完美
        :addTo(self.contentContainer_)

    self.stencil_ = display.newRect(FAQListItem.WIDTH, bottomPanelMinHeight_, {fill=true, fillColor=cc.c4f(0, 0, 0, 1)})
        :align(display.BOTTOM_CENTER, 0, -FAQListItem.HEIGHT * 0.5)--设置模板位置，也就是裁剪显示的内容
    self.bottomPanel_:setStencil(self.stencil_)

    local contentH = FAQListItem.HEIGHT - itemPadding
    --底部背景，相当于底板
    self.bottomBackground_ = display.newScale9Sprite("#help_item_background_bottom.png")
        :size(self.contentWidth, contentH)
        :addTo(self.bottomPanel_)

    --顶部面板
    local topPanel = display.newNode():addTo(self.contentContainer_)
    -- 顶部背景
    local bg = display.newScale9Sprite(
        "#help_item_background_top.png",
        0, 0,
        cc.size(self.contentWidth, contentH))
        :addTo(topPanel)

    --分割线
    self.splitLine_ = display.newScale9Sprite(
        "#pop_up_split_line.png",
        self.contentWidth/2, 0,
        cc.size(self.contentWidth, 4))
        :addTo(bg):hide()

    --折叠按钮
    local foldIconMarginLeft = 28
    self.foldIcon_ = display.newSprite("#store_list_triangle.png", FAQListItem.WIDTH * -0.5 + foldIconMarginLeft, -3):addTo(topPanel)
    self.foldIcon_:setAnchorPoint(cc.p(0.3, 0.5))

    --标题
    self.titleMarginLeft = foldIconMarginLeft + self.foldIcon_:getContentSize().width + 12
    self.title_ = ui.newTTFLabel({size=28, color=cc.c3b(0xca, 0xca, 0xca), align=ui.TEXT_ALIGN_LEFT})
        :align(display.LEFT_CENTER, FAQListItem.WIDTH * -0.5 + self.titleMarginLeft, 0)
        :addTo(topPanel)

    --解答
    local answerLabelPadding = 30 * 2
    self.answerLabel = ui.newTTFLabel({
            size = FAQListItem.ANSWER_SIZE, 
            color = FAQListItem.ANSWER_COLOR, 
            align = ui.TEXT_ALIGN_LEFT,
            valign = ui.TEXT_VALIGN_TOP,
            dimensions = cc.size(self.contentWidth - answerLabelPadding, 0)})
        :align(display.LEFT_CENTER, 0, 0)
        :addTo(self.bottomPanel_):hide()

    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.onEnterFrame_))
end

function FAQListItem:onTouch_(evt)
    local name, x, y, prevX, prevY = evt.name, evt.x, evt.y, evt.prevX, evt.prevY
    local isTouchInSprite = self:getCascadeBoundingBox():containsPoint(cc.p(x, y))
    if name == "began" then
        if isTouchInSprite then
            self.beginY_ = evt.y
            self.cancelClick_ = false
            self.isTouching_ = true
            return true
        else
            return false
        end
    elseif not self.isTouching_ then
        return false
    elseif name == "moved" then
        if math.abs(evt.y - self.beginY_) > 10 then
            self.cancelClick_ = true
        end
    elseif name == "ended"  or name == "cancelled" then
        self.isTouching_ = false
        if not self.cancelClick_ and isTouchInSprite and self:getParent():getParent():getCascadeBoundingBox():containsPoint(cc.p(evt.x, evt.y)) then
            self:foldContent()
        end
    end
    return true
end

function FAQListItem:onEnterFrame_()
    local bottomHeight = self.bottomBackground_:getContentSize().height
    local dest, direction
    if self.isFolded_ then
        dest = 0
        direction = -1
    else
        dest = bottomHeight
        direction = 1
    end
    if self.heightExtra_ == dest then
        if dest == 0 then --yk
            self.splitLine_:hide()
        end
        self:unscheduleUpdate()
    else
        self.heightExtra_ = self.heightExtra_ + direction * math.max(1, math.abs(self.heightExtra_ - dest) * 0.08)
        if direction > 0 and self.heightExtra_ > dest or direction < 0 and self.heightExtra_ < dest then
            self.heightExtra_ = dest
        end
    end
    self.foldIcon_:rotation(90 * (self.heightExtra_ / (bottomHeight)))

    local contentHeight = FAQListItem.HEIGHT + self.heightExtra_
    self.bottomPanel_:setPositionY(-self.heightExtra_ + itemPadding/2)
    self:setContentSize(cc.size(FAQListItem.WIDTH, contentHeight))
    self.contentContainer_:setPositionY(FAQListItem.HEIGHT * 0.5 + self.heightExtra_)
    self.touchBtn_:setButtonSize(FAQListItem.WIDTH, FAQListItem.HEIGHT + self.heightExtra_)
    self.touchBtn_:setPositionY(contentHeight * 0.5)
    if direction == -1 then --收缩
        self.stencil_:setScaleY((bottomPanelMinHeight_ + self.heightExtra_ ) / bottomPanelMinHeight_)
        self.bottomPanel_:setPositionY(-self.heightExtra_ - bottomPanelMinHeight_/2 )
    else --展开
        self.stencil_:setScaleY((self.heightExtra_) / bottomPanelMinHeight_)
    end
    self:dispatchEvent({name="RESIZE"})
end

function FAQListItem:foldContent()
    if self.isFolded_ then
        self.isFolded_ = false
        self.splitLine_:show()
    else
        self.isFolded_ = true
    end
    self:unscheduleUpdate()
    self:scheduleUpdate()

    if self.index_ == 2 and not self.initItem2 then
        self.initItem2 = true
        self:createItem2(self.data_)
    elseif self.index_ ~= 2 and not self.initItem then
        self.initItem = true
        self:createItem(self.data_)
    end    
end

function FAQListItem:onDataSet(dataChanged, data)
    if dataChanged then
        self.data_ = data
        self.title_:setString(data[1])
    end
end

local answerLabelMarginBottom = 5
local linePadding = 26

function FAQListItem:createItem(data)
    self.answerLabel:show()
    local answerLabelMarginLeft = self.titleMarginLeft
    self.answerLabel:setString(data[2])
    local answerLabelSize = self.answerLabel:getContentSize()    
    local h = linePadding + answerLabelSize.height
    self.bottomBackground_:size(self.contentWidth, h)
    self.bottomBackground_:setPositionY(h * 0.5 - FAQListItem.HEIGHT * 0.5 + 4)
    self.answerLabel:pos(-FAQListItem.WIDTH/2 + answerLabelMarginLeft, h * 0.5 - FAQListItem.HEIGHT * 0.5 + answerLabelMarginBottom)
end

function FAQListItem:createItem2(data)
    self.answerLabel:removeFromParent()
    local answerLabelMarginLeft = self.titleMarginLeft

    local answerLabel = ui.newTTFLabel({
            text = data[2][1],
            size = FAQListItem.ANSWER_SIZE, 
            color = FAQListItem.ANSWER_COLOR, 
            align = ui.TEXT_ALIGN_LEFT
        }):addTo(self.bottomPanel_)
    answerLabel:setAnchorPoint(cc.p(0, 0.5))

    --商城图标
    local storeIcon = display.newSprite("#store_btn_icon.png"):addTo(self.bottomPanel_)
    local answerLabel2 = ui.newTTFLabel({
            text = data[2][2],
            size = FAQListItem.ANSWER_SIZE, 
            color = FAQListItem.ANSWER_COLOR, 
            align = ui.TEXT_ALIGN_LEFT
        }):addTo(self.bottomPanel_)
    answerLabel2:setAnchorPoint(cc.p(0, 0.5))

    local padding = 10
    local answerLabelSize = answerLabel:getContentSize()    
    local h = linePadding + math.max(answerLabelSize.height, storeIcon:getContentSize().height)
    self.bottomBackground_:size(self.contentWidth, h)
    self.bottomBackground_:setPositionY(h * 0.5 - FAQListItem.HEIGHT * 0.5 + 4)
    answerLabel:pos(-FAQListItem.WIDTH/2 + answerLabelMarginLeft, h * 0.5 - FAQListItem.HEIGHT * 0.5 + answerLabelMarginBottom)
    storeIcon:pos(-FAQListItem.WIDTH/2 + answerLabelMarginLeft + padding + answerLabelSize.width + storeIcon:getContentSize().width/2, 
            h * 0.5 - FAQListItem.HEIGHT * 0.5 + answerLabelMarginBottom)
    answerLabel2:pos(-FAQListItem.WIDTH/2 + answerLabelMarginLeft + padding + answerLabelSize.width + storeIcon:getContentSize().width + padding, 
            h * 0.5 - FAQListItem.HEIGHT * 0.5 + answerLabelMarginBottom)
end

return FAQListItem