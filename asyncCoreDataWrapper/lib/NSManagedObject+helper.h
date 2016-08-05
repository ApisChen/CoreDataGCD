//
//  NSManagedObject+helper.h
//  agent
//
//  Created by LiMing on 14-6-24.
//  Copyright (c) 2014年 bangban. All rights reserved.
//

typedef void (^ListResult)(NSArray* results);

#import <CoreData/CoreData.h>
#import "CoreDataFundation.h"


@interface NSManagedObject (helper)

#pragma mark - 增
+ (void)add:(NSDictionary *)para handler:(OperationResult)handler;

#pragma mark - 查
+ (void)getByFetch:(NSFetchRequest *)fetch results:(ListResult)results;

+ (void)getByFilter:(NSString *)predicate
            orderby:(NSArray *)orders
             offset:(int)offset
              limit:(int)limit
            results:(ListResult)results;

#pragma mark - 删
+ (void)delete:(NSArray *)objs handler:(OperationResult)handler;

+ (void)deleteByFilter:(NSString *)predicate
               orderby:(NSArray *)orders
                offset:(int)offset
                 limit:(int)limit
               handler:(OperationResult)handler;

+ (void)deleteByFetch:(NSFetchRequest *)request
              handler:(OperationResult)handler;


@end
