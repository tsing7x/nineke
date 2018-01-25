--
-- Author: KevinYu
-- Date: 2016-05-27 10:29:30
-- 购买记录弹窗

local ProductRecordPopup = class("ProductRecordPopup", nk.ui.Panel)
local HistoryListItem = import(".views.HistoryListItem")

local POPUP_WIDTH = 815
local POPUP_HEIGHT = 516
local LIST_WIDTH, LIST_HEIGHT =  POPUP_WIDTH - 80, POPUP_HEIGHT - 120

function ProductRecordPopup:ctor(controller)
	ProductRecordPopup.super.ctor(self, {POPUP_WIDTH, POPUP_HEIGHT})

    self:setNodeEventEnabled(true)

    self.setHistoryListId_ = bm.EventCenter:addEventListener("setStoreHistoryList", handler(self, self.setHistoryList_))

    self.controller_ = controller

	self:setBackgroundStyle1()
	self:addCloseBtn()
    self:setCloseBtnOffset(0, -16)
    
    ui.newTTFLabel({text = bm.LangUtil.getText("STORE", "TITLE_HISTORY"), size=28, color=cc.c3b(0xBA, 0xE9, 0xFF), align=ui.TEXT_ALIGN_LEFT})
    	:pos(0, POPUP_HEIGHT/2 - 40)
        :addTo(self)

    HistoryListItem.WIDTH = LIST_WIDTH
    HistoryListItem.HEIGHT =  70

    self:addHistoryPage_()

    self.controller_:loadHistory()
end

function ProductRecordPopup:addHistoryPage_()
    local page = display.newNode():addTo(self)
    local pageX, pageY = 0, -20

    self.historyList_ = bm.ui.ListView.new({
            viewRect = cc.rect(-0.5 * LIST_WIDTH, -0.5 * LIST_HEIGHT, LIST_WIDTH, LIST_HEIGHT),
            direction = bm.ui.ListView.DIRECTION_VERTICAL
        }, HistoryListItem)
        :pos(pageX, pageY)
        :addTo(page)

   
    self.historyListJuhua_ = nk.ui.Juhua.new()
        :pos(pageX, pageY)
        :addTo(page)
        :hide()

    self.historyListMsg_ = ui.newTTFLabel({text = "", color = cc.c3b(255, 255, 255), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :pos(pageX, pageY)
        :addTo(page)
        :hide()

    return page
end

function ProductRecordPopup:setHistoryList_(event)
    local data = event.data
    local isComplete = data.isComplete

    if isComplete then
        local listData = data.list
        
        self.historyListJuhua_:hide()
        if type(listData) == "string" then
            self.historyListMsg_:setString(listData)
            self.historyListMsg_:show()
            self.historyList_:setData(nil)
        else
            self.historyListMsg_:hide()
            self.historyList_:setData(listData)
            self:updateTouchRect_()
        end
    else
        self.historyList_:setData(nil)
        self.historyListMsg_:hide()
        self.historyListJuhua_:show()
    end
end

function ProductRecordPopup:updateTouchRect_()
    if self.historyList_ then
        self.historyList_:setScrollContentTouchRect()
    end
end

function ProductRecordPopup:onShowed()
    self:updateTouchRect_()
end

function ProductRecordPopup:show()
    self:showPanel_()
end

function ProductRecordPopup:onCleanup()
    bm.EventCenter:removeEventListener(self.setHistoryListId_)
end

return ProductRecordPopup
