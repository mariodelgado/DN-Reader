//
//  ViewController.m
//  DN Reader
//
//  Created by Mario C. Delgado Jr. on 5/20/14.
//  Copyright (c) 2014 Mario C. Delgado Jr. All rights reserved.
//

#import "ViewController.h"
#import "DNAPI.h"

@interface ViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *dialogView;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passTextField;
- (IBAction)loginButtonDidPress:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *loginError;
@property (strong, nonatomic) NSDictionary *data;



@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.emailTextField.delegate =self;
    self.passTextField.delegate = self;
    
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
 //highlight email, pass
    
    if ([textField isEqual:self.emailTextField]) {
        // Email
    } else if ([textField isEqual:self.passTextField]) {
        // Pass
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doErrorMessage{
    //animate shake
    
    //animate expanding error
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:0 animations:^{
        if (self.dialogView.frame.origin.y == 144) {
            [self.dialogView setFrame:CGRectMake(self.dialogView.frame.origin.x, self.dialogView.frame.origin.y-60, self.dialogView.frame.size.width, 300)];
        }
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.loginError.alpha =1;
        }];
    }];

}

- (IBAction)loginButtonDidPress:(id)sender {
    
    //login
    NSString *email = self.emailTextField.text;
    NSString *password = self.passTextField.text;
    NSDictionary *param = @{@"grant_type":@"password",
                            @"username":email,
                            @"password":password,
                            @"client_id":@"750ab22aac78be1c6d4bbe584f0e3477064f646720f327c5464bc127100a1a6d",
                            @"client_secret":@"53e3822c49287190768e009a8f8e55d09041c5bf26d0ef982693f215c72d87da"                            };
    NSURLRequest *request = [NSURLRequest postRequest:DNAPILogin parameters:param];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request
                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                            NSError *serializeError;
                                            id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&serializeError];
                                            double delayInSeconds = 1.0f;   // Just for debug
                                            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                                            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                
                                                // Hide loading
                                               // self.loadingView.hidden = YES;
                                                
                                                // Get response
                                                self.data = json;
                                                NSString *token = [self.data valueForKeyPath:@"access_token"];
                                                NSLog(@"%@", self.data);
                                                
                                                // If logged
                                                if(token) {
                                                    // Do something after logged
                                                    NSLog(@"I am logged!");
                                                    // Perform segue
                                                    [self performSegueWithIdentifier:@"loginToHomeScene" sender:self];
                                                }
                                                else {
                                                    [self doErrorMessage];
                                                }
                                                
                                            });
                                        }];
    [task resume];
}
@end
