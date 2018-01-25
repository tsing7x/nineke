package com.boomegg.cocoslib.core.functions;

import android.content.Intent;
import android.util.Log;

import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;

public class ShowEmailViewFunction {
	public static void apply(final String subject, final String content) {
		final Cocos2dxActivityWrapper ctx = Cocos2dxActivityWrapper.getContext();
		if(ctx != null) {
			ctx.runOnUiThread(new Runnable() {
				@Override
				public void run() {
					Intent intent =new Intent(android.content.Intent.ACTION_SEND);
					intent.setType("plain/text");
					intent.putExtra(Intent.EXTRA_SUBJECT, subject);
					intent.putExtra(Intent.EXTRA_TEXT, content);
					try {
						ctx.startActivity(Intent.createChooser(intent, "Choose Email client"));
					} catch(Exception e) {
						Log.e(ShowEmailViewFunction.class.getSimpleName(), e.getMessage(), e);
					}
				}
			});
		}
	}
}
