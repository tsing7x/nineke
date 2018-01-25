--
-- Author: kevinYu
-- Date: 2016-5-24
-- 每行显示多个商品,注意比ProductChipListItem多了个s

local ProductChipListItems = class("ProductChipListItems", bm.ui.ListItem)
local ProductChipItem = import(".ProductChipItem")

ProductChipListItems.WIDTH = 100
ProductChipListItems.HEIGHT = 20

local item_w, item_h = 191, 250 --每个子元素的宽高
local floor_y = 25

function ProductChipListItems:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    local w, h = ProductChipListItems.WIDTH, ProductChipListItems.HEIGHT

    ProductChipListItems.super.ctor(self, w, h + 2) 

    self:setNodeEventEnabled(true)

    display.newScale9Sprite("#store_goods_floor.png", 0, 0, cc.size(w, 56))
        :align(display.TOP_CENTER, w/2, floor_y)
        :addTo(self)

    local dir = (w - item_w * 3) / 4
    local offsetX = dir + item_w
    local sx, sy = dir + item_w/2, h/2 - 30

    self.items_ = {}
    self.lights_ = {}
    for i = 1, 3 do
        self.items_[i] = self:createProductChipItem_(sx + (i - 1) * offsetX, sy)
    end   
end

function ProductChipListItems:createProductChipItem_(x, y)
    local item = ProductChipItem.new({
            width = item_w,
            height = item_h,
        })
        :pos(x, y)
        :addTo(self)
        :hide()

    return item
end

function ProductChipListItems:onDataSet(dataChanged, data)
    for i = 1, 3 do
        self.items_[i]:hide()
    end
    
    for i = 1, #data do
        self.items_[i]:show()
        self.items_[i]:setProductData(dataChanged, data[i])

        if self.index_ > 1 then
            self.items_[i]:showTopLight()
        end
    end

    if self.index_ == 1 then
        local w, h = ProductChipListItems.WIDTH, ProductChipListItems.HEIGHT - floor_y
        self:setContentSize(cc.size(w, h))
    end
end

return ProductChipListItems