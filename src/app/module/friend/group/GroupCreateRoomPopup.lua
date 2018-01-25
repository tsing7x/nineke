local GroupCreateRoomPopup = class("GroupCreateRoomPopup", nk.ui.Panel)

local logger = bm.Logger.new("GroupCreateRoomPopup")

local WIDTH, HEIGHT = 750, 480
local frame_w, frame_h = WIDTH - 60, HEIGHT - 150--小框宽高
local width, height = frame_w, 360 --scrollview内容结点宽高
local lineNum = 5 --分割线数
local itemHeight = height / lineNum --每个item高度
local sy = height - itemHeight/2 - 3 --第一个item y坐标
local gcoinBlindCfg = {10, 50, 100, 500, 1000, 5000}

function GroupCreateRoomPopup:ctor(groupid,delegate)
	GroupCreateRoomPopup.super.ctor(self, {WIDTH, HEIGHT})
	self:setNodeEventEnabled(true)
    self.this_ = self
    self.group_id_ = groupid
    self.delegate_ = delegate

	self:addTitle(bm.LangUtil.getText("GROUP","CROOMPOPTITLE"),5)
    self.title_:setTextColor(cc.c3b(0xff,0xff,0xff))
    self.title_:setSystemFontSize(28)
    self:addCloseBtn()

    self.betType_ = 1 --下注类型
    self.tableType_ = 1 --桌子类型
    
    display.newScale9Sprite("#panel_overlay.png",
        0, 0, cc.size(frame_w, frame_h)):addTo(self)

    self.viewNode_ = display.newNode()
        :size(width, height)
        :align(display.CENTER)

    for i = 1, lineNum - 1 do
        display.newScale9Sprite("#group_dividing_line.png",
            width/2, (lineNum - i) * itemHeight,
            cc.size(width - 4, 2)):addTo(self.viewNode_)
    end

    self:addRoomBetType_()
    self:addRoomPlayType_()
    self:addRoomTableType_()
    self:addRoomBlind_()
    self:addRoomPassword_()
    self:addCreateButton_()

    local w, h = frame_w, frame_h - 10
    local scrollViewRect = cc.rect(-w/2, -h/2, w, h)
    self.scrollView_ = bm.ui.ScrollView.new({
        viewRect      = scrollViewRect,
        scrollContent = self.viewNode_,
        direction     = bm.ui.ScrollView.DIRECTION_VERTICAL,
    })
    :addTo(self)

    self:addTouchLayer_(w, h, 0, 0)

    self:dealRoomList()
end

--场次类型(下注类型)
function GroupCreateRoomPopup:addRoomBetType_()
    local node = self.viewNode_
    local y = sy
    ui.newTTFLabel({
            text = bm.LangUtil.getText("GROUP","ROOM_TYPE"),
            color = cc.c3b(0xa8, 0x9f, 0xe1), 
            size = 24,
            align = ui.TEXT_ALIGN_LEFT,
        })
        :align(display.LEFT_CENTER, 30, y)
        :addTo(node)

    local privateRoom = nk.userData.groupConfig.privateRoom or 0
    if privateRoom == 1 then--暂时关闭游戏币房间创建，PHP有BUG修复，后期去掉判断
        local betTypeGroup = cc.ui.UICheckBoxButtonGroup.new()
        local chipBtn = cc.ui.UICheckBoxButton.new({off="#group_radio_normal.png", on="#group_radio_select.png"}, {scale9 = true})
            :setButtonLabel(ui.newTTFLabel({text=bm.LangUtil.getText("GROUP","ROOM_PLAY_TYPE_GCOIN"), size=24, color=cc.c3b(0xdc, 0xdc, 0xff), align=ui.TEXT_ALIGN_LEFT}))
            :setButtonLabelAlignment(display.CENTER_LEFT)
            :setButtonLabelOffset(26, -2)
            :align(display.LEFT_CENTER)

        local gcionBtn = cc.ui.UICheckBoxButton.new({off="#group_radio_normal.png", on="#group_radio_select.png"}, {scale9 = true})
            :setButtonLabel(ui.newTTFLabel({text=bm.LangUtil.getText("GROUP","ROOM_PLAY_TYPE_CHIP"), size=24, color=cc.c3b(0xdc, 0xdc, 0xff), align=ui.TEXT_ALIGN_LEFT}))
            :setButtonLabelAlignment(display.CENTER_LEFT)
            :setButtonLabelOffset(26, -2)
            :align(display.LEFT_CENTER)

        --betTypeGroup:addButton(chipBtn)
        betTypeGroup:addButton(gcionBtn)

        local size1 = chipBtn:getCascadeBoundingBox()
        local size2 = gcionBtn:getCascadeBoundingBox()

        betTypeGroup:pos(220, y - 20):addTo(node)

        local distance = (width - 220 - size1.width - size2.width)/2
        betTypeGroup:setButtonsLayoutMargin(0, distance, 0, 0)

        -- 处理初始化默认选择
        local btn = betTypeGroup:getButtonAtIndex(1)
        if btn then
            btn:setButtonSelected(true)
        end

        betTypeGroup:onButtonSelectChanged(function(event)
            nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
            self.betType_ = event.selected
            self:dealRoomList()
        end)
    else
        ui.newTTFLabel({
            text = bm.LangUtil.getText("GROUP","ROOM_PLAY_TYPE_GCOIN"),
            color = cc.c3b(0xdc, 0xdc, 0xff), 
            size = 24,
            align = ui.TEXT_ALIGN_LEFT,
        })
        :align(display.LEFT_CENTER, 220, y)
        :addTo(node)
    end
    
end

--房间玩法
function GroupCreateRoomPopup:addRoomPlayType_()
    local node = self.viewNode_
    local y = sy - itemHeight
    ui.newTTFLabel({
            text = bm.LangUtil.getText("GROUP","ROOM_PLAY_TYPE_TITLE"),
            color = cc.c3b(0xa8, 0x9f, 0xe1), 
            size = 24,
            align = ui.TEXT_ALIGN_LEFT,
        })
        :align(display.LEFT_CENTER, 30, y)
        :addTo(node)

    ui.newTTFLabel({
            text = bm.LangUtil.getText("GROUP","ROOM_PLAY_TYPE"),
            color = cc.c3b(0xdc, 0xdc, 0xff), 
            size = 24,
            align = ui.TEXT_ALIGN_LEFT,
        })
        :align(display.LEFT_CENTER, 220, y)
        :addTo(node)
end

--桌子类型(5人或9人)
function GroupCreateRoomPopup:addRoomTableType_()
    local node = self.viewNode_
    local y = sy - itemHeight * 2
    ui.newTTFLabel({
            text = bm.LangUtil.getText("GROUP","CROOMPOPNUMWORD"),
            color = cc.c3b(0xa8, 0x9f, 0xe1), 
            size = 24,
            align = ui.TEXT_ALIGN_LEFT,
        })
        :align(display.LEFT_CENTER, 30, y)
        :addTo(node)

    self.memberBtnGroup_ = cc.ui.UICheckBoxButtonGroup.new()
    local btn5 = cc.ui.UICheckBoxButton.new({off="#group_radio_normal.png", on="#group_radio_select.png"}, {scale9 = true})
        :setButtonLabel(ui.newTTFLabel({text=bm.LangUtil.getText("GROUP","CROOMPOPNUM5"), size=24, color=cc.c3b(0xdc, 0xdc, 0xff), align=ui.TEXT_ALIGN_LEFT}))
        :setButtonLabelAlignment(display.CENTER_LEFT)
        :setButtonLabelOffset(26, -2)
        :align(display.LEFT_CENTER)

    local btn9 = cc.ui.UICheckBoxButton.new({off="#group_radio_normal.png", on="#group_radio_select.png"}, {scale9 = true})
        :setButtonLabel(ui.newTTFLabel({text=bm.LangUtil.getText("GROUP","CROOMPOPNUM9"), size=24, color=cc.c3b(0xdc, 0xdc, 0xff), align=ui.TEXT_ALIGN_LEFT}))
        :setButtonLabelAlignment(display.CENTER_LEFT)
        :setButtonLabelOffset(26, -2)
        :align(display.LEFT_CENTER)

    self.memberBtnGroup_:addButton(btn5)
    self.memberBtnGroup_:addButton(btn9)

    local size5 = btn5:getCascadeBoundingBox()
    local size9 = btn9:getCascadeBoundingBox()

    self.memberBtnGroup_:addTo(node)
        :pos(220, y - 20)

    local distance = (width-220-size5.width-size9.width)/2
    self.memberBtnGroup_:setButtonsLayoutMargin(0, distance, 0, 0)

    -- 处理初始化默认选择
    local btn = self.memberBtnGroup_:getButtonAtIndex(1)
    if btn then
        btn:setButtonSelected(true)
    end
    
    self.memberBtnGroup_:onButtonSelectChanged(function(event)
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
        self.tableType_ = event.selected
        self:dealRoomList()
    end)
end

--房间盲注
function GroupCreateRoomPopup:addRoomBlind_()
    local node = self.viewNode_
    local y = sy - itemHeight*3
    ui.newTTFLabel({
            text = bm.LangUtil.getText("GROUP","CROOMPOPBETWORD"),
            color = cc.c3b(0xa8, 0x9f, 0xe1), 
            size = 24,
            align = ui.TEXT_ALIGN_LEFT,
        })
        :align(display.LEFT_CENTER, 30, y)
        :addTo(node)

    self.baseLabel_ = ui.newTTFLabel({
            text = "0",
            size = 22, 
            color = cc.c3b(0xff, 0xd8, 0x00), 
        })

    local tempWidth = nil
    self.baseBtn_,tempWidth = self:createAddSubBtn(self.baseLabel_,1,1)

    self.baseBtn_:addTo(node)
        :pos(220 + tempWidth*0.5, y)
end

--设置密码
function GroupCreateRoomPopup:addRoomPassword_()
    local node = self.viewNode_
    local y = sy - itemHeight*4
    ui.newTTFLabel({
            text = bm.LangUtil.getText("GROUP","CROOMPOPPWD"),
            color = cc.c3b(0xa8, 0x9f, 0xe1), 
            size = 24,
            align = ui.TEXT_ALIGN_LEFT,
        })
        :align(display.LEFT_CENTER, 30, y)
        :addTo(node)

    self.passBtn_ = cc.ui.UICheckBoxButton.new({off="#group_radio_normal.png", on="#group_radio_select.png"})
        :setButtonLabel(ui.newTTFLabel({text=bm.LangUtil.getText("GROUP","CROOMPOPPWDNULL"), size=24, color=cc.c3b(0xdc, 0xdc, 0xff), align=ui.TEXT_ALIGN_LEFT}))
        :setButtonLabelAlignment(display.CENTER_LEFT)
        :setButtonLabelOffset(26, -2)
        :align(display.LEFT_CENTER, 220, y)
        :onButtonClicked(buttontHandler(self, function()
            if self.passBtn_:isButtonSelected() then
                self.passwordEdit_:setText("")
                self.editPreNick_ = nil
            end
        end))
        :addTo(node)

    local passSize = self.passBtn_:getCascadeBoundingBox()

    self.passwordEdit_ = ui.newEditBox({image = "#transparent.png", 
            listener = handler(self, self.onPasswordEdit_), 
            size = cc.size(180, 50),
            image = "#common_input_bg.png",
            imagePressed="#common_input_bg_down.png",
        })
        :pos(490, y)
        :addTo(node)

    self.passwordEdit_:setFont(ui.DEFAULT_TTF_FONT, 24)
    self.passwordEdit_:setPlaceholderFont(ui.DEFAULT_TTF_FONT, 22)
    self.passwordEdit_:setMaxLength(25)
    self.passwordEdit_:setAnchorPoint(cc.p(0, 0.5))
    self.passwordEdit_:setPlaceholderFontColor(cc.c3b(0x7a, 0x7e, 0xca))
    self.passwordEdit_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.passwordEdit_:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.passwordEdit_:setPlaceHolder(bm.LangUtil.getText("GROUP","CROOMPOPPWDNUM"))

    nk.EditBoxManager:addEditBox(self.passwordEdit_)

    self.passBtn_:setButtonSelected(true)
end

function GroupCreateRoomPopup:addCreateButton_()
    cc.ui.UIPushButton.new({normal = "#common_btn_yellow_normal.png", pressed = "#common_btn_yellow_pressed.png"},{scale9 = true})
        :setButtonSize(170, 55)
        :setButtonLabel(ui.newTTFLabel({text = bm.LangUtil.getText("GROUP","CROOMPOPCREATE"),size = 22,color = cc.c3b(0xff, 0xff, 0xff)}))
        :pos(0,-self.height_*0.5+45)
        :addTo(self)
        :onButtonClicked(buttontHandler(self, function(...)
            local sb = tonumber(self.baseLabel_:getString())
            local flag = 6  -- 专业场(黄金币)
            if self.betType_ == 2 then
                flag = 2  -- 专业场(游戏币)
            end
            
            local pc = 5
            if self.tableType_ == 2 then
                pc = 9
            end

            local psword = self.editPreNick_
            if psword=="" then
                psword = nil
            end

            local requestFun = function()
                self:setLoading(true)
                -- 检测变量
                bm.HttpService.CANCEL(self.groupCreateRoomId_)
                self.groupCreateRoomId_ = bm.HttpService.POST(
                    {
                        mod = "Group",
                        act = "createTable",
                        uid = nk.userData.uid,
                        group_id = self.group_id_,
                        sb = sb,
                        flag = flag,
                        pc = pc,
                        psword = psword,
                    },
                    function (data)
                        if self.this_ then
                            self:setLoading(false)
                            local retData = json.decode(data)
                            if retData and tonumber(retData.ret)==1 and retData.data and retData.data.tid then
                                if self.delegate_ and self.delegate_.enterGroupRoom then
                                    self.delegate_:enterGroupRoom(retData.data.room_id,retData.data.tid,psword)
                                end
                                self:hidePanel_()
                            else
                                if retData and tonumber(retData.ret)==-4 then
                                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","CROOMPOPERROR1"))
                                elseif retData and tonumber(retData.ret)==-5 then
                                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","CROOMPOPERROR2"))
                                elseif retData and tonumber(retData.ret)==-6 then
                                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","CROOMPOPERROR4"))
                                else
                                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","CROOMPOPERROR3"))
                                end
                            end
                        end
                    end,
                    function ()
                        if self.this_ then
                            self:setLoading(false)
                            nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","CROOMPOPERROR3"))
                        end
                    end
                )
            end

            if psword then
                if string.len(psword)==4 then
                    psword = tonumber(psword)
                    if not psword then
                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","CROOMPOPERROR4"))
                        return
                    end
                else
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","CROOMPOPERROR4"))
                    return
                end
                requestFun()
            else
                nk.ui.Dialog.new({
                    messageText = bm.LangUtil.getText("GROUP","CROOMPOPNOPASSTIPS"),
                    callback = function (type)
                        if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                            requestFun()
                        end
                    end
                }):show()
            end
        end))
end

--添加一个触摸层，级别为0，用于屏蔽输入框
function GroupCreateRoomPopup:addTouchLayer_(w, h, x, y)
    local node = display.newNode()
    node:setContentSize(cc.size(w, h))
    node:pos(x, y)
    node:addTo(self, 10)

    local rect = cc.rect(-w/2, -h/2, w, h)

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(function(touch, event)--(Touch* touch, Event* event)
        local pos = touch:getLocation()
        pos = node:convertToNodeSpace(pos)

        if not cc.rectContainsPoint(rect, pos) then
            self.passwordEdit_:setTouchEnabled(false)
            return true
        end

        return false
    end, cc.Handler.EVENT_TOUCH_BEGAN)

    listener:registerScriptHandler(function(touch, event)
        self.passwordEdit_:setTouchEnabled(true)
    end, cc.Handler.EVENT_TOUCH_ENDED)

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)
end

function GroupCreateRoomPopup:dealRoomList()
    local index = self.tableType_
    -- 房间JSON                                1普通 2专业   1,2,3:金币 4:黄金币      人数
    -- local preCalls = nk.userData.tableConf[self.roomType_][selectedTab][ChooseRoomView.PLAYER_LIMIT_SELECTED]
    local allList = nk.userData.tableConf[2]
    local baseList = allList[4][index]  -- 可以创建的场次,默认为黄金币，可以创建游戏币
    
    if self.betType_ == 2 then
        baseList = {}
        local itemList = nil
        for i = 1, 3 do
            if allList[i] and allList[i][index] then
                itemList = allList[i][index]
                table.insertto(baseList, itemList)
            end
        end
    end

    self.baseBtn_.index = self:getBlindIndex_(baseList)
    self.baseBtn_.list = baseList
    self.baseBtn_.resetBaseList(baseList)
end

--根据携带资产，设置默认底注
function GroupCreateRoomPopup:getBlindIndex_(baseList)
    local index = 1
    local blind
    if self.betType_ == 1 then
        blind = self:getGcoinBlind_()
    elseif self.betType_ == 2 then
        blind = self:getChipBlind_()
    end

    for i, v in ipairs(baseList) do
        if blind == v then
            index = i
            break
        end
    end

    return index
end

function GroupCreateRoomPopup:getGcoinBlind_()
    local blind = 1
    local gcoins = nk.userData.gcoins
    if gcoins >= 5000 then
        blind = 100
    elseif gcoins >= 1000 then
        blind = 50
    elseif gcoins >= 500 then
        blind = 10
    elseif gcoins >50 then
        blind = 5
    else
        blind = 1
    end

    return blind
end

function GroupCreateRoomPopup:getChipBlind_()
    local blind = 1
    local money = nk.userData.money
    if money > 100000000 then
        blind = 500000
    elseif money > 50000000 then
        blind = 300000
    elseif money > 10000000 then
        blind = 150000
    elseif money > 5000000 then
        blind = 99000
    elseif money > 1000000 then
        blind = 50000
    elseif money > 500000 then
        blind = 20000
    elseif money > 200000 then
        blind = 5000
    elseif money > 80000 then
        blind = 3000
    elseif money > 30000 then
        blind = 1000
    elseif money > 10000 then
        blind = 200
    else
        blind = 50
    end

    return blind
end

function GroupCreateRoomPopup:createAddSubBtn(label,step,min)
    local width = 220
    local node = display.newNode()
    node.list = {1,1}
    node.index = 1
    display.newScale9Sprite("#group_add_bg.png",0, 0, cc.size(width, 40))
        :addTo(node)

    node.subBtn = cc.ui.UIPushButton.new({normal = "#group_add_normal.png", pressed = "#group_add_down.png"},{scale9 = true})
        :pos(-width*0.5+19,0)
        :addTo(node)
        :onButtonClicked(buttontHandler(self, function()
            local cur = node.index - 1
            if cur<1 then 
                cur = 1 
            end

            node.index = cur
            label:setString(node.list[cur])
        end))

    node.addBtn = cc.ui.UIPushButton.new({normal = "#group_add_normal.png", pressed = "#group_add_down.png"},{scale9 = true})
        :pos(width*0.5-19,0)
        :addTo(node)
        :onButtonClicked(buttontHandler(self, function()
            local cur = node.index + 1
            if cur>#node.list then
                cur = #node.list
            end

            node.index = cur
            label:setString(node.list[cur])
        end))

    node.resetBaseList = function(list)
        local cur = node.index
        if cur>#list then
            cur = #list
        end

        label:setString(list[cur])
    end

    node.addBtn:setScaleX(-1)
    label:addTo(node)
    return node,width
end

function GroupCreateRoomPopup:onCleanup()
    nk.EditBoxManager:removeEditBox(self.passwordEdit_)
    bm.HttpService.CANCEL(self.groupCreateRoomId_)
end

function GroupCreateRoomPopup:show()
    self:showPanel_()
end

function GroupCreateRoomPopup:onPasswordEdit_(event)
    if event == "began" then
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
        self.passwordEdit_:setText(self.editPreNick_)
    elseif event == "changed" then
        local text = self.passwordEdit_:getText()
        local filteredText = text
        self.editNick_ = string.trim(filteredText)
        self.editPreNick_ = filteredText
    elseif event == "ended" then
        local text = self.passwordEdit_:getText()
        local filteredText = text

        self.passwordEdit_:setText(nk.Native:getFixedWidthText("",26,filteredText,190))

        if not self.editPreNick_ or self.editPreNick_=="" then
            self.passBtn_:setButtonSelected(true)
        else
            self.passBtn_:setButtonSelected(false)
        end
    elseif event == "return" then
        local text = self.passwordEdit_:getText()
        local filteredText = text

        self.passwordEdit_:setText(nk.Native:getFixedWidthText("",26,filteredText,190))

        if not self.editPreNick_ or self.editPreNick_=="" then
            self.passBtn_:setButtonSelected(true)
        else
            self.passBtn_:setButtonSelected(false)
        end
    end
end

function GroupCreateRoomPopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new():addTo(self)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

return GroupCreateRoomPopup