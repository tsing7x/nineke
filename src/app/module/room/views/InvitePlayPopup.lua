--
-- Author: KevinYu
-- Date: 2017-01-18 14:19:21
-- 邀请玩牌，玩家列表弹窗

local InvitePlayPopup = class("InvitePlayPopup", nk.ui.Panel)
local InvitePlayListItem = import("app.module.room.views.InvitePlayListItem")

local POPUP_WIDTH, POPUP_HEIGHT = 650, 440
local EDIT_BOX_FONT_COLOR = cc.c3b(0x4d, 0x4d, 0x4d)
local friendDataGlobal = {}

function InvitePlayPopup:ctor(roomInfo, data)
	InvitePlayPopup.super.ctor(self, {POPUP_WIDTH, POPUP_HEIGHT})

    self:setNodeEventEnabled(true)
	self.data_ = data
    self.roomInfo_ = roomInfo
	self:addCloseBtn()
	self:setCloseBtnOffset(5, 0)

	ui.newTTFLabel({text = bm.LangUtil.getText("GROUP","ROOM_INVITE_TITLE"), size = 26})
        :pos(0, POPUP_HEIGHT/2 - 38)
        :addTo(self)

    self:addSearchNode_()

    self:addListView_(data)

    self.inviteListenerId_ = bm.EventCenter:addEventListener("ROOM_INVITE_PLAY", handler(self, self.sendInvitePlay_))
end

function InvitePlayPopup:addSearchNode_()
	local sx, sy = -POPUP_WIDTH/2 + 25, POPUP_HEIGHT/2 - 100
	ui.newTTFLabel({text = bm.LangUtil.getText("GROUP","ROOM_INVITE_TEXT"), size = 22})
        :align(display.LEFT_CENTER, sx, sy)
        :addTo(self)

    local input_w, input_h = 290, 46
    self.editBox_ = ui.newEditBox({
        image = "#common_input_bg.png",
        imagePressed = "#common_input_bg_down.png",
        size = cc.size(input_w, input_h),
        listener = handler(self, self.onSearchEdit_)
    }):align(display.RIGHT_CENTER, POPUP_WIDTH/2 - 140, sy)
    self.editBox_:setFontName(ui.DEFAULT_TTF_FONT)
    self.editBox_:setFontSize(32)
    self.editBox_:setFontColor(EDIT_BOX_FONT_COLOR)
    self.editBox_:setPlaceholderFontName(ui.DEFAULT_TTF_FONT)
    self.editBox_:setPlaceholderFontSize(25)
    self.editBox_:setPlaceholderFontColor(cc.c3b(0xb7, 0xc8, 0xd4))
    self.editBox_:setPlaceHolder(bm.LangUtil.getText("GROUP","ROOM_INVITE_HOLDER"))
    self.editBox_:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.editBox_:setReturnType(cc.KEYBOARD_RETURNTYPE_SEARCH)
    self.editBox_:addTo(self)

    cc.ui.UIPushButton.new({normal="#common_btn_blue_normal.png", pressed="#common_btn_blue_pressed.png"}, {scale9 = true})
    	:setButtonSize(100, 52)
        :setButtonLabel(cc.ui.UILabel.new({text = bm.LangUtil.getText("GROUP","ROOM_INVITE_SEARCH"), size = 22}))
        :pos(POPUP_WIDTH/2 - 80, sy)
        :onButtonClicked(buttontHandler(self, self.onSearchClicked_))
        :addTo(self)
end

function InvitePlayPopup:addListView_(data)
	local frame_w, frame_h = 615, 280
	local frame = display.newScale9Sprite("#panel_overlay.png", 0, 0, cc.size(frame_w, frame_h))
        :align(display.BOTTOM_CENTER, 0, -POPUP_HEIGHT/2 + 25)
        :addTo(self)

    local list_w, list_h = frame_w - 10, frame_h - 10
    self.list_ = bm.ui.ListView.new(
            {
                viewRect = cc.rect(-list_w/2, -list_h/2, list_w, list_h),
            }, 
            InvitePlayListItem
        )
        :pos(frame_w/2, frame_h/2)
        :addTo(frame)

    self.list_:setData(data)
end

function InvitePlayPopup:onSearchEdit_(evt, editbox)
    local text = editbox:getText()
    if evt == "began" then
    elseif evt == "ended" then
    elseif evt == "return" then
        self:onSearchClicked_()
    elseif evt == "changed" then
        self.searchStr_ = text
        editbox:setText(text)
    end
end

function InvitePlayPopup:onSearchClicked_()
	if self.searchStr_ ~= nil then
		self:filterData_(self.searchStr_)
	end
end

function InvitePlayPopup:filterData_(searchStr)
	if searchStr ~= "" then
        local data = {}
        for k, v in pairs(self.data_) do
            if tostring(v.uid) == searchStr then
                table.insert(data, v)
                break
            end
        end

        self.list_:setData(data)
        if #data == 0 then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","ROOM_INVITE_SEARCH_ERR"))
        end
        
    else
    	self.list_:setData(self.data_)
    end
end

function InvitePlayPopup:sendInvitePlay_(evt)
    local roomInfo = self.roomInfo_
    bm.HttpService.POST({
        mod = "Group",
        act = "invitePlay", 
        invite_uid = tonumber(evt.uid),
        sb = roomInfo.blind,
        tid = roomInfo.tid,
        flag = roomInfo.roomType,
        group_id = nk.userData.groupId
        },
        function(data)
            local jsonData = json.decode(data)
            if jsonData.ret == 1 then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","INVITE_SUCC"))
            elseif jsonData.ret == -4 then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","INVITE_ERROR"))
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","INVITE_FAIL"))
            end
        end)
end

function InvitePlayPopup:show()
    self:showPanel_()
end

function InvitePlayPopup:onShowed()
    if self.list_ then
        self.list_:setScrollContentTouchRect()
    end
end

function InvitePlayPopup:onCleanup()
    bm.EventCenter:removeEventListener(self.inviteListenerId_)
end

return InvitePlayPopup