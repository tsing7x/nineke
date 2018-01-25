-- Facebook帐号切换提醒弹窗
-- Author: Quinn
-- Date: 2015-05-10 00:00:19
--

local FbGuidePopup = class('FbGuidePopup', nk.ui.Panel)

local SettingAndHelpPopup = import("app.module.settingAndhelp.SettingAndHelpPopup")

local f1 = 1.25
local W, H = 480 * f1, 320 * f1
local f2 = 1.08
local CW, CH = 480 * f2, 320 - 100 * f2

local topTitleSize = 28
local topTitleColor = cc.c3b(0x64, 0x9a, 0xc9)

local contentSize = 22
local contentColor = cc.c3b(0xca, 0xca, 0xca)

function FbGuidePopup:ctor()
    FbGuidePopup.super.ctor(self, {W, H})

    self:addCloseBtn() -- base class method

    -- 标题: 推荐使用facebook登录
    ui.newTTFLabel({
        text  = bm.LangUtil.getText("FBGUIDE", "TITLE"),
        size  = topTitleSize,
        color = topTitleColor,
        align = ui.TEXT_ALIGN_CENTER,
    })
        :pos(0, H / 2 - 40)
        :addTo(self)

    -- 内容背景框
    display.newScale9Sprite(
        "#panel_overlay.png",
        0, 0,
        cc.size(CW, CH)
    )
        :addTo(self)

    -- 推荐原因1
    local line_1 = ui.newTTFLabel({
        text = bm.LangUtil.getText('FBGUIDE', 'LINE_1'),
        color = styles.FONT_COLOR.LIGHT_TEXT,
        size = contentSize,
        align = ui.TEXT_ALIGN_LEFT,
    })
        :pos(60 - W / 2, 40) -- 左侧起 60像素 左对齐
        :addTo(self)
    line_1:setAnchorPoint(0, 0.5)

    -- 推荐原因2
    local line_2 = ui.newTTFLabel({
        text = bm.LangUtil.getText('FBGUIDE', 'LINE_2'),
        color = styles.FONT_COLOR.LIGHT_TEXT,
        size = contentSize,
        align = ui.TEXT_ALIGN_LEFT,
    })
        :pos(60 - W / 2, -40)
        :addTo(self)
    line_2:setAnchorPoint(0, 0.5)

    -- 按钮
    local switchLoginLabel = ui.newTTFLabel({
        text = bm.LangUtil.getText('FBGUIDE', 'SWITCH_FB_BTN_TEXT'),
        color = styles.FONT_COLOR.LIGHT_TEXT,
        size = 20,
        align = ui.TEXT_ALIGN_CENTER
    })
    local switchLoginBtn = cc.ui.UIPushButton.new({
        normal = '#common_dark_blue_btn_up.png',
        pressed = '#common_dark_blue_btn_down.png',
        disabled = '#common_btn_disabled.png'
    }, { scale9 = true}
    )
        :setButtonSize(180, 52)
        :setButtonLabel('normal', switchLoginLabel)
        :pos(160, -(CH / 2 + 45))
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.onBtnSwitchToFbLoginClick))
end

function FbGuidePopup:onEnter()
    self.controller_:init()
    if FbGuidePopup.super.onEnter then
        FbGuidePopup.super.onEnter(self)
    end
end

function FbGuidePopup:onExit()
    self.controller_:dispose()
    if FbGuidePopup.super.onExit then
        FbGuidePopup.super.onExit(self)
    end
end

-- 显示 note: 关闭按钮在panel中
function FbGuidePopup:showPopup()
    self:showPanel_(true, true, true, true)
end

function FbGuidePopup:closePopup_()
    self:onClose()
    nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
end

-- 打开设置界面 引导至游客的退出 -> fb登录流程
function FbGuidePopup:onBtnSwitchToFbLoginClick(evt)
    SettingAndHelpPopup.new():show()
    self:closePopup_()
end

return FbGuidePopup
