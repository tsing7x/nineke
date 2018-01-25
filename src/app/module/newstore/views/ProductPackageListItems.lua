--
-- Author: kevinYu
-- Date: 2016-5-24
-- 大礼包
local ProductPackageListItems = class("ProductPackageListItems", bm.ui.ListItem)
local ProductPackageItem = import(".ProductPackageItem")

ProductPackageListItems.WIDTH = 100
ProductPackageListItems.HEIGHT = 20

local item_w, item_h = 330, 228 --每个子元素的宽高

function ProductPackageListItems:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    local w, h = ProductPackageListItems.WIDTH, ProductPackageListItems.HEIGHT

    ProductPackageListItems.super.ctor(self, w, h + 2)

    self:setNodeEventEnabled(true)
    
    self.items_ = {}
    local dir = (w - item_w * 2) / 3
    local offsetX = dir + item_w
    local sx, sy = dir + item_w/2, h/2
    for i = 1, 2 do
        self.items_[i] = self:createProductPackageItem_(sx + (i - 1) * offsetX, sy)
    end
end

function ProductPackageListItems:createProductPackageItem_(x, y)
    local item = ProductPackageItem.new({
            width = item_w,
            height = item_h,
        })
        :pos(x, y)
        :addTo(self)
        :hide()

    return item
end

function ProductPackageListItems:onDataSet(dataChanged, data)
    for i = 1, 2 do
        self.items_[i]:hide()
    end

    for i = 1, #data do
        self.items_[i]:show()
        self.items_[i]:setProductData(dataChanged, data[i])
    end 
end

return ProductPackageListItems