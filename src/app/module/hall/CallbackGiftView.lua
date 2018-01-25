--
-- Author: davidxifeng@gmail.com
-- Date: 2015-06-09 17:17:00
-- 召回宝箱弹框
--- class
local CallbackGiftView = class("CallbackGiftView", function ()
    return display.newNode()
end)

--- import
local CommonRewardChipAnimation = import("app.login.CommonRewardChipAnimation")

-- chips
-- key
function CallbackGiftView:ctor(gift)

    self.gift_ = gift

    -- 半透明黑色背景遮罩 + 触摸事件拦截
    local dark_bg = display.newColorLayer(cc.c4f(0, 0, 0, 128))
        :addTo(self)
    dark_bg:setTouchEnabled(true)
    dark_bg:setTouchSwallowEnabled(true)
    dark_bg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == 'began' then
            return true
        elseif event.name == 'ended' then
            self:playBoxOpenThenClose_()
        end
    end)
    self.dark_bg_ = dark_bg

    local batchNode = display.newBatchNode("hall_texture.png")
        :addTo(dark_bg)

    local light_effect = display.newSprite('#callback_gift/light_effect.png')
    light_effect:addTo(batchNode)
    light_effect:pos(display.cx, display.cy)

    local ROTATE_TIME = 1

    light_effect:runAction(cc.RepeatForever:create(transition.sequence({
        cc.RotateTo:create(ROTATE_TIME, 180),
        cc.RotateTo:create(ROTATE_TIME, 360)
    })))

    self.box_ = display.newSprite('#callback_gift/box_close.png')
    self.box_:addTo(batchNode)
    self.box_:pos(display.cx, display.cy)

end

function CallbackGiftView:playBoxOpenThenClose_()
    -- 禁掉后续的点击，防止重复领取
    self.dark_bg_:setTouchEnabled(false)
    bm.HttpService.POST(
        {
            mod  = "recall",
            act  = "reward",
            key  = self.gift_.key,
        },
        function (httpResponse)
            -- ret == 0 一切成功
            if json.decode(httpResponse).ret ~= 0 then
                self:removeFromParent()
                return
            end

            local box_open_sf = display.newSpriteFrame('callback_gift/box_open.png')
            self.box_:setSpriteFrame(box_open_sf)

            local txt = bm.LangUtil.getText('HALL', 'OPEN_CALLBACK_REWARD',
                bm.formatBigNumber(self.gift_.chips))
            local label_tip = ui.newTTFLabel({
                    text = txt, color = cc.c3b(0xfb, 0xee, 0x59),
                    size = 28, align = ui.TEXT_ALIGN_CENTER})
                :pos(display.cx, display.cy + 100)
                :addTo(self)

            self:performWithDelay(function ()
                local box_empty_sf = display.newSpriteFrame('callback_gift/box_empty.png')
                self.box_:setSpriteFrame(box_empty_sf)

                local OFFSET_X, OFFSET_Y = 50, 120

                CommonRewardChipAnimation.new()
                    :pos(display.cx - OFFSET_X, display.cy - OFFSET_Y)
                    :addTo(self)
                nk.ui.ChangeChipAnim.new(self.gift_.chips)
                    :pos(display.cx, display.cy)
                    :addTo(self)

                -- 动画播放删除自己
                self:performWithDelay(function ()
                    self:removeFromParent()
                end, 1.25)

            end, 0.25)
        end,
        function ()
            self:removeFromParent()
        end
    )

end

return CallbackGiftView
