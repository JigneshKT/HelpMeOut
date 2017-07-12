

#import "LoginVCCareGiver.h"

@interface LoginVCCareGiver ()

@end

@implementation LoginVCCareGiver

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    fireuser = [FIRAuth auth].currentUser;
    refDb = [[FIRDatabase database] reference];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)btnActionToSignUpLogin:(id)sender
{
    NSString *strUerName = [txtUsername.text stringByTrimmingCharactersInSet:
                            [NSCharacterSet whitespaceCharacterSet]];
    strUerName = [strUerName stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *userEmail =[NSString stringWithFormat:@"%@@%@",strUerName,keyCareGiverEmail];
    NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    if (refreshedToken == nil)
    {
        refreshedToken =@"invalid token";
    }
    [txtUsername resignFirstResponder];
    if (strUerName.length < 4)
    {
        [[[UIAlertView alloc]initWithTitle:nil message:@"name more then 4 character." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil]show];
        return;
    }
    
    

    NSDate *date = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd hh:mm a"];
    NSString *dateString =[[NSString alloc]initWithString:[df stringFromDate:date]];
    

    NSLog(@"FCM registration token: %@", refreshedToken);

    
    NSLog(@"user email :%@",userEmail);
    [[FIRAuth auth] createUserWithEmail:userEmail
                               password:userEmail
                             completion:^(FIRUser * _Nullable FBuser, NSError * _Nullable error) {
                                 if (error) {
                                     NSLog(@"Error %@", error.localizedDescription);
                                     if ([error.localizedDescription isEqualToString:@"The email address is already in use by another account."])
                                     {
                                         //go to home
                                         [[FIRAuth auth] signInWithEmail:userEmail
                                                                password:userEmail
                                                              completion:^(FIRUser *user, NSError *error)
                                          {
                                              NSLog(@"Firebase Account Login");
                                              if (error)
                                              {
                                                  [[[UIAlertView alloc]initWithTitle:@"error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil, nil]show];
                                                  
                                                  return ;
                                              }

                                             /* [[[refDb child:keyCareGiver]child:yourShorTId] setValue:@{keyCareGiverName:strUerName,
                                                                                                        keyCareGiverId:user.uid,
                                                                                                        keyEmail:userEmail,
                                                                                                        KeyFcmToken:refreshedToken}];
                                              
                                              */
                                              
                                              [Global saveUserName:strUerName];
                                              //update fcm token and time only
                                              NSString *yourShorTId = [user.uid substringWithRange:NSMakeRange(0,6)];

                                              [[[[refDb child:keyCareGiver] child:yourShorTId]child:keyModifyTime]setValue:dateString];
                                              [[[[refDb child:keyCareGiver] child:yourShorTId]child:KeyFcmToken]setValue:refreshedToken];
                                              [self saveUserDetailsAndGoToHome_UserName:strUerName];

                                          }];
                                         
                                     }
                                     return;
                                 }
                                 else
                                 {

                                     NSLog(@"Firebase Account Created");
                                     
                                     NSString *yourShorTId = [FBuser.uid substringWithRange:NSMakeRange(0,6)];

                                     [[[refDb child:keyCareGiver] child:yourShorTId]setValue:@{keyLoginCareGiver: strUerName,
                                                                                          keyEmail:userEmail,
                                                                                          keyCreateTime:dateString,
                                                                                          keyModifyTime:dateString,
                                                                                          KeyFcmToken:refreshedToken,
                                                                                          keyCareGiverId:FBuser.uid}];
                                     
                                     [self saveUserDetailsAndGoToHome_UserName:strUerName];
                                 }
                             }];
}

-(void)saveUserDetailsAndGoToHome_UserName:(NSString *)userName
{
    userModel *mod = [[userModel alloc]init];
    mod.userloginType = keyLoginTypeCareGiver;
    mod.userName =userName;
    
    [Global saveuserModelData:mod];
    
    UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"homeCareGiver" bundle:nil];
    HomeVcCareGiver *HomeScreen = (HomeVcCareGiver *)[secondStoryBoard instantiateInitialViewController];
    [self presentViewController:HomeScreen animated:YES completion:nil];

}
@end
