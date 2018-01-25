--
-- Author: Devin
-- Date: 2014-09-15 14:21:30
--
local function removeModule(moduleName)
    package.loaded[moduleName] = nil
end

--已加载模块清理
removeModule("config")


--应用本地更新
if BM_UPDATE then
    print("version", BM_UPDATE.VERSION)
    print(dump(BM_UPDATE.STAGE_FILE_LIST))
    if BM_UPDATE.STAGE_FILE_LIST and #BM_UPDATE.STAGE_FILE_LIST > 0 then
        for i = 1, #BM_UPDATE.STAGE_FILE_LIST do
            local fileinfo = BM_UPDATE.STAGE_FILE_LIST[i]
            if fileinfo then
                if fileinfo.act and string.lower(fileinfo.act) == "framework" then
                    print("load framework ", fileinfo.name)
                    print(cc.LuaLoadChunksFromZIP(fileinfo.name))
                end
            end
        end
        for i = 1, #BM_UPDATE.STAGE_FILE_LIST do
            local fileinfo = BM_UPDATE.STAGE_FILE_LIST[i]
            if fileinfo then
                if fileinfo.act and string.lower(fileinfo.act) == "load" then
                    print("load zip ", fileinfo.name)
                    print(cc.LuaLoadChunksFromZIP(fileinfo.name))
                end
            end
        end
    end
end

require("app.NineKeApp").new():run()
