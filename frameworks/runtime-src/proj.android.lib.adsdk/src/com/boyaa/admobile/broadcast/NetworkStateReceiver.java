package com.boyaa.admobile.broadcast;

import com.boyaa.admobile.util.BDebug;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo.State;

/**
 * 监听网络服务，续传数据
 * 
 * @author Carrywen
 * 
 */
public class NetworkStateReceiver extends BroadcastReceiver {
	public static final String TAG = "task";

	@Override
	public void onReceive(Context context, Intent intent) {
		try {
			BDebug.d(TAG, "网络状态改变");
			boolean success = false;
			// 获取网络连接
			ConnectivityManager connManager = (ConnectivityManager) context
					.getSystemService(Context.CONNECTIVITY_SERVICE);
			State state = connManager.getNetworkInfo(ConnectivityManager.TYPE_WIFI)
					.getState();
			if (State.CONNECTED == state) {
				success = true;
			}
			state = connManager.getNetworkInfo(ConnectivityManager.TYPE_MOBILE)
					.getState();
			if (State.CONNECTING == state || State.CONNECTED == state) {
				success = true;
			}
			if (success) {
				Intent newIntent = new Intent();
				newIntent.setAction("com.boyaa.admobile.service");
				context.sendBroadcast(newIntent);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		

	}
}
