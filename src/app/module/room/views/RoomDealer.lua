--
-- Author: johnny@boomegg.com
-- Maintainer: QuinnNie@boyaa.com
-- Date: 2014-08-20 13:32:49
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local RoomDealer = class("RoomDealer", function ()
    return display.newNode()
end)

-- 暂定所有荷官的动作帧数 时间 一样
-- 不同荷官只有美术资源的不同 和 相应的位置坐标的不同
local DealerInfo = {
    [1] = {
        dealerBody = '#dealer_basic/room_dealer.png', -- 荷官
        tapTablePos = {0, 0},
        tapTable = {
            'dealer_basic/room_dealer_tap_table_1.png',
            'dealer_basic/room_dealer_tap_table_2.png',
            'dealer_basic/room_dealer_tap_table_3.png',
        },
        -- 眨两只眼睛动画
        blinkTwoEyePos = {0, 0},
        blinkTwoEyes = {
            'dealer_basic/room_dealer_blink_1.png',
            'dealer_basic/room_dealer_blink_2.png',
        },
        singleBlinkPos = {0, 0},
        singleBlink = {
            'dealer_basic/room_dealer_single_blink_1.png',
            'dealer_basic/room_dealer_single_blink_2.png',
        },
        kissPlayerPos = {0, 0},
        kissPlayer = {
            'dealer_basic/room_dealer_kiss_1.png',
            'dealer_basic/room_dealer_kiss_2.png',
        },
    },

    [2] = {
        dealerBody = '#dealer_intermediate/room_dealer.png', -- 荷官
        tapTablePos = {0, 0},
        tapTable = {
            'dealer_intermediate/room_dealer_tap_table_1.png',
            'dealer_intermediate/room_dealer_tap_table_2.png',
            'dealer_intermediate/room_dealer_tap_table_3.png',
        },
        -- 眨两只眼睛动画
        blinkTwoEyePos = {0, 0},
        blinkTwoEyes = {
            'dealer_intermediate/room_dealer_blink_1.png',
            'dealer_intermediate/room_dealer_blink_2.png',
        },
        singleBlinkPos = {0, 0},
        singleBlink = {
            'dealer_intermediate/room_dealer_single_blink_1.png',
            'dealer_intermediate/room_dealer_single_blink_2.png',
        },
        kissPlayerPos = {0, 0},
        kissPlayer = {
            'dealer_intermediate/room_dealer_kiss_1.png',
            'dealer_intermediate/room_dealer_kiss_2.png',
        },
    },

    [3] = {
        dealerBody = '#dealer_advanced/room_dealer.png',
        dealerBodyPos = {0,12},
        tapTablePos = {0, 12},
        tapTable = {
            'dealer_advanced/room_dealer_tap_table_1.png',
            'dealer_advanced/room_dealer_tap_table_2.png',
            'dealer_advanced/room_dealer_tap_table_3.png',
        },
        -- 眨两只眼睛动画
        blinkTwoEyePos = {0, 12},
        blinkTwoEyes = {
            'dealer_advanced/room_dealer_blink_1.png',
            'dealer_advanced/room_dealer_blink_2.png',
        },
        singleBlinkPos = {0, 12},
        singleBlink = {
            'dealer_advanced/room_dealer_single_blink_1.png',
            'dealer_advanced/room_dealer_single_blink_2.png',
        },
        kissPlayerPos = {0, 12},
        kissPlayer = {
            'dealer_advanced/room_dealer_kiss_1.png',
            'dealer_advanced/room_dealer_kiss_2.png',
        },
    },

    [4] = {
        isMatch = true,
        dealerBodyPos = {1,4},
        dealerBody = '#match1/room_dealer.png', -- 荷官
        tapTablePos = {0, 0},
        tapTable = {
            'match1/room_dealer_tap_table_1.png',
            'match1/room_dealer_tap_table_2.png',
            'match1/room_dealer_tap_table_3.png',
        },
        -- 眨两只眼睛动画
        blinkTwoEyePos = {0, 0},
        blinkTwoEyes = {
            'match1/room_dealer_blink_1.png',
            'match1/room_dealer_blink_2.png',
        },
        singleBlinkPos = {0, 0},
        singleBlink = {
            'match1/room_dealer_single_blink_1.png',
            'match1/room_dealer_single_blink_2.png',
        },
        kissPlayerPos = {0, 0},
        kissPlayer = {
            'match1/room_dealer_kiss_1.png',
            'match1/room_dealer_kiss_2.png',
        },
    },
    [5] = {
        dealerBody = '#dealer_4k/room_dealer.png',
        dealerBodyPos = {0,12},
        tapTablePos = {-2, 13},
        tapTable = {
            'dealer_4k/room_dealer_tap_table_1.png',
            'dealer_4k/room_dealer_tap_table_2.png',
            'dealer_4k/room_dealer_tap_table_3.png',
        },
        -- 眨两只眼睛动画
        blinkTwoEyePos = {0, 12},
        blinkTwoEyes = {
            'dealer_4k/room_dealer_blink_1.png',
            'dealer_4k/room_dealer_blink_2.png',
        },
        singleBlinkPos = {0, 12},
        singleBlink = {
            'dealer_4k/room_dealer_single_blink_1.png',
            'dealer_4k/room_dealer_single_blink_2.png',
        },
        kissPlayerPos = {0, 12},
        kissPlayer = {
            'dealer_4k/room_dealer_kiss_2.png',
            'dealer_4k/room_dealer_kiss_1.png',
        },
    },
    [6] = {
        dealerBody = '#dealer_5k/room_dealer.png',
        dealerBodyPos = {0,12},
        tapTablePos = {-2, 13},
        tapTable = {
            'dealer_5k/room_dealer_tap_table_1.png',
            'dealer_5k/room_dealer_tap_table_2.png',
            'dealer_5k/room_dealer_tap_table_3.png',
        },
        -- 眨两只眼睛动画
        blinkTwoEyePos = {-1, 12},
        blinkTwoEyes = {
            'dealer_5k/room_dealer_blink_1.png',
            'dealer_5k/room_dealer_blink_2.png',
        },
        singleBlinkPos = {0, 12},
        singleBlink = {
            'dealer_5k/room_dealer_single_blink_1.png',
            'dealer_5k/room_dealer_single_blink_2.png',
        },
        kissPlayerPos = {0, 12},
        kissPlayer = {
            'dealer_5k/room_dealer_kiss_2.png',
            'dealer_5k/room_dealer_kiss_1.png',
        },
    },
}
-- 比赛场荷官
local MatchDealerInfo = {
    [1] = {
        isMatch = true,
        dealerBodyPos = {1,4},
        dealerBody = '#match1/room_dealer.png', -- 荷官
        tapTablePos = {0, 0},
        tapTable = {
            'match1/room_dealer_tap_table_1.png',
            'match1/room_dealer_tap_table_2.png',
            'match1/room_dealer_tap_table_3.png',
        },
        -- 眨两只眼睛动画
        blinkTwoEyePos = {0, 0},
        blinkTwoEyes = {
            'match1/room_dealer_blink_1.png',
            'match1/room_dealer_blink_2.png',
        },
        singleBlinkPos = {0, 0},
        singleBlink = {
            'match1/room_dealer_single_blink_1.png',
            'match1/room_dealer_single_blink_2.png',
        },
        kissPlayerPos = {0, 0},
        kissPlayer = {
            'match1/room_dealer_kiss_1.png',
            'match1/room_dealer_kiss_2.png',
        },
    },
    [2] = DealerInfo[2],
    [3] = DealerInfo[3]
    -- [2] = {
    --     dealerBody = '#match2/room_dealer.png', -- 荷官
    --     tapTablePos = {0, 0},
    --     tapTable = {
    --         'match2/room_dealer_tap_table_1.png',
    --         'match2/room_dealer_tap_table_2.png',
    --         'match2/room_dealer_tap_table_3.png',
    --     },
    --     -- 眨两只眼睛动画
    --     blinkTwoEyePos = {0, 0},
    --     blinkTwoEyes = {
    --         'match2/room_dealer_blink_1.png',
    --         'match2/room_dealer_blink_2.png',
    --     },
    --     singleBlinkPos = {0, 0},
    --     singleBlink = {
    --         'match2/room_dealer_single_blink_1.png',
    --         'match2/room_dealer_single_blink_2.png',
    --     },
    --     kissPlayerPos = {0, 0},
    --     kissPlayer = {
    --         'match2/room_dealer_kiss_1.png',
    --         'match2/room_dealer_kiss_2.png',
    --     },
    -- },

    -- [3] = {
    --     dealerBodyPos = {0,5},
    --     dealerBody = '#match3/room_dealer.png',
    --     tapTablePos = {0, 0},
    --     tapTable = {
    --         'match3/room_dealer_tap_table_1.png',
    --         'match3/room_dealer_tap_table_2.png',
    --         'match3/room_dealer_tap_table_3.png',
    --     },
    --     -- 眨两只眼睛动画
    --     blinkTwoEyePos = {0, 0},
    --     blinkTwoEyes = {
    --         'match3/room_dealer_blink_1.png',
    --         'match3/room_dealer_blink_2.png',
    --     },
    --     singleBlinkPos = {0, 0},
    --     singleBlink = {
    --         'match3/room_dealer_single_blink_1.png',
    --         'match3/room_dealer_single_blink_2.png',
    --     },
    --     kissPlayerPos = {0, 0},
    --     kissPlayer = {
    --         'match3/room_dealer_kiss_1.png',
    --         'match3/room_dealer_kiss_2.png',
    --     },
    -- },
}

function RoomDealer:ctor(dealerId,isMatch,clickCallback)
    assert(dealerId == math.floor(dealerId) and dealerId >= 1 and dealerId <= #DealerInfo)
    self.dealerId_ = dealerId -- 此ID暂时没用到
    self.clickCallback_ = clickCallback
   
    if isMatch == true then
        self.ti = MatchDealerInfo[dealerId]
        if self.ti.isMatch==true then
            self.batchNode_ = display.newBatchNode("roommatch_texture.png")
            :addTo(self)
        else
            self.batchNode_ = display.newBatchNode("room_texture.png")
            :addTo(self)
        end
    else
        self.ti = DealerInfo[dealerId]
        self.batchNode_ = display.newBatchNode("room_texture.png")
        :addTo(self)
        self.pushArea_ = cc.ui.UIPushButton.new({normal="#common_transparent_skin.png"}, {scale9 = true})
        :setButtonSize(100,150)
        :onButtonClicked(buttontHandler(self,self.onDealerPush_))
        :addTo(self)
    end

    self.mainBody_ = display.newSprite(self.ti.dealerBody)
        :addTo(self.batchNode_)
    
    local coord = self.ti.dealerBodyPos
    if coord then
        self.mainBody_:setPosition(coord[1],coord[2])
    end
    self.tapSpr_ = display.newSprite('#' .. self.ti.tapTable[1])
        :pos(unpack(self.ti.tapTablePos))
        :addTo(self.batchNode_)
    self.blinkTwoEyesAction_ = self.mainBody_:schedule(handler(self, self.blinkTwoEyes_), 3)
end

function RoomDealer:onDealerPush_()
    if self.clickCallback_ then
        self.clickCallback_()
    end
end

function RoomDealer:killLoop()
    -- if self.mainBody_ and self.blinkTwoEyesAction_ then
        self.mainBody_:stopAction(blinkTwoEyesAction_)
        self.blinkTwoEyesAction_ = nil
    -- end
end

function RoomDealer:blinkTwoEyes_()
    local blinkTwoSpr = display.newSprite('#' .. self.ti.blinkTwoEyes[1])
        :pos(unpack(self.ti.blinkTwoEyePos))
        :addTo(self.batchNode_)
    blinkTwoSpr:performWithDelay(function ()
        blinkTwoSpr:setSpriteFrame(display.newSpriteFrame(self.ti.blinkTwoEyes[2]))
    end, 0.05)
    blinkTwoSpr:performWithDelay(function ()
        blinkTwoSpr:setSpriteFrame(display.newSpriteFrame(self.ti.blinkTwoEyes[1]))
    end, 0.15)
    blinkTwoSpr:performWithDelay(function ()
        blinkTwoSpr:removeFromParent()
    end, 0.20)
end

-- 亲嘴玩家
function RoomDealer:kissPlayer()
    -- 先眨眼
    if self.blinkSingleSpr_ then
        self.blinkSingleSpr_:removeFromParent()
    end
    self.blinkSingleSpr_ = display.newSprite('#' .. self.ti.singleBlink[1])
        :pos(unpack(self.ti.singleBlinkPos))
        :addTo(self.batchNode_)

    self.blinkSingleSpr_:performWithDelay(function ()
        self.blinkSingleSpr_:setSpriteFrame(display.newSpriteFrame(self.ti.singleBlink[2]))
    end, 0.05)
    self.blinkSingleSpr_:performWithDelay(function ()
        self.blinkSingleSpr_:setSpriteFrame(display.newSpriteFrame(self.ti.singleBlink[1]))
    end, 0.15)
    self.blinkSingleSpr_:performWithDelay(function ()
        self.blinkSingleSpr_:removeFromParent()
        self.blinkSingleSpr_ = nil

        -- 后亲嘴
        local kissSpr = display.newSprite('#' .. self.ti.kissPlayer[1])
            :pos(unpack(self.ti.kissPlayerPos))
            :addTo(self.batchNode_)
        kissSpr:performWithDelay(function ()
            kissSpr:setSpriteFrame(display.newSpriteFrame(self.ti.kissPlayer[2]))
        end, 0.05)
        kissSpr:performWithDelay(function ()
            kissSpr:setSpriteFrame(display.newSpriteFrame(self.ti.kissPlayer[1]))
        end, 0.15)
        kissSpr:performWithDelay(function ()
            kissSpr:removeFromParent()
        end, 0.20)
    end, 0.20)
end

-- 敲桌子
function RoomDealer:tapTable()
    local tapSpr = self.tapSpr_
    if tapSpr:getNumberOfRunningActions() >= 1 then
        tapSpr:stopAllActions()
    end

    local t = self.ti.tapTable

    tapSpr:performWithDelay(function ()
        nk.SoundManager:playSound(nk.SoundManager.TAP_TABLE)
        tapSpr:setSpriteFrame(display.newSpriteFrame(t[2]))
    end, 0.25)
    tapSpr:performWithDelay(function ()
        tapSpr:setSpriteFrame(display.newSpriteFrame(t[3]))
    end, 0.40)
    tapSpr:performWithDelay(function ()
        tapSpr:setSpriteFrame(display.newSpriteFrame(t[2]))
    end, 0.55)
    tapSpr:performWithDelay(function ()
        tapSpr:setSpriteFrame(display.newSpriteFrame(t[3]))
    end, 0.65)
    tapSpr:performWithDelay(function ()
        tapSpr:setSpriteFrame(display.newSpriteFrame(t[1]))
    end, 0.90)
end

return RoomDealer
