--
-- Author: Jonah0608@gmail.com
-- Date: 2016-12-02 16:21:21
--
local CardHelpPopup = import(".CardHelpPopup")
local CardActListItem = import(".CardActListItem")
local CardActPopupNew = class("CardActPopupNew",function()
    return display.newNode()
end)

local POP_WIDTH = 880
local POP_HEIGHT = 562

function CardActPopupNew:ctor()
    self:setNodeEventEnabled(true)
    self:setupView()
end

function CardActPopupNew:setupView()
    self.background_ = display.newSprite("#card_activity_new_bg.png"):addTo(self)
    self.background_:setTouchEnabled(true)
    self.background_:setTouchSwallowEnabled(true)
    self.titlebg_ = display.newSprite("#card_activity_new_title_bg.png")
        :pos(0,245)
        :addTo(self)
    self.title_ = display.newSprite("#card_activity_new_title.png")
        :pos(0,245)
        :addTo(self)

    self.closeBtn_ = cc.ui.UIPushButton.new({normal = "#card_activity_close.png", pressed = "#card_activity_close.png"})
        :onButtonClicked(handler(self,self.onCloseBtnListener_))
        :pos(390,235)
        :addTo(self)

    self.helpBtn_ = cc.ui.UIPushButton.new({normal = "#card_activity_help.png", pressed = "#card_activity_help.png"})
        :onButtonClicked(handler(self,self.onHelpBtnListener_))
        :pos(-390,235)
        :addTo(self)

    self.activityTime_ = ui.newTTFLabel({text = "", color = cc.c3b(0xff, 0xff, 0xff), size = 16, align = ui.TEXT_ALIGN_LEFT})
        :align(display.CENTER_LEFT)
        :pos(-385,180)
        :addTo(self)

    -- 昵称标签
    self.codeEdit_ = ui.newEditBox({listener = handler(self, self.onCodeEdit_), size = cc.size(600, 50),
            image = "#card_activity_input_bg.png",
            imagePressed="#card_activity_input_bg.png"})
        :align(display.CENTER_LEFT)
        :pos(-385,140)
        :addTo(self)
    self.codeEdit_:setFont(ui.DEFAULT_TTF_FONT, 26)
    self.codeEdit_:setFontColor(cc.c3b(0x00, 0x00, 0x00))
    self.codeEdit_:setPlaceholderFont(ui.DEFAULT_TTF_FONT, 26)
    self.codeEdit_:setMaxLength(10)
    self.codeEdit_:setAnchorPoint(cc.p(0, 0.5))
    self.codeEdit_:setPlaceholderFontColor(cc.c3b(0xec, 0x9c, 0x9d))
    self.codeEdit_:setPlaceHolder(bm.LangUtil.getText("CARD_ACT", "INPUT_CODE"))
    self.codeEdit_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.codeEdit_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)

    nk.EditBoxManager:addEditBox(self.codeEdit_)

    self.enterCodeBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_yellow_normal.png", pressed = "#common_btn_yellow_pressed.png"}, {scale9 = true})
        :setButtonLabel(ui.newTTFLabel({text=bm.LangUtil.getText("CARD_ACT","ENTER_CODE"), size=20, color=styles.FONT_COLOR.LIGHT_TEXT, align=ui.TEXT_ALIGN_CENTER}))
        :setButtonSize(145, 50)
        :pos(305,140)
        :onButtonClicked(handler(self,self.bindActCode))
        :addTo(self)


    self.progressBg_ = display.newNode():pos(0,-20):addTo(self)
    display.newScale9Sprite("#card_activity_bg_1.png", 0, 0, cc.size(767, 255))
        :pos(0,0)
        :addTo(self.progressBg_)

    self:buildProgressLogin():addTo(self.progressBg_):pos(0,70)
    self:buildProgressInvite():addTo(self.progressBg_):pos(0,-30)
    self:buildProgressRecall():addTo(self.progressBg_):pos(0,-100)


    self.rewardDesc_ = ui.newTTFLabel({text = bm.LangUtil.getText("CARD_ACT","REWARD_DESC_NEW"), color = cc.c3b(0xff, 0xe9, 0x2a), size = 22, align = ui.TEXT_ALIGN_LEFT})
        :align(display.CENTER_LEFT)
        :pos(-385,-170)
        :addTo(self)

    self.rewardPayDesc_ = ui.newTTFLabel({text = "", color = cc.c3b(0xff, 0xff, 0xff), size = 18, align = ui.TEXT_ALIGN_LEFT})
        :align(display.CENTER_LEFT)
        :pos(-385,-205)
        :addTo(self)
end

function CardActPopupNew:onCodeEdit_(event)
     if event == "began" then
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
        self.codeEdit_:setText(self.editCode_ or "")
    elseif event == "changed" then
        local text = self.codeEdit_:getText()
        self.editCode_ = text
    elseif event == "ended" then
        local text = self.codeEdit_:getText()
        self.editCode_ = text
    elseif event == "return" then
        local text = self.codeEdit_:getText()
        self.editCode_ = text
    end
end

function CardActPopupNew:onHelpBtnListener_()
    CardHelpPopup.new(true):show()
end

function CardActPopupNew:onCloseBtnListener_()
    self:hide()
end

function CardActPopupNew:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
                :addTo(self, 999)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

function CardActPopupNew:getData()
    self:setLoading(true)
    bm.HttpService.POST(
        { mod = "Invite",
          act = "returnPlayer"
        },function(data)
            self:setLoading(false)
            local jsnData = json.decode(data)
            if jsnData and jsnData.code == 1 then
                self:updateData(jsnData)
            end
        end,function()
            self:setLoading(false)
        end)
end

function CardActPopupNew:updateData(data)
    self.data_ = data
    self.activityTime_:setString(bm.LangUtil.getText("CARD_ACT","ACT_TIME",data.openDate))
    self.rewardPayDesc_:setString(data.mainActThai.notice)
    self.tipsLogin_:setString(data.mainActThai.loginThai)
    self.tipsInvite_:setString(data.mainActThai.inviteThai)
    self.tipsRecall_:setString(data.mainActThai.recallThai)
    if data.inviteStatus.num > data.inviteStatus.total then
        data.inviteStatus.num = data.inviteStatus.total
    end
    self.progressInviteLabel:setString(data.inviteStatus.num .. "/ ".. data.inviteStatus.total)
    self.progressInvite_:setValue(data.inviteStatus.num / data.inviteStatus.total)
    if data.recallStatus.num > data.recallStatus.total then
        data.recallStatus.num = data.recallStatus.total
    end
    self.progressRecallLabel:setString(data.recallStatus.num .. "/ ".. data.recallStatus.total)
    self.progressRecall_:setValue(data.recallStatus.num / data.recallStatus.total)
    if data.inviteStatus.canreward == 1 then
        self:updateCanReward("invite",true)
    else
        self:updateCanReward("invite",false)
    end
    if data.recallStatus.canreward == 1 then
        self:updateCanReward("recall",true)
    else
        self:updateCanReward("recall",false)
    end
    local dailyLogin = data.dailyLogin

    self:updateStar(dailyLogin)
end

function CardActPopupNew:updateStar(data)
    self.tipspaopaolabel_[1]:setString(data[1].title)
    self.tipspaopaolabel_[2]:setString(data[2].title)
    for i = 1,3 do
        self.tipsProgress_[i]:setString(tostring(i))
        if data[4].finish >= i then
            self.tipsSprite_[i]:setSpriteFrame(display.newSpriteFrame("card_activity_star_reward.png"))
            self.tipsProgress_[i]:setTextColor(cc.c3b(0xff, 0x76, 0x12))
            if data[i].canreward == 0 then
                self:updateSprite(self.tipspaopao_[i],"rewarded")
            else
                self:updateSprite(self.tipspaopao_[i],"canreward")
            end
        else
            self:updateSprite(self.tipspaopao_[i],"notreward")
        end
    end
    if data[4].finish >= 3 then
        data[4].finish = 3
    end
    self.progressLogin_:setValue(data[4].finish / 3)
    self.progressLoginLabel:setString(tostring(data[4].finish) .. "/3")
    if data[4].canreward == 1 then
        self:updateCanReward("login",true)
    else
        self:updateCanReward("login",false)
    end
end

function CardActPopupNew:updateSprite(sprite,status)
    if status == "canreward" then
        sprite:setSpriteFrame(display.newSpriteFrame("card_activity_tips_3.png"))
    elseif status == "rewarded" then 
        sprite:setSpriteFrame(display.newSpriteFrame("card_activity_tips_2.png"))
    elseif status == "notreward" then
        sprite:setSpriteFrame(display.newSpriteFrame("card_activity_tips_1.png"))
    end
end

function CardActPopupNew:buildProgressLogin()
    local node = display.newNode()
    self.tipsLogin_ = ui.newTTFLabel({text = "", color = cc.c3b(0xff, 0xff, 0xff), size = 20, align = ui.TEXT_ALIGN_LEFT})
        :align(display.CENTER_LEFT)
        :pos(-337,30)
        :addTo(node)

    local progressWidth = 495
    local progressHeight = 24
    self.progressLogin_ = nk.ui.ProgressBar.new(
        "#card_activity_progress_bg.png", 
        "#card_activity_progress_front.png", 
        {
            bgWidth = progressWidth, 
            bgHeight = 26, 
            fillWidth = 34, 
            fillHeight = progressHeight
        }
    ):pos(-338,0)
    :addTo(node):setValue(0.0)

    self.progressLoginLabel = ui.newTTFLabel({
            text = "",
            size = 18,
            color = cc.c3b(0xfF, 0xfF, 0xfF),
            align = ui.TEXT_ALIGN_CENTER
        }):addTo(self.progressLogin_):pos(progressWidth/2, 0) 

    self.rewardBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_yellow_normal.png", pressed = "#common_btn_yellow_pressed.png",disabled="#common_btn_disabled.png"}, {scale9 = true})
        :setButtonLabel(ui.newTTFLabel({text=bm.LangUtil.getText("CARD_ACT","GET_REWARD"), size=20, color=styles.FONT_COLOR.LIGHT_TEXT, align=ui.TEXT_ALIGN_CENTER}))
        :setButtonSize(145, 50)
        :onButtonClicked(function(evt)
            self:getLoginReward()
        end)
        :pos(255,0)
        :addTo(node)
    self.rewardBtn_:setButtonEnabled(false)
    self.tipspaopao_ = {}
    self.tipspaopaolabel_ = {}
    self.tipsSprite_ = {}
    self.tipsProgress_ = {}
    for i = 1,3 do
        self.tipspaopao_[i] = display.newSprite("#card_activity_tips_1.png")
            :pos(165 * i -  330,-30)
            :addTo(node)

        local size = self.tipspaopao_[i]:getContentSize()
        self.tipspaopaolabel_[i] =  ui.newTTFLabel({
            text = "",
            size = 18,
            color = cc.c3b(0xff, 0xff, 0xff),
            align = ui.TEXT_ALIGN_CENTER
        }):addTo(self.tipspaopao_[i]):pos(size.width/2, size.height / 2 - 3) 

        self.tipsSprite_[i] = display.newSprite("#card_activity_star_progress.png")
            :pos(165 * i -  340,0)
            :addTo(node)

        self.tipsProgress_[i] =  ui.newTTFLabel({
            text = "",
            size = 24,
            color = cc.c3b(0x86,0x54,0x56),
            align = ui.TEXT_ALIGN_CENTER
        }):addTo(self.tipsSprite_[i]):pos(22,22)
        
    end
    self.tipspaopao_[3]:hide()
    return node
end

function CardActPopupNew:buildProgressInvite()
    local node = display.newNode()
    self.tipsInvite_ = ui.newTTFLabel({text = "", color = cc.c3b(0xff, 0xff, 0xff), size = 20, align = ui.TEXT_ALIGN_LEFT})
        :align(display.CENTER_LEFT)
        :pos(-337,30)
        :addTo(node)

    local progressWidth = 495
    local progressHeight = 24
    self.progressInvite_ = nk.ui.ProgressBar.new(
        "#card_activity_progress_bg.png", 
        "#card_activity_progress_front.png", 
        {
            bgWidth = progressWidth, 
            bgHeight = 26, 
            fillWidth = 34, 
            fillHeight = progressHeight
        }
    ):pos(-338,0)
    :addTo(node):setValue(0.0)

    self.progressInviteLabel = ui.newTTFLabel({
            text = "",
            size = 18,
            color = cc.c3b(0xfF, 0xfF, 0xfF),
            align = ui.TEXT_ALIGN_CENTER
        }):addTo(self.progressInvite_):pos(progressWidth/2, 0) 

    self.rewardInviteBtn_ = cc.ui.UIPushButton.new({normal = "#card_activity_new_box_close.png", pressed = "#card_activity_new_box_close.png"})
        :onButtonClicked(function(evt)
            self:getInviteRecallReward("invite")
        end)
        :pos(255,0)
        :addTo(node)
    self.rewardInviteBtn_:setButtonEnabled(false)
    return node
end

function CardActPopupNew:buildProgressRecall()
    local node = display.newNode()
    self.tipsRecall_ = ui.newTTFLabel({text = "", color = cc.c3b(0xff, 0xff, 0xff), size = 20, align = ui.TEXT_ALIGN_LEFT})
        :align(display.CENTER_LEFT)
        :pos(-337,30)
        :addTo(node)

    local progressWidth = 495
    local progressHeight = 24
    self.progressRecall_ = nk.ui.ProgressBar.new(
        "#card_activity_progress_bg.png", 
        "#card_activity_progress_front.png", 
        {
            bgWidth = progressWidth, 
            bgHeight = 26, 
            fillWidth = 34, 
            fillHeight = progressHeight
        }
    ):pos(-338,0)
    :addTo(node):setValue(0.0)

    self.progressRecallLabel = ui.newTTFLabel({
            text = "",
            size = 18,
            color = cc.c3b(0xfF, 0xfF, 0xfF),
            align = ui.TEXT_ALIGN_CENTER
        }):addTo(self.progressRecall_):pos(progressWidth/2, 0) 

    self.rewardRecallBtn_ = cc.ui.UIPushButton.new({normal = "#card_activity_new_box_close.png", pressed = "#card_activity_new_box_close.png"})
        :onButtonClicked(function(evt)
            self:getInviteRecallReward("recall")
        end)
        :pos(255,0)
        :addTo(node)
    self.rewardRecallBtn_:setButtonEnabled(false)
    return node
end

function CardActPopupNew:getLoginReward()
    bm.HttpService.POST(
        { mod = "Invite",
          act = "rpLoginReward"
        },function(data)
            local jsnData = json.decode(data)
            if jsnData and jsnData.code == 1 then
                nk.TopTipManager:showTopTip(jsnData.tips)
                self:updateStar(jsnData.dailyLogin)
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("CARD_ACT","REWARD_FAIL"))
            end
        end,function()
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("CARD_ACT","REWARD_FAIL"))
        end)
end

function CardActPopupNew:getInviteRecallReward(type_)
    bm.HttpService.POST(
        { mod = "Invite",
          act = "raffle",
          type = type_,
        },function(data)
            local jsnData = json.decode(data)
            if jsnData and jsnData.code == 1 then
                nk.TopTipManager:showTopTip(jsnData.rewardmsg)
                self:updateCanReward(type_,false)
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("CARD_ACT","REWARD_FAIL"))
            end
        end,function()
        end)
end

function CardActPopupNew:updateCanReward(type,canReward)
    if type == "login" then
        if canReward then
            self.rewardBtn_:setButtonEnabled(true)
        else
            self.rewardBtn_:setButtonEnabled(false)
        end
    elseif type == "invite" then
        if canReward then
            self.rewardInviteBtn_:setButtonImage("normal", "#card_activity_new_box_open.png")
            self.rewardInviteBtn_:setButtonImage("pressed", "#card_activity_new_box_open.png")
            self.rewardInviteBtn_:setButtonEnabled(true)
        else
            self.rewardInviteBtn_:setButtonImage("normal", "#card_activity_new_box_close.png")
            self.rewardInviteBtn_:setButtonImage("pressed", "#card_activity_new_box_close.png")
            self.rewardInviteBtn_:setButtonEnabled(false)
        end
    elseif type == "recall" then
        if canReward then
            self.rewardRecallBtn_:setButtonImage("normal", "#card_activity_new_box_open.png")
            self.rewardRecallBtn_:setButtonImage("pressed", "#card_activity_new_box_open.png")
            self.rewardRecallBtn_:setButtonEnabled(true)
        else
            self.rewardRecallBtn_:setButtonImage("normal", "#card_activity_new_box_close.png")
            self.rewardRecallBtn_:setButtonImage("pressed", "#card_activity_new_box_close.png")
            self.rewardRecallBtn_:setButtonEnabled(false)
        end
    end
end

function CardActPopupNew:bindActCode()
    if self.editCode_ then
        bm.HttpService.POST(
            { mod = "Invite",
              act = "actBinding",
              code = self.editCode_
            },function(data)
                local jsnData = json.decode(data)
                if jsnData and jsnData.ret == 0 then
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("CARD_ACT","BIND_SUCC"))
                    self:getData()
                elseif jsnData and jsnData.ret == -2 then
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("CARD_ACT","BIND_ERROR_CODE"))
                elseif jsnData and jsnData.ret == -3 then
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("CARD_ACT","BIND_ERROR_SELF"))
                elseif jsnData and jsnData.ret == -102 then
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("CARD_ACT","BIND_ERROR_BINDED"))
                elseif jsnData and jsnData.ret == -103 then
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("CARD_ACT","BIND_ERROR_MORE"))
                else
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("CARD_ACT","BIND_ERROR"))
                end
            end,function()
            end)
    else
    end
end

function CardActPopupNew:onShowed()
    self:getData()
end

function CardActPopupNew:show()
    nk.PopupManager:addPopup(self)
    return self
end

function CardActPopupNew:hide()
    nk.PopupManager:removePopup(self)
    return self
end

function CardActPopupNew:onCleanup()
    nk.EditBoxManager:removeEditBox(self.codeEdit_)
end

return CardActPopupNew