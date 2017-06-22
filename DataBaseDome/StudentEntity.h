//
//  StudentEntity.h
//  DataBaseDome
//
//  Created by 瞿杰 on 2017/6/19.
//  Copyright © 2017年 yiniu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StudentEntity : NSObject

@property(nonatomic,assign)NSInteger number;
@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSString *gender;
@property(nonatomic,assign)NSInteger age;

@end
