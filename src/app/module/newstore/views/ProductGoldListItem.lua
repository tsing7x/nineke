--
-- Author: kevinYu
-- Date: 2016-5-24
-- 黄金币
local BaseProductItem = import(".BaseProductItem")
local ProductGoldListItem = class("ProductGoldListItem", BaseProductItem)

ProductGoldListItem.WIDTH = 100
ProductGoldListItem.HEIGHT = 77

function ProductGoldListItem:ctor()
    local item_w, item_h = ProductGoldListItem.WIDTH, ProductGoldListItem.HEIGHT

    ProductGoldListItem.super.ctor(self, item_w, item_h + 2)
end

function ProductGoldListItem:setProductIcon_()
    local data = self.data_

    local filename = "store_prd_gold_" .. data.img .. ".png"
    local x, y = 50, 53
    local path = cc.FileUtils:getInstance():fullPathForFilename(filename)
    if io.exists(path) then
        self.prdImg_ = display.newSprite(filename)
            :align(display.LEFT_CENTER, x, y)
            :addTo(self.bg_)
    else
        local prdFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(filename)
        if prdFrame then
            self.prdImg_ = display.newSprite(prdFrame)
                :align(display.LEFT_CENTER, x, y)
                :addTo(self.bg_)
        end
    end
end

return ProductGoldListItem