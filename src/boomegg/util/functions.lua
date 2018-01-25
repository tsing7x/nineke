--
-- Author: tony
-- Date: 2014-07-11 13:47:18
--

require("lfs")
local socket = require("socket")
local lime = require 'boomegg.util.Lime'

local functions = {}

functions.lime = lime

function functions.getTime()
    return socket.gettime()
end

function functions.isFileExist(path)
    return path and cc.FileUtils:getInstance():isFileExist(path)
end

function functions.isDirExist(path)
    local success, msg = lfs.chdir(path)
    return success
end
 
function functions.mkdir(path)
    print("mkdir " .. path)
    if not functions.isDirExist(path) then
        local prefix = ""
        if string.sub(path, 1, 1) == device.directorySeparator then
            prefix = device.directorySeparator
        end
        local pathInfo = string.split(path, device.directorySeparator)
        local i = 1
        while(true) do
            if i > #pathInfo then
                break
            end
            local p = string.trim(pathInfo[i] or "")
            if p == "" or p == "." then
                table.remove(pathInfo, i)
            elseif p == ".." then
                if i > 1 then
                    table.remove(pathInfo, i)
                    table.remove(pathInfo, i - 1)
                    i = i - 1
                else
                    return false
                end
            else
                i = i + 1
            end
        end
        for i = 1, #pathInfo do
            local curPath = prefix .. table.concat(pathInfo, device.directorySeparator, 1, i) .. device.directorySeparator
            if not functions.isDirExist(curPath) then
                local succ, err = lfs.mkdir(curPath)
                if not succ then 
                    print("mkdir " .. path .. " failed, " .. err)
                    return false
                end
            else
            end
        end
    end
    print("done mkdir " .. path)
    return true
end
 
function functions.rmdir(path)
    print("rmdir " .. path)
    if functions.isDirExist(path) then
        local function _rmdir(path)
            local iter, dir_obj = lfs.dir(path)
            while true do
                local dir = iter(dir_obj)
                if dir == nil then break end
                if dir ~= "." and dir ~= ".." then
                    local curDir = path..dir
                    local mode = lfs.attributes(curDir, "mode") 
                    if mode == "directory" then
                        _rmdir(curDir.."/")
                    elseif mode == "file" then
                        os.remove(curDir)
                    end
                end
            end

            local succ, des = lfs.rmdir(path)
            if not succ then print("remove dir " .. path .. " failed, " .. des) end
            return succ
        end
        _rmdir(path)
    end
    print("done rmdir " .. path)
    return true
end

function functions.cacheFile(url, callback, dirName)
    local dirPath = device.writablePath .. "cache" .. device.directorySeparator ..  (dirName or "tmpfile") .. device.directorySeparator
    local hash = crypto.md5(url)
    local filePath = dirPath .. hash
    print("cacheFile filePath", filePath)
    if functions.mkdir(dirPath) then
        if io.exists(filePath) then
            print("cacheFile io exists", filePath)
            callback("success", io.readfile(filePath))
        else
            print("cacheFile url", url)
            bm.HttpService.GET_URL(url, {}, function(data)
                io.writefile(filePath, data, "w+")
                callback("success", data)
            end,
            function()
                callback("fail")
            end)
        end
    end
end

-- 遍历table，释放CCObject
local function releaseHelper (obj)
    if type(obj) == "table" then
        for k, v in pairs(obj) do
            releaseHelper(v)
        end
    elseif type(obj) == "userdata" then
        obj:release()
    end
end
functions.objectReleaseHelper = releaseHelper

function functions.formatBigNumber(num)
    local len  = string.len(tostring(num))
    local temp = tonumber(num)
    local ret
    if len >= 13 then
        temp = temp / 1000000000000;
        ret = string.format("%.3f", temp)
        ret = string.sub(ret, 1, string.len(ret) - 1)
        ret = ret .. "T"
    elseif len >= 10 then
        temp = temp / 1000000000;
        ret = string.format("%.3f", temp)
        ret = string.sub(ret, 1, string.len(ret) - 1)
        ret = ret .. "B"
    elseif len >= 7 then
        temp = temp / 1000000;
       ret = string.format("%.3f", temp)
        ret = string.sub(ret, 1, string.len(ret) - 1)
        ret = ret .. "M"
    elseif len >= 5 then
        temp = temp / 1000;
        ret = string.format("%.3f", temp)
        ret = string.sub(ret, 1, string.len(ret) - 1)
        ret = ret .. "K"
    else
        return tostring(temp)
    end

    if string.find(ret, "%.") then
        while true do
            local len = string.len(ret)
            local c = string.sub(ret, len - 1, string.len(ret) - 1)
            if c == "." then
                ret = string.sub(ret, 1, len - 2) .. string.sub(ret, len)
                break
            else
                c = tonumber(c)
                if c == 0 then
                    ret = string.sub(ret, 1, len - 2) .. string.sub(ret, len)
                else
                    break
                end
            end
        end
    end

    return ret
end

function functions.formatNumberWithSplit(num)
    return string.formatnumberthousands(num)
end

function functions.getVersionNum(version, num)
    local versionNum = 0
    if version then
        local list = string.split(version, ".")
        for i = 1, 4 do
            if num and num > 0 and i > num then
                break
            end
            if list[i] then
                versionNum = versionNum  + tonumber(list[i]) * (100 ^ (4 - i))
            end
        end
    end
    return versionNum
end

--- 返回utf8字符串从1到n的子串
-- @string str 要处理的utf-8字符串, 本函数不会校验其正确性
-- @integer n 默认16
-- @return 限制长度后的昵称 如果有截断会在字符串尾附上 '...'
function functions.limitNickLength(str, n)
    n = n or 16
    -- 不严格的utf8字符数量判断
    local function chsize(c)
        if c > 239 then return 4
        elseif c > 223 then return 3
        elseif c > 191 then return 2
        else return 1
        end
    end

    local s_len = # str

    if s_len <= n then return str end

    local s_b = string.byte
    local i = 1
    while n > 0 and i <= s_len do
        i = i + chsize(s_b(str, i))
        n = n - 1
    end
    local i_m_1 = i - 1
    if i_m_1 < s_len then
        return string.sub(str, 1, i_m_1) .. '...'
    else
        return str
    end
end

-- 首字符大写
function functions.ucfirst(value)
    if not value or string.len(value) == 0 then
        return ""
    end

    local lstr = string.lower(value)
    local ustr = string.upper(value)

    return string.sub(ustr, 1, 1) .. string.sub(lstr, 2)
end

-- 获取文件名
function functions.getFileNameByFilePath(filepath)
    -- assert(filepath, "functions.getFileNameByFilePath filepath is nil")
    if not filepath then
        return nil
    end

    local arr = string.split(filepath, "/")
    if not arr or 0 == #arr then
        return nil
    end

    local parr, item
    local tarr = string.split(arr[#arr], "?")
    local params = {}
    -- 解析文件名
    params["path"] = table.concat(arr, "/", 1, #arr-1)  -- 文件路径
    if tarr[1] and string.len(tarr[1]) > 0 then
        parr = string.split(tarr[1], ".")
        params["filename"] = tarr[1]    -- 文件名
        params["name"] = parr[1]        -- 基础名
        params["extension"] = parr[2]   -- 扩展名
        if string.find(parr[1], "-") then
            local farr = string.split(parr[1], "-")
            if #farr > 1 then
                params["lastname"] = params["name"]
                params["name"] = farr[2]
            end
        end
    end
    -- 解析参数
    if tarr[2] and string.len(tarr[2]) > 0 then
        parr = string.split(tarr[2], "&")
        for _,v in ipairs(parr) do
            item = string.split(v, "=")
            if item and #item > 1 then
                params[item[1]] = checknumber(item[2])
            end
        end
    end

    return params
end

-- 判断
function functions.isExistFiles(files, path)
    local isExist = true
    for _,v in ipairs(files) do
        local filepath = path .. device.directorySeparator .. v
        if not io.exists(filepath) then
            isExist = false
            break;
        end
    end

    return isExist
end

-- 删除文件
function functions.delFiles(files, path, hash)
    local filepath
    if hash then
        filepath = path .. device.directorySeparator .. hash
        if io.exists(filepath) then
            os.remove(filepath)
        end
    end

    for _,v in ipairs(files) do
        filepath = path .. device.directorySeparator .. v
        if io.exists(filepath) then
            os.remove(filepath)
        end
    end
end

-- 获取最合适的宽或高适配
function functions.getFitScale(maxDW, maxDH, sz)
    local retScale = 1
    if sz.width >= sz.height then
        retScale = maxDH / sz.height
        if retScale*sz.width > maxDW then
            retScale = maxDW / sz.width
        end
    else
        retScale = maxDW / sz.width
        if retScale*sz.height > maxDW then
            retScale = maxDH / sz.height
        end
    end

    return retScale
end

-- 文本框闪烁效果
function functions.blinkTextTarget(txtTarget, value, callback)
    if nil == value then
        return;
    end

    txtTarget:setOpacity(255*0.3);
    local delayTs = 0.1;
    transition.fadeIn(txtTarget, {
        time=0.3, 
        opacity = 255, 
        delay = delayTs, 
        onComplete = function()
            txtTarget:setString(value)
            if callback then
                callback();
            end
        end
    })
end

-----------------------------
-- @param:node 欲描边的显示对象
-- @param:strokeWidth 描边宽度
-- @param:color 描边颜色
-- @param:opacity 描边透明度
function functions.createStroke(node, strokeWidth, color, opacity, step)
    local degrees2radians = function(angle)
        return angle * 0.01745329252
    end

    local radians2degrees = function(angle)
        return angle * 57.29577951
    end

    -- 记录原始位置
    local originX, originY = node:getPosition()

    -- 记录原始颜色RGB信息
    local originColorR = node:getColor().r
    local originColorG = node:getColor().g
    local originColorB = node:getColor().b

    -- 记录原始透明度信息
    local originOpacity = node:getOpacity()

    -- 记录原始是否显示
    local originVisibility = node:isVisible()

    -- 记录原始混合模式
    local originBlend = node:getBlendFunc()

    -- 设置颜色、透明度、显示
    node:setColor(color)
    node:setOpacity(opacity)
    node:setVisible(true)
    
    -- 设置新的混合模式
    node:setBlendFunc(GL_SRC_ALPHA, GL_ONE)

    --node:getTexture():getContentSize()
    local size = node:getContentSize()
    local w = size.width + strokeWidth * 2
    local h = size.height + strokeWidth * 2
    local anchorPoint = node:getAnchorPoint()
    local rt = cc.RenderTexture:create(w, h)

    -- 这里考虑到锚点的位置，如果锚点刚好在中心处，代码可能会更好理解点
    local bottomLeftX = size.width * anchorPoint.x + strokeWidth 
    local bottomLeftY = size.height * anchorPoint.y + strokeWidth
    local positionOffsetX = size.width * anchorPoint.x - size.width / 2
    local positionOffsetY = size.height * anchorPoint.y - size.height / 2
    local rtPosition = cc.p(originX - positionOffsetX, originY - positionOffsetY)

    rt:setPosition(rtPosition)
    rt:setAnchorPoint(anchorPoint)

    rt:begin()
    -- 步进值这里为10，不同的步进值描边的精细度也不同
    step = step or 5;
    for i = 0, 360, step do
        -- 这里解释了为什么要保存原来的初始信息
        node:setPosition(cc.p(bottomLeftX + math.sin(degrees2radians(i)) * strokeWidth, bottomLeftY + math.cos(degrees2radians(i)) * strokeWidth))
        node:visit()
    end
    rt:endToLua()
    display.immediatelyRender()
    
    -- 恢复原状
    node:setPosition(originX, originY)
    node:setColor(cc.c3b(originColorR, originColorG, originColorB))
    node:setBlendFunc(originBlend.src, originBlend.dst)
    node:setVisible(originVisibility)
    node:setOpacity(originOpacity)
    
    -- rt:setPosition(rtPosition)

    rt:getSprite():getTexture():setAntiAliasTexParameters()
    node:getParent():addChild(rt, node:getLocalZOrder()-1)
    return rt
end

--[[
local tmp = bm.cloneNode(self.inviteNode_, cc.size(270, 47), 270*0.5, 47*0.5);
tmp:pos(display.cx, 450)
tmp:addTo(self.middle_part)
]]
-- 克隆Sprite
function functions.cloneNode(node, size, offX, offY, pixelformat)
    local sz
    if size then
        sz = size;   
    else
        sz = node:getContentSize() 
    end

    if sz.width == 0 or sz.height == 0 then
        return nil
    end

    offX = offX or 0
    offY = offY or 0

    local oldAnchor = node:getAnchorPoint()
    local oldPos = cc.p(node:getPosition())
    node:setAnchorPoint(cc.p(0, 0))
    node:setPosition(offX, offY)
    local canva = cc.RenderTexture:create(sz.width,sz.height, pixelformat or cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888, 0x88F0)

    canva:begin()
    node:visit()
    canva:endToLua()

    -- 必须立即渲染，3.x渲染规则改了
    display.immediatelyRender()--调用cc.Director:getInstance():getRenderer():render()

    node:setAnchorPoint(oldAnchor);
    node:setPosition(oldPos)

    local tex = canva:getSprite():getTexture()
    local cnode = cc.Sprite:createWithTexture(tex)
    cnode:setFlippedY(true)

    return cnode
end

-- 高斯模糊Node容器
-- Node: 高斯模糊容器
-- scaleFactor：为node容器渲染缩放比率，默认为0.08
-- pixelformat: 为渲染的纹理格式
-- filePath: 需要保存的路徑
function functions.GaussianBlurNode(node, scaleFactor, pixelformat, filePath)
    scaleFactor = scaleFactor or 0.2
    pixelformat = pixelformat or cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888
    local sz = node:getContentSize()
    local dw = math.ceil(sz.width * scaleFactor)
    local dh = math.ceil(sz.height * scaleFactor)
    local canva = functions.cloneSpriteTexture(node, dw, dh, scaleFactor, pixelformat)
    local tex = canva:getSprite():getTexture()
    tex:setAntiAliasTexParameters() -- 抗锯齿

    local cnode = cc.Sprite:createWithTexture(tex);
    cnode:setFlippedY(true)
    bm.DisplayUtil.setGaussian(cnode, {sampleNum=8, radius=4})

    if filePath then
        local cloneCanva = functions.cloneSpriteTexture(cnode, dw, dh, 1, pixelformat)
        cloneCanva:saveToFile(filePath)
    end

    return cnode
end

-- node容器縮略拷貝
function functions.cloneSpriteTexture(node, dw, dh, scaleFactor)
    local canva = cc.RenderTexture:create(dw, dh, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888, 0x88F0)
    local oldAnchor = node:getAnchorPoint();
    local oldPos = cc.p(node:getPosition());
    local oldScale = node:getScale()
    node:setAnchorPoint(cc.p(0, 0))
    node:setPosition(0,0)
    node:scale(scaleFactor)

    canva:begin()
    node:visit()
    canva:endToLua()
    display.immediatelyRender()

    node:setAnchorPoint(oldAnchor)
    node:setPosition(oldPos)
    node:scale(oldScale)

    return canva
end

-- 获取模糊背景路径
function functions.getBlurBgPath(filename)
    if not functions.blurBgPath_ then
        functions.blurBgPath_ = "cache"..device.directorySeparator.."blurBg"..device.directorySeparator--device.writablePath.."cache"..device.directorySeparator.."blurBg"..device.directorySeparator
        bm.mkdir(functions.blurBgPath_)
    end
    return functions.blurBgPath_..filename
end

-- 创建模糊背景图
function functions.createBlurBg(node, filename, scaleFactor)
    local filePath = functions.getBlurBgPath(filename)
    local fullPath = device.writablePath .. filePath

    if not io.exists(fullPath) then
        local cnode = functions.GaussianBlurNode(nk.runningScene, scaleFactor, nil, filePath):scale(1 / scaleFactor)
        if not io.exists(fullPath) then
            return cnode
        end
    end

    display.setTexturePixelFormat(fullPath, cc.TEXTURE2_D_PIXEL_FORMAT_RG_B565)
    local blurBg = display.newSprite(fullPath)
    blurBg:scale(1/scaleFactor)

    return blurBg
end

function functions.grayNodeByTex(tex, params)
    params = params or {0.2, 0.3, 0.5, 0.1};
    local spr_ = CCFilteredSpriteWithOne:createWithTexture(tex);
    local filters = filter.newFilter("GRAY", params);
    spr_:setFilter(filters);
    return spr_;
end

function functions.grayNodeBySprite(spr)
    local tex = spr:getTexture()
    return functions.grayNodeByTex(tex);
end

-- 判断坐标点是否在Node区域中
function functions.containPointByNode(px, py, ...)
    local numArgs = select("#", ...);
    if numArgs then
        local node;
        for i=1,numArgs do
            node = select(i, ...);
            if node then
                if node:getCascadeBoundingBox():containsPoint(cc.p(px, py)) then
                    return true;
                end
            end
            node = nil;
        end
    end
    return false;
end

-- 对sprite进行以width宽度进行自适配
-- width:为sprite宽度最大宽度
-- offVal:为宽度的偏差值，用于修正
function functions.fitSprteWidth(sprite, width)
    local sz = sprite:getContentSize();
    if sz.width > width then
        local scaleVal = width / sz.width;
        sprite:setScale(scaleVal);
    else
        sprite:setScale(1);
    end
end

-- 画出容器显示区域，方便查看node占位区域
function functions.testDraw(contains)
    print("functions.testDraw:::")
    local childs = contains:getChildren();
    for i=0,childs:count()-1,1 do
        local obj = tolua.cast(childs:objectAtIndex(i), "cc.Node")
        local px, py = obj:getPosition();
        local size = obj:getContentSize();
        local parent = obj:getParent();
        local testNode = display.newScale9Sprite("#common_red_btn_up.png", px, py, cc.size(size.width, size.height))
            :addTo(parent)
        testNode:setOpacity(30)

        print("obj.name::"..tostring(obj.name))
    end
end

functions.exportMethods = function(target)
    for k, v in pairs(functions) do
        if k ~= "exportMethods" then
            target[k] = v
        end
    end
end

return functions
