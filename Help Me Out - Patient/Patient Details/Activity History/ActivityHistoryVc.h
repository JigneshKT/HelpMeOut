

#import <UIKit/UIKit.h>

@interface ActivityHistoryVc : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    
    IBOutlet UITableView *tblView;
    NSMutableArray *arrActivityList;
    FIRDatabaseReference *refDb;
    FIRUser *fireuser;

}

@end
