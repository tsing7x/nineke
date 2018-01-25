--
-- Author: Jonah0608@gmail.com
-- Date: 2015-06-30 14:27:23
--
local MatchManager = class("MatchManager")
local logger = bm.Logger.new("MatchManager")
local LoadMatchControl = import("app.module.match.LoadMatchControl")

MatchManager.MATCH_LEVEL_FREE = 11
MatchManager.MATCH_LEVEL_MIDDLE = 21
MatchManager.MATCH_LEVEL_SENIOR = 31

function MatchManager:ctor(model,view)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self.model_ = model
    self.view_ = view
    cc.EventProxy.new(nk.socket.MatchSocket,view)
        :addEventListener(nk.socket.MatchSocket.EVT_PACKET_RECEIVED, handler(self, self.onPacketReceived_))
        :addEventListener(nk.socket.MatchSocket.EVT_CONNECTED, handler(self, self.onConnected_))

    self.packetCache_ = {}

end

function MatchManager:reg(matchLevel)
    local matchid = self.model_.regList and self.model_.regList[matchLevel]
    if matchid~=nil and matchid~=0 and matchid~="" then
        self:cancelReg(matchLevel,matchid)
    else
        local userInfo = {nick = nk.userData.nick,img = nk.userData.s_picture,mtkey = nk.userData.mtkey}
        nk.socket.MatchSocket:sendReg({
                matchlevel = matchLevel,
                userinfo = json.encode(userInfo)
            })
    end
end

function MatchManager:cancelReg(matchLevel,matchId)
    nk.socket.MatchSocket:sendCancelReg({
            matchlevel = matchLevel,
            matchid = matchId
        })

    nk.userData.useTickType_ = nil;
end

function MatchManager:enterRoom(tid)
    nk.socket.MatchSocket:sendEnterRoom({
            
        })
end

function MatchManager:getAllLevelCount()
    local data = nk.match.MatchModel.openMatchIds
    nk.socket.MatchSocket:sendGetOnlineCount(data)
end

function MatchManager:getOnlineCount(matchLevel)
    nk.socket.MatchSocket:sendGetOnlineCount({matchLevel})
end

function MatchManager:onConnected_(evt)
    self.packetCache_ = {}
    self.loginMatchRetryTimes_ = 0
end

function MatchManager:onPacketReceived_(evt)
    self:processPacket_(evt.packet)
end

function MatchManager:processPacket_(pack)
    local cmd = pack.cmd
    local P = nk.socket.MatchSocket.PROTOCOL
    
    if cmd == P.SVR_GET_COUNT then
        self.model_:handleOnlineCount(pack.levels)
    end
end

function MatchManager:onExitMatch()
    if not self.model_:isRegistered() and not self.model_.lastTotalCount_ then
        nk.socket.MatchSocket:disconnect(true)
        self.model_:reset()
    end
end

function MatchManager:dispose()
end

return MatchManager