--
-- Author: shanks
-- Date: 2014.09.15
-- 消息视图,设置旁边的消息按钮

local MessageView = class("MessageView", nk.ui.Panel)
local MessageListItem = import(".MessageListItem")
local MessageData = import(".MessageData")

local POP_WIDTH = 815
local POP_HEIGHT = 516
local LIST_WIDTH = 760
local LIST_HEIGHT = 364

local logger = bm.Logger.new("MessageView")

function MessageView:ctor()
    self:setNodeEventEnabled(true)

    self.currentFriPage_ = 1
    self.currentSysPage_ = 1
    self.maxFriPage_ = false
    self.maxSysPage_ = false

    MessageView.super.ctor(self, {POP_WIDTH, POP_HEIGHT})
    self:initView()
    self:addCloseBtn()
    self:setCloseBtnOffset(0, -16)

    -- 每次打开 消息面板弹窗 后, 清除新消息提醒状态
    -- MessageData.hasNewMessage = false
    -- bm.DataProxy:setData(nk.dataKeys.NEW_MESSAGE, MessageData.hasNewMessage)
end

function MessageView:initView()
    --修改背景框
    self:setBackgroundStyle1()

    -- tab
    self.tabBar = nk.ui.CommonPopupTabBar.new(
        {
            popupWidth = POP_WIDTH,
            scale = 468/POP_WIDTH,
            iconOffsetX = 10,
            btnText = bm.LangUtil.getText("MESSAGE", "TAB_TEXT"),
        })
        :pos(0, self.height_ * 0.5 - nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5 - 32)
        :addTo(self)

    self:addTopDivide(nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5)
    self:addTopIcon("#pop_messagecenter_icon.png", -8)  

    -- list
    self.listPosY = - nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5 - 16
    display.newScale9Sprite("#pop_common_list_bg.png", 0, self.listPosY, cc.size(LIST_WIDTH + 8, LIST_HEIGHT + 12))
        :addTo(self)
    self.list = bm.ui.ListView.new(
        {
            viewRect = cc.rect(-LIST_WIDTH * 0.5, -LIST_HEIGHT * 0.5, LIST_WIDTH, LIST_HEIGHT),
            upRefresh = handler(self, self.requestMessageDataPage_)
        },
        MessageListItem
    )
    :pos(0, self.listPosY )
    :addTo(self)

    -- empty prompt
    self.emptyPrompt = ui.newTTFLabel({text = bm.LangUtil.getText("MESSAGE", "EMPTY_PROMPT"), color = cc.c3b(0xff, 0xff, 0xff), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :pos(0, -40)
        :addTo(self)
        :hide()

    self:addTabNewMessagePoint()
    self.list.onListItemChangedListener = handler(self, self.updateNewMessagePoint)
end

function MessageView:addTabNewMessagePoint()
    --有新消息标记
    self.newFriendMessagePoint = display.newSprite(nk.userData.motherDayRedNodePath)
        :pos(-16, self.height_ * 0.5 - nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5 - 24)
        :addTo(self)
        :scale(0.8)
        :hide()
    self.newSystemMessagePoint = display.newSprite(nk.userData.motherDayRedNodePath)
        :pos(234 - 16, self.height_ * 0.5 - nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5 - 24)
        :addTo(self)
        :scale(0.8)
        :hide()
end

function MessageView:updateNewMessagePoint(retData_, rect_)
    --
    if self.friendData and #self.friendData > 0 then
        local hasNewFriMess = false
        for i = 1, #self.friendData do
            if tonumber(self.friendData[i].btntype) == 2 then
                hasNewFriMess = true
                break
            end
        end
        if hasNewFriMess then
            self.newFriendMessagePoint:show()
        else
            self.newFriendMessagePoint:hide()
        end
    else
        self.newFriendMessagePoint:hide()
    end
    if self.systemData and #self.systemData > 0 then
        local hasNewSysMess = false
        for i = 1, #self.systemData do
            if tonumber(self.systemData[i].btntype) == 2 then
                hasNewSysMess = true
                break
            end
        end
        if hasNewSysMess then
            self.newSystemMessagePoint:show()
        else
            self.newSystemMessagePoint:hide()
        end
    else
        self.newSystemMessagePoint:hide()
    end
    if not self.newSystemMessagePoint:isVisible() and not self.newFriendMessagePoint:isVisible() then
        MessageData.hasNewMessage = false
        bm.DataProxy:setData(nk.dataKeys.NEW_MESSAGE, MessageData.hasNewMessage)
    end

    if retData_ and rect_ then
        self:playRewardAnimation_(retData_, rect_)
    end
end

function MessageView:playRewardAnimation_(retData, rect_)
    if retData and retData.code > 0 then
        local rect = rect_
        local num = retData.num
        local itype;
        local scaleVal = 0.8;
        local isHddj = nil
        -- type=1为游戏币，2为道具，3为比赛券,4为现金币,5为门票
        if retData.type == 1 then
            itype = 1
        elseif retData.type == 2 then
            itype = 8
            scaleVal = 1;
        elseif retData.type == 3 then
            itype = 2
            scaleVal = 0.5;
        elseif retData.type == 4 then
            itype = 3
            isHddj = false
            scaleVal = 0.9;
        elseif retData.type == 5 then
            local ptype = retData.ptype
            local num = 1; -- 门票数量数量
            local ticketValue = 0; -- 门票面值
            if ptype == 1000 then --7泰铢门票
                ticketValue = 7;
            elseif ptype == 1001 then --10泰铢门票
                ticketValue = 10;
            elseif ptype == 1002 then --20泰铢门票
                ticketValue = 20;
            elseif ptype == 1003 then --100泰铢门票
                ticketValue = 100;
            elseif ptype == 1004 then --300泰铢门票
                ticketValue = 300;
            end
            itype = 5;
            scaleVal = 0.5;
            nk.UserInfoChangeManager:playWheelFlyTicketAnimation(ticketValue, rect, itype, num, url, scaleVal);
            return
        end

        nk.UserInfoChangeManager:playWheelFlyAnimationByType(itype, rect, num, scaleVal, true, isHddj)
    end
end

function MessageView:onShowed()
    -- 延迟设置，防止list出现触摸边界的问题
    self.tabBar:onTabChange(handler(self, self.onTabChange))
    self.list:setScrollContentTouchRect()
end

function MessageView:onTabChange(selectedTab)
    self.selectedTab = selectedTab
    self.list:setDynamicSetDatasetEnabled(true)
    self.list:clearDynamicSetDataset()
    self:requestMessageData()
end

function MessageView:show()
    self:showPanel_()
end

function MessageView:requestMessageData()
    if self.friendData and self.systemData then
        self:setListData()
        return
    end

    self:setLoading(true)
    self.requestMessageDataId = bm.HttpService.POST(
    {
        mod = "Usernews",
        act = "getUserMsg",
        p = 1
    },
    handler(self, self.onGetMessageData),
    function (data)
        self:setLoading(false)
        logger:debug("get_message_data:" .. data)
    end
    )
end

function MessageView:onGetMessageData(data)
    self:setLoading(false)

    self.messageData = data
    logger:debug("get_message_data:" .. data)

    if data then
        local jsonData = json.decode(data)

        if jsonData and jsonData.code and jsonData.code > 0 then

            self.friendData = jsonData.newslist.frinews
            self.systemData = jsonData.newslist.sysnews

            self.list:setData(nil)
            self.emptyPrompt:hide()
            if self.selectedTab == 1 then
                self.list:setData(self.friendData)
                if #self.friendData <= 0 then
                    self.emptyPrompt:show()
                end
            else
                self.list:setData(self.systemData)
                if #self.systemData <= 0 then
                    self.emptyPrompt:show()
                end
            end
            if jsonData.red then
                if jsonData.red.redFri and jsonData.red.redFri == 1 then
                    self.newFriendMessagePoint:show()
                end
                if jsonData.red.redSys and jsonData.red.redSys == 1 then
                    self.newSystemMessagePoint:show()
                end
                if not self.newSystemMessagePoint:isVisible() and not self.newFriendMessagePoint:isVisible() then
                    MessageData.hasNewMessage = false
                    bm.DataProxy:setData(nk.dataKeys.NEW_MESSAGE, MessageData.hasNewMessage)
                end
            end
        else
            self.emptyPrompt:show()
        end
    end
end

-- 使用分页加载模型请求数据
function MessageView:requestMessageDataPage_()
    if self.selectedTab == 1 then
        if not self.maxFriPage_ then
            -- self:setLoading(true)
            self.currentFriPage_ = self.currentFriPage_ + 1
            -- bm.HttpService.CANCEL(self.messageDataRequestId_)
            self.messageDataRequestId_ = bm.HttpService.POST(
            {
                mod = "Usernews",
                act = "getUserMsg",
                p = self.currentFriPage_,
                newstype = 2
            },
            handler(self, self.onGetMessageDataPage_),
                function ()
                    -- self:setLoading(false)
                    logger:debug("get_message_data:" .. data)
                end
            )
        end
    else
        if not self.maxSysPage_ then
            -- self:setLoading(true)
            self.currentSysPage_ = self.currentSysPage_ + 1
            -- bm.HttpService.CANCEL(self.messageDataRequestId_)
            self.messageDataRequestId_ = bm.HttpService.POST(
            {
                mod = "Usernews",
                act = "getUserMsg",
                p = self.currentSysPage_,
                newstype = 1
            },
            handler(self, self.onGetMessageDataPage_),
                function ()
                    -- self:setLoading(false)
                    logger:debug("get_message_data:" .. data)
                end
            )
        end
    end
end

function MessageView:onGetMessageDataPage_(data)
    self:setLoading(false)

    if data then
        local jsonData = json.decode(data)
        if  jsonData.code and jsonData.code > 0 then
            if jsonData.newslist and #jsonData.newslist > 0 then
                if self.selectedTab == 1 then
                    for i = 1, #jsonData.newslist do
                        self.friendData[#self.friendData + 1] = jsonData.newslist[i]
                    end
                else
                    for i = 1, #jsonData.newslist do
                        self.systemData[#self.systemData + 1] = jsonData.newslist[i]
                    end
                end
            else
                if self.selectedTab == 1 then
                    self.maxFriPage_ = true
                else
                    self.maxSysPage_ = true
                end
            end
            self:setListData()
        else
            -- self.emptyPrompt:show()
        end
    end
end

function MessageView:setListData()
    self.list:setData(nil)
    self.emptyPrompt:hide()
    if self.selectedTab == 1 then
        self.list:setData(self.friendData)
        if #self.friendData <= 0 then
            self.emptyPrompt:show()
        end
    else
        self.list:setData(self.systemData)
        if #self.systemData <= 0 then
            self.emptyPrompt:show()
        end
    end
end

function MessageView:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
                :pos(0, self.listPosY )
                :addTo(self)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

function MessageView:onCleanup()
    bm.HttpService.CANCEL(self.requestMessageDataId)
end

return MessageView
