//
//  SecondViewController.h
//  Loop
//
//  Created by Fletcher Fowler on 8/11/12.
//  Copyright (c) 2012 Zamboni Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>

@interface EditUserViewController : UIViewController
{
    ACAccountStore  *accountStore;
}

@property (retain, nonatomic) IBOutlet UITextField *firstNameField;
@property (retain, nonatomic) IBOutlet UITextField *lastNameField;
@property (retain, nonatomic) IBOutlet UILabel *twitterHandleLabel;

@end
