--
-- Author: viking@boomegg.com
-- Date: 2014-12-18 10:54:42
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--
local Panel = import("app.pokerUI.Panel")
local TutorialPopup = class("TutorialPopup", Panel)

local TopHeight = 60
local BottomHeight = 30

local ImageWidth = 866
local ImageHeight = 378

TutorialPopup.WIDTH = ImageWidth
TutorialPopup.HEIGHT = ImageHeight + TopHeight + BottomHeight

local titleTextSize = 26
local titleTextColor = cc.c3b(0x27, 0x90, 0xd5)

function TutorialPopup:ctor()
    TutorialPopup.super.ctor(self, {TutorialPopup.WIDTH, TutorialPopup.HEIGHT})
    self:setupView()
end

function TutorialPopup:setupView()
    self:addCloseBtn()
    self.indexs = 4
    self.currentIndex_ = 1
    self.titleTexts = {
        bm.LangUtil.getText("TUTORIAL", "VIEW1_TITLE"),
        bm.LangUtil.getText("TUTORIAL", "VIEW2_TITLE"),
        bm.LangUtil.getText("TUTORIAL", "VIEW3_TITLE"),
        bm.LangUtil.getText("TUTORIAL", "VIEW3_TITLE"),
    }

    --title
    local titileMarginTop = 6
    self.titleLabel_ = ui.newTTFLabel({
            text = self.titleTexts[1],
            size = titleTextSize,
            color = titleTextColor,
            align = ui.TEXT_ALIGN_CENTER
        })
        :addTo(self)
    local titleSize = self.titleLabel_:getContentSize()
    self.titleLabel_:pos(0, TutorialPopup.HEIGHT/2 - TopHeight/2 + titileMarginTop)

    --触摸区域
    self.touchNode_ = display.newScale9Sprite("#transparent.png"):size(ImageWidth, ImageHeight):addTo(self)
    self.touchNode_:setTouchEnabled(true)
    self.touchNode_:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouchListner_))

    --图片
    self.viewNode_ = display.newNode()
    display.newSprite("tutorial_1.jpg"):addTo(self.viewNode_)
    display.newSprite("tutorial_2.jpg"):addTo(self.viewNode_):pos(ImageWidth, 0)
    display.newSprite("tutorial_3.jpg"):addTo(self.viewNode_):pos(ImageWidth*2, 0)
    display.newSprite("tutorial_4.jpg"):addTo(self.viewNode_):pos(ImageWidth*3, 0)

    --遮罩
    local viewClipNode_ = cc.ClippingNode:create():addTo(self)
    local stencil = display.newDrawNode()
    stencil:drawPolygon({
             {-ImageWidth/2, -ImageHeight/2},
             {-ImageWidth/2, ImageHeight/2},
             {ImageWidth/2, ImageHeight/2},
             {ImageWidth/2, -ImageHeight/2}
        })
    viewClipNode_:setStencil(stencil)
    viewClipNode_:addChild(self.viewNode_)

    --下部点组
    local dotPadding = 10
    local dotWidth = 18
    local dotHeight = 18
    local dotMarginBottom = 8
    local dotPosY = -TutorialPopup.HEIGHT/2 + BottomHeight/2 + dotMarginBottom
    local batchNode = display.newBatchNode("hall_texture.png", self.indexs):addTo(self)

    local index4PosX = dotPadding/2 + dotWidth + dotPadding + dotWidth/2
    display.newSprite("#tutorial_dot_bg.png"):addTo(batchNode):pos(index4PosX, dotPosY)--4

    local index3PosX = dotPadding/2 + dotWidth/2
    display.newSprite("#tutorial_dot_bg.png"):addTo(batchNode):pos(index3PosX, dotPosY)--3

    local index2PosX = -dotPadding/2 - dotWidth/2
    display.newSprite("#tutorial_dot_bg.png"):addTo(batchNode):pos(index2PosX, dotPosY)--2

    local index1PosX = -dotPadding/2 - dotWidth - dotPadding - dotWidth/2
    display.newSprite("#tutorial_dot_bg.png"):addTo(batchNode):pos(index1PosX, dotPosY)--1

    self.indexNode_ = display.newSprite("#tutorial_dot_fg.png"):addTo(batchNode):pos(index1PosX, dotPosY)
    self.indexPos_ = {index1PosX, index2PosX, index3PosX, index4PosX}
end

function TutorialPopup:onTouchListner_(event)
    local name, x, y = event.name, event.x, event.y
    local isTouchInSprite = self.touchNode_:getCascadeBoundingBox():containsPoint(cc.p(x, y))
    -- print("Handler:onTouchListner_", name, x, isTouchInSprite)

    if name == "began" then
        if not isTouchInSprite then 
            return false 
        end
        self.startX = x
        return true
    elseif name == "moved" then
        self.currentX = x
        if isTouchInSprite then
            self:notifyTouchChanged(name)
            return true
        else
            return false 
        end
      elseif name == "cancelled" then
          self.currentX = x    
      elseif name == "ended" then
          self.currentX = x
          if isTouchInSprite then
              if self.currentX ~= self.startX then
                  self:notifyTouchChanged(name)
              end
            return true
        else
            return false 
        end                                        
    end
end

local MIN_DISTANCE = 5
function TutorialPopup:notifyTouchChanged(name)
    local distance = self.currentX - self.startX
    if math.abs(distance) < MIN_DISTANCE then
        return
    end

    if name == "moved" then
        --todo
    elseif name == "ended" then
        if distance < 0 then    --right
            self:viewChange("right", self.currentIndex_)
        else                       --left
            self:viewChange("left", self.currentIndex_)
        end
    end

end

function TutorialPopup:viewChange(direction, index)
    local srcX = self.viewNode_:getPositionX()
    if direction == "right" then
        if index == self.indexs then
            return
        else
            self.currentIndex_ = self.currentIndex_ + 1
            if self.currentIndex_ >  self.indexs then
                self.currentIndex_ = self.indexs
            end
            transition.moveTo(self.viewNode_, {time = 0.2, x = srcX - ImageWidth})
            self:dotPosChange(self.currentIndex_)
        end
    elseif direction == "left" then
        if index == 1 then
            return
        else
            self.currentIndex_ = self.currentIndex_ - 1
            if self.currentIndex_ < 1 then
                self.currentIndex_ = 1
            end
            transition.moveTo(self.viewNode_, {time = 0.2, x = srcX + ImageWidth})
            self:dotPosChange(self.currentIndex_)
        end
    end 
end

function TutorialPopup:dotPosChange(index)
    transition.moveTo(self.indexNode_, {time = 0.2, x = self.indexPos_[index], 
        onComplete = function()
            self:titleTextChange(index)
        end})
end

function TutorialPopup:titleTextChange(index)
    self.titleLabel_:setString(self.titleTexts[index])
end

function TutorialPopup:show()
    self:showPanel_(true, true, true)
    return self
end

return TutorialPopup