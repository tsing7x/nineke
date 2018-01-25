local ScrollView = import(".ScrollView")

local ScrollLabel = class("ScrollLabel", ScrollView)


function ScrollLabel:ctor(labelParams,scrollParams)
    ScrollLabel.super.ctor(self, scrollParams)
    if not scrollParams then
        scrollParams = {}
    end

    if not scrollParams.viewRect then
        scrollParams.viewRect = cc.rect(0, 0, 10, 10)
    end

    -- 滚动容器
    self.content_ = display.newNode()
    self:setScrollContent(self.content_)
    self.label_ = ui.newTTFLabel(labelParams)
        :pos(2,0)
        :addTo(self.content_)


    -- 高度必须设置零
    self.label_:setDimensions(scrollParams.viewRect.width, 0)
    self.maxWidth_ = scrollParams.viewRect.width
    self.maxHeight_ = scrollParams.viewRect.height
    self:update()
end

function ScrollLabel:setString(str)
    if not str then str="" end
    self.label_:setString(str)
    local size = self.label_:getContentSize()
    self.content_:setContentSize(cc.size(size.width,size.height))
    self:update()
end

function ScrollLabel:getString()
    return self.label_:getString()
end

return ScrollLabel