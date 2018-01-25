package com.boomegg.cocoslib.core.functions;

import android.content.Context;
import android.os.Vibrator;
import android.util.Log;

import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;

public class VibrateFunction {

	public static void apply(int time) {
		Context ctx = Cocos2dxActivityWrapper.getContext();
		if(ctx != null) {
			Vibrator vibrator = (Vibrator) ctx.getSystemService(Context.VIBRATOR_SERVICE);
			if(vibrator != null) {
				vibrator.vibrate(time);
			} else {
				Log.e("VibrateFunction", "VIBRATOR_SERVICE not availiable");
			}
		}
	}
}
