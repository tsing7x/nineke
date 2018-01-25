package com.boyaa.admobile.ad.facebook;

import java.math.BigDecimal;
import java.util.Currency;
import java.util.HashMap;

import android.content.Context;
import android.os.Bundle;
import android.util.Log;

import com.boyaa.admobile.util.BDebug;
import com.boyaa.admobile.util.BUtility;
import com.boyaa.admobile.util.Constant;
import android.app.Activity;
import com.facebook.appevents.AppEventsConstants;
import com.facebook.appevents.AppEventsLogger;

/**
 * @author Carrywen
 */
public class FaceBookManager {
    public static final String APP_ID = "fb_appId";
    public static final String TAG = "FB";
    public static FaceBookManager mFaceBookManager;
    public AppEventsLogger logger;

    private FaceBookManager(Activity activity) {
        logger = AppEventsLogger.newLogger(activity);
    }


    public static FaceBookManager getInstance(Activity context) {
        if (mFaceBookManager == null) {
            mFaceBookManager = new FaceBookManager(context);
        }
        return mFaceBookManager;
    }

    /**
     * start
     *
     * @param paraterMap
     */
    public void start(HashMap paraterMap) {
        try {
            logger.setUserID((String) paraterMap.get(Constant.APP_USER_ID));
            logger.logEvent(Constant.FB_PRE+Constant.AF_EVENT_START);
        } catch (Exception e) {
            Log.e(TAG, "FB??", e);
        }

    }


    /**
     * register
     *
     * @param paraterMap
     */
    public void register(HashMap paraterMap) {
        try {
            logger.setUserID((String) paraterMap.get(Constant.APP_USER_ID));
            Bundle params = new Bundle();
            params.putString(AppEventsConstants.EVENT_PARAM_REGISTRATION_METHOD, (String)paraterMap.get("userType"));
            logger.logEvent(AppEventsConstants.EVENT_NAME_COMPLETED_REGISTRATION, params);
        } catch (Exception e) {
            Log.e(TAG, "FB??", e);
        }

    }


    /**
     * login
     *
     * @param paraterMap
     */
    public void login(HashMap paraterMap) {
        try {
            logger.setUserID((String) paraterMap.get(Constant.APP_USER_ID));
            logger.logEvent(Constant.FB_PRE+Constant.AF_EVENT_LOGIN);
        } catch (Exception e) {
            Log.e(TAG, "FB??", e);
        }

    }


    /**
     * play
     *
     * @param paraterMap
     */
    public void play(HashMap paraterMap) {
        try {
            logger.setUserID((String) paraterMap.get(Constant.APP_USER_ID));
            logger.logEvent(Constant.FB_PRE+Constant.AF_EVENT_PLAY);
        } catch (Exception e) {
            Log.e(TAG, "FB??", e);
        }

    }


    /**
     * pay
     *
     * @param paraterMap
     */
    public void pay(HashMap paraterMap) {
        try {
            logger.setUserID((String) paraterMap.get(Constant.APP_USER_ID));
            logger.logPurchase(BigDecimal.valueOf(Float.parseFloat((String)paraterMap.get("pay_money"))), Currency.getInstance((String)paraterMap.get("currencyCode")));
        } catch (Exception e) {
            Log.e(TAG, "FB??", e);
        }

    }

    public void logout(HashMap paraterMap) {
        try {
            logger.setUserID((String) paraterMap.get(Constant.APP_USER_ID));
            logger.logEvent(Constant.FB_PRE + Constant.AF_EVENT_LOGOUT);
        } catch (Exception e) {
            Log.e(TAG, "FB??", e);

        }
    }

    public void customEvent(HashMap paraterMap) {
        try {
            String eventName = (String) paraterMap.get(Constant.AF_EVENT_CUSTOM);
            logger.setUserID((String) paraterMap.get(Constant.APP_USER_ID));
            logger.logEvent(Constant.FB_PRE+eventName);
        } catch (Exception e) {
            Log.e(TAG, "FB??", e);
        }

    }


	/* (non-Javadoc)
	 * @see com.boyaa.admobile.ad.AdManager#remind(android.content.Context, java.util.HashMap)
	 */
	public void recall(HashMap paraterMap) {
		// TODO Auto-generated method stub
		 try {
             String eventName = (String) paraterMap.get(Constant.AF_EVENT_RECALL);
             logger.setUserID((String) paraterMap.get(Constant.APP_USER_ID));
             logger.logEvent(Constant.FB_PRE+Constant.AF_EVENT_RECALL);
	        } catch (Exception e) {
	            Log.e(TAG, "FB??", e);
	        }
	}

    public void share(HashMap paraterMap) {
        // TODO Auto-generated method stub
        try {
            logger.setUserID((String) paraterMap.get(Constant.APP_USER_ID));
            logger.logEvent(Constant.FB_PRE+"share");
        } catch (Exception e) {
            Log.e(TAG, "FB??", e);
        }
    }

    public void invite(HashMap paraterMap) {
        // TODO Auto-generated method stub
        try {
            logger.setUserID((String) paraterMap.get(Constant.APP_USER_ID));
            logger.logEvent(Constant.FB_PRE + "invite");
        } catch (Exception e) {
            Log.e(TAG, "FB??", e);
        }
    }

    public void purchaseCancel(HashMap paraterMap){
        try {
            logger.setUserID((String) paraterMap.get(Constant.APP_USER_ID));
            logger.logEvent(Constant.FB_PRE+"purchase_cancel");
        } catch (Exception e) {
            Log.e(TAG, "FB??", e);
        }
    }

}
