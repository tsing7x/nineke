--
-- Author: HLF(IdaHuang@boyaa.com)
-- Date: 2016-02-16 14:53:03
--
--不进行灰化的对象特有的方法
local  DisplayUtil = {}

DisplayUtil.LIST_DONT_SHADER = {
    "setString",     --Label
}

-- 冰冻
function DisplayUtil.setIce(node, v)
	DisplayUtil.setShader(DisplayUtil.drawIceNode, node, v)
end

-- 灰色
function DisplayUtil.setGray(node, v)
	DisplayUtil.setShader(DisplayUtil.drawGrayNode, node, v)
end

-- 高斯模糊
function DisplayUtil.setGaussian(node, params)
    params = params or {}
    local paramsFunc = function(pProgramState, subNode)
        pProgramState:setUniformFloat("sampleNum", params.sampleNum or 3.75)
        
        pProgramState:setUniformFloat("blurRadius", params.radius or 4)
        
        local sz = params.size or subNode:getContentSize()
        pProgramState:setUniformVec2("resolution", cc.p(sz.width, sz.height))
    end
    node.paramsFunc = paramsFunc
	DisplayUtil.setShader(DisplayUtil.drawGaussianNode, node, params)
end

function DisplayUtil.setShader(func, node, v)
	if type(node) ~= "userdata" then
        return
    end

    if v == nil then
        v = true
    end

    if not node.__isShader__ then
        node.__isShader__ = false
    end

    if v == node.__isShader__ then
        return
    end

    if v then
        if DisplayUtil.canShader(node) then
            local pProgramState = func(node)

            if node.paramsFunc then
                node.paramsFunc(pProgramState, node)
            end
        end

        local children = node:getChildren()

        if children and #children > 0 then
            --遍历子对象设置
            local count = #children
            for i = 1, count do
                local val = tolua.cast(children[i], "cc.Node")
                if DisplayUtil.canShader(val) then
                    DisplayUtil.setShader(func, val)
                end
            end
        end
    else
        DisplayUtil.removeShader(node)
    end
    node.__isShader__ = v
end

--取消着色器
function DisplayUtil.removeShader(node)
    if type(node) ~= "userdata" then
        printError("node must be a userdata")
        return
    end

    if not node.__isShader__ then
        return
    end

    if DisplayUtil.canShader(node) then
        -- local pProgramState = cc.GLProgramState:getOrCreateWithGLProgramName(cc.SHADER_NAME_POSITION_TEXTURE_COLOR_NO_MVP)
        -- node:setGLProgramState(pProgramState)
        DisplayUtil.drawNormalNode(node)
    end

    local children = node:getChildren()
    if children and #children > 0 then
        --遍历子对象设置
        local count = #children
            for i = 1, count do
            local val = tolua.cast(children[i], "cc.Node")
            if DisplayUtil.canShader(val) then
                DisplayUtil.removeShader(val)
            end
        end
    end

    node.__isShader__ = false
end

-- 使用冰封效果着色器
function DisplayUtil.drawIceNode(node)
    local pProgram = cc.GLProgram:createWithFilenames("res/Shaders/ice.vsh","res/Shaders/ice.fsh")
	pProgram:bindAttribLocation("a_position", cc.VERTEX_ATTRIB_POSITION)
	pProgram:bindAttribLocation("a_color", cc.VERTEX_ATTRIB_COLOR)
	pProgram:bindAttribLocation("a_texCoord", cc.VERTEX_ATTRIB_TEX_COORD)
	pProgram:link()
	pProgram:updateUniforms()

    local pProgramState = cc.GLProgramState:create(pProgram)
    node:setGLProgramState(pProgramState)

	return pProgramState
end

-- 使用灰色效果着色器
function DisplayUtil.drawGrayNode(node)
    local pProgram = cc.GLProgram:createWithFilenames("res/Shaders/gray.vsh","res/Shaders/gray.fsh")
    pProgram:bindAttribLocation("a_position", cc.VERTEX_ATTRIB_POSITION)
    pProgram:bindAttribLocation("a_color", cc.VERTEX_ATTRIB_COLOR)
    pProgram:bindAttribLocation("a_texCoord", cc.VERTEX_ATTRIB_TEX_COORD)
    pProgram:link()
    pProgram:updateUniforms()
    
    local pProgramState = cc.GLProgramState:create(pProgram)
    node:setGLProgramState(pProgramState)

    return pProgramState
end

-- 高斯模糊
function DisplayUtil.drawGaussianNode(node)
    local pProgram = cc.GLProgram:createWithFilenames("res/Shaders/blur.vsh","res/Shaders/blur.fsh")
    pProgram:bindAttribLocation("a_position", cc.VERTEX_ATTRIB_POSITION)
    pProgram:bindAttribLocation("a_color", cc.VERTEX_ATTRIB_COLOR)
    pProgram:bindAttribLocation("a_texCoord", cc.VERTEX_ATTRIB_TEX_COORD)
    pProgram:link()
    pProgram:updateUniforms()

    local pProgramState = cc.GLProgramState:create(pProgram)
    node:setGLProgramState(pProgramState)

    return pProgramState
end

function DisplayUtil.drawNormalNode(node)    
    local pProgram = cc.GLProgram:createWithFilenames("res/Shaders/normal_render.vsh","res/Shaders/normal_render.fsh")
    pProgram:bindAttribLocation("a_position", cc.VERTEX_ATTRIB_POSITION)
    pProgram:bindAttribLocation("a_color", cc.VERTEX_ATTRIB_COLOR)
    pProgram:bindAttribLocation("a_texCoord", cc.VERTEX_ATTRIB_TEX_COORD)
    pProgram:link()
    pProgram:updateUniforms()

    local pProgramState = cc.GLProgramState:create(pProgram)
    node:setGLProgramState(pProgramState)
end

--判断能否使用着色器
function DisplayUtil.canShader(node)
    for i,v in ipairs(DisplayUtil.LIST_DONT_SHADER) do
        if node[v] then
            return false
        end
    end
    
    return true
end

return DisplayUtil