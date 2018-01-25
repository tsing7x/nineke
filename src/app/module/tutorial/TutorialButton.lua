--
-- Author: viking@boomegg.com
-- Date: 2014-12-18 15:01:37
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--
local TutorialButton = class("TutorialButton", function()
    return display.newNode()
end)

local TutorialPopup = import(".TutorialPopup")

local btnColor = cc.c3b(0xa9, 0xd7, 0xff)
local btnSize = 22
local animKey = "TUTORIAL_AMIN"
local btnWidth = 190
local btnHeight = 60

function TutorialButton:ctor()
    --按钮
    self.button_ = cc.ui.UIPushButton.new({normal = "#tutorial_btn_up.png", pressed = "#tutorial_btn_down.png"}, {scale9 = true})
        :setButtonSize(btnWidth, btnHeight)
        :setButtonLabel(ui.newTTFLabel({
            text = bm.LangUtil.getText("TUTORIAL", "HOW_TO_PLAY"),
            size = btnSize,
            color = btnColor,
            align = ui.TEXT_ALIGN_CENTER
        }))
        :onButtonClicked(buttontHandler(self, self.onButtonClickListener_))
        :addTo(self)

    local isAnim = cc.UserDefault:getInstance():getBoolForKey(nk.userData.uid .. animKey, true)
    if isAnim then
        self:playAnim()
    end
end

function TutorialButton:playAnim()
    local animWidth = 46
    local animHeight = 1

    local animBottomRotation = 0
    local animBottomStartX = -btnWidth/2 + animWidth/2
    local animBottomEndX = btnWidth/2 - animWidth/2
    local animBottomPosY = -btnHeight/2 + animHeight/2 + 5
    self.animView_ = display.newSprite("#tutorial_btn_light.png"):addTo(self):pos(animBottomStartX, animBottomPosY)

    local animRightRotation = -90
    local animRightPosX = btnWidth/2 - animHeight/2 - 3
    local animRightStartY = -btnHeight/2 + animWidth/2
    local animRightEndY = btnHeight/2 - animWidth/2
    -- self.animRightView_ = display.newSprite("#tutorial_btn_light.png"):addTo(self):rotation(animRightRotation):pos(animRightPosX, animRightStartY):hide()

    local animUpRotation = -180
    local animUpStartX = btnWidth/2 - animWidth/2
    local animUpEndX = -btnWidth/2 + animWidth/2
    local animUpPosY = btnHeight/2 - animHeight/2 - 3
    -- self.animUpView_ = display.newSprite("#tutorial_btn_light.png"):addTo(self):rotation(animUpRotation):pos(animUpStartX, animUpPosY):hide()

    local animLeftRotation = -270
    local animLeftStartY = btnHeight/2 - animWidth/2
    local animLeftEndY = -btnHeight/2 + animWidth/2
    local animLeftPosX = -btnWidth/2 + animHeight/2 + 3
    -- self.animLeftView_ = display.newSprite("#tutorial_btn_light.png"):addTo(self):rotation(animLeftRotation):pos(animLeftPosX, animLeftStartY):hide()

    local animTime = 0.4
    local sequence = transition.sequence({
            cc.MoveTo:create(animTime, cc.p(animBottomEndX, animBottomPosY)),--bottom
            cc.CallFunc:create(function()
                self.animView_:rotation(animRightRotation)
                self.animView_:pos(animRightPosX, animRightStartY)
            end),
            cc.MoveTo:create(animTime, cc.p(animRightPosX, animRightEndY)),--right
            cc.CallFunc:create(function()
                self.animView_:rotation(animUpRotation)
                self.animView_:pos(animUpStartX, animUpPosY)
            end),
            cc.MoveTo:create(animTime, cc.p(animUpEndX, animUpPosY)),--up
            cc.CallFunc:create(function()
                self.animView_:rotation(animLeftRotation)
                self.animView_:pos(animLeftPosX, animLeftStartY)
            end),
            cc.MoveTo:create(animTime, cc.p(animLeftPosX, animLeftEndY)),--left
            cc.CallFunc:create(function()
                self.animView_:rotation(animBottomRotation)
                self.animView_:pos(animBottomStartX, animBottomPosY)
            end),
        })
    self.animView_:runAction(cc.RepeatForever:create(sequence))
end

function TutorialButton:stopAnim()
    self.animView_:stopAllActions()
    self.animView_:removeFromParent()
end

function TutorialButton:onButtonClickListener_()
    print("TutorialButton:onButtonClickListener_")
    local isAnim = cc.UserDefault:getInstance():getBoolForKey(nk.userData.uid .. animKey, true)
    if isAnim then
        self:stopAnim()
        cc.UserDefault:getInstance():setBoolForKey(nk.userData.uid .. animKey, false)
        cc.UserDefault:getInstance():flush()
    end
    TutorialPopup.new():show()
end

return TutorialButton