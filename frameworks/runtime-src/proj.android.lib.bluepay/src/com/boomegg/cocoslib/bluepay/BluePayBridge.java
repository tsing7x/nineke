package com.boomegg.cocoslib.bluepay;

import java.util.List;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import com.boomegg.cocoslib.core.Cocos2dxActivityUtil;
import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;
import com.boomegg.cocoslib.core.IPlugin;

import android.util.Log;

public class BluePayBridge {
	static final String TAG = BluePayBridge.class.getSimpleName();
	
	private static int setupCompleteCallbackMethodId = -1;
	private static int purchaseCompleteCallbackMethodId = -1;
	
	private static BluePayPlugin getBluePayPlugin() {
		List<IPlugin> list = Cocos2dxActivityWrapper.getContext()
				.getPluginManager().findPluginByClass(BluePayPlugin.class);
		if (list != null && list.size() > 0) {
			return (BluePayPlugin) list.get(0);
		} else {
			Log.d(TAG, "BluePayPlugin not found");
			return null;
		}
	}
	
	public static boolean isSetupComplete() {
		BluePayPlugin bluePay = getBluePayPlugin();
		boolean isSetupComplete = false;
		if (bluePay != null) {
			isSetupComplete = bluePay.isSetupComplete();
		}
		Log.d(TAG, "isSetupComplete " + isSetupComplete);
		return isSetupComplete;
	}

	public static boolean isSupported() {
		BluePayPlugin bluePay = getBluePayPlugin();
		boolean isSupported = false;
		if (bluePay != null) {
			isSupported = bluePay.isSupported();
		}
		Log.d(TAG, "isSupported " + isSupported);
		return isSupported;
	}
	
	
	public static void setup() {
		Log.d(TAG, "setup");
		final BluePayPlugin bluePay = getBluePayPlugin();
		if (bluePay != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				@Override
				public void run() {
					bluePay.setup();
				}
			}, 50);
		}
	}
	
	
	public static void setSetupCompleteCallback(int methodId) {
		if (setupCompleteCallbackMethodId != -1) {
			Cocos2dxLuaJavaBridge
					.releaseLuaFunction(setupCompleteCallbackMethodId);
			setupCompleteCallbackMethodId = -1;
		}
		if (methodId != -1) {
			setupCompleteCallbackMethodId = methodId;
		}
	}
	
	public static void setPurchaseCompleteCallback(int methodId) {
		if (purchaseCompleteCallbackMethodId != -1) {
			Cocos2dxLuaJavaBridge
					.releaseLuaFunction(purchaseCompleteCallbackMethodId);
			purchaseCompleteCallbackMethodId = -1;
		}
		if (methodId != -1) {
			purchaseCompleteCallbackMethodId = methodId;
		}
	}
	
	
	public static void payBySMS(final String uid,final String pid,final String transactionId,final String currency,final String price,final int smsId,final String propsName,final boolean isShowDialog) {
		Log.d(TAG, "payBySMS-> " + "orderId:" + transactionId + "pid: " + pid + "uid: " + uid + " currency:"+ currency + " price:" + price + " smsId:" + smsId + "propsName:" + propsName + " isShowDialog:" + String.valueOf(isShowDialog) );
		final BluePayPlugin bluePay = getBluePayPlugin();
		if (bluePay != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				@Override
				public void run() {
					bluePay.payBySMS(uid, pid, transactionId, currency, price, smsId, propsName, isShowDialog);
				}
			}, 50);
		}
	}
	
	
	
	public static void payByCashcard(final String uid,final String pid, final String transactionId, final String propsName, final String publicer, final String cardNo, final String serialNo){
		Log.d(TAG, "payByCashcard-> " + "orderId:" + transactionId + "pid: " + pid + "uid: " + uid + " publicer:" + publicer + " propsName:"+propsName );
		final BluePayPlugin bluePay = getBluePayPlugin();
		if (bluePay != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				@Override
				public void run() {
					bluePay.payByCashcard( uid, pid,  transactionId,  propsName,  publicer,  cardNo,  serialNo);
				}
			}, 50);
		}
	}
	
	public static void payByBank(final String uid,final String pid,final String transactionId,final String currency,final String price,final String propsName,final boolean isShowDialog) {
		Log.d(TAG, "payByBank-> " + "orderId:" + transactionId + "pid: " + pid + "uid: " + uid + " currency:"+ currency + " price:" + price + "propsName:" + propsName + " isShowDialog:" + String.valueOf(isShowDialog) );
		final BluePayPlugin bluePay = getBluePayPlugin();
		if (bluePay != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				@Override
				public void run() {
					bluePay.payByBank(uid, pid, transactionId, currency, price, propsName, isShowDialog);
				}
			}, 50);
		}
	}
	
	static void callLuaSteupCompleteCallbackMethod(final boolean isSupported) {
		Log.d(TAG, "callLuaSteupCompleteCallbackMethod " + isSupported);
		if (setupCompleteCallbackMethodId != -1) {
//			Cocos2dxActivityUtil.runOnResumed(new Runnable() {
//				@Override
//				public void run() {
					Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
						@Override
						public void run() {
							Cocos2dxLuaJavaBridge.callLuaFunctionWithString(
									setupCompleteCallbackMethodId,
									String.valueOf(isSupported));
						}
					});
//				}
//			});
		}
	}
	
	
	static void callLuaPurchaseCompleteCallbackMethod(final String result) {
		Log.d(TAG, "callLuaPurchaseCompleteCallbackMethod " + result);
		if (purchaseCompleteCallbackMethodId != -1) {
//			Cocos2dxActivityUtil.runOnResumed(new Runnable() {
//				@Override
//				public void run() {
					Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
						@Override
						public void run() {
							Cocos2dxLuaJavaBridge.callLuaFunctionWithString(
									purchaseCompleteCallbackMethodId, result);
						}
					});
//				}
//			});
		}
	}
	
	
	
}
