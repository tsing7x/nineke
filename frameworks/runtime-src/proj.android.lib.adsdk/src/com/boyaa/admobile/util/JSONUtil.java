package com.boyaa.admobile.util;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Map;


public class JSONUtil {

	private static final String UNKNOWN_INFO = "no info";
	private static final String NULL_INFO = ":null info";

	/**
	 * 将string转换成json，如果失败，则返回null
	 * @param json
	 * @return
	 */
	public static JSONObject parse(String json) {
		if (null == json || 0 == json.length()) {
			BDebug.e("JSONUtil", "null json string");
			return null;
		}
		try {
			return new JSONObject(json);
		} catch (JSONException e) {
			BDebug.e("JSONUtil", json);
			return null;
		}
	}

	public static JSONObject getJSONObject(JSONObject obj, String name) {
		if (null == obj)
			return null;
		try {
			return obj.getJSONObject(name);
		} catch (JSONException e) {
			BDebug.e("JSONUtil", name + "-->" + obj.toString());
			return null;
		}
	}

	// 返回为""标明没有error_type,否则返回值中是错误描述
	public static String checkErrorType(JSONObject obj) {
		if (null == obj) {
			return NULL_INFO;
		}
		String strType;
		try {
			strType = obj.getString("error_type");
		} catch (JSONException e) {
			return "";
		}

		String strInfo;
		try {
			strInfo = obj.getString("info");
		} catch (JSONException e) {
			strInfo = UNKNOWN_INFO;
		}
		if (null == strInfo || 0 == strInfo.length()) {
			strInfo = UNKNOWN_INFO;
		}
		StringBuilder sb = new StringBuilder();
		sb.append(strType);
		sb.append(":");
		sb.append(strInfo);
		return sb.toString();
	}
	/**
	 * 转换成String 
	 * @param params
	 * @return
	 */
	public static String mapToJson(Map<String,Object> params){
		JSONObject jsonObject =  new JSONObject(params);
		return jsonObject.toString();
	}
	// 不对name做判断，请调用者注意!
	public static String getString(JSONObject obj, String name,
			String defaultValue) {
		if (null == obj)
			return defaultValue;
		try {
			String str = obj.getString(name);
			// if ( null == str || 0 == str.length() )
			if (null == str) {
				BDebug.e("JSONUtil", name + "-->" + obj.toString());
				return defaultValue;
			}
			return str;
		} catch (JSONException e) {
			BDebug.e("JSONUtil", name + "-->" + obj.toString());
			return defaultValue;
		}
	}

	// 不对name做判断，请调用者注意!
	public static int getInt(JSONObject obj, String name, int defaultValue) {
		if (null == obj)
			return defaultValue;
		try {
			return obj.getInt(name);
		} catch (JSONException e) {
			BDebug.e("JSONUtil", name + "-->" + obj.toString());
			return defaultValue;
		}
	}

	// 不对name做判断，请调用者注意!
	public static long getLong(JSONObject obj, String name, long defaultValue) {
		if (null == obj)
			return defaultValue;
		try {
			return obj.getLong(name);
		} catch (JSONException e) {
			BDebug.e("JSONUtil", name + "-->" + obj.toString());
			return defaultValue;
		}
	}

	// 不对name做判断，请调用者注意!
	public static double getDouble(JSONObject obj, String name,
			double defaultValue) {
		if (null == obj)
			return defaultValue;
		try {
			return obj.getDouble(name);
		} catch (JSONException e) {
			BDebug.e("JSONUtil", name + "-->" + obj.toString());
			return defaultValue;
		}
	}

	// 不对name做判断，请调用者注意!
	public static boolean getBoolean(JSONObject obj, String name,
			boolean defaultValue) {
		if (null == obj)
			return defaultValue;
		try {
			return obj.getBoolean(name);
		} catch (JSONException e) {
			BDebug.e("JSONUtil", name + "-->" + obj.toString());
			return defaultValue;
		}
	}

	public static JSONArray getJSONArray(JSONObject obj, String name) {
		if (null == obj) {
			return null;
		}
		try {
			return obj.getJSONArray(name);
		} catch (JSONException e) {
			BDebug.e("JSONUtil", name + "-->" + obj.toString());
			return null;
		}
	}

	public static JSONArray parseArray(String json) {
		try {
			if (null == json || 0 == json.length()) {
				BDebug.e("JSONUtil", "null json array string");
				return null;
			}
			return new JSONArray(json);
		} catch (JSONException e) {
			BDebug.e("JSONUtil", json);
			return null;
		}
	}

	public static int getInt(JSONArray arr, int id, int defaultValue) {
		if (null == arr)
			return defaultValue;
		try {
			return arr.getInt(id);
		} catch (JSONException e) {
			BDebug.e("JSONUtil", id + "-->" + arr.toString());
			return defaultValue;
		}
	}

	public static JSONObject getJSONObject(JSONArray arr, int id) {
		if (null == arr)
			return null;
		try {
			return arr.getJSONObject(id);
		} catch (JSONException e) {
			BDebug.e("JSONUtil", id + "-->" + arr.toString());
			return null;
		}
	}

	public static String getString(JSONArray arr, int id, String defaultValue) {
		if (null == arr)
			return defaultValue;
		try {
			String str = arr.getString(id);
			if (null == str) {
				if (null == str) {
					BDebug.e("JSONUtil", id + "-->" + arr.toString());
					return defaultValue;
				}
			}
			return str;
		} catch (JSONException e) {
			BDebug.e("JSONUtil", id + "-->" + arr.toString());
			return defaultValue;
		}
	}

	/*************************************************************************/
	/**
	 * 从JOSNArray 中 获取 JOSNArray
	 */
	public static JSONArray getJSONArrayByJOSNArray(JSONArray arr, int id) {
		if (null == arr)
			return null;
		try {
			return arr.getJSONArray(id);
		} catch (JSONException e) {
			BDebug.e("JSONUtil", id + "-->" + arr.toString());
			return null;
		}
	}

}
