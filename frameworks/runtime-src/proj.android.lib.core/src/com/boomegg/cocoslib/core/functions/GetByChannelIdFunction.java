package com.boomegg.cocoslib.core.functions;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.util.Log;

import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;

public class GetByChannelIdFunction {
    public static String apply() {
        Context ctx = Cocos2dxActivityWrapper.getContext();
        String bychannelId = null;
        if(ctx != null) {
            try {
                ApplicationInfo appInfo = ctx.getPackageManager().getApplicationInfo(ctx.getPackageName(), PackageManager.GET_META_DATA);
                bychannelId = appInfo.metaData.getString("BY_CHANNEL_ID");
                if(bychannelId != null) {
                    bychannelId = bychannelId.trim();
                }
            } catch(Exception e) {
                Log.e("GetByChannelIdFunction", e.getMessage(), e);
            }
        }
        return bychannelId;
    }
}
