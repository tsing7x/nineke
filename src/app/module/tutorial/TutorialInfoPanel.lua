--
-- Author: HLF(IdaHuang@boyaa.com)
-- Date: 2016-08-05 10:24:26
--
local TutorialInfoPanel = class("TutorialInfoPanel")
local DH = 50
function TutorialInfoPanel:ctor()

end

-- msg:为显示的文字信息
-- arrowOffX:小箭头的偏移量
-- isPullDown:是否倒置方向
function TutorialInfoPanel:createArrowView(cfg)
	local arrowOffX = cfg.arrowOffX or 0
	local isPullDown = cfg.isPullDown or 0
	local holdTime = cfg.holdTime or 2
	local delayTime = cfg.delayTime or 1
	local msg = cfg.msg or ""	
	-- 
    local tutorialNode_ = display.newNode()
    tutorialNode_:setCascadeOpacityEnabled(true)
    tutorialNode_:setNodeEventEnabled(true);-- 设置为true时，当销毁的时候会调用 onCleanUp();
    -- lbl
    local lbl = ui.newTTFLabel({
        text=msg,
        color=cc.c3b(164, 99, 1),
        size=18,
    })
    :addTo(tutorialNode_, 2)
    local sz = lbl:getContentSize()
    -- bar
    local bar_ = display.newScale9Sprite("#common_guide_bar.png", 0, 0, cc.size(sz.width + 15, DH))
    :addTo(tutorialNode_, 0)
    -- arrow
    local arrow_ = display.newSprite("#common_guide_arrow.png")
    :addTo(tutorialNode_, 1)
    :pos(arrowOffX, -27)
    -- 
    tutorialNode_:setOpacity(0)
    -- 
    local dh = DH
    if isPullDown == 1 then
        tutorialNode_:scale(-1)
        lbl:scale(-1)
        dh = -dh
    else
        tutorialNode_:scale(1)
        lbl:scale(1)
    end
    -- 
    local inTs = 0.4
    local outTs = 0.2
    local playShow = function()
    	tutorialNode_:stopAllActions()
	    tutorialNode_:setOpacity(0)
	    tutorialNode_:runAction(transition.sequence({
	    	cc.DelayTime:create(delayTime),
	        cc.Spawn:create(cc.FadeIn:create(inTs), cc.MoveBy:create(inTs, cc.p(0, dh)))
	    }))
	    return tutorialNode_
	end
	-- 
	local playHide = function()
		tutorialNode_:stopAllActions()
    	tutorialNode_:stopAllActions()
	    tutorialNode_:setOpacity(255)
	    tutorialNode_:runAction(transition.sequence({
	        cc.Spawn:create(cc.FadeOut:create(outTs), cc.MoveBy:create(outTs, cc.p(0, -dh))),
	        cc.CallFunc:create(function(obj)
	        	bm.EventCenter:dispatchEvent({name=nk.TutorialManager.TutorialAnimationEnd_Event, data=cfg})
	        	tutorialNode_:removeFromParent()
	        end)
	    }))
	    return tutorialNode_
	end
	-- 自动显示和隐藏
	local autoShowAndHide = function()
    	tutorialNode_:stopAllActions()
	    tutorialNode_:setOpacity(0)
	    tutorialNode_:runAction(transition.sequence({
	    	cc.DelayTime:create(delayTime),
	        cc.Spawn:create(cc.FadeIn:create(inTs), cc.MoveBy:create(inTs, cc.p(0, dh))),
	        cc.DelayTime:create(holdTime),
	        cc.Spawn:create(cc.FadeOut:create(outTs), cc.MoveBy:create(outTs, cc.p(0, -dh))),
	        cc.CallFunc:create(function(obj)
	        	bm.EventCenter:dispatchEvent({name=nk.TutorialManager.TutorialAnimationEnd_Event, data=cfg})
	        	tutorialNode_:removeFromParent()
	        end)
	    }))
	    return tutorialNode_
	end
	-- 
	-- 
	local onCleanup = function()
		tutorialNode_:stopAllActions()		
	end
	-- 
	tutorialNode_.playShow = playShow
	tutorialNode_.playHide = playHide
	tutorialNode_.autoShowAndHide = autoShowAndHide
	tutorialNode_.onCleanup = onCleanup

	return tutorialNode_
end

return TutorialInfoPanel