

#import "HomeVcPatient.h"

@interface HomeVcPatient ()
{
    userModel *userInfo;
}
@end

@implementation HomeVcPatient

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    arrCareGiverList = [[NSMutableArray alloc]init];
    refDb = [[FIRDatabase database] reference];
    fireuser = [FIRAuth auth].currentUser;
    userInfo = [Global getUserModelData];
    lblMyname.text = userInfo.userName;
    if (fireuser == nil)
    {
        [self btnLogOut:self];
    }
    else
    {
        yourShorTId = [fireuser.uid substringWithRange:NSMakeRange(0,6)];
        lblYourId.text = yourShorTId;
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    //get my caregiver list
    [[[[refDb child:keyPatient ] child:yourShorTId]child:keyCareGiverList ]  observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
     {
         if(snapshot.childrenCount > 0)
         {
             //get values
             NSDictionary *msg = snapshot.value;             
             NSMutableArray *arrTemp = [[NSMutableArray alloc]init];
             for (id item in msg)
             {
                 [arrTemp addObject:[msg objectForKey:item]];
             }
             arrCareGiverList = arrTemp.mutableCopy;
             [tblview reloadData];
         }
     }];
    
}

- (IBAction)btnLogOut:(id)sender
{
    NSError *signOutError;
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    if (!status)
    {
        NSLog(@"Error signing out: %@", signOutError);
        return;
    }
    else
    {
        [[FIRInstanceID instanceID] deleteIDWithHandler:^(NSError *error){
            NSLog(@"Token:%@",error);
        }];
        NSLog(@"Successfully Signout");
        [Global saveuserModelData:nil];
        UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        mainLandingVc *HomeScreen = (mainLandingVc *)[secondStoryBoard instantiateInitialViewController];
        
        [self presentViewController:HomeScreen animated:YES completion:nil];
    }
}

#pragma Mark - TableView Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrCareGiverList.count + 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        static NSString *cellIdentifier = @"AddCell";
        AddCell *cell = (AddCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
            cell = (AddCell *)[nib objectAtIndex:0];
        }
        return cell;
    }
    else
    {
        static NSString *cellIdentifier = @"HomeCell";
        HomeCell *cell = (HomeCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
            cell = (HomeCell *)[nib objectAtIndex:0];
        }
        cell.lblName.text =[[arrCareGiverList objectAtIndex:indexPath.row - 1] valueForKey:keyCareGiverName];
        cell.lblStatus.text =[[arrCareGiverList objectAtIndex:indexPath.row -1]valueForKey:KeyStatus];
        
        return cell;
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tblview deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0)
    {
        //add
        UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"homePatient" bundle:nil];
        addpersonVc *addPerson = (addpersonVc *)[secondStoryBoard instantiateViewControllerWithIdentifier:@"addpersonVc"];        
        [self presentViewController:addPerson animated:YES completion:nil];
    }
}

- (IBAction)btnNotifyCareGiver:(id)sender
{
    NSMutableArray *arrNotify = [[NSMutableArray alloc]init];
    
    for (int index = 0; index < arrCareGiverList.count; index ++)
    {
        if ([[[arrCareGiverList objectAtIndex:index] valueForKey:KeyStatus]isEqualToString:keyStatusAccept])
        {
            [arrNotify addObject:[arrCareGiverList objectAtIndex:index]];
        }
    }
    if (arrNotify.count > 0)
    {
        NSLog(@"notify this user %@",arrNotify);
        
        for (int index = 0; index < arrNotify.count; index ++)
        {
            NSString *strcareGiverId = [[arrNotify objectAtIndex:index] valueForKey:keyCareGiverId];
            [[[refDb child:keyCareGiver ] child:strcareGiverId ]  observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
             {
                 if(snapshot.childrenCount > 0)
                 {
                     NSDictionary *msg = snapshot.value;
                     NSLog(@"values:%@",msg);

                     //store values in firebase
                     NSString *strNotiTitle = [NSString stringWithFormat:@"you have send help request to %@",[msg valueForKey:keyCareGiver]];
                     NSString *strCurrentTime =[Global getcurrentdateInString];
                     NSDictionary *dict = @{KeyNotiTitle:strNotiTitle,
                                            KeyNotiSendTime:strCurrentTime};
                     [[[[refDb child:KeyActivity ] child:fireuser.uid]child:strCurrentTime] setValue:dict];
                     //get values
                     NSString *strReciverFcmToken =  [msg valueForKey:KeyFcmToken];
                     //send notification
                     NSString *strBodyMsh = [NSString stringWithFormat:@"%@ needs your help",lblMyname.text];
                     [Global sendpushNotiViaFireBase_PushTitle:@"Help me out" bodyMsg:strBodyMsh ReciverToken:strReciverFcmToken Sendername:lblMyname.text senderFcmId:fireuser.uid];

                 }
             }];
        }
    }
    
}
- (IBAction)btnGotoActivityHistoryVc:(id)sender
{
    UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"homePatient" bundle:nil];
    ActivityHistoryVc *Activityvc = (ActivityHistoryVc *)[secondStoryBoard instantiateViewControllerWithIdentifier:@"ActivityHistoryVc"];
    [self presentViewController:Activityvc animated:YES completion:nil];
}


@end
