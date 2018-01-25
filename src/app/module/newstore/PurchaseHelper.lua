--
-- Author: tony
-- Date: 2014-11-19 21:54:34
--
local PurchaseHelper = class("PurchaseHelper")

local DEFAULT_CACHE_DIR = device.writablePath .. "cache" .. device.directorySeparator .. "remotedata" .. device.directorySeparator
bm.mkdir(DEFAULT_CACHE_DIR)

function PurchaseHelper:ctor(name)
    self.logger = bm.Logger.new(name .. ".PurchaseHelper")
end

function PurchaseHelper:parsePrice(p)
    local s, e = string.find(p, "%d")
    local partDollar
    local partNumber
    local partNumberLen
    if s <= 1 then
        local lastNumIdx = 1
        while true do
            local st, ed = string.find(p, "%d", lastNumIdx + 1)
            if ed then
                lastNumIdx = ed
            else
                partDollar = string.sub(p, lastNumIdx + 1)
                partNumber = string.sub(p, 1, lastNumIdx)
                partNumberLen = string.len(partNumber)
                break
            end
        end
    else
        partDollar = string.sub(p, 1, s - 1)
        partNumber = string.sub(p, s)
        partNumberLen = string.len(partNumber)
    end

    local priceNum = 0
    local split, dot = "", ""
    local s1, e1 = string.find(partNumber, "%p")
    if s1 then
        --找到第一个标点
        local firstP = string.sub(partNumber, s1, e1)
        local s2, e2 = string.find(partNumber, "%p", s1 + 1)
        if s2 then
            --至少2个标点
            local secondP = string.sub(partNumber, s2, e2)
            if firstP == secondP then
                --2个一样的标点肯定分隔符
                split = firstP
                local str = string.gsub(partNumber, "%" .. firstP, "")
                local sdb, sde = string.find(str, "%p")
                if sdb then
                    --去掉分隔符之后的肯定是小数点
                    dot = string.sub(str, sdb, sde)
                    str = string.gsub(str, "%" .. dot, ".")
                end
                priceNum = tonumber(str)
            else
                --2个标点不一样，前面的是分隔符，后面的是小数点
                split = firstP
                dot = secondP
                local str = string.gsub(partNumber, "%" .. split, "")
                str = string.gsub(str, "%" .. dot, ".")
                priceNum = tonumber(str)
            end
        else
            --只有一个标点
            if string.sub(partNumber, 1, s1 - 1) == "0" then
                --标点前面为0，这个标点肯定是小数点
                dot = firstP
                --把这个标点替换为 "."
                local str = string.gsub(partNumber, "%" .. firstP, ".")
                priceNum = tonumber(str)
            elseif partNumberLen == e1 + 3 then
                --标点之后有3位，假定这个标点为分隔符
                split = firstP
                local str = string.gsub(partNumber, "%" .. firstP, "")
                priceNum = tonumber(str)
            elseif partNumberLen <= e1 + 2 then
                --标点之后有2或1位，假定这个标点为小数点
                dot = firstP
                local str = string.gsub(partNumber, "%" .. firstP, ".")
                priceNum = tonumber(str)
            elseif firstP == "," then
                --默认","为分隔符
                split = firstP
                local str = string.gsub(partNumber, "%" .. firstP, "")
                priceNum = tonumber(str)
            elseif firstP == "." then
                --默认"."为小数点
                dot = firstP
                local str = string.gsub(partNumber, "%" .. firstP, ".")
                priceNum = tonumber(str)
            else
                split = firstP
                local str = string.gsub(partNumber, "%" .. firstP, "")
                priceNum = tonumber(str)
            end
        end
    else
        --找不到标点
        priceNum = tonumber(partNumber)
    end

    return partDollar, priceNum, split, dot
end

function PurchaseHelper:parseConfig(jsonString, itemCallback)
end

function PurchaseHelper:parseGoods(goodsTable, itemCallback)
    local jsonGoods = goodsTable
    local result = {}
    result.skus = {}

    local chips = {}
    result.chips = chips

    local props = {}
    result.props = props

    local golds = {}
    result.golds = golds

    local packages = {}
    result.packages = packages

    local vips = {}
    result.vips = vips

    for _, good in pairs(jsonGoods) do
        local prd = {}
        if good.show == "1" then
            if good.ptype == "1" then --筹码
                prd.pid = good.id
                prd.id = good.id
                prd.price = good.pamount
                prd.title = good.getname
                prd.pnum = good.pnum
                prd.pamount = good.pamount
                prd.tag = good.tag or ""
                prd.pmode = good.pmode
                prd.sortid = good.sortid
                prd.bygood = good
                prd.skus = good.skus
                prd.discount = tonumber(good.discount)
                if itemCallback then
                    itemCallback("chips", prd)
                end
                table.insert(chips,prd)
                if prd.skus then
                    table.insert(result.skus, prd.skus)
                end
            elseif good.ptype == "2" or good.ptype == "38" or good.ptype == "34" then --道具
                prd.pid = good.id
                prd.id = good.id
                prd.detail = good.getname
                prd.price = good.pamount
                prd.title = good.getname
                prd.propId = good.ptype
                prd.tag = good.tag or ""
                prd.pmode = good.pmode
                prd.sortid = good.sortid
                prd.propType = tonumber(good.ptype)
                prd.bygood = good
                prd.discount = tonumber(good.discount)
                prd.skus = good.skus
                prd.pnum = good.pnum
                if itemCallback then
                    itemCallback("props", prd)
                end
                table.insert(props,prd)
                if prd.skus then
                    table.insert(result.skus, prd.skus)
                end
            elseif good.ptype == "35" then --黄金币
                prd.pid = good.id
                prd.id = good.id
                prd.detail = good.getname
                prd.price = good.pamount
                prd.title = good.getname
                prd.propId = good.ptype
                prd.tag = good.tag or ""
                prd.pmode = good.pmode
                prd.sortid = good.sortid
                prd.propType = tonumber(good.ptype)
                prd.bygood = good
                prd.discount = tonumber(good.discount)
                prd.pnum = good.pnum
                prd.skus = good.skus
                if itemCallback then
                    itemCallback("golds", prd)
                end
                table.insert(golds,prd)
                if prd.skus then
                    table.insert(result.skus, prd.skus)
                end
            elseif good.ptype == "37" then --VIP
                prd.pid = good.id
                prd.id = good.id
                prd.detail = good.getname
                prd.price = good.pamount
                prd.title = good.getname
                prd.propId = good.ptype
                prd.tag = good.tag or ""
                prd.pmode = good.pmode
                prd.sortid = good.sortid
                prd.bygood = good
                prd.discount = tonumber(good.discount)
                prd.pnum = good.pnum
                prd.skus = good.skus

                local content = json.decode(good.ext.content) 
                prd.chips = content.chips

                local ext = json.decode(content.ext) 
                prd.loginrwd = ext.loginrwd
                prd.level = ext.level
                prd.exp = ext.exp
                prd.brokeDis = ext.dis
                prd.brokeDisNum = ext.disnum
                prd.expression = ext.vipface
                prd.tickcard = ext.tickcard
                if itemCallback then
                    itemCallback("vips", prd)
                end
                table.insert(vips,prd)
                if prd.skus then
                    table.insert(result.skus, prd.skus)
                end
            elseif good.ptype == "6" then --礼包
                prd.pid = good.id
                prd.id = good.id
                prd.price = good.pamount
                prd.title = good.subtitle
                prd.desc = good.getname
                prd.pnum = good.pchips
                prd.pamount = good.pamount
                prd.tag = good.tag or ""
                prd.pmode = good.pmode
                prd.sortid = good.sortid
                prd.propType = tonumber(good.ptype)
                prd.bygood = good
                prd.discount = tonumber(good.discount)
                prd.skus = good.skus
                if itemCallback then
                    itemCallback("packages", prd)
                end
                table.insert(packages, prd)
                if prd.skus then
                    table.insert(result.skus, prd.skus)
                end
            elseif good.ptype == "7" then --新版礼包
                prd.pid = good.id
                prd.id = good.id
                prd.price = good.pamount
                prd.title = good.subtitle or good.getname
                prd.desc = good.getname
                prd.pnum = good.pnum
                prd.content = json.decode(good.ext.content)
                prd.pchips = prd.content.chips
                prd.pamount = good.pamount
                prd.tag = good.tag or ""
                prd.pmode = good.pmode
                prd.sortid = good.sortid
                prd.propType = tonumber(good.ptype)
                prd.bygood = good
                prd.discount = tonumber(good.discount)
                prd.skus = good.skus
                if itemCallback then
                    itemCallback("packages", prd)
                end
                table.insert(packages, prd)
                if prd.skus then
                    table.insert(result.skus, prd.skus)
                end
            end
        end
        
    end

    table.sort(chips,function(a,b) 
            if tonumber(a.sortid) == tonumber(b.sortid) then
                return tonumber(a.pnum) > tonumber(b.pnum) 
            else
                return tonumber(a.sortid) > tonumber(b.sortid) 
            end
        end)

    table.sort(golds,function(a,b) 
            if tonumber(a.sortid) == tonumber(b.sortid) then
                return tonumber(a.pnum) > tonumber(b.pnum) 
            else
                return tonumber(a.sortid) > tonumber(b.sortid) 
            end
        end)

    table.sort(props,function(a,b) 
            if tonumber(a.sortid) == tonumber(b.sortid) then
                return tonumber(a.pnum) > tonumber(b.pnum) 
            else
                return tonumber(a.sortid) > tonumber(b.sortid) 
            end
        end)

    table.sort(vips,function(a,b) 
            if tonumber(a.sortid) == tonumber(b.sortid) then
                return tonumber(a.level) < tonumber(b.level) 
            else
                return tonumber(a.sortid) > tonumber(b.sortid) 
            end
        end)

    local size = #chips
    for i = 1,size do
        chips[i].img = self:getChipsImg(tonumber(chips[i].pnum))
    end

    for i = 1, #props do
        props[i].img = self:getPropsImg(tonumber(props[i].pnum))
    end

    for i = 1, #golds do
        golds[i].img = self:getGoldsImg(tonumber(golds[i].pnum))
    end

    return result
end

function PurchaseHelper:getChipsImg(chips)
    if chips >= 3000000 then
        return 105
    elseif chips >= 2000000 then
        return 104
    elseif chips >= 1000000 then
        return 103
    elseif chips >= 500000 then
        return 102
    elseif chips >= 250000 then
        return 101
    else
        return 100
    end
end

function PurchaseHelper:getPropsImg(prop)
    if prop >= 750 then
        return 105
    elseif prop >= 450 then
        return 104
    elseif prop >= 250 then
        return 103
    elseif prop >= 100 then
        return 102
    elseif prop >= 50 then
        return 101
    else
        return 100
    end
end

function PurchaseHelper:getGoldsImg(gold)
    if gold >= 3500 then
        return 105
    elseif gold >= 2000 then
        return 104
    elseif gold >= 1300 then
        return 103
    elseif gold >= 600 then
        return 102
    elseif gold >= 350 then
        return 101
        
    else
        return 100
    end
end

function PurchaseHelper:updateDiscount(products)
    if not products then return end
    if products.chips then
        for i, chip in ipairs(products.chips) do
            if not chip.priceLabel then
                chip.priceLabel = "THB" .. chip.price
            end

            local partDollar, priceNum
            if chip.priceNum and chip.priceDollar then
                partDollar = chip.priceDollar
                priceNum = chip.priceNum
            elseif not chip.priceNum then
                partDollar, priceNum = self:parsePrice(chip.priceLabel)
                chip.priceNum = priceNum
                chip.priceDollar = partDollar
            else
                priceNum = chip.priceNum
                chip.priceDollar = self:parsePrice(chip.priceLabel)
            end

            if chip.discount ~= 1 then
                chip.rate = chip.pnum * chip.discount / priceNum
                chip.numOff = math.floor(chip.pnum * chip.discount)
                chip.discountTitle = bm.LangUtil.getText("STORE", "FORMAT_CHIP", bm.formatBigNumber(chip.numOff))
            else
                chip.rate = chip.pnum / priceNum
                chip.discountTitle = chip.title
            end
            chip.rate = tonumber(string.format("%.2f", chip.rate))
        end
    end

    if products.props then
        for i, prop in ipairs(products.props) do
            if not prop.priceLabel then
                prop.priceLabel = "THB" .. prop.price
            end

            local partDollar, priceNum
            if prop.priceNum and prop.priceDollar then
                partDollar = prop.priceDollar
                priceNum = prop.priceNum
            elseif not prop.priceNum then
                partDollar, priceNum = self:parsePrice(prop.priceLabel)
                prop.priceNum = priceNum
                prop.priceDollar = partDollar
            else
                priceNum = prop.priceNum
                prop.priceDollar = self:parsePrice(prop.priceLabel)
            end

            if prop.discount ~= 1 then
                prop.rate = prop.pnum * prop.discount / priceNum
                prop.numOff = math.floor(prop.pnum * prop.discount)
                prop.discountTitle = bm.LangUtil.getText("STORE", "FORMAT_PROP", bm.formatBigNumber(prop.numOff))
            else
                prop.rate = prop.pnum / priceNum
                prop.discountTitle = prop.title
            end
            
            prop.rate = tonumber(string.format("%.2f", prop.rate))
        end
    end

    if products.golds then
        for i, gold in ipairs(products.golds) do
            if not gold.priceLabel then
                gold.priceLabel = "THB" .. gold.price
            end

            local partDollar, priceNum
            if gold.priceNum and gold.priceDollar then
                partDollar = gold.priceDollar
                priceNum = gold.priceNum
            elseif not gold.priceNum then
                partDollar, priceNum = self:parsePrice(gold.priceLabel)
                gold.priceNum = priceNum
                gold.priceDollar = partDollar
            else
                priceNum = gold.priceNum
                gold.priceDollar = self:parsePrice(chip.priceLabel)
            end

            if gold.discount ~= 1 then
                gold.rate = gold.pnum * gold.discount / priceNum
                gold.numOff = math.floor(gold.pnum * gold.discount)
                gold.discountTitle = bm.LangUtil.getText("STORE", "FORMAT_GOLD", bm.formatBigNumber(gold.numOff))
            else
                gold.rate = gold.pnum / priceNum
                gold.discountTitle = gold.title
            end

            gold.rate = tonumber(string.format("%.2f", gold.rate))
        end
    end

    if products.vips then
        for i, vip in ipairs(products.vips) do
            if not vip.priceLabel then
                vip.priceLabel = "THB" .. vip.price
            end

            local partDollar, priceNum
            if vip.priceNum and vip.priceDollar then
                partDollar = vip.priceDollar
                priceNum = vip.priceNum
            elseif not vip.priceNum then
                partDollar, priceNum = self:parsePrice(vip.priceLabel)
                vip.priceNum = priceNum
                vip.priceDollar = partDollar
            else
                priceNum = gold.priceNum
                vip.priceDollar = self:parsePrice(chip.priceLabel)
            end

            if vip.discount ~= 1 then
                vip.rate = vip.pnum * vip.discount / priceNum
                vip.numOff = math.floor(vip.pnum * vip.discount)
                vip.discountTitle = bm.LangUtil.getText("STORE", "FORMAT_GOLD", bm.formatBigNumber(vip.numOff))
            else
                vip.rate = vip.pnum / priceNum
                vip.discountTitle = vip.title
            end

            vip.rate = tonumber(string.format("%.2f", vip.rate))
        end
    end
end

function PurchaseHelper:generateOrderId(pid,pmode,params,callback)
    local orderId = ""
    local orderData = {}
    local postData = {
            mod="Payment",
            act="callPayOrder",
            id = pid,
            pmode = pmode,
            siteuid = nk.userData.siteuid or "",
            uid = nk.userData.uid or ""
        }
    if params then
        table.merge(postData,params)
    end
    -- 群组商城优惠
    if Global_isInGroupShop==1 then
        postData.is_group = 1   -- 使用群组折扣
    else
        postData.is_group = 0   -- 正常其他地方支付
    end

    bm.HttpService.POST(postData,
            function(data)
                local orderData = json.decode(data)
                dump(orderData, "PurchaseHelper:generateOrderId[Payment.callPayOrder].retData :===========")


                if orderData and orderData.RET == 0 then
                    orderId = orderData.ORDER
                    callback(true,orderId,orderData.MSG,orderData)
                else
                    callback(false,"",orderData and orderData.MSG or "")
                end
            end,
            function()
                nk.badNetworkToptip()
                callback(false)
            end)
end

return PurchaseHelper
