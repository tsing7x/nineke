--
-- Author: KevinYu
-- Date: 2016-8-11 15:39:36
-- 四级以下的破产提示

local InvitePopup  = import("app.module.friend.InvitePopup")
local CommonRewardChipAnimation = import("app.login.CommonRewardChipAnimation")

local NewUserCrash = class("NewUserCrash", nk.ui.Panel)

local POPUP_WIDTH, POPUP_HEIGHT = 620, 380

local GET_REWARD_TYPE = 1 --领取奖励
local INVITE_TYPE = 2 --FB邀请提示

function NewUserCrash:ctor(popupType, reward)
    NewUserCrash.super.ctor(self, {POPUP_WIDTH, POPUP_HEIGHT})
    self:setCommonStyle(bm.LangUtil.getText("CRASH", "TITLE"), 15)
    self:addCloseBtn()

    self.popupType_ = popupType

    local img, btnTitle, rewardDes, tipsText
    if popupType == GET_REWARD_TYPE then
        tipsText = bm.LangUtil.getText("CRASH", "REWARD_TIPS")
        img = "#new_crash_chip_icon.png"
        btnTitle = bm.LangUtil.getText("COMMON", "CONFIRM")
        rewardDes = bm.LangUtil.getText("CRASH", "CHIPS_TIPS_2")
        reward = bm.LangUtil.getText("CRASH", "CHIPS", reward)
    else
        tipsText = bm.LangUtil.getText("CRASH", "NO_REWARD_TIPS")
        img = "#new_crash_invite_friend_icon.png"
        btnTitle = bm.LangUtil.getText("CRASH", "INVITE")
        rewardDes = bm.LangUtil.getText("CRASH", "INVITE_INFO")
    end

    ui.newTTFLabel({
            text = tipsText,
            color = cc.c3b(0xeb, 0xce, 0x8e),
            size = 22,
            align = ui.TEXT_ALIGN_CENTER})
        :pos(0, 80)
        :addTo(self)

    local w, h = 560,  130
    local frame = display.newScale9Sprite("#new_crash_frame.png", 0, 0, cc.size(w, h))
        :pos(0, -20)
        :addTo(self)

    local x, y = w/2, h/2
    display.newSprite(img)
        :align(display.RIGHT_CENTER, x - 20, y)
        :addTo(frame)

    ui.newTTFLabel({text = rewardDes, size = 24})
        :align(display.LEFT_CENTER, x + 10, y + 15)
        :addTo(frame)

    ui.newTTFLabel({text = "+" .. reward, size = 24, color = cc.c3b(0xff, 0xcd1, 0x4b)})
        :align(display.LEFT_CENTER, x + 10, y - 15)
        :addTo(frame)

    self.btn_ = cc.ui.UIPushButton.new({normal = "#common_btn_yellow_normal.png", pressed = "#common_btn_yellow_pressed.png"}, {scale9 = true})
        :setButtonSize(165, 55)
        :setButtonLabel(ui.newTTFLabel({text = btnTitle, size = 20}))
        :onButtonClicked(buttontHandler(self, self.onInviteOrConfirmClicked_))
        :pos(0, -POPUP_HEIGHT/2 + 55)
        :addTo(self)
end

--邀请或确定
function NewUserCrash:onInviteOrConfirmClicked_()
    self.btn_:setButtonEnabled(false)

    if self.popupType_ == INVITE_TYPE then
        InvitePopup.new():show()
        if device.platform == "android" or device.platform == "ios" then
            cc.analytics:doCommand {
                command = "event",
                args = {eventId = "hall_Invite_friends"},
                label = "user hall_Invite_friends"
            }
        end
    end

    self:onClose()
end

function NewUserCrash:show()
    self:showPanel_()
end

return NewUserCrash
