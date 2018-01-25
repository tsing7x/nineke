--
-- Author: HLF
-- Date: 2015-09-10 17:51:48

local LuckturnController = import(".LuckturnController");
local AnimUpScrollQueueExt = import("boomegg.ui.AnimUpScrollQueueExt")

local MatchEventHandler         = import("app.module.match.MatchEventHandler")

local LuckturnPopup = class("LuckturnPopup", function()
    return display.newNode()
end)

local WIDTH = 470;
local HEIGHT = 470;
local PANEL_CLOSE_BTN_Z_ORDER = 99
local AVATAR_TAG = 101;
local ICON_WIDTH = 85
local ICON_HEIGHT = 85

function LuckturnPopup:ctor(cfgId, fee, cfgList)
    
    self.cfgId_ = cfgId;
	self.fee_ = fee or 5;
    self.cfgs_ = cfgList;
	self:setNodeEventEnabled(true);
	self.controller_ = LuckturnController.new(self);
	self:init();
    self:checkPlayBtnStatus();

    -- 添加日志
    self:getLogs();
end

function LuckturnPopup:checkPlayBtnStatus()
    if nk.userData.score < self.fee_ then
        self.playBtn_:setButtonEnabled(false)
    else
        self.playBtn_:setButtonEnabled(true)
    end
end

function LuckturnPopup:getLogs()
    self.logList_ = {};
    self.controller_:getBigWheelLog(self.cfgId_, function(retData)
        self.logList_ = retData;
        self:initLuckturnLog();
    end);
end

function LuckturnPopup:init()
	self.playTimes_ = 0;
	self.bg_ = display.newScale9Sprite("#luckTurn_dialog_Bg.png", 0, 0, cc.size(WIDTH, HEIGHT)):addTo(self);
	self.border_ = display.newScale9Sprite("#luckTurn_border_Bg.png", 0, -30, cc.size(WIDTH-60, HEIGHT-90)):addTo(self);
	self.bg_:setTouchEnabled(true)
	self.border_:setTouchEnabled(true)

	self.batchNode_ = display.newBatchNode("luckturn_texture.png"):addTo(self);
	self.batchNode_:setTouchEnabled(true);

	self.leftTle_ = display.newSprite("#luckTurn_title_bg.png"):addTo(self.batchNode_);
	self.rightTle_ = display.newSprite("#luckTurn_title_bg.png"):addTo(self.batchNode_);
	local sz = self.leftTle_:getContentSize();
	self.leftTle_:pos(-sz.width*0.5+0, HEIGHT*0.5);
	self.rightTle_:pos(sz.width*0.5-0, HEIGHT*0.5);
	self.rightTle_:flipX(true);

	display.newSprite("#luckTurn_title.png"):pos(0, HEIGHT*0.5):addTo(self.batchNode_);

	self.leftBar_ = display.newSprite("#luckTurn_bar_Bg.png"):addTo(self.batchNode_);
	self.rightBar_ = display.newSprite("#luckTurn_bar_Bg.png"):addTo(self.batchNode_);
	local barsz = self.leftBar_:getContentSize();
	self.leftBar_:pos(-barsz.width*0.5, -HEIGHT*0.5 + 48)
	self.rightBar_:pos(barsz.width*0.5, -HEIGHT*0.5 + 48)
	self.rightBar_:flipX(true);

	display.newSprite("#luckTurn_goldIcon_Bg.png"):addTo(self.batchNode_):pos(-barsz.width*0.5, -HEIGHT*0.5 + 55);
	display.newSprite("#luckTurn_giftIcon_Bg.png"):addTo(self.batchNode_):pos(barsz.width*0.5+36, -HEIGHT*0.5 + 80);	

	self.leftBot_ = display.newSprite("#luckTurn_bottom_Bg.png"):addTo(self.batchNode_);
	self.rightBot_ = display.newSprite("#luckTurn_bottom_Bg.png"):addTo(self.batchNode_);
	local bsz = self.leftBot_:getContentSize();
	self.leftBot_:pos(-bsz.width*0.5, -HEIGHT*0.5)
	self.rightBot_:pos(bsz.width*0.5, -HEIGHT*0.5)
	self.rightBot_:flipX(true);

	self.lcircleBg_ = display.newSprite("#luckTurn_circle_Bg.png"):addTo(self.batchNode_);
	self.rcircleBg_ = display.newSprite("#luckTurn_circle_Bg.png"):addTo(self.batchNode_);
	self.rcircleBg_:flipX(true);
	local csz = self.lcircleBg_:getContentSize();
	self.lcircleBg_:setAnchorPoint(cc.p(1, 0.5))
	self.rcircleBg_:setAnchorPoint(cc.p(0, 0.5))
	self.lcircleBg_:pos(0, 2);
	self.rcircleBg_:pos(0, 2);

	local bdsz = self.border_:getContentSize();
	self.lightLT_ = display.newSprite("#luckTurn_light.png"):pos(-bdsz.width*0.5+10, bdsz.height*0.5-40):addTo(self.batchNode_);
	self.lightRT_ = display.newSprite("#luckTurn_light.png"):pos(bdsz.width*0.5-10, bdsz.height*0.5-40):addTo(self.batchNode_);
	self.lightLB_ = display.newSprite("#luckTurn_light.png"):pos(-bdsz.width*0.5+10, -bdsz.height*0.5):addTo(self.batchNode_);
	self.lightRB_ = display.newSprite("#luckTurn_light.png"):pos(bdsz.width*0.5-10, -bdsz.height*0.5):addTo(self.batchNode_);

	self.lightLT_:setAnchorPoint(cc.p(0.5, 0.2));
	self.lightRT_:setAnchorPoint(cc.p(0.5, 0.2));
	self.lightLB_:setAnchorPoint(cc.p(0.5, 0.2));
	self.lightRB_:setAnchorPoint(cc.p(0.5, 0.2));

	self:resetLightRotate();
	-- 添加光点
	local px, py, pot;
	local radius = 182;
	self.bigPots_ = {};
	self.smallPots_ = {};
	self.allPots_ = {};
	for i=0,360,30 do
		px, py = math.sin(i*math.pi/180)*radius, math.cos(i*math.pi/180)*radius;
		pot = display.newSprite("#luckTurn_smallpot_Bg.png"):pos(px, py):addTo(self.batchNode_);
		table.insert(self.smallPots_, #self.smallPots_+1, pot);
		table.insert(self.allPots_, #self.allPots_+1, pot);

		px, py = math.sin((i+15)*math.pi/180)*radius, math.cos((i+15)*math.pi/180)*radius;
		pot = display.newSprite("#luckTurn_bigpot_Bg.png"):pos(px, py):addTo(self.batchNode_);
		table.insert(self.bigPots_, #self.bigPots_+1, pot);
		table.insert(self.allPots_, #self.allPots_+1, pot);
	end

	self.playBtn_ = cc.ui.UIPushButton.new({normal = "#luckTurn_start_btn_up.png", pressed = "#luckTurn_start_btn_down.png", disabled = "#luckTurn_start_btn_disabled.png"})
        :addTo(self, 9999)
        :pos(0, 0)
        :onButtonClicked(handler(self, self.onPlayBtnListener_))
        :onButtonRelease(function()

        end)
        :setButtonLabel(ui.newTTFLabel({
                 text = bm.LangUtil.getText("WHEEL", "PLAY"),
                 size = 32,
                 color = styles.FONT_COLOR.GOLDEN_TEXT,
                 align = ui.TEXT_ALIGN_CENTER
            }))
        :setButtonLabelOffset(0, -18)

    self.goRecordBtn_ = cc.ui.UIPushButton.new({
	    		normal="#luckTurn_goto_btn_up.png",
	    		pressed="#luckTurn_goto_btn_down.png"
    		},{scale9 = true}
    	)
    	:setButtonSize(100, 53)
    	:addTo(self)
    	:pos(WIDTH*0.5-70, -HEIGHT*0.5-13)
    	:onButtonClicked(handler(self, self.onGotRecordBtn_))
    	:setButtonLabel(ui.newTTFLabel({
                 text = bm.LangUtil.getText("WHEEL", "GOTO_RECORD"),
                 size = 18,
                 color = styles.FONT_COLOR.GOLDEN_TEXT,
                 align = ui.TEXT_ALIGN_CENTER
            }));

	self.closeBtn_ = cc.ui.UIPushButton.new({normal = "#panel_close_btn_up.png", pressed="#panel_close_btn_down.png"})
            :pos(WIDTH*0.5 + 45, HEIGHT*0.5 - 35)
            :onButtonClicked(function()
                self:onClose()
                nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
            end)
            :addTo(self, PANEL_CLOSE_BTN_Z_ORDER)

	display.addSpriteFrames("wheel_texture.plist", "wheel_texture.png", handler(self, self.addSliceBar))
end

function LuckturnPopup:addSliceBar()
	-- 添加转盘资源
	local slice;
	local imgRes;
	local lblColor;
	self.wheel_ = display.newNode():addTo(self);
	self.wheel_:setTouchEnabled(true);
	self.sliceItems_ = {};
	for i=1,8 do
		if i%2 == 1 then
			imgRes = "#luckTurn_yellow_slice.png";
			lblColor = cc.c3b(0x57, 0x3a, 0x00);
		else
			imgRes = "#luckTurn_purple_slice.png";
			lblColor = styles.FONT_COLOR.GOLDEN_TEXT;
		end
		slice = display.newSprite(imgRes):addTo(self.wheel_);
        -- 保存Slice尺寸
        if not self.sliceSZ_ then
            self.sliceSZ_  = slice:getContentSize(); 
        end
		self:addSliceItem(i, slice, self.cfgs_[i], lblColor);
		slice:setAnchorPoint(cc.p(0.5, 0));
		slice:rotation(45*(i-1));

		table.insert(self.sliceItems_, #self.sliceItems_+1, slice);
	end
end

function LuckturnPopup:addSliceItem(index, sliceNode, cfg, lblColor)
	----type:: 1互动道具  2现金卡  3比赛劵 4金券 5为最高筹码(wheel_reward_1.png) 
	-- 6为最高筹码(wheel_reward_2.png) 7为最高筹码(wheel_reward_3.png) 8为最高筹码(wheel_reward_4.png) 
	-- 9为最高筹码(wheel_reward_5.png) 10为最高筹码(wheel_reward_6.png)
	if not cfg then
		return;
	end

    local fontSize = 16;
    local px, py = self.sliceSZ_.width*0.5, 0;
    local cfgName = cfg.name;
	if cfg.type == "fun_face" then
        -- 互动道具
		display.newSprite("#prop_hddj_icon.png"):pos(px, 118):addTo(sliceNode);
		ui.newTTFLabel({
            text = cfg.num, color = cc.c3b(0xff,0xff,0),
            size = 24, align = ui.TEXT_ALIGN_CENTER})
        :pos(80, 102)
        :addTo(sliceNode)

        py = 150;
	elseif cfg.type == "score" then
        -- 积分现金卡
		display.newSprite("#luckTurn_reward_card.png"):pos(px, 115):addTo(sliceNode);
		ui.newTTFLabel({
            text = cfg.num, color = cc.c3b(0xa0,0x4e,0x02),
            size = 16, align = ui.TEXT_ALIGN_CENTER})
        :pos(65, 123)
        :addTo(sliceNode)

        py = 150;
	elseif cfg.type == "game_coupon" then
        -- 比赛券
		display.newSprite("#luckTurn_reward_coupon.png"):pos(px, 115):addTo(sliceNode);

        py = 150;
        ui.newTTFLabel({
            text = cfg.num, color = cc.c3b(0xff,0xff,0),
            size = 24, align = ui.TEXT_ALIGN_CENTER})
        :pos(80, 102)
        :addTo(sliceNode)
    elseif cfg.type == "chips" then
        local res;
        if cfg.num < 800 then
            res = "wheel_reward_6.png";
        elseif cfg.num < 1500 then
            res = "wheel_reward_5.png";
        elseif cfg.num < 4000 then
            res = "wheel_reward_4.png";
        elseif cfg.num < 70000 then
            res = "wheel_reward_3.png";
        elseif cfg.num < 500000 then
            res = "wheel_reward_2.png";
        else
            res = "wheel_reward_1.png";
        end

        display.newSprite("#"..res):pos(px, 108):addTo(sliceNode);

        py = 150;
    elseif cfg.type == "real" then
        local iconContainer = display.newNode():pos(px, 118):size(ICON_WIDTH, ICON_HEIGHT):addTo(sliceNode);
        local iconLoaderId = nk.ImageLoader:nextLoaderId();
        local defaultIcon = display.newSprite("#game_logo.png"):addTo(iconContainer, AVATAR_TAG, AVATAR_TAG)
        defaultIcon:setScale(0.4)

        self["icon_"..index] = iconContainer;
        self["iconLoaderId_"..index] = iconLoaderId;
        self["defaultIcon"..index] = defaultIcon;

        nk.ImageLoader:cancelJobByLoaderId(iconLoaderId)
        nk.ImageLoader:loadAndCacheImage(iconLoaderId,
            cfg.img,
            function(success, sprite)
                if sprite and type(sprite) ~= "string" then
                    local tex = sprite:getTexture()
                    local texSize = tex:getContentSize()
                    local oldAvatar = iconContainer:getChildByTag(AVATAR_TAG)
                    if oldAvatar then
                        oldAvatar:removeFromParent()
                    end

                    local iconSize = iconContainer:getContentSize()
                    local xxScale = iconSize.width/texSize.width
                    local yyScale = iconSize.height/texSize.height
                    local scaleVal = xxScale<yyScale and xxScale or yyScale;
                    sprite:scale(scaleVal):addTo(iconContainer, 0, AVATAR_TAG)
                end
            end
        )
        py = 150;
        lblColor = cc.c3b(0x99, 0, 0);
    end

    if cfg.type == "real" then
        ui.newTTFLabelWithOutline({
            text = cfgName,
            text = cfgName, color = lblColor,
            size = fontSize, align = ui.TEXT_ALIGN_CENTER,
            outlineWidth = 1,
            dimensions=cc.size(120, 0),
            outlineColor = cc.c3b(0xcc, 0x66, 0x0),
        })
        :pos(px, py)
        :addTo(sliceNode)
    else
        ui.newTTFLabel({
            text = cfgName, color = lblColor,
            size = fontSize, align = ui.TEXT_ALIGN_CENTER,
            dimensions=cc.size(120, 0),
        })
        :pos(px, py)
        :addTo(sliceNode)
    end
end

function LuckturnPopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
            self.juhua_:pos(0, 0)
            self.juhua_:addTo(self)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

-- flushMyScore 刷新商城积分
-- 跳转到大转盘日志
-- 同步大转盘日志
function LuckturnPopup:show(flushMyScore, gotoLogcallback, gotoShowGoodscallback)
    self.flushMyScore_ = flushMyScore;
    self.gotoLogflushMyScore_ = gotoLogcallback;
    self.gotoShowGoodscallback_ = gotoShowGoodscallback;
    nk.PopupManager:addPopup(self)
    return self
end

function LuckturnPopup:onShowed()
end

function LuckturnPopup:hide()
    nk.PopupManager:removePopup(self)
    return self
end

function LuckturnPopup:onClose()
    if self.modal_ then
        self.modal_:removeFromParent()
        self.modal_ = nil
    end

	return self:hide();
end

function LuckturnPopup:onCleanup()
    self:flushMyScore();

	self.controller_:dispose();

	self:stopDotsAnim_()

	display.removeSpriteFramesWithFile("wheel_texture.plist", "wheel_texture.png")
    nk.schedulerPool:delayCall(function()
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end, 0.1)

    for i=1,8 do
        if self["iconLoaderId_"..i] then
            nk.ImageLoader:cancelJobByLoaderId(self["iconLoaderId_"..i])
        end
    end
end

-- 刷新我的积分
function LuckturnPopup:flushMyScore()
    if self.flushMyScore_ then
        self.flushMyScore_();
    end
end

function LuckturnPopup:onGotRecordBtn_()
    if self.gotoLogflushMyScore_ then
        self.gotoLogflushMyScore_();
    end
    self:onClose();
end

function LuckturnPopup:onPlayBtnListener_(evt)
    if nk.userData.score >= self.fee_ then
        if evt then
            nk.ui.Dialog.new({
                messageText = bm.LangUtil.getText("WHEEL", "LUCKTURN_COMFIRM_PAYFEE", self.fee_),
                closeWhenTouchModel = false,
                callback = function (type)
                    if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                        self.playBtn_:setButtonEnabled(false);
                        self:playNow();
                    else
                        
                    end

                    self:addModule();
                end
            }):show();
        else
            self.playBtn_:setButtonEnabled(false);
            self:playNow();

            self:addModule();
        end
    else
        self:checkPlayBtnStatus();
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("WHEEL", "LUCKTURN_NOT_ENOUGH_MONEY"));
    end

    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand {
            command = "event",
            args = {eventId = "match_luckturn_play_"..self.cfgId_},
            label = "luckturn play"
        }
    end
end

function LuckturnPopup:addModule()
    if not self.modal_ then
        self.modal_ = display.newScale9Sprite("#modal_texture.png", 0, 0, cc.size(display.width, display.height))
            :pos(0, 0)
            :addTo(self, -999)
        self.modal_:setTouchEnabled(true)
        self.modal_:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onClose))
    end    
end

function LuckturnPopup:onplayLightEffect()
end

function LuckturnPopup:playDotsAnimInNormal_()
    self:stopDotsAnim_()
    local dts = 0.1;
    for _, dot in ipairs(self.bigPots_) do
        dot:runAction(cc.RepeatForever:create(transition.sequence({
                    cc.FadeTo:create(dts, 255), 
                    cc.DelayTime:create(dts),
                    cc.FadeTo:create(dts, 0),
                    cc.DelayTime:create(dts)
                })
            )
        )
    end

    for _, dot in ipairs(self.smallPots_) do
        dot:runAction(cc.RepeatForever:create(transition.sequence({
        			cc.FadeTo:create(dts, 0),
        			cc.DelayTime:create(dts),
                    cc.FadeTo:create(dts, 255),
                    cc.DelayTime:create(dts)
                })
            )
        )
    end

    local ts = 0.5;
    self.lightLT_:runAction(cc.RepeatForever:create(transition.sequence({
		cc.RotateTo:create(ts, 120);
		cc.RotateTo:create(ts, 160);
	})))

	self.lightRT_:runAction(cc.RepeatForever:create(transition.sequence({
		cc.RotateTo:create(ts, -120);
		cc.RotateTo:create(ts, -160);
	})))

	self.lightLB_:runAction(cc.RepeatForever:create(transition.sequence({
		cc.RotateTo:create(ts, 30);
		cc.RotateTo:create(ts, 75);
	})))

	self.lightRB_:runAction(cc.RepeatForever:create(transition.sequence({
		cc.RotateTo:create(ts, -30);
		cc.RotateTo:create(ts, -75);
	})))
end

function LuckturnPopup:stopDotsAnimInNormal_()
	for _, dot in ipairs(self.allPots_) do
        dot:setOpacity(255);
    end

    self:stopDotsAnim_();
    self:resetLightRotate();
end

function LuckturnPopup:resetLightRotate()
	self.lightLT_:rotation(135);
	self.lightRT_:rotation(-135);
	self.lightLB_:rotation(45);
	self.lightRB_:rotation(-45);
end

function LuckturnPopup:stopDotsAnim_()
    for _, dot in ipairs(self.allPots_) do
        dot:stopAllActions()
    end

    self.lightLT_:stopAllActions();
    self.lightRT_:stopAllActions();
    self.lightLB_:stopAllActions();
    self.lightRB_:stopAllActions();
end

function LuckturnPopup:findItemById(id)
	return self.cfgs_[id+1];
end

function LuckturnPopup:setDestDegreeById(id)
	math.randomseed(tostring(os.time()):reverse():sub(1, 6))
	local randDegree = 0
    local offsetDegree = 5
    if id == 0 then
        randDegree = math.random(-20 + offsetDegree, 20 - offsetDegree)
    else
        local min = 20 + 3 + 45 * (id - 1) + offsetDegree
        local max = min - 3 + 45 - offsetDegree * 2
        randDegree = math.random(min, max)
    end

    self.destDegree_ = 360 - randDegree
end

function LuckturnPopup:startRotation(callback)
    self.animOverflushMyScore_ = callback
    if self.soundId then
          audio.stopSound(self.soundId)
    end
    self.soundId = nk.SoundManager:playSound(nk.SoundManager.WHEEL_LOOP, false)
    self:rotationByAccelerate()
end

function LuckturnPopup:rotationByAccelerate()
    self.wheel_:stopAllActions()
    local sequence = transition.sequence({
        cc.EaseIn:create(cc.RotateBy:create(1, 360), 2.5),
        cc.CallFunc:create(function()
            self:rotationByDefault()
        end),
    })
    self.wheel_:runAction(sequence)
end

function LuckturnPopup:rotationByDefault()
    self.wheel_:setRotation(self.destDegree_)
    local sequence = transition.sequence({
        cc.RotateBy:create(0.5, 360),
        cc.CallFunc:create(function()
            self:rotationByDecelerate()
        end),
    })
    self.wheel_:runAction(sequence)
end

function LuckturnPopup:rotationByDecelerate()
    local sequence = transition.sequence({
        cc.EaseOut:create(cc.RotateBy:create(3, 360), 2.5),
        cc.CallFunc:create(function()
            if self.soundId then
                  audio.stopSound(self.soundId)
            end
            if self.animOverflushMyScore_ then
                self.animOverflushMyScore_()
            end
        end),
    })
    self.wheel_:runAction(sequence)
end

function LuckturnPopup:playNow()
    self.controller_:playNow(self.cfgId_, function(isSucc, data)
        if isSucc then
            self:playDotsAnimInNormal_();
            self:setDestDegreeById(data.pos)
            self:startRotation(function()
                if nk.userData.score >= self.fee_ then
                    self.playBtn_:setButtonEnabled(true)
                end

                local item = self:findItemById(data.pos);
                -- 比赛券 
                self:performWithDelay(function()
                    nk.SoundManager:playSound(nk.SoundManager.WHEEL_WIN)
                    self:stopDotsAnimInNormal_();
                    self:addRewardAlertTip(item);

                    -- 添加日志
                    self:getLogs();
                    self:flushMyScore();
                end, 0.5)
                nk.SoundManager:playSound(nk.SoundManager.WHEEL_END)
            end)
        else
            if nk.userData.score >= self.fee_ then
                self.playBtn_:setButtonEnabled(true)
            end
        end
    end)
end

function LuckturnPopup:addRewardAlertTip(itemCfg)
    if itemCfg.type == "real" then
        if self.gotoShowGoodscallback_ then
            self.gotoShowGoodscallback_(itemCfg);
        end
    else
        nk.ui.Dialog.new({
            messageText = bm.LangUtil.getText("WHEEL", "DIALOG_CONTENT", itemCfg.name),
            secondBtnText = "เล่นอีกครั้ง",
            firstBtnText = bm.LangUtil.getText("WHEEL","DIALOG_SEE"),
            callback = function (type)
                if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                    self:onPlayBtnListener_();                    
                elseif type == nk.ui.Dialog.FIRST_BTN_CLICK then
                    self:onGotRecordBtn_();
                end
            end
        }):show();
    end
end

function LuckturnPopup:initLuckturnLog()
    local list = {};
    for i=1,#self.logList_ do
        local item = self.logList_[i];
        if item and item.msg and string.len(item.msg)>0 then
            table.insert(list, #list+1, item.msg)
        end
    end

    if nil == self.queue_ then
        local params = {}
        params.lineCnt = 3;
        params.contentSize = cc.size(400, 20*params.lineCnt);
        params.lblSize = 16;
        params.color = cc.c3b(255, 255, 255);
        params.align = ui.TEXT_ALIGN_LEFT;
        params.offx = 10;
        params.offy = 0;
        params.delayTs = 1.0;
        self.queue_ = AnimUpScrollQueueExt.new(params)
            :addTo(self)
            :pos(-15, -247)
            :setData(list)
            :setMaxSize(30)
            :startAnim();
    else
        self.queue_:setData(list);
    end
end

return LuckturnPopup;