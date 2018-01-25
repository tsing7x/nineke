//
//  BlueMessage.h

//
//  Created by guojianmin on 16/1/13.
//  Copyright © 2016年 alvin. All rights reserved.
//

#ifndef BlueMessage_h
#define BlueMessage_h


#endif /* BlueMessage_h */

#define TELCO_INDOSAT @"indosat"
#define TELCO_XL @"xl"

@interface BlueMessage : NSObject
{
    NSInteger _code;
    NSString* _desc;
    NSString* _price;
    NSString* _propsName;
    NSString* _transactionId;
    NSString* _pCode;
    

}
@property(nonatomic, retain) NSString* desc,*price,*propsName ,*transactionId,*pCode,*publisher,*telco;
@property(nonatomic) NSInteger code;
@end