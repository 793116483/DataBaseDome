//
//  QJDataBaseTable.h
//  DataBaseDome
//
//  Created by 瞿杰 on 2019/12/4.
//  Copyright © 2019 yiniu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QJDataBaseTable : NSObject

@property (nonatomic , copy) NSString * name ;
@property (nonatomic , strong) NSMutableArray<NSString *> * keys ;

+(instancetype)createSQLTable:(NSString *)name ;

@end

NS_ASSUME_NONNULL_END
