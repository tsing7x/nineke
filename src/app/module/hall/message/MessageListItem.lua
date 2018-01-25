--列表元素
local MessageListItem = class("MessageListItem", bm.ui.ListItem)

local logger = bm.Logger.new("MessageListItem")

local CONTENT_COLOR = cc.c3b(0xC7, 0xE5, 0xFF)
local CONTENT_COLOR_READED = cc.c3b(0xaa, 0xaa, 0xaa)

local AVATAR_SIZE = 50
local ERR_CODE_OVER_TIMES = -6

function MessageListItem:ctor()
    self:setNodeEventEnabled(true)
    MessageListItem.super.ctor(self, 750, 86)

    display.newScale9Sprite("#pop_common_listitem_bg.png", self.width_ * 0.5, self.height_ * 0.5, cc.size(self.width_, 82), cc.rect(45, 40, 1, 1))
        :addTo(self)

    local posY = self.height_ * 0.5

    -- pic
    self.img_ = display.newSprite("#common_male_avatar.png")
        :pos(50, posY)
        :scale(AVATAR_SIZE / 100)
        :addTo(self)
    self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id

    self.content = ui.newTTFLabel({
            text = "",
            color = CONTENT_COLOR,
            size = 24,
            align = ui.TEXT_ALIGN_LEFT,
            dimensions = cc.size(480, 80)
        })
        :align(display.LEFT_CENTER, 90, posY)
        :addTo(self)

    local buttonWidth = 165
    local buttonPosX = self.width_ - buttonWidth/2
    local buttonHeight = 55

    -- 领取奖励
    self.getRewardButton = cc.ui.UIPushButton.new({normal = "#common_btn_yellow_normal.png", pressed = "#common_btn_yellow_pressed.png", disabled = "#common_btn_disabled.png"},{scale9 = true})
        :setButtonSize(buttonWidth, buttonHeight)
        :onButtonClicked(handler(self, self.onGetReward))
        :setButtonLabel(ui.newTTFLabel({text = bm.LangUtil.getText("COMMON", "GET_REWARD"), color = cc.c3b(0xEF, 0xEF, 0xEF), size = 26, align = ui.TEXT_ALIGN_CENTER}))
        :pos(buttonPosX - 10, posY)
        :addTo(self)
        :hide()

    -- 删除按钮
    self.delButton = cc.ui.UIPushButton.new({normal = "#pop_messagecenter_delete.png", pressed = "#pop_messagecenter_delete_pressed.png"})
        :onButtonClicked(handler(self, self.onDelete))
        :pos(buttonPosX, posY)
        :addTo(self)

    -- 同意，拒绝
    self.agreeButton = cc.ui.UIPushButton.new({normal = "#common_btn_green_normal.png", pressed = "#common_btn_green_pressed.png", disabled = "#common_btn_disabled.png"},{scale9 = true})
        :setButtonSize(buttonWidth/2, buttonHeight)
        :onButtonClicked(handler(self, self.onAgreeClick))
        :setButtonLabel(ui.newTTFLabel({text = bm.LangUtil.getText("GROUP","CHECKPOPAGREE"), color = cc.c3b(0xEF, 0xEF, 0xEF), size = 26, align = ui.TEXT_ALIGN_CENTER}))
        :pos(buttonPosX - 20-buttonWidth/3, posY)
        :addTo(self)

    self.refuseButton = cc.ui.UIPushButton.new({normal = "#common_btn_yellow_normal.png", pressed = "#common_btn_yellow_pressed.png", disabled = "#common_btn_disabled.png"},{scale9 = true})
        :setButtonSize(buttonWidth/2, buttonHeight)
        :onButtonClicked(handler(self, self.onRefuseClick))
        :setButtonLabel(ui.newTTFLabel({text = bm.LangUtil.getText("GROUP","CHECKPOPREFUSE"), color = cc.c3b(0xEF, 0xEF, 0xEF), size = 26, align = ui.TEXT_ALIGN_CENTER}))
        :pos(buttonPosX - 20+buttonWidth/3, posY)
        :addTo(self)


    self:setTouchEnabled(true)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onClick))
    self:setTouchSwallowEnabled(false)
end

function MessageListItem:onAgreeClick()
    local list = self:getOwner()
    local data = list:getData()
    local itemData = data[self:getIndex()]

    local btntype = tonumber(itemData.btntype)
    if btntype == 4 then
        self:onAgreeJoinGroup_(itemData)
    elseif btntype == 5 then
        self:onAgreePlayCard_(itemData)
    end

    list.onListItemChangedListener()
    table.remove(data, self:getIndex())
    list:setData(nil)
    list:setData(data)
end

--同意加入群
function MessageListItem:onAgreeJoinGroup_(itemData)
    nk.userData.groupConfig = nil
    
    bm.HttpService.POST(
        { 
            mod = "Group",
            act = "acceptInvite",
            uid = nk.userData.uid,
            type = 1,
            extend_col = itemData.extend_col,
            msg_id = itemData.id
        }, 
        function (data) 
            local retData = json.decode(data)
            if retData and retData.ret==1 then
                -- 群主和群组成员邀请提示不一样
                if retData.data and retData.data.status==1 then
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","INVITPOPRESULT3"))
                else
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","INVITPOPRESULT1"))
                end
            elseif retData and tonumber(retData.ret)==-4 then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","INVITPOPRESULT2"))
            elseif retData and tonumber(retData.ret)==-3 then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","INVITPOPRESULT1"))
            end
        end
    )
end

--同意玩牌邀请
function MessageListItem:onAgreePlayCard_(itemData)
    bm.HttpService.POST(
        { 
            mod = "Group",
            act = "delInviteMsg",
            msg_id = itemData.id
        }
    )

    local info = json.decode(itemData.extend_col)
    local roomData = {
        ip = info.ip,
        port = info.port,
        tid = info.tid,
        isPlayNow = false,
        psword = info.password,
    }
                    
    nk.userData.groupId = info.group_id
    bm.EventCenter:dispatchEvent({name = nk.eventNames.ENTER_ROOM_WITH_DATA, data = roomData, isTrace = false})
end

function MessageListItem:onRefuseClick()
    local list = self:getOwner()
    local data = list:getData()
    local itemData = data[self:getIndex()]

    local btntype = tonumber(itemData.btntype)
    if btntype == 4 then
        self:onRefuseJoinGroup_(itemData)
    elseif btntype == 5 then
        self:onRefusePlayCard_(itemData)
    end

    list.onListItemChangedListener()
    table.remove(data, self:getIndex())
    list:setData(nil)
    list:setData(data)
end

--拒绝加入群
function MessageListItem:onRefuseJoinGroup_(itemData)
    bm.HttpService.POST(
        { 
            mod = "Group",
            act = "acceptInvite",
            uid = nk.userData.uid,
            type = 0,
            extend_col = itemData.extend_col,
            msg_id = itemData.id
        }
    )
end

--拒绝玩牌邀请
function MessageListItem:onRefusePlayCard_(itemData)
    bm.HttpService.POST(
        { 
            mod = "Group",
            act = "delInviteMsg",
            msg_id = itemData.id
        }
    )
end

function MessageListItem:onClick()
    local list = self:getOwner()
    local data = list:getData()
    local itemData = data[self:getIndex()]
    self.content:setString(itemData.content)
    self.content:setTextColor(CONTENT_COLOR_READED)

    bm.HttpService.POST({ mod = "Usernews" , act = "read", newsid = itemData.id})
end

function MessageListItem:onDelete()
    local list = self:getOwner()
    local data = list:getData()
    local itemData = data[self:getIndex()]
    table.remove(data, self:getIndex())
    list:setData(nil)
    list:setData(data)

    bm.HttpService.POST({ mod = "Usernews", act = "delNews", newsid = itemData.id})
end

function MessageListItem:onGetReward()
    local list = self:getOwner()
    local data = list:getData()
    local itemData = data[self:getIndex()]

    bm.HttpService.POST({
        mod = "Usernews",
        act = "userReward",
        newsid = itemData.id}, 
        handler(self, self.onGetRewardData))
end

function MessageListItem:onGetRewardData(data)
    local list = self:getOwner()
    local data1 = list:getData()
    local itemData = data1[self:getIndex()]
    itemData.btntype = 1

    if list.onListItemChangedListener then
        local jsonData = json.decode(data)
        if jsonData and jsonData.code == ERR_CODE_OVER_TIMES then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL", "TIP_FRI_GIFT"))
        else
            list.onListItemChangedListener(jsonData, self.getRewardButton:getParent():convertToWorldSpace(cc.p(self.getRewardButton:getPosition())))
            list:setData(nil)
            list:setData(data1)
        end
    end    
end

function MessageListItem:onDataSet(dataChanged, data)
    if string.len(data.img) > 5 then
        nk.ImageLoader:loadAndCacheImage(
            self.userAvatarLoaderId_,
            data.img,
            handler(self, self.onAvatarLoadComplete_),
            nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
        )
    end
    
    if data.content then
        self.content:setString(data.content)
    end
    if data.status and tonumber(data.status) == 2 then
        self.content:setTextColor(CONTENT_COLOR_READED)
    end

    if data.btntype and tonumber(data.btntype) == 4 or tonumber(data.btntype) == 5  then   -- 4群组邀请,5玩牌邀请
        self.delButton:hide()
        self.getRewardButton:hide()
        self.agreeButton:show()
        self.refuseButton:show()
    elseif data.btntype and tonumber(data.btntype) == 2 then
        self.delButton:hide()
        self.getRewardButton:show()
        self.agreeButton:hide()
        self.refuseButton:hide()
    else
        self.delButton:show()
        self.getRewardButton:hide()
        self.agreeButton:hide()
        self.refuseButton:hide()
    end
end

function MessageListItem:onAvatarLoadComplete_(success, sprite)
    if success then
        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()
        if self.img_ then
            self.img_:setTexture(tex)
            self.img_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
            self.img_:setScaleX(AVATAR_SIZE / texSize.width)
            self.img_:setScaleY(AVATAR_SIZE / texSize.height)
        end
    end
end

return MessageListItem
