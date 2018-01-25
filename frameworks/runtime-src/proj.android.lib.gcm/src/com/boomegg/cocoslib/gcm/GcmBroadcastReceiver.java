package com.boomegg.cocoslib.gcm;

import android.content.Context;

import com.google.android.gcm.GCMBroadcastReceiver;

/**
 * 推送消息的接收处理类
 */
public class GcmBroadcastReceiver extends GCMBroadcastReceiver {

	/* (non-Javadoc)
	 * @see com.google.android.gcm.GCMBroadcastReceiver#getGCMIntentServiceClassName(android.content.Context)
	 */
	@Override
	protected String getGCMIntentServiceClassName(Context context) {
		return GcmIntentService.class.getName();
	}
}
