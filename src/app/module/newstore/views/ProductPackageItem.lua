--
-- Author: KevinYu
-- Date: 2016-05-18 18:04:31
-- 礼包item，一行显示多个礼包商品

local BaseProductItems = import(".BaseProductItems")
local ProductPackageItem = class("ProductPackageItem", BaseProductItems)

function ProductPackageItem:ctor(params)
    ProductPackageItem.super.ctor(self, params)
end

function ProductPackageItem:setProductIcon_()
    -- self.rateBg_:hide()
    
    local filename = "store_prd_package.png"

    local path = cc.FileUtils:getInstance():fullPathForFilename(filename)
    if io.exists(path) then
        self.prdImg_ = display.newSprite(filename)
    else
        local prdFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(filename)
        if prdFrame then
            self.prdImg_ = display.newSprite(prdFrame)
        end
    end

    if self.prdImg_ then
        self.prdImg_:pos(70, self.bg_h/2 + 8)
        self.prdImg_:addTo(self.bg_)
    end

    if not self.descLabel_ then
        local desc = self.data_.desc
        desc = string.gsub(desc, "+", "\n+")
        self.descLabel_= ui.newTTFLabel({
            text = desc,
            color = cc.c3b(0xd3, 0xd0, 0x7f),
            size = 22,
            align = ui.TEXT_ALIGN_LEFT,
            dimensions = cc.size(150, 0)
        })
        :pos(self.bg_w/2 + 50, self.bg_h/2 + 8)
        :addTo(self.bg_)
    end
    
end

return ProductPackageItem
