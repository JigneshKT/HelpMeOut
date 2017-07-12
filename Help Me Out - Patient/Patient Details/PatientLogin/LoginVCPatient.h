

#import <UIKit/UIKit.h>

@interface LoginVCPatient : UIViewController
{
    
    IBOutlet UITextField *txtUsername;
    FIRDatabaseReference *refDb;
}
- (IBAction)btnActionToSignUpLogin:(id)sender;

@end

