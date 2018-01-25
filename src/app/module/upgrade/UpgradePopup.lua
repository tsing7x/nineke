--
-- Author: viking@boomegg.com
-- Date: 2014-12-08 11:56:19
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--
local UpgradePopup = class("UpgradePopup", function()
    return display.newNode()
end)

local UpgradeController = import(".UpgradeController")

local btnTextSize = 26
local rewardTextSize = 32
local whiteColor = cc.c3b(0xff, 0xff, 0xff)

function UpgradePopup:ctor(level)
    self:setNodeEventEnabled(true)
    self.controller_ = UpgradeController.new(self)
    if level < 0 then
        level = 1
    elseif level > 99 then
        level = 99
    end
    self.level_ = tonumber(level)
    self:setupView()
end

function UpgradePopup:setupView()
    local container = display.newNode():addTo(self)
    self.container_ = container
    local containerPadding = 50
    container:setTouchEnabled(true)
    container:pos(0, containerPadding)

    local bgWidth = 648
    local bgHeight = 276
    --关闭宝箱时的背景
    self.closeBg_ = display.newSprite("#upgrade_bg_closed.png"):addTo(container)

    --打开宝箱之后的背景
    self.openBg_ = display.newSprite("#upgrade_bg_opened.png"):addTo(container):hide()

    --等级LV
    local levelNode_ = display.newNode():addTo(container)
    local lvWidth = 132
    local lvHeight = 106
    local lvMarginLeft = 25
    local lvMarginTop = -15
    display.newSprite("#upgrade_lv.png"):addTo(levelNode_):pos(-bgWidth/2 + lvWidth + lvMarginLeft, lvMarginTop)
    self:getLevelNumberNode():addTo(levelNode_):pos(-bgWidth/2 + lvWidth * 3/2 + lvMarginLeft, lvMarginTop)

    --宝箱
    local treasureWidth = 274
    local treasureHeight = 174
    local treasurePadding = 15
    self.treasureBtn_ = cc.ui.UIPushButton.new({normal = "#upgrade_treasure_closed.png", pressed = "#upgrade_treasure_pressed.png"})
        :addTo(container)
        :onButtonClicked(buttontHandler(self, self.onOpenTreasureListener_))
    self.treasureBtn_:setAnchorPoint(cc.p(1, 0.5))
    self.treasureBtn_:pos(bgWidth/2 + treasurePadding, treasurePadding)

    self.treasureOpenIcon_ = display.newSprite("#upgrade_treasure_opened.png"):addTo(container):hide()
    self.treasureOpenIcon_:setAnchorPoint(cc.p(1, 0.5))
    self.treasureOpenIcon_:pos(bgWidth/2 + treasurePadding, treasurePadding)    

    --打开宝箱之后的奖励说明
    local rewardMarginTop = 60
    self.rewardLabel_ = ui.newTTFLabel({
            text = "good boy",
            size = rewardTextSize, 
            color = whiteColor,
            align = ui.TEXT_ALIGN_CENTER
        })
        :addTo(container)
        :hide()
    local rewardLabelSize = self.rewardLabel_:getContentSize()
    self.rewardLabel_:pos(0, bgHeight/2 - treasureHeight - rewardLabelSize.height/2 - rewardMarginTop)

    --按钮
    local btnWidth = 291
    local btnHeight = 55
    local btnMarginTop = 30
    self.btn_ = cc.ui.UIPushButton.new({normal = "#common_btn_green_normal.png", pressed = "#common_btn_green_pressed.png"}, {scale9 = true})
        :setButtonSize(btnWidth, btnHeight)
        :addTo(container)
        :onButtonClicked(buttontHandler(self, self.onOpenTreasureListener_))
        :setButtonLabel(ui.newTTFLabel({
            text = bm.LangUtil.getText("UPGRADE", "OPEN"),
            size = btnSize,
            color = whiteColor,
            align = ui.TEXT_ALIGN_CENTER
        }))
        :pos(0, bgHeight/2 - treasureHeight - rewardMarginTop - rewardLabelSize.height - btnHeight/2 - btnMarginTop)
end

function UpgradePopup:getLevelNumberNode()
    local numberNode_ = display.newNode()
    local width = 78
    local height = 106
    local num2 = self.level_%10
    local num2Node_ = display.newSprite("#upgrade_" .. num2 .. ".png"):addTo(numberNode_)
    num2Node_:setAnchorPoint(cc.p(0, 0.5))

    if self.level_ >= 10 then
        local num1 = math.floor(self.level_/10)
        local num1Node_ = display.newSprite("#upgrade_" .. num1 .. ".png"):addTo(numberNode_)
        num1Node_:setAnchorPoint(cc.p(0, 0.5))
        num2Node_:pos(width, 0)
    end

    return numberNode_
end

function UpgradePopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
            local size = self.juhua_:getContentSize()
            local marginTop = 35
            self.juhua_:pos(0, -size.height/2 - marginTop)
            self.juhua_:addTo(self.container_)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

function UpgradePopup:onOpenTreasureListener_()
    if self.isShared then
        self:onShareListener_()
    else
        print("UpgradePopup:onOpenTreasureListener_")
        self:setLoading(true)
        self.controller_:getReward()
    end
end

function UpgradePopup:afterGetReward(rewards)
    nk.SoundManager:playSound(nk.SoundManager.BOX_OPEN_REWARD)
    self.rewards_ = rewards

    self.closeBg_:hide()
    self.openBg_:show()

    self.treasureBtn_:hide()
    self.treasureOpenIcon_:show()

    self.rewardLabel_:show()
    self.rewardLabel_:setString(bm.LangUtil.getText("UPGRADE", "GET_REWARD", rewards))

    self.btn_:setButtonLabelString(bm.LangUtil.getText("UPGRADE", "SHARE"))
    self.isShared = true
end

function UpgradePopup:onShareListener_()
    print("UpgradePopup:onShareListener_")
    self.btn_:setButtonEnabled(false)
    local feedData = clone(bm.LangUtil.getText("FEED", "UPGRADE_REWARD"))
     feedData.name = bm.LangUtil.formatString(feedData.name, self.level_, self.rewards_)
     feedData.picture = bm.LangUtil.formatString(feedData.picture, self.level_)
     nk.Facebook:shareFeed(feedData, function(success, result)
         print("FEED.UPGRADE_REWARD result handler -> ", success, result)
         if not success then
             self.btn_:setButtonEnabled(true)
             nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_FAILED"))
         else
             nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_SUCCESS"))
             self:hide()
         end
     end)    
     self.btn_:setButtonEnabled(true)
end

function UpgradePopup:show()
    nk.PopupManager:addPopup(self)
end

function UpgradePopup:hide()
    nk.PopupManager:removePopup(self)
end

function UpgradePopup:onCleanup()
    self.controller_:dispose()
    display.removeSpriteFramesWithFile("upgrade_texture.plist", "upgrade_texture.png")
end

return UpgradePopup