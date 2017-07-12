

#import "LoginVCPatient.h"

@interface LoginVCPatient ()

@end
@import FirebaseAuth;

@implementation LoginVCPatient

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    refDb = [[FIRDatabase database] reference];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)btnActionToSignUpLogin:(id)sender
{
    [txtUsername resignFirstResponder];
    
    NSString *strUerName = [txtUsername.text stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    if (strUerName.length < 4)
    {
        [[[UIAlertView alloc]initWithTitle:nil message:@"name more then 4 character." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil]show];
        return;
    }
    NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    if (refreshedToken == nil)
    {
        refreshedToken = @"invalid token";
    }
    
    NSDate *date = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd hh:mm a"];
    NSString *dateString =[[NSString alloc]initWithString:[df stringFromDate:date]];
    
    NSString *userEmail =[NSString stringWithFormat:@"%@%@",strUerName,keypatientEmail];

    [[FIRAuth auth] createUserWithEmail:userEmail
                               password:[NSString stringWithFormat:@"%@",strUerName]
                             completion:^(FIRUser * _Nullable FBuser, NSError * _Nullable error) {
                                 if (error) {
                                     NSLog(@"Error %@", error.localizedDescription);
                                     if ([error.localizedDescription isEqualToString:@"The email address is already in use by another account."])
                                     {
                                         //go to home
                                         [[FIRAuth auth] signInWithEmail:userEmail
                                                                password:strUerName
                                                              completion:^(FIRUser *user, NSError *error)
                                          {
                                              if (error)
                                              {
                                                  [[[UIAlertView alloc]initWithTitle:@"error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil, nil]show];
                                                  
                                                  return ;
                                              }
                                              NSLog(@"Firebase Account Login");
                                              
                                              [Global saveUserName:strUerName];
                                              //update fcm token and time only
                                              NSString *yourShorTId = [user.uid substringWithRange:NSMakeRange(0,6)];

                                              [[[[refDb child:keyPatient] child:yourShorTId]child:keyModifyTime]setValue:dateString];
                                              [[[[refDb child:keyPatient] child:yourShorTId]child:KeyFcmToken]setValue:refreshedToken];
                                              
                                              [self saveUserDetailsAndGoToHome_UserName:strUerName];

                                          }];
                                         
                                     }
                                     else
                                     {
                                         [Global showToastMessageonView:self.view withTitle:@"The name must be 6 characters long or more."];
                                     }
                                     return;
                                 }
                                 else
                                 {
                                     NSLog(@"Firebase Account Created");
                                     [Global saveUserName:strUerName];
                                     NSString *yourShorTId = [FBuser.uid substringWithRange:NSMakeRange(0,6)];

                                     [[[refDb child:keyPatient]child:yourShorTId] setValue:@{keyPatientName:strUerName,
                                                                                            keyPatientId:FBuser.uid,
                                                                                            keyEmail:userEmail,
                                                                                            keyCreateTime:dateString,
                                                                                            keyModifyTime:dateString,
                                                                                            KeyFcmToken:refreshedToken}];
                                     
                                     [self saveUserDetailsAndGoToHome_UserName:strUerName];
                                     
                                 }
                             }];
}
-(void)saveUserDetailsAndGoToHome_UserName:(NSString *)userName
{
    userModel *mod = [[userModel alloc]init];
    mod.userloginType = keyLoginTypePatient;
    mod.userName =userName;
    
    [Global saveuserModelData:mod];
    
    UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"homePatient" bundle:nil];
    HomeVcPatient *HomeScreen = (HomeVcPatient *)[secondStoryBoard instantiateInitialViewController];
    [self presentViewController:HomeScreen animated:YES completion:nil];
    
}
@end
