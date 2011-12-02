//
//  AAMFeedbackViewController.m
//  AAMFeedbackViewController
//
//  Created by 深津 貴之 on 11/11/30.
//  Copyright (c) 2011年 Art & Mobile. All rights reserved.
//

#import "AAMFeedbackViewController.h"
#import "AAMFeedbackTopicsViewController.h"
#include <sys/types.h>
#include <sys/sysctl.h>

@interface AAMFeedbackViewController(private)
    - (NSString *) _platform;
    - (NSString *) _platformString;
    - (NSString*)_feedbackSubject;
    - (NSString*)_feedbackBody;
    - (NSString*)_appName;
    - (NSString*)_appVersion;
    - (NSString*)_selectedTopic;
    - (NSString*)_selectedTopicToSend;
    - (void)_updatePlaceholder;
@end


@implementation AAMFeedbackViewController

@synthesize descriptionText;
@synthesize topics;
@synthesize topicsToSend;
@synthesize toRecipients;
@synthesize ccRecipients;
@synthesize bccRecipients;


+ (BOOL)isAvailable
{
    if([MFMailComposeViewController class]){
        return YES;
    }
    return NO;
}

-(id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if(self){
        self.topics = [[[NSArray alloc]initWithObjects:
                       @"AAMFeedbackTopicsQuestion",
                       @"AAMFeedbackTopicsRequest",
                       @"AAMFeedbackTopicsBugReport",
                       @"AAMFeedbackTopicsMedia",
                       @"AAMFeedbackTopicsBusiness",
                       @"AAMFeedbackTopicsOther", nil]autorelease];
        
        self.topicsToSend = [[[NSArray alloc]initWithObjects:
                             @"Question",
                             @"Request",
                             @"Bug Report",
                             @"Media",
                             @"Business",
                             @"Other", nil]autorelease];
    }
    return self;
}

- (id)initWithTopics:(NSArray*)theIssues
{
    self = [self init];
    if(self){
        self.topics = theIssues;
        self.topicsToSend = theIssues;
    }
    return self;
}

- (void)dealloc {
    self.descriptionText = nil;
    self.topics = nil;
    self.topicsToSend = nil;
    self.toRecipients = nil;
    self.ccRecipients = nil;
    self.bccRecipients = nil;
    [super dealloc];
}


#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    self.title = NSLocalizedString(@"AAMFeedbackTitle", nil);
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelDidPress:)]autorelease];
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"AAMFeedbackButtonMail", nil) style:UIBarButtonItemStyleDone target:self action:@selector(nextDidPress:)]autorelease];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _descriptionPlaceHolder = nil;
    _descriptionTextView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self _updatePlaceholder];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(_isFeedbackSent){
        [self dismissModalViewControllerAnimated:YES];
    }
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
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0){
        return 2;
    }
    return 4;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0 && indexPath.row==1){
        return MAX(88, _descriptionTextView.contentSize.height);
    }
    
    return 44;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return NSLocalizedString(@"AAMFeedbackTableHeaderTopics", nil);
            break;
        case 1:
            return NSLocalizedString(@"AAMFeedbackTableHeaderBasicInfo", nil);
            break;
        default:
            break;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        if(indexPath.section==1){
            //General Infos
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        }else{
            if(indexPath.row==0){
                //Topics
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1      reuseIdentifier:CellIdentifier] autorelease];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }else{
                //Topics Description
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault      reuseIdentifier:CellIdentifier] autorelease];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                _descriptionTextView = [[[UITextView alloc]initWithFrame:CGRectMake(10, 0, 300, 88)]autorelease];
                _descriptionTextView.backgroundColor = [UIColor clearColor];
                _descriptionTextView.font = [UIFont systemFontOfSize:16];
                _descriptionTextView.delegate = self;
                _descriptionTextView.scrollEnabled = NO;
                _descriptionTextView.text = self.descriptionText;
                [cell addSubview:_descriptionTextView];
                
                _descriptionPlaceHolder = [[[UITextField alloc]initWithFrame:CGRectMake(16, 8, 300, 20)]autorelease];
                _descriptionPlaceHolder.font = [UIFont systemFontOfSize:16];
                _descriptionPlaceHolder.placeholder = NSLocalizedString(@"AAMFeedbackDescriptionPlaceholder", nil);
                _descriptionPlaceHolder.userInteractionEnabled = NO;
                [cell addSubview:_descriptionPlaceHolder];
                
                [self _updatePlaceholder];
            }
        }
    }
    
    // Configure the cell...
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    
                    cell.textLabel.text = NSLocalizedString(@"AAMFeedbackTopicsTitle", nil);
                    cell.detailTextLabel.text = NSLocalizedString([self _selectedTopic],nil);
                    break;
                case 1:
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Device";
                    cell.detailTextLabel.text = [self _platformString];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                case 1:
                    cell.textLabel.text = @"iOS";
                    cell.detailTextLabel.text = [UIDevice currentDevice].systemVersion;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                case 2:
                    cell.textLabel.text = @"App Name";
                    cell.detailTextLabel.text = [self _appName];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                case 3:
                    cell.textLabel.text = @"App Version";
                    cell.detailTextLabel.text = [self _appVersion];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0 && indexPath.row==0){
        [_descriptionTextView resignFirstResponder];
        
        AAMFeedbackTopicsViewController *vc = [[[AAMFeedbackTopicsViewController alloc]initWithStyle:UITableViewStyleGrouped]autorelease];
        vc.delegate = self;
        vc.selectedIndex = _selectedTopicsIndex;
        [self.navigationController pushViewController:vc animated:YES];
    }
}


- (void)cancelDidPress:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)nextDidPress:(id)sender
{
    [_descriptionTextView resignFirstResponder];
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    [picker setToRecipients:self.toRecipients];
    [picker setCcRecipients:self.ccRecipients];  
    [picker setBccRecipients:self.bccRecipients];
    
    [picker setSubject:[self _feedbackSubject]];
    [picker setMessageBody:[self _feedbackBody] isHTML:NO];
    [self presentModalViewController:picker animated:YES];
    [picker release];
}


- (void)textViewDidChange:(UITextView *)textView
{
    CGRect f = _descriptionTextView.frame;
    f.size.height = _descriptionTextView.contentSize.height;
    _descriptionTextView.frame = f;
    [self _updatePlaceholder];
    self.descriptionText = _descriptionTextView.text;
    
    //Magic for updating Cell height
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}


-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if(result==MFMailComposeResultCancelled){
    }else if(result==MFMailComposeResultSent){
        _isFeedbackSent = YES;
    }else if(result==MFMailComposeResultFailed){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil 
                                                        message:@"AAMFeedbackMailDidFinishWithError"
                                                       delegate:nil 
                                              cancelButtonTitle:nil 
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        [alert release];
    }
    [controller dismissModalViewControllerAnimated:YES]; 
}


- (void)feedbackTopicsViewController:(AAMFeedbackTopicsViewController *)feedbackTopicsViewController didSelectTopicAtIndex:(NSInteger)selectedIndex {
    _selectedTopicsIndex = selectedIndex;
}

#pragma mark - Internal Info

- (void)_updatePlaceholder
{
    if([_descriptionTextView.text length]>0){
        _descriptionPlaceHolder.hidden = YES;
    }else{
        _descriptionPlaceHolder.hidden = NO;
    }
}

- (NSString*)_feedbackSubject
{
    return [NSString stringWithFormat:@"%@: %@", [self _appName],[self _selectedTopicToSend], nil];
}
   
- (NSString*)_feedbackBody
{
    NSString *body = [NSString stringWithFormat:@"%@\n\n\nDevice:\n%@\n\niOS:\n%@\n\nApp:\n%@ %@",
                      _descriptionTextView.text,
                      [self _platformString],
                      [UIDevice currentDevice].systemVersion, 
                      [self _appName],
                      [self _appVersion], nil];

    return body;
}

- (NSString*)_selectedTopic
{
    return [topics objectAtIndex:_selectedTopicsIndex];
}

- (NSString*)_selectedTopicToSend
{
    return [topicsToSend objectAtIndex:_selectedTopicsIndex];
}

- (NSString*)_appName
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:
            @"CFBundleDisplayName"];
}

- (NSString*)_appVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

// Codes are from 
// http://stackoverflow.com/questions/448162/determine-device-iphone-ipod-touch-with-iphone-sdk
// Thanks for sss and UIBuilder
- (NSString *) _platform
{
    int mib[2];
    size_t len;
    char *machine;
    
    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    return platform;
}

- (NSString *) _platformString
{
    NSString *platform = [self _platform];
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"i386"])   return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])   return @"iPhone Simulator";
    return platform;
}

@end
