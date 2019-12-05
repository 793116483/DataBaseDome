//
//  DataBaseHandle.m
//  DataBaseDome
//
//  Created by 瞿杰 on 2017/6/19.
//  Copyright © 2017年 yiniu. All rights reserved.
//

#import "DataBaseHandle.h"

#import "StudentEntity.h"
#import "QJDataBaseObject.h"

@interface DataBaseHandle ()

@property (nonatomic , strong) QJDataBaseObject * db ;

@property (nonatomic , copy) NSString * tableName ;

@end

@implementation DataBaseHandle

+(instancetype)dataBaseHandle
{
    DataBaseHandle * dataBaseHandle = [[self alloc] init];
    dataBaseHandle.db = [QJDataBaseObject share] ;
    
//    for (NSString * key in keys) {
//        [dataBaseHandle.db addKeyWithName:key proportyType:QJSQLKeyTypeDefault toTable:[dataBaseHandle.db getTableWithName:tableName]];
//    }
    
//    NSString * dataBaseFile = [dataBaseHandle dataBaseFile];
    
    // 打开数据库
//    int result = sqlite3_open([dataBaseFile UTF8String], &db);
    
//    if (result == SQLITE_OK) {
//        // 创建数据库表语句 , primary key autoincrement 修饰主键在表中值是唯一存在(最后一个单词自动增加)
//        // 条件：
//        // 1.表中必须要有一个主键；
//        // 2.在插入数据时主键自动增加使用 autoincrement 修饰;
//        // 3.主键的值在表中是唯一的，如果插入的数据主键值一样则不能添加在表内
//        NSString * sqliteStr = @"create table if not exists StudentList(stu_number integer primary key autoincrement,stu_name text,stu_gender text,stu_age integer)";
//        // 执行语句
//        sqlite3_exec(db, [sqliteStr UTF8String], NULL, NULL, NULL);
//    }
    
    return dataBaseHandle ;
}

/// 创建数据库表
-(BOOL)addTableWithName:(nonnull NSString *)tableName keys:(NSArray<NSString *> *)keys {
    
    // 向数据库添加表
    self.tableName = tableName ;
    BOOL result = [self.db addTableWithName:tableName keys:keys];
        
    return result ;
}

// 数据库文件存放所在的 Caches 文件夹路径
+(NSString *)dataBasePath
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

//// 数据库文件路径
//-(NSString *)dataBaseFile
//{
//    return [[DataBaseHandle dataBasePath] stringByAppendingPathComponent:[self.tableName stringByAppendingString:@".db"]];
//}

// 打开数据库
//-(void)openDataBase
//{
//    NSString * dataBaseFile = [self dataBaseFile];
//
//    NSLog(@"%@",dataBaseFile);
//
//    int result = sqlite3_open([dataBaseFile UTF8String], &db);
//
//    if (result == SQLITE_OK) {
//        NSLog(@"打开成功");
//    }
//    else{
//        NSLog(@"打开失败");
//    }
//}
//
//// 关闭数据库
//-(void)closeDataBase
//{
//    int result = sqlite3_close(db);
//    NSLog(@"%@",result == SQLITE_OK ? @"关闭成功":@"关闭失败");
//}

// 插入数据
-(void)insertDataWithKeyValues:(StudentEntity *)entity count:(int)count
{
    NSMutableArray * messages = [NSMutableArray array];
    for (int i = 0; i<count; i++) {
        NSDictionary * message = @{
            @"number" : @(entity.number) ,
            @"name" : entity.name ,
            @"gender" : entity.gender ,
            @"age" : @(entity.age) ,
            @"data": entity.data,
        };
        [messages addObject:message];
    }
    [self.db insertMassages:messages toTable:[self.db getTableWithName:self.tableName]];
    
    // 1.打开数据库
//    [self openDataBase];
    
    // 2.插入语句
//    NSString * sqlStr = @"insert into StudentList(stu_name,stu_gender,stu_age,stu_number)values(?,?,?,?)";

    // 3.创建数据管理指针
//    sqlite3_stmt * stmt = nil ;
//
//    // 4.验证数据库语句，
//    int result = sqlite3_prepare_v2(db, [sqlStr UTF8String], -1, &stmt, NULL);
//
//    if (result == SQLITE_OK) {
//        NSLog(@"可以插入数据");
//        // 5.帮定数据
//        // 参数：数据库管理指针 , 在 sqlStr 的第n个 ？, 数据库语句 , 语句长度(-1表示自动计算长度) ,
//        sqlite3_bind_text(stmt, 1, [entity.name UTF8String], -1, NULL);
//        sqlite3_bind_text(stmt, 2, [entity.gender UTF8String], -1, NULL);
//        sqlite3_bind_int(stmt, 3, (int)entity.age);
//        sqlite3_bind_int(stmt, 4, (int)entity.number);
//
//        // 6.让 sql 语句执行
//        sqlite3_step(stmt);
//    }
//
//    // 7.释放
//    sqlite3_finalize(stmt);
//
//    // 8.关闭数据库
//    [self closeDataBase];
}

// 更新数据
-(void)updateStudentGender:(NSString *)gender byNumber:(NSInteger)number
{
    NSDictionary * dataDic = @{@"gender":gender} ;
    NSDictionary * whereDic = @{@"number":@(number)} ;
    [self.db updateMessage:dataDic toTable:[self.db getTableWithName:self.tableName] where:whereDic] ;
    
//    [self openDataBase];
//
//    sqlite3_stmt * stmt = nil ;
//
//    NSString * sql = @"update StudentList set stu_gender = ? where stu_number = ?";
//
//    int result = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL);
//
//    if (result == SQLITE_OK) { // 是否可以执行
//
//        sqlite3_bind_text(stmt, 1, [gender UTF8String], -1, NULL);
//        sqlite3_bind_int(stmt, 2, (int)number);
//
//        sqlite3_step(stmt);
//    }
//
//    sqlite3_finalize(stmt);
//    [self closeDataBase];
}

// 查询所有数据
-(NSArray<StudentEntity *> *)selectAllKeyValues
{
    QJDataBaseTable * sqlTable = [self.db getTableWithName:self.tableName] ;
    
    NSArray<NSDictionary *> * resultArr = [self.db selectFromTable:sqlTable where:nil limitStartIndex:0 count:1000000000 otherWhere:nil];
    NSMutableArray * mArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (NSDictionary * dic in resultArr) {
        StudentEntity * entity = [[StudentEntity alloc] init];
        entity.number = [dic[@"number"] integerValue];
        entity.name = dic[@"name"];
        entity.gender = dic[@"gender"];
        entity.age = [dic[@"age"] integerValue];
        entity.data = [dic[@"data"] dataUsingEncoding:NSUTF8StringEncoding];
        
        [mArr addObject:entity];
    }
    
    return mArr ;
    // 1.打开数据库
//    [self openDataBase];
//
//    // 2.准备语句
//    NSString * sql = @"select * from StudentList ";
//
//    // 3.创建数据管理指针
//    sqlite3_stmt * stmt = nil ;
//
//    // 4.验证语句是否正确
//    int result = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL);
//
//    NSMutableArray * mArr = [[NSMutableArray alloc] initWithCapacity:0];
//
//    if (result == SQLITE_OK) {
//
//        // 5.获取数据
//        while (sqlite3_step(stmt) == SQLITE_ROW) {
//            StudentEntity * entity = [[StudentEntity alloc] init];
//            [mArr addObject:entity];
//
//            entity.number = sqlite3_column_int(stmt, 0);
//            entity.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 1)];
//            entity.gender = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)];
//            entity.age = sqlite3_column_int(stmt, 3);
//        }
//    }
//
//    // 6.释放 和 关闭数据库
//    sqlite3_finalize(stmt);
//    [self closeDataBase];
//
//    return mArr ;
}

// 查询某一个满足条件的数据
-(StudentEntity *)selectOneStudentByNumber:(NSInteger)number
{
    QJDataBaseTable * sqlObject = [self.db getTableWithName:self.tableName] ;

    NSDictionary * dic = [self.db selectFromTable:sqlObject where:@{@"number":@(number)} limitStartIndex:0 count:1 otherWhere:nil].firstObject;
    
    if (dic == nil) {
        return nil ;
    }
    
    StudentEntity * entity = [[StudentEntity alloc] init];
    entity.number = [dic[@"number"] integerValue];
    entity.name = dic[@"name"];
    entity.gender = dic[@"gender"];
    entity.age = [dic[@"age"] integerValue];
    entity.data = [dic[@"data"] dataUsingEncoding:NSUTF8StringEncoding];
    
    return entity ;
    
//    [self openDataBase];
//
//    // 数据库语句：* 表示每条数据的所有字段；? 表示需要帮定的值
//    NSString * sql = @"select * from StudentList where stu_number = ?";
//    // 多条件查询如：@"select * from StudentList where stu_number = ? and stu_name = ?"
//    // @"select * from StudentList where stu_number = ? or stu_name"
//    // @"select * from StudentList where stu_number > ?"
//    // @"select * from StudentList where stu_number > ? limit 5" 满足条件的5条数据
//    // @"select * from StudentList where stu_number > ? limit 3,5" 跳过前三条数据 接着取后5条
//    // @"select * from StudentList where stu_number > ?  order by stu_age disc " 在数据库中的数据满足条件 stu_number > ?(帮定的值) 选出的个数，然后以 stu_age 列把数据降序排列
//    // @"select stu_name,stu_age from StudentList where ...... " 选出满足条件数据条的 stu_name 和 stu_age 值
//
//
//    // 创建数据管理指针
//    sqlite3_stmt * stmt = nil ;
//    StudentEntity * entity = [[StudentEntity alloc] init];
//
//    // 验证语句是否正确
//    int result = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL);
//
//    if (result == SQLITE_OK) {
//        // 帮定参数
//        sqlite3_bind_int(stmt, 1, (int)number);
//        sqlite3_bind_text(stmt, 2, [@"李四" UTF8String], -1, NULL);
//
//        while (sqlite3_step(stmt) == SQLITE_ROW) {
//            entity.number = sqlite3_column_int(stmt, 0);
//            entity.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 1)];
//            entity.gender = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)];
//            entity.age = sqlite3_column_int(stmt, 3);
//        }
//    }
//
//    sqlite3_finalize(stmt);
//    [self closeDataBase];
//
//    return entity ;
}

// 模糊查询
-(StudentEntity *)selectOneStudentLikeName:(NSString *)likeName
{
    QJDataBaseTable * sqlObject = [self.db getTableWithName:self.tableName] ;

    NSDictionary * dic = [self.db selectFromTable:sqlObject whereLike:@{@"name":likeName} otherSqlStr:@"limit 1"].firstObject;
    
    StudentEntity * entity = [[StudentEntity alloc] init];
    entity.number = [dic[@"number"] integerValue];
    entity.name = dic[@"name"];
    entity.gender = dic[@"gender"];
    entity.age = [dic[@"age"] integerValue];
    entity.data = [dic[@"data"] dataUsingEncoding:NSUTF8StringEncoding];
    
    return entity ;
    
//    [self openDataBase];
//
//    sqlite3_stmt * stmt = nil ;
//    StudentEntity * entit = [[StudentEntity alloc] init] ;
//
//    NSString * sql = [NSString stringWithFormat:@"select * from StudentList where stu_name like '%%%@%%'",likeName];
//
//    int result = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL);
//
//    if (result == SQLITE_OK) {
//
//        NSLog(@"可以模糊查询");
//
////        sqlite3_bind_text(stmt, 1, [likeName UTF8String], -1, NULL);
//
//        while (sqlite3_step(stmt) == SQLITE_ROW) {
//            entit.number = sqlite3_column_int(stmt, 0);
//            entit.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 1)];
//            entit.gender = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)];
//            entit.age = sqlite3_column_int(stmt, 3);
//        }
//    }
//
//    sqlite3_finalize(stmt);
//    [self closeDataBase];
//
//    return entit ;
}

// 中断一个长时间执行的查询语句
-(void)sqliteInterrupt
{
    [self.db sqliteInterrupt];
//    [self openDataBase];
//
//    sqlite3_interrupt(db);
//
//    [self closeDataBase];
}

// 删除表中的数据
-(void)deleteOneStudentByNumber:(NSInteger)number
{
    [self.db deleteFromTable:[self.db getTableWithName:self.tableName] where:@{@"number":@(number)}];
    
//    [self openDataBase];
//
//    NSString * sql = @"delete from StudentList where stu_number = ?";
//
//    sqlite3_stmt * stmt = nil ;
//
//    int result = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL);
//
//    if (result == SQLITE_OK) {
//
//        sqlite3_bind_int(stmt, 1, (int)number);
//
//        // 执行语句
//        sqlite3_step(stmt);
//    }
//
//    sqlite3_finalize(stmt);
//    [self closeDataBase];
}

// 执行某条DML（数据库语句）之后，用于返回受该条DML语句影响的记录条数
-(NSInteger)sqliteEffectedChangesCount
{
    return 0 ;
//    [self openDataBase];
//
//    NSInteger count = sqlite3_changes(db);
//
//    [self closeDataBase];
//
//    return count ;
}

// 用于返回受所有DML语句影响的所有记录条数
-(NSInteger)sqliteEffectedTolalChangesCount
{
    return 0 ;
//    [self openDataBase];
//
//    NSInteger totalCount = sqlite3_total_changes(db);
//
//    [self closeDataBase];
//
//    return totalCount ;
}

// 删除整个表
-(void)dropTable
{
    [self.db dropTable:[self.db getTableWithName:self.tableName]];
    
//    [self openDataBase];
//
//    NSString * sql = @"drop table StudentList";
//
//    sqlite3_stmt * stmt = nil ;
//
//    int result = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL);
//
//    if (result == SQLITE_OK) {
//        NSLog(@"成功删除当前表");
//        sqlite3_step(stmt);
//    }
//
//    sqlite3_finalize(stmt);
//    [self closeDataBase];
}


@end
