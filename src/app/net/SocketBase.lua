--
-- Author: tony
-- Date: 2014-07-07 18:05:52
--
local CURRENT_MODULE_NAME = ...

local ProxySelector = import(".ProxySelector")

local SocketBase    = class("SocketBase")

SocketBase.EVT_PACKET_RECEIVED = "SocketBase.EVT_PACKET_RECEIVED"
SocketBase.EVT_CONNECTED       = "SocketBase.EVT_CONNECTED"
SocketBase.EVT_CONNECT_FAIL    = "SocketBase.EVT_CONNECT_FAIL"
SocketBase.EVT_CLOSED          = "SocketBase.EVT_CLOSED"
SocketBase.EVT_ERROR           = "SocketBase.EVT_ERROR"

function SocketBase:ctor(name, protocol)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self.PROTOCOL = protocol

    self.socket_ = bm.SocketService.new(name, protocol)
    self.socket_:addEventListener(bm.SocketService.EVT_PACKET_RECEIVED, handler(self, self.onPacketReceived))
    self.socket_:addEventListener(bm.SocketService.EVT_CONN_SUCCESS, handler(self, self.onConnected))
    self.socket_:addEventListener(bm.SocketService.EVT_CONN_FAIL, handler(self, self.onConnectFailure))
    self.socket_:addEventListener(bm.SocketService.EVT_ERROR, handler(self, self.onError))
    self.socket_:addEventListener(bm.SocketService.EVT_CLOSED, handler(self, self.onClosed))
    self.socket_:addEventListener(bm.SocketService.EVT_CLOSE, handler(self, self.onClose))

    self.name_           = name
    self.shouldConnect_  = false
    self.isConnected_    = false
    self.isConnecting_   = false
    self.isProxy_        = false
    self.isPaused_       = false
    self.delayPackCache_ = nil
    self.retryLimit_     = 3

    self.heartBeatSchedulerPool_ = bm.SchedulerPool.new()

    self.logger_ = bm.Logger.new(self.name_)
end


function SocketBase:isConnected()
    return self.isConnected_
end

function SocketBase:connect(ip, port, retryConnectWhenFailure)
    self.shouldConnect_ = true
    self.ip_ = ip
    self.port_ = port
    if self:isConnected() then
        self.logger_:debug("isConnected true")
    elseif self.isConnecting_ then
        self.logger_:debug("isConnecting true")
    else
        self.isConnecting_ = true

        if ProxySelector.hasProxy() then
            self.isProxy_ = true
            self.proxySelector_ = ProxySelector.new()
            self.proxy_ = self.proxySelector_:getCurrentProxy()
            local proxyNum = self.proxySelector_:leftProxyNum()
            if proxyNum == 1 then
                self.proxyRetryLimit_ = 3
            elseif proxyNum <= 3 then
                self.proxyRetryLimit_ = 2
            else
                self.proxyRetryLimit_ = 1
            end
            self.retryLimit_ = self.proxyRetryLimit_
        else
            self.isProxy_ = false
            self.proxySelector_ = nil
            self.proxy_ = nil
            self.retryLimit_ = 3
        end
        self.retryConnectWhenFailure_ = retryConnectWhenFailure
        if self.isProxy_ then
            if self.proxy_ then
                self.logger_:debugf("connect to proxy %s:%s", self.proxy_.ip, self.proxy_.port)
                self.socket_:connect(self.proxy_.ip, self.proxy_.port, false)
            else
                self:onAfterConnectFailure()
                self:dispatchEvent({name=SocketBase.EVT_CONNECT_FAIL})
            end
        else
            self.logger_:debugf("direct connect to %s:%s", self.ip_, self.port_)
            self.socket_:connect(self.ip_, self.port_, retryConnectWhenFailure)
        end
    end
end

function SocketBase:connectDirect(ip, port, retryConnectWhenFailure)
    self.shouldConnect_ = true
    self.ip_ = ip
    self.port_ = port
    if self:isConnected() then
        self.logger_:debug("isConnected true")
    elseif self.isConnecting_ then
        self.logger_:debug("isConnecting true")
    else
        self.isConnecting_ = true
        self.isProxy_ = false
        self.proxySelector_ = nil
        self.proxy_ = nil
        self.retryLimit_ = 3
        self.retryConnectWhenFailure_ = retryConnectWhenFailure
        self.logger_:debugf("direct connect to %s:%s", self.ip_, self.port_)
        self.socket_:connect(self.ip_, self.port_, retryConnectWhenFailure)
    end
end

function SocketBase:disconnect(noEvent)
    self.shouldConnect_ = false
    self.isConnecting_ = false
    self.isConnected_ = false
    self.ip_ = nil
    self.port_ = nil
    self:unscheduleHeartBeat()
    self.socket_:disconnect(noEvent)
    -- if noEvent then
    --     self.logger_:error("noEvent true")
    -- end
end

function SocketBase:pause()
    self.isPaused_ = true
    self.logger_:debug("paused event dispatching")
end

function SocketBase:resume()
    self.isPaused_ = false
    self.logger_:debug("resume event dispatching")
    if self.delayPackCache_ and #self.delayPackCache_ > 0 then
        for i, v in ipairs(self.delayPackCache_) do
            self:dispatchEvent({name=SocketBase.EVT_PACKET_RECEIVED, packet=v})
        end
        self.delayPackCache_ = nil
    end
end

function SocketBase:createPacketBuilder(cmd)
    return self.socket_:createPacketBuilder(cmd)
end

function SocketBase:send(pack)
    if self:isConnected() then
        self.socket_:send(pack)
    else
        self.logger_:error("sending packet when socket is not connected")
    end
end

function SocketBase:onConnected(evt)
    --print("SocketBase connected")
    self.isConnected_ = true
    self.isConnecting_ = false
    self.heartBeatTimeoutCount_ = 0
    if self.isProxy_ then
        local buf = cc.utils.ByteArray.new(cc.utils.ByteArray.ENDIAN_BIG)
        buf:writeStringBytes("ES")
        buf:writeUShort(0x6001)
        buf:writeUShort(1)
        buf:writeUShort(0)
        local ip = tostring(self.ip_) or ""
        buf:writeUInt(#ip + 1)
        buf:writeStringBytes(ip)
        buf:writeByte(0)
        buf:writeUInt(self.port_ or 0)
        buf:setPos(7)
        buf:writeUShort(buf:getLen() - 8)
        self.logger_:debugf("BUILD PACKET ==> %x(%s) [%s]", 0x6001, buf:getLen(), cc.utils.ByteArray.toString(buf, 16))
        self:send(buf)
    end
    self:onAfterConnected()
    self:dispatchEvent({name=SocketBase.EVT_CONNECTED})
end

function SocketBase:scheduleHeartBeat(command, interval, timeout)
    self.heartBeatCommand_ = command
    self.heartBeatTimeout_ = timeout
    self.heartBeatTimeoutCount_ = 0
    self.heartBeatSchedulerPool_:clearAll()
    self.heartBeatSchedulerId_ = self.heartBeatSchedulerPool_:loopCall(handler(self, self.onHeartBeat_), interval)
end

function SocketBase:unscheduleHeartBeat()
    self.heartBeatTimeoutCount_ = 0
    --清理所有定时器，会把onHeartBeatTimeout_定时器一起干掉，断网的时候不会执行onHeartBeatTimeout_,所以只清理心跳包定时器
    -- self.heartBeatSchedulerPool_:clearAll()
    self.heartBeatSchedulerPool_:clear(self.heartBeatSchedulerId_)
end

function SocketBase:buildHeartBeatPack()
    self.logger_:debug("not implemented method buildHeartBeatPack")
    return nil
end

function SocketBase:onHeartBeatTimeout(timeoutCount)
    self.logger_:debug("not implemented method onHeartBeatTimeout")
end

function SocketBase:onHeartBeatReceived(delaySeconds)
    self.logger_:debug("not implemented method onHeartBeatReceived")
end

function SocketBase:onHeartBeat_()
    local heartBeatPack = self:buildHeartBeatPack()
    if heartBeatPack then
        self.heartBeatPackSendTime_ = bm.getTime()
        self:send(heartBeatPack)
        self.heartBeatTimeoutId_ = self.heartBeatSchedulerPool_:delayCall(handler(self, self.onHeartBeatTimeout_), self.heartBeatTimeout_)
        self.logger_:debug("send heart beat packet")
    end
    return true
end

function SocketBase:onHeartBeatTimeout_()
    self.heartBeatTimeoutId_ = nil
    self.heartBeatTimeoutCount_ = (self.heartBeatTimeoutCount_ or 0) + 1
    self:onHeartBeatTimeout(self.heartBeatTimeoutCount_)
    self.logger_:debug("heart beat timeout", self.heartBeatTimeoutCount_)
end

function SocketBase:onHeartBeatReceived_()
    local delaySeconds = bm.getTime() - self.heartBeatPackSendTime_
    if self.heartBeatTimeoutId_ then
        self.heartBeatSchedulerPool_:clear(self.heartBeatTimeoutId_)
        self.heartBeatTimeoutId_ = nil
        self.heartBeatTimeoutCount_ = 0
        self:onHeartBeatReceived(delaySeconds)
        self.logger_:debug("heart beat received", delaySeconds)
    else
        self.logger_:debug("timeout heart beat received", delaySeconds)
    end
end

function SocketBase:onConnectFailure(evt)
    self.isConnected_ = false
    self.logger_:debug("connect failure ...")

    local report = self:getReportCurrentProxyFailFunction("connect fail")
    if not self:reconnect_() then
        report()
        self:onAfterConnectFailure()
        self:dispatchEvent({name=SocketBase.EVT_CONNECT_FAIL})
    end
end

function SocketBase:onError(evt)
    self.isConnected_ = false
    self.socket_:disconnect(true)
    self.logger_:debug("data error ...")
    local report = self:getReportCurrentProxyFailFunction("connect error")
    if not self:reconnect_() then
        report()
        self:onAfterDataError()
        self:dispatchEvent({name=SocketBase.EVT_ERROR})
    end
end

function SocketBase:onClosed(evt)
    self.isConnected_ = false
    self:unscheduleHeartBeat()
    if self.shouldConnect_ then
        if not self:reconnect_() then
            self:onAfterConnectFailure()
            self:dispatchEvent({name=SocketBase.EVT_CONNECT_FAIL})
            self.logger_:debug("closed and reconnect fail")
        else
            self.logger_:debug("closed and reconnecting")
        end
    else
        self.logger_:debug("closed and do not reconnect")
        self:dispatchEvent({name=SocketBase.EVT_CLOSED})
    end
end

function SocketBase:onClose(evt)
    self:unscheduleHeartBeat()
end

function SocketBase:reconnect_()
    self.socket_:disconnect(true)
    self.retryLimit_ = self.retryLimit_ - 1
    local isRetrying = true
    if self.isProxy_ then
        if self.retryLimit_ > 0 then
            self.socket_:connect(self.proxy_.ip, self.proxy_.port, false)
        else
            if self.proxySelector_:hasMoreProxy() then
                self.proxy_ = self.proxySelector_:getNextProxy()
                self.retryLimit_ = self.proxyRetryLimit_
                self.socket_:connect(self.proxy_.ip, self.proxy_.port, false)
            elseif self.retryConnectWhenFailure_ then
                self.proxySelector_ = ProxySelector.new()
                self.proxy_ = self.proxySelector_:getCurrentProxy()
                self.retryLimit_ = self.proxyRetryLimit_
                self.socket_:connect(self.proxy_.ip, self.proxy_.port, false)
            else
                isRetrying = false
                self.isConnecting_ = false
            end
        end
    else
        if self.retryLimit_ > 0 or self.retryConnectWhenFailure_ then
            self.socket_:connect(self.ip_, self.port_, self.retryConnectWhenFailure_)
        else
            isRetrying = false
            self.isConnecting_ = false
        end
    end
    return isRetrying
end

function SocketBase:onPacketReceived(evt)
    local pack = evt.data
    if pack.cmd == self.heartBeatCommand_ then
        if self.heartBeatTimeoutId_ then
            self:onHeartBeatReceived_()
        end
    else
        self:onProcessPacket(pack)
        if self.isPaused_ then
            if not self.delayPackCache_ then
                self.delayPackCache_ = {}
            end
            self.delayPackCache_[#self.delayPackCache_ + 1] = pack
            self.logger_:debugf("%s paused cmd:%x", self.name_, pack.cmd)
        else
            self.logger_:debugf("%s dispatching cmd:%x", self.name_, pack.cmd)
            local ret, errMsg = pcall(function() self:dispatchEvent({name=SocketBase.EVT_PACKET_RECEIVED, packet=evt.data}) end)
            if errMsg then
                self.logger_:errorf("%s dispatching cmd:%x error %s", self.name_, pack.cmd, errMsg)
            end
            --self:dispatchEvent({name=SocketBase.EVT_PACKET_RECEIVED, packet=evt.data})
        end
    end
end

function SocketBase:onProcessPacket(pack)
    self.logger_:debug("not implemented method onProcessPacket")
end

function SocketBase:onAfterConnected()
    self.logger_:debug("not implemented method onAfterConnected")
end

function SocketBase:onAfterConnectFailure()
    self.logger_:debug("not implemented method onAfterConnectFailure")
end

function SocketBase:onAfterDataError()
    self:onAfterConnectFailure()
    self.logger_:debug("not implemented method onAfterDataError")
end

function SocketBase:getReportCurrentProxyFailFunction(pReason)
    if self.isProxy_ and self.proxy_ then
        local proxyIp, proxyPort = self.proxy_.ip, self.proxy_.port
        local param = {
                mod="mobileTj",
                act="proxyFailLog",
                ip=proxyIp,
                port=proxyPort,
                reason=pReason,
            }
        return function()
            bm.HttpService.POST(param)
            --将当前代理放到最后去
            local list = ProxySelector.getProxyList()
            print("before", dump(list))
            for i, v in ipairs(list) do
                if tostring(v.ip) == tostring(proxyIp) and tostring(v.port) == tostring(proxyPort) then
                    local proxy = table.remove(list, i)
                    table.insert(list, proxy)
                    break
                end
            end
            print("after", dump(list))
        end
    else
        return function() end
    end
end

return SocketBase
