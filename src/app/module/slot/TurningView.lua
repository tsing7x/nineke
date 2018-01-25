--
-- Author: viking@boomegg.com
-- Date: 2014-11-26 18:56:06
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--
local TurningView = class("TurningView", function()
    return display.newNode()
end)

local TurningElement = import(".TurningElement")

function TurningView:ctor()
    self.view1 = TurningElement.new():addTo(self)
    self.view2 = TurningElement.new():addTo(self):hide()
end

function TurningView:start(element, callback)
    self.view1:start(true, function()
        self.view2:start(false, function()
            self.view1:turnToWhich(element, callback)
        end)
    end)
end

function TurningView:stop()
    self.view1:stop()
    self.view2:stop()
end

return TurningView