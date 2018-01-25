package com.boomegg.cocoslib.core.functions;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.telephony.TelephonyManager;
import android.util.Log;

import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;

/**
 * 获取网络类型
 * @author IdaHuang
 *
 */
public class GetNetWorkTypeFunction {
	private static final String TAG = GetNetWorkTypeFunction.class.getSimpleName();
	private static int callbackMethodId = -1;
	
	public static void apply(int methodId){
		if (-1 != callbackMethodId){
			Cocos2dxLuaJavaBridge.releaseLuaFunction(callbackMethodId);
			callbackMethodId = -1;
		}		
		callbackMethodId = methodId;
		
	    final ConnectivityManager connectivityManager =	(ConnectivityManager)Cocos2dxActivityWrapper.getContext().getSystemService(Context.CONNECTIVITY_SERVICE);
	    final NetworkInfo networkInfo = connectivityManager.getActiveNetworkInfo();
	    String retStr;
	    if (null == networkInfo || !networkInfo.isAvailable()){
	    	retStr = "";
	    }else if(networkInfo.getType() == ConnectivityManager.TYPE_WIFI){
	    	retStr = "wifi";
	    }else if(isFastMobileNetwork(Cocos2dxActivityWrapper.getContext())){
	    	retStr = "3G";
	    }else{
	    	retStr = "3G";
	    }
		
	    Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callbackMethodId, retStr);
	}
	
	private static boolean isFastMobileNetwork(Context context) {
		TelephonyManager telephonyManager = (TelephonyManager) context
				.getSystemService(Context.TELEPHONY_SERVICE);

		Log.d(TAG, "telephonyManager.getNetworkType()::"+telephonyManager.getNetworkType());
		
		switch (telephonyManager.getNetworkType()) {
		case TelephonyManager.NETWORK_TYPE_1xRTT:
			return false; // ~ 50-100 kbps
		case TelephonyManager.NETWORK_TYPE_CDMA:
			return false; // ~ 14-64 kbps
		case TelephonyManager.NETWORK_TYPE_EDGE:
			return false; // ~ 50-100 kbps
		case TelephonyManager.NETWORK_TYPE_EVDO_0:
			return true; // ~ 400-1000 kbps
		case TelephonyManager.NETWORK_TYPE_EVDO_A:
			return true; // ~ 600-1400 kbps
		case TelephonyManager.NETWORK_TYPE_GPRS:
			return false; // ~ 100 kbps
		case TelephonyManager.NETWORK_TYPE_HSDPA:
			return true; // ~ 2-14 Mbps
		case TelephonyManager.NETWORK_TYPE_HSPA:
			return true; // ~ 700-1700 kbps
		case TelephonyManager.NETWORK_TYPE_HSUPA:
			return true; // ~ 1-23 Mbps
		case TelephonyManager.NETWORK_TYPE_UMTS:
			return true; // ~ 400-7000 kbps
		case TelephonyManager.NETWORK_TYPE_IDEN:
			return false; // ~25 kbps
		case TelephonyManager.NETWORK_TYPE_UNKNOWN:
			return false;
		default:
			return false;
		}
	}
}












































