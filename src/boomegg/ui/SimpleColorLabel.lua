--
-- Author: hlf
-- Date: 2015-09-21 12:05:00
--

local SimpleColorLabel = {}
--[[
-- 每邀请一位好友，您可获得{1}比赛券，每天最多可获得{2}比赛券
    local fontSize = 16;
    local cfg1 = SimpleColorLabel.addMultiLabel("每邀请一位好友，您可获得{1}比赛券", fontSize, cc.c3b(255, 255, 255), cc.c3b(255, 255, 0), cc.c3b(255, 255, 255))
                    .addTo(self);
    local cfg2 = SimpleColorLabel.addMultiLabel("，每天最多可获得{1}比赛券", fontSize, cc.c3b(255, 255, 255), cc.c3b(255, 255, 0), cc.c3b(255, 255, 255))
                    .addTo(self);
    cfg1.setString(5);
    cfg2.setString(500);
    -- SimpleColorLabel.pos(cfg1, cfg2, ui.TEXT_ALIGN_CENTER, cc.p(display.cx, display.cy), 5);
    -- SimpleColorLabel.pos(cfg1, cfg2, ui.TEXT_ALIGN_LEFT, cc.p(display.cx, display.cy), 5);
    SimpleColorLabel.pos(cfg1, cfg2, ui.TEXT_ALIGN_RIGHT, cc.p(display.cx, display.cy), 5);
]]
-- cfg1, 
-- cfg2, 
-- align 对齐方式
-- pt 坐标位置
-- gapX x间距
function SimpleColorLabel.pos(cfg1, cfg2, align, pt, gapX)
    pt = pt or cc.p(0, 0);
    gapX = gapX or 0;

    local sz1;
    local sz2;
    if cfg1 and cfg2 then
        sz1 = cfg1.getContentSize();
        sz2 = cfg2.getContentSize();
        -- 
        if align == ui.TEXT_ALIGN_CENTER then
            pt.x = pt.x - (sz1.width + sz2.width)*0.5;
        elseif align == ui.TEXT_ALIGN_RIGHT then
            pt.x = pt.x - (sz1.width + sz2.width)*1.0;
        end
        -- 
        cfg1.pos(pt.x+sz1.width*0.5, pt.y);
        cfg2.pos(pt.x+sz1.width*1+sz2.width*0.5+gapX, pt.y);
    elseif cfg1 then
        sz1 = cfg1.getContentSize();
        if align == ui.TEXT_ALIGN_LEFT then
            pt.x = pt.x - sz1.width*0.5;
        elseif align == ui.TEXT_ALIGN_RIGHT then
            pt.x = pt.x - sz1.width*1.0;
        end
        cfg1.pos(pt.x, pt.y);
    elseif cfg2 then
        sz2 = cfg2.getContentSize();
        if align == ui.TEXT_ALIGN_LEFT then
            pt.x = pt.x - sz2.width*0.5;
        elseif align == ui.TEXT_ALIGN_RIGHT then
            pt.x = pt.x - sz2.width*1.0;
        end
        cfg2.pos(pt.x, pt.y);
    end
end

function SimpleColorLabel.addMultiLabel(str, fontSize, color1, color2, color3)
    local split_ = function(str, delimiter)
        if str==nil or str=='' or delimiter==nil then
            return nil
        end
        
        local result = {}
        for match in (str..delimiter):gmatch("(.-)"..delimiter) do
            table.insert(result, match)
        end
        return result
    end
    -- 
    local node = display.newNode();
    fontSize = fontSize or 22;
    -- 
    local txt1 = ui.newTTFLabel({
            text = "",
            size = fontSize,
            color = color1 or cc.c3b(0xff,0xff,0xff),
            align = ui.TEXT_ALIGN_CENTER,
        }):pos(0, 0):addTo(node);
    -- 
    local txt2 = ui.newTTFLabel({
            text = "",
            size = fontSize,
            color = color2 or cc.c3b(0xff,0xff,0xff),
            align = ui.TEXT_ALIGN_CENTER,
        }):pos(0, 0):addTo(node);
    -- 
    local txt3 = ui.newTTFLabel({
            text = "",
            size = fontSize,
            color = color3 or cc.c3b(0xff,0xff,0xff),
            align = ui.TEXT_ALIGN_CENTER,
        }):pos(0, 0):addTo(node);
    -- 
    local txt = txt2;
    local arr = split_(str,"{1}");
    local fidx,lidx = string.find(str,"{1}");
    if 1 == fidx then
        table.insert(arr, 1,"");
        txt = txt1;
    elseif string.len(str) == lidx then
        table.insert(arr, #arr+1,"");
        txt = txt3;
    else
        table.insert(arr, #arr,"");
        txt = txt2;
    end
    -- 
    if txt1 and arr[1] then txt1:setString(arr[1] or "") end
    if txt2 and arr[2] then txt2:setString(arr[2] or "") end
    if txt3 and arr[3] then txt3:setString(arr[3] or "") end

    -- 
    local cfg = {
        node=node,
        txt1=txt1,
        txt2=txt2,
        txt3=txt3,
        txt=txt,
        fontSize=fontSize,
    };

    -- 刷新位置
    cfg.refreshPos = function()
        local lsz1 = txt1:getContentSize();
        local lsz2 = txt2:getContentSize();
        local lsz3 = txt3:getContentSize();
        -- 
        local tw = lsz1.width + lsz2.width + lsz3.width;
        local offl = lsz1.width + lsz2.width*0.5;
        local offr = lsz3.width + lsz2.width*0.5;
        local dx = (offl - offr)*0.5;
        local offx = 1; --cfg.fontSize*0.5;
        -- 
        txt2:setPosition(dx, 0)
        txt1:setPosition(-lsz1.width*0.5 - lsz2.width*0.5 + dx - offx, 0);
        txt3:pos(lsz3.width*0.5 + lsz2.width*0.5 + dx + offx, 0);
        return cfg;
    end
    cfg.getContentSize = function()
        local lsz1 = txt1:getContentSize();
        local lsz2 = txt2:getContentSize();
        local lsz3 = txt3:getContentSize();
        local tw = lsz1.width + lsz2.width + lsz3.width;
        return {width=tw, height=lsz2.height};
    end
    -- 
    cfg.setScale = function(val)
        node:setScale(val)
    end
    --
    cfg.setString = function(value)
        txt:setString(value or "");
        cfg.refreshPos();
        return cfg;
    end
    -- 
    cfg.addTo = function(parent, zIndex, tag)
        node:addTo(parent, zIndex, tag);
        print("addMultiLabel:::::::addTo")
        return cfg;
    end
    -- 
    cfg.pos = function(px, py)
        node:pos(px, py);
        return cfg;
    end
    cfg.txtVisible1 = function(value)
        txt1:setVisible(value);
        return cfg;
    end
    cfg.txtVisible2 = function(value)
        txt2:setVisible(value);
        return cfg;
    end
    cfg.txtVisible3 = function(value)
        txt3:setVisible(value);
        return cfg;
    end
    cfg.show=function()
        node:show();
        return cfg;
    end
    cfg.hide=function()
        node:hide();
        return cfg;
    end
    cfg.setVisible=function(value)
        node:setVisible(value);
        return cfg;
    end
    return cfg;
end

--[[
local str = "ABC{OOOO}EDFG{PPPP}MMMM{QQQQ}LlLL"
local fontSize = 20;
local node = SimpleColorLabel:html(str, cc.c3b(0xff, 0xff, 0x0), cc.c3b(0xff,0x0, 0x0), fontSize, 2)
node:addTo(self):pos(display.cx, display.cy)
]]
-- str:为处理的字符串
-- defaultColor:默认字颜色
-- colors:为加量字颜色数组，如果所有加量字同一个颜色直接给一个颜色，如果每一个加量字要设置不同颜色请数组进行一一对应
-- fontSize:字体大小
-- alignType:对齐方式，默认为左对齐，1居中，2右对齐，3左对齐
function SimpleColorLabel.html(str, defaultColor, colors, fontSize, alignType)
    local defaultColor_ = defaultColor or cc.c3b(0xff, 0xff, 0xff);

    local i,j,w;
    local keys = {}
    for w in string.gfind(str, "%b{}") do 
        table.insert(keys, w)
    end
    -- 
    local key
    local index = 1;
    local fields = {}
    for i=1,#keys do
        local startIndex, endIndex = string.find(str, keys[i], index)
        -- print(string.format("index=%d, startIndex=%d, endIndex=%d", index, startIndex, endIndex))
        if index <= startIndex then
            key = string.sub(str, index, startIndex-1)
            if key and string.len(key) > 0 then
                table.insert(fields, key)
            end
            key = string.sub(str, startIndex, endIndex)
            if key and string.len(key) > 0 then
                table.insert(fields, key)
            end
            index = endIndex + 1
        end
    end
    --
    if index < string.len(str) then
        table.insert(fields, string.sub(str, index))
    end    -- 
    local dw = 0;
    local kColor,sz,lbl,key
    local lbls = {}
    local contain = display.newNode()
    for i=1,#fields do
        key = fields[i]
        kColor = defaultColor_
        for j=1,#keys do
            if keys[j] == fields[i] then
                if colors then
                    if tostring(tolua.type(colors)) == "ccColor3B" then
                        kColor = colors;
                    elseif colors[j] then
                        kColor = colors[j];
                    elseif colors[1] then
                        kColor = colors[1];
                    end
                end
                key = string.sub(key, 2, string.len(key)-1)
                break;
            end
        end
        -- 
        lbl = ui.newTTFLabel({
                text=key,
                color=kColor,
                size=fontSize,
                align=ui.TEXT_ALIGN_CENTER
            })
            :addTo(contain)
        sz = lbl:getContentSize()
        dw = dw + sz.width*0.5;
        lbl:pos(dw, 0)
        dw = dw + sz.width*0.5;
        table.insert(lbls, lbl)
    end

    local refreshPos = function()
        local offX = 0
        local px = 0
        if alignType == 1 then
            -- 居中
            offX = dw * 0.5;
            for i=1,#lbls do
                lbl = lbls[i];
                sz = lbl:getContentSize()
                px = px + sz.width*0.5;
                lbl:pos(px-offX, 0)
                px = px + sz.width*0.5;
            end
        elseif alignType == 2 then
            -- 右对齐
            offX = dw;
            for i=1,#lbls do
                lbl = lbls[i];
                sz = lbl:getContentSize()
                px = px + sz.width*0.5;
                lbl:pos(px-offX, 0)
                px = px + sz.width*0.5;
            end
        else
            offX = 0;
            for i=1,#lbls do
                lbl = lbls[i];
                sz = lbl:getContentSize()
                px = px + sz.width*0.5-offX;
                lbl:pos(px, 0)
                px = px + sz.width*0.5;
            end
        end
    end

    local setString = function(index, text)
        if #lbls >= index and index > 0 then
            lbls[index]:setString(text)
            -- 
            local w = 0
            for i=1,#lbls do
                w = w + lbls[i]:getContentSize().width
            end
            contain.width = w;
            dw = w
            -- 
            refreshPos()
        end
    end
    local setStringByKey = function(key, text)
        for i=1,#fields do
            local keystr = fields[i]
            if key and keystr == key then
                lbls[i]:setString(text)
                -- 
                local w = 0
                for i=1,#lbls do
                    w = w + lbls[i]:getContentSize().width
                end
                contain.width = w;
                dw = w
                -- 
                refreshPos()
                -- 
                break
            end
        end
    end
    refreshPos()

    contain.refreshPos = refreshPos;
    contain.setString = setString;
    contain.setStringByKey = setStringByKey
    contain.width = dw;
    return contain;
end
-- 创建图片加文字混合效果
-- alignType:对齐方式，默认为左对齐，1居中，2右对齐，3左对齐
function SimpleColorLabel.addIconText(iconParams, textParams, alignType)
    local resId = iconParams.resId or "#transparent.png"
    local resScale = iconParams.resScale or 1
    local textStr = textParams.text or ""
    local textSize = textParams.size or 20
    local textColor = textParams.color or cc.c3b(0xff, 0xff, 0xff)
    local txtMaxDW = textParams.txtMaxDW or 0
    local txtGap = textParams.txtGap or 1
    local txtScaleVal = 1
    alignType = alignType or 1
    -- 
    local contain = display.newNode()
    local icon = display.newSprite(resId)
        :scale(resScale)
        :addTo(contain)
    local txt = ui.newTTFLabel({
            text=textStr,
            size=textSize,
            color=textColor,
            align=ui.TEXT_ALIGN_CENTER
        })
        :addTo(contain)
    -- 
    local lbls = {icon, txt}
    -- 计算元素宽度
    local getWidth = function()
        local w = 0
        for i=1,#lbls do
            w = w + lbls[i]:getContentSize().width
        end
        contain.width = w;
    end
    -- 重新刷新坐标
    local refreshPos = function()
        getWidth()
        local offX = 0
        local px = 0
        local dw = 0
        if alignType == 1 then
            -- 居中
            offX = contain.width * 0.5;
            for i=1,#lbls do
                lbl = lbls[i];
                sz = lbl:getContentSize()
                dw = sz.width*0.5
                if lbl == txt then
                    dw = dw * txtScaleVal
                end
                px = px + dw + txtGap;
                lbl:pos(px-offX, 0)
                px = px + dw;
            end
        elseif alignType == 2 then
            -- 右对齐
            offX = contain.width;
            for i=1,#lbls do
                lbl = lbls[i];
                sz = lbl:getContentSize()
                dw = sz.width*0.5
                if lbl == txt then
                    dw = dw * txtScaleVal
                end
                px = px + dw + txtGap;
                lbl:pos(px-offX, 0)
                px = px + dw;
            end
        else
            offX = 0;
            for i=1,#lbls do
                lbl = lbls[i];
                sz = lbl:getContentSize()
                dw = sz.width*0.5
                if lbl == txt then
                    dw = dw * txtScaleVal
                end
                px = px + dw-offX + txtGap;
                lbl:pos(px, 0)
                px = px + dw;
            end
        end
    end
    -- 设置文字内容
    local setString = function(index, text)
        txt:setString(text)
        local sz = txt:getContentSize()
        if txtMaxDW > 0 and sz.width > txtMaxDW then
            txtScaleVal = txtMaxDW/sz.width
        else
            txtScaleVal = 1
        end
        txt:scale(txtScaleVal)
        -- 
        refreshPos()
    end
    -- 
    local setColor = function(index, color)
        if #lbls >= index and index > 0 then
            lbls[index]:setTextColor(color)
            refreshPos()
        end
    end
    -- 设置图标
    local setIcon = function(iconResId)
        icon:setSpriteFrame(display.newSpriteFrame(iconResId))
        icon:scale(resScale)
    end
    refreshPos()
    setString(1, textStr)
    contain.refreshPos = refreshPos;
    contain.setString = setString;
    contain.setColor = setColor
    contain.setIcon = setIcon
    return contain
end

return SimpleColorLabel;