--
-- Author: kevinYu
-- Date: 2016-5-24

local BaseProductItem = import(".BaseProductItem")
local ProductPropListItem = class("ProductPropListItem", BaseProductItem)

ProductPropListItem.WIDTH = 100
ProductPropListItem.HEIGHT = 77

function ProductPropListItem:ctor()
    local item_w, item_h = ProductPropListItem.WIDTH, ProductPropListItem.HEIGHT

    ProductPropListItem.super.ctor(self, item_w, item_h + 2, ProductPropListItem.IS_SHOW_BTN)
end

function ProductPropListItem:setProductIcon_()
    local data = self.data_

    local scale = 1
    local str = bm.LangUtil.getText("STORE", "PROP_DES", self.data_.pnum)
    local filename = "store_prd_prop_" .. data.img .. ".png"
    if data.propId and data.propId == "38" then
        filename = "pop_userinfo_prop_kickCard.png"
        scale = 0.6
        str = bm.LangUtil.getText("STORE", "KICK_CARD_DES")
    end

    if data.propId and data.propId == "34" then
        filename = "pop_userinfo_prop_e2p_".. data.skus ..".png"
        scale = 0.6
        str = bm.LangUtil.getText("STORE", "E2P_TICKET_DES_" .. data.skus)
    end

    self:showGoodsDes(str)
    local x, y = 50, 68
    local path = cc.FileUtils:getInstance():fullPathForFilename(filename)
    if io.exists(path) then
        self.prdImg_ = display.newSprite(filename)
            :align(display.LEFT_CENTER, x, y)
            :addTo(self.bg_)
            :scale(scale)
    else
        local prdFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(filename)
        if prdFrame then
            self.prdImg_ = display.newSprite(prdFrame)
                :align(display.LEFT_CENTER, x, y)
                :addTo(self.bg_)
                :scale(scale)
        end
    end
end

return ProductPropListItem