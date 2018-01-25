--
-- Author: johnny@boomegg.com
-- Date: 2014-08-12 20:58:45
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local RoomLoading = class("RoomLoading", function()
    return display.newNode()
end)

function RoomLoading:ctor(tip, isShowMatchIpPort)
    if tip == bm.LangUtil.getText("ROOM", "ENTERING_MSG") or tip == bm.LangUtil.getText("MATCH", "CHANGING_ROOM_MSG") then
        tip = nk.EnterTipsManager:getRandomTips();
        nk.EnterTipsManager:reg(self)
    end
    self:setTouchEnabled(true)
    self:setNodeEventEnabled(true)
    -- 透明触摸层
    local transparentSkin = display.newSprite("#common_transparent_skin.png")
        :addTo(self)
    transparentSkin:setScaleX(display.width / 4)
    transparentSkin:setScaleY(display.height / 4)

    -- 背景
    local bg = display.newSprite("#full_screen_tip_bg.png")
        :addTo(self)
    bg:setScaleX((display.width) / bg:getContentSize().width)
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

    if isShowMatchIpPort then
        self.iplbl_ = ui.newTTFLabel({
                text="",
                color=cc.c3b(255,255,255),
                size=16,
                align=ui.TEXT_ALIGN_CENTER
            })
            :pos(0, 96)
            :addTo(self);

        self.roomloadingId_ = bm.EventCenter:addEventListener("update_matchIpPort_roomLoading", handler(self, self.onUpdateMatchRoomLoading_))
    end
end

function RoomLoading:onUpdateMatchRoomLoading_(evt)
    if evt and evt.data then
        if not self.total_ then
            self.total_ = 0;
        end
        -- 
        local evtData = evt.data;
        self.total_ = self.total_ + tonumber(evtData.src)
        local preStr = ""
        for i=1,self.total_ do
            preStr=preStr.."."
        end

        local msg = evtData.ip..":"..evtData.port.." "..preStr;
        self.iplbl_:setString(msg)
    end
end

function RoomLoading:onCleanup()
    nk.EnterTipsManager:unreg(self)
    if self.roomloadingId_ then
        bm.EventCenter:removeEventListener(self.roomloadingId_)
        self.roomloadingId_ = nil;
    end
end

return RoomLoading