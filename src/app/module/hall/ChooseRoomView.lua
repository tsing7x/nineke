-- 普通场 两张场 选场界面
--
-- Author: Johnny Lee
-- Date: 2014-08-07 23:22:07
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local ChooseRoomView = class("ChooseRoomView", function ()
    return display.newNode()
end)


local StorePopup = import("app.module.newstore.StorePopup")
local FirstPayPopup = import("app.module.firstpay.FirstPayPopup")
local GuidePayPopup = import("app.module.firstpay.GuidePayPopup")
local HelpPopup = import("app.module.settingAndhelp.SettingAndHelpPopup")
local HallSearchRoomPanel = import("app.module.hall.HallSearchRoomPanel")

local ChooseRoomChip = import(".ChooseRoomChip")
local ChooseDiceRoomChip = import(".ChooseDiceRoomChip")
local ChoosePdengRoomChip = import(".ChoosePdengRoomChip")

ChooseRoomView.PLAYER_LIMIT_SELECTED = 2   -- 1：9人场； 2：5人场
ChooseRoomView.ROOM_LEVEL_SELECTED   = nil -- 1：初级场；2：中级场；3：高级场

ChooseRoomView.COIN_ROOM_SELECTED = 1
ChooseRoomView.COIN_ROOM_TYPE = 1
ChooseRoomView.GCOIN_ROOM_TYPE = 2

local ROOM_TYPE_NOR = 1
local ROOM_TYPE_PRO = 2
local ROOM_TYPE_4K = 3
local ROOM_TYPE_5K = 4
local ROOM_TYPE_DICE = 5
local ROOM_TYPE_PDENG = 6
local TOP_BUTTOM_WIDTH   = 102
local TOP_BUTTOM_HEIGHT  = 75
local TOP_BUTTOM_PADDING = 0
local TOP_BUTTOM_PADDING_Y = 15
local TOP_TAB_BAR_WIDTH  = 612
local TOP_TAB_BAR_HEIGHT = 66
local CHIP_HORIZONTAL_DISTANCE = 240 * nk.widthScale
local CHIP_VERTICAL_DISTANCE   = 216 * nk.heightScale

--顶部操作栏，相关数据
local top_frame_h = 105 --顶部背景框高度
local select_btn_w = 162 --选场按钮宽度
local select_btn_x = (select_btn_w/2 + 100) * 960/1140 * nk.widthScale --选场场按钮x位置,右边取负的
local select_btn_y = display.cy - top_frame_h/2 + 8 --选场按钮y位置
local middleFrameW = 53 --中间框箭头 部分 宽度不拉伸，保持原图快读
local leftFrameW = display.width/2 - select_btn_x - middleFrameW/2 --左边框宽度
local rightFrameW = display.width/2 + select_btn_x - middleFrameW/2 --右边框宽度
local frame_y = display.cy - top_frame_h/2 --背景框位置y
local light_y = frame_y - 10 --选中场次类型 灯光位置
local TOP_BTN_BG_ZORDER = -102 --UIPushButton 按钮图片的默认深度为-100, 要让背景框在按钮图片下面

function ChooseRoomView:ctor(controller, viewType, tabIndex,isCoin)
    if isCoin then
        ChooseRoomView.COIN_ROOM_SELECTED = 2
    else
        ChooseRoomView.COIN_ROOM_SELECTED = 1
    end

    self.animIsEnd_ = false
    self.controller_ = controller
    self.controller_:setDisplayView(self)

    self.controller_:getCurDealerId()
    
    self:setNodeEventEnabled(true)
    self.isChangeRoomViewType_ = false --是否是在切换房间类型,区分playShowAnim时机，目前只有初始化的时候为false
    self.viewType_ = viewType

    -- 默认是中级场
    nk.gameState.roomLevel = 'middle'

    -- 桌子
    self.pokerTable_ = display.newNode():pos(0, -(display.cy + 100)):addTo(self):scale(self.controller_:getBgScale() + 0.1)
    display.newSprite("#main_hall_table.png")
        :align(display.RIGHT_CENTER, 2, 0)
        :addTo(self.pokerTable_)
    
    display.newSprite("#main_hall_table.png")
        :flipX(true)
        :align(display.LEFT_CENTER, -2, 0)
        :addTo(self.pokerTable_)
        
    --添加顶部按钮结点
    self:addTopNode_()

    self:updateStoreIcon()

    -- 在玩人数
    self.playerCount_ = display.newSprite("#player_count_icon.png")
        :align(display.RIGHT_CENTER, -108, display.cy * 0.54)
        :addTo(self)
        :hide()

    local playerCountSize = self.playerCount_:getContentSize()
    self.userOnline_ = ui.newTTFLabel({
        text = bm.LangUtil.getText("HALL", "USER_ONLINE", 0),
        color = cc.c3b(0xa5, 0xef, 0xaf),
        size = 24, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER, playerCountSize.width / 2 + 20, playerCountSize.height/2)
        :addTo(self.playerCount_) 

    local topTabTxt = clone(bm.LangUtil.getText("HALL", "ROOM_LEVEL_TEXT_NOCOINROOM"))

    if (nk.userData.gcoinsonoff and nk.userData.gcoinsonoff == 1) then
        if nk.userData.gcoinstypeonoff then --gcoinstypeonoff     0全开，1只开普通场，2只开专业场
            if nk.userData.gcoinstypeonoff == 0 then
                topTabTxt = clone(bm.LangUtil.getText("HALL", "ROOM_LEVEL_TEXT"))
            elseif nk.userData.gcoinstypeonoff == 1 and viewType == self.controller_.CHOOSE_NOR_VIEW then
                topTabTxt = clone(bm.LangUtil.getText("HALL", "ROOM_LEVEL_TEXT"))
            elseif nk.userData.gcoinstypeonoff == 2 and viewType == self.controller_.CHOOSE_PRO_VIEW then
                topTabTxt = clone(bm.LangUtil.getText("HALL", "ROOM_LEVEL_TEXT"))
            end
        end
    else
        if ChooseRoomView.ROOM_LEVEL_SELECTED == 4 then
            ChooseRoomView.ROOM_LEVEL_SELECTED = nk.userData.DEFAULT_TAB or 1
        end
    end

    if BM_UPDATE.MATCHMALL and BM_UPDATE.MATCHMALL == 0 then
        topTabTxt = clone(bm.LangUtil.getText("HALL", "ROOM_LEVEL_TEXT_NOCOINROOM"))
    end

    if viewType == self.controller_.CHOOSE_4K_VIEW then
        self.is4k_ = true
    end

    if viewType == self.controller_.CHOOSE_5K_VIEW then
        self.is5k_ = true
    end

    self:dealDefaultType_()

    -- 分割线
    self.splitLine_ = display.newScale9Sprite("#choose_room_split_line.png", 0, 0, cc.size(960 / 1140 * 960, 2))
        :pos(0, display.cy * 0.45)
        :opacity(0)
        :addTo(self)
    self.splitLine_:setScaleX(nk.widthScale * 0.9)

    -- 顶部tab bar
    if ChooseRoomView.ROOM_LEVEL_SELECTED == nil then
        ChooseRoomView.ROOM_LEVEL_SELECTED = tabIndex or nk.userData.DEFAULT_TAB or 1
        if viewType == self.controller_.CHOOSE_4K_VIEW and tabIndex and tabIndex > 1 then
            ChooseRoomView.ROOM_LEVEL_SELECTED = tabIndex - 1
        end
        if viewType == self.controller_.CHOOSE_5K_VIEW and tabIndex and tabIndex > 1 then
            ChooseRoomView.ROOM_LEVEL_SELECTED = tabIndex - 1
        end
    end
    
    if ChooseRoomView.ROOM_LEVEL_SELECTED and ChooseRoomView.ROOM_LEVEL_SELECTED > #topTabTxt then
        ChooseRoomView.ROOM_LEVEL_SELECTED = #topTabTxt
    end

    self.chipBtnNode_ = display.newNode()
        :addTo(self)

    self.db_node = display.newNode()
        :addTo(self.chipBtnNode_)

    --楼下2个坑爹的变量专门为博定选场界面制定，共用一套飞出动画
    --他们的ITEM间距和Y值有点不一样。将就一下了。。
    self.tempVetical_d = 0
    self.tempYGrap_ = 0
    -- 筹码,底注选择
    self.chips_ = {}
    local chipTextColors = {
        cc.c3b(0x37, 0x88, 0x1c),
        cc.c3b(0xCA, 0x7C, 0x2C),
        cc.c3b(0x2F, 0x88, 0xE1),
        cc.c3b(0xBB, 0x06, 0x06),
        cc.c3b(0xAD, 0x22, 0x9C),
        cc.c3b(0xED, 0x61, 0x06),
    }
    if viewType == self.controller_.CHOOSE_DICE_VIEW then
        for i = 1, 3 do
            self.chips_[i] = ChooseDiceRoomChip.new(i, chipTextColors[i])
                :pos(((i - 1) % 3 - 1) * CHIP_HORIZONTAL_DISTANCE, CHIP_VERTICAL_DISTANCE - display.cy - 240)
                :addTo(self.chipBtnNode_)
                :onChipClick(handler(self, self.onChipClick_))
        end
    elseif viewType == self.controller_.CHOOSE_PDENG_VIEW then
        self.tempVetical_d = 80
        self.tempYGrap_ = 65

        self.splitLine_:hide()
        self.pdengBg_ = {} --装背景的
        self.pdengPlayerCountArr_ = {}--装在线玩家数字的
        self.pdengPlayerIconArr= {}--装在线玩家icon的
        for i = 1,3 do 
           self.pdengBg_[i] = display.newSprite("#choosePdengRoom_bg_"..i..".png")
            :addTo(self.chipBtnNode_)
            :pos((i-2) * CHIP_HORIZONTAL_DISTANCE,
                (math.floor((6 - i) / 3) - 1) * CHIP_VERTICAL_DISTANCE - display.cy - 81 + 346)

            self.pdengPlayerIconArr[i]=display.newSprite("#choose_room_pdeng_num_1.png")
            :align(display.LEFT_CENTER)
            :addTo(self.chipBtnNode_)
            :hide()
            :pos((i-2) * CHIP_HORIZONTAL_DISTANCE-30,
                (math.floor((6 - i) / 3) - 1) * CHIP_VERTICAL_DISTANCE - display.cy - 81 + 460)

            self.pdengPlayerCountArr_[i] = ui.newTTFLabel({text = "", color = cc.c3b(0x4d, 0x7e, 0x3b), size = 18, align = ui.TEXT_ALIGN_CENTER})
            :align(display.LEFT_CENTER)
            :addTo(self.chipBtnNode_)
            :hide()
            :pos((i-2) * CHIP_HORIZONTAL_DISTANCE,
                (math.floor((6 - i) / 3) - 1) * CHIP_VERTICAL_DISTANCE - display.cy - 81 + 460)

        end
        for i = 1, 6 do
            self.chips_[i] = ChoosePdengRoomChip.new(i, chipTextColors[i])
                :pos(((i - 1) % 3 - 1) * CHIP_HORIZONTAL_DISTANCE, 
                    (math.floor((6 - i) / 3) - 1) * CHIP_VERTICAL_DISTANCE - display.cy - 81)
                :addTo(self.chipBtnNode_)
                :onChipClick(handler(self, self.onChipClick_))
            if i > 3 then
                self.chips_[i]:setIsGrabDealer(true)
            end
        end
    else
        for i = 1, 6 do
            self.chips_[i] = ChooseRoomChip.new(i, chipTextColors[i])
                :pos(((i - 1) % 3 - 1) * CHIP_HORIZONTAL_DISTANCE,
                    (math.floor((6 - i) / 3) - 1) * CHIP_VERTICAL_DISTANCE - display.cy - 81)
                :addTo(self.chipBtnNode_)
                :onChipClick(handler(self, self.onChipClick_))
        end
    end

    self.defaultTopTabTxt_ = topTabTxt
    self.topTabBar_ = self:addTopTabBar_(self.defaultTopTabTxt_, 550, handler(self, self.onTopTabChange_))
    self.topGcoinTabBar_ = display.newSprite("#choose_room_type_gcoin_title.png"):addTo(self.topBtnNode_):pos(0, display.cy - 56 - TOP_TAB_BAR_HEIGHT * 0.5)
    self.topGcoinTabBar_:hide()
    self:addGCoinChooseTab_()
    self:addRightChooseTab_()

    -- 添加数据观察器
    self:addPropertyObservers()

    --更新视图 普通场和专业场
    self:updateView_(viewType)
end

function ChooseRoomView:addTopTabBar_(topTabTxt, dw, onChangeCallback)
    dw = dw or 550
    local tabBar = nk.ui.TabBarWithIndicator.new(
        {
            background = "#choose_room_level_tab_bar_bg.png",
            indicator = "#choose_room_level_tab_bar_indicator.png"
        },
        topTabTxt,
        {
            selectedText = {color = styles.FONT_COLOR.LIGHT_TEXT, size = 26},
            defaltText = {color = cc.c3b(0x78, 0x76, 0x85), size = 26}
        },
        true,
        true)
        :setTabBarSize(dw, 69, -8, -8)
        :pos(0, display.cy - 56 - TOP_TAB_BAR_HEIGHT * 0.5)
        :addTo(self.topBtnNode_)
    tabBar:onTabChange(onChangeCallback)

    return tabBar
end

-- 右边tab bar
function ChooseRoomView:addRightChooseTab_()
    local background = display.newNode()
    local bg = display.newSprite("#choose_room_player_limit_tab_bar_bg.png")
    :addTo(background)
    :pos(0, 2)
    bg:setAnchorPoint(cc.p(0.5, 0))

    bg = display.newSprite("#choose_room_player_limit_tab_bar_bg.png")
    :addTo(background)
    :pos(0, 2)
    bg:setScaleY(-1)
    bg:setAnchorPoint(cc.p(0.5, 0))

    local sz = bg:getContentSize()
    background:setContentSize(sz.width, sz.height*2)
    self.rightTabBar_ = nk.ui.TabBarWithIndicator.new(
        {
            background = background,
            indicator = "#choose_room_player_limit_tab_bar_indicator.png"
        },
        bm.LangUtil.getText("HALL", "PLAYER_LIMIT_TEXT"),
        {
            selectedText = {color = cc.c3b(0xff, 0xff, 0xff), size = 32},
            defaltText = {color = cc.c3b(0x12, 0x58, 0x2f), size = 32}
        },
        false,
        true,
        nk.ui.TabBarWithIndicator.VERTICAL)
        :pos(display.cx + 72, -CHIP_VERTICAL_DISTANCE * 0.5 + 40 * nk.heightScale)
        :addTo(self)
    -- 设置筹码后，绑定初/中/高 场次切换的回调 tab change回调    
    self.rightTabBar_:onTabChange(handler(self, self.onRightTabChange_))
end

-- 黄金币入口Tab
function ChooseRoomView:addGCoinChooseTab_()
    local background = display.newNode()
    local bg = display.newSprite("#choose_room_type_tabBg.png")
    :addTo(background)
    :pos(0, 2)
    bg:setAnchorPoint(cc.p(0.5, 0))

    bg = display.newSprite("#choose_room_type_tabBg.png")
    :addTo(background)
    :pos(0, 2)
    bg:setScaleY(-1)
    bg:setAnchorPoint(cc.p(0.5, 0))

    local sz = bg:getContentSize()
    background:setContentSize(sz.width, sz.height*2)
    local images = {
        background = background,
        indicator="#choose_room_type_tab.png",
    }
    local iconCfg = {
        {upRes="choose_room_type_coin_up.png", downRes="choose_room_type_coin_down.png"},
        {upRes="choose_room_type_gcoin_up.png", downRes="choose_room_type_gcoin_down.png"}        
    }
    self.leftTabBar_ = nk.ui.TabBarWithIndicator.new(
        images,
        {"", ""},
        nil,
        false,
        true,
        nk.ui.TabBarWithIndicator.VERTICAL)
        :pos(-display.cx - 72, -CHIP_VERTICAL_DISTANCE * 0.5 + 40 * nk.heightScale)
        :addTo(self, 2)
        :hide()
    self.leftTabBar_:setButtonIcons(iconCfg)
    self.leftTabBar_:onTabChange(handler(self, self.onLeftTabChange_))
end

function ChooseRoomView:onLeftTabChange_(selectedTab)
    ChooseRoomView.COIN_ROOM_SELECTED = selectedTab
    if selectedTab == 1 then
        self.topTabBar_:show()
        self.topGcoinTabBar_:hide()
        
        local topSelectedTab = self.topTabBar_:getSelectedTab()
        if topSelectedTab then
            self:onTopTabChange_(topSelectedTab)
        end
    else
        self.topTabBar_:hide()
        self.topGcoinTabBar_:show()

        local idx = self:getGCoinIndex()
        if idx then
            self:onTopTabChange_(idx)
        end
    end
end

function ChooseRoomView:dealDefaultType_()
    if not nk.userData.sbGuide then return end
    local curList = nil
    local attribute="money"
    if self.is4k_ then 
        curList = nk.userData.sbGuide["k4"]
    elseif self.is5k_ then
        curList = nk.userData.sbGuide["k5"]
    else
        curList = nk.userData.sbGuide["normal"]
    end
    if ChooseRoomView.ROOM_LEVEL_SELECTED==4 then
        curList = nk.userData.sbGuide["gold"]
        attribute = "gcoins"
    end
    if not curList or #curList<1 then return end

    local chipsList = {}  -- 统计底注  有重复的
    for k,v in ipairs(curList) do
        local rang = v.rang
        local sb = v.sb --推荐底注房间，有2个
        if nk.userData[attribute]>=rang[1] and nk.userData[attribute]<=rang[2] then
            table.insertto(chipsList,sb)
            table.sort(chipsList)
            -- 删除重复的
            local check = {}
            local index = 0  -- 匹配索引号 
            for m, n in ipairs(chipsList) do
                if not check[n] then
                    check[n] = true
                    index = index + 1
                    if sb and sb[1]==n then  -- 优先推荐第一个
                        break
                    end
                end
            end
            nk.userData.DEFAULT_TAB = math.ceil(index/6)--根据资产计算默认tab，显示对应等级房间选择
            break
        else
            table.insertto(chipsList,sb)
        end
    end

    if ChooseRoomView.ROOM_LEVEL_SELECTED ~= 4 then
        ChooseRoomView.ROOM_LEVEL_SELECTED = nil
    end

    if self.is4k_ then
        ChooseRoomView.ROOM_LEVEL_SELECTED = nil
    end

    if self.is5k_ then
        ChooseRoomView.ROOM_LEVEL_SELECTED = nil
    end
end

--更新视图 普通场和专业场
function ChooseRoomView:updateView_(viewType)
    if viewType == self.controller_.CHOOSE_NOR_VIEW then
        self.roomType_ = ROOM_TYPE_NOR
        if self.roomTypeIcon_ then
            self.roomTypeIcon_:removeFromParent()
        end
        self.roomTypeIcon_ = display.newSprite("#choose_room_nor_icon.png")
    elseif viewType == self.controller_.CHOOSE_PRO_VIEW then
        self.roomType_ = ROOM_TYPE_PRO
        if self.roomTypeIcon_ then
            self.roomTypeIcon_:removeFromParent()
        end
        self.roomTypeIcon_ = display.newSprite("#choose_room_pro_icon.png")
    elseif viewType == self.controller_.CHOOSE_4K_VIEW then
        self.roomType_ = ROOM_TYPE_4K
        if self.roomTypeIcon_ then
            self.roomTypeIcon_:removeFromParent()
        end
        self.roomTypeIcon_ = display.newSprite("#choose_room_4k_icon.png")

        if nk.userData.fourktable == 1 then
            ChooseRoomView.PLAYER_LIMIT_SELECTED = 2
            self.rightTabBar_:hide()
        elseif nk.userData.fourktable == 2 then
            ChooseRoomView.PLAYER_LIMIT_SELECTED = 1
            self.rightTabBar_:hide()
        elseif nk.userData.fourktable == 3 then
            self.rightTabBar_:show()
        end
    elseif viewType == self.controller_.CHOOSE_5K_VIEW then
        self.roomType_ = ROOM_TYPE_5K
        if self.roomTypeIcon_ then
            self.roomTypeIcon_:removeFromParent()
        end
        self.roomTypeIcon_ = display.newSprite("#choose_room_5k_icon.png")
    elseif viewType == self.controller_.CHOOSE_DICE_VIEW then
        self.roomType_ = ROOM_TYPE_DICE
        ChooseRoomView.PLAYER_LIMIT_SELECTED = 1
        ChooseRoomView.ROOM_LEVEL_SELECTED = 1
        if self.roomTypeIcon_ then
            self.roomTypeIcon_:removeFromParent()
        end
        self.roomTypeIcon_ = display.newSprite("#choose_room_dice_icon.png")
    elseif viewType == self.controller_.CHOOSE_PDENG_VIEW then
        self.roomType_ = ROOM_TYPE_PDENG
        ChooseRoomView.PLAYER_LIMIT_SELECTED = 1
        ChooseRoomView.ROOM_LEVEL_SELECTED = 1
        if self.roomTypeIcon_ then
            self.roomTypeIcon_:removeFromParent()
        end
        self.roomTypeIcon_ = display.newSprite("#choose_room_pdeng_icon.png")
    end
    nk.gameState.roomType = self.roomType_
    self.roomTypeIcon_:align(display.LEFT_CENTER, -(display.cx + self.roomTypeIcon_:getContentSize().width), -CHIP_VERTICAL_DISTANCE * 0.5 + 40 * nk.heightScale)
        :addTo(self)

    nk.userData.lastChooseRoomType = viewType --在房间选择界面返回，未进入房间，记录是普通场还是专业场

    -- 设置当前场景类型全局数据
    bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, viewType) --进入房间以后，记录是普通场还是专业场

    self.topTabBar_:gotoTab(ChooseRoomView.ROOM_LEVEL_SELECTED, true)
    self.rightTabBar_:gotoTab(ChooseRoomView.PLAYER_LIMIT_SELECTED, true)
    self.leftTabBar_:gotoTab(ChooseRoomView.COIN_ROOM_SELECTED, true)

    self.iconOffX_ = 60
    if self:isShowGCoinTab() then
        self.leftTabBar_:show()
    else
        self.leftTabBar_:gotoTab(1, true)
    end

    self.leftTabBar_:hide()
    if viewType == self.controller_.CHOOSE_DICE_VIEW then
        self:hideTabBar_("#choose_room_dice_title.png")
        self:setDiceRoomChips()
    elseif viewType == self.controller_.CHOOSE_PDENG_VIEW then
        self:hideTabBar_("#choose_room_pdeng_title.png")
        self:setPdengRoomChips()
    elseif viewType == self.controller_.CHOOSE_4K_VIEW then
        self:hideTabBar_("choose_room_4k_title.png")
        self.rightTabBar_:show()
    elseif viewType == self.controller_.CHOOSE_5K_VIEW then
        self:hideTabBar_("choose_room_5k_title.png")
        self.rightTabBar_:show()
    end
end

function ChooseRoomView:hideTabBar_(img)
    self.topTabBar_:hide()
    self.leftTabBar_:hide()
    self.rightTabBar_:hide()
    self.topGcoinTabBar_:hide()

    display.newSprite(img)
        :pos(0, display.cy - 56 - TOP_TAB_BAR_HEIGHT * 0.5)
        :addTo(self.topBtnNode_)
end

function ChooseRoomView:setDiceRoomChips()
    -- 给筹码设置前注
    for i, chip in ipairs(self.chips_) do
        local preCall = nk.userData.tableConf[self.roomType_][i][1][1]
        local baseBuy = nil
        if nk.userData.tableBaseBuy then
            baseBuy = nk.userData.tableBaseBuy[self.roomType_][i][1][1]
        end
        if preCall then
            if baseBuy then 
                chip:setPreCall(preCall, 0, baseBuy)
            else
                chip:setPreCall(preCall)
            end
            chip:show()
        else
            chip:hide()
        end
    end
end

function ChooseRoomView:setPdengRoomChips()
    -- 给筹码设置前注
    local roomType_ = self.roomType_
    for i, chip in ipairs(self.chips_) do
        local preCall = nk.userData.tableConf[roomType_][i][1][1]
        local baseBuy = nil
        if nk.userData.tableBaseBuy then
            baseBuy = nk.userData.tableBaseBuy[roomType_][i][1][1]
        end
        if preCall then
            if baseBuy then 
                chip:setPreCall(preCall, 0, baseBuy)
            else
                chip:setPreCall(preCall)
            end
            chip:show()
        else
            chip:hide()
        end
    end
end

-- 判断是否黄金币场
function ChooseRoomView:isShowGCoinTab()
    local total = 0
    local roomType_ = self.roomType_
    local list = nk.userData.tableConf[roomType_][4]
    if not list then
        return 
    end
    if list then
        for _,v in pairs(list) do
            if v then
                for _,k in pairs(v) do
                    total = total + k
                end
            end
        end
    end

    if total == 0 then
        return false
    else
        return true
    end
end

function ChooseRoomView:getGCoinIndex()
    local idx = 0
    local total = 0
    local roomType_ = self.roomType_
    local list = nk.userData.tableConf[roomType_]
    for i=1,#list do
        total = 0
        for j=1,#list[i] do
            for k=1,#list[i][j] do
                total = total + list[i][j][k]
            end
        end

        if total > 0 then
            idx = idx + 1
        end

        if i == 4 and total > 0 then
            return idx
        end
    end

    return nil
end

function ChooseRoomView:updateStoreIcon()
    -- 商城
    if self.storeNode_ then
        self.storeNode_:removeAllChildren()
    else
        self.storeNode_ = display.newNode()
        self.storeNode_:pos(display.cx - TOP_BUTTOM_WIDTH * 0.5 - TOP_BUTTOM_PADDING, display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING_Y)
            :addTo(self.topBtnNode_)
    end

    -- local onsaletime_ = nk.OnOff:getCurrentTime(nk.OnOff.onsaleCountDownTimerId)
    -- if onsaletime_ and onsaletime_ > 0 then
    --     cc.ui.UIPushButton.new({normal = {"#guidepay_discount_normal.png"}, pressed = {"#guidepay_discount_pressed.png"}})
    --         :addTo(self.storeNode_)
    --         :onButtonClicked(buttontHandler(self, self.onSaleGoodsPayClick_))

    --     ui.newTTFLabel({text="+50%", size=18, color = cc.c3b(0xff, 0xed, 0x23)})
    --         :pos(0, 15)
    --         :addTo(self.storeNode_)

    --     self.onsaleTimeText_ = ui.newTTFLabel({text = "", size = 20, align = ui.TEXT_ALIGN_CENTER})
    --         :pos(0, -20)
    --         :addTo(self.storeNode_)

    --     self.onsaleTimeText_:runAction((cc.RepeatForever:create(transition.sequence({
    --         cc.CallFunc:create(function()
    --             local onsaletime_ = nk.OnOff:getCurrentTime(nk.OnOff.onsaleCountDownTimerId)
    --             if onsaletime_ > 0 then
    --                 self.onsaleTimeText_:setString(bm.TimeUtil:getTimeString(onsaletime_))
    --             else
    --                 self.onsaleTimeText_:stopAllActions()
    --                 self:updateStoreIcon()
    --             end
    --         end),
    --         cc.DelayTime:create(1.0)
    --     }))))
    -- elseif nk.userData.firstPay then
    --     cc.ui.UIPushButton.new({normal = "#common_first_pay_normal.png", pressed = "#common_first_pay_pressed.png"})
    --         :addTo(self.storeNode_)
    --         :onButtonClicked(buttontHandler(self, self.onFirstPayClick_))
    -- else
        cc.ui.UIPushButton.new({normal = {"#common_btn_bg_normal.png","#top_store_btn_normal.png"}, pressed = {"#common_btn_bg_pressed.png","#top_store_btn_pressed.png"}})
            :addTo(self.storeNode_)
            :onButtonClicked(buttontHandler(self, self.onStoreClick_))
            
    --end
end

function ChooseRoomView:playShowAnim()
    local animTime = self.controller_:getAnimTime()
    local delayTime = 0.2

    -- 桌子
    transition.moveTo(self.pokerTable_, {time = animTime, y = -10})
    -- icon
    transition.moveTo(self.roomTypeIcon_, {time = animTime, x = -display.cx + self.iconOffX_, delay = delayTime})
    -- 分割线
    transition.fadeIn(self.splitLine_, {time = animTime, opacity = 255, delay = animTime})
    -- 在线人数icon
    nk.schedulerPool:delayCall(function()
        self.playerCount_:show()
    end, animTime)

    -- 顶部操作区
    transition.moveTo(self.topBtnNode_, {time = animTime, y = 0, delay = delayTime})

    -- 筹码
    for i, chip in ipairs(self.chips_) do
        chip:pos(
            ((i - 1) % 3 - 1) * CHIP_HORIZONTAL_DISTANCE,
            (math.floor((6 - i) / 3) - 1) * CHIP_VERTICAL_DISTANCE - display.cy - 90)

        local y_ = (math.floor((6 - i) / 3) - 1) * (CHIP_VERTICAL_DISTANCE-self.tempVetical_d) + 40 * nk.heightScale - self.tempYGrap_
        if #self.chips_ == 3 then
            y_ = -42
        end

        if i==#self.chips_ then
            transition.moveTo(chip, {
                time = animTime,
                y = y_,
                delay = delayTime + 0.1 * ((i - 1) % 3),
                easing = "BACKOUT",
                onComplete = function()
                    self.animIsEnd_ = true
                    self:dealDBNodeShow_()
                end
            })
        else
            transition.moveTo(chip, {
                time = animTime,
                y = y_,
                delay = delayTime + 0.1 * ((i - 1) % 3),
                easing = "BACKOUT"
            })
        end

        if self.pdengBg_ and self.pdengBg_[i] then
            self.pdengBg_[i]:pos(
                (i-2) * CHIP_HORIZONTAL_DISTANCE,
                (math.floor((6 - i) / 3) - 1) * CHIP_VERTICAL_DISTANCE - display.cy - 81 + 146
            )
            transition.moveTo(self.pdengBg_[i], {
                time = animTime,
                y = (math.floor((6 - i) / 3) - 1) * CHIP_VERTICAL_DISTANCE - display.cy - 81 + 346,
                delay = delayTime + 0.1 * ((i - 1) % 3),
                easing = "BACKOUT",
                onComplete = function()
                    self.pdengPlayerIconArr[i]:show()
                    self.pdengPlayerCountArr_[i]:show()
                end
            })
        end
    end

    -- 右边tab bar
    transition.moveTo(self.rightTabBar_, {time = animTime, x = display.cx - 72, delay = animTime})
    transition.moveTo(self.leftTabBar_, {time = animTime, x = -display.cx + 72, delay = animTime})

    self.isChangeRoomViewType_ = true
end

function ChooseRoomView:playHideAnim()
    self:removeFromParent()
end

function ChooseRoomView:onReturnClick_()
    self.controller_:showMainHallView()
end

function ChooseRoomView:onSearchClick_()
    HallSearchRoomPanel.new(self.controller_):showPanel()
end

function ChooseRoomView:onStoreClick_()
    StorePopup.new():showPanel()
end

function ChooseRoomView:onFirstPayClick_()
    FirstPayPopup.new():show()
end

function ChooseRoomView:onSaleGoodsPayClick_()
    if nk.userData.onsaleData then
        GuidePayPopup.new(13, nil, nk.userData.onsaleData):show()
    else
        --请求特价商品
        bm.HttpService.POST({
                mod = "PreferentialOrder",
                act = "jmtinfo"
            },
            function(data)
                local jsnData = json.decode(data)
                if jsnData and jsnData.goods then
                    jsnData.goodsInfo = jsnData.goods
                    nk.userData.onsaleData = jsnData
                    GuidePayPopup.new(13, nil, nk.userData.onsaleData):show()
                else
                    nk.OnOff:clearTimer(nk.OnOff.onsaleCountDownTimerId)
                    nk.userData.onsaleCountDownTime = -1
                end
            end,
            function()
                nk.OnOff:clearTimer(nk.OnOff.onsaleCountDownTimerId)
                nk.userData.onsaleCountDownTime = -1
            end)
    end
end

function ChooseRoomView:onGetPlayerCountData(data, field)
    local levelSelected = ChooseRoomView.ROOM_LEVEL_SELECTED
    if self.roomType_ == ROOM_TYPE_4K then
        levelSelected = levelSelected -1
    end

    if self.roomType_ == ROOM_TYPE_5K then
        levelSelected = levelSelected -1
    end

    if field ~= levelSelected then
        return
    end

    self.fivePlayerCounts_ = data.list[levelSelected..""]["5"]
    self.ninePlayerCounts_ = data.list[levelSelected..""]["9"]
    local playerCounts = nil
    local totalPlayer = 0
    if ChooseRoomView.PLAYER_LIMIT_SELECTED == 1 then
        playerCounts = self.ninePlayerCounts_
    elseif ChooseRoomView.PLAYER_LIMIT_SELECTED == 2 then
        playerCounts = self.fivePlayerCounts_
    end
    -- 设置对应筹码的在玩人数
    for i, chip in ipairs(self.chips_) do
        if playerCounts and playerCounts[i] then
            chip:setPlayerCount(playerCounts[i].c)
            totalPlayer = totalPlayer + playerCounts[i].c
            if self.pdengPlayerCountArr_ and self.pdengPlayerCountArr_[i] then
                self.pdengPlayerCountArr_[i]:setString(""..playerCounts[i].c)
            end
        else
            chip:setPlayerCount(0)
        end
    end
    -- 设置总在玩人数
    if self.viewType_ == self.controller_.CHOOSE_PDENG_VIEW then
        self.userOnline_:setString(bm.LangUtil.getText("HALL", "USER_ONLINE", math.floor(totalPlayer / 2)))
    else
        self.userOnline_:setString(bm.LangUtil.getText("HALL", "USER_ONLINE", totalPlayer))
    end
end

-- 顶部tab切换 初级 中级 高级 场次切换
function ChooseRoomView:onTopTabChange_(selectedTab)
    local roomType_ = self.roomType_

    if roomType_ == ROOM_TYPE_4K or roomType_ == ROOM_TYPE_5K then
        selectedTab = selectedTab + 1
    elseif (roomType_ == ROOM_TYPE_NOR or roomType_ == ROOM_TYPE_PRO) and selectedTab == 2 then--1：初级场；2：中级场；3：高级场,现在去掉中级，所以需要加1
        selectedTab = selectedTab + 1
    end

    ChooseRoomView.ROOM_LEVEL_SELECTED = selectedTab

    -- 清空、拉取在玩人数
    self.fivePlayerCounts_ = nil
    self.ninePlayerCounts_ = nil
    self.controller_:getPlayerCountData(roomType_, selectedTab)

    -- 给筹码设置前注
    local preCalls = nk.userData.tableConf[roomType_][selectedTab][ChooseRoomView.PLAYER_LIMIT_SELECTED]
    local maxBuys = nil
    local baseBuys = nil
    if nk.userData.tableMaxBuy then
        maxBuys = nk.userData.tableMaxBuy[roomType_][selectedTab][ChooseRoomView.PLAYER_LIMIT_SELECTED]
    end

    if nk.userData.tableBaseBuy then
        baseBuys = nk.userData.tableBaseBuy[roomType_][selectedTab][ChooseRoomView.PLAYER_LIMIT_SELECTED]
    end

    for i, chip in ipairs(self.chips_) do
        if preCalls and preCalls[i] then
            if selectedTab == 4 then
                chip:setIsCoin(true)
            else
                chip:setIsCoin(false)
            end

            if maxBuys and maxBuys[i] then 
                if baseBuys and baseBuys[i] then
                    chip:setPreCall(preCalls[i],maxBuys[i],baseBuys[i])
                else
                    chip:setPreCall(preCalls[i],maxBuys[i])
                end
            else
                chip:setPreCall(preCalls[i])
            end

            chip:show()
        else
            chip:hide()
        end
    end

    -- 记住当前选择的房间场次类型, 后续创建room场景时会读取此值
    -- note: 当前selectedTab 取值范围刚好是 1,2,3
    nk.gameState.roomLevel = nk.gameState.RoomLevel[selectedTab] or 'middle'
    self:dealDBNodeShow_()
end

function ChooseRoomView:dealDBNodeShow_()
    if not self.animIsEnd_ then return end
    if not nk.userData.sbGuide then return end
    local curList = nil
    local attribute="money"

    if self.is4k_ then 
        curList = nk.userData.sbGuide["k4"]
    elseif self.is5k_ then
        curList = nk.userData.sbGuide["k5"]
    else
        curList = nk.userData.sbGuide["normal"]
    end

    if ChooseRoomView.ROOM_LEVEL_SELECTED==4 then
        curList = nk.userData.sbGuide["gold"]
        attribute = "gcoins"
    end

    if not curList or #curList<1 then 
        if self.dragonbones1 then
            self.dragonbones1:getAnimation():stop()
            self.dragonbones1:hide()
            self.dragonbones2:getAnimation():stop()
            self.dragonbones2:hide()
        end        
        return 
    end

    -- 开始计算
    local indexList = {}
    for i, chip in ipairs(self.chips_) do
        if chip:isVisible() then
            indexList[chip.preCall_] = i
        end
    end

    local fitList = {}
    for k,v in ipairs(curList) do
        local rang = v.rang
        local sb = v.sb --推荐底注房间，有2个

        if nk.userData[attribute]>=rang[1] and nk.userData[attribute]<=rang[2] then
            for kk,vv in pairs(sb) do
                if indexList[vv] then
                    if #fitList<2 then -- 推荐两个
                        table.insert(fitList,indexList[vv])
                    end
                end
            end
            
            break
        end
    end

    for i=1,2,1 do
        local curDB = self["dragonbones"..i]
        if fitList[i] then
            if not curDB then
                local path = "dragonbones/fla_mangxuan/"
                    curDB = dragonbones.new({
                        skeleton=path .. "skeleton.xml",
                        texture=path .. "texture.xml",
                        armatureName="fla_mangxuan",
                        aniName="",
                        skeletonName="fla_mangxuan",
                    })
                        :addTo(self.db_node)
                self["dragonbones"..i] = curDB
            end
            curDB:getAnimation():play()
            curDB:show()
            curDB:pos(self.chips_[fitList[i]]:getPosition())
        else
            if curDB then
                curDB:getAnimation():stop()
                curDB:hide()
            end
        end
    end
end

-- 右侧tab切换 9人 5人 房间切换
function ChooseRoomView:onRightTabChange_(selectedTab)
    ChooseRoomView.PLAYER_LIMIT_SELECTED = selectedTab
    local playerCounts = nil
    local totalPlayer = 0
    if selectedTab == 1 then
        playerCounts = self.ninePlayerCounts_
    elseif selectedTab == 2 then
        playerCounts = self.fivePlayerCounts_
    end
    local roomType_ = self.roomType_

    local preCalls = nk.userData.tableConf[roomType_][ChooseRoomView.ROOM_LEVEL_SELECTED][selectedTab]
    local maxBuys = nil
    if nk.userData.tableMaxBuy then
        maxBuys = nk.userData.tableMaxBuy[roomType_][ChooseRoomView.ROOM_LEVEL_SELECTED][selectedTab]
    end
    if nk.userData.tableBaseBuy then
        baseBuys = nk.userData.tableBaseBuy[roomType_][ChooseRoomView.ROOM_LEVEL_SELECTED][selectedTab]
    end
    for i, chip in ipairs(self.chips_) do
        if preCalls and preCalls[i] then
            chip:show()
            if maxBuys and maxBuys[i] then 
                if baseBuys and baseBuys[i] then
                    chip:setPreCall(preCalls[i],maxBuys[i],baseBuys[i])
                else
                    chip:setPreCall(preCalls[i],maxBuys[i])
                end
            else
                chip:setPreCall(preCalls[i])
            end
            -- 设置对应筹码的在玩人数
            if playerCounts and  playerCounts[i] then
                chip:setPlayerCount(playerCounts[i].c)
                totalPlayer = totalPlayer + playerCounts[i].c
            else
                chip:setPlayerCount(0)
            end
        else
            chip:hide()
        end
    end
    -- 设置总在玩人数
    self.userOnline_:setString(bm.LangUtil.getText("HALL", "USER_ONLINE", totalPlayer))
end

-- 点击筹码进入指定场次
function ChooseRoomView:onChipClick_(preCall,isCoin, IsGrabDealer)
    local tabletype = self.roomType_
    if self.roomType_ == 4 then
        tabletype = 5
    end
    local pc_ = ChooseRoomView.PLAYER_LIMIT_SELECTED == 2 and 5 or 9
    if self.roomType_ == ROOM_TYPE_DICE then
        tabletype = 6
        pc_ = 8
    end
    if self.roomType_ == ROOM_TYPE_PDENG then
        tabletype = 13
        pc_ = 10
    end
    local params = {
        tt = tabletype,
        sb = preCall,
        pc = pc_
    }
    if isCoin then
        params.isgcoin = 1
    end
    if IsGrabDealer then
        params.banker = 1
    end
    if self.roomType_ == ROOM_TYPE_DICE then
        self.controller_:getEnterDiceData(self, params)
    elseif self.roomType_ == ROOM_TYPE_PDENG then
        return self.controller_:getEnterPdengData(params, IsGrabDealer)
    else
        self.controller_:getEnterRoomData(params)
    end
end

function ChooseRoomView:addPropertyObservers()
    self.firstPayObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "firstPay", handler(self, function (obj, firstPay)
        self:updateStoreIcon()
    end))
    self.onsaleCountDownTimeObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "onsaleCountDownTime", handler(self, function (obj, onsaleCountDownTime)
        self:updateStoreIcon()
    end))
end

function ChooseRoomView:removePropertyObservers()
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "firstPay", self.firstPayObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "onsaleCountDownTime", self.onsaleCountDownTimeObserverHandle_)
end

function ChooseRoomView:onCleanup()
    self:removePropertyObservers()
    bm.HttpService.CANCEL(self.playerCountRequestId_)

    ChooseRoomView.ROOM_LEVEL_SELECTED = nil
end

--添加顶部按钮结点
function ChooseRoomView:addTopNode_()
    self.topBtnNode_ = display.newNode()
        :pos(0, TOP_BUTTOM_HEIGHT + TOP_TAB_BAR_HEIGHT + TOP_BUTTOM_PADDING_Y + 50)
        :addTo(self)

    -- 返回
    self:addTopBtn_(
        "#top_return_btn_normal.png",
        "top_return_btn_pressed.png",
        -display.cx + TOP_BUTTOM_WIDTH * 0.5 + TOP_BUTTOM_PADDING,
        display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING_Y,
        buttontHandler(self, self.onReturnClick_))
    
    -- -- 搜索房间
    -- self:addTopBtn_(
    --     "#top_search_room_btn_normal.png",
    --     "top_search_room_btn_pressed.png",
    --     display.cx - TOP_BUTTOM_WIDTH * 1.5 - TOP_BUTTOM_PADDING * 2,
    --     display.cy - TOP_BUTTOM_HEIGHT * 0.5 - TOP_BUTTOM_PADDING_Y,
    --     buttontHandler(self, self.onSearchClick_))
end

function ChooseRoomView:addTopBtn_(normalImg, pressedImg, x, y, callback)
    local btn = cc.ui.UIPushButton.new({normal = {"#common_btn_bg_normal.png",normalImg}, pressed = {"#common_btn_bg_pressed.png",normalImg}})
        :pos(x, y)
        :onButtonClicked(callback)
        :addTo(self.topBtnNode_)
end

return ChooseRoomView
