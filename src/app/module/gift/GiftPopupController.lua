--
-- Author: Tom
-- Date: 2014-11-28 17:50:47
-- 礼物商店控制器
local GiftPopupController = class("GiftPopupController")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local LoadGiftControl = import(".LoadGiftControl")

function GiftPopupController:ctor(view)
    bm.EventCenter:addEventListener(nk.eventNames.GET_CUR_SELECT_GIFT_ID, handler(self, self.getSelectGiftIdHandler))
    self.view_ = view

    self.boutiqueGift_ = {}
    self.hotGift_ = {}
    self.festivalGift_ = {}
    self.otherGift_ = {}
    self.uid_ = 0
    self.tableUidArr_ = 0
    self.toUidArr_ = 0
    self.selectGiftId_ = nil

    self:requestMyGiftData_()
    self:requestShopGiftData_()
end

function GiftPopupController:onMainTabChange(selectedTab)
    self.mainSelectedTab_ = selectedTab
    local clearGift = {}
    self.view_:setListData(clearGift, -1)
    requestRetryTimes_ = 2
    if self.mainSelectedTab_ == 1 then
        self.view_:setLoading(true)
        self.view_:setNoDataTip(false)
        if self.selfShopGiftData then
            -- 1,2,3,4 热销，精品 ，节日，其他
            if self.subSelectedTab_ == 1 then
                if #self.hotGift_ == 0 then
                    self.view_:setNoDataTip(true)
                    self.view_:setLoading(false)
                    self.view_:setListData(self.hotGift_, -1)
                else
                    self:getGroupGiftData(self.hotGift_)
                end
            elseif self.subSelectedTab_ == 2 then
                if #self.boutiqueGift_ == 0 then
                    self.view_:setNoDataTip(true)
                    self.view_:setLoading(false)
                    self.view_:setListData(self.boutiqueGift_, -1)
                else
                    self:getGroupGiftData(self.boutiqueGift_)
                end
            elseif self.subSelectedTab_ == 3 then
                if #self.festivalGift_ == 0 then
                    self.view_:setNoDataTip(true)
                    self.view_:setLoading(false)
                    self.view_:setListData(self.festivalGift_, -1)
                else
                    self:getGroupGiftData(self.festivalGift_)
                end
            elseif self.subSelectedTab_ == 4 then
                if #self.otherGift_ == 0 then
                    self.view_:setNoDataTip(true)
                    self.view_:setLoading(false)
                    self.view_:setListData(self.otherGift_, -1)
                else
                    self:getGroupGiftData(self.otherGift_)
                end
            end
            
        else
            print("No data  data  data  data")
            self.view_:setLoading(false)
            self.view_:setNoDataTip(true)
            self:requestShopGiftData_()
        end
        
        --todo
    elseif self.mainSelectedTab_ == 2 then
        self.view_:setLoading(true)
        self.view_:setNoDataTip(false)
        if self.selfMyGiftData then
            -- 1 ,2 为可以使用，过期礼物
            if self.subSelectedTab_ == 1  then
                if #self.selfBuyGiftData == 0 then
                    self.view_:setNoDataTip(true)
                    self.view_:setLoading(false)
                    self.view_:setListData(self.selfBuyGiftData, -1)
                else
                    self:getGroupGiftData(self.selfBuyGiftData, nk.userData.user_gift)
                end
            elseif self.subSelectedTab_ == 2 then
                if #self.friendPresentData == 0 then 
                    self.view_:setNoDataTip(true)
                    self.view_:setLoading(false)
                    self.view_:setListData(self.friendPresentData, -1)
                else
                    self:getGroupGiftData(self.friendPresentData, nk.userData.user_gift)
                end
            elseif self.subSelectedTab_ == 3 then
                if #self.systemPresentData == 0 then 
                    self.view_:setNoDataTip(true)
                    self.view_:setLoading(false)
                    self.view_:setListData(self.systemPresentData, -1)
                else
                    self:getGroupGiftData(self.systemPresentData, nk.userData.user_gift)
                end
            else
                self.view_:setNoDataTip(true)
                self.view_:setLoading(false)
                self:requestMyGiftData_()
            end
        else
            -- self.view_:setLoading(false)
            self.view_:setNoDataTip(true)
            self:requestMyGiftData_()
        end
    end
    
end

function GiftPopupController:onSubTabChange(selectedTab)
    self.subSelectedTab_ = selectedTab
    local clearGift = {}
    self.view_:setListData(clearGift, -1)
    if self.mainSelectedTab_ == 1 then
        self.view_:setLoading(true)
        self.view_:setNoDataTip(false)
        if selectedTab == 1 and self.hotGift_  then
            if #self.hotGift_ == 0 then
                self.view_:setNoDataTip(true)
                -- self.view_:setLoading(false)
                self.view_:setListData(self.hotGift_, -1)

            end
            self:getGroupGiftData(self.hotGift_)
        elseif selectedTab ==2 and self.boutiqueGift_ then
            if #self.boutiqueGift_ == 0 then
                self.view_:setNoDataTip(true)
                self.view_:setLoading(false)
                self.view_:setListData(self.boutiqueGift_, -1)
            else
                self:getGroupGiftData(self.boutiqueGift_)
            end
        elseif selectedTab == 3 and self.festivalGift_  then
            if #self.festivalGift_ == 0 then
                self.view_:setNoDataTip(true)
                self.view_:setLoading(false)
                self.view_:setListData(self.festivalGift_, -1)
            else
                self:getGroupGiftData(self.festivalGift_)
            end
        elseif  selectedTab == 4 and  self.otherGift_  then
            if #self.otherGift_ == 0 then
                self.view_:setNoDataTip(true)
                self.view_:setLoading(false)
                self.view_:setListData(self.otherGift_, -1)
            else
                self:getGroupGiftData(self.otherGift_)
            end
        else
            self.view_:setNoDataTip(true)
            self.view_:setLoading(false)
            self:requestShopGiftData_()
        end
    elseif self.mainSelectedTab_ == 2 then
        self.view_:setLoading(true)
        self.view_:setNoDataTip(false)
        if selectedTab == 1 and self.selfBuyGiftData then
            if #self.selfBuyGiftData == 0 then
                self.view_:setNoDataTip(true)
                self.view_:setLoading(false)
                self.view_:setListData(self.selfBuyGiftData, -1)
            else
                self:getGroupGiftData(self.selfBuyGiftData, nk.userData.user_gift)
            end
        elseif selectedTab == 2 and self.friendPresentData then
            if #self.friendPresentData == 0 then
                self.view_:setNoDataTip(true)
                self.view_:setLoading(false)
                self.view_:setListData(self.friendPresentData, -1)
            else
                self:getGroupGiftData(self.friendPresentData, nk.userData.user_gift)
            end
        elseif selectedTab == 3 and self.systemPresentData then
            if #self.systemPresentData == 0 then
                self.view_:setNoDataTip(true)
                self.view_:setLoading(false)
                self.view_:setListData(self.systemPresentData, -1)
            else
                self:getGroupGiftData(self.systemPresentData, nk.userData.user_gift)
            end
        else
            self.view_:setNoDataTip(true)
            self.view_:setLoading(false)
            self:requestMyGiftData_()
        end
    end
    
end

function GiftPopupController:requestMyGiftData_()
    if self.myGiftRequesting_ then return end
    local request
    local retry = 3
    request = function()
        self.myGiftRequesting_ = true
        self.myGiftDataRequestId_ = bm.HttpService.POST(
            {
                mod = "gift", 
                act = "list", 
            }, 
            handler(self, self.onGetMyGiftData_), 
            function()
                self.myGiftDataRequestId_ = nil
                retry = retry - 1
                if retry > 0 then
                    request()
                else
                    self.myGiftRequesting_ = false
                end
            end
        )
    end
    request()
end


function GiftPopupController:requestShopGiftData_()
    if not self.selfShopGiftData then
        LoadGiftControl:getInstance():loadConfig(nk.userData.GIFT_JSON, function(success, data)
            if success then
                self.view_:setLoading(false)
                self.selfShopGiftData = data
                for i=1,#data do
                    if data[i].status == "1"  then
                        if data[i].gift_category == "0" then
                            table.insert(self.hotGift_, data[i])
                        elseif data[i].gift_category == "1" then
                            table.insert(self.boutiqueGift_, data[i])
                        elseif data[i].gift_category == "2" then
                            table.insert(self.festivalGift_, data[i])
                        elseif  data[i].gift_category == "3" then 
                            table.insert(self.otherGift_, data[i])
                        end
                    end
                end
            else
                -- self.view_:setLoading(false)
            end
        end)
    end
    
end

function GiftPopupController:getGroupGiftData(setGiftData, selectedId)
    -- 本人愚钝 目前想到的分组算法只能到这，后面若有大牛能提出更好的方案可以进行修改
    if setGiftData then
        local storageGiftData = {} -- 存储礼物数据
        local row = 5  -- 一行有多少个礼物
        local count  -- 对礼物进行分割后，满足不了5个礼物还有几个
        local minRow = math.floor(#setGiftData/row) 
        local maxRow = math.ceil(#setGiftData/row)

        -- 对前面可以构成一行的礼物，将其存储到storageGiftData 
        print("minRowminRowShopshop",minRow,maxRow,#setGiftData,#setGiftData % row)
        if minRow == 1 then
            table.insert(storageGiftData, {setGiftData[1], setGiftData[2], setGiftData[3], setGiftData[4],setGiftData[5]}) 
        elseif minRow > 1 then
            for i=1, minRow do
                table.insert(storageGiftData, {setGiftData[(i-1)*row + 1], setGiftData[(i-1)*row + 2], setGiftData[(i-1)*row + 3], setGiftData[(i-1)*row + 4],setGiftData[(i-1)*row + 5]}) 
            end
        end
        
        -- 对于不能凑成一行的剩余元素挨个赋值后将其加入storageGiftData
        if #setGiftData % row ~= 0 then
            count = #setGiftData % row
            if count ==1 then
                table.insert(storageGiftData, {setGiftData[minRow * row + 1]})
            elseif count == 2 then
                table.insert(storageGiftData, {setGiftData[minRow * row + 1],setGiftData[minRow * row + 2]})
            elseif count == 3 then
                table.insert(storageGiftData, {setGiftData[minRow * row + 1],setGiftData[minRow * row + 2],setGiftData[minRow * row + 3]})
            elseif count == 4 then
                table.insert(storageGiftData, {setGiftData[minRow * row + 1],setGiftData[minRow * row + 2],setGiftData[minRow * row + 3],setGiftData[minRow * row + 4]})
            end
        end
        local setGiftDataList = {}
        --将其分割好的数组重置为新的一行数据放置在List 中
        self.view_:setListData(setGiftDataList)

        if maxRow > 1 then
            for i=1,maxRow do
                table.insert(setGiftDataList, {storageGiftData[i][1], storageGiftData[i][2], storageGiftData[i][3], storageGiftData[i][4],storageGiftData[i][5]})
            end
        elseif  maxRow == 1 and #setGiftData % row == 0 then
            table.insert(setGiftDataList, {setGiftData[1], setGiftData[2], setGiftData[3], setGiftData[4],setGiftData[5]})

        elseif maxRow == 1  then
            if count == 1 then
                table.insert(setGiftDataList, {storageGiftData[1][1]})
            elseif count == 2 then
                table.insert(setGiftDataList, {storageGiftData[1][1], storageGiftData[1][2]})
            elseif count == 3 then
                table.insert(setGiftDataList, {storageGiftData[1][1], storageGiftData[1][2], storageGiftData[1][3]})
            elseif count == 4 then
                table.insert(setGiftDataList, {storageGiftData[1][1], storageGiftData[1][2], storageGiftData[1][3], storageGiftData[1][4]})
            end

        end
        self.view_:setListData(setGiftDataList, selectedId)
        self.view_:setLoading(false)
        self.view_:setNoDataTip(false)
        setGiftDataList = nil
        setGiftDataList = {}
        
    else
        loadShopGiftDataError()
    end
    
end


function GiftPopupController:loadShopGiftDataError()
    requestRetryTimes_ = requestRetryTimes_ - 1
    if requestRetryTimes_ > 0 then
        self.giftDataRequestScheduleHandle_ = scheduler.performWithDelayGlobal(handler(self, self.requestShopGiftData_), 2)
    end
end

function GiftPopupController:onGetMyGiftData_(data)
    self.myGiftRequesting_ = false
    self.myGiftDataRequestId_ = nil
    self.selfBuyGiftData = {}
    self.friendPresentData = {}
    self.systemPresentData = {}
    if data then
        self.selfMyGiftData = json.decode(data)
        -- dump(self.selfMyGiftData, "GiftPopupController:onGetMyGiftData_.selfMyGiftData :===============")

        if self.selfMyGiftData.ret == 1 and self.selfShopGiftData then
            for i=1,#self.selfShopGiftData do
                for j=1,#self.selfMyGiftData.data do
                    if (self.selfMyGiftData.data[j].type) == 2 and string.len(self.selfShopGiftData[i].id) > 0 and (self.selfMyGiftData.data[j].id ==  tonumber(self.selfShopGiftData[i].id)) then
                        self.selfMyGiftData.data[j].image = self.selfShopGiftData[i].image
                        self.selfMyGiftData.data[j].money = self.selfShopGiftData[i].money
                        self.selfMyGiftData.data[j].expire = self.selfMyGiftData.data[j].expireDay
                        self.selfMyGiftData.data[j].giftType = 1
                        table.insert(self.selfBuyGiftData, self.selfMyGiftData.data[j])
                    elseif (self.selfMyGiftData.data[j].type > 1000) and string.len(self.selfShopGiftData[i].id) and (self.selfMyGiftData.data[j].id ==  tonumber(self.selfShopGiftData[i].id)) then
                        self.selfMyGiftData.data[j].image = self.selfShopGiftData[i].image
                        self.selfMyGiftData.data[j].money = self.selfShopGiftData[i].money
                        self.selfMyGiftData.data[j].expire = self.selfMyGiftData.data[j].expireDay
                        self.selfMyGiftData.data[j].giftType = 1
                        table.insert(self.friendPresentData, self.selfMyGiftData.data[j])
                    elseif (self.selfMyGiftData.data[j].type == 10) and string.len(self.selfShopGiftData[i].id) and (self.selfMyGiftData.data[j].id ==  tonumber(self.selfShopGiftData[i].id)) then
                        self.selfMyGiftData.data[j].image = self.selfShopGiftData[i].image
                        self.selfMyGiftData.data[j].money = self.selfShopGiftData[i].money
                        self.selfMyGiftData.data[j].expire = self.selfMyGiftData.data[j].expireDay
                        self.selfMyGiftData.data[j].giftType = 10
                        table.insert(self.systemPresentData, self.selfMyGiftData.data[j])
                    end
                end
            end
        else
            --重置数据
        end
    else
        -- 重置数据
    end

end

function GiftPopupController:getTableUseUid(uid,tableUidArr,toUidArr)
    self.uid_ = uid
    self.tableUidArr_ = tableUidArr
    self.toUidArr_ = toUidArr
end

function GiftPopupController:getSelectGiftIdHandler(evt)
    self.selectGiftId_ = evt.data.giftId
end

-- 
function GiftPopupController:updateGiftIdHandler(data)
    self.selectGiftId_ = data
end

-- 设置设置自己的礼物
function GiftPopupController:useBuyGiftRequest(isRoom)
    if self.selectGiftId_ == nil or (self.selectGiftId_ == nk.userData.user_gift) or ( self.selectGiftId_ == 0) then
        return 
    end
    self.setGiftRequestId_ = bm.HttpService.POST(
        {
            mod = "gift", 
            act = "set",
            id = self.selectGiftId_
        }, 
        function (data)
            local callBackBuyData =  json.decode(data)
            if callBackBuyData.ret == 1 then
                nk.userData.user_gift = self.selectGiftId_
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "SET_GIFT_SUCCESS_TOP_TIP"))
                if isRoom then
                    nk.socket.HallSocket:sendUserInfoChanged()
                    nk.socket.RoomSocket:sendSetGift(self.selectGiftId_, nk.userData.uid)
                end
                bm.EventCenter:dispatchEvent({name = nk.eventNames.HIDE_GIFT_POPUP})
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "SET_GIFT_FAIL_TOP_TIP"))
            end
            self.buyGiftRequestId_ = nil
        end, 
        function ()
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "SET_GIFT_FAIL_TOP_TIP"))
            self.buyGiftRequestId_ = nil
        end
    )
end


-- 给牌桌的某个人购买
function GiftPopupController:requestPresentGiftData(isRoom)
    if self.selectGiftId_ == nil then
        return 
    end
    self.presentGiftRequestId_ = bm.HttpService.POST(
        {
            mod = "gift", 
            act = "buyTo",
            id = self.selectGiftId_,
            tuid_list = self.uid_

        }, 
        function (data)
            local callBackPresentData =  json.decode(data)
            if callBackPresentData.ret == 1 then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "PRESENT_GIFT_SUCCESS_TOP_TIP"))
                --赠送礼物成功
                local sendType = 1
                if isRoom then
                    nk.socket.RoomSocket:sendPresentGift(self.selectGiftId_, nk.userData.uid, {self.uid_})
                end
                bm.EventCenter:dispatchEvent({name = nk.eventNames.HIDE_GIFT_POPUP})
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "PRESENT_GIFT_FAIL_TOP_TIP"))
            end
            self.presentGiftRequestId_ = nil
        end, 
        function ()
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("TIPS", "ERROR_BUY_GIFT"))
            self.presentGiftRequestId_ = nil
        end
    )
end

-- 给自己购买
function GiftPopupController:buyGiftRequest(isRoom)
    if self.selectGiftId_ == nil then
        return 
    end
    self.buyGiftRequestId_ = bm.HttpService.POST(
        {
            mod = "gift", 
            act = "buy",
            id = self.selectGiftId_
        }, 
        function (data)
            local callBackBuyData =  json.decode(data)
            if callBackBuyData.ret == 1 then
                nk.userData.user_gift = self.selectGiftId_
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "BUY_GIFT_SUCCESS_TOP_TIP"))
                local sendType = 1
                if isRoom then
                    nk.socket.RoomSocket:sendSetGift(self.selectGiftId_, nk.userData.uid)
                end
                bm.EventCenter:dispatchEvent({name = nk.eventNames.HIDE_GIFT_POPUP})
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "BUY_GIFT_FAIL_TOP_TIP"))
            end
            self.buyGiftRequestId_ = nil
        end, 
        function ()
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "BUY_GIFT_FAIL_TOP_TIP"))
            self.buyGiftRequestId_ = nil
        end
    )
end

--给牌桌的人购买
function GiftPopupController:requestPresentTableGift(isRoom)
    if self.selectGiftId_ == nil then
        return 
    end
    self.presentTableGiftRequestId_ = bm.HttpService.POST(
        {
            mod = "gift", 
            act = "buyTo",
            id = self.selectGiftId_,
            tuid_list = self.tableUidArr_

        }, 
        function (data)
            local callBackPresentData =  json.decode(data)
            if callBackPresentData.ret == 1 then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "PRESENT_TABLE_GIFT_SUCCESS_TOP_TIP"))
                local sendType = 3
                nk.userData.user_gift = self.selectGiftId_
                if isRoom then
                    nk.socket.HallSocket:sendUserInfoChanged()
                    nk.socket.RoomSocket:sendPresentGift(self.selectGiftId_, nk.userData.uid, self.toUidArr_)
                end
                bm.EventCenter:dispatchEvent({name = nk.eventNames.HIDE_GIFT_POPUP})
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "PRESENT_TABLE_GIFT_FAIL_TOP_TIP"))
            end
            self.presentTableGiftRequestId_ = nil
        end, 
        function ()
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("TIPS", "ERROR_BUY_GIFT"))
            self.presentTableGiftRequestId_ = nil
        end
    )
end



function GiftPopupController:dispose()
    if self.giftDataRequestScheduleHandle_ then
        scheduler.unscheduleGlobal(self.giftDataRequestScheduleHandle_)
    end
    if self.myGiftDataRequestScheduleHandle_ then
        scheduler.unscheduleGlobal(self.myGiftDataRequestScheduleHandle_)
    end
    if self.myGiftDataRequestId_ then
        bm.HttpService.CANCEL(self.myGiftDataRequestId_)
        self.myGiftDataRequestId_ = nil
    end
    self.selfBuyGiftData = nil
    self.friendPresentData = nil
    self.systemPresentData = nil
    bm.EventCenter:removeEventListenersByEvent(nk.eventNames.GET_CUR_SELECT_GIFT_ID)

end

return GiftPopupController
