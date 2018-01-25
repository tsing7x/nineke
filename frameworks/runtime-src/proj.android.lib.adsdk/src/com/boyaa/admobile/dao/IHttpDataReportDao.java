package com.boyaa.admobile.dao;

import java.util.HashMap;
import java.util.List;

import com.boyaa.admobile.entity.BasicMessageData;

/**
 * 数据上报服务接口
 * @author Carrywen
 *
 */
public interface IHttpDataReportDao {
	/**
	 * 插入上报记录
	 * @param data
	 * @return  
	 */
	public boolean insert(BasicMessageData data);
	/**
	 * 删除不上报记录
	 * @param pid
	 * @return
	 */
	public boolean delete(String pid);
	/**
	 * 查询待上报记录
	 * @return
	 */
	public List<BasicMessageData> queryReportData();
}
