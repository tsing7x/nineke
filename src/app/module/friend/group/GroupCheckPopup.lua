local GroupCheckListItem          = import(".GroupCheckListItem")
local GroupCheckPopup = class("GroupCheckPopup", nk.ui.Panel)

local logger = bm.Logger.new("GroupCheckPopup")

function GroupCheckPopup:ctor(groupid)
	GroupCheckPopup.super.ctor(self, nk.ui.Panel.SIZE_NORMAL)
    self.groupid_ = groupid
    self.this_ = self
	self:setNodeEventEnabled(true)
	self:addTitle(bm.LangUtil.getText("GROUP","CHECKPOPTITLE"),5)
    self.title_:setTextColor(cc.c3b(0xff,0xff,0xff))
    self.title_:setSystemFontSize(28)
    self:addCloseBtn()
    self.conWidth,self.conHeight = self.width_-40, self.height_-90
    display.newScale9Sprite("#panel_overlay.png",0, 0, cc.size(self.conWidth,self.conHeight))
    	:pos(0,-20)
        :addTo(self)
    local line = display.newScale9Sprite("#group_dividing_line.png",
   		0, self.conHeight*0.5-60, cc.size(self.conWidth-4, 2))
		:addTo(self)

	ui.newTTFLabel({
        text = bm.LangUtil.getText("GROUP","CHECKPOPNAME"),
        color=cc.c3b(0xa8,0x9f,0xe1),
        size = 20,
    })
	:pos(-self.conWidth/3,self.conHeight*0.5-60+18)
	:addTo(self)

   	ui.newTTFLabel({
        text = bm.LangUtil.getText("GROUP","CHECKPOPMONEY"),
        color=cc.c3b(0xa8,0x9f,0xe1),
        size = 20,
    })
	:pos(0,self.conHeight*0.5-60+18)
	:addTo(self)

    ui.newTTFLabel({
        text = bm.LangUtil.getText("GROUP","CHECKPOPACTION"),
        color=cc.c3b(0xa8,0x9f,0xe1),
        size = 20,
    })
	:pos(self.conWidth/3,self.conHeight*0.5-60+18)
	:addTo(self)
end

function GroupCheckPopup:onCleanup()
    bm.HttpService.CANCEL(self.getGroupCheckListId_)
    bm.HttpService.CANCEL(self.getGroupCheckId_)
end

function GroupCheckPopup:show()
    self:showPanel_()
end
function GroupCheckPopup:onUpFrefresh_()
    if self.page_=="end" then return; end
    bm.HttpService.CANCEL(self.getGroupCheckListId_)
    self:setLoading(true)
    self.getGroupCheckListId_ = bm.HttpService.POST(
        {
            mod = "Group",
            act = "getGroupInfo",
            group_id = self.groupid_,
            type = 5, -- 1,2,3 中所有的数据
            page = self.page_
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
                    self.groupCheckList_:setData(self.list_,true)
                end
            end
        end,
        function ()
        end
    )
end
function GroupCheckPopup:onShowed()
    GroupCheckListItem.WIDTH = self.conWidth
    local listWidth,listHeight = GroupCheckListItem.WIDTH,self.conHeight-60
	local list_height_offset = 60+20
    self.groupCheckList_ = bm.ui.ListView.new(
        {
            viewRect = cc.rect(-listWidth * 0.5, -listHeight * 0.5, listWidth, listHeight),
            upRefresh = handler(self, self.onUpFrefresh_)
        }, 
        GroupCheckListItem
    )
    :pos(0, -list_height_offset*0.5+2)
    :addTo(self)

    self.groupCheckList_:addEventListener("ITEM_EVENT",handler(self,self.onItemEvent))
    self.list_ = {}
    self.page_ = 1
    self:onUpFrefresh_()
end

function GroupCheckPopup:onItemEvent(evt)
    if evt.type=="GROUP_AGREE_IN" or evt.type=="GROUP_REFUSE_IN" then
        self:setLoading(true)
        local action = 0
        if evt.type=="GROUP_REFUSE_IN" then
            action = 0
        else
            action = 1
        end

        local item = evt.data
        local itemdata = item:getData()
        local index = item:getIndex()
        bm.HttpService.CANCEL(self.getGroupCheckId_)
        self.getGroupCheckId_ = bm.HttpService.POST(
            {
                mod = "Group",
                act = "groupCheck",
                uid = nk.userData.uid,
                type = action,
                group_id = self.groupid_,
                mid = itemdata.mid,
            },
            function (data)
                if self.this_ then
                    local retData = json.decode(data)
                    if retData and retData.ret==1 then
                        table.remove(self.list_,index)
                        self.groupCheckList_:setData(self.list_,true)
                    elseif retData and tonumber(retData.ret)==-4 then
                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("GROUP","CHECKPOPFULL"))
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

function GroupCheckPopup:setLoading(isLoading)
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

return GroupCheckPopup