package com.boyaa.admobile.util;

import android.content.Context;
import android.os.Build.VERSION;
import android.text.TextUtils;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.SocketTimeoutException;
import java.net.URL;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

/**
 * HTTP 服务类
 * 
 * @author Carrywen
 * 
 */
public class BHttpRequest {
	public static final String TAG = "BHttpRequest";

	/**
	 * get请求
	 * 
	 * @param url
	 * @param parameterMap
	 */
	public static HashMap<String, Object> requestGet(Context context,
			String url, HashMap parameterMap) {
		HashMap<String, Object> resultMap = new HashMap<String, Object>();
		resultMap.put("code", 0);
		resultMap.put("result", "fail");

		if (TextUtils.isEmpty(url)) {
			BDebug.d(TAG, "url is empty");
			resultMap.put("result", "参数url为空");
			return resultMap;
		}

		HttpURLConnection httpURLConnection = null;
		BufferedReader br = null;
		try {
			StringBuffer sb = new StringBuffer(url);
			if (parameterMap != null) {
				if (url.indexOf("?") < 0) {
					sb.append("?");
				}
				Iterator localIterator = parameterMap.entrySet().iterator();
				while (localIterator.hasNext()) {
					Map.Entry entry = (Map.Entry) localIterator.next();
					sb.append((String) entry.getKey());
					sb.append("=");
					try {
						// sb.append((String)entry.getKey());
						Object obj = entry.getValue();
						if (obj != null) {
							sb.append(URLEncoder.encode(obj.toString(), "utf-8"));
						} else {
							sb.append("");
						}
						sb.append("&");
					} catch (Exception localException) {
						BDebug.e(TAG, "http exception", localException);
						Object obj = entry.getValue();
						if (obj != null) {
							sb.append(URLEncoder.encode(obj.toString(), "utf-8"));
						} else {
							sb.append("");
						}

						sb.append("&");
					}
				}
				if (sb.length() > 0) {
					sb = sb.deleteCharAt(sb.length() - 1);
				}
			}
			BDebug.d("requestGet", sb.toString());

			URL localURL = new URL(sb.toString());
			httpURLConnection = (HttpURLConnection) localURL.openConnection();
			if (VERSION.SDK_INT < 13) {
				httpURLConnection.setDoOutput(true);
			}
			httpURLConnection.setDoInput(true);
			httpURLConnection.setConnectTimeout(Constant.TIME_OUT);
			httpURLConnection.setRequestMethod("GET");
			httpURLConnection.connect();

			int code = httpURLConnection.getResponseCode();
			InputStream inputStream = httpURLConnection.getInputStream();

			br = new BufferedReader(new InputStreamReader(inputStream));
			String lineStr = null;
			StringBuilder resultSB = new StringBuilder();
			while ((lineStr = br.readLine()) != null) {
				resultSB.append(lineStr);
			}

			resultMap.put("code", code);
			resultMap.put("result", resultSB.toString());

		} catch (Exception e) {
			resultMap.put("result", "出现异常");
			BDebug.e(TAG, "http exception", e);
		} finally {
			try {
				if (httpURLConnection != null) {
					httpURLConnection.disconnect();
				}
				if (br != null) {
					br.close();
				}
			} catch (Exception e) {
				BDebug.e(TAG, "http exception", e);
			}
		}
		return resultMap;
	}

	/**
	 * get请求
	 * 
	 * @param url
	 * @param parameterMap
	 */
	public static HashMap<String, Object> requestGet(Context context, String url) {
		HashMap<String, Object> resultMap = new HashMap<String, Object>();
		resultMap.put("code", 0);
		resultMap.put("result", "fail");

		if (TextUtils.isEmpty(url)) {
			resultMap.put("result", "参数url为空");
			return resultMap;
		}

		HttpURLConnection httpURLConnection = null;
		BufferedReader br = null;
		try {
			StringBuffer sb = new StringBuffer(url);

			BDebug.d("requestGet", sb.toString());

			URL localURL = new URL(sb.toString());
			httpURLConnection = (HttpURLConnection) localURL.openConnection();
			if (VERSION.SDK_INT < 13) {
				httpURLConnection.setDoOutput(true);
			}
			httpURLConnection.setDoInput(true);
			httpURLConnection.setConnectTimeout(Constant.TIME_OUT);
			httpURLConnection.setRequestMethod("GET");
			httpURLConnection.connect();

			int code = httpURLConnection.getResponseCode();
			InputStream inputStream = httpURLConnection.getInputStream();

			br = new BufferedReader(new InputStreamReader(inputStream));
			String lineStr = null;
			StringBuilder resultSB = new StringBuilder();
			while ((lineStr = br.readLine()) != null) {
				resultSB.append(lineStr);
			}

			resultMap.put("code", code);
			resultMap.put("result", resultSB.toString());

		} catch (SocketTimeoutException e) {
			resultMap.put("result", "请求超时，请重试");
			e.printStackTrace();
		} catch (Exception e) {
			resultMap.put("result", "出现异常");
			e.printStackTrace();
		} finally {
			try {
				if (httpURLConnection != null) {
					httpURLConnection.disconnect();
				}
				if (br != null) {
					br.close();
				}

			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		return resultMap;
	}

	/**
	 * post请求
	 * 
	 * @param url
	 * @param parameterMap
	 */
	public static HashMap<String, Object> requestPost(Context context,
			String url, HashMap<String, String> parameterMap) {
		HashMap<String, Object> resultMap = new HashMap<String, Object>();
		resultMap.put("code", 0);
		resultMap.put("result", "fail");

		if (TextUtils.isEmpty(url)) {
			resultMap.put("result", "参数url为空");
			return resultMap;
		}

		HttpURLConnection httpURLConnection = null;
		BufferedReader br = null;
		try {
			URL localURL = new URL(url);
			httpURLConnection = (HttpURLConnection) localURL.openConnection();
			httpURLConnection.setDoOutput(true);
			httpURLConnection.setDoInput(true);
			httpURLConnection.setConnectTimeout(Constant.TIME_OUT);
			httpURLConnection.setRequestMethod("POST");

			// localHttpURLConnection.setRequestProperty("Cookie",
			// RLUtility.getCookie(paramContext));

			byte[] bytes = outputDataForBody(parameterMap);
			String tString = new String(bytes);
			BDebug.d("BhttpRequest", new String(bytes));

			httpURLConnection.setRequestProperty("Content-Length",
					String.valueOf(bytes.length));

			DataOutputStream dateOutputStream = new DataOutputStream(
					httpURLConnection.getOutputStream());

			dateOutputStream.write(bytes, 0, bytes.length);
			dateOutputStream.flush();
			dateOutputStream.close();
			httpURLConnection.connect();

			int code = httpURLConnection.getResponseCode();
			InputStream inputStream = httpURLConnection.getInputStream();

			br = new BufferedReader(new InputStreamReader(inputStream));
			String lineStr = null;
			StringBuilder sb = new StringBuilder();
			while ((lineStr = br.readLine()) != null) {
				sb.append(lineStr);
			}

			resultMap.put("code", code);
			resultMap.put("result", sb.toString());

		} catch (SocketTimeoutException e) {
			resultMap.put("result", "请求超时，请重试");
			e.printStackTrace();
		} catch (Exception e) {
			resultMap.put("result", "出现异常");
			e.printStackTrace();
		} finally {
			try {
				if (httpURLConnection != null) {
					httpURLConnection.disconnect();
				}
				if (br != null) {
					br.close();
				}

			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		return resultMap;
	}

	/**
	 * 将参数转化为字节数组
	 * 
	 * @param paramMap
	 * @return
	 */
	private static byte[] outputDataForBody(Map<String, String> paramMap) {
		StringBuffer sb = new StringBuffer();
		Iterator localIterator = paramMap.entrySet().iterator();

		while (localIterator.hasNext()) {
			Map.Entry entry = (Map.Entry) localIterator.next();
			sb.append(((String) entry.getKey()));
			sb.append("=");
			try {
				Object obj = entry.getValue();
				if (obj != null) {
					sb.append(URLEncoder.encode(obj.toString(), "utf-8"));
				} else {
					sb.append("");
				}
				sb.append("&");
			} catch (Exception localException) {
				localException.printStackTrace();
				Object obj = entry.getValue();
				if (obj != null) {
					try {
						sb.append(URLEncoder.encode(obj.toString(), "utf-8"));
					} catch (UnsupportedEncodingException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
				} else {
					sb.append("");
				}
				sb.append("&");
			}
		}

		if (sb.length() > 0) {
			sb = sb.deleteCharAt(-1 + sb.length());
		}

		return sb.toString().getBytes();
	}

}
