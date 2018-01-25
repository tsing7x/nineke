--
-- Author: hlf
-- Date: 2015-11-17 15:42:03
-- 保存游戏日志到日志NINK_LOG.txt文本文件中
-- 从手机上导出游戏日志：adb pull /sdcard/boyaa/NINK_LOG.txt

if CF_DEBUG > 0 then
	-- 
	if device.platform == "windows" then
	    LOG_FILE = io.open("NINK_LOG.txt", "w+")
	else
	    -- LOG_FILE = io.open("/sdcard/boyaa/NINK_LOG.txt", "w+")
	    LOG_FILE = io.open(device.writablePath .. "/" .. "NINK_LOG.txt", "w+")
	end
	-- 
	GAME_PRINT = print;
	-- 
	local WRITE_LOG = function(str)
	    LOG_FILE:write(str)
	    LOG_FILE:write("\r")
	end

	print = function(...)
		local numArgs = select("#", ...)
		if numArgs >= 1 then
			local output = ""
	        for i = 1, numArgs do
	            local value = select(i, ...)
	            output = output .. tostring(value) .. " "
	        end

			LOG_FILE:write(output)
	    	LOG_FILE:write("\r\n")
	    end

	    GAME_PRINT(...)
	end

	return WRITE_LOG;
else
	return nil;
end
