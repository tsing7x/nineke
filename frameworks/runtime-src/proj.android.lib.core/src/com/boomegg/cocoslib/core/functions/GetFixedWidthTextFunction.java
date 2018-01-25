package com.boomegg.cocoslib.core.functions;

import android.graphics.Paint;
import android.graphics.Typeface;
import android.text.TextUtils;
import android.util.Log;

public class GetFixedWidthTextFunction {
	
	private static final String TAG = GetFixedWidthTextFunction.class.getSimpleName();

	public static String apply(String font, int size, String text, int width) {
//		Log.d(TAG, "GetFixedWidthTextFunction: " + font + " " + size + " " + width + " " + text);
		if(text == null || text.length() <= 3) {
			return text;
		}
		
		Paint p = new Paint();
		p.setTextSize(size);
 		if(!TextUtils.isEmpty(font)) {
			p.setTypeface(Typeface.create(font, Typeface.NORMAL));
		} else {
			p.setTypeface(Typeface.DEFAULT);
		}
// 		if(text.indexOf("\n") != -1) {
// 			String[] textArr = text.split("\\n");
// 			StringBuilder result = new StringBuilder();
// 			for(String row : textArr) {
// 				Log.d(TAG, "mesure1 row " + row);
// 				StringBuilder sb = new StringBuilder(row.subSequence(0, 1));
// 				sb.append("..");
// 				int i;
// 				String ret = "";
// 				for(i = 1; i < row.length(); i++) {
// 					float w = p.measureText(sb.toString());
// 					Log.d(TAG, "mesure1 " + sb.toString() + " " + w + "|" + width);
// 					if(w < width) {
// 						ret = sb.toString();
// 						sb.insert(i, row.subSequence(i, i + 1));
// 						if(i + 1 == row.length()) {
// 							if(result.length() > 0) {
// 								result.append("\n");
// 							}
// 							result.append(row);
// 						}
// 					} else {
// 						if(result.length() > 0) {
//							result.append("\n");
//						}
//						result.append(ret);
//						Log.d(TAG, "mesure1 return1 => " + result.toString());
// 						return result.toString();
// 					}
// 				}
// 			}
// 			Log.d(TAG, "mesure1 return2 => " + result.toString());
// 			return result.toString();
// 		} else {
			StringBuilder sb = new StringBuilder(text.subSequence(0, 1));
			sb.append("..");
			int i;
			String ret = "";
			for(i = 1; i < text.length(); i++) {
				float w = p.measureText(sb.toString());
//				Log.d(TAG, "mesure " + sb.toString() + " " + w + "|" + width);
				if(w < width) {
					ret = sb.toString();
					sb.insert(i, text.subSequence(i, i + 1));
					if(i + 1 == text.length()) {
//						Log.d(TAG, "mesure return1 => " + text);
						return text;
					}
				} else {
					break;
				}
			}
//			Log.d(TAG, "mesure return2 => " + ret);
			return ret;
// 		}
	}
	
}
