--
-- Author: Jonah0608@gmail.com
-- Date: 2016-09-18 14:45:46
--

local UserInfoItem = import(".UserInfoItem")

local AllUserInfoPopup = class("AllUserInfoPopup", nk.ui.Panel)

local POPUP_WIDTH = 715
local POPUP_HEIGHT = 480


function AllUserInfoPopup:ctor(ctx)
    self:setNodeEventEnabled(true)
    AllUserInfoPopup.super.ctor(self, {POPUP_WIDTH, POPUP_HEIGHT})
    self.ctx = ctx
    self.infoitem_ = {}
    self.uidList_ ={}
    self.curCount = 0
    self.curPage = 0
    self.maxPage = 0
    self.isloaded = false
    self:createNodes_()
    self:addCloseBtn()
end

function AllUserInfoPopup:addEventListener()
    self.userCountChangeId_ = bm.EventCenter:addEventListener("UserCountChange", handler(self, self.onUserCountChange_))
    self.getNewPlayerId_ = bm.EventCenter:addEventListener("getPageUser", handler(self, self.onPageUserGet_))
    nk.socket.HallSocket:getUserCount()
    nk.socket.HallSocket:getAllUser(self.curPage,6)
end

function AllUserInfoPopup:onUserCountChange_()
    if self.count_ then
        self.count_:setString(bm.LangUtil.getText("DICE","CURR_USER_COUNT",self.ctx.model.curcount))
    end
end

function AllUserInfoPopup:onPageUserGet_(evt)
    local data = evt.data
    if data then
        self.isloaded = true
        self.curPage = data.index
        if #(data.pageUser) == 6 then
            self.maxPage = self.maxPage + 1
        end
        if #(data.pageUser) > 0 then
            self:updateData(data.pageUser)
        end
    end
end

function AllUserInfoPopup:createNodes_()
    display.newScale9Sprite("#panel_overlay.png", 
           0, 0, cc.size(POPUP_WIDTH - 30, POPUP_HEIGHT - 90)):addTo(self):pos(0,-25)
    self.count_ = ui.newTTFLabel({text = bm.LangUtil.getText("DICE","CURR_USER_COUNT",self.ctx.model.curcount), color = cc.c3b(192, 201, 255), size = 28, align = ui.TEXT_ALIGN_LEFT}):pos(-320,200):addTo(self)
    self.count_:setAnchorPoint(cc.p(0,0.5))
end

function AllUserInfoPopup:createUserInfo()
    local CW = 682
    local CH = 387
    self.scrollContent = display.newNode()

    local playerData = self:getUserData()
    local count = #playerData
    local scrollHeight = (math.floor((count -1)/3) + 1) * 103 + 30
    self.scrollContent:setContentSize(682,scrollHeight)
    for i = 1,count do
        self.infoitem_[i] = UserInfoItem.new(self.ctx,playerData[i].seatId,playerData[i],playerData[i].exData)
        self.infoitem_[i]:pos(((i-1) % 3 - 1) * 224,scrollHeight / 2 - 65 - math.floor((i -1) /3) * 103)
        self.infoitem_[i]:addTo(self.scrollContent)
    end
    self.curCount = count
    local scrollViewRect = cc.rect(-CW * 0.5, -CH * 0.5, CW, CH)
    self.scroll_ = bm.ui.ScrollView.new({
            viewRect      = scrollViewRect,
            scrollContent = self.scrollContent,
            direction     = bm.ui.ScrollView.DIRECTION_VERTICAL,
            upRefresh = handler(self, self.onAllUserUpFrefresh_)
        })
        :pos(0, -25)
        :hideScrollBar()
        :addTo(self)
end

function AllUserInfoPopup:onAllUserUpFrefresh_()
    if self.curPage >= self.maxPage then
        return
    end
    self.needscroll_ = true
    if self.isloaded then
        self.isloaded = false
        nk.socket.HallSocket:getAllUser(self.curPage + 1,6)
    end
end

function AllUserInfoPopup:updateData(data)
    data = self:filterData_(data)
    local count = self.curCount + #data
    local scrollHeight = (math.floor((count -1)/3) + 1) * 103 + 30
    local curP = self.scrollContent:getContentSize().height
    self.scrollContent:setContentSize(682,scrollHeight)
    for i = 1,self.curCount do
        self.infoitem_[i]:pos(((i-1) % 3 - 1) * 224,scrollHeight / 2 - 65 - math.floor((i -1) /3) * 103)
    end

    for i = self.curCount + 1,count do
        local infoData = {}
        infoData = json.decode(data[i - self.curCount].userInfo)
        infoData.seatId = -1
        infoData.money = data[i - self.curCount].money
        infoData.exData = json.decode(data[i - self.curCount].userInfoEx)
        self.infoitem_[i] = UserInfoItem.new(self.ctx,-1,infoData,infoData.exData)
        self.infoitem_[i]:pos(((i-1) % 3 - 1) * 224,scrollHeight / 2 - 65 - math.floor((i -1) /3) * 103)
        self.infoitem_[i]:addTo(self.scrollContent)
    end

    self.curCount = count
    self.scroll_:update()
    if self.needscroll_ then
        self.scroll_:scrollTo(curP + 20)
    end
end

--过滤重复数据
function AllUserInfoPopup:filterData_(data)
    local filterData = {}

    for _, v in ipairs(data) do
        local infoData = json.decode(v.userInfo)
        local uid = tostring(infoData.uid)
        if not self.uidList_[uid] then
            self.uidList_[uid] = true
            table.insert(filterData, v)
        end
    end

    return filterData
end

function AllUserInfoPopup:onShowed()
    self:createUserInfo()
    self:addEventListener()
end

function AllUserInfoPopup:show()
    self:showPanel_()
end

function AllUserInfoPopup:hide()
    self:hidePanel_()
end

function AllUserInfoPopup:onCleanup()
    self:removeEventListener()
end

function AllUserInfoPopup:removeEventListener()
    if self.userCountChangeId_ then
        bm.EventCenter:removeEventListener(self.userCountChangeId_)
        self.userCountChangeId_ = nil
    end
    if self.getNewPlayerId_ then
        bm.EventCenter:removeEventListener(self.getNewPlayerId_)
        self.getNewPlayerId_ = nil
    end
end



function AllUserInfoPopup:getUserData()
    local players = {}
    local playerlist = self.ctx.model.playerList
    for i,v in pairs(playerlist) do
        table.insert(players,v)
    end
    local data = {}
    for i=1,#players do
        data[i] = {}
        data[i] = json.decode(players[i].userInfo)
        data[i].seatId = players[i].seatId
        data[i].money = players[i].money
        data[i].exData = json.decode(players[i].userInfoEx)
    end
    if self.ctx.model:selfSeatId() > -1 then
        local index = #data + 1
        data[index] = {}
        data[index] = nk.socket.HallSocket:buildUserInfo()
        data[index].seatId = self.ctx.model:selfSeatId()
        data[index].money = nk.userData.money
        data[index].exData = {}
    end
    return data
end

return AllUserInfoPopup