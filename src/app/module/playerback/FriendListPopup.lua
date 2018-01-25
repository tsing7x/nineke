--
-- Author: Jonah0608@gmail.com
-- Date: 2015-12-30 16:24:53
--
local FriendListItem = import(".FriendListItem")
local FriendListPopup = class("FriendListPopup", function()
    return display.newNode()
end)

local LIST_WIDTH = 210
local LIST_HEIGHT = 580

function FriendListPopup:ctor()
    self:setupView()
    self:loadData()
end

function FriendListPopup:setupView()
    display.newScale9Sprite("#playerback_popup_friend_list_bg.png", 0, 0, cc.size(220, 620), cc.rect(10, 10, 2,2)):addTo(self)
    display.newScale9Sprite("#playerback_popup_friend_list_title.png", 0, 290, cc.size(212, 32), cc.rect(10, 10, 2,2)):addTo(self)
    ui.newTTFLabel({text = bm.LangUtil.getText("PLAYERBACK","FRIENDLIST_TITLE"), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 20, align = ui.TEXT_ALIGN_CENTER})
        :pos( 0, 290)
        :addTo(self)
    self.list_ = bm.ui.ListView.new(
            {
                viewRect = cc.rect(-LIST_WIDTH * 0.5, -LIST_HEIGHT * 0.5, LIST_WIDTH, LIST_HEIGHT)
            }, 
            FriendListItem
        ):pos(0,-25)
    :addTo(self)
end

function FriendListPopup:loadData()
    self:setLoading(true)
    bm.HttpService.POST({
        mod = "friend",
        act = "list",
        washed = 15,
        offline = 1
        }, function(data)
            self:onGetData(true,json.decode(data))
        end, 
        function()
            self:onGetData(false)
        end)
end

function FriendListPopup:onGetData(succ,friendData)
    self:setLoading(false)
    if succ then
        if #friendData == 0 then
            self:setNoDataTip(true)
        else
            self:setNoDataTip(false)
            self.list_:setData(friendData)
        end
    else
        self:setNoDataTip(true)
    end
end

function FriendListPopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
                :pos(0, 0)
                :addTo(self)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

function FriendListPopup:setNoDataTip(noData)
    if noData then
        if not self.noDataTip_ then
            self.noDataTip_ = ui.newTTFLabel({text = bm.LangUtil.getText("FRIEND", "NO_FRIEND_TIP"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 24, align = ui.TEXT_ALIGN_CENTER})
                :pos(0, 0)
                :addTo(self)
        end
    else
        if self.noDataTip_ then
            self.noDataTip_:removeFromParent()
            self.noDataTip_ = nil
        end
    end
end

function FriendListPopup:onShowed()
    if self.list_ then
        self.list_:setScrollContentTouchRect()
    end
end

function FriendListPopup:show()
    self:pos(display.width - 120,display.cy)
    nk.PopupManager:addPopup(self,true,false,true,false)
    return self
end

function FriendListPopup:hide()
    nk.PopupManager:removePopup(self)
    return self
end

return FriendListPopup