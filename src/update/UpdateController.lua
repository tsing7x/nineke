--
-- module update.UpdateController
-- Date: 2014-11-03 15:08:05
--
require("framework.init")

local TextureLoader = import("boomegg.ui.TextureLoader")
local upd = require("update.init")

local UpdateScene = require("update.UpdateScene")
local UpdateView = require("update.UpdateView")
local Func = require("update.functions")

local UpdateController = class("UpdateController")

function UpdateController:ctor()
    --设置资源文件搜索路径
    cc.FileUtils:getInstance():addSearchPath(device.writablePath .. "upd/res/")
    cc.FileUtils:getInstance():addSearchPath("res/")

    self.isSilented_ = false  -- 是否有静默更新
    self:initUpdate()

    self.scene_ = UpdateScene.new(self)
    self.view_ = self.scene_:getUpdateView()
    display.replaceScene(self.scene_)
end


function UpdateController:initUpdate()
    print("initUpdate..")

    --创建目录
    upd.mkdir(upd.conf.UPDATE_DIR)
    upd.mkdir(upd.conf.UPDATE_RES_DIR)
    upd.mkdir(upd.conf.UPDATE_RES_TMP_DIR)

    --读取现有的版本文件
    if upd.conf.ENABLED and upd.isFileExist(upd.conf.UPDATE_LIST_FILE) then
        self.fileList_ = dofile(upd.conf.UPDATE_LIST_FILE)
    end
    self.fileList_ = self.fileList_ or {
        ver = upd.conf.CLIENT_VERSION,
        stage = {},
        remove = {},
    }
    -- -- PC测试
    -- local testInfo = {
    --     size = 29,
    --     silent = 1,
    --     act = "load",
    --     name = "update.zip",
    --     code = "e229d4883cfdd712e18c00c4739c2dff",
    -- }
    -- table.insert(self.fileList_.stage,testInfo)

    print("fileList_:" .. json.encode(self.fileList_))

    --本地资源文件检查标志
    local fileCheckOK = true
    print("checking local files ..")
    self:checkResources(self.fileList_, function(fileinfo, name)
            if name ~= fileinfo.name then
                if string.find(fileinfo.name, "/") then
                    local arr = string.split(fileinfo.name, "/")
                    arr[#arr] = nil
                    upd.mkdir(upd.conf.UPDATE_RES_DIR .. table.concat(arr, "/") .. "/")
                end
                local oldfile = upd.conf.UPDATE_RES_DIR .. name
                local newfile = upd.conf.UPDATE_RES_DIR .. fileinfo.name
                print("rename " .. oldfile .. " => " .. newfile)
                if upd.isFileExist(newfile) then
                    os.remove(newfile)
                end
                os.rename(oldfile, newfile)
            end
            fileinfo.fileCheckOK = true
        end,
        function(file)
            print("remove => " .. file)
            os.remove(file)
        end)
    for k, v in pairs(self.fileList_.stage) do
        if not v.fileCheckOK then
            fileCheckOK = false
            print("missing file => " .. v.name)
        end
    end

    --本地资源校验不通过，全部干掉重来
    if not fileCheckOK then
        print("FILE CHECK FAILED!!!")
        upd.rmdir(upd.conf.UPDATE_DIR)
        upd.mkdir(upd.conf.UPDATE_DIR)
        upd.mkdir(upd.conf.UPDATE_RES_DIR)
        upd.mkdir(upd.conf.UPDATE_RES_TMP_DIR)
        self.fileList_ = {
            ver = upd.conf.CLIENT_VERSION,
            stage = {},
            remove = {},
        }
    else
        print("local files check ok.")
    end
end

function UpdateController:checkResources(filelist, validMd5Handler, notFoundHandler)
    --检查本地upd目录有没有不需要的文件
    local interateDir = nil
    interateDir = function(basepath, path, namebase)
        local iter, dir_obj = lfs.dir(path)
        while true do
            local dir = iter(dir_obj)
            if dir == nil then break end
            if dir ~= "." and dir ~= ".." then
                local curDir = path..dir
                local mode = lfs.attributes(curDir, "mode")
                local name = namebase and (namebase .. "/" .. dir) or dir
                if mode == "directory" then
                    interateDir(basepath, curDir.."/", name)
                elseif mode == "file" then
                    local md5 = string.lower(crypto.md5file(curDir))
                    local keep = false
                    for i, v in ipairs(filelist.stage) do
                        if string.lower(v.code) == md5 then
                            keep = true
                            if validMd5Handler then
                                validMd5Handler(v, name)
                            end
                            break
                        end
                    end
                    if not keep then
                        if notFoundHandler then
                            notFoundHandler(curDir)
                        end
                    end
                end
            end
        end
    end
    interateDir(upd.conf.UPDATE_RES_DIR, upd.conf.UPDATE_RES_DIR)
end

-- 1.开始更新：请求服务端版本信息
function UpdateController:startUpdate()
    --提示正在检查版本
    print("startUpdate checking server version..")
    self.view_:setVersion(self.fileList_.ver)
    self.view_:setTipsLabel(upd.lang.getText("UPDATE", "CHECKING_VERSION"))
    self.view_:setBarVisible(false)

    if not upd.conf.ENABLED then
        self:endUpdate()
        return
    end

    local retryTimes = 3
    local requestServerVersion

    requestServerVersion = function()
        upd.http.POST_URL(appconfig.VERSION_CHECK_URL, 
            {
                device = (device.platform == "windows" and "android" or device.platform), 
                pay = (device.platform == "windows" and "android" or device.platform), 
                noticeVersion = "noticeVersion",
                osVersion = upd.conf.CLIENT_VERSION,
                version = upd.conf.CLIENT_VERSION,
                sid = appconfig.SID[string.upper(device.platform)],
                isPrisonBag = IS_PRISONBAG
            }, 
            function (data)
                print(data)
                local retData = data and json.decode(data) or nil
                if retData then
                    self.FACEBOOK_BONUS = tonumber(retData.fbBonus)
                    local svrVersion = retData.curVersion
                    local svrVerTitle = retData.verTitle
                    local svrVerMsg = retData.verMessage
                    local svrStoreURL = retData.updateUrl
                    local svrIsForce = (checknumber(retData.isForce) ~= 0)
                    local svrFBBonus = tonumber(retData.fbBonus)                    
                    self.feedBackUrl = retData.FEEDBACK_CGI_NEW or retData.FEEDBACK_CGI

                    self.showExchange = tonumber(retData.showExchange)
                    self.matchMall = tonumber(retData.matchMall)
                    
                    if upd.conf.DEBUG then
                        svrVersion = upd.conf.DEBUG_SVR_VERSION or svrVersion
                    end
                    
                    local svrVersionNum = upd.getVersionNum(svrVersion, 3)
                    local cliVersionNum = upd.getVersionNum(upd.conf.CLIENT_VERSION, 3)
                    local curVersionNum = upd.getVersionNum(self.fileList_.ver, 3)

                    print("svrVersionNum " .. svrVersionNum)
                    print("cliVersionNum " .. cliVersionNum)
                    print("curVersionNum " .. curVersionNum)

                    --大版本不同，干掉upd目录，因为这些东西不是为这个版本准备的,比如说刚刚从商城更新了应用
                    --例如大版本1.9.4安装后，curVersionNum还是大版本1.9.3配置，这时需要删除掉upd目录
                    if cliVersionNum ~= curVersionNum then
                        print("DELETE INVALID UPDATE FILES")
                        upd.rmdir(upd.conf.UPDATE_DIR)
                        upd.mkdir(upd.conf.UPDATE_DIR)
                        upd.mkdir(upd.conf.UPDATE_RES_DIR)
                        upd.mkdir(upd.conf.UPDATE_RES_TMP_DIR)
                        self.fileList_ = {
                            ver = upd.conf.CLIENT_VERSION,
                            stage = {},
                            remove = {},
                        }
                        curVersionNum = cliVersionNum
                    end

                    if curVersionNum >= svrVersionNum then
                        --不需要大版本更新，进入热更新流程
                        self:startHotUpdate()
                    else
                        --需要大版本更新，弹出提示
                        local count = cc.UserDefault:getInstance():getIntegerForKey(upd.conf.SKIT_UPDATE_TIMES_KEY, 0)
                        device.showAlert(
                            svrVerTitle,
                            svrVerMsg,
                            {
                                upd.lang.getText("UPDATE", "UPDATE_NOW"),
                                upd.lang.getText("UPDATE", "UPDATE_LATER")
                            },
                            function(event)
                                if event.buttonIndex == 1 then
                                    device.openURL(svrStoreURL)
                                else
                                    cc.UserDefault:getInstance():setIntegerForKey(upd.conf.SKIT_UPDATE_TIMES_KEY, count + 1)
                                end
                                if svrIsForce then
                                    os.exit()
                                else
                                    self.view_:setTipsLabel(upd.lang.getText("UPDATE", "UPDATE_CANCELED"))
                                    self:startHotUpdate()
                                end
                            end)
                    end
                else
                    retryTimes = retryTimes - 1
                    if retryTimes >= 0 then
                        requestServerVersion()
                    else
                        self.view_:setTipsLabel(upd.lang.getText("UPDATE", "BAD_NETWORK_MSG"))
                        self:endUpdate()
                    end
                end
            end, 
            function ()
                retryTimes = retryTimes - 1
                if retryTimes >= 0 then
                    requestServerVersion()
                else
                    self.view_:setTipsLabel(upd.lang.getText("UPDATE", "BAD_NETWORK_MSG"))
                    self:endUpdate()
                end
            end
        )
    end
    --请求服务器版本信息
    requestServerVersion()
end

--2.热更新流程
function UpdateController:startHotUpdate()
    print("startHotUpdate..")
    self.view_:setTipsLabel(upd.lang.getText("UPDATE", "CHECKING_RES_UPDATE"))
    
    local retryTimes = 3
    local newFileListFile = upd.conf.UPDATE_LIST_FILE .. ".upd"
    local requestServerFileList
    requestServerFileList = function()
        upd.http.GET_URL(string.format(upd.conf.SERVER_FILE_URL_FMT, upd.conf.UPDATE_LIST_FILE_NAME, upd.getTime()),
            {},
            function(data)
                ------将从服务器下载的配置文件写入到本地
                print("startHotUpdate.. successed")
                io.writefile(newFileListFile, data, "wb+")
                self.fileListNew_ = dofile(newFileListFile)
                if not self.fileListNew_ then
                    retryTimes = retryTimes - 1
                    if retryTimes >= 0 then
                        requestServerFileList()
                    else
                        self.view_:setTipsLabel(upd.lang.getText("UPDATE", "DOWNLOAD_ERROR"))
                        self:endUpdate()
                    end
                    return
                end
                -- -- PC测试
                -- local testInfo = {
                --     size = 29,
                --     silent = 1,
                --     act = "load",
                --     name = "update.zip",
                --     code = "e229d4883cfdd712e18c00c4739c2dff",
                -- }
                -- table.insert(self.fileListNew_.stage,testInfo)

                print("fileListNew_:" .. json.encode(self.fileListNew_))

                local curVersionNum = upd.getVersionNum(self.fileList_.ver, 4)
                local svrVersionNum = upd.getVersionNum(self.fileListNew_.ver, 4)
                print("curVersionNum " .. curVersionNum)
                print("svrVersionNum " .. svrVersionNum)

                if curVersionNum >= svrVersionNum then
                    print("already latest version")
                    self.view_:setTipsLabel(upd.lang.getText("UPDATE", "IS_ALREADY_THE_LATEST_VERSION"))
                    self:endUpdate()
                else
                    self:startDownload()
                end
            end,
            function(data)
                print("startHotUpdate.. failed retry ".. data)
                if data == 404 then
                    retryTimes = 0
                end

                retryTimes = retryTimes - 1
                if retryTimes >= 0 then
                    requestServerFileList()
                else
                    self.view_:setTipsLabel(upd.lang.getText("UPDATE", "DOWNLOAD_ERROR"))
                    self:endUpdate()
                end
            end)
    end
    requestServerFileList()
end

--2.1 下载流程：先比较本地文件与远程文件，生成需要下载的文件list
function UpdateController:startDownload()
    print("startDownload..")
    -- 初始化静默更新
    local haveSilent = false
    local silentIsCom = false -- 静默更新已经全部完毕
    for k, v in pairs(self.fileListNew_.stage) do
        if v then
            -- -- PC测试
            -- if k==6 then
            --     v.silent = 1
            -- else
            --     v.silent = 0
            -- end
            if haveSilent then
                v.silent = 1
            else
                if not v.silent then
                    v.silent = 0
                else
                    v.silent = tonumber(v.silent)
                    if not v.silent then
                        v.silent = 0
                    end
                end
                if v.silent==1 then
                    haveSilent = true
                end
            end
        end
    end
    --需要下载的文件列表
    self.downloadList_ = clone(self.fileListNew_.stage)
    self.updateCommands_ = {}
    if haveSilent then  -- 检测最后的那个文件
        local v = self.downloadList_[#self.downloadList_]
        if v then
            local tmpfile = upd.conf.UPDATE_RES_TMP_DIR .. string.lower(v.code)
            if upd.isFileExist(tmpfile) then
                if string.lower(crypto.md5file(tmpfile)) == string.lower(v.code) then
                    silentIsCom = true
                end
            end
        end
    end

    print("checking local resources..")
    --检查本地upd目录有没有不需要的文件
    self:checkResources(self.fileList_, function(fileinfo, name)
            --现有文件是热更新中应该存在的，还要检查下名称
            if name ~= fileinfo.name then
                if string.find(fileinfo.name, "/") then
                    local arr = string.split(fileinfo.name, "/")
                    arr[#arr] = nil
                    upd.mkdir(upd.conf.UPDATE_RES_DIR .. table.concat(arr, "/") .. "/")
                end
                local oldfile = upd.conf.UPDATE_RES_DIR .. name
                local newfile = upd.conf.UPDATE_RES_DIR .. fileinfo.name
                table.insert(self.updateCommands_, function()
                    print("rename " .. oldfile .. " => " .. newfile)
                    os.rename(oldfile, newfile)
                end)
            end
            --从下载列表中移除
            table.filter(self.downloadList_, function(v, k)
                return string.lower(v.code) ~= fileinfo.code
            end)
            print("file " .. fileinfo.name .. "(" .. fileinfo.code .. ") already exists")
        end,
        function(file)
            table.insert(self.updateCommands_, function()
                print("remove => " .. file)
                os.remove(file)
            end)
        end)
    

    --下载之前，在临时文件夹updtmp看看有没有md5相同的文件，有的话，移动到upd目录，不用下载了
    table.filter(self.downloadList_, function(v, k)
        local tmpfile = upd.conf.UPDATE_RES_TMP_DIR .. string.lower(v.code)
        if upd.isFileExist(tmpfile) then
            if string.lower(crypto.md5file(tmpfile)) == string.lower(v.code) then
                if string.find(v.name, "/") then
                    local arr = string.split(v.name, "/")
                    arr[#arr] = nil
                    upd.mkdir(upd.conf.UPDATE_RES_DIR .. table.concat(arr, "/") .. "/")
                end
                if v.silent~=1 or (v.silent==1 and silentIsCom==true) then
                    table.insert(self.updateCommands_, function()
                        os.rename(upd.conf.UPDATE_RES_TMP_DIR .. string.lower(v.code), upd.conf.UPDATE_RES_DIR .. v.name)
                    end)
                    if v.silent~=1 then
                        self.needDoCommandIndex_ = #self.updateCommands_
                    end
                    print("file " .. v.name .. "(" .. v.code .. ") already downloaded to restmp")
                else
                    table.insert(self.updateCommands_, function()

                    end)
                end
                return false
            else
                print("remove broken file => " .. tmpfile)
                os.remove(tmpfile)
            end
        end
        return true
    end)

    -- 此处存在bug json.encode = nil 导致字符串连接报错
    -- print("download list => " .. json.encode(self.downloadList_))

    --对过滤后的下载列表重组为下标1开始的数组
    self.downloadList_ = table.values(self.downloadList_)

    --计算需要下载的文件大小
    self.downloadFileSize_ = 0
    if #self.downloadList_ > 0 then
        self.downloadFileNum_ = 0
        self.needDownloadFileNum_ = 0 -- 必须更新
        self.silentDownloadFileNum_ = 0 -- 静默更新
        -- self.silentStartIndex_ = nil  -- 静默更新开始位置
        for k, v in pairs(self.downloadList_) do
            if v then
                if not self.isSilented_ and v.silent == 0 then
                    self.downloadFileSize_ = self.downloadFileSize_ + checknumber(v.size)
                    self.needDownloadFileNum_ = self.needDownloadFileNum_ + 1
                else
                    -- if not self.silentStartIndex_ then
                    --     self.silentStartIndex_ = k
                    -- end
                    self.isSilented_ = true
                    self.silentDownloadFileNum_ = self.silentDownloadFileNum_ + 1
                end
                self.downloadFileNum_ = self.downloadFileNum_ + 1
            end
        end
        print("download file size => " .. self.downloadFileSize_ .. "K")
        local downloadSizeLabel
        if self.downloadFileSize_ > 1024 then
            downloadSizeLabel = string.format("%.2fM", self.downloadFileSize_ / 1024)
        else
            downloadSizeLabel = self.downloadFileSize_ .. "K"
        end
        self.view_:setTotalLabel(downloadSizeLabel)
        local netState = network.getInternetConnectionStatus()
        -- -- PC测试
        -- if device.platform == "windows" then
        --     netState = cc.kCCNetworkStatusReachableViaWiFi
        -- end

        if netState ~= cc.kCCNetworkStatusReachableViaWiFi then
            if self.needDownloadFileNum_ < 1 then
                self:checkSilentDownload()
                self:endUpdate()
            else
                device.showAlert(
                    upd.lang.getText("UPDATE", "DOWNLOAD_NOT_IN_WIFI_PROMPT_TITLE"),
                    upd.lang.getText("UPDATE", "DOWNLOAD_NOT_IN_WIFI_PROMPT_MSG", downloadSizeLabel),
                    {
                        upd.lang.getText("UPDATE", "UPDATE_LATER"),
                        upd.lang.getText("UPDATE", "UPDATE_NOW"),
                    },
                    function(event)
                        if event.buttonIndex == 2 then
                            self.view_:setBarVisible(true)
                            self.downloadFileIndex_ = 1
                            self.view_:setTipsLabel(upd.lang.getText("UPDATE", "DOWNLOADING_MSG", self.downloadFileIndex_, self.needDownloadFileNum_))
                            self:downloadNextFile()
                        else
                            self.view_:setTipsLabel(upd.lang.getText("UPDATE", "UPDATE_CANCELED"))
                            self:endUpdate()
                        end
                    end)
            end
        else
            if self.needDownloadFileNum_ > 0 then
                self.view_:setBarVisible(true)
                self.downloadFileIndex_ = 1
                self.view_:setTipsLabel(upd.lang.getText("UPDATE", "DOWNLOADING_MSG", self.downloadFileIndex_, self.needDownloadFileNum_))
                self:downloadNextFile()
            else
                self:checkSilentDownload()
                self:endUpdate()
            end
        end
    else
        --更新完成
        self:completeUpdate()
    end
end

function UpdateController:checkSilentDownload()
    if self.silentDownloadFileNum_ and self.silentDownloadFileNum_>0 then
        self:checkDoNeedCommand()
        self:checkWriteVirtualVersion()

        local netState = network.getInternetConnectionStatus()
        -- -- PC测试
        
        -- if device.platform == "windows" then
        --     netState = cc.kCCNetworkStatusReachableViaWiFi
        -- end
        
        if netState == cc.kCCNetworkStatusReachableViaWiFi then
            self:downloadNextFile(true)
        end
    end
end

function UpdateController:checkDoNeedCommand()
    if self.needDoCommandIndex_ then
        local index = 0
        while true do
            index = index + 1
            local fun = table.remove(self.updateCommands_, 1)
            if fun then
                fun()
            end
            if index>=self.needDoCommandIndex_ then
                break
            end
        end
        self.needDoCommandIndex_ = nil
    end
end

function UpdateController:checkWriteVirtualVersion()
    -- 模拟假版本号
    local newStage = self.fileListNew_ and self.fileListNew_.stage
    if newStage then
        local data = 'local list = { ver = "'
        local version = upd.conf.CLIENT_VERSION..'.0", stage = {'
        local stage = ""
        local item = nil
        for k,v in pairs(newStage) do
            if v.silent and tonumber(v.silent)==1 then
                local silentFile = upd.conf.UPDATE_RES_DIR .. v.name
                -- 判断该静默更新是否已经在资源列表中
                if upd.isFileExist(silentFile) then
                    print(v.name.." is in the updateFold-RES")
                else
                    break
                end
            end
            if not v.silent then
                v.silent = 0
            end
            item = '{size="'..v.size..'",act="'..v.act..'",name="'..v.name..'",code="'..v.code..'",silent="'..v.silent..'"}'
            if stage=="" then
                stage = stage..item
            else
                stage = stage..','..item
            end
        end
        data = data..version..stage..' } }return list'
        io.writefile(upd.conf.UPDATE_LIST_FILE, data, "wb+")
        -- 重置变量
        self.fileList_ = dofile(upd.conf.UPDATE_LIST_FILE)
    end
end

function UpdateController:downloadNextFile(isSilent)
    if #self.downloadList_ > 0 then
        local fileinfo = table.remove(self.downloadList_, 1)
        if not fileinfo then return self:downloadNextFile(isSilent) end
        -- 直接静默更新
        if not self.downloadFileIndex_ then
            self.downloadFileIndex_ = 1
        end
        -- 第一个静默更新文件
        if not isSilent and fileinfo.silent==1 then
            self:checkDoNeedCommand()
            self:checkWriteVirtualVersion()
            self:endUpdate()
            isSilent = true
        end
        local requestFile
        local retryTimes = 2
        if isSilent then
            retryTimes = 999 -- 静默更新999次
        end
        print("downloading ====> " .. fileinfo.name)
        if not isSilent then
            self.view_:setTipsLabel(upd.lang.getText("UPDATE", "DOWNLOADING_MSG", self.downloadFileIndex_, self.needDownloadFileNum_))
        end
        requestFile = function()
            local lastTime = upd.getTime()
            local lastSize = 0
            local lastSpeed = "0KB/S"
            local request
            local requestURL = string.format(upd.conf.SERVER_FILE_URL_FMT, fileinfo.code, upd.getTime())
            -- -- PC测试
            -- if fileinfo.code=="e229d4883cfdd712e18c00c4739c2dff" then
            --     requestURL = "http://pirates133.by.com/w7poker_swf/apkft/e229d4883cfdd712e18c00c4739c2dff"
            -- end
            -- print("requestURL====="..requestURL)
            request = network.createHTTPRequest(function(event)
                    if event.name == "completed" then
                        print(request:getResponseStatusCode())
                        if request:getResponseStatusCode() ~= 200 then
                            retryTimes = retryTimes - 1
                            if retryTimes >= 0 then
                                requestFile()
                            else
                                if not isSilent then
                                    self:endUpdate()
                                end
                            end
                            return
                        end
                        local data = request:getResponseData()
                        io.writefile(upd.conf.UPDATE_RES_TMP_DIR .. fileinfo.code .. ".tmp", data, "wb+")
                        if string.lower(crypto.md5file(upd.conf.UPDATE_RES_TMP_DIR .. fileinfo.code .. ".tmp")) == string.lower(fileinfo.code) then
                            if not isSilent then
                                self.view_:setProgress(1, lastSpeed)
                            end
                            os.rename(upd.conf.UPDATE_RES_TMP_DIR .. fileinfo.code .. ".tmp", upd.conf.UPDATE_RES_TMP_DIR .. fileinfo.code)
                            if string.find(fileinfo.name, "/") then
                                local arr = string.split(fileinfo.name, "/")
                                arr[#arr] = nil
                                upd.mkdir(upd.conf.UPDATE_RES_DIR .. table.concat(arr, "/") .. "/")
                            end
                            if not isSilent then 
                                table.insert(self.updateCommands_, function()
                                    os.rename(upd.conf.UPDATE_RES_TMP_DIR .. fileinfo.code, upd.conf.UPDATE_RES_DIR .. fileinfo.name)
                                end)
                                self.needDoCommandIndex_ = #self.updateCommands_
                            else
                                table.insert(self.updateCommands_, function()
                                    
                                end)
                            end
                            self.downloadFileIndex_ = self.downloadFileIndex_ + 1
                            self:downloadNextFile(isSilent)
                        else
                            if not isSilent then
                                self.view_:setProgress(0, lastSpeed)
                            end
                            print("md5 not match !!!")
                            os.remove(upd.conf.UPDATE_RES_TMP_DIR .. fileinfo.code .. ".tmp")
                            retryTimes = retryTimes -1
                            if retryTimes >= 0 then
                                requestFile()
                            else
                                if not isSilent then
                                    self:endUpdate()
                                end
                            end
                        end
                    elseif event.name == "progress" then
                        if not isSilent then
                            local now = upd.getTime()
                            if now - lastTime > 1.5 then
                                if event.dltotal > lastSize then
                                    lastSpeed = (event.dltotal - lastSize) / ((now - lastTime) * 1024)
                                    if lastSpeed > 1024 then
                                        lastSpeed = string.format("%.2fMB/S", lastSpeed / 1024)
                                    else
                                        lastSpeed = string.format("%dKB/S", lastSpeed)
                                    end
                                end
                                lastSize = event.dltotal
                                lastTime = now
                            end
                            
                            print(string.format("inprogress %s %s %s", event.total, event.dltotal, lastSpeed))
                            self.view_:setProgress(event.total == 0 and 0 or event.dltotal / event.total, lastSpeed)
                        end
                    else
                        retryTimes = retryTimes -1
                        if retryTimes >= 0 then
                            requestFile()
                        else
                            if not isSilent then
                                self:endUpdate()
                            end
                        end
                    end
                end,
                -- string.format(upd.conf.SERVER_FILE_URL_FMT, fileinfo.code, upd.getTime()),
                requestURL,
                "GET")
            request:setTimeout(60 * 10)
            request:start()
        end
        requestFile()
    else
        self:completeUpdate(isSilent)
    end
end

function UpdateController:completeUpdate(isSilent)
    while #self.updateCommands_ > 0 do
        table.remove(self.updateCommands_, 1)()
    end
    -- -- PC测试
    -- os.remove(upd.conf.UPDATE_RES_DIR .. "update_20160114_1_android.zip")
    -- os.rename(upd.conf.UPDATE_RES_TMP_DIR .. "update_20160114_1_android.zip", upd.conf.UPDATE_RES_DIR .. "update_20160114_1_android.zip")
    -- 确保所有文件加载完成
    if not self.isSilented_ then
        local newFListContent = upd.readFile(upd.conf.UPDATE_LIST_FILE .. ".upd")
        if newFListContent then
            io.writefile(upd.conf.UPDATE_LIST_FILE, newFListContent, "wb+")
        end
    end
    if not isSilent then
        self.view_:setTipsLabel(upd.lang.getText("UPDATE", "UPDATE_COMPLETE"))
        self:endUpdate_(self.fileListNew_)
    end
end

--结束更新：进入游戏
function UpdateController:endUpdate()
    self:endUpdate_(self.fileList_)
end


function UpdateController:endUpdate_(fileList)
    self.view_:setBarVisible(false)

    local version = fileList.ver
    if #(string.split(version, ".")) == 3 then
        version = version .. ".0"
    end
    --导出到全局命名空间
    BM_UPDATE = {}
    BM_UPDATE.VERSION = version
    BM_UPDATE.FACEBOOK_BONUS = self.FACEBOOK_BONUS
    BM_UPDATE.FEEDBACK_URL = self.feedBackUrl
    BM_UPDATE.SHOWEXCHANGE = self.showExchange
    BM_UPDATE.MATCHMALL = self.matchMall
    BM_UPDATE.STAGE_FILE_LIST = clone(fileList.stage)
    -- TextureLoader.new({{"pop_common_texture.plist", "pop_common_texture.png"}, {"hall_texture.plist", "hall_texture.png"}, {"common_texture.plist", "common_texture.png"}}, function()
        TextureLoader.new({{"hall_texture.plist", "hall_texture.png"}, {"common_texture.plist", "common_texture.png"}}, function()
        self.view_:playLeaveScene(function()
            require("appentry")
        end)
    end, 0, 0)
end

return UpdateController
