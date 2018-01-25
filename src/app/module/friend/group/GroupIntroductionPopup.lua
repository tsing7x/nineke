local GroupIntroductionPopup = class("GroupIntroductionPopup", nk.ui.Panel)

local logger = bm.Logger.new("GroupIntroductionPopup")

function GroupIntroductionPopup:ctor()
	GroupIntroductionPopup.super.ctor(self,nk.ui.Panel.SIZE_NORMAL)
	self:setNodeEventEnabled(true)
	self:addTitle(bm.LangUtil.getText("GROUP","INTRPOPTITLE"),5)
	self.title_:setTextColor(cc.c3b(0xff,0xff,0xff))
    self.title_:setSystemFontSize(28)
    self:addCloseBtn()

    display.newScale9Sprite("#panel_overlay.png",0, 0, cc.size(self.width_-40, self.height_-90))
    	:pos(0,-20)
        :addTo(self)

end

function GroupIntroductionPopup:show()
    self:showPanel_()
end

function GroupIntroductionPopup:onShowed()
	local width,height = self.width_-40-40,self.height_-90-40
    self.mainNode_ = display.newNode()

    self.label1_ = ui.newTTFLabel({
            size = 22, 
            color = cc.c3b(0xdc, 0xdc, 0xff), 
            align = ui.TEXT_ALIGN_LEFT,
            valign = ui.TEXT_VALIGN_TOP,
            dimensions = cc.size(width, 0)
    	})
	        :align(display.TOP_LEFT, 0, 0)
	        :pos(-width*0.5,height*0.5)
	        :addTo(self.mainNode_)
	self.label1_:setString(bm.LangUtil.getText("GROUP","INTRPOP1"))

	local label1Size = self.label1_:getContentSize()

	local bgWidth,bgHeight = width+10,182
	local awardList = bm.LangUtil.getText("GROUP","INTRPOP2")
	local itemHeight = bgHeight/(#awardList)
	local awardNode = display.newNode()
		:pos(0,height*0.5-label1Size.height-bgHeight*0.5)
		:addTo(self.mainNode_)
	display.newScale9Sprite("#panel_overlay.png",0, 0, cc.size(bgWidth, bgHeight))
        :addTo(awardNode)
    for k,v in ipairs(awardList) do
    	if k==1 then
    		local line = display.newScale9Sprite("#group_dividing_line.png",
           		0, 0, cc.size(bgHeight-4, 2))
    			:addTo(awardNode)
    		line:setRotation(90)

    		ui.newTTFLabel({
		            text = awardList[k][1],
		            color = cc.c3b(0xdc, 0xdc, 0xff),
		            size = 16,
		        })
		   		:pos(-bgWidth/4,bgHeight*0.5-(k-0.5)*itemHeight)
		    	:addTo(awardNode)

		    ui.newTTFLabel({
		            text = awardList[k][2],
		            color = cc.c3b(0xdc, 0xdc, 0xff),
		            size = 16,
		        })
		   		:pos(bgWidth/4,bgHeight*0.5-(k-0.5)*itemHeight)
		    	:addTo(awardNode)
    	else
    		local line = display.newScale9Sprite("#group_dividing_line.png",
           		0, 0, cc.size(bgWidth-4, 2))
    			:pos(0,bgHeight*0.5-(k-1)*itemHeight)
    			:addTo(awardNode)

    		ui.newTTFLabel({
		            text = awardList[k][1],
		            color=cc.c3b(0xff, 0xe9, 0x52),
		            size = 16,
		        })
		   		:pos(-bgWidth/4,bgHeight*0.5-(k-0.5)*itemHeight)
		    	:addTo(awardNode)

		    ui.newTTFLabel({
		            text = awardList[k][2],
		            color=cc.c3b(0xc8, 0x8a, 0xcf),
		            size = 16,
		        })
		   		:pos(bgWidth/4,bgHeight*0.5-(k-0.5)*itemHeight)
		    	:addTo(awardNode)
    	end
    end

    self.label2_ = ui.newTTFLabel({
            size = 22, 
            color = cc.c3b(0xdc, 0xdc, 0xff), 
            align = ui.TEXT_ALIGN_LEFT,
            valign = ui.TEXT_VALIGN_TOP,
            dimensions = cc.size(width, 0)
    	})
	        :align(display.TOP_LEFT, 0, 0)
	        :pos(-width*0.5,height*0.5-label1Size.height-bgHeight)
	        :addTo(self.mainNode_)
	self.label2_:setString(bm.LangUtil.getText("GROUP","INTRPOP3"))

	local label2Size = self.label2_:getContentSize()
	
	local CW,CH = self.width_-44,height
	local scrollViewRect = cc.rect(-CW * 0.5, -CH * 0.5, CW, CH)
    self.scrollView_ = bm.ui.ScrollView.new({
            viewRect      = scrollViewRect,
            scrollContent = self.mainNode_,
            direction     = bm.ui.ScrollView.DIRECTION_VERTICAL,
        })
        :pos(0,-20)
        :addTo(self)
        
    -- 内部规则不是匹配的哦
    self.scrollView_.srcContentPlace_ = 0
    self.mainNode_:pos(0,0)
end

return GroupIntroductionPopup