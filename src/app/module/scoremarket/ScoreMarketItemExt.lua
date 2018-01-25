--
-- Author: HLF
-- Date: 2015-09-24 20:56:52
--
local AnimationIcon             = import("boomegg.ui.AnimationIcon")
local ScoreMarketItemExt = class("ScoreMarketItemExt", bm.ui.ListItem)
local AvatarIcon          = import("boomegg.ui.AvatarIcon")
local SimpleColorLabel = import("boomegg.ui.SimpleColorLabel")

ScoreMarketItemExt.HEIGHT = 228-30-- 228 218
ScoreMarketItemExt.WIDTH = 205-- 205 252

local AVATART_DW, AVATAR_DH = 30, 30
local ICON_WIDTH = 100
local ICON_HEIGHT = 96
local AVATAR_TAG = 101
local BIG_OFF_DH = 60
local LEFT_BG_DH = 36
local LEFT_BG_PY = 64
local EXCHANGE_NUM_OFFX = 8
local SCORE_ICON_OFFX = 15
local SCORE_ICONTXT_OFFX = 2
local NAME_TXT_OFFY = 15
local ICON_DEFAULT_SCALE = 0.6
local ANIMATION_INTERVAL = 5
local ANIMATION_DELAY_INTERVAL = 2
local EXCAHGNE_NUM_OFFY = 24

function ScoreMarketItemExt:ctor()
    local WIDTH = ScoreMarketItemExt.WIDTH
    local HEIGHT = ScoreMarketItemExt.HEIGHT
    local GRID_WIDTH = WIDTH * 2 + 25 * 2
    local GRID_HEIGHT = HEIGHT + 12
    self.isBigBar_ = false
    self:setNodeEventEnabled(true) -- 框架直接执行 onCleanup
    ScoreMarketItemExt.super.ctor(self, GRID_WIDTH, GRID_HEIGHT)
    self:createSubItem(1)
    self:createSubItem(2)
    self:createSubItem(3)
end

function ScoreMarketItemExt:createSubItem(index)
    local WIDTH = ScoreMarketItemExt.WIDTH
    local HEIGHT = ScoreMarketItemExt.HEIGHT
    local offY = HEIGHT*0.5
    local clip = cc.ClippingNode:create()
        :pos((WIDTH+20)*(index-1),HEIGHT*0.5)
        :addTo(self, 99)
    local stencil = display.newScale9Sprite("#rounded_rect_10.png", 0, 0, cc.size(WIDTH, HEIGHT))
    clip:setStencil(stencil)

    local rankBg = display.newNode()
        :addTo(clip)
        :size(WIDTH, HEIGHT)

    local bg = display.newScale9Sprite(
        '#sm_good_border2.png',
        0, 0,
        cc.size(WIDTH, HEIGHT)
    )
    :addTo(rankBg)

    local nameTxt = ui.newTTFLabel {
        text  = '',
        color = styles.FONT_COLOR.LIGHT_TEXT,
        size  = 20,
        align = ui.TEXT_ALIGN_CENTER,
    }
    :pos(0, HEIGHT*0.5 - NAME_TXT_OFFY)
    :addTo(rankBg, 10)
    nameTxt:pos(-WIDTH*0.5 + 10, HEIGHT*0.5 - NAME_TXT_OFFY)
    nameTxt:setAnchorPoint(cc.p(0, 0.5))

    local leftBg = display.newScale9Sprite("#sm_goodBar.png", 0, LEFT_BG_PY-HEIGHT*0.5, cc.size(WIDTH, LEFT_BG_DH))
    :addTo(rankBg)

    local left = ui.newTTFLabel {
        text  = '',
        color = cc.c3b(184, 148, 255),
        size  = 22,
        align = ui.TEXT_ALIGN_CENTER,
    }
    :pos(0, LEFT_BG_PY-HEIGHT*0.5)
    :addTo(rankBg)

    local scoreIcon = display.newSprite("#icon_score.png")
    :addTo(rankBg)

    local scoreTxt = ui.newTTFLabel {
        text  = '',
        color = styles.FONT_COLOR.GOLDEN_TEXT,
        size  = 22,
        align = ui.TEXT_ALIGN_CENTER,
    }
    :addTo(rankBg)
    scoreTxt:setAnchorPoint(cc.p(0, 0.5))

    -- 设置现金币价格位置
    local lsz = scoreTxt:getContentSize()
    local isz = scoreIcon:getContentSize()
    local px = isz.width*0.5 - WIDTH*0.5 + SCORE_ICON_OFFX
    local py = EXCAHGNE_NUM_OFFY - HEIGHT*0.5
    scoreIcon:setPosition(px, py)
    scoreTxt:setPosition(isz.width - WIDTH*0.5 + SCORE_ICON_OFFX + SCORE_ICONTXT_OFFX, 23 - HEIGHT*0.5)

    -- 光效
    local light = display.newSprite("#sm_good_light.png")
        :addTo(rankBg)

    -- 实物图片显示的容器
    local icon = display.newNode()
        :size(ICON_WIDTH,ICON_HEIGHT)
        :addTo(rankBg)
    lsz = light:getContentSize()
    local ldh = HEIGHT - (LEFT_BG_PY + LEFT_BG_DH)
    local py = HEIGHT*0.5 - ldh*0.5 - 25
    light:pos(0, py)
    icon:pos(0, py)

    local animationIcon_ = AnimationIcon.new("#game_logo.png", 1, 1, nil, nil, nil, ICON_DEFAULT_SCALE)
        :addTo(rankBg)
        :pos(0, py)

    local tempBtn = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#common_transparent_skin.png"}, {scale9 = true})
        :setButtonSize(WIDTH, HEIGHT)
        :onButtonPressed(function(evt) 
                self.btnPressedY_ = evt.y
                self.btnClickCanceled_ = false

                bg:setSpriteFrame(display.newSpriteFrame("sm_good_border3.png"))
                bg:setContentSize(cc.size(WIDTH + self["BIG_OFF_DW"..index.."_"], HEIGHT + self["BIG_OFF_DH"..index.."_"]))
            end)
        :onButtonRelease(function(evt)
                if math.abs(evt.y - self.btnPressedY_) > 5 then
                    self.btnClickCanceled_ = true
                end
                bg:setSpriteFrame(display.newSpriteFrame("sm_good_border2.png"))
                bg:setContentSize(cc.size(WIDTH + self["BIG_OFF_DW"..index.."_"], HEIGHT + self["BIG_OFF_DH"..index.."_"]))
            end)
        :onButtonClicked(function(evt)
                if not self.btnClickCanceled_ then
                    if index==1 then
                        self:exchangeGoods1()
                    elseif index==2 then
                        self:exchangeGoods2()
                    elseif index==3 then
                        self:exchangeGoods3()
                    end
                end
            end)
        :addTo(rankBg)
    tempBtn:setTouchSwallowEnabled(false)
    rankBg:setVisible(false)

    self["clip"..index.."_"] = clip
    self["stencil"..index.."_"] = stencil
    -- rankBg为item容器
    self["rankBg"..index.."_"] = rankBg
    -- 为背景图片
    self["bg"..index.."_"] = bg
    -- 光效
    self["light"..index.."_"] = light
    -- 
    self["animationIcon"..index.."_"] = animationIcon_
    -- 实物图片显示的容器
    self["icon"..index.."_"] = icon
    -- 实物名称
    self["name"..index.."_"] = nameTxt
    -- 剩余次数的嘿块
    self["leftBg"..index.."_"] = leftBg
    -- 剩余次数
    self["left"..index.."_"] = left
    -- 现金币图标
    self["scoreIcon"..index.."_"] = scoreIcon
    -- 现金币文字
    self["score"..index.."_"] = scoreTxt
    -- item可点击区域遮罩按钮
    self["btn"..index.."_"] = tempBtn    
    self["BIG_OFF_DW"..index.."_"] = 0
    self["BIG_OFF_DH"..index.."_"] = 0
end

function ScoreMarketItemExt:exchangeGoods1()
    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    -- 变量
    local index = 1
    local tempData = self["data"..index.."_"]
    bm.EventCenter:dispatchEvent({name = nk.eventNames.SCORE_MARKET_EXCHANGE, data = tempData})
end

function ScoreMarketItemExt:exchangeGoods2()
    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    -- 变量
    local index = 2
    local tempData = self["data"..index.."_"]
    bm.EventCenter:dispatchEvent({name = nk.eventNames.SCORE_MARKET_EXCHANGE, data = tempData})
end

function ScoreMarketItemExt:exchangeGoods3()
    nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
    -- 变量
    local index = 3
    local tempData = self["data"..index.."_"]
    bm.EventCenter:dispatchEvent({name = nk.eventNames.SCORE_MARKET_EXCHANGE, data = tempData})
end

-- value为true表示为实物
function ScoreMarketItemExt:setBigAndSmallStyle(value)
    local WIDTH = ScoreMarketItemExt.WIDTH
    local HEIGHT = ScoreMarketItemExt.HEIGHT + 0
    local offDW = 0
    local offDH = 0
    local offX = 0
    if value then
        offDW = ScoreMarketItemExt.WIDTH*0.5 + 10
        offDH = BIG_OFF_DH
        offX = offDW*0.5
    end

    WIDTH = WIDTH + offDW
    HEIGHT = HEIGHT + offDH

    local py, lsz, isz
    local stencil, bg, rankBg, light, icon, nameTxt, leftBg, left, scoreIcon, scoreTxt, btn, bigHotIcon, avatar, avatarBg, exInfo, exchangeNum, nilExchangeTip
    local itemData
    for i=1,2 do
        itemData = self.data_[i]
        if not itemData then
            break
        end
        clip = self["clip"..i.."_"]
        stencil = self["stencil"..i.."_"]
        bg = self["bg"..i.."_"]
        rankBg = self["rankBg"..i.."_"]
        light = self["light"..i.."_"]
        icon = self["icon"..i.."_"]
        nameTxt = self["name"..i.."_"]
        leftBg = self["leftBg"..i.."_"]
        left = self["left"..i.."_"]
        scoreIcon = self["scoreIcon"..i.."_"]
        scoreTxt = self["score"..i.."_"]
        btn = self["btn"..i.."_"]
        bigHotIcon = self["bigHotIcon"..i.."_"]
        avatar = self["avatar"..i.."_"]
        avatarBg = self["avatarBg"..i.."_"]
        exInfo = self["exInfo"..i.."_"]
        exchangeNum = self["exchangeNum"..i.."_"]
        nilExchangeTip = self["nilExchangeTip"..i.."_"]
        if nilExchangeTip then
            nilExchangeTip:hide()
        end

        self["BIG_OFF_DW"..i.."_"] = offDW
        self["BIG_OFF_DH"..i.."_"] = offDH

        clip:pos((WIDTH+20)*(i-1)+offX, HEIGHT*0.5)
        bg:setContentSize(WIDTH, HEIGHT)
        rankBg:setContentSize(WIDTH, HEIGHT)
        stencil:setContentSize(WIDTH, HEIGHT)
        btn:setButtonSize(WIDTH, HEIGHT)

        left:pos(0, LEFT_BG_PY-HEIGHT*0.5)
        leftBg:setContentSize(WIDTH, LEFT_BG_DH)
        leftBg:pos(0, LEFT_BG_PY-HEIGHT*0.5)
        exchangeNum:hide()

        local ldh = HEIGHT - (LEFT_BG_PY + LEFT_BG_DH)
        local py = HEIGHT*0.5 - ldh*0.5 - 20
        if value then
            py = py + 0
            ldh = ldh + LEFT_BG_DH*0.5 - 15
            light:setScale(1.36)
            light:pos(0, py)
            icon:setScale(ldh/icon:getContentSize().height)
            icon:pos(0, py)
            -- 设置物品名称左对齐
            if offDW > 0 then
                nameTxt:pos(-WIDTH*0.5 + 10, HEIGHT*0.5 - NAME_TXT_OFFY)
                nameTxt:setAnchorPoint(cc.p(0, 0.5))
            else
                nameTxt:pos(0,ScoreMarketItemExt.HEIGHT*0.5 - NAME_TXT_OFFY)
                nameTxt:setAnchorPoint(cc.p(0.5, 0.5))
            end
            left:hide()

            -- 设置现金币价格位置
            lsz = scoreTxt:getContentSize()
            isz = scoreIcon:getContentSize()
            scoreIcon:setPosition(isz.width*0.5 - WIDTH*0.5 + SCORE_ICON_OFFX, LEFT_BG_PY-HEIGHT*0.5)
            scoreTxt:setPosition(isz.width - WIDTH*0.5 + SCORE_ICON_OFFX + SCORE_ICONTXT_OFFX, LEFT_BG_PY-HEIGHT*0.5-1)

            self:refreshExchangeTxt_(exchangeNum, scoreTxt, scoreIcon, itemData, offDW, offDH)

            -- 热门商品、最新上架
            if not bigHotIcon then
                bigHotIcon = display.newSprite("#sm_hot.png")
                :pos(WIDTH*0.5 + 3,HEIGHT*0.5 + 5)
                :addTo(rankBg)
                self["bigHotIcon"..i.."_"] = bigHotIcon
                bigHotIcon:setAnchorPoint(cc.p(1, 1))
            end

            if itemData.isHot then
                bigHotIcon:setSpriteFrame(display.newSpriteFrame("sm_hot.png"))
            else
                bigHotIcon:setSpriteFrame(display.newSpriteFrame("sm_new.png"))
            end
            bigHotIcon:pos(WIDTH*0.5,HEIGHT*0.5)  

            -- 兑换的玩家头像
            local offy = 37
            px, py = scoreIcon:getPosition()
            px = px + 5
            py = py - 4
            if not avatar then                
                avatar = AvatarIcon.new("#common_male_avatar.png", AVATART_DW - 2, AVATAR_DH - 2, 0, {borderRes="#transparent.png"}, 1, 8, 0)
                    :pos(px, py - offy + 5)
                    :addTo(rankBg, 99)
                self["avatar"..i.."_"] = avatar

                avatarBg = display.newSprite("#sm_avatar_bg.png")
                    :pos(px - 3, py - offy + 2)
                    :addTo(rankBg, 98)
                self["avatarBg"..i.."_"] = avatarBg                
            end

            if string.len(tostring(itemData.lastUimg) or "") > 0 then
                avatarBg:show()
                avatar:show()
                avatar:setSexAndImgUrl(itemData.lastUimg, itemData.lastUimg)
            else
                avatar:hide()
                avatarBg:hide()
            end

            -- 如果兑换人员信息发生变化，删除exInfo
            self:refreshLastExInfo_(i, itemData, exInfo, avatar, avatarBg, rankBg, offDW, offDH)
        else
            light:setScale(1)
            light:pos(0, py)

            icon:setScale(1)            
            icon:pos(0, py)

            -- 设置物品名称居中
            nameTxt:pos(0,ScoreMarketItemExt.HEIGHT*0.5 - NAME_TXT_OFFY)
            nameTxt:setAnchorPoint(cc.p(0.5, 0.5))

            left:show()
            -- 设置现金币价格位置
            self:refreshExchangeTxt_(exchangeNum, scoreTxt, scoreIcon, itemData)

            if bigHotIcon then
                bigHotIcon:removeFromParent()
                self["bigHotIcon"..i.."_"] = nil
            end

            if avatar then
                avatar:hide()
            end

            if exInfo then
                exInfo:hide()
            end
        end
    end

    if value then
        self:addSchedulerPool_()
    else
        self:removeSchedulerPool_()
    end
end

function ScoreMarketItemExt:addSchedulerPool_()
    if not self.schedulerPool_ then
        self["idx1_"] = 2
        self["idx2_"] = 2
        self.schedulerPool_ = bm.SchedulerPool.new()
        self.schedulerPool_:loopCall(handler(self, self.onLoopCall_), ANIMATION_INTERVAL)
    end
end

function ScoreMarketItemExt:removeSchedulerPool_()
    if self.schedulerPool_ then
        self.schedulerPool_:clearAll()
        self.schedulerPool_ = nil
    end

    for i=1,2 do
        if self["cloneContainer_"..i] then
            self["cloneContainer_"..i]:stopAllActions()
            if self["cloneContainer_"..i]:getParent() then
                self["cloneContainer_"..i]:removeFromParent()
            end
            self["cloneContainer_"..i] = nil
        end
    end
end

function ScoreMarketItemExt:onLoopCall_()
    for i=1, 2 do
        self:animation2_(i, (i-1)*ANIMATION_DELAY_INTERVAL)
    end
    return true
end

function ScoreMarketItemExt:animation2_(i, delayTime)
    if not self["data"..i.."_"] then
        return
    end

    local WIDTH = ScoreMarketItemExt.WIDTH
    local HEIGHT = ScoreMarketItemExt.HEIGHT
    local clip, rankBg, offDW, offDH, idx, subList, dw, dh, px, py, cloneContainer
    local animTS = 0.5
    clip = self["clip"..i.."_"]
    rankBg = self["rankBg"..i.."_"]
    offDW = self["BIG_OFF_DW"..i.."_"]
    offDH = self["BIG_OFF_DH"..i.."_"]
    idx = self["idx"..i.."_"]
    subList = self["data"..i.."_"].subList

    if idx > #subList then
        idx = 1
    end
    
    dw = WIDTH+offDW
    dh = HEIGHT+offDH
    if not px or not py then
        px, py = rankBg:getPosition()
    end
    cloneContainer = bm.cloneNode(rankBg, cc.size(dw, dh), dw*0.5, dh*0.5)
        :pos(px, py)
        :addTo(clip)

    self:refreshItem(i, subList[idx])

    local animTS = 0.5
    transition.fadeIn(rankBg, {time=animTS, delay=delayTime, onComplete = function()
        rankBg:stopAllActions()
    end})

    self["cloneContainer_"..i] = cloneContainer
    transition.fadeOut(cloneContainer, {time=animTS, delay=delayTime, onComplete = function()
        cloneContainer:stopAllActions()
        cloneContainer:removeFromParent()
        self["cloneContainer_"..i] = nil
    end})

    idx = idx + 1
    self["idx"..i.."_"] = idx
end

-- 动画1
function ScoreMarketItemExt:animation1_(i)
    if not self["data"..i.."_"] then
        return
    end
    -- 
    local WIDTH = ScoreMarketItemExt.WIDTH
    local HEIGHT = ScoreMarketItemExt.HEIGHT
    local clip, rankBg, offDW, offDH, idx, subList, dw, dh, px, py, cloneContainer
    local animTS = 0.5
    clip = self["clip"..i.."_"]
    rankBg = self["rankBg"..i.."_"]
    offDW = self["BIG_OFF_DW"..i.."_"]
    offDH = self["BIG_OFF_DH"..i.."_"]
    idx = self["idx"..i.."_"]
    subList = self["data"..i.."_"].subList

    if idx > #subList then
        idx = 1
    end
    
    dw = WIDTH+offDW
    dh = HEIGHT+offDH
    if not px or not py then
        px, py = rankBg:getPosition()
    end
    cloneContainer = bm.cloneNode(rankBg, cc.size(dw, dh), dw*0.5, dh*0.5)
        :pos(px, py)
        :addTo(clip)
    -- 
    self:refreshItem(i, subList[idx])
    -- 
    rankBg:pos(px+dw, py)
    rankBg:runAction(transition.sequence({
        cc.MoveTo:create(animTS, cc.p(px, py)),
        cc.CallFunc:create(function(obj)
            rankBg:stopAllActions()
        end)
    }))
    -- 
    cloneContainer:runAction(transition.sequence({
        cc.MoveTo:create(animTS, cc.p(px-dw, py)),
        cc.CallFunc:create(function(obj)
            cloneContainer:stopAllActions()
            cloneContainer:removeFromParent()
        end)
    }))

    idx = idx + 1
    self["idx"..i.."_"] = idx
end
-- 
function ScoreMarketItemExt:onDataSet(dataChanged, data)
    self.dataChanged_ = self.dataChanged_ or dataChanged
    local rankBg, exchangeNum
    local py = EXCAHGNE_NUM_OFFY - ScoreMarketItemExt.HEIGHT*0.5
    for i=1,3 do
        rankBg = self["rankBg"..i.."_"]
        rankBg:hide()
        if not self["exchangeNum"..i.."_"] then
            if self:getIndex() == 1 then
                exchangeNum = SimpleColorLabel.html(bm.LangUtil.getText("SCOREMARKET", "BIG_EXCHANGE_SUCC_MSG"), cc.c3b(184, 148, 0xff), cc.c3b(127, 224, 68), 22, 2)
                    :addTo(rankBg,99)
            else
                exchangeNum = SimpleColorLabel.html(bm.LangUtil.getText("SCOREMARKET", "EXCHANGE_NUM_TXT"), cc.c3b(184, 148, 0xff), cc.c3b(127, 224, 68), 22, 2)
                    :addTo(rankBg,99)
            end
            exchangeNum:pos(ScoreMarketItemExt.WIDTH*0.5-exchangeNum.width*0.5, py)
            self["exchangeNum"..i.."_"] = exchangeNum
        end
        self:refreshItem(i, data[i])
    end
    -- 
    if data[1].isHot or data[1].isNew then
        self:setBigAndSmallStyle(true)
        self.isBigBar_ = true
    else
        self:setBigAndSmallStyle(false)
        self.isBigBar_ = false
    end
end
-- k 为下标， v为绑定数据
function ScoreMarketItemExt:refreshItem(k, v)
    local tempBg = self["rankBg"..k.."_"]
    self["data"..k.."_"] = v
    -- 
    local rankBg = self["rankBg"..k.."_"]
    local nameTxt = self["name"..k.."_"]
    local leftTxt = self["left"..k.."_"]
    local scoreTxt = self["score"..k.."_"]
    local scoreIcon = self["scoreIcon"..k.."_"]
    local exchangeNum = self["exchangeNum"..k.."_"]
    local avatar = self["avatar"..k.."_"]
    local exInfo = self["exInfo"..k.."_"]
    local offDW = self["BIG_OFF_DW"..k.."_"]
    local offDH = self["BIG_OFF_DH"..k.."_"]
    local exInfoText = self["exInfoText"..k.."_"]
    local avatarBg = self["avatarBg"..k.."_"]
    local nilExchangeTip = self["nilExchangeTip"..k.."_"]
    if nilExchangeTip then
        nilExchangeTip:hide()
    end
    -- 
    if v==nil then
        tempBg:setVisible(false)
    else
        tempBg:setVisible(true)
        -- 
        if v.isHot or v.isNew then
            offDW = ScoreMarketItemExt.WIDTH*0.5 + 10
            offDH = BIG_OFF_DH
        end
        -- 设置物品名称左对齐
        if offDW > 0 then
            nameTxt:pos(-(ScoreMarketItemExt.WIDTH+offDW)*0.5 + 10, (ScoreMarketItemExt.HEIGHT+offDH)*0.5 - NAME_TXT_OFFY)
            nameTxt:setAnchorPoint(cc.p(0, 0.5))
        else
            -- nameTxt:setPositionX(0)
            nameTxt:pos(0,ScoreMarketItemExt.HEIGHT*0.5 - NAME_TXT_OFFY)
            nameTxt:setAnchorPoint(cc.p(0.5, 0.5))
        end
        -- 如果实物
        self:refreshExchangeTxt_(exchangeNum, scoreTxt, scoreIcon, v, offDW, offDH)
        nameTxt:setString(tostring(v.name))
        -- 
        local WIDTH = ScoreMarketItemExt.WIDTH
        if v.lastCount<1 then
            leftTxt:setString(bm.LangUtil.getText("SCOREMARKET", "NOLEFT"))
        else
            if v.lastCount<5 then
                leftTxt:setString(bm.LangUtil.getText("SCOREMARKET", "LEFTWORD",v.lastCount))
            else
                leftTxt:setString(bm.LangUtil.getText("SCOREMARKET", "GOODSFULL"))
            end
        end
        -- 
        local iconContainer = self["icon"..k.."_"]
        local animationIcon = self["animationIcon"..k.."_"]
        iconContainer:hide()
        if v.image and string.len(v.image)>10 then
            local iconSize = iconContainer:getContentSize()
            if v.isHot or v.isNew then
                iconSize.width = iconSize.width + offDW
                iconSize.height = iconSize.height + offDH
            end
            -- 
            animationIcon:onData(v.image, iconSize.width, iconSize.height, function(succ)
                local oldAvatar = iconContainer:getChildByTag(AVATAR_TAG)
                if oldAvatar then
                    oldAvatar:removeFromParent()
                end
                iconContainer:show()
            end, 8)
        end
        -- 
        if v.sale and tostring(v.sale) == "1" then
            if not self["hotIcon"..k.."_"] then
                self["hotIcon"..k.."_"] = display.newSprite("#scoremarket_saleIcon2.png")
                    :addTo(nameTxt:getParent())
                local sz = self["hotIcon"..k.."_"]:getContentSize()
                local px = ScoreMarketItemExt.WIDTH * 0.5 - sz.width * 0.5 + 18
                local py = ScoreMarketItemExt.HEIGHT * 0.5 - sz.height * 0.5 + 10
                self["hotIcon"..k.."_"]:setPosition(px, py)
                self["hotIcon"..k.."_"]:setScale(0.6)
            else
                
            end
        else
            if self["hotIcon"..k.."_"] then
                self["hotIcon"..k.."_"]:removeFromParent()
                self["hotIcon"..k.."_"] = nil
            end
        end
        bm.fitSprteWidth(nameTxt, ScoreMarketItemExt.WIDTH - 10)

        -- 更新头像
        if avatar then
            avatar:setSexAndImgUrl(v.lastUimg, v.lastUimg)
        end
        -- 如果兑换人员信息发生变化，删除exInfo
        self:refreshLastExInfo_(k, v, exInfo, avatar, avatarBg, rankBg, offDW, offDH)
    end
end
-- 
function ScoreMarketItemExt:refreshLastExInfo_(k, v, exInfo, avatar, avatarBg, rankBg, offDW, offDH)
    -- 如果兑换人员信息发生变化，删除exInfo
    if not v.lastUsers and exInfo then
        exInfo:removeFromParent()
        self["exInfo"..k.."_"] = nil
        exInfo = nil
    end
    -- 
    if self["exInfoText"..k.."_"] and v.lastUsers and self["exInfoText"..k.."_"] ~= v.lastUsers and exInfo then
        exInfo:removeFromParent()
        self["exInfo"..k.."_"] = nil
        exInfo = nil
    end
    -- 
    local px, py
    if not exInfo and avatar then
        exInfo = SimpleColorLabel.html(v.lastUsers or "", cc.c3b(184, 148, 0xff), styles.FONT_COLOR.GOLDEN_TEXT, 22, 3)
            :addTo(rankBg, 1, 1)
        self["exInfo"..k.."_"] = exInfo
        self["exInfoText"..k.."_"] = v.lastUsers or ""
        -- 
        px, py = avatar:getPosition()
        exInfo:pos(px+AVATART_DW, py)
        -- nk.TopTipManager:showTopTip("offDW::"..tostring(offDW))
        local maxDW = ScoreMarketItemExt.WIDTH + offDW - AVATART_DW - 40
        if exInfo.width > maxDW then
            exInfo:setScale(maxDW/exInfo.width)
        else
            exInfo:setScale(1)
        end
    end
    -- 
    if avatar and avatarBg then
        avatar:hide()
        avatarBg:hide()
        if v.lastUsers and string.len(tostring(v.lastUsers)) > 0 then
            avatar:show() 
            avatarBg:show()
        else
            local nilExchangeTip
            px, py = avatar:getPosition()
            if not nilExchangeTip then
                nilExchangeTip = ui.newTTFLabel({
                        text=bm.LangUtil.getText("SCOREMARKET", "NIL_EXCHANGE_TIP"),
                        color=styles.FONT_COLOR.LIGHT_TEXT,
                        size = 22,
                        align=ui.TEXT_ALIGN_CENTER
                    })
                    :pos(0, py)
                    :addTo(rankBg)
                self["nilExchangeTip"..k.."_"] = nilExchangeTip
            end
            -- 
            if nilExchangeTip then
                nilExchangeTip:show()
            end
        end
    end
end
-- 
function ScoreMarketItemExt:refreshExchangeTxt_(exchangeNum, scoreTxt, scoreIcon, v, offDW, offDH)
    -- 如果实物
    offDW = offDW or 0
    offDH = offDH or 0
    if v.category  == "real" then
        exchangeNum.setStringByKey("{1}", v.exchanged or "0")
        if v.exchanged and v.exchanged >= 0 then
            exchangeNum:show()
            scoreTxt:setString(v.score)
        else
            scoreTxt:setString(v.score)
        end
        -- 
        exchangeNum:show()
        exchangeNum:setPosition((ScoreMarketItemExt.WIDTH + offDW) * 0.5 - 5, scoreIcon:getPositionY())
        -- 
        local leftDW = -15 + (ScoreMarketItemExt.WIDTH + offDW) - scoreTxt:getContentSize().width - scoreIcon:getContentSize().width - SCORE_ICON_OFFX - SCORE_ICONTXT_OFFX 
        if exchangeNum.width > leftDW then
            exchangeNum:scale(leftDW/exchangeNum.width or 1)
        else
            exchangeNum:scale(1)
        end
    else
        scoreTxt:setString(bm.LangUtil.getText("SCOREMARKET", "RECHANGENUM",v.score))
        exchangeNum:hide()

        local lsz = scoreTxt:getContentSize()
        local isz = scoreIcon:getContentSize()
        scoreIcon:setPosition(isz.width*0.5 - ScoreMarketItemExt.WIDTH*0.5 + SCORE_ICON_OFFX, EXCAHGNE_NUM_OFFY - ScoreMarketItemExt.HEIGHT*0.5)
        scoreTxt:setPosition(isz.width - ScoreMarketItemExt.WIDTH*0.5 + SCORE_ICON_OFFX + SCORE_ICONTXT_OFFX, EXCAHGNE_NUM_OFFY - 1 - ScoreMarketItemExt.HEIGHT*0.5)
    end
end
-- 
function ScoreMarketItemExt:getBigOffDH()
    return self.isBigBar_ and BIG_OFF_DH or 0
end
-- 
function ScoreMarketItemExt:onCleanup()
    self:removeSchedulerPool_()
end

return ScoreMarketItemExt