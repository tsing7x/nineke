--
-- Author: KevinYu
-- Date: 2017-05-05 12:52:48
-- ActivityCenterItem

local DiscountInfoPopup     = import("app.module.newestact.DiscountInfoPopup")
local FootballQuizPopup     = import("app.module.football.FootballQuizPopup")
local ActivityRankingPopup  = import("app.module.newestact.template.ranking.ActivityRankingPopup")

local ACT_PATH = device.writablePath .. "cache/act" .. device.directorySeparator

local ActivityCenterItem = class("ActivityCenterItem", function ()
    return display.newNode()
end)

function ActivityCenterItem:ctor(popup)
	self:setNodeEventEnabled(true)

	self.popup_ = popup

	local btn = cc.ui.UIPushButton.new("activity/activity_item_bg.png")
        :onButtonClicked(buttontHandler(self, self.onActivityClicked))
        :addTo(self)

    btn:setTouchSwallowEnabled(false)

    self.icon_ = display.newSprite():addTo(btn)
    
    self.iconLoaderId_ = nk.ImageLoader:nextLoaderId()
    self.isLoadImg_ = true

    local curScene = display.getRunningScene()
    if curScene.name == "HallScene" then
        if curScene.controller_ then
            self.hall_controller_ = curScene.controller_
        end
    end
end

function ActivityCenterItem:setData(data, cdn)
	self.data_ = data
    self.cdn_ = cdn
	local url = cdn .. data.bannerImg

	nk.ImageLoader:loadAndCacheImage(
		  self.iconLoaderId_, 
		  url, 
		  handler(self, self.onBannerLoadComplete_),
		  nk.ImageLoader.CACHE_TYPE_ACT
	)
	
	return self
end

--goto: 跳转ID
-- 1 => '普通场',
-- 2 => '中级场',
-- 3 => '高级场',
-- 4 => '比赛场大厅',
-- 5 => '快速开始',
-- 6 => '好友弹窗',
-- 7 => '邀请页面',
-- 8 => '打开大转盘',
-- 9 => '打开礼物弹窗',
-- 10 => '打开老虎机',
-- 11 => '打开宝箱',
-- 12 => '彩票页面',
-- 13 => '足球彩票页面',
-- 14 => '博定场',
-- 15 => '广告信息',
-- 16 => '商店',
-- 17 => '水灯节',

function ActivityCenterItem:onActivityClicked()
	if not self.isLoadTexture_ then
        return
    end
    
    self.popup_:addActivityStat(self.data_.doActTj, self.data_.id, 1)

    DiscountInfoPopup.new(self.backgroundImg_, "", handler(self, function(self)
        
        self.popup_:addActivityStat(self.data_.doActTj, self.data_.id, 2)

        local data = self.data_
        local actType = data.goto
        if actType == 1 or actType == 2 or actType == 3 then
            if self.hall_controller_ then
                local last = nil
                if nk.userData.lastChooseRoomType then
                    last = nk.userData.lastChooseRoomType
                    if (last == self.hall_controller_.CHOOSE_4K_VIEW or last == self.hall_controller_.CHOOSE_5K_VIEW) 
                            and actType == 1 then
                        last = self.hall_controller_.CHOOSE_PRO_VIEW
                    end
                end
                self.hall_controller_:showChooseRoomView(last 
                    or self.hall_controller_.CHOOSE_PRO_VIEW, actType)
            end
        elseif actType == 4 then
            if self.hall_controller_ then
                self.hall_controller_:onEnterMatch()
            end
        elseif actType == 5 then
            if self.hall_controller_ then
                self.hall_controller_:getEnterRoomData(nil, true)
            end
        elseif actType == 6 then
            local FriendPopup = import("app.module.friend.FriendPopup")
            FriendPopup.new():show()
        elseif actType == 7 then
            local InvitePopup = import("app.module.friend.InvitePopup")
            InvitePopup.new():show()
        elseif actType == 8 then
            local HallController = import("app.module.hall.HallController")
            local LuckWheelFreePopup = import("app.module.luckturn.LuckWheelFreePopup")
            LuckWheelFreePopup.load(self.hall_controller_, HallController.MAIN_HALL_VIEW)
        elseif actType == 9 then
            local GiftShopPopup = import("app.module.gift.GiftShopPopup")
            GiftShopPopup.new(2):show(false, nk.userData.uid)
        elseif actType == 10 then
            if self.hall_controller_ then
                self.hall_controller_:showSlotPopup()
            end
        elseif actType == 11 then
            local CrazedBoxPopup = import("app.module.crazedbox.CrazedBoxPopup")
            display.addSpriteFrames("crazed_box_texture.plist", "crazed_box_texture.png",function()
                CrazedBoxPopup.new():show()
            end)
        elseif actType == 12 then
            local LotteryPopup = import("app.module.lottery.LotteryPopup")
            LotteryPopup.new():show()
        elseif actType == 13 then
            local FootballQuizPopup = import("app.module.football.FootballQuizPopup")
            display.addSpriteFrames("football_quiz_texture.plist", "football_quiz_texture.png", function()
                FootballQuizPopup.new():showPanel()
            end)
        elseif actType == 14 then
            if self.hall_controller_ then
                self.hall_controller_:showChooseRoomView(self.hall_controller_.CHOOSE_PDENG_VIEW, actType)
            end
        elseif actType == 15 then
            device.openURL(data.jumpurl)
        elseif actType == 16 then
            local StorePopup = import("app.module.newstore.StorePopup")
            StorePopup.new(nil, tostring(data.jumpurl)):showPanel()
        elseif actType == 17 then
            local WaterLampPopup = import("app.module.waterLamp.waterLampPopup")
            WaterLampPopup.new():show()
        end

        self.popup_:hide()

    end)):show()
end

function ActivityCenterItem:onImgZipLoadComplete_(success)
    if success then
    	local data = self.data_
    	local img = ACT_PATH .. "Desktop" .. "/" .. data.name
	    local tex = cc.Director:getInstance():getTextureCache():addImage(img)
	    local texSize = tex:getContentSize()
        self.icon_:setTexture(tex)
        self.icon_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))

        self.isLoadTexture_ = true
    end
end

function ActivityCenterItem:onBannerLoadComplete_(success, sprite, loadId)
    if success then

        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()
        self.icon_:setTexture(tex)
        self.icon_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))        
        
        if self.data_.backgroundImg ~= "" then    --加载背景
            local url = self.cdn_ .. self.data_.backgroundImg
            self.iconLoaderId_ = nk.ImageLoader:nextLoaderId()
            nk.ImageLoader:loadAndCacheImage(
                self.iconLoaderId_, 
                url, 
                handler(self, self.onBgLoadComplete_),
                nk.ImageLoader.CACHE_TYPE_ACT
            )
        else
            self.isLoadTexture_ = true
        end
    end
end

function ActivityCenterItem:onBgLoadComplete_(success, sprite, loadId)
    if success then
        self.backgroundImg_ = sprite:getTexture()
        self.isLoadTexture_ = true
    end
end

function ActivityCenterItem:onCleanup()
    nk.ImageLoader:cancelJobByLoaderId(self.iconLoaderId_)
end

return ActivityCenterItem