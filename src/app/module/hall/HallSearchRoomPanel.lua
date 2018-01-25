--
-- Author: Tom
-- Date: 2014-10-28 15:36:16
-- 搜索房间
local WIDTH = display.width
local HEIGHT = 140
local HallSearchRoomPanel = class("HallSearchRoomPanel", function() return display.newNode() end)
local logger = bm.Logger.new("HallSearchRoomPanel")

function HallSearchRoomPanel:ctor(controller_)
    self.controller_ = controller_
    self.background = display.newScale9Sprite("#search_room_background_icon.png", 0, 0, cc.size(WIDTH, HEIGHT))
    self.background:pos(display.cx, display.top - HEIGHT * 0.5)
    self.background:addTo(self)
    self.background:setTouchEnabled(true)
    self.background:setTouchSwallowEnabled(true)

    self.inputContentBackground = display.newScale9Sprite("#search_room_input_content_background_icon.png",0, 0, cc.size(WIDTH - 300, 62))
        :pos(display.cx - 60, display.top - HEIGHT * 0.5)
        :addTo(self)

    self.searIcon_ = display.newSprite("#search_room_icon.png")
        :pos(self.inputContentBackground:getPositionX() - self.inputContentBackground:getContentSize().width * 0.5 + 40   , display.top - HEIGHT * 0.5)
        :addTo(self)

    self.editRoomCode_ = ui.newEditBox({
        size = cc.size(WIDTH - 360, 62),
        align=ui.TEXT_ALIGN_CENTER - 30,
        image="#transparent.png",
        x = display.cx + 10,
        y = display.top - HEIGHT * 0.5,
        listener = handler(self, self.onCodeEdit_)
    })
    self.editRoomCode_:setFontName(ui.DEFAULT_TTF_FONT)
    self.editRoomCode_:setFontSize(30)
    self.editRoomCode_:setFontColor(cc.c3b(0x92, 0x8d, 0x8d))
    self.editRoomCode_:setPlaceholderFontName(ui.DEFAULT_TTF_FONT)
    self.editRoomCode_:setPlaceholderFontSize(30)
    self.editRoomCode_:setPlaceholderFontColor(cc.c3b(0x92, 0x8d, 0x8d))
    self.editRoomCode_:setPlaceHolder(bm.LangUtil.getText("HALL", "SEARCH_ROOM_INPUT_CORRECT_ROOM_NUMBER"))
    self.editRoomCode_:setReturnType(cc.KEYBOARD_RETURNTYPE_GO)
    self.editRoomCode_:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.editRoomCode_:addTo(self)

    -- 点击取消
    self.cancelButton_ = cc.ui.UIPushButton.new({normal = "#transparent.png"}, {scale9 = true})
        :setButtonLabel(ui.newTTFLabel({text=bm.LangUtil.getText("COMMON", "CANCEL"), size=30, color=cc.c3b(0xb2, 0xdc, 0xff), align=ui.TEXT_ALIGN_CENTER}))
        :onButtonClicked(handler(self,self.hidePanel))
        :pos(self.inputContentBackground:getPositionX() + self.inputContentBackground:getContentSize().width *0.5 + 80 , display.top - HEIGHT * 0.5)
        :addTo(self)

end

function HallSearchRoomPanel:onCodeEdit_(event)
    logger:debug("onCodeEdit_ " .. event)
    if event == "began" then
    elseif event == "changed" then
        self.codeEdit_ = self.editRoomCode_:getText()
    elseif event == "ended" then
    elseif event == "return" then
        self:requestEnterRoom()
        self:hidePanel()
    end
end

function HallSearchRoomPanel:requestEnterRoom()

    if self.codeEdit_ and string.len(string.trim(self.codeEdit_)) == 0 then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL", "SEARCH_ROOM_INPUT_ROOM_NUMBER_EMPTY"))
        return
    end

    if self.codeEdit_ and (string.len(string.trim(self.codeEdit_)) >=5  and string.len(string.trim(self.codeEdit_)) <= 8) then
        self.requestId_ = bm.HttpService.POST({mod="table", act="searchRoom", tid = string.trim(self.codeEdit_)},
        function(data) 
            self.requestId_ = nil
            local callData = json.decode(data)
            if callData then
                if callData.ret ~= nil and callData.ret == 0 then
                    bm.EventCenter:dispatchEvent({name = nk.eventNames.ENTER_ROOM_WITH_DATA, data = {
                        ip = callData.tabInfo.ip,
                        port = callData.tabInfo.port,
                        tid = callData.tabInfo.tid,
                        dice = callData.tabInfo.dice or 0,
                        isPlayNow = false,
                        tableFlag = callData.tabInfo.tableFlag,
                        tableType = callData.tabInfo.tableType
                    },isTrace = true})
                else
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL", "SEARCH_ROOM_INPUT_ROOM_NUMBER_ERROR"))
                end
            end
        end, function()
             nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"))
        end)
    else
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL", "SEARCH_ROOM_NUMBER_IS_WRONG"))
    end
end


function HallSearchRoomPanel:showPanel()
    nk.PopupManager:addPopup(self, true, false, true, false)
end

function HallSearchRoomPanel:hidePanel()
    nk.PopupManager:removePopup(self)
end

function HallSearchRoomPanel:onRemovePopup(removeFunc)
    self:stopAllActions()
    transition.moveTo(self, {time=0.3, y = display.top + HEIGHT * 0.5, easing="OUT", onComplete=function() 
        removeFunc()
    end})
end

return HallSearchRoomPanel