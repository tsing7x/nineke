local GroupMsgListItem          = import(".GroupMsgListItem")
local GroupMsgPopup = class("GroupMsgPopup", nk.ui.Panel)

local logger = bm.Logger.new("GroupMsgPopup")

function GroupMsgPopup:ctor(groupid)
	-- GroupMsgPopup.super.ctor(self, {POPUP_WIDTH, POPUP_HEIGHT})
	GroupMsgPopup.super.ctor(self,nk.ui.Panel.SIZE_NORMAL)
    self.groupid_ = groupid
    self.this_ = self
	self:setNodeEventEnabled(true)
	self:addTitle(bm.LangUtil.getText("GROUP","MSGPOPTITLE"),5)
    self.title_:setTextColor(cc.c3b(0xff,0xff,0xff))
    self.title_:setSystemFontSize(28)
    self:addCloseBtn()
    self.conWidth,self.conHeight = self.width_-40, self.height_-90
end

function GroupMsgPopup:onCleanup()
    bm.HttpService.CANCEL(self.getGroupMsgListId_)
    bm.HttpService.CANCEL(self.deleteGroupMsgId_)
end

function GroupMsgPopup:show()
    self:showPanel_()
end
function GroupMsgPopup:onUpFrefresh_()
    if self.page_=="end" then return; end
    bm.HttpService.CANCEL(self.getGroupMsgListId_)
    self:setLoading(true)
    self.getGroupMsgListId_ = bm.HttpService.POST(
        {
            mod = "Group",
            act = "getGroupInfo",
            group_id = self.groupid_,
            type = 6, -- 1,2,3 中所有的数据
            page = self.page_,
        },
        function (data)
            if self.this_ then
                local retData = json.decode(data)
                if retData and retData.data then
                    self:setLoading(false)
                    if #retData.data<1 then
                        self.page_="end"
                        return;
                    end
                    self.page_ = self.page_ + 1
                    table.insertto(self.list_,retData.data)
                    self.groupMsgList_:setData(self.list_,true)
                end
            end
        end,
        function ()
            if self.this_ then
                
            end
        end
    )
end
function GroupMsgPopup:onShowed()
    GroupMsgListItem.WIDTH = self.conWidth
    local listWidth,listHeight = GroupMsgListItem.WIDTH,self.conHeight
	local list_height_offset = 40
    self.groupMsgList_ = bm.ui.ListView.new(
        {
            viewRect = cc.rect(-listWidth * 0.5, -listHeight * 0.5, listWidth, listHeight),
            upRefresh = handler(self, self.onUpFrefresh_)
        }, 
        GroupMsgListItem
    )
        :pos(0, -list_height_offset*0.5+2)
        :addTo(self)
    self.groupMsgList_:addEventListener("ITEM_EVENT",handler(self,self.onItemEvent))
    self.list_ = {}
    self.page_ = 1
    self:onUpFrefresh_()
end

function GroupMsgPopup:onItemEvent(evt)
    if evt.type=="DELETE_GROUP_INFO"then
  
    elseif evt.type=="HEAD_CLICK" then

    end
end

function GroupMsgPopup:setLoading(isLoading)
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

return GroupMsgPopup