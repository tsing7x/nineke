package com.boomegg.cocoslib.gcm;

import java.util.List;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.json.JSONException;
import org.json.JSONObject;

import android.util.Log;

import com.boomegg.cocoslib.core.Cocos2dxActivityUtil;
import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;
import com.boomegg.cocoslib.core.IPlugin;

public class GoogleCloudMessagingBridge {
	private static final String TAG = GoogleCloudMessagingBridge.class.getSimpleName();
	private static int registeredCallbackId = -1;
	
	//for lua
	public static void setRegisteredCallback(int methodId) {
		if(registeredCallbackId != -1) {
			Cocos2dxLuaJavaBridge.releaseLuaFunction(registeredCallbackId);
			registeredCallbackId = -1;
		}
		registeredCallbackId = methodId;
	}
	
	public static void register() {
		Cocos2dxActivityUtil.runOnBGThread(new Runnable() {
			@Override
			public void run() {
				GoogleCloudMessagingPlugin plugin = getGoogleCloudMessagingPlugin();
				if(plugin != null) {
					Log.d(TAG, "register begin");
					plugin.register();
					Log.d(TAG, "register end");
				}
			}
		});
	}
	
	// to lua
	static void callRegisteredCallback(final String eventType, final boolean success, final String detail) {
		Cocos2dxActivityUtil.runOnResumed(new Runnable() {
			@Override
			public void run() {
				Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
					@Override
					public void run() {
						JSONObject json = new JSONObject();
						try {
							json.put("type", eventType);
							json.put("success", success);
							json.put("detail", detail);
							Cocos2dxLuaJavaBridge.callLuaFunctionWithString(registeredCallbackId, json.toString());
						} catch (JSONException e) {
							Log.e(TAG, e.getMessage(), e);
						}
					}
				});
			}
		});
	}
	
	private static GoogleCloudMessagingPlugin getGoogleCloudMessagingPlugin() {
		if(Cocos2dxActivityWrapper.getContext() != null) {
			List<IPlugin> list = Cocos2dxActivityWrapper.getContext().getPluginManager().findPluginByClass(GoogleCloudMessagingPlugin.class);
			if(list != null && list.size() > 0) {
				return (GoogleCloudMessagingPlugin) list.get(0);
			}else {
				Log.d(TAG, "GoogleCloudMessagingPlugin not found");
			}
		}
		return null;
	}
}
