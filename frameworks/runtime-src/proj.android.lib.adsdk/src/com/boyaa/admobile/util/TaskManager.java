package com.boyaa.admobile.util;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.Queue;

import android.content.Context;

import com.boyaa.admobile.entity.AdTask;


/**
 * 任务队列管理器（加线程池管理)
 * @author CarryWen
 *
 */
public class TaskManager {

	private static byte[] syn = new byte[0];
	
	private static int threadCount = 4;
	private Context mContext;
	private LooperThread mLooperThread;
	
	private int sleepTime = 3000;
	
	private  Queue<AdTask> taskQueue = new LinkedList<AdTask>();  
	
	private  List<TaskThread> threadPool = new ArrayList<TaskThread>();
	
	private static TaskManager mBTaskManager;
	
	private TaskManager(Context context){
		mContext = context;
		for(int i=0; i<threadCount; i++){
			TaskThread thread = new TaskThread(i,mContext);
			threadPool.add(thread);
			thread.start();
		}
	}
	
	
	public static TaskManager getInstance(Context context){
		synchronized (syn) {
			if(mBTaskManager == null){
				mBTaskManager = new TaskManager(context);
			}
		}
		return mBTaskManager;
	}
	
	
	
	
	public  void addTask(AdTask task){
		if(task == null){
			return;
		}
		if(mLooperThread == null){
			mLooperThread = new LooperThread();
			mLooperThread.start();
		}
		taskQueue.add(task);
		
		if(!mLooperThread.isRunning){
			mLooperThread.setRun(true);
		}		
		System.out.println("task queque size "+ taskQueue.size());
	}
	
	
	
	private  void executeTask(AdTask task){
		//System.out.println("executeTask "+task);
		TaskThread thread = null;
		for(int i=0; i<threadCount; i++){
			 thread = threadPool.get(i);
			 if(thread.isRunning()){
				 thread =null;
			 }else{
				 break;
			 }
		}
		if(thread == null){
			System.out.println("线程池满?..");
			addTask(task);
			return;
		}
		System.out.println("thread flag  "+thread.flag);
		thread.setArgument(task);
		thread.setRun(true);
	}
	
	
	
	
	
	class LooperThread extends Thread{
		
		 private boolean isRunning;
		 public boolean isRunning(){
		    return this.isRunning;
		 }
		 
		 public synchronized void setRun(boolean isRunning) {
			 this.isRunning = isRunning;
			 if(this.isRunning){
				 this.notify();
			 }
		}
		 
		 @Override
		public synchronized void run() {
			while(true){
				if(taskQueue.size() == 0){
					
						 try {
							setRun(false);
							wait();
						} catch (InterruptedException e) {
							e.printStackTrace();
						}

				}else{
					AdTask task = taskQueue.poll();
					executeTask(task);
				}
				System.out.println("running..taskQueue. "+taskQueue.size() );
				try {
					Thread.sleep(sleepTime);
				} catch (InterruptedException e) {
					e.printStackTrace();
				}
								
			}
		}
	}
	
}


class TaskThread extends Thread{
	
	public int flag;
	public Context context;
	public TaskThread(int flag,Context context){
		this.flag = flag;
		this.context = context;
	}
	
	private boolean isRunning;
	
	private AdTask task;
	
	 public boolean isRunning(){
	    return this.isRunning;
	 }
	 
	 public void setArgument(AdTask task){
		// System.out.println("setArgument "+task);
	    this.task = task;
	 }
	 
	 public synchronized void setRun(boolean isRunning) {
		 this.isRunning = isRunning;
		 if(this.isRunning){
			 this.notify();
		 }
	}
	 
	 @Override
	public synchronized void run() {
		// System.out.println("run ---------- ");
		 while(true){
			 if(!this.isRunning){
				 try {
					wait();
				} catch (InterruptedException e) {
					e.printStackTrace();
				}
			 }
			 
			 try{
				 if(this.task != null){
					 this.task.context = context;
					 if (this.task.offLineFlag) {
						this.task.offLineTask();
					 }else {
						 this.task.execute();
					}
				 }
			 }catch(Exception e){
				 e.printStackTrace();
			 }
			 
			 setRun(false);
		 }
		 
	}		
}
