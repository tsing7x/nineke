--
-- Author: KevinYu
-- Date: 2017-03-24 15:20:18
-- 新版活动中心，入口由PHP控制
local ActivityCenterPopup = class("ActivityCenterPopup", function ()
    return display.newNode()
end)

local DiscountInfoPopup     = import("app.module.newestact.DiscountInfoPopup")
local FootballQuizPopup     = import("app.module.football.FootballQuizPopup")
local ActivityRankingPopup  = import("app.module.newestact.template.ranking.ActivityRankingPopup")
local ActivityCenterItem    = import(".ActivityCenterItem")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

local requestRetryTimes_ = 3

function ActivityCenterPopup:ctor()
	self:setTouchEnabled(true)
    self:setNodeEventEnabled(true)

    requestRetryTimes_ = 3

    local bgScale = 1
    if display.width > 960 and display.height == 640 then
        bgScale = display.width / 960
    elseif display.width == 960 and display.height > 640 then
        bgScale = display.height / 640
    end

	local bg = display.newSprite("activity/activity_bg.png")
        :scale(bgScale)
        :addTo(self)

    local s = 1
    if display.width > 960 then
        s = display.width / 960
    end
    
    display.newSprite("activity/activity_title_bg.png")
    	:align(display.TOP_CENTER, 0, display.cy)
        :scale(s)
        :addTo(self)

    display.newSprite("activity/activity_title.png")
    	:pos(0, display.cy - 35)
        :addTo(self)
    
    cc.ui.UIPushButton.new("activity/activity_title_close.png")
		:onButtonClicked(buttontHandler(self, self.onCloseClicked))
        :pos(-display.cx + 50, display.cy - 35)
        :addTo(self)

    --self:getActivityIcon_()
    self.getActivityIconSchedule_ = scheduler.performWithDelayGlobal(handler(self, self.getActivityIcon_), 0.5)
    bm.EventCenter:addEventListener("ON_ACTIVITY_CLICKED", handler(self, self.onActivityClicked))
end

function ActivityCenterPopup:getActivityIcon_()
    self:setLoading(true)
    bm.HttpService.CANCEL(self.getActivityIconRequestId_)
    self.getActivityIconRequestId_ = bm.HttpService.POST(
    {
        mod = "Act",
        act = "getList",
    },
    function(data)
        local callData = json.decode(data)
        if callData.ret == 0 then
            self:setLoading(false)
            self.cdn_ = callData.cdn
            self:createMainUI_(callData.list or {})
        end
    end,
    function ()
        requestRetryTimes_ = requestRetryTimes_ - 1
        if requestRetryTimes_ > 0 then
            self.getActivityIconSchedule_ = scheduler.performWithDelayGlobal(handler(self, self.getActivityIcon_), 1)
        end
    end)
end

function ActivityCenterPopup:createMainUI_(data)
    if #data > 0 then
        self:addActivityList_(data)        
    else
        ui.newTTFLabel({text = bm.LangUtil.getText("NEWESTACT", "NO_ACT"), size = 22, color = cc.c3b(0xff, 0xda, 0x2c)})
            :addTo(self) 
    end
end

function ActivityCenterPopup:addActivityList_(data)
	local contentNode = display.newNode()
	local list_w, list_h = 960, 500
	local num = #data
	local item_w = 300
	local contentNode_w = num * item_w
	contentNode:size(contentNode_w, list_h)
	local sx = -contentNode_w/2 + item_w/2

    --将数据进行排序
    for i = 2, #data do
        local tmp = clone(data[i])
        for j = i - 1, 1, -1 do
            local num1 = tonumber(tmp.sort) or 0
            local num2 = tonumber(data[j].sort) or 0
            if num1 > num2 then
                data[j + 1] = clone(data[j])
                data[j] = tmp
            elseif num1 <= num2 then
                data[j + 1] = tmp
                break
            end
        end
    end

	for i = 1, num do
        ActivityCenterItem.new(self)
                :pos(sx + (i - 1) * item_w, 0)
                :addTo(contentNode)
            :setData(data[i], self.cdn_)
        end

    local scrollViewRect = cc.rect(-list_w/2, -list_h/2, list_w, list_h)
	self.scrollView_ = bm.ui.ScrollView.new({
        viewRect      = scrollViewRect,
        scrollContent = contentNode,
        direction     = bm.ui.ScrollView.DIRECTION_HORIZONTAL
    })
    :addTo(self)
end

function ActivityCenterPopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
                :addTo(self, 8)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

function ActivityCenterPopup:onCloseClicked(evt)
	self:hide()
end

function ActivityCenterPopup:onShowed()
	if self.scrollView_ then
        self.scrollView_:setScrollContentTouchRect()
    end
end

function ActivityCenterPopup:show()
    self:addActivityStat(nk.userData.activityTj, 0, 0)
    nk.PopupManager:addPopup(self)
    return self
end

function ActivityCenterPopup:hide()
    nk.PopupManager:removePopup(self)
    return self
end

function ActivityCenterPopup:onCleanup()
    bm.HttpService.CANCEL(self.getActivityIconRequestId_)

    if self.getActivityIconSchedule_ then
        scheduler.unscheduleGlobal(self.getActivityIconSchedule_)
    end

    bm.EventCenter:removeEventListenersByEvent("ON_ACTIVITY_CLICKED")
end

--添加活动统计
function ActivityCenterPopup:addActivityStat(doActTj, pActivityId, pType)
    if doActTj == 0 then return end
    bm.HttpService.POST(
    {
        act = "tj",
        mod = "Act",
        activityId = pActivityId, --活动id 活动入口点击传0，其余传活动id
        type = pType, --0:活动入口；1：一级图标；2：参加按钮
        isNewVersion = 1 
    },
    function(data)
        local callData = json.decode(data)
        if callData.ret == 0 then
            print("pType:" .. pType .. "  " .. "pActivityId:" .. pActivityId .. "  " .. "统计上报成功")
        else
            print("pType:" .. pType .. "  " .. "pActivityId:" .. pActivityId .. "  " .. "统计上报失败:" .. callData.ret)
        end
    end,
    function ()
        print("pType:" .. pType .. "  " .. "pActivityId:" .. pActivityId .. "  " .. "统计上报失败")
    end)
end

return ActivityCenterPopup