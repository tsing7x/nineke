--
-- Author: tony
-- Date: 2014-07-18 14:44:26
--

local OperationButton = import(".OperationButton")

local RaiseSlider = class("RaiseSlider", function()
    return display.newNode()
end)

function RaiseSlider:ctor()
    -- local backgroundWidth = OperationButton.BUTTON_WIDTH + 2
    local backgroundWidth = 212 + 16
    local backgroundHeight = 548 + 2 + 12
    local labelWidth = backgroundWidth - 16 - 12
    local trackX = backgroundWidth * 0.5 - 39 - 8
    
    --背景
    self.background_ = display.newScale9Sprite("#room_raise_panel_bg.png", 0, 0, cc.size(backgroundWidth, backgroundHeight))
    self.background_:setCapInsets(cc.rect(20, 20, 20, 20))
    self.background_:addTo(self)
    self.background_:setTouchEnabled(true)
    self.background_:setTouchSwallowEnabled(true)

    --文字背景
    self.labelBackground_ = display.newScale9Sprite("#room_raise_bar_chip_text_bg.png", 0, backgroundHeight * 0.5 - 14 - 29 - 6, cc.size(labelWidth, 58))
    self.labelBackground_:addTo(self)

    --横线1
    self.hline1_ = display.newSprite("#room_raise_split_line.png")
    self.hline1_:pos(0, self.labelBackground_:getPositionY() - 29 - 6 - 6)
    self.hline1_:setScaleX(labelWidth / 4)
    self.hline1_:addTo(self)

    --横线2
    self.hline2_ = display.newSprite("#room_raise_split_line.png")
    self.hline2_:pos(0, self.hline1_:getPositionY() - 430 - 20 - 6)
    self.hline2_:setScaleX(labelWidth / 4)
    self.hline2_:addTo(self)

    local trackY = (self.hline1_:getPositionY() + self.hline2_:getPositionY()) * 0.5
    RaiseSlider.THUMB_BOUND_TOP = trackY + 218 - 176 / 2
    RaiseSlider.THUMB_BOUND_BOTTOM = trackY - 218 + 176 / 2
    RaiseSlider.THUMB_BOUND_HEIGHT = RaiseSlider.THUMB_BOUND_TOP - RaiseSlider.THUMB_BOUND_BOTTOM

    --加注Slider背景
    self.trackBackground_ = display.newScale9Sprite("#room_raise_track_bg.png", trackX, trackY, cc.size(24,430))
    self.trackBackground_:setCapInsets(cc.rect(0, 12, 24, 8))
    self.trackBackground_:addTo(self)

    --加注Slider背景覆盖层
    self.trackBackgroundOverlay_ = display.newScale9Sprite("#room_raise_track_bg_overlay.png", trackX, trackY, cc.size(12, 418)):addTo(self)

    --加注Slider背景横纹
    self.trackHLineBatch_ = display.newDrawNode()
    for i = 1, 412 / 4 do
        local ox, oy = -4, i*4 - 209
        self.trackHLineBatch_:drawRect({x = ox, y = oy}, {x = ox + 7, y = oy + 2}, {fillColor=cc.c3b(0x32, 0x46, 0x39)})
    end
    self.trackHLineBatch_:pos(trackX, trackY):addTo(self)

    --加注Slider蓝色指示条
    self.trackBlue_ = display.newScale9Sprite("#room_raise_blue_track_bg.png", 0, 0, cc.size(12, 418))
    self.trackBlue_:setAnchorPoint(cc.p(0.5, 0))
    self.trackBlue_:pos(trackX, trackY-209)
    self.trackBlue_:addTo(self)

    --加注Slider黄色指示条
    self.trackYellow_ = display.newScale9Sprite("#room_raise_yellow_track_bg.png", 0, 0, cc.size(12, 418))
    self.trackYellow_:setAnchorPoint(cc.p(0.5, 0))
    self.trackYellow_:pos(trackX, trackY-209)
    self.trackYellow_:addTo(self)

    --加注Slider按钮
    self.thumb_ = display.newSprite("#common_slider_thumb.png")
    self.thumb_:setRotation(90)
    self.thumb_:setTouchEnabled(true)
    self.thumb_:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onThumbTouch_))
    self.thumb_:pos(trackX, trackY)
    self.thumb_:addTo(self)

    local btnX = -40
    local btnTop = self.hline1_:getPositionY() - 44 -  20
    local btnGap = 88 + 12

    --全部奖池按钮
    self.btnAllPot_ = nk.ui.SimpleButton.new({
        label = bm.LangUtil.getText("ROOM", "BUYIN_ALL_POT"),
        width = labelWidth - 76,
        height = 88,
        up={
            background={
                texture="#room_raise_btn_up.png",
                scale9 = true
            },
            label={
                type="ttf",
                size=20,
                color=cc.c3b(0xab, 0xb1, 0xbb)
            }
        },
        down={
            background={
                texture="#room_raise_btn_down.png",
                scale9 = true
            },
            label={
                type="ttf",
                size=20,
                color=cc.c3b(0x46, 0x47, 0x47)
            }
        },
        disabled="down"
    }, 1):onClicked(handler(self, self.onButtonClicked_)):pos(btnX, btnTop):enabled(true):addTo(self)

    --3/4奖池按钮
    self.btn3QPot_ = nk.ui.SimpleButton.new({
        label = bm.LangUtil.getText("ROOM", "BUYIN_3QUOT_POT"),
        width = labelWidth - 76,
        height = 88,
        up={
            background={
                texture="#room_raise_btn_up.png",
                scale9 = true
            },
            label={
                type="ttf",
                size=20,
                color=cc.c3b(0xab, 0xb1, 0xbb)
            }
        },
        down={
            background={
                texture="#room_raise_btn_down.png",
                scale9 = true
            },
            label={
                type="ttf",
                size=20,
                color=cc.c3b(0x46, 0x47, 0x47)
            }
        },
        disabled="down"
    }, 2):onClicked(handler(self, self.onButtonClicked_)):pos(btnX, btnTop - btnGap):enabled(true):addTo(self)

    --1/2奖池按钮
    self.btnHalfPot_ = nk.ui.SimpleButton.new({
        label = bm.LangUtil.getText("ROOM", "BUYIN_HALF_POT"),
        width = labelWidth - 76,
        height = 88,
        up={
            background={
                texture="#room_raise_btn_up.png",
                scale9 = true
            },
            label={
                type="ttf",
                size=20,
                color=cc.c3b(0xab, 0xb1, 0xbb)
            }
        },
        down={
            background={
                texture="#room_raise_btn_down.png",
                scale9 = true
            },
            label={
                type="ttf",
                size=20,
                color=cc.c3b(0x46, 0x47, 0x47)
            }
        },
        disabled="down"
    }, 3):onClicked(handler(self, self.onButtonClicked_)):pos(btnX, btnTop - 2 * btnGap):enabled(true):addTo(self)

    --3倍反加
    self.btnTriple_ = nk.ui.SimpleButton.new({
        label = bm.LangUtil.getText("ROOM", "BUYIN_TRIPLE"),
        width = labelWidth - 76,
        height = 88,
        up={
            background={
                texture="#room_raise_btn_up.png",
                scale9 = true
            },
            label={
                type="ttf",
                size=20,
                color=cc.c3b(0xab, 0xb1, 0xbb)
            }
        },
        down={
            background={
                texture="#room_raise_btn_down.png",
                scale9 = true
            },
            label={
                type="ttf",
                size=20,
                color=cc.c3b(0x46, 0x47, 0x47)
            }
        },
        disabled="down"
    }, 4):onClicked(handler(self, self.onButtonClicked_)):pos(btnX, btnTop - 3 * btnGap):enabled(true):addTo(self)

    self.label_ = ui.newTTFLabel({text="$0", size=32, color=cc.c3b(0xc4, 0xca, 0xd4)})
        :pos(self.labelBackground_:getPositionX(), self.labelBackground_:getPositionY())
        :addTo(self)

    --all in 按钮
    local s = self.labelBackground_:getContentSize()
    self.btnAllin_ = nk.ui.SimpleButton.new({
        width = s.width,
        height = s.height,
        up={
            background={
                texture="#room_raise_allin_btn_up.png",
                scale9 = true
            }
        },
        down={
            background={
                texture="#room_raise_allin_btn_down.png",
                scale9 = true
            }
        },
        disabled="down"
    }, 5):onClicked(handler(self, self.onButtonClicked_)):pos(self.labelBackground_:getPositionX(), self.labelBackground_:getPositionY()):enabled(true):addTo(self):hide()
    self.btnAllin_:setOpacity(0.2 * 255)

    display.newSprite("#room_raise_allin_txt.png"):addTo(self.btnAllin_)
    display.newSprite("#room_raise_allin_icon.png"):addTo(self.btnAllin_):pos(-60, 0)
    display.newSprite("#room_raise_allin_icon.png"):addTo(self.btnAllin_):pos(60, 0)

    self:setValueRange(0, 0)
    self:setSliderPercentValue(0)
end

function RaiseSlider:showPanel()
    self:setSliderPercentValue(0)
    return self:show()
end

function RaiseSlider:setButtonStatus(allPotEnabled, q3PotEnabled, halfPotEnabled, tripleEnabled, isMaxAllin)
    self.btnAllPot_:enabled(allPotEnabled)
    self.btn3QPot_:enabled(q3PotEnabled)
    self.btnHalfPot_:enabled(halfPotEnabled)
    self.btnTriple_:enabled(tripleEnabled)

    self.isMaxAllin_ = isMaxAllin
end

function RaiseSlider:hidePanel()
    self:setSliderPercentValue(0)
    return self:hide()
end

function RaiseSlider:onButtonClicked(callback)
    self.buttonClickedCallback_ = callback
    return self
end

function RaiseSlider:setValueRange(valueMin, valueMax)
    printf("slider range %s~%s", valueMin, valueMax)
    self.valueMin_ = valueMin
    self.valueMax_ = valueMax
    self.valueRange_ = valueMax - valueMin
    return self
end

function RaiseSlider:setValue(val)
    if self.valueRange_ and self.valueRange_ > 0 then
        self:setSliderPercentValue(val / self.valueRange_)
    else
        self:setSliderPercentValue(0)
    end
    return self
end

function RaiseSlider:getValue()
    return math.round(self:getSliderPercentValue() * self.valueRange_ + self.valueMin_)
end

function RaiseSlider:setSliderPercentValue(newVal)
    assert(newVal >= 0 and newVal <= 1, "slider value must be between 0 and 1")
    self:onSliderPercentValueChanged_(newVal, true)
    self.thumb_:setPositionY(RaiseSlider.THUMB_BOUND_BOTTOM + RaiseSlider.THUMB_BOUND_HEIGHT * newVal)
    return self
end

function RaiseSlider:getSliderPercentValue()
    return (self.thumb_:getPositionY() - RaiseSlider.THUMB_BOUND_BOTTOM) / RaiseSlider.THUMB_BOUND_HEIGHT
end

function RaiseSlider:onSliderPercentValueChanged_(newVal, forceUpdate, needSound)
    if self.percentValue_ ~= newVal or forceUpdate then
        self.percentValue_ = newVal
        if newVal == 1 then
            if self.isMaxAllin_ then
                if self.allinState_ ~= true then
                    self.trackYellow_:stopAllActions()
                    self.trackYellow_:show()
                    self.trackYellow_:fadeTo(0.75, 255)

                    self.btnAllin_:stopAllActions()
                    self.btnAllin_:show()
                    self.btnAllin_:runAction(cc.FadeTo:create(0.75, 255))
                    self:playDBAllInAnim()
                end
                self.allinState_ = true
            else
                self.btnAllin_:stopAllActions()
                self.btnAllin_:hide()

                self.trackYellow_:stopAllActions()
                self.trackYellow_:hide()
            end
        else
            if self.isMaxAllin_ then
                if self.allinState_ ~= false then
                    self.btnAllin_:stopAllActions()
                    self.btnAllin_:setOpacity(0.2 * 255)
                    self.btnAllin_:hide()

                    self.trackYellow_:stopAllActions()
                    transition.execute(self.trackYellow_, cc.FadeTo:create(0.75, 0), {onComplete=function() self.trackYellow_:hide() end})
                end
                self.allinState_ = false
            else
                self.btnAllin_:stopAllActions()
                self.btnAllin_:hide()

                self.trackYellow_:stopAllActions()
                self.trackYellow_:hide()
            end
        end
        self.prevValue_ = self.curValue_
        self.curValue_ = self:getValue()
        local curTime = bm.getTime()
        local prevTime = self.lastRaiseSliderGearTickPlayTime_ or 0
        if needSound and self.prevValue_ ~= self.curValue_  and curTime - prevTime > 0.05 then
            self.lastRaiseSliderGearTickPlayTime_ = curTime
            nk.SoundManager:playSound(nk.SoundManager.GEAR_TICK)
        end
        self.label_:setString("$" .. self.curValue_)
        self.trackBlue_:setContentSize(cc.size(12, math.max(418 * newVal, 20)))
        if self.addBtn_ then
            self.addBtn_:getButtonLabel("normal"):setString(bm.formatBigNumber(self.curValue_))
        end
    end
end

function RaiseSlider:playDBAllInAnim()
    if not self.db_node then
        self.db_node = display.newNode():addTo(self.btnAllin_):pos(0, 2)
    end
    if self.db then
        self.db:removeFromParent()
    end 
    local path = "dragonbones/fla_allintiao/"
    self.db = dragonbones.new({
            skeleton=path .. "skeleton.xml",
            texture=path .. "texture.xml",
            armatureName="fla_allintiao_ADDITIVE",
            aniName="",
            skeletonName="fla_allintiao",
        })
        :addTo(self.db_node, i)
    self.db:getAnimation():play()
end

function RaiseSlider:setAddBtn(btn)
    self.addBtn_ = btn
end

function RaiseSlider:onThumbTouch_(evt)
    local name, x, y, prevX, prevY = evt.name, evt.x, evt.y, evt.prevX, evt.prevY
    local isTouchInSprite = self.thumb_:getCascadeBoundingBox():containsPoint(cc.p(x, y))
    if name == "began" then
        if isTouchInSprite then
            self.isThumbTouching_ = true
            self.thumbTouchBeginY_ = y
            self.thumbBeginY_ = self.thumb_:getPositionY()
            return true
        else
            return false
        end
    elseif not self.isThumbTouching_ then
        return false
    elseif name == "moved" then
        local movedY = y - self.thumbTouchBeginY_
        local toY = self.thumbBeginY_ + movedY
        if toY >= RaiseSlider.THUMB_BOUND_TOP then
            toY = RaiseSlider.THUMB_BOUND_TOP
        elseif toY <= RaiseSlider.THUMB_BOUND_BOTTOM then
            toY = RaiseSlider.THUMB_BOUND_BOTTOM
        end
        self.thumb_:setPositionY(toY)
        local val = (toY - RaiseSlider.THUMB_BOUND_BOTTOM) / RaiseSlider.THUMB_BOUND_HEIGHT
        self:onSliderPercentValueChanged_(val, false, true)
    elseif name == "ended"  or name == "cancelled" then
        self.isThumbTouching_ = false
    end
    return true
end

function RaiseSlider:onButtonClicked_(tag)
    print("onclick tag " .. tag)
    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    if self.buttonClickedCallback_ and (
            tag == 1 and self.btnAllPot_:isEnabled() or
            tag == 2 and self.btn3QPot_:isEnabled() or
            tag == 3 and self.btnHalfPot_:isEnabled() or
            tag == 4 and self.btnTriple_:isEnabled() or
            tag == 5 and self.btnAllin_:isEnabled()) then
        self.buttonClickedCallback_(tag)
    end
end

return RaiseSlider