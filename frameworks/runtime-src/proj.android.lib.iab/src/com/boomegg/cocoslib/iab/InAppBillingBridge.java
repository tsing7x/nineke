package com.boomegg.cocoslib.iab;

import java.util.List;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import android.util.Log;

import com.boomegg.cocoslib.core.Cocos2dxActivityUtil;
import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;
import com.boomegg.cocoslib.core.IPlugin;

public class InAppBillingBridge {
	private static final String TAG = InAppBillingBridge.class.getSimpleName();

	private static int setupCompleteCallbackMethodId = -1;
	private static int loadProductCompleteCallbackMethodId = -1;
	private static int purchaseCompleteCallbackMethodId = -1;
	private static int deliveryMethodId = -1;
	private static int consumeCompleteCallbackMethodId = -1;

	private static InAppBillingPlugin getInAppBillingPlugin() {
		List<IPlugin> list = Cocos2dxActivityWrapper.getContext()
				.getPluginManager().findPluginByClass(InAppBillingPlugin.class);
		if (list != null && list.size() > 0) {
			return (InAppBillingPlugin) list.get(0);
		} else {
			Log.d(TAG, "InAppBillingPlugin not found");
		}
		return null;
	}

	// ////////////////// FROM LUA

	public static boolean isSetupComplete() {
		InAppBillingPlugin iab = getInAppBillingPlugin();
		boolean isSetupComplete = false;
		if (iab != null) {
			isSetupComplete = iab.isSetupComplete();
		}
		Log.d(TAG, "isSetupComplete " + isSetupComplete);
		return isSetupComplete;
	}

	public static boolean isSupported() {
		InAppBillingPlugin iab = getInAppBillingPlugin();
		boolean isSupported = false;
		if (iab != null) {
			isSupported = iab.isSupported();
		}
		Log.d(TAG, "isSupported " + isSupported);
		return isSupported;
	}

	public static void setup() {
		Log.d(TAG, "setup");
		final InAppBillingPlugin iab = getInAppBillingPlugin();
		if (iab != null) {
			Cocos2dxActivityUtil.runOnBGThreadDelay(new Runnable() {
				@Override
				public void run() {
					iab.setup();
				}
			}, 50);
		}
	}

	public static void loadProductList(String joinedSkuList) {
		Log.d(TAG, "loadProductList " + joinedSkuList);
		final InAppBillingPlugin iab = getInAppBillingPlugin();
		if (iab != null) {
			final String[] skus = joinedSkuList.split(",");
			Cocos2dxActivityUtil.runOnBGThread(new Runnable() {
				@Override
				public void run() {
					iab.loadProductList(skus);
				}
			});
		}
	}

	public static void makePurchase(final String orderId, final String sku,
			final String uid, final String channel) {
		Log.d(TAG, "makePurchase " + orderId + " " + sku + " " + uid + " "
				+ channel);
		final InAppBillingPlugin iab = getInAppBillingPlugin();
		if (iab != null) {
			Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
				@Override
				public void run() {
					iab.makePurchase(orderId, sku, uid, channel);
				}
			}, 50);
		}
	}

	public static void consume(final String sku) {
		Log.d(TAG, "consume " + sku);
		final InAppBillingPlugin iab = getInAppBillingPlugin();
		if (iab != null) {
			Cocos2dxActivityUtil.runOnBGThread(new Runnable() {
				@Override
				public void run() {
					iab.consume(sku);
				}
			});
		}
	}

	public static void delayDispose(final int delaySeconds) {
		Log.d(TAG, "delayDispose " + delaySeconds);
		final InAppBillingPlugin iab = getInAppBillingPlugin();
		if (iab != null) {
			Cocos2dxActivityUtil.runOnUIThread(new Runnable() {
				@Override
				public void run() {
					iab.delayDispose(delaySeconds);
				}
			});
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

	public static void setLoadProductsCompleteCallback(int methodId) {
		if (loadProductCompleteCallbackMethodId != -1) {
			Cocos2dxLuaJavaBridge
					.releaseLuaFunction(loadProductCompleteCallbackMethodId);
			loadProductCompleteCallbackMethodId = -1;
		}
		if (methodId != -1) {
			loadProductCompleteCallbackMethodId = methodId;
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

	public static void setDeliveryMethod(int methodId) {
		if (deliveryMethodId != -1) {
			Cocos2dxLuaJavaBridge.releaseLuaFunction(deliveryMethodId);
			deliveryMethodId = -1;
		}
		if (methodId != -1) {
			deliveryMethodId = methodId;
		}
	}

	public static void setConsumeCompleteCallback(int methodId) {
		if (consumeCompleteCallbackMethodId != -1) {
			Cocos2dxLuaJavaBridge
					.releaseLuaFunction(consumeCompleteCallbackMethodId);
			consumeCompleteCallbackMethodId = -1;
		}
		if (methodId != -1) {
			consumeCompleteCallbackMethodId = methodId;
		}
	}

	// ///////////////// TO LUA

	static void callLuaDeliveryMethod(final String jsonString) {
		Log.d(TAG, "callLuaDeliveryMethod " + jsonString);
		if (deliveryMethodId != -1) {
			Cocos2dxActivityUtil.runOnResumed(new Runnable() {
				@Override
				public void run() {
					Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
						@Override
						public void run() {
							Cocos2dxLuaJavaBridge.callLuaFunctionWithString(
									deliveryMethodId, jsonString);
						}
					});
				}
			});
		}
	}

	static void callLuaSteupCompleteCallbackMethod(final boolean isSupported) {
		Log.d(TAG, "callLuaSteupCompleteCallbackMethod " + isSupported);
		if (setupCompleteCallbackMethodId != -1) {
			Cocos2dxActivityUtil.runOnResumed(new Runnable() {
				@Override
				public void run() {
					Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
						@Override
						public void run() {
							Cocos2dxLuaJavaBridge.callLuaFunctionWithString(
									setupCompleteCallbackMethodId,
									String.valueOf(isSupported));
						}
					});
				}
			});
		}
	}

	static void callLuaLoadProductsCompleteCallbackMethod(final String products) {
		Log.d(TAG, "callLuaLoadProductsCompleteCallbackMethod " + products);
		if (loadProductCompleteCallbackMethodId != -1) {
			Cocos2dxActivityUtil.runOnResumed(new Runnable() {
				@Override
				public void run() {
					Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
						@Override
						public void run() {
							Cocos2dxLuaJavaBridge.callLuaFunctionWithString(
									loadProductCompleteCallbackMethodId,
									products);
						}
					});
				}
			});
		}
	}

	static void callLuaPurchaseCompleteCallbackMethod(final String result) {
		Log.d(TAG, "callLuaPurchaseCompleteCallbackMethod " + result);
		if (purchaseCompleteCallbackMethodId != -1) {
			Cocos2dxActivityUtil.runOnResumed(new Runnable() {
				@Override
				public void run() {
					Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
						@Override
						public void run() {
							Cocos2dxLuaJavaBridge.callLuaFunctionWithString(
									purchaseCompleteCallbackMethodId, result);
						}
					});
				}
			});
		}
	}

	static void callLuaConsumeCompleteCallbackMethod(final String result) {
		Log.d(TAG, "callLuaConsumeCompleteCallbackMethod " + result);
		if (consumeCompleteCallbackMethodId != -1) {
			Cocos2dxActivityUtil.runOnResumed(new Runnable() {
				@Override
				public void run() {
					Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
						@Override
						public void run() {
							Cocos2dxLuaJavaBridge.callLuaFunctionWithString(
									consumeCompleteCallbackMethodId, result);
						}
					});
				}
			});
		}
	}

}
