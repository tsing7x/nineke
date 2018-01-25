--
-- Author: johnny@boomegg.com
-- Date: 2014-08-12 20:58:45
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--
local RoomViewPosition = import(".RoomViewPosition")

local SeatView = import(".PdengSeatView")

local SeatStateMachine = import("app.module.pdeng.model.SeatStateMachine")

local WaitDealerView = class("WaitDealerView", function()
    return display.newNode()
end)

function WaitDealerView:ctor(parent,tip, ctx)
    self.parent_ = parent
    self.ctx_ = ctx
    if tip == bm.LangUtil.getText("ROOM", "ENTERING_MSG") or tip == bm.LangUtil.getText("MATCH", "CHANGING_ROOM_MSG") then
        tip = nk.EnterTipsManager:getRandomTips();
        nk.EnterTipsManager:reg(self)
    end
   -- self:setTouchEnabled(true)
    --self:setNodeEventEnabled(true)
    -- 透明触摸层
    local transparentSkin = display.newSprite("#common_transparent_skin.png")
        :addTo(self)
    transparentSkin:setScaleX(display.width / 4)
    transparentSkin:setScaleY(display.height / 4)

    -- 背景
    local bg = display.newSprite("table_mask.png")
        :addTo(self)
    bg:setScaleX((display.width) / bg:getContentSize().width)
    bg:setScaleY((display.height) / bg:getContentSize().height)
    bg:setOpacity(200)
    -- 筹码动画
    self.selfThis_ = self
    display.addSpriteFrames("loadingChip_texture.plist", "loadingChip_texture.png", function()
        if self.selfThis_ then       
            local frames = display.newFrames("loading_chip_%d.png", 1, 12)
            local animation = display.newAnimation(frames, 1 / 12)
            local animSprite = display.newSprite(animation[1])
                :pos(0, 44)
                :addTo(self.selfThis_)
            animSprite:playAnimationForever(animation, 0)
        end
    end)
    -- 文字
    self.lbl = ui.newTTFLabel({text = tip, color = styles.FONT_COLOR.LIGHT_TEXT, size = 28, align = ui.TEXT_ALIGN_CENTER})
        :pos(0, -50)
        :addTo(self)

    self.systemDealerChair_ = display.newSprite("#pdeng_room_dealer_chair.png")
    self.systemDealerChair_:setSpriteFrame("pdeng_room_upbanker_chair.png")
    self.systemDealerChair_:pos(display.cx, RoomViewPosition.SeatPositionForDealer[1].y - 12 - 462)
    :addTo(parent,2,2)

    local SEAT_POS = RoomViewPosition.SeatPositionForDealer[5]
    self.seat_ = SeatView.new(self.ctx_, 1) --seatId 0~8
    :addTo(parent,3,3)
    :pos(SEAT_POS.x,SEAT_POS.y+40)

    local player = {};
    player.userInfo = nk.getUserInfo(false) 
            player.giftId = player.userInfo.giftId
            player.nick = player.userInfo.name
            player.userInfo.nick = player.userInfo.name
            player.img = player.userInfo.mavatar
            player.userInfo.img = player.userInfo.mavatar
            player.seatChips = nk.userData.money
    player.statemachine = SeatStateMachine.new(player, false, "st_waitstart")
    self.seat_:setSeatData(player)
    self.seat_:updateState()
    --seat:updateHeadImage(nk.userData.s_picture)
     --2 桌子背景
    -- local SEAT_POS = RoomViewPosition.SeatPositionForDealer[5]
    -- self.background_ = display.newScale9Sprite("#room_seat_bg.png", 0, 0, cc.size(108, 164)):addTo(parent, 3)
    -- :pos(SEAT_POS.x,SEAT_POS.y+30)


    -- --用户头像容器
    -- self.image_ = display.newNode():add(display.newSprite("#common_male_avatar.png"), 1, 1):pos(0, -100)
    
    -- local stencil = display.newDrawNode()
    -- local pn = {{-50, -50}, {-50, 50}, {50, 50}, {50, -50}}  
    -- local clr = cc.c4f(255, 0, 0, 255)  
    -- stencil:drawPolygon(pn, clr, 1, clr)

    -- self.clipNode_:setStencil(stencil)
    -- self.clipNode_:addChild(self.sitdown_, 1, 1)
    -- self.clipNode_:addChild(self.image_, 2, 2)
    -- self.clipNode_:addTo(parent, 4, 4)

    -- if isShowMatchIpPort then
    --     self.iplbl_ = ui.newTTFLabel({
    --             text="",
    --             color=cc.c3b(255,255,255),
    --             size=16,
    --             align=ui.TEXT_ALIGN_CENTER
    --         })
    --         :pos(0, 96)
    --         :addTo(self);

    --     self.WaitDealerViewId_ = bm.EventCenter:addEventListener("update_matchIpPort_WaitDealerView", handler(self, self.onUpdateMatchWaitDealerView_))
    -- end
end

function WaitDealerView:onUpdateMatchWaitDealerView_(evt)
    -- if evt and evt.data then
    --     if not self.total_ then
    --         self.total_ = 0;
    --     end
    --     -- 
    --     local evtData = evt.data;
    --     self.total_ = self.total_ + tonumber(evtData.src)
    --     local preStr = ""
    --     for i=1,self.total_ do
    --         preStr=preStr.."."
    --     end

    --     local msg = evtData.ip..":"..evtData.port.." "..preStr;
    --     self.iplbl_:setString(msg)
    --end
end

function WaitDealerView:dispose()
    self.systemDealerChair_:removeFromParent()
    self.seat_:removeFromParent()
end

function WaitDealerView:onCleanup()
    nk.EnterTipsManager:unreg(self)
    if self.WaitDealerViewId_ then
        bm.EventCenter:removeEventListener(self.WaitDealerViewId_)
        self.WaitDealerViewId_ = nil;
    end
end

return WaitDealerView