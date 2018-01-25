--
-- Author: Jonah0608@gmail.com
-- Date: 2015-12-23 17:06:50
--

local PushMsgController = import(".PushMsgController")
local PushMsgListItem = import(".PushMsgListItem")

local LIST_WIDTH = 560
local LIST_HEIGHT = 280

local PushMsgPopup = class("PushMsgPopup", function()
    return display.newNode()
end)

function PushMsgPopup:ctor(title,msg,showIcon, type)
    self:setNodeEventEnabled(true)
    self.controller_ = PushMsgController.new(self,title,msg,showIcon, type)
    self:setupView()
end


function PushMsgPopup:setupView()
    local node, width, height = cc.uiloader:load('pushmsg.ExportJson')
    if node then
        node:setAnchorPoint(cc.p(0.5, 0.5))
        node:addTo(self)
    end

    bm.TouchHelper.new(cc.uiloader:seekNodeByTag(self, 5)):enableTouch()

    --关闭按钮
    local closeButton = cc.uiloader:seekNodeByTag(self, 1000)
    closeButton:onButtonClicked(function(event)
        self:onCloseBtnListener_()
    end)

    self.title_ = cc.uiloader:seekNodeByTag(self, 1001)
    self.title_:setString(bm.LangUtil.getText("PUSHMSG","PUSH_POPUP_TITLE"))

    self.list_ = bm.ui.ListView.new(
            {
                viewRect = cc.rect(-LIST_WIDTH * 0.5, -LIST_HEIGHT * 0.5, LIST_WIDTH, LIST_HEIGHT)
            }, 
            PushMsgListItem
        ):pos(0,-25)
    :addTo(self)
    self.list_.controller_ = self.controller_
    self.controller_:getListData()
end

function PushMsgPopup:setListData(data)
    self.list_:setData(data)
end

function PushMsgPopup:setLoading(isLoading)
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

function PushMsgPopup:setNoDataTip(noData)
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


function PushMsgPopup:onCloseBtnListener_()
    self:hide()
end

function PushMsgPopup:onShowed()
    if self.list_ then
        self.list_:setScrollContentTouchRect()
    end
end

function PushMsgPopup:show()
    nk.PopupManager:addPopup(self)
    return self
end

function PushMsgPopup:hide()
    nk.PopupManager:removePopup(self)
    return self
end

function PushMsgPopup:onCleanup()
    self.controller_:dispose()
end

return PushMsgPopup