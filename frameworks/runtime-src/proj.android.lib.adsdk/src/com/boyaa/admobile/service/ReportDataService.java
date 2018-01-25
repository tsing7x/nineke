package com.boyaa.admobile.service;

import java.net.HttpURLConnection;
import java.util.HashMap;
import java.util.List;

import android.content.Context;
import android.text.TextUtils;

import com.boyaa.admobile.db.AdDataBaseManager;
import com.boyaa.admobile.entity.BasicMessageData;
import com.boyaa.admobile.util.BDebug;
import com.boyaa.admobile.util.BHttpRequest;
import com.boyaa.admobile.util.BUtility;
import com.boyaa.admobile.util.Constant;

/**
 * 数据操作
 * @author Carrywen
 *
 */
public class ReportDataService {
	private static AdDataBaseManager manager;
	private static ReportDataService service;
	
	private ReportDataService(Context context){
		manager = AdDataBaseManager.getInstance(context);
	}
	public static ReportDataService getReportService(Context context){
		if (null == service) {
			service = new ReportDataService(context);
		}
		return service;
	}
	
	public  boolean save(BasicMessageData data){
		return manager.insert(data);
	}
	public boolean delete(String pid){
		return manager.delete(pid);
	}
	public List<BasicMessageData> queryReportData(){
		return manager.queryReportData();
	}
	/**
	 * @param data
	 * @return
	 */
	public  HashMap<String, Object> reportDataToHttp(Context context,BasicMessageData data){
		String url = data.serverUrl;
		return BHttpRequest.requestPost(context,url,BUtility.convertDataToMap(data)); 
	}
	
	/**
	 * 后台服务一次处理 
	 */
	public void dealSqlData(Context context){
		List<BasicMessageData> datas = queryReportData();
		if (null !=datas && datas.size()>0) {
			for (int i = 0; i < datas.size(); i++) {
				HashMap<String, Object> resultMap = reportDataToHttp(context,datas.get(i));
				if (null != resultMap) {
					int code = (Integer) resultMap.get("code");
					if(code == HttpURLConnection.HTTP_OK){
						try {
							String reStr = (String) resultMap.get("result");
							BDebug.d("BRequestUtil",  reStr);
							HashMap retMap = BUtility.jsonToMap(reStr);	
							String retCode = (String) retMap.get("code");
							if (!TextUtils.isEmpty(retCode) && retCode.equals("0000")) {
								delete(retMap.get("pid")+"");
							}
						} catch (Exception e) {
							e.printStackTrace();
						}finally{
							continue;
						}
					}
				}else {
					continue;
				}
			}
		}
	}
}
