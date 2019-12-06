//
//  QJDataBaseObject.m
//  DataBaseDome
//
//  Created by 瞿杰 on 2019/12/4.
//  Copyright © 2019 yiniu. All rights reserved.
//

#import "QJDataBaseObject.h"


/// 数据库
static sqlite3 * db = nil ;

@interface QJDataBaseObject ()

@property (nonatomic , strong) NSMutableArray<QJDataBaseTable *> * tables ;


@end

@implementation QJDataBaseObject

+(instancetype)share {
    static dispatch_once_t onceToken;
    static QJDataBaseObject * shareObj = nil ;
    dispatch_once(&onceToken, ^{
        // 数据库存放的文件夹
        NSString * directory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] ;
        shareObj = [self createSQLWithDBName:@"SQLite3.db" inDirectory:directory] ;
    });
    return shareObj ;
}
+(instancetype)createSQLWithDBName:(NSString *)dbName inDirectory:(NSString *)dicrectory {
    QJDataBaseObject * dbObject = [[self alloc] init];
    dbObject.dbPath = [dicrectory stringByAppendingPathComponent:dbName] ;
    
    return dbObject ;
}


/// 创建数据库表
-(BOOL)addTableWithName:(nonnull NSString *)tableName keys:(NSArray<NSString *> *)keys {

    // 创建数据库表语句 , primary key autoincrement 修饰主键在表中值是唯一存在(最后一个单词自动增加)
    // 条件：
    // 1.表中必须要有一个主键；
    // 2.在插入数据时主键自动增加使用 autoincrement 修饰;
    // 3.主键的值在表中是唯一的，如果插入的数据主键值一样则不能添加在表内
    NSMutableString * columns = [NSMutableString string];
    for (NSString * key  in keys) {
        if ([key isEqualToString:keys.lastObject]) {
            [columns appendFormat:@"%@ text",key];
        } else {
            [columns appendFormat:@"%@ text , ", key];
        }
    }
    
    NSMutableString * sqliteStr = [NSMutableString stringWithFormat:@"create table if not exists %@(ID integer primary key autoincrement ",tableName];
    if (columns.length) {
        [sqliteStr appendFormat:@", %@ ",columns];
    }
    [sqliteStr appendString:@")"];

    // 执行语句
    BOOL result = [self execSQLString:sqliteStr];
    if (result) {
        QJDataBaseTable * table = [QJDataBaseTable createSQLTable:tableName] ;
        [table.keys addObjectsFromArray:keys];
        [self.tables addObject:table];
    }

    return result ;
}

/// 获取表
-(nullable QJDataBaseTable *)getTableWithName:(nonnull NSString *)tableName {
    for (QJDataBaseTable * table in self.tables) {
        if ([table.name isEqualToString:tableName]) {
            return table ;
        }
    }
    return nil ;
}

// 删除整个表
-(BOOL)dropTable:(QJDataBaseTable *)table
{
    NSString * sql = [NSString stringWithFormat:@"drop table if exists %@",table.name];
    
    int result = [self stepSQLString:sql bindMessageBlock:nil resultBlock:nil];
    if (result == SQLITE_OK) {
        [self.tables removeObject:table];
    }
    return result == SQLITE_OK;
}


// 数据库文件路径
-(NSString *)dataBaseFile
{
    return self.dbPath;
}

// 打开数据库
-(BOOL)openDataBase
{
    NSString * dataBaseFile = [self dataBaseFile];
    
    int result = sqlite3_open([dataBaseFile UTF8String], &db);
    
    NSLog(result == SQLITE_OK ? @"数据库打开成功" : @"打开失败");
    return result == SQLITE_OK ;
}

// 关闭数据库
-(BOOL)closeDataBase
{
    int result = sqlite3_close(db);
    NSLog(@"%@",result == SQLITE_OK ? @"关闭成功":@"关闭失败");
    return result == SQLITE_OK ;
}
/// 执行语句
-(BOOL)execSQLString:(nonnull NSString *)sqlStr {
    BOOL result = false ;
    
    // 打开数据库
    if ([self openDataBase]) {
        // 执行语句
        result = sqlite3_exec(db, [sqlStr UTF8String], NULL, NULL, NULL) == SQLITE_OK;
    }
    
    // 关闭数据库
    [self closeDataBase];
    
    return result ;
}

/// 执行SQL语句
/// @param sqlStr 数据库语句
/// @param bindMessageBlock 邦定数据回调(即 sqlStr 中 ? 数据邦定)
/// @param resultBlock 结果回调
-(BOOL)stepSQLString:(NSString *)sqlStr bindMessageBlock:(void(^)(sqlite3_stmt * stmt))bindMessageBlock resultBlock:(void(^)(NSArray<NSDictionary *> * result))resultBlock {
    
    // 1.打开数据库
    [self openDataBase];

    // 2.创建 数据库管理指针
    sqlite3_stmt * stmt = nil ;
    
    // 3.验证 数据库语句
    int result = sqlite3_prepare_v2(db, [sqlStr UTF8String], -1, &stmt, NULL);
    
    // 4.是否可以执行
    if (result == SQLITE_OK) {
        // 5.邦定数据
        if (bindMessageBlock) {
            bindMessageBlock(stmt);
        }
        
        NSMutableArray * mArr = [[NSMutableArray alloc] initWithCapacity:0];

        // 6.执行 数据库语句
        while (( result = sqlite3_step(stmt) ) == SQLITE_ROW) {
            NSMutableDictionary * entity = [[NSMutableDictionary alloc] init];
            [mArr addObject:entity];
            
            int count = sqlite3_column_count(stmt) ;
            for (int i = 0; i < count ; i++) {
                NSString * key = [NSString stringWithUTF8String:sqlite3_column_name(stmt, i)] ;
                
                int type = sqlite3_column_type(stmt, i) ;
                switch (type) {
                case SQLITE_INTEGER:
                        entity[key] = @(sqlite3_column_int(stmt, i)) ;
                        break;
                case SQLITE_FLOAT:
                        entity[key] = @(sqlite3_column_double(stmt, i)) ;
                        break;
                case SQLITE_BLOB:
                        entity[key] = (__bridge id _Nullable)(sqlite3_column_blob(stmt, i)) ;
                        break;
                case SQLITE_TEXT:
                        entity[key] = [NSString stringWithUTF8String:sqlite3_column_text(stmt, i)] ;
                        break;
                case SQLITE_NULL:
                        entity[key] = @"" ;
                        break;
                        default:
                        break;
                }
            }
        }
        // 7.结果 回调
        if (resultBlock) {
            resultBlock(mArr);
        }
    }
    
    // 8.释放 数据库管理指针
    sqlite3_finalize(stmt);
    
    // 执行某条DML（数据库语句）之后，用于返回受该条DML语句影响的记录条数
    NSInteger count = sqlite3_changes(db);
    // 用于返回受所有DML语句影响的所有记录条数
    NSInteger totalCount = sqlite3_total_changes(db);
    
    // 9.关闭数据库
    [self closeDataBase];
    
    // 10.返回是否执行成功
    return result == SQLITE_OK || result == SQLITE_DONE;
}

/// 邦定数据库语句 ? 代表 的数据
/// @param message 需要被邦定的数据
/// @param stmt 数据库管理指针
/// @param index 从第几个 ? 开始 , [0...n]
-(void)bindMessage:(nullable NSDictionary *)message stmt:(sqlite3_stmt *)stmt startIndex:(NSUInteger)index{
    
    if (message.count == 0) {
        return ;
    }
    
    // 参数：数据库管理指针 , 在 sqlStr 的第n个 ？, 数据库语句 , 语句长度(-1表示自动计算长度) ,
    for (int i = 1; i <= message.allKeys.count; i++) {
        NSString * key = [message.allKeys objectAtIndex:i-1];
        id value = message[key];
        
        BOOL result = false;
        if ([value isKindOfClass:[NSData class]]) {
            value = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding] ;
        } else if ([value isKindOfClass:[NSDate class]]) {
            value = [value description];
        }
        result = sqlite3_bind_text(stmt, index + i, [NSString stringWithFormat:@"%@",value].UTF8String, -1, NULL) == SQLITE_OK;

//        NSLog(result ?  @"邦定数据成功":@"邦定数据失败");
    }
}

/// 向数据库表中添加 key
/// @param keyName key name , 不能为 ID , 因为已经设置成了主键
/// @param table 数据库表
- (BOOL)addKeyWithName:(nullable NSString *)keyName toTable:(QJDataBaseTable *)table{
    
    NSString * sqlStr = [NSString stringWithFormat:@"alter table %@ add column %@ text",table.name , keyName ] ;
    
    BOOL result = [self execSQLString:sqlStr] ;
    if (result) {
        [table.keys addObject:keyName];
    }
    
    return result ;
}


/// 插入数据
/// @param message 数据的 key value
/// @param table 表
-(BOOL)insertMassage:(nonnull NSDictionary *)message toTable:(QJDataBaseTable *)table
{
    if (message.count == 0) {
        return false ;
    }
    return [self insertMassages:@[message] toTable:table];
}


/// 插入n个模型数据
/// @param messages 模型字典 数组
/// @param table 表
-(BOOL)insertMassages:(NSArray<NSDictionary *> *)messages toTable:(QJDataBaseTable *)table {
    
    if (messages.count == 0) {
        return false ;
    }
    
    // 1.打开数据库
    [self openDataBase];
    
    // 2.插入语句 insert into tableName(stu_name,stu_gender,stu_age,stu_number)values(?,?,?,?)
    NSDictionary * message = messages.firstObject ;
    NSMutableString * keys = [NSMutableString string];
    NSMutableString * values = [NSMutableString string];
    for (int i = 0; i < message.allKeys.count; i++) {
        NSString * key = [message.allKeys objectAtIndex:i];
        if (i < message.allKeys.count - 1) {
            [keys appendFormat:@"%@,",key];
            [values appendFormat:@"?,"];
            
        } else {
            [keys appendFormat:@"%@",key];
            [values appendFormat:@"?"];
        }
    }
    NSMutableString * sqlStr = [NSMutableString stringWithFormat:@"insert into %@(%@)values(%@)",table.name,keys,values];

    // 执行
    return [self stepSQLString:sqlStr bindMessageBlock:^(sqlite3_stmt *stmt) {
        
        // 1. begin transaction , 2. commit transaction
        
        // (1) 开启事务 开启通道， stmt 在执行任务时不会关闭； 在插入很多数据时 更高效率
        sqlite3_exec(db, [@"begin transaction" UTF8String], NULL, NULL, NULL) ;
        
        // 插入n组数据更高效
        for (NSDictionary * message in messages) {
            // 邦定数据
            [self bindMessage:message stmt:stmt startIndex:0];
            
            // 最后一组邦定的数据 交由方法内容执行操作
            if (message != messages.lastObject) {
                // 因为 stepSQLString: bindMessageBlock: resultBlock: 方法内部最后会执行一次操作，所以最后一个不需要执行由内部来实现一次数据插入
                
                // stmt 执行了sqlite3_step 如果没有添加事务，stmt 就会关闭通道 ，所以在添加事务后，每次插入数据就无阻隔
                sqlite3_step(stmt);
                // 重新设置 stmt 后，使 stmt 可以继续有效使用
                sqlite3_reset(stmt);
            }
        }
        
        // (2) 提交事务：把所有的操作添加到数据库中
        // 注意：如果在事务还没有提交前，想把当前的所有操作都回退，使用事务回退 rollback transaction
        sqlite3_exec(db, [@"commit transaction" UTF8String], NULL, NULL, NULL) ;
        
    } resultBlock:nil];
}

// 删除表中的数据
-(BOOL)deleteFromTable:(QJDataBaseTable *)table where:(nullable NSDictionary *)where
{
    [self openDataBase];
    
    NSMutableString * sqlStr = [NSMutableString stringWithFormat:@"delete from %@ ",table.name];
    if (where.count) {
        NSMutableString * keys = [NSMutableString string];
        for (int i = 0; i < where.allKeys.count; i++) {
            NSString * key = [where.allKeys objectAtIndex:i];
            if (i < where.allKeys.count - 1) {
                [keys appendFormat:@" %@ = ? ,",key];
            } else {
                [keys appendFormat:@" %@ = ? ",key];
            }
        }
        [sqlStr appendFormat:@" where %@",keys];
    }
    
    return [self stepSQLString:sqlStr bindMessageBlock:^(sqlite3_stmt *stmt) {
        [self bindMessage:where stmt:stmt startIndex:0];
    } resultBlock:nil];
}


/// 更新数据
/// @param message 数据的 key value
/// @param table 表
/// @param where 条件 数据 key value
-(BOOL)updateMessage:(NSDictionary *)message toTable:(QJDataBaseTable *)table where:(nullable NSDictionary *)where
{
    NSMutableString * keys = [NSMutableString string];
    for (int i = 0; i < message.allKeys.count; i++) {
        NSString * key = [message.allKeys objectAtIndex:i];
        if (i < message.allKeys.count - 1) {
            [keys appendFormat:@" %@ = ? ,",key];
            
        } else {
            [keys appendFormat:@" %@ = ? ",key];
        }
    }
    // @"update StudentList set stu_gender = ? where stu_number = ?";
    NSMutableString * sqlStr = [NSMutableString stringWithFormat:@"update %@ set %@ ",table.name,keys];
    if (where.count) {
        NSMutableString * keys = [NSMutableString string];
        for (int i = 0; i < where.allKeys.count; i++) {
            NSString * key = [where.allKeys objectAtIndex:i];
            if (i < where.allKeys.count - 1) {
                [keys appendFormat:@" %@ = ? ,",key];
            } else {
                [keys appendFormat:@" %@ = ? ",key];
            }
        }
        [sqlStr appendFormat:@"where %@ ",keys];
    }
    
    return [self stepSQLString:sqlStr bindMessageBlock:^(sqlite3_stmt *stmt) {
        [self bindMessage:message stmt:stmt startIndex:0];
        [self bindMessage:where stmt:stmt startIndex:message.allKeys.count];
    } resultBlock:nil];
}



/// 查询数据
/// @param sqlStr 数据库语句
- (NSArray<NSDictionary *> *)selectWithSQLString:(NSString *)sqlStr {
    
    __block NSArray * resultArr = nil;

    [self stepSQLString:sqlStr bindMessageBlock:nil resultBlock:^(NSArray<NSDictionary *> *result) {
        resultArr = result ;
    }];
    
    return resultArr ;
}

/// 查询数据
/// @param table 表
/// @param where key value 条件
/// @param limitStartIndex 起始个数
/// @param count 长度
/// @param otherWhere 其他条件
-(NSArray<NSDictionary *> *)selectFromTable:(QJDataBaseTable *)table where:(nullable NSDictionary *)where limitStartIndex:(NSUInteger)limitStartIndex count:(NSUInteger)count otherWhere:(nullable NSString *)otherWhere
{
    // 多条件查询如：@"select * from StudentList where stu_number = ? and stu_name = ?"
    // @"select * from StudentList where stu_number = ? or stu_name"
    // @"select * from StudentList where stu_number > ?"
    // @"select * from StudentList where stu_number > ? limit 5" 满足条件的5条数据
    // @"select * from StudentList where stu_number > ? limit 3,5" 跳过前三条数据 接着取后5条
    // @"select * from StudentList where stu_number > ?  order by stu_age disc " 在数据库中的数据满足条件 stu_number > ?(帮定的值) 选出的个数，然后以 stu_age 列把数据降序排列
    // @"select stu_name,stu_age from StudentList where ...... " 选出满足条件数据条的 stu_name 和 stu_age 值
    // 2.准备语句
    NSMutableString * sqlStr = [NSMutableString stringWithFormat:@"select * from %@ ",table.name];
    if (where.count) {
        NSMutableString * keys = [NSMutableString string];
        for (int i = 0; i < where.allKeys.count; i++) {
            NSString * key = [where.allKeys objectAtIndex:i];
            if (i < where.allKeys.count - 1) {
                [keys appendFormat:@" %@ = ? and ",key];
            } else {
                [keys appendFormat:@" %@ = ? ",key];
            }
        }
        [sqlStr appendFormat:@" where %@ ",keys];
    }
    
    if (otherWhere != nil) {
        if (where.count == 0) {
            [sqlStr appendString:[NSString stringWithFormat:@" where %@ ",otherWhere]];
        }else {
            [sqlStr appendString:otherWhere];
        }
    }
    
    [sqlStr appendFormat:@" limit %ld,%ld ",limitStartIndex , count];
    
    __block NSArray * mArr = nil;
    [self stepSQLString:sqlStr bindMessageBlock:^(sqlite3_stmt *stmt) {
        // 邦定数据
        [self bindMessage:where stmt:stmt startIndex:0];
        
    } resultBlock:^(NSArray<NSDictionary *> *result) {
        mArr = result ;
    }];
    
    return mArr ;
}

/// 模糊查询
/// @param table 表
/// @param likeDic key value 模糊条件
-(NSArray<NSDictionary *> *)selectFromTable:(QJDataBaseTable *)table whereLike:(nullable NSDictionary<NSString * , NSString *> *)likeDic otherSqlStr:(nullable NSString *)otherSqlStr
{
    NSMutableString * sqlStr = [NSMutableString stringWithFormat:@"select * from %@ ",table.name];
    if (likeDic.count) {
        [sqlStr appendString:@" where "];
        for (NSString * key in likeDic.allKeys) {
            if ([key isEqualToString:likeDic.allKeys.lastObject]) {
                [sqlStr appendFormat:@" %@ like '%%%@%%' ",key , likeDic[key]];
            } else {
                [sqlStr appendFormat:@" %@ like '%%%@%%' ,",key , likeDic[key]];
            }
        }
    }
    if (otherSqlStr.length) {
        [sqlStr appendString:otherSqlStr];
    }
    
    __block NSArray * mArr = nil;
    [self stepSQLString:sqlStr bindMessageBlock:nil resultBlock:^(NSArray<NSDictionary *> *result) {
        mArr = result ;
    }];
    
    return mArr ;
}

/// 中断一个长时间执行的查询语句
-(void)sqliteInterrupt
{
    [self openDataBase];
    
    sqlite3_interrupt(db);
    
    [self closeDataBase];
}


-(NSMutableArray *)tables {
    if (!_tables) {
        _tables = [NSMutableArray array];
    }
    return _tables ;
}

@end
