--
-- 代理连接速度测试上报
-- Author: tony
-- Date: 2014-10-20 16:40:09
--

local ProxySpeedTest = class("ProxySpeedTest")
local ProxySelector = import("app.net.ProxySelector")
local logger = bm.Logger.new("ProxySpeedTest")

ProxySpeedTest.RUNNING_TEST = {}

function ProxySpeedTest:ctor(proxyList)
    self.proxyList_ = proxyList
    self.uid_ = nk.userData.uid
    if proxyList and #proxyList > 0 then
        --加入类变量，避免被回收
        table.insert(ProxySpeedTest.RUNNING_TEST, self)
        self:start()
    end
end

function ProxySpeedTest:start()
    self.total_ = #self.proxyList_
    self.index_ = 1
    self.succ_ = {}
    self.fail_ = {}

    logger:debug("start speed testing, proxy num -> ", self.total_)
    if self.total_ > 0 then
        self:doSpeedTest()
    else
        table.removebyvalue(ProxySpeedTest.RUNNING_TEST, self)
    end
end

function ProxySpeedTest:doSpeedTest()
    local currentProxy = self.proxyList_[self.index_]
    if currentProxy then
        local ip, port = currentProxy.ip, currentProxy.port
        logger:debugf("testing [%s] -> %s:%s", self.index_, ip, port)
        self.socket_ = cc.net.SocketTCP.new(ip, port, false)
        self.socket_:addEventListener(cc.net.SocketTCP.EVENT_CONNECTED, handler(self, self.onConnected))
        self.socket_:addEventListener(cc.net.SocketTCP.EVENT_CONNECT_FAILURE, handler(self, self.onConnectFailure))

        self.socketStartTime_ = bm.getTime()
        self.socket_:setName("ProxySpeedTest["..self.index_.."]"):connect()
    end
end

function ProxySpeedTest:onConnected(evt)
    logger:debug(evt.name)
    local currentProxy = self.proxyList_[self.index_]
    table.insert(self.succ_, {ip=currentProxy.ip, port=currentProxy.port, time=math.round((bm.getTime() - self.socketStartTime_) * 1000)})
    self:nextTest()
end

function ProxySpeedTest:onConnectFailure(evt)
    logger:debug(evt.name)
    local currentProxy = self.proxyList_[self.index_]
    table.insert(self.fail_, {ip=currentProxy.ip, port=currentProxy.port})
    self:nextTest()
end

function ProxySpeedTest:nextTest()
    if self.socket_ then
        self.socket_:removeAllEventListeners()
        self.socket_:disconnect()
    end
    local userData = nk.userData
    if userData and userData.uid == self.uid_ then
        self.index_ = self.index_ + 1
        if self.index_ <= self.total_ then
            self:doSpeedTest()
        else
            logger:debug("end speed testing")
            bm.HttpService.POST({
                mod="mobileTj",
                act="proxyTj",
                uid=self.uid_,
                succ= json.encode(self.succ_),
                fail=json.encode(self.fail_),
            })
            --根据测速结果重排
            --self:sortProxySelector()
            table.removebyvalue(ProxySpeedTest.RUNNING_TEST, self)
        end
    else
        table.removebyvalue(ProxySpeedTest.RUNNING_TEST, self)
    end
end

function ProxySpeedTest:sortProxySelector()
    local succ = self.succ_
    local fail = self.fail_
    local function getConnTime(p)
        for i, v in ipairs(succ) do
            if tostring(v.ip) == tostring(p.ip) and tostring(v.port) == tostring(p.port) then
                return v.time
            end
        end
        for i, v in ipairs(fail) do
            if tostring(v.ip) == tostring(p.ip) and tostring(v.port) == tostring(p.port) then
                return 300000
            end
        end
        return 200000
    end

    table.sort(ProxySelector.getProxyList(), function(p1, p2)
        return getConnTime(p1) < getConnTime(p2)
    end)

end

return ProxySpeedTest