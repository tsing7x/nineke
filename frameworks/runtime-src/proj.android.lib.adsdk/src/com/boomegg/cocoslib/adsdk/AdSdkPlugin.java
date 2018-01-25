package com.boomegg.cocoslib.adsdk;

import java.util.HashMap;

import org.json.JSONObject;

import android.app.Activity;
import android.util.Log;

import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;
import com.boomegg.cocoslib.core.IPlugin;
import com.boomegg.cocoslib.core.LifecycleObserverAdapter;
import com.boyaa.admobile.util.BoyaaADUtil;
import com.boyaa.admobile.util.Constant;

public class AdSdkPlugin extends LifecycleObserverAdapter implements IPlugin {

    private static final String TAG = AdSdkPlugin.class.getSimpleName();
    private String pluginId;
    private String fbAppId;

    @Override
    public void initialize() {
        Cocos2dxActivityWrapper.getContext().addObserver(this);
    }

    @Override
    public void setId(String id) {
        pluginId = id;
    }

    public String getId() {
        return pluginId;
    }

    public void setFbAppId(String id) {
        Log.d(TAG, "AdSdkPlugin set fbAppId ");
        fbAppId = id;
    }

    private boolean isFbAppIdNull() {
        if (fbAppId == null || "".equals(fbAppId))
            return true;
        else
            return false;
    }
    
    public void report(final String param) {
        Activity mActivity = Cocos2dxActivityWrapper.getContext();
        try {
            JSONObject json = new JSONObject(param);
            int type = json.optInt("type");
            String uid = json.optString("uid");
            HashMap<String, String> map = new HashMap<String, String>();
            if (isFbAppIdNull())
                return;
            map.put("fb_appId", fbAppId);
            map.put("uid", uid);
            if (type == BoyaaADUtil.METHOD_START) {
                BoyaaADUtil.push(mActivity, map, BoyaaADUtil.METHOD_START);
            } else if (type == BoyaaADUtil.METHOD_REG) {
                Log.d("zyh", "register as " + json.optString("userType"));
                map.put("userType", json.optString("userType"));
                BoyaaADUtil.push(mActivity, map, BoyaaADUtil.METHOD_REG);
            } else if (type == BoyaaADUtil.METHOD_LOGIN) {
                BoyaaADUtil.push(mActivity, map, BoyaaADUtil.METHOD_LOGIN);
            } else if (type == BoyaaADUtil.METHOD_PLAY) {
                BoyaaADUtil.push(mActivity, map, BoyaaADUtil.METHOD_PLAY);
            } else if (type == BoyaaADUtil.METHOD_PAY) {
                String payMoney = json.optString("payMoney");
                map.put("pay_money", payMoney);
                String currencyCode = json.optString("currencyCode");
                map.put("currencyCode", currencyCode);
                String orderId = json.optString("orderId");
                map.put("orderId",orderId);
                BoyaaADUtil.push(mActivity, map, BoyaaADUtil.METHOD_PAY);
            } else if (type == BoyaaADUtil.METHOD_RECALL) {
                BoyaaADUtil.push(mActivity, map, BoyaaADUtil.METHOD_RECALL);
            } else if (type == BoyaaADUtil.METHOD_LOGOUT) {
                BoyaaADUtil.push(mActivity, map, BoyaaADUtil.METHOD_LOGOUT);
            } else if (type == BoyaaADUtil.METHOD_CUSTOM) {
                map.put(Constant.AF_EVENT_CUSTOM, json.optString("event_name"));
                BoyaaADUtil.push(mActivity, map, BoyaaADUtil.METHOD_CUSTOM);
            }else if (type == BoyaaADUtil.METHOD_SHARE){
                BoyaaADUtil.push(mActivity, map, BoyaaADUtil.METHOD_SHARE);
            }else if (type == BoyaaADUtil.METHOD_INVITE){
                BoyaaADUtil.push(mActivity, map, BoyaaADUtil.METHOD_INVITE);
            }else if (type == BoyaaADUtil.METHOD_PURCHASE_CANCEL){
                BoyaaADUtil.push(mActivity, map, BoyaaADUtil.METHOD_PURCHASE_CANCEL);
            }
        } catch (Exception e) {
        }
    }
}
