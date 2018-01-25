-- 框架代码
require("framework.init")

-- 兼容lua string.format 对boolean不支持, 而luajit支持boolean
do
  local strformat = string.format
  function string.format(format, ...)
    local args = {...}
    local match_no = 1
    for pos, type in string.gmatch(format, "()%%.-(%a)") do
      if type == 's' then
        args[match_no] = tostring(args[match_no])
      end
      match_no = match_no + 1
    end
    return strformat(format,
      unpack(args,1,select('#',...)))
  end
end

local CURRENT_MODULE_NAME = ...

local bm         = bm or {}
_G.bm            = bm
bm.PACKAGE_NAME  = string.sub(CURRENT_MODULE_NAME, 1, -6)
bm.Logger        = import(".util.Logger")
bm.HttpService   = import(".http.HttpService")
bm.ImageLoader   = import(".http.ImageLoader")
bm.SocketService = import(".socket.SocketService")
bm.EventCenter   = import(".event.EventCenter")
bm.DataProxy     = import(".proxy.DataProxy")
bm.LangUtil      = import(".lang.LangUtil")
bm.TouchHelper   = import(".util.TouchHelper")
bm.ObjectPool    = import(".util.ObjectPool")
bm.SchedulerPool = import(".util.SchedulerPool")
bm.ui            = import(".ui.init")
bm.TimeUtil      = import(".util.TimeUtil")
bm.DisplayUtil   = import("boomegg.util.DisplayUtil")

import(".util.functions").exportMethods(bm)

return bm
