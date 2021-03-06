//
//  ViewController.m
//  DataBaseDome
//
//  Created by 瞿杰 on 2017/6/19.
//  Copyright © 2017年 yiniu. All rights reserved.
//

#import "ViewController.h"

#import "DataBaseHandle.h"
#import "StudentEntity.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"%@",[DataBaseHandle dataBasePath]);
    
    DataBaseHandle * dataBaseHandle = [DataBaseHandle dataBaseHandle];
    
    // 添加表
    NSArray * keys = @[@"number" , @"name" , @"gender" , @"age" , @"data"];
    [dataBaseHandle addTableWithName:@"Student1" keys:keys] ;
    
    // 查询所有缓存的数据
    NSArray * allStudents = [dataBaseHandle selectAllKeyValues];
    
    
    // 1.插入数据
    StudentEntity * entity = [[StudentEntity alloc] init];
    entity.number = 1000 ;
    entity.name = @"张三";
    entity.gender = @"男";
    entity.age = 20 ;
    entity.data = [@"张三Data" dataUsingEncoding:NSUTF8StringEncoding];
    
    StudentEntity * entity2 = [[StudentEntity alloc] init];
    entity2.number = 1001 ;
    entity2.name = @"李四";
    entity2.gender = @"女";
    entity2.age = 25 ;
    entity2.data = [@"李四Data" dataUsingEncoding:NSUTF8StringEncoding];

    
    [dataBaseHandle insertDataWithKeyValues:entity count:100000];
    [dataBaseHandle insertDataWithKeyValues:entity2 count:100000];

    NSInteger count = [dataBaseHandle sqliteEffectedChangesCount];
    
    // 2.查询所有数据
    allStudents = [dataBaseHandle selectAllKeyValues];
    
    // 查询单个数据
    StudentEntity * selectStudent = [dataBaseHandle selectOneStudentByNumber:1000];
    StudentEntity * selectStudent2 = [dataBaseHandle selectOneStudentByNumber:1001];
    
    // 模糊查询
    selectStudent = [dataBaseHandle selectOneStudentLikeName:@"三"];
    
    // 3.更新数据
    [dataBaseHandle updateStudentGender:@"女" byNumber:1000];
    [dataBaseHandle updateStudentGender:@"男" byNumber:1001];
    
    // 查询所有数据
    allStudents = [dataBaseHandle selectAllKeyValues];
    
    
    NSInteger totalCount = [dataBaseHandle sqliteEffectedTolalChangesCount];
    
    [dataBaseHandle deleteOneStudentByNumber:1001];

    // 查询所有数据
    allStudents = [dataBaseHandle selectAllKeyValues];
    
    // 查询单个数据
    selectStudent = [dataBaseHandle selectOneStudentByNumber:1000];
    selectStudent2 = [dataBaseHandle selectOneStudentByNumber:1001];
    
    // 删除整张表
    [dataBaseHandle dropTable];
    
    // 查询所有数据
    allStudents = [dataBaseHandle selectAllKeyValues];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
