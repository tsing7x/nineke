--
-- Author: johnny@boomegg.com
-- Date: 2014-08-31 20:11:50
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
-- 好友弹窗

local FriendPopup           = class("FeiendPopup", nk.ui.Panel)
local FriendListItem        = import(".FriendListItem")
local FriendData            = import(".FriendData")
local FriendPopupController = import(".FriendPopupController")
local InvitePopup           = import(".InvitePopup")
local AvatarIcon            = import("boomegg.ui.AvatarIcon")
local SearchUserInfo        = import(".SearchUserInfo")

local PADDING = 16
local POPUP_WIDTH = 815 + 50
local POPUP_HEIGHT = 516
local LIST_WIDTH = 760
local LIST_HEIGHT = 352
local INVITE_BTN_WIDTH = 220
local INVITE_BTN_HEIGHT = 104
local INVITE_BTN_GAP = 30
local CONTENT_PADDING = 12
local PLAYER_INFO_W, PLAYER_INFO_H = POPUP_WIDTH - 60, 290
local EDIT_BOX_FONT_COLOR = cc.c3b(0x4d, 0x4d, 0x4d)

local SHOW_FRIEND = 1
local SHOW_INVITE = 2
local SHOW_GROUP = 3

local GroupMainNode = import(".group.GroupMainNode")

local RECALL_ONEKEY_BUTTON = "เลือกทั้งหมด"

function FriendPopup:ctor(defaultTab)
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    FriendPopup.super.ctor(self, {POPUP_WIDTH, POPUP_HEIGHT})

    self:setNodeEventEnabled(true)
    self.controller_ = FriendPopupController.new(self)

    self.controller_:getInviteCode()

    --修改背景框
    self:setBackgroundStyle1()
    self:createNodes_()
    self:addCloseBtn()
    self:setCloseBtnOffset(0, -16)
    
    if defaultTab then
        self.mainTabBar_:gotoTab(defaultTab)
    end

    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:start("analytics.UmengAnalytics")
    end
end

function FriendPopup:createNodes_()
    local text = clone(bm.LangUtil.getText("FRIEND", "MAIN_TAB_TEXT"))
    if nk.userData.group and tonumber(nk.userData.group)==1 then
    else
        table.remove(text,#text)
    end
    -- 一级tab bar
    self.mainTabBar_ = nk.ui.CommonPopupTabBar.new(
        {
            popupWidth = 650,
            iconOffsetX = 10, 
            btnText = text, 
        })
        :pos(0, self.height_ * 0.5 - nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5 - 32)
        :addTo(self, 10)

    self:addTopDivide(nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5 - 10)
    self:addTopIcon("#pop_friend_icon.png", -16)

    self.listPosY_ = -nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5

    -- 恢复好友按钮
    local restoreicon
    self.restoreBtn_ = cc.ui.UIPushButton.new({normal = "#pop_friend_back_button_normal.png", pressed = "#pop_friend_back_button_pressed.png"})
        :pos(-POPUP_WIDTH / 2 + 53, self.height_ * 0.5 - nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5 - 30)
        :addTo(self,11)
        :onButtonClicked(handler(self, self.onRestoreList_))
        :onButtonPressed(function()
            restoreicon:setSpriteFrame(display.newSpriteFrame("pop_friend_recovery_icon_pressed.png"))
        end)
        :onButtonRelease(function()
            restoreicon:setSpriteFrame(display.newSpriteFrame("pop_friend_recovery_icon.png"))
        end)
    restoreicon = display.newSprite("#pop_friend_recovery_icon.png"):addTo(self.restoreBtn_)

    self.paopaoTips_ = nk.ui.PaoPaoTips.new(bm.LangUtil.getText("FRIEND", "RESTORE_BTN_TIP"), 24)
    self.paopaoTips_:pos(-POPUP_WIDTH / 2 + 53, self.height_ * 0.5 - nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5 + 10):addTo(self, 12):hide()
    local restore_state_tip_state = nk.userDefault:getIntegerForKey(nk.cookieKeys.TIPS_STATE.."restore", 0)
    if restore_state_tip_state == 1 then
        self.paopaoTips_:hide()
    end

    local returnicon
    self.returnBtn_ = cc.ui.UIPushButton.new({normal = "#pop_friend_back_button_normal.png", pressed = "#pop_friend_back_button_pressed.png"})
        :pos(-POPUP_WIDTH / 2 + 53, self.height_ * 0.5 - nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5 - 30)
        :addTo(self,11)
        :onButtonClicked(handler(self, self.onReturnBtn_))
        :onButtonPressed(function()
                returnicon:setSpriteFrame(display.newSpriteFrame("pop_friend_back_icon_pressed.png"))
            end)
            :onButtonRelease(function()
                returnicon:setSpriteFrame(display.newSpriteFrame("pop_friend_back_icon.png"))
            end)
    returnicon = display.newSprite("#pop_friend_back_icon.png"):addTo(self.returnBtn_)
    self.returnBtn_:hide()
end

function FriendPopup:addInviteNode_(codeData)
    self:setLoading(false)
    self.codeData_ = codeData

    --搜索好友
    local input_w, input_h = 630, 70
    self.inputNode_ = display.newScale9Sprite("#room_pop_chat_input_bg.png", -60, 115, cc.size(input_w, input_h))
        :addTo(self)

    self.editBox_ = ui.newEditBox({
        image = "#transparent.png", 
        size = cc.size(input_w - 20, 60),
        x = input_w/2,
        y = input_h/2,
        listener = handler(self, self.onEditBoxStateChange_)
    })
    self.editBox_:setFontName(ui.DEFAULT_TTF_FONT)
    self.editBox_:setFontSize(32)
    self.editBox_:setFontColor(EDIT_BOX_FONT_COLOR)
    self.editBox_:setPlaceholderFontName(ui.DEFAULT_TTF_FONT)
    self.editBox_:setPlaceholderFontSize(25)
    self.editBox_:setPlaceholderFontColor(cc.c3b(0xb7, 0xc8, 0xd4))
    self.editBox_:setPlaceHolder(bm.LangUtil.getText("FRIEND", "INPUT_USER_ID"))
    self.editBox_:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.editBox_:setReturnType(cc.KEYBOARD_RETURNTYPE_SEARCH)
    self.editBox_:addTo(self.inputNode_)

    --查找,清除按钮
    self.searchBtn_ = cc.ui.UIPushButton.new({normal="#room_pop_chat_send_button_normal.png", pressed="#room_pop_chat_send_button_pressed.png"})
        :setButtonLabel(cc.ui.UILabel.new({text = bm.LangUtil.getText("FRIEND", "SEARCH"), size = 28, color = cc.c3b(0xff, 0xff, 0xff)}))
        :setButtonLabelOffset(2, 2)
        :pos(input_w + 60, input_h/2)
        :scale(0.92)
        :onButtonClicked(buttontHandler(self, self.onSearchClicked_))
        :addTo(self.inputNode_)

    self.clearBtn_ = cc.ui.UIPushButton.new({normal="#room_pop_chat_send_button_normal.png", pressed="#room_pop_chat_send_button_pressed.png"})
        :setButtonLabel(cc.ui.UILabel.new({text = bm.LangUtil.getText("FRIEND", "CLEAR"), size = 28, color = cc.c3b(0xff, 0xff, 0xff)}))
        :setButtonLabelOffset(2, 2)
        :pos(input_w + 60, input_h/2)
        :scale(0.91)
        :onButtonClicked(buttontHandler(self, self.onClearClicked_))
        :addTo(self.inputNode_)
        :hide()

    -- 添加邀请按钮
    self.inviteNode_ = display.newNode():addTo(self)

    -- 第二层背景
    local bg_w, bg_h = 565, 200
    local frame = display.newScale9Sprite("#pop_friend_content_bg.png", 0, 0, cc.size(bg_w, bg_h))
        :align(display.LEFT_CENTER, -POPUP_WIDTH/2 + 35 + 25, -30)
        :addTo(self.inviteNode_)

    --邀请码
    local label_x, label_y = 22, bg_h - 20
    local label = ui.newTTFLabel(
        {
            text = bm.LangUtil.getText("FRIEND", "INVITE_CODE"),
            size = 22, 
            align = ui.TEXT_ALIGN_LEFT, 
        })
        :align(display.LEFT_CENTER, label_x, label_y)
        :addTo(frame)

    local size = label:getContentSize()
    ui.newTTFLabel(
        {
            text = codeData.icode,
            color = cc.c3b(0x4d, 0xcd, 0xd1),
            size = 22, 
            align = ui.TEXT_ALIGN_LEFT, 
        })
        :align(display.LEFT_CENTER, label_x + size.width, label_y)
        :addTo(frame)

    --累计收益
    label_x = bg_w/2 + 8
    label = ui.newTTFLabel(
        {
            text = bm.LangUtil.getText("FRIEND", "INVITE_PROFIT"),
            size = 22, 
            align = ui.TEXT_ALIGN_LEFT, 
        })
        :align(display.LEFT_CENTER, label_x, label_y)
        :addTo(frame)

    size = label:getContentSize()

    ui.newTTFLabel(
        {
            text = bm.formatNumberWithSplit(codeData.bonus),
            color = cc.c3b(0xfd, 0xae, 0x36),
            size = 22, 
            align = ui.TEXT_ALIGN_LEFT, 
        })
        :align(display.LEFT_CENTER, label_x + size.width, label_y)
        :addTo(frame)

    display.newScale9Sprite("#panel_split_line.png", bg_w/2, bg_h - 40, cc.size(2, bg_w - 30))
        :rotation(90)
        :addTo(frame)

    -- 邀请描述
    ui.newTTFLabel(
        {
            text = bm.LangUtil.getText("FRIEND", "INVITE_DESCRIPTION", nk.userData.inviteSendChips or "", nk.userData.inviteBackReward or "", '40K'),
            color = cc.c3b(0xc7, 0xe5, 0xff),
            size = 22, 
            align = ui.TEXT_ALIGN_LEFT, 
            dimensions = cc.size(550, 0)
        })
        :align(display.LEFT_CENTER, 15, bg_h/2 - 20)
        :addTo(frame)

    -- 邀请提示
    -- local historyVal = nk.userDefault:getIntegerForKey(nk.cookieKeys.FACEBOOK_INVITE_MONEY, 0)
    -- ui.newTTFLabel(
    --     {
    --         text = bm.LangUtil.getText("FRIEND", "INVITE_REWARD_TIP", bm.formatNumberWithSplit(historyVal)), 
    --         color = cc.c3b(0x74, 0x37, 0x9f), 
    --         size = 22, 
    --         align = ui.TEXT_ALIGN_CENTER
    --     })
    --     :pos(0, -self.height_ * 0.5 + 36)
    --     :addTo(self.inviteNode_)

    local bg_w2 = 180
    local frame2 = display.newScale9Sprite("#pop_friend_content_bg.png", 0, 0, cc.size(bg_w2, bg_h))
        :align(display.LEFT_CENTER, POPUP_WIDTH/2 - 205 - 25, -30)
        :addTo(self.inviteNode_)

    display.newSprite("code_icon.png")
        :pos(bg_w2/2, bg_h/2 + 10)
        :addTo(frame2)

    ui.newTTFLabel({
            text = bm.LangUtil.getText("FRIEND", "SCAN_DOWN"),
            color = cc.c3b(0xc7, 0xe5, 0xff),
            size = 20, 
            align = ui.TEXT_ALIGN_LEFT, 
        })
        :pos(bg_w2/2, 15)
        :addTo(frame2)

    local BTN_POS_Y = -185

    -- line邀请按钮
    local btnPosX = -INVITE_BTN_GAP - INVITE_BTN_WIDTH
    local lineText = bm.LangUtil.getText("FRIEND", "INVITE_WITH_LINE")
    cc.ui.UIPushButton.new({normal = "#pop_friend_add_button_line.png"}, {scale9 = true})
        :setButtonLabel("normal", ui.newTTFLabel({text = lineText, color = styles.FONT_COLOR.LIGHT_TEXT, size = 24, align = ui.TEXT_ALIGN_CENTER}))
        :setButtonLabel("pressed", ui.newTTFLabel({text = lineText, color = styles.FONT_COLOR.GREY_TEXT, size = 24, align = ui.TEXT_ALIGN_CENTER}))
        :setButtonLabelOffset(25, 0)
        :pos(btnPosX, BTN_POS_Y)
        :setButtonSize(INVITE_BTN_WIDTH, INVITE_BTN_HEIGHT)
        :onButtonClicked(buttontHandler(self, self.onLineInviteClick_))
        :addTo(self.inviteNode_)

    display.newSprite("#pop_friend_add_line.png")
        :pos(btnPosX - 68, BTN_POS_Y )
        :addTo(self.inviteNode_)
        :scale(0.9)

    -- 短信邀请按钮
    btnPosX = 0
    local smsText = bm.LangUtil.getText("FRIEND", "INVITE_WITH_SMS")
    cc.ui.UIPushButton.new({normal = "#pop_friend_add_button_sms.png"}, {scale9 = true})
        :setButtonLabel("normal", ui.newTTFLabel({text = smsText, color = styles.FONT_COLOR.LIGHT_TEXT, size = 24, align = ui.TEXT_ALIGN_CENTER}))
        :setButtonLabel("pressed", ui.newTTFLabel({text = smsText, color = styles.FONT_COLOR.GREY_TEXT, size = 24, align = ui.TEXT_ALIGN_CENTER}))
        :setButtonLabelOffset(30, 0)
        :pos(btnPosX, BTN_POS_Y)
        :setButtonSize(INVITE_BTN_WIDTH, INVITE_BTN_HEIGHT)
        :onButtonClicked(buttontHandler(self, self.onSmsInviteClick_))
        :addTo(self.inviteNode_)

    display.newSprite("#pop_friend_add_sms.png")
        :pos(btnPosX - 58, BTN_POS_Y)
        :addTo(self.inviteNode_)

    -- 更多邀请按钮
    btnPosX = INVITE_BTN_GAP + INVITE_BTN_WIDTH
    local moreText = bm.LangUtil.getText("FRIEND", "INVITE_WITH_MORE")
    cc.ui.UIPushButton.new({normal = "#pop_friend_add_button_more.png"}, {scale9 = true})
        :setButtonLabel("normal", ui.newTTFLabel({text = moreText, color = styles.FONT_COLOR.LIGHT_TEXT, size = 24, align = ui.TEXT_ALIGN_CENTER}))
        :setButtonLabel("pressed", ui.newTTFLabel({text = moreText, color = styles.FONT_COLOR.GREY_TEXT, size = 24, align = ui.TEXT_ALIGN_CENTER}))
        :setButtonLabelOffset(30, 0)
        :pos(btnPosX, BTN_POS_Y)
        :setButtonSize(INVITE_BTN_WIDTH, INVITE_BTN_HEIGHT)
        :onButtonClicked(buttontHandler(self, self.onMoreInviteClick_))
        :addTo(self.inviteNode_)

    display.newSprite("#pop_friend_add_more.png")
        :pos(btnPosX - 58, BTN_POS_Y)
        :addTo(self.inviteNode_)
end

-- 移除邀请结点,包括搜索的用户信息
function FriendPopup:removeInviteNode_()
    if self.inviteNode_ then 
        self.inviteNode_:removeFromParent()
        self.inviteNode_ = nil
    end

    if self.inputNode_ then
        self.inputNode_:removeFromParent()
        self.inputNode_ = nil
    end

    self:removeSearchUserInfo_()
end

--搜索好友结果UI
function FriendPopup:addSearchUserInfo_(id)
    self:removeSearchUserInfo_()

    self:setLoading(true)
    bm.HttpService.POST({
        mod="Friend",
        act="searchFriends",
        searchid = id},
        function(data)
            self:setLoading(false)
            local jsonData = json.decode(data)
            if jsonData.code == 1 then --搜索成功
                self.searchUserInfo_ = SearchUserInfo.new(jsonData.data, self.controller_):pos(0, -80):addTo(self)
            else --ID不存在
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "INPUT_USER_ID_NO_EXIST"))
                self:removeSearchUserInfo_()
                self.inviteNode_:show()
                self.editBox_:setFontColor(cc.c3b(0xc6, 0x4c, 0x4c))
            end
        end, function()
            self:setLoading(false)
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
            self:removeSearchUserInfo_()
            self.inviteNode_:show()
        end)
end

function FriendPopup:removeSearchUserInfo_()
    if self.searchUserInfo_ then
        self.searchUserInfo_:removeFromParent()
        self.searchUserInfo_ = nil
    end
end

function FriendPopup:setAddFriendStatus_()
    self.addFriendBtn_:setButtonEnabled(true)
    if self.isFriend_ == 0 then
        self.addFriendBtn_:setButtonImage("normal", "#common_btn_green_normal.png", true)
        self.addFriendBtn_:setButtonImage("pressed", "#common_btn_green_pressed.png", true)
        self.addFriendBtn_:setButtonLabelString(bm.LangUtil.getText("ROOM", "ADD_FRIEND"))
    else
        self.addFriendBtn_:setButtonImage("normal", "#common_btn_blue_normal.png", true)
        self.addFriendBtn_:setButtonImage("pressed", "#common_btn_blue_pressed.png", true)
        self.addFriendBtn_:setButtonLabelString(bm.LangUtil.getText("ROOM", "DEL_FRIEND"))
    end
end

function FriendPopup:onMainTabChange_(selectedTab)
    if self.delList_ then
        self.delList_:removeFromParent()
        self.delList_ = nil
    end
    if self.groupMainNode_ then
        self.groupMainNode_:removeFromParent()
        self.groupMainNode_ = nil
    end

    self.returnBtn_:hide()
    self.restoreBtn_:show()
    self:setDelListNoDataTip(false)
    self.paopaoTips_:setText(bm.LangUtil.getText("FRIEND", "RESTORE_BTN_TIP"))
    
    if selectedTab == SHOW_FRIEND then
        self:removeInviteNode_()

        self.bottom_recall_node = display.newNode():addTo(self)
        display.newScale9Sprite("#panel_overlay.png", 
           0, 0, cc.size(LIST_WIDTH, LIST_HEIGHT - 60)):addTo(self.bottom_recall_node)

        -- 添加列表
        local list_height_offset = 80
        self.list_ = bm.ui.ListView.new(
            {
                viewRect = cc.rect(-LIST_WIDTH * 0.5, -LIST_HEIGHT * 0.5 + list_height_offset * 0.5, LIST_WIDTH, LIST_HEIGHT - list_height_offset),
                upRefresh = handler(self, self.onFriendUpFrefresh_)
            }, 
            FriendListItem
        )
        :pos(0, self.listPosY_ + list_height_offset * 0.5)
        :addTo(self)
        self.list_.controller_ = self.controller_

        -- 一键赠送按钮
        self.oneKeySendBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_blue_normal.png", pressed = "#common_btn_blue_pressed.png", disabled = "#common_btn_disabled.png"}, {scale9 = true})
            :setButtonSize(200, 55)
            :setButtonLabel("normal", ui.newTTFLabel({text = bm.LangUtil.getText("FRIEND", "ONE_KEY_SEND_CHIP"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER}))
            :pos(-160, -180)
            :onButtonClicked(buttontHandler(self, self.onOneKeySend))
            :addTo(self.bottom_recall_node)
        self.oneKeySendBtn_:setButtonEnabled(false)

        -- 一键召回按钮
        self.oneKeyRecallBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_yellow_normal.png", pressed = "#common_btn_yellow_pressed.png", disabled = "#common_btn_disabled.png"}, {scale9 = true})
            :setButtonSize(200, 55)
            :setButtonLabel("normal", ui.newTTFLabel({text = RECALL_ONEKEY_BUTTON, color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER}))
            :pos(160, -180)
            :onButtonClicked(buttontHandler(self, self.onOneKeyRecall))
            :addTo(self.bottom_recall_node)
        self.oneKeyRecallBtn_:setButtonEnabled(false)

        self.newFriendRecallPoint = display.newSprite(nk.userData.motherDayRedNodePath)
            :pos(90, 16)
            :addTo(self.oneKeyRecallBtn_)
            :scale(0.8)
            :hide()

        local RECALL_TIP = "ทุกการสะกิดจะได้รับ " .. nk.userData.recallSendChips .. " ชิป หากเพื่อนที่สะกิดเข้าเกมส์จะได้รับ " .. nk.userData.recallBackChips .. " ชิปเพิ่ม สะกิดเยอะได้รางวัลเยอะ！"
        ui.newTTFLabel({text = RECALL_TIP, color = styles.FONT_COLOR.LIGHT_TEXT, size = 18, align = ui.TEXT_ALIGN_CENTER})
            :pos(0, -226)
            :addTo(self.bottom_recall_node)

    elseif selectedTab == SHOW_INVITE then
        self:setNoDataTip(false)

        -- 移除列表
        if self.list_ then 
            self.list_:removeFromParent()
            self.list_ = nil

            self.bottom_recall_node:removeFromParent()
            self.bottom_recall_node = nil
        end
    elseif selectedTab == SHOW_GROUP then
        self:setNoDataTip(false)
        if self.list_ then 
            self.list_:removeFromParent()
            self.list_ = nil

            self.bottom_recall_node:removeFromParent()
            self.bottom_recall_node = nil
        end
        self:removeInviteNode_()
    end
    self.controller_:onMainTabChange(selectedTab)
end

function FriendPopup:onRestoreList_()
    nk.userDefault:setIntegerForKey(nk.cookieKeys.TIPS_STATE.."restore", 1)

    self:setLoading(false)
    self:setNoDataTip(false)
    self:setDelListNoDataTip(false)
    self.mainTabBar_:gotoTab(0)
    self.returnBtn_:show()
    
    local restore_return_tip_state = nk.userDefault:getIntegerForKey(nk.cookieKeys.TIPS_STATE.."restore_return", 0)
    if restore_return_tip_state == 1 then
        self.paopaoTips_:hide()
    end
    self.paopaoTips_:setText(bm.LangUtil.getText("FRIEND", "RETURN_BTN_TIP"))
    
    self.restoreBtn_:hide()
    
    -- 移除列表
    if self.list_ then 
        self.list_:removeFromParent() 
        self.list_ = nil

        self.bottom_recall_node:removeFromParent()
        self.bottom_recall_node = nil
    end

    self:removeInviteNode_()

    -- 添加列表
    self.delList_ = bm.ui.ListView.new(
        {
            viewRect = cc.rect(-LIST_WIDTH * 0.5, -LIST_HEIGHT * 0.5, LIST_WIDTH, LIST_HEIGHT)
        }, 
        FriendListItem
    )
    :pos(0, self.listPosY_)
    :addTo(self)
    self.delList_.controller_ = self.controller_

    self.controller_:getDelFriendData()
end

function FriendPopup:onReturnBtn_()
    nk.userDefault:setIntegerForKey(nk.cookieKeys.TIPS_STATE.."restore_return", 1)
    self.returnBtn_:hide()
    self.restoreBtn_:show()
    self.mainTabBar_:gotoTab(1)
end

function FriendPopup:onLineInviteClick_()
    local content = self.codeData_.sharecontent
    nk.Native:showLineView(content, function(result)
        if result == "nolineapp" then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "NO_LINE_APP"))
        end
    end)

    nk.reportToDAdmin("invitecode", "lineInviteClicked=1")
end

function FriendPopup:onSmsInviteClick_()
    local content = self.codeData_.sharecontent
    nk.Native:showSMSView(content)
    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand{
            command = "event",
            args = {eventId = "sms_invite_friends"},
            label = "user sms_invite_friends"
        }
    end

    nk.reportToDAdmin("invitecode", "smsInviteClicked=1")
end

function FriendPopup:onMoreInviteClick_()
    local title = self.codeData_.sharetitle
    local content = self.codeData_.sharecontent
    
    local feedData = {
        name = content,
        caption = title,
        link = "",
        picture = "",
        message = "",
    }

    nk.Facebook:moreInvite(feedData, function(success, result)
        if not success then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_FAILED"))
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_SUCCESS"))
        end
    end)

    nk.reportToDAdmin("invitecode", "moreInviteClicked=1")
end

function FriendPopup:onOneKeyRecall()
    self.controller_:oneKeyRecall()
end

function FriendPopup:onOneKeySend()
    self.controller_:oneKeySend()
end

function FriendPopup:updateFriendSendData(enable)
    if self.bottom_recall_node then
        if enable then
            self.oneKeySendBtn_:setButtonEnabled(true)
        else
            self.oneKeySendBtn_:setButtonEnabled(false)
        end
    end
end

function FriendPopup:updateFriendSendReward(reward)
    if self.bottom_recall_node then
        if reward > 0 then
            self.oneKeySendBtn_:setButtonLabelString(bm.LangUtil.getText("FRIEND", "ONE_KEY_SEND_CHIP") .. bm.formatBigNumber(reward))
        else
            self.oneKeySendBtn_:setButtonLabelString(bm.LangUtil.getText("FRIEND", "ONE_KEY_SEND_CHIP"))
        end
    end
end

function FriendPopup:updateFriendRecallData(enable)
    if self.bottom_recall_node and self.newFriendRecallPoint then
        if enable then
            self.newFriendRecallPoint:show()
        else
            self.newFriendRecallPoint:hide()
            FriendData.hasNewMessage = false
            bm.DataProxy:setData(nk.dataKeys.NEW_FRIEND_DATA, FriendData.hasNewMessage)
        end
    end
    if self.bottom_recall_node then
        if enable then
            self.oneKeyRecallBtn_:setButtonEnabled(true)
        else
            self.oneKeyRecallBtn_:setButtonEnabled(false)
        end
    end
end

function FriendPopup:updateFriendRecallReward(reward)
    if self.bottom_recall_node then
        if reward > 0 then
            self.oneKeyRecallBtn_:setButtonLabelString(RECALL_ONEKEY_BUTTON .. "+" .. reward)
        else
            self.oneKeyRecallBtn_:setButtonLabelString(RECALL_ONEKEY_BUTTON)
        end
    end
end

function FriendPopup:onFriendUpFrefresh_()
    self.controller_:requestFriendDataPage_()
end

function FriendPopup:onEditBoxStateChange_(evt, editbox)
    local text = editbox:getText()
    if evt == "began" then
    elseif evt == "ended" then
    elseif evt == "return" then
        self:onSearchClicked_()
    elseif evt == "changed" then
        editbox:setFontColor(EDIT_BOX_FONT_COLOR)
        local filteredText = nk.keyWordFilter(text)
        if filteredText ~= text then
            editbox:setText(filteredText)
        end
    else
        printf("EditBox event %s", tostring(evt))
    end
end

function FriendPopup:onSearchClicked_()
    local text = string.trim(self.editBox_:getText())

    if text ~= "" then
        if nk.userData.uid == tonumber(text) then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "NO_SEARCH_SELF"))
            self.editBox_:setText("")
            return
        end
        self.searchBtn_:hide()
        self.clearBtn_:show()
        self.inviteNode_:hide()
        self:addSearchUserInfo_(text)
    else
        self.editBox_:setText("")
    end
end

function FriendPopup:onClearClicked_()
    self.clearBtn_:hide()
    self.searchBtn_:show()
    self.editBox_:setText("")
    self.inviteNode_:show()
    self:removeSearchUserInfo_()
end

function FriendPopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
                :pos(0, self.listPosY_)
                :addTo(self)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

function FriendPopup:setNoDataTip(noData)
    if noData then
        if not self.noDataTip_ then
            self.noDataTip_ = ui.newTTFLabel({text = bm.LangUtil.getText("FRIEND", "NO_FRIEND_TIP"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 24, align = ui.TEXT_ALIGN_CENTER})
                :pos(0, self.listPosY_)
                :addTo(self)
        end
    else
        if self.noDataTip_ then
            self.noDataTip_:removeFromParent()
            self.noDataTip_ = nil
        end
    end
end

function FriendPopup:setDelListNoDataTip(noData)
    if noData then
        if not self.noDelListDataTip_ then
            self.noDelListDataTip_ = ui.newTTFLabel({text = bm.LangUtil.getText("FRIEND", "RESTORE_NO_DATA"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 24, align = ui.TEXT_ALIGN_CENTER})
                :pos(0, self.listPosY_)
                :addTo(self)
        end
    else
        if self.noDelListDataTip_ then
            self.noDelListDataTip_:removeFromParent()
            self.noDelListDataTip_ = nil
        end
    end
end

function FriendPopup:setListData(data)
    self:sortFriendData_(data)
    self.list_:setData(data,true)
end

function FriendPopup:setDelListData(data)
    self.delList_:setData(data)
end

function FriendPopup:show()
    self:showPanel_()
end

function FriendPopup:onShowed()
    -- 延迟设置，防止list出现触摸边界的问题
    self.mainTabBar_:onTabChange(handler(self, self.onMainTabChange_))
    if self.list_ then
        self.list_:setScrollContentTouchRect()
    end
end

function FriendPopup:onCleanup()
    nk.userData.groupConfig = nil
    self.controller_:dispose()
    display.removeSpriteFramesWithFile("group_texture.plist", "group_texture.png")
end

function FriendPopup:onExit()
    nk.schedulerPool:delayCall(function()
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end, 0.1)
end

--FB牌友在线可追踪 > 普通牌友在线可追踪 > FB牌友在线不可追踪 > 普通牌友在线不可追踪 > FB牌友可召回 > 普通牌友可召回 > FB牌友不在线> 普通牌友不在线
function FriendPopup:sortFriendData_(data)
    for _, v in ipairs(data) do
        if v.ip and v.port and v.tid then
            v.isTrack = 1
        else
            v.isTrack = 0
        end
    end

    local function sort_(a, b)
        local r
        local a_online = tonumber(a.isOnline) --是否在线
        local b_online = tonumber(b.isOnline)

        local a_isTrack = tonumber(a.isTrack) --是否可追踪
        local b_isTrack = tonumber(b.isTrack)

        local a_isFb = tonumber(a.isFb) --是否FB登录
        local b_isFb = tonumber(b.isFb)

        local a_isRecall = tonumber(a.isRecall) --是否需要召回
        local b_isRecall = tonumber(b.isRecall)

        if a_online == b_online then
            if a_online == 1 then
                if a_isTrack == b_isTrack then
                    r = a_isFb > b_isFb
                else
                    r = a_isTrack > b_isTrack
                end                
            else
                if a_isRecall == b_isRecall then
                    r = a_isFb > b_isFb
                else
                    r = a_isRecall > b_isRecall
                end
            end
        else
            r = a_online > b_online
        end

        return r
    end

    table.sort(data, sort_)
end

function FriendPopup:addGroupNode_()
    display.addSpriteFrames("group_texture.plist", "group_texture.png", function()
        self:setLoading(false)
        if not self.groupMainNode_ then
            self.groupMainNode_ = GroupMainNode.new():addTo(self)
        end
    end)
end

return FriendPopup