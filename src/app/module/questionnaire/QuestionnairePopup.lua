--
-- Author: HLF(IdaHuang@boyaa.com)
-- Date: 2016-02-23 15:40:48
--
local QuestionnairePopup = class("QuestionnairePopup", nk.ui.Panel)
local WIDTH = 786
local HEIGHT = 450
local TOP = HEIGHT*0.5
local BOTTOM = -HEIGHT*0.5
local LEFT = -WIDTH*0.5
local RIGHT = WIDTH*0.5
local TOP_HEIGHT = 30
local PADDING = 10
local BUTTON_W = 180;
local BUTTON_H = 48;

local GOTO_URL = "https://goo.gl/forms/Gkd5DSM2TfmPp01F2"
local TITLE_TXT = "แบบสอบถามห้องศึกชิงพิภพ"
local DESC_TXT = "สวัสดีค่ะ แบบสอบถามฉบับนี้จัดทำขึ้นเพื่อสอบถามความรู้สึกที่เพื่อนๆมีต่อห้องศึกกชิงพิภพ รบกวนทุกท่านให้ความร่วมมือในการทำแบบสอบฉบับนี้ตามความจริง หลังทำเสร็จแล้ว 【รางวัลชิปรออยู่】 ขอบคุณมากค่ะ "
local BTN_TXT = "ทำทันที"

function QuestionnairePopup:ctor()
    GOTO_URL = nk.userData.questionUrl or GOTO_URL
    QuestionnairePopup.super.ctor(self, {WIDTH, HEIGHT})
    self:setNodeEventEnabled(true)
    self:setupView()
    self:addCloseBtn()
end

function QuestionnairePopup:onCleanup()
    self.feedListData_ = nil
end

function QuestionnairePopup:setupView()
    local sz;
    local TDH = 59;
    local px, py = 0, HEIGHT*0.5-TDH*0.5;
    local titleTxt = ui.newTTFLabel({
            text=nk.userData.questionTitle or TITLE_TXT,
            color=cc.c3b(0x27, 0x8e, 0xd1),
            size=46,
            align=ui.TEXT_ALIGN_CENTER
        })
        :addTo(self, 1)
    sz = titleTxt:getContentSize();
    titleTxt:pos(80, py)
    if sz.width > 475 then
        titleTxt:setScale(475/sz.width)
    else
        titleTxt:setScale(1)
    end

    local barBg = display.newSprite("Questionnaire_bar.png")
        :addTo(self)
    local bsz = barBg:getContentSize();
    py = py-TDH*0.5-bsz.height*0.5-15;
    barBg:pos(-7, py+76)
    local txtDesc = ui.newTTFLabel({
            text=nk.userData.questionDesc or DESC_TXT,
            color=cc.c3b(0xb1, 0xb1, 0xb1),
            size=22,
            align=ui.TEXT_ALIGN_CENTER,
            dimensions=cc.size(WIDTH-50, 0),
        })
        :addTo(self)
    sz = txtDesc:getContentSize();
    py = py - 156*0.5 - sz.height*0.5 + 30;
    txtDesc:pos(px, py)

    local px, py = 0, -HEIGHT*0.5 + BUTTON_H;
    local btn = cc.ui.UIPushButton.new({normal="#common_green_btn_up.png", pressed="#common_green_btn_up.png"}, {scale9=true})
        :setButtonSize(BUTTON_W, BUTTON_H)
        :setButtonLabel(ui.newTTFLabel({text=BTN_TXT, color=styles.FONT_COLOR.LIGHT_TEXT,size=24}))
        :pos(px, py)
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.onBtnClicked_))
end

function QuestionnairePopup:onBtnClicked_()
    local W, H = 860, 614 - 72
    if device.platform == 'ios' then
        local function start()
        end
        local function finish()
        end
        local function fail(error_info)
        end
        local function userClose()
            nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
        end
        local function shouldStartLoad()
            return true
        end

        local x, y = display.cx - W / 2, display.cy - H / 2
        local view, err = Webview.create(start, finish, fail, userClose, shouldStartLoad)
        if view then
            view:show(x,y,W,H)
            view:updateURL(GOTO_URL)
        end
    elseif device.platform == "android" then
        device.openURL(GOTO_URL)
    else
        device.openURL(GOTO_URL)
    end

    self:onClose()
end

function QuestionnairePopup:show()
    self:showPanel_(true, true, true);

    return self
end

return QuestionnairePopup;