--
-- Author: KevinLiang@boyaa.com
-- Date: 2015-12-09 11:57:54
--
local HighRoomRewardPopup = class("HighRoomRewardPopup", nk.ui.Panel)
local HighRoomRewardListItem = import(".HighRoomRewardListItem")
local UserInfoPopup = import("app.module.userInfo.UserInfoPopup")

local WIDTH = 780
local HEIGHT = 444
local LIST_WIDTH = 740
local LIST_HEIGHT = 216
local TEXT_COLOR = cc.c3b(0xEE, 0xEE, 0xEE)

function HighRoomRewardPopup:ctor()
    self:setNodeEventEnabled(true)
    self:loadConfigData()
    self:setupView()
end

function HighRoomRewardPopup:setupView()

    HighRoomRewardPopup.super.ctor(self, {WIDTH, HEIGHT})

    self:setCommonStyle(bm.LangUtil.getText("HIGHROOMREWARD", "TITLE"))

    local conductConfig = nk.OnOff:getConfig('conductConfig')
    local gameCount = 30
    if conductConfig and conductConfig.num then
        gameCount = conductConfig.num
    end
    ui.newTTFLabel({text = bm.LangUtil.getText("HALLOWEEN", "TIPS2", gameCount), color = styles.FONT_COLOR.GOLDEN_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})
        :pos(0, -HEIGHT * 0.5 + 54)
        :addTo(self)

    local list_bg_pos_y = 2
    display.newScale9Sprite("#pop_vip_list_bg.png", 0, 0, cc.size(740, 266), cc.rect(22,0,1,1)):pos(0, list_bg_pos_y):addTo(self)
    display.newScale9Sprite("#pop_vip_list_item_divide.png", 0, 0, cc.size(3, 256)):pos(-234, list_bg_pos_y):addTo(self)
    display.newScale9Sprite("#pop_vip_list_item_divide.png", 0, 0, cc.size(3, 256)):pos(32, list_bg_pos_y):addTo(self)
    display.newScale9Sprite("#pop_vip_list_item_divide.png", 0, 0, cc.size(3, 256)):pos(172, list_bg_pos_y):addTo(self)

    local list_title_pos_y = 114
    ui.newTTFLabel({text = bm.LangUtil.getText("HIGHROOMREWARD", "LIST_TITLE1"), color = TEXT_COLOR, size = 18, align = ui.TEXT_ALIGN_CENTER})
        :pos(-LIST_WIDTH * 0.5 + 60, list_title_pos_y)
        :addTo(self)
    ui.newTTFLabel({text = bm.LangUtil.getText("HIGHROOMREWARD", "LIST_TITLE2"), color = TEXT_COLOR, size = 18, align = ui.TEXT_ALIGN_CENTER})
        :pos(-LIST_WIDTH * 0.5 + 256, list_title_pos_y)
        :addTo(self)
    ui.newTTFLabel({text = bm.LangUtil.getText("HIGHROOMREWARD", "LIST_TITLE3"), color = TEXT_COLOR, size = 18, align = ui.TEXT_ALIGN_CENTER})
        :pos(-LIST_WIDTH * 0.5 + 468, list_title_pos_y)
        :addTo(self)
    ui.newTTFLabel({text = bm.LangUtil.getText("HIGHROOMREWARD", "LIST_TITLE4"), color = TEXT_COLOR, size = 18, align = ui.TEXT_ALIGN_CENTER})
        :pos(-LIST_WIDTH * 0.5 + 642, list_title_pos_y)
        :addTo(self)

	self.list_ = bm.ui.ListView.new(
	        {
	            viewRect = cc.rect(-LIST_WIDTH * 0.5, -LIST_HEIGHT * 0.5, LIST_WIDTH, LIST_HEIGHT)
	        }, 
	        HighRoomRewardListItem
	    )
        :pos(-8, -14)
    	:addTo(self)
end

function HighRoomRewardPopup:updateUIFromJson()
    if self.Data_ and self.Data_.list then
        self.list_:setData(self.Data_.list)
    end
end

function HighRoomRewardPopup:loadConfigData()
    bm.HttpService.POST({mod="RecordNum", act="getList"},
        function(data)
            local callData = json.decode(data)
            if callData and callData.code and callData.code > 0 then
                    self.Data_ = callData
                    if self.isShowed then
                        self:updateUIFromJson()
                    end
            end
        end, function()
    end)
end

function HighRoomRewardPopup:onCloseBtnListener_()
    self:hide()
end

function HighRoomRewardPopup:gotoCheckTickets()
    self:hide()
    local pop = UserInfoPopup.new()
    pop:onOpenPropClick_()
    pop:onItemEvent_({name="ITEM_EVENT", type="SEE_PROP"})
    pop:show(false)
end

function HighRoomRewardPopup:onOpenMatch()
    local curScene = display.getRunningScene()
    if curScene.name == "RoomScene" then
        -- 设置当前场景类型全局数据
        bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, 5)
        curScene:doBackToHall()
    elseif curScene.name == "HallScene" then
        curScene.controller_:onEnterMatch()
    end
    self:hide()
end

function HighRoomRewardPopup:onShowed()
    if self.Data_ then
        self:updateUIFromJson()
    end
    self.isShowed = true

    -- 延迟设置，防止list出现触摸边界的问题
    self.list_:setScrollContentTouchRect()
    self.list_:update()
end

function HighRoomRewardPopup:show()
    nk.PopupManager:addPopup(self)
    return self
end

function HighRoomRewardPopup:hide()
    nk.PopupManager:removePopup(self)
    return self
end

function HighRoomRewardPopup:onCleanup()
end

return HighRoomRewardPopup