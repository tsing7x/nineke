package com.boomegg.cocoslib.aisflow;

import java.util.List;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import android.util.Log;

import com.boomegg.cocoslib.core.Cocos2dxActivityUtil;
import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;
import com.boomegg.cocoslib.core.IPlugin;

public class AisFlowBridge {

    private static final String TAG = AisFlowPlugin.class.getSimpleName();

    private static int loginResultListener = -1;
    private static int payResultListener = -1;
    
    private static AisFlowPlugin getAisFlowPlugin() {
        if (Cocos2dxActivityWrapper.getContext() != null) {
            List<IPlugin> list = Cocos2dxActivityWrapper.getContext()
                    .getPluginManager().findPluginByClass(AisFlowPlugin.class);
            if (list != null && list.size() > 0) {
                return (AisFlowPlugin) list.get(0);
            } else {
                Log.d(TAG, "AisFlowPlugin not found");
            }
        }
        return null;
    }
    
    public static void login() {
        final AisFlowPlugin aisFlow = getAisFlowPlugin();
        
        if (aisFlow != null) {
            Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
                @Override
                public void run() {
                    aisFlow.login();
                }
            },50);
            
        }
    }
    
    public static void pay(final String packageName) {
        final AisFlowPlugin aisFlow = getAisFlowPlugin();
        
        if (aisFlow != null) {
            Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
                @Override
                public void run() {
                    aisFlow.pay(packageName);
                }
            },50);
            
        }
    }
    
    public static void setLoginResultListener(final int listener) {
        if(AisFlowBridge.loginResultListener != -1) {
            Log.d(TAG, "release lua function " + AisFlowBridge.loginResultListener);
            Cocos2dxLuaJavaBridge.releaseLuaFunction(AisFlowBridge.loginResultListener);
            AisFlowBridge.loginResultListener = -1;
        }
        AisFlowBridge.loginResultListener = listener;
    }
    
    public static void setPayResultListener(final int listener) {
        if(AisFlowBridge.payResultListener != -1) {
            Log.d(TAG, "release lua function " + AisFlowBridge.payResultListener);
            Cocos2dxLuaJavaBridge.releaseLuaFunction(AisFlowBridge.payResultListener);
            AisFlowBridge.payResultListener = -1;
        }
        AisFlowBridge.payResultListener = listener;
    }
    
    public static void callLoginResultListener(final String loginResult) {
        Cocos2dxActivityUtil.runOnGLThreadDelay(new Runnable() {
            @Override
            public void run() {
                if(AisFlowBridge.loginResultListener == -1) return;
                if(loginResult == null) return;
                Cocos2dxLuaJavaBridge.callLuaFunctionWithString(AisFlowBridge.loginResultListener,loginResult);
            }
        }, 50);
    }
    
    public static void callPayResultListener(final String payResult) {
        Cocos2dxActivityUtil.runOnGLThreadDelay(new Runnable() {
            @Override
            public void run() {
                if(AisFlowBridge.payResultListener == -1) return;
                if(payResult == null) return;
                Cocos2dxLuaJavaBridge.callLuaFunctionWithString(AisFlowBridge.payResultListener,payResult);
            }
        }, 50);
    }
}
