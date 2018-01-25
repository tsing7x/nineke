--
-- Author: kevinYu
-- Date: 2016-5-25
-- 一行显示一个筹码商品

local BaseProductItem = import(".BaseProductItem")
local ProductChipListItem = class("ProductChipListItem", BaseProductItem)

ProductChipListItem.WIDTH = 100
ProductChipListItem.HEIGHT = 20

function ProductChipListItem:ctor()
    local item_w, item_h = ProductChipListItem.WIDTH, ProductChipListItem.HEIGHT
    ProductChipListItem.super.ctor(self, item_w, item_h + 2)
end

function ProductChipListItem:setProductIcon_()
    local img = self.data_.img
    local path = cc.FileUtils:getInstance():fullPathForFilename("store_prd_" .. img .. ".png")
    local x, y = 50, 50
    if io.exists(path) then
        self.prdImg_ = display.newSprite("store_prd_" .. img .. ".png")
            :align(display.LEFT_BOTTOM, x, y)
            :addTo(self.bg_)
    else
        local prdFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame("store_prd_" .. img .. ".png")
        if prdFrame then
            self.prdImg_ = display.newSprite(prdFrame)
                :align(display.LEFT_CENTER, x, y)
                :addTo(self.bg_)
        end
    end
end

return ProductChipListItem