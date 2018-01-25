package com.boomegg.cocoslib.easy2payapi;

import java.util.List;
import java.util.Map;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.json.JSONObject;

import com.boomegg.cocoslib.core.Cocos2dxActivityUtil;
import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;
import com.boomegg.cocoslib.core.IPlugin;

import android.util.Log;

public class Easy2PayApiBridge {

	
private static int callbackId = -1;
	
	// call from LUA
	
	public static void setCallback(int callback) {
		if(callbackId != -1) {
			Cocos2dxLuaJavaBridge.releaseLuaFunction(callbackId);
			callbackId = -1;
		}
		callbackId = callback;
	}
	
	static final String TAG = Easy2PayApiBridge.class.getSimpleName();
	public static void makePurchase(final String ptxId, final String userId, final String merchantId, final String priceId) {
		final Easy2PayApiPlugin e2p = getEasy2PayApiPlugin();
		if(e2p != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				@Override
				public void run() {
					e2p.makePurchase(ptxId, userId, merchantId, priceId);
				}
			}, 50);
		}
	}
	
	static void callCallback(final Map<String, String> dataMap) {
		if(callbackId != -1 && dataMap != null) {
			Cocos2dxActivityUtil.runOnResumed(new Runnable() {
				@Override
				public void run() {
					if(callbackId != -1) {
						Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
							@Override
							public void run() {
								if(callbackId != -1) {
									JSONObject json = null;
									try {
										json = new JSONObject(dataMap);
										Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callbackId, json.toString());
									} catch(Exception e) {
										Log.e(TAG, "json encode error " + e.getMessage(), e);
									}
								}
							}
						});
					}
				}
			});
		}
	}
	
	private static Easy2PayApiPlugin getEasy2PayApiPlugin() {
		List<IPlugin> list = Cocos2dxActivityWrapper.getContext()
				.getPluginManager().findPluginByClass(Easy2PayApiPlugin.class);
		if (list != null && list.size() > 0) {
			return (Easy2PayApiPlugin) list.get(0);
		} else {
			Log.d(TAG, "Easy2PayApiPlugin not found");
			return null;
		}
	}
}
