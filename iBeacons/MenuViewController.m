//
//  MenuViewController.m
//  iBeacons
//
//  Created by Apple on 14-3-5.
//  Copyright (c) 2014年 meng.wang. All rights reserved.
//

#import "MenuViewController.h"
#import "DetailViewController.h"
#import "XHPathCover.h"
@interface MenuViewController ()
@property NSMutableArray *allLoctionInTableView;
@property NSInteger n;
@property (nonatomic, strong) XHPathCover* pathCover;
@end

@implementation MenuViewController
@synthesize subUrlString;
@synthesize allLoctionInTableView;
@synthesize n;
@synthesize index;
@synthesize titleChoose;
@synthesize floorPlanId;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSData *allLocationData=[[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:subUrlString]];
    

    NSError *error;
    NSMutableDictionary *allLocation = [NSJSONSerialization
                                       JSONObjectWithData:allLocationData
                                       options:kNilOptions
                                       error:&error];
    if( error )
    {
        NSLog(@"%@", [error localizedDescription]);
    }
    else {
        NSArray *locations = allLocation[@"locations"];

        NSDictionary *location;
        for ( location in locations )
        {

            n++;
        }

    }

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //new features
    _pathCover = [[XHPathCover alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 210)];
    [_pathCover setBackgroundImage:[UIImage imageNamed:@"shopping_cart.jpg"]];
    [_pathCover setAvatarImage:[UIImage imageNamed:@"ibeacon-icon.png"]];
    self.tableView.tableHeaderView = self.pathCover;
    
    __weak MenuViewController *wself = self;
    [_pathCover setHandleRefreshEvent:^{
        [wself _refreshing];
    }];

}

- (void)_refreshing {
    // refresh your data sources
    
    __weak MenuViewController*wself = self;
    double delayInSeconds = 4.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [wself.pathCover stopRefresh];
    });
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_pathCover scrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [_pathCover scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_pathCover scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_pathCover scrollViewWillBeginDragging:scrollView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSLog(@"---%ld",(long)n);
    return n;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier ];
    
    // Configure the cell...
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier] ;
    }
    NSData *allLocationData=[[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:subUrlString]];
    
    
    NSError *error;
    NSMutableDictionary *allLocation = [NSJSONSerialization
                                        JSONObjectWithData:allLocationData
                                        options:kNilOptions
                                        error:&error];
    if( error )
    {
        NSLog(@"%@", [error localizedDescription]);
    }
    else {
        NSArray *locations = allLocation[@"locations"];
        
        NSDictionary *location;
        location=[locations objectAtIndex:indexPath.row];
        cell.textLabel.text=[location objectForKey:@"id"];
        cell.detailTextLabel.text=[location objectForKey:@"type"];
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"Detail" sender:self];
    index=indexPath.row;
        //    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"Detail"]) {
        
        NSData *allLocationData=[[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:subUrlString]];
        
        
        NSError *error;
        NSMutableDictionary *allLocation = [NSJSONSerialization
                                            JSONObjectWithData:allLocationData
                                            options:kNilOptions
                                            error:&error];
        if( error )
        {
            NSLog(@"%@", [error localizedDescription]);
        }
        else {
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            NSArray *locations = allLocation[@"locations"];
            
            self.titleChoose=[[locations objectAtIndex:indexPath.row]valueForKey:@"id"];
            NSLog(@"index:%@",titleChoose);
            
        }
        DetailViewController *detail=segue.destinationViewController;
        detail.roomName=titleChoose;
        detail.uploadFloorPlanId=floorPlanId;
        detail.count=n;
    }
}



@end
