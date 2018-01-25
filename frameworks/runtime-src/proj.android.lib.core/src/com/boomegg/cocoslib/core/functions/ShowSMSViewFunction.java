package com.boomegg.cocoslib.core.functions;

import android.content.Intent;
import android.net.Uri;
import android.util.Log;

import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;

public class ShowSMSViewFunction {

	public static void apply(final String smsBody) {
		final Cocos2dxActivityWrapper ctx = Cocos2dxActivityWrapper.getContext();
		if(ctx != null) {
			ctx.runOnUiThread(new Runnable() {
				@Override
				public void run() {
					Uri smsToUri = Uri.parse("smsto:");
					Intent intent = new Intent(Intent.ACTION_SENDTO, smsToUri);  
					intent.putExtra("sms_body", smsBody);
					try {
						ctx.startActivity(intent);
					} catch(Exception e) {
						Log.e(ShowSMSViewFunction.class.getSimpleName(), e.getMessage(), e);
					}
				}
			});
		}
	}
}
