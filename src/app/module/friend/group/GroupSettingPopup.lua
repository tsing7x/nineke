local GroupSettingPopup = class("GroupSettingPopup", nk.ui.Panel)

local logger = bm.Logger.new("GroupSettingPopup")

local PANEL_W, PANEL_H = 750, 480
local SCROLL_VIEW_W, SCROLL_VIEW_H = PANEL_W - 45, PANEL_H - 160 --滚动视图宽高
local LEFT_X = -(SCROLL_VIEW_W - 35)/2--视图内容结点，左边X
local FRAME_W = SCROLL_VIEW_W - 5 --底框宽度

function GroupSettingPopup:ctor(groupid,groupInfoBase)
	GroupSettingPopup.super.ctor(self, {PANEL_W, PANEL_H})
    self.groupid_ = groupid
    self.groupInfoBase_ = groupInfoBase
    self.this_ = self
	self:setNodeEventEnabled(true)
	self:addTitle(bm.LangUtil.getText("GROUP","SETPOPTITLE"),5)
    self.title_:setTextColor(cc.c3b(0xff,0xff,0xff))
    self.title_:setSystemFontSize(28)
    self:addCloseBtn()
end

function GroupSettingPopup:onCleanup()
    bm.HttpService.CANCEL(self.groupSaveId_)
end

function GroupSettingPopup:show()
    self:showPanel_()
end

function GroupSettingPopup:onShowed()
    local scrollNode = display.newNode()
    self.mainNode_ = display.newNode():addTo(scrollNode)

    self:addIntroductionInfo_()

    self:addJoinCondition_()

    self:addJoinMode_()

	-- 矩形滑动区域
	local w, h = SCROLL_VIEW_W, SCROLL_VIEW_H
	local scrollViewRect = cc.rect(-w/2, -h/2, w, h)
    self.scrollView_ = bm.ui.ScrollView.new({
        viewRect      = scrollViewRect,
        scrollContent = scrollNode,
        direction     = bm.ui.ScrollView.DIRECTION_VERTICAL,
    })
    :pos(0, 10)
    :addTo(self)

    local size = self.mainNode_:getCascadeBoundingBox()
    self.mainNode_:pos(0, size.height/2)

    self:addTouchLayer_(0, 10)

    self:addSaveButton_()
    
    -- 设置数据
    self.initLevel_ = tonumber(self.groupInfoBase_.level)
    self.initMoney_ = tonumber(self.groupInfoBase_.money)
    self.initCheck_ = tonumber(self.groupInfoBase_.is_check)
    self.initDes_ = self.groupInfoBase_.description

    self.levelLabel_:setString(self.initLevel_)
    self.propertyLabel_:setString(self.initMoney_)
    self.introductionInfo_:setString(self.initDes_)

    self.levelLabelPreStr_ = self.levelLabel_:getString()
    self.propertyLabelPreStr_ = self.propertyLabel_:getString()

    if self.initCheck_==0 then
        local btn = self.checkBtnGroup_:getButtonAtIndex(2)
        if btn then
            btn:setButtonSelected(true)
        end
    else
        local btn = self.checkBtnGroup_:getButtonAtIndex(1)
        if btn then
            btn:setButtonSelected(true)
        end
    end

    -- 处理初始化默认选择
    if self.initLevel_==0 and self.initMoney_==0 then
        self.allowInBtn_:setButtonSelected(true)
    end

    -- 这里的声音好坑
    self.checkBtnGroup_:onButtonSelectChanged(function(event)
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    end)
end

--群简介
function GroupSettingPopup:addIntroductionInfo_()
    local mainNode = self.mainNode_
    local sy = 0

    ui.newTTFLabel({
        size = 22, 
        color = cc.c3b(0xa8, 0x9f, 0xe1), 
        align = ui.TEXT_ALIGN_LEFT,
        text = bm.LangUtil.getText("GROUP", "INTRODUCTION_TITLE")
    })
    :align(display.TOP_LEFT, LEFT_X, sy)
    :addTo(mainNode)

    local w, h = FRAME_W, 80
    local frame = display.newScale9Sprite("#panel_overlay.png",0, 0, cc.size(w, h))
        :align(display.TOP_CENTER, 0, sy - 30)
        :addTo(mainNode)

    local inputWidth, inputHeight = w - 20, h - 20
    self.introductionEditBox_ = ui.newEditBox({
        size = cc.size(inputWidth, inputHeight),
        image="#transparent.png",
        listener = handler(self, self.onIntroductionInfoEdit_)
    }):pos(w/2, h/2):addTo(frame)

    local editBox_ = self.introductionEditBox_
    editBox_:setFontName(ui.DEFAULT_TTF_FONT)
    editBox_:setFontSize(22)
    editBox_:setMaxLength(50)
    editBox_:setPlaceholderFontName(ui.DEFAULT_TTF_FONT)
    editBox_:setPlaceholderFontSize(22)
    editBox_:setPlaceholderFontColor(cc.c3b(0xEE, 0xEE, 0xEE))
    editBox_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    editBox_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)

    self.introductionHint_ = bm.LangUtil.getText("GROUP", "INTRODUCTION_HINT", 50)
    self.introductionInfo_ = ui.newTTFLabel({
            text = "",
            size = 20,
            align = ui.TEXT_ALIGN_LEFT,
            valign = ui.TEXT_VALIGN_TOP,
            dimensions = cc.size(inputWidth, inputHeight)
        })
        :pos(w/2, h/2)
        :addTo(frame)
    self.introductionInfo_:setString(self.introductionHint_)
end

--设置加群条件
function GroupSettingPopup:addJoinCondition_()
    local sx, sy = LEFT_X, -130

    self.label1_ = ui.newTTFLabel({
        size = 22, 
        color = cc.c3b(0xa8, 0x9f, 0xe1), 
        align = ui.TEXT_ALIGN_LEFT,
        text = bm.LangUtil.getText("GROUP","SETPOPCONDITION")
    })
    :align(display.TOP_LEFT, sx, sy)
    :addTo(self.mainNode_)

    local w, h = FRAME_W, 75
    local node = display.newScale9Sprite("#panel_overlay.png",0, 0, cc.size(w, h))
        :align(display.TOP_CENTER, 0, sy - 30)
        :addTo(self.mainNode_)

    self.allowInBtn_ = cc.ui.UICheckBoxButton.new({off="#group_radio_normal.png", on="#group_radio_select.png"})
        :setButtonLabel(ui.newTTFLabel({text=bm.LangUtil.getText("GROUP","SETPOPALLOWALL"), size=24, color=cc.c3b(0xdc, 0xdc, 0xff), align=ui.TEXT_ALIGN_LEFT}))
        :setButtonLabelAlignment(display.CENTER_LEFT)
        :setButtonLabelOffset(26, -2)
        :align(display.LEFT_CENTER, 35, h/2)
        :onButtonClicked(buttontHandler(self, function()
            if self.allowInBtn_:isButtonSelected() then
                self.levelLabel_:setString(0)
                self.propertyLabel_:setString(0)
            else
                self.levelLabel_:setString(self.levelLabelPreStr_)
                self.propertyLabel_:setString(self.propertyLabelPreStr_)
            end
        end))
        :addTo(node)

    local node = display.newScale9Sprite("#panel_overlay.png",0, 0, cc.size(w, h))
        :align(display.TOP_CENTER, 0, sy - 110)
        :addTo(self.mainNode_)

    local label = ui.newTTFLabel({
        text = bm.LangUtil.getText("GROUP","SETPOPLEVEL"),
        size = 22, 
        color = cc.c3b(0xdc, 0xdc, 0xff), 
        align = ui.TEXT_ALIGN_LEFT,
    })
    :align(display.CENTER_LEFT, 35, h/2)
    :addTo(node)

    local size = label:getContentSize()

    local levelBtn
    levelBtn, self.levelLabel_ = self:createMoneyLimit_(cc.c3b(0x84, 0xfe, 0x84), handler(self, self.onLevelEdit_))
    levelBtn:pos(140 + size.width, h/2)
    levelBtn:addTo(node)

    local label = ui.newTTFLabel({
        text = bm.LangUtil.getText("GROUP","SETPOPPROPERTY"),
        size = 22, 
        color = cc.c3b(0xdc, 0xdc, 0xff), 
        align = ui.TEXT_ALIGN_LEFT,
    })
    :align(display.CENTER_LEFT, w/2 + 35, h/2)
    :addTo(node)

    local size = label:getContentSize()

    local propertyBtn
    propertyBtn, self.propertyLabel_ = self:createMoneyLimit_(cc.c3b(0xff, 0xd8, 0x00), handler(self, self.onPropertyEdit_))
    propertyBtn:pos(w/2 + 140 + size.width, h/2)
    propertyBtn:addTo(node)

    local width__ = (w/2 + 140 + size.width + 80) - w
    if width__ > 0 then
        local x = label:getPositionX()
        local offx = width__ + 20
        label:setPositionX(x - offx)
        x = propertyBtn:getPositionX()
        propertyBtn:setPositionX(x - offx)
    end
end

function GroupSettingPopup:createMoneyLimit_(color, callback)
    local node = display.newNode()
    display.newScale9Sprite("#group_add_bg.png",0, 0, cc.size(160, 40))
        :addTo(node)

    local editbox = ui.newEditBox({
        size = cc.size(110, 40),
        image = "#transparent.png",
        align = ui.TEXT_ALIGN_CENTER,
        listener = callback
    }):align(display.CENTER):addTo(node)

    editbox:setFontName(ui.DEFAULT_TTF_FONT)
    editbox:setFontSize(22)
    editbox:setFontColor(color)
    editbox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    editbox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)

    local label = ui.newTTFLabel({
        text = "",
        size = 22, 
        color = color, 
     }):addTo(node)

    return node, label 
end

--加人模式
function GroupSettingPopup:addJoinMode_()
    local sx, sy = LEFT_X, -330

    ui.newTTFLabel({
        size = 22, 
        color = cc.c3b(0xa8, 0x9f, 0xe1), 
        align = ui.TEXT_ALIGN_LEFT,
        text = bm.LangUtil.getText("GROUP","SETPOPREVIEW")
    })
    :align(display.TOP_LEFT, sx, sy)
    :addTo(self.mainNode_)

    local w, h = FRAME_W, 75
    local node = display.newScale9Sprite("#panel_overlay.png",0, 0, cc.size(w, h))
        :align(display.TOP_CENTER, 0, sy - 30)
        :addTo(self.mainNode_)

    self.checkBtnGroup_ = cc.ui.UICheckBoxButtonGroup.new()
    local btn1 = cc.ui.UICheckBoxButton.new({off="#group_radio_normal.png", on="#group_radio_select.png"}, {scale9 = true})
        :setButtonLabel(ui.newTTFLabel({text=bm.LangUtil.getText("GROUP","SETPOPAUTOIN"), size=24, color=cc.c3b(0xdc, 0xdc, 0xff), align=ui.TEXT_ALIGN_LEFT}))
        :setButtonLabelAlignment(display.CENTER_LEFT)
        :setButtonLabelOffset(26, -2)
        :align(display.LEFT_CENTER)
    self.checkBtnGroup_:addButton(btn1)

    local btn2 = cc.ui.UICheckBoxButton.new({off="#group_radio_normal.png", on="#group_radio_select.png"}, {scale9 = true})
            :setButtonLabel(ui.newTTFLabel({text=bm.LangUtil.getText("GROUP","SETPOPREVIEWIN"), size=24, color=cc.c3b(0xdc, 0xdc, 0xff), align=ui.TEXT_ALIGN_LEFT}))
            :setButtonLabelAlignment(display.CENTER_LEFT)
            :setButtonLabelOffset(26, -2)
            :align(display.LEFT_CENTER)
    self.checkBtnGroup_:addButton(btn2)

    local size1 = btn1:getCascadeBoundingBox()
    local size2 = btn2:getCascadeBoundingBox()

    local distance = (w - 35 - size1.width - size2.width)/2

    self.checkBtnGroup_:addTo(node):pos(35, h/2 - 20)
    self.checkBtnGroup_:setButtonsLayoutMargin(0, distance, 0, 0)
end

--添加一个触摸层，级别为0，用于屏蔽输入框
function GroupSettingPopup:addTouchLayer_(x, y)
    local w, h = SCROLL_VIEW_W, SCROLL_VIEW_H

    local node = display.newNode()
    node:setContentSize(cc.size(w, h))
    node:pos(x, y)
    node:addTo(self, 10)

    local rect = cc.rect(-w/2, -h/2, w, h)

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(function(touch, event)
        local pos = touch:getLocation()
        pos = node:convertToNodeSpace(pos)

        if not cc.rectContainsPoint(rect, pos) then
            self.introductionEditBox_:setTouchEnabled(false)
            return true
        end

        return false
    end, cc.Handler.EVENT_TOUCH_BEGAN)

    listener:registerScriptHandler(function(touch, event)
        self.introductionEditBox_:setTouchEnabled(true)
    end, cc.Handler.EVENT_TOUCH_ENDED)

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)
end

-- 底部保存按钮
function GroupSettingPopup:addSaveButton_()
    local width, height = self.width_ - 80, self.height_ - 130
    
    cc.ui.UIPushButton.new({normal = "#common_btn_yellow_normal.png", pressed = "#common_btn_yellow_pressed.png"},{scale9 = true})
        :setButtonSize(150, 55)
        :setButtonLabel(ui.newTTFLabel({text = bm.LangUtil.getText("GROUP","SETPOPCONFIRM"),size = 22,color = cc.c3b(0xff, 0xff, 0xff)}))
        :align(display.TOP_CENTER, 0, -height*0.5 + 15)
        :addTo(self)
        :onButtonClicked(buttontHandler(self, function()
            local curLevel = tonumber(self.levelLabel_:getString())
            local curtMoney = tonumber(self.propertyLabel_:getString())
            local des = self.introductionInfo_:getString()
            local curCheck = 0

            if self.checkBtnGroup_.currentSelectedIndex_==1 then
                curCheck = 1
            end

            -- 没更改
            if self.initLevel_ == curLevel and
               self.initMoney_ == curtMoney and
               self.initCheck_ == curCheck and
               self.initDes_ == des then
                return
            end

            self:setLoading(true)
            self.groupSaveId_ = bm.HttpService.POST(
                {
                    mod = "Group",
                    act = "updateGroupConfig",
                    group_id = self.groupid_,
                    uid = nk.userData.uid,
                    group_name = self.groupInfoBase_.group_name,  -- 设置群名字
                    image_url = self.groupInfoBase_.image_url,  -- 设置群头像
                    level = curLevel,      -- 入群等级限制
                    money = curtMoney,    -- 入群金币限制(改成黄金币)
                    is_check = curCheck,   -- 是否需要审核 0： 需要   1：不需要
                    description = des, --群简介
                },
                function (data)
                    if self.this_ then
                        local retData = json.decode(data)
                        if retData and retData.ret==1 and retData.data then
                            for k,v in pairs(retData.data) do
                                self.groupInfoBase_[k] = v
                            end

                            self.initLevel_ = tonumber(self.groupInfoBase_.level)
                            self.initMoney_ = tonumber(self.groupInfoBase_.money)
                            self.initCheck_ = tonumber(self.groupInfoBase_.is_check)
                            self.initDes_ = self.groupInfoBase_.description

                            nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","SETPOPSETSUCC"))
                        else
                            nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","SETPOPSETFAIL"))
                        end
                        self:setLoading(false)
                    end
                end,
                function ()
                    if self.this_ then
                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","SETPOPSETFAIL"))
                        self:setLoading(false)
                    end
                end)
        end))
end

function GroupSettingPopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
                :addTo(self)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

function GroupSettingPopup:onLevelEdit_(event, editbox)
    if event == "began" then
        local text = self.levelLabel_:getString()
        editbox:setText(text)
        self.levelLabel_:setString("")
    elseif event == "changed" then
    elseif event == "ended" then
    elseif event == "return" then
        local str = editbox:getText()
        editbox:setText("")
        
        local inputNum = self:checkInputNumber_(str)
        if not inputNum then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","SETPOPONLYNUM"))
            self.levelLabel_:setString(self.levelLabelPreStr_)
        else
            if inputNum > 30 then
                inputNum = 30
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","SETPOPLEVEL30"))
            end

            self.levelLabelPreStr_ = inputNum
            self.levelLabel_:setString(inputNum)

            if inputNum > 0 then
                self.allowInBtn_:setButtonSelected(false)
            elseif tonumber(self.propertyLabelPreStr_) and tonumber(self.propertyLabelPreStr_)==0 then
                self.allowInBtn_:setButtonSelected(true)
            end
        end
    end
end

function GroupSettingPopup:onPropertyEdit_(event, editbox)
    if event == "began" then
        local text = self.propertyLabel_:getString()
        editbox:setText(text)
        self.propertyLabel_:setString("")
    elseif event == "changed" then
    elseif event == "ended" then
    elseif event == "return" then
        local str = editbox:getText()
        editbox:setText("")

        local inputNum = self:checkInputNumber_(str)
        if not inputNum then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","SETPOPONLYNUM"))
            self.propertyLabel_:setString(self.propertyLabelPreStr_)
        else
            if inputNum > 1000000000 then
                inputNum = 1000000000
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","SETPOPROPERTY10Y"))
            end

            self.propertyLabelPreStr_ = inputNum
            self.propertyLabel_:setString(inputNum)

            if inputNum > 0 then
                self.allowInBtn_:setButtonSelected(false)
            elseif tonumber(self.levelLabelPreStr_) and tonumber(self.levelLabelPreStr_)==0 then
                self.allowInBtn_:setButtonSelected(true)
            end
        end
    end
end

--检测输入的是否为数字
function GroupSettingPopup:checkInputNumber_(str)
    local p1 = "^%d*$" --检测是否为数字
    local p2 = "0*(%d*)" --去掉前导0
    if string.find(str, p1) then
        local num = string.match(str, p2)
        if num == "" then --全部为0
            num = "0"
        end

        return tonumber(num)
    else
        return nil
    end
end

function GroupSettingPopup:onIntroductionInfoEdit_(event, editbox)
    if event == "began" then
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
        local displayingText = self.introductionInfo_:getString()
        if displayingText == self.introductionHint_ then
            editbox:setText("")
        else
            editbox:setText(displayingText)
        end
        self.introductionInfo_:setString("")
    elseif event == "changed" then
    elseif event == "ended" then
    elseif event == "return" then
        local text = editbox:getText()
        if text == "" then 
            text = bm.LangUtil.getText("GROUP", "INTRODUCTION_HINT")
        end
        local filteredText = nk.keyWordFilter(text)
        self.introductionInfo_:setString(filteredText)
        editbox:setText("")
    end
end

return GroupSettingPopup