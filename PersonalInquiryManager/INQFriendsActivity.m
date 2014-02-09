//
//  INQFriendsActivity.m
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 8/7/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "INQFriendsActivity.h"

@interface INQFriendsActivity ()

@end

@implementation INQFriendsActivity

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [self setupFetchedResultsController];
}

- (void) viewDidAppear:(BOOL)animated {
    ARLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    [INQCloudSynchronizer syncUsers:appDelegate.managedObjectContext];
}

- (void)setupFetchedResultsController {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Account"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                                     ascending:YES
                                                                                      selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    NSNumber* accountType = [[NSUserDefaults standardUserDefaults] objectForKey:@"accountType"];
    request.predicate = [NSPredicate predicateWithFormat:
                         @"accountType != %d or localId != %@",
                         [accountType intValue],
                         [[NSUserDefaults standardUserDefaults] objectForKey:@"accountLocalId"]];
    
    ARLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:appDelegate.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    Account * generalItem = ((Account*)[self.fetchedResultsController objectAtIndexPath:indexPath]);
    INQFriendsTableViewItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendsCell"];
    if (cell == nil) {
        cell = [[INQFriendsTableViewItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"friendsCell"];
    }
    cell.name.text = generalItem.name;
    cell.name.font = [UIFont boldSystemFontOfSize:16.0f];
    //    for (Action * action in generalItem.actions) {
    //        if (action.run == self.run) {
    //            if ([action.action isEqualToString:@"read"]) {
    //                cell.giTitleLabel.font = [UIFont systemFontOfSize:16.0f];
    //            }
    //        }
    //    }
    //    //    cell.detailTextLabel.text = [NSString stringWithFormat:@"vis statements %d", [generalItem.visibility count] ];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    INQFriendsTableViewItemCell *cell = (INQFriendsTableViewItemCell*) [tableView cellForRowAtIndexPath:indexPath];
    cell.name.font = [UIFont systemFontOfSize:16.0f];
}

-(void) configureCell: (INQFriendsTableViewItemCell *) cell atIndexPath:(NSIndexPath *)indexPath {
    Account * account = ((Account*)[self.fetchedResultsController objectAtIndexPath:indexPath]);
    
    cell.name.text = account.name;
        //cell.detailTextLabel.text = [NSString stringWithFormat:@"vis statements %d", [generalItem.visibility count] ];
        NSData* icon = [account picture];
        if (icon) {
            UIImage *image = [UIImage imageWithData:icon];
            cell.icon.image = image;
        }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    Account *generalItem = ((Account*)[self.fetchedResultsController objectAtIndexPath:indexPath]);
   
    if (generalItem){
        //veg Silence unused variable warning!
    }
    
    //    if ([segue.destinationViewController respondsToSelector:@selector(setGeneralItem:)]) {
    //        [segue.destinationViewController performSelector:@selector(setGeneralItem:) withObject:generalItem];
    //    }
    //    if ([segue.destinationViewController respondsToSelector:@selector(setRun:)]) {
    //        [segue.destinationViewController performSelector:@selector(setRun:) withObject:self.run];
    //    }
}

@end
