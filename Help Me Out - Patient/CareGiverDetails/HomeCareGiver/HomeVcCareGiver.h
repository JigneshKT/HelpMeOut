

#import <UIKit/UIKit.h>

@interface HomeVcCareGiver : UIViewController<UITableViewDelegate,UITableViewDataSource>

{
    IBOutlet UILabel *lblMyName;
    NSMutableArray *arrCareGiverList;
    IBOutlet UITableView *tblview;
    FIRDatabaseReference *refDb;
    FIRUser *fireuser;
    NSString *yourShorTId;
    IBOutlet UILabel *lblyourId;
}
@end
