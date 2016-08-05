//
//  mmDAO.h
//  agent
//
//  Created by LiMing on 14-6-24.
//  Copyright (c) 2014年 bangban. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^OperationResult)(NSError* error);

@interface CoreDataFundation: NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *mainObjectContext;
@property (strong, nonatomic) dispatch_queue_t t;


+ (CoreDataFundation *)instance;
- (void)setupEnvModel:(NSString *)model dBFile:(NSString*)filename;

@end
