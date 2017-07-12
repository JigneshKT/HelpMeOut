

#import "Global.h"

@implementation Global

+(void)saveUserName:(NSString *)username
{
    [[NSUserDefaults standardUserDefaults]setObject:username forKey:keyLoginPatient];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
+(NSString *)getLoginUserName
{
   return [[NSUserDefaults standardUserDefaults]valueForKey:keyLoginPatient];
}
+(void)showToastMessageonView:(UIView *)view withTitle:(NSString *)title
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.label.text = title;
    hud.margin = 10.f;
    hud.yOffset = 100.f;
    hud.removeFromSuperViewOnHide = YES;
    // hud.backgroundColor = [UIColor blackColor];
    hud.tintColor = [UIColor redColor];
    
    [hud hideAnimated:YES afterDelay:2];
}
+(NSString *)getcurrentdateInString
{
    NSDate *date = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd hh:mm a"];
    NSString *dateString =[[NSString alloc]initWithString:[df stringFromDate:date]];
    return dateString;
}
+(void)saveuserModelData:(userModel *)usrMod
{
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:usrMod];
    [currentDefaults setObject:data forKey:KcUserModel];
    [currentDefaults synchronize];
}
+(userModel *)getUserModelData
{
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [currentDefaults objectForKey:KcUserModel];
    userModel *token = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return token;
}
+(void)sendpushNotiViaFireBase_PushTitle:(NSString *)title bodyMsg:(NSString *)bodyMsg ReciverToken:(NSString *)strReciverFcmToken Sendername:(NSString *)sendername senderFcmId:(NSString *)SenderfcmId
{
    
    
    
    NSDictionary *Dict = @{@"body":bodyMsg,
                           @"title":title,
                           @"sound":@"default",
                           @"priority": @"high",
                           @"strSenerName":sendername,
                           @"strSenderFcmId":SenderfcmId};
    
    NSMutableDictionary *paramNoti = [[NSMutableDictionary alloc] init];
    
    [paramNoti setValue:Dict forKey:@"notification"];
    [paramNoti setValue:strReciverFcmToken forKey:@"to"];
    
    NSString *strUrlReq = UrlSendNotiFirebaseApi;
    
    
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"key=AAAAfOBRCVY:APA91bGE4ZH5rvRwcdrWhBK0X3esGC2gDmuqzRobbRThRqyC56_9-2-INycGcogruAQ7tLbUOhavxepY4qLQxlMenXLqzJqDzPa54kaiba-2GvdDCNCd28MEeVEzYyWRGrA0i-rNyH_E" forHTTPHeaderField:@"Authorization"];
    [manager POST:strUrlReq parameters:paramNoti progress:nil success:^(NSURLSessionTask *task, id responseObject)
     {
         NSLog(@"responseObject: %@", responseObject);
     }
          failure:^(NSURLSessionTask *operation, NSError *error)
     {
         NSLog(@"Error: %@", error);
     }];
}
@end
