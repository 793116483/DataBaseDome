//
//  QJDataBaseObject.h
//  DataBaseDome
//
//  Created by 瞿杰 on 2019/12/4.
//  Copyright © 2019 yiniu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QJDataBaseTable.h"
#import <sqlite3.h>

NS_ASSUME_NONNULL_BEGIN


@interface QJDataBaseObject : NSObject

/// 数据库文件存放的绝对路径
@property (nonatomic , nullable , copy) NSString * dbPath ;

/// 单例
+(instancetype)share ;


/// 创建一个数据库表 添加到数据库中
/// @param tableName 表名
/// @param keys 表中的字段 key 名  , 字段存储类型都为 NSString
-(BOOL)addTableWithName:(nonnull NSString *)tableName keys:(NSArray<NSString *> *)keys ;

/// 获取表
-(nullable QJDataBaseTable *)getTableWithName:(nonnull NSString *)tableName ;

/// 删除整个表
-(BOOL)dropTable:(QJDataBaseTable *)table ;

/// 向数据库表中添加 key
/// @param keyName key name , 不能为 ID , 因为已经设置成了主键
/// @param table 数据库表
- (BOOL)addKeyWithName:(nullable NSString *)keyName toTable:(QJDataBaseTable *)table ;

#pragma mark - 执行数据库语句

/// 执行语句 , 建议使用 stepSQLString...
-(BOOL)execSQLString:(nonnull NSString *)sqlStr  ;

/// 执行SQL语句
/// @param sqlStr 数据库语句
/// @param bindMessageBlock 邦定数据回调(即 sqlStr 中 ? 数据邦定)
/// @param resultBlock 结果回调
-(BOOL)stepSQLString:(NSString *)sqlStr bindMessageBlock:(void(^)(sqlite3_stmt * stmt))bindMessageBlock resultBlock:(void(^)(NSArray<NSDictionary<NSString * , NSString *> *> * result))resultBlock ;

/// 邦定数据库语句 ? 代表 的数据
/// @param message 需要被邦定的数据
/// @param stmt 数据库管理指针
/// @param index 从第几个 ? 开始 , [0...n]
-(void)bindMessage:(nullable NSDictionary *)message stmt:(sqlite3_stmt *)stmt startIndex:(NSUInteger)index ;

#pragma mark - 插入数据
/// 插入数据
/// @param message 数据的 key value
/// @param table 表
-(BOOL)insertMassage:(nonnull NSDictionary *)message toTable:(QJDataBaseTable *)table ;


#pragma mark - 删除数据
/// 删除表中的数据
-(BOOL)deleteFromTable:(QJDataBaseTable *)table where:(nullable NSDictionary *)where ;


#pragma mark - 更新数据

/// 更新数据
/// @param message 数据的 key value
/// @param table 表
/// @param where 条件 数据 key value
-(BOOL)updateMessage:(NSDictionary *)message toTable:(QJDataBaseTable *)table where:(nullable NSDictionary *)where ;


#pragma mark - 查询数据
/// 查询数据
/// @param sqlStr 数据库语句
- (NSArray<NSDictionary<NSString * , NSString *> *> *)selectWithSQLString:(NSString *)sqlStr ;

/// 查询数据
/// @param table 表
/// @param where key value 条件
/// @param limitStartIndex 起始个数
/// @param length 长度
/// @param otherWhere 其他条件
-(NSArray<NSDictionary<NSString * , NSString *> *> *)selectFromTable:(QJDataBaseTable *)table where:(nullable NSDictionary *)where limitStartIndex:(NSUInteger)limitStartIndex count:(NSUInteger)count otherWhere:(nullable NSString *)otherWhere ;

/// 模糊查询
/// @param table 表
/// @param likeDic key value 模糊条件
-(NSArray<NSDictionary<NSString * , NSString *> *> *)selectFromTable:(QJDataBaseTable *)table whereLike:(NSDictionary<NSString * , NSString *> *)likeDic ;

#pragma mark - other
/// 中断一个长时间执行的查询语句
-(void)sqliteInterrupt ;

@end

NS_ASSUME_NONNULL_END
