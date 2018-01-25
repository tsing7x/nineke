--
-- Author: hlf
-- Date: 2015-12-08 16:11:56
-- 货币道具转换列表界面
local MixCurrencyItem = import(".MixCurrencyItem")
local Panel = import("app.pokerUI.Panel")
local MixListPopup = class("MixListPopup", Panel)

MixListPopup.WIDTH = 830
MixListPopup.HEIGHT = 546

function MixListPopup:ctor(data)
    MixListPopup.super.ctor(self, {MixListPopup.WIDTH, MixListPopup.HEIGHT})

    self.popupName_ = "MixListPopup"
    self:setBackgroundStyle1()
    self:addTopIcon("#mix_tip_icon.png", 7)

    self:addCloseBtn()
    self:setCloseBtnOffset(10,-10)
    self:addTopDivide(nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5-45)
	self:initView()

    self:addListener()
    self:setLoading(true)
end

function MixListPopup:initView()
	local width, height = MixListPopup.WIDTH, MixListPopup.HEIGHT
	self.mainContainer_ = display.newNode():addTo(self)
    self.mainContainer_:setContentSize(width,height)

    self.mainContainer_:setTouchSwallowEnabled(true)

    local px, py
    local dw, dh

    px, py = 0, height*0.5-59*0.5
    dw, dh = width-6, 59

    px, py = 0, -12
    dw, dh = width-36, height - 136
    self.commonBar_ = display.newScale9Sprite("#panel_overlay.png", 0, 0, cc.size(dw, dh-28), cc.rect(21,18,1,1))
    	:pos(px, py-14)
    	:addTo(self.mainContainer_)

    local bgDw,bgDh = 225,35

    -- 金币
    self.moneyBg_ = display.newScale9Sprite("#pop_userinfo_my_bank_bg.png", 0, 0, cc.size(bgDw, bgDh))
        :pos(-300, 185)
        :addTo(self.mainContainer_)
    self.moneyIcon_ = display.newSprite("#chip_icon.png")
        :pos(25,17)
        :addTo(self.moneyBg_)
        :scale(0.9)
    self.moneyText_ = ui.newTTFLabel({
            text="",
            color=cc.c3b(0xff, 0xff, 0xff),
            size=20,
            align = ui.TEXT_ALIGN_LEFT
        })
        :pos(45,17)
        :align(display.LEFT_CENTER)
        :addTo(self.moneyBg_)

    -- 黄金币
    self.gcoinsBg_ = display.newScale9Sprite("#pop_userinfo_my_bank_bg.png", 0, 0, cc.size(100, bgDh))
        :pos(-100, 185)
        :addTo(self.mainContainer_)
    self.gcoinsIcon_ = display.newSprite("#common_gcoin_icon.png")
        :pos(25,17)
        :addTo(self.gcoinsBg_)
        :scale(0.9)
    self.gcoinsText_ = ui.newTTFLabel({
            text="",
            color=cc.c3b(0xff, 0xff, 0xff),
            size=20,
            align = ui.TEXT_ALIGN_LEFT
        })
        :pos(45,17)
        :align(display.LEFT_CENTER)
        :addTo(self.gcoinsBg_)

    -- 比赛券
    self.gameCouponBg_ = display.newScale9Sprite("#pop_userinfo_my_bank_bg.png", 0, 0, cc.size(bgDw, bgDh))
        :pos(100, 185)
        :addTo(self.mainContainer_)
    self.gameCouponIcon_ = display.newSprite("#icon_gamecoupon.png")
        :pos(25,17)
        :addTo(self.gameCouponBg_)
    self.gameCouponText_ = ui.newTTFLabel({
            text="",
            color=cc.c3b(0xff, 0xff, 0xff),
            size=20,
            align = ui.TEXT_ALIGN_LEFT
        })
        :pos(45,17)
        :align(display.LEFT_CENTER)
        :addTo(self.gameCouponBg_)

    -- 金券
    self.goldCouponBg_ = display.newScale9Sprite("#pop_userinfo_my_bank_bg.png", 0, 0, cc.size(bgDw, bgDh))
        :pos(300, 185)
        :addTo(self.mainContainer_)
    self.goldCouponIcon_ = display.newSprite("#icon_goldcoupon.png")
        :pos(25,17)
        :addTo(self.goldCouponBg_)
    self.goldCouponText_ = ui.newTTFLabel({
            text="",
            color=cc.c3b(0xff, 0xff, 0xff),
            size=20,
            align = ui.TEXT_ALIGN_LEFT
        })
        :pos(45,17)
        :align(display.LEFT_CENTER)
        :addTo(self.goldCouponBg_)

    self:moneyObserverHandleFun_()
    self:goldCouponObserverHandleFun_()
    self:gameCouponObserverHandleFun_()
    self:gcoinsObserverHandleFun_()

    self.moneyObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "money", handler(self, function(obj, userMoney)
        self:moneyObserverHandleFun_()
        end))

    self.goldCouponObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "goldCoupon", handler(self, function(obj, userMoney)
        self:goldCouponObserverHandleFun_()
        end))

    self.gameCouponObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "gameCoupon", handler(self, function(obj, userMoney)
        self:gameCouponObserverHandleFun_()
        end))

    self.gcoinsObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "gcoins", handler(self, function(obj, userMoney)
        self:gcoinsObserverHandleFun_()
        end))
end

-- 创建列表
function MixListPopup:createListView_(px, py)
    local LIST_WIDTH = 520
    local LIST_HEIGHT = 372
    px = px + LIST_WIDTH*0.0 - 14
    py = py + LIST_HEIGHT*0.5 - 12
    self.listDW_ = LIST_WIDTH
    self.list_ = bm.ui.ListView.new(
            {
                viewRect = cc.rect(-LIST_WIDTH * 0.5, -LIST_HEIGHT * 0.5, LIST_WIDTH, LIST_HEIGHT*1),
            }, 
            MixCurrencyItem
        )
        :pos(px, py-1)
        :addTo(self.mainContainer_)
    self.list_:setNotHide(true)
    self.list_:addEventListener("ITEM_EVENT", handler(self, self.onItemEvent_))
end

function MixListPopup:onItemEvent_(evt)
    if evt.data then
        bm.EventCenter:dispatchEvent({name="Mix_List_Select_Item", data=evt.data})
    end
end

-- 创建菜单按钮列表
function MixListPopup:createSelectItems_()
    if not self.data_ or not self.data_.list then
        return
    end

	local px,py
	local itemData
	local itype = 1
	local dw, dh = 250, 76
    self.menuList_ = {}
	px, py = self.tabBg_:getPosition()
	local sz = self.tabBg_:getContentSize()
	py = py + sz.height*0.5 - dh*0.5 + 0
	px = px - 0
	py = py - 3.5
	for i=1,#self.data_.list do
		itemData = self:createMenuButton(i, self.data_.list[i].url, self.data_.list[i].name, dw, dh)
		itemData.contain:pos(px, py):addTo(self.mainContainer_)
		table.insert(self.menuList_, #self.menuList_+1, itemData)
		py = py-dh-1
	end

	self:onMenuListSelectedHandler_(1)
end

-- 根据类型创建不同类型的菜单按钮
function MixListPopup:createMenuButton(i, url, lblTxt, dw, dh)
	local bg1, bg2
	local maxNums = 5
	local px, py = 0, 0	
	local offx = 10
	local itemData = {}
	itemData.index = i
	itemData.contain = display.newNode()

    itemData.bg1 = display.newScale9Sprite("#left_tab_no.png", 0, 0, cc.size(dw, 77), cc.rect(13, 38, 1, 1))
        :pos(px, py)
        :addTo(itemData.contain)

    itemData.bg2 = display.newScale9Sprite("#left_tab_selected.png", 0, 0, cc.size(dw+10,78), cc.rect(8, 20, 1, 20))
        :pos(px+offx-5, py-1)
        :addTo(itemData.contain)

    itemData.btn = cc.ui.UIPushButton.new({normal = "#transparent.png", pressed="#transparent.png"}, {scale9=true})
        :setButtonSize(dw, dh)
        :pos(px, py)
        :addTo(itemData.contain)
        :onButtonClicked(function(evt)
        	self:onMenuListSelectedHandler_(i)
        end)

    local iconDW = 64
    px = -dw*0.5 + iconDW*0.5 + 15
    itemData.icon = display.newSprite(url)
		:pos(px-10, py)
		:addTo(itemData.contain)
    local sz = itemData.icon:getContentSize()
	itemData.icon:setScale(iconDW/sz.width)

	itemData.lbl = ui.newTTFLabel({
			text=lblTxt,
			color=cc.c3b(0x78, 0x76, 0x85),
			size=26,
			align = ui.TEXT_ALIGN_CENTER
		})
		:pos(px, py)
		:addTo(itemData.contain)

    local lblMaxDw = 180
    local lsz = itemData.lbl:getContentSize()
    if lsz.width > lblMaxDw then
        itemData.lbl:setScale(lblMaxDw/lsz.width)
        itemData.lbl:setPositionX(px+lblMaxDw*0.5+iconDW*0.5-10)        
    else
        itemData.lbl:setPositionX(px+lsz.width*0.5+iconDW*0.5-10)
        itemData.lbl:setScale(1)
    end
    
    itemData.selected = function(status)
    	if status then
    		itemData.bg1:hide()
    		itemData.bg2:show()
    	else
    		itemData.bg2:hide()
    		itemData.bg1:show()
    	end
    end

    itemData.selected(false)

    return itemData
end

function MixListPopup:onMenuListSelectedHandler_(index)
	if index > 0 and index <= #self.menuList_ then
		self:onCleanAllSelected_()
		local itemData = self.menuList_[index]
		itemData.selected(true)
        itemData.lbl:setTextColor(cc.c3b(0xff,0xff,0xff))

        self:selectListByType(index)
	end
end

function MixListPopup:onCleanAllSelected_()
	for i=1,#self.menuList_ do
		self.menuList_[i].selected(false)

        self.menuList_[i].lbl:setTextColor(cc.c3b(0x71, 0x80, 0xa1))
	end
end

function MixListPopup:onCleanup()
    self:removeListener()
end

function MixListPopup:show(callback)
    self.callback_ = callback

	nk.PopupManager:addPopup(self)

	return self
end

function MixListPopup:render()
    if self.data_ then
        self.descLbl_:setString(bm.LangUtil.formatString(bm.LangUtil.getText("MixCurrent", "MIX_DESC"), self.data_.limit, self.data_.leftCnt))

        bm.fitSprteWidth(self.descLbl_, self.listDW_ - 20)
    end
end

function MixListPopup:selectListByType(itype)
    if self.data_ then
        local listData = self.data_.list[itype].list
        self.list_:setData(listData)

        local length = listData and #listData or 0
        local mixCurrencyItem = nil
        for i = 1, length do
            mixCurrencyItem = self.list_:getListItem(i)
            if mixCurrencyItem and mixCurrencyItem.resizeSize then
                mixCurrencyItem:resizeSize()
            end
        end
    end
end

function MixListPopup:onShowed()
    if self.list_ then
        self.list_:setScrollContentTouchRect()
    end
end

function MixListPopup:setLoading(isLoading)
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

function MixListPopup:onClose()
	self:close()
end

function MixListPopup:close()
	nk.PopupManager:removePopup(self)
	return self
end

function MixListPopup:onRemovePopup(func)
    if self.callback_ then
        self.callback_()
    end
    self:onCleanup()
    func()
end

function MixListPopup:addListener()
    if not self.mixExchangeSuccessId_  then
        self.mixExchangeSuccessId_ = bm.EventCenter:addEventListener("Mix_Exchange_Success", handler(self, self.render))
    end
    if not self.mixGetReturnId_ then
        self.mixGetReturnId_ = bm.EventCenter:addEventListener("mix_get_return", handler(self, self.onMixGetReturn))
    end
end

function MixListPopup:onMixGetReturn()
    self.data_ = nk.MixCurrentManager:getMixData()

    self:setLoading(false)
    local width, height = MixListPopup.WIDTH, MixListPopup.HEIGHT
    local px, py = -(width-30)*0.5+282*0.5-20, -27
    local dw, dh = 294, height - 166
    self.tabBg_ = display.newScale9Sprite("#panel_overlay.png", 0, 0, cc.size(dw-40, dh), cc.rect(13,18,1,1))
        :pos(px+10, py)
        :addTo(self.mainContainer_)

    local csz = self.commonBar_:getContentSize()
    px, py = self.commonBar_:getPosition()
    px = px - csz.width*0.5 + dw + (csz.width - dw)*0.5
    py = py - csz.height*0.5 + 18
    self.descLbl_ = ui.newTTFLabel({
            text="", --每天最多可完成5次合成，您当前还有3次
            color=cc.c3b(0x5b, 0x5d, 0xa1),
            size=20,
            align = ui.TEXT_ALIGN_CENTER
        })
        :pos(0, -height*0.5+37)
        :addTo(self.mainContainer_)

    self:createListView_(px, py)
    self:createSelectItems_()
    self:render()
end

function MixListPopup:moneyObserverHandleFun_()
    self.moneyText_:setString(bm.formatNumberWithSplit(nk.userData.money))
    local size = self.moneyText_:getContentSize()
    self.moneyBg_:setContentSize(size.width+60,35)
end

function MixListPopup:goldCouponObserverHandleFun_()
    self.goldCouponText_:setString(bm.formatNumberWithSplit(nk.userData.goldCoupon))
    local size = self.goldCouponText_:getContentSize()
    self.goldCouponBg_:setContentSize(size.width+60,35)
end

function MixListPopup:gameCouponObserverHandleFun_()
    self.gameCouponText_:setString(bm.formatNumberWithSplit(nk.userData.gameCoupon))
    local size = self.gameCouponText_:getContentSize()
    self.gameCouponBg_:setContentSize(size.width+60,35)
end

function MixListPopup:gcoinsObserverHandleFun_()
    self.gcoinsText_:setString(bm.formatNumberWithSplit(nk.userData.gcoins))
    local size = self.gcoinsText_:getContentSize()
    self.gcoinsBg_:setContentSize(size.width+60,35) 
end

function MixListPopup:removeListener()
    if self.mixExchangeSuccessId_ then
        bm.EventCenter:removeEventListener(self.mixExchangeSuccessId_)
    end
    if self.mixGetReturnId_ then
        bm.EventCenter:removeEventListener(self.mixGetReturnId_)
    end
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "money", self.moneyObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "goldCoupon", self.goldCouponObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "gameCoupon", self.gameCouponObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "gcoins", self.gcoinsObserverHandle_)
end

return MixListPopup
