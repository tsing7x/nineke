--[[
    全局上下文
]]

-- 临时hack, 在mac player上面运行时,把平台 伪装成windows以适配现有代码
if device.platform == 'mac' then
    device.platform = 'windows'
end

require("app.consts")
require("app.styles")


-- 通过元表特殊处理 特定key的读写访问
nk = setmetatable(nk or {}, {
    __index = function (t, k)
        if k == "userData" then
            return bm.DataProxy:getData(nk.dataKeys.USER_DATA)
        elseif k == "runningScene" then
            return cc.Director:getInstance():getRunningScene()
        elseif k == "userDefault" then
            return cc.UserDefault:getInstance()
        end
    end,
    -- 拦截特殊key,防止错误的用法
    __newindex = function (t, k, v)
        if k ~= "userData" and k ~= "runningScene" and k ~= "userDefault" then
            rawset(t, k, v)
        else
            print('error mk field set! ', k)
        end
    end
})

import(".util.functions").exportMethods(nk)

-- local game state
nk.gameState = {
    RoomLevel = {'low', 'middle', 'high', 'coin'}, -- 初级场 中级场 高级场 3个状态
    roomLevel = 'middle',
}

-- 常量设置
nk.widthScale = display.width / 960
nk.heightScale = display.height / 640

-- 公共UI
nk.ui = import(".pokerUI.init")

-- Socket
nk.socket = {}
nk.socket.ProxySelector = import(".net.ProxySelector")
nk.socket.HallSocket = import(".net.HallSocket").new()
nk.socket.RoomSocket = nk.socket.HallSocket
nk.socket.RealRoomSocket = nk.socket.RoomSocket
nk.socket.MatchSocket = import(".net.MatchSocket").new()

nk.match = {}
nk.match.MatchModel = import("app.module.match.MatchModel").new()

nk.config = import(".config")

-- data keys
nk.dataKeys = import(".keys.DATA_KEYS")
nk.cookieKeys = import(".keys.COOKIE_KEYS")

-- event names
nk.eventNames = import(".keys.EVENT_NAMES")

-- 声音管理类
nk.SoundManager = import(".manager.SoundManager").new()

-- 弹框管理类
nk.PopupManager = import(".manager.PopupManager").new()

-- 编辑框管理类
nk.EditBoxManager = import(".manager.EditBoxManager").new()

-- test util
nk.TestUtil = import(".util.TestUtil").new()

-- 顶部消息管理类
nk.TopTipManager = import(".manager.TopTipManager").new()

-- 比赛消息处理
nk.MatchTipsManager = import(".manager.MatchTipsManager").new()

--公共调度器
nk.schedulerPool = bm.SchedulerPool.new()

--每日任务事件上报类
nk.DailyTasksEventHandler = import(".module.dailytasks.DailyTasksEventHandler").new()
-- 指引
-- nk.TutorialManager = import("app.module.tutorial.TutorialManager").new()

-- 过滤敏感字
-- nk.FilterKey = import(".util.FilterKeyWord").new()

-- 活动中心网页版
--nk.ByActivity = import("app.module.login.plugins.ByActivityPlugin").new()

-- 原生桥接
if device.platform == "android" then
    nk.Native = import(".util.LuaJavaBridge").new()
    nk.Facebook = import("app.module.login.plugins.FacebookPluginAndroid").new()
    nk.AdSdk = import("app.module.login.plugins.AdSdkPluginAndroid").new()
    -- nk.Push = import("app.module.login.plugins.UniversalPushApi").new()
    nk.GcmPush = import("app.module.login.plugins.GoogleCloudMessaging").new()
    -- if nk.config.ADSCENE_ENABLED then
        -- nk.AdSceneSdk = import("app.module.login.plugins.AdScenePluginAndroid").new()
    -- end
    nk.SimUtils = import(".util.SimUtils").new()
    -- nk.ByActivity = import("app.module.login.plugins.ByActivityPluginAndroid").new()
elseif device.platform == "ios" then
    nk.Native = import(".util.LuaOCBridge").new()
    nk.Facebook = import("app.module.login.plugins.FacebookPluginIos").new()
    nk.AdSdk = import("app.module.login.plugins.AdSdkPluginIos").new()
    nk.Push = import("app.module.login.plugins.UniversalPushApi").new()
    -- nk.ByActivity = import("app.module.login.plugins.ByActivityPluginIos").new()
else
    nk.Native = import(".util.LuaBridgeAdapter")
    nk.Facebook = import("app.module.login.plugins.FacebookPluginAdapter").new()
    nk.AdSdk = import("app.module.login.plugins.AdSdkPluginAdapter").new()
end

-- 支持graph api
import("app.module.login.plugins.FacebookGraphApi").exportMethods(nk.Facebook)
nk.OnOff = import("app.module.login.OnOff").new()
-- 比赛场门票管理基类
nk.MatchTickManager = import("app.module.match.MatchTickManager").new();
-- 比赛场每日任务基类
nk.MatchDailyManager = import("app.module.match.MatchDailyManager").new();
-- 管理比赛场参赛记录
nk.MatchRecordManager = import("app.module.match.MatchRecordManager").new();
-- 管理加载文字提示信息
nk.EnterTipsManager = import("app.manager.EnterTipsManager").new();
-- 管理玩家属性发生变化
nk.UserInfoChangeManager = import("app.manager.UserInfoChangeManager").new();
-- 
nk.MixCurrentManager = import("app.module.match.mix.MixCurrentManager").new();

-- 加载远程图像
nk.ImageLoader = bm.ImageLoader.new()
nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG = "CACHE_TYPE_USER_HEAD_IMG"
nk.ImageLoader:registerCacheType(nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG, {
    path = device.writablePath .. "cache" .. device.directorySeparator .. "headpics" .. device.directorySeparator,
    onCacheChanged = function(path)
        require("lfs")
        local fileDic = {}
        local fileIdx = {}
        local MAX_FILE_NUM = 500
        for file in lfs.dir(path) do
            if file ~= "." and file ~= ".." then
                local f = path.. device.directorySeparator ..file
                local attr = lfs.attributes(f)
                assert(type(attr) == "table")
                if attr.mode ~= "directory" then
                    fileDic[attr.access] = f
                    fileIdx[#fileIdx + 1] = attr.access
                end
            end
        end
        if #fileIdx > MAX_FILE_NUM then
            table.sort(fileIdx)
            repeat
                local file = fileDic[fileIdx[1]]
                print("remove file -> " .. file)
                os.remove(file)
                table.remove(fileIdx, 1)
            until #fileIdx <= MAX_FILE_NUM
        end
    end,
})
nk.ImageLoader.CACHE_TYPE_ACT = "CACHE_TYPE_ACT"
nk.ImageLoader:registerCacheType(nk.ImageLoader.CACHE_TYPE_ACT, {
    path = device.writablePath .. "cache" .. device.directorySeparator .. "act" .. device.directorySeparator,
    onCacheChanged = function(path) 
        require("lfs")
        local fileDic = {}
        local fileIdx = {}
        local MAX_FILE_NUM = 100
        for file in lfs.dir(path) do
            if file ~= "." and file ~= ".." then
                local f = path.. device.directorySeparator ..file
                local attr = lfs.attributes(f)
                assert(type(attr) == "table")
                if attr.mode ~= "directory" then
                    fileDic[attr.access] = f
                    fileIdx[#fileIdx + 1] = attr.access
                end
            end
        end
        if #fileIdx > MAX_FILE_NUM then
            table.sort(fileIdx)
            repeat
                local file = fileDic[fileIdx[1]]
                print("remove file -> " .. file)
                os.remove(file)
                table.remove(fileIdx, 1)
            until #fileIdx <= MAX_FILE_NUM
        end
    end,
})
nk.ImageLoader.CACHE_TYPE_GIFT = "CACHE_TYPE_GIFT"
nk.ImageLoader:registerCacheType(nk.ImageLoader.CACHE_TYPE_GIFT, {
    path = device.writablePath .. "cache" .. device.directorySeparator .. "gift" .. device.directorySeparator,
    onCacheChanged = function(path) 
        require("lfs")
        local fileDic = {}
        local fileIdx = {}
        local MAX_FILE_NUM = 400
        for file in lfs.dir(path) do
            if file ~= "." and file ~= ".." then
                local f = path.. device.directorySeparator ..file
                local attr = lfs.attributes(f)
                assert(type(attr) == "table")
                if attr.mode ~= "directory" then
                    fileDic[attr.access] = f
                    fileIdx[#fileIdx + 1] = attr.access
                end
            end
        end
        if #fileIdx > MAX_FILE_NUM then
            table.sort(fileIdx)
            repeat
                local file = fileDic[fileIdx[1]]
                print("remove file -> " .. file)
                os.remove(file)
                table.remove(fileIdx, 1)
            until #fileIdx <= MAX_FILE_NUM
        end
    end,
})
nk.ImageLoader.CACHE_TYPE_ANIMATION = "CACHE_TYPE_ANIMATION"
nk.ImageLoader:registerCacheType(nk.ImageLoader.CACHE_TYPE_ANIMATION, {
    path = device.writablePath .. "cache" .. device.directorySeparator .. "animation" .. device.directorySeparator,
    onCacheChanged = function(path) 
        require("lfs")
        local fileDic = {}
        local fileIdx = {}
        local MAX_FILE_NUM = 400
        for file in lfs.dir(path) do
            if file ~= "." and file ~= ".." then
                local ftype = 1
                local f = path .. device.directorySeparator .. file
                local ftex = f .. device.directorySeparator .. "texture.png"
                if not io.exists(ftex) then
                    ftex = f .. device.directorySeparator .. file .. ".png"
                    ftype = 2
                end

                if io.exists(ftex) then
                    local attr = lfs.attributes(ftex)
                    assert(type(attr) == "table")
                    if attr.mode ~= "directory" then
                        fileDic[attr.access] = {f, file, ftype}
                        fileIdx[#fileIdx + 1] = attr.access
                    end
                end
            end
        end
        -- 
        if #fileIdx > MAX_FILE_NUM then
            table.sort(fileIdx)
            repeat
                local dic = fileDic[fileIdx[1]]
                local fp = dic[1]
                local filename = dic[2]
                local ftype = dic[3]
                local delfiles
                if ftype == 1 then
                    delfiles = {
                        fp .. device.directorySeparator .. "texture.png",
                        fp .. device.directorySeparator .. "texture.xml",
                        fp .. device.directorySeparator .. "skeleton.xml",
                    }
                else
                    delfiles = {
                        fp .. device.directorySeparator .. filename .. ".png",
                        fp .. device.directorySeparator .. filename .. ".gaf",
                    }
                end
                for _,v in ipairs(delfiles) do
                    -- if io.exists(v) then
                        os.remove(v)
                    -- end
                end
                -- bm.rmdir(fp)
                table.remove(fileIdx, 1)
            until #fileIdx <= MAX_FILE_NUM
        end
    end,
})
if device.platform == "android" then
    nk.ImageLoader.CACHE_TYPE_SHARE = "CACHE_TYPE_SHARE"
    local path_ = "/sdcard/NineKe" .. device.directorySeparator .. "share" .. device.directorySeparator
    if not bm.isDirExist(path_) then
        bm.mkdir(path_)
    end
    nk.ImageLoader:registerCacheType(nk.ImageLoader.CACHE_TYPE_SHARE, {
        path = path_,
        -- path = device.writablePath .. "cache" .. device.directorySeparator .. "share" .. device.directorySeparator,
        onCacheChanged = function(path) 
            require("lfs")
            local fileDic = {}
            local fileIdx = {}
            local MAX_FILE_NUM = 100
            for file in lfs.dir(path) do
                if file ~= "." and file ~= ".." then
                    local f = path.. device.directorySeparator ..file
                    local attr = lfs.attributes(f)
                    assert(type(attr) == "table")
                    if attr.mode ~= "directory" then
                        fileDic[attr.access] = f
                        fileIdx[#fileIdx + 1] = attr.access
                    end
                end
            end
            if #fileIdx > MAX_FILE_NUM then
                table.sort(fileIdx)
                repeat
                    local file = fileDic[fileIdx[1]]
                    print("remove file -> " .. file)
                    os.remove(file)
                    table.remove(fileIdx, 1)
                until #fileIdx <= MAX_FILE_NUM
            end
        end,
    })
end

--业务逻辑类
nk.Level = import(".util.Level").new()

bm.ui.ScrollView.defaultScrollBarFactory =  function (direction)
    if direction == bm.ui.ScrollView.DIRECTION_VERTICAL then
        return display.newScale9Sprite("#vertical_scroll_bar.png", 0, 0, cc.size(8, 24))
    elseif direction == bm.ui.ScrollView.DIRECTION_HORIZONTAL then
        return display.newScale9Sprite("#horizontal_scroll_bar.png", 0, 0, cc.size(24, 8))
    end
end

-- 务必先设置下node的setContentSize(cc.size(100,100))
function display.printscreen(node, args,anchorX,anchorY)
    if not anchorX then
        anchorX = 0
    end
    if not anchorY then
        anchorY = 0
    end
    local sp = true
    local file = nil
    local filters = nil
    local filterParams = nil
    if args then
        if args.sprite ~= nil then sp = args.sprite end
        file = args.file
        filters = args.filters
        filterParams = args.filterParams
    end
    local size = node:getContentSize()
    local __oldAnchor = node:getAnchorPoint()
    local __oldPos = node:getPosition()
    node:setAnchorPoint(ccp(anchorX, anchorY))
    node:setPosition(0,0)
    local canvas = cc.RenderTexture:create(size.width,size.height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888, 0x88F0)

    canvas:begin()
    node:visit()
    canvas:endToLua()
    display.immediatelyRender()

    node:setAnchorPoint(__oldAnchor)
    node:setPosition(__oldPos)

    if sp then
        local texture = canvas:getSprite():getTexture()
        if filters then
            sp = display.newFilteredSprite(texture, filters, filterParams)
        else
            sp = display.newSprite(texture)
        end
        sp:flipY(true)
    end
    if file and device.platform ~= "mac" then
        canvas:saveToFile(file)
    end
    return sp, file
end

return nk
