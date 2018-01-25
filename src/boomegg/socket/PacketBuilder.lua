--[[
    封包
]]

local TYPE = import(".PACKET_DATA_TYPE")
local TimeUtil = import("boomegg.util.TimeUtil")

local PacketBuilder = class("PacketBuilder")

function PacketBuilder:ctor(cmd, config, socketName)
    self.cmd_ = cmd    
    self.config_ = config
    self.params_ = {}
    self.logger_ = bm.Logger.new(socketName .. ".PacketBuilder"):enabled(true)
end

function PacketBuilder:setParameter(key, value)
    self.params_[key] = value
    return self
end

function PacketBuilder:setParameters(params)
    table.merge(self.params_, params)
    return self
end

local function writeData(buf, dtype, val, fmt, outFmt)
    if dtype == TYPE.UBYTE then
        if type(val) == "string" and string.len(val) == 1 then
            buf:writeChar(val)
        else
            buf:writeUByte(tonumber(val) or 0)
        end
    elseif dtype == TYPE.BYTE then
        if type(val) == "string" and string.len(val) == 1 then
            buf:writeChar(val)
        else
            local n = tonumber(val)
            if n and n < 0 then
                n = n + 2^8
            end
            buf:writeByte(n or 0)
        end
    elseif dtype == TYPE.INT then
        buf:writeInt(tonumber(val) or 0)
    elseif dtype == TYPE.UINT then
        buf:writeUInt(tonumber(val) or 0)
    elseif dtype == TYPE.SHORT then
        buf:writeShort(tonumber(val) or 0)
    elseif dtype == TYPE.USHORT then
        buf:writeUShort(tonumber(val) or 0)
    elseif dtype == TYPE.LONG then
        val = tonumber(val) or 0
        local low = val % 2^32
        local high = val / 2^32
        buf:writeInt(high)
        buf:writeUInt(low)
    elseif dtype == TYPE.ULONG then
        val = tonumber(val) or 0
        local low = val % 2^32
        local high = val / 2^32
        buf:writeInt(high)
        buf:writeUInt(low)
    elseif dtype == TYPE.STRING then
        val = tostring(val) or ""
        buf:writeUInt(#val + 1)
        buf:writeStringBytes(val)
        buf:writeByte(0)
    elseif dtype == TYPE.ARRAY then
        local len = 0
        if val then
            len = #val
        end
        if outFmt and outFmt.lengthType then
            if outFmt.lengthType == TYPE.UBYTE then
                buf:writeUByte(len)
            elseif outFmt.lengthType == TYPE.BYTE then
                buf:writeByte(len)
            elseif outFmt.lengthType == TYPE.INT then
                buf:writeInt(len)
            elseif outFmt.lengthType == TYPE.UINT then
                buf:writeUInt(len)
            elseif outFmt.lengthType == TYPE.SHORT then
                buf:writeShort(len)
            elseif outFmt.lengthType == TYPE.USHORT then
                buf:writeUShort(len)
            elseif outFmt.lengthType == TYPE.LONG then
                local low = len % 2^32
                local high = len / 2^32
                buf:writeInt(high)
                buf:writeUInt(low)
            elseif outFmt.lengthType == TYPE.ULONG then
                local low = len % 2^32
                local high = len / 2^32
                buf:writeInt(high)
                buf:writeUInt(low)
            end
        else
            buf:writeUByte(len)
        end
        if len > 0 then
            for i1, v1 in ipairs(val) do
                for i2, v2 in ipairs(fmt) do
                    local name = v2.name
                    local dtype = v2.type
                    local fmt = v2.fmt
                    local value
                    if type(v1) == "number" then
                        value = v1
                    else
                        value = v1[name]
                    end
                    writeData(buf, dtype, value, fmt, v2)
                end
            end
        end
    end
end

function PacketBuilder:build()
    local buf = cc.utils.ByteArray.new(cc.utils.ByteArray.ENDIAN_BIG)
    --写包头，包体长度先写0
    buf:writeStringBytes("ES")                    -- ES
    buf:writeUShort(self.cmd_)                    -- 命令字
    -- 版本号
    if self.config_ and self.config_.ver then
        buf:writeUShort(self.config_.ver)
    else
        buf:writeUShort(1)
    end
    buf:writeUShort(0)                            -- 包体长度

    if self.config_ and self.config_.fmt and #self.config_.fmt > 0 then
        -- 写包体
        for i, v in ipairs(self.config_.fmt) do
            local name = v.name
            local dtype = v.type
            local fmt = v.fmt
            local value = self.params_[name]
            writeData(buf, dtype, value, fmt, v)
        end
        --修改包体长度
        buf:setPos(7)
        buf:writeUShort(buf:getLen() - 8)
        buf:setPos(buf:getLen() + 1)
    end
    self.logger_:debugf("BUILD PACKET ==> %x(%s) [%s]", self.cmd_, buf:getLen(), cc.utils.ByteArray.toString(buf, 16))
    self.logger_:debugf("the time is ==>"..TimeUtil:getTimeStampString(os.time(),nil,true))
    return buf
end

return PacketBuilder