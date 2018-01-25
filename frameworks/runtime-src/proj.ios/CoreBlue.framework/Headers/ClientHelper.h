//
//  ClientHelper.h
//  BluePay
//
//  Created by guojianmin on 16/1/25.
//  Copyright © 2016年 alvin. All rights reserved.
//

#ifndef ClientHelper_h
#define ClientHelper_h

#endif /* ClientHelper_h */

@interface ClientHelper : NSObject

/*!
 * @discription return the UUID from local.this uuid have stored by generateUUID function.
 */
+(NSString*)UUID;
/*!
 *@discription return the tid by random.
 *@param NSString*  never will be null
 *
 */
+(NSString*) generateTId;

/*!
 *@discription generate uuid and store on local.
 *
 */
 
+(void)generateUUID;

@end
