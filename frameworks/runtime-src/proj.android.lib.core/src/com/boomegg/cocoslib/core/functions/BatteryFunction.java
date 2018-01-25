package com.boomegg.cocoslib.core.functions;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import com.boomegg.cocoslib.core.Cocos2dxActivityUtil;
import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;
/**
 * 获取电量
 * @author IdaHuang
 *
 */
public class BatteryFunction {
	private static final String TAG = BatteryFunction.class.getSimpleName();
	private static int callbackMethodId = -1;
	
	private static int level;
	
	private static String lastThreadName = "not init";
	
	public static void apply(int methodId){
		if(-1 != callbackMethodId){
			Cocos2dxLuaJavaBridge.releaseLuaFunction(callbackMethodId);
			callbackMethodId = -1;
		}
		callbackMethodId = methodId;
		
		BroadcastReceiver batteryLevelReceiver = new BroadcastReceiver(){
			@Override
			public void onReceive(Context context, Intent intent) {
				// TODO Auto-generated method stub
				try{
					context.unregisterReceiver(this);
					int rawlevel = intent.getIntExtra("level", -1);
					int rawscale = intent.getIntExtra("scale", -1);
					// 获得总电量
					level = -1;
					if(rawlevel>=0 && rawscale>0){
						level = (rawlevel * 100) / rawscale; 
						Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
							@Override
							public void run() {
								Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callbackMethodId, level+"");
							}
						});
					}
				}
				catch(Exception e){
					
				}
			}
			
		};
	    IntentFilter batteryLevelFilter = new IntentFilter(Intent.ACTION_BATTERY_CHANGED);
	    Cocos2dxActivityWrapper.getContext().registerReceiver(batteryLevelReceiver, batteryLevelFilter);
	}
}