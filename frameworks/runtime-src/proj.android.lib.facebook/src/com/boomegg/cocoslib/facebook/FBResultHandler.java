package com.boomegg.cocoslib.facebook;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import com.facebook.FacebookBroadcastReceiver;
import com.facebook.internal.NativeProtocol;

public class FBResultHandler extends FacebookBroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        String appCallId = intent.getStringExtra(NativeProtocol.EXTRA_PROTOCOL_CALL_ID);
        String action = intent.getStringExtra(NativeProtocol.EXTRA_PROTOCOL_ACTION);
        if (appCallId != null && action != null) {
            Bundle extras = intent.getExtras();
//            for (String key: extras.keySet()){
//              Log.i("FBResultHandler", "Key=" + key + ", content=" +extras.getString(key));  
//            }
            if (NativeProtocol.isErrorResult(intent)) {
//            	Log.e("FBResultHandler", "failded");
                onFailedAppCall(appCallId, action, extras);
            } else {
//            	Log.e("FBResultHandler", "successed");
                onSuccessfulAppCall(appCallId, action, extras);
            }
        }else{
//        	Log.e("FBResultHandler", "failded11111");
        	onFailedAppCall(null, null, null);
        }
    }

    protected void onSuccessfulAppCall(String appCallId, String action, Bundle extras) {
        // Default does nothing.
    	FacebookBridge.callLuaUploadPhotoResult(appCallId, true);
    }

    protected void onFailedAppCall(String appCallId, String action, Bundle extras) {
        // Default does nothing.
    	FacebookBridge.callLuaUploadPhotoResult("failed", true);
    }
}