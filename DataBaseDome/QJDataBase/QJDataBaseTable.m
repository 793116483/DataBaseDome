//
//  QJDataBaseTable.m
//  DataBaseDome
//
//  Created by 瞿杰 on 2019/12/4.
//  Copyright © 2019 yiniu. All rights reserved.
//

#import "QJDataBaseTable.h"

@implementation QJDataBaseTable

+(instancetype)createSQLTable:(NSString *)name {
    QJDataBaseTable * table = [[self alloc] init];
    table.name = name ;
    return table ;
}

-(NSMutableArray *)keys {
    if (!_keys) {
        _keys = [[NSMutableArray alloc] init];
    }
    return _keys ;
}

@end
