package com.boomegg.cocoslib.core.functions;

import android.content.Context;

import com.boomegg.cocoslib.core.Cocos2dxActivityWrapper;


public class ClipboardManagerFunction {
	public static void apply(final String content){
		final Cocos2dxActivityWrapper ctx = Cocos2dxActivityWrapper.getContext();
		if(null != ctx){
			ctx.runOnUiThread(new Runnable() {
				
				@Override
				public void run() {
					// 获取剪贴板管理服务
					int sdk = android.os.Build.VERSION.SDK_INT;
					if (sdk < android.os.Build.VERSION_CODES.HONEYCOMB) {
						android.text.ClipboardManager clipboard = (android.text.ClipboardManager) ctx
								.getSystemService(Context.CLIPBOARD_SERVICE);
						clipboard.setText(content);
					} else {
						android.content.ClipboardManager clipboard = (android.content.ClipboardManager) ctx
								.getSystemService(Context.CLIPBOARD_SERVICE);
						android.content.ClipData clip = android.content.ClipData
								.newPlainText("", content);
						clipboard.setPrimaryClip(clip);
					}
				}
			});
		}
	}
}
