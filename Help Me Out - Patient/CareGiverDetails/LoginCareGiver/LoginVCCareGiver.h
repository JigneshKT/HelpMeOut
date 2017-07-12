

#import <UIKit/UIKit.h>

@interface LoginVCCareGiver : UIViewController
{
    
    IBOutlet UITextField *txtUsername;
    FIRDatabaseReference *refDb;
    FIRUser *fireuser;
}
- (IBAction)btnActionToSignUpLogin:(id)sender;

@end

