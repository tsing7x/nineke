package com.boomegg.cocoslib.core.functions;

import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import com.boomegg.cocoslib.core.Cocos2dxActivityUtil;
import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;

public class ShowLineViewFunction {
	private static int callbackMethodId = -1;
	
	public static void apply(final String content, int methodId) {
		if(callbackMethodId != -1) {
			Cocos2dxLuaJavaBridge.releaseLuaFunction(callbackMethodId);
			callbackMethodId = -1;
		}
		callbackMethodId = methodId;
		
		final Cocos2dxActivityWrapper ctx = Cocos2dxActivityWrapper.getContext();
		if(ctx != null) {
			ctx.runOnUiThread(new Runnable() {
//				@Override
				public void run() {
					Intent appIntent = new Intent(Intent.ACTION_VIEW);
					String appUrl= "line://msg/text/" + content;
					appIntent.setData(Uri.parse(appUrl));
					
					try {
						ctx.startActivity(appIntent);
					}catch(ActivityNotFoundException e) {
						ShowLineViewCallback("nolineapp");
					} catch(Exception e) {
						Log.e(ShowLineViewFunction.class.getSimpleName(), e.getMessage(), e);
					}
				}
				
				
			});
		}
		
	}
	
	public static void ShowLineViewCallback(final String result) {
		Cocos2dxActivityUtil.runOnResumed(new Runnable() {
			@Override
			public void run() {
				Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
					@Override
					public void run() {
						if(callbackMethodId != -1) {
							Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callbackMethodId, result);
						}
					}
				});
			}
		});
	}
}
