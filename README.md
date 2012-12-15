AAMFeedback
===========

Library that you can add User feedback form in you app on the fly. :-)


//Code is pretty simple.

AAMFeedbackViewController *vc = [[[AAMFeedbackViewController alloc]init]autorelease];
vc.toRecipients = [NSArray arrayWithObject:@"YOUR_CONTACT@email.com"];
vc.ccRecipients = nil;
vc.bccRecipients = nil;
UINavigationController *nvc = [[[UINavigationController alloc]initWithRootViewController:vc]autorelease];
[self presentModalViewController:nvc animated:YES];
