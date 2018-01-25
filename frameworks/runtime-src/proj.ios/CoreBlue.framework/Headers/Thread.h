//
//  Thread.h
//  BluePay
//
//  Created by guojianmin on 16/1/9.
//  Copyright © 2016年 alvin. All rights reserved.
//

#ifndef Thread_h

#define Thread_h

#import <Foundation/Foundation.h>
#import "Protocol.h"
#endif /* Thread_h */


@interface Thread : NSOperation
{
    __unsafe_unretained id<Protocol > _threadProc;
    NSMutableDictionary* _params;
    
}
@property(nonatomic,assign)  id<Protocol> threadProc;
@property(nonatomic,copy) NSMutableDictionary * params;
/*!
 * @discription 重写了init函数
 * @param  aParams  NSMutableDictionary*  参数表，往往是用于请求服务器的参数列表
 **/
-(Thread*) init: (NSMutableDictionary*) aParams;;
@end