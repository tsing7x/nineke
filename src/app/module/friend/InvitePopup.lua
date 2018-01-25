--
-- Author: johnny@boomegg.com
-- Date: 2014-09-10 13:22:07
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
-- 邀请好友弹窗

local POPUP_WIDTH = 780
local POPUP_HEIGHT = 520
local LIST_POS_Y = -48
local friendDataGlobal = {}
local InvitePopup = class("InvitePopup", function ()
    return display.newNode()
end)
local InviteListItem = import(".InviteListItem")
local InvitePopupController = import(".InvitePopupController")
local logger = bm.Logger.new("InvitePopup")
local SimpleColorLabel = import("boomegg.ui.SimpleColorLabel")

local IS_SHOWALERT = true

local MAX_SELECT_NUM --当前最多选择人数

local INVITE_NUM --0全选 其他数字表示具体人数

function InvitePopup:ctor()
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()

    self.controller_ = InvitePopupController.new(self)

    self:setVisible(false)

    if nk.userData.newInviteType == 3 then
        INVITE_NUM = nk.OnOff:getConfig('dailyInviteCount')
    else
        INVITE_NUM = nk.userData.newInviteNum
    end
    
    if INVITE_NUM == 0 then
        MAX_SELECT_NUM = 99999
    else
        local num = self:getTodayInviteCount()
        MAX_SELECT_NUM = INVITE_NUM - num
    end
end

function InvitePopup:initUI_()
    self.background_ = display.newScale9Sprite("#pop_invite_content_bg.png", 0, 0, cc.size(POPUP_WIDTH, POPUP_HEIGHT))
        :addTo(self, 1, 1)
    self.background_:setTouchEnabled(true)
    self.background_:setTouchSwallowEnabled(true)

    --搜索栏背景
    self.cover_ = display.newScale9Sprite("#invite_popup_bg.png", 0, POPUP_HEIGHT * 0.5 - 98 * 0.5, cc.size(POPUP_WIDTH, 98))
        :addTo(self, 3, 3)
    self.cover_:setTouchEnabled(true)
    self.cover_:setTouchSwallowEnabled(true)

    bm.TouchHelper.new(
        display.newSprite("#panel_black_close_btn_up.png")
            :pos(-POPUP_WIDTH * 0.5, POPUP_HEIGHT * 0.5)
            :addTo(self, 4, 4),
        function (target, evtName)
            if evtName == bm.TouchHelper.CLICK then
                nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
                nk.PopupManager:removePopup(self)
            end
        end
    )

    -- 全选按钮
    local frame = display.newSprite("#invite_friend_selectall_checkbox_bg.png"):pos(-90 + 8 + 16, 0)
    local selected = display.newSprite("#invite_friend_selectall_checkbox_selected.png"):pos(-90 + 8 + 16, 0):hide()
    local btn, selectedAllStr

    if INVITE_NUM == 0 then
        selectedAllStr = bm.LangUtil.getText("FRIEND", "SELECT_ALL")
    else
        selectedAllStr = bm.LangUtil.getText("FRIEND", "SELECT_NUM", MAX_SELECT_NUM)
    end
    
    self.setSelectedAll_ = function()
        if not self.userItems_ or #self.userItems_ == 0 then
            selected:hide()
            return
        end
        local selectedNum = self:getSelectedItemNum()
        if selectedNum >= MAX_SELECT_NUM or selectedNum == #self.userItems_ then
            selected:show()
            btn:setButtonLabelString("normal", bm.LangUtil.getText("FRIEND", "DESELECT_ALL"))
        else
            selected:hide()
            btn:setButtonLabelString("normal", selectedAllStr)
        end
    end

    btn = cc.ui.UIPushButton.new({normal = "#invite_popup_btn_up.png", pressed = "#invite_popup_btn_down.png"}, {scale9=true})
        :setButtonLabel("normal", ui.newTTFLabel({text = selectedAllStr, color = styles.FONT_COLOR.LIGHT_TEXT, size = 22, align = ui.TEXT_ALIGN_CENTER}))
        :setButtonLabelOffset(20, 0)
        :setButtonSize(180, 60)
        :pos(-POPUP_WIDTH * 0.5 + 90 + 30, POPUP_HEIGHT * 0.5 + LIST_POS_Y)
        :addTo(self, 5, 5)
        :add(frame)
        :add(selected)
        :onButtonClicked(buttontHandler(self, self.onSelectAllClicked))

    -- 邀请按钮
    cc.ui.UIPushButton.new({normal = "#invite_popup_btn_up.png", pressed = "#invite_popup_btn_down.png"})
        :setButtonLabel("normal", ui.newTTFLabel({text = bm.LangUtil.getText("FRIEND", "SEND_INVITE"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 22, align = ui.TEXT_ALIGN_CENTER}))
        :pos(POPUP_WIDTH * 0.5 - 80, POPUP_HEIGHT * 0.5 + LIST_POS_Y)
        :addTo(self, 6, 6)
        :onButtonClicked(buttontHandler(self, self.onInviteClick_))

    -- 搜索
    local tipY = 50
    if nk.OnOff:check("openFriendSearch") then
        self.searchIcon_ = display.newSprite("#pop_invite_search_icon.png")
            :pos(-130, POPUP_HEIGHT * 0.5 + LIST_POS_Y + 10)
            :addTo(self, 12, 12)

        self.searchEdit_ = ui.newEditBox({
            size = cc.size(360, 40),
            align=ui.TEXT_ALIGN_CENTER - 30,
            image="#pop_invite_content_bg.png",
            x = 30,
            y = POPUP_HEIGHT * 0.5 + LIST_POS_Y + 10,
            listener = handler(self, self.onSearchStart_)
        })
        self.searchEdit_:setFontName(ui.DEFAULT_TTF_FONT)
        self.searchEdit_:setFontSize(24)
        self.searchEdit_:setFontColor(cc.c3b(0x92, 0x8d, 0x8d))
        self.searchEdit_:setPlaceholderFontName(ui.DEFAULT_TTF_FONT)
        self.searchEdit_:setPlaceholderFontSize(24)
        self.searchEdit_:setPlaceholderFontColor(cc.c3b(0x92, 0x8d, 0x8d))
        self.searchEdit_:setPlaceHolder("       " .. bm.LangUtil.getText("FRIEND", "SEARCH_FRIEND"))
        self.searchEdit_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
        self.searchEdit_:setReturnType(cc.KEYBOARD_RETURNTYPE_GO)
        self.searchEdit_:addTo(self, 10, 10)
        tipY = 80
    end

    -- 选中好友人数提示和奖励提示
    self.inviteTip_ = ui.newTTFLabel({text = bm.LangUtil.getText("FRIEND", "INVITE_SELECT_TIP", 0, 0), color = styles.FONT_COLOR.LIGHT_TEXT, size = 16, align = ui.TEXT_ALIGN_CENTER})
        :pos(30, POPUP_HEIGHT * 0.5 - tipY)
        :addTo(self, 7, 7)

    --奖励描述说明
    self.cover_ = display.newScale9Sprite("#invite_bar_tip_bg.png", -0, -POPUP_HEIGHT * 0.5 + 64 * 0.5 - 3, cc.size(POPUP_WIDTH+4, 66))
        :addTo(self, 7, 7)

    local alertCfg1_ = SimpleColorLabel.addMultiLabel(
        bm.LangUtil.getText("FRIEND","INVITE_ALERTLBL21"),
        16,
        styles.FONT_COLOR.LIGHT_TEXT,
        styles.FONT_COLOR.GOLDEN_TEXT,
        styles.FONT_COLOR.LIGHT_TEXT).addTo(self, 8, 8)
    alertCfg1_.setString(bm.LangUtil.getText("FRIEND","INVITE_ALERTLBL22", nk.userData.inviteSendChips))
    local sz1 = alertCfg1_.getContentSize()
    local ay1_ = -POPUP_HEIGHT*0.5 + 42
    alertCfg1_.pos(-POPUP_WIDTH*0.5 + sz1.width*0.5 + 15, ay1_)

    local rewardLimit = self:getInviteRewardText()
    local alertCfg3_ = SimpleColorLabel.addMultiLabel(
        bm.LangUtil.getText("FRIEND","INVITE_ALERTLBL23"),
        16,
        styles.FONT_COLOR.LIGHT_TEXT,
        styles.FONT_COLOR.GOLDEN_TEXT,
        styles.FONT_COLOR.LIGHT_TEXT).addTo(self, 8, 8)
    alertCfg3_.setString(bm.LangUtil.getText("FRIEND","INVITE_ALERTLBL22", rewardLimit))
    local sz3 = alertCfg3_.getContentSize()
    local ay3_ = -POPUP_HEIGHT*0.5 + 42
    alertCfg3_.pos(-POPUP_WIDTH*0.5 + sz1.width + sz3.width*0.5 + 15, ay3_)
    
    local alertCfg2_ = SimpleColorLabel.addMultiLabel(
        bm.LangUtil.getText("FRIEND","INVITE_ALERTLBL11"),
        16,
        styles.FONT_COLOR.LIGHT_TEXT,
        styles.FONT_COLOR.GOLDEN_TEXT,
        styles.FONT_COLOR.LIGHT_TEXT).addTo(self, 8, 8)
    alertCfg2_.setString(nk.userData.inviteBackReward)
    local sz2 = alertCfg2_.getContentSize()
    local ay2_ = -POPUP_HEIGHT*0.5 + 18
    alertCfg2_.pos(-POPUP_WIDTH*0.5 + sz2.width*0.5 + 15, ay2_)

    -- local alertCfg4_ = SimpleColorLabel.addMultiLabel(
    --     bm.LangUtil.getText("FRIEND","INVITE_ALERTLBL12"),
    --     16,
    --     styles.FONT_COLOR.LIGHT_TEXT,
    --     styles.FONT_COLOR.GOLDEN_TEXT,
    --     styles.FONT_COLOR.LIGHT_TEXT).addTo(self, 8, 8)
    -- alertCfg4_.setString(bm.LangUtil.getText("FRIEND","INVITE_ALERTLBL22", "50K"))
    -- local sz4 = alertCfg4_.getContentSize()
    -- local ay4_ = -POPUP_HEIGHT*0.5 + 18
    -- alertCfg4_.pos(-POPUP_WIDTH*0.5 + sz2.width + sz4.width*0.5 + 15, ay4_)

    -- 获得邀请好友数据
    self:setLoading(true)

    self:reportNewUserClickInviteBtn_()
end

function InvitePopup:onSelectAllClicked()
    -- 全选/取消权限 按钮点击事件
    if not self.userItems_ or #self.userItems_ == 0 then
        self.setSelectedAll_()
        return
    end

    local selectedNum = self:getSelectedItemNum()
    if selectedNum >= MAX_SELECT_NUM or selectedNum == #self.userItems_ then
        for _, item in ipairs(self.userItems_) do
            item:setSelected(false)
        end
    else
        for _, item in ipairs(self.userItems_) do
            if not item:isSelected() then
                selectedNum = selectedNum + 1
                item:setSelected(true)
                if selectedNum >= MAX_SELECT_NUM then
                    break
                end
            end
        end
    end

    self:setSelecteTip()
end

function InvitePopup:searchIconClick_()
    self.searchStr = self.searchEdit_:getText()
    self:filterData()
end

function InvitePopup:onSearchStart_(event)
    if event == "changed" then
        -- 输入框内容发生变化是
        self.searchStr_ = self.searchEdit_:getText()
        if self.searchStr_ == "" then
            self.searchIcon_:show()
        else
            self.searchIcon_:hide()
        end
    elseif event == "return" then
        self:filterData()
    end
end

function InvitePopup:filterData()
    if self.scrollView_ then
        self.scrollView_:hide()
    end

    self:setNoDataTip(false)

    if self.searchStr_ and self.searchStr_ ~= nil then
        self:onGetData_(true, friendDataGlobal, self.searchStr_)
    end

    self.setSelectedAll_()
end

-- 上报新用户facebook邀请点击量
function InvitePopup:reportNewUserClickInviteBtn_()
    if device.platform == "android" or device.platform == "ios" then
        if nk.userData.lastloginRewardStep and nk.userData.lastloginRewardStep == 1 then
            cc.analytics:doCommand{
                command = "event",args = {eventId = "new_user_fb_invite_click",label = "new_user_fb_invite_click"}
            }
        end
    end
end

function InvitePopup:onGetData_(success, friendData, filterStr)
    if type(friendData) == "string" then --当在加载FB登录界面点击关闭返回 "canceled" or "failed"
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL", "INVITE_FAIL_SESSION"))
        nk.PopupManager:removePopup(self)
        return
    end

    self:setVisible(true)
    friendDataGlobal = clone(friendData)

    self:setLoading(false)
    if success then
        self.pageNum_ = checkint(nk.userDefault:getStringForKey(nk.cookieKeys.FACEBOOK_INVITED_PAGE, 0))
        
        friendData = self.controller_:filterAllData(friendData)

        if filterStr and filterStr ~= "" then
            print("string.lower(filterStr):" .. string.lower(filterStr))
            local tmpData = {}
            for k, v in pairs(friendData) do
                if (string.find(string.lower(v.name),string.lower(filterStr)) ~= nil) then
                    table.insert(tmpData,v)
                end
            end
            friendData = tmpData
        end

        friendData = self:sortFreind_(friendData)

        self.maxData_ = #friendData
        if self.maxData_ == 0 then
            self:setNoDataTip(true)
            return
        end

        self.scrollView_ = bm.ui.ScrollView.new()
        self.inviteUserNode_ = display.newNode()
        local nodeWidth = POPUP_WIDTH
        local nodeHeight = math.ceil(self.maxData_ / 3) * 100
        self.inviteUserNode_:setContentSize(cc.size(nodeWidth, nodeHeight))
        self.userItems_ = {} -- scrollview里面的好友子控件
        for i = 1, self.maxData_ do
            friendData[i].chips =  nk.userData.inviteSendChips
            self.userItems_[i] = InviteListItem.new(friendData[i], self.scrollView_, self, i, 1)
                :pos(
                    -nodeWidth * 0.5 + InviteListItem.ITEM_WIDTH * 0.5 + (i + 2) % 3 * InviteListItem.ITEM_WIDTH,
                    nodeHeight * 0.5 - InviteListItem.ITEM_HEIGHT * 0.5 - math.floor((i - 1) / 3) * InviteListItem.ITEM_HEIGHT
                )
                :addTo(self.inviteUserNode_)
        end

        local outterSelf = self
        local innerSelf = self.scrollView_
        self.scrollView_.onScrolling = function()
            if innerSelf.viewRectOriginPoint_ and #outterSelf.userItems_ > 0 then
                for _, item in ipairs(outterSelf.userItems_) do
                    local tempWorldPt = outterSelf.inviteUserNode_:convertToWorldSpace(cc.p(item:getPosition()))
                    if tempWorldPt.y > innerSelf.viewRectOriginPoint_.y + innerSelf.viewRect_.height + item.ITEM_HEIGHT or tempWorldPt.y < innerSelf.viewRectOriginPoint_.y - item.ITEM_HEIGHT - item.ITEM_HEIGHT then
                        item:hide()
                        if item.onItemDeactived then
                            if tempWorldPt.y - (innerSelf.viewRectOriginPoint_.y + innerSelf.viewRect_.height) > innerSelf.viewRect_.height or innerSelf.viewRectOriginPoint_.y - item.ITEM_HEIGHT - tempWorldPt.y > innerSelf.viewRect_.height then
                                item:onItemDeactived()
                            end
                        end
                    else
                        item:show()
                        if item.lazyCreateContent then
                            item:lazyCreateContent()
                        end
                    end
                end
            end
        end

        local offh = 96
        local offy = LIST_POS_Y
        if IS_SHOWALERT then
            offh = 160
            offy = -16
        end

        self.scrollView_:setViewRect(cc.rect(-POPUP_WIDTH * 0.5, -(POPUP_HEIGHT - offh) * 0.5,
            POPUP_WIDTH, POPUP_HEIGHT - offh))
        self.scrollView_:setScrollContent(self.inviteUserNode_)
        self.scrollView_:pos(0, offy):addTo(self, 2, 2)
        self.scrollView_:update()
        self.scrollView_:update() -- note: 控件bug，需要调用2次update才能正常显示
    else
        self:setNoDataTip(true)
    end
end

--- 排序好友列表
function InvitePopup:sortFreind_(friendData)
    local count = #friendData
    if nk.config.INVITE_SORT_TYPE == 2 and count > 50 then
        --随机固定后分页邀请, 使好友的曝光度均等
        math.randomseed(2015)
        for i=1, count do
            local j,k = math.random(count), math.random(count)
            friendData[j],friendData[k] = friendData[k],friendData[j]
        end
        math.newrandomseed()

        local pageStartIdx = (self.pageNum_ - 1) * 50 + 1
        local pageSizeCount = 50
        if count < pageStartIdx + 50 then
            pageSizeCount = count - pageStartIdx + 1
        end
        local friendDataTmp = {}
        local k,j = 1,1
        for i=1, count do
            if i < pageStartIdx or i >= pageStartIdx + pageSizeCount then
                friendDataTmp[j] = friendData[i]
                j = j + 1
            else
                friendDataTmp[count - pageSizeCount + k] =  friendData[i]
                k = k + 1
            end
        end
        friendData = friendDataTmp
    elseif nk.config.INVITE_SORT_TYPE == 1 then
        --纯随机排序
        for i=1, count do
            local j,k = math.random(count), math.random(count)
            friendData[j],friendData[k] = friendData[k],friendData[j]
        end
    end

    return friendData
end

-- 获取选择了多少个好友
function InvitePopup:getSelectedItemNum()
    local selectedNum = 0
    if self.userItems_ then
        for _, item in ipairs(self.userItems_) do
            if item:isSelected() then
                selectedNum = selectedNum + 1
            end
        end
    end
    return selectedNum
end

function InvitePopup:setSelecteTip()
    local selectedNum = 0
    for _, item in ipairs(self.userItems_) do
        if item:isSelected() then
            selectedNum = selectedNum + 1
        end
    end

    local todayLimitReward = nk.userData.inviteRewardLimit
    local totalReward = selectedNum * nk.userData.inviteSendChips
    local todayMoney = self.controller_:getTodayInvitedMoney_()
    todayLimitReward = todayLimitReward - todayMoney

    if todayLimitReward < 0 then
        todayLimitReward = 0
    end

    if totalReward > todayLimitReward then
        totalReward = todayLimitReward
    end

    self.inviteTip_:setString(bm.LangUtil.getText("FRIEND", "INVITE_SELECT_TIP", selectedNum, totalReward))
    
    -- 设置好友 「全部选择」「取消」的状态
    self.setSelectedAll_()
end

-- 获取当前已经邀请的好友数量
function InvitePopup:getTodayInviteCount()
    local k1 = nk.cookieKeys.FB_LAST_INVITE_DAY
    -- 今日已邀请数量
    local saved_day = nk.userDefault:getStringForKey(k1, '')
    if saved_day == os.date('%Y%m%d') then
        local k2 = nk.cookieKeys.FB_INVITE_FRIENDS_NUMBER
        return nk.userDefault:getIntegerForKey(k2, 0)
    else
        return 0
    end
end

function InvitePopup:onInviteClick_()
    if not self.userItems_ then return end

    local selectedNum = self:getSelectedItemNum()
    local remain_count = MAX_SELECT_NUM

    if INVITE_NUM == 0 then
        self:sendInvites_()
        return
    end

    if remain_count < selectedNum then
        local txt = bm.LangUtil.getText("FRIEND", "INVITE_LEFT_TIP")
        local fmt_txt = bm.LangUtil.formatString(txt, remain_count)
        nk.TopTipManager:showTopTip(fmt_txt)

        return
    elseif selectedNum == 0 then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "INVITE_EMPTY_TIP"))
    elseif remain_count >= selectedNum then
        -- 今日可用邀请数量 > 本次选择的, 继续删除本弹窗自己
        self:sendInvites_()
    else 
        nk.PopupManager:removePopup(self)
        return
    end 
end

function InvitePopup:isCanSelected()
    local selectedNum = self:getSelectedItemNum()
    if selectedNum >= MAX_SELECT_NUM then
        local txt = bm.LangUtil.getText("FRIEND", "INVITE_LEFT_TIP")
        local fmt_txt = bm.LangUtil.formatString(txt, MAX_SELECT_NUM)
        nk.TopTipManager:showTopTip(fmt_txt)

        return false
    end

    return true
end

function InvitePopup:sendInvites_()
    nk.schedulerPool:delayCall(function()
        nk.PopupManager:removePopup(self)
    end, 0.2)

    -- 发送邀请
    if toIds ~= "" then
        self.controller_:sendInvites(self.userItems_)
    end
end

function InvitePopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
                :pos(0, LIST_POS_Y)
                :addTo(self, 9, 9)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

function InvitePopup:setNoDataTip(noData)
    if noData then
        if not self.noDataTip_ then
            self.noDataTip_ = ui.newTTFLabel({text = bm.LangUtil.getText("FRIEND", "NO_FRIEND_TIP"), color = styles.FONT_COLOR.GREY_TEXT, size = 24, align = ui.TEXT_ALIGN_CENTER})
                :pos(0, LIST_POS_Y)
                :addTo(self, 8, 8)
        end
    else
        if self.noDataTip_ then
            self.noDataTip_:removeFromParent()
            self.noDataTip_ = nil
        end
    end
end

function InvitePopup:getInviteRewardText()
    local num = nk.userData.inviteRewardLimit / 1000
    local str = num .. "K"

    return str
end

function InvitePopup:show()
    if MAX_SELECT_NUM <= 0 then --达到当天邀请上限，不显示弹窗
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "INVITE_FULL_TIP"))
        return
    end

    display.addSpriteFrames("invite_texture.plist", "invite_texture.png")
    self:initUI_()
    nk.PopupManager:addPopup(self) 
    self.controller_:getInvitableFriends()
end

function InvitePopup:onShowed()
    -- 延迟设置，防止list出现触摸边界的问题
    if self.scrollView_ then
        self.scrollView_:setScrollContentTouchRect()
    end
end

function InvitePopup:onExit()
    nk.schedulerPool:delayCall(function()
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end, 0.1)
end

return InvitePopup