--
-- Author: HLF(IdaHuang@boyaa.com)
-- Date: 2015-12-14 15:38:59
-- 过期门展示面板 
local MatchTickOverDueItem = import(".MatchTickOverDueItem")
local MatchTickOverduePopup = class("MatchTickOverduePopup", nk.ui.Panel)

MatchTickOverduePopup.WIDTH = 750;
MatchTickOverduePopup.HEIGHT = 476;

function MatchTickOverduePopup:ctor(params)
    self.titleTxt_ = bm.LangUtil.getText("TICKET", "TITLE_DESC")
    if params then
        self.titleTxt_ = params.title or bm.LangUtil.getText("TICKET", "TITLE_DESC");
        self.effectTicketId_ = params.ticketId;
    end

    MatchTickOverduePopup.super.ctor(self, {MatchTickOverduePopup.WIDTH+26, MatchTickOverduePopup.HEIGHT+30})
    self:addBgLight()
	self:initView();

    self.onSynchTickId_ = bm.EventCenter:addEventListener(nk.MatchTickManager.EVENT_SYNCH_TICK, handler(self, self.onRenderList_))
end

function MatchTickOverduePopup:initView()
	local width, height = MatchTickOverduePopup.WIDTH, MatchTickOverduePopup.HEIGHT

	self.mainContainer_ = display.newNode():addTo(self)
    self.mainContainer_:setContentSize(width,height)

    self.mainContainer_:setTouchSwallowEnabled(true)
    local px, py = 0, height*0.5-70;
    self.titleBg_ = display.newScale9Sprite("#modal_texture.png", px, py, cc.size(width-9, 34)):addTo(self.mainContainer_);

    local lblPY = py
    self.tipLbl_ = ui.newTTFLabel({
            text=bm.LangUtil.getText("TICKET", "TIP_LBL1"),
            color=cc.c3b(0xff, 0xc9, 0xfb),
            size=22,
            align=ui.TEXT_ALIGN_CENTER
        })
        :pos(px, py)
        :addTo(self)
    local sz = self.tipLbl_:getContentSize();
    px = -width*0.5 + sz.width*0.5 + 15;
    self.tipLbl_:setPositionX(px)

    px, py = 0, height*0.5 - 30;
    self.titleLbl_ = ui.newTTFLabel({
            text=self.titleTxt_,
            color=cc.c3b(0xfb, 0xd0, 0x0a),
            size=36,
            align=ui.TEXT_ALIGN_CENTER
        })
        :pos(px, py+4)
        :addTo(self)

    -- 列表標題
    py = lblPY - 33;
    px = -width*0.5 + 95;
    self.lbl1_ = ui.newTTFLabel({
            text=bm.LangUtil.getText("TICKET", "TIP_TITLE1"),
            color=cc.c3b(255, 255, 255),
            size=22,
            align=ui.TEXT_ALIGN_CENTER
        })
        :pos(px, py)
        :addTo(self);
    px = -width*0.5 + 290;
    self.lbl2_ = ui.newTTFLabel({
            text=bm.LangUtil.getText("TICKET", "TIP_TITLE2"),
            color=cc.c3b(255, 255, 255),
            size=22,
            align=ui.TEXT_ALIGN_CENTER
        })
        :pos(px, py)
        :addTo(self);
    px = -width*0.5 + 480;
    self.lbl3_ = ui.newTTFLabel({
            text=bm.LangUtil.getText("TICKET", "TIP_TITLE3"),
            color=cc.c3b(255, 255, 255),
            size=22,
            align=ui.TEXT_ALIGN_CENTER
        })
        :pos(px, py)
        :addTo(self);

	self:createList_(px, py);
    self:addCloseBtn()
end

function MatchTickOverduePopup:createList_(px, py)
    local width, height = MatchTickOverduePopup.WIDTH, MatchTickOverduePopup.HEIGHT
	local LIST_WIDTH = width - 10;
	local LIST_HEIGHT = height - 132;
    MatchTickOverDueItem.WIDTH = LIST_WIDTH - 20;
	self.toolList_ = bm.ui.ListView.new(
			{
				viewRect = cc.rect(-width*0.5, -LIST_HEIGHT*0.5, LIST_WIDTH, LIST_HEIGHT),
			},
			MatchTickOverDueItem
		)
		:pos(0, -55)
		:addTo(self.mainContainer_)
    self.toolList_:addEventListener("ITEM_EVENT",handler(self,self.itemSelect_))
    self:updateTouchRect_();

    self:onRenderList_();
end

function MatchTickOverduePopup:onRenderList_()
    local tickList
    if self.effectTicketId_ then
        tickList = nk.MatchTickManager:getOverdueTickList();
        self.toolList_:setData(tickList)
    else
        tickList = nk.MatchTickManager:getOverdueTickList();
        self.toolList_:setData(tickList)
    end

    if self.effectTicketId_ and tickList and #tickList > 0 then
        for i=1,#tickList do

            if tostring(tickList[i].tid) == tostring(self.effectTicketId_) then
                local item = self.toolList_:getListItem(i)
                if item then
                    item:showEffect();
                end

                break;
            end
        end
    end
end

function MatchTickOverduePopup:itemSelect_(evt)
    if self.effectTicketId_ then
        nk.userData.isShowed = true
    end
    
    local itemData = evt.data;
    self:onClose();
    nk.userData.useTickType_ = nk.MatchTickManager.TYPE1;-- 过期门票弹出框使用门票
    nk.MatchTickManager:applyTick(itemData)
end

function MatchTickOverduePopup:updateTouchRect_()
	if self.toolList_ then
        self.toolList_:setScrollContentTouchRect()
    end
end

function MatchTickOverduePopup:show(callback)
    self.callback_ = callback;
    nk.PopupManager:addPopup(self)
    return self
end

function MatchTickOverduePopup:onShowed()
    self:updateTouchRect_();
end

function MatchTickOverduePopup:onClose()
    self:close()
end

function MatchTickOverduePopup:close()
    nk.PopupManager:removePopup(self)
    return self
end

function MatchTickOverduePopup:onCleanup()
    if self.onSynchTickId_ then
        bm.EventCenter:removeEventListener(self.onSynchTickId_);
        self.onSynchTickId_ = nil;
    end
end

function MatchTickOverduePopup:onRemovePopup(func)
    self:onCleanup();
    func()
end

return MatchTickOverduePopup;