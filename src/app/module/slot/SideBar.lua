--
-- Author: viking@boomegg.com
-- Date: 2014-11-21 12:00:32
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--
local SideBar = class("SideBar", function()
    return display.newNode()
end)

local sideBtnWidth = 37
local sideBtnHeight = 85
SideBar.WIDTH = sideBtnWidth
SideBar.HEIGHT = sideBtnHeight

function SideBar:ctor(callback)
    self.callback_ = callback
    self.schedulerPool_ = bm.SchedulerPool.new()

    --触摸区域
    local touchWidth = sideBtnWidth * 2
    local touchHeight = sideBtnHeight + 40
    self.touchNode_ = display.newScale9Sprite("#transparent.png"):size(touchWidth, touchHeight):addTo(self)
    self.touchNode_:setTouchEnabled(true)
    self.touchNode_:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onSideBtnListener_))

    -- 按钮
    self.sideBtn_ = display.newSprite("#slot_side_btn_bg.png"):addTo(self)
    -- self.sideBtn_:setTouchEnabled(true)
    -- self.sideBtn_:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onSideBtnListener_))

    local offsetX = 0
    local offsetY = 5
    self.normalIcon_ = display.newSprite("#slot_side_btn_icon_up.png"):addTo(self):pos(offsetX, offsetY)
    self.pressedIcon_ = display.newSprite("#slot_side_btn_icon_down.png"):addTo(self):pos(offsetX, offsetY):hide()

    self.glowImage_ = display.newSprite("#slot_side_btn_icon_glow.png")
        :pos(offsetX, offsetY)
        :addTo(self)
        :hide()
end

function SideBar:onSideBtnListener_(event)
    local name, x, y = event.name, event.x, event.y
    local isTouchInSprite = self.touchNode_:getCascadeBoundingBox():containsPoint(cc.p(x, y))
    if name == "began" then
        if not isTouchInSprite then 
            return false 
        end
        self.startX = x
        return true
    elseif name == "moved" then
        self.currentX = x
        self:notifyTouchChanged("moved")
        if isTouchInSprite then
            return true
        else
            return false 
        end
      elseif name == "cancelled" then
          self.currentX = x    
      elseif name == "ended" then
          self.currentX = x
          if isTouchInSprite and self.startX == self.currentX then
              self:notifyTouchChanged("clicked")
            return true
        else
            self:notifyTouchChanged("ended")
            return false 
        end                                        
    end
end

function SideBar:notifyTouchChanged(evtName)
    if self.callback_ then
        self.callback_(evtName, {startX = self.startX, currentX = self.currentX})
    end
end

function SideBar:setGlow(isGlow)
    self.glowImage_:setVisible(isGlow)
end

function SideBar:getContentSize()
    return cc.size(sideBtnWidth, sideBtnHeight)
end

function SideBar:handlerAnim(delay)
    self.normalIcon_:hide()
    self.pressedIcon_:show()
    self.schedulerPool_:clearAll()
    self.schedulerPool_:delayCall(function()
        self.normalIcon_:show()
        self.pressedIcon_:hide()
    end, delay or 0.2)
end

function SideBar:glowAnim(delay)
    self:setGlow(true)
    self.schedulerPool_:delayCall(function()
        self:setGlow(false)
    end, delay or 2)
end

function SideBar:dispose()
    self.schedulerPool_:clearAll()
end

return SideBar