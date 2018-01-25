package com.boyaa.cocoslib.godsdk;

import java.util.HashMap;
import java.util.Map;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.R.string;
import android.app.Activity;
import android.os.Bundle;
import android.util.Log;

import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;
import com.boomegg.cocoslib.core.IPlugin;
import com.boomegg.cocoslib.core.LifecycleObserverAdapter;
import com.boyaa.godsdk.callback.CallbackStatus;
import com.boyaa.godsdk.callback.IAPListener;
import com.boyaa.godsdk.callback.SDKListener;
import com.boyaa.godsdk.callback.SpecialMethodListener;
import com.boyaa.godsdk.core.GodSDK;
import com.boyaa.godsdk.core.GodSDKIAP;
import com.boyaa.godsdk.core.GodSDK.IGodSDKIterator;

public class GodSdkPlugin extends LifecycleObserverAdapter implements IPlugin {
	private static final String TAG = GodSdkPlugin.class.getSimpleName();
	
	private Activity mActivity;
	protected String id;
	
	private IAPListener mIapListener;
	private SDKListener mSdkListener;

	public GodSdkPlugin() {
		// TODO Auto-generated constructor stub
		Log.d(TAG, "GodSdkPlugin constructor Called!");
		
		this.mIapListener = new IAPListener() {

			@Override
			public void onPaySuccess(CallbackStatus status, String pmode) {
				// TODO Auto-generated method stub
				Log.d(TAG, "IAPListener.onPaySuccess, CallbackStatus :" + status.getMsg() + "  pmode :" + pmode);
				
				Map<String, String> jsonDataMap = new HashMap<String, String>();
				if (pmode.equals("12")) {
					jsonDataMap.put("ret", "0");
					jsonDataMap.put("pmode", pmode);
					
					Map<String, String> map = status.getExtras();
					if (map != null) {
						jsonDataMap.put("signedData", map.get("OriginalJson"));
						jsonDataMap.put("signature", map.get("Signature"));
					}
				} else {
					jsonDataMap.put("ret", "1");
					jsonDataMap.put("pmode", pmode);
					jsonDataMap.put("msg", "Not Iab pmode(12), pmode:" + pmode);
				}
				
				try {
					JSONObject jsonObject = new JSONObject(jsonDataMap);
					
					Log.d(TAG, "IAPListener.onPaySuccess Call Lua With Param :" + jsonObject.toString());
					GodSdkBridge.callLuaByIabPurchaseCallbackMethod(jsonObject.toString());
				} catch (Exception e) {
					// TODO: handle exception
					e.printStackTrace();
					
					Log.d(TAG, "IAPListener.onPaySuccess JsonObj Create Wrong!");
				}
			}

			@Override
			public void onPayFailed(CallbackStatus status, String pmode) {
				// TODO Auto-generated method stub
				Log.d(TAG, "IAPListener.onPayFailed, CallbackStatus :" + status.getMsg() + "  pmode :" + pmode);
				
				Map<String, String> jsonDataMap = new HashMap<String, String>();
				jsonDataMap.put("ret", "-1");
				jsonDataMap.put("mainStatus", "" + status.getMainStatus());
				jsonDataMap.put("subStatus", "" + status.getSubStatus());
				jsonDataMap.put("errmsg", status.getMsg());
				jsonDataMap.put("pmode", pmode);
		        
				try {
					JSONObject jsonObject = new JSONObject(jsonDataMap);
					
					Log.d(TAG, "IAPListener.onPayFailed Call Lua With Param :" + jsonObject.toString());
					GodSdkBridge.callLuaByIabPurchaseCallbackMethod(jsonObject.toString());
				} catch (Exception e) {
					// TODO: handle exception
					e.printStackTrace();
					
					Log.d(TAG, "IAPListener.onPayFailed JsonObj Create Wrong!");
				}
			}
		};

		this.mSdkListener = new SDKListener() {

			@Override
			public void onQuitSuccess(CallbackStatus arg0) {
				// TODO Auto-generated method stub
				Log.d(TAG, "SDKListener.onQuitSuccess, CallbackStatus:" + arg0.getMsg());
			}

			@Override
			public void onQuitCancel(CallbackStatus arg0) {
				// TODO Auto-generated method stub
				Log.d(TAG, "SDKListener.onQuitCancel, CallbackStatus:" + arg0.getMsg());
			}

			@Override
			public void onInitSuccess(CallbackStatus arg0) {
				// TODO Auto-generated method stub
				Log.d(TAG, "SDKListener.onInitSuccess, CallbackStatus:" + arg0.getMsg());
			}

			@Override
			public void onInitFailed(CallbackStatus arg0) {
				// TODO Auto-generated method stub
				Log.d(TAG, "SDKListener.onInitFailed, CallbackStatus:" + arg0.getMsg());
			}
		};
	}
	
	@Override
	public void onCreate(Activity activity, Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		Log.d(TAG, "GodSdkPlugin.onCreate called!");
		super.onCreate(activity, savedInstanceState);
		this.mActivity = activity;
	}

	@Override
	public void initialize() {
		// TODO Auto-generated method stub
		Cocos2dxActivityWrapper.getContext().addObserver(this);
	}

	@Override
	public void setId(String id) {
		// TODO Auto-generated method stub
		this.id = id;
	}
	
	public void init() {
		GodSDK.getInstance().setDebugMode(true);
		GodSDKIAP.getInstance().setDebugMode(true);
		
		boolean b = GodSDK.getInstance().initSDK(this.mActivity, new IGodSDKIterator<Integer>(){
			private int i = 20000;
			private final int end = 20100;
			
			@Override
			public Integer next() {
				i = i + 1;
				return i;
			}
			
			@Override
			public boolean hasNext() {
				if (i < end) {
					return true;
				} else {
					return false;
				}
			}
		});
		
		GodSDK.getInstance().setSDKListener(this.mSdkListener);
		GodSDKIAP.getInstance().setIAPListener(this.mIapListener);
		if (b) {
			Log.d(TAG, "GodSDK.initSDK Success");
		} else {
			Log.d(TAG, "GodSDK.initSDK Faild");
		}
	}
	
	public void makeIabPurchase(final String purcahseDataJson) {
		Log.d(TAG, "makeIabPurchase Called!with Param :" + purcahseDataJson);
		
		GodSDKIAP.getInstance().requestPay(this.mActivity, purcahseDataJson);
	}
	
	public void consumeIabProduct(final String productId) {
		Map<String, Object> dataMap = new HashMap<String, Object>();
		dataMap.put("sku", productId);
		
		GodSDKIAP.getInstance().callSpecialMethod("12", "doConsumeSku", dataMap, new SpecialMethodListener() {
			
			@Override
			public void onCallSuccess(CallbackStatus status, Map map) {
				// TODO Auto-generated method stub
				Log.d(TAG, "GodSDKIAP.doConsumeSku CallSuccess");
			}
			
			@Override
			public void onCallFailed(CallbackStatus status, Map map) {
				// TODO Auto-generated method stub
				Log.d(TAG, "GodSDKIAP.doConsumeSku CallFailed");
			}
		});
	}
	
	public void loadProductList(final String skuList) {
		Map<String, Object> skuDataMap = new HashMap<String, Object>();
		
		skuDataMap.put("skuList", skuList);
		GodSDKIAP.getInstance().callSpecialMethod("12", "doLoadProductList", skuDataMap, new SpecialMethodListener() {
			
			@Override
			public void onCallSuccess(CallbackStatus status, Map map) {
				// TODO Auto-generated method stub
				Log.d(TAG, "GodSDKIAP.doLoadProductList CallSuccess");
				
				String resultJsonArray = (String)map.get("productList");
				
//				try {
//					JSONArray productJsonArray = new JSONArray(resultJsonArray);
//					
//					for (int i = 0; i < productJsonArray.length(); i++) {
//						JSONObject jsonObj = (JSONObject)productJsonArray.get(i);
//					}
//				} catch (JSONException e) {
//					// TODO: handle exception
//				}
				
				GodSdkBridge.callLuaByIabLoadProductCallbackMethod(resultJsonArray);
			}
			
			@Override
			public void onCallFailed(CallbackStatus status, Map map) {
				// TODO Auto-generated method stub
				Log.d(TAG, "GodSDKIAP.doLoadProductList CallFailed");
			}
		});
	}
	
	public void queryUnfinishedIAP() {
		GodSDKIAP.getInstance().callSpecialMethod("12", "doQueryInventory", null, new SpecialMethodListener() {
			
			@Override
			public void onCallSuccess(CallbackStatus status, Map map) {
				// TODO Auto-generated method stub
				Log.d(TAG, "GodSDKIAP.doQueryInventory CallSuccess");
				
				String result = (String) map.get("purchaseOwns");
				try {
					JSONArray jsonArray = new JSONArray(result);
					Log.d(TAG, "GodSDKIAP.doQueryInventory retJson.len :" + jsonArray.length());
					
					for (int i = 0; i < jsonArray.length(); i++) {
						JSONObject jsonObj = (JSONObject)jsonArray.get(i);
						
						Map<String, String> dataMap = new HashMap<String, String>();
						dataMap.put("ret", "0");
						dataMap.put("pmode", "12");
						dataMap.put("signedData", (String)jsonObj.get("OriginalJson"));
						dataMap.put("signature", (String)jsonObj.get("Signature"));
						
						try {
							JSONObject retJsonObj = new JSONObject(dataMap);
							GodSdkBridge.callLuaByIabQueryUnfinishedIAPCallbackMethod(retJsonObj.toString());
						} catch (Exception e) {
							// TODO: handle exception
							e.printStackTrace();
						}
					}
				} catch (JSONException e) {
					// TODO: handle exception
					e.printStackTrace();
				}
			}
			
			@Override
			public void onCallFailed(CallbackStatus status, Map map) {
				// TODO Auto-generated method stub
				Log.d(TAG, "GodSDKIAP.doQueryInventory CallFailed");
				Map<String, String> dataMap = new HashMap<String, String>();
				dataMap.put("ret", "-1");
				dataMap.put("mainStatus", "" + status.getMainStatus());
				dataMap.put("subStatus", "" + status.getSubStatus());
				dataMap.put("errmsg", status.getMsg());
				dataMap.put("pmode", "12");
		        
				try {
					JSONObject jsonObject = new JSONObject(dataMap);
					GodSdkBridge.callLuaByIabQueryUnfinishedIAPCallbackMethod(jsonObject.toString());
				} catch (Exception e) {
					// TODO: handle exception
					e.printStackTrace();
				}
			}
		});
	}
	
	public void finish() {
		GodSDK.getInstance().release(this.mActivity);
	}
	
	public void quit() {
		GodSDK.getInstance().quit(this.mActivity);
	}
}