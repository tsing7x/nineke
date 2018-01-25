package com.boyaa.admobile.service;

import org.json.JSONObject;

import android.content.Context;
import android.content.SharedPreferences;

/**
 * @author Carrywen
 *
 */
public class CommitManager {
	
	public static String START = "start";
	public static String LOGIN = "login";
	public static String REGISTER = "register";
	public static String PLAY = "play";
	public static String PAY = "pay";
	public static String F_REGISTER = "firstRegister";
	public static String REG_PLAY = "regPlay";
	private static final String CONFIG = "ad_data";
	
	/**
	 * 保存点击次数
	 * 
	 * @param context
	 * @param payCustomize
	 */
	public static void saveValue(Context context, String type){
		SharedPreferences sharePreferences = context.getSharedPreferences(
				CONFIG, 0);
		if (sharePreferences != null) {
			SharedPreferences.Editor localEditor = sharePreferences.edit();
			int count = sharePreferences.getInt(type, 0)+1;
			localEditor.putInt(type, count);
			localEditor.commit();
		}
	}
	public static void saveValue(Context context,String type,String value){
		SharedPreferences sharePreferences = context.getSharedPreferences(
				CONFIG, 0);
		if (sharePreferences != null) {
			SharedPreferences.Editor localEditor = sharePreferences.edit();
			localEditor.putString(type, value);
			localEditor.commit();
		}
	}
	public static String getStringValue(Context context,String type){
		String value = "";
		SharedPreferences sharePreferences = context.getSharedPreferences(
				CONFIG, 0);
		if (null != sharePreferences) {
			value = sharePreferences.getString(type, "");
		}
		return value;
	}
	

	/**
	 * 取出点击次数
	 * 
	 * @param context
	 * @return
	 */
	public static int getVlaue(Context context, String key) {
		int count = 0;
		SharedPreferences sharePreferences = context.getSharedPreferences(
				CONFIG, 0);
		if (sharePreferences != null) {
			count = sharePreferences.getInt(key, 0);
		}
		return count;
	}
	
	
	
	public static String getResult(Context context){
		SharedPreferences sp = context.getSharedPreferences(
				CONFIG, 0);
		return new JSONObject(sp.getAll()).toString();
	}
	
	
	
	public static void clear(Context context){
		SharedPreferences sharePreferences = context.getSharedPreferences(
				CONFIG, 0);
		if (sharePreferences != null) {
			SharedPreferences.Editor localEditor = sharePreferences.edit();
			localEditor.clear();
			localEditor.commit();
		}
	}
	
	

}
