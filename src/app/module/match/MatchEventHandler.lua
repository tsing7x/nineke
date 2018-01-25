--
-- Author: Jonah0608@gmail.com
-- Date: 2015-07-02 14:55:44
--
local MatchEventHandler = class("DailyTasksEventHandler")

MatchEventHandler.REGISTER_STATE_CHANGED = "REGISTER_STATE_CHANGED"
MatchEventHandler.ONLINE_COUNT_CHANGED = "ONLINE_COUNT_CHANGED"

MatchEventHandler.ROOM_PACKET_RECEIVED = "ROOM_PACKET_RECEIVED"

MatchEventHandler.MATCH_AWARD = "MATCH_AWARD"

return MatchEventHandler
