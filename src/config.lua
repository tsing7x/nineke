
-- 发布正式版本的时候，打开此标志
-- 日前: 2015.5.26
local IS_RELEASE = false
if IS_RELEASE then
    DEBUG    = 0 -- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
    CF_DEBUG = 0
    DEBUG_FPS = false
else
    DEBUG    = 5
    CF_DEBUG = 5
	DEBUG_FPS = true
end

--是否是越狱包
IS_PRISONBAG = 0

--AppStore支付沙盒模式开关
IS_SANDBOX = false

-- dump memory info every 10 seconds
DEBUG_MEM = false

-- load deprecated API
LOAD_DEPRECATED_API = false

-- load shortcodes API
LOAD_SHORTCODES_API = true

DISABLE_DEPRECATED_WARNING = false

-- screen orientation
CONFIG_SCREEN_ORIENTATION = "landscape"

-- design resolution
CONFIG_SCREEN_WIDTH  = 960
CONFIG_SCREEN_HEIGHT = 640

SHOW_SCROLLVIEW_BORDER = false --是否显示边框

-- auto scale mode
local glview = cc.Director:getInstance():getOpenGLView()
local size = glview:getFrameSize()
local w = size.width
local h = size.height
if w / h >= CONFIG_SCREEN_WIDTH / CONFIG_SCREEN_HEIGHT then
    CONFIG_SCREEN_AUTOSCALE = "FIXED_HEIGHT"
else
    CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH"
end

