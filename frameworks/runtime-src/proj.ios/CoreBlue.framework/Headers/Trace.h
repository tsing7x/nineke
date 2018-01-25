//
//  Trace.h
//  CoreBluePay
//
//  Created by guojianmin on 16/2/24.
//  Copyright © 2016年 alvin. All rights reserved.
//

#ifndef Trace_h
#define Trace_h


#endif /* Trace_h */


@interface Trace : NSObject


+(void) i:(NSString*) tag info:(NSString*) msg;

+(void) e:(NSString*) tag info:(NSString*) msg;
+(void) on;
+(void) off;
@end