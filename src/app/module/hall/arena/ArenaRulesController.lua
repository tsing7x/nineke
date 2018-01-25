--
-- Author: XT
-- Date: 2015-07-30 09:12:04
-- 比赛场 规则说明
local ArenaRulesController = class("ArenaRulesController");

function ArenaRulesController:ctor( view )
	self.view_ = view;
end

function ArenaRulesController:getListData()
	local data = bm.LangUtil.getText("MATCH", "RULES_LIST");
	local list = self.view_:getListView();
    list:setData(data)

    local len = #data;
    for i=1,len do
    	local item = list:getListItem(i)
    	if item then
    		nk.schedulerPool:delayCall(function()
    			item:foldContent();
    		end, 0.2*(i -1))
    	end
    end
end

return ArenaRulesController;