

#import "ActivityHistoryVc.h"

@interface ActivityHistoryVc ()

@end

@implementation ActivityHistoryVc

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    refDb = [[FIRDatabase database] reference];
    fireuser = [FIRAuth auth].currentUser;
    arrActivityList = [[NSMutableArray alloc]init];
    tblView.rowHeight = UITableViewAutomaticDimension;
    tblView.estimatedRowHeight = 60;

    //get my caregiver list
    [[[refDb child:KeyActivity ] child:fireuser.uid].queryOrderedByPriority  observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
     {
         if(snapshot.childrenCount > 0)
         {
             //get values
             NSDictionary *msg = snapshot.value;
             [arrActivityList addObject:msg];
         }
         [tblView reloadData];

     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrActivityList.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ActivityCell";
    ActivityCell *cell = (ActivityCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = (ActivityCell *)[nib objectAtIndex:0];
    }
  
    cell.lblTitle.text = [[arrActivityList objectAtIndex:indexPath.row]valueForKey:KeyNotiTitle];
    cell.lblTime.text = [[arrActivityList objectAtIndex:indexPath.row]valueForKey:KeyNotiSendTime];
    
    [cell.contentView setNeedsLayout];
    [cell.contentView layoutIfNeeded];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (IBAction)btnGoToBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
