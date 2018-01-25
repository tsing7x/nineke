local GroupInviteListItem          = import(".GroupInviteListItem")
local GroupInvitePopup = class("GroupInvitePopup", nk.ui.Panel)
local SimpleColorLabel = import("boomegg.ui.SimpleColorLabel")
local location0 = "22.5700847444,113.9277961850"--公司
local location1 = "13.719171454000715,100.52985988898314"--泰国公司

local logger = bm.Logger.new("GroupInvitePopup")

function GroupInvitePopup:ctor(groupid)
	GroupInvitePopup.super.ctor(self,nk.ui.Panel.SIZE_NORMAL)
    self.groupid_ = groupid
    self.this_ = self
	self:setNodeEventEnabled(true)
	self:addTitle(bm.LangUtil.getText("GROUP","INVITEPOPTITLE"),3)
    self.title_:setTextColor(cc.c3b(0xff,0xff,0xff))
    self.title_:setSystemFontSize(28)
    self:addCloseBtn()
    self.conWidth,self.conHeight = self.width_ - 40, self.height_ - 90

    self.maLabel_ = SimpleColorLabel.addMultiLabel(bm.LangUtil.getText("GROUP","INVITEPOPCODE"), 22, cc.c3b(0xdc,0xdc,0xff), cc.c3b(0xff,0xd8,0x00), cc.c3b(0xff,0xd8,0x00))
    self.maLabel_.pos(0, self.conHeight/2 - 42).addTo(self)
end

function GroupInvitePopup:onCleanup()
    bm.HttpService.CANCEL(self.getNearbyUsersId_)
    bm.HttpService.CANCEL(self.getNearbyInviteId_)
end

function GroupInvitePopup:show()
    self:showPanel_()
end

function GroupInvitePopup:onItemEvent(evt)
    if evt.type=="GROUP_INVITE" then
        self:setLoading(true)
        local item = evt.data
        local itemdata = item:getData()
        local index = item:getIndex()
        bm.HttpService.CANCEL(self.getNearbyInviteId_)
        self.getNearbyInviteId_ = bm.HttpService.POST(
            {
                mod = "Group",
                act = "groupInvite",
                uid = nk.userData.uid,
                invite_uid = itemdata.uid,
                group_id = self.groupid_,
            },
            function (data)
                if self.this_ then
                    local retData = json.decode(data)
                    if retData and retData.ret==1 then
                        table.remove(self.list_,index)
                        self.groupInviteList_:setData(self.list_,true)
                    elseif retData and retData.ret==-3 then  --等级不符合群要求
                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","JOINLEVELERROR_1"))
                    elseif retData and retData.ret==-4 then  --等级不符合群要求
                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","JOINGCOINERROR_1"))
                    end
                    self:setLoading(false)
                end
            end,
            function ()
                if self.this_ then
                    self:setLoading(false)
                end
            end
        )
    elseif evt.type=="HEAD_CLICK" then
    end
end

function GroupInvitePopup:onShowed()
    GroupInviteListItem.WIDTH = self.conWidth
    local listWidth,listHeight = GroupInviteListItem.WIDTH,self.conHeight-60
	local list_height_offset = 60+20
    self.groupInviteList_ = bm.ui.ListView.new(
        {
            viewRect = cc.rect(-listWidth * 0.5, -listHeight * 0.5, listWidth, listHeight),
            upRefresh = handler(self, self.onUpFrefresh_)
        }, 
        GroupInviteListItem)
        :pos(0, -list_height_offset*0.5+2)
        :addTo(self)

    self.groupInviteList_:addEventListener("ITEM_EVENT",handler(self,self.onItemEvent))
    self.list_ = {}
    self.page_ = 1
    self:onUpFrefresh_()
end

function GroupInvitePopup:onUpFrefresh_()
    if self.page_=="end" then return end
    local location = nk.Native:getDeviceInfo().location
    if not location or location=="" then
        location = location0
    end
    self:setLoading(true)
    bm.HttpService.CANCEL(self.getNearbyUsersId_)
    self.getNearbyUsersId_ = bm.HttpService.POST(
        {
            mod = "Group",
            act = "getNearbyUsers",
            uid = nk.userData.uid,
            location = location,
            page = self.page_,
        },
        function (data)
            if self.this_ then
                local retData = json.decode(data)
                if retData and retData.ret==1 and retData.data and retData.data.list then
                    self:setLoading(false)

                    self.code_ = retData.data.code
                    if self.code_ then
                        self.maLabel_.setString(self.code_)
                    end

                    if #retData.data.list < 1 then
                        self.page_="end"
                        return
                    end

                    self.page_ = self.page_ + 1
                    table.insertto(self.list_, retData.data.list)
                    self.groupInviteList_:setData(self.list_,true)
                elseif retData and retData.ret==-1 then -- 未获取到玩家地址
                    self:setLoading(false)
                    self.page_ = "end"
                end
            end
        end,
        function ()
        end
    )
end

function GroupInvitePopup:setLoading(isLoading)
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

return GroupInvitePopup