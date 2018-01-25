--
-- Author: tony
-- Date: 2014-08-06 11:56:22
--
local ChatMsgShortcutListItem = import(".ChatMsgShortcutListItem")
local ChatMsgToListItem = import(".ChatMsgToListItem")
local ChatMsgHistoryListItem = import(".ChatMsgHistoryListItem")
local ChatTabPanel = import(".ChatTabPanel")
local ChatMsgPanel = class("ChatMsgPanel", ChatTabPanel)
local StorePopup = import("app.module.newstore.StorePopup")
local ExpressionConfig = import(".ExpressionConfig").new()
local messageList = {}
local setMessageList = {}

function ChatMsgPanel:ctor(ctx,toPlayer)
    display.addSpriteFrames("room_expression_popup.plist", "room_expression_popup.png")
    self.ctx = ctx
    self.toPlayer = toPlayer
    ChatMsgPanel.super.ctor(self, bm.LangUtil.getText("ROOM", "CHAT_TAB_SHORTCUT"), bm.LangUtil.getText("ROOM", "CHAT_TAB_HISTORY"),false)

    self:setNodeEventEnabled(true)

    self.bottom_bg_ = display.newScale9Sprite("#new_chat_bottom_bg.png", 0, -self.HEIGHT * 0.5+48, cc.size(ChatMsgPanel.PAGE_WIDTH + 6, 80))
        :addTo(self)

    self.input_bg_ = display.newScale9Sprite("#room_pop_chat_input_bg.png", -56, -self.HEIGHT * 0.5+48, cc.size(ChatMsgPanel.PAGE_WIDTH - 110, 75))
        :addTo(self)

    --聊天输入框
    self.editBox_ = ui.newEditBox({
    	image = "#transparent.png", 
        size = cc.size(ChatMsgPanel.PAGE_WIDTH - 170, 60),
        x = -28,
        y = -self.HEIGHT * 0.5+48,
        listener = handler(self, self.onEditBoxStateChange_)
    })
    self.editBox_:setFontName(ui.DEFAULT_TTF_FONT)
    self.editBox_:setFontSize(32)
    self.editBox_:setFontColor(cc.c3b(0xb7, 0xc8, 0xd4))
    self.editBox_:setPlaceholderFontName(ui.DEFAULT_TTF_FONT)
    self.editBox_:setPlaceholderFontSize(25)
    self.editBox_:setPlaceholderFontColor(cc.c3b(0xb7, 0xc8, 0xd4))
    self.editBox_:setPlaceHolder(bm.LangUtil.getText("ROOM", "INPUT_HINT_MSG"))
    self.editBox_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    if device.platform == "ios" then
        self.editBox_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    else
        self.editBox_:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
    end

    self.editBox_:addTo(self,101)

    --发送按钮
    self.room_pop_chat_send_button_normal = cc.ui.UIPushButton.new({normal="#room_pop_chat_send_button_normal.png", pressed="#room_pop_chat_send_button_pressed.png"})
        :setButtonLabel(cc.ui.UILabel.new({text = bm.LangUtil.getText("COMMON", "SEND"), size = 28,  color = cc.c3b(0xff, 0xff, 0xff)}))
        :pos(ChatMsgPanel.PAGE_WIDTH * 0.5 - 54, self.editBox_:getPositionY() - 2)
        :onButtonClicked(buttontHandler(self, self.onSendClicked_))
        :addTo(self,102)

    --@按钮
    self.toBtn_ = cc.ui.UIPushButton.new({normal="#room_chat_to_normal.png", pressed="#room_chat_to_down.png"})
        :pos(-ChatMsgPanel.PAGE_WIDTH * 0.5+35, self.editBox_:getPositionY())
        :onButtonClicked(buttontHandler(self, self.onToBtnClicked_))
        :addTo(self,103)

    --左侧tab
    local leftTabHeight = 384
    local itemTabHeigth = 384/3
    display.newScale9Sprite("#new_chat_left_bg.png", -201, 39, cc.size(80, leftTabHeight))
        :addTo(self)
    --
    local list = {
        [1] = {
            "#transparent.png",
            "#new_chat_select_top.png",
            "#room_pop_chat_exp_normal.png",
            "#room_pop_chat_exp_selected.png",
        },
        [2] = {
            "#transparent.png",
            "#new_chat_select_middle.png",
            "#room_pop_chat_icon_normal.png",
            "#room_pop_chat_icon_selected.png",
        },
        [3] = {
            "#transparent.png",
            "#new_chat_select_middle.png",
            "#room_pop_chat_record_normal.png",
            "#room_pop_chat_record_selected.png",
        },
    }
    -- 分割线
    local startY = 167
    for k,v in ipairs(list) do
        if k<#list then
            local line_ = display.newScale9Sprite("#new_chat_line.png", 0, 0, cc.size(80, 2))
                :pos(-201,startY+itemTabHeigth*0.5-k*itemTabHeigth)
                :addTo(self)
        end
    end

    -- 按钮组
    self.group_ = cc.ui.UICheckBoxButtonGroup.new(display.TOP_TO_BOTTOM)
        :pos(-271,-24)
        :addTo(self,100)

    self.iconSprites_ = {}
    for k,v in ipairs(list) do
        local chkBox = cc.ui.UICheckBoxButton.new({off=v[1], on=v[2]}, {scale9 = true})
            :setButtonSize(80,itemTabHeigth)
            :align(display.CENTER)
        self.group_:addButton(chkBox, 2)

        local sprites = {}
        sprites[1] = display.newSprite(v[3])
        sprites[1]:addTo(chkBox)
        sprites[2] = display.newSprite(v[4])
        sprites[2]:addTo(chkBox)
        sprites[2]:hide()
        self.iconSprites_[k] = sprites
    end

    self.group_:onButtonSelectChanged(function(event)
        self:selectPage(event.selected)
        ChatMsgPanelIndex = event.selected
        for k,v in ipairs(self.iconSprites_) do
            if k==event.selected then
                v[1]:hide()
                v[2]:show()
            else
                v[1]:show()
                v[2]:hide()
            end
        end
    end)

    self.MessageType = 1
    if not ChatMsgPanelIndex then
        ChatMsgPanelIndex = 1
    end

    self.group_:getButtonAtIndex(ChatMsgPanelIndex):setButtonSelected(true)
    if self.toPlayer then
        local name = string.format("@%s ",self.toPlayer.nick)
        self.editBox_:setText(name)
        self.inputText_ = name
    end

    self.toPlayer = nil
end

function ChatMsgPanel:setPage(index, page)
    if index == 1 then
        if self.page1_ then
            self.page1_:removeFromParent()
        end
        self.page1_ = page:pos(0, 93):addTo(self):hide()
    elseif index == 2 then
        if self.page2_ then
            self.page2_:removeFromParent()
        end
        self.page2_ = page:pos(0, 93):addTo(self):hide()
    elseif index == 3 then
        if self.page3_ then
            self.page3_:removeFromParent()
        end
        self.page3_ = page:pos(0, 93):addTo(self):hide()
    end
    self:selectPage(self.selectedIndex_)
end

function ChatMsgPanel:selectPage(index)
    if self.page1_ then self.page1_:hide() end
    if self.page2_ then self.page2_:hide() end
    if self.page3_ then self.page3_:hide() end
    if index == 2 then
        self.selectedIndex_ = 2
        if not self.page2_ then
            self:setPage(2, self:createShortcutPage_())
            return
        end
        self.page2_:show()
    elseif index == 3 then
        self.selectedIndex_ = 3
        if not self.page3_ then
            self:setPage(3, self:createHistoryPage_())
            return
        end
        self.page3_:show()
    elseif index == 1 then
        self.selectedIndex_ = 1
        if not self.page1_ then
            self:setPage(1, self:createExpPage_())

            display.addSpriteFrames("room_expression_popup.plist", "room_expression_popup.png", function()
                self:chageExpBtnImg(1)
            end)

            display.addSpriteFrames("word_expression.plist", "word_expression.png", function()
                self:chageExpBtnImg(2)
            end)

            display.addSpriteFrames("expressions/room_vipexpression_popup.plist", "expressions/room_vipexpression_popup.png", function()
                self:chageExpBtnImg(3)
            end)

            display.addSpriteFrames("expressions/expressions_icon.plist", "expressions/expressions_icon.png", function()
                self:chageExpBtnImg(4)
            end)

            return
        end

        self.page1_:show()
    end
end

function ChatMsgPanel:chageExpBtnImg(index)
    if not index then return end
    local btn = self.subGroup_ and self.subGroup_:getButtonAtIndex(index)
    if btn and btn.options and not btn.icon then
        local sprite = display.newSprite(btn.options[2])
            :addTo(btn)
        sprite:setScale(btn.options[3])
        btn:setPosition(22+(index-1)*75,48)
        if index~=ChatMsgPanelExpIndex then
            btn:setColor(cc.c3b(150, 150, 150))
        end
    end
end

function ChatMsgPanel:createExpPage_()
    local page = display.newNode()
    local topSprite_ = display.newScale9Sprite("#new_chat_top_bg.png", 0, 0, cc.size(ChatMsgPanel.PAGE_WIDTH-74, 60))
        :pos(40,108)
        :addTo(page,101)
    local line_ = display.newScale9Sprite("#new_chat_line.png", 0, 0, cc.size(ChatMsgPanel.PAGE_WIDTH-74, 2))
        :pos(40,77)
        :addTo(page,102)
    self.expArrowStartX_ = -105
    self.arrow_ = display.newSprite("#new_chat_arrow.png")
        :pos(self.expArrowStartX_,73)
        :addTo(page,103)

    --表情tab
    local listW, listH = ChatMsgPanel.PAGE_WIDTH-74, ChatMsgPanel.PAGE_HEIGHT - 18
    self.subGroup_ = cc.ui.UICheckBoxButtonGroup.new()
        :pos(-125,60)
        :addTo(page,104)

    local groupBtns_ = {
        [1] = {
            "#transparent.png",
            "#expression-7.png",
            0.6,
        },
        [2] = {
            "#transparent.png",
            "#expression-105.png",
            0.4,
        },
        [3] = {
            "#transparent.png",
            "#expression-1003.png",
            0.3
        },
        [4] = {
            "#transparent.png",
            "#expressions_icon_2001.png",
            0.3
        },
    }

    if (self.ctx.model.isdice_ and not self:checkIsVip_()) or self.ctx.model.isInMatch_ then
        groupBtns_[3] = nil
        groupBtns_[4] = nil
        ChatMsgPanelExpIndex = 1
    end

    -- groupBtns_的坐标要根据长度来显示  坑爹
    for k,v in ipairs(groupBtns_) do
        local chkBox = cc.ui.UICheckBoxButton.new({off=v[1]})
            :align(display.CENTER)
        self.subGroup_:addButton(chkBox, 2)

        -- 动态赋值
        chkBox.options = v
    end

    for k,v in ipairs(groupBtns_) do
        local chkBox = self.subGroup_:getButtonAtIndex(k)
        local x_ = chkBox:getPositionX()
        chkBox:setPositionX(x_+(k-1)*35)
    end

    self.subGroup_:onButtonSelectChanged(function(event)
        local index = event.selected
        ChatMsgPanelExpIndex = index
        for i=1,5,1 do
            local chkBox = self.subGroup_:getButtonAtIndex(i)
            if chkBox then
                if index==i then
                    chkBox:setColor(display.COLOR_WHITE)
                else
                    chkBox:setColor(cc.c3b(150, 150, 150))
                end
            end
        end

        self.arrow_:setPositionX(self.expArrowStartX_+(index-1)*75)
        if index == 1 then
            if self.vipExpressionList_ then
                self.vipExpressionList_:hide()
            end

            if self.wordExpressionList_ then
                self.wordExpressionList_:hide()
            end

            if self.vipExpressionList2_ then
                self.vipExpressionList2_:hide()
            end

            if self.expressionList_ then
                self.expressionList_:show()
            else
                display.addSpriteFrames("room_expression_popup.plist", "room_expression_popup.png", function()
                    self:createUI_(page)
                end)
            end
        elseif index == 2 then
            if self.expressionList_ then
                self.expressionList_:hide()
            end

            if self.vipExpressionList_ then
                self.vipExpressionList_:hide()
            end

            if self.vipExpressionList2_ then
                self.vipExpressionList2_:hide()
            end

            if self.wordExpressionList_ then
                self.wordExpressionList_:show()
            else
                display.addSpriteFrames("word_expression.plist", "word_expression.png", function()
                    self:createWordExp_(page)
                end)
            end
        elseif index == 3 then
            if self.expressionList_ then
                self.expressionList_:hide()
            end

            if self.wordExpressionList_ then
                self.wordExpressionList_:hide()
            end

            if self.vipExpressionList2_ then
                self.vipExpressionList2_:hide()
            end

            if self.vipExpressionList_ then
                self.vipExpressionList_:show()
            else
                display.addSpriteFrames("expressions/room_vipexpression_popup.plist", "expressions/room_vipexpression_popup.png", function()
                    self:createVIPUI_(page)
                end)
            end
        elseif index == 4 then
            if self.expressionList_ then
                self.expressionList_:hide()
            end

            if self.wordExpressionList_ then
                self.wordExpressionList_:hide()
            end

            if self.vipExpressionList_ then
                self.vipExpressionList_:hide()
            end
            
            if self.vipExpressionList2_ then
                self.vipExpressionList2_:show()
            else
                display.addSpriteFrames("expressions/expressions_icon.plist", "expressions/expressions_icon.png", function()
                    self:createVIPUI_2_(page)
                end)
            end
        end
    end)

    if not ChatMsgPanelExpIndex then
        ChatMsgPanelExpIndex = 1
    end

    self.subGroup_:getButtonAtIndex(ChatMsgPanelExpIndex):setButtonSelected(true)

    return page
end

function ChatMsgPanel:createShortcutPage_()
    local page = display.newNode()

    --快捷消息
    local listW, listH = ChatMsgPanel.PAGE_WIDTH-74, ChatMsgPanel.PAGE_HEIGHT - 18
    self.shortcutMsgStringArr_ = bm.LangUtil.getText("ROOM", "CHAT_SHORTCUT")
    ChatMsgShortcutListItem.WIDTH = listW
    ChatMsgShortcutListItem.HEIGHT = 64
    ChatMsgShortcutListItem.ON_ITEM_CLICKED_LISTENER = buttontHandler(self, self.onChatShortcutClicked_)
    self.shortcutMsgList_ = bm.ui.ListView.new({
            viewRect = cc.rect(-0.5 * listW, -0.5 * listH, listW, listH),
            direction = bm.ui.ListView.DIRECTION_VERTICAL,
        }, ChatMsgShortcutListItem)
    self.shortcutMsgList_:addTo(page):pos(0+40, -55)
    self.shortcutMsgList_:setData(self.shortcutMsgStringArr_)
    return page
end

function ChatMsgPanel:createHistoryPage_()
    local page = display.newNode()
    --快捷消息
    local listW, listH = ChatMsgPanel.PAGE_WIDTH - 74, ChatMsgPanel.PAGE_HEIGHT - 18
    ChatMsgHistoryListItem.WIDTH = listW
    ChatMsgHistoryListItem.HEIGHT = 64
    self.historyList_ = bm.ui.ListView.new({
        viewRect = cc.rect(-0.5 * listW, -0.5 * listH, listW, listH),
        direction = bm.ui.ListView.DIRECTION_VERTICAL,
        }, ChatMsgHistoryListItem)
    self.historyList_:addTo(page):pos(0+40, -55)
    self:historyChanged_(nil)
    return page
end

function ChatMsgPanel:onChatShortcutClicked_(msg)
    if nk.userData.silenced == 1 then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "USER_SILENCED_MSG"))
        return
    end
    if not self.ctx.model:isSelfInSeat() then
        if not self.ctx.model.standChatCount then
            self.ctx.model.standChatCount = 0;
        end
        self.ctx.model.standChatCount = self.ctx.model.standChatCount + 1
        if self.ctx.model.standChatCount>3 then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SEND_CHAT_MUST_BE_IN_SEAT"))
            self:hidePanel()
            return;
        end
    end
    nk.socket.RoomSocket:sendChatMsg(msg)
    self:hidePanel()
end

function ChatMsgPanel:onEnter()
    self.historyWatcher_ = bm.DataProxy:addDataObserver(nk.dataKeys.ROOM_CHAT_HISTORY, handler(self, self.historyChanged_))
    self.bigLaBaMessageWatacher_ = bm.DataProxy:addDataObserver(nk.dataKeys.BIG_LA_BA_CHAT_HISTORY, handler(self, self.historyChanged_))
end

function ChatMsgPanel:onExit()
    bm.DataProxy:removeDataObserver(nk.dataKeys.ROOM_CHAT_HISTORY, self.historyWatcher_)
    bm.DataProxy:removeDataObserver(nk.dataKeys.BIG_LA_BA_CHAT_HISTORY, self.bigLaBaMessageWatacher_)
    if self.laBaNumberRequestId_ then
        bm.HttpService.CANCEL(self.laBaNumberRequestId_)
    end
end

function ChatMsgPanel:historyChanged_(list)
    local mergedList = {}
    table.insertto(mergedList, bm.DataProxy:getData(nk.dataKeys.ROOM_CHAT_HISTORY) or {})
    table.insertto(mergedList, bm.DataProxy:getData(nk.dataKeys.BIG_LA_BA_CHAT_HISTORY) or {})
    table.sort(mergedList, function(o1, o2)
        return o1.time > o2.time
    end)
    if self.historyList_ then
        self.historyList_:setData(mergedList)
    end
end


function ChatMsgPanel:onEditBoxStateChange_(evt, editbox)
    local text = editbox:getText()

    if evt == "began" then
        self.inputText_ = text
    elseif evt == "ended" then
    elseif evt == "return" then
        if device.platform ~= "ios" then
            self:onSendClicked_()
            self:hidePanel()
        end
    elseif evt == "changed" then
        local filteredText = nk.keyWordFilter(text)
        self.inputText_ = filteredText
        if filteredText ~= text then
            editbox:setText(filteredText)
        end
    else
        printf("EditBox event %s", tostring(evt))
    end
end

function ChatMsgPanel:onSelectTo_(player)
    local str = self.inputToTxt_:getText()
    str = string.format("@%s %s",player.nick,str)
    self.inputToTxt_:setText(str)
    self.editBox_:setText(str)
    self.inputText_ = str

    self:hideSendToNode_()
end

function ChatMsgPanel:hideSendToNode_()
    if self.sendToNode_ then
        self.sendToNode_:hide()
    end

    self.editBox_:setTouchEnabled(true)
end

function ChatMsgPanel:onToBtnClicked_()
    self.editBox_:setTouchEnabled(false)

    if not self.sendToNode_ then
        self.sendToNode_ = display.newScale9Sprite("#room_pop_bg.png", 0, 0, cc.size(ChatTabPanel.WIDTH, ChatTabPanel.HEIGHT))
            :pos(0, 0)
            :addTo(self,110)

        local sendBg = display.newScale9Sprite("#new_chat_bottom_bg.png", 0, 0, cc.size(ChatMsgPanel.PAGE_WIDTH + 6, 80))
            :pos((ChatMsgPanel.PAGE_WIDTH)*0.5+12,80*0.5+8)
            :addTo(self.sendToNode_,100)

        self.inputBg_ = display.newScale9Sprite("#room_pop_chat_input_bg.png", 0, 0, cc.size(ChatMsgPanel.PAGE_WIDTH - 195, 75))
            :pos((ChatMsgPanel.PAGE_WIDTH)*0.5,80*0.5+8)
            :addTo(self.sendToNode_,101)

        --聊天输入框
        self.inputToTxt_ = ui.newEditBox({
	        image = "#transparent.png", 
            size = cc.size(ChatMsgPanel.PAGE_WIDTH - 170, 60),
            x = 158,
            y = 36,
            listener = handler(self, self.onEditBoxStateChange_)
        })
        self.inputToTxt_:setFontName(ui.DEFAULT_TTF_FONT)
        self.inputToTxt_:setFontSize(32)
        self.inputToTxt_:setFontColor(cc.c3b(0xb7, 0xc8, 0xd4))
        self.inputToTxt_:setPlaceholderFontName(ui.DEFAULT_TTF_FONT)
        self.inputToTxt_:setPlaceholderFontSize(25)
        self.inputToTxt_:setPlaceholderFontColor(cc.c3b(0xb7, 0xc8, 0xd4))
        self.inputToTxt_:setPlaceHolder(bm.LangUtil.getText("ROOM", "INPUT_HINT_MSG"))
        self.inputToTxt_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)

        if device.platform == "ios" then
            self.inputToTxt_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
        else
            self.inputToTxt_:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
        end

        self.inputToTxt_:addTo(self.inputBg_,101)

        cc.ui.UIPushButton.new({normal="#room_pop_chat_send_button_normal.png", pressed="#room_pop_chat_send_button_pressed.png"})
            :setButtonLabel(cc.ui.UILabel.new({text = bm.LangUtil.getText("COMMON", "SEND"), size = 28,  color = cc.c3b(0xff, 0xff, 0xff)}))
            :pos((ChatMsgPanel.PAGE_WIDTH)*0.5+196,80*0.5+6)
            :onButtonClicked(function()
                local text = string.trim(self.inputToTxt_:getText() or "")
                self.editBox_:setText(text)
                if text=="" then
                    self:hideSendToNode_()
                else
                    self:onSendClicked_()
                end
            end)
            :addTo(self.sendToNode_,102)

        local backBtn_ = cc.ui.UIPushButton.new({normal="#room_pop_chat_send_button_normal.png", pressed="#room_pop_chat_send_button_pressed.png"},{scale9=true})
            :setButtonSize(88, 76)
            :pos((ChatMsgPanel.PAGE_WIDTH)*0.5-184,80*0.5+6)
            :onButtonClicked(function()
                local ss = self.inputToTxt_:getText()
                self.editBox_:setText(ss)
                self:hideSendToNode_()
            end)
            :addTo(self.sendToNode_,102)

        display.newSprite("#room_menu_button_normal.png")
            :rotation(90)
            :addTo(backBtn_)

        -- 头像选择列表
        local listW, listH = ChatTabPanel.WIDTH - 6, ChatTabPanel.HEIGHT - 24-80
        ChatMsgToListItem.WIDTH = listW-10
        ChatMsgToListItem.HEIGHT = 112
        ChatMsgToListItem.ON_ITEM_CLICKED_LISTENER = buttontHandler(self, self.onSelectTo_)
        self.sendToList_ = bm.ui.ListView.new({
                viewRect = cc.rect(-0.5 * listW, -0.5 * listH, listW, listH),
                direction = bm.ui.ListView.DIRECTION_VERTICAL,
            }, ChatMsgToListItem)
        self.sendToList_:addTo(self.sendToNode_,99):pos(listW*0.5+2, listH*0.5+91)
    end

    if self.editBox_ then
        local str = self.editBox_:getText()
        self.inputToTxt_:setText(str)
        self.inputText_ = str
    end

    self.sendToNode_:show()

    -- 刷新list
    local list = {}
    local players = self.ctx.model.playerList
    for i = 0, 9 do
        local player = players[i]
        if player and not player.isSelf and player.uid >1 then
            if self.ctx.model.isdice_ then
                table.insert(list,json.decode(player.userInfo))
            else
                table.insert(list,player)
            end
        end
    end

    self.sendToList_:setData(list)
    self.sendToList_:update()

    return self.sendToNode_
end

function ChatMsgPanel:onSendClicked_()
    if nk.userData.silenced == 1 then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "USER_SILENCED_MSG"))
        return
    end

    local text = string.trim(self.inputText_ or "")
 
    if self.MessageType == 3 then
        if text ~= "" then
            self.laBaUserRequestId_ = bm.HttpService.POST({mod="user", act="useprops",id = 32,message = text,key = crypto.md5("boomegg!@#$%"..text..os.time()),time = os.time() ,nick = nk.userData.nick},
                function(data) 
                    self.laBaUserRequestId_ = nil
                    local callData = json.decode(data)
                    self:hidePanel()
                end, function()
                    self.laBaUserRequestId_ = nil
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SEND_BIG_LABA_MESSAGE_FAIL"))
                end)
        end
    else
        if text ~= "" then
            if not self.ctx.model:isSelfInSeat() then
                if not self.ctx.model.standChatCount then
                    self.ctx.model.standChatCount = 0;
                end
                self.ctx.model.standChatCount = self.ctx.model.standChatCount + 1
                if self.ctx.model.standChatCount>3 then
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SEND_CHAT_MUST_BE_IN_SEAT"))
                    self:hidePanel()
                    return;
                end
            end
            local message = {messagetype = self.MessageType,content = text}
            nk.socket.RoomSocket:sendChatMsg(message)
            self:hidePanel()
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "INPUT_ALERT"))
        end
    end
end

function ChatMsgPanel:onCleanup()
    display.removeSpriteFramesWithFile("room_expression_popup.plist", "room_expression_popup.png")
    display.removeSpriteFramesWithFile("expressions/room_vipexpression_popup.plist", "expressions/room_vipexpression_popup.png")
end

function ChatMsgPanel:onExpressionClicked(id)
    if self.ctx.model:isSelfInSeat() then
        if id > 1000 then   --vip
            if self.ctx.model.isPDengRoom_ then
                if not self:checkIsVip_() then
                    nk.ui.Dialog.new({
                        messageText = bm.LangUtil.getText("VIP", "PDENG_SEND_EXP_TIPS"),
                        callback = function(param)
                            if param == nk.ui.Dialog.SECOND_BTN_CLICK then
                                local selpmode = StorePopup.BLUE_PAY

                                if device.platform == "ios" then
                                    selpmode = StorePopup.BLUE_PAY_IOS 
                                end
                                
                                StorePopup.new(StorePopup.GOODS_VIP, selpmode):showPanel()
                                self:hidePanel()
                            end
                        end
                    }):show()
                else
                    self:sendExpress_(id)
                end
                return
            end
            if not self:checkIsVip_() and self:isShowTipDialog_(id) then --yk
                local price = 100
                if id > 2000 then
                    price = 200
                end

                nk.ui.Dialog.new({
                    messageText = bm.LangUtil.getText("VIP", "ROOM_SEND_EXPRESSIONS_TIPS", price),
                    firstBtnText = bm.LangUtil.getText("VIP", "OPEN_VIP"),
                    callback = function(param)
                        if param == nk.ui.Dialog.FIRST_BTN_CLICK then
                            local selpmode = StorePopup.BLUE_PAY

                            if device.platform == "ios" then
                                selpmode = StorePopup.BLUE_PAY_IOS 
                            end
                            
                            StorePopup.new(StorePopup.GOODS_VIP, selpmode):showPanel()
                            self:hidePanel()
                        elseif param == nk.ui.Dialog.SECOND_BTN_CLICK then
                            self:sendExpress_(id)
                        end
                    end
                }):show()
            else
                self:sendExpress_(id)
            end
        else
            self:sendExpress_(id)
        end
    else
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SEND_EXPRESSION_MUST_BE_IN_SEAT"))
    end
end

function ChatMsgPanel:isShowTipDialog_(id)
    local IS_SHOW_EXPRESS_TIP_DIALOG = "IS_SHOW_EXPRESS_TIP_DIALOG_DOLPHIN"--海豚
    if id > 2000 then
        IS_SHOW_EXPRESS_TIP_DIALOG = "IS_SHOW_EXPRESS_TIP_DIALOG_BIG_FACE"--大脸
    end

    local lastday = nk.userDefault:getStringForKey(IS_SHOW_EXPRESS_TIP_DIALOG, "")
    local today = os.date("%Y%m%d")
    if lastday == "" or lastday ~= today then
        nk.userDefault:setStringForKey(IS_SHOW_EXPRESS_TIP_DIALOG, today)
        return true
    end
    
    return false
end

--yk
function ChatMsgPanel:checkIsVip_()
    local vipconfig = nk.OnOff:getConfig('newvipmsg')
    if vipconfig and vipconfig.newvip == 1 then
        return true
    end

    vipconfig = nk.OnOff:getConfig('vipmsg')
    if nk.OnOff:check("christmasVipbag") or vipconfig and vipconfig.vipbag and vipconfig.vipbag == 1 then
        return true
    end

    return false
end

function ChatMsgPanel:sendExpress_(id)
    if id < 1000 then
        self:sendFreeExpress_(id)
    else
        self:sendVipExpress_(id)
    end    

    self:hidePanel()
end

--免费表情
function ChatMsgPanel:sendFreeExpress_(id)
    local curScene = display.getRunningScene()
            
    if self.ctx.model.isdice_ then
        nk.socket.HallSocket:sendExpressionDice(1, id)
    elseif curScene.name == "PdengScene" then
        nk.socket.HallSocket:sendExpressionPdeng(1, id)
    else
        nk.socket.RoomSocket:sendExpression(1, id)
    end
end

--VIP表情
function ChatMsgPanel:sendVipExpress_(id)
    local price = -100
    local expType = 1
    if id > 2000 then
        expType = 2
        price = -200
    end

    local seatId = self.ctx.model:getSeatIdByUid(nk.userData.uid)
    if self.ctx.model.isdice_ then
        seatId = self.ctx.model:selfSeatId()
    end
    local pack = json.encode({
        uid = nk.userData.uid,
        seatId = seatId,
        expressionType = 1,
        expressionId = id,
        minusChips = -1,
        type = 5
    })

    bm.HttpService.POST(
        {
            mod = "User",
            act = "useVipFunFace",
            info = pack,
            facetype = expType,
            tid = self.ctx.model.roomInfo.tid
        },
        function (data)
            local ret = tonumber(data)
            if ret == -1 or ret == -3 then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("VIP", "ROOM_SEND_EXPRESSIONS_FAILED"))
            elseif ret == 1 then
                if not self:checkIsVip_() then
                    app:tip(1, price, 50, 50, 9999, 0, 20, 0)
                end
            end
        end,
        function ()
        end
    )
end

function ChatMsgPanel:createUI_(parent)
    local listW, listH = ChatMsgPanel.PAGE_WIDTH-74, ChatMsgPanel.PAGE_HEIGHT - 88

    local rect = cc.rect(-listW*0.5, -listH*0.5, listW, listH)
    local page = display.newNode()
        
    local row, col = 1, 1
    local expNum = 27
    local contentWidth = 500
    local contentHeight = ((expNum / 5 - (expNum / 5) % 1) + (expNum % 5 == 0 and 0 or 1)) * 100
    local contentLeft =  -0.5 * contentWidth+40
    local contentTop = 0.5 * contentHeight + 80
    for i = 1, expNum do
        local id = i
        local btn = cc.ui.UIPushButton.new({normal="#expression_transparent.png", pressed="#expression-btn-down.png"}, {scale9=true})
        btn:setTouchSwallowEnabled(false)
        btn:onButtonPressed(function(evt) 
            self.btnPressedY_ = evt.y
            self.btnClickCanceled_ = false
            btn:setButtonSize(120, 120)
        end)
        btn:onButtonRelease(function(evt) 
            btn:setButtonSize(100, 100)
            if math.abs(evt.y - self.btnPressedY_) > 10 then
                self.btnClickCanceled_ = true
            end
        end)
        btn:onButtonClicked(function(evt)
            if not self.btnClickCanceled_ and self:getParent():getCascadeBoundingBox():containsPoint(cc.p(evt.x, evt.y)) then
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                self:onExpressionClicked(id)
            end
        end)
        btn:setButtonSize(100, 100)
        btn:setAnchorPoint(cc.p(0.5, 0.5))
        btn:pos(contentLeft + 50 + (col - 1) * 100, contentTop - 70 - (row - 1) * 100)
        btn:addTo(page)
        local expConfig = ExpressionConfig:getConfig(id)
        local sprite = display.newSprite("#expression-" .. id .. ".png", contentLeft + 50 + (col - 1) * 100 + expConfig.adjustX * 0.7, contentTop - 70 - (row - 1) * 100 + expConfig.adjustY * 0.7):addTo(page)
        sprite:setScale(1)

        col = col + 1
        if col > 4 then
            row = row + 1
            col = 1
        end
    end
    self.expressionList_ = bm.ui.ScrollView.new({viewRect=rect, scrollContent=page, direction=bm.ui.ScrollView.DIRECTION_VERTICAL})
        :pos(50, -90)
    self.expressionList_:addTo(parent)
end

function ChatMsgPanel:onShow()
    if self.expressionList_ then
        self.expressionList_:setScrollContentTouchRect()
        self.expressionList_:update()
    end

    if self.wordExpressionList_ then
        self.wordExpressionList_:setScrollContentTouchRect()
        self.wordExpressionList_:update()
    end

    if self.vipExpressionList_ then
        self.vipExpressionList_:setScrollContentTouchRect()
        self.vipExpressionList_:update()
    end

    if self.vipExpressionList2_ then
        self.vipExpressionList2_:setScrollContentTouchRect()
        self.vipExpressionList2_:update()
    end

    if self.shortcutMsgList_ then
        self.shortcutMsgList_:setScrollContentTouchRect()
        self.shortcutMsgList_:update()
    end

    if self.historyList_ then
        self.historyList_:setScrollContentTouchRect()
    end

    nk.cacheKeyWordFile()
end

function ChatMsgPanel:createVIPUI_(parent)
    local listW, listH = ChatMsgPanel.PAGE_WIDTH-74, ChatMsgPanel.PAGE_HEIGHT - 88

    local rect = cc.rect(-listW*0.5, -listH*0.5, listW, listH)
    local page = display.newNode()

    local row, col = 1, 1
    local expNum = 9
    local contentWidth = 500
    local contentHeight = ((expNum / 5 - (expNum / 5) % 1) + (expNum % 5 == 0 and 0 or 1)) * 100
    local contentLeft =  -0.5 * contentWidth+40
    local contentTop = 0.5 * contentHeight + 80
    for i = 1, expNum do
        local id = 1000 + i
        local btn = cc.ui.UIPushButton.new({normal="#expression_transparent.png", pressed="#expression-btn-down.png"}, {scale9=true})
        btn:setTouchSwallowEnabled(false)
        btn:onButtonPressed(function(evt) 
            self.btnPressedY_ = evt.y
            self.btnClickCanceled_ = false
            btn:setButtonSize(120, 120)
        end)
        btn:onButtonRelease(function(evt) 
            btn:setButtonSize(100, 100)
            if math.abs(evt.y - self.btnPressedY_) > 10 then
                self.btnClickCanceled_ = true
            end
        end)
        btn:onButtonClicked(function(evt)
            if not self.btnClickCanceled_ and self:getParent():getCascadeBoundingBox():containsPoint(cc.p(evt.x, evt.y)) then
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                self:onExpressionClicked(id)
            end
        end)
        btn:setButtonSize(100, 100)
        btn:setAnchorPoint(cc.p(0.5, 0.5))
        btn:pos(contentLeft + 50 + (col - 1) * 100, contentTop - 80 - (row - 1) * 100)
        btn:addTo(page)
        local expConfig = ExpressionConfig:getConfig(id)
        local sprite = display.newSprite("#expression-" .. id .. ".png", contentLeft + 50 + (col - 1) * 100 + expConfig.adjustX * 0.7, contentTop - 80 - (row - 1) * 100 + expConfig.adjustY * 0.7):addTo(page)
        sprite:setScale(0.5)

        col = col + 1
        if col > 4 then
            row = row + 1
            col = 1
        end
    end
    self.vipExpressionList_ = bm.ui.ScrollView.new({viewRect=rect, scrollContent=page, direction=bm.ui.ScrollView.DIRECTION_VERTICAL})
        :pos(50, -90)
    self.vipExpressionList_:addTo(parent)
end

function ChatMsgPanel:createVIPUI_2_(parent)
    local listW, listH = ChatMsgPanel.PAGE_WIDTH-74, ChatMsgPanel.PAGE_HEIGHT - 88

    local rect = cc.rect(-listW*0.5, -listH*0.5, listW, listH)
    local page = display.newNode()

    local row, col = 1, 1
    local expNum = 20
    local contentWidth = 500
    local contentHeight = ((expNum / 5 - (expNum / 5) % 1) + (expNum % 5 == 0 and 0 or 1)) * 100
    local contentLeft =  -0.5 * contentWidth+40
    local contentTop = 0.5 * contentHeight + 80
    for i = 1, expNum do
        local id = 2000 + i
        local btn = cc.ui.UIPushButton.new({normal="#expression_transparent.png", pressed="#expression-btn-down.png"}, {scale9=true})
        btn:setTouchSwallowEnabled(false)
        btn:onButtonPressed(function(evt) 
            self.btnPressedY_ = evt.y
            self.btnClickCanceled_ = false
            btn:setButtonSize(120, 120)
        end)
        btn:onButtonRelease(function(evt) 
            btn:setButtonSize(100, 100)
            if math.abs(evt.y - self.btnPressedY_) > 10 then
                self.btnClickCanceled_ = true
            end
        end)
        btn:onButtonClicked(function(evt)
            if not self.btnClickCanceled_ and self:getParent():getCascadeBoundingBox():containsPoint(cc.p(evt.x, evt.y)) then
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                self:onExpressionClicked(id)
            end
        end)
        btn:setButtonSize(100, 100)
        btn:setAnchorPoint(cc.p(0.5, 0.5))
        btn:pos(contentLeft + 50 + (col - 1) * 100, contentTop - 80 - (row - 1) * 100)
        btn:addTo(page)
        local expConfig = ExpressionConfig:getConfig(id)
        local sprite = display.newSprite("#expressions_icon_" .. id .. ".png", contentLeft + 50 + (col - 1) * 100 + expConfig.adjustX * 0.7, contentTop - 80 - (row - 1) * 100 + expConfig.adjustY * 0.7):addTo(page)
        sprite:setScale(0.5)

        col = col + 1
        if col > 4 then
            row = row + 1
            col = 1
        end
    end
    self.vipExpressionList2_ = bm.ui.ScrollView.new({viewRect=rect, scrollContent=page, direction=bm.ui.ScrollView.DIRECTION_VERTICAL})
        :pos(50, -90)
    self.vipExpressionList2_:addTo(parent)
end

function ChatMsgPanel:createWordExp_(parent)
    local listW, listH = ChatMsgPanel.PAGE_WIDTH-74, ChatMsgPanel.PAGE_HEIGHT - 88

    local rect = cc.rect(-listW*0.5, -listH*0.5, listW, listH)
    local page = display.newNode()

    local row, col = 1, 1
    local expNum = 36
    local contentWidth = 500
    local contentHeight = ((expNum / 5 - (expNum / 5) % 1) + (expNum % 5 == 0 and 0 or 1)) * 100
    local contentLeft =  -0.5 * contentWidth+40
    local contentTop = 0.5 * contentHeight-50-30
    for i = 1, expNum do
        local id = 100 + i
        local btn = cc.ui.UIPushButton.new({normal="#expression_transparent.png", pressed="#expression-btn-down.png"}, {scale9=true})
        btn:setTouchSwallowEnabled(false)
        btn:onButtonPressed(function(evt) 
            self.btnPressedY_ = evt.y
            self.btnClickCanceled_ = false
            btn:setButtonSize(120, 120)
        end)
        btn:onButtonRelease(function(evt) 
            btn:setButtonSize(100, 60)
            if math.abs(evt.y - self.btnPressedY_) > 10 then
                self.btnClickCanceled_ = true
            end
        end)
        btn:onButtonClicked(function(evt)
            if not self.btnClickCanceled_ and self:getParent():getCascadeBoundingBox():containsPoint(cc.p(evt.x, evt.y)) then
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
                self:onExpressionClicked(id)
            end
        end)
        btn:setButtonSize(100, 60)
        btn:setAnchorPoint(cc.p(0.5, 0.5))
        btn:pos(contentLeft + 50 + (col - 1) * 100, contentTop - 80 - (row - 1) * 60)
        btn:addTo(page)
        local expConfig = ExpressionConfig:getConfig(id)
        local sprite = display.newSprite("#expression-" .. id .. ".png", contentLeft + 50 + (col - 1) * 100 + expConfig.adjustX * 0.7, contentTop - 80 - (row - 1) * 60 + expConfig.adjustY * 0.7):addTo(page)
        sprite:setScale(expConfig.scale)

        col = col + 1
        if col > 4 then
            row = row + 1
            col = 1
        end
    end
    self.wordExpressionList_ = bm.ui.ScrollView.new({viewRect=rect, scrollContent=page, direction=bm.ui.ScrollView.DIRECTION_VERTICAL})
        :pos(50, -90)
    self.wordExpressionList_:addTo(parent)
end

return ChatMsgPanel