--
-- Author: Johnny Lee
-- Date: 2014-07-03 16:46:02
--

local EventObject = class("EventObject")

function EventObject:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
end

return EventObject