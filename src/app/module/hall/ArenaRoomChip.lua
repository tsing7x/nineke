-- 比赛场 选场界面 筹码-场次 控件
-- Author: davidxifeng@gmail.com
local AnimationIcon             = import("boomegg.ui.AnimationIcon")
local LoadMatchControl = import("app.module.match.LoadMatchControl")
local AVATAR_TAG             = 100 -- 获取子节点时， 通过此tag查找 替换贴图
local ArenaRoomChip1 = class('ArenaRoomChip1', bm.ui.ListItem)
ArenaRoomChip1.WIDTH = 390
ArenaRoomChip1.HEIGHT = 119
local color = {
    [1] = 137,
    [2] = 89,
    [3] = 35,
}
local color1 = {
    [1] = 165,
    [2] = 128,
    [3] = 49,
}
local color2 = {
    [1] = 0xd2,
    [2] = 0xe6,
    [3] = 0xae,
}
local btn_sprite = "arena/arena_itemBg_normal.png"
local btn_sprite1 = "arena/arena_itemBg_over.png"
local btn_sprite2 = "arena/arena_itemBg_normal2.png"
--- 参数
function ArenaRoomChip1:ctor(index,pageView)
    self.pageView_ = pageView
    self.isReg_ = 0
    self.iconPy_ = 10;
    self.nameOffX_ = 18;
    self.championOffX_ = 0;
    self:setNodeEventEnabled(true)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    local width, height = ArenaRoomChip1.WIDTH, ArenaRoomChip1.HEIGHT;
    ArenaRoomChip1.super.ctor(self, width, height)
    
    local icon = display.newScale9Sprite("#"..btn_sprite, 0, 0, cc.size(width, height+4),cc.rect(55,62,5,5))
        :addTo(self)
    local size = icon:getContentSize()
    self.bg_ = icon;
    -- 开赛条件
    local lsz;
    local sz = size
    local px, py = -sz.width*0.5 + 25, 5;
    self.matchts_ = display.newSprite("#arena/arena_conditionIcon.png")
        :pos(px, py-2)
        :addTo(self)
    self.factor_ = ui.newTTFLabel({
            text = "",
            color = cc.c3b(color[1], color[2], color[3]),
            size = 20,
            align = ui.TEXT_ALIGN_CENTER,
        })
        :align(display.CENTER_LEFT)
        :addTo(self)
    sz = self.matchts_:getContentSize();
    lsz = self.factor_:getContentSize();
    px = px + sz.width*0.5 + lsz.width*0.5 + 3;
    self.factor_:pos(px, py)
    px = px + lsz.width*0.5 + 20;
    -- 
    px = 10;
    -- 在线
    self.onLineBg_ = display.newSprite("#arena/arena_onlineIcon.png")
        :addTo(self)
        :pos(px, py+0)
    self.onLine_ = ui.newTTFLabel({
            text = "",
            color = cc.c3b(color[1], color[2], color[3]),
            size = 18,
            align = ui.TEXT_ALIGN_CENTER,
        })
        :align(display.CENTER_LEFT)
        :pos(px, py)
        :addTo(self)
    sz = self.onLineBg_:getContentSize();
    lsz = self.onLine_:getContentSize();
    px = px + sz.width*0.5 + lsz.width*0.5
    self.onLine_:pos(px, py)

    self.onLineBg_:hide()
    self.onLine_:hide()

    -- 冠军ICON
    self.championIcon_ = display.newSprite("#chip_icon.png")
        :pos(ArenaRoomChip1.WIDTH*0.5, 0)
        :addTo(self)
    -- 名字
    self.name_ = ui.newTTFLabel({
            text = "",
            color = cc.c3b(color[1], color[2], color[3]),
            size = 24,-- 40
        })
        :pos(0,38)--43
        :addTo(self)
    -- self.nameOffX_ = 26;
    -- 
    bm.TouchHelper.new(icon, function(target,evtName,isTouchInSprite,evt)
        if evtName==bm.TouchHelper.CLICK then
            if self.canSendEvent_ then
                if self.pageView_ then
                    local name, x, y, prevX, prevY = evt.name, evt.x, evt.y, evt.prevX, evt.prevY
                    local xx,yy = self.pageView_:getPosition()
                    local recWidth,recHeight = self.pageView_.recWidth_,self.pageView_.recHeight_
                    if x>=xx-recWidth*0.5 and x<=xx+recWidth*0.5 then
                        if self.goldLightBg_ and bm.containPointByNode(x, y, self.goldLightBg_) then
                            self:onEntityClickHandler_();
                        else
                            self:dispatchEvent({name="ITEM_EVENT",data=self})
                        end
                    end
                else
                    self:dispatchEvent({name="ITEM_EVENT",data=self})
                end
            end
            -- 
            self.canSendEvent_ = false
            -- 
            self:setTouchBgStyle_(evtName);
        elseif evtName==bm.TouchHelper.TOUCH_BEGIN then
            self.canSendEvent_ = true
            self.startX_ = self:convertToWorldSpace(cc.p(target:getPosition())).x
            -- 
            self:setTouchBgStyle_(evtName)
        elseif evtName==bm.TouchHelper.TOUCH_MOVE then
            if self.canSendEvent_ then
                local x = self:convertToWorldSpace(cc.p(target:getPosition())).x
                if math.abs(self.startX_-x)>5 then
                    self.canSendEvent_ = false
                end
            end
        elseif evtName == bm.TouchHelper.TOUCH_END then
            -- 
            self:setTouchBgStyle_(evtName)
        end
    end)
    icon:setTouchSwallowEnabled(false)
end

function ArenaRoomChip1:setTouchBgStyle_(evtName)
    if self.isReg_ and self.isReg_ ~= 1 then
        local key = btn_sprite;
        if evtName == bm.TouchHelper.TOUCH_BEGIN then
            key = btn_sprite2;
        end
        self.bg_:setSpriteFrame(display.newSpriteFrame(key))
        self.bg_:setContentSize(ArenaRoomChip1.WIDTH, ArenaRoomChip1.HEIGHT)
    end
end

function ArenaRoomChip1:addAnimation_()
    if self.goldLight_ then 
        return;
    end

    self.goldLight_ = display.newSprite("#arena/match_goldlight.png")
        :addTo(self, 7, 7)
    self.goldLightAnim_ = display.newSprite("#arena/match_goldlight.png")
        :addTo(self, 7, 7)

    local sz = self.bg_:getContentSize();
    local lsz = self.goldLightBg_:getCascadeBoundingBox();
    local px = sz.width*0.5 - lsz.width*0.5 + 10;
    self.goldLightBg_:pos(px, self.iconPy_)
    self.goldLight_:pos(px, self.iconPy_)
    self.goldLightAnim_:pos(px, self.iconPy_)

    self.goldLightAnim_:setBlendFunc(GL_DST_COLOR, GL_ONE);
    
    local ts1 = 1.2;
    local ts2 = 0.5;
    self.goldLightAnim_:runAction(cc.RepeatForever:create(transition.sequence({cc.FadeOut:create(ts1), cc.FadeIn:create(ts2)})));
    self.goldLight_:runAction(cc.RepeatForever:create(transition.sequence({cc.FadeOut:create(ts2), cc.FadeIn:create(ts1)})));
end

function ArenaRoomChip1:addEntityStyle()
    self:addLightEffect_();
    self:loadImage_();
end

function ArenaRoomChip1:addLightEffect_()
    if self.goldLightBg_ then
        return 
    end

    self.goldLightBg_ = display.newSprite("#arena/match_goldlight_bg.png")
        :pos(5, 5)
        :addTo(self)
    -- 
    self.icon_ = display.newNode()
        :size(100, 100)
        :addTo(self, 6, 6)
    -- 
    if self.championIcon_ then
        self.championIcon_:removeFromParent();
        self.championIcon_ = nil;
    end
    -- 
    local sz = self.bg_:getContentSize();
    local lsz = self.goldLightBg_:getCascadeBoundingBox();
    local px = sz.width*0.5 - lsz.width*0.5 + 10;
    self.goldLightBg_:pos(px, self.iconPy_)
    self.icon_:pos(px, self.iconPy_)

    self.logo_ = display.newSprite("#game_logo.png")
            :addTo(self.icon_, AVATAR_TAG, AVATAR_TAG)
    self.logo_:setScale(0.6)
    -- 
    self:addAnimation_()
end

function ArenaRoomChip1:loadImage_()
    local real = self.data_.first.real;
    if self.lastRealImg_ == real.img then
        return;
    end
    -- 
    if not self.animationIcon_ then
        self.animationIcon_ = AnimationIcon.new(nil, 1, 1)
            :addTo(self.icon_, 10)
    end
    local sz = self.icon_:getContentSize()
    local url = (nk.userData.cdn or "")..''..real.img
    self.animationIcon_:onData(url, sz.width, sz.height, handler(self, self.onAnimationLoaderSucc_), 12)

    self.lastRealImg_ = real.img;
end

function ArenaRoomChip1:onAnimationLoaderSucc_(succ)
    if succ then
        local oldAvatar = self.icon_:getChildByTag(AVATAR_TAG)
        if oldAvatar then
            oldAvatar:removeFromParent()
        end
    end
end

function ArenaRoomChip1:removeAboutReal()
    self:stopAllActions_()
    -- 
    if self.animationIcon_ then
        self.animationIcon_:removeFromParent()
        self.animationIcon_ = nil
    end
    -- 
    if self.goldLightBg_ then
        self.goldLightBg_:removeFromParent()
        self.goldLightBg_ = nil
    end
    -- 
    if self.icon_ then
        self.icon_:removeFromParent()
        self.icon_ = nil
    end
    -- 
    self.lastRealImg_ = nil
end

function ArenaRoomChip1:refresh()
    if not self.data_ then
        return
    end

    local first = self.data_.first or {}
    local getFrame = display.newSpriteFrame
    if first.real then
        self:addEntityStyle()
    else
        self:removeAboutReal()
    end
    -- 冠军
    if not self.champion_ then
        self.champion_ = ui.newTTFLabel({
            text = "",
            color = cc.c3b(color1[1], color1[2], color1[3]),
            size = 20,
            align = ui.TEXT_ALIGN_CENTER,
        }):pos(0,-32):addTo(self)
    end
    -- 
    if DEBUG>0 then
        self.name_:setString(self.data_.name.."   id:"..self.data_.id)
    else
        self.name_:setString(self.data_.name)
    end
    local width = ArenaRoomChip1.WIDTH;
    local sz = self.name_:getContentSize();
    local px = -width*0.5 + self.nameOffX_;
    self.name_:setPositionX(px + sz.width*0.5)
    -- ArenaRoomChip1.WIDTH = 416
    if self.data_.factor1 then
        self.factor_:setString(bm.LangUtil.getText("MATCH","TIMESTART",self.data_.factor1))
    elseif self.data_.factor then
        self.factor_:setString(self.data_.factor)
    end    
    -- 
    local resId = nil;
    if first.real then
        self.champion_:setString(bm.LangUtil.getText("MATCH","CHAMPION",first.real.name))
    elseif self.data_.condition and self.data_.condition.chips and first.chips and tonumber(first.chips)>0 then
        self.champion_:setString(bm.LangUtil.getText("MATCH","CHAMPION",bm.LangUtil.getText("MATCH", "MONEY").." "..first.chips))
        resId = "match_chip.png";
    else
        if first.score and tonumber(first.score)>0 then
            self.champion_:setString(bm.LangUtil.getText("MATCH","CHAMPION",bm.LangUtil.getText("MATCH", "SCORE").." "..bm.LangUtil.getText("MATCH", "SCOREX", first.score)))
            resId = "match_score.png";
        elseif first.pool and tonumber(first.pool)>0 then
            -- 冠军奖励：50%现金币奖池 50% ของรางวัลกองกลาง
            self.champion_:setString(bm.LangUtil.getText("MATCH","CHAMPION", (first.pool*100).."%%ของรางวัลกองกลาง" ))
            resId = "match_score.png";
        --黄金币
        elseif first.gcoins and tonumber(first.gcoins)>0 then
            self.champion_:setString(bm.LangUtil.getText("MATCH","CHAMPION",bm.LangUtil.getText("MATCH", "GOLDCOIN").." "..first.gcoins))
            resId = "match_gcoins.png";
        elseif first.chips and tonumber(first.chips)>0 then
            self.champion_:setString(bm.LangUtil.getText("MATCH","CHAMPION",bm.LangUtil.getText("MATCH", "MONEY").." "..first.chips))
            resId = "match_chip.png";
        elseif first.gameCoupon then
            self.champion_:setString(bm.LangUtil.getText("MATCH","CHAMPION",bm.LangUtil.getText("MATCH", "GAMECOUPON").." "..first.gameCoupon))
            resId = "match_gamecoupon.png";
        elseif first.goldCoupon then
            self.champion_:setString(bm.LangUtil.getText("MATCH","CHAMPION",bm.LangUtil.getText("MATCH", "GOLDCOUPON").." "..first.goldCoupon))
            resId = "match_goldcoupon.png";
        end
    end
    -- 
    if self.championIcon_ then
        self.championIcon_:removeFromParent();
        self.championIcon_ = nil;
    end
    -- 
    if resId then
        self.championIcon_ = display.newSprite(resId)
            :addTo(self)
        local sz = self.championIcon_:getContentSize();
        self.championIcon_:setPositionX(ArenaRoomChip1.WIDTH*0.5 - sz.width*0.5 - 15)
    end
    -- 
    local tempSize = self.champion_:getContentSize()
    self.champion_:setPositionX(px+tempSize.width*0.5 + self.championOffX_)
    local maxDW = 270;
    if tempSize.width > maxDW then
        self.champion_:setScale(maxDW/tempSize.width)
        self.champion_:setPositionX(px + maxDW*0.5 + self.championOffX_)
    else
        self.champion_:setScale(1) 
    end

    local list = nk.match.MatchModel.online
    if list then
        for i=1, #list do
            if list[i].level == tonumber(self.data_.id) then
                self.onLine_:setString(""..list[i].usercount)
                break
            end
        end
    end
    local matchid = nk.match.MatchModel.regList and nk.match.MatchModel.regList[tonumber(self.data_.id)]
    local isReg = 0
    if matchid~=nil and matchid~=0 and matchid~="" then
        isReg = 1
    end
    if self.isReg_ ~= isReg then
        self.isReg_ = isReg
        local key;
        if isReg==1 then
            self.name_:setTextColor(cc.c3b(color2[1], color2[2], color2[3]))
            self.onLine_:setTextColor(cc.c3b(color2[1], color2[2], color2[3]))
            self.factor_:setTextColor(cc.c3b(color2[1], color2[2], color2[3]))
            self.champion_:setTextColor(cc.c3b(color2[1], color2[2], color2[3]))
            key = btn_sprite1;
        else
            self.name_:setTextColor(cc.c3b(color[1], color[2], color[3]))
            self.onLine_:setTextColor(cc.c3b(color[1], color[2], color[3]))
            self.factor_:setTextColor(cc.c3b(color[1], color[2], color[3]))
            self.champion_:setTextColor(cc.c3b(color1[1], color1[2], color1[3]))
            key = btn_sprite;
        end
        self.bg_:setSpriteFrame(display.newSpriteFrame(key))
        self.bg_:setContentSize(ArenaRoomChip1.WIDTH, ArenaRoomChip1.HEIGHT)
    end
    -- 玩法特性 rebuy or hunt
    if not self.playIcons_ then
        self.playIcons_ = {}
    end
    for k,v in ipairs(self.playIcons_) do
        v:hide()
    end
    local showIcons = {}
    if self.data_.rebuy==1 and not self.rebuyIcon_ then
        self.rebuyIcon_ = display.newSprite("#arena/rebuy.png")
            :addTo(self)
        self.rebuyIcon_:hide()
        table.insert(self.playIcons_,self.rebuyIcon_)
    end
    if self.data_.hunter==1 and not self.huntIcon_ then
        self.huntIcon_ = display.newSprite("#arena/hunt.png")
            :addTo(self)
        self.huntIcon_:hide()
        table.insert(self.playIcons_,self.huntIcon_)
    end
    if self.data_.rebuy==1 then
        table.insert(showIcons,self.rebuyIcon_)
    end
    if self.data_.hunter==1 then
        table.insert(showIcons,self.huntIcon_)
    end
    local coordX,coordY = self.factor_:getPosition()
    for k,v in ipairs(showIcons) do
        v:pos(60 - (k-1)*30,coordY-3)
        v:show()
    end
end

function ArenaRoomChip1:onDataSet(dataChanged, data)
    self:refresh()
end

-- addAnimation
-- 设置是否为报名状态
function ArenaRoomChip1:setSelected(value)
    
end

function ArenaRoomChip1:setName(name)
    
end

function ArenaRoomChip1:setInfo(info)
    
end

function ArenaRoomChip1:setOnlineNum(num)
    
end

function ArenaRoomChip1:onCleanup()
    self:stopAllActions_();
end

function ArenaRoomChip1:stopAllActions_()
    if self.goldLightAnim_ then
        self.goldLightAnim_:stopAllActions();
        self.goldLightAnim_:removeFromParent();
        self.goldLightAnim_ = nil;
    end

    if self.goldLight_ then
        self.goldLight_:stopAllActions();
        self.goldLight_:removeFromParent();
        self.goldLight_ = nil;
    end
end

function ArenaRoomChip1:onEntityClickHandler_(evt)
    bm.EventCenter:dispatchEvent({name="ON_CLICK_REAL_ENTITY", data=self.data_})
end

return ArenaRoomChip1
