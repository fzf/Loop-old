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
@synthesize twitterId           = _twitterId;

- (void)viewWillAppear:(BOOL)animated
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey: @"user_id"])
    {
        self.firstNameField.text = [defaults objectForKey:@"first_name"];
        self.lastNameField.text = [defaults objectForKey:@"last_name"];
        self.companyField.text = [defaults objectForKey:@"company"];
        self.phoneField.text = [defaults objectForKey:@"phone"];
        self.emailField.text = [defaults objectForKey:@"email"];
        self.twitterHandleLabel.text = [defaults objectForKey:@"twitterHandle"];
        self.twitterId = [defaults objectForKey:@"uid"];
        
    }
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
                 NSString *handle     = [resp objectForKey:@"screen_name"];
                 NSString *fullName   = [resp objectForKey:@"name"];
                 NSArray *splitName   = [fullName componentsSeparatedByString:@" "];
                 
                 // Make sure to perform our operation back on the main thread
                 dispatch_async(dispatch_get_main_queue(), ^{
                     // Do something with the fetched data
					 _firstNameField.text = [splitName objectAtIndex:0];
					 if (splitName.count > 1) {
						 _lastNameField.text  = [splitName objectAtIndex:1];
					 }
					 _twitterId           = [resp objectForKey:@"id"];
					 _twitterHandleLabel.text = (@"\@%@", handle);
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

- (IBAction)createOrUpdateUser
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [defaults objectForKey:@"user_id"];

	NSLog(@"twitter id: %@", self.twitterId);
	NSLog(@"user id: %@", user_id);
    NSDictionary *jsonDictionary =  @{
        @"user" :
        @{
            @"first_name" : self.firstNameField.text,
            @"last_name"  : self.lastNameField.text,
            @"email"      : self.emailField.text,
            @"company"    : self.companyField.text,
            @"phone"      : self.phoneField.text,
            @"uid"        : self.twitterId,
            @"twitter_handle": self.twitterHandleLabel.text,
        }
    };
	if (user_id != nil) {
		[[jsonDictionary objectForKey:@"user"] setObject:user_id forKey:@"id"];
	}
    NSError* error;

    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:kNilOptions error:&error];
    NSURL *URL = [NSURL URLWithString:@"http://bluebanana.herokuapp.com/profiles.json"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    SMWebRequest *loginRequest = [SMWebRequest requestWithURLRequest:request delegate:nil context:nil];
    [loginRequest addTarget:self action:@selector(userCreatedOrUpdated:) forRequestEvents:SMWebRequestEventComplete];
    [loginRequest start];

}

- (void)userCreatedOrUpdated:(NSData *)data
{
    NSError *jsonParsingError = nil;
    NSDictionary *parsedResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
    NSLog(@"%@", parsedResponse.description);
    
    if([parsedResponse objectForKey:@"user_id"])
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[parsedResponse objectForKey:@"user_id"]       forKey:@"user_id"];
        [defaults setObject:[parsedResponse objectForKey:@"first_name"]       forKey:@"first_name"];
        [defaults setObject:[parsedResponse objectForKey:@"last_name"]       forKey:@"last_name"];
        [defaults setObject:[parsedResponse objectForKey:@"company"]       forKey:@"company"];
        [defaults setObject:[parsedResponse objectForKey:@"phone"]       forKey:@"phone"];
        [defaults setObject:[parsedResponse objectForKey:@"uid"]       forKey:@"uid"];
        [defaults setObject:[parsedResponse objectForKey:@"email"]       forKey:@"email"];
        [defaults setObject:[parsedResponse objectForKey:@"twitter_handle"] forKey:@"twitter_handle"];
        [defaults synchronize];    
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"User Error"
                                                        message:@"There was an error updating your account."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    }
}

- (void)touchesEnded: (NSSet *)touches withEvent: (UIEvent *)event {
	for (UIView* view in self.view.subviews) {
		if ([view isKindOfClass:[UITextField class]])
			[view resignFirstResponder];
	}
}

@end
