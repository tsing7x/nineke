--
-- Author: hlf
-- Date: 2015-08-13 21:04:22
--
local TitleBtnGroup = class("TitleBtnGroup", function()
	return display.newNode();
end);

TitleBtnGroup.BTN_MODLE = 1;
TitleBtnGroup.TOUCH_MODLE = 2;

function TitleBtnGroup:ctor(params, cancelSelectedCallback, isCancelSelected, bgUpImg, bgDownImg, lineUpImg, lineDownImg, modleType)
    self.cfg_ = params;
    self.cancelSelectedCallback_ = cancelSelectedCallback;
    self.isCancelSelected_ = isCancelSelected or false; -- 是否可以取消选中的Tab状态 false为点击同一个Tab不取消选中状态
    self.selectIdx = -1; -- 如果isCancelSelected为true表示可以取消选中状态，没选中self.selectIdx的状态为-1
    self.bgUpImg_ = bgUpImg or "transparent.png";
	self.bgDownImg_ = bgDownImg or "transparent.png";
	self.lineUpImg_ = lineUpImg or "transparent.png";
	self.lineDownImg_ = lineDownImg or "transparent.png"
    self.defaultModle_ = modleType or TitleBtnGroup.TOUCH_MODLE;
end

function TitleBtnGroup:setCfgData(value)
	self.cfg_ = value;
	return self;
end

function TitleBtnGroup:setModle(value)
    self.defaultModle_ = value or TitleBtnGroup.TOUCH_MODLE;
end

function TitleBtnGroup:render()
	self.itemsCfg_ = {}
	if self.cfg_ and type(self.cfg_) == "table" then
		for i=1,#self.cfg_ do
			local v = self.cfg_[i];
			local item = self:addItem_(i, v, self.selectIdx_ == i)
			table.insert(self.itemsCfg_, #self.itemsCfg_+1, item);
		end
	end
	return self;
end

function TitleBtnGroup:addItem_(idx, params, isSelected)
    local contain_ = display.newNode()
        :addTo(self)
	local line_ = display.newSprite("#"..self.lineUpImg_)
        :pos(params.lx or 0, params.ly or 0)
        :addTo(contain_,2);
    if params.isLineHide then
        line_:hide();
    end
    local px, py = params.x or 0, params.y or 0;
    local bg_ = display.newSprite("#"..self.bgUpImg_)
        :pos(px + (params.bgx or 0), py + (params.bgy or 0))
        :addTo(contain_, params.bgIndex or 2);    
    -- 按钮
    local btn_ = cc.ui.UIPushButton.new({normal = params.btnUpImg, pressed = params.btnDownImg}, {scale9 = true})
        :pos(px, py)
        :setButtonLabelOffset(params.offBtnX or 0, params.offBtnY or 0)
        :addTo(contain_, params.btnIndex or 1);
    local lbl_ = ui.newTTFLabel({text = params.lbl or "", color = params.pcolor or cc.c3b(0xC7, 0xE5, 0xFF), size = params.fontSize or 26, align = ui.TEXT_ALIGN_CENTER})
        :pos((params.x or 0) + (params.offBtnX or 0), (params.y or 0) + (params.offBtnY or 0))
        :addTo(contain_, params.lblIndex or 3)
    -- 是否水平翻转
    if params.isFippedX then
        btn_:setScaleX(-1)
    end
    -- 是否垂直翻转
    if params.isFippedY then
        btn_:setScaleY(-1)
    end
    -- 设置按钮大小
    if params.btnDW and params.btnDH then
        btn_:setButtonSize(params.btnDW, params.btnDH)
        local lsz = lbl_:getContentSize();
        if lsz.width > params.btnDW - 10 then
            lbl_:setScale((params.btnDW - 10)/lsz.width)
        else
            lbl_:setScale(1)
        end
        bg_:setScale(params.bgScale or 1);
    end
    -- 
    local items = {bg=bg_, line=line_, btn=btn_, params=params, status=false, lbl=lbl_, contain=contain_}
    local btnReleaseFunc = function() 
        if not self.isCancelSelected_ and items.status then
            return;
        end
        bg_:setSpriteFrame(display.newSpriteFrame(self.bgUpImg_))
        line_:setSpriteFrame(display.newSpriteFrame(self.lineUpImg_))
        bg_:setScale(params.bgScale or 1);
    end
    local btnClickedFunc = function()
        if not self.isCancelSelected_ and items.status then
            return;
        end

        if params.clickCallback and params.clickCallback(not items.status, items) then
            self:cleanOtherSelected_(items);
            if items.status then
                self:cancelSelected_(items);
                -- 如果isCancelSelected为true表示可以取消选中状态，没选中self.selectIdx的状态为-1
                if self.isCancelSelected_ and self.selectIdx_ == idx then
                    self.selectIdx_ = -1;
                end
            else
                bg_:setSpriteFrame(display.newSpriteFrame(self.bgDownImg_))
                line_:setSpriteFrame(display.newSpriteFrame(self.lineDownImg_))
                lbl_:setTextColor(params.ncolor or cc.c3b(0x27, 0x90, 0xd5))
                btn_:setButtonImage("normal", params.btnDownImg, true);
                items.status = true;
                --                  
                self.selectIdx_ = idx;
                bg_:setScale(params.bgScale or 1);
            end
        end
    end
    local btnPressed = function()
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON);
        bg_:setSpriteFrame(display.newSpriteFrame(self.bgDownImg_))
        line_:setSpriteFrame(display.newSpriteFrame(self.lineDownImg_))
        bg_:setScale(params.bgScale or 1);
    end

    items.btnReleaseFunc = btnReleaseFunc;
    items.btnClickedFunc = btnClickedFunc;
    items.btnPressed = btnPressed;

    if self.defaultModle_ == TitleBtnGroup.BTN_MODLE then
        btn_:onButtonClicked(btnClickedFunc);
        btn_:onButtonRelease(btnReleaseFunc);
        btn_:onButtonPressed(btnPressed)
    else
        btn_:onButtonClicked(btnClickedFunc);
        btn_:onButtonRelease(btnReleaseFunc);
        btn_:onButtonPressed(btnPressed)

        contain_:setTouchEnabled(true)
        contain_:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(evt)
            local name, x, y, prevX, prevY = evt.name, evt.x, evt.y, evt.prevX, evt.prevY
            if evt.name == 'began' then
            elseif name == "moved" then

            elseif name == "ended"  or name == "cancelled" then 
                if bm.containPointByNode(x, y, bg_, line_, lbl_) then -- 个人档
                    btnClickedFunc();
                end
            end
            return true;
        end)
    end    
    
    return items;
end
-- 
function TitleBtnGroup:cleanOtherSelected_(value)
	for i=1,#self.itemsCfg_ do
		local item = self.itemsCfg_[i];
		if item ~= value and item.status then
            self:cancelSelected_(item);
		end
	end
end

function TitleBtnGroup:cancelSelected_(item)
	item.status = false;
	item.bg:setSpriteFrame(display.newSpriteFrame(self.bgUpImg_))
    item.line:setSpriteFrame(display.newSpriteFrame(self.lineUpImg_))
    item.lbl:setTextColor(item.params.pcolor or cc.c3b(0xC7, 0xE5, 0xFF))
    item.btn:setButtonImage("normal", item.params.btnUpImg, true);
    if self.cancelSelectedCallback_ then
    	self.cancelSelectedCallback_(self.selectIdx_);
    end
end

function TitleBtnGroup:selectIndex(index)
	if index > 0 and index <= #self.itemsCfg_ then
		-- self.itemsCfg_[index].btn:dispatchEvent({name = "CLICKED_EVENT", nil})
        self.itemsCfg_[index].btnClickedFunc();
		self.selectIdx_ = index;
	end
end

function TitleBtnGroup:cleanup()

end

return TitleBtnGroup;