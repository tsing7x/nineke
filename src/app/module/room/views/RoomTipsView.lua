--
-- Author: tony
-- Date: 2014-09-11 16:02:33
--
local RoomTipsView = class("RoomTipsView", function() return display.newNode() end)

RoomTipsView.WIDTH = display.width * 0.7 - 16

local TIPS = bm.LangUtil.getText("ROOM", "TIPS")
local INTERVAL = 30
local TEXT_COLOR = cc.c3b(0x0c, 0xd4, 0x3f)

function RoomTipsView:ctor()
    self.background_ = display.newScale9Sprite("#room_tips_background.png", 0, 0, cc.size(RoomTipsView.WIDTH, 72)):addTo(self)
    self.schedulerPool_ = bm.SchedulerPool.new()
    self.isPlaying_ = false
    self.indexArr_ = self:randomIndexArr_(#TIPS)
    self.currentIndex_ = 1
    self.clip_ = cc.ClippingNode:create():addTo(self)
    local w, h = RoomTipsView.WIDTH - 4, 72 - 4
    local stencil = display.newDrawNode()
    local pn = {{-0.5 * w, -0.5 * h}, {-0.5 * w,  0.5 * h}, {0.5 * w, 0.5 * h}, {0.5 * w, -0.5 * h}}  
    local clr = cc.c4f(255, 0, 0, 255)  
    stencil:drawPolygon(pn, clr, 1, clr)
    self.clip_:setStencil(stencil)
    self.label_ = ui.newTTFLabel({size=24, color=TEXT_COLOR,
            text=TIPS[self.currentIndex_],
            dimensions=cc.size(RoomTipsView.WIDTH - 8, 72),
            align=ui.TEXT_ALIGN_CENTER})
        :addTo(self.clip_)
end

function RoomTipsView:play()
    if not self.isPlaying_ then
        self.isPlaying_ = true
        self.schedulerPool_:clearAll()
        self.schedulerPool_:delayCall(handler(self, self.playNext_), INTERVAL)
    end
    return self
end

function RoomTipsView:stop()
    if self.isPlaying_ then
        self.isPlaying_ = false
        self.schedulerPool_:clearAll()
    end
    return self
end

function RoomTipsView:playNext_()
    if self.isPlaying_ then
        self.currentIndex_ = self.currentIndex_ + 1
        if self.currentIndex_ > #TIPS then
            self.currentIndex_ = 1
        end
        local nextLabel = ui.newTTFLabel({size=24, color=TEXT_COLOR,
                text=TIPS[self.currentIndex_],
                dimensions=cc.size(RoomTipsView.WIDTH - 8, 72),
                align=ui.TEXT_ALIGN_CENTER})
            :pos(0, -72)
            :addTo(self.clip_)
        transition.moveTo(nextLabel,{time=0.5, easing="OUT", y=0})
        transition.moveBy(self.label_, {time=0.5, easing="OUT", y=72, onComplete=function()
            self.label_:removeFromParent()
            self.label_ = nextLabel
            if self.isPlaying_ then
                self.schedulerPool_:clearAll()
                self.schedulerPool_:delayCall(handler(self, self.playNext_), INTERVAL)
            end
        end})
    end
end

function RoomTipsView:randomIndexArr_(total)
    local src = {}
    for i = 1, total do
        src[i] = i
    end
    local ret = {}
    while #src > 0 do
        local len = #src
        local idx = 1
        if len > 1 then
            math.newrandomseed()
            idx = math.random(1, len)
        end
        table.insert(ret, table.remove(src, idx))
    end
    return ret
end

return RoomTipsView