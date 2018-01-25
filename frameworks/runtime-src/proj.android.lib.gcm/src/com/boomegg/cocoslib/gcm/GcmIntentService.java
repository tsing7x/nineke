package com.boomegg.cocoslib.gcm;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;

import org.json.JSONObject;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.ApplicationInfo;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.BitmapFactory.Options;
import android.media.AudioManager;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Vibrator;
import android.preference.PreferenceManager;
import android.support.v4.app.NotificationCompat;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.View;
import android.widget.RemoteViews;
import me.leolin.shortcutbadger.ShortcutBadger;

import com.google.android.gcm.GCMBaseIntentService;

/**
 * 处理收到的消息
 */
public class GcmIntentService extends GCMBaseIntentService {
	protected String TAG = getClass().getSimpleName();
	
	public GcmIntentService() {
	}
	
	@Override
	protected String[] getSenderIds(Context context) {
		return context.getResources().getStringArray(R.array.gcm_sender_ids);
	}
	
	private void getPicture(Context context, Intent intent, String urlStr, int count, String flag, Map<String, Object> map) {
		if(urlStr!=null &&urlStr!=""){
			URL url = null;
			InputStream is = null;
			FileOutputStream fos = null;
			 try {  
		            //构建图片的url地址  
		            url = new URL(urlStr);  
		            //开启连接  
		            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
		            conn.setDoInput(true);
		            //设置超时的时间，10000毫秒即10秒  
		            conn.setConnectTimeout(10000);
		            //设置获取图片的方式为GET  
		            conn.setRequestMethod("GET");  
		            //响应码为200，则访问成功  
		            if (conn.getResponseCode() == 200) {  
		                //获取连接的输入流，这个输入流就是图片的输入流  
		                is = conn.getInputStream();  
		                //构建一个file对象用于存储图片  
		                File file = new File(context.getFilesDir().getAbsolutePath(), flag+".png");  
		                fos = new FileOutputStream(file);  
		                int len = 0;  
		                byte[] buffer = new byte[1024];  
		                //将输入流写入到我们定义好的文件中  
		                while ((len = is.read(buffer)) != -1) {  
		                    fos.write(buffer, 0, len);  
		                }  
		                //将缓冲刷入文件  
		                fos.flush();  
		                Log.d(TAG, "file.getAbsolutePath()"+file.getAbsolutePath());
		                Bitmap bm = BitmapFactory.decodeFile(file.getAbsolutePath());
		                map.put(flag, bm);
		                //告诉handler，图片已经下载成功  
		                //handler.sendEmptyMessage(LOAD_SUCCESS);  
		            }  
		        } catch (Exception e) {  
		            //告诉handler，图片已经下载失败  
		            //handler.sendEmptyMessage(LOAD_ERROR);  
		            e.printStackTrace();  
		        } finally {
		        	Integer loaded = (Integer)map.get("count");
		        	int counted = loaded;
		        	counted = counted + 1;
		        	if(counted>=count){
		        		this.startNotification(context,intent,(Bitmap)map.get("icon"),(Bitmap)map.get("bg"));
		        	}else{
		        		map.put("count", counted);
		        	}
		            //在最后，将各种流关闭  
		            try {  
		                if (is != null) {  
		                    is.close();  
		                }  
		                if (fos != null) {  
		                    fos.close();  
		                }  
		            } catch (Exception e) {  
		                //handler.sendEmptyMessage(LOAD_ERROR);  
		                e.printStackTrace();  
		            }  
		        }  
		}
	}
	
	private void applyCountPushNews(Context context)
	{
		SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(context);
		int count = preferences.getInt("PUSH_NEWS_NUM", 0);
		count++;
		
		SharedPreferences.Editor mEditor = preferences.edit();  
        mEditor.putInt("PUSH_NEWS_NUM", count); 
        mEditor.commit(); 
        
		ShortcutBadger.applyCount(context, count);
	}
	
	/**
	 * 图片加载完成展示推送
	 */
	private void startNotification(Context context, Intent intent,Bitmap bigIconBitmap,Bitmap bgBitmap){
		Context app = context.getApplicationContext();
		ApplicationInfo appInfo = app.getApplicationInfo();
		String fileDirectory = app.getFilesDir().getAbsolutePath();
		
		//add tips
		applyCountPushNews(app);
		
		String parameters = intent.getStringExtra("parameters");
		String tickerText = intent.getStringExtra("tickerText");
		String contentTitle = intent.getStringExtra("contentTitle");
		String contentText = intent.getStringExtra("contentText");
		
		int type = 0;
		String pagetype = intent.getStringExtra("pagetype");
		if(pagetype!=null){
			type = Integer.valueOf(pagetype).intValue();
		}
		String code = intent.getStringExtra("code");

		int id = intent.getIntExtra("id", 0);
		if(bigIconBitmap == null) {
			//服务器没返回图标，则使用应用图标
			Options options = new BitmapFactory.Options();
			options.inDensity = DisplayMetrics.DENSITY_HIGH;
			options.inTargetDensity = DisplayMetrics.DENSITY_HIGH;
			options.outWidth = 100;
			options.outHeight = 100;
			bigIconBitmap = BitmapFactory.decodeResource(getResources(), appInfo.icon, options);
		}
		if(TextUtils.isEmpty(contentTitle)) {
			contentTitle = getString(appInfo.labelRes);
		}
		if(TextUtils.isEmpty(tickerText)) {
			tickerText = contentText;
		}
		
		boolean needReport = false;
		String sid = intent.getStringExtra("sid");
		String lid = intent.getStringExtra("lid");
		String log = intent.getStringExtra("log");
		if (!TextUtils.isEmpty(sid) && !TextUtils.isEmpty(lid) && !TextUtils.isEmpty(log)) {
		    needReport = true;
		}
		Uri soundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
		long when = System.currentTimeMillis();
		Intent notificationIntent = app.getPackageManager().getLaunchIntentForPackage(app.getPackageName());
		notificationIntent.putExtra("type", type);
		notificationIntent.putExtra("code", code);
		if (needReport) {
		    notificationIntent.putExtra("sid", sid);
	        notificationIntent.putExtra("lid", lid);
	        notificationIntent.putExtra("log", log);
		}
		PendingIntent contentIntent = PendingIntent.getActivity(context, 0, notificationIntent, PendingIntent.FLAG_UPDATE_CURRENT);
		Notification notification = null;
		Log.d(TAG, "android.os.Build.VERSION.SDK_INT=="+android.os.Build.VERSION.SDK_INT);
		
		if(android.os.Build.VERSION.SDK_INT>=15){
			notification = new Notification(R.drawable.ic_stat_gcm,contentTitle,when);
			notification.flags = Notification.FLAG_INSISTENT;
			RemoteViews remoteView=new RemoteViews(app.getPackageName(),R.layout.notification);
			remoteView.setImageViewBitmap(R.id.notiicon, bigIconBitmap);
			if(bgBitmap!=null){
				remoteView.setImageViewBitmap(R.id.notibg, bgBitmap);
				remoteView.setViewVisibility(R.id.notibg, View.VISIBLE);
			}else{
				remoteView.setViewVisibility(R.id.notibg, View.INVISIBLE);
				//remoteView.setImageViewResource(R.id.notibg, R.drawable.logo_ninekepro2);
			}
			remoteView.setTextViewText(R.id.notititle, contentTitle);
			remoteView.setTextViewText(R.id.noticontent,contentText);
			remoteView.setTextColor(R.id.notititle, 0xFF63C2FF);
			remoteView.setTextColor(R.id.noticontent, 0xFFFFFFFF);
			JSONObject json = null;
			try {
				json = new JSONObject(parameters);
				if(json.has("titleColor")){
					int color = json.getInt("titleColor");
					remoteView.setTextColor(R.id.notititle, color);
				}
				if(json.has("contentColor")){
					int color = json.getInt("contentColor");
					remoteView.setTextColor(R.id.noticontent, color);
				}
				if(json.has("title_font")){
					int fontSize = json.getInt("title_font");
					if(fontSize<1){
						fontSize = 20;
					}
					remoteView.setFloat(R.id.notititle, "setTextSize", fontSize);
				}
				if(json.has("content_font")){
					int fontSize = json.getInt("content_font");
					if(fontSize<1){
						fontSize = 10;
					}
					remoteView.setFloat(R.id.noticontent, "setTextSize", fontSize);					
				}
			} catch(Exception e) {
				
			}finally {
				
			}
			
			notification.contentView = remoteView;
			notification.contentIntent = contentIntent;
		}else{
			notification = new NotificationCompat.Builder(context)
				.setSmallIcon(R.drawable.ic_stat_gcm)
				.setLargeIcon(bigIconBitmap)
				.setTicker(tickerText)
				.setWhen(when)
				.setAutoCancel(true)
				.setContentTitle(contentTitle)
				.setContentText(contentText)
				.setSound(soundUri, AudioManager.STREAM_NOTIFICATION)
				.setContentIntent(contentIntent)
				.build();
		}
		Vibrator v = (Vibrator) context.getSystemService(Context.VIBRATOR_SERVICE);
		if(v != null) {
			v.vibrate(100);  //vibrate 100 ms
		}
		NotificationManager notificationManager = (NotificationManager)context.getSystemService(Context.NOTIFICATION_SERVICE);
		notificationManager.notify(id, notification);
	}
	/* (non-Javadoc)
	 * @see com.google.android.gcm.GCMBaseIntentService#onMessage(android.content.Context, android.content.Intent)
	 */
	@Override
	protected void onMessage(Context context, Intent intent) {
		Log.d(TAG, "intent:" + intent.getExtras());
		
		Context app = context.getApplicationContext();
		ApplicationInfo appInfo = app.getApplicationInfo();
		String fileDirectory = app.getFilesDir().getAbsolutePath();
		
		String parameters = intent.getStringExtra("parameters");
		String tickerText = intent.getStringExtra("tickerText");
		String contentTitle = intent.getStringExtra("contentTitle");
		String contentText = intent.getStringExtra("contentText");
		int id = intent.getIntExtra("id", 0);
		
		Bitmap bigIconBitmap = null;
		Bitmap bgBitmap = null;
		JSONObject json = null;
		String urlStr = null;
		String bgUrlStr = null;
		Map<String, Object> map = new HashMap<String, Object>();
		int urlCount = 0;
		try {
			json = new JSONObject(parameters);
			if(json.has("bgUrl")){
				urlCount = urlCount + 1;
				bgUrlStr = json.getString("bgUrl");
				map.put("bg", null);
//				URL url = new URL(json.getString("pictureUrl"));
//				HttpURLConnection connection = (HttpURLConnection) url.openConnection();
//				connection.setDoInput(true);
//				connection.connect();
//				InputStream input = connection.getInputStream();
//				Bitmap retBitmap = BitmapFactory.decodeStream(input);
//				//bgBitmap = Bitmap.createScaledBitmap(retBitmap, 100, 100, true);
//				bgBitmap = retBitmap;
			}
			//优先使用服务器返回的图标
			if(json.has("pictureUrl")) {
				urlCount = urlCount + 1;
				urlStr = json.getString("pictureUrl");
				map.put("icon", null);
//				URL url = new URL(urlStr);
//				HttpURLConnection connection = (HttpURLConnection) url.openConnection();
//				connection.setDoInput(true);
//				connection.connect();
//				InputStream input = connection.getInputStream();
//				
//				Bitmap retBitmap = BitmapFactory.decodeStream(input);
//				bigIconBitmap = Bitmap.createScaledBitmap(retBitmap, 100, 100, true);
			}
			map.put("count", 0);
			if(bgUrlStr!=null){
				this.getPicture(context,intent,bgUrlStr,urlCount,"bg",map);
			}
			if(urlStr!=null){
				this.getPicture(context,intent,urlStr,urlCount,"icon",map);
			}
		} catch(Exception e) {
			urlStr = null;
			bgUrlStr = null;
			urlCount = 0;
			Log.e(TAG, e.getMessage(), e);
		}finally {
			if(urlStr==null && bgUrlStr==null && urlCount==0){
				this.startNotification(context, intent, null, null);
			}
		}
	}

	/* (non-Javadoc)
	 * @see com.google.android.gcm.GCMBaseIntentService#onError(android.content.Context, java.lang.String)
	 */
	@Override
	protected void onError(Context context, String errorId) {
		Log.e(TAG, "errorId:" + errorId);
		GoogleCloudMessagingBridge.callRegisteredCallback("ERR", false, errorId);
	}

	/* (non-Javadoc)
	 * @see com.google.android.gcm.GCMBaseIntentService#onRegistered(android.content.Context, java.lang.String)
	 */
	@Override
	protected void onRegistered(Context context, String registrationId) {
		Log.d(TAG, "reg id:" + registrationId);
		GoogleCloudMessagingBridge.callRegisteredCallback("REG", true, registrationId);
	}

	/* (non-Javadoc)
	 * @see com.google.android.gcm.GCMBaseIntentService#onUnregistered(android.content.Context, java.lang.String)
	 */
	@Override
	protected void onUnregistered(Context context, String registrationId) {
		Log.d(TAG, "reg id:" + registrationId);
		GoogleCloudMessagingBridge.callRegisteredCallback("UNREG", true, registrationId);
	}

}
