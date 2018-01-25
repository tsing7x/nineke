--
-- Author: viking@boomegg.com
-- Date: 2014-10-28 18:48:02
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
-- XA$KGCDv8EY7VHapok#2REVxT33VBmd0

local ScoreMarketController = class("ScoreMarketController")

function ScoreMarketController:ctor(view)
    self.view_ = view
    self:getAllOrderIdPraises()
end

function ScoreMarketController:getMatchScoreList(type)
    if not type then 
        type = "bag"
    end
    bm.HttpService.CANCEL(self.getMatchScoreListId_)
    self.getMatchScoreListId_ = bm.HttpService.POST(
        {
            mod = "Match",
            act = "mall",
            category = type,
        },
        function(data)
            -- print("Match.mall:::"..data)
            local retData = json.decode(data)
            if retData and retData.ret == 0 then
                -- 对热卖和新上架数据做特殊处理
                local lenNew, lenHot, i
                -- retData.new = nil
                if retData.new or retData.hot then
                    lenNew = 0
                    if retData.new and #retData.new > 0 then
                        lenNew = #retData.new
                    end
                    if lenNew > 0 then
                        for i=1, lenNew do
                            retData.new[i].isNew = true
                            retData.new[i].subList = retData.new
                        end
                    end
                    -- 
                    lenHot = 0
                    if retData.hot and #retData.hot > 0 then
                        lenHot = #retData.hot
                    end
                    if lenHot > 0 then
                        for i=1, lenHot do
                            retData.hot[i].isHot = true
                            retData.hot[i].subList = retData.hot
                        end
                    end
                    -- 
                    if lenNew > 0 and lenHot > 0 then
                        retData.new[1].subList = retData.new
                        retData.hot[1].subList = retData.hot

                        table.insert(retData.data, 1, nil)
                        table.insert(retData.data, 1, retData.new[1])
                        table.insert(retData.data, 1, retData.hot[1])
                    elseif lenHot > 0 then
                        retData.hot[1].subList = retData.hot

                        table.insert(retData.data, 1, nil)
                        table.insert(retData.data, 1, nil)
                        table.insert(retData.data, 1, retData.hot[1])
                    elseif lenNew > 0 then
                        retData.new[1].subList = retData.new

                        table.insert(retData.data, 1, nil)
                        table.insert(retData.data, 1, nil)
                        table.insert(retData.data, 1, retData.new[1])
                    end
                    -- 


                end
                -- 
                if self.view_ then
                    self.view_:onGetList(type, retData.data, retData);
                end
            else
                if self.view_ then
                    self.view_:onGetList(type, nil, nil);
                end
            end
        end,
        function()
            if self.view_ then
                self.view_:onGetList(type, nil,nil);
            end
        end
    )
end

function ScoreMarketController:exchangeGoods(goods, itemCfg)
    if not goods then 
        return 
    end
    bm.HttpService.CANCEL(self.exchangeGoodsId_)
    self.exchangeGoodsId_ = bm.HttpService.POST(
        {
            mod = "Match",
            act = "exchange",
            gid = goods.id,
            category = goods.category
        },
        function(data)
            local retData = json.decode(data)
            if retData and retData.ret == 0 then
                if self.view_ and self.view_['onExchangeGoods']  then
                    self.view_:onExchangeGoods(retData.data,nil,goods);
                    -- 保存购买物品类型
                    self:saveExchangeGoodsRecord(goods.category);
                end
            else
                if self.view_ and self.view_['onExchangeGoods'] then
                    self.view_:onExchangeGoods(nil,retData,goods);
                end
            end
        end,
        function()
            if self.view_ and self.view_['onExchangeGoods'] then
                self.view_:onExchangeGoods(nil,nil,goods);
            end
        end
    )
end
-- 设置关注
function ScoreMarketController:setOrderPraise(orderId)
    if self.setOrderPraiseId_ then
        if not self.orderStack_ then
            self.orderStack_ = {}
        end
        table.insert(self.orderStack_, orderId)
        return
    end

    self.tempOrderId_ = orderId
    bm.HttpService.CANCEL(self.setOrderPraiseId_)
    self.setOrderPraiseId_ = bm.HttpService.POST(
        {
            mod = "Match",
            act = "orderPraise",
            orderId = self.tempOrderId_
        },
        function(data)
            local retData = json.decode(data)
            if retData and retData.ret == 0 then
                self:saveOrderIdPraise_(self.tempOrderId_)
            end
            self.setOrderPraiseId_ = nil
            if self.orderStack_ and #self.orderStack_ > 0 then
                self:setOrderPraise(table.remove(self.orderStack_, 1))
            end
        end,
        function()
            self.setOrderPraiseId_ = nil
            if self.orderStack_ and #self.orderStack_ > 0 then
                self:setOrderPraise(table.remove(self.orderStack_, 1))
            end
        end
    )
end
-- 添加好友
function ScoreMarketController:setFriendPoker(uid, callback)
    self.setFriendPokerId_ = bm.HttpService.POST({
        mod="friend", 
        act="setPoker", 
        fuid=uid
    }, function(data)
        if callback then
            callback(data)
        end
        self.setFriendPokerId_ = nil
    end, function()
        if callback then
            callback(nil)
        end
        self.setFriendPokerId_ = nil
    end)
end
-- 
function ScoreMarketController:getOrderByGidData(type,page, gid, goodsData)
    if not type then 
        type = "bag"
    end
    if not page then 
        page = 0
    end
    local tempGoodsData = goodsData
    local tempGid = gid
    local tempType = type
    local tempPage = page
    bm.HttpService.CANCEL(self.exchangeRecordId_)
    self.exchangeRecordId_ = bm.HttpService.POST(
        {
            mod = "Match",
            act = "getOrderByGid",
            gid = gid,
            page = page,
        },
        function(data)
            print("getOrderByGid::::".."  type::"..tostring(type))
            print(data)
            local retData = json.decode(data)
            if retData and retData.ret == 0 then
                if self.view_ then
                    -- 给数据绑定物品数据和设置是否已经关注状态
                    for i,v in ipairs(retData.data) do
                        v.goodsData = tempGoodsData
                        v.focused = self:isOrderIdPraise_(v.orderId)
                    end
                    self.view_:onGetExchangeRecord(retData.data,nil,tempType,tempPage,tempGid);
                end
            else
                if self.view_ then
                    self.view_:onGetExchangeRecord(nil,retData,tempType,tempPage,tempGid);
                end
            end
        end,
        function()
            if self.view_ then
                self.view_:onGetExchangeRecord(nil,nil,tempType,tempPage,tempGid);
            end
        end
    )
end

function ScoreMarketController:getExchangeRecord(type,page)
    if not type then 
        type = "bag"
    end
    if not page then 
        page = 0
    end
    local tempType = type
    local tempPage = page
    bm.HttpService.CANCEL(self.exchangeRecordId_)
    self.exchangeRecordId_ = bm.HttpService.POST(
        {
            mod = "Match",
            act = "history",
            category = type,
            page = page,
        },
        function(data)
            -- print("history::::".."  type::"..tostring(type))
            -- print(data)
            local retData = json.decode(data)
            if retData and retData.ret == 0 then
                if self.view_ then
                    self.view_:onGetExchangeRecord(retData.data,nil,tempType,tempPage);
                end
            else
                if self.view_ then
                    self.view_:onGetExchangeRecord(nil,retData,tempType,tempPage);
                end
            end
        end,
        function()
            if self.view_ then
                self.view_:onGetExchangeRecord(nil,nil,tempType,tempPage);
            end
        end
    )
end

-- 获取大转盘列表
function ScoreMarketController:getBigWheelList(callback)
    self.getBigWheelListId_ = bm.HttpService.POST( {
            mod = "Match", 
            act = "bigwheelList"
        },
        function(data)
            local retData = json.decode(data)
            if retData and retData.ret == 0 then
                local retList = {};
                local list = {};
                for k,v in pairs(retData.data.list) do
                    v.img = retData.data.cdn..v.img;

                    table.insert(list, #list+1, v);
                    -- 
                    if #list == 3 then
                        table.insert(retList, #retList+1, list);
                        list = {};
                    end
                end
                -- 
                if #list > 0 then
                    table.insert(retList, #retList+1, list);
                end
                callback(retList);
            end
        end,
        function() 
            callback(nil);
        end
    );
end

-- 获取大转盘详情
function ScoreMarketController:getBigWheelConfig(cfgId, callback)
    self.getBigWheelCfgId_ = bm.HttpService.POST( {
            mod = "Match", 
            act = "bigwheel",
            id = cfgId
        },
        function(data)
            -- print("bigwheel:::"..data);
            local retData = json.decode(data)
            if retData and retData.ret == 0 then
                local retList = {};
                for k,v in pairs(retData.data.list) do
                    v.img = retData.data.cdn..v.img;
                    table.insert(retList, #retList+1, v);
                end
                callback(cfgId, retList);
            end
        end,
        function() 
            callback(nil);
        end
    );
end

-- 获取抽奖历史记录
function ScoreMarketController:getBigWheelLog(type,page)
    if not page then 
        page = 0
    end

    local tempType = type
    local tempPage = page
    self.getBigWheelLogId_ = bm.HttpService.POST( {
            mod = "Match", 
            act = "luckyDrawLog",
            type = 2,
            id = 0,
            p = page
        },
        function(data)
            -- print("luckyDrawLog::::"..data)
            local retData = json.decode(data)
            if retData and retData.ret == 0 then
                local retList = {};
                local item;
                for k,v in pairs(retData.data) do
                    -- v.pin = "23456789456123"
                    item = {}
                    item.name = v.msg;
                    item.create_time = v.time;
                    item.desc = v.pin or "";
                    item.pin = v.pin or "";
                    item.image = "";

                    table.insert(retList, #retList+1, item);
                end
                -- callback(retList)
                if self.view_ then
                    self.view_:onGetExchangeRecord(retList,nil,tempType,tempPage);
                end
            else
                if self.view_ then
                    self.view_:onGetExchangeRecord(nil,retData,tempType,tempPage);
                end 
            end
        end,
        function() 
            callback(nil, nil);
        end
    );
end

-- 获取地址信息
function ScoreMarketController:getMatchAddress1(callback)
    -- if callback then
    --     callback(nil);
    -- end
    
    local result = self:getMatchAddress();
    if result ~= "" then
        if nil ~= callback then
            print("getMatchAddress:::"..result);
            callback(json.decode(result));
        end
    else
        self.getMatchAddressId_ = bm.HttpService.POST( {
                mod = "Match", 
                act = "getAddress"
            },
            function(data)
                print("getMatchAddress:::"..data);
                local retData = json.decode(data)
                if retData and retData.ret == 0 then
                    if callback then
                        callback(retData.data);
                    end
                    -- 保存地址
                    self:updateMatchAddress(json.encode(retData.data));
                else
                    if callback then
                        callback(nil);
                    end
                end
            end,
            function()
                if callback then
                    callback(nil);
                end
            end
        );
    end    
end

-- 保存地址接口
function ScoreMarketController:saveMatchAddress(params, callback)
    self.getMatchAddressId_ = bm.HttpService.POST( {
            mod = "Match", 
            act = "address",
            name = params.name or "",
            sex = params.sex or "",
            phone = params.phone or "",
            city = params.city or "",
            address = params.address or "",
            email = params.email or "",
            area = params.area or "",
            country = params.country or "",
            post = params.post or "",
        },
        function(data)
            print("getMatchAddress:::"..data);
            local retData = json.decode(data)
            if retData and retData.ret == 0 then
                if callback then
                    callback(retData);
                end
                -- 保存地址
                self:updateMatchAddress(json.encode(params));

                nk.TopTipManager:showTopTip(bm.LangUtil.getText("SCOREMARKET", "SAVEADDRESS_SUCCESS"))
            end
        end,
        function()
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("SCOREMARKET", "SAVEADDRESS_FAIL"))
            if callback then
                callback(nil);
            end
        end
    );
end
-- 获取兑换记录详情
function ScoreMarketController:getHistoryDetail(id, itype, callback)
    -- if self.getMatchAddressId_ then
    --     print("getHistoryDetail ~= nil")
    --     return
    -- end
    local tempId = id
    local tempCallback = callback
    self.lastOptTime_ = os.time()
    self.getMatchAddressId_ = bm.HttpService.POST( {
            mod = "Match", 
            act = "historyDetail",
            id = tempId,
            type= itype,
        },
        function(data)
            -- print("historyDetail:::"..data);
            local retData = json.decode(data)
            if retData and retData.ret == 0 then
                if tempCallback then
                    tempCallback(tempId, retData);
                end
            end
            -- 
            self.getMatchAddressId_ = nil
        end,
        function()
            if tempCallback then
                tempCallback(nil, nil);
            end
            -- 
            self.getMatchAddressId_ = nil
        end
    )
end
-- 用户更新兑换订单状态 status 3、5
function ScoreMarketController:updateOrderStatus(orderId, status, img, callback)
    if self.updateOrderStatusId_ then
        return
    end

    local tempOrderId = orderId
    local tempStatus = status
    local tempImg = img
    local tempCallback = callback
    self.updateOrderStatusId_ = bm.HttpService.POST( {
            mod = "Match", 
            act = "updateOrderStatus",
            orderId = tempOrderId,
            status = tempStatus,
            img = tempImg
        },
        function(data)
            print("updateOrderStatus:::"..data);
            local retData = json.decode(data)
            if retData then
                if retData.ret == 0 then
                    if tempCallback then
                        tempCallback(tempOrderId, retData);
                    end
                else
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("SCOREMARKET", "UPDATE_ORDER_STATUS_FAIL", tostring(retData.ret)))
                    tempCallback(nil, nil);
                end
            else
                tempCallback(nil, nil); 
            end
            -- 
            self.updateOrderStatusId_ = nil
        end,
        function()
            if tempCallback then
                tempCallback(nil, nil);
            end
            -- 
            self.updateOrderStatusId_ = nil
        end
    )
end
--     {
--   mod: "Match",
--   act: "updateOrderStatus",
--   orderId: 1053,  // 订单ID
--   status: "3",    // 状态，只能是3或5，具体含义参照上面兑换记录
--   img: "http://xxxxxxxxxxxxxxx/xx.jpg"    // 收货图片
-- }
-- 保存比赛场玩家地址信息
function ScoreMarketController:updateMatchAddress(str)
    local key = "MATCH_ADDRESS_"..tostring(nk.userData.uid);
    nk.userDefault:setStringForKey(key, str);
    nk.userDefault:flush();
end
-- 获取比赛场玩家地址信息
function ScoreMarketController:getMatchAddress()
    local key = "MATCH_ADDRESS_"..tostring(nk.userData.uid);
    return nk.userDefault:getStringForKey(key);
end

-- 保存用户兑换物品记录信息
-- “สินค้าแต่ละกลุ่มสามารถแลกได้วันละ 1 ครั้งเท่านั้น วันนี้ท่านได้ทำการแลกสินค้าในกลุ่ม XXX ไปแล้ว กรุณาไปแลกสินค้าในกลุ่มอื่นค่ะ ”
function ScoreMarketController:saveExchangeGoodsRecord(category)
    local today = os.date("%Y%m%d")
    local k1 = "MATCH_EXCHANGE_DAY_"..tostring(nk.userData.uid);
    local k2 = "MATCH_EXCHANGE_GR_"..tostring(nk.userData.uid);
    local saved_day = nk.userDefault:getStringForKey(k1, "");
    local key = category.."_";
    local items;
    if saved_day == today then
        items = json.decode(nk.userDefault:getStringForKey(k2, "")) or {};
        if items and items[category] then
            items[category] = items[category] + 1;
        else
            items[category] = 1;
        end
        -- 
        key = json.encode(items);
        nk.userDefault:setStringForKey(k2, key)
    else
        items = {};
        items[category] = 1;
        key = json.encode(items);
        nk.userDefault:setStringForKey(k1, today);
        nk.userDefault:setStringForKey(k2, key)
    end
    nk.userDefault:flush();
end
-- 判断是否可以兑换
function ScoreMarketController:isExchangeGoods(category)
    local today = os.date("%Y%m%d")
    local k1 = "MATCH_EXCHANGE_DAY_"..tostring(nk.userData.uid);
    local k2 = "MATCH_EXCHANGE_GR_"..tostring(nk.userData.uid);
    local saved_day = nk.userDefault:getStringForKey(k1, "");
    local key = category.."_";
    if saved_day == tostring(today) then
        local items = json.decode(nk.userDefault:getStringForKey(k2, "")) or {};
        -- 限制每一项只能兑换一个
        if items[category] and items[category] > 0 then
            return false;
        end

        return true;
    else
        return true;  
    end
end

-- 保存OrderId
function ScoreMarketController:saveOrderIdPraise_(orderId)
    local key = tostring(orderId)
    self.allOrderIdPraises_[key] = true
end
-- 获取OrderId
function ScoreMarketController:isOrderIdPraise_(orderId)
    if not orderId then
        return false
    end
    -- 
    local key = tostring(orderId)
    if self.allOrderIdPraises_[key] then
        return true
    else
        return false
    end
end
-- 
function ScoreMarketController:getAllOrderIdPraises()
    if not self.allOrderIdPraises_ then
        local key = "orderIdPraises_"..tostring(nk.userData.uid)
        local orderIdPraiseStr = self:getUserDefaultData(key)
        local arr = string.split(orderIdPraiseStr,",")
        self.allOrderIdPraises_ = {}
        for i=1, #arr do
            key = tostring(arr[i])
            if key ~= "nil" and string.len(key) > 0 then
                self.allOrderIdPraises_[key] = true
            end
        end
    end
    return self.allOrderIdPraises_
end
-- 
function ScoreMarketController:setAllOrderIdPraises()
    if self.allOrderIdPraises_ then
        local key = "orderIdPraises_"..tostring(nk.userData.uid)
        local keys = {}
        for value,_ in pairs(self.allOrderIdPraises_) do
            table.insert(keys, value)
        end
        local valueStr = table.concat(keys, ",")
        self:updateUserDefaultData(key, valueStr) 
    end
end
-- 获取保存本地数据
function ScoreMarketController:getUserDefaultData(key)
    return nk.userDefault:getStringForKey(key);
end
-- 把dataStr保存到本地
function ScoreMarketController:updateUserDefaultData(key, dataStr)
    nk.userDefault:setStringForKey(key, dataStr);
    nk.userDefault:flush();
end

function ScoreMarketController:dispose()
    self.view_ = nil
    bm.HttpService.CANCEL(self.exchangeGoodsId_)
    bm.HttpService.CANCEL(self.getMatchScoreListId_)
    bm.HttpService.CANCEL(self.exchangeRecordId_)
    bm.HttpService.CANCEL(self.getBigWheelListId_)
    bm.HttpService.CANCEL(self.getBigWheelCfgId_)
    bm.HttpService.CANCEL(self.getBigWheelLogId_)

    bm.HttpService.CANCEL(self.getMatchAddressId_)
    
    self:setAllOrderIdPraises()
end

return ScoreMarketController
