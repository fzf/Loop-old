//
//  SecondViewController.h
//  Loop
//
//  Created by Fletcher Fowler on 8/11/12.
//  Copyright (c) 2012 Zamboni Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import "SMWebRequest.h"


@interface EditUserViewController : UIViewController <UITextFieldDelegate>
{
    ACAccountStore  *accountStore;
    NSString *twitterId;
}

@property (nonatomic) NSString *twitterId;

@property (retain, nonatomic) IBOutlet UITextField *firstNameField;
@property (retain, nonatomic) IBOutlet UITextField *lastNameField;
@property (retain, nonatomic) IBOutlet UITextField *emailField;
@property (retain, nonatomic) IBOutlet UITextField *companyField;
@property (retain, nonatomic) IBOutlet UITextField *phoneField;

@property (retain, nonatomic) IBOutlet UILabel *twitterHandleLabel;

- (IBAction)createOrUpdateUser;


@end
