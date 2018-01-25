--
-- Author: KevinYu
-- Date: 2016-1-20 10:44:31

local UpdatePopup = import(".UpdatePopup")
local SettingView = class("SettingView", function ()
    return display.newNode()
end)

local AboutPopup = import("app.module.about.AboutPopup")

local labelTitleSize = 26
local labelContentSize = 26
local labelTitleColor = cc.c3b(0x27, 0x90, 0xd5)
local labelContentColor = cc.c3b(0xca, 0xca, 0xca)

local contentWidth = 750 --列表元素 背景框宽度
local contentHeight = 67 --列表元素 背景框一个单位高度
local contentPadding = 40 --列表元素 左边文字位置
local dividerWidth, dividerHeight = 696, 4 --列表元素分割线，宽高
local switchPadding = 165   --开关按钮位置
local soundProgressWidth = 440
local soundProgressHeight = 26
local soundProgressFillHeight = 20

function SettingView:ctor(mainView)
    self.mainView_ = mainView
    self:setupView()

    self:setNodeEventEnabled(true)
end

function SettingView:onExit()
    cc.UserDefault:getInstance():setBoolForKey(nk.cookieKeys.SHOCK, self.isVibrate_)
    cc.UserDefault:getInstance():setBoolForKey(nk.cookieKeys.AUTO_SIT, self.isAutoSit_)
    cc.UserDefault:getInstance():setBoolForKey(nk.cookieKeys.AUTO_BUY_IN, self.isAutoBuyin_)
    if self.isBgSound1_~=self.isBgSound_ then
        cc.UserDefault:getInstance():setBoolForKey(nk.cookieKeys.BG_SOUND, self.isBgSound1_)
    end
    if self.isChatVoice1_~=self.isChatVoice_ then
        cc.UserDefault:getInstance():setBoolForKey(nk.cookieKeys.CHATVOICE, self.isChatVoice1_)
    end
    cc.UserDefault:getInstance():flush()
    if self.isChatVoice1_~=self.isChatVoice_ then
        nk.SoundManager:updateVolume()
    end
    if (self.isFollowFriend_ == (nk.userData.isfollowfriend == 1)) then
        if self.isFollowFriend_ then
            nk.userData.isfollowfriend = 1
        else
            nk.userData.isfollowfriend = 0
        end
    else
        if self.isFollowFriend_ then
            nk.userData.isfollowfriend = 1
        else
            nk.userData.isfollowfriend = 0
        end
        bm.HttpService.POST(
        { mod = "Friend",
          act = "setFollowFriends",
          followOff = nk.userData.isfollowfriend
        },function()
        end,function()
        end)
    end
end

function SettingView:setupView()
    local size_ = self.mainView_.background_:getContentSize()
    local titlePadding = self.mainView_.TAB_HEIGHT
    local contentMarginTop = 12
    local heightSum = 0
    local topOriginY = size_.height/2 - (self.mainView_.TAB_HEIGHT + self.mainView_.PADDING)

    --ScrollView
    local scrollContent = display.newNode() 
    self.container_ = display.newNode():addTo(scrollContent)

    --添加名字和登出
    heightSum = heightSum  + titlePadding
    topOriginY = topOriginY - titlePadding

    self:addNameNode_(topOriginY+contentHeight)

    --添加声音设置
    heightSum = heightSum + contentHeight + contentMarginTop
    topOriginY = topOriginY - contentHeight - contentMarginTop

    self:addSoundNode_(topOriginY)
    
    --自动坐下以及自动买入
    heightSum = heightSum  + contentHeight * 3 + contentMarginTop
    topOriginY = topOriginY - contentHeight * 3 - contentMarginTop

    topOriginY = topOriginY - contentHeight
    self:addAutoBtn_(topOriginY+contentHeight)
    
    --其他内容
    heightSum = heightSum  + contentHeight * 3 + contentMarginTop
    topOriginY = topOriginY - contentHeight * 3 - contentMarginTop

    self:addOtherContent_(heightSum, topOriginY+contentHeight)

    local w, h = contentWidth + 10, 365
    local bound = cc.rect(-0.5 * w, -0.5 * h+contentHeight*0.5, w, h)
    self.scrollView_ = bm.ui.ScrollView.new({viewRect = bound, scrollContent = scrollContent, direction = bm.ui.ScrollView.DIRECTION_VERTICAL})
        :pos(0, -size_.height/2 + h/2 )
        :addTo(self)    
end

--添加名字和登出
function SettingView:addNameNode_(topOriginY)
        local container = self.container_
        local nickNameContent = display.newScale9Sprite(
            "#panel_overlay.png", 
            contentWidth/2, topOriginY - contentHeight/2,
            cc.size(contentWidth, contentHeight))
            :addTo(container)

        --昵称
        local nickNameTitle = ui.newTTFLabel({
                text = bm.LangUtil.getText("SETTING", "NICK"),
                size = labelContentSize,
                color = labelContentColor,
                align = ui.TEXT_ALIGN_CENTER
            })
            :align(display.LEFT_CENTER, contentPadding, contentHeight/2)
            :addTo(nickNameContent)

        local nickNameTitleSize = nickNameTitle:getContentSize()

        --昵称名字
        local nickNamePadding = 20
        local nickName = ui.newTTFLabel({
                text = nk.userData.nick, 
                size = labelContentSize, 
                color = labelTitleColor, 
                align = ui.TEXT_ALIGN_CENTER
            })
            :align(display.LEFT_CENTER, contentPadding + nickNameTitleSize.width + nickNamePadding, contentHeight/2)
            :addTo(nickNameContent)

        -- guest模式下显示 facebook引导
        local lastLoginType = nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE)
        if lastLoginType == "GUEST" then
            local px = contentPadding + nickNameTitleSize.width + nickNamePadding + nickName:getContentSize().width + 20

            ui.newTTFLabel({
                text = bm.LangUtil.getText("SETTING", "PLEASE_USE_FACEBOOK"),
                size = labelContentSize - 4.5,
                color = labelContentColor,
                align = ui.TEXT_ALIGN_LEFT,
            })
            :align(display.LEFT_CENTER, px, contentHeight/2)
            :addTo(nickNameContent)
        end

        --登出按钮
        if not self.mainView_.isInRoom then
            cc.ui.UIPushButton.new({normal = "#common_btn_yellow_normal.png", pressed = "#common_btn_yellow_pressed.png"}, {scale9 = true})
                :setButtonSize(165, 55)
                :setButtonLabel(ui.newTTFLabel({
                    text = bm.LangUtil.getText("SETTING", "LOGOUT"), 
                    size = labelTitleSize, 
                    color = cc.c3b(0xc7, 0xe5, 0xff), 
                    align = ui.TEXT_ALIGN_LEFT}))
                :addTo(nickNameContent)
                :pos(contentWidth - 91, contentHeight/2)
                :onButtonClicked(buttontHandler(self, self.logOut_))
        end
end

--添加声音设置
function SettingView:addSoundNode_(topOriginY)
    local container = self.container_

    --声音和震动
    local soundVibrateContent = display.newScale9Sprite(
        "#panel_overlay.png", 
        contentWidth/2, topOriginY - contentHeight,
        cc.size(contentWidth, contentHeight * 4))
        :addTo(container)

    --分割线
    display.newScale9Sprite(
        "#pop_up_split_line.png",
        contentWidth/2, contentHeight,
        cc.size(dividerWidth, dividerHeight))
        :addTo(soundVibrateContent)
    display.newScale9Sprite(
        "#pop_up_split_line.png",
        contentWidth/2, contentHeight*2,
        cc.size(dividerWidth, dividerHeight))
        :addTo(soundVibrateContent)
    display.newScale9Sprite(
        "#pop_up_split_line.png",
        contentWidth/2, contentHeight*3,
        cc.size(dividerWidth, dividerHeight))
        :addTo(soundVibrateContent)

    --声音
    local sound = ui.newTTFLabel({
            text = bm.LangUtil.getText("SETTING", "SOUND"),
            size = labelContentSize,
            color = labelContentColor,
            align = ui.TEXT_ALIGN_CENTER
        })
        :align(display.LEFT_CENTER, contentPadding, contentHeight + contentHeight/2+contentHeight * 2)
        :addTo(soundVibrateContent)

    --声音调节
    local soundPosX = 170

    display.newScale9Sprite("#pop_common_progress_bg.png")
        :align(display.LEFT_CENTER, soundPosX, contentHeight * 3/2+contentHeight  * 2)
        :size(soundProgressWidth - 4, soundProgressHeight)
        :addTo(soundVibrateContent)

    self.soundProgressFg = display.newScale9Sprite("#pop_common_progress_img.png")
        :align(display.LEFT_CENTER, soundPosX + 3, contentHeight * 3/2+contentHeight  * 2)
        :size(0, soundProgressFillHeight)
        :addTo(soundVibrateContent)
        :hide()

    local soundSlider = cc.ui.UISlider.new(display.LEFT_TO_RIGHT, {bar = "#transparent.png", button = "#setting_seekbar_thumb.png"}, {scale9 = true})
        :setSliderSize(soundProgressWidth + 40, soundProgressHeight)
        :align(display.LEFT_CENTER, soundPosX - 30, contentHeight * 3/2+contentHeight  * 2)
        :onSliderValueChanged(handler(self, self.soundValueChangeListener))
        :onSliderRelease(handler(self, self.soundValueUpdate_))
        :addTo(soundVibrateContent)
        
        local volume = cc.UserDefault:getInstance():getIntegerForKey(nk.cookieKeys.VOLUME, 100)
        soundSlider:setSliderValue(volume)

    local xPosPadding = sound:getPositionX() + sound:getContentSize().width + 30

    --静音按钮
    local soundMinIcon = cc.ui.UIPushButton.new("#setting_sound_min_btn.png")
        :pos(xPosPadding, contentHeight * 3/2+contentHeight  * 2)
        :onButtonPressed(function(evt)
            evt.target:setColor(cc.c3b(0x0, 0xff, 0xff))
        end)
        :onButtonRelease(function(evt)
            evt.target:setColor(cc.c3b(0xff, 0xff, 0xff))
        end)
        :onButtonClicked(function(evt)
            soundSlider:setSliderValue(0)
            self:soundValueUpdate_()
        end)
        :addTo(soundVibrateContent)

    --最大音量按钮
    local soundMaxIcon = cc.ui.UIPushButton.new("#setting_sound_max_btn.png")
        :pos(contentWidth - 60, contentHeight * 3/2+contentHeight  * 2)
        :onButtonPressed(function(evt)
            evt.target:setColor(cc.c3b(0x0, 0xff, 0xff))
        end)
        :onButtonRelease(function(evt)
            evt.target:setColor(cc.c3b(0xff, 0xff, 0xff))
        end)
        :onButtonClicked(function ()
            soundSlider:setSliderValue(100)
            self:soundValueUpdate_()
        end)
        :addTo(soundVibrateContent)


    -- 背景音效
    local bgSound = ui.newTTFLabel({
        text = bm.LangUtil.getText("SETTING", "BG_SOUND"),
        size = labelContentSize,
        color = labelContentColor,
        align = ui.TEXT_ALIGN_CENTER
        })
        bgSound:addTo(soundVibrateContent)
        bgSound:setAnchorPoint(cc.p(0, 0.5))
        bgSound:pos(contentPadding, contentHeight/2+contentHeight *2)
    local isBgSound = cc.UserDefault:getInstance():getBoolForKey(nk.cookieKeys.BG_SOUND, true)
    self.isBgSound_ = isBgSound
    self.isBgSound1_ = isBgSound
    self.bgSoundSwitch = cc.ui.UICheckBoxButton.new({
            on = "#setting_checkbox_on.png",
            off = "#setting_checkbox_off.png"
        })
        :onButtonStateChanged(handler(self, self.bgSoundChangeListener))
        :align(display.LEFT_CENTER, contentWidth - switchPadding, contentHeight/2+contentHeight *2)
        :addTo(soundVibrateContent)
        :setButtonSelected(isBgSound)

    -- 聊天音效
    local chatSound = ui.newTTFLabel({
        text = bm.LangUtil.getText("SETTING", "CHATVOICE"),
        size = labelContentSize,
        color = labelContentColor,
        align = ui.TEXT_ALIGN_CENTER
        })
        chatSound:addTo(soundVibrateContent)
        chatSound:setAnchorPoint(cc.p(0, 0.5))
        chatSound:pos(contentPadding, contentHeight/2+contentHeight)
    local isChatVoice = cc.UserDefault:getInstance():getBoolForKey(nk.cookieKeys.CHATVOICE, true)
    self.isChatVoice_ = isChatVoice
    self.isChatVoice1_ = isChatVoice
    self.chatVoiceSwitch = cc.ui.UICheckBoxButton.new({
            on = "#setting_checkbox_on.png",
            off = "#setting_checkbox_off.png"
        })
        :onButtonStateChanged(handler(self, self.chatVoiceChangeListener))
        :align(display.LEFT_CENTER, contentWidth - switchPadding, contentHeight/2+contentHeight)
        :addTo(soundVibrateContent)
        :setButtonSelected(isChatVoice)
    --震动
    local vibrate = ui.newTTFLabel({
        text = bm.LangUtil.getText("SETTING", "VIBRATE"),
        size = labelContentSize,
        color = labelContentColor,
        align = ui.TEXT_ALIGN_CENTER
        })
        vibrate:addTo(soundVibrateContent)
        vibrate:setAnchorPoint(cc.p(0, 0.5))
        vibrate:pos(contentPadding, contentHeight/2)

    local isShock = cc.UserDefault:getInstance():getBoolForKey(nk.cookieKeys.SHOCK, false)

    self.vibrateSwitch = cc.ui.UICheckBoxButton.new({
            on = "#setting_checkbox_on.png",
            off = "#setting_checkbox_off.png"
        })
        :onButtonStateChanged(handler(self, self.vibrateChangeListener))
        :align(display.LEFT_CENTER, contentWidth - switchPadding, contentHeight/2)
        :addTo(soundVibrateContent)
        :setButtonSelected(isShock)
end

--自动坐下以及自动买入
function SettingView:addAutoBtn_(topOriginY)
    local container = self.container_
    local autoOptItemCount = 3
    local autoOptHeight = autoOptItemCount * contentHeight
    local autoOptContent = display.newScale9Sprite("#panel_overlay.png", 
            contentWidth/2, topOriginY - autoOptHeight/2, cc.size(contentWidth, autoOptHeight))
        autoOptContent:addTo(container)

    --分割线
    display.newScale9Sprite("#pop_up_split_line.png", contentWidth/2, (autoOptItemCount-1) * contentHeight)
        :addTo(autoOptContent)
        :size(dividerWidth, dividerHeight)

    --分割线
    display.newScale9Sprite("#pop_up_split_line.png", contentWidth/2, (autoOptItemCount-2) * contentHeight)
        :addTo(autoOptContent)
        :size(dividerWidth, dividerHeight)

    --自动坐下
    local autoSit = ui.newTTFLabel({
        text = bm.LangUtil.getText("SETTING", "AUTO_SIT"),
        size = labelContentSize,
        color = labelContentColor,
        align = ui.TEXT_ALIGN_CENTER
        })
        autoSit:addTo(autoOptContent)
        autoSit:setAnchorPoint(cc.p(0, 0.5))
        autoSit:pos(contentPadding, contentHeight * (autoOptItemCount-1) + contentHeight/2)

    local isAutoSit = cc.UserDefault:getInstance():getBoolForKey(nk.cookieKeys.AUTO_SIT, true)

    self.autoSitSwitch = cc.ui.UICheckBoxButton.new({
            on = "#setting_checkbox_on.png",
            off = "#setting_checkbox_off.png"
        })
        :onButtonStateChanged(handler(self, self.autoSitChangeListener))
        :align(display.LEFT_CENTER, contentWidth - switchPadding, contentHeight * (autoOptItemCount-1) + contentHeight/2)
        :addTo(autoOptContent)
        :setButtonSelected(isAutoSit)

    --自动买入
    local autoBuyin = ui.newTTFLabel({
        text = bm.LangUtil.getText("SETTING", "AUTO_BUYIN"),
        size = labelContentSize,
        color = labelContentColor,
        align = ui.TEXT_ALIGN_CENTER
        })
        autoBuyin:addTo(autoOptContent)
        autoBuyin:setAnchorPoint(cc.p(0, 0.5))
        autoBuyin:pos(contentPadding, contentHeight * (autoOptItemCount-2) + contentHeight/2)

    local isBuyin = cc.UserDefault:getInstance():getBoolForKey(nk.cookieKeys.AUTO_BUY_IN, true)

    self.autobuySwitch = cc.ui.UICheckBoxButton.new({
            on = "#setting_checkbox_on.png",
            off = "#setting_checkbox_off.png"
        })
        :onButtonStateChanged(handler(self, self.autoBuyinChangeListener))
        :align(display.LEFT_CENTER, contentWidth - switchPadding, contentHeight * (autoOptItemCount-2) + contentHeight/2)
        :addTo(autoOptContent)
        :setButtonSelected(isBuyin)


    --仅允许好友追踪
    local followFriend = ui.newTTFLabel({
        text = "เพื่อนเท่านั้นที่ตามได้",
        size = labelContentSize,
        color = labelContentColor,
        align = ui.TEXT_ALIGN_CENTER
        })
        followFriend:addTo(autoOptContent)
        followFriend:setAnchorPoint(cc.p(0, 0.5))
        followFriend:pos(contentPadding, contentHeight * (autoOptItemCount-3) + contentHeight/2)

    local isFollowFriend = (nk.userData.isfollowfriend == 1)

    self.autobuySwitch = cc.ui.UICheckBoxButton.new({
            on = "#setting_checkbox_on.png",
            off = "#setting_checkbox_off.png"
        })
        :onButtonStateChanged(handler(self, self.followFriendChangeListener))
        :align(display.LEFT_CENTER, contentWidth - switchPadding, contentHeight * (autoOptItemCount-3) + contentHeight/2)
        :addTo(autoOptContent)
        :setButtonSelected(isFollowFriend)
end

--其他内容
function SettingView:addOtherContent_(heightSum, topOriginY)
    local container = self.container_
    local otherItemCount = 4
    local otherHeight = otherItemCount * contentHeight
    local otherContent = display.newScale9Sprite("#panel_overlay.png", contentWidth/2, topOriginY - otherHeight/2, cc.size(contentWidth, otherHeight))
        otherContent:addTo(container)    

    --分割线
    display.newScale9Sprite("#pop_up_split_line.png", contentWidth/2, (otherItemCount-1) * contentHeight)
        :addTo(otherContent)
        :size(dividerWidth, dividerHeight)

    display.newScale9Sprite("#pop_up_split_line.png", contentWidth/2, (otherItemCount-2) * contentHeight)
        :addTo(otherContent)
        :size(dividerWidth, dividerHeight)    

    display.newScale9Sprite("#pop_up_split_line.png", contentWidth/2, (otherItemCount-3) * contentHeight)
        :addTo(otherContent)
        :size(dividerWidth, dividerHeight)

    --到应用商城去评分
    local appStoreGradeBtn = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#setting_content_up_pressed.png"}, {scale9 = true})
        :setButtonSize(contentWidth, contentHeight)
        :addTo(otherContent)
        :pos(0, contentHeight * (otherItemCount-1) + contentHeight/2)
        appStoreGradeBtn:setTouchSwallowEnabled(false)
        appStoreGradeBtn:setAnchorPoint(cc.p(0, 0.5))

    --评分文字
    local appStoreLabel = ui.newTTFLabel({
        text = bm.LangUtil.getText("SETTING", "APP_STORE_GRADE"),
        size = labelContentSize,
        color = labelContentColor,
        align = ui.TEXT_ALIGN_CENTER
        })
        appStoreLabel:addTo(otherContent)
        appStoreLabel:setAnchorPoint(cc.p(0, 0.5))
        appStoreLabel:pos(contentPadding, contentHeight * (otherItemCount-1) + contentHeight/2)

    local arrowPadding = 45
    --评分箭头
    local appStoreArrow = display.newSprite("#setting_arrow_right.png")
        appStoreArrow:addTo(otherContent)
        appStoreArrow:pos(contentWidth - arrowPadding, contentHeight * (otherItemCount-1) + contentHeight/2)
        appStoreArrow:setAnchorPoint(cc.p(0, 0.5))

    local appStoreArrowPress = display.newSprite("#setting_arrow_right_pressed.png"):addTo(appStoreArrow):align(display.LEFT_BOTTOM, 0, 0):hide()
    self:buttonTouchHandler(appStoreGradeBtn, buttontHandler(self, self.appStoreOnClick), appStoreArrowPress)

    --检测更新
    local checkVersionBtn = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#setting_content_middle_pressed.png"}, {scale9 = true})
        :setButtonSize(contentWidth, contentHeight)
        :addTo(otherContent)
        :pos(0, contentHeight * (otherItemCount-2) + contentHeight/2)
        checkVersionBtn:setTouchSwallowEnabled(false)
        checkVersionBtn:setAnchorPoint(cc.p(0, 0.5))

    --更新文字
    local checkVersionLabel = ui.newTTFLabel({
        text = bm.LangUtil.getText("SETTING", "CHECK_VERSION"),
        size = labelContentSize,
        color = labelContentColor,
        align = ui.TEXT_ALIGN_CENTER
        })
        checkVersionLabel:addTo(otherContent)
        checkVersionLabel:setAnchorPoint(cc.p(0, 0.5))
        checkVersionLabel:pos(contentPadding, contentHeight * (otherItemCount-2) + contentHeight/2)

    --更新箭头
    local checkVersionArrow = display.newSprite("#setting_arrow_right.png")
        checkVersionArrow:addTo(otherContent)
        checkVersionArrow:pos(contentWidth - arrowPadding, contentHeight * (otherItemCount-2) + contentHeight/2)
        checkVersionArrow:setAnchorPoint(cc.p(0, 0.5))

    local checkVersionArrowPress = display.newSprite("#setting_arrow_right_pressed.png"):addTo(checkVersionArrow):align(display.LEFT_BOTTOM, 0, 0):hide()
    self:buttonTouchHandler(checkVersionBtn, buttontHandler(self, self.checkVersionOnClick), checkVersionArrowPress)

    --当前版本号
    local currentVersionPadding = 15
    local currentVersion = nk.Native:getAppVersion()
    local currentVersionLabel = ui.newTTFLabel({
        text = bm.LangUtil.getText("SETTING", "CURRENT_VERSION", BM_UPDATE and BM_UPDATE.VERSION or currentVersion),
        size = labelContentSize,
        color = labelContentColor,
        align = ui.TEXT_ALIGN_CENTER
        })
        currentVersionLabel:addTo(otherContent)
        currentVersionLabel:setAnchorPoint(cc.p(0, 0.5))
        currentVersionPadding = currentVersionPadding + currentVersionLabel:getContentSize().width + arrowPadding
        currentVersionLabel:pos(contentWidth - currentVersionPadding, contentHeight * (otherItemCount-2) + contentHeight/2)    

    --官方粉丝页
    local fansBtn = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#setting_content_middle_pressed.png"}, {scale9 = true})
        :setButtonSize(contentWidth, contentHeight)
        :addTo(otherContent)
        :pos(0, contentHeight * (otherItemCount-3) + contentHeight/2)
        fansBtn:setTouchSwallowEnabled(false)
        fansBtn:setAnchorPoint(cc.p(0, 0.5))

    --官方粉丝页文字
    local fansLabel = ui.newTTFLabel({
        text = bm.LangUtil.getText("SETTING", "FANS"),
        size = labelContentSize,
        color = labelContentColor,
        align = ui.TEXT_ALIGN_CENTER
        })
        fansLabel:addTo(otherContent)
        fansLabel:setAnchorPoint(cc.p(0, 0.5))
        fansLabel:pos(contentPadding, contentHeight * (otherItemCount-3) + contentHeight/2)

    --官方粉丝页箭头
    local fansArrow = display.newSprite("#setting_arrow_right.png")
        fansArrow:addTo(otherContent)
        fansArrow:pos(contentWidth - arrowPadding, contentHeight * (otherItemCount-3) + contentHeight/2)
        fansArrow:setAnchorPoint(cc.p(0, 0.5))    

    local fansArrowPress = display.newSprite("#setting_arrow_right_pressed.png"):addTo(fansArrow):align(display.LEFT_BOTTOM, 0, 0):hide()
    self:buttonTouchHandler(fansBtn, buttontHandler(self, self.fansOnClick), fansArrowPress)

    --关于
    local aboutBtn = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#setting_content_down_pressed.png"}, {scale9 = true})
        :setButtonSize(contentWidth, contentHeight)
        :addTo(otherContent)
        :pos(0, contentHeight * (otherItemCount-4) + contentHeight/2)
        aboutBtn:setTouchSwallowEnabled(false)
        aboutBtn:setAnchorPoint(cc.p(0, 0.5))

    --关于文字
    local aboutLabel = ui.newTTFLabel({
        text = bm.LangUtil.getText("SETTING", "ABOUT"),
        size = labelContentSize,
        color = labelContentColor,
        align = ui.TEXT_ALIGN_CENTER
        })
        aboutLabel:addTo(otherContent)
        aboutLabel:setAnchorPoint(cc.p(0, 0.5))
        aboutLabel:pos(contentPadding, contentHeight * (otherItemCount-4) + contentHeight/2)

    --关于箭头
    local aboutArrow = display.newSprite("#setting_arrow_right.png")
        aboutArrow:addTo(otherContent)
        aboutArrow:pos(contentWidth - arrowPadding, contentHeight * (otherItemCount-4) + contentHeight/2)
        aboutArrow:setAnchorPoint(cc.p(0, 0.5))    

    local aboutArrowPress = display.newSprite("#setting_arrow_right_pressed.png"):addTo(aboutArrow):align(display.LEFT_BOTTOM, 0, 0):hide()
    self:buttonTouchHandler(aboutBtn, buttontHandler(self, self.aboutOnClick), aboutArrowPress)

    heightSum = heightSum  + contentHeight * otherItemCount + 35

    container:pos(-contentWidth/2, heightSum/2 - contentHeight * otherItemCount/2 - 35)
end

function SettingView:buttonTouchHandler(button, clickCallback, arrowIcon)
    button:onButtonPressed(function(evt)
        self.btnPressedY_ = evt.y
        self.btnClickCanceled_ = false
        arrowIcon:show()
    end)
    button:onButtonRelease(function(evt)
        if math.abs(evt.y - self.btnPressedY_) > 10 then
            self.btnClickCanceled_ = true
        end
        arrowIcon:hide()
    end)
    button:onButtonClicked(function(evt)
        if not self.btnClickCanceled_ and self:getParent():getParent():getCascadeBoundingBox():containsPoint(cc.p(evt.x, evt.y)) then
            clickCallback()
        end
    end)    
end

function SettingView:logOut_()
    self.mainView_:onClose()
    -- 派发登出成功事件
    bm.EventCenter:dispatchEvent(nk.eventNames.HALL_LOGOUT_SUCC)
end

function SettingView:vibrateChangeListener(event)
    if self.canSound then
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    end
    
    if event.target:isButtonSelected() then
        self.isVibrate_ = true
        if self.canSound then
            nk.Native:vibrate(500)
        end
    else
        self.isVibrate_ = false
    end
end    

function SettingView:bgSoundChangeListener(event)
    if self.canSound then
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    end
    
    if event.target:isButtonSelected() then
        self.isBgSound1_ = true
    else
        self.isBgSound1_ = false
    end
    if nk.userData.inHall_ then
        cc.UserDefault:getInstance():setBoolForKey(nk.cookieKeys.BG_SOUND, self.isBgSound1_)
        cc.UserDefault:getInstance():flush()
        if self.isBgSound1_ then
            nk.SoundManager:playBgMusic()
        else
            nk.SoundManager:stopBgMusic()
        end
    end
end

function SettingView:chatVoiceChangeListener(event)
    if self.canSound then
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    end
    
    if event.target:isButtonSelected() then
        self.isChatVoice1_ = true
    else
        self.isChatVoice1_ = false
    end
end

function SettingView:autoSitChangeListener(event)
    if self.canSound then
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    end
    
    if event.target:isButtonSelected() then
        self.isAutoSit_ = true
    else
        self.isAutoSit_ = false
    end
end

function SettingView:autoBuyinChangeListener(event)
    if self.canSound then
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    end
    if event.target:isButtonSelected() then
        self.isAutoBuyin_ = true
    else
        self.isAutoBuyin_ = false
    end
end

function SettingView:followFriendChangeListener(event)
    if self.canSound then
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    end
    if event.target:isButtonSelected() then
        self.isFollowFriend_ = true
    else
        self.isFollowFriend_ = false
    end
end

function SettingView:soundValueChangeListener(event)
    if event.value == 0 then
        self.soundProgressFg:hide()
    else
        self.soundProgressFg:show()
        self.soundProgressFg:size((soundProgressWidth - 8) * event.value/100, soundProgressFillHeight)
    end

    self.soundValue = event.value

    self.prevValue_ = self.curValue_
    self.curValue_ = self.soundValue
    local curTime = bm.getTime()
    local prevTime = self.lastRaiseSliderGearTickPlayTime_ or 0
    if self.prevValue_ ~= self.curValue_  and curTime - prevTime > 0.05 then
        self.lastRaiseSliderGearTickPlayTime_ = curTime
        if self.canSound then
            nk.SoundManager:playSound(nk.SoundManager.GEAR_TICK)
        end
    end
end

function SettingView:soundValueUpdate_()
    if self.soundValue then
        cc.UserDefault:getInstance():setIntegerForKey(nk.cookieKeys.VOLUME, self.soundValue)
        cc.UserDefault:getInstance():flush()
        nk.SoundManager:updateVolume()
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    end
end

function SettingView:appStoreOnClick()
    device.openURL(nk.userData.commentUrl)
end

function SettingView:checkVersionOnClick()
    bm.HttpService.POST_URL(appconfig.VERSION_CHECK_URL, 
        {
            device = (device.platform == "windows" and nk.TestUtil.simuDevice or device.platform), 
            pay = (device.platform == "windows" and nk.TestUtil.simuDevice or device.platform), 
            osVersion = BM_UPDATE.VERSION, 
            version = BM_UPDATE.VERSION, 
            noticeVersion = "noticeVersion"
        }, 
        function (data)
            if data then
                local retData = json.decode(data)
                self:checkUpdate(retData.curVersion, retData.verTitle, retData.verMessage, retData.updateUrl)
            end
        end
    )
end

function SettingView:checkUpdate(curVersion, verTitle, verMessage, updateUrl)
    local latestVersionNum = bm.getVersionNum(curVersion)
    local installVersionNum = bm.getVersionNum(BM_UPDATE.VERSION)

    if latestVersionNum <= installVersionNum then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("UPDATE", "HAD_UPDATED"))
    else
        UpdatePopup.new(verTitle, verMessage, updateUrl):show()
    end
end

function SettingView:aboutOnClick()
    AboutPopup.new():show()
end

function SettingView:fansOnClick()
    device.openURL(bm.LangUtil.getText("ABOUT", "FANS_OPEN"))
end

function SettingView:onShowed()
    self.scrollView_:setScrollContentTouchRect()
    self.canSound = true
end

return SettingView
