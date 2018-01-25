--
-- Author: KevinYu
-- Date: 2017-03-07 15:54:48
--

local FootballQuizRuleView = class("FootballQuizRuleView",function()
    return display.newNode()
end)

function FootballQuizRuleView:ctor(width, height)
	local bg = display.newScale9Sprite("#football_content_frame.png", 0, 0, cc.size(width, height))
		:addTo(self)

	local rules = bm.LangUtil.getText("FOOTBALL","RULE_DESC")
	local str = ""
	for _, v in ipairs(rules) do
		str = str .. v
	end

	local scrollNode = display.newNode()

    ui.newTTFLabel({
    	text = str,
        size = 22, 
        color = cc.c3b(0xdc, 0xdc, 0xff), 
        align = ui.TEXT_ALIGN_LEFT,
        valign = ui.TEXT_VALIGN_TOP,
        dimensions = cc.size(width - 20, 0)
    }):addTo(scrollNode)

    local w, h = width - 10, height - 10
	local rect = cc.rect(-w/2, -h/2, w, h)
    bm.ui.ScrollView.new({
        viewRect      = rect,
        scrollContent = scrollNode,
        direction     = bm.ui.ScrollView.DIRECTION_VERTICAL,
    })
    :pos(width/2, height/2)
    :addTo(bg)

end

return FootballQuizRuleView