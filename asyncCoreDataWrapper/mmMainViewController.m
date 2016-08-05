//
//  mmMainViewController.m
//  asyncCoreDataWrapper
//
//  Created by LiMing on 14-6-26.
//  Copyright (c) 2014年 liming. All rights reserved.
//

#import "mmMainViewController.h"
#import "Entity.h"

static BOOL actionLock = NO;
static BOOL notHidden = YES;

@interface mmMainViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSArray *dataArray;
@property (weak, nonatomic) IBOutlet UITableView *mainTable;


@end

@implementation mmMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fetchEntitys];
    
    for (NSInteger i=0; i<20; i++) {
        NSDictionary *para = @{
                               @"task_id":  @(i*100),
                               @"title":    @"呵呵",
                               @"detail":   @"哈哈",
                               @"done":     @(NO),
                               };
        
        [Entity add:para handler:^(NSError *error) {
            if (i==19) {
                [self fetchEntitys];
            }
        }];
    }
}

-(void)fetchEntitys{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Entity"];
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"task_id" ascending:YES]]];
    [Entity getByFetch:request results:^(NSArray *results) {
        _dataArray = results;
        [_mainTable reloadData];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = [@(indexPath.row+1).stringValue stringByAppendingString:((Entity*)_dataArray[indexPath.row]).title];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    Entity *task = _dataArray[indexPath.row];
    [Entity delete:@[task] handler:^(NSError *error) {
        [self fetchEntitys];
    }];

}

- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView setEditing:YES animated:YES];
}

- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView setEditing:NO animated:YES];

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"showDetail" sender:[_dataArray objectAtIndex:indexPath.row]];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showDetail"]) {
        id tarVC = segue.destinationViewController;
        [tarVC setValue:sender forKeyPath:@"entity"];
    }

}


@end
