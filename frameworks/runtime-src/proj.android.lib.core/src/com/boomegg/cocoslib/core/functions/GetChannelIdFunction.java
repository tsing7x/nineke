package com.boomegg.cocoslib.core.functions;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.util.Log;

import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;

public class GetChannelIdFunction {

	public static String apply() {
		Context ctx = Cocos2dxActivityWrapper.getContext();
		String channelId = null;
		if(ctx != null) {
			try {
				ApplicationInfo appInfo = ctx.getPackageManager().getApplicationInfo(ctx.getPackageName(), PackageManager.GET_META_DATA);
				channelId = appInfo.metaData.getString("BM_CHANNEL_ID");
				if(channelId != null) {
					channelId = channelId.trim();
				}
			} catch(Exception e) {
				Log.e("GetChannelIdFunction", e.getMessage(), e);
			}
		}
		return channelId;
	}

}
