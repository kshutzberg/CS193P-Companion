//
//  TimePickerTableViewController.m
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/9/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "TimePickerTableViewController.h"

@implementation TimePickerTableViewController

- (NSArray *)times { return self.objects; }
- (void)setTimes:(NSArray *)times { self.objects = times; }

#pragma mark - View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Configure Defaults
    self.mode = PickerModeSingleSelection;
    self.name = @"Choose a Time Interval";
    self.title = @"Question Time Interval";
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    NSDate *timeDate = [self objectAtIndexPath:indexPath];
    NSTimeInterval time = [timeDate timeIntervalSinceReferenceDate];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    if (time < 60)
        [dateFormatter setDateFormat:@"s 'seconds'"];
    else if (time == 60)
        [dateFormatter setDateFormat:@"m 'minute'"];
    else if ((int)time % 60 == 0)
        [dateFormatter setDateFormat:@"m 'minutes'"];
    else if (time >=60 && time < 120)
        [dateFormatter setDateFormat:@"m 'minute' s 'seconds'"];
    else
        [dateFormatter setDateFormat:@"m 'minutes' s 'seconds'"];
    
    cell.textLabel.text = [dateFormatter stringFromDate:timeDate];

    return cell;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

@end
