

#import "HomeVcCareGiver.h"

@interface HomeVcCareGiver ()
{
    userModel *userInfo;
}
@end

@implementation HomeVcCareGiver

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    arrCareGiverList = [[NSMutableArray alloc]init];
    refDb = [[FIRDatabase database] reference];
    fireuser = [FIRAuth auth].currentUser;
    
    userInfo = [Global getUserModelData];
    lblMyName.text = userInfo.userName;
   
    if (fireuser == nil)
    {
        [self btnLogOut:self];
    }
    else
    {
        yourShorTId = [fireuser.uid substringWithRange:NSMakeRange(0,6)];
        lblyourId.text = yourShorTId;

    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    if (fireuser == nil)
    {
        return;
    }
   
    //get my patient list
    [[[[refDb child:keyCareGiver ] child:yourShorTId]child:keyPatientList ]  observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
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
    
    return arrCareGiverList.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
      static NSString *cellIdentifier = @"CareHomeCell";
        CareHomeCell *cell = (CareHomeCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
            cell = (CareHomeCell *)[nib objectAtIndex:0];
        }
    cell.lblName.text =[[arrCareGiverList objectAtIndex:indexPath.row] valueForKey:keyPatientName];
    NSString *status =[[arrCareGiverList objectAtIndex:indexPath.row]valueForKey:KeyStatus];
    cell.lblStatus.text =status;

    if ([status isEqualToString:keyStatusPending])
    {
        cell.btnAccept.hidden = NO;
        cell.btnReject.hidden = NO;
        cell.lblStatus.hidden = YES;
    }
    else
    {
        cell.btnAccept.hidden = YES;
        cell.btnReject.hidden = YES;
        cell.lblStatus.hidden = NO;
    }
    [cell.btnReject addTarget:self action:@selector(btnRejectPress:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnAccept addTarget:self action:@selector(btnAcceptPress:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
    
}
-(void)btnRejectPress:(UIButton *)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:tblview];
    NSIndexPath *indexPath = [tblview indexPathForRowAtPoint:buttonPosition];
    NSDictionary *dict = [arrCareGiverList objectAtIndex:indexPath.row];
    NSLog(@"btnAcceptPress details:%@",dict);
    
    NSString *strPatientId =[[dict valueForKey:keyPatientId] substringWithRange:NSMakeRange(0, 6)];
    
    NSString *strCurentTime = [Global getcurrentdateInString];
    //update caregiver database status & time
    [[[[[[refDb child:keyCareGiver ] child:yourShorTId]child:keyPatientList ]child:strPatientId ] child:KeyStatus]setValue:keyStatusReject];;
    [[[[[[refDb child:keyCareGiver ] child:yourShorTId]child:keyPatientList ]child:strPatientId ] child:keyModifyTime]setValue:strCurentTime];;

 
    //update patient database status & time
    [[[[[[refDb child:keyPatient ] child:strPatientId]child:keyCareGiverList ]child:yourShorTId ] child:KeyStatus]setValue:keyStatusReject];;
    [[[[[[refDb child:keyPatient ] child:strPatientId]child:keyCareGiverList ]child:yourShorTId ] child:keyModifyTime]setValue:strCurentTime];;

    [[[refDb child:keyPatient ] child:strPatientId ]  observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
     {
         if(snapshot.childrenCount > 0)
         {
             //get values
             NSDictionary *msg = snapshot.value;
             NSLog(@"values:%@",msg);
             //store values in firebase
             NSString *strNotiTitle = [NSString stringWithFormat:@"your request Rejected by %@",lblMyName.text];
             NSString *strCurrentTime =[Global getcurrentdateInString];
             NSDictionary *dict = @{KeyNotiTitle:strNotiTitle,
                                    KeyNotiSendTime:strCurrentTime};
             NSString *strPatientId = [msg valueForKey:keyPatientId];
             [[[[refDb child:KeyActivity ] child:strPatientId]child:strCurrentTime] setValue:dict];

             //send notification
             NSString *strReciverFcmToken =  [msg valueForKey:KeyFcmToken];
             NSString *strTitle = @"Request rejected";
             NSString *strMsgBody = [NSString stringWithFormat:@"Your request to add %@ as caregiver is rejected",lblMyName.text];
             
             [Global sendpushNotiViaFireBase_PushTitle:strTitle bodyMsg:strMsgBody ReciverToken:strReciverFcmToken Sendername:lblMyName.text senderFcmId:fireuser.uid];
             
         }
     }];

}
-(void)btnAcceptPress:(UIButton *)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:tblview];
    NSIndexPath *indexPath = [tblview indexPathForRowAtPoint:buttonPosition];
    NSDictionary *dict = [arrCareGiverList objectAtIndex:indexPath.row];
    NSLog(@"btnAcceptPress details:%@",dict);
    
    NSString *strPatientId =[[dict valueForKey:keyPatientId] substringWithRange:NSMakeRange(0, 6)];
    NSString *strCurentTime = [Global getcurrentdateInString];

    //update caregiver database status
    [[[[[[refDb child:keyCareGiver ] child:yourShorTId]child:keyPatientList ]child:strPatientId ] child:KeyStatus ] setValue:keyStatusAccept];
    [[[[[[refDb child:keyCareGiver ] child:yourShorTId]child:keyPatientList ]child:strPatientId ] child:keyModifyTime ] setValue:strCurentTime];

    
    //update patient database status
    [[[[[[refDb child:keyPatient ] child:strPatientId]child:keyCareGiverList ]child:yourShorTId ] child:KeyStatus] setValue:keyStatusAccept];
    [[[[[[refDb child:keyPatient ] child:strPatientId]child:keyCareGiverList ]child:yourShorTId ] child:keyModifyTime] setValue:strCurentTime];
    
    [[[refDb child:keyPatient ] child:strPatientId ]  observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
     {
         if(snapshot.childrenCount > 0)
         {
             //get values
             NSDictionary *msg = snapshot.value;
             NSLog(@"values:%@",msg);
             
             //store values in firebase
             NSString *strNotiTitle = [NSString stringWithFormat:@"your request Accepted by %@",lblMyName.text];
             NSString *strCurrentTime =[Global getcurrentdateInString];
             NSDictionary *dict = @{KeyNotiTitle:strNotiTitle,
                                    KeyNotiSendTime:strCurrentTime};
             NSString *strPatientId = [msg valueForKey:keyPatientId];
             
             [[[[refDb child:KeyActivity ] child:strPatientId]child:strCurrentTime] setValue:dict];
             
             //send notification
             NSString *strReciverFcmToken =  [msg valueForKey:KeyFcmToken];
             NSString *strTitle = @"Request accepted";
             NSString *strMsgBody = [NSString stringWithFormat:@"Your request to add %@ as caregiver is accepted",lblMyName.text];
             
             [Global sendpushNotiViaFireBase_PushTitle:strTitle bodyMsg:strMsgBody ReciverToken:strReciverFcmToken Sendername:lblMyName.text senderFcmId:fireuser.uid];
             
         }
     }];
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.row == 0)
//    {
//        //add
//        UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"home" bundle:nil];
//        addpersonVc *addPerson = (addpersonVc *)[secondStoryBoard instantiateViewControllerWithIdentifier:@"addpersonVc"];
//        
//        [self presentViewController:addPerson animated:YES completion:nil];
//    }
}

- (IBAction)btnNotifyCareGiver:(id)sender
{
    
}
@end
