package com.boomegg.cocoslib.gcm;

import java.io.IOException;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.text.TextUtils;
import android.util.Log;
import me.leolin.shortcutbadger.ShortcutBadger;

import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;
import com.boomegg.cocoslib.core.IPlugin;
import com.boomegg.cocoslib.core.LifecycleObserverAdapter;
import com.google.android.gcm.GCMRegistrar;
import com.google.android.gms.gcm.GoogleCloudMessaging;

public class GoogleCloudMessagingPlugin extends LifecycleObserverAdapter implements IPlugin {
	protected final String TAG = getClass().getSimpleName(); 
	protected String id;
	
	@Override
	public void initialize() {
		Cocos2dxActivityWrapper.getContext().addObserver(this);
	}

	@Override
	public void setId(String id) {
		this.id = id;
	}

	@Override
	public void onCreate(Activity activity, Bundle savedInstanceState) {
		//doReg(false);
		cleanCountPushNews();
	}
	
	public void register() {
		doReg(true);
	}
	
	private void doReg(boolean callback) {
		Context ctx = Cocos2dxActivityWrapper.getContext().getApplicationContext();
		if(ctx != null) {
//		    try {
//		        final String regId = GoogleCloudMessaging.getInstance(ctx).register("567189822311");
//		        Log.e(TAG, regId);
//		        if (TextUtils.isEmpty(regId)) {
//                    GCMRegistrar.register(ctx, ctx.getResources().getStringArray(R.array.gcm_sender_ids));
//                } else if(callback) {
//                  GoogleCloudMessagingBridge.callRegisteredCallback("REG", true, regId);
//                }
//            } catch (IOException e) {
//                Log.e(TAG, e.getMessage(), e);
//                if (callback) {
//                    GoogleCloudMessagingBridge.callRegisteredCallback("REG", false, e.getMessage());
//                }
//            }
			try {
				//GCMRegistrar.checkDevice(ctx);
				//GCMRegistrar.checkManifest(ctx);
				final String regId = GCMRegistrar.getRegistrationId(ctx);
				Log.e(TAG, regId);
				if (TextUtils.isEmpty(regId)) {
					GCMRegistrar.register(ctx, "567189822311");
				} else if(callback) {
					GoogleCloudMessagingBridge.callRegisteredCallback("REG", true, regId);
				}
			} catch(Exception e) {
				Log.e(TAG, e.getMessage(), e);
				if (callback) {
					GoogleCloudMessagingBridge.callRegisteredCallback("REG", false, e.getMessage());
				}
			}
		}
	}
	
	private void cleanCountPushNews()
	{
		Context context = Cocos2dxActivityWrapper.getContext();
		SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(context);
		SharedPreferences.Editor mEditor = preferences.edit();  
        mEditor.putInt("PUSH_NEWS_NUM", 0); 
        mEditor.commit(); 
		
		ShortcutBadger.removeCount(context);
	}
}
