--
-- Author: tony
-- Date: 2014-07-14 18:19:27
--
require("lfs")

local ImageLoader = class("ImageLoader")
local log = bm.Logger.new("ImageLoader"):enabled(true)


ImageLoader.CACHE_TYPE_NONE = "CACHE_TYPE_NONE"
ImageLoader.DEFAULT_TMP_DIR = device.writablePath .. "cache" .. device.directorySeparator .. "tmpimg" .. device.directorySeparator

function ImageLoader:ctor()
    self.loadId_ = 0
    self.cacheConfig_ = {}
    self.loadingJobs_ = {}
    bm.rmdir(ImageLoader.DEFAULT_TMP_DIR)
    bm.mkdir(ImageLoader.DEFAULT_TMP_DIR)
    self:registerCacheType(ImageLoader.CACHE_TYPE_NONE, {path=ImageLoader.DEFAULT_TMP_DIR})
end

function ImageLoader:registerCacheType(cacheType, cacheConfig)
    self.cacheConfig_[cacheType] =  cacheConfig
    if cacheConfig.path then
        bm.mkdir(cacheConfig.path)
    else
        cacheConfig.path = ImageLoader.DEFAULT_TMP_DIR
    end
end

function ImageLoader:clearCache()
    for k, v in pairs(self.cacheConfig_) do
        bm.rmdir(v.path)
    end
end

function ImageLoader:nextLoaderId()
    self.loadId_ = self.loadId_ + 1
    return self.loadId_
end

function ImageLoader:loadAndCacheAnimation(files, loadId, url, callback, cacheType)
    log:debugf("loadAndCacheAnimation(%s, %s, %s)", loadId, url, cacheType)
    self:cancelJobByLoaderId(loadId)
    cacheType = cacheType or ImageLoader.CACHE_TYPE_NONE
    self:addJobAnimation_(files, loadId, url, self.cacheConfig_[cacheType], callback)
end
-- 
function ImageLoader:loadAndCacheAnimationExt(files, loadId, url, callback, cacheType)
    log:debugf("loadAndCacheAnimation(%s, %s, %s)", loadId, url, cacheType)
    files = files or {"texture.png", "texture.xml", "skeleton.xml"}
    self:cancelJobByLoaderId(loadId)
    cacheType = cacheType or ImageLoader.CACHE_TYPE_NONE
    self:addJobAnimation_(files, loadId, url, self.cacheConfig_[cacheType], function(success, params, loaderId)
        callback(success)
    end)
end
-- 
function ImageLoader:addJobAnimation_(files, loadId, url, config, callback)
    local params = bm.getFileNameByFilePath(url)
    local hash = crypto.md5(url)
    local path = config.path .. params["name"]
    if bm.isExistFiles(files, path) then
        log:debugf("file exists (%s, %s, %s)", loadId, url, params["name"])
        lfs.touch(path..device.directorySeparator..files[1])
        if callback ~= nil then
            callback(true, params, loadId)
        end
    else
        bm.delFiles(files, path, hash)
        bm.mkdir(path)
        local loadingJob = self.loadingJobs_[url]
        if loadingJob then
            log:debugf("job is loading -> %s", url)
            loadingJob.callbacks[loadId] = callback
        else
            log:debugf("start job -> %s", url)
            loadingJob = {}
            loadingJob.callbacks = {}
            loadingJob.callbacks[loadId] = callback
            self.loadingJobs_[url] = loadingJob
            local function onRequestFinished(evt)
                if evt.name ~= "progress" then
                    local ok = (evt.name == "completed")
                    local request = evt.request
                    -- 
                    if not ok then
                        -- 请求失败，显示错误代码和错误消息
                        log:debugf("[%d] errCode=%s errmsg=%s", loadId, request:getErrorCode(), request:getErrorMessage())
                        local values = table.values(loadingJob.callbacks)
                        for i, v in ipairs(values) do
                            if v ~= nil then
                                v(false, request:getErrorCode() .. " " .. request:getErrorMessage(), loadId)
                            end
                        end
                        self.loadingJobs_[url] = nil
                        return
                    end
                    -- 
                    local code = request:getResponseStatusCode()
                    if code ~= 200 then
                        -- 请求结束，但没有返回 200 响应代码
                        log:debugf("[%d] code=%s", loadId, code)
                        local values = table.values(loadingJob.callbacks)
                        for i, v in ipairs(values) do
                            if v ~= nil then
                                v(false, code, loadId)
                            end
                        end
                        self.loadingJobs_[url] = nil
                        return
                    end
                    -- 请求成功，显示服务端返回的内容
                    log:debugf("loaded from network, save to file -> %s", path)
                    local content = request:getResponseData()
                    local zippath = path..device.directorySeparator..hash
                    io.writefile(zippath, content, "w+b")
                    -- 读取zip包中文件
                    -- local zipData = cc.FileUtils:getInstance():getFileData(zippath)

                    for _,v in ipairs(files) do
                        local file_content = cc.FileUtils:getInstance():getFileDataFromZip(zippath, v)
                        io.writefile(path..device.directorySeparator..v, file_content, "w+b")
                    end
                    os.remove(zippath)
                    -- 
                    if bm.isExistFiles(files, path) then
                        for k, v in pairs(loadingJob.callbacks) do
                            log:debugf("call callback -> " .. k)
                            if v then
                                v(true, params, loadId)
                            end
                        end
                        if config.onCacheChanged then
                            config.onCacheChanged(config.path)
                        end
                    else
                        log:debug("file not exists -> " .. path)
                    end
                    self.loadingJobs_[url] = nil
                end
            end
            -- 创建一个请求，并以 指定method发送数据到服务端HttpService.cloneDefaultParams初始化
            local request = network.createHTTPRequest(onRequestFinished, url, "GET")
            loadingJob.request = request
            request:start()
        end
    end
end

function ImageLoader:loadAndCacheImage(loadId, url, callback, cacheType)
    log:debugf("loadAndCacheImage(%s, %s, %s)", loadId, url, cacheType)
    self:cancelJobByLoaderId(loadId)
    cacheType = cacheType or ImageLoader.CACHE_TYPE_NONE
    self:addJob_(loadId, url, self.cacheConfig_[cacheType], callback)
end

function ImageLoader:loadImage(url, callback, cacheType)
    local loadId = self:nextLoaderId()
    cacheType = cacheType or ImageLoader.CACHE_TYPE_NONE
    local config = self.cacheConfig_[cacheType]
    log:debugf("loadImage(%s, %s, %s)", loadId, url, cacheType)
    self:addJob_(loadId, url, config, callback)
end

function ImageLoader:cancelJobByUrl_(url)
    local loadingJob = self.loadingJobs_[url]
    if loadingJob then
        loadingJob.callbacks = {}
    end
end

function ImageLoader:cancelJobByLoaderId(loaderId)
    if loaderId then
        for url, loadingJob in pairs(self.loadingJobs_) do
            loadingJob.callbacks[loaderId] = nil
        end
    end
end

function ImageLoader:addJob_(loadId, url, config, callback)
    local hash = crypto.md5(url)

    if config == self.cacheConfig_[nk.ImageLoader.CACHE_TYPE_SHARE] then
        if string.find(url, "/") then
            local arr = string.split(url, "/")
            hash = arr[#arr]
        end
    end

    local path = config.path .. hash
    if io.exists(path) then
        log:debugf("file exists (%s, %s, %s)", loadId, url, path)
        lfs.touch(path)
        local tex = cc.Director:getInstance():getTextureCache():addImage(path)
        if not tex then
            os.remove(path)
        elseif callback ~= nil then
            callback(tex ~= nil, cc.Sprite:createWithTexture(tex), loadId)
        end
    else
        local loadingJob = self.loadingJobs_[url]
        if loadingJob then
            log:debugf("job is loading -> %s", url)
            loadingJob.callbacks[loadId] = callback
        else
            log:debugf("start job -> %s", url)
            loadingJob = {}
            loadingJob.callbacks = {}
            loadingJob.callbacks[loadId] = callback
            self.loadingJobs_[url] = loadingJob
            local function onRequestFinished(evt)
                if evt.name ~= "progress" then
                    local ok = (evt.name == "completed")
                    local request = evt.request

                    if not ok then
                        -- 请求失败，显示错误代码和错误消息
                        log:debugf("[%d] errCode=%s errmsg=%s", loadId, request:getErrorCode(), request:getErrorMessage())
                        local values = table.values(loadingJob.callbacks)
                        for i, v in ipairs(values) do
                            if v ~= nil then
                                v(false, request:getErrorCode() .. " " .. request:getErrorMessage(), loadId)
                            end
                        end
                        self.loadingJobs_[url] = nil
                        return
                    end

                    local code = request:getResponseStatusCode()
                    if code ~= 200 then
                        -- 请求结束，但没有返回 200 响应代码
                        log:debugf("[%d] code=%s", loadId, code)
                        local values = table.values(loadingJob.callbacks)
                        for i, v in ipairs(values) do
                            if v ~= nil then
                                v(false, code, loadId)
                            end
                        end
                        self.loadingJobs_[url] = nil
                        return
                    end

                    -- 请求成功，显示服务端返回的内容
                    local content = request:getResponseData()
                    log:debugf("loaded from network, save to file -> %s", path)
                    io.writefile(path, content, "w+b")

                    if bm.isFileExist(path) then
                        local tex = nil
                        for k, v in pairs(loadingJob.callbacks) do
                            log:debugf("call callback -> " .. k)
                            if v then
                                if not tex then
                                    lfs.touch(path)
                                    tex = cc.Director:getInstance():getTextureCache():addImage(path)
                                end
                                if not tex then
                                    os.remove(path)
                                else
                                    v(true, cc.Sprite:createWithTexture(tex), loadId)
                                end
                            end
                        end
                        if config.onCacheChanged then
                            config.onCacheChanged(config.path)
                        end
                    else
                        log:debug("file not exists -> " .. path)
                    end
                    self.loadingJobs_[url] = nil
                end
            end
            -- 创建一个请求，并以 指定method发送数据到服务端HttpService.cloneDefaultParams初始化
            local request = network.createHTTPRequest(onRequestFinished, url, "GET")
            loadingJob.request = request
            request:start()
        end
    end
end

return ImageLoader