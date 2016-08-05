//
//  NSManagedObject+helper.m
//  agent
//
//  Created by LiMing on 14-6-24.
//  Copyright (c) 2014年 bangban. All rights reserved.
//

#import "NSManagedObject+helper.h"

@implementation NSManagedObject (helper)
+ (id)createNew:(NSManagedObjectContext *)ctx {
    NSString *className = [NSString stringWithUTF8String:object_getClassName(self)];
    return [NSEntityDescription insertNewObjectForEntityForName:className inManagedObjectContext:ctx];
}

+ (void)save{
    NSError *error = nil;
    if ([[CoreDataFundation instance].mainObjectContext hasChanges]) {
        [[CoreDataFundation instance].mainObjectContext save:&error];
    }
}

+ (NSArray *)ctx:(NSManagedObjectContext *)ctx
          filter:(NSString *)predicate
         orderby:(NSArray *)orders
          offset:(int)offset
           limit:(int)limit {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSString *className = [NSString stringWithUTF8String:object_getClassName(self)];
    fetchRequest.entity = [NSEntityDescription entityForName:className inManagedObjectContext:ctx];
    
    if (predicate) {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:predicate];
    }
    
    NSMutableArray *orderArray = [[NSMutableArray alloc] init];
    for (NSString *order in orders) {
        NSSortDescriptor *orderDesc = nil;
        if ([[order substringToIndex:1] isEqualToString:@"-"]) {
            orderDesc = [[NSSortDescriptor alloc] initWithKey:[order substringFromIndex:1]
                                                    ascending:NO];
        }else{
            orderDesc = [[NSSortDescriptor alloc] initWithKey:order
                                                    ascending:YES];
        }
        [orderArray addObject:orderDesc];
    }
    [fetchRequest setSortDescriptors:orderArray];

    if (offset>0) {
        [fetchRequest setFetchOffset:offset];
    }
    if (limit>0) {
        [fetchRequest setFetchLimit:limit];
    }

    NSError* error = nil;
    NSArray* results = [ctx executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"error: %@", error);
        return @[];
    }
    return results;
}

+ (NSArray *)ctx:(NSManagedObjectContext *)ctx predicate:(NSFetchRequest *)fetch {
    NSError *error;
    NSArray *results = [ctx executeFetchRequest:fetch error:&error];
    if (error) {
        NSLog(@"error: %@", error);
        return @[];
    }
    return results;
}

+ (void)ctx:(NSManagedObjectContext *)ctx delobject:(id)object handler:(OperationResult)handler {
    [ctx deleteObject:object];
    [self save];
}

#pragma mark - 增
+ (void)add:(NSDictionary *)para handler:(OperationResult)handler {
    dispatch_async([CoreDataFundation instance].t, ^{
        id entity = [self createNew:[CoreDataFundation instance].mainObjectContext];
        for (NSString *key in para.allKeys) {
            [entity setValue:para[key] forKey:key];
        }
        
        [self save];
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(nil);
        });
    });
}

#pragma mark - 查
+ (void)getByFetch:(NSFetchRequest *)fetch results:(ListResult)results {
    dispatch_async([CoreDataFundation instance].t, ^{
        __block NSArray *listArray = [self ctx:[CoreDataFundation instance].mainObjectContext predicate:fetch];
        dispatch_async(dispatch_get_main_queue(), ^{
            results(listArray);
        });
    });
}

+ (void)getByFilter:(NSString *)predicate
            orderby:(NSArray *)orders
             offset:(int)offset
              limit:(int)limit
            results:(ListResult)results {
    dispatch_async([CoreDataFundation instance].t, ^{
        __block NSArray *listArray = [self ctx:[CoreDataFundation instance].mainObjectContext
                                        filter:predicate
                                       orderby:orders
                                        offset:offset
                                         limit:limit];
        dispatch_async(dispatch_get_main_queue(), ^{
            results(listArray);
        });
    });
}

#pragma mark - 删
+ (void)delete:(NSArray *)objs handler:(OperationResult)handler {
    dispatch_async([CoreDataFundation instance].t, ^{
        for (NSManagedObject *obj in objs) {
            [self ctx:[CoreDataFundation instance].mainObjectContext delobject:obj handler:nil];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(nil);
        });
    });
}

+ (void)deleteByFilter:(NSString *)predicate
               orderby:(NSArray *)orders
                offset:(int)offset
                 limit:(int)limit
               handler:(OperationResult)handler {
    [self getByFilter:predicate orderby:orders offset:offset limit:limit results:^(NSArray *results) {
        [self delete:results handler:handler];
    }];
}

+ (void)deleteByFetch:(NSFetchRequest *)request
              handler:(OperationResult)handler {
    [self getByFetch:request results:^(NSArray *results) {
        [self delete:results handler:handler];
    }];
}

@end
