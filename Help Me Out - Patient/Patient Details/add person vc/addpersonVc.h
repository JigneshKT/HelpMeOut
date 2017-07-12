

#import <UIKit/UIKit.h>

@interface addpersonVc : UIViewController

{
    
    IBOutlet UITextField *txtname;
    IBOutlet UITextField *txtIdNumber;
    NSString *strPatientName;
    NSString *yourShorTId;
}
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) FIRUser *fireuser;

- (IBAction)btnAddPerson:(id)sender;

@end
