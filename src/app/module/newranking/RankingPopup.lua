--
-- Author: KevinYu
-- Date: 2014-08-23 20:47:26
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local RankingPopup = class("RankingPopup", nk.ui.Panel)
local RankingListItem = import(".RankingListItem")
local RankingPopupController = import(".RankingPopupController")
local AddFriendPopup = import(".AddFriendPopup")

local SUB_TAB_SPACE = 72
local REFRESH_INTERVAL = 30 --刷新按钮可点击间隔
local POPUP_WIDTH, POPUP_HEIGHT = 815, 520 --弹窗
local LIST_WIDTH, LIST_HEIGHT = 525, 220 --排行榜
local HEAD_W, HEAD_H = 120, 120 --头像宽高
local REWARD_BG_W, REWARD_BG_H = 200, 130 --昨日冠军奖励背景框
local RANKING_BG_W, RANKING_BG_H = 535, 320--排行榜背景框

local CHAMPION_NAME_COLOR = cc.c3b(0xac, 0xac, 0xac)
local CHAMPION_MONEY_COLOR = cc.c3b(0xf4, 0x9a, 0x25)
local CHAMPION_REWARD_COLOR = cc.c3b(0x80, 0x6f, 0xe8)
local GET_REWARD_TIPS_COLOR = cc.c3b(0x89, 0x87, 0xce)

local YESTERDAY_RANKING_COUNT = 20 --昨日排行榜 榜单内总数

function RankingPopup:ctor(mainTab, secondTab)
    RankingPopup.super.ctor(self, {POPUP_WIDTH, POPUP_HEIGHT})

    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    display.addSpriteFrames("ranking_texture.plist", "ranking_texture.png")
    self:setNodeEventEnabled(true)

     --修改背景框
    self:setBackgroundStyle1()

    self:addCloseBtn()
    self:setCloseBtnOffset(0, -16)

    self.controller_ = RankingPopupController.new(self)

    self.isCanRefresh_ = true --是否可以点击刷新按钮，防止频繁操作
    self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id

    self.contentNode_ = display.newNode():pos(-POPUP_WIDTH/2, -POPUP_HEIGHT/2):addTo(self) --内容结点，管理弹窗背景意外的全部UI

    self:addChampionNode_()

    self:addTabNode_()

    if mainTab and mainTab > 0 and mainTab < 3 then
        self.mainTabBar_:gotoTab(mainTab)
    end
    
    if secondTab and secondTab > 0 and secondTab < 5 then
        self.initSecondTab = secondTab
    else
        self.initSecondTab = 1
    end

    self.controller_:requestYesterdayChampionData()
end

function RankingPopup:showUI(data)
    self.championData = data
    self:showChampionNode_(data)
end

--添加昨日盈利榜冠军结点或者昨日大师榜冠军结点（后期添加）
function RankingPopup:addChampionNode_()
    local x = 130
    local bg = self.contentNode_
    --冠军标题
    local title_y = POPUP_HEIGHT - 115
    local str = self:getText_("YESTERDAY_PROFIT_TITLE")
    self.championTitle_ = ui.newTTFLabel({
            text = str,
            color = cc.c3b(0xe6, 0xd7, 0x55),
            size = 18})
        :align(display.TOP_CENTER, x, title_y)
        :addTo(bg)

    --冠军框
    local frame = display.newSprite("#ranking_champion_frame.png")
        :align(display.TOP_CENTER, x, title_y - 30)
        :addTo(bg)
    bm.TouchHelper.new(frame, handler(self, self.onChampionTouch_))

    local frameSize = frame:getContentSize()

    --头像剪裁容器
    local headImgContainer = cc.ClippingNode:create()
    local stencil = display.newScale9Sprite("#common_green_btn_up.png", 0, 0, cc.size(120, 120))
    headImgContainer:setStencil(stencil)
    headImgContainer:setAlphaThreshold(0.05)
    headImgContainer:pos(frameSize.width/2, frameSize.height/2 + 20)
    headImgContainer:addTo(frame, -1)

    --冠军头像
    self.championHead_ = display.newSprite():addTo(headImgContainer)

    --性别
    self.championSex_ = display.newSprite("#ranking_sex_male.png")
        :pos(frameSize.width/2, 8)
        :addTo(frame)

    --姓名
    self.championName_ = ui.newTTFLabel({
            text = "",
            size = 22,
        })
        :pos(x, POPUP_HEIGHT/2 - 65)
        :addTo(bg)
        
    --数值
    self.championValue_ = ui.newTTFLabel({
            text = "",
            color = CHAMPION_MONEY_COLOR,
            size = 22,
        })
        :pos(x, POPUP_HEIGHT/2 - 90)
        :addTo(bg)

    self:addGetChampionReward_()
end

--添加领取冠军奖励结点
function RankingPopup:addGetChampionReward_()
    local bg = self.contentNode_
    local x = 130
    local frame = display.newScale9Sprite("#panel_overlay.png", 0, 0, cc.size(REWARD_BG_W, REWARD_BG_H))
        :align(display.BOTTOM_CENTER, x, 30)
        :addTo(bg)

    local size = frame:getContentSize()
    
    --排名和奖励描述
    local str = self:getText_("PROFIT_REWARD_DESC", nk.userData.rankReward)
    self.championRewardDesc_ = ui.newTTFLabel({
            text = str,
            size = 16,
            color = GET_REWARD_TIPS_COLOR,
            align = ui.TEXT_ALIGN_LEFT,
            valign = ui.TEXT_VALIGN_TOP,
            dimensions = cc.size(400, 200)
        })
        :align(display.LEFT_TOP, 10, size.height - 10)
        :addTo(frame)
        
    self.getRewardBtn_ = cc.ui.UIPushButton.new({normal = "#common_btn_green_normal.png", pressed = "#common_btn_green_pressed.png", disabled = "#common_btn_disabled.png"}, {scale9 = true})
        :setButtonSize(190, 55)
        :setButtonLabel("normal", ui.newTTFLabel({
            text = self:getText_("GET_REWARD_BTN"),
            size = 24,
        }))
        :pos(size.width / 2, 30)
        :scale(0.8)
        :onButtonClicked(handler(self, self.onGetRewardClicked_))
        :addTo(frame)    
        :hide() 
end

function RankingPopup:onChampionTouch_(target, evt)
    if evt == bm.TouchHelper.CLICK then
        AddFriendPopup.new(self.championData):show(self.championData)
    end
end

--添加切换Tab
function RankingPopup:addTabNode_()
    -- 好友榜和总榜切换
    local bg = self.contentNode_ 

    self.mainTabBar_ = nk.ui.CommonPopupTabBar.new(
        {
            popupWidth = POPUP_WIDTH, 
            scale = 458 / POPUP_WIDTH,
            btnText = self:getText_("MAIN_TAB_TEXT"), 
        })
        :pos(POPUP_WIDTH/2, self.height_ - nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5 - 32)
        :addTo(bg, 10)
    self:addTopDivide(nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5)
    self:addTopIcon("#pop_rank_icon.png", -8)

    self:addRankingNode_()
    
    ui.newTTFLabel({
            text = self:getText_("GET_REWARD_TIPS"),
            size = 18,
            color = GET_REWARD_TIPS_COLOR,
            align = ui.TEXT_VALIGN_CENTER,
            dimensions = cc.size(600, 50)
        })
        :align(display.BOTTOM_CENTER, POPUP_WIDTH/2 + 100, 30)
        :addTo(bg)
end

--添加排行榜结点
function RankingPopup:addRankingNode_()
    local bg = self.contentNode_
    --背景框
    local frame = display.newScale9Sprite("#panel_overlay.png", 
        POPUP_WIDTH/2 + 105, POPUP_HEIGHT/2 - 15, cc.size(RANKING_BG_W, RANKING_BG_H)):addTo(bg)

    --总榜子tab
    local rank_X, rank_Y = RANKING_BG_W/2, RANKING_BG_H - 30
    local tab_w, tab_h, off_w, off_h = 500, 44, -8, -8
    self.subTabBarGlobal_ = nk.ui.TabBarWithIndicator.new({
            background = "#popup_sub_tab_bar_bg.png", 
            indicator = "#popup_sub_tab_bar_indicator.png"    
        }, 
        self:getText_("SUB_TAB_TEXT_GLOBAL"),
        {
            selectedText = {color = cc.c3b(0xff, 0xff, 0xff), size = 22},
            defaltText = {color = CHAMPION_REWARD_COLOR, size = 22}
        }, true, true)
        :hide()
        :pos(rank_X, rank_Y)
        :addTo(frame)
    self.subTabBarGlobal_:setTabBarSize(tab_w, tab_h, off_w, off_h)

    --好友榜子tab
    self.subTabBarFriend_ = nk.ui.TabBarWithIndicator.new({
            background = "#popup_sub_tab_bar_bg.png", 
            indicator = "#popup_sub_tab_bar_indicator.png"
        },
        self:getText_("SUB_TAB_TEXT_FRIEND"),
        {
            selectedText = {color = cc.c3b(0xff, 0xff, 0xff), size = 22},
            defaltText = {color = CHAMPION_REWARD_COLOR, size = 22}
        }, true, true)
        :hide()
        :pos(rank_X, rank_Y)
        :addTo(frame)
    self.subTabBarFriend_:setTabBarSize(tab_w, tab_h, off_w, off_h)

    --当前排名
    local refBtnY = RANKING_BG_H - 70
    self.rankingLabel_ = ui.newTTFLabel({
            text = "",
            color = CHAMPION_REWARD_COLOR,
            size = 20,
        })
        :align(display.LEFT_CENTER, 30, refBtnY)
        :hide()
        :addTo(frame)

    --刷新按钮
    self.refreshBtn_ = cc.ui.UIPushButton.new({normal = "#ranking_refresh_btn_normal.png", pressed = "#ranking_refresh_btn_pressed.png"})
        :pos(RANKING_BG_W - 60, refBtnY)
        :onButtonClicked(buttontHandler(self, self.onRefreshClick_))
        :onButtonPressed(function(evt)
            evt.target:setColor(cc.c3b(0xbe, 0xbe, 0xbe))
        end)
        :onButtonRelease(function(evt)
            evt.target:setColor(cc.c3b(0xff, 0xff, 0xff))
        end)
        :hide()
        :addTo(frame)

    display.newSprite("#ranking_refresh_btn_bg.png")
        :addTo(self.refreshBtn_)

    -- 列表
    self.list_ = bm.ui.ListView.new(
        {
            viewRect = cc.rect(-LIST_WIDTH * 0.5, -LIST_HEIGHT * 0.5, LIST_WIDTH, LIST_HEIGHT)
        }, 
        RankingListItem
    )
    :pos(RANKING_BG_W/2, 120)
    :addTo(frame)

    local str = self:getText_("NOT_DATA_TIPS")
    self.notDatatext_ = ui.newTTFLabel({
        text = str,
        color = GET_REWARD_TIPS_COLOR,
        size = 22,
    })
    :pos(RANKING_BG_W/2, 150)
    :hide()
    :addTo(frame)    
end

function RankingPopup:onMainTabChange_(selectedTab)
    self.refreshBtn_:hide()
    self.rankingLabel_:hide()
    self.notDatatext_:hide()

    if selectedTab == 1 then
        self:showAllRankView(selectedTab)
    elseif selectedTab == 2 then
        self:showFriendRankView(selectedTab)
    end

    self.controller_:onMainTabChange(selectedTab)    
end

function RankingPopup:onSubTabChange_(selectedTab)
    self.controller_:onSubTabChange(selectedTab)
end

function RankingPopup:setLoading(isLoading)
    if isLoading then
        self.list_:setData({})
        if not self.juhua_ then
            local y = -60
            self.juhua_ = nk.ui.Juhua.new()
                :pos(120, y)
                :addTo(self)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

function RankingPopup:setListData(data)
    if data then
        self:setLoading(false)
    end

    if data and #data == 0 then
        self.notDatatext_:show()
    else
        self.notDatatext_:hide()
    end

    self.list_:setData(data)
    self:updateCurRankingLabel_(data) 
end

function RankingPopup:onShowed()
    -- 延迟设置，防止list出现触摸边界的问题
    self.mainTabBar_:onTabChange(handler(self, self.onMainTabChange_))
    self.list_:setScrollContentTouchRect()
end

function RankingPopup:show()
    self:showPanel_()
end

--显示总排行
function RankingPopup:showAllRankView(selectedTab)
    if self.subTabBarFriend_ then
        self.subTabBarFriend_:setVisible(false)
    end

    self.subTabBarGlobal_:onTabChange(handler(self, self.onSubTabChange_))
    self.subTabBarGlobal_:gotoTab(self.initSecondTab, true)
    self.subTabBarGlobal_:setVisible(true)
end

--显示好友排行
function RankingPopup:showFriendRankView(selectedTab)
    if self.subTabBarGlobal_ then
        self.subTabBarGlobal_:setVisible(false)
    end

    self.subTabBarFriend_:onTabChange(handler(self, self.onSubTabChange_))
    self.subTabBarFriend_:gotoTab(1, true)
    self.subTabBarFriend_:setVisible(true)
end

function RankingPopup:onExit()
    self.controller_:dispose()
    nk.schedulerPool:delayCall(function()
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end, 0.1)
end

--领取昨日盈利榜奖励
function RankingPopup:onGetRewardClicked_()
    if self.isGotReward then
        self:onShareClicked_()
    else
        self.controller_:getYesterdayReward_()
    end
end

function RankingPopup:onShareClicked_()
    self.getRewardBtn_:setButtonEnabled(false)
    local feedData = clone(bm.LangUtil.getText("FEED", "RANK_REWARD"))
    feedData.name = bm.LangUtil.formatString(feedData.name, self.championData.winsmoney)
    nk.Facebook:shareFeed(feedData, function(success, result)
        if not success then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_FAILED"))
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_SUCCESS"))
        end
        self.getRewardBtn_:setButtonEnabled(true)
    end)
    self.getRewardBtn_:setButtonEnabled(true)
end

--领取昨日盈利榜奖励成功提示
function RankingPopup:showGetRewardSuccess()
    nk.TopTipManager:showTopTip(self:getText_("GET_REWARD_SUCCESS"))
    self.championData.isGetReward = 0
    self:updateRewardBtn()
end

--已经领取昨日盈利榜奖提示
function RankingPopup:showAlreadyGetReward()
    nk.TopTipManager:showTopTip(self:getText_("ALREADY_GET_REWARD"))
    self.championData.isGetReward = 0
    self:updateRewardBtn()
end

--刷新排行
function RankingPopup:onRefreshClick_()
    self.notDatatext_:hide()
    if self.isCanRefresh_ then
        self:setRefreshState_()
        self.controller_:refreshRankingData(self.refreshType_)
    else
        nk.TopTipManager:showTopTip(self:getText_("REFRESH_TIPS"))
    end
    
end

--是否进入当前排行榜
function RankingPopup:isInCurRanking_(rank)
    local uid = nk.userData.uid
    if not rank then
        return false
    end

    for index, rt in ipairs(rank) do
        if rt.uid == uid then
            self.curRankingIndex_ = index
            return true
        end
    end

    return false
end

--更新当前排名描述
function RankingPopup:updateCurRankingLabel_(rank)
    local text = ""
    local isShow = true 
    if self:isInCurRanking_(rank) then
        if RankingPopupController.currentRankingType == 1 then -- 盈利排行
            text = self:getText_("PROFIT_RANKING", self.curRankingIndex_, bm.formatNumberWithSplit(nk.userData.curProfitVal or 0))
            isShow = true
            self.refreshType_ = "earn"
        elseif RankingPopupController.currentRankingType == 3 then -- 资产排行
            local str = bm.formatNumberWithSplit(nk.userData.bank_money + nk.userData.money)
            text = self:getText_("CHIP_RANKING", self.curRankingIndex_, str)
            isShow = false
        elseif RankingPopupController.currentRankingType == 4 then -- 现金币
            text = self:getText_("CASH_RANKING", self.curRankingIndex_, bm.formatNumberWithSplit(nk.userData.score))
            isShow = true
            self.refreshType_ = "mon"
        end
    else
        if RankingPopupController.currentRankingType == 1 then -- 盈利排行
            text = self:getText_("NOT_IN_PROFIT_RANKING", nk.userData.curProfitVal or 0)
            isShow = true
            self.refreshType_ = "earn"
        elseif RankingPopupController.currentRankingType == 3 then -- 资产排行
            local str = bm.formatNumberWithSplit(nk.userData.bank_money + nk.userData.money)
            text = self:getText_("NOT_IN_CHIP_RANKING", str)
            isShow = false  
        end
    end
    
    if isShow then
        self.refreshBtn_:show()
    else
        self.refreshBtn_:hide()
    end
    
    self.rankingLabel_:show()
    self.rankingLabel_:setString(text)
end

function RankingPopup:getText_(key, ...)
    return bm.LangUtil.getText("RANKING", key, ...)
end

--加载昨日盈利榜冠军头像
function RankingPopup:onAvatarLoadComplete_(success, sprite)
    if success then
        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()
        self.championHead_:setTexture(tex)
        self.championHead_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
        self.championHead_:setScaleX(HEAD_W / texSize.width)
        self.championHead_:setScaleY(HEAD_H / texSize.height)
    end
end

--更新昨日冠军信息
function RankingPopup:updateYesterdayChampionInfo_(data)
    --性别
    local sexImg = ""
    local headImg = ""
    if data.sex == "f" then
        sexImg = "ranking_sex_female.png"
        headImg = "common_female_avatar.png"
    else
        sexImg = "ranking_sex_male.png"
        headImg = "common_male_avatar.png"
    end
    self.championSex_:setSpriteFrame(display.newSpriteFrame(sexImg))
    
    local imgurl = data.img
    if imgurl and string.len(imgurl) > 5 then
        if string.find(imgurl, "facebook") then
            if string.find(imgurl, "?") then
                imgurl = imgurl .. "&width=200&height=200"
            else
                imgurl = imgurl .. "?width=200&height=200"
            end
        end
        nk.ImageLoader:loadAndCacheImage(
            self.userAvatarLoaderId_, 
            imgurl, 
            handler(self, self.onAvatarLoadComplete_), 
            nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
        )
    else
        --冠军头像
        self.championHead_:setSpriteFrame(display.newSpriteFrame(headImg))
        self.championHead_:setScale(1.2)
    end
    
    if data.notChampion then
        --姓名
        self.championName_:setString(self:getText_("EXPECT_TIPS"))
        self.championName_:setPositionY(POPUP_HEIGHT/2 - 75)
        --数值
        self.championValue_:setVisible(false)
        self.championSex_:setVisible(false)
    else
        --姓名
        self.championName_:setString(nk.Native:getFixedWidthText("", 22, data.name, 200))
        self.championName_:setPositionY(POPUP_HEIGHT/2 - 65)
        --数值
        self.championValue_:setString(self:getText_("YESTERDAY_PROFIT", "$" .. bm.formatNumberWithSplit(data.value)))
    end

    --排名和奖励描述
    local rewardStr = self:getChampionRewardText_(data.championType, data.rank)
    self.championRewardDesc_:setString(rewardStr)

    -- self.getRewardBtn_:setButtonEnabled(data.rank <= YESTERDAY_RANKING_COUNT)
    self:updateRewardBtn()
end

function RankingPopup:updateRewardBtn()
    self.getRewardBtn_:setButtonEnabled(true)
    if self.championData.isGetReward ~= 1 then
        self.getRewardBtn_:setButtonImage("normal", "#common_btn_blue_normal.png")
        self.getRewardBtn_:setButtonImage("pressed", "#common_btn_blue_pressed.png")
        self.getRewardBtn_:setButtonLabelString(bm.LangUtil.getText("COMMON", "SHARE"))
        self.isGotReward = true
    else
        self.isGotReward = false
    end
    if self.championData.rank  <= YESTERDAY_RANKING_COUNT then
        self.getRewardBtn_:show()
    end
end

--显示冠军结点，加载完数据后再显示
function RankingPopup:showChampionNode_(data)
    self.contentNode_:show()
    self:updateYesterdayChampionInfo_(data)
end

--设置刷新可点击
function RankingPopup:setRefreshState_()
    self.isCanRefresh_ = false
    nk.schedulerPool:delayCall(function()
        self.isCanRefresh_ = true
    end, REFRESH_INTERVAL)
end

--获取冠军奖励描述 昨日盈利championType : 1 昨日盈利 
function RankingPopup:getChampionRewardText_(championType, rank)
    local rewardStr = ""
    if championType == 1 then
        if rank <= YESTERDAY_RANKING_COUNT then
            rewardStr = self:getText_("GET_REWARD_DESC", tostring(rank), nk.userData.rankReward)
        else
            rewardStr = self:getText_("PROFIT_REWARD_DESC", nk.userData.rankReward)
        end
    end

    return rewardStr
end

return RankingPopup