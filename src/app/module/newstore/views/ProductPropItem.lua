--
-- Author: KevinYu
-- Date: 2016-05-18 18:04:31
-- 道具item，一行显示多个道具商品

local BaseProductItems = import(".BaseProductItems")
local ProductPropItem = class("ProductPropItem", BaseProductItems)

function ProductPropItem:ctor(params)
    ProductPropItem.super.ctor(self, params)
end

function ProductPropItem:setProductIcon_()
    local data = self.data_

    local filename = "store_prd_prop_" .. data.img .. ".png"
    if data.propId and data.propId == "38" then
        filename = "pop_userinfo_prop_kickCard.png"
    end
    if data.propId and data.propId == "34" then
        filename = "pop_userinfo_prop_e2p_".. data.skus ..".png"
    end

    local x, y = self.bg_w/2, self.bg_h/2 + 20
    
    local path = cc.FileUtils:getInstance():fullPathForFilename(filename)
    if io.exists(path) then
        self.prdImg_ = display.newSprite(filename)
            :pos(x, y)
            :addTo(self.bg_)
    else
        local prdFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(filename)
        if prdFrame then
            self.prdImg_ = display.newSprite(prdFrame)
                :pos(x, y)
                :addTo(self.bg_)
        end
    end
end

return ProductPropItem
