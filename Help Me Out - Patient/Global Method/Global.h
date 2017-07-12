

#import <Foundation/Foundation.h>
#import "userModel.h"

@interface Global : NSObject


+(void)saveUserName:(NSString *)username;
+(NSString *)getLoginUserName;
+(void)showToastMessageonView:(UIView *)view withTitle:(NSString *)title;
+(NSString *)getcurrentdateInString;
+(void)saveuserModelData:(userModel *)usrMod;
+(userModel *)getUserModelData;
+(void)sendpushNotiViaFireBase_PushTitle:(NSString *)title bodyMsg:(NSString *)bodyMsg ReciverToken:(NSString *)strReciverFcmToken Sendername:(NSString *)sendername senderFcmId:(NSString *)SenderfcmId;

@end
