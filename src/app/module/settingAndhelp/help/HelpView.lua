--
-- Author: viking@boomegg.com
-- Date: 2014-08-22 16:56:47
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local HelpView = class("HelpView", function()
    return display.newNode()
end)

local HelpController = import(".HelpController")
local FeedbackView = import(".FeedbackView")
local FAQListItem = import(".listItems.FAQListItem")
local RuleListItem = import(".listItems.RuleListItem")
local LevelListItem = import(".listItems.LevelListItem")
local PunishListItem = import(".listItems.PunishListItem")

function HelpView:ctor(mainView, gotoTab)
    self:setNodeEventEnabled(true)
    self.mainView_ = mainView
    self.controller_ = HelpController.new(self)
    self.gotoTab_ = gotoTab or 1
    self.schedulerPool_ = bm.SchedulerPool.new()
    self:setupView()
end

function HelpView:setupView()
    local width, height = self.mainView_.width_, self.mainView_.height_

    local subTabItemWidth = 180 * 0.85
    local subTabItemHeight = 45

    local touchCover = display.newScale9Sprite("#transparent.png", 0, height/2 - self.mainView_.TAB_HEIGHT - 12 - 30, cc.size(width, 60)):addTo(self, 9)
    touchCover:setTouchEnabled(true)
    touchCover:setTouchSwallowEnabled(true)

    self.subTabBar_ = nk.ui.TabBarWithIndicator.new(
        {
            background = "#popup_sub_tab_bar_bg.png", 
            indicator = "#popup_sub_tab_bar_indicator.png"
        }, 
        bm.LangUtil.getText("HELP", "SUB_TAB_TEXT"), 
        {
            selectedText = {color = cc.c3b(0xff, 0xff, 0xff), size = 22},
            defaltText = {color = cc.c3b(0xdd, 0xc5, 0x93), size = 22}
        },
        true, 
        true
    )
    :setTabBarSize(subTabItemWidth * 4, subTabItemHeight, -10, -10)
    :gotoTab(self.gotoTab_, true)
    :onTabChange(handler(self, self.onTabChanged))
    :addTo(self, 11)

    --底框
    display.newScale9Sprite(
        "#panel_overlay.png",
        0, 0, cc.size(745, 315))
        :pos(0, -75)
        :addTo(self)

    self.currentTab = 1
    local subTabBarMarginTop = 60
    local subTabBarSize = self.subTabBar_.background_:getContentSize()
    local tabHeight = self.mainView_.TAB_HEIGHT
    self.subTabBar_:pos(0, height/2 - tabHeight - subTabBarSize.height/2 - subTabBarMarginTop)

    --内容ScrollView
    local contentMarginTop, contentMarginBottom = 12, 12
    self.viewRectWidth, self.viewRectHeight = width - 80, 295

    self.container = display.newNode():addTo(self):pos(0, -(height/2 - contentMarginBottom - self.viewRectHeight/2))
    self.bound = cc.rect(-self.viewRectWidth/2, -self.viewRectHeight/2, self.viewRectWidth, self.viewRectHeight)

    local topOriginY = 0
    self.listPosY_ = -(height/2 - contentMarginBottom - self.viewRectHeight/2)

    --反馈列表
    self.feedbackView_ = FeedbackView.new(self):addTo(self.container):hide()

    --FAQ列表
    FAQListItem.WIDTH = 710
    local listY = 25
    self.faqListView_ = bm.ui.ListView.new(
        {viewRect = self.bound, direction = bm.ui.ListView.DIRECTION_VERTICAL}, FAQListItem)
        :pos(0, listY)
        :addTo(self.container)

    --基本规则列表
    RuleListItem.WIDTH = 710
    self.ruleListView_ = bm.ui.ListView.new(
        {viewRect = self.bound, direction = bm.ui.ListView.DIRECTION_VERTICAL}, RuleListItem)
        :pos(0, listY)
        :addTo(self.container)
        
    --等级说明列表
    LevelListItem.WIDTH = 710
    self.levelListView_ = bm.ui.ListView.new(
        {viewRect = self.bound, direction = bm.ui.ListView.DIRECTION_VERTICAL}, LevelListItem)
        :pos(0, listY)
        :addTo(self.container)

    --基本规则列表
    PunishListItem.WIDTH = 710
    self.punishListView_ = bm.ui.ListView.new(
        {viewRect = self.bound, direction = bm.ui.ListView.DIRECTION_VERTICAL}, PunishListItem)
        :pos(0, listY)
        :addTo(self.container)
end

function HelpView:onTabChanged(selectedTab)
    print("help view selectedTab:"..selectedTab)

    local width, height = self.mainView_.width_, self.mainView_.height_
    if selectedTab == HelpController.FEED_BACK  and not self.feedbackViewInit_ then
        --反馈列表
        self.feedbackViewInit_ = true
        self:getFeedbackListData()
    elseif selectedTab == HelpController.FAQ  and not self.faqListViewInit_ then
        --FAQ列表
        self.faqListViewInit_ = true
        self:getFaqListData()
    elseif selectedTab == HelpController.RULE and not self.ruleListViewInit_ then
        --基本规则列表
        self.ruleListViewInit_ = true
        self:getRuleListData()
    elseif selectedTab == HelpController.LEVEL and not self.levelListViewInit_ then
        --等级说明列表
        self.levelListViewInit_ = true
        self:getLevelListData()
    elseif selectedTab == HelpController.PUNISH and not self.punishListViewInit_ then
        --惩罚规则
        self.punishListViewInit_ = true
        self:getPunishListData()
    end

    self.currentTab = selectedTab
    self.controller_:onTabChanged(selectedTab)
end

function HelpView:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
                :pos(0, self.listPosY_)
                :addTo(self)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

function HelpView:getFeedbackListData()
    self.controller_:getFeedbackListData()
end

function HelpView:getFeedbackView()
    return self.feedbackView_
end

function HelpView:getFaqListData()
    self:setLoading(true)
    self.schedulerPool_:delayCall(function()
        self.controller_:getFaqListData()
        self:setLoading(false)
    end, 0.5)
end

function HelpView:getFaqListView()
    return self.faqListView_
end

function HelpView:getRuleListData()
    self:setLoading(true)
    self.schedulerPool_:delayCall(function()
        self.controller_:getRuleListData()
        self:setLoading(false)
    end, 0.5)
end

function HelpView:getRuleListView()
    return self.ruleListView_
end

function HelpView:getLevelListData()
    self:setLoading(true)
    self.schedulerPool_:delayCall(function()
        self.controller_:getLevelListData()
        self:setLoading(false)
    end, 0.5)
end

function HelpView:getLevelListView()
    return self.levelListView_
end

function HelpView:getPunishListData()
    self:setLoading(true)
    self.schedulerPool_:delayCall(function()
        self.controller_:getPunishListData()
        self:setLoading(false)
    end, 0.5)
end

function HelpView:getPunishListView()
    return self.punishListView_
end

function HelpView:onShowed()
    self:onTabChanged(self.gotoTab_)

    self.feedbackView_:onShowed()

    self.faqListView_:setScrollContentTouchRect()
    self.faqListView_:setNotHide(true)

    self.ruleListView_:setScrollContentTouchRect()
    self.ruleListView_:setNotHide(true)
    
    self.levelListView_:setScrollContentTouchRect()
    self.levelListView_:setNotHide(true)

    self.punishListView_:setScrollContentTouchRect()
    self.punishListView_:setNotHide(true)
end

function HelpView:onExit()
    self.schedulerPool_:clearAll()
end

return HelpView