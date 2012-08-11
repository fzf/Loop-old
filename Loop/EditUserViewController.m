//
//  SecondViewController.m
//  Loop
//
//  Created by Fletcher Fowler on 8/11/12.
//  Copyright (c) 2012 Zamboni Dev. All rights reserved.
//

#import "EditUserViewController.h"
#import <Twitter/Twitter.h>

@interface EditUserViewController ()

@end

@implementation EditUserViewController
@synthesize firstNameField = _firstNameField;
@synthesize lastNameField  = _lastNameField;
@synthesize twitterHandleLabel  = _twitterHandleLabel;

- (void)viewWillAppear:(BOOL)animated
{
    accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error)
     {
         // Did user allow us access?
         if (granted == YES)
         {
             // Populate array with all available Twitter accounts
             ACAccount *account = [[accountStore accountsWithAccountType:accountType] objectAtIndex:0];
             
             NSURL *url = [NSURL URLWithString:@"http://api.twitter.com/1/account/verify_credentials.json"];
             TWRequest *req = [[TWRequest alloc] initWithURL:url
                                                  parameters:nil
                                               requestMethod:TWRequestMethodGET];
             
             // Important: attach the user's Twitter ACAccount object to the request
             req.account = account;
             
             [req performRequestWithHandler:^(NSData *responseData,
                                              NSHTTPURLResponse *urlResponse,
                                              NSError *error) {
                 
                 // If there was an error making the request, display a message to the user
                 if(error != nil) {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter Error"
                                                                     message:@"There was an error talking to Twitter. Please try again later."
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
                     [alert show];
                     return;
                 }
                 
                 // Parse the JSON response
                 NSError *jsonError = nil;
                 id resp = [NSJSONSerialization JSONObjectWithData:responseData
                                                           options:0
                                                             error:&jsonError];
                 
                 // If there was an error decoding the JSON, display a message to the user
                 if(jsonError != nil) {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter Error"
                                                                     message:@"Twitter is not acting properly right now. Please try again later."
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
                     [alert show];
                     return;
                 }

                 NSLog(@"%@", [resp description]);
                 NSString *handle = [resp objectForKey:@"screen_name"];
                 NSString *fullName   = [resp objectForKey:@"name"];
                 NSArray *splitName   = [fullName componentsSeparatedByString:@" "];
                 _firstNameField.text = [splitName objectAtIndex:0];
                 _lastNameField.text  = [splitName objectAtIndex:1];
                 _twitterHandleLabel.text = (@"\@%@", handle);
                 
                 
                 // Make sure to perform our operation back on the main thread
                 dispatch_async(dispatch_get_main_queue(), ^{
                     // Do something with the fetched data
                 });
             }];

         }
     }];
    
}

- (void)viewDidLoad
{

    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
