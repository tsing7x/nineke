--
-- Author: KevinLiang@boyaa.com
-- Date: 2015-11-27 11:57:54
--
local PlayerbackModel = import(".PlayerbackModel")
local FriendListPopup = import(".FriendListPopup")

local PlayerbackPopup = class("PlayerbackPopup", function()
    return display.newNode()
end)

local TAB_COLOR = cc.c3b(0x65, 0x1b, 0x1b)
local TAB_COLOR_SELECT = cc.c3b(0xfe, 0xfe, 0xfe)

function PlayerbackPopup:ctor(callback)
    self:setNodeEventEnabled(true)
    self:setupView()
    self.callback_ = callback
    self.tabIndex_ = 1
    self:updateTaskStatus()
end

function PlayerbackPopup:setupView()

    local node, width, height = cc.uiloader:load('playerback.ExportJson')
    if node then
        node:setAnchorPoint(cc.p(0.5, 0.5))
        node:addTo(self)
    end

    bm.TouchHelper.new(cc.uiloader:seekNodeByTag(self, 5)):enableTouch()

    --关闭按钮
    local closeButton = cc.uiloader:seekNodeByTag(self, 51)
    closeButton:onButtonClicked(function(event)
        self:onCloseBtnListener_()
    end)

    -- 老用户回归奖
    self.leftTab1 = cc.uiloader:seekNodeByTag(self, 11)
    self.leftTab1Selected = cc.uiloader:seekNodeByTag(self, 13)
    bm.TouchHelper.new(self.leftTab1, function(target,evtName)
        if evtName==bm.TouchHelper.CLICK then
            self:updateTab(1)
        end
    end)
    self.leftTab1Text = cc.uiloader:seekNodeByTag(self, 15)
    self.leftTab1Text:setString(bm.LangUtil.getText("PLAYERBACK", "TASK_TIPS")[1])

    -- 普通场玩牌1局
    self.leftTab2 = cc.uiloader:seekNodeByTag(self, 22)
    self.leftTab2Selected = cc.uiloader:seekNodeByTag(self, 23)
    bm.TouchHelper.new(self.leftTab2, function(target,evtName)
        if evtName==bm.TouchHelper.CLICK then
            self:updateTab(2)
        end
    end)
    self.leftTab2Text = cc.uiloader:seekNodeByTag(self, 25)
    self.leftTab2Text:setString(bm.LangUtil.getText("PLAYERBACK", "TASK_TIPS")[2])

    -- 比赛场玩牌1局
    self.leftTab3 = cc.uiloader:seekNodeByTag(self, 32)
    self.leftTab3Selected = cc.uiloader:seekNodeByTag(self, 33)
    bm.TouchHelper.new(self.leftTab3, function(target,evtName)
        if evtName==bm.TouchHelper.CLICK then
            self:updateTab(3)
        end
    end)
    self.leftTab3Text = cc.uiloader:seekNodeByTag(self, 35)
    self.leftTab3Text:setString(bm.LangUtil.getText("PLAYERBACK", "TASK_TIPS")[3])

    -- 召回老朋友
    self.leftTab4 = cc.uiloader:seekNodeByTag(self, 42)
    self.leftTab4Selected = cc.uiloader:seekNodeByTag(self, 43)
    bm.TouchHelper.new(self.leftTab4, function(target,evtName)
        if evtName==bm.TouchHelper.CLICK then
            self:updateTab(4)
        end
    end)
    self.leftTab4Text = cc.uiloader:seekNodeByTag(self, 45)
    self.leftTab4Text:setString(bm.LangUtil.getText("PLAYERBACK", "TASK_TIPS")[4])

    self.rightContent = cc.uiloader:seekNodeByTag(self, 1002)
    self.rightContent:setString("")

    --按钮
    self.rewardButton = cc.uiloader:seekNodeByTag(self, 50)
    self.rewardButton:setButtonLabelString("")
    self.rewardButton:onButtonClicked(function(event)
        self:onRewardBtnListener_()
    end)

    self.rightPanel = cc.uiloader:seekNodeByTag(self, 10025)

    self.fuidInput_ = ui.newEditBox({
            size = cc.size(260, 40),
            align=ui.TEXT_ALIGN_CENTER - 30,
            image="#playerback_popup_input_bg.png",
            x = 150,
            y = 220,
            listener = handler(self, self.fuidChange_)
        })
    self.fuidInput_:setFontName(ui.DEFAULT_TTF_FONT)
    self.fuidInput_:setFontSize(24)
    self.fuidInput_:setFontColor(cc.c3b(0x92, 0x8d, 0x8d))
    self.fuidInput_:setPlaceholderFontName(ui.DEFAULT_TTF_FONT)
    self.fuidInput_:setPlaceholderFontSize(38)
    self.fuidInput_:setPlaceholderFontColor(cc.c3b(0x92, 0x8d, 0x8d))
    self.fuidInput_:setPlaceHolder(bm.LangUtil.getText("PLAYERBACK", "INPUT_HINT_MSG"))
    self.fuidInput_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.fuidInput_:setReturnType(cc.KEYBOARD_RETURNTYPE_GO)
    self.fuidInput_:addTo(self.rightPanel, 10, 10)
    
    self.rewardsBtn_ = cc.ui.UIPushButton.new({normal= "#playerback_popup_btn_green.png",pressed="#playerback_popup_btn_green.png"},{scale9 = true})
            :setButtonSize(150, 45)
            :onButtonClicked(handler(self,self.onGetRecallBtnListener_))
            :setButtonLabel(ui.newTTFLabel({text=bm.LangUtil.getText("PLAYERBACK", "GET_COIN"), size=24, color=cc.c3b(0xff, 0xff, 0xff), align=ui.TEXT_ALIGN_CENTER}))
            :pos(370,220)
            :addTo(self.rightPanel)

    self.recallCode_ = cc.uiloader:seekNodeByTag(self, 10026)
    self.recallCode_:setString(bm.LangUtil.getText("PLAYERBACK", "RECALL_CODE",nk.userData.uid))
    self.recallCodeDesc_ = cc.uiloader:seekNodeByTag(self, 10027)
    self.recallCodeDesc_:setString(bm.LangUtil.getText("PLAYERBACK", "RECALL_CODE_DESC"))

    self:updateTab(1)
end

function PlayerbackPopup:fuidChange_(event)
    if event == "changed" then
        self.fuid_ = self.fuidInput_:getText()
    elseif event == "return" then
        self.fuid_ = self.fuidInput_:getText()
    end
end

function PlayerbackPopup:updateTab(index_)
    if index_ == 1 then
        if PlayerbackModel.getTask1Status() == "rewarded" then
            self.rewardButton:setButtonLabelString(bm.LangUtil.getText("PLAYERBACK","GOT_REWARD"))
        else
            self.rewardButton:setButtonLabelString(bm.LangUtil.getText("PLAYERBACK","GET_REWARD"))
        end
        self.leftTab1Selected:show()
        self.leftTab1Text:setTextColor(TAB_COLOR_SELECT)
        self.rightContent:setString(bm.LangUtil.getText("PLAYERBACK", "OLD_CONTENT"))

        self.leftTab2Selected:hide()
        self.leftTab2Text:setTextColor(TAB_COLOR)

        self.leftTab3Selected:hide()
        self.leftTab3Text:setTextColor(TAB_COLOR)

        self.leftTab4Selected:hide()
        self.leftTab4Text:setTextColor(TAB_COLOR)
        self.rightPanel:hide()
    elseif index_ == 2 then
        if PlayerbackModel.getTask2Status() == "rewarded" then
            self.rewardButton:setButtonLabelString(bm.LangUtil.getText("PLAYERBACK","CHECK_TICKET"))
        elseif PlayerbackModel.getTask2Status() == "done" then
            self.rewardButton:setButtonLabelString(bm.LangUtil.getText("PLAYERBACK","GET_TICKET"))
        elseif PlayerbackModel.getTask2Status() == "doing" then
            self.rewardButton:setButtonLabelString(bm.LangUtil.getText("PLAYERBACK","PLAY_NOW"))
        elseif PlayerbackModel.getTask2Status() == "not_start" then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("PLAYERBACK","TASK_NOT_START"))
            return
        end

        self.leftTab1Selected:hide()
        self.leftTab1Text:setTextColor(TAB_COLOR)

        self.leftTab2Selected:show()
        self.leftTab2Text:setTextColor(TAB_COLOR_SELECT)
        self.rightContent:setString(bm.LangUtil.getText("PLAYERBACK", "NORMAL_PLAY"))

        self.leftTab3Selected:hide()
        self.leftTab3Text:setTextColor(TAB_COLOR)

        self.leftTab4Selected:hide()
        self.leftTab4Text:setTextColor(TAB_COLOR)
        self.rightPanel:hide()
    elseif index_ == 3 then
        if PlayerbackModel.getTask3Status() == "rewarded" then
            self.rewardButton:setButtonLabelString(bm.LangUtil.getText("PLAYERBACK","COIN_SUGGEST"))
        elseif PlayerbackModel.getTask3Status() == "done" then
            self.rewardButton:setButtonLabelString(bm.LangUtil.getText("PLAYERBACK","GET_REWARD"))
        elseif PlayerbackModel.getTask3Status() == "doing" then
            self.rewardButton:setButtonLabelString(bm.LangUtil.getText("PLAYERBACK","INMATCH_NOW"))
        elseif PlayerbackModel.getTask3Status() == "not_start" then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("PLAYERBACK","TASK_NOT_START"))
            return
        end
        self.leftTab1Selected:hide()
        self.leftTab1Text:setTextColor(TAB_COLOR)

        self.leftTab2Selected:hide()
        self.leftTab2Text:setTextColor(TAB_COLOR)

        self.leftTab3Selected:show()
        self.leftTab3Text:setTextColor(TAB_COLOR_SELECT)
        self.rightContent:setString(bm.LangUtil.getText("PLAYERBACK", "MATCH_PLAY"))

        self.leftTab4Selected:hide()
        self.leftTab4Text:setTextColor(TAB_COLOR)
        self.rightPanel:hide()
    else
        if PlayerbackModel.getTask4Status() == "rewarded" then
            self.rewardsBtn_:setButtonLabelString(bm.LangUtil.getText("PLAYERBACK","GOT_REWARD"))
        else
            self.rewardsBtn_:setButtonLabelString(bm.LangUtil.getText("PLAYERBACK","GET_COIN"))
        end

        self.rewardButton:setButtonLabelString(bm.LangUtil.getText("PLAYERBACK","CHECK_FIRENDS"))
        self.leftTab1Selected:hide()
        self.leftTab1Text:setTextColor(TAB_COLOR)

        self.leftTab2Selected:hide()
        self.leftTab2Text:setTextColor(TAB_COLOR)

        self.leftTab3Selected:hide()
        self.leftTab3Text:setTextColor(TAB_COLOR)

        self.leftTab4Selected:show()
        self.leftTab4Text:setTextColor(TAB_COLOR_SELECT)
        self.rightContent:setString("")
        self.rightPanel:show()
    end
    self.tabIndex_ = index_
end

function PlayerbackPopup:getReward(num,fuid)
    if num < 2 or num > 5 then
        return 
    end
    if not fuid then
        fuid = 0
    end
    if postId then
        bm.HttpService.CANCEL(postId)
    end
    postId = bm.HttpService.POST({mod = "Regression", act = "awardOldUser",
            num = num,
            fuid = fuid
        }, function(data)
            local jsn = json.decode(data)
            if jsn and jsn.ret == 1 then
                PlayerbackModel.setStatus(num)
                self:updateTaskStatus()
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("PLAYERBACK","GET_REWARD_SUCC"))
            elseif jsn and jsn.ret == -4 then
                PlayerbackModel.setStatus(num)
                self:updateTaskStatus()
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("PLAYERBACK","GOT_REWARD_ERROR"))
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("PLAYERBACK","GET_REWARD_FAIL"))
            end
        end,
        function()
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("PLAYERBACK","GET_REWARD_FAIL"))
        end)
end

function PlayerbackPopup:onCloseBtnListener_()
    self:hide()
end

function PlayerbackPopup:onGetRecallBtnListener_()
    if not self.fuid_ or self.fuid_ == "" then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("PLAYERBACK","NOT_INPUT_FUID_ERROR"))
    else
        self:getReward(5,self.fuid_)
    end
end

function PlayerbackPopup:onRewardBtnListener_()
    if self.tabIndex_ == 1 then
        if PlayerbackModel.getTask1Status() == "done" then
            self:getReward(2,0)
        end
    elseif self.tabIndex_ == 2 then
        if PlayerbackModel.getTask2Status() == "doing" then
            self:goPlayNow()
        elseif PlayerbackModel.getTask2Status() == "done" then
            self:getReward(3,0)
        elseif PlayerbackModel.getTask2Status() == "rewarded" then
            self:checkTicket()
        end
    elseif self.tabIndex_ == 3 then
        if PlayerbackModel.getTask3Status() == "doing" then
            self:goMatch()
        elseif PlayerbackModel.getTask3Status() == "done" then
            self:getReward(4,0)
        elseif PlayerbackModel.getTask3Status() == "rewarded" then
            self:openExchange()
        end
    elseif self.tabIndex_ == 4 then
        FriendListPopup.new():show()
    end
end

function PlayerbackPopup:updateTaskStatus()
    if PlayerbackModel.getTask3Status() == "not_start" then
        if PlayerbackModel.getTask2Status() == "not_start" then
            self:updateTab(1)
        else
            self:updateTab(2)
        end
    elseif PlayerbackModel.getTask3Status() == "rewarded" then
        self:updateTab(4)
    else
        self:updateTab(3)
    end

end

function PlayerbackPopup:goPlayNow()
    if self.callback_ then
        self.callback_("playnow")
        self:hide()
    end
end

function PlayerbackPopup:goMatch()
    if self.callback_ then
        self.callback_("gotoArenaRoomView")
        self:hide()
    end
end

function PlayerbackPopup:checkTicket()
    if self.callback_ then
        self.callback_("gotoCheckMatchTicket")
        self:hide()
    end
end

function PlayerbackPopup:openExchange()
    if self.callback_ then
        self.callback_("openExchange")
        self:hide()
    end
end

function PlayerbackPopup:show()
    nk.PopupManager:addPopup(self)
    
    return self
end

function PlayerbackPopup:hide()
    nk.PopupManager:removePopup(self)

    return self
end

return PlayerbackPopup