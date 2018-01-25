package com.boyaa.admobile.service;

import java.util.Calendar;
import java.util.List;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.IBinder;
import android.util.Log;

import com.boyaa.admobile.ad.boya.BoyaaManager;
import com.boyaa.admobile.entity.BasicMessageData;
import com.boyaa.admobile.exception.CrashHandler;
import com.boyaa.admobile.util.BDebug;

/**
 * @author Carrywen
 * 
 */
public class CommitService extends Service {
	protected static final String SERVICE_ACTION = "com.boyaa.admobile.service";
	public static final String TAG = "task";

	public IBinder onBind(Intent intent) {
		return null;
	}

	@Override
	public int onStartCommand(Intent intent, int flags, int startId) {
		try {
			CrashHandler crashHandler = CrashHandler.getInstance();
			crashHandler.init(this);
			PendingIntent pendingIntent = PendingIntent.getBroadcast(this, 0,
					new Intent(SERVICE_ACTION), 0);
			BroadcastReceiver receiver = new BroadcastReceiver() {

				public void onReceive(Context context, Intent intent) {
					new Thread(new OutLineTaskThread()).start();
				}
			};
			BDebug.d(TAG, "CommitService启动");
			registerReceiver(receiver, new IntentFilter(SERVICE_ACTION));
			Calendar calendar = Calendar.getInstance();
			calendar.setTimeInMillis(System.currentTimeMillis());
			calendar.add(Calendar.HOUR, 1);
			AlarmManager manager = (AlarmManager) getSystemService(Context.ALARM_SERVICE);
			manager.setRepeating(AlarmManager.RTC_WAKEUP, calendar.getTimeInMillis(),
					AlarmManager.INTERVAL_HOUR*2, pendingIntent);
		} catch (Exception e) {
			e.printStackTrace();
		}

		return Service.START_STICKY;
	}

	class OutLineTaskThread implements Runnable {

		@Override
		public void run() {
			try {
				ReportDataService service = ReportDataService
						.getReportService(getApplicationContext());
				List<BasicMessageData> messageDatas = service.queryReportData();
				BDebug.d(TAG, "待续传任务数：" + messageDatas.size());
				if (null != messageDatas && messageDatas.size() > 0) {
					for (BasicMessageData message : messageDatas) {
						BoyaaManager.getInstance().commitRecord(
								getApplicationContext(), message);
					}
				}
			} catch (Exception e) {
				e.printStackTrace();
			}

		}

	}
}
