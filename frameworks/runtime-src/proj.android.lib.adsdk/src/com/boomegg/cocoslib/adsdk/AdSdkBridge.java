package com.boomegg.cocoslib.adsdk;

import java.util.List;

import com.boomegg.cocoslib.core.Cocos2dxActivityUtil;
import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;
import com.boomegg.cocoslib.core.IPlugin;

import android.util.Log;

public class AdSdkBridge {

    private static final String TAG = AdSdkBridge.class.getSimpleName();

    private static AdSdkPlugin getAdSdkPlugin() {
        if (Cocos2dxActivityWrapper.getContext() != null) {
            List<IPlugin> list = Cocos2dxActivityWrapper.getContext()
                    .getPluginManager().findPluginByClass(AdSdkPlugin.class);
            if (list != null && list.size() > 0) {
                return (AdSdkPlugin) list.get(0);
            } else {
                Log.d(TAG, "FacebookLoginPlugin not found");
            }
        }
        return null;
    }

    public static void setFbAppId(final String fbAppId) {
        final AdSdkPlugin plugin = getAdSdkPlugin();
        if (plugin != null) {
            Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
                @Override
                public void run() {
                    Log.d(TAG, "plugin  setFbAppId begin");
                    plugin.setFbAppId(fbAppId);
                    Log.d(TAG, "plugin setFbAppId  end");
                }
            }, 50);
        }
    }

    public static void report(final String data) {
        final AdSdkPlugin plugin = getAdSdkPlugin();
      if (plugin != null) {
          Cocos2dxActivityUtil.runOnUiThreadDelay(new Runnable() {
              @Override
              public void run() {
                  Log.d(TAG, "plugin  reportStart begin");
                  Log.d(TAG, "plugin  data:" + data);
                  plugin.report(data);
                  Log.d(TAG, "plugin reportStart  end");
              }
          }, 50);
      }
    }
}
