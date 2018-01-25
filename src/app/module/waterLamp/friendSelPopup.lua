local FriendListSelItem        = import(".friendSelListItem")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

local FriendSelPopup = class("FriendSelPopup", function()
    return display.newNode()
end)

----[[
local POP_WIDTH = 264
local POP_HEIGHT = 185
local PANEL_CLOSE_BTN_Z_ORDER = 99

local LIST_WIDTH = 264
local LIST_HEIGHT = 155

function FriendSelPopup:ctor(...)
    self:setNodeEventEnabled(true)

    local bgScaleX, bgScaleY = 1, 1
    if display.width > 960 and display.height == 640 then
        bgScaleX = display.width / 960
    elseif display.width == 960 and display.height > 640 then
        bgScaleY = display.height / 640
    end
    self:setScaleX(bgScaleX)
    self:setScaleY(bgScaleY)

    local params = {...}
    self.parentPopu = params[1]

    local backFrame = display.newSprite("#waterLampFrame.png"):pos(-130, -14):addTo(self)
    backFrame:setTouchEnabled(true)
    backFrame:setTouchSwallowEnabled(true)

    self.friendPage_ = 1
    self.maxPage_ = false
    requestRetryTimes_ = 2

    self:createFrienList()
end

function FriendSelPopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
                :pos(-130, -14)
                :addTo(self)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

function FriendSelPopup:createFrienList()
    local list_height_offset = 0
    self.list_ = bm.ui.ListView.new(
        {
            viewRect = cc.rect(-LIST_WIDTH * 0.5, -LIST_HEIGHT * 0.5 + list_height_offset * 0.5, LIST_WIDTH, LIST_HEIGHT - list_height_offset),
            upRefresh = handler(self, self.requestFriendDataPage_)
        }, 
        FriendListSelItem
    )
    :pos(-130, -14)
    :addTo(self)
    self:requestFriendDataPage_()
    self.list_.popu = self
end

function FriendSelPopup:requestFriendDataPage_()
    self:setLoading(true)
    if not self.maxPage_ then
        if not self.friendData_ then
            self.friendData_ = {}
        end

        bm.HttpService.CANCEL(self.friendDataRequestId_)
        self.friendDataRequestId_ = bm.HttpService.POST(
        {
            mod = "friend",
            act = "list",
            new = 1,
            page = self.friendPage_
        },
        handler(self, self.onGetFriendDataPage_),
        function ()
            requestRetryTimes_ = requestRetryTimes_ - 1
            if requestRetryTimes_ > 0 then
                self.friendDataRequestScheduleHandle_ = scheduler.performWithDelayGlobal(handler(self, self.requestFriendDataPage_), 1)
            end
        end)
    end
end

function FriendSelPopup:onGetFriendDataPage_(jsondata)
    if jsondata then
        local jsondata_ = json.decode(jsondata)
        local data = jsondata_.flist or {}
        if #data == 0 then
            self.maxPage_ = true
            if self.friendPage_ > 1 then
                return
            end
        end

        self.friendPage_ = self.friendPage_ + 1
        for i=0,#data do
            table.insert(self.friendData_,data[i])
        end

        local uidList = {}
        if self.friendData_ then
            for i, v in ipairs(self.friendData_) do
                uidList[#uidList + 1] = v.uid
            end
        end
        
        if #self.friendData_ > 0 then
            self:setListData(self.friendData_)
        else
            self:setNoDataTip(true)
        end
        self:setLoading(false)
    else
        self.friendDataRequestScheduleHandle_ = scheduler.performWithDelayGlobal(handler(self, self.requestFriendDataPage_), 2)
    end
end

function FriendSelPopup:sortFriendData_(data)
    for _, v in ipairs(data) do
        if v.ip and v.port and v.tid then
            v.isTrack = 1
        else
            v.isTrack = 0
        end
    end

    local function sort_(a, b)
        local r
        local a_online = tonumber(a.isOnline) --是否在线
        local b_online = tonumber(b.isOnline)

        local a_isTrack = tonumber(a.isTrack) --是否可追踪
        local b_isTrack = tonumber(b.isTrack)

        local a_isFb = tonumber(a.isFb) --是否FB登录
        local b_isFb = tonumber(b.isFb)

        local a_isRecall = tonumber(a.isRecall) --是否需要召回
        local b_isRecall = tonumber(b.isRecall)

        if a_online == b_online then
            if a_online == 1 then
                if a_isTrack == b_isTrack then
                    r = a_isFb > b_isFb
                else
                    r = a_isTrack > b_isTrack
                end                
            else
                if a_isRecall == b_isRecall then
                    r = a_isFb > b_isFb
                else
                    r = a_isRecall > b_isRecall
                end
            end
        else
            r = a_online > b_online
        end

        return r
    end

    table.sort(data, sort_)
end

function FriendSelPopup:setListData(data)
    self:sortFriendData_(data)
    self.list_:setData(data, true)
end

function FriendSelPopup:setNoDataTip(noData)
    if noData then
        if not self.noDataTip_ then
            self.noDataTip_ = ui.newTTFLabel({text = bm.LangUtil.getText("FRIEND", "NO_FRIEND_TIP"), color = cc.c3b(0x73, 0x56, 0x52), size = 24, align = ui.TEXT_ALIGN_CENTER})
                :pos(-125, -11)
                :addTo(self)
        end
    else
        if self.noDataTip_ then
            self.noDataTip_:removeFromParent()
            self.noDataTip_ = nil
        end
    end
end

function FriendSelPopup:modToId(id)
    self.parentPopu:modToId(id)
    self:hide()
end

function FriendSelPopup:show()
    nk.PopupManager:addPopup(self, true ~= false, true ~= false, true ~= false, nil ~= false)
    return self
end

function FriendSelPopup:hide()
    nk.PopupManager:removePopup(self)
    return self
end

--]]

return FriendSelPopup
