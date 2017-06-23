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

// 删除表中数据
-(void)deleteOneStudentByNumber:(NSInteger)number ;

// 删除表
-(void)dropTable;


@end
