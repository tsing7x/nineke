package com.boyaa.admobile.db;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import com.boyaa.admobile.util.BDebug;

/**
 * @author Carrywen
 * 
 */
public class AdDbHelper extends SQLiteOpenHelper {
	private static final String TAG = "AdDbHelper";
	public final static byte[] _writeLock = new byte[0]; // 定义一个Byte作为写锁,解决多线程同时操作数据库问题

	public AdDbHelper(Context context) {
		super(context, DbConstant.DATABASE_NAME, null, DbConstant.DB_VERSION);
	}

	@Override
	public void onCreate(SQLiteDatabase db) {
		createDb(db);
	}

	@Override
	public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
		dropTable(db);
		createDb(db);
	}
	public void dropTable(SQLiteDatabase db){
		synchronized (_writeLock){
			db.beginTransaction();
			try {
				String sql = "drop table "+DbConstant.HTTP_DATA_TABLE;
				db.execSQL(sql);
				db.setTransactionSuccessful();
			} catch (Exception exception) {
				BDebug.d(TAG, exception.getMessage());
			} finally {
				db.endTransaction();
				BDebug.d("StartDbHelper", "删除startTask表成功");
			}
		}
	}
	public void createDb(SQLiteDatabase db) {
		synchronized (_writeLock) {
			db.beginTransaction();
			try {
				String sql = createHttpDataTableSql();
				db.execSQL(sql);
				db.setTransactionSuccessful();
			} catch (Exception exception) {
				BDebug.d(TAG, exception.getMessage());
			} finally {
				db.endTransaction();
				BDebug.d("StartDbHelper", "创建startTask表成功");
			}
		}
	}

	/**
	 * 创建数据库SQL
	 * 
	 * @return
	 */
	private String createHttpDataTableSql() {
		StringBuffer sbBuffer = new StringBuffer();
		sbBuffer.append("create table ")
				.append(DbConstant.HTTP_DATA_TABLE + "(")
				.append(DbConstant.HTTP_ID + " text primary key, ")
				.append(DbConstant.HTTP_LTS_AT + " text, ")
				.append(DbConstant.HTTP_SIG + " text, ")
				.append(DbConstant.HTTP_DEVICE_ID + " text, ")
				.append(DbConstant.HTTP_URL + " text, ")
				.append(DbConstant.HTTP_UID + " text, ")
				.append(DbConstant.HTTP_PLA_UID + " text, ")
				.append(DbConstant.HTTP_IP + " text, ")
				.append(DbConstant.HTTP_EVENT_TYPE + " text, ")
				.append(DbConstant.HTTP_CLI_VERSION + " text, ")
				.append(DbConstant.HTTP_CLI_OS + " text, ")
				.append(DbConstant.HTTP_DEVICE_TYPE + " text, ")
				.append(DbConstant.HTTP_PX_INFO + " text, ")
				.append(DbConstant.HTTP_ISP + " text, ")
				.append(DbConstant.HTTP_NW_TYPE + " text, ")
				.append(DbConstant.HTTP_API + " text, ")
				.append(DbConstant.HTTP_PAY_MONEY + " text, ")
				.append(DbConstant.HTTP_PAY_RATE + " text, ")
				.append(DbConstant.HTTP_PAY_MODE + " text, ")
				.append(DbConstant.HTTP_MAC + " text, ")
				.append(DbConstant.HTTP_ANDROID + " text, ")
                .append(DbConstant.HTTP_GAME_TIME + " text, ")
                .append(DbConstant.HTTP_REF + " text);");
		return sbBuffer.toString();
	}

}
