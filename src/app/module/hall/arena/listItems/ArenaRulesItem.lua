--
-- Author: XT
-- Date: 2015-07-30 09:28:52
-- 比赛场 规则说明列表的Item
local ArenaRulesItem = class("ArenaRulesItem", bm.ui.ListItem);
ArenaRulesItem.WIDTH = 0;
ArenaRulesItem.HEIGHT = 75;

ArenaRulesItem.ANSWER_SIZE = 20;
ArenaRulesItem.ANSWER_COLOR = cc.c3b(0x64, 0x9a, 0xc9);

function ArenaRulesItem:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    ArenaRulesItem.super.ctor(self, ArenaRulesItem.WIDTH, ArenaRulesItem.HEIGHT)

    self.contentWidth = ArenaRulesItem.WIDTH - 4
    local contentH = ArenaRulesItem.HEIGHT
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
    self.touchBtn_:setButtonSize(ArenaRulesItem.WIDTH, ArenaRulesItem.HEIGHT)
    self.touchBtn_:pos(ArenaRulesItem.WIDTH * 0.5, ArenaRulesItem.HEIGHT * 0.5)
    self.touchBtn_:addTo(self)

    --内容容器
    self.contentContainer_ = display.newNode():addTo(self):pos(ArenaRulesItem.WIDTH * 0.5, ArenaRulesItem.HEIGHT * 0.5)

    self.heightExtra_ = 0
    --底部详情面板
    self.bottomPanel_ = cc.ClippingNode:create():addTo(self.contentContainer_)
    self.bottomPanel_:setContentSize(cc.size(self.contentWidth, 1))

    self.stencil_ = display.newRect(ArenaRulesItem.WIDTH - 4, ArenaRulesItem.HEIGHT * 0.5, {fill=true, fillColor=cc.c4f(1, 1, 1, 1)})
        :align(display.BOTTOM_CENTER, -1, -ArenaRulesItem.HEIGHT * 0.5 - 14)
    self.bottomPanel_:setStencil(self.stencil_)

    --顶部面板
    self.topPanel_ = display.newNode():addTo(self.contentContainer_)

    --底部背景
    self.bottomHeight = 60
    self.bottomBackground_ = display.newScale9Sprite("#help_item_background_bottom.png"):addTo(self.bottomPanel_):size(self.contentWidth - 4, self.bottomHeight):pos(-1, 0)

    --顶部背景
    self.background_ = display.newScale9Sprite("#help_item_background_top.png")
    self.background_:setContentSize(cc.size(ArenaRulesItem.WIDTH - 7, ArenaRulesItem.HEIGHT))
    self.background_:addTo(self.topPanel_)
    self.background_:pos(- 1, 0)

    --折叠按钮
    local foldIconMarginLeft = 28
    self.foldIcon_ = display.newSprite("#store_list_triangle.png", ArenaRulesItem.WIDTH * -0.5 + foldIconMarginLeft, 0):addTo(self.topPanel_)
    self.foldIcon_:setAnchorPoint(cc.p(0.3, 0.5))

    --标题
    self.titleMarginLeft = foldIconMarginLeft + self.foldIcon_:getContentSize().width + 12
    self.title_ = ui.newTTFLabel({size=28, color=cc.c3b(0xca, 0xca, 0xca), align=ui.TEXT_ALIGN_LEFT}):pos(ArenaRulesItem.WIDTH * -0.5 + self.titleMarginLeft, 0)
        :addTo(self.topPanel_)
    self.title_:setAnchorPoint(cc.p(0, 0.5))
    self.title_:setString("data[1]data[1]")

    --解答
    local answerLabelPadding = 30 * 2
    self.answerLabel = ui.newTTFLabel({
            size = ArenaRulesItem.ANSWER_SIZE, 
            color = ArenaRulesItem.ANSWER_COLOR, 
            align = ui.TEXT_ALIGN_LEFT,
            valign = ui.TEXT_VALIGN_TOP,
            dimensions = cc.size(self.contentWidth - answerLabelPadding, 0)
        }):addTo(self.bottomPanel_):hide()
    self.answerLabel:setAnchorPoint(cc.p(0, 0.5))

    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.onEnterFrame_))
end

function ArenaRulesItem:onTouch_(evt)
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

function ArenaRulesItem:onEnterFrame_()
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
        self:unscheduleUpdate()
    else
        self.heightExtra_ = self.heightExtra_ + direction * math.max(1, math.abs(self.heightExtra_ - dest) * 0.08)
        if direction > 0 and self.heightExtra_ > dest or direction < 0 and self.heightExtra_ < dest then
            self.heightExtra_ = dest
        end
    end
    self.foldIcon_:rotation(90 * (self.heightExtra_ / (bottomHeight)))

    local contentHeight = ArenaRulesItem.HEIGHT + self.heightExtra_
    self.bottomPanel_:setPositionY(-self.heightExtra_)
    self:setContentSize(cc.size(ArenaRulesItem.WIDTH, ArenaRulesItem.HEIGHT + self.heightExtra_))
    self.contentContainer_:setPositionY(ArenaRulesItem.HEIGHT * 0.5 + self.heightExtra_)
    self.touchBtn_:setButtonSize(ArenaRulesItem.WIDTH, ArenaRulesItem.HEIGHT + self.heightExtra_)
    self.touchBtn_:setPositionY(contentHeight * 0.5)
    self.stencil_:setScaleY((ArenaRulesItem.HEIGHT * 0.2 + self.heightExtra_ ) / (ArenaRulesItem.HEIGHT * 0.5))
    self:dispatchEvent({name="RESIZE"})
end

function ArenaRulesItem:onFolded()
    local dest = 0
    local direction = -1
    local bottomHeight = self.bottomBackground_:getContentSize().height
    
    self.heightExtra_ = bottomHeight;
    self.foldIcon_:rotation(90 * (self.heightExtra_ / (bottomHeight)))

    local contentHeight = ArenaRulesItem.HEIGHT + self.heightExtra_
    self.bottomPanel_:setPositionY(-self.heightExtra_)
    self:setContentSize(cc.size(ArenaRulesItem.WIDTH, ArenaRulesItem.HEIGHT + self.heightExtra_))
    self.contentContainer_:setPositionY(ArenaRulesItem.HEIGHT * 0.5 + self.heightExtra_)
    self.touchBtn_:setButtonSize(ArenaRulesItem.WIDTH, ArenaRulesItem.HEIGHT + self.heightExtra_)
    self.touchBtn_:setPositionY(contentHeight * 0.5)
    self.stencil_:setScaleY((ArenaRulesItem.HEIGHT * 0.2 + self.heightExtra_ ) / (ArenaRulesItem.HEIGHT * 0.5))
    self.isFolded_ = false
end

function ArenaRulesItem:foldContent()
    if self.isFolded_ then
        self.isFolded_ = false
    else
        self.isFolded_ = true
    end
    self:unscheduleUpdate();
    self:scheduleUpdate();
    self:createItem(self.data_);
end

function ArenaRulesItem:onDataSet(dataChanged, data)
    if dataChanged then
        self.data_ = data
        self.title_:setString(data[1]);
        
        if not self.isFirstFold_ then
            -- self:foldContent();
            self.isFirstFold_ = true;
        end
    end
end

local answerLabelMarginBottom = 5
local linePadding = 26

function ArenaRulesItem:createItem(data)
    self.answerLabel:show()
    local answerLabelMarginLeft = self.titleMarginLeft
    self.answerLabel:setString(data[2])
    local answerLabelSize = self.answerLabel:getContentSize()    
    local h = linePadding + answerLabelSize.height
    self.bottomBackground_:size(self.contentWidth - 4, h)
    self.bottomBackground_:setPositionY(h * 0.5 - ArenaRulesItem.HEIGHT * 0.5-1)
    self.answerLabel:pos(-ArenaRulesItem.WIDTH/2 + answerLabelMarginLeft, h * 0.5 - ArenaRulesItem.HEIGHT * 0.5 + answerLabelMarginBottom)
end

return ArenaRulesItem;