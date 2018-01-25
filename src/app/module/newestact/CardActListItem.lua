--
-- Author: Jonah0608@gmail.com
-- Date: 2016-12-05 11:26:15
--
local CardActRewardPopup = import(".CardActRewardPopup")
local CardActListItem =  class("CardActListItem",function()
    return display.newNode()
end)

function CardActListItem:ctor(parent,type)
    self.parent_ = parent
    self.type_ = type
    self.canreward_ = false
    self.rewardId_ = -1
    self:setupView()
end

function CardActListItem:setupView()
    local tipsStr = bm.LangUtil.getText("CARD_ACT", "INVITE_NUM")
    if self.type_ == "recall" then
        tipsStr = bm.LangUtil.getText("CARD_ACT", "RECALL_NUM")
    end
    self.tips_ = ui.newTTFLabel({text = tipsStr, color = cc.c3b(0xff, 0xff, 0xff), size = 16, align = ui.TEXT_ALIGN_LEFT})
        :align(display.CENTER_LEFT)
        :pos(-367,33)
        :addTo(self)

    local progressWidth = 495
    local progressHeight = 24
    self.progress_ = nk.ui.ProgressBar.new(
        "#card_activity_progress_bg.png", 
        "#card_activity_progress_front.png", 
        {
            bgWidth = progressWidth, 
            bgHeight = 26, 
            fillWidth = 34, 
            fillHeight = progressHeight
        }
    ):pos(-368,0)
    :addTo(self):setValue(0.0)

    self.progressLabel = ui.newTTFLabel({
            text = "",
            size = 18,
            color = cc.c3b(0xfF, 0xfF, 0xfF),
            align = ui.TEXT_ALIGN_CENTER
        }):addTo(self.progress_):pos(progressWidth/2 + 30, 0) 

    local iconStr = "#card_activity_card_blue.png"
    if self.type_ == "invite" then
        iconStr = "#card_activity_card_red.png"
    else
        iconStr = "#card_activity_card_blue.png"
    end
    self.rewardIcon_ = display.newSprite(iconStr)
        :pos(180,0)
        :addTo(self)

    self.rewardBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_blue_normal.png", pressed = "#common_btn_blue_pressed.png"}, {scale9 = true})
        :setButtonLabel(ui.newTTFLabel({text=bm.LangUtil.getText("CARD_ACT","GOTO_FINISH"), size=20, color=styles.FONT_COLOR.LIGHT_TEXT, align=ui.TEXT_ALIGN_CENTER}))
        :setButtonSize(145, 50)
        :onButtonClicked(function(evt)
            self:goToFinish()
        end)
        :pos(305,0)
        :addTo(self)

    self.tipspaopao_ = {}
    self.tipspaopaolabel_ = {}
    self.tipsSprite_ = {}
    self.tipsProgress_ = {}
    for i = 1,3 do
        self.tipspaopao_[i] = display.newSprite("#card_activity_tips_1.png")
            :pos(125 * i -  370,-30)
            :addTo(self)

        local size = self.tipspaopao_[i]:getContentSize()
        self.tipspaopaolabel_[i] =  ui.newTTFLabel({
            text = "",
            size = 18,
            color = cc.c3b(0xff, 0xff, 0xff),
            align = ui.TEXT_ALIGN_CENTER
        }):addTo(self.tipspaopao_[i]):pos(size.width/2, size.height / 2 - 3) 

        self.tipsSprite_[i] = display.newSprite("#card_activity_star_progress.png")
            :pos(125 * i -  380,0)
            :addTo(self)

        self.tipsProgress_[i] =  ui.newTTFLabel({
            text = "",
            size = 24,
            color = cc.c3b(0x86,0x54,0x56),
            align = ui.TEXT_ALIGN_CENTER
        }):addTo(self.tipsSprite_[i]):pos(22,22)
        
    end

    self.tipsSprite_[4] = display.newSprite("#card_activity_star_progress.png")
        :pos(120,0)
        :addTo(self)

    self.tipsProgress_[4] =  ui.newTTFLabel({
        text = "",
        size = 24,
        color = cc.c3b(0x86,0x54,0x56),
        align = ui.TEXT_ALIGN_CENTER
    }):addTo(self.tipsSprite_[4]):pos(22,22)

    self.rewardDesc_ = ui.newTTFLabel({
        text = "",
        size = 18,
        color = cc.c3b(0xff, 0xff, 0xff),
        align = ui.TEXT_ALIGN_CENTER
    }):addTo(self):pos(180, -30) 
end

function CardActListItem:setData(data,cur)
    if cur > data[4].num then
        cur = data[4].num
    end
    self.cur_ = cur
    self.data_ = data
    for i = 1,3 do
        self:setDataItem(i,data[i],cur)
    end

    self.tipsProgress_[4]:setString(data[4].num)
    if cur >= data[4].num then
        self.tipsSprite_[4]:setSpriteFrame(display.newSpriteFrame("card_activity_star_reward.png"))
        self.tipsProgress_[4]:setColor(cc.c3b(0xff, 0x76, 0x12))
    end

    self.progress_:setValue(self.cur_ / data[4].num)
    self.progressLabel:setString(self.cur_ .. "/" .. data[4].num)
    local reward = data[4].reward.name
    if data[4].cardReward then
        reward = data[4].cardReward.name
    end
    self.rewardDesc_:setString(reward)
    self:checkCanReward(data,cur)
end

function CardActListItem:checkCanReward(data,cur)
    for i = 1,4 do
        if cur >= data[i].num and data[i].rewarded ~= 1 then
            self:setCanReward(true,i-1)
            return
        end 
    end
    if cur >= data[4].num then
        self:setCanReward(false,-1,true)
    else
        self:setCanReward(false,-1,false)
    end
end

function CardActListItem:setDataItem(index,item,cur)
    if cur < item.num then
        self:updateSprite(self.tipspaopao_[index],"notreward")
    else
        if item.rewarded == 1 then
            self:updateSprite(self.tipspaopao_[index],"rewarded")
        else
            self:updateSprite(self.tipspaopao_[index],"canreward")
        end
    end
    -- if index == 1 then
    --     local posX = self.tipspaopao_[index]:getPositionX()
    --     self.tipspaopao_[index]:pos(posX-5,-30)
    --     posX = self.tipsSprite_[index]:getPositionX()
    --     self.tipsSprite_[index]:pos(posX-5,0)
    -- end
    -- if index == 2 then
    --     local posX = self.tipspaopao_[index]:getPositionX()
    --     self.tipspaopao_[index]:pos(posX-45,-30)
    --     posX = self.tipsSprite_[index]:getPositionX()
    --     self.tipsSprite_[index]:pos(posX-45,0)
    -- end
    if cur >= item.num then
        self.tipsSprite_[index]:setSpriteFrame(display.newSpriteFrame("card_activity_star_reward.png"))
        self.tipsProgress_[index]:setColor(cc.c3b(0xff, 0x76, 0x12))
    end

    self.tipsProgress_[index]:setString(item.num)
    self.tipspaopaolabel_[index]:setString(bm.formatNumberWithSplit(item.reward.money) .. bm.LangUtil.getText("CARD_ACT","MONEY"))
end



function CardActListItem:updateSprite(sprite,status)
    if status == "canreward" then
        sprite:setSpriteFrame(display.newSpriteFrame("card_activity_tips_3.png"))
    elseif status == "rewarded" then 
        sprite:setSpriteFrame(display.newSpriteFrame("card_activity_tips_2.png"))
    elseif status == "notreward" then
        sprite:setSpriteFrame(display.newSpriteFrame("card_activity_tips_1.png"))
    end
end

function CardActListItem:getReward()
    bm.HttpService.POST(
        { mod = "Invite",
          act = "actReward",
          type = self.type_,
          idx = self.rewardId_
        },function(data)
            local jsnData = json.decode(data)
            if jsnData and jsnData.ret == 0 then
                CardActRewardPopup.new(jsnData,self.rewardId_):show()
                self.data_[self.rewardId_ + 1].rewarded = 1
                self.rewardId_ = -1
                self:checkCanReward(self.data_,self.cur_)
                self:updateTotal(jsnData.total)
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("CARD_ACT","REWARD_FAIL"))
            end
        end,function()
        end)
end

function CardActListItem:setCanReward(canreward,rewardId,check)
    self.rewardId_ = rewardId or -1
    if self.canreward_ == canreward and check == false then
        return
    end
    self.canreward_ = canreward
    if self.canreward_ then
        self.rewardBtn_:setButtonImage("normal", "#common_btn_yellow_normal.png")
        self.rewardBtn_:setButtonImage("pressed", "#common_btn_yellow_pressed.png")
        self.rewardBtn_:setButtonLabelString(bm.LangUtil.getText("CARD_ACT","GET_REWARD"))
        self.rewardBtn_:removeEventListenersByEvent("CLICKED_EVENT")
        self.rewardBtn_:onButtonClicked(function(evt)
            self:getReward()
        end)
    else
        if check then
            self.rewardBtn_:setButtonImage("normal", "#common_btn_blue_normal.png")
            self.rewardBtn_:setButtonImage("pressed", "#common_btn_blue_pressed.png")
            if self.type_ == "invite" then
                self.rewardBtn_:setButtonLabelString(bm.LangUtil.getText("DAILY_TASK","HAD_FINISH"))
                self.rewardBtn_:removeEventListenersByEvent("CLICKED_EVENT")
            else
                self.rewardBtn_:setButtonLabelString(bm.LangUtil.getText("CARD_ACT","CHECK"))
                self.rewardBtn_:removeEventListenersByEvent("CLICKED_EVENT")
                self.rewardBtn_:onButtonClicked(function(evt)
                    self:goToMarket()
                end)
            end
            
        else
            self.rewardBtn_:setButtonImage("normal", "#common_btn_blue_normal.png")
            self.rewardBtn_:setButtonImage("pressed", "#common_btn_blue_pressed.png")
            self.rewardBtn_:setButtonLabelString(bm.LangUtil.getText("CARD_ACT","GOTO_FINISH"))
            self.rewardBtn_:removeEventListenersByEvent("CLICKED_EVENT")
            self.rewardBtn_:onButtonClicked(function(evt)
                self:goToFinish()
            end)
        end
    end
end

function CardActListItem:updateTotal(total)
    if self.parent_ then
        self.parent_:updateTotal(total)
    end
end

function CardActListItem:goToFinish()
    if self.parent_ then
        self.parent_:goToFinish()
    end
end

function CardActListItem:goToMarket()
    if self.parent_ then
        self.parent_:goToMarket()
    end
end

return CardActListItem