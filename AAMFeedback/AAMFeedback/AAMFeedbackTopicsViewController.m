//
//  AAMFeedbackTopicsViewController.m
//  AAMFeedbackViewController
//
//  Created by 深津 貴之 on 11/11/30.
//  Copyright (c) 2011年 Art & Mobile. All rights reserved.
//

#import "AAMFeedbackTopicsViewController.h"


@interface AAMFeedbackTopicsViewController(private)
    - (void)_setSelectedIndex:(int)theIndex;
    - (int)_selectedIndex;
    - (void)_updateCellselection;
    -(NSArray*)_topics;
@end


@implementation AAMFeedbackTopicsViewController

@synthesize delegate;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"AAMFeedbackTopicsTitle", nil);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self _updateCellselection];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(delegate){
        return [[self _topics]count];
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.textLabel.text = NSLocalizedString([[self _topics]objectAtIndex:indexPath.row],nil);
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self _setSelectedIndex:indexPath.row];
    [self _updateCellselection];
}

#pragma mark - Internal

- (int)_selectedIndex
{
    return [[NSUserDefaults standardUserDefaults]integerForKey:@"AAMFeedbackTopicsIndex"];
}

- (void)_setSelectedIndex:(int)theIndex;
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:theIndex forKey:@"AAMFeedbackTopicsIndex"];
    [defaults synchronize];
}

- (void)_updateCellselection
{
    NSArray *cells = [self.tableView visibleCells];
    int n = [cells count];
    for(int i=0; i<n; i++)
    {
        UITableViewCell *cell = [cells objectAtIndex:i];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:[self _selectedIndex] inSection:0];
    
    UITableViewCell *cell;
    cell = [self.tableView cellForRowAtIndexPath:path];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell.textLabel.textColor = [UIColor colorWithRed:51.0f/255.0f green:102.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
    [cell setSelected:NO animated:YES];
}

- (NSArray*)_topics
{
    if(delegate)
        return (NSArray*)[delegate performSelector:@selector(topics)];
    return nil;
}
@end
