--
-- Author: kevinYu
-- Date: 2015-11-10 15:20:20
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

--[[
    取值范围：0~1
    local bar = ProgressBar.new("#progress_bar_bg.png", "#progress_bar_fill.png", 200)
    bar:addTo(container)
    bar:setValue(0.3)
]]

local ProgressBar = class("ProgressBar", function ()
    return display.newNode()
end)

function ProgressBar:ctor(backgroundSkin, fillSkin, sizes)
    self.isShowZeroValue_ = false 
    self.sizes_ = sizes
    self.background_ = display.newScale9Sprite(backgroundSkin, 0, 0, cc.size(sizes.bgWidth, sizes.bgHeight))
        :align(display.LEFT_CENTER, 0, 0)
        :addTo(self)
    self.fill_ = display.newScale9Sprite(fillSkin, 0, 0, cc.size(sizes.fillWidth, sizes.fillHeight))
        :align(display.LEFT_CENTER, (sizes.bgHeight - sizes.fillHeight) * 0.5, 0)
        :addTo(self)
    self.value_ = -1
    self.maxFillWidth_ = sizes.bgWidth - (sizes.bgHeight - sizes.fillHeight)
end

function ProgressBar:setValue(val)
    if val == self.value_ then
        return self
    end
    if val <= 0 then val = 0 end
    if val >= 1 then val = 1 end
    self.value_ = val
    local x = self.sizes_.fillWidth / self.maxFillWidth_

    if self.value_ <= self.sizes_.fillWidth / self.maxFillWidth_ then
        if self.isShowZeroValue_ then
            self.fill_:hide()
        else
            self.fill_:setContentSize(cc.size(self.sizes_.fillWidth, self.sizes_.fillHeight))
        end
    else
        self.fill_:show()
        self.fill_:setContentSize(cc.size(self.maxFillWidth_ * self.value_, self.sizes_.fillHeight))
    end

    return self
end

--为了兼容不同图片，设置fill的位置偏差
function ProgressBar:setOffset(x, y)
    local px, py = self.fill_:getPosition()
    self.fill_:pos(px + x, py + y)
    return self
end

--是否显示进度为0的情况  true显示（看不见进度） false 不显示（有一个最小值，不为0）
function ProgressBar:setZeroState(enable)
    self.isShowZeroValue_ = enable
    return self
end

return ProgressBar