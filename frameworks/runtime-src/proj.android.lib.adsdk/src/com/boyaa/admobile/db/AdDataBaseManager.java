package com.boyaa.admobile.db;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import com.boyaa.admobile.dao.IHttpDataReportDao;
import com.boyaa.admobile.entity.BasicMessageData;
import com.boyaa.admobile.util.BDebug;

import java.util.ArrayList;
import java.util.List;

/**
 * 数据库操作管理类
 * 
 * @author Carrywen
 * 
 */
public class AdDataBaseManager implements IHttpDataReportDao {
	private static final String TAG = "AdDataBaseManager";
	private AdDbHelper helper;
	private  static AdDataBaseManager manager;
	private AdDataBaseManager(Context context) {
		helper = new AdDbHelper(context);
	}
	public static AdDataBaseManager getInstance(Context context){
		if (null == manager) {
			manager = new AdDataBaseManager(context);
		}
		return manager;
	}

	public synchronized boolean insert(BasicMessageData data) {
		long id = 0;
		synchronized (helper._writeLock) {
			SQLiteDatabase db = helper.getWritableDatabase();
			db.beginTransaction();
			try {
				ContentValues cv = new ContentValues();
				cv.put(DbConstant.HTTP_LTS_AT, data.triggerTimestamp);
				cv.put(DbConstant.HTTP_SIG, data.sig);
				cv.put(DbConstant.HTTP_DEVICE_ID, data.deviceId);
				cv.put(DbConstant.HTTP_UID, data.uid);
				cv.put(DbConstant.HTTP_URL, data.serverUrl);
				cv.put(DbConstant.HTTP_EVENT_TYPE, data.eventType);
				cv.put(DbConstant.HTTP_PLA_UID, data.platformUid);
				cv.put(DbConstant.HTTP_IP, data.clientIp);
				cv.put(DbConstant.HTTP_CLI_VERSION, data.appVersion);
				cv.put(DbConstant.HTTP_CLI_OS, data.appOs);
				cv.put(DbConstant.HTTP_DEVICE_TYPE, data.deviceType);
				cv.put(DbConstant.HTTP_PX_INFO, data.pixelInfo);
				cv.put(DbConstant.HTTP_ISP, data.netServicePro);
				cv.put(DbConstant.HTTP_NW_TYPE, data.connNetType);
				cv.put(DbConstant.HTTP_PAY_MONEY, data.amount);
				cv.put(DbConstant.HTTP_PAY_RATE, data.rate);
				cv.put(DbConstant.HTTP_PAY_MODE, data.pmode);
				cv.put(DbConstant.HTTP_REF, data.httpRef);
				cv.put(DbConstant.HTTP_ID, data.recordId);
				cv.put(DbConstant.HTTP_API, data.api);
				cv.put(DbConstant.HTTP_ANDROID, data.androidId);
				cv.put(DbConstant.HTTP_MAC, data.macAddress);
                cv.put(DbConstant.HTTP_GAME_TIME, data.gameTime);
                id = db.insert(DbConstant.HTTP_DATA_TABLE, null, cv);
				db.setTransactionSuccessful();
			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				db.endTransaction();
				db.close();
			}
		}
		BDebug.d(TAG, id+"");
		return id >0? true : false;
	}

	public synchronized boolean delete(String pid) {
		boolean flag = false;
		int count = 0;
		synchronized (AdDbHelper._writeLock) {
			SQLiteDatabase db = helper.getWritableDatabase();
			db.beginTransaction();
			try{
				count = db.delete(DbConstant.HTTP_DATA_TABLE, DbConstant.HTTP_ID+"=?",
						new String[] { pid });
				db.setTransactionSuccessful();   
			}catch(Exception e){
				e.printStackTrace();
			}finally{    
			    db.endTransaction();    
				db.close();  
			}     
		}
		flag = (count > 0 ? true : false);
		BDebug.d(TAG, flag+"");
		return flag;
	}

	public synchronized List<BasicMessageData> queryReportData() {
		List<BasicMessageData> list = new ArrayList<BasicMessageData>();
		SQLiteDatabase db = null;
		db = helper.getReadableDatabase();
		db.beginTransaction();
		try{
			Cursor cursor =  db.rawQuery(DbConstant.DB_OP_QUERY_ALL, null);
			
			if (cursor != null) {
				int count = cursor.getColumnCount();
				while (cursor.moveToNext()) {
					BasicMessageData data = new BasicMessageData();
					data.amount = cursor.getString(cursor.getColumnIndex(DbConstant.HTTP_PAY_MONEY));
					data.triggerTimestamp = cursor.getString(cursor.getColumnIndex(DbConstant.HTTP_LTS_AT));
					data.sig = cursor.getString(cursor.getColumnIndex(DbConstant.HTTP_SIG));
					data.eventType = cursor.getString(cursor.getColumnIndex(DbConstant.HTTP_EVENT_TYPE));
					data.uid = cursor.getString(cursor.getColumnIndex(DbConstant.HTTP_UID));
					data.deviceId = cursor.getString(cursor.getColumnIndex(DbConstant.HTTP_DEVICE_ID));
					data.platformUid = cursor.getString(cursor.getColumnIndex(DbConstant.HTTP_PLA_UID));
					data.clientIp = cursor.getString(cursor.getColumnIndex(DbConstant.HTTP_IP));
					data.appVersion = cursor.getString(cursor.getColumnIndex(DbConstant.HTTP_CLI_VERSION));
					data.appOs = cursor.getString(cursor.getColumnIndex(DbConstant.HTTP_CLI_VERSION));
					data.deviceType = cursor.getString(cursor.getColumnIndex(DbConstant.HTTP_DEVICE_TYPE));
					data.pixelInfo = cursor.getString(cursor.getColumnIndex(DbConstant.HTTP_PX_INFO));
					data.netServicePro = cursor.getString(cursor.getColumnIndex(DbConstant.HTTP_ISP));
					data.connNetType = cursor.getString(cursor.getColumnIndex(DbConstant.HTTP_NW_TYPE));
					data.rate = cursor.getString(cursor.getColumnIndex(DbConstant.HTTP_PAY_RATE));
					data.pmode = cursor.getString(cursor.getColumnIndex(DbConstant.HTTP_PAY_MODE));
					data.httpRef = cursor.getString(cursor.getColumnIndex(DbConstant.HTTP_REF));
					data.recordId = cursor.getString(cursor.getColumnIndex(DbConstant.HTTP_ID));
					data.api = cursor.getString(cursor.getColumnIndex(DbConstant.HTTP_API));
					data.serverUrl = cursor.getString(cursor.getColumnIndex(DbConstant.HTTP_URL));
					data.macAddress = cursor.getString(cursor.getColumnIndex(DbConstant.HTTP_MAC));
					data.androidId = cursor.getString(cursor.getColumnIndex(DbConstant.HTTP_ANDROID));
					list.add(data);
				}
			}
		}catch(Exception e){
			e.printStackTrace();
		}finally{    
			db.endTransaction();    
			db.close();  
		} 
		return list;
	}

}
