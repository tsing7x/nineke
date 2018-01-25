--
-- Author: shanks
-- Date: 2014.09.03
--
local CommonRewardChipAnimation = import("app.login.CommonRewardChipAnimation")
local SimpleColorLabel = import("boomegg.ui.SimpleColorLabel")

-- 每日登录奖励
-- 1-6天,超过6天时按照6天的额度奖励
-- 奖励数据来源: nk.userData.loginReward
local LoginRewardView = class("LoginRewardView", nk.ui.Panel)
local SimpleColorLabel = import("boomegg.ui.SimpleColorLabel")
local logger = bm.Logger.new("LoginRewardView")

local WINDOW_WIDTH = 880
local WINDOW_HEIGHT = 540
local BG_TOP_HEIGHT = 60
local BG_MIDDLE_HEIGHT = 360
local BG_BOTTOM_HEIGHT = 110

local CONTEXT_TEXT_COLOR = cc.c3b(0xbb, 0xbb, 0xff)

function LoginRewardView:ctor(hasAnim_)
    self:setNodeEventEnabled(true)

    LoginRewardView.super.ctor(self, {WINDOW_WIDTH, WINDOW_HEIGHT})

    --修改背景框
    self:setBackgroundStyle1()

    self:addCloseBtn()
    self.closeBtn_:pos(self.closeBtn_:getPositionX(), self.closeBtn_:getPositionY() - 16)

    display.newSprite("#pop_loginreward_title_bg2.png")
        :pos(0, WINDOW_HEIGHT * 0.5 - BG_TOP_HEIGHT * 0.5 + 20)
        :addTo(self)
        :setTouchEnabled(true)
    self.leftTitleBar_ = display.newSprite("#pop_loginreward_title_bg.png")
        :pos(0, WINDOW_HEIGHT * 0.5 - BG_TOP_HEIGHT * 0.5)
        :addTo(self)
    self.rightTitleBar_ = display.newSprite("#pop_loginreward_title_bg.png")
        :pos(0, WINDOW_HEIGHT * 0.5 - BG_TOP_HEIGHT * 0.5)
        :addTo(self)
    self.leftTitleBar_:setAnchorPoint(1, 0.5)
    self.rightTitleBar_:setAnchorPoint(1, 0.5)
    self.rightTitleBar_:setScaleX(-1)

    display.newSprite("#pop_loginreward_title.png")
        :pos(0, WINDOW_HEIGHT * 0.5 - BG_TOP_HEIGHT * 0.5)
        :addTo(self)

    if not hasAnim_ then
        local data_ = nk.userDefault:getStringForKey("LOGIN_REWARD_DATA_" .. nk.userData.uid, "")
        if data_ and data_ ~= "" then
            nk.userData.loginReward = json.decode(data_)
        else -- 领取完删除应用重新安装不弹窗BUG
            nk.userData.loginReward = json.decode('{"ret":-1,"baseChip":3000,"days":2,"vipRewardNum":0,"baseReward":[1500,3000,5000,8000,10000,12000],"chips":3000,"vipRewardTips":"ทุกวันผู้เล่น VIP เพชรมีโอกาสรับชิปฟรีสูงสุดถึง 100K + 0 ชิป","data":[{"type":"base","id":0,"chips":3000,"days":2,"tag":0},{"id":2,"chips":0,"type":"play","tag":0}]}')
        end
    end

    -- nk.userData.loginReward.baseReward[i] 第1到6天的奖励数据在此
    -- note: 连续登录领取到第6天以后时, 只要没有中断,继续按照第6天的奖励额度领
    -- 这段代码是用来计算当前领奖励 进行到哪一天了
    for _, v in ipairs(nk.userData.loginReward.data) do
        -- 需要改进客户端和服务器的协议方案约定了,现在这样太容易出问题
        -- 2015.7.7 david feng
        if v.days and v.type == "base" then
            nk.userData.loginReward.days = v.days
            nk.userData.loginReward.baseChip = v.chips

            -- 保存奖励类型, 以确定提示字符串
            local k1 = nk.cookieKeys.QT_NEXT_DAY_CHIPS_TYPE
            nk.userDefault:setStringForKey(k1, 'daily_login_reward')

            -- 保存奖励金额
            local k2 = nk.cookieKeys.QT_NEXT_DAY_CHIPS_REWARD
            local i = v.days + 1
            if i > 6 then i = 6 end
            nk.userDefault:setStringForKey(k2, nk.userData.loginReward.baseReward[i])
        elseif v.type == "fb" then
            nk.userData.loginReward.fbRwd = v.chips
        end
    end

    self:addRewardTips_()

    local item_pos_y = -46
    for i = 1, 6 do
        local x = 70 + (i - 4) * 138

        display.newSprite("#pop_loginreward_item_bg.png")
            :pos(x, item_pos_y)
            :addTo(self, 0, i)

        ui.newTTFLabel({text = bm.LangUtil.getText("LOGINREWARD", "DAYS", (i))..((i==6) and " +" or ""), color = cc.c3b(0xef, 0xef, 0xef), size = 24, align = ui.TEXT_ALIGN_CENTER})
            :pos(x, item_pos_y + 78)
            :addTo(self)

        ui.newTTFLabel({text = "+" .. nk.userData.loginReward.baseReward[i], color = cc.c3b(0xef, 0xef, 0xef), size = 24, align = ui.TEXT_ALIGN_CENTER})
            :pos(x, item_pos_y - 64)
            :addTo(self)

        display.newSprite("#pop_loginreward_day".. i ..".png")
            :pos(x, item_pos_y)
            :addTo(self)

        -- 是否 已经领取过的奖励
        if nk.userData.loginReward.days and i <= nk.userData.loginReward.days then
            display.newSprite("#pop_loginreward_item_got.png")
                :pos(x, item_pos_y + 2)
                :addTo(self)
        else

        end
    end

    ui.newTTFLabel({
            text = bm.LangUtil.getText("LOGINREWARD", "PROMPT", nk.userData.loginReward.baseReward[6]),
            color = CONTEXT_TEXT_COLOR,
            size = 24, align = ui.TEXT_ALIGN_CENTER})
        :pos(0, item_pos_y - 114)
        :addTo(self)

    self.shareBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_blue_normal.png", pressed = "#common_btn_blue_pressed.png"}, {scale9=true})
        :setButtonSize(200, 55)
        :setButtonLabel(ui.newTTFLabel({text=bm.LangUtil.getText("COMMON", "SHARE"), size=30, color=cc.c3b(0xd7, 0xf6, 0xff), align=ui.TEXT_ALIGN_CENTER}))
        :pos(0, -218)
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.onShare))

    -- 播放动画期间触摸边上不让弹框关闭
    if hasAnim_ then
        self.canClose_ = false
        self:playRewardAnim()
    else
        self.canClose_ = true
    end
end

function LoginRewardView:addRewardTips_()
    local lb_t = ui.newTTFLabel({text = bm.LangUtil.getText("LOGINREWARD", "REWARD", nk.userData.loginReward.chipsText or nk.userData.loginReward.chips), color = cc.c3b(0xf9, 0xe5, 0x68), size = 36, align = ui.TEXT_ALIGN_CENTER})
        :pos(0, 168)
        :addTo(self)

    local lb_left_x = -250
    local lb_left_y = 134

    display.newScale9Sprite("#pop_loginreward_content_bg.png", 0, 0, cc.size(self.width_ - 16, 326)):pos(0, -16):addTo(self)

    local loginReward = nk.userData.loginReward
    local str = bm.LangUtil.getText("LOGINREWARD", "REWARD_ADD_3")
    
    --连续登录奖励
    local alertCfg1_ = SimpleColorLabel.addMultiLabel(
        bm.LangUtil.getText("LOGINREWARD", "REWARD_ADD", loginReward.days, loginReward.baseChip) .. str,
        20,
        styles.FONT_COLOR.LIGHT_TEXT,
        styles.FONT_COLOR.GOLDEN_TEXT,
        styles.FONT_COLOR.LIGHT_TEXT).addTo(self, 8, 8)
    alertCfg1_.setString("+" .. loginReward.baseChip)
    local sz1 = alertCfg1_.getContentSize()
    alertCfg1_.pos(lb_left_x + sz1.width/2, lb_left_y)

    --FB登录奖励
    local fbRwd = loginReward.fbRwd or 0
    local alertCfg2_ = SimpleColorLabel.addMultiLabel(
        bm.LangUtil.getText("LOGINREWARD", "REWARD_ADD_2") .. str,
        20,
        styles.FONT_COLOR.LIGHT_TEXT,
        styles.FONT_COLOR.GOLDEN_TEXT,
        styles.FONT_COLOR.LIGHT_TEXT).addTo(self, 8, 8)
    alertCfg2_.setString("+" .. fbRwd)
    local sz2 = alertCfg2_.getContentSize()
    alertCfg2_.pos(lb_left_x + sz2.width/2, lb_left_y - 25)
    local strNum = "3. "
    local posY = 50
    if loginReward.fbreward and loginReward.fbreward == 0 then
        alertCfg2_:hide()
        strNum = "2. "
        posY = 30
    end
    --VIP奖励
    local vipRewardNum = loginReward.vipRewardNum or 0
    local alertCfg3_ = SimpleColorLabel.addMultiLabel(
        strNum .. loginReward.vipRewardTips .. str,
        20,
        styles.FONT_COLOR.LIGHT_TEXT,
        styles.FONT_COLOR.GOLDEN_TEXT,
        styles.FONT_COLOR.LIGHT_TEXT).addTo(self, 8, 8)
    alertCfg3_.setString("+" .. vipRewardNum)
    local sz3 = alertCfg3_.getContentSize()
    alertCfg3_.pos(lb_left_x + sz3.width/2, lb_left_y - posY)
end

function LoginRewardView:onClose()
    if self.canClose_ then
        self:hide_()
    else
        self:playCoinAnim()
        self:hide_() 
    end
end

function LoginRewardView:onShare()
    if nk.userData.loginReward.chips then
        self.shareBtn_:setButtonEnabled(false)
         local feedData = clone(bm.LangUtil.getText("FEED", "LOGIN_REWARD"))
         feedData.name = bm.LangUtil.formatString(feedData.name, nk.userData.loginReward.chips)
         nk.Facebook:shareFeed(feedData, function(success, result)
             logger:debug("FEED.LOGIN_REWARD result handler -> ", success, result)
             if not success then
                 self.shareBtn_:setButtonEnabled(true)
                 nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_FAILED"))
             else
                 nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_SUCCESS"))
                 self:hide_()
             end
         end)
         self.shareBtn_:setButtonEnabled(true)
    end
end

function LoginRewardView:onRemovePopup(removeFunc)
    if self.canClose_ and removeFunc then
        removeFunc()
    end
end

function LoginRewardView:playRewardAnim()
    if nk.userData.loginReward.ret == 1 then
        --保证第二次打开不播动画
        nk.userData.loginReward.ret = -1

        nk.userDefault:setStringForKey("LOGIN_REWARD_DATA_" .. nk.userData.uid, json.encode(nk.userData.loginReward))
        self:performWithDelay(function()
            if not self.canClose_ then
                self:playCoinAnim()
                self.canClose_ = true
            end
        end, 1.0)
    end
end

function LoginRewardView:playCoinAnim()
    local daysTag = nk.userData.loginReward.days
    if nk.userData.loginReward.days > 6 then
        daysTag = 6
    end
    local itemBg = self:getChildByTag(daysTag)
    local rect = itemBg:getParent():convertToWorldSpace(cc.p(itemBg:getPosition()))
    self.animation_ = CommonRewardChipAnimation.new(nil, -rect.x + 210, -rect.y + 130)
    :pos(rect.x-50, rect.y-80)
    :addTo(display.getRunningScene(), 9999)

    self.changeChipAnim_ = nk.ui.ChangeChipAnim.new(nk.userData.loginReward.chips, nil, -rect.x + 190, -rect.y + 50)
    :pos(rect.x, rect.y)
    :addTo(display.getRunningScene(), 9999)

    nk.userData.money = nk.userData.money + nk.userData.loginReward.chips
    nk.UserInfoChangeManager:refreshSceneUserInfoChangeCallback(nk.UserInfoChangeManager.MainHall);
end

function LoginRewardView:hide_()
    self.canClose_ = true
    nk.PopupManager:removePopup(self)
    if self.closeCallback_ then
        self.closeCallback_()
    end
end

return LoginRewardView
