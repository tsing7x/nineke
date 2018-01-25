package com.boomegg.cocoslib.core.functions;

import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;

public class CheckPackageExist {
    public static boolean apply(String packageName) {
        Context ctx = Cocos2dxActivityWrapper.getContext();
        if(packageName == null || "".equals(packageName)) {
            return false;
        }
        try {
            ApplicationInfo info = ctx.getPackageManager().getApplicationInfo(packageName,PackageManager.GET_UNINSTALLED_PACKAGES);
            return true;
        } catch(NameNotFoundException e) {
        }
        return false;
    }
}
