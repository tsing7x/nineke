--
-- Author: HLF(IdaHuang@boyaa.com)
-- Date: 2016-03-18 10:17:44
--
local SimpleColorLabel = import("boomegg.ui.SimpleColorLabel")
local MatchDetailBar = class("MatchDetailBar", function()
	return display.newNode()
end)

local DW = 191
local DH = 61
local EXT_DH = 26;
local txtX = 12
local txtY = 52
local offVal = 23;

function MatchDetailBar:ctor()
    self.isScorePool_ = false
	self:setTouchEnabled(true)
	self:initView_()
	self:addListener()
end

function MatchDetailBar:initView_()
	-- 创建比赛信息
	local isShowScorePool = true
    self.size_ = cc.size(DW, DH);

    self.px_, self.py_ = 0, 0
    self.bg_ = display.newScale9Sprite("#match_info_panel.png", self.px_, self.py_, self.size_)
            :addTo(self, 1)
    self.bg_:setCascadeOpacityEnabled(true)

    local fontSize = 18    
    self.rankWord_ = ui.newTTFLabel({size=fontSize, text="", color=cc.c3b(0xff, 0xff, 0xff)})
        :pos(txtX, txtY)
        :addTo(self.bg_, 1)
        :align(display.LEFT_TOP)
    self.myRankTxt_ = ui.newTTFLabel({size=fontSize, text="", color=cc.c3b(0xff, 0xd2, 0x0)})
        :pos(txtX+60, txtY)
        :addTo(self.bg_, 1)
        :align(display.LEFT_TOP)
    self.allNumTxt_ = ui.newTTFLabel({size=fontSize, text="", color=cc.c3b(0xff, 0xff, 0xff)})
        :pos(txtX+90, txtY)
        :addTo(self.bg_, 1)
        :align(display.LEFT_TOP)

    self.otherTxt_ = ui.newTTFLabel({size=fontSize, text="", color=cc.c3b(0xff, 0xff, 0xff)})
        :pos(txtX, txtY - offVal*1)
        :addTo(self.bg_, 1)
        :align(display.LEFT_TOP)
    self.countdownTxt_ = ui.newTTFLabel({size=fontSize, text="", color=cc.c3b(0xff, 0xff, 0xff)})
        :pos(txtX, txtY - offVal*1)
        :addTo(self.bg_, 1)
        :align(display.LEFT_TOP)

    self.scorePoolWord_ = SimpleColorLabel.html(bm.LangUtil.getText("MATCH", "SCORE_POOL", 0), styles.FONT_COLOR.LIGHT_TEXT, cc.c3b(0xff, 0xff, 0x0), fontSize, 3)
    	:pos(txtX, txtY - offVal*2 - offVal)
        :addTo(self.bg_, 1)
        :align(display.LEFT_TOP)
end

-- 播放动画
function MatchDetailBar:playAnimation()
	self:stopAnimation();

	if not self.matchInfoBgs_ then
		self.matchInfoBgs_ = display.newNode()
            :addTo(self, 0)

        for i=1,5 do
            local bg = display.newScale9Sprite("#match_info_panel.png", self.px_, self.py_, self.size_)
                :addTo(self.matchInfoBgs_, 0)
            bg:setColor(cc.c3b(0xff, 0xff, 0x0))
        end
        self.matchInfoBgs_:setCascadeOpacityEnabled(true)
	end

	local ts1 = 0.6;
    local ts2 = 0.6;
    self.matchInfoBgs_:show()
    self.matchInfoBgs_:runAction(cc.RepeatForever:create(transition.sequence({cc.FadeOut:create(ts2), cc.FadeIn:create(ts1)})));
end

-- 停止动画
function MatchDetailBar:stopAnimation()
	if self.matchInfoBgs_ then
		self.matchInfoBgs_:hide();
		self.matchInfoBgs_:stopAllActions();
		self.matchInfoBgs_:removeFromParent();
		self.matchInfoBgs_ = nil;
	end
end

function MatchDetailBar:addListener()
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onMatchInfoPanelTouchHandler_))
end

function MatchDetailBar:removeListener()
	self:removeNodeEventListenersByEvent(cc.NODE_TOUCH_EVENT)
end

function MatchDetailBar:onMatchInfoPanelTouchHandler_(evt)
	if evt.name == "began" then
		return true
	elseif evt.name == "moved" then

	elseif evt.name == "ended" then
		if self.onClickCallback_ then
			self.onClickCallback_(evt)
		end
	end
end

function MatchDetailBar:setClickHandler(callback)
	self.onClickCallback_ = callback;
	return self
end

function MatchDetailBar:onCleanup()
	self:removeListener();
	self:stopRiseBlind();
end

function MatchDetailBar:isMatchDetail()
    return nk.userData.isMatchDetail and nk.userData.isMatchDetail == 1;
end

function MatchDetailBar:renderInfo(info)
	self.info_ = info
    self.rankWord_:setString(bm.LangUtil.getText("MATCH", "RANKWORD"))
    self.myRankTxt_:setString(tostring(info.selfRank))
    self.allNumTxt_:setString("/"..info.totalCount)
    --计算坐标
    local x1,y1 = self.rankWord_:getPosition()
    local tsz1 = self.rankWord_:getContentSize()
    local tsz2 = self.myRankTxt_:getContentSize()
    self.myRankTxt_:setPosition(x1+tsz1.width,y1)
    self.allNumTxt_:setPosition(x1+tsz1.width+tsz2.width, y1)

    nk.MatchRecordManager:saveMatchOnlineCount(info.totalCount)
    if self.matchData_ then
        self:setMatchData(self.matchData_)
    end
end

function MatchDetailBar:cleanInfo()
	self.myRankTxt_:setString("")
    self.allNumTxt_:setString("")
    self.otherTxt_:setString("")
    self.countdownTxt_:setString("")
end

function MatchDetailBar:setMatchInfo(matchInfo)
	self:stopRiseBlind();

    self.matchInfo_ = matchInfo;
    self.otherTxt_:setString(bm.LangUtil.getText("MATCH", "RANKINFO",tostring(matchInfo.currentChip or "")))
    self.riseBlindTime_ = matchInfo.leftTime + 1

    local x1,y1 = self.otherTxt_:getPosition()
    local textSize1 = self.otherTxt_:getContentSize()
    self.countdownTxt_:setPosition(x1+textSize1.width,y1)
    self.actionRiseBlind_ = self:schedule(function ()
        self.riseBlindTime_ = self.riseBlindTime_ - 1
        if self.riseBlindTime_<0 then
            return
        end
        self:showMatchCountDown()
    end, 1)
    self:showMatchCountDown()
end

function MatchDetailBar:stopRiseBlind()
	if self.actionRiseBlind_ then
        self:stopAction(self.actionRiseBlind_)
        self.actionRiseBlind_ = nil
    end
end

function MatchDetailBar:showMatchCountDown()
    local timeStr = (self.riseBlindTime_ > 0 and bm.TimeUtil:getTimeString(self.riseBlindTime_)) or ""
    self.countdownTxt_:setString(timeStr)
end

function MatchDetailBar:setMatchData(matchData)
    self.matchData_ = matchData
	local offY = 0
	if matchData.condition and matchData.condition.score and matchData.rewardType == 2 then
        local totalCount = nk.MatchRecordManager:getMatchOnlineCount();
        local val = math.ceil((matchData.condition.score or 1) * totalCount)
    	self.scorePoolWord_.setString(2, val)
    	self.scorePoolWord_:show()

    	self.px_, self.py_ = self.bg_:getPosition()
    	if self.py_ == 0 then
    		self.py_ = -EXT_DH*0.5
	    	self.size_ = cc.size(DW, DH + EXT_DH)
	    	self.bg_:setContentSize(self.size_)
	    	self.bg_:setPositionY(self.py_)

	    	offY = EXT_DH*1.0
	    	self.rankWord_:setPositionY(txtY + offY)
		    self.myRankTxt_:setPositionY(txtY + offY)
		    self.allNumTxt_:setPositionY(txtY + offY)
		    self.otherTxt_:setPositionY(txtY - offVal + offY)
		    self.countdownTxt_:setPositionY(txtY - offVal + offY)
		    self.scorePoolWord_:setPositionY(txtY - offVal*2 + offY*0.5)
	    end

        self.isScorePool_ = true
    else
    	self.scorePoolWord_:hide()

    	self.px_, self.py_ = self.bg_:getPosition()
    	if self.py_ ~= 0 then
    		self.py_ = 0
	    	self.size_ = cc.size(DW, 61)
	    	self.bg_:setContentSize(self.size_)
	    	self.bg_:setPositionY(self.py_)
	    	-- 
	    	self.rankWord_:setPositionY(txtY + offY)
		    self.myRankTxt_:setPositionY(txtY + offY)
		    self.allNumTxt_:setPositionY(txtY + offY)
		    self.otherTxt_:setPositionY(txtY - offVal + offY)
		    self.countdownTxt_:setPositionY(txtY - offVal + offY)
		    self.scorePoolWord_:setPositionY(txtY - offVal*2 + offY)
    	end
        
        self.isScorePool_ = false
    end

    return self
end

function MatchDetailBar:isScorePool()
    return self.isScorePool_
end

return MatchDetailBar