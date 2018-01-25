#include "cocos2d.h"
#import "platform/ios/CCEAGLView-ios.h"

extern "C" {
#import "lua.h"
#import "lauxlib.h"
}

#import "SimpleWebview.h"

USING_NS_CC;

extern "C" {
	int luaopen_webview(lua_State *L);
}

#define WEBVIEW_META_NAME "webview_meta_ios"

static int webview_create(lua_State *L) {
	if (lua_isfunction(L, 1) && lua_isfunction(L, 2) && lua_isfunction(L, 3)
		&& lua_isfunction(L, 4)) {
		WebView_iOS ** view = (WebView_iOS **)lua_newuserdata(L, sizeof(WebView_iOS *));
		
		lua_pushvalue(L, 1);
		int s = luaL_ref(L, LUA_REGISTRYINDEX);
		lua_pushvalue(L, 2);
		int f = luaL_ref(L, LUA_REGISTRYINDEX);
		lua_pushvalue(L, 3);
		int fail = luaL_ref(L, LUA_REGISTRYINDEX);
		lua_pushvalue(L, 4);
		int close = luaL_ref(L, LUA_REGISTRYINDEX);
		lua_pushvalue(L, 5);
		int shouldStartLoad = luaL_ref(L, LUA_REGISTRYINDEX);
		
		*view = [[WebView_iOS alloc] init];
		[*view setLuaCallback_start: s finish :f  fail: fail close: close shouldStartLoad:shouldStartLoad];
		
		luaL_getmetatable(L, WEBVIEW_META_NAME);
		lua_setmetatable(L, -2);
		
		return 1;
	} else {
		lua_pushnil(L);
		lua_pushstring(L, "Webview.create() wrong argument");
		return 2;
	}
}

static const luaL_Reg webview_lib[] = {
	{"create", webview_create},
	{NULL, NULL}
};

static int webview_show(lua_State *L) {
	if (lua_gettop(L) != 5) {
		lua_pushnil(L);
		lua_pushstring(L, "show() wrong argument");
		return 2;
	} else {
		luaL_checktype(L, 1, LUA_TUSERDATA);
		luaL_checktype(L, 2, LUA_TNUMBER);
		luaL_checktype(L, 3, LUA_TNUMBER);
		luaL_checktype(L, 4, LUA_TNUMBER);
		luaL_checktype(L, 5, LUA_TNUMBER);
		
		WebView_iOS **wv = (WebView_iOS **)lua_touserdata(L, 1);
		double x = lua_tonumber(L, 2);
		double y = lua_tonumber(L, 3);
		double width = lua_tonumber(L, 4);
		double height = lua_tonumber(L, 5);
		
        cocos2d::GLView *glview = cocos2d::Director::getInstance()->getOpenGLView();
        CCEAGLView *eaglview = (CCEAGLView*) glview->getEAGLView();
        
        cocos2d::Size designsize = glview->getDesignResolutionSize();
		cocos2d::Size framesize = glview->getFrameSize();
		float sx = glview->getScaleX();
		float sy = glview->getScaleY();
		cocos2d::Size designframe(framesize.width / sx, framesize.height / sy);
		
		// 这里可能需要根据ResolutionPolicy进行修改。
		float ratio = designsize.height / framesize.height;
		
		Vec2 orig((designframe.width - designsize.width) / 2, (designframe.height - designsize.height) / 2);
		
		x = x / ratio + orig.x / ratio; y = y / ratio + orig.y / ratio;
		width /= ratio; height /= ratio;
		
		[*wv showWebView_x:x y:y width:width height:height];
		return 0;
	}
}

static int webview_update_url(lua_State *L) {
	luaL_checktype(L, 1, LUA_TUSERDATA);
	luaL_checktype(L, 2, LUA_TSTRING);
	WebView_iOS **wv = (WebView_iOS**)lua_touserdata(L, 1);
	const char * url = lua_tostring(L, 2);
	[*wv updateURL:url];
	return 0;
}

static int webview_dispose(lua_State *L) {
	luaL_checktype(L, 1, LUA_TUSERDATA);
	WebView_iOS **wv = (WebView_iOS**)lua_touserdata(L, 1);
	[*wv removeWebView];
	return 0;
}

static int webview_gc(lua_State *L) {
	if (lua_isuserdata(L, 1)) {
		WebView_iOS **wv = (WebView_iOS**)lua_touserdata(L, 1);
		int w, x, y, z, q;
		[*wv getLuaCallback_start:&w finish:&x fail:&y close: &z shouldStartLoad: &q];
		[*wv release];
		luaL_unref(L, LUA_REGISTRYINDEX, w);
		luaL_unref(L, LUA_REGISTRYINDEX, x);
		luaL_unref(L, LUA_REGISTRYINDEX, y);
		luaL_unref(L, LUA_REGISTRYINDEX, z);
		luaL_unref(L, LUA_REGISTRYINDEX, q);
	}
	return 0;
}

static int webview_set_closeBtn_visible(lua_State *L) {
	luaL_checktype(L, 1, LUA_TUSERDATA);
	luaL_checktype(L, 2, LUA_TBOOLEAN);
	WebView_iOS **wv = (WebView_iOS**)lua_touserdata(L, 1);
	const bool visible = lua_toboolean(L, 2);
	[*wv setCloseBtnVisible:visible];
	return 0;
}

static int webview_set_background_color(lua_State *L){
	luaL_checktype(L, 1, LUA_TUSERDATA);
	luaL_checktype(L, 2, LUA_TNUMBER);
	luaL_checktype(L, 3, LUA_TNUMBER);
	luaL_checktype(L, 4, LUA_TNUMBER);
	luaL_checktype(L, 5, LUA_TNUMBER);
	WebView_iOS **wv = (WebView_iOS**)lua_touserdata(L, 1);
	const float  r = lua_tonumber(L, 2);
	const float  g = lua_tonumber(L, 3);
	const float  b = lua_tonumber(L, 4);
	const float  a = lua_tonumber(L, 5);
	[*wv setBackgroundColor_r:r g:g b:b a:a];
	return 0;
}

static const luaL_reg wv_meta_lib[] = {
	{"show", webview_show},
	{"updateURL", webview_update_url},
	{"dispose", webview_dispose},// not used yet
	{"__gc", webview_gc},
	{"setCloseBtnVisible",webview_set_closeBtn_visible},
	{"setBackgroundColor",webview_set_background_color},
	{NULL, NULL}
};

static void create_webview_meta(lua_State *L) {
	luaL_newmetatable(L, WEBVIEW_META_NAME);
	lua_pushvalue(L, -1);
	lua_setfield(L, -2, "__index");
	luaL_register(L, NULL, wv_meta_lib);
}

int luaopen_webview(lua_State *L) {
	create_webview_meta(L);
	luaL_register(L, "Webview", webview_lib);
	return 1;
}
