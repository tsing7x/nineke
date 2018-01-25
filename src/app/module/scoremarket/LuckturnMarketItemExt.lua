--
-- Author: XT
-- Date: 2015-09-10 18:54:17
--
local GRID_HEIGHT = 240
local ICON_WIDTH = 191
local ICON_HEIGHT = 150
local AVATAR_TAG = 101

local LuckturnMarketItemExt = class("LuckturnMarketItemExt", bm.ui.ListItem)
LuckturnMarketItemExt.WIDTH = 205; -- 205 252
LuckturnMarketItemExt.HEIGHT = 218; -- 205 252

function LuckturnMarketItemExt:ctor()
  local WIDTH = LuckturnMarketItemExt.WIDTH;
  local HEIGHT = LuckturnMarketItemExt.HEIGHT;
  local GRID_WIDTH = WIDTH * 2 + 25 * 2;
	self:setNodeEventEnabled(true); -- 框架直接执行 onCleanup
	LuckturnMarketItemExt.super.ctor(self, GRID_WIDTH, GRID_HEIGHT)
	self:createSubItem(1)
	self:createSubItem(2)
	self:createSubItem(3)
  self["iconLoaderId1_"] = nk.ImageLoader:nextLoaderId()
  self["iconLoaderId2_"] = nk.ImageLoader:nextLoaderId()
  self["iconLoaderId3_"] = nk.ImageLoader:nextLoaderId()

 -- 	local tempBg = display.newScale9Sprite("#luckTurn_border_Bg.png",0,0,cc.size(WIDTH, HEIGHT))
	-- 		:pos((WIDTH+20)*(2-1),HEIGHT*0.5)
	-- 	    :addTo(self);
end

function LuckturnMarketItemExt:createSubItem(index)
  local WIDTH = LuckturnMarketItemExt.WIDTH;
  local HEIGHT = LuckturnMarketItemExt.HEIGHT;
  local GRID_WIDTH = WIDTH * 2 + 25 * 2;
  -- luckTurn_border_Bg.png
	local tempBg = display.newScale9Sprite("#sm_good_border1.png",0,0,cc.size(WIDTH, HEIGHT))
			:pos((WIDTH+20)*(index-1),HEIGHT*0.5)
		    :addTo(self);
    self["itemBg"..index.."_"] = tempBg;
    local bgsz = tempBg:getContentSize();
    -- 
    local defaultIcon_ = display.newSprite():addTo(tempBg);    
    -- local isz = defaultIcon_:getContentSize();
    -- defaultIcon_:pos(bgsz.width*0.5, bgsz.height - isz.height*0.5 - 6);
    self["defaultIcon"..index.."_"] = defaultIcon_;

    local lblNum = ui.newTTFLabel({
    		text = "5",
    		color = styles.FONT_COLOR.GOLDEN_TEXT,
    		size = 22,
    		align = ui.TEXT_ALIGN_CENTER
    	})
    	:pos(bgsz.width*0.5, bgsz.height * 0.5 + 18)
    	:addTo(tempBg, 9999)
   	self["lblNum"..index.."_"] = lblNum;
    lblNum:hide();

    local tempIcon = display.newNode()
        :size(ICON_WIDTH,ICON_HEIGHT)
        :pos(bgsz.width*0.5,bgsz.height*1.0)
        :addTo(tempBg);    
   	self["icon"..index.."_"] = tempIcon;

   	local offy = -0;
    display.newScale9Sprite("#luckTurn_open_btn_up.png", bgsz.width*0.5, 30 + offy, cc.size(WIDTH, 62), cc.rect(25, 22, 2, 5)):addTo(tempBg)
   	local tempLbl = ui.newTTFLabel({
   			text = bm.LangUtil.getText("SCOREMARKET", "JOIN_LUCKTURN"), 
   			color = styles.FONT_COLOR.LIGHT_TEXT,
   			size = 32, 
   			align = ui.TEXT_ALIGN_CENTER
   			})
		:pos(bgsz.width*0.5, 30 + offy)
		:addTo(tempBg);
   	self["btnLbl"..index.."_"] = tempLbl;

    local tempBtn = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_6.png"}, {scale9 = true})
              :setButtonSize(WIDTH+6, HEIGHT+6)
              :pos(WIDTH*0.5, HEIGHT*0.5)
              :onButtonClicked(function(evt)
                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON);
                self:onGotoLuckturnView(index);
              end)
              :addTo(tempBg);
    self["btn"..index.."_"] = tempBtn;

    tempBtn:setTouchSwallowEnabled(false)
    tempBg:setVisible(false)

    tempBg:hide();
end

function LuckturnMarketItemExt:onDataSet(dataChanged, data)
	self.data_ = data;
	self.dataChanged_ = self.dataChanged_ or dataChanged
    self["itemBg1_"]:setVisible(false)
    self["itemBg2_"]:setVisible(false)
    self["itemBg3_"]:setVisible(false)
    local tempBg = nil
    for k,v in ipairs(data) do
        tempBg = self["itemBg"..k.."_"]
        if v==nil then
            tempBg:hide();
        else
            tempBg:show();
            local lbl = self["lblNum"..k.."_"];
            lbl:setString(tostring(v.condition.score))

            local btnLbl = self["btnLbl"..k.."_"];
            btnLbl:setString(tostring(v.name))            

            if v.img and string.len(v.img) > 0 then
            	self["defaultIcon"..k.."_"]:hide();
            	-- self["lblNum"..k.."_"]:hide()
            	local iconContainer = self["icon"..k.."_"]
	            local iconLoader = self["iconLoaderId"..k.."_"];            -- v.img = "http://pclptl9k02-static.boyaagame.com/static/nineke/nineke/gift/gift-1049.png"
	            -- print("imageurl==="..v.img)
	            nk.ImageLoader:cancelJobByLoaderId(iconLoader)
	            nk.ImageLoader:loadAndCacheImage(iconLoader,
	                v.img, 
	                function(success, sprite)
	                    if success then
	                        -- print("success===============")
	                        local tex = sprite:getTexture()
	                        local texSize = tex:getContentSize()
	                        local oldAvatar = iconContainer:getChildByTag(AVATAR_TAG)
	                        if oldAvatar then
	                            oldAvatar:removeFromParent()
	                        end
	                        -- self.awardIcon_:setTexture(tex)
	                        -- self.awardIcon_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
	                        -- local bgsz = tempBg:getContentSize();
	                        local iconSize = iconContainer:getContentSize()
	                        local xxScale = iconSize.width/texSize.width
	                        local yyScale = iconSize.height/texSize.height
	                        sprite:scale(xxScale<yyScale and xxScale or yyScale)
	                            :addTo(iconContainer, 0, AVATAR_TAG)
	                            :pos(0, -iconSize.height*0.5 - 6)
	                            -- :pos(iconSize.width/2,iconSize.height/2)
	                    else
	                        -- print("faile===============")
	                    end
	                end,
	                nk.ImageLoader.CACHE_TYPE_GIFT
	            )
            end            
        end
    end
end

-- luckTurn_border_Bg.png

function LuckturnMarketItemExt:onGotoLuckturnView(index)
	bm.EventCenter:dispatchEvent({name = "goto_luckturnPopup", data = self.data_[index]})
end

return LuckturnMarketItemExt;