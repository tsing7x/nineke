--
-- Author: Jonah0608@gmail.com
-- Date: 2015-05-11 10:24:48
--
-- 用于debug 选项配置   DEBUG >= 5时 点击登录界面右上角点出现
-- Note:目前主要用于后端服务器选择和语言切换，如果需要其他功能，请重构它

local WIDTH = 720
local HEIGHT = 480
local TOP = HEIGHT*0.5
local BOTTOM = -HEIGHT*0.5
local LEFT = -WIDTH*0.5
local RIGHT = WIDTH*0.5
local TOP_HEIGHT = 64

local PHPServerUrl = import("app.PHPServerUrl")
local ActivityServerUrl = import("app.ActivityServerUrl")
local DebugPopup = class("DebugPopup", nk.ui.Panel)

DebugPopup.RADIO_BUTTON_IMAGES = {
    off = "#common_blue_btn_up.png",
    off_pressed = "#common_blue_btn_down.png",
    off_disabled = "#common_btn_disabled.png",
    on = "#common_red_btn_up.png",
    on_pressed = "#common_red_btn_down.png",
    on_disabled = "#common_btn_disabled.png",
}


function DebugPopup:ctor()
    DebugPopup.super.ctor(self,{WIDTH,HEIGHT})
    self:setNodeEventEnabled(true)
    self.title_ = ui.newTTFLabel({text="调试选项", size=30, color=cc.c3b(0xd7, 0xf6, 0xff), align=ui.TEXT_ALIGN_CENTER})
        :pos(0, TOP - 35)
        :addTo(self)
    self:addLangConfig()
    self:addPhpServerUrlConfig()
    self:addCloseBtn()
end

function DebugPopup:addLangConfig()
    cc.ui.UILabel.new({text = "语言选择", size=24, color = cc.c3b(0xd7, 0xf6, 0xff)})
        :align(display.CENTER_TOP,LEFT + 100, TOP - 80)
        :addTo(self)
    local group = cc.ui.UICheckBoxButtonGroup.new(display.TOP_TO_BOTTOM)
        :addButton(cc.ui.UICheckBoxButton.new(DebugPopup.RADIO_BUTTON_IMAGES)
            :setButtonLabel(cc.ui.UILabel.new({text = "中文", color = display.COLOR_WHITE}))
            :setButtonLabelOffset(30, 0)
            :align(display.LEFT_CENTER))
        :addButton(cc.ui.UICheckBoxButton.new(DebugPopup.RADIO_BUTTON_IMAGES)
            :setButtonLabel(cc.ui.UILabel.new({text = "英语", color = display.COLOR_WHITE}))
            :setButtonLabelOffset(30, 0)
            :align(display.LEFT_CENTER))
        :addButton(cc.ui.UICheckBoxButton.new(DebugPopup.RADIO_BUTTON_IMAGES)
            :setButtonLabel(cc.ui.UILabel.new({text = "泰语", color = display.COLOR_WHITE}))
            :setButtonLabelOffset(30, 0)
            :align(display.LEFT_CENTER))
        :addButton(cc.ui.UICheckBoxButton.new(DebugPopup.RADIO_BUTTON_IMAGES)
            :setButtonLabel(cc.ui.UILabel.new({text = "越南语", color = display.COLOR_WHITE}))
            :setButtonLabelOffset(30, 0)
            :align(display.LEFT_CENTER))
        :setButtonsLayoutMargin(10, 10, 10, 10)
        :onButtonSelectChanged(function(event)
            print("Option %d selected, Option %d unselected", event.selected, event.last)
            DebugPopup:switchLang_(self:langIndexToStr_(event.selected))
        end)
        :align(display.LEFT_TOP,LEFT + 50, TOP - 250)
        :addTo(self)
    group:getButtonAtIndex(self:langStrToIndex_(appconfig.LANG_FILE_NAME))
        :setButtonSelected(true)
end

function DebugPopup:addPhpServerUrlConfig()
    cc.ui.UILabel.new({text = "服务器选择", size=24, color = cc.c3b(0xd7, 0xf6, 0xff)})
        :align(display.CENTER_TOP,LEFT + 300, TOP - 80)
        :addTo(self)
    local group = cc.ui.UICheckBoxButtonGroup.new(display.TOP_TO_BOTTOM)
        :setButtonsLayoutMargin(10, 10, 10, 10)
        :onButtonSelectChanged(function(event)
            --DebugPopup:switchPhpServer_(PHPServerUrl[event.selected].url)
            DebugPopup:switchServer_(event.selected)
        end)
        :align(display.LEFT_TOP,LEFT + 250, TOP - 250)
        :addTo(self)
    for i = 1,#PHPServerUrl do
        group:addButton(cc.ui.UICheckBoxButton.new(DebugPopup.RADIO_BUTTON_IMAGES)
            :setButtonLabel(cc.ui.UILabel.new({text = PHPServerUrl[i].name, color = display.COLOR_WHITE}))
            :setButtonLabelOffset(30, 0)
            :align(display.LEFT_CENTER))
    end
    group:getButtonAtIndex(self:getUrlIndex_(appconfig.LOGIN_SERVER_URL))
        :setButtonSelected(true)
end

function DebugPopup:switchPhpServer_(url)
    appconfig.LOGIN_SERVER_URL = url
end

function DebugPopup:switchServer_(index)
    -- body
    appconfig.LOGIN_SERVER_URL = PHPServerUrl[index].url
    appconfig.ACTIVITY_URL = ActivityServerUrl[index].url
end

function DebugPopup:switchLang_(lang)
    appconfig.LANG_FILE_NAME = lang
    bm.LangUtil = nil
    bm.LangUtil = import("boomegg.lang.LangUtil")
    bm.LangUtil.reload()
end

function DebugPopup:langIndexToStr_(index)
    if index == 1 then
        return "lang"
    elseif index == 2 then
        return "lang_en"
    elseif index == 3 then
        return "lang_th"
    elseif index == 4 then
        return "lang_vn"
    end

end

function DebugPopup:langStrToIndex_(str)
    if str == "lang" then
        return 1
    elseif str == "lang_en" then
        return 2
    elseif str == "lang_th" then
        return 3
    elseif str == "lang_vn" then
        return 4
    end
end

function DebugPopup:getUrlIndex_(url)
    for i = 1,#PHPServerUrl do
        if PHPServerUrl[i].url == url then
            return i
        end
    end
    return 1 -- 增加一点容错~
end

function DebugPopup:show()
    self:showPanel_()
end

function DebugPopup:hide()
    self:hidePanel_()
end

return DebugPopup
