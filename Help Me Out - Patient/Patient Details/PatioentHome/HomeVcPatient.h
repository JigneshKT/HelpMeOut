

#import <UIKit/UIKit.h>

@interface HomeVcPatient : UIViewController<UITableViewDelegate,UITableViewDataSource>

{
    IBOutlet UILabel *lblMyname;
    IBOutlet UITableView *tblview;
    IBOutlet UILabel *lblYourId;
    NSMutableArray *arrCareGiverList;
    FIRDatabaseReference *refDb;
    FIRUser *fireuser;
    NSString *yourShorTId;
    IBOutlet UIButton *btnNotify;
}
- (IBAction)btnNotifyCareGiver:(id)sender;
@end
