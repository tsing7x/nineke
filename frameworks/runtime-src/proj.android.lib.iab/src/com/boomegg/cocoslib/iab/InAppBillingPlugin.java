package com.boomegg.cocoslib.iab;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.apache.http.NameValuePair;
import org.apache.http.client.utils.URLEncodedUtils;
import org.apache.http.message.BasicNameValuePair;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import com.boomegg.cocoslib.core.Cocos2dxActivityUtil;
import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;
import com.boomegg.cocoslib.core.IPlugin;
import com.boomegg.cocoslib.core.LifecycleObserverAdapter;
import com.boomegg.cocoslib.iab.util.IabHelper;
import com.boomegg.cocoslib.iab.util.IabResult;
import com.boomegg.cocoslib.iab.util.Inventory;
import com.boomegg.cocoslib.iab.util.Purchase;
import com.boomegg.cocoslib.iab.util.SkuDetails;

/**
 * @author tony<tony@boomegg.com>
 */
public class InAppBillingPlugin extends LifecycleObserverAdapter implements IPlugin {
	private static final String TAG = InAppBillingPlugin.class.getSimpleName();
	private static final int REQUEST_CODE = 985451345;
	
	private IabHelper helper;
	private String base64EncodedPublicKey;
	private boolean isDebug;
	
	private boolean isSetupComplete = false;
	private boolean isSetuping = false;
	private boolean isSupported = false;
	private boolean isLoadingProductList = false;
	private List<String> skuList = null;
	private Inventory inventory;
	private boolean isPurchasing = false;
	
	private int retryLimit = 4;
	protected String id;
	
	public InAppBillingPlugin(String base64EncodedPublicKey, boolean isDebug) {
		this.base64EncodedPublicKey = base64EncodedPublicKey;
		this.isDebug = isDebug;
	}
	
	@Override
	public void initialize() {
		Cocos2dxActivityWrapper.getContext().addObserver(this);
		disposeRunnable.run();
	}

	@Override
	public void onCreate(Activity activity, Bundle savedInstanceState) {
		if(helper != null) {
			disposeRunnable.run();
		}
		helper = new IabHelper(activity, base64EncodedPublicKey);
		//调试开关
		helper.enableDebugLogging(isDebug, "InAppBillingPlugin");
	}
	
	@Override
	public void onDestroy(Activity activity) {
		disposeRunnable.run();
	}
	
	private IabHelper.OnIabSetupFinishedListener setupFinishedListener = new IabHelper.OnIabSetupFinishedListener() {
		public void onIabSetupFinished(IabResult result) {
			Log.i(TAG, "Setup finished.");
			if (!result.isSuccess()) {
				// Oh noes, there was a problem.
				Log.e(TAG, "Problem setting up in-app billing: " + result);
				if(retryLimit-- > 0) {
					Log.i(TAG, "retry ... limit left " + retryLimit);
					helper.startSetup(setupFinishedListener);
				} else {
					isSetupComplete = true;
					isSetuping = false;
					isSupported = false;
					InAppBillingBridge.callLuaSteupCompleteCallbackMethod(false);
				}
			} else {
				Log.i(TAG, "Setup successful.");
				isSetupComplete = true;
				isSetuping = false;
				isSupported = true;
				InAppBillingBridge.callLuaSteupCompleteCallbackMethod(true);
			}
		}
    };
    
    private IabHelper.QueryInventoryFinishedListener gotInventoryListener = new IabHelper.QueryInventoryFinishedListener() {
		public void onQueryInventoryFinished(IabResult result, Inventory inventory) {
			Log.d(TAG, "Query inventory finished.");

			// Have we been disposed of in the meantime? If so, quit.
			if (helper == null)
				return;

			// Is it a failure?
			if (result.isFailure()) {
				if(retryLimit-- > 0) {
					helper.queryInventoryAsync(true, skuList, gotInventoryListener);
				} else {
					Log.e(TAG, "Failed to query inventory: " + result);
					isLoadingProductList = false;
					InAppBillingBridge.callLuaLoadProductsCompleteCallbackMethod("fail");
				}
			} else {
				Log.i(TAG, "Query inventory was successful.");
				isLoadingProductList = false;
				InAppBillingPlugin.this.inventory = inventory;
				JSONArray array = new JSONArray();
				if(skuList != null) {
					for(String sku : skuList) {
						SkuDetails detail = inventory.getSkuDetails(sku);
						if(detail != null) {
							JSONObject json = new JSONObject();
							try {
								json.put("description", detail.getDescription());
								json.put("price", detail.getPrice());
								json.put("sku", detail.getSku());
								json.put("title", detail.getTitle());
								json.put("type", detail.getType());
								json.put("priceNum", detail.getPriceNum());
								json.put("priceDollar", detail.getPriceDollar());
								array.put(json);
							} catch(JSONException e) {
								Log.e(TAG, e.getMessage(), e);
							}
						} else {
							Log.d(TAG, "sku detail not found -> " + sku);
						}
						Purchase purchase = inventory.getPurchase(sku);
						if(purchase != null) {
							Log.d(TAG, "found purchased item -> " + purchase.toString());
							JSONObject json = new JSONObject();
							try {
								json.put("purchaseTime", purchase.getPurchaseTime());
								json.put("developerPayload", purchase.getDeveloperPayload());
								json.put("itemType", purchase.getItemType());
								json.put("orderId", purchase.getOrderId());
								json.put("originalJson", purchase.getOriginalJson());
								json.put("packageName", purchase.getPackageName());
								json.put("signature", purchase.getSignature());
								json.put("sku", purchase.getSku());
								json.put("token", purchase.getToken());
								json.put("purchaseState", purchase.getPurchaseState());
							} catch(JSONException e) {
								Log.e(TAG, e.getMessage(), e);
							}
							InAppBillingBridge.callLuaDeliveryMethod(json.toString());
						}
					}
				}
				String prdListJson = array.toString();
				Log.d(TAG, "query products return -> " + prdListJson);
				InAppBillingBridge.callLuaLoadProductsCompleteCallbackMethod(prdListJson);
			}
		}
	};
	
	private IabHelper.OnIabPurchaseFinishedListener purchaseFinishedListener = new IabHelper.OnIabPurchaseFinishedListener() {
		public void onIabPurchaseFinished(IabResult result, Purchase purchase) {
			Log.i(TAG, "Purchase finished: " + result + ", purchase: " + purchase);
			isPurchasing = false;
			
			// if we were disposed of in the meantime, quit.
			if (helper == null)
				return;
			
			if(inventory != null && purchase != null && !inventory.hasPurchase(purchase.getSku())) {
				inventory.addPurchase(purchase);
			}
			
			if (result.isFailure()) {
				if(purchase == null && inventory != null) {
					purchase = inventory.getPurchase(purchasingSku);
				}
				if(result.getResponse() == 7 && purchase != null) {
					//7:Item Already Owned
					JSONObject json = new JSONObject();
					try {
						json.put("purchaseTime", purchase.getPurchaseTime());
						json.put("developerPayload", purchase.getDeveloperPayload());
						json.put("itemType", purchase.getItemType());
						json.put("orderId", purchase.getOrderId());
						json.put("originalJson", purchase.getOriginalJson());
						json.put("packageName", purchase.getPackageName());
						json.put("signature", purchase.getSignature());
						json.put("sku", purchase.getSku());
						json.put("token", purchase.getToken());
						json.put("purchaseState", purchase.getPurchaseState());
						InAppBillingBridge.callLuaPurchaseCompleteCallbackMethod(json.toString());
					} catch(JSONException e) {
						Log.e(TAG, e.getMessage(), e);
					}
				} else if (result.getResponse() == IabHelper.BILLING_RESPONSE_RESULT_USER_CANCELED) {
					InAppBillingBridge.callLuaPurchaseCompleteCallbackMethod("fail:canceled");
				} else {
					// InAppBillingBridge.callLuaPurchaseCompleteCallbackMethod("fail");
					InAppBillingBridge.callLuaPurchaseCompleteCallbackMethod("fail:code->" + result.getResponse() + ",msg->" +
						result.getMessage());
				}
			} else {
				if (purchase.getPurchaseState() == Purchase.PURCHASE_STATE_PURCHASED) {
					Log.i(TAG, "Purchase successful.");
					
					JSONObject json = new JSONObject();
					try {
						json.put("purchaseTime", purchase.getPurchaseTime());
						json.put("developerPayload", purchase.getDeveloperPayload());
						json.put("itemType", purchase.getItemType());
						json.put("orderId", purchase.getOrderId());
						json.put("originalJson", purchase.getOriginalJson());
						json.put("packageName", purchase.getPackageName());
						json.put("signature", purchase.getSignature());
						json.put("sku", purchase.getSku());
						json.put("token", purchase.getToken());
						json.put("purchaseState", purchase.getPurchaseState());
					} catch(JSONException e) {
						Log.e(TAG, e.getMessage(), e);
					}
					InAppBillingBridge.callLuaPurchaseCompleteCallbackMethod(json.toString());
				} else {
					Log.i(TAG, "purchase status is " + purchase.getPurchaseState());
					InAppBillingBridge.callLuaPurchaseCompleteCallbackMethod("fail:" + purchase.getPurchaseState());
				}
			}
		}
    };
    
    private IabHelper.OnConsumeFinishedListener consumeFinishedListener = new IabHelper.OnConsumeFinishedListener() {
		public void onConsumeFinished(Purchase purchase, IabResult result) {
			Log.i(TAG, "Consumption finished. Purchase: " + purchase + ", result: " + result);

			// if we were disposed of in the meantime, quit.
			if (helper == null)
				return;

			// We know this is the "gas" sku because it's the only one we
			// consume,
			// so we don't check which sku was consumed. If you have more than
			// one
			// sku, you probably should check...
			if (result.isSuccess()) {
				// successfully consumed, so we apply the effects of the item in
				// our
				// game world's logic, which in our case means filling the gas
				// tank a bit
				Log.i(TAG, "Consumption successful. Provisioning.");
				inventory.erasePurchase(purchase.getSku());
				InAppBillingBridge.callLuaConsumeCompleteCallbackMethod("success:" + purchase.getSku());
			} else {
				Log.e(TAG, "consume error");
				for(int i = 0; i < 4; i++) {//重试4次
					try {
						Inventory iv = helper.queryInventory(true, skuList);
						if(iv != null) {
							if(iv.getPurchase(purchase.getSku()) == null) {
								InAppBillingBridge.callLuaConsumeCompleteCallbackMethod("success:" + purchase.getSku());
							} else {
								//没辙了，真的是失败了，不管了，下次登录应用的时候，会继续尝试
								InAppBillingBridge.callLuaConsumeCompleteCallbackMethod("fail:" + purchase.getSku());
							}
							return;
						}
					} catch (com.boomegg.cocoslib.iab.util.IabException e) {
						Log.e(TAG, e.getMessage(), e);
					}
				}
			}
		}
    };
    
	@Override
	public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
		if(helper != null) {
			helper.handleActivityResult(requestCode, resultCode, data);
		} else {
			Log.d(TAG, "onActivityResult helper is null");
		}
	}

	@Override
	public void setId(String id) {
		this.id = id;
	}

	public boolean isSetupComplete() {
		return isSetupComplete;
	}
	
	public boolean isSupported() {
		return isSupported;
	}

	public void setup() {
		Cocos2dxActivityWrapper.getContext().getUIThreadHandler().removeCallbacks(disposeRunnable);
		if(helper != null) {
			if(!isSetupComplete) {
				if(!isSetuping) {
					isSetuping = true;
					retryLimit = 4;
					Log.d(TAG, "setup -> startSetup");
					helper.startSetup(setupFinishedListener);
				}
			} else {
				Log.d(TAG, "setup -> completed " + isSupported);
				InAppBillingBridge.callLuaSteupCompleteCallbackMethod(isSupported);
			}
		} else {
			Log.d(TAG, "setup -> helper null");
			disposeRunnable.run();
			
			helper = new IabHelper(Cocos2dxActivityWrapper.getContext(), base64EncodedPublicKey);
			//调试开关
			helper.enableDebugLogging(isDebug, "InAppBillingPlugin");
			
			retryLimit = 4;
			Log.d(TAG, "setup -> startSetup 2");
			helper.startSetup(setupFinishedListener);
		}
	}

	public void loadProductList(String[] skus) {
		if(helper != null && isSetupComplete && isSupported) {
			if(!isLoadingProductList) {
				isLoadingProductList = true;
				retryLimit = 4;
				skuList = Arrays.asList(skus);
				helper.queryInventoryAsync(true, skuList, gotInventoryListener);
			}
		}
	}
	private String purchasingSku = null;
	public void makePurchase(String orderId, String sku, String uid, String channel) {
		if(helper != null && isSetupComplete && isSupported && !isPurchasing) {
//			List<NameValuePair> params = new ArrayList<NameValuePair>();
//			params.add(new BasicNameValuePair("uid", uid));
//			params.add(new BasicNameValuePair("orderId", orderId));
//			params.add(new BasicNameValuePair("developerPayload", orderId));
//			params.add(new BasicNameValuePair("productId", sku));
//			params.add(new BasicNameValuePair("channel", channel));
			
			helper.launchPurchaseFlow(Cocos2dxActivityWrapper.getContext(), sku, REQUEST_CODE, purchaseFinishedListener,orderId);
			isPurchasing = true;
			purchasingSku = sku;
		}
	}

	public void consume(final String sku) {
		if(helper != null && isSetupComplete && isSupported) {
			Purchase purchase = null;
			
			if(inventory == null || !inventory.hasPurchase(sku)) {
				try {
					inventory = helper.queryInventory(true, skuList);
					purchase = inventory.getPurchase(sku);
					if(purchase == null) {
						InAppBillingBridge.callLuaConsumeCompleteCallbackMethod("success:" + sku);
						return;
					}
				} catch(Exception e) {
					Log.e(TAG, e.getMessage(), e);
				}
			} else {
				purchase = inventory.getPurchase(sku);
			}
			if(purchase != null) {
				try {
					helper.consumeAsync(purchase, consumeFinishedListener);
				} catch(IllegalStateException e) {
					if(!helper.isDisposed() && helper.isSetupDone()) {
						Cocos2dxActivityUtil.runOnBGThreadDelay(new Runnable() {
							@Override
							public void run() {
								consume(sku);
							}
						}, 500);
					}
				}
			} else {
				InAppBillingBridge.callLuaConsumeCompleteCallbackMethod("fail:" + sku);
			}
		}
	}
	
	private Runnable disposeRunnable = new Runnable() {
		@Override
		public void run() {
			isSetupComplete = false;
			isLoadingProductList = false;
			isPurchasing = false;
			isSetuping = false;
			isSupported = false;
			if(helper != null) {
				helper.dispose();
			}
			helper = null;
			Cocos2dxActivityWrapper.getContext().getUIThreadHandler().removeCallbacks(disposeRunnable);
		}
	};

	public void delayDispose(int delaySeconds) {
		Cocos2dxActivityWrapper.getContext().getUIThreadHandler().postDelayed(disposeRunnable, delaySeconds * 1000);
	}

}
