local Dialog = import("app.pokerUI.Dialog")

local MatchStartPopup = class("MatchStartPopup", Dialog)
local AnimationDownNum = import("app.module.room.views.AnimationDownNum")

local timeStr
local countAction

function MatchStartPopup:ctor(args)
    self.modalBg_ = display.newScale9Sprite("#modal_texture.png", 0, 0, cc.size(display.width, display.height))
        :addTo(self)
    self.modalBg_:setTouchEnabled(true)
    self.modalBg_:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onModalBgTouch_))
    
	MatchStartPopup.super.ctor(self, args)

    self.time_ = args.time
    timeStr = (self.time_ > 0 and bm.LangUtil.getText("MATCH", "JOINGAME_COUNT",tostring(self.time_))) or ""
    self.timeTxt = ui.newTTFLabel({text = timeStr, color = cc.c3b(0xff, 0x00, 0x00), size = 25, align = ui.TEXT_ALIGN_CENTER})
        :pos(0, -40)
        :addTo(self):hide();
    
    self.animationDownNum_ = AnimationDownNum.new({
        parent=self,
        px=0,
        py=-40, 
        time=args.time, 
        scale=0.5, 
        refreshCallback=function(retVal)
            self:refreshRenderInfo(retVal);
        end,
        callback=function()
            self:endDownTimeCallback();
        end});
end

function MatchStartPopup:onModalBgTouch_()
end

function MatchStartPopup:refreshRenderInfo(val)
end

function MatchStartPopup:endDownTimeCallback()
    local curScene = display.getRunningScene()
    if curScene and curScene.controller and curScene.controller.resetMatchGuide then
        curScene.controller:resetMatchGuide()
    end
    self:onClose()
end

function MatchStartPopup:countFunc()
    self.time_ = self.time_ - 1
    if self.time_ <= 0 then
        local curScene = display.getRunningScene()
        if curScene and curScene.controller and curScene.controller.resetMatchGuide then
            curScene.controller:resetMatchGuide()
        end
        self:onClose()
    end
end

function MatchStartPopup:showTime()
    timeStr = (self.time_ > 0 and bm.LangUtil.getText("MATCH", "JOINGAME_COUNT",tostring(self.time_))) or ""
    if self.timeTxt then
        self.timeTxt:setString(timeStr)
    end
end

function MatchStartPopup:onClose()
    if self.parent_ and self.parent_.showMatchStartTimes then
        self.parent_.showMatchStartTimes = self.parent_.showMatchStartTimes - 1
        if self.parent_.showMatchStartTimes<0 then
            self.parent_.showMatchStartTimes = 0
        end
    end
    MatchStartPopup.super.onClose(self)
end

-- 按钮点击事件处理
function MatchStartPopup:onButtonClick_(event)
    if self.parent_ and self.parent_.showMatchStartTimes then
        self.parent_.showMatchStartTimes = self.parent_.showMatchStartTimes - 1
        if self.parent_.showMatchStartTimes<0 then
            self.parent_.showMatchStartTimes = 0
        end
    end

    MatchStartPopup.super.onButtonClick_(self,event)
end

function MatchStartPopup:show(parent)
    self.parent_ = parent
    if parent then
        self:addTo(parent,1000-1)
        self:pos(display.cx, display.cy)
    end

    return self
end

function MatchStartPopup:hidePanel_()
    self.animationDownNum_:cleanUp()
    
    if countAction then
        self:stopAction(countAction)
    end

    self:removeFromParent()

    return self
end

return MatchStartPopup