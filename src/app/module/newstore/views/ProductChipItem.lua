--
-- Author: KevinYu
-- Date: 2016-05-18 18:04:31
-- 筹码item，一行显示多个筹码商品

local BaseProductItems = import(".BaseProductItems")
local ProductChipItem = class("ProductChipItem", BaseProductItems)

function ProductChipItem:ctor(params)
    ProductChipItem.super.ctor(self, params)
end

function ProductChipItem:setProductIcon_()
    local index = self.data_.img
    local img = "store_prd_" .. index .. ".png"
    local x, y = self.bg_w/2, self.bg_h/2 + 20
    local s = 1
    if index > 102 then
        s = 1.2
    end
    
    if self.data_.pmode == "348" then
        if self.data_.pamount == "14" then
            img = "store_prd_flow_1.png"
        elseif self.data_.pamount == "34" then
            img = "store_prd_flow_7.png"
        end
    end
    --先查找非打包文件，主要用于更新某张图片，不需要打包更新
    local path = cc.FileUtils:getInstance():fullPathForFilename(img)
    if io.exists(path) then
        self.prdImg_ = display.newSprite(img)
            :scale(s)
            :pos(x, y)
            :addTo(self.bg_)
    else
        local prdFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(img)
        if prdFrame then
            self.prdImg_ = display.newSprite(prdFrame)
                :scale(s)
                :pos(x, y)
                :addTo(self.bg_)
        end
    end
end

return ProductChipItem
