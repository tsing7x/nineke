--
-- Author: KevinLiang@boyaa.com
-- Date: 2016-01-14 11:43:10
--

local UserInfoPopup = class("UserInfoPopup", nk.ui.Panel)

local UserInfoPopupController   = import(".UserInfoPopupController")
local ModifyBankPassWordPopup   = import("app.module.room.bank.ModifyBankPassWordPopup")
local StorePopup                = import("app.module.newstore.StorePopup")
local HelpPopup                 = import("app.module.settingAndhelp.SettingAndHelpPopup")
local PassWordPopUp             = import("app.module.room.bank.PassWordPopUp")
local UpgradePopup              = import("app.module.upgrade.UpgradePopup")
local LoadGiftControl           = import("app.module.gift.LoadGiftControl")
local GiftShopPopup             = import("app.module.gift.GiftShopPopup")
local ScoreHelpPopup            = import(".ScoreHelpPopup")
local UserInfoStuffItem         = import(".UserInfoStuffItem")
local MatchTickPanel            = import("app.module.match.MatchTickPanel")
local UserInfoOtherDialog       = import("app.module.room.views.UserInfoOtherDialog")
local AvatarIcon                = import("boomegg.ui.AvatarIcon")
local AnimationIcon             = import("boomegg.ui.AnimationIcon")
local BubbleButton              = import("boomegg.ui.BubbleButton")
local UserBankPopup             = import("app.module.userInfo.UserBankPopup")
local UserInfoMatchArenaItem    = import("app.module.room.views.UserInfoMatchArenaItem")
local UserInfoMatchRecordItem   = import("app.module.room.views.UserInfoMatchRecordItem")
local logger                    = bm.Logger.new("UserInfoPopup")

local WIDTH = 896
local HEIGHT = 544
local PADDING = 12
local MAX_NICK_LENGTH = 9

local TEXT_COLOR = cc.c3b(0xEE, 0xEE, 0xEE)
local OPTION_TEXT_COLOR = cc.c3b(0x5e, 0x72, 0x9f)
local OPTION_TEXT_COLOR_SELECTED = cc.c3b(0xdd, 0xc5, 0x93)
local content_w, content_h = 672, 260 --底部视图内容背景框大小

function UserInfoPopup:ctor(ctx)
    self.ctx_ = ctx
    self.controller_ = UserInfoPopupController.new(self)
    self.popupName_ = "UserInfoPopup"
    UserInfoPopup.super.ctor(self, {WIDTH, HEIGHT})

    self:addBgLight()
    self:addCloseBtn()
    self:setNodeEventEnabled(true)

    self.openBankView_ = bm.EventCenter:addEventListener(nk.eventNames.OPEN_BANK_POPUP_VIEW, handler(self, self.checkPassWordSuccess))
    self.openResetPasswordDialog_ = bm.EventCenter:addEventListener(nk.eventNames.OPEN_RESET_PASSWORD_DIALOG, handler(self, self.onCancelAndSettingPasswordClicked_))
    self.onMatchStatListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.MATCH_ASYNC_STAT_LOG, handler(self, self.renderMatchStatInfo_))
    self.onGetMatchLogListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.MATCH_ASYNC_RECORD_LOG, handler(self, self.renderRecordList_))

    self.bankChangeFlag = false
    self.propChangeFlag = false
    self.giftChangeFlag = false

    self.passWordFlag = false

    --添加头像结点
    self:addAvatarNode_()

    --添加名字，现金币等用户信息
    self:addUserInfo_()

    --添加底部选项按钮
    self:addOptionButtons_()

    -- 个人成就
    self:addInfoView_ ()
    
    -- 道具面板
    self:addPropView_()

    -- 比赛记录面板
    self:addMatchRecord_()

    self:addPropertyObservers_()
    -- 默认显示个人成就
    self:switchTab(1)
end

--添加头像结点
function UserInfoPopup:addAvatarNode_()
    -- 头像
    local avatarPosX = 75
    local avatarPosY = 75

    self.avatarBg = display.newScale9Sprite("#pop_userinfo_avatar_bg.png", 0, 0, cc.size(152, 152), cc.rect(21, 18, 1, 1))
        :pos(-330, 174)
        :addTo(self)
    self.avatarIcon_ = AvatarIcon.new("#common_male_avatar.png", 100, 100, 8, {resId="#transparent.png", size=cc.size(100,100)}, 1, 14)
        :pos(avatarPosX, avatarPosY)
        :scale(1.5)
        :addTo(self.avatarBg)
    local cameraImage = cc.ui.UIPushButton.new({normal = "#pop_userinfo_change_avatar.png"})
        :pos(avatarPosX * 2, 6)
        :addTo(self.avatarBg)

    self.giftImage_ = AnimationIcon.new("#pop_userinfo_gift.png", 0.6, 0.5, buttontHandler(self, self.openGiftPopUpHandler))
        :pos(0, avatarPosY - 4)
        :addTo(self.avatarBg, 99)

    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:start("analytics.UmengAnalytics")
    end

    local userData = nk.userData
    if not userData.canEditAvatar then
        cameraImage:hide()
    end

    -- 统计点击的次数
    local function report_change_avatar_click()
        if device.platform == "android" or device.platform == "ios" then
            cc.analytics:doCommand {
                command = "event",
                args = {eventId = "change_avatar_click"},
                label = "user Upload Avatar_click"
            }
        end
    end

    local function report_upload_failed(reason)
        local t = bm.LangUtil.getText("USERINFO", "UPLOAD_PIC_UPLOAD_FAIL")
        nk.TopTipManager:showTopTip(t)
        if device.platform == "android" or device.platform == "ios" then
            cc.analytics:doCommand {
                command = "event",
                args = {eventId = "upload_avatar_failed"},
                label = "Upload Avatar to userData.UPLOAD_PIC failed: " .. reason
            }
        end
    end

    local function report_change_avatar_time()
        if device.platform == "android" or device.platform == "ios" then
            cc.analytics:doCommand {
                command = "event",
                args = {eventId = "change_avatar_time"},
                label = "user Upload avatar_time"
            }
        end
    end

    local uploadURL = userData.iconUrl

    local function uploadPictureCallback(result, evt)
        if evt.name == "completed" then
            local request = evt.request
            local code = request:getResponseStatusCode()
            local ret = request:getResponseString()
            logger:debugf("REQUEST getResponseStatusCode() = %d", code)
            logger:debugf("REQUEST getResponseHeadersString() =\n%s", request:getResponseHeadersString())
            logger:debugf("REQUEST getResponseDataLength() = %d", request:getResponseDataLength())
            logger:debugf("REQUEST getResponseString() =\n%s", ret)

            local retTable = json.decode(ret)
            if retTable and retTable.code == 1 and retTable.iconname then
                local imgURL = retTable.iconname
                bm.HttpService.POST(
                    {
                        mod="user", act="uploadIcon",
                        iconname=imgURL
                    },
                    function(ret1)
                        local ret1Table = json.decode(ret1)
                        if ret1Table and ret1Table.code == 1 then
                            userData.b_picture = ret1Table.data.sb_picture
                            userData.m_picture = ret1Table.data.sm_picture
                            userData.s_picture = ret1Table.data.ss_picture

                            local t = bm.LangUtil.getText("USERINFO", "UPLOAD_PIC_UPLOAD_SUCCESS")
                            nk.TopTipManager:showTopTip(t)
                            if self.isInRoom_ or self.isDice_ then
                                nk.socket.HallSocket:sendUserInfoChanged()
                            end
                        else
                            local t = bm.LangUtil.getText("USERINFO", "UPLOAD_PIC_UPLOAD_FAIL")
                            nk.TopTipManager:showTopTip(t)
                        end
                    end,
                    function()
                        local t = bm.LangUtil.getText("USERINFO", "UPLOAD_PIC_UPLOAD_FAIL")
                        nk.TopTipManager:showTopTip(t)
                    end)
            else
                local msg = ""
                if retTable and retTable.msg then
                    msg = retTable.msg
                else
                    msg = bm.LangUtil.getText("USERINFO", "UPLOAD_PIC_UPLOAD_FAIL")
                end
                nk.TopTipManager:showTopTip(msg)
            end
            -- 统计统计换头像成功花费的次数
            report_change_avatar_time()
            os.remove(result)
        elseif evt.name == 'cancelled' then
            report_upload_failed('cancelled')
        elseif evt.name == 'failed' then
            report_upload_failed('failed')
        elseif evt.name == 'unknown' then
            report_upload_failed('unknown')
        else
        end
    end

    local function pickImageCallback(success, result)
        logger:debug("nk.Native:pickImage callback ", success, result)
        if success then
            if bm.isFileExist(result) then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "UPLOAD_PIC_IS_UPLOADING"))
                local sid = appconfig.SID[string.upper(device.platform)] or 1
                local time = os.time()
                local iconKey = "~#kevin&^$xie$&boyaa"
                local sig = crypto.md5(nk.userData.uid .. "|" .. sid .. "|" .. time .. iconKey)

                local upload_data = {
                    fileFieldName = "upload", filePath = result,
                    contentType = "image/png",
                    extra = {
                        {"uid", userData.uid},
                        {"sid", sid},
                        {"time", time},
                        {"sig", sig},
                    }
                }
                if appconfig.LOGIN_SERVER_URL == "http://nineke-th-demo.boyaa.com/mobile.php?demo=1" then
                    table.insert(upload_data.extra,{"demo", 1})
                end
                local cb = bm.lime.simple_curry(uploadPictureCallback, result)
                network.uploadFile(cb, uploadURL,upload_data)
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "UPLOAD_PIC_PICK_IMG_FAIL"))
            end
        else
            if result == "nosdcard" then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "UPLOAD_PIC_NO_SDCARD"))
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "UPLOAD_PIC_PICK_IMG_FAIL"))
            end
        end
    end

    local function onUploadPicClicked()
        report_change_avatar_click()
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
        nk.Native:pickImage(pickImageCallback)
    end

    if uploadURL and userData.canEditAvatar then
        self.uploadPicBtn_ = cc.ui.UIPushButton.new("#transparent.png", {scale9=true})
            :setButtonSize(148, 148)
            :onButtonClicked(onUploadPicClicked)
            :pos(avatarPosX, avatarPosY)
            :addTo(self.avatarBg)
        cameraImage:onButtonClicked(onUploadPicClicked)
    end

    -- 礼物
    if ((nk.config.GIFT_SHOP_ENABLED) and (nk.userData.GIFT_SHOP == 1)) then
        if self.giftUrlReqId_ then
            LoadGiftControl:getInstance():cancel(self.giftUrlReqId_)
        end

        self.giftUrlReqId_ = LoadGiftControl:getInstance():getGiftUrlById(nk.userData.user_gift, function(url)
            self.giftUrlReqId_ = nil
            if url and string.len(url) > 5 then
                self.giftImage_:onData(url, AnimationIcon.MAX_GIFT_DW, AnimationIcon.MAX_GIFT_DH)
            end
        end)
    end

    -- uid标签
    local l_x = -380
    ui.newTTFLabel({text = "ID:", color = cc.c3b(0x76, 0x80, 0xCF), size = 20, align = ui.TEXT_ALIGN_CENTER}):pos(l_x, 80):addTo(self)
    ui.newTTFLabel({text = nk.userData.uid , color = TEXT_COLOR, size = 20, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER, l_x + 15, 80)
        :addTo(self)
end

--添加名字，现金币等用户信息
function UserInfoPopup:addUserInfo_()
    local label_pos_x, label_pos_y = -210, 220
    local interval_h = 65
    self.genderIcon_ = display.newSprite("#pop_userinfo_sex_male.png"):pos(label_pos_x, label_pos_y):addTo(self)

    -- 昵称标签
    self.nickLabel_ = ui.newTTFLabel({
            text = "23456",
            size = 26,
            align = ui.TEXT_ALIGN_LEFT,
        })
        :align(display.LEFT_CENTER, label_pos_x + 20, label_pos_y)
        :addTo(self)

    if nk.userData.canEditAvatar then
        bm.TouchHelper.new(self.genderIcon_, handler(self, self.onGenderIconClick_))

        self.nickEdit_ = ui.newEditBox({image = "#transparent.png", listener = handler(self, self.onNickEdit_), size = cc.size(240, 40)})
            :align(display.LEFT_CENTER, label_pos_x + 20, label_pos_y)
            :addTo(self)
        self.nickEdit_:setFont(ui.DEFAULT_TTF_FONT, 26)
        self.nickEdit_:setPlaceholderFont(ui.DEFAULT_TTF_FONT, 26)
        self.nickEdit_:setMaxLength(25)
        self.nickEdit_:setAnchorPoint(cc.p(0, 0.5))
        self.nickEdit_:setPlaceholderFontColor(cc.c3b(0xEE, 0xEE, 0xEE))
        self.nickEdit_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
        self.nickEdit_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
        self.nickEdit_:setCascadeOpacityEnabled(true)
        self.nickEdit_:setOpacity(0)

        nk.EditBoxManager:addEditBox(self.nickEdit_)

        display.newSprite("#pop_userinfo_edit.png"):pos(label_pos_x + 220, label_pos_y):addTo(self)
    end

    -- 筹码数值
    self.chip_ = self:createInfoItem_(
        "#chip_icon.png",
        bm.formatNumberWithSplit(nk.userData.money),
        label_pos_x, label_pos_y - interval_h, 1,
        buttontHandler(self, self.onAddCashButtonClicked_)
        )

    -- 等级标签
    local level_x, level_y = label_pos_x + 10, label_pos_y - interval_h * 2
    self.level_ = ui.newTTFLabel({text = bm.LangUtil.getText("COMMON", "LEVEL", nk.userData.level) , color = TEXT_COLOR, size = 22, align = ui.TEXT_ALIGN_CENTER})
        :pos(level_x, level_y)
        :addTo(self)

    local size = self.level_:getContentSize()
    -- 经验值条
    local exp_x = level_x + size.width/2 + 5
    self.expProgBar_ = nk.ui.ProgressBar.new(
        "#pop_common_progress_bg.png",
        "#pop_common_progress_img.png",
        {
            bgWidth = 160,
            bgHeight = 26,
            fillWidth = 34,
            fillHeight = 20
        }
    )
    :pos(exp_x, level_y)
    :addTo(self)
    :setValue(nk.Level:getLevelUpProgress(nk.userData.experience))

    local ratio, progress, all = nk.Level:getLevelUpProgress(nk.userData.experience)

    -- 经验值标签
    self.experience_ = ui.newTTFLabel({text = bm.LangUtil.getText("USERINFO","EXPERIENCE_VALUE",progress,all), color = cc.c3b(0xEE, 0xEE, 0xEE), size = 14, align = ui.TEXT_ALIGN_CENTER})
    self.experience_:pos(80, 0)
    self.experience_:addTo(self.expProgBar_)

    --升级领取奖励按钮
    self.upgradeBtn = cc.ui.UIPushButton.new({normal = "#user_info_upgrade_normal.png", pressed = "#user_info_upgrade_pressed.png"})
        :pos(label_pos_x + 220, level_y + 2)
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.onUpgradeClick_))
        :hide()

    --经验帮助按钮
    self.expHelpBtn = cc.ui.UIPushButton.new({normal = "#pop_userinfo_help_normal.png", pressed = "#pop_userinfo_help_pressed.png"})
        :pos(label_pos_x + 220, level_y)
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.onLevelHelpClick_))

    display.newScale9Sprite("#transparent.png", 0, 0, cc.size(45, 45)):addTo(self.expHelpBtn)

    if nk.userData.nextRwdLevel and nk.userData.nextRwdLevel ~= 0 then
        self.upgradeBtn:show()
        self.expHelpBtn:hide()
    end

    local r_x = 90
    -- 黄金币
    self.gcoins_ = self:createInfoItem_(
        "#common_gcoin_icon.png",
        bm.formatNumberWithSplit(nk.userData.gcoins),
        r_x, label_pos_y, 1,
        buttontHandler(self, self.onAddGoldButtonClicked_)
        )
    if not self.gcoinsId_ then
        self.gcoinsId_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "gcoins", handler(self, function (obj, gcoins)
            obj.gcoins_:setString(bm.formatNumberWithSplit(nk.userData.gcoins))
        end))
    end

    -- 现金币
    self.score_ = self:createInfoItem_(
            "#icon_score.png",
            bm.formatNumberWithSplit(nk.userData.score),
            r_x, label_pos_y - interval_h, 1,
            buttontHandler(self, self.onAddCashButtonClicked_)
            )
    if not self.scoreId_ then
        self.scoreId_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "score", handler(self, function (obj, score)
            obj.score_:setString(bm.formatNumberWithSplit(nk.userData.score))
        end))
    end

    -- vip
    if nk.userData.verifyThirdPay == 0 then
    else
        self:addVipLabel_(r_x, label_pos_y - interval_h * 2)
    end

    -- 保险箱按钮
    local px, py = 400, label_pos_y - interval_h * 2
    cc.ui.UIPushButton.new({normal = "#pop_userinfo_bank_normal.png", pressed = "#pop_userinfo_bank_pressed.png"})
        :onButtonClicked(buttontHandler(self, self.onClickBankSaveHandler_))
        :pos(px, py)
        :addTo(self)

    if BM_UPDATE.MATCHMALL and BM_UPDATE.MATCHMALL == 0 then
    else
        cc.ui.UIPushButton.new({normal = "#pop_userinfo_mixed_normal.png", pressed = "#pop_userinfo_mixed_pressed.png"})
            :onButtonClicked(buttontHandler(self, self.onMixButtonClicked_))
            :pos(px, py + interval_h)
            :addTo(self)
    end
end

--yk
function UserInfoPopup:addVipLabel_(x, y)
    local text
    local vipconfig = nk.OnOff:getConfig('newvipmsg')
    local img
    if vipconfig and vipconfig.newvip == 1 then
        text = " " .. bm.LangUtil.getText("VIP", "AVAILABLE_DAYS", vipconfig.ttl)
        img = "#pop_vip_icon_level_" .. vipconfig.vip.level .. ".png"
    else
        text = " " .. bm.LangUtil.getText("VIP", "NOT_VIP")
        img = "#pop_vip_icon_level_0.png"
    end

    self:createInfoItem_(
        img,
        text,
        x, y, 2,
        buttontHandler(self, self.onVipButtonClicked_)
        )
end

function UserInfoPopup:createInfoItem_(icon, labelText, x, y, btnType, callback)
    local bg_w, bg_h = 240, 36

    display.newSprite(icon)
        :pos(x, y)
        :addTo(self, 3) 

    local bg = display.newScale9Sprite("#pop_userinfo_info_bg.png", 0, 0, cc.size(bg_w, bg_h))
            :align(display.RIGHT_CENTER, x + bg_w - 8, y)
            :addTo(self, 1)  

    local btn = cc.ui.UIPushButton.new({normal = "#pop_userinfo_add_button_normal.png", pressed = "#pop_userinfo_add_button_pressed.png"})
        :pos(x + bg_w - 20, y)
        :onButtonClicked(callback)
        :addTo(self, 2) 

    local label = ui.newTTFLabel({text = labelText, color = TEXT_COLOR, size = 22, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER, 32, bg_h/2)
        :addTo(bg, 2)

    if btnType ~= 1 then
        btn:setButtonImage("normal", "#pop_userinfo_arrow_normal.png")
        btn:setButtonImage("pressed", "#pop_userinfo_arrow_pressed.png")
    end
    
    return label
end

function UserInfoPopup:setNickString_(name)
    self.nickLabel_:setString(nk.Native:getFixedWidthText("", 26, name, 190))
end

function UserInfoPopup:onMixButtonClicked_()
    nk.MixCurrentManager:openMixListPopup()
end

function UserInfoPopup:onVipButtonClicked_()
    local selpmode = StorePopup.BLUE_PAY

    if device.platform == "ios" then
        selpmode = StorePopup.BLUE_PAY_IOS 
    end
    
    StorePopup.new(StorePopup.GOODS_VIP, selpmode):showPanel()
end

function UserInfoPopup:onAddCashButtonClicked_()
    StorePopup.new(1):showPanel()
end

function UserInfoPopup:onAddGoldButtonClicked_()
    StorePopup.new(3):showPanel()
end

--添加底部选项按钮
function UserInfoPopup:addOptionButtons_()
    local tab_width = 170
    local tab_height = 85
    local tab_item_pos_x = -341
    local tab_item_pos_y = -21
    local btnTitleSize = 20

    -- 点击我的成就
    self.achievementButton_ = cc.ui.UIPushButton.new({normal = "#pop_userinfo_ver_tab_top_normal.png", pressed = "#pop_userinfo_ver_tab_top_pressed.png"}, {scale9=true})
        :setButtonSize(tab_width, tab_height)
        :onButtonClicked(buttontHandler(self, self.onOpenAchievementClick_))
        :pos(tab_item_pos_x, tab_item_pos_y)
        :addTo(self)

    self.achievementSelected_ = display.newScale9Sprite("#pop_userinfo_ver_tab_top_selected.png", 0, 0, cc.size(tab_width, tab_height), cc.rect(50, 40, 1, 1))
        :addTo(self.achievementButton_, 1)
        :hide()

    self.achievementText_ = ui.newTTFLabel({text = bm.LangUtil.getText("USERINFO","MY_INFOS"), color = OPTION_TEXT_COLOR, size = btnTitleSize, align = ui.TEXT_ALIGN_CENTER})
        :addTo(self.achievementButton_, 2)

    -- 点击物品
    tab_item_pos_y = tab_item_pos_y - tab_height - 2
    self.stuffButton_ = cc.ui.UIPushButton.new({normal = "#pop_userinfo_ver_tab_middle_normal.png", pressed = "#pop_userinfo_ver_tab_middle_pressed.png"}, {scale9=true})
        :setButtonSize(tab_width, tab_height)
        :onButtonClicked(buttontHandler(self, self.onOpenStuffClick_))
        :pos(tab_item_pos_x, tab_item_pos_y)
        :addTo(self)

    self.stuffSelected_ = display.newScale9Sprite("#pop_userinfo_ver_tab_middle_selected.png", 0, 0, cc.size(tab_width, tab_height), cc.rect(50, 40, 1, 1))
        :addTo(self.stuffButton_, 1)
        :hide()

    self.stuffText_ = ui.newTTFLabel({text = bm.LangUtil.getText("USERINFO","MY_GOODS"), color = OPTION_TEXT_COLOR, size = btnTitleSize, align = ui.TEXT_ALIGN_CENTER})
        :addTo(self.stuffButton_, 2)

    -- 点击比赛记录
    tab_item_pos_y = tab_item_pos_y - tab_height - 2
    self.matchButton_ = cc.ui.UIPushButton.new({normal = "#pop_userinfo_ver_tab_bottom_normal.png", pressed = "#pop_userinfo_ver_tab_bottom_pressed.png"}, {scale9=true})
        :setButtonSize(tab_width, tab_height)
        :onButtonClicked(buttontHandler(self, self.onMatchRecordClick_))
        :pos(tab_item_pos_x, tab_item_pos_y)
        :addTo(self)

    self.matchSelected_ = display.newScale9Sprite("#pop_userinfo_ver_tab_bottom_selected.png", 0, 0, cc.size(tab_width, tab_height), cc.rect(50, 40, 1, 1))
        :addTo(self.matchButton_, 1)
        :hide()

    self.matchText_ = ui.newTTFLabel({text = bm.LangUtil.getText("USERINFO","MY_MATCH"), color = OPTION_TEXT_COLOR, size = btnTitleSize, align = ui.TEXT_ALIGN_CENTER})
        :addTo(self.matchButton_, 2)
    
    self.contentFrame_ = display.newScale9Sprite("#pop_userinfo_content_bg.png", 0, 0, cc.size(content_w, content_h), cc.rect(24, 24, 1, 1))
        :pos(86, -108)
        :addTo(self)
end

--个人成就
function UserInfoPopup:addInfoView_()
    self.InfoView_ = display.newNode()
    self.InfoView_:addTo(self)
    self.InfoView_:hide()

    local label_pos_x = -200
    local label_pos_y = -25
    local label_margin_y = 56

    -- 历史胜率
    display.newSprite("#pop_userinfo_my_achievement_spade.png")
        :pos(label_pos_x, label_pos_y)
        :addTo(self.InfoView_)
    self.winRate_ = ui.newTTFLabel({text = bm.LangUtil.getText("USERINFO", "WIN_RATE_HISTORY"), color = TEXT_COLOR, size = 20, align = ui.TEXT_ALIGN_CENTER})
        :pos(label_pos_x + 20, label_pos_y)
        :addTo(self.InfoView_)
    self.winRate_:setAnchorPoint(cc.p(0, 0.5))

    -- 排名
    label_pos_y = label_pos_y - label_margin_y
    display.newSprite("#pop_userinfo_my_achievement_heart.png")
        :pos(label_pos_x, label_pos_y)
        :addTo(self.InfoView_)

    self.ranking_ = ui.newTTFLabel({text = bm.LangUtil.getText("USERINFO", "INFO_RANKING"), color = TEXT_COLOR, size = 20, align = ui.TEXT_ALIGN_CENTER})
        :pos(label_pos_x + 20, label_pos_y)
        :addTo(self.InfoView_)

    self.ranking_:setAnchorPoint(cc.p(0, 0.5))

    -- 赢得最大奖池
    label_pos_y = label_pos_y - label_margin_y
    display.newSprite("#pop_userinfo_my_achievement_club.png")
        :pos(label_pos_x, label_pos_y)
        :addTo(self.InfoView_)

    self.historyAward = ui.newTTFLabel({text = bm.LangUtil.getText("USERINFO", "MAX_POT_HISTORY"), color = TEXT_COLOR, size = 20, align = ui.TEXT_ALIGN_CENTER})
        :pos(label_pos_x + 20, label_pos_y)
        :addTo(self.InfoView_)

    self.historyAward:setAnchorPoint(cc.p(0, 0.5))

    -- 历史最高资产
    label_pos_y = label_pos_y - label_margin_y
    display.newSprite("#pop_userinfo_my_achievement_diamond.png")
        :pos(label_pos_x, label_pos_y)
        :addTo(self.InfoView_)

    self.historyPoperty = ui.newTTFLabel({text = bm.LangUtil.getText("USERINFO", "MAX_MONEY_HISTORY"), color = TEXT_COLOR, size = 20, align = ui.TEXT_ALIGN_CENTER})
        :pos(label_pos_x + 20, label_pos_y)
        :addTo(self.InfoView_)

    self.historyPoperty:setAnchorPoint(cc.p(0, 0.5))

    -- 奖杯区域  
    local cup_pos_x = 233
    local cup_pos_y = -108 
    display.newSprite("#pop_userinfo_my_achievement_cup_bg_left.png")
        :pos(cup_pos_x - 76, cup_pos_y)
        :addTo(self.InfoView_)

    display.newSprite("#pop_userinfo_my_achievement_cup_bg_left.png")
        :pos(cup_pos_x + 76, cup_pos_y)
        :addTo(self.InfoView_)
        :setScaleX(-1)

    display.newSprite("#pop_userinfo_my_achievement_cup_left.png"):pos(cup_pos_x - 88, cup_pos_y + 90):addTo(self.InfoView_)
    display.newSprite("#pop_userinfo_my_achievement_cup_left.png"):pos(cup_pos_x + 88, cup_pos_y + 90):addTo(self.InfoView_):setScaleX(-1)
    ui.newTTFLabel({text = bm.LangUtil.getText("USERINFOMATCH", "SELF_CUP"), color = cc.c3b(0xFF, 0xD7, 0x4A), size = 20, align = ui.TEXT_ALIGN_CENTER})
        :pos(cup_pos_x, cup_pos_y + 90)
        :addTo(self.InfoView_)

    -- 铜牌 
    display.newSprite("#pop_userinfo_my_achievement_cup_bronze.png"):pos(cup_pos_x + 90, cup_pos_y - 9):addTo(self.InfoView_)   
    self.cupTxt3_ = ui.newTTFLabel({text = bm.LangUtil.getText("USERINFO", "MY_PROPS_TIMES", 0), color = TEXT_COLOR, size = 20, align = ui.TEXT_ALIGN_CENTER})
        :pos(cup_pos_x + 90, cup_pos_y - 9 - 54)
        :addTo(self.InfoView_)

    -- 银牌
    display.newSprite("#pop_userinfo_my_achievement_cup_silver.png"):pos(cup_pos_x - 90, cup_pos_y - 9):addTo(self.InfoView_)   
    self.cupTxt2_ = ui.newTTFLabel({text = bm.LangUtil.getText("USERINFO", "MY_PROPS_TIMES", 0), color = TEXT_COLOR, size = 20, align = ui.TEXT_ALIGN_CENTER})
        :pos(cup_pos_x - 90, cup_pos_y - 9 - 54)
        :addTo(self.InfoView_)

    -- 金牌
    display.newSprite("#pop_userinfo_my_achievement_cup_gold.png"):pos(cup_pos_x, cup_pos_y - 20):addTo(self.InfoView_)   
    self.cupTxt1_ = ui.newTTFLabel({text = bm.LangUtil.getText("USERINFO", "MY_PROPS_TIMES", 0), color = cc.c3b(0xFF, 0xD7, 0x4A), size = 20, align = ui.TEXT_ALIGN_CENTER})
        :pos(cup_pos_x, cup_pos_y - 20 - 64)
        :addTo(self.InfoView_)

    --更新实时数据
    self:loadUpdateData()
end

--个人道具
function UserInfoPopup:addPropView_()
    self.propView_ = display.newNode()
    self.propView_:addTo(self)
    self.propView_:hide()
end

--比赛信息
function UserInfoPopup:addMatchRecord_()
    self.matchView_ = display.newNode()
    self.matchView_:addTo(self.contentFrame_)
    self.matchView_:hide()

    local subTabItemWidth, subTabItemHeight = 292, 44
    
    self.subTabBar_ = nk.ui.TabBarWithIndicator.new(
        {
            background = "#pop_userinfo_record_tab_bg.png", 
            indicator = "#pop_userinfo_record_tab.png"
        }, 
        {bm.LangUtil.getText("USERINFOMATCH","COUNT"), bm.LangUtil.getText("USERINFOMATCH","RECORD")}, 
        {
            selectedText = {color = OPTION_TEXT_COLOR_SELECTED, size = 22},
            defaltText = {color = OPTION_TEXT_COLOR, size = 22}
        },
        true, 
        true)
        :setTabBarSize(subTabItemWidth, subTabItemHeight, -10, -8)
        :pos(content_w/2, content_h - 28)
        :gotoTab(1, true)
        :onTabChange(handler(self, self.onTabChanged_))
        :addTo(self.matchView_)
end

function UserInfoPopup:onTabChanged_(selectedTab)
    if selectedTab == 1 then
        self.countNode_:show()
        self.recordNode_:hide()
    else
        self.recordNode_:show()
        self.countNode_:hide()
    end
end

--比赛统计
function UserInfoPopup:addMatchCountContent_()
    self.countNode_ = display.newNode()
        :pos(content_w/2, content_h/2 - 25)
        :addTo(self.matchView_)

    local countNode = self.countNode_
    local titleBg_w, titleBg_h = content_w - 20, 35
    display.newScale9Sprite("#rounded_rect_10.png", 0, 5, cc.size(titleBg_w, 185))
        :opacity(150)
        :addTo(countNode)

    local titleBg = display.newScale9Sprite("#pop_userinfo_record_title.png", 0, 0, cc.size(titleBg_w, titleBg_h))
        :align(display.TOP_CENTER, 0, 97.5)
        :addTo(countNode)

    local dws,dhs = 180, 28
    local offXs = 120
    local fontSzs = 22
    local lblFontSz = 20
    local lblColor = cc.c3b(68, 84, 106)
    local txtColor = cc.c3b(173, 174, 174)
    ui.newTTFLabel({
        text  = bm.LangUtil.getText("USERINFOMATCH", "TYPE"),
        color = lblColor,
        align = ui.TEXT_ALIGN_CENTER,
        dimensions = cc.size(dws, dhs),
        size  = lblFontSz
    }):pos(offXs, titleBg_h/2):addTo(titleBg)

    local offXs2 = 200
    ui.newTTFLabel({
        text  = bm.LangUtil.getText("USERINFOMATCH", "WINRATE"),
        color = lblColor,
        align = ui.TEXT_ALIGN_CENTER,
        dimensions = cc.size(dws, dhs),
        size  = lblFontSz
    }):pos(offXs + offXs2, titleBg_h/2):addTo(titleBg)

    local offXs3 = 220
    ui.newTTFLabel({
        text  = bm.LangUtil.getText("USERINFOMATCH", "MATCHCNT"),
        color = lblColor,
        align = ui.TEXT_ALIGN_CENTER,
        dimensions = cc.size(dws, dhs),
        size  = lblFontSz
    }):pos(offXs + offXs2 + offXs3, titleBg_h/2):addTo(titleBg)

    local LIST_WIDTH = titleBg_w
    local LIST_HEIGHT = 140

    self.countList_ = bm.ui.ListView.new(
        {
            viewRect = cc.rect(-LIST_WIDTH * 0.5, -LIST_HEIGHT * 0.5, LIST_WIDTH, LIST_HEIGHT),
            direction = bm.ui.ListView.DIRECTION_VERTICAL,
        }, 
        UserInfoMatchArenaItem
    )
    :pos(-20, -10)
    :addTo(countNode)
end

--比赛记录
function UserInfoPopup:addMatchRecordContent_()
    self.recordNode_ = display.newNode()
        :pos(content_w/2, content_h/2 - 25)
        :addTo(self.matchView_)
        :hide()

    local recordNode = self.recordNode_
    local titleBg_w, titleBg_h = content_w - 20, 35

    display.newScale9Sprite("#rounded_rect_10.png", 0, 5, cc.size(titleBg_w, 185))
        :opacity(150)
        :addTo(recordNode)

    local titleBg = display.newScale9Sprite("#pop_userinfo_record_title.png", 0, 0, cc.size(titleBg_w, titleBg_h))
        :align(display.TOP_CENTER, 0, 97.5)
        :addTo(recordNode)

    local dws, dhs = 120, 32
    local fontSzs = 22
    local lblColor = cc.c3b(68, 84, 106)
    ui.newTTFLabel({
        text  = bm.LangUtil.getText("USERINFOMATCH", "TYPE"),
        color = lblColor,
        align = ui.TEXT_ALIGN_CENTER,
        dimensions = cc.size(dws,dhs),
        size  = fontSzs
    }):pos(95, titleBg_h/2):addTo(titleBg)

    ui.newTTFLabel({
        text  = bm.LangUtil.getText("USERINFOMATCH", "RANDING"),
        color = lblColor,
        align = ui.TEXT_ALIGN_CENTER,
        dimensions = cc.size(dws,dhs),
        size  = fontSzs
    }):pos(220, titleBg_h/2):addTo(titleBg)

    dws = 340
    ui.newTTFLabel({
        text  = bm.LangUtil.getText("USERINFOMATCH", "REWARD"),
        color = lblColor,
        align = ui.TEXT_ALIGN_CENTER,
        dimensions = cc.size(dws,dhs),
        size  = fontSzs
    }):pos(335, titleBg_h/2):addTo(titleBg)

    dws = 120
    ui.newTTFLabel({
        text  = bm.LangUtil.getText("USERINFOMATCH", "TIME"),
        color = lblColor,
        align = ui.TEXT_ALIGN_CENTER,
        dimensions = cc.size(dws,dhs),
        size  = fontSzs
    }):pos(520, titleBg_h/2):addTo(titleBg)

    local LIST_WIDTH = titleBg_w
    local LIST_HEIGHT = 140
    self.recordList_ = bm.ui.ListView.new(
        {
            viewRect = cc.rect(-LIST_WIDTH * 1.0, -LIST_HEIGHT * 0.5, LIST_WIDTH, LIST_HEIGHT*1),
            direction = bm.ui.ListView.DIRECTION_VERTICAL,
        }, 
        UserInfoMatchRecordItem
    )
    :pos(LIST_WIDTH/2, -10)
    :addTo(recordNode)
    self.recordList_:setNotHide(true)
    self.recordList_:addEventListener("ITEM_EVENT", handler(self, self.onItemEvent_))
    
    nk.MatchRecordManager:asyncMatchLog()
end

-- 比赛记录
function UserInfoPopup:renderRecordList_(evt)
    --[[Response: { "ret":0, "data":[ { 
    id:11, // 场次：11免费场，21中级场，31高级场 
    name: 免费场, 
    rank: 1, // 名次 
    reward: { 
        giftId: 1049, // 礼物，1047金杯,1048银杯,1049铜杯 
        score: 100, // 积分 goldCoupon: 100, // 金券 
        gameCoupon: 100, // 比赛券 
        }, 
    time: 1440128260, // 参赛时间 }, ] } 
    ]] 
    self.recordList_:setData(evt.data)
end

-- 加载用户道具
function UserInfoPopup:loadUserProp()
    if self.toolList_ then
        return
    end

    local LIST_WIDTH = 640
    local LIST_HEIGHT = 240
    self.toolList_ = bm.ui.ListView.new(
        {
            viewRect = cc.rect(-LIST_WIDTH * 0.5, -LIST_HEIGHT * 0.5, LIST_WIDTH, LIST_HEIGHT*1),
            direction=bm.ui.ListView.DIRECTION_VERTICAL
        }, 
        UserInfoStuffItem
    )
    :pos(90, -LIST_HEIGHT*0.5 + 10)
    :addTo(self.propView_)
    self.toolList_:setNotHide(true)
    self.toolList_:addEventListener("ITEM_EVENT", handler(self, self.onItemEvent_))

    self.toolDatas_ = {}
    table.insert(self.toolDatas_, {
        icon="user-info-prop-icon.png",
        label=bm.LangUtil.getText("BANK", "BANK_DROP_LABEL"),
        num=0,
        btnType=0
    })

    table.insert(self.toolDatas_, {
        icon="pop_userinfo_prop_kickCard.png",
        label=bm.LangUtil.getText("VIP", "KICK_CARD"),
        num=0,
        btnType=0
    })

    if nk.OnOff:check("halloweenAct") then
        --todo
        table.insert(self.toolDatas_, {
            icon = "userinfo_halloween_prop.png",
            label = bm.LangUtil.getText("BANK", "BANK_HALLOWEEN_PROP"),
            num = 0,
            btnType = 5
        })
    end

    -- if nk.userData.songkranProps == 1 then
    --     table.insert(self.toolDatas_, {
    --         icon="userinfo_holiday_prop.png",
    --         label=bm.LangUtil.getText("USERINFO", "HOLIDAY_PROP"),
    --         num=0,
    --         btnType=5
    --     })
    -- end
    
    if nk.userData.waterLampProps == 1 then
        table.insert(self.toolDatas_, {
                icon="waterLampPropAB.png",
                label=bm.LangUtil.getText("WATERLAMP", "WATER_LAMP_PROP"),
                num=0,
                btnType=6
            })
    end

    -- 获取门票
    local tickets = nk.MatchTickManager:getAllTickets()
    if tickets and tickets.num == 0 then
        
    else
        for i  = 1, #tickets do 
            table.insert(self.toolDatas_, tickets[i])
        end
    end

    if nk.userData.vipcoupon == 1 then
        table.insert(self.toolDatas_, {
            icon="pop_userinfo_prop_vipcoupon.png",
            label=bm.LangUtil.getText("VIP", "COUPON"),
            num=1,
            btnType=4
        })
    end

    self.toolList_:setData(self:transformToolDatas(self.toolDatas_))
    -- 添加数据观察器
    self.controller_:getHddjNum()

    -- 更新互动道具
    self:updateHDDJData()

    -- 更新踢人卡数量
    self:updateKickData()

    -- 更新节日道具数量
    -- if nk.userData.songkranProps == 1 then
    --     self:updateHolidayPropData()
    -- end

    --更新水灯节道具数量
    if nk.userData.waterLampProps == 1 then
        self:updateWaterLampPropData()
    end
    

    if nk.OnOff:check("halloweenAct") then
        --todo
        self:updateHalloweenPropNum()
    end
end

-- 道具类型转换，一行三个
function UserInfoPopup:transformToolDatas(data)
    local resArray = {}
    local length = math.ceil(#data/3)
    for i = 1, length do
        local arr = {}
        local min = math.min(i * 3, #data)
        for k = (i - 1) * 3 + 1, min do
            table.insert(arr, #arr+1, data[k])
        end
        table.insert(resArray, #resArray+1, arr)
    end
    
    return resArray
end

-- 根据icon 更新道具数量
function UserInfoPopup:getToolDatasByIcon(icon)
    for i,v in ipairs(self.toolDatas_) do
        if v.icon == icon then
            return v
        end
    end
    return nil
end

function UserInfoPopup:onItemEvent_(evt)
    if evt.type == "USE_PROP" then
        StorePopup.new(2):showPanel()
    elseif evt.type == "BUY_GIFT" then
        self:onSelectedUserGift(evt.data)
    elseif evt.type == "SEE_PROP" then
        self:onOpenStuffClick_(self, bm.TouchHelper.CLICK)
    elseif evt.type == "APPLY_PROP" then
        nk.userData.useTickType_ = nk.MatchTickManager.TYPE2-- 个人档门票弹出框使用门票
        nk.MatchTickManager:applyTick(evt.data)
    elseif evt.type == "USE_VIP_COUPON" then
        self:gotoVipMarket()
    elseif evt.type == "USE_HOLIDAY_PROP" then
        self:gotoPlay()
    elseif evt.type == "USE_WATERLAMP_PROP" then
        self:quickStart()
    end
end

--立即玩牌
function UserInfoPopup:gotoPlay()
    local curScene = display.getRunningScene()
    if curScene.name == "HallScene" then
        if curScene.controller_ then
            curScene.controller_:getEnterRoomData(nil, true)
        end
    end

    self:hidePanel_()
end

function UserInfoPopup:quickStart()
    local curScene = display.getRunningScene()
    if curScene.name == "HallScene" then
        if curScene.controller_ then
            curScene.controller_:getEnterRoomData({}, true)
        end
    end

    self:hidePanel_()
end

function UserInfoPopup:gotoVipMarket()
    self:onVipButtonClicked_()
end

function UserInfoPopup:loadUpdateData()
    self.rankingRequestId_ = bm.HttpService.POST({mod="user", act="main"},
        function(data)
            self.rankingRequestId_ = nil
            local callData = json.decode(data)
            if callData then
                if callData.maxmoney ~= nil and callData.maxaward ~= nil and callData.money ~= nil then
                    nk.userData.maxmoney = callData.maxmoney or nk.userData.maxmoney or 0
                    nk.userData.maxaward = callData.maxaward or nk.userData.maxaward or 0
                    nk.userData.level = callData.level or nk.userData.level or 1
                    nk.userData.win = callData.win or nk.userData.win or 0
                    nk.userData.lose = callData.lose or nk.userData.lose or 0
                    

                    if not self.ranking_ then
                        return
                    end
                    if callData.rankMoney > 10000 then
                        self.ranking_:setString(bm.LangUtil.getText("USERINFO", "INFO_RANKING") .. ">10,000")
                    else
                        self.ranking_:setString(bm.LangUtil.getText("USERINFO", "INFO_RANKING") .. bm.formatNumberWithSplit(callData.rankMoney))
                    end
                    -- 
                    nk.UserInfoChangeManager:updateOtherMethod(function()
                        nk.userData.gameCoupon = callData.gameCoupon or nk.userData.gameCoupon or 0
                        nk.userData.gcoins = callData.gcoins or nk.userData.gcoins or 0
                        nk.userData.money = callData.money or nk.userData.money or 0
                        nk.userData.score = callData.coins or nk.userData.score or 0
                    end)                    
                end

                self.historyPoperty:setString(bm.LangUtil.getText("USERINFO", "MAX_MONEY_HISTORY") .. bm.formatBigNumber(callData.maxmoney))
                self.historyAward:setString(bm.LangUtil.getText("USERINFO", "MAX_POT_HISTORY") .. bm.formatBigNumber(callData.maxaward))
                self.chip_:setString(bm.formatNumberWithSplit(nk.userData.money))
                self.score_:setString(bm.formatNumberWithSplit(nk.userData.score))
                self.gcoins_:setString(bm.formatNumberWithSplit(nk.userData.gcoins))
                self.level_:setString(bm.LangUtil.getText("COMMON", "LEVEL", callData.level))
                self.winRate_:setString(bm.LangUtil.getText("USERINFO", "WIN_RATE_HISTORY") .. " " .. (callData.win + callData.lose > 0 and math.round(callData.win * 100 / (callData.win + callData.lose)) or 0) .."%")
            end
        end, function()
            self.rankingRequestId_ = nil
        end)
end

function UserInfoPopup:updateKickData()
    self.kickNumberRequestId_ = bm.HttpService.POST({mod="user", act="getUserProps"},
        function(data)
            self.kickNumberRequestId_ = nil
            local callData = json.decode(data)

            if callData and #callData > 0 then
                for i = 1, #callData do
                    if callData[i].a == "5" then
                        local toolData = self:getToolDatasByIcon("pop_userinfo_prop_kickCard.png")
                        toolData.num = tonumber(callData[i].b)
                        nk.userData.kickNum = toolData.num
                        if (self.isInRoom_ and toolData.num > 0) then
                            toolData.btnType = 1
                        else
                            toolData.btnType = 0
                        end
                        -- 
                        if self.toolList_ then
                            self.toolList_:setData(self:transformToolDatas(self.toolDatas_))
                        end
                    end
                end
                
            else
            end
        end, function()
            self.kickNumberRequestId_ = nil
        end)
end

function UserInfoPopup:updateHDDJData()
    self.hddjNumRequestId_ = bm.HttpService.POST(
        {
            mod = "user",
            act = "getUserFun"
        },
        function (data)
            nk.userData.hddjNum = tonumber(data)
            if self.getToolDatasByIcon and self.toolDatas_ then
                local toolData = self:getToolDatasByIcon("user-info-prop-icon.png")
                toolData.num = nk.userData.hddjNum
                if (self.isInRoom_ and nk.userData.hddjNum > 0) then
                    toolData.btnType = 1
                else
                    toolData.btnType = 0
                end
                -- 
                if self.toolList_ then
                    self.toolList_:setData(self:transformToolDatas(self.toolDatas_))
                end
            end
            self.hddjNumRequestId_ = nil
        end,
        function ()
            self.hddjNumRequestId_ = nil
        end
    )
end

--更新节日道具数量
function UserInfoPopup:updateHolidayPropData()
    self.holidayPropNumRequestId_ = bm.HttpService.POST(
        {
            mod = "Songkran",
            act = "getActFunFace"
        },
        function (jsonData)
            local data = json.decode(jsonData)
            if data.num then
                if self.getToolDatasByIcon and self.toolDatas_ then
                local toolData = self:getToolDatasByIcon("userinfo_holiday_prop.png")
                    toolData.num = data.num

                    if self.toolList_ then
                        self.toolList_:setData(self:transformToolDatas(self.toolDatas_))
                    end
                end
            end
            
            self.holidayPropNumRequestId_ = nil
        end,
        function ()
            self.holidayPropNumRequestId_ = nil
        end
    )
end

function UserInfoPopup:updateWaterLampPropData()
    self.waterLampPropNumRequestId_ = bm.HttpService.POST(
    {
        mod = "Lkf",
        act = "getFreeTime",
        uid = tonumber(nk.userData.uid)
     },
    function (data) 
        local callData = json.decode(data)
        local propsCount = callData.propsCount
        if propsCount then
            if self.getToolDatasByIcon and self.toolDatas_ then
            local toolData = self:getToolDatasByIcon("waterLampPropAB.png")
                toolData.num = propsCount

                if self.toolList_ then
                    self.toolList_:setData(self:transformToolDatas(self.toolDatas_))
                end
            end
        end

        self.waterLampPropNumRequestId_ = nil
    end,
    function (data)
        self.waterLampPropNumRequestId_ = nil
    end)
end

function UserInfoPopup:updateHalloweenPropNum()
    -- body
    self.ReqHalloweenPropNumId_ = bm.HttpService.POST({mod = "Halloween", act = "getPumpkinNum"}, function(jsonData)
        local data = json.decode(jsonData)
        -- dump(data, "UserInfoPopup:updateHalloweenPropNum.data :==============")

        if data.data and data.data.num then
            if self.getToolDatasByIcon and self.toolDatas_ then
            local toolData = self:getToolDatasByIcon("userinfo_halloween_prop.png")
                toolData.num = data.data.num

                if self.toolList_ then
                    self.toolList_:setData(self:transformToolDatas(self.toolDatas_))
                end
            end
        end
        
        self.ReqHalloweenPropNumId_ = nil
    end, function(errData)
        dump(errData, "UserInfoPopup:updateHalloweenPropNum.errData :==============")
        self.ReqHalloweenPropNumId_ = nil
    end)
end

function UserInfoPopup:addPropertyObservers_()
    self.nickObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "nick", function (nick)
        self:setNickString_(nick)
    end)

    self.sexObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "sex", function (sex)
        if sex == "f" then
            self.selectedGender_ = "f"
            self.genderIcon_:setSpriteFrame(display.newSpriteFrame("pop_userinfo_sex_female.png"))
        else
            self.selectedGender_ = "m"
            self.genderIcon_:setSpriteFrame(display.newSpriteFrame("pop_userinfo_sex_male.png"))
        end
    end)

    self.moneyObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "money", function (money)
        if not money then return end
        if self.chip_ then
            self.chip_:setString(bm.formatNumberWithSplit(money))
        end
    end)

    self.expObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "experience", function (exp)
        if not exp then return end
        local ratio, progress, all = nk.Level:getLevelUpProgress(exp)
        if self.expProgBar_ then
            self.expProgBar_:setValue(ratio)
        end
        if self.experience_ then
            self.experience_:setString(bm.LangUtil.getText("USERINFO","EXPERIENCE_VALUE",progress,all))
        end
    end)

    self.levelObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "level", function (lv)
        if not lv then return end
        if self.level_ then
            self.level_:setString(bm.LangUtil.getText("COMMON", "LEVEL", lv))
        end
    end)

    self.avatarUrlObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "s_picture", function (s_picture)
        if string.len(s_picture) <= 5 then
            if nk.userData.sex == "f" then
                self.avatarIcon_:setSpriteFrame("common_female_avatar.png")
            else
                self.avatarIcon_:setSpriteFrame("common_male_avatar.png")
            end
        else
            local imgurl = s_picture
            if string.find(imgurl, "facebook") then
                if string.find(imgurl, "?") then
                    imgurl = imgurl .. "&width=200&height=200"
                else
                    imgurl = imgurl .. "?width=200&height=200"
                end
            end
            self.avatarIcon_:loadImage(imgurl)
        end
    end)

    self.nextRwdLevelHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "nextRwdLevel", function (nextRwdLevel)
        if nextRwdLevel ~= 0 then
            self.upgradeBtn:show()
            self.expHelpBtn:hide()
        else
            self.upgradeBtn:hide()
            self.expHelpBtn:show()
        end
    end)

    if ((nk.config.GIFT_SHOP_ENABLED) and (nk.userData.GIFT_SHOP == 1)) then
        self.giftImageHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "user_gift", function (nextRwdLevel)
            if self.giftUrlReqId_ then
                LoadGiftControl:getInstance():cancel(self.giftUrlReqId_)
            end
            self.giftUrlReqId_ = LoadGiftControl:getInstance():getGiftUrlById(nk.userData.user_gift, function(url)
                self.giftUrlReqId_ = nil
                if url and string.len(url) > 5 then
                    self.giftImage_:onData(url, AnimationIcon.MAX_GIFT_DW, AnimationIcon.MAX_GIFT_DH)
                end
            end)
        end)
    end
end

function UserInfoPopup:removePropertyObservers_()
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "nick", self.nickObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "sex", self.sexObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "s_picture", self.avatarUrlObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "money", self.moneyObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "experience", self.expObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "level", self.levelObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "nextRwdLevel", self.nextRwdLevelHandle_)
    if ((nk.config.GIFT_SHOP_ENABLED) and (nk.userData.GIFT_SHOP == 1)) then
        bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "user_gift", self.giftImageHandle_)
    end
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "gcoins", self.gcoinsId_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "score", self.scoreId_)

end

function UserInfoPopup:onNickEdit_(event, editbox)
    if event == "began" then
        local text = self.nickLabel_:getString()
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
        editbox:setText(text)
    elseif event == "changed" then
    elseif event == "ended" then
    elseif event == "return" then
        local text = editbox:getText()
        local filteredText = nk.keyWordFilter(text)
        self.editNick_ = string.trim(filteredText)
        self:setNickString_(filteredText)
    end
end

function UserInfoPopup:onMatchRecordClick_()
    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    self:switchTab(2)
end

function UserInfoPopup:onScoreClick_()
    ScoreHelpPopup.new(display.cx + 245,display.cy + 30, bm.LangUtil.getText("USERINFO", "SCORE_TIPS"), true):show()
end

function UserInfoPopup:onLevelHelpClick_()
    HelpPopup.new(false,true,4):show()
end

function UserInfoPopup:onUpgradeClick_()
    display.addSpriteFrames("upgrade_texture.plist", "upgrade_texture.png", function()
        UpgradePopup.new(nk.userData.nextRwdLevel):show()
    end)
end

function UserInfoPopup:switchTab(index_)
    local buttons = {self.achievementButton_, self.matchButton_, self.stuffButton_}
    local buttonSelects = {self.achievementSelected_, self.matchSelected_, self.stuffSelected_}
    local buttonTexts = {self.achievementText_, self.matchText_, self.stuffText_}
    local views = {self.InfoView_, self.matchView_, self.propView_}

    for i = 1, 3 do
        if index_ == i then
            buttonSelects[i]:show()
            buttonTexts[i]:setTextColor(OPTION_TEXT_COLOR_SELECTED)
            views[i]:show()
        else
            buttonSelects[i]:hide()
            buttonTexts[i]:setTextColor(OPTION_TEXT_COLOR)
            views[i]:hide()
        end
    end
end

function UserInfoPopup:onOpenStuffClick_()
    print("我的物品点击了")
    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    self:switchTab(3)
end

function UserInfoPopup:onOpenAchievementClick_()
    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    self:switchTab(1)
end

function UserInfoPopup:onCancelAndSettingPasswordClicked_()
    nk.ui.Dialog.new({
        hasCloseButton = true,
        messageText = bm.LangUtil.getText("BANK", "BANK_CANCEL_OR_SETING_PASSWORD"),
        firstBtnText = bm.LangUtil.getText("BANK", "BANK_CACEL_PASSWORD_BUTTON_LABEL"),
        secondBtnText = bm.LangUtil.getText("BANK", "BANK_SETTING_PASSWORD_BUTTON_LABEL"),
        callback = function (type)
            if type == nk.ui.Dialog.FIRST_BTN_CLICK then
                self:CancelPassWordClick_()
            elseif type == nk.ui.Dialog.SECOND_BTN_CLICK then
                self:onSetPassWordClick_()
            end
        end
    }):show()
end

--取消密码
function UserInfoPopup:CancelPassWordClick_()
    self.cancelPasswordRequestId_ = bm.HttpService.POST({mod="bank", act="canclePWD", token = crypto.md5(nk.userData.uid..nk.userData.mtkey..os.time().."*&%$#@123++web-ipoker)(abc#@!<>;:to"), time =os.time()},
        function(data)
            self.cancelPasswordRequestId_ = nil
            local callData = json.decode(data)
            if callData ~= nil and callData.tag == 0 then
                nk.userData.bank_password = false
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK","CANCEL_PASSWORD_SUCCESS_TOP_TIP"))
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK","CANCEL_PASSWORD_FAIL_TOP_TIP"))
            end
        end, function()
            self.cancelPasswordRequestId_ = nil
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK","CANCEL_PASSWORD_FAIL_TOP_TIP"))
        end)
end

--设置密码
function UserInfoPopup:onSetPassWordClick_()
    bm.HttpService.POST(
        {
            mod="PwdProtected",
            act="getPwdquestion"
        },
        function(data)
            local ret = json.decode(data)
            if ret and ret.tag == 1 then
                ModifyBankPassWordPopup.new(ret):show()

            else
                ModifyBankPassWordPopup.new():show()
            end
        end, function()
            ModifyBankPassWordPopup.new():show()
        end)
end

function UserInfoPopup:onGenderIconClick_(target, evt)
    if evt == bm.TouchHelper.CLICK then
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
        if self.selectedGender_ == "f" then
            self.genderIcon_:setSpriteFrame(display.newSpriteFrame("pop_userinfo_sex_male.png"))
            if string.len(nk.userData.s_picture) <= 5 then
                self.avatarIcon_:setSpriteFrame("common_male_avatar.png")
            end

            self.selectedGender_ = "m"
        else
            self.genderIcon_:setSpriteFrame(display.newSpriteFrame("pop_userinfo_sex_female.png"))
            if string.len(nk.userData.s_picture) <= 5 then
                self.avatarIcon_:setSpriteFrame("common_female_avatar.png")
            end

            self.selectedGender_ = "f"
        end
    end
end

function UserInfoPopup:setHddjNum(num)
    local toolData = self:getToolDatasByIcon("user-info-prop-icon.png")
    toolData.num = tonumber(num) or 0
    if (self.isInRoom_ and toolData.num > 0) then
        toolData.btnType = 1
    else
        toolData.btnType = 0
    end
    if self.toolList_ then
        self.toolList_:setData(self:transformToolDatas(self.toolDatas_))
    end
end

function UserInfoPopup:show(isInRoom,tableMessage,isDice,notShowGift)
    self.isInRoom_ = isInRoom
    self.isDice_ = isDice
    nk.userData.isInRoom = isInRoom
    if self.isInRoom_ then
        self.tableAllUid = tableMessage.tableAllUid
        self.toUidArr = tableMessage.toUidArr
        self.tableNum = tableMessage.tableNum
    end
    if notShowGift and self.giftImage_ then
        self.giftImage_:hide()
    end
    self:showPanel_()
    nk.cacheKeyWordFile()
end

function UserInfoPopup:openGiftPopUpHandler()
    if ((nk.config.GIFT_SHOP_ENABLED) and (nk.userData.GIFT_SHOP == 1)) then
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
        if self.isInRoom_ then
            local curScene = display.getRunningScene()
            if curScene.name == "PdengScene" then
                return
            end
            GiftShopPopup.new(2):show(self.isInRoom_,nk.userData.uid,self.tableAllUid,self.tableNum,self.toUidArr)
        else
            GiftShopPopup.new(2):show(self.isInRoom_,nk.userData.uid)
        end
    end
end

-- 更新统计面板信息
function UserInfoPopup:renderMatchStatInfo_(evt)
    if evt and evt.data and self.cupTxt1_ then
        local stat = evt.data.stat
        local cups = evt.data.cups
        self.cupTxt3_:setString(bm.LangUtil.getText("USERINFO", "MY_PROPS_TIMES", cups[1]))-- 铜杯
        self.cupTxt2_:setString(bm.LangUtil.getText("USERINFO", "MY_PROPS_TIMES", cups[2]))-- 银杯
        self.cupTxt1_:setString(bm.LangUtil.getText("USERINFO", "MY_PROPS_TIMES", cups[3]))-- 金杯

        self.countList_:setData(stat)
    end
end

function UserInfoPopup:onCleanup()
    self.controller_:dispose()
    self:removePropertyObservers_()
    bm.EventCenter:removeEventListener(self.openBankView_)
    bm.EventCenter:removeEventListener(self.openResetPasswordDialog_)
    bm.EventCenter:removeEventListener(self.onMatchStatListenerId_)
    bm.EventCenter:removeEventListener(self.onGetMatchLogListenerId_)

    if self.nickEdit_ then
        nk.EditBoxManager:removeEditBox(self.nickEdit_)
    end
    
    if (self.selectedGender_ and self.selectedGender_ ~= nk.userData.sex) or (self.editNick_ and self.editNick_ ~= nk.userData.nick) then
        bm.HttpService.POST(
            {
                mod = "user",
                act = "modifyInfo",
                nick = self.editNick_,
                s = self.selectedGender_
            }
        )

        if self.selectedGender_ and self.selectedGender_ ~= nk.userData.sex then
            nk.userData.sex = self.selectedGender_
            if string.len(nk.userData.s_picture) <= 5 then
                nk.userData.s_picture = nk.userData.s_picture
            end
        end

        if self.editNick_ and self.editNick_ ~= nk.userData.nick then
            nk.userData.nick = self.editNick_
            if self.isInRoom_ or self.isDice_ then
                nk.socket.HallSocket:sendUserInfoChanged()
            end
        end
    end

    if self.rankingRequestId_ then
        bm.HttpService.CANCEL(self.rankingRequestId_)
        self.rankingRequestId_ = nil
    end

    if self.kickNumberRequestId_ then
        bm.HttpService.CANCEL(self.kickNumberRequestId_)
        self.kickNumberRequestId_ = nil
    end

    if self.hddjNumRequestId_ then
        bm.HttpService.CANCEL(self.hddjNumRequestId_)
        self.hddjNumRequestId_ = nil
    end

    if self.holidayPropNumRequestId_ then
        bm.HttpService.CANCEL(self.holidayPropNumRequestId_)
        self.holidayPropNumRequestId_ = nil
    end

    if self.waterLampPropNumRequestId_ then
        bm.HttpService.CANCEL(self.waterLampPropNumRequestId_)
        self.waterLampPropNumRequestId_ = nil
    end

    if self.ReqHalloweenPropNumId_ then
        bm.HttpService.CANCEL(self.ReqHalloweenPropNumId_)
        self.ReqHalloweenPropNumId_ = nil
    end
end

function UserInfoPopup:onShowed()
    self.isShowed_ = true

    -- 加载用户道具
    self:loadUserProp()
    --比赛统计
    self:addMatchCountContent_()
    --比赛记录
    self:addMatchRecordContent_()
    self:updateTouchRect_()

    nk.MatchRecordManager:asyncMatchStat()
end

function UserInfoPopup:updateTouchRect_()
    if self.toolList_ then
        self.toolList_:setScrollContentTouchRect()
    end

    if self.countList_ then
        self.countList_:setScrollContentTouchRect()
    end

    if self.recordList_ then
        self.recordList_:setScrollContentTouchRect()
    end
end

function UserInfoPopup:onOpenPropClick_()

end

function UserInfoPopup:onClickBankSaveHandler_(target, evt)
    if nk.userData.level < 5 then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK","BANK_LEVELS_DID_NOT_REACH"))
    else
        if (not nk.userData.bank_password) then
            UserBankPopup.new():show()
        else
            if nk.userData.bank_password  and not self.passWordFlag then
                 PassWordPopUp.new():show()
             end
            -- self.passWordFlag 置为false,为了连续点击弹出密码框
            self.passWordFlag = false
        end
    end
end

function UserInfoPopup:checkPassWordSuccess( )
    --  self.passWordFlag 不让第二次点击输入密码框弹出来
    self.passWordFlag = true
    UserBankPopup.new():show() 
end

return UserInfoPopup
