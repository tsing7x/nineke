--
-- Author: KevinLiang@boyaa.com
-- Date: 2016-07-13 11:57:54
--
local PokerActivityPopup = class("PokerActivityPopup", nk.ui.Panel)

local WIDTH = 810
local HEIGHT = 586

local TEXT_COLOR = cc.c3b(0xEE, 0xEE, 0xEE)

function PokerActivityPopup:ctor(scene_, type_)
    self:setNodeEventEnabled(true)
    self.roomType = type_
    self.scene = scene_
    self:setupView()
    self:loadConfigData()
end

function PokerActivityPopup:setupView()

    PokerActivityPopup.super.ctor(self, {WIDTH, HEIGHT})

    self.background_:removeFromParent()
    self.backgroundTex_:removeFromParent()
    self.background_ = display.newSprite("#poker_activity_bg.png"):addTo(self)
    self.background_:setTouchEnabled(true)
    self.background_:setTouchSwallowEnabled(true)

    cc.ui.UIPushButton.new({normal = "#poker_activity_close.png"})
            :pos(self.close_x_ - 20, self.close_y_ - 8)
            :onButtonClicked(function()
                self:onClose()
                nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
            end)
            :addTo(self, PANEL_CLOSE_BTN_Z_ORDER)
    display.newSprite("#poker_activity_title.png"):pos(0, 210):addTo(self)

    local time_node = display.newNode():pos(0, 116):addTo(self):hide()
    local time_pos_y = 2
    ui.newTTFLabel({text = bm.LangUtil.getText("POKER_ACT", "TIME_TITLE"), color = TEXT_COLOR, size = 22, align = ui.TEXT_ALIGN_CENTER})
        :pos(-108, time_pos_y):addTo(time_node)
    display.newScale9Sprite("#poker_activity_time_bg.png", 0, 0, cc.size(160, 48)):pos(52, 0):addTo(time_node)
    local time1 = display.newSprite("#poker_activity_time_icon.png"):pos(0, 0):addTo(time_node)
    local time2 = display.newSprite("#poker_activity_time_icon.png"):pos(52, 0):addTo(time_node)
    local time3 = display.newSprite("#poker_activity_time_icon.png"):pos(104, 0):addTo(time_node)
    self.time_hour = ui.newTTFLabel({text = "", color = TEXT_COLOR, size = 22, align = ui.TEXT_ALIGN_CENTER})
        :pos(time1:getPositionX(), time1:getPositionY() + time_pos_y)
        :addTo(time_node)
    self.time_min = ui.newTTFLabel({text = "", color = TEXT_COLOR, size = 22, align = ui.TEXT_ALIGN_CENTER})
        :pos(time2:getPositionX(), time2:getPositionY() + time_pos_y)
        :addTo(time_node)
    self.time_sec = ui.newTTFLabel({text = "", color = TEXT_COLOR, size = 22, align = ui.TEXT_ALIGN_CENTER})
        :pos(time3:getPositionX(), time3:getPositionY() + time_pos_y)
        :addTo(time_node)
    self.time_node = time_node

    self.tasks = {}
    display.newScale9Sprite("#poker_activity_content_bg.png", 0, 0, cc.size(724, 286)):pos(0, -60):addTo(self)
    for i = 1, 3 do
        local task_pos_y = 24 - (i - 1) * 88
        local task_node = display.newNode():pos(0, task_pos_y):addTo(self)
        display.newSprite("#poker_activity_content_list_bg.png"):pos(-172, 0):addTo(task_node)
        display.newSprite("#poker_activity_content_list_bg.png"):pos(172, 0):addTo(task_node):setScaleX(-1)
        display.newSprite("#poker_activity_content_list_icon.png"):pos(-292, 0):addTo(task_node)
        self.tasks[i] = {}
        self.tasks[i].titleText = ui.newTTFLabel({text = "", color = TEXT_COLOR, size = 18, align = ui.TEXT_ALIGN_CENTER})
            :pos(-150, 0):addTo(task_node)
        self.tasks[i].rewardText = ui.newTTFLabel({text = "", color = TEXT_COLOR, size = 18, align = ui.TEXT_ALIGN_CENTER})
            :pos(76, 0):addTo(task_node)

        self.tasks[i].rewardTip = ui.newTTFLabel({text = "", color = cc.c3b(0,191,255), size = 18, align = ui.TEXT_ALIGN_CENTER})
            :pos(76, -20):addTo(task_node):hide()

        self.tasks[i].rewardStamp = display.newSprite("#poker_activity_content_list_stamp.png"):pos(-64, -4)
            :addTo(task_node):hide()
        self.tasks[i].button_node = display.newNode():pos(264, 0):addTo(task_node)
        self.tasks[i].buttonSprite = display.newSprite("#poker_activity_reward_button_progress.png"):addTo(self.tasks[i].button_node)
        self.tasks[i].buttonText = ui.newTTFLabel({text = "", color = TEXT_COLOR, size = 22, align = ui.TEXT_ALIGN_CENTER})
            :pos(0, 2)
            :addTo(self.tasks[i].button_node)
        self.tasks[i].buttonClick = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png"},{scale9 = true})
            :setButtonSize(144, 40)
            :addTo(self.tasks[i].button_node)
            :onButtonClicked(function(evt)
                    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                    self:onGetRewardClick(i)
                end)
            :hide()
    end

    local bottom_pos_y = -246
    self.bottomButton = cc.ui.UIPushButton.new({normal = "#poker_activity_button_1.png"})
        :pos(0, bottom_pos_y)
        :setButtonLabel("normal", ui.newTTFLabel({text = bm.LangUtil.getText("POKER_ACT", "TASK_GIVEUP"), size = 24, color = TEXT_COLOR}))
        :onButtonClicked(buttontHandler(self, self.onButtonClick))
        :addTo(self)
        :hide()
end

function PokerActivityPopup:updateTime(time_)
    if time_ >= 0 then
        local hour = math.floor(time_ / 3600)
        local min = math.floor((time_ - hour * 3600) / 60)
        local sec = time_ - hour * 3600 - min * 60
        if hour < 10 then
            hour = "0" .. hour
        end
        if min < 10 then
            min = "0" .. min
        end
        if sec < 10 then
            sec = "0" .. sec
        end
        self.time_hour:setString(hour)
        self.time_min:setString(min)
        self.time_sec:setString(sec)
    end
end

function PokerActivityPopup:setTime(time_)
    if time_ > 0 then
        self.time_down = time_
        self.time_node:stopAllActions()
        self.time_node:runAction((cc.RepeatForever:create(transition.sequence({
                    cc.CallFunc:create(function()
                        if self.time_down >= 0 then
                            self:updateTime(self.time_down)
                        else
                            self.time_node:stopAllActions()
                        end
                        self.time_down = self.time_down - 1
                    end),
                    cc.DelayTime:create(1.0)
            }))))
    else
        self.time_node:stopAllActions()
    end
end

function PokerActivityPopup:updateUIFromJson()
    if self.Data_ then
        self.bottomButton:show()
        if self.Data_.select and self.Data_.select == 1 then
            self.time_node:show()
            self.bottomButton:setButtonLabelString("normal", bm.LangUtil.getText("POKER_ACT", "TASK_GIVEUP"))
        else
            self.time_node:hide()
            self.bottomButton:setButtonLabelString("normal", bm.LangUtil.getText("POKER_ACT", "TASK_GET"))
        end
        if self.Data_.list and #self.Data_.list == 3 then
            for i = 1, 3 do
                self.tasks[i].rewardText:pos(76,0)
                self.tasks[i].rewardTip:hide()
                local mul = ""
                if nk.OnOff:check("newMotherDays") then
                    mul = "x2"
                    self.tasks[i].rewardText:pos(76,15)
                    self.tasks[i].rewardTip:show()
                    self.tasks[i].rewardTip:setString("โบนัสเฉพาะวันแม่แห่งชาติ")
                end
                self.tasks[i].titleText:setString(bm.LangUtil.getText("POKER_ACT", "TASK_TITLE", self.Data_.sb, self.Data_.list[i].num))
                if self.Data_.list[i].reward.money then
                    self.tasks[i].rewardText:setString(bm.LangUtil.getText("POKER_ACT", "TASK_REWARD", tostring(self.Data_.list[i].reward.money) .. mul))
                elseif self.Data_.list[i].reward.gcoins then
                    self.tasks[i].rewardText:setString(bm.LangUtil.getText("POKER_ACT", "TASK_REWARD_GCOIN", tostring(self.Data_.list[i].reward.gcoins) .. mul))
                elseif self.Data_.list[i].reward.coins then
                    if self.Data_.list[i].cardReward then
                        local card_name = self.Data_.list[i].cardReward.name
                        local card_num = self.Data_.list[i].cardReward.left
                        local str = "บัตร " .. card_name .. "หรือ \n" .. bm.LangUtil.getText("LOTTERY", "CASH_BUY", self.Data_.list[i].reward.coins)
                        self.tasks[i].rewardText:setString(str)
                        self.tasks[i].rewardText:pos(76,15)
                        local tips = "บัตร " .. card_name .. "ยังเหลือ " .. card_num .. " ใบ"
                        self.tasks[i].rewardTip:setString(tips)
                        self.tasks[i].rewardTip:show()
                    else
                        self.tasks[i].rewardText:setString(bm.LangUtil.getText("POKER_ACT", "TASK_REWARD_COIN", tostring(self.Data_.list[i].reward.coins) .. mul))
                    end  
                end
                if self.Data_.list[i].rewarded and self.Data_.list[i].rewarded == 1 then
                    self.tasks[i].buttonClick:hide()
                    self.tasks[i].buttonSprite:setSpriteFrame(display.newSpriteFrame("poker_activity_reward_button_got.png"))
                    self.tasks[i].buttonText:setString(bm.LangUtil.getText("LOTTERY", "RESULT_WIN_GOT"))
                    self.tasks[i].rewardStamp:show()
                else
                    self.tasks[i].rewardStamp:hide()
                    if self.Data_.cur >= self.Data_.list[i].num then
                        self.tasks[i].buttonClick:show()
                        self.tasks[i].buttonSprite:setSpriteFrame(display.newSpriteFrame("poker_activity_reward_button_get.png"))
                        self.tasks[i].buttonText:setString(bm.LangUtil.getText("COMMON", "GET_REWARD"))
                    else
                        self.tasks[i].buttonClick:hide()
                        self.tasks[i].buttonSprite:setSpriteFrame(display.newSpriteFrame("poker_activity_reward_button_progress.png"))
                        self.tasks[i].buttonText:setString(self.Data_.cur .. "/" .. self.Data_.list[i].num)
                    end
                end
            end
            if self.Data_.list[1].rewarded == 1 and
                self.Data_.list[2].rewarded == 1 and
                self.Data_.list[3].rewarded == 1 then
                    self.bottomButton:hide()
                    self.time_node:hide()
            end
        else
            self.bottomButton:hide()
            self.time_node:hide()
        end
    end
end

function PokerActivityPopup:loadConfigData()
    if not self.juhua_ then
        self.juhua_ = nk.ui.Juhua.new():addTo(self)
    end
    bm.HttpService.POST({mod="Task", act="paList", type = self.roomType},
        function(data)
            if self.juhua_ then
                self.juhua_:removeFromParent()
                self.juhua_ = nil
            end
            local callData = json.decode(data)
            if callData and callData.ret and callData.ret == 0 then
                    self.Data_ = callData
                    if callData.timeLeft then
                        self:setTime(self.Data_.timeLeft)
                    end
                    if self.isShowed then
                        self:updateUIFromJson()
                    end
            end
        end, function()
    end)
end

function PokerActivityPopup:onButtonClick()
    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    if self.Data_ then
        if self.Data_.select and self.Data_.select == 1 then
            nk.ui.Dialog.new({
                messageText = bm.LangUtil.getText("POKER_ACT", "TASK_GIVEUP_TIPS"), 
                firstBtnText = bm.LangUtil.getText("COMMON", "CANCEL"),
                secondBtnText = bm.LangUtil.getText("COMMON", "CONFIRM"), 
                callback = function (type)
                    if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                        bm.HttpService.POST({mod="Task", act="paCancel", type = self.roomType},
                            function(data)
                                local callData = json.decode(data)
                                if callData and callData.ret and callData.ret == 0 then
                                    self:loadConfigData()
                                end
                            end, function()
                        end)
                    end
                end
            }):show()

        else
            bm.HttpService.POST({mod="Task", act="paSelect", type = self.roomType, sb = self.Data_.sb},
                function(data)
                    local callData = json.decode(data)
                    if callData and callData.ret and callData.ret == 0 then
                        self.Data_.select = 1
                        self:updateUIFromJson()
                    end
                end, function()
            end)
        end
    end
end

function PokerActivityPopup:onGetRewardClick(index)
    bm.HttpService.POST({mod="Task", act="paReward", type = self.roomType, idx = (index - 1)},
                function(data)
                    local callData = json.decode(data)
                    if callData and callData.ret and callData.ret == 0 then
                        self.Data_.list[index].rewarded = 1
                        local tips = ""
                        if callData.id and callData.id > 0 and self.Data_.list[index].cardReward then
                            self.Data_.list[index].cardReward.left = self.Data_.list[index].cardReward.left - 1
                            tips = "ยินดีด้วยค่ะ คุณได้รับ " .. self.Data_.list[index].cardReward.name .. " กรุณาเช็ครายละเอียดที่ห้างห้องแข่งขันค่ะ"
                        elseif self.Data_.list[index].reward.money then
                            tips = "ยินดีด้วยค่ะ ท่านได้รับ " .. self.Data_.list[index].reward.money .. " ชิป"
                        elseif self.Data_.list[index].reward.gcoins then
                            tips = "ยินดีด้วยค่ะ ท่านได้รับ " .. self.Data_.list[index].reward.gcoins .. " ชิปทองคำ"
                        elseif self.Data_.list[index].reward.coins then
                            tips = "ยินดีด้วยค่ะ ท่านได้รับ " .. self.Data_.list[index].reward.coins .. " ชิปเงินสด"
                        end
                        if tips ~= "" then
                            nk.TopTipManager:showTopTip(tips)
                        end
                        
                        self:updateUIFromJson()
                        self:checkPokerActivityStatus()
                        self:checkTaskFinished()
                    end
                end, function()
            end)
end


-- 检查牌局活动是否完成
function PokerActivityPopup:checkTaskFinished()
    local finished = false
    if self.Data_.list[1].rewarded == 1 and
        self.Data_.list[2].rewarded == 1 and
        self.Data_.list[3].rewarded == 1 then
            finished = true
    end
    if finished then
        self:loadConfigData()
    end
end

-- 检查牌局活动是否可以领奖
function PokerActivityPopup:checkPokerActivityStatus()
    local rewardable = false
    for i = 1, 3 do
        if self.Data_.list[i].rewarded and self.Data_.list[i].rewarded == 0 then
            if self.Data_.cur >= self.Data_.list[i].num then
                rewardable = true
                break
            end
        end
    end
    if self.scene then
        if rewardable then
            self.scene:updatePokerActivityStatus(true)
        else
            self.scene:updatePokerActivityStatus(false)
        end
    end
end

function PokerActivityPopup:onShowed()
    if self.Data_ then
        self:updateUIFromJson()
    end
    self.isShowed = true
end

function PokerActivityPopup:show()
    nk.PopupManager:addPopup(self)
    return self
end

function PokerActivityPopup:hide()
    nk.PopupManager:removePopup(self)
    return self
end

function PokerActivityPopup:onCleanup()
end

return PokerActivityPopup