--
-- Author: KevinYu
-- Date: 2016-05-18 18:04:31
-- 黄金币item，一行显示多个黄金币商品

local BaseProductItems = import(".BaseProductItems")
local ProductGoldItem = class("ProductGoldItem", BaseProductItems)

function ProductGoldItem:ctor(params)
    ProductGoldItem.super.ctor(self, params)
end

function ProductGoldItem:setProductIcon_()
    local data = self.data_
    local bg = self.bg_
    local x, y = self.bg_w/2, self.bg_h/2 + 20
    local filename = "store_prd_gold_" .. data.img .. ".png"

    local path = cc.FileUtils:getInstance():fullPathForFilename(filename)
    if io.exists(path) then
        self.prdImg_ = display.newSprite(filename)
            :pos(x, y)
            :addTo(bg)
    else
        local prdFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(filename)
        if prdFrame then
            self.prdImg_ = display.newSprite(prdFrame)
                :pos(x, y)
                :addTo(bg)
        end
    end
end

return ProductGoldItem
