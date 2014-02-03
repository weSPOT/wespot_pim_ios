//
//  INQGeneralItemTableViewController.m
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 8/8/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "INQGeneralItemTableViewController.h"

@interface INQGeneralItemTableViewController ()

@end

@implementation INQGeneralItemTableViewController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    GeneralItem * generalItem = ((CurrentItemVisibility*)[self.fetchedResultsController objectAtIndexPath:indexPath]).item;
    ARLGeneralItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:generalItem.type];
    if (cell == nil) {
        cell = [[ARLGeneralItemTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:generalItem.type];
    }
    cell.giTitleLabel.text = generalItem.name;
    cell.giTitleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    [self setDCIcon:cell withGi:generalItem];

    for (Action * action in generalItem.actions) {
        if (action.run == self.run) {
            if ([action.action isEqualToString:@"read"]) {
                cell.giTitleLabel.font = [UIFont systemFontOfSize:16.0f];
            }
        }
    }
    //    cell.detailTextLabel.text = [NSString stringWithFormat:@"vis statements %d", [generalItem.visibility count] ];
    
    return cell;
}

-(void) configureCell: (ARLGeneralItemTableViewCell *) cell atIndexPath:(NSIndexPath *)indexPath {
    GeneralItem * generalItem = ((CurrentItemVisibility*)[self.fetchedResultsController objectAtIndexPath:indexPath]).item;
    
    cell.giTitleLabel.text = generalItem.name;
    //    cell.detailTextLabel.text = [NSString stringWithFormat:@"vis statements %d", [generalItem.visibility count] ];
        cell.icon.image = [UIImage imageNamed:@"dc_calculator_128.png"];
}

- (void) setDCIcon: (ARLGeneralItemTableViewCell *) cell withGi: (GeneralItem *) generalItem {
        NSDictionary * jsonDict = [NSKeyedUnarchiver unarchiveObjectWithData:generalItem.json];
    
    NSLog(@"[%s] log %@", __func__, [jsonDict objectForKey:@"openQuestion"]);
    
    if ([[[jsonDict objectForKey:@"openQuestion"] objectForKey:@"withAudio"] intValue] == 1) {
            cell.icon.image = [UIImage imageNamed:@"dc_voice_search_128.png"];
    }
    if ([[[jsonDict objectForKey:@"openQuestion"] objectForKey:@"withPicture"] intValue] == 1) {
        cell.icon.image = [UIImage imageNamed:@"dc_camera_128.png"];
    }
    if ([[[jsonDict objectForKey:@"openQuestion"] objectForKey:@"withText"]intValue] == 1) {
        cell.icon.image = [UIImage imageNamed:@"dc_note_128.png"];
    }
    if ([[[jsonDict objectForKey:@"openQuestion"] objectForKey:@"withValue"]intValue] == 1) {
        cell.icon.image = [UIImage imageNamed:@"dc_calculator_128.png"];
    }
    if ([[[jsonDict objectForKey:@"openQuestion"] objectForKey:@"withVideo"]intValue] == 1) {
        cell.icon.image = [UIImage imageNamed:@"dc_video_128.png"];
    }
}

@end
