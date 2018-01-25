--
-- Author: KevinYu
-- Date: 2016-10-27
--
local ProductChipListItem = import(".views.ProductChipListItem")
local ProductPropListItem = import(".views.ProductPropListItem")
local ProductGoldListItem = import(".views.ProductGoldListItem")
local ProductChipListItems = import(".views.ProductChipListItems")
local ProductPackageListItems = import(".views.ProductPackageListItems")
local ProductPropListItems = import(".views.ProductPropListItems")
local ProductGoldListItems = import(".views.ProductGoldListItems")

local ProductVipList = import(".views.ProductVipList")

local ProductRecordPopup = import(".ProductRecordPopup")
local StorePopupController = import(".StorePopupController")
local CheckoutGuidePopup = import("app.module.newstore.CheckoutGuidePopup")

local logger = bm.Logger.new("StorePopup")

local StorePopup = class("StorePopup",function()
    return display.newNode()
end)

local LEFT_BG_W, LEFT_BG_H = 262, display.height --左边背景图片宽高
local GOODS_LIST_OFFSET = 234
local TOP_BG_W, TOP_BG_H = display.width - 225, 72
local BOTTOM_TIPS_BG_W, BOTTOM_TIPS_BG_H = display.width - 225, 40
local GOODS_LIST_W, GOODS_LIST_H = display.width - GOODS_LIST_OFFSET, display.height - TOP_BG_H - BOTTOM_TIPS_BG_H - 10 --商品列表视图宽高
local GOODS_LIST_X, GOODS_LIST_Y = GOODS_LIST_OFFSET/2, -BOTTOM_TIPS_BG_H/2

local TAB_CHIP      = 1  --筹码
local TAB_TOOL      = 2  --道具
local TAB_GOLD_COIN = 3  --黄金币
local TAB_VIP       = 4  --VIP

StorePopup.GOODS_CHIP       = TAB_CHIP
StorePopup.GOODS_TOOL       = TAB_TOOL
StorePopup.GOODS_GOLD_COIN  = TAB_GOLD_COIN
StorePopup.GOODS_VIP        = TAB_VIP

StorePopup.CHECKOUT_PMODE = "12"
StorePopup.E2P_PMODE      = "600"
StorePopup.BLUE_PAY       = "240"
StorePopup.BLUE_PAY_IOS   = "741"
StorePopup.AIS_PMODE      = "348"

local TAB_TEXT = {
    bm.LangUtil.getText("STORE", "TITLE_CHIP"),
    bm.LangUtil.getText("STORE", "TITLE_PROP"),
    bm.LangUtil.getText("STORE", "TITLE_GOLD"),
    bm.LangUtil.getText("STORE", "TITLE_VIP"),
}

local IS_SHOW_SHIELD = false --是否屏蔽黄金币

function StorePopup:ctor(defaultProductType, selpmode)
    self.isLoadedTexture_ = false
    self.createMainData = nil
    self:setContentSize(display.width, display.height)
    self:setTouchEnabled(true)
    self:setNodeEventEnabled(true)
    self.defaultProductType_ = defaultProductType
    self.defaultTab_ = 1
    self.controller_ = StorePopupController.new(self)
    self.selpmode_ = selpmode

    display.addSpriteFrames("store_texture.plist", "store_texture.png", function()
        self:addUI()
    end)
end

function StorePopup:checkNeedShowGuide()
    if device.platform == "ios" then
        return
    end
    local needshow = false
    local first = nk.userDefault:getIntegerForKey("CheckoutGuideFirst", 0)
    local today = os.date('%Y%m%d')
    if first == 0 then
        needshow = true
        nk.userDefault:setIntegerForKey("CheckoutGuideFirst", os.time())
    else
        if nk.userData.marketData.showCheckout == 1 then
            local lastshow = nk.userDefault:getStringForKey("CheckoutGuideLast", "")
            if os.time() - tonumber(first) < 86400 * 3 then
                needshow = true
            else
                if lastshow == today then
                    needshow = false
                else
                    needshow = true
                end
            end
            nk.userDefault:setStringForKey("CheckoutGuideLast", today)
        else
            needshow = false
        end
    end
    nk.userDefault:flush()
    if needshow then
        CheckoutGuidePopup.new():show()
    end
end

function StorePopup:addUI()
    -- 背景
    local bg = display.newSprite("#store_bg.png")
        :addTo(self)

    local bgSz = bg:getContentSize();
    local sx = display.width/bgSz.width;
    local sy = display.height/bgSz.height;
    bg:scale(sx > sy and sx or sy)

    self.closeBtn_ = cc.ui.UIPushButton.new({normal = "#pop_common_close_normal.png", pressed = "#pop_common_close_pressed.png"})
        :onButtonClicked(buttontHandler(self, self.hidePanel_))
        :pos(display.cx * 0.92, display.cy - 35)
        :addTo(self, 10)

    self.firstPay_ = nk.userData.firstPay

    self.bigJuhua_ = nk.ui.Juhua.new():addTo(self)
    
    self:addPropertyObservers_()

    self.isLoadedTexture_ = true
    if self.createMainData then  -- 出现异步情况
        self:createMainUI(self.createMainData.payTypeList,self.createMainData.tablist,self.createMainData.tips)
    end
end

function StorePopup:onEnter()
    self.controller_:init()
end

function StorePopup:onExit()
    self.controller_:dispose()
    if self.closeCallback_ then
        self.closeCallback_()
        self.closeCallback_ = nil
    end
    
    self:removePropertyObservers_()
end

function StorePopup:onCleanup()
    display.removeSpriteFramesWithFile("store_texture.plist", "store_texture.png")
end

function StorePopup:onShowed()
    self.isShowed_ = true
    if self.createMainUIRequest_ then
        self.createMainUIRequest_()
        self.createMainUIRequest_ = nil
    end

    self:updateTouchRect_()
    
end

function StorePopup:updateTouchRect_()
    if self.payTypeSelectList_ then
        self.payTypeSelectList_:setScrollContentTouchRect()
    end

    if self.chipList_ then
        self.chipList_:setScrollContentTouchRect()
    end

    if self.propList_ then
        self.propList_:setScrollContentTouchRect()
    end

    if self.goldList_ then
        self.goldList_:setScrollContentTouchRect()
    end

    if self.packageList_ then
        self.packageList_:setScrollContentTouchRect()
    end
end

function StorePopup:createMainUI(payTypeList, tablist, tips)
    if self.isLoadedTexture_==false then  -- 资源还没加载完成就执行了
        self.createMainData = {
            payTypeList = payTypeList,
            tablist = tablist,
            tips = tips
        }
        return;
    end
    --商品类型选项顺序列表
    self.tips_ = tips
    table.sort(tablist, function(a, b)
        return a.sortid > b.sortid
    end)
    self.tabList_ = clone(tablist)

    self:getDefaultTab_(tablist)

    if self.isShowed_ then
        self:createMainUI_(payTypeList)
    else
        self.createMainUIRequest_ = function()
            self:createMainUI_(payTypeList)
        end
    end
end

function StorePopup:getDefaultTab_(tablist)
    self.defaultTab_ = 1--如果没有开通第三方支付，黄金币和VIP是看不到的，必须有个默认值
    if self.defaultProductType_ then
        for i = 1, #tablist do
            if tablist[i].type == self.defaultProductType_ then
                self.defaultTab_ = i
                break
            end
        end
    end
end

function StorePopup:createMainUI_(payTypeList)
    if self.bigJuhua_ then
        self.bigJuhua_:removeFromParent()
        self.bigJuhua_ = nil
    end

    self.payTypeList_ = payTypeList
    self.selectedPayType_ = payTypeList[1]
    self:initItemType_()
    self:createLeftListNode_(payTypeList)
    
    --一行一个商品的item宽高
    local smallItemW, smallItemH = GOODS_LIST_W, 120
    ProductChipListItem.WIDTH = smallItemW
    ProductChipListItem.HEIGHT = smallItemH

    ProductPropListItem.WIDTH = smallItemW
    ProductPropListItem.HEIGHT = smallItemH

    ProductGoldListItem.WIDTH = smallItemW
    ProductGoldListItem.HEIGHT = smallItemH

    --一行多个商品的item宽高
    local bigItemW, bigItemH = GOODS_LIST_W, 284
    ProductChipListItems.WIDTH = bigItemW
    ProductChipListItems.HEIGHT = bigItemH

    ProductPropListItems.WIDTH = bigItemW
    ProductPropListItems.HEIGHT = bigItemH

    ProductGoldListItems.WIDTH = bigItemW
    ProductGoldListItems.HEIGHT = bigItemH

    ProductPackageListItems.WIDTH = bigItemW
    ProductPackageListItems.HEIGHT = bigItemH

    self:addTopOptionsNode_()

    if not IS_SHOW_SHIELD then
        self:addBottomTipsNode_()
    end
    
    self:gotoTab(self.defaultTab_)
end

function StorePopup:addBottomTipsNode_()
    local w, h = BOTTOM_TIPS_BG_W, BOTTOM_TIPS_BG_H
    local bg = display.newScale9Sprite("#store_bottom_txt_bg.png", 0, 0, cc.size(w, h))
        :align(display.BOTTOM_CENTER, GOODS_LIST_X + 6, -display.cy)
        :addTo(self, 3)

    self.bottomTipsLabel_ = ui.newTTFLabel({
        size = 18,
        text = self.tips_,
        color = cc.c3b(0x88, 0xb6, 0xcc),
    })
    :pos(w/2, h/2)
    :addTo(bg)
end

--创建左边列表Node
function StorePopup:createLeftListNode_(payTypeList)
    local w, h = LEFT_BG_W, LEFT_BG_H

    self.leftBg_ = display.newScale9Sprite("#store_left_bg.png", 0, 0, cc.size(w, h), cc.rect(5,5, 1, 1))
        :align(display.LEFT_CENTER, -display.cx, 0)
        :addTo(self, 2)

    local bg = self.leftBg_

    local icon_x = w/2 - 15
    display.newSprite("#store_icon.png")
        :align(display.TOP_CENTER, icon_x, h)
        :addTo(bg)

    local num = #payTypeList
    -- if num > 1 then
        self.goldLabel_ = self:addInfoNode_("#common_gcoin_icon.png", nk.userData.gcoins, cc.c3b(0xed, 0xcd, 0x10), icon_x, h - 140)
        self.chipLabel_ = self:addInfoNode_("#chip_icon.png", nk.userData.money, cc.c3b(0xd7, 0x64, 0x49), icon_x, h - 180, 0.9)
        IS_SHOW_SHIELD = false
    -- else
    --     self.chipLabel_ = self:addInfoNode_("#chip_icon.png", nk.userData.money, cc.c3b(0xd7, 0x64, 0x49), w/2, h/2 + 140, 0.9)
    --     IS_SHOW_SHIELD = true
    --     self.selpmode_ = nil
    --     -- self.defaultTab_ = 1
    -- end
    
    self:createPayTypeList_(payTypeList, 116, h * 0.38)

    self:addCustomerServiceNode_(w/2 - 60, h * 0.04)
end

--创建相关财产信息
function StorePopup:addInfoNode_(image, num, color, x, y, s)
    local w, h = 185, 31
    s = s or 1

    local frame = display.newScale9Sprite("#store_left_txt_bg.png", x, y, cc.size(w, h)):addTo(self.leftBg_)
    display.newSprite(image)
        :scale(s)
        :align(display.LEFT_CENTER, 1, h/2)
        :addTo(frame)

    local label = ui.newTTFLabel({
        size = 18,
        color = color,
        text = bm.formatNumberWithSplit(num)
    }):align(display.LEFT_CENTER, 40, h/2):addTo(frame)

    return label
end

function StorePopup:createPayTypeList_(payTypeList, x, y)
    local bg = self.leftBg_
    
    local contentNode = display.newNode()
    local payTypeGroup = nk.ui.CheckBoxButtonGroup.new()

    local btn_w, btn_h = 234, 74
    local item_h = btn_h
    local fromY = item_h * (#payTypeList - 1) * 0.5
    local selIndex = 1

    for i, paytype in ipairs(payTypeList) do
        local payBg = display.newNode()
            :size(btn_w, btn_h)
            :align(display.CENTER, 0, fromY)
            :addTo(contentNode)

        local btn = cc.ui.UICheckBoxButton.new({
                on="#store_paytype_selected.png",
                off="#transparent.png",
                off_pressed = "#store_paytype_pressed.png"},
                {scale9=true})
            :setButtonSize(btn_w, btn_h)
            :pos(btn_w/2, btn_h/2)
            :addTo(payBg)

        btn:setTouchSwallowEnabled(false)
        payTypeGroup:addButton(btn)
        
        if i > 1 then
            display.newScale9Sprite("#store_line.png",0, 0, cc.size(btn_w, 4))
                :pos(0, fromY + item_h/2)
                :addTo(contentNode)
        end

        local img = "store_paytype_" .. paytype.id .. ".png"
        local path = cc.FileUtils:getInstance():fullPathForFilename(img)
        if paytype.id == 10001 then
            self.paytype_ = display.newSprite("payBindPhone.png")
                :pos(-5, fromY)
                :addTo(contentNode)
        elseif io.exists(path) then
            self.paytype_ = display.newSprite(img)
                :pos(-5, fromY)
                :addTo(contentNode)
        else
            local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(img)
            if frame then
                self.paytype_ = display.newSprite(frame)
                    :pos(-5, fromY)
                    :addTo(contentNode)
            end
        end
        if paytype.id == 501 or paytype.id == 502 or paytype.id == 503 or paytype.id == 504 then
            display.newSprite("#store_paytype_mol_tag.png")
                :align(display.LEFT_BOTTOM, 2, 2)
                :addTo(payBg, 2)
        end
        fromY = fromY - item_h

        if self.selpmode_ and self.selpmode_ == paytype.pmode then
            selIndex = i
            self.selectedPayType_ = paytype
        end
    end

    local w, h = 234, 375

    display.newScale9Sprite("#store_paytype_bg.png", x, y - 1, cc.size(w, h + 3))
        :addTo(bg, 9)

    self.payTypeSelectList_ = bm.ui.ScrollView.new({
        viewRect = cc.rect(-0.5 * w, -0.5 * h, w, h),
        direction = bm.ui.ScrollView.DIRECTION_VERTICAL,
        scrollContent = contentNode,
    })
    :pos(x, y)
    :addTo(bg, 10)

    local pageIndex = (selIndex - 1)/5
    self.payTypeSelectList_:scrollTo(pageIndex * h)

    payTypeGroup:getButtonAtIndex(selIndex):setButtonSelected(true)
    payTypeGroup:onButtonSelectChanged(handler(self, self.onPayTypeChange_))
end

--创建客服结点
function StorePopup:addCustomerServiceNode_(x, y)
    local bg = self.leftBg_
    local fontCorlor = cc.c3b(0x5a, 0x5d, 0x8f)
    display.newSprite("#store_telephone_icon.png")
        :pos(x, y)
        :addTo(bg)

    local offx, offy = 30, 10
    ui.newTTFLabel({
        size = 14,
        text = "026700909",
        color = fontCorlor,
    }):align(display.LEFT_CENTER, x + offx, y + offy):addTo(bg)

    display.newScale9Sprite("#store_line.png", 0, 0, cc.size(75, 1))
        :align(display.LEFT_CENTER, x + offx, y + 2)
        :addTo(bg)

    ui.newTTFLabel({
        size = 14,
        color = fontCorlor,
        text = "09:00-23:00"
    }):align(display.LEFT_CENTER, x + offx, y - offy):addTo(bg)
end

--创建顶部tab结点
function StorePopup:addTopOptionsNode_()
    local w, h = TOP_BG_W, TOP_BG_H
    self.topBg_ = display.newScale9Sprite("#store_top_bg.png", 0, 0, cc.size(w, h))
        :align(display.LEFT_TOP, -display.cx + 225, display.cy)
        :addTo(self)
   
    self:createMainTabUI_(w * 0.7, w/2 - 20, h/2)

    cc.ui.UIPushButton.new({normal = "#store_record_normal.png", pressed = "#store_record_pressed.png"})
        :onButtonClicked(buttontHandler(self, self.onBuyRecordClicked_))
        :pos(w * 0.87, h/2)
        :addTo(self.topBg_)
end

function StorePopup:createMainTabUI_(tabW, x, y)
    local fontSize = 26
    local tabWidth = tabW
    
    local tablist = self.tabList_
    local btnText = {}
    local goldIndex, vipIndex --黄金币，VIP下标

    local isShowPackage = nk.userData.firstPay

    if IS_SHOW_SHIELD then
        btnText = self:hideGoldAndVipProduct_(tablist)
        self:getDefaultTab_(tablist)
    else
        for i = 1, #tablist do
            local index = tablist[i].type
            btnText[i] = TAB_TEXT[index]
            if index == TAB_GOLD_COIN then
                goldIndex = i
            elseif index == TAB_VIP then
                vipIndex = i
            end
        end
    end

    self.mainTabBar_ = nk.ui.TabBarWithIndicator.new(
        {
            background = "#store_tab_item_bg.png",
            indicator = "#store_tab_item_middle_normal.png"
        },
        btnText,
        {
            selectedText = {color = styles.FONT_COLOR.LIGHT_TEXT, size = 26},
            defaltText = {color = cc.c3b(0x83, 0x98, 0xc9), size = 26}
        },
        true, true)
        :setTabBarSize(tabWidth, 54, -5, -8)
        :align(display.LEFT_CENTER, x, y)
        :onTabChange(handler(self, self.onMainTabChange))
        :addTo(self.topBg_, 10)

    --添加标记
    if goldIndex then
        self.mainTabBar_:addTabTipIcon({index = goldIndex, image = "#store_tab_hot.png", offx = 15, offy = 3})
    end

    if vipIndex then
        self.mainTabBar_:addTabTipIcon({index = vipIndex, image = "#store_tab_new.png", offx = 15, offy = 3})
    end
end

function StorePopup:gotoTab(tab)
    self.mainTabBar_:gotoTab(tab)
end

function StorePopup:getSelectedTab_()
    return self.selectedTab_ or 1
end

function StorePopup:getSelectedPayType()
    return self.selectedPayType_ or self.payTypeList_[1]
end

function StorePopup:onMainTabChange(selectedTab)
    if self.selectedTab_ ~= selectedTab then
        self.selectedTab_ = selectedTab
        if self.input1_ then
            self.input1_:hide()
        end

        if self.input2_ then
            self.input2_:hide()
        end

        if self.submitBtn_ then
            self.submitBtn_:hide()
        end

        self:showCurProductPage_(selectedTab)

        self:updateProductItemType_()--道具统一显示一行一个，不调用，跟支付类型有关

        self:loadProductList_()
    end
end

function StorePopup:onPayTypeChange_(evt)
    --print(self.createMainData.payTypeList[evt.selected].id)
    if(evt.selected == #self.createMainData.payTypeList and self.createMainData.payTypeList[evt.selected].id == 10001 ) then
        self:getBindInfo()
        return
    end

    self.selectedPayType_ = self.payTypeList_[evt.selected] or self.payTypeList_[1]
    self:updateProductItemType_()
    self:loadProductList_()
end

--请求绑定信息
function StorePopup:getBindInfo()
    local retryTimes = 3

    local getInofo = function()
        -- body
        bm.HttpService.POST(
        {
            mod = "Phone" ,
            act = "isBound"
        },
        function (data)
            local callData = json.decode(data)
            if callData then 
                if callData.code == 0 then
                    local PhoneBind = import("app.module.dailytasks.PhoneBindPopup")
                    PhoneBind.new():show()
                    return
                elseif callData.code == 1 then
                    device.openURL("http://th.boyaa.com/")
                end
            end
        end,
        function (data)
            retryTimes = retryTimes - 1
            if retryTimes > 0 then
                getInofo()
            end
        end
        )
    end
    
    getInofo()
end

--创建弹窗的时候，初始化item类型
function StorePopup:initItemType_()
    self.itemType_ = self:getProductItemType_(self.selectedPayType_.pmode)
end

function StorePopup:updateProductItemType_()
    local selectedTab = self.selectedTab_
    local itemType = self:getProductItemType_(self.selectedPayType_.pmode)

    if self.itemType_ ~= itemType then
        self.itemType_ = itemType
        for i, v in ipairs(self.tabList_) do
            local page = self.pages_[i]
            if page then
                page:removeFromParent()
            end

            page = self:createPageByTabType_(v.type)
            self.pages_[i]= page
        end

        self:showCurProductPage_(selectedTab)
    end
end

function StorePopup:showInputIfNeeded_(productType)
    local input_w, input_h = 480, 58
    if not self.input1_ then
        self.input1_ = ui.newEditBox({image = "#transparent.png", 
            image = "#store_input_up.png",
            imagePressed = "#store_input_down.png",
            size = cc.size(input_w, input_h),
        }):addTo(self, 100):hide()
        self.input1_:setFontName(ui.DEFAULT_TTF_FONT)
        self.input1_:setFontSize(24)
        self.input1_:setFontColor(cc.c3b(0xb7, 0xc8, 0xd4))
        self.input1_:setPlaceholderFontName(ui.DEFAULT_TTF_FONT)
        self.input1_:setPlaceholderFontSize(24)
        self.input1_:setPlaceholderFontColor(cc.c3b(0xb7, 0xc8, 0xd4))
    end

    if not self.input2_ then
        self.input2_ = ui.newEditBox({image = "#transparent.png", 
            image = "#store_input_up.png",
            imagePressed = "#store_input_down.png",
            size = cc.size(input_w, input_h),
        }):addTo(self, 100):hide()
        self.input2_:setFontName(ui.DEFAULT_TTF_FONT)
        self.input2_:setFontSize(24)
        self.input2_:setFontColor(cc.c3b(0xb7, 0xc8, 0xd4))
        self.input2_:setPlaceholderFontName(ui.DEFAULT_TTF_FONT)
        self.input2_:setPlaceholderFontSize(24)
        self.input2_:setPlaceholderFontColor(cc.c3b(0xb7, 0xc8, 0xd4))
    end

    if not self.submitBtn_ then
        self.submitBtn_ = cc.ui.UIPushButton.new({normal="#common_btn_green_normal.png", pressed="#common_btn_green_pressed.png"}, {scale9=true})
            :setButtonLabel("normal", ui.newTTFLabel({size=28, text=bm.LangUtil.getText("STORE", "CARD_INPUT_SUBMIT"), align=ui.TEXT_ALIGN_CENTER}))
            :onButtonClicked(buttontHandler(self, self.onSubmitClicked_))
            :addTo(self, 100)
            :hide()
    end
 
    self.input1_:setMaxLength(0)
    self.input1_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.input1_:setInputFlag(cc.EDITBOX_INPUT_FLAG_SENSITIVE)
    self.input1_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.input1_:setPlaceHolder("")
    self.input1_:setText("")

    self.input2_:setMaxLength(0)
    self.input2_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.input2_:setInputFlag(cc.EDITBOX_INPUT_FLAG_SENSITIVE)
    self.input2_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.input2_:setPlaceHolder("")
    self.input2_:setText("")

    local selectedPayType = self:getSelectedPayType()

    self.controller_:prepareEditBox(selectedPayType, self.input1_, self.input2_, self.submitBtn_)

    local inputHeight = 0
    local input_x = GOODS_LIST_X - 75
    local submitBtn_x = input_x + 340
    local list_h = GOODS_LIST_H
    local list_x, list_y = GOODS_LIST_X, GOODS_LIST_Y

    if selectedPayType.inputType == "singleLine" and productType ~= TAB_VIP then
        inputHeight = 80
        list_h = GOODS_LIST_H - inputHeight
        list_y = GOODS_LIST_Y - inputHeight * 0.5

        local input_y = list_y + list_h/2 + input_h/2 + 15

        self.input1_:pos(input_x, input_y)
        self.submitBtn_:setButtonSize(160, 52):pos(submitBtn_x, input_y)

        self.input1_:show()
        self.input2_:hide()
        self.submitBtn_:show()
    elseif selectedPayType.inputType == "twoLine" and productType ~= TAB_VIP then
        inputHeight = 130
        list_h = GOODS_LIST_H - inputHeight
        list_y = GOODS_LIST_Y - inputHeight * 0.5

        local input_y = list_y + list_h/2 + input_h/2 + 10

        self.input1_:pos(input_x, input_y + input_h + 5)
        self.input2_:pos(input_x, input_y)
        self.submitBtn_:setButtonSize(160, 74):pos(submitBtn_x, input_y + 30)

        self.input1_:show()
        self.input2_:show()
        self.submitBtn_:show()
    else
        self.input1_:hide()
        self.input2_:hide()
        self.submitBtn_:hide()
    end

    local list_rect = cc.rect(
        -0.5 * GOODS_LIST_W,
        -0.5 * list_h,
        GOODS_LIST_W,
        list_h)

    if self.chipList_ then
        self.chipList_:setViewRect(list_rect)
        self.chipList_:pos(list_x, list_y)
    end

    if self.propList_ then
        self.propList_:setViewRect(list_rect)
        self.propList_:pos(list_x, list_y)
    end

    if self.goldList_ then
        self.goldList_:setViewRect(list_rect)
        self.goldList_:pos(list_x, list_y)
    end

    if self.packageList_ then
        self.packageList_:setViewRect(list_rect)
        self.packageList_:pos(list_x, list_y)
    end
end

function StorePopup:onSubmitClicked_()
    self.controller_:onInputCardInfo(self:getSelectedPayType(), self.selectedProductType_, self.input1_, self.input2_, self.submitBtn_)
end

function StorePopup:loadProductList_()
    local tabType = self:getCurSelectTabType_()
    self.selectedProductType_ = tabType
    Global_StorePopupType = false  -- 群组内部用到  BaseProductItem  BaseProductItems
    if tabType == TAB_CHIP then
        self.controller_:loadChipProductList(self:getSelectedPayType())
    elseif tabType == TAB_TOOL then
        self.controller_:loadPropProductList(self:getSelectedPayType())
    elseif tabType == TAB_GOLD_COIN then
        Global_StorePopupType = true
        self.goldList_:setData(nil)
        self.controller_:loadGoldProductList(self:getSelectedPayType())
    elseif tabType == TAB_VIP then
        self.controller_:loadVipProductList(self:getSelectedPayType())
    end
end

function StorePopup:setChipList(paytype, isComplete, data)
    self:showInputIfNeeded_(TAB_CHIP)
    if paytype.id == self:getSelectedPayType().id then
        if not self.chipList_ then
            return 
        end

        if isComplete then
            self.chipListJuhua_:hide()
            if type(data) == "string" then
                self.chipListMsg_:setString(data)
                self.chipListMsg_:show()
                self.chipList_:setData(nil)
            else
                if self.itemType_ == 2 then
                    data = self:createProductDataGroup_(data, 3)
                end

                self.chipListMsg_:hide()
                self.chipList_:setData(data)
                self.chipList_:setItemsZorder()
                self:updateTouchRect_()
            end
        else
            self.chipList_:setData(nil)
            self.chipListMsg_:hide()
            self.chipListJuhua_:show()
        end
    end
end

function StorePopup:setPropList(paytype, isComplete, data)
    self:showInputIfNeeded_(TAB_TOOL)
    if paytype.id == self:getSelectedPayType().id then
        if not self.propList_ then
            return 
        end

        if isComplete then
            self.propListJuhua_:hide()
            if type(data) == "string" then
                self.propListMsg_:setString(data)
                self.propListMsg_:show()
                self.propList_:setData(nil)

                self.input1_:hide()
                self.input2_:hide()
                self.submitBtn_:hide()
            else
                if self.itemType_ == 2 then
                    data = self:createProductDataGroup_(data, 3)
                end

                self.propListMsg_:hide()
                self.propList_:setData(data)
                self.propList_:setItemsZorder()
                self:updateTouchRect_()
            end
        else
            self.propList_:setData(nil)
            self.propListMsg_:hide()
            self.propListJuhua_:show()
        end
    end
end

function StorePopup:setGoldList(paytype, isComplete, data)
    self:showInputIfNeeded_(TAB_GOLD_COIN)
    if paytype.id == self:getSelectedPayType().id then
        if not self.goldList_ then
            return
        end

        if isComplete then
            self.goldListJuhua_:hide()
            if type(data) == "string" then
                self.goldListMsg_:setString(data)
                self.goldListMsg_:show()
                self.goldList_:setData(nil)
            else
                if self.itemType_ == 2 then
                    data = self:createProductDataGroup_(data, 3)
                end

                self.goldListMsg_:hide()
                self.goldList_:setData(data)
                self.goldList_:setItemsZorder()
                self:updateTouchRect_()
            end
        else
            self.goldList_:setData(nil)
            self.goldListMsg_:hide()
            self.goldListJuhua_:show()
        end
    end
end

function StorePopup:setPackageList(paytype, isComplete, data)
    self:showInputIfNeeded_(TAB_VIP)
    if paytype.id == self:getSelectedPayType().id then
        if not self.packageList_ then
            return 
        end

        if isComplete then
            self.packageListJuhua_:hide()
            if type(data) == "string" then
                self.packageListMsg_:setString(data)
                self.packageListMsg_:show()
                self.packageList_:setData(nil)
            else
                if self.itemType_ == 2 then
                    data = self:createProductDataGroup_(data, 2)
                end

                self.packageListMsg_:hide()
                self.packageList_:setData(data)
                self:updateTouchRect_()
            end
        else
            self.packageList_:setData(nil)
            self.packageListMsg_:hide()
            self.packageListJuhua_:show()
        end
    end
end

--vip不是ListView
function StorePopup:setVipList(paytype, isComplete, data)
    self:showInputIfNeeded_(TAB_VIP)
    if paytype.id == self:getSelectedPayType().id then
        if not self.vipList_ then
            return
        end

        if isComplete then
            self.vipListJuhua_:hide()
            if type(data) == "string" then
                self.vipListMsg_:setString(data)
                self.vipListMsg_:show()
                self.vipList_:hide()
            else
                self.vipListMsg_:hide()
                self.vipList_:show()
                self.vipList_:setData(data)
            end
        else
            self.vipListMsg_:hide()
            self.vipListJuhua_:show()
            self.vipList_:hide()
        end
    end
end

function StorePopup:createPageByTabType_(tabType)
    local page
    if tabType == TAB_CHIP then
        page = self:createChipPage_()
    elseif tabType == TAB_TOOL then
        page = self:createPropPage_()
    elseif tabType == TAB_VIP then
        page = self:createVipPage_()
    elseif tabType == TAB_GOLD_COIN then
        page = self:createGoldPage_()
    end

    page:addTo(self, 2)
    
    return page
end

--显示当前商品列表
function StorePopup:showCurProductPage_(selectedTab)
    self.pages_ = self.pages_ or {}
    for _, page in pairs(self.pages_) do
        page:hide()
    end

    local page = self.pages_[selectedTab]

    if not page then
        local tabType = self:getCurSelectTabType_()
        page = self:createPageByTabType_(tabType)
        self.pages_[selectedTab] = page
    end

    page:show()
end

--创建筹码商品列表
function StorePopup:createChipPage_()
    local page = display.newNode()
    local pageX, pageY = GOODS_LIST_X, GOODS_LIST_Y
    local list_w, list_h = GOODS_LIST_W, GOODS_LIST_H

    local listItem = ProductChipListItem
    if self.itemType_ == 2 then
        listItem = ProductChipListItems
    end

    self.chipList_ = bm.ui.ListView.new({
            viewRect = cc.rect(-0.5 * list_w, -0.5 * list_h, list_w, list_h),
            direction = bm.ui.ListView.DIRECTION_VERTICAL
        }, listItem)
        :pos(pageX, pageY)
        :addTo(page)

    self.chipList_:addEventListener("ITEM_EVENT", handler(self, self.onItemEvent_))
    self.chipListJuhua_ = nk.ui.Juhua.new():addTo(page):pos(pageX, pageY):hide()
    self.chipListMsg_ = ui.newTTFLabel({text = "", color = cc.c3b(255, 255, 255), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :pos(pageX, pageY)
        :addTo(page)
        :hide()

    return page
end

--创建黄金币商品列表
function StorePopup:createGoldPage_()
    local page = display.newNode()
    local pageX, pageY = GOODS_LIST_X, GOODS_LIST_Y
    local list_w, list_h = GOODS_LIST_W, GOODS_LIST_H

    local listItem = ProductGoldListItem
    if self.itemType_ == 2 then
        listItem = ProductGoldListItems
    end

    self.goldList_ = bm.ui.ListView.new({
            viewRect = cc.rect(-0.5 * list_w, -0.5 * list_h, list_w, list_h),
            direction = bm.ui.ListView.DIRECTION_VERTICAL
        }, listItem)
        :pos(pageX, pageY)
        :addTo(page)

    self.goldList_:setNotHide(true)
    self.goldList_:addEventListener("ITEM_EVENT", handler(self, self.onItemEvent_))
    self.goldListJuhua_ = nk.ui.Juhua.new():addTo(page):pos(pageX, pageY):hide()
    self.goldListMsg_ = ui.newTTFLabel({text = "", color = cc.c3b(255, 255, 255), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :pos(pageX, pageY)
        :addTo(page)
        :hide()

    return page
end

--创建道具商品列表
function StorePopup:createPropPage_()
    local page = display.newNode()
    local pageX, pageY = GOODS_LIST_X, GOODS_LIST_Y
    local list_w, list_h = GOODS_LIST_W, GOODS_LIST_H

    local listItem = ProductPropListItem
    if self.itemType_ == 2 then
        listItem = ProductPropListItems
    end

    if self.itemType_ == 3 then
        listItem.IS_SHOW_BTN = true
    else
        listItem.IS_SHOW_BTN = false
    end

    self.propList_ = bm.ui.ListView.new({
            viewRect = cc.rect(-0.5 * list_w, -0.5 * list_h, list_w, list_h),
            direction = bm.ui.ListView.DIRECTION_VERTICAL
        }, listItem)
        :pos(pageX, pageY)
        :addTo(page)

    self.propList_:setNotHide(true)
    self.propList_:addEventListener("ITEM_EVENT", handler(self, self.onItemEvent_))

    self.propListJuhua_ = nk.ui.Juhua.new():addTo(page):pos(pageX, pageY):hide()

    self.propListMsg_ = ui.newTTFLabel({text = "", color = cc.c3b(255, 255, 255), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :pos(pageX, pageY)
        :addTo(page)
        :hide()

    return page
end

--大礼包
function StorePopup:createPackagePage_()
    local page = display.newNode()
    local pageX, pageY = GOODS_LIST_X, GOODS_LIST_Y
    local list_w, list_h = GOODS_LIST_W, GOODS_LIST_H

    local listItem = ProductPackageListItems
    self.packageList_ = bm.ui.ListView.new({
            viewRect = cc.rect(-0.5 * list_w, -0.5 * list_h, list_w, list_h),
            direction = bm.ui.ListView.DIRECTION_VERTICAL
        }, listItem)
        :pos(pageX, pageY)
        :addTo(page)

    self.packageList_:addEventListener("ITEM_EVENT", handler(self, self.onItemEvent_))
    self.packageListJuhua_ = nk.ui.Juhua.new():addTo(page):pos(pageX, pageY):hide()
    self.packageListMsg_ = ui.newTTFLabel({text = "", color = cc.c3b(255, 255, 255), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :pos(pageX, pageY)
        :addTo(page)
        :hide()

    return page
end

--VIP
function StorePopup:createVipPage_()
    local page = display.newNode()
    local pageX, pageY = GOODS_LIST_X, GOODS_LIST_Y

    self.vipList_ = ProductVipList.new(GOODS_LIST_W - 28, GOODS_LIST_H + 10)
        :pos(pageX + 14, pageY + 5)
        :addTo(page)
    self.vipList_:addEventListener("ITEM_EVENT", handler(self, self.onItemEvent_))

    self.vipListJuhua_ = nk.ui.Juhua.new():addTo(page):pos(pageX, pageY):hide()
    self.vipListMsg_ = ui.newTTFLabel({text = "", color = cc.c3b(255, 255, 255), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :pos(pageX, pageY)
        :addTo(page)
        :hide()

    return page
end

function StorePopup:onItemEvent_(evt)
    if evt.type == "MAKE_PURCHASE" then
        self.controller_:makePurchase(self:getSelectedPayType(), evt.pid, evt.goodsItem)
    end
end

-- 添加监听
function StorePopup:addListenerEvent()
    bm.EventCenter:addEventListener("Easy2Pay_Purchase", handler(self, self.easy2payPurchaseCallback_))
end

-- 移除监听
function StorePopup:removeListenerEvent()
    bm.EventCenter:removeEventListenersByEvent("Easy2Pay_Purchase")

    if self.isEasy2PayPurchase_ then
        app:loadOnOffData()
        self.isEasy2PayPurchase_ = false
    end
end

-- easy2Pay购买请求，当关闭StorePopup需要调用拉去比赛券请求
function StorePopup:easy2payPurchaseCallback_(e)
    if e then
        if e.data == "4158" then      --比赛券
            self.isEasy2PayPurchase_ = true
        elseif e.data == "4056" then  --筹码
                
        elseif e.data == "4057" then  --道具
            
        end
    end
end

function StorePopup:onBuyRecordClicked_()
    ProductRecordPopup.new(self.controller_):show()
end

--获取当前选中的tab商品类型
function StorePopup:getCurSelectTabType_()
    local index = self:getSelectedTab_()
    return self.tabList_[index].type
end

--获取item类型，1为一行一个，2为一行多个
function StorePopup:getProductItemType_(mode)
    --ios和android对应的pmode不一样
    if device.platform == "ios" then
        --卡密支付
        if mode == "621" or mode == "622" or mode == "623" or mode == "624" then
            return 1
        else --渠道支付
            if self:getCurSelectTabType_() == TAB_TOOL then
                return 3
            end

            return 2
        end
    end
    
    --卡密支付
    if mode == "472" or mode == "473" or mode == "474" or mode == "475" or mode == "707" then
        return 1
    else --渠道支付
        if self:getCurSelectTabType_() == TAB_TOOL then
            return 3
        end

        return 2
    end
end

--对数据进行分组，一行显示多个商品
function StorePopup:createProductDataGroup_(data, step)
    local num = #data
    local index = 1
    local dataArr = {}
    for i = 1, num, step do
        local arr = {}
        for j = 1, step do
            arr[j] = data[i + j - 1]
        end

        dataArr[index] = arr
        index = index + 1
    end

    return dataArr
end

function StorePopup:showPanel(closeCallback)
    self.closeCallback_ = closeCallback
    nk.PopupManager:addPopup(self, false, true, true, true)

    --  添加监听
    self:addListenerEvent()
    self:checkNeedShowGuide()
end

function StorePopup:hidePanel()
    self:hidePanel_()
end

function StorePopup:hidePanel_()
    -- 删除监听
    self:removeListenerEvent()
    nk.PopupManager:removePopup(self)
end

function StorePopup:hideGoldAndVipProduct_(tablist)
    local i, max = 1, #tablist
    local btnText = {}
    while i <= max do
        local index = tablist[i].type
        if index == TAB_GOLD_COIN then
           table.remove(tablist, i)
            i = i - 1
            max = max - 1
        end
        i = i + 1
    end

    for i = 1, max do
        local index = tablist[i].type
        btnText[i] = TAB_TEXT[index]
    end

    return btnText
end

function StorePopup:addPropertyObservers_()
    self.gcoinsObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "gcoins",function (gcoins)
            if self.goldLabel_ then
                self.goldLabel_:setString(bm.formatNumberWithSplit(gcoins))
            end
        end)

    self.moneyObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "money", function (money)
        if self.chipLabel_ then
            self.chipLabel_:setString(bm.formatNumberWithSplit(money))
        end
    end)

    self.firstPayObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "firstPay", function(firstPay)
        if self.firstPay_ ~= nk.userData.firstPay then
            self:hidePanel_()
        end
    end)
    self.needRefreshStoreId_ = bm.EventCenter:addEventListener("getNewStoreInfo", handler(self, self.onRefresh_))
end

function StorePopup:onRefresh_()
    self:hidePanel()
end

function StorePopup:removePropertyObservers_()
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "gcoins", self.gcoinsObserverHandle_)

    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "money", self.moneyObserverHandle_)

    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "firstPay", self.firstPayObserverHandle_)
    if self.needRefreshStoreId_ then
        bm.EventCenter:removeEventListener(self.needRefreshStoreId_)
        self.needRefreshStoreId_ = nil;
    end
end

return StorePopup
