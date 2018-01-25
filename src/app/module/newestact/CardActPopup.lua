--
-- Author: Jonah0608@gmail.com
-- Date: 2016-12-02 16:21:21
--
local CardHelpPopup = import(".CardHelpPopup")
local CardActListItem = import(".CardActListItem")
local CardActPopup = class("CardActPopup",function()
    return display.newNode()
end)

local POP_WIDTH = 880
local POP_HEIGHT = 562

function CardActPopup:ctor()
    self:setNodeEventEnabled(true)
    self:setupView()
end

function CardActPopup:setupView()
    self.background_ = display.newSprite("#card_activity_bg.png"):addTo(self)
    self.background_:setTouchEnabled(true)
    self.background_:setTouchSwallowEnabled(true)
    self.title_ = display.newSprite("#card_activity_title.png")
        :pos(0,245)
        :addTo(self)

    self.closeBtn_ = cc.ui.UIPushButton.new({normal = "#card_activity_close.png", pressed = "#card_activity_close.png"})
        :onButtonClicked(handler(self,self.onCloseBtnListener_))
        :pos(390,225)
        :addTo(self)

    self.helpBtn_ = cc.ui.UIPushButton.new({normal = "#card_activity_help.png", pressed = "#card_activity_help.png"})
        :onButtonClicked(handler(self,self.onHelpBtnListener_))
        :pos(-390,225)
        :addTo(self)

    self.activityTime_ = ui.newTTFLabel({text = "", color = cc.c3b(0xc0, 0x50, 0x53), size = 24, align = ui.TEXT_ALIGN_LEFT})
        :align(display.CENTER_LEFT)
        :pos(-385,170)
        :addTo(self)

    -- 昵称标签
    -- self.codeEdit_ = ui.newEditBox({listener = handler(self, self.onCodeEdit_), size = cc.size(600, 50),
    --         image = "#card_activity_input_bg.png",
    --         imagePressed="#card_activity_input_bg.png"})
    --     :align(display.CENTER_LEFT)
    --     :pos(-385,130)
    --     :addTo(self)
    -- self.codeEdit_:setFont(ui.DEFAULT_TTF_FONT, 26)
    -- self.codeEdit_:setFontColor(cc.c3b(0x00, 0x00, 0x00))
    -- self.codeEdit_:setPlaceholderFont(ui.DEFAULT_TTF_FONT, 26)
    -- self.codeEdit_:setMaxLength(10)
    -- self.codeEdit_:setAnchorPoint(cc.p(0, 0.5))
    -- self.codeEdit_:setPlaceholderFontColor(cc.c3b(0xec, 0x9c, 0x9d))
    -- self.codeEdit_:setPlaceHolder(bm.LangUtil.getText("CARD_ACT", "INPUT_CODE"))
    -- self.codeEdit_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    -- self.codeEdit_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)

    -- nk.EditBoxManager:addEditBox(self.codeEdit_)

    -- self.enterCodeBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_yellow_normal.png", pressed = "#common_btn_yellow_pressed.png"}, {scale9 = true})
    --     :setButtonLabel(ui.newTTFLabel({text=bm.LangUtil.getText("CARD_ACT","ENTER_CODE"), size=20, color=styles.FONT_COLOR.LIGHT_TEXT, align=ui.TEXT_ALIGN_CENTER}))
    --     :setButtonSize(145, 50)
    --     :pos(305,130)
    --     :onButtonClicked(handler(self,self.bindActCode))
    --     :addTo(self)

    local posY = 40
    self.rewardCount_ = ui.newTTFLabel({text = "", color = cc.c3b(0xff, 0xe9, 0x2a), size = 24, align = ui.TEXT_ALIGN_LEFT})
        :align(display.CENTER_LEFT)
        :pos(-385,80 + posY)
        :addTo(self)

    self.progressBg_ = display.newNode():pos(0,-50 + posY):addTo(self)
    display.newScale9Sprite("#card_activity_bg_1.png", 0, 0, cc.size(767, 219))
        :pos(0,0)
        :addTo(self.progressBg_)

    self.newplayer_ = CardActListItem.new(self,"invite"):pos(0,55):addTo(self.progressBg_)
    self.recall_ = CardActListItem.new(self,"recall"):pos(0,-55):addTo(self.progressBg_)
    

    posY = 15
    self.rewardDesc_ = ui.newTTFLabel({text = bm.LangUtil.getText("CARD_ACT","REWARD_DESC"), color = cc.c3b(0xff, 0xe9, 0x2a), size = 22, align = ui.TEXT_ALIGN_LEFT})
        :align(display.CENTER_LEFT)
        :pos(-385,-190 + posY)
        :addTo(self)

    self.rewardPay_ = ui.newTTFLabel({text = bm.LangUtil.getText("CARD_ACT","PAY_REWARD"), color = cc.c3b(0xff, 0x9e, 0x9f), size = 18, align = ui.TEXT_ALIGN_LEFT})
        :align(display.CENTER_LEFT)
        :pos(-385,-215 + posY)
        :addTo(self)
    self.rewardPlay_ = ui.newTTFLabel({text = bm.LangUtil.getText("CARD_ACT","PLAY_REWARD"), color = cc.c3b(0xff, 0x9e, 0x9f), size = 18, align = ui.TEXT_ALIGN_LEFT})
        :align(display.CENTER_LEFT)
        :pos(-385,-240 + posY)
        :addTo(self)

    self.rewardPayDesc_ = ui.newTTFLabel({text = "", color = cc.c3b(0xdb, 0x5f, 0x60), size = 18, align = ui.TEXT_ALIGN_LEFT})
        :align(display.CENTER_LEFT)
        :pos(-385 + self.rewardPay_:getContentSize().width,-215 + posY)
        :addTo(self)

    self.rewardPlayDesc_ = ui.newTTFLabel({text = "", color = cc.c3b(0xdb, 0x5f, 0x60), size = 18, align = ui.TEXT_ALIGN_LEFT})
        :align(display.CENTER_LEFT)
        :pos(-385 + self.rewardPlay_:getContentSize().width,-240 + posY)
        :addTo(self)

end

function CardActPopup:onCodeEdit_(event)
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

function CardActPopup:onHelpBtnListener_()
    CardHelpPopup.new():show()
end

function CardActPopup:onCloseBtnListener_()
    self:hide()
end

function CardActPopup:setLoading(isLoading)
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

function CardActPopup:getData()
    self:setLoading(true)
    bm.HttpService.POST(
        { mod = "Invite",
          act = "getActList"
        },function(data)
            self:setLoading(false)
            local jsnData = json.decode(data)
            if jsnData and jsnData.ret == 0 then
                self:updateData(jsnData)
            end
        end,function()
            self:setLoading(false)
        end)
end

function CardActPopup:updateData(data)
    self.data_ = data
    self.activityTime_:setString(bm.LangUtil.getText("CARD_ACT","ACT_TIME",data.openDate))
    self.rewardPayDesc_:setString(data.desc.payDesc)
    self.rewardPlayDesc_:setString(data.desc.playDesc)
    self.newplayer_:setData(data.data.invite,data.data.inviteNum)
    self.recall_:setData(data.data.recall,data.data.recallNum)
    self.rewardCount_:setString(bm.LangUtil.getText("CARD_ACT","REWARD_COUNT",data.total))
end

function CardActPopup:goToFinish()
    local FriendPopup = import("app.module.friend.FriendPopup")
    FriendPopup.new():show()
    self:hide()
end

function CardActPopup:goToMarket()
    local ScoreMarketView = import("app.module.scoremarket.ScoreMarketViewExt");
    ScoreMarketView.load(nil, nil,2,2)
    self:hide()
end

function CardActPopup:updateTotal(total)
    self.rewardCount_:setString(bm.LangUtil.getText("CARD_ACT","REWARD_COUNT",total))
end

function CardActPopup:bindActCode()
    if self.editCode_ then
        bm.HttpService.POST(
            { mod = "Invite",
              act = "actBinding",
              code = self.editCode_
            },function(data)
                local jsnData = json.decode(data)
                if jsnData and jsnData.ret == 0 then
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("CARD_ACT","BIND_SUCC"))
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

function CardActPopup:onShowed()
    self:getData()
end

function CardActPopup:show()
    nk.PopupManager:addPopup(self)
    return self
end

function CardActPopup:hide()
    nk.PopupManager:removePopup(self)
    return self
end

function CardActPopup:onCleanup()
    -- nk.EditBoxManager:removeEditBox(self.codeEdit_)
end

return CardActPopup