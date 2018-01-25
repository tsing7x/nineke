package com.boyaa.admobile.ad.appsflyer;

import android.app.Activity;

import com.appsflyer.AFInAppEventParameterName;
import com.appsflyer.AFInAppEventType;
import com.appsflyer.AppsFlyerLib;
import com.boyaa.admobile.util.BDebug;
import com.boyaa.admobile.util.BUtility;
import com.boyaa.admobile.util.Constant;

import java.util.HashMap;

import android.util.Log;
/**
 * @author Carrywen
 */
public class AppsFlyManager {
    public static final String AF_TAG = "AppsFlyManager";
    public static AppsFlyManager mAppsFlyManager;
    private static byte[] sync = new byte[1];
    private Activity mActivity;

    private AppsFlyManager(Activity context) {
        mActivity = context;
        Log.d(AF_TAG, "AppsFlyManager ctor");
        String deviceId = BUtility.getUniqueDeviceId(context);
        if (deviceId != null && (! deviceId.equals("")))
        {
            Log.d(AF_TAG, "deviceId " + deviceId);
            AppsFlyerLib.getInstance().setImeiData(deviceId);
        }
        String androidId = BUtility.getAndroidId(context);
        if (androidId != null && (! androidId.equals("")))
        {
            Log.d(AF_TAG, "androidId " + androidId);
            AppsFlyerLib.getInstance().setAndroidIdData(androidId);
        }
        Log.d(AF_TAG, " Constant.AF_KEY " +  Constant.AF_KEY);
        AppsFlyerLib.getInstance().startTracking(context.getApplication(), Constant.AF_KEY);
        AppsFlyerLib.getInstance().sendDeepLinkData(context);
        AppsFlyerLib.getInstance().setCurrencyCode("THB");
//        日志开关
//        AppsFlyerProperties.getInstance().enableLogOutput(true);
    }


    public static AppsFlyManager getInstance(Activity context) {
        if (mAppsFlyManager == null) {
            Log.d(AF_TAG, "getInstance");
            mAppsFlyManager = new AppsFlyManager(context);
        }
        return mAppsFlyManager;
    }

    /**
     * start
     *
     * @param paraterMap
     */
    public void start(HashMap paraterMap) {
        try {     
        	Log.e(AF_TAG, "Start<------>方法调用启动中");
            AppsFlyerLib.getInstance().setCustomerUserId((String)paraterMap.get(Constant.APP_USER_ID));
            HashMap<String, Object> eventValue = new HashMap<String, Object>();
            eventValue.put(AFInAppEventParameterName.EVENT_START, System.currentTimeMillis());
            AppsFlyerLib.getInstance().trackEvent(mActivity.getApplicationContext(), Constant.AF_EVENT_START, eventValue);
        } catch (Exception e) {
            Log.e(AF_TAG, "AF异常", e);
        }

    }


    /**
     * register
     *
     * @param paraterMap
     */
    public void register(HashMap paraterMap) {
        try {
        	Log.d(AF_TAG, "注册<------>方法调用启动中");
            AppsFlyerLib.getInstance().setCustomerUserId((String) paraterMap.get(Constant.APP_USER_ID));
            HashMap<String, Object> eventValue = new HashMap<String, Object>();
            eventValue.put(AFInAppEventParameterName.REGSITRATION_METHOD, (String)paraterMap.get("userType"));
            AppsFlyerLib.getInstance().trackEvent(mActivity.getApplicationContext(), AFInAppEventType.COMPLETE_REGISTRATION, eventValue);
        } catch (Exception e) {
            Log.e(AF_TAG, "AF异常", e);
        }


    }


    /**
     * login
     *
     * @param paraterMap
     */
    public void login(HashMap paraterMap) {
        try {
            Log.d(AF_TAG, "Login<------>方法调用启动中");
            AppsFlyerLib.getInstance().setCustomerUserId((String) paraterMap.get(Constant.APP_USER_ID));
            AppsFlyerLib.getInstance().trackEvent(mActivity.getApplicationContext(), AFInAppEventType.LOGIN, paraterMap);
        } catch (Exception e) {
            Log.e(AF_TAG, "AF异常", e);
        }


    }


    /**
     * play
     *
     * @param paraterMap
     */
    public void play(HashMap paraterMap) {
        try {
        	Log.d(AF_TAG, "PLAY<-------------->方法调用启动中");
            AppsFlyerLib.getInstance().setCustomerUserId((String) paraterMap.get(Constant.APP_USER_ID));
            AppsFlyerLib.getInstance().trackEvent(mActivity.getApplicationContext(), Constant.AF_EVENT_PLAY, paraterMap);
        } catch (Exception e) {
            Log.e(AF_TAG, "AF异常", e);
        }

    }


    /**
     * pay
     *
     * @param paraterMap
     */
    public void pay(HashMap paraterMap) {
        try {
        	Log.d(AF_TAG, "支付<-------------------->方法调用启动中");
            AppsFlyerLib.getInstance().setCustomerUserId((String) paraterMap.get(Constant.APP_USER_ID));
            HashMap<String, Object> eventValue = new HashMap<String, Object>();
            eventValue.put(AFInAppEventParameterName.REVENUE, Float.parseFloat((String)paraterMap.get("pay_money")));
            eventValue.put(AFInAppEventParameterName.CURRENCY, (String)paraterMap.get("currencyCode"));
            eventValue.put(AFInAppEventParameterName.RECEIPT_ID,(String)paraterMap.get("orderId"));
            AppsFlyerLib.getInstance().trackEvent(mActivity.getApplicationContext(), AFInAppEventType.PURCHASE, eventValue);
        } catch (Exception e) {
            Log.e(AF_TAG, "AF异常", e);
        }

    }

    public void logout(HashMap paraterMap) {
        try {
        	Log.e(AF_TAG, "退出<------>方法调用启动中");
            AppsFlyerLib.getInstance().setCustomerUserId((String) paraterMap.get(Constant.APP_USER_ID));
            AppsFlyerLib.getInstance().trackEvent(mActivity.getApplicationContext(), "logout", paraterMap);
        } catch (Exception e) {
            Log.e(AF_TAG, "AF异常", e);
        }
    }


    /* (non-Javadoc)
     * @see com.boyaa.admobile.ad.AdManager#customEvent(android.content.Context, java.util.HashMap)
     */
    public void customEvent(HashMap paraterMap) {
        try {
        	Log.e(AF_TAG, "自定义方法出<------>方法调用启动中");
            AppsFlyerLib.getInstance().setCustomerUserId((String) paraterMap.get(Constant.APP_USER_ID));
            AppsFlyerLib.getInstance().trackEvent(mActivity.getApplicationContext(), (String) paraterMap.get(Constant.AF_EVENT_CUSTOM), paraterMap);
        } catch (Exception e) {
            Log.e(AF_TAG, "AF异常", e);
        }

    }


	/* (non-Javadoc)
	 * @see com.boyaa.admobile.ad.AdManager#recall(android.content.Context, java.util.HashMap)
	 */
	public void recall(HashMap paraterMap) {
		// TODO Auto-generated method stub
		 try {
             Log.d(AF_TAG, "召回事件");
             AppsFlyerLib.getInstance().setCustomerUserId((String) paraterMap.get(Constant.APP_USER_ID));
             AppsFlyerLib.getInstance().trackEvent(mActivity.getApplicationContext(), AFInAppEventType.RE_ENGAGE, paraterMap);
	        } catch (Exception e) {
	            Log.e(AF_TAG, "AF异常", e);
	        }
	}

    public void share(HashMap paraterMap){
        try{
            Log.d(AF_TAG, "分享事件");
            AppsFlyerLib.getInstance().setCustomerUserId((String) paraterMap.get(Constant.APP_USER_ID));
            AppsFlyerLib.getInstance().trackEvent(mActivity.getApplicationContext(), AFInAppEventType.SHARE, paraterMap);
        }catch(Exception e){
            Log.e(AF_TAG, "AF异常", e);
        }
    }

    public void invite(HashMap paraterMap){
        try{
            Log.d(AF_TAG, "邀请");
            AppsFlyerLib.getInstance().setCustomerUserId((String) paraterMap.get(Constant.APP_USER_ID));
            AppsFlyerLib.getInstance().trackEvent(mActivity.getApplicationContext(), AFInAppEventType.INVITE, paraterMap);
        }catch(Exception e){
            Log.e(AF_TAG, "AF异常", e);
        }
    }

    public void purchaseCancel(HashMap paraterMap){
        try{
            Log.d(AF_TAG, "购买取消");
            AppsFlyerLib.getInstance().setCustomerUserId((String) paraterMap.get(Constant.APP_USER_ID));
            AppsFlyerLib.getInstance().trackEvent(mActivity.getApplicationContext(), "purchase_cancel", paraterMap);
        }catch(Exception e){
            Log.e(AF_TAG, "AF异常", e);
        }
    }
}
