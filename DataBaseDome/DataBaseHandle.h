//
//  DataBaseHandle.h
//  DataBaseDome
//
//  Created by 瞿杰 on 2017/6/19.
//  Copyright © 2017年 yiniu. All rights reserved.
//

#import <Foundation/Foundation.h>


@class StudentEntity ;

@interface DataBaseHandle : NSObject

+(instancetype)dataBaseHandleWithDataBaseName:(NSString *)dataBaseName;

/// 创建数据库表
-(BOOL)addTableWithName:(nonnull NSString *)tableName keys:(NSArray<NSString *> *)keys ;

// 数据库文件存放所在的 Caches 文件夹路径
+(NSString *)dataBasePath ;

// 打开数据库
-(void)openDataBase ;
// 关闭数据库
-(void)closeDataBase ;

// 插入数据
-(void)insertDataWithKeyValues:(StudentEntity *)entity ;

// 更新
-(void)updateStudentGender:(NSString *)gender byNumber:(NSInteger)number ;

// 查询
// 查询所有数据
-(NSArray<StudentEntity *> *)selectAllKeyValues ;

// 根据条件查询
-(StudentEntity *)selectOneStudentByNumber:(NSInteger)number ;

// 模糊查询,只要包含 likeName 内容
-(StudentEntity *)selectOneStudentLikeName:(NSString *)likeName ;

// 中断一个长时间执行的查询语句
-(void)sqliteInterrupt;

// 删除表中数据
-(void)deleteOneStudentByNumber:(NSInteger)number ;

// 执行某条DML（数据库语句）之后，用于返回受该条DML语句影响的记录条数
-(NSInteger)sqliteEffectedChangesCount ;

// 用于返回受所有DML语句影响的所有记录条数
-(NSInteger)sqliteEffectedTolalChangesCount;

// 删除表
-(void)dropTable;


@end
