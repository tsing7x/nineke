package com.boyaa.cocoslib.godsdk;

import java.util.List;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import android.util.Log;

import com.boomegg.cocoslib.core.Cocos2dxActivityUtil;
import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;
import com.boomegg.cocoslib.core.IPlugin;

public class GodSdkBridge {
	private static final String TAG = GodSdkBridge.class.getSimpleName();
	
	private static int iabPurchaseCallbackMethodId = -1;
	private static int iabQueryUnfinishedIAPCallbackMethodId = -1;
	private static int iabLoadProductListCallbackMethodId = -1;
	
	private static GodSdkPlugin getGodSdkPlugin() {
		List<IPlugin> list = Cocos2dxActivityWrapper.getContext().getPluginManager()
				.findPluginByClass(GodSdkPlugin.class);
		if (list != null && list.size() > 0) {
			return (GodSdkPlugin)list.get(0);
		}else {
			Log.e(TAG, "GodSdkPlugin not found");
			return null;
		}
	}
	
	public static void setIabPurchaseCallback(int methodId) {
		if (iabPurchaseCallbackMethodId != -1) {
			Cocos2dxLuaJavaBridge.releaseLuaFunction(iabPurchaseCallbackMethodId);
			iabPurchaseCallbackMethodId = -1;
		}
		
		if (methodId != -1) {
			iabPurchaseCallbackMethodId = methodId;
		}
	}
	
	public static void setIabQueryUnfinishedIapCallback(int methodId) {
		if (iabQueryUnfinishedIAPCallbackMethodId != -1) {
			Cocos2dxLuaJavaBridge.releaseLuaFunction(iabQueryUnfinishedIAPCallbackMethodId);
			iabQueryUnfinishedIAPCallbackMethodId = -1;
		}
		
		if (methodId != -1) {
			iabQueryUnfinishedIAPCallbackMethodId = methodId;
		}
	}
	
	public static void setIabLoadProductListCallback(int methodId) {
		if (iabLoadProductListCallbackMethodId != -1) {
			Cocos2dxLuaJavaBridge.releaseLuaFunction(iabLoadProductListCallbackMethodId);
			iabLoadProductListCallbackMethodId = -1;
		}
		
		if (methodId != -1) {
			iabLoadProductListCallbackMethodId = methodId;
		}
	}
	
	public static void iabPurchase(final String param) {
		final GodSdkPlugin godSdkPlugin = getGodSdkPlugin();
		if (godSdkPlugin != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				
				@Override
				public void run() {
					// TODO Auto-generated method stub
					Log.d(TAG, "iabPurchase Called!");
					
					godSdkPlugin.makeIabPurchase(param);
				}
			}, 50);
		}
	}
	
	public static void iabConsumeProduct(final String productId) {
		final GodSdkPlugin godSdkPlugin = getGodSdkPlugin();
		if (godSdkPlugin != null) {
			Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
				
				@Override
				public void run() {
					// TODO Auto-generated method stub
					godSdkPlugin.consumeIabProduct(productId);
				}
			});
		}
	}
	
	public static void iabQueryUnfinishedIAP() {
		final GodSdkPlugin godSdkPlugin = getGodSdkPlugin();
		if (godSdkPlugin != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				
				@Override
				public void run() {
					// TODO Auto-generated method stub
					godSdkPlugin.queryUnfinishedIAP();
				}
			}, 50);
		}
	}
	
	public static void iabLoadProductList(final String skuList) {
		final GodSdkPlugin godSdkPlugin = getGodSdkPlugin();
		if (godSdkPlugin != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				
				@Override
				public void run() {
					// TODO Auto-generated method stub
					godSdkPlugin.loadProductList(skuList);
				}
			}, 50);
		}
	}
	
//	public static void iabQuit() {
//		final GodSdkPlugin godSdkPlugin = getGodSdkPlugin();
//		if (godSdkPlugin != null) {
//			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
//				
//				@Override
//				public void run() {
//					// TODO Auto-generated method stub
//					godSdkPlugin.quit();
//				}
//			}, 50);
//		}
//	}
	
	static void callLuaByIabPurchaseCallbackMethod(final String result){
		if (iabPurchaseCallbackMethodId != -1) {
			Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
				@Override
				public void run() {
					// TODO Auto-generated method stub
					Cocos2dxLuaJavaBridge.callLuaFunctionWithString(iabPurchaseCallbackMethodId, result);
				}
			});
		}
	}
	
	static void callLuaByIabQueryUnfinishedIAPCallbackMethod(final String result){
		if (iabQueryUnfinishedIAPCallbackMethodId != -1) {
			Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
				
				@Override
				public void run() {
					// TODO Auto-generated method stub
					Cocos2dxLuaJavaBridge.callLuaFunctionWithString(iabQueryUnfinishedIAPCallbackMethodId, result);
				}
			});
		}
	}
	
	static void callLuaByIabLoadProductCallbackMethod(final String result){
		if (iabLoadProductListCallbackMethodId != -1) {
			Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
				
				@Override
				public void run() {
					// TODO Auto-generated method stub
					Cocos2dxLuaJavaBridge.callLuaFunctionWithString(iabLoadProductListCallbackMethodId, result);
				}
			});
		}
	}
}
