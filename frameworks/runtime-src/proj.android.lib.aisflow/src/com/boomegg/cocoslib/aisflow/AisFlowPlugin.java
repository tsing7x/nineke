package com.boomegg.cocoslib.aisflow;

import th.co.ais.fungus.api.ResponseStatus;
import th.co.ais.fungus.api.authentication.ClientAuthenService;
import th.co.ais.fungus.api.authentication.parameters.AppAuthenResponse;
import th.co.ais.fungus.api.authentication.AuthenParameters;
import th.co.ais.fungus.api.ServiceData;
import th.co.ais.fungus.api.callback.ICallbackService;
import th.co.ais.fungus.api.purchase.ClientPurchaseApi;
import th.co.ais.fungus.api.purchase.parameters.PurchasePackageParameters;
import th.co.ais.fungus.api.purchase.parameters.PurchasePackageResponse;
import th.co.ais.fungus.exception.FungusException;
import android.app.Activity;
import android.os.Bundle;
import android.os.Message;
import android.util.Log;

import com.boomegg.cocoslib.core.IPlugin;
import com.boomegg.cocoslib.core.LifecycleObserverAdapter;
import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;

public class AisFlowPlugin extends LifecycleObserverAdapter implements IPlugin{
    
    private boolean isLoginSucc = false;
    private Activity mActivity;
    private String accessToken;
    private String privateId;
    private String userIdType;
    @Override
    public void initialize() {
        Cocos2dxActivityWrapper.getContext().addObserver(this);
    }

    @Override
    public void setId(String id) {
        
    }
    
    ICallbackService<AppAuthenResponse> callback = new ICallbackService<AppAuthenResponse>() {
        @Override
        public void callbackServiceSuccessed(AppAuthenResponse data) {
            Log.d("Log", "Login succeeded.");
            Log.d("Log", "accessToken: " + data.getAccessToken());
            Log.d("Log", "privateId: " + data.getPrivateId());
            Log.d("Log", "expireIn: " + data.getExpireIn());
            accessToken = data.getAccessToken();
            privateId = data.getPrivateId();
            userIdType = data.getIdType();
            isLoginSucc = true;
            String loginStr = "{\"isSucc\":\"true\",\"privateId\":\"" + privateId + "\"}";
            callLoginResult(loginStr);
        }
        @Override
        public void callbackServiceError(ResponseStatus status) {
            Log.e("Log", "Login failed.");
            Log.e("Log", "resultCode: " + status.getResultCode());
            Log.e("Log", "developerMessage: " + status.getDeveloperMessage());
            Log.e("Log", "userMessage: " + status.getUserMessage());
            Log.e("Log", "moreInfo: " + status.getMoreInfo());
            accessToken = "";
            privateId = "";
            isLoginSucc = false;
            String loginStr = "{\"isSucc\":\"false\",\"resultCode\":\"" + status.getResultCode() +"\",\"userMessage\":\"" + status.getUserMessage() +"\"}";
            callLoginResult(loginStr);
        }
    };

    
    ICallbackService<ServiceData> callbackLogout = new ICallbackService<ServiceData>() {
        @Override
        public void callbackServiceSuccessed(ServiceData data) {
            Log.d("Log", "Logout succeeded.");
            isLoginSucc = false;
        }
        @Override
        public void callbackServiceError(ResponseStatus status) {
            Log.e("Log", "Logout failed.");
            Log.e("Log", "resultCode: " + status.getResultCode());
            Log.e("Log", "developerMessage: " + status.getDeveloperMessage());
            Log.e("Log", "userMessage: " + status.getUserMessage());
            Log.e("Log", "moreInfo: " + status.getMoreInfo());
        }
    };
    
        
    @Override
    public void onCreate(Activity activity, Bundle savedInstanceState) {
        super.onCreate(activity, savedInstanceState);
        this.mActivity = activity;
        try {
            AppAuthenResponse appAuthen = ClientAuthenService.initialApplication(activity);
        } catch (FungusException e) {
            e.printStackTrace();
        }
    }


    
    public void login() {
        if(isLoginSucc) {
            String loginStr = "{\"isSucc\":\"true\",\"privateId\":\"" + this.privateId + "\"}";
            callLoginResult(loginStr);
            return;
        }
        ClientAuthenService.login(mActivity, callback);
    }
    

    public void logout() {
        if(isLoginSucc) {
            if(accessToken != null && !"".equals(accessToken)) {
                AuthenParameters params = new AuthenParameters(accessToken);
                ClientAuthenService.logout(mActivity, params, callbackLogout);
            }
        }
    }

    public void callLoginResult(String loginResult) {
        AisFlowBridge.callLoginResultListener(loginResult);
    }
    
    public void callPayResult(String payResult) {
        AisFlowBridge.callPayResultListener(payResult);
    }
    
    public void pay(String packageName) {
        if(!isLoginSucc) {
            String payStr = "{\"isSucc\":\"false\",\"resultCode\":\"-2\",\"userMessage\":\"need login first\"}";
            callPayResult(payStr);
           return; 
        }
        PurchasePackageParameters params =
                new PurchasePackageParameters(accessToken, privateId, packageName, "https://m-stbbe.ais.co.th:8443/provision");
        ICallbackService<PurchasePackageResponse> callback = new ICallbackService< PurchasePackageResponse>() {
            @Override
            public void callbackServiceSuccessed(PurchasePackageResponse response) {
                Log.e("Log","PurchasePackage succeeded.");
                String payStr = "{\"isSucc\":\"true\"}";
                callPayResult(payStr);
                logout();
            }
            @Override
            public void callbackServiceError(ResponseStatus status) {
                Log.e("Log","PurchasePackage failed.");
                String resultCode = status.getResultCode();
                String developerMessage = status.getDeveloperMessage();
                String userMessage = status.getUserMessage();
                String payStr = "{\"isSucc\":\"false\",\"resultCode\":\"" + resultCode +"\",\"userMessage\":\"" + userMessage +"\"}";
                callPayResult(payStr);
                logout();
               }
            };
            ClientPurchaseApi.purchasePackage(this.mActivity, params, callback);
    }

    

}
