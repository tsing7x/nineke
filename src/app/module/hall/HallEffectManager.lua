--
-- Author: HLF(IdaHuang@boyaa.com)
-- Date: 2016-08-05 11:43:55
--

local HallEffectManager = class("HallEffectManager")
local DisplayUtil = import("boomegg.util.DisplayUtil")
function HallEffectManager:ctor()
	self.arenaLimitLevel_ = nk.userData.arenaLimiteLevel
end
-- 
function HallEffectManager:addHallEffect(configs, otherConfigs)
	if not configs or not otherConfigs then
		return
	end
	-- 
	self.configs_ = configs
	self.otherConfigs_ = otherConfigs
	-- 
	local skeletonName = "fla_zhujiemian"
    local cardParent, effectNode, px, py, effect, drgCfg, cfg, scaleVal
    for _,cfg in ipairs(configs) do
        effectNode = display.newNode()
        :addTo(cfg[3])
        cfg[3].effectNode = effectNode
        -- 
        for i=1,2 do
            if cfg[i] then
            	drgCfg = {
                    skeleton="dragonbones/fla_zhujiemian/skeleton.xml", 
                    texture="dragonbones/fla_zhujiemian/texture.xml",
                    skeletonName="fla_zhujiemian",
                    armatureName=cfg[i],
                }              
                -- 
                px = cfg["px"..i] or 0
                py = cfg["py"..i] or 0
                scaleVal = cfg["scale"..i] or 1
                effect = dragonbones.new(drgCfg):pos(px, py-2):addTo(effectNode, 99+i):scale(scaleVal):getAnimation():gotoAndPlay("play")
                table.insert(cfg, effect)
            else
                table.insert(cfg, nil) 
            end
        end
    end
    -- 
    for _,cfg in ipairs(otherConfigs) do
        px, py = cfg.px or 0, cfg.py or 0
        scaleVal = cfg.scale or 1
        drgCfg = {
            skeletonName="fla_zhujiemian",
            armatureName=cfg.armatureName,
        }
        effect = dragonbones.new(drgCfg):pos(px, py):addTo(cfg.parent):scale(scaleVal)
        if cfg.func then
            cfg.func()
        else
            effect:getAnimation():gotoAndPlay("play") 
        end
        cfg.parent.effect = effect
    end
    -- 
    self:decideArenaLevelLimit()
end
-- 判断是否显示比赛场加锁图标
function HallEffectManager:decideArenaLevelLimit()
	local arenaCard = self.configs_[2][3]
	local loginUserLevel = tonumber(self:getUserDefaultData(nk.cookieKeys.LOGIN_USER_LEVEL) or 0)
	-- 玩家等级小于限制等级，显示加锁状态
    if nk.userData.level < nk.userData.arenaLimiteLevel or loginUserLevel < nk.userData.arenaLimiteLevel then
    	if arenaCard and not arenaCard.icon_ then
	        local node = display.newNode()
            :addTo(arenaCard, 2)
            :pos(0, 32)
            -- 
            local icon = display.newSprite("#levle_lock.png"):addTo(node)
            local px = 0
            local py = -0.5*icon:getContentSize().height - 12
            local lblBg = display.newSprite("#level_lblBG.png")
            :addTo(node, 2)
            :pos(px, py)

            local lblSz = lblBg:getContentSize()
            local numBg = display.newSprite("#level_"..tostring(nk.userData.arenaLimiteLevel)..".png")
            :addTo(node, 2)
            :pos(px, py)
            local numDW = numBg:getContentSize().width + 4
            lblBg:pos(-0.5*numDW, py)
            numBg:pos(0.5*numDW, py)
            lblBg:pos(-0.5*numDW, py)
            numBg:pos(lblSz.width*0.5 + 3, py)
            --
            local dh = 36
            local dw = lblSz.width + numDW + 20
            local lblBg = display.newScale9Sprite("#level_bg.png", px, py, cc.size(dw, dh))
            :addTo(node, 1)
            -- 
            arenaCard.icon_ = node
            arenaCard.mask_ = display.newScale9Sprite("#common_button_pressed_cover.png", 0, 0, cc.size(178,212))
            :addTo(arenaCard)
            :opacity(120)
	    end
	    arenaCard.effectNode:hide()
    else
    	if arenaCard and not arenaCard.icon_ then
    		arenaCard.effectNode:show()
    	end
    end
end
-- 
function HallEffectManager:isOpenArenaLock()
	local arenaCard = self.configs_[2][3]
	local loginUserLevel = tonumber(self:getUserDefaultData(nk.cookieKeys.LOGIN_USER_LEVEL) or 0)
	if nk.userData.level >= nk.userData.arenaLimiteLevel and loginUserLevel < nk.userData.arenaLimiteLevel then
    	if arenaCard and arenaCard.icon_ then
    		local ts = 0.05
    		local animTS = 0.3
    		local rotateVal = 15
	        arenaCard.icon_:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.RotateTo:create(ts, rotateVal),cc.RotateTo:create(ts, -rotateVal))))
		    arenaCard.icon_:runAction(transition.sequence({
		    	cc.DelayTime:create(1.2),
				cc.Spawn:create(
					cc.ScaleTo:create(animTS, 6),
					cc.FadeOut:create(animTS)
				),
				cc.CallFunc:create(function(obj)
					arenaCard.icon_:stopAllActions()
		    		arenaCard.icon_:removeFromParent()
		    		arenaCard.icon_ = nil
                    if arenaCard.mask_ then
                        arenaCard.mask_:removeFromParent()
                        arenaCard.mask_ = nil
                    end
		    		arenaCard.effectNode:show()
		    		self:updateUserDefaultData(nk.cookieKeys.LOGIN_USER_LEVEL, nk.userData.level)
		    	end)
			}))	        
	    end
    end
end

-- 获取保存本地数据
function HallEffectManager:getUserDefaultData(key)
    return nk.userDefault:getStringForKey(key);
end

-- 把dataStr保存到本地
function HallEffectManager:updateUserDefaultData(key, dataStr)
    nk.userDefault:setStringForKey(key, dataStr);
    nk.userDefault:flush();
end

function HallEffectManager:clean()
	dragonbones.unloadData({
		skeleton="dragonbones/fla_zhujiemian/skeleton.xml", 
        texture="dragonbones/fla_zhujiemian/texture.xml"
    })
end

return HallEffectManager.new()