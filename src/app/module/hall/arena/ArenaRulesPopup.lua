--
-- Author: XT
-- Date: 2015-07-29 19:43:17
-- 比赛场 规则说明
local Panel = import("app.pokerUI.Panel")
local ArenaRulesPopup = class("ArenaRulesPopup", Panel)

local ArenaRulesController = import '.ArenaRulesController'
local ArenaRulesItem = import(".listItems.ArenaRulesItem")

function ArenaRulesPopup:ctor()
	ArenaRulesPopup.SIZE_NORMAL = {750, 490}
    ArenaRulesPopup.SIZE_NORMAL1 = {750+30, 490+30}
    ArenaRulesPopup.super.ctor(self, ArenaRulesPopup.SIZE_NORMAL1)
    self:addBgLight()
    self.controller_ = ArenaRulesController.new(self)
    self:setupView()    
end

function ArenaRulesPopup:setupView()
    local touchCover = display.newScale9Sprite("#transparent.png", 0, self.height_ * 0.5 - 38, cc.size(self.width_, 76)):addTo(self, 9)
    touchCover:setTouchEnabled(true)
    touchCover:setTouchSwallowEnabled(true)

    --内容ScrollView
    local subTabBarMarginTop = 16
    local tabHeight = 55
    local contentMarginTop, contentMarginBottom = 12, 12
    self.viewRectWidth, self.viewRectHeight = ArenaRulesPopup.SIZE_NORMAL[1], 
        ArenaRulesPopup.SIZE_NORMAL[2] - (tabHeight + subTabBarMarginTop + contentMarginTop + contentMarginBottom)+25

    self.container = display.newNode():addTo(self):pos(0, -25)
    self.bound = cc.rect(-self.viewRectWidth/2, -self.viewRectHeight/2, self.viewRectWidth, self.viewRectHeight)
    --FAQ列表
    ArenaRulesItem.WIDTH = ArenaRulesPopup.SIZE_NORMAL[1] - 0

    display.newScale9Sprite("#panel_overlay.png",0,0,cc.size(self.viewRectWidth, self.viewRectHeight+15))
        :addTo(self)
        :pos(0,-30)

    self.listView_ = bm.ui.ListView.new({viewRect = self.bound, direction = bm.ui.ListView.DIRECTION_VERTICAL}, ArenaRulesItem):addTo(self.container)
    self.controller_:getListData()

    ui.newTTFLabel({text=bm.LangUtil.getText("MATCH", "RULES_TILE"), size=36, color=cc.c3b(0xfb, 0xd0, 0x0a), align=ui.TEXT_ALIGN_CENTER, dimensions=cc.size(750, 0)}):pos(0, self.height_ * 0.5 - 45):addTo(self, 10)
    self:setLoading(false)
    self:addCloseBtn()
end

function ArenaRulesPopup:getListView()
	return self.listView_
end

function ArenaRulesPopup:show()
    self:showPanel_(true, true, true)
    return self
end

function ArenaRulesPopup:close()
    nk.PopupManager:removePopup(self)
    return self
end

function ArenaRulesPopup:onClose()
    self:close()
end

function ArenaRulesPopup:onShowed()
    self.listView_:setScrollContentTouchRect()
    self.listView_:setNotHide(true)
end

function ArenaRulesPopup:setLoading(isLoading)
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

return ArenaRulesPopup