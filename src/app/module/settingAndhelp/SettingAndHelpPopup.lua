--
-- Author: viking@boomegg.com
-- Date: 2014-08-21 17:35:59
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local Panel = import("app.pokerUI.Panel")
local SettingAndHelpPopup = class("SettingAndHelpPopup", Panel)

local SettingView = import(".setting.SettingView")
local HelpView = import(".help.HelpView")

SettingAndHelpPopup.TAB_SETTING = 1
SettingAndHelpPopup.TAB_HELP    = 2

SettingAndHelpPopup.CLOSEBTN_PADDING = 10
SettingAndHelpPopup.TAB_HEIGHT = nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT
SettingAndHelpPopup.PADDING = 11

local POP_WIDTH = 815
local POP_HEIGHT = 520
local LIST_WIDTH = 890
local LIST_HEIGHT = 372

function SettingAndHelpPopup:ctor(isInRoom, isHelp, helpSubTab)
    self:setNodeEventEnabled(true)
    SettingAndHelpPopup.super.ctor(self, {POP_WIDTH, POP_HEIGHT})

    self.isInRoom = isInRoom

    if isHelp then
        self.CURRENT_TAB = SettingAndHelpPopup.TAB_HELP
        if helpSubTab then
            self.helpSubTab_ = helpSubTab
        end
    else
        self.CURRENT_TAB = SettingAndHelpPopup.TAB_SETTING
    end

    self:setupView()
end

function SettingAndHelpPopup:setupView()
    local touchCover = display.newScale9Sprite("#transparent.png", 0, self.height_ * 0.5 - 38, cc.size(POP_WIDTH, 76)):addTo(self, 9)
    touchCover:setTouchEnabled(true)
    touchCover:setTouchSwallowEnabled(true)

    --修改背景框
    self:setBackgroundStyle1()

    --TAB title
    self.tabLayout = nk.ui.CommonPopupTabBar.new(
        {
            popupWidth = POP_WIDTH, 
            scale = 458/POP_WIDTH, --458 CommonPopupTabBar 宽度 
            btnText = {bm.LangUtil.getText("SETTING", "TITLE"), bm.LangUtil.getText("HELP", "TITLE")}
        })
        :pos(0, self.height_ * 0.5 - nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5 - 32)
        :addTo(self, 10)

    self:addTopDivide(nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5)
    self:addTopIcon("#pop_setting_icon.png", -8)

    if self.CURRENT_TAB == SettingAndHelpPopup.TAB_HELP then
        self.helpContent = HelpView.new(self, self.helpSubTab_):addTo(self):show()
    else
        self.settingContent = SettingView.new(self):addTo(self):show()
    end

    self:addCloseBtn()
    self:setCloseBtnOffset(0, -16)

    self.tabLayout:gotoTab(self.CURRENT_TAB)
end

function SettingAndHelpPopup:show()
    self:showPanel_(true, true, true)
    return self
end

function SettingAndHelpPopup:notifyContent(currentTab)
    self.CURRENT_TAB = currentTab
    if self.CURRENT_TAB == SettingAndHelpPopup.TAB_HELP then
        if self.settingContent then
            self.settingContent:hide()
        end

        if not self.helpContent then
            self.helpContent = HelpView.new(self, self.helpSubTab_):addTo(self)
            self.helpContent:onShowed()
        end
        self.helpContent:show()
    else
        if self.helpContent then
            self.helpContent:hide()
        end

        if not self.settingContent then
            self.settingContent = SettingView.new(self):addTo(self)
            self.settingContent:onShowed()
        end
        self.settingContent:show()
    end
end

function SettingAndHelpPopup:onShowed()
    self.tabLayout:onTabChange(handler(self, self.notifyContent))
    if self.settingContent then
        self.settingContent:onShowed()
    end

    if self.helpContent then
        self.helpContent:onShowed()
    end
end

return SettingAndHelpPopup