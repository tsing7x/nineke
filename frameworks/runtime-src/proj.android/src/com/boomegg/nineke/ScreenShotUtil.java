package com.boomegg.nineke;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.IntBuffer;

import javax.microedition.khronos.opengles.GL10;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.graphics.Bitmap.Config;
import android.graphics.Canvas;
import android.graphics.Rect;
import android.net.Uri;
import android.opengl.GLES10;
import android.os.Environment;
import android.provider.MediaStore;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.View;

import com.boomegg.cocoslib.core.Cocos2dxActivityUtil;
import com.google.android.gms.games.Game;

/**
 * 截图相关
 * @author SeanYang
 */
public class ScreenShotUtil {
	
	/**
	 * @param x
	 * @param y
	 * @param w
	 * @param h
	 * @param config 位图保存格式
	 * @return
	 */
	public static Bitmap saveGLPixels(int x, int y, int w, int h, Bitmap.Config config) {
		int b[] = new int[w * h];
		int bt[] = new int[w * h];
		IntBuffer ib = IntBuffer.wrap(b);
		ib.position(0);
		GLES10.glReadPixels(x, y, w, h, GL10.GL_RGBA, GL10.GL_UNSIGNED_BYTE, ib);
		for (int i = 0; i < h; i++) {
			for (int j = 0; j < w; j++) {
				int pix = b[i * w + j];
				int pb = (pix >> 16) & 0xff;
				int pr = (pix << 16) & 0x00ff0000;
				int pix1 = (pix & 0xff00ff00) | pr | pb;
				bt[(h - i - 1) * w + j] = pix1;
			}
		}
		Bitmap sb = Bitmap.createBitmap(bt, w, h, config);
		return sb;
	}
	
	/**
	 * @param rect
	 * @return
	 */
	public static Bitmap saveGLPixels(Rect rect) {
		// 坐标需要
		return saveGLPixels(rect.left, rect.top, rect.width(), rect.height(), Bitmap.Config.ARGB_8888);
	}

	public static Bitmap takeScreenShot(Activity activity) {
		View view = activity.getWindow().getDecorView();
		int width = view.getWidth();
		int height = view.getHeight();
		Bitmap bmp = Bitmap.createBitmap(width, height, Config.ARGB_8888);
		Canvas c = new Canvas(bmp);
		view.draw(c);
		return bmp;
	}

	private static void savePic(Bitmap b, String strFileName, CompressFormat format) {
		FileOutputStream fos = null;
		try {
			fos = new FileOutputStream(strFileName);
			if (null != fos) {
				b.compress(format, 90, fos);
				fos.flush();
				fos.close();
			}
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public static String saveScreenShot(String fileName) {
		File file = new File(Environment.getExternalStorageDirectory(), fileName);
		if (!file.exists()) {
			try {
				file.createNewFile();
			} catch (IOException e) {
			}
		}
		Bitmap bmp = takeScreenShot(NineKe.getContext());
		savePic(bmp, file.getAbsolutePath(), Bitmap.CompressFormat.PNG);
		return file.getAbsolutePath();
	}

	public static File saveBitmapAsFile(Bitmap bmp, String fileName) {
		File file = new File(Environment.getExternalStorageDirectory(), fileName);
		if (!file.exists()) {
			try {
				file.createNewFile();
			} catch (IOException e) {
			}
		}
		savePic(bmp, file.getAbsolutePath(), Bitmap.CompressFormat.PNG);
		return file;
	}

	public static String saveBitmap(Bitmap bmp, String filePath, String fileName) {
		String path = null;
		if (null == filePath || 0 == filePath.length())
			return path;
		if (null == fileName || 0 == fileName.length())
			return path;
		if (null == bmp)
			return path;
		if (bmp.isRecycled())
			return path;

		String fullPath = filePath + fileName;

		File file = new File(fullPath);
		try {
			if(file.exists()){
				file.delete();
			}
			file.createNewFile();
		} catch (IOException e) {
			return path;
		}
		path = file.getAbsolutePath();
		savePic(bmp, path, Bitmap.CompressFormat.JPEG);
		return path;
	}
	
	private static int callbackMethodId = -1;
	
	public static void screenShot(int methodId,int x, int y, int w, int h) {
		if(-1 != callbackMethodId){
			Cocos2dxLuaJavaBridge.releaseLuaFunction(callbackMethodId);
			callbackMethodId = -1;
		}
		callbackMethodId = methodId;
		
		if(w==0||h==0){
			x=0;
			y=0;
			DisplayMetrics dm = new DisplayMetrics();
			NineKe.getContext().getWindowManager().getDefaultDisplay().getMetrics(dm);
			w = dm.widthPixels;
			h = dm.heightPixels;
		}
		Bitmap bmp = saveGLPixels(x,y,w,h,Config.ARGB_8888);
		File appDir = new File(Environment.getExternalStorageDirectory(), "NineKe");
		if (!appDir.exists()) {
			appDir.mkdir();
		}
		String fileName = System.currentTimeMillis() + ".jpg";
		File file = new File(appDir, fileName);
		try {
			FileOutputStream fos = new FileOutputStream(file);
			bmp.compress(CompressFormat.JPEG, 100, fos);
			fos.flush();
			fos.close();
		}catch (FileNotFoundException e) {
			//异常
			Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
				@Override
				public void run() {
					Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callbackMethodId, "0");
				}
			});
			e.printStackTrace();
			return;
		}catch (IOException e) {
			//异常
			Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
				@Override
				public void run() {
					Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callbackMethodId, "0");
				}
			});
			e.printStackTrace();
			return;
		}
		// 其次把文件插入到系统图库
		try {
			MediaStore.Images.Media.insertImage(NineKe.getContext().getContentResolver(),file.getAbsolutePath(), fileName, null);
		} catch (FileNotFoundException e) {
			//异常
			Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
				@Override
				public void run() {
					Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callbackMethodId, "0");
				}
			});
			e.printStackTrace();
			return;
		}
		// 最后通知图库更新
		NineKe.getContext().sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.parse("file://" + file.getAbsolutePath())));
		//正常
		Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
			@Override
			public void run() {
				Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callbackMethodId, "1");
			}
		});
	}
	
	private static int callbackMethodId1 = -1;
	
	public static void updateMediaStore(String filePath,String fileName,int methodId) {
		if(-1 != callbackMethodId){
			Cocos2dxLuaJavaBridge.releaseLuaFunction(callbackMethodId1);
			callbackMethodId1 = -1;
		}
		callbackMethodId1 = methodId;
		// 其次把文件插入到系统图库
		try {
			MediaStore.Images.Media.insertImage(NineKe.getContext().getContentResolver(),filePath, fileName, null);
		} catch (FileNotFoundException e) {
			//异常
			Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
				@Override
				public void run() {
					Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callbackMethodId1, "0");
				}
			});
			e.printStackTrace();
			return;
		}
		// 最后通知图库更新
		NineKe.getContext().sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.parse("file://" + filePath)));
		//正常
		Cocos2dxActivityUtil.runOnGLThread(new Runnable() {
			@Override
			public void run() {
				Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callbackMethodId1, "1");
			}
		});
	}
}