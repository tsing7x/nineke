--
-- Author: kevinYu
-- Date: 2016-5-24
-- 每行显示多个商品,注意比ProductChipListItem多了个s

local ProductGoldListItems = class("ProductGoldListItems", bm.ui.ListItem)
local ProductGoldItem = import(".ProductGoldItem")

ProductGoldListItems.WIDTH = 100
ProductGoldListItems.HEIGHT = 20

local item_w, item_h = 191, 250 --每个子元素的宽高
local floor_y = 25

function ProductGoldListItems:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    local w, h = ProductGoldListItems.WIDTH, ProductGoldListItems.HEIGHT

    ProductGoldListItems.super.ctor(self, w, h + 2)

    self:setNodeEventEnabled(true)

    display.newScale9Sprite("#store_goods_floor.png", 0, 0, cc.size(w, 56))
        :align(display.TOP_CENTER, w/2, floor_y)
        :addTo(self)
    
    local dir = (w - item_w * 3) / 4
    local offsetX = dir + item_w
    local sx, sy = dir + item_w/2, h/2 - 30

    self.items_ = {}
    for i = 1, 3 do
        self.items_[i] = self:createProductItem_(sx + (i - 1) * offsetX, sy)
    end
end

function ProductGoldListItems:createProductItem_(x, y)
    local item = ProductGoldItem.new({
            width = item_w,
            height = item_h,
        })
        :pos(x, y)
        :addTo(self)
        :hide()

    return item
end

function ProductGoldListItems:onDataSet(dataChanged, data)
    for i = 1, 3 do
        self.items_[i]:hide()
    end

    for i = 1, #data do
        self.items_[i]:show()
        self.items_[i]:setProductData(dataChanged, data[i])

        if self.index_ > 1 then
            self.items_[i]:showTopLight()
        end

        if self.index_ == 1 then
            local w, h = ProductGoldListItems.WIDTH, ProductGoldListItems.HEIGHT - floor_y
            self:setContentSize(cc.size(w, h))
        end
    end 
end

return ProductGoldListItems