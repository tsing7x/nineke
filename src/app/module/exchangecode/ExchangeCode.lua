
-- Author: jacob@boomegg.com
-- Date: 2014-09-28 10:57:15
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--
local WIDTH = 800
local HEIGHT = 468
local TOP_HEIGHT = 64
local Panel = nk.ui.Panel
local ExchangeCode = class("ExchangeCode", Panel)

local CommonRewardChipAnimation = import("app.login.CommonRewardChipAnimation")
local logger = bm.Logger.new("ExchangeCode")

local TEXT_COLOR = cc.c3b(0xEE, 0xEE, 0xEE)

function ExchangeCode:ctor(code)
    ExchangeCode.super.ctor(self, {WIDTH, HEIGHT})
    self.code_ = code
    display.addSpriteFrames("ecode.plist", "ecode.png")

    self:setNodeEventEnabled(true)
    self:setCommonStyle(bm.LangUtil.getText("ECODE", "TITLE"))
    
    local TOP = self.height_*0.5
    local BOTTOM = -self.height_*0.5
    local LEFT = -self.width_*0.5
    local RIGHT = self.width_*0.5
        
    self.editCode_ = ui.newEditBox({
        size = cc.size(520, 62),
        align=ui.TEXT_ALIGN_CENTER,
        image="#common_input_bg.png",
        imagePressed="#common_input_bg_down.png",
        x = LEFT + 290,
        y = TOP - 120,
        listener = handler(self, self.onCodeEdit_)
    })
    self.editCode_:setFontName(ui.DEFAULT_TTF_FONT)
    self.editCode_:setFontSize(30)
    self.editCode_:setFontColor(cc.c3b(0xd7, 0xf6, 0xff))
    self.editCode_:setPlaceholderFontName(ui.DEFAULT_TTF_FONT)
    self.editCode_:setPlaceholderFontSize(26)
    self.editCode_:setPlaceholderFontColor(cc.c3b(0xb7, 0xc8, 0xd4))
    self.editCode_:setPlaceHolder(bm.LangUtil.getText("ECODE", "EDITDEFAULT"))
    self.editCode_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.editCode_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.editCode_:addTo(self)

    self.exchangeButton_ = cc.ui.UIPushButton.new({normal= "#common_btn_green_normal.png", pressed = "#common_btn_green_pressed.png"},{scale9 = true})
        :setButtonSize(180, 55)
        :setButtonLabel(ui.newTTFLabel({text=bm.LangUtil.getText("ECODE", "EXCHANGE"), size=24, color=cc.c3b(0xb2, 0xdc, 0xff), align=ui.TEXT_ALIGN_CENTER}))
        :onButtonClicked(handler(self, self.onExchangeHandler))
        :pos(277, TOP - 120)
        :addTo(self)

    self.contentBackground_ = display.newScale9Sprite("#panel_overlay.png", 0, 0, cc.size(WIDTH-56, 230))
        :pos(0, TOP -270)
        :addTo(self)

    self.exchangeReward_ = display.newSprite("#ecode_icon.png")
        :pos(LEFT + 196, -50)
        :addTo(self)

    self.desc_ = ui.newTTFLabel({text=bm.LangUtil.getText("ECODE", "DESC"), size=24, color=cc.c3b(0xb2, 0xdc, 0xff), align=ui.TEXT_ALIGN_LEFT, valign=ui.TEXT_VALIGN_TOP,dimensions=cc.size(380, 230)}):addTo(self)
    self.desc_:setAnchorPoint(cc.p(0.5, 1))
    self.desc_:pos(RIGHT-238, TOP-166)

    self.fansButton_ = cc.ui.UIPushButton.new({normal= "#common_btn_blue_normal.png", pressed = "#common_btn_blue_pressed.png"},{scale9 = true})
        :setButtonSize(742, 55)
        :setButtonLabel(ui.newTTFLabel({text=bm.LangUtil.getText("ECODE", "FANS"), size=24, color=cc.c3b(0xb2, 0xdc, 0xff), align=ui.TEXT_ALIGN_CENTER}))
        :onButtonClicked(handler(self, self.fansOnClick))
        :pos(0, BOTTOM + 50)
        :addTo(self)
    if self.code_ and self.code_~="" and self.code_~=0 and self.code_~="0" then
        self.editCode_:setText(self.code_)
    end
end

function ExchangeCode:onExchangeHandler()
    local len = 0
    if self.codeEdit_ then
        len = string.len(string.trim(self.codeEdit_))
    end
    if len == 6 then
        self:onExchangeCode_()
    elseif len == 8 then
        self:onInviteCode_()
    else
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("ECODE", "ERROR_FAILED"))
    end
end

--兑换码
function ExchangeCode:onExchangeCode_()
    if string.len(string.trim(self.codeEdit_)) ~= 6 then
       nk.TopTipManager:showTopTip(bm.LangUtil.getText("ECODE", "ERROR_FAILED"))
    else 
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new():pos(0, 0):addTo(self)
        end

        bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="Wheel_start"})
        bm.HttpService.POST(
        {
            mod = "exchangeCode", 
            act = "exchange",
            code=string.trim(self.codeEdit_)
         },
        function (data)
            logger:debug("Jacob")
            logger:debug("ExchangeCode", data)
            local callData = json.decode(data)
            self:clearJuhua()

            if callData ~= nil and callData.ret == 0 then
                local p1, p2 = self:getItem(callData)
                self.codeReward = p1
                nk.ui.Dialog.new({
                    messageText = bm.LangUtil.getText("ECODE", "SUCCESS", self.codeReward), 
                    secondBtnText = bm.LangUtil.getText("COMMON", "SHARE"),
                    hasFirstButton = false,
                    callback = function (type)
                           if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                               self:onShare()
                           end
                       end
                }):show()

                if p2 then  --没筹码就不播动画
                    self:playBoxRewardAnimation_(p2)
                else
                    bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="Wheel_end"}) 
                end
            else
                if callData ~= nil and callData.ret == 1 then
                    self.codeReward = self:getItem(callData)
                    nk.ui.Dialog.new({
                        messageText = bm.LangUtil.getText("ECODE", "ERROR_USED", self.codeReward),
                        secondBtnText = bm.LangUtil.getText("COMMON", "SHARE"),
                        hasFirstButton = false,
                        callback = function (type)
                               if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                                   self:onShare()
                               end
                           end
                    }):show()
                elseif callData ~= nil and callData.ret == 2 then
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("ECODE", "ERROR_INVALID"))      --2 过期了
                elseif callData ~= nil and callData.ret == 3 then
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("ECODE", "ERROR_END"))          --3 领完了
                else
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("ECODE", "ERROR_FAILED"))
                end

                bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="Wheel_end"}) 
            end
        end,
        function (data)
            self:clearJuhua()
            bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="Wheel_end"})
        end
        )
    end
end

--邀请码
function ExchangeCode:onInviteCode_()
    bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="Wheel_start"})
    bm.HttpService.POST(
        {
            mod = "InviteCode", 
            act = "exchange",
            icode = string.trim(self.codeEdit_)
        },
        function(data)
            local callData = json.decode(data)
            self:clearJuhua()

            if callData.ret == 1 then
                self.codeReward = callData.reward
                nk.ui.Dialog.new({
                messageText = bm.LangUtil.getText("ECODE", "SUCCESS", callData.reward), 
                secondBtnText = bm.LangUtil.getText("COMMON", "SHARE"),
                hasFirstButton = false,
                callback = function (type)
                       if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                           self:onShare()
                       end
                   end
                }):show()

                self:playBoxRewardAnimation_(callData.reward)
            else
                nk.TopTipManager:showTopTip(callData.msg)
                bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="Wheel_end"})
            end  
        end,
        function()
            self:clearJuhua(data)
            bm.EventCenter:dispatchEvent({name="Player_BoxRewardAnimation", data="Wheel_end"})
        end
    )
end

function ExchangeCode:playBoxRewardAnimation_(money)
    local rewards = {}
    local info = {
        type = 1,
        icon = "match_chip.png",
        txt  = bm.LangUtil.getText("MATCH", "MONEY").." + "..tostring(money),
        num  = bm.formatBigNumber(money),
        val  = money
    }
        
    table.insert(rewards, #info + 1, info)

    nk.UserInfoChangeManager:playBoxRewardAnimation(nk.UserInfoChangeManager.MainHall, rewards, true)
end

function ExchangeCode:getItem(val)
    local index=1
    local itemName=""
    local chips
    while val.rwd[index] do
        if val.rwd[index]["key"]=="chips" then
            chips=itemName..val.rwd[index]["val"]
            itemName=itemName..val.rwd[index]["val"].." "..bm.LangUtil.getText("STORE", "TITLE_CHIP")
        elseif val.rwd[index]["key"]=="fun_face" then
            itemName=itemName..val.rwd[index]["val"].." "..bm.LangUtil.getText("STORE", "TITLE_PROP")
        else
            itemName=itemName..val.rwd[index]["val"]..val.rwd[index]["key"]---需要本地化的物品名称
        end
        index = index +1
    end
    return itemName,chips
end  

-- 清除菊花
function ExchangeCode:clearJuhua()
    if self.juhua_ then
        self.juhua_:removeFromParent()
        self.juhua_ = nil
    end
end

function ExchangeCode:onCodeEdit_(event)
    if event == "began" then
        -- 开始输入
    elseif event == "changed" then
        -- 输入框内容发生变化是
        self.codeEdit_ = self.editCode_:getText()
    elseif event == "ended" then
        -- 输入结束
    elseif event == "return" then
        -- 从输入框返回
        print(self.codeEdit_)
    end
end

function ExchangeCode:onShare() 

    local feedData = clone(bm.LangUtil.getText("FEED", "EXCHANGE_CODE"))
    feedData.name = bm.LangUtil.formatString(feedData.name, self.codeReward)
    nk.Facebook:shareFeed(feedData, function(success, result)
    logger:debug("FEED.EXCHANGE_CODE result handler -> ", success, result)
         if not success then
             self.shareBtn_:setButtonEnabled(true)
             nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_FAILED"))
         else
             nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_SUCCESS"))
         end
    end)
end

function ExchangeCode:fansOnClick()
    print("setting fans on click")
    device.openURL(bm.LangUtil.getText("ABOUT", "FANS_OPEN"))
end
function ExchangeCode:hide()
    self:hidePanel_()
end

function ExchangeCode:show(times,subsidizeChips)
    
    self:showPanel_()
end

function ExchangeCode:onEnter()
end

function ExchangeCode:onExit()
    display.removeSpriteFramesWithFile("ecode.plist", "ecode.png")
    if self.closeCallback_ then
        self.closeCallback_()
    end
end

return ExchangeCode
