
local DealerRewardView = class("DealerRewardView", function() return display.newNode() end)

function DealerRewardView:ctor(type, msg)
    self.type_ = type
    self.light = display.newSprite("#pop_vip_light.png")
            :addTo(self)
    self.light:runAction(cc.RepeatForever:create(transition.sequence({
            cc.RotateTo:create(1, 180), 
            cc.RotateTo:create(1, 360)
        })))
    
    if self.type_ > 0 and self.type_ < 4 then
        self.goldbox = display.newSprite("#goldbox" .. self.type_ .. "_closed.png"):addTo(self)
    else
        self.goldbox = display.newSprite("#goldbox3_closed.png"):addTo(self)
    end

    self.paopaoTips_ = nk.ui.PaoPaoTips.new(msg, 18, {left=0,right=0}, cc.size(400, 0))
    self.paopaoTips_:pos(0, 88):addTo(self, 12):hide()
end

function DealerRewardView:showContent()
    if self.goldbox then
        if self.type_ > 0 and self.type_ < 4 then
            self.goldbox:setSpriteFrame(display.newSpriteFrame("goldbox" .. self.type_ .. "_open.png"))
        else
            self.goldbox:setSpriteFrame(display.newSpriteFrame("goldbox3_open.png"))
        end
    end
    self.paopaoTips_:show()
end

return DealerRewardView