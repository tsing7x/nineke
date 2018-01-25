--
-- Author: XT
-- Date: 2015-09-08 11:19:53

local BubbleButton = {}

-- create bubble button
function BubbleButton.new(params)
    local listener = params.listener
    local button

    params.listener = function(tag)
        if params.prepare then
            params.prepare()
        end

        local function zoom1(offset, time, onComplete)
            local x, y = button:getPosition()
            local size = button:getContentSize()

            local scaleX = button:getScaleX() * (size.width + offset) / size.width
            local scaleY = button:getScaleY() * (size.height - offset) / size.height

            transition.moveTo(button, {y = y - offset, time = time})
            transition.scaleTo(button, {
                scaleX     = scaleX,
                scaleY     = scaleY,
                time       = time,
                onComplete = onComplete,
            })
        end

        local function zoom2(offset, time, onComplete)
            local x, y = button:getPosition()
            local size = button:getContentSize()

            transition.moveTo(button, {y = y + offset, time = time / 2})
            transition.scaleTo(button, {
                scaleX     = 1.0,
                scaleY     = 1.0,
                time       = time,
                onComplete = onComplete,
            })
        end

        button:setTouchEnabled(false)

        zoom1(40, 0.08, function()
            zoom2(40, 0.09, function()
                zoom1(20, 0.10, function()
                    zoom2(20, 0.11, function()
                        button:setTouchEnabled(true)
                        listener(tag)
                    end)
                end)
            end)
        end)
    end

    if params.scale9 then 
        button = display.newScale9Sprite(params.image, params.x, params.y, params.size, params.capInsets)
    else
        button = display.newSprite(params.image, params.x, params.y)
    end

    params.offX = params.offX or 0
    params.offY = params.offY or 0
    params.size = params.size or cc.size(1,1)
    button:setNodeEventEnabled(true)
    button:setTouchEnabled(true)
    button:setTouchSwallowEnabled(true)
    button:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
    	if event.name == 'began' then
            return true
        elseif event.name == 'ended' then
        	nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
        	params.listener(event)
        end
    end)

    button.onCleanup = handler(self, function()
        button:removeNodeEventListenersByEvent(cc.NODE_TOUCH_EVENT)
    end)

    if params.text and string.len(params.text) > 0 then
        local lbl = ui.newTTFLabelWithOutline({
            text = params.text or "", 
            color = params.color or styles.FONT_COLOR.GOLDEN_TEXT,
            outlineColor = params.outcolor or cc.c3b(0, 0, 0),
            size = params.fontSize or 18,
            align = params.align or ui.TEXT_ALIGN_CENTER,
            outlineWidth = params.outlineWidth or 1,
            dimensions = cc.size(params.size.width - (params.lblOffDw or 10),0)
        })
        :pos((params.size.width + (params.offX or 10))*0.5, (params.size.height + (params.offY or 0))*0.5)
        :addTo(button)
        button.lbl = lbl
    end

    return button
end

local Default_ResID = "#common_transparent_skin.png"
function BubbleButton.createCommonBtn(params)
    local iconNormalResId = params.iconNormalResId
    local iconOverResId = params.iconOverResId or iconNormalResId
    local btnNormalResId = params.btnNormalResId or Default_ResID
    local btnOverResId = params.btnOverResId or btnNormalResId
    local btnLightResId = params.btnLightResId
    local selfParent = params.parent or self
    local selfparentIndex = params.parentIndex or 1
    local clickHandler = params.onClick or nil
    local onReleaseFunc = params.onReleaseFunc or nil
    local onPressedFunc = params.onPressedFunc or nil
    local iconZIndex = params.iconZIndex or 2
    local btnZIndex = params.btnZIndex or 1
    local imageZIndex = params.imageZIndex or 15
    local iconScale = params.iconScale or 1
    local btnScale = params.btnScale or 1
    local strokeColor = params.strokeColor
    local strokeWidth = params.strokeWidth or 5
    local strokeOpacity = params.strokeOpacity or 100
    local strokeStep = params.strokeStep or 12
    local txtString = params.txtString
    local txtColor = params.txtColor or cc.c3b(0xff, 0xff, 0xff)
    local txtSize = params.txtSize or 20
    local txtOffX = params.txtOffX or 0
    local txtOffY = params.txtOffY or 0
    local txtWidth = params.txtWidth or 0
    local resPre = params.resPre or "#"
    local imgParams = params.imgParams
    local x = params.x or 0
    local y = params.y or 0
    local lx = params.lx or 0
    local ly = params.ly or 0
    local ix = params.ix or 0
    local iy = params.iy or 0
    local lscale = params.lscale or 0
    local lzindex = params.lzindex or 0
    local scaleVal = params.scaleVal or 1
    local px, py = 0, 0
    local isBtnScale9 = true
    if params.isBtnScale9 ~= nil then
        isBtnScale9 = params.isBtnScale9
    end

    local isz
    local icon
    local btn
    local node = display.newNode()
        :pos(x, y)
        :addTo(selfParent, selfparentIndex)

    if iconNormalResId then
        icon = display.newSprite(iconNormalResId)
            :pos(px+ix, py+iy)
            :addTo(node, iconZIndex)
        isz = icon:getContentSize()
    else
        isz = cc.size(1, 1)
    end

    btn = cc.ui.UIPushButton.new({
            normal = btnNormalResId, 
            pressed = btnOverResId
        }, {
            scale9 = isBtnScale9
        })
    :pos(px, py)
    :addTo(node, btnZIndex)
    :onButtonClicked(function()
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
        if clickHandler then
            clickHandler()
        end
    end)

    local buttonWidth = params.buttonWidth or isz.width
    local buttonHeight = params.buttonHeight or isz.height
    if isBtnScale9 and buttonWidth and buttonHeight then        
        btn:setButtonSize(buttonWidth, buttonHeight)
    end

    local strokeSpr
    if strokeColor and icon then
        strokeSpr = bm.createStroke(icon, strokeWidth, strokeColor, strokeOpacity, strokeStep)
        strokeSpr:hide()
    end

    local btnLight
    if btnLightResId then
        btnLight = display.newSprite(btnLightResId)
            :pos(px + lx, py + ly)
            :addTo(node, btnZIndex + lzindex)
            :scale(lscale)
    end

    btn:onButtonRelease(function()
        btn:setScale(btnScale)
        if iconOverResId ~= iconNormalResId then
            if icon then
                if string.byte(iconNormalResId) == 35 then
                    icon:setSpriteFrame(display.newSpriteFrame(string.sub(iconNormalResId, 2)))                
                else
                    icon:setSpriteFrame(display.newSpriteFrame(iconNormalResId)) 
                end
            end
        end

        if onReleaseFunc then
            onReleaseFunc()
        end

        if strokeSpr then
            strokeSpr:hide()
        end
    end)

    btn:onButtonPressed(function()
        btn:setScale(scaleVal)
        if iconOverResId ~= iconNormalResId then
            if string.byte(iconOverResId) == 35 then
                icon:setSpriteFrame(display.newSpriteFrame(string.sub(iconOverResId, 2)))                
            else
                icon:setSpriteFrame(display.newSpriteFrame(iconOverResId)) 
            end
        end

        if onPressedFunc then
            onPressedFunc()
        end

        if strokeSpr then
            strokeSpr:show()
        end
    end)
    icon:setScale(iconScale)
    btn:setScale(btnScale)

    local txt
    if txtString then
        txt = ui.newTTFLabel({
                text=txtString,
                color=txtColor,
                size=txtSize,
            })
            :pos(px+txtOffX, py+txtOffY)
            :addTo(node, btnZIndex+8)
        
        if txtWidth > 0 then
            bm.fitSprteWidth(txt, txtWidth)
        end
    end

    local imageLoaderId
    local imageNode
    if imgParams and imgParams.url then
        imageNode = display.newNode()
            :addTo(node, btnZIndex+imageZIndex)
        imageLoaderId = nk.ImageLoader:nextLoaderId()
        nk.ImageLoader:loadAndCacheImage(imageLoaderId, imgParams.url, function(success, sprite)
            if sprite and type(sprite) ~= "string" then
                local tex = sprite:getTexture()
                local texSize = tex:getContentSize()
                local xscale = (imgParams.width or buttonWidth) / texSize.width
                local yscale = (imgParams.height or buttonHeight) / texSize.height
                local scaleVal = xscale < yscale and xscale or yscale
                local imgOffX = imgParams.offX or 0
                local imgOffY = imgParams.offY or 0
                sprite:scale(scaleVal)
                    :pos(px+imgOffX, py+imgOffY)
                    :addTo(imageNode)                    
            end
        end)
    end

    node.onCleanup = function()
        if imageLoaderId then
            nk.ImageLoader:cancelJobByLoaderId(imageLoaderId)
        end
    end
    node.icon = icon
    node.txt = txt
    node.btn = btn
    node.light = btnLight
    node.imageNode = imageNode
    node.strokeSpr = strokeSpr
    node:setNodeEventEnabled(true)
    
    return node
end

return BubbleButton
