--
-- Author: Jonah0608@gmail.com
-- Date: 2015-05-11 10:24:48
--
-- 用于debug 选项配置   DEBUG >= 5时 点击登录界面右上角点出现
-- Note:目前主要用于后端服务器选择和语言切换，如果需要其他功能，请重构它

DebugTstPopup = class("DebugTstPopup", nk.ui.Panel)

local WIDTH = 720
local HEIGHT = 480
local TOP = HEIGHT*0.5
local BOTTOM = -HEIGHT*0.5
local LEFT = -WIDTH*0.5
local RIGHT = WIDTH*0.5

DebugTstPopup.tstOutput = "zcc"
DebugTstPopup.saved_day = "zcc"
DebugTstPopup.today = "zcc"

function DebugTstPopup:ctor()
    DebugTstPopup.super.ctor(self,{WIDTH,HEIGHT})
    self:setNodeEventEnabled(true)
    self.title_ = ui.newTTFLabel({text="调试输出", size=30, color=cc.c3b(0xd7, 0xf6, 0xff), align=ui.TEXT_ALIGN_CENTER})
        :pos(0, TOP - 35)
        :addTo(self)
    
end

function DebugTstPopup:show()
    self.output_ = ui.newTTFLabel({text=DebugTstPopup.tstOutput, size=20, color=cc.c3b(0xd7, 0xf6, 0xff), align=ui.TEXT_ALIGN_CENTER})        
        :pos(0, 100)
        :addTo(self)

    self.output_ = ui.newTTFLabel({text=DebugTstPopup.saved_day, size=20, color=cc.c3b(0xd7, 0xf6, 0xff), align=ui.TEXT_ALIGN_CENTER})        
        :pos(0, 0)
        :addTo(self)

    self.output_ = ui.newTTFLabel({text=DebugTstPopup.today, size=20, color=cc.c3b(0xd7, 0xf6, 0xff), align=ui.TEXT_ALIGN_CENTER})        
        :pos(0, -100)
        :addTo(self)

    self.output_:setDimensions(200, 300)

    self:showPanel_()
end

function DebugTstPopup:hide()
    self:hidePanel_()
end

return DebugTstPopup
