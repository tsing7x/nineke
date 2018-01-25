--[[
    解包
]]
local TYPE = import(".PACKET_DATA_TYPE")

local HEAD_LEN = 8     -- 包头长度

local PacketParser = class("PacketParser")

function PacketParser:ctor(protocol, socketName)
    self.config_ = protocol.CONFIG
    self.protocol_ = protocol
    self.logger_ = bm.Logger.new(socketName .. ".PacketParser"):enabled(true)
end

function PacketParser:reset()
    self.buf_ = nil
end

--[[
    校验包头，并返回包体长度与命令字, 校验不通过则都返回-1
]]
local function verifyHeadAndGetBodyLenAndCmd(buf)
    local cmd = -1
    local len = -1

    local pos = buf:getPos()
    buf:setPos(1)

    if buf:readStringBytes(2) == "ES" then
        cmd = buf:readUShort()
        buf:setPos(7)
        len = buf:readUShort()
    end

    buf:setPos(pos)
    return cmd, len
end

function PacketParser:read(buf)
    local ret = {}
    local success = true
    while true do
        if not self.buf_ then
            self.buf_ = cc.utils.ByteArray.new(cc.utils.ByteArray.ENDIAN_BIG)
        else 
            self.buf_:setPos(self.buf_:getLen() + 1)
        end

        local available = buf:getAvailable()
        local buffLen = self.buf_:getLen()
        if available <= 0 then
            break
        else
            local headCompleted = (buffLen >= HEAD_LEN)
            --先收包头
            if not headCompleted then
                if available + buffLen >= HEAD_LEN then
                    --收到完整包头，按包头长度写入缓冲区
                    for i=1, HEAD_LEN - buffLen do
                        self.buf_:writeRawByte(buf:readRawByte())
                    end
                    headCompleted = true
                else
                    --不够完整包头，把全部内容写入缓冲区
                    for i=1, available do
                        self.buf_:writeRawByte(buf:readRawByte())
                    end
                    break
                end
            end
            if headCompleted then
                --包头已经完整，取包体长度并校验包头
                local command, bodyLen = verifyHeadAndGetBodyLenAndCmd(self.buf_)
                self.logger_:debugf("command %x bodylen %d", command, bodyLen)

                if bodyLen == 0 then
                    --无包体，直接返回一个只有cmd字段的table，并重置缓冲区
                    ret[#ret + 1] = { cmd = command }
                    self:reset()
                elseif bodyLen > 0 then
                    --有包体
                    available = buf:getAvailable()
                    buffLen = self.buf_:getLen()
                    if available <= 0 then
                        break
                    elseif available + buffLen >= HEAD_LEN + bodyLen then
                        -- 收到完整包，向缓冲区补齐当前包剩余字节
                        for i=1, HEAD_LEN + bodyLen - buffLen do
                            self.buf_:writeRawByte(buf:readRawByte())
                        end
                        -- 开始解析
                        local packet = self:parsePacket_(self.buf_)
                        if packet then
                            ret[#ret + 1] = packet
                        end
                        --重置缓冲区
                        self:reset()
                    else
                        --不够包体长度，全部内容写入缓冲区
                        for i=1, available do
                            self.buf_:writeRawByte(buf:readRawByte())
                        end
                        break
                    end
                else
                    -- 包头校验失败
                    return false, "PKG HEAD VERIFY ERROR, " .. cc.utils.ByteArray.toString(self.buf_, 16)
                end
            end
        end
    end
    return true, ret
end

function PacketParser:readData_(ctx, buf, dtype, thisFmt)
    local ret
    if buf:getAvailable() <= 0 and thisFmt.optional == true then
        return nil
    end
    if dtype == TYPE.UBYTE then
        ret = buf:readUByte()
        if ret < 0 then
            ret = ret + 2^8
        end
    elseif dtype == TYPE.BYTE then
        ret = buf:readByte()
        if ret > 2^7 -1 then
            ret = ret - 2^8
        end
    elseif dtype == TYPE.INT then
        ret = buf:readInt()
    elseif dtype == TYPE.UINT then
        ret = buf:readUInt()
    elseif dtype == TYPE.SHORT then
        ret = buf:readShort()
    elseif dtype == TYPE.USHORT then
        ret = buf:readUShort()
    elseif dtype == TYPE.LONG then
        local high = buf:readInt()
        local low = buf:readUInt()
        ret = high * 2^32 + low
    elseif dtype == TYPE.ULONG then
        local high = buf:readInt()
        local low = buf:readUInt()
        ret = high * 2^32 + low
    elseif dtype == TYPE.STRING then
        local len = buf:readUInt()
        -- 防止server出尔反尔，个别协议中出现字符串不以\0结尾的情况，这里做个判断
        local pos = buf:getPos()
        buf:setPos(pos + len -1)
        local lastByte = buf:readByte()
        buf:setPos(pos)

        if lastByte == 0 then
            ret = buf:readStringBytes(len - 1)
            buf:readByte() -- 消费掉最后一个字节
        else
            self.logger_:error("#################################### NOT END WITH 0")
            ret = buf:readStringBytes(len)
        end
    elseif dtype == TYPE.ARRAY then
        ret = {}
        local contentFmt = thisFmt.fmt
        if not thisFmt.fixedLength then
            --配置文件中未指定长度，从包体中得到
            if thisFmt.lengthType then
                -- 配置文件中指定了长度字段的类型
                if thisFmt.lengthType == TYPE.UBYTE then
                    len = buf:readUByte()
                    self.logger_:debug("read ubyte length")
                elseif thisFmt.lengthType == TYPE.BYTE then
                    self.logger_:debug("read byte length")
                    len = buf:readByte()
                elseif thisFmt.lengthType == TYPE.SHORT then
                    self.logger_:debug("read short length")
                    len = buf:readShort()
                elseif thisFmt.lengthType == TYPE.USHORT then
                    self.logger_:debug("read ushort length")
                    len = buf:readUShort()
                elseif thisFmt.lengthType == TYPE.INT then
                    self.logger_:debug("read int length")
                    len = buf:readInt()
                elseif thisFmt.lengthType == TYPE.UINT then
                    self.logger_:debug("read uint length")
                    len = buf:readUInt()
                elseif thisFmt.lengthType == TYPE.LONG then
                    self.logger_:debug("read long length")
                    local high = buf:readInt()
                    local low = buf:readUInt()
                    len = high * 2^32 + low
                elseif thisFmt.lengthType == TYPE.ULONG then
                    self.logger_:debug("read ulong length")
                    local high = buf:readInt()
                    local low = buf:readUInt()
                    len = high * 2^32 + low
                end
            else
                -- 未指定长度字段类型，默认按照无符号byte类型读
                len = buf:readUByte()
            end
        else
            -- 配置文件中直接指定了长度
            len = thisFmt.fixedLength
        end
        if len > 0 then
            if #contentFmt == 1 then
                local dtype = contentFmt[1].type
                for i = 1, len do
                    if contentFmt[1].depends ~= nil then
                        if contentFmt[1].depends(ctx) then
                            ret[#ret + 1] = self:readData_(ctx, buf, dtype, contentFmt[1])
                        end
                    else            
                        ret[#ret + 1] = self:readData_(ctx, buf, dtype, contentFmt[1])
                    end
                end
            elseif #contentFmt == 0 and contentFmt.type then
                for i = 1, len do
                    if contentFmt.depends ~= nil then
                        if contentFmt.depends(ctx) then
                            ret[#ret + 1] = self:readData_(ctx, buf, contentFmt.type, contentFmt)
                        end
                    else
                        ret[#ret + 1] = self:readData_(ctx, buf, contentFmt.type, contentFmt)
                    end
                end
            else
                for i = 1, len do
                    local ele = {}
                    ret[#ret + 1] = ele
                    for i, v in ipairs(contentFmt) do
                        local name = v.name
                        local dtype = v.type
                        if v and v.depends ~= nil then
                            if v.depends(ctx, ele) then
                                ele[name] = self:readData_(ctx, buf, dtype, v)
                            end
                        else
                            ele[name] = self:readData_(ctx, buf, dtype, v)
                        end
                    end
                end
            end
        end
    end
    return ret
end

function PacketParser:parsePacket_(buf)
    self.logger_:debug("#[PACK_PARSE] len:" .. buf:getLen() .. " [" .. cc.utils.ByteArray.toString(buf, 16) .. "]")
    local ret = {}
    local cmd = buf:setPos(3):readUShort()
    local ver = buf:readUShort()
    local config = self.config_[cmd]
    if config ~= nil then
        local fmt = config.fmt
        if ver ~= 1 then
            fmt = config["fmt" .. ver]
        end
        buf:setPos(HEAD_LEN + 1)
        if type(fmt) == "function" then
            fmt(ret, buf)
        elseif fmt then
            for i, v in ipairs(fmt) do
                local name = v.name
                local dtype = v.type
                local depends = v.depends
                if depends ~= nil then
                    if depends(ret) then
                        local fpos = buf:getPos()
                        -- 容错
                        if fpos>buf:getLen() then
                            ret[name] = nil
                        else
                            ret[name] = self:readData_(ret, buf, dtype, v)
                        end
                        local epos = buf:getPos()

                        if type(ret[name]) == "table" then
                            self.logger_:debugf("[%03d-%03d][%03d]%s=%s", fpos, epos-1, epos - fpos, name, json.encode(ret[name]))
                        else
                            self.logger_:debugf("[%03d-%03d][%03d]%s=%s", fpos, epos-1, epos - fpos, name, ret[name])
                        end
                        buf:setPos(epos)
                    end
                else
                    local fpos = buf:getPos()
                    -- 容错
                    if fpos>buf:getLen() then
                        ret[name] = nil
                    else
                        ret[name] = self:readData_(ret, buf, dtype, v)
                    end
                    local epos = buf:getPos()

                    if type(ret[name]) == "table" then
                        self.logger_:debugf("[%03d-%03d][%03d]%s=%s", fpos, epos-1, epos - fpos, name, json.encode(ret[name]))
                    else
                        self.logger_:debugf("[%03d-%03d][%03d]%s=%s", fpos, epos-1, epos - fpos, name, ret[name])
                    end
                    buf:setPos(epos)
                end
            end
        end
        -- if buf:getLen() ~= buf:getPos() - 1 and DEBUG > 0 then
        --     --print("buf len: " .. buf:getLen() .. " pos:" .. buf:getPos())
        --     error(string.format("PROTOCOL ERROR !!!!! %x bufLen:%s pos:%s [%s]", cmd,buf:getLen(), buf:getPos(), cc.utils.ByteArray.toString(buf, 16)))
        -- end
        ret.cmd = cmd
        return ret
    else
        self.logger_:debugf("========> [NOT_PROCESSED_PKG] ========> %x", cmd)
        return nil
    end
end

return PacketParser