//
//  LoginViewController.m
//  Snap Scramble
//
//  Created by Tim Gorer on 4/4/16.
//  Copyright © 2016 Tim Gorer. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginViewModel.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "SignupViewController.h"




@interface LoginViewController ()

@property(nonatomic, strong) LoginViewModel *viewModel;

@end

@implementation LoginViewController

- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _viewModel = [[LoginViewModel alloc] init];
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    self.navigationItem.hidesBackButton = YES;
    [self.navigationItem.backBarButtonItem setTitle:@""];
    self.usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.passwordField setDelegate:self];
    [self.usernameField setDelegate:self];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self.navigationController.navigationBar setHidden:true];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setHidden:false];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.usernameField) {
        [self.usernameField resignFirstResponder];
        [self.passwordField becomeFirstResponder];
    }
    
    else if (theTextField == self.passwordField) {
        [self.passwordField resignFirstResponder];
    }
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard {
    if ([self.passwordField isFirstResponder]) {
        [self.passwordField resignFirstResponder];
    }
    
    else if ([self.usernameField isFirstResponder]) {
        [self.usernameField resignFirstResponder];
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)signupScreenButtonDidPress:(id)sender {
    int index = 0;
    //This for loop iterates through all the view controllers in navigation stack.
    for (UIViewController* viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[SignupViewController class]] ) {
            SignupViewController *VC = [self.navigationController.viewControllers objectAtIndex:index];
            [self.navigationController popToViewController:VC animated:NO];
        }
        index += 1;
    }
}


- (IBAction)loginButtonDidPress:(id)sender {
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    username = [username lowercaseString]; // make all strings lowercase
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([username length] == 0 || [password length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                            message:@"Make sure you enter a username and password!"
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    else {
        // initiate timer for timeout
        self.totalSeconds = [NSNumber numberWithInt:0];
        self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(incrementTime) userInfo:nil repeats:YES];
        
        
        [KVNProgress showWithStatus:@"Logging in..."]; // UI
        [self.viewModel logInUser:username password:password completion:^(PFUser *user, NSError *error) {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                                    message:@"Your e-mail or password don't match an account we have in our database."
                                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                [self.timeoutTimer invalidate];
                [KVNProgress dismiss];
            }
            else {
                [self.timeoutTimer invalidate];
                [self.navigationController popToRootViewControllerAnimated:YES]; // go to the main menu
                NSLog(@"User %@ logged in.", user);
                [KVNProgress dismiss];
                self.loginView.animation = @"fall";
                self.loginView.delay = 1.0;
                [self.loginView animate];
            }
        }];
    }
}

- (void)incrementTime {
    int value = [self.totalSeconds intValue];
    self.totalSeconds = [NSNumber numberWithInt:value + 1];
    NSLog(@"%@", self.totalSeconds);
    
    // if too much time passed in uploading
    if ([self.totalSeconds intValue] > 20) {
        NSLog(@"timeout error. took longer than 20 seconds");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"A server error occurred." message:@"Please play again later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        [KVNProgress dismiss];
        [self.timeoutTimer invalidate];
    }
    
}


@end
