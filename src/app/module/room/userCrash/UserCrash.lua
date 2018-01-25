--
-- Author: KevinYu
-- Date: 2016-11-2 17:48:37
--

local UserCrashListItem = import(".UserCrashListItem")
local StorePopup = import("app.module.newstore.StorePopup")
local logger = bm.Logger.new("UserCrash")
local InvitePopup = import("app.module.friend.InvitePopup")
local QuickPurchaseServiceManager = import("app.module.newstore.QuickPurchaseServiceManager")

local UserCrash = class("UserCrash", function ()
    return display.newNode()
end)

local WIDTH, HEIGHT = 830, 500 --弹窗宽高

function UserCrash:ctor(times,subsidizeChips,phpCrashChips,remainTime, param, roomLevel)
    self:setNodeEventEnabled(true)

    self.isShowPay_ = nk.OnOff:check("bankruptcypay") --是否显示破产快捷支付

    if self.isShowPay_ then
        HEIGHT = 500
    else
        HEIGHT = 320
    end

    self.subsidizeChips_ = subsidizeChips or 0
    self.phpCrashChips_ = phpCrashChips or 0
    self.giveChips_ = self.subsidizeChips_ + self.phpCrashChips_
    self.remainTime_ = remainTime or 0
    self.param_ = param or {}

    display.addSpriteFrames("crash_texture.plist", "crash_texture.png")

    local node = display.newScale9Sprite("#transparent.png", 0, 0, cc.size(WIDTH, HEIGHT)):addTo(self)
    node:setTouchEnabled(true)
    node:setTouchSwallowEnabled(true)

    self.bg_ = display.newScale9Sprite("#crash_bg.png", 0, 0, cc.size(WIDTH, HEIGHT)):addTo(self)

    cc.ui.UIPushButton.new({normal = "#pop_common_close_normal.png", pressed = "#pop_common_close_pressed.png"})
        :onButtonClicked(buttontHandler(self, self.hidePanel_))
        :pos(WIDTH - 35, HEIGHT - 35)
        :addTo(self.bg_)
    
    self:addTitle_()

    if self.isShowPay_ then
        self.quickPayService_ = QuickPurchaseServiceManager.getInstance()
        self.bigJuhua_ = nk.ui.Juhua.new():addTo(self)
        bm.HttpService.POST({mod="Broke", act="discountOrder", field = roomLevel or 1},--field 房间类型初中高
            function(data)
                local jsonData = json.decode(data)
                if jsonData then
                    self:onLoadGoods_(jsonData)
                end
            end,
            function()
                self.bigJuhua_:removeSelf()
                self:buildView_()
            end)
        self.schedulerPool_ = bm.SchedulerPool.new()
    else
        self:buildView_() 
    end
end

function UserCrash:addTitle_()
    local node = display.newNode()
        :pos(WIDTH/2, HEIGHT - 36)
        :addTo(self.bg_)

    display.newSprite("#crash_title_bg.png")
        :align(display.RIGHT_CENTER, 1, 0)
        :addTo(node)

    display.newSprite("#crash_title_bg.png")
        :align(display.LEFT_CENTER, -1, 0)
        :flipX(true)
        :addTo(node)

    ui.newTTFLabel({font = "fonts/BLK-Suphanburi.ttf", text = bm.LangUtil.getText("CRASH", "TITLE"), size = 35})
        :addTo(node)
end

function UserCrash:onLoadGoods_(retData)
    self.bigJuhua_:removeSelf()
    self:buildView_()

    self.newGoodsDiscount = retData.discount
    local data = {}
    if retData.goods and type(retData.goods) == 'table' then 
        self.payData_ = retData.goods
        --保存原价标题
        self.payData_[1].title = self.payData_[1].getname
        self.payData_[2].title = self.payData_[2].getname

        self:showPayItem_(self.payData_)
        if retData.limittime then
            self:goodsCountDown_(retData.limittime)
        end
    end
end

function UserCrash:goodsCountDown_(limittime)
    if limittime <= 0  then
        return
    else
        for _,v in ipairs(self.times_) do
            v[1]:show()
            v[2]:show():setString(bm.TimeUtil:getTimeString1(limittime))
        end
    end

    self.schedulerPool_:loopCall(function()
        limittime = limittime - 1
        
        if limittime <= 0 then
            self:updatePayItem_()

            return false
        end

        for _,v in ipairs(self.times_) do
            v[2]:setString(bm.TimeUtil:getTimeString1(limittime))
        end

        return true
    end, 1)
end

function UserCrash:buildView_()
    local LIST_WIDTH = WIDTH - 30
    local LIST_HEIGHT = 230

    -- 添加列表
    self.list_ = bm.ui.ListView.new(
        {
            viewRect = cc.rect(-LIST_WIDTH * 0.5, -LIST_HEIGHT * 0.5, LIST_WIDTH, LIST_HEIGHT),
        }, 
        UserCrashListItem
    )
    :pos(WIDTH/2, HEIGHT - 190)
    :addTo(self.bg_)

    self.listData = {}

    local showMatch = false
    local curScene = display.getRunningScene()
    if curScene.name == "RoomScene" or curScene.name == "HallScene" then
        showMatch = true
    end
    
    if showMatch then
        local MatchData = {}
        MatchData.img = "crash_match_icon.png"
        MatchData.chips = 0
        MatchData.title = bm.LangUtil.getText("CRASH", "MATCH_TITLE")
        MatchData.info = bm.LangUtil.getText("CRASH", "MATCH_INFO")
        MatchData.btnTitle = bm.LangUtil.getText("CRASH", "MATCH_BTN_TITLE")
        MatchData.type = 5
        table.insert(self.listData,MatchData)
    end

    local showChips = (self.giveChips_ ~= 0)
    if showChips then
        local chipsData = {}
        chipsData.img = "crash_chips_icon.png"
        chipsData.chips = self.giveChips_
        chipsData.title = bm.LangUtil.getText("CRASH", "CHIPS_TIPS")
        chipsData.info = bm.LangUtil.getText("CRASH", "CHIPS_INFO")
        chipsData.btnTitle = bm.LangUtil.getText("CRASH", "GET")
        chipsData.type = 2
        chipsData.remainTime = self.remainTime_
        table.insert(self.listData,chipsData)
    end

    local oldUserInviteData = {}
    oldUserInviteData.img = "crash_invite_icon.png"
    oldUserInviteData.chips = 50000
    oldUserInviteData.title = bm.LangUtil.getText("CRASH", "RECALL")
    oldUserInviteData.info = bm.LangUtil.getText("CRASH", "RECALL_INFO")
    oldUserInviteData.btnTitle = bm.LangUtil.getText("CRASH", "GET")
    oldUserInviteData.type = 3
    table.insert(self.listData,oldUserInviteData)

    self.list_.owner_ = self
    self.list_:setData(self.listData)
end 

function UserCrash:showPayItem_(data)
    local w, h = WIDTH, HEIGHT
    self.payItemBg_ = display.newNode()
        :align(display.CENTER, w/2, 100)
        :addTo(self.bg_)

    self.times_ = {}
    self.times_[1] = self:createPayItem_("#store_prd_101.png", -205, 0, data[1], handler(self, self.onGoStoreHandler1_))
    self.times_[2] = self:createPayItem_("#store_prd_103.png", 205, 0, data[2], handler(self, self.onGoStoreHandler2_))
end

function UserCrash:updatePayItem_()
    if self.payItemBg_ then 
        self.payItemBg_:removeFromParent()
        self.payItemBg_ = nil
    end

    --恢复原价
    self.payData_[1].discount = 1
    self.payData_[2].discount = 1
    self.payData_[1].getname = self.payData_[1].title
    self.payData_[2].getname = self.payData_[2].title

    self:showPayItem_(self.payData_)
end

function UserCrash:createPayItem_(icon, x, y, goods, callback)
    local btn_w, btn_h = 410, 180
    local origin_x, origin_y = btn_w/2, btn_h/2

    local btn = cc.ui.UIPushButton.new({normal= "#crash_product_normal.png", pressed = "#crash_product_pressed.png"},{scale9 = true})
        :pos(x, y)
        :onButtonClicked(callback)
        :addTo(self.payItemBg_)

    local discount = tonumber(goods.discount)
    if discount and discount ~= 1 then
        local numOff = math.floor(goods.pnum * discount)
        goods.getname = bm.LangUtil.getText("STORE", "FORMAT_CHIP", bm.formatBigNumber(numOff))

        local discount_icon = display.newSprite("#crash_discount_bg.png")
            :align(display.LEFT_TOP, -origin_x + 5, origin_y - 5)
            :addTo(btn)
        local discount_info = ui.newTTFLabel({text="+" .. (discount * 100 - 100) .. "%",size = 20, align=ui.TEXT_ALIGN_CENTER})
            :pos(discount_icon:getContentSize().width/4 + 6,discount_icon:getContentSize().height/2 + 8)
            :addTo(discount_icon)
        discount_info:setRotation(-45)
    else
        display.newSprite("#store_label_recommend.png")
            :align(display.LEFT_TOP, -origin_x + 5, origin_y - 7)
            :addTo(btn)
    end

    display.newSprite(icon)
        :pos(-origin_x + 65, 15)
        :addTo(btn)

    local label_x, label_y = -origin_x + 120, 30
    ui.newTTFLabel({
            text = goods.getname,
            size = 24,
            color = cc.c3b(0xff, 0xde, 0x46),
            })
        :align(display.LEFT_CENTER, label_x, label_y)
        :addTo(btn)

    ui.newTTFLabel({
            text = goods.pamount .. "THB",
            size = 24})
        :align(display.LEFT_CENTER, label_x, label_y - 35)
        :addTo(btn)
    
    local str = "E2P"
    if goods and goods.pmode and self.quickPayService_:isBluePay(tonumber(goods.pmode)) then
        str = "bluepay"
    end

    if goods and goods.pmode and self.quickPayService_:isIabPay(tonumber(goods.pmode)) then
        str = "Google Play"
    end

    ui.newTTFLabel({
            text = bm.LangUtil.getText("CRASH", "E2P_TIP", str),
            size = 20,
            color = cc.c3b(0xc9, 0x80, 0xff),
            align = ui.TEXT_ALIGN_LEFT})
        :pos(0, label_y - 65)
        :addTo(btn)

    local time_x, time_y = 70, -origin_y + 30
    local clock = display.newSprite("#crash_clock.png")
            :pos(time_x, time_y)
            :addTo(btn)
            :hide()

    local time = ui.newTTFLabel({
            text = "",
            size = 22})
        :align(display.LEFT_CENTER, time_x + 15, time_y - 1)
        :addTo(btn)
        :hide()

    return {clock, time}
end

function UserCrash:itemClicked_(type)
    if type == 1 then
    elseif type == 2 then
        self:onGetCrashChips_()
    elseif type == 3 then
        self:onReCall_()
    elseif type == 4 then
        self:onInvite_()
    elseif type == 5 then
        self:onOpenMatch()
    end
end

function UserCrash:removeItem(type)
    local index = 0
    for i,v in ipairs(self.listData) do
        if v.type == type then
            index = i
            break
        end
    end
    if index ~= 0 then
        table.remove(self.listData,index)
        self.list_:setData(self.listData)
    end
end

-- 获取破产补助
function UserCrash:onGetCrashChips_()
    if self.subsidizeChips_ ~= 0 then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("CRASH", "GET_REWARD", self.subsidizeChips_))
        self:removeItem(2)
    end
    
    if self.phpCrashChips_ ~= 0 then
        local param = self.param_ or {}
        param.act = "complement"
        param.mod = "Broke"
        bm.HttpService.POST(param,
            function(data)
                local jsonData = json.decode(data)
                if jsonData and jsonData.code == 1 then
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("CRASH", "GET_REWARD", self.phpCrashChips_))
                    nk.userData.money = nk.userData.money + self.phpCrashChips_
                    self:removeItem(2)
                else
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("CRASH", "GET_REWARD_FAIL"))
                end
            end,
            function(data)
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("CRASH", "GET_REWARD_FAIL"))
            end)
    end
end

function UserCrash:onOpenMatch()
    local curScene = display.getRunningScene()
    if curScene.name == "RoomScene" or curScene.name == "DiceScene" then
        -- 设置当前场景类型全局数据
        bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, 5)
        curScene:doBackToHall()
    elseif curScene.name == "HallScene" then
        curScene.controller_:onEnterMatch()
    end

    self:reportData_("crash_match","crash match")
    self:hide()
end

function UserCrash:onInvite_()
    self:reportData_("crash_invite","crash invite")
    InvitePopup.new():show()
end

function UserCrash:onReCall_()
    self:reportData_("crash_recall","crash recall")
    InvitePopup.new():show()
end

function UserCrash:onGoStoreHandler1_()
    self:reportData_("crash_gostore1","crash gostore1")
    self:makePurchase(self.payData_[1])
end

function UserCrash:onGoStoreHandler2_()
    self:reportData_("crash_gostore2","crash gostore2")
    self:makePurchase(self.payData_[2])
end

function UserCrash:parseGoods(goods)
    if not goods then return nil end 
    local item = {}
    item.pid = goods.id
    item.id = goods.id
    item.price = goods.pamount
    item.title = goods.getname
    item.pnum = goods.pnum
    if tonumber(goods.ptype) == 7 then
        item.content = json.decode(goods.ext.content)
        item.pchips = item.content.chips
    end
    item.pamount = goods.pamount
    item.tag = ""
    item.pmode = goods.pmode
    item.bygood = goods
    item.category = "chips"
    item.skus = goods.skus or {}
    item.discount = tonumber(goods.discount)
    local payInfo = {}
    payInfo.merchantId = "4165"
    payInfo.priceId = tonumber(goods.pamount) 
    item.payInfo = payInfo
    return item

end

function UserCrash:purchaseResult_(succ, result)
    if succ then
        nk.userData.firstPay = false
        bm.EventCenter:dispatchEvent(nk.eventNames.ROOM_REFRESH_HDDJ_NUM)
        -- FIXME:没有上报具体的金额
        -- 上报广告平台 支付成功
        -- nk.AdSdk:reportPay("0.00", "HKD")
        local userData = nk.userData
        --更新互动道具数量
        bm.HttpService.POST(
            {
                mod = "user", 
                act = "getUserFun"
            }, 
            function (data)
                userData.hddjNum = tonumber(data)
            end
        )
        
        local pid_ = ""
        if result and type(result) == "table" and result.pid then
            pid_ = result.pid
        else
            pid_ = result
        end
        nk.reportToDAdmin("jmtBrokeOrder", "jmtBrokeOrderSuccessed=goods" .. pid_)
    end
end

function UserCrash:makePurchase(data)
    if data then
        local goods = self:parseGoods(data)
        if goods and self.quickPayService_ then
            self.payingGoods = goods
            self.quickPayService_:makePurchase(goods.pid, handler(self, self.purchaseResult_), goods)
            nk.reportToDAdmin("jmtBrokeOrder", "jmtBrokeOrder=goods" .. goods.pid)
        end

        self:hidePanel_()
    end
end

function UserCrash:onCleanup()
    if self.schedulerPool_ then
        self.schedulerPool_:clearAll()
    end
end

function UserCrash:reportData_(id,dataLabel)
    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand{command = "event",
            args = {eventId = id} , label = dataLabel}
    end
end

function UserCrash:onShowed()
    if self.list_ then
        self.list_:setScrollContentTouchRect()
        self.list_:update()
    end
end

function UserCrash:hidePanel_()
    nk.PopupManager:removePopup(self)
end

function UserCrash:show()    
    -- nk.PopupManager:addPopup(self, true, true, true, true, nil, nil, true)
    nk.PopupManager:addPopup(self)
end

function UserCrash:onEnter()
end

function UserCrash:onExit()
    display.removeSpriteFramesWithFile("crash_texture.plist", "crash_texture.png")
end

return UserCrash
