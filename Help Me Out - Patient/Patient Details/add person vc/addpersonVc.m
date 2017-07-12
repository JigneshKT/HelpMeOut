

#import "addpersonVc.h"

@interface addpersonVc ()

@end

@implementation addpersonVc

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.ref = [[FIRDatabase database] reference];
   _fireuser = [FIRAuth auth].currentUser;
    strPatientName = [Global getLoginUserName];
    yourShorTId = [_fireuser.uid substringWithRange:NSMakeRange(0,6)];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)gotoBackVC:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnAddPerson:(id)sender
{
    NSString *strCareGiverName = txtname.text;
    NSString *strCareGiverId = txtIdNumber.text;
    [txtname resignFirstResponder];
    [txtIdNumber resignFirstResponder];
    [[[_ref child:keyCareGiver] child:strCareGiverId]  observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
    {
        //NSString *record = snapshot.value;
        if(snapshot.childrenCount > 0)
        {
            // Yes! there is a record.
            [self addPatientDetails:strCareGiverId strCareGiverName:strCareGiverName];
        }
        else
        {
            NSLog(@"record not exist");
            //show alert
            [Global showToastMessageonView:self.view withTitle:@"Enter valid careGiver Id or Name"];
        }
        
    }];
    
}
-(void)addPatientDetails:(NSString *)strCareGiverId strCareGiverName:(NSString *)strCareGiverName
{

    
    [[[[[_ref child:keyCareGiver] child:strCareGiverId] child:keyPatientList ]child:yourShorTId ] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
     {
         if(snapshot.childrenCount > 0)
         {
             // you have alrady request sended.
             [Global showToastMessageonView:self.view withTitle:@"you have already request sended..."];
         }
         else
         {
             //add details in activity
             NSString *strNotiTitle = [NSString stringWithFormat:@"you have send add request to  %@",strCareGiverName];
             NSString *strCurrentTime =[Global getcurrentdateInString];
             NSDictionary *dict = @{KeyNotiTitle:strNotiTitle,
                                    KeyNotiSendTime:strCurrentTime};
             [[[[_ref child:KeyActivity ] child:_fireuser.uid]child:strCurrentTime] setValue:dict];
             
             
             //set values
             NSString *strcurrentdate  =[Global getcurrentdateInString];
             [[[[[_ref child:keyCareGiver] child:strCareGiverId] child:keyPatientList ]child:yourShorTId ]
              setValue:@{keyPatientName: strPatientName,
                         keyPatientId:_fireuser.uid,
                         KeyStatus:keyStatusPending,
                         keyCreateTime:strcurrentdate,
                         keyModifyTime:strcurrentdate}];
             
             [[[[[_ref child:keyPatient] child:yourShorTId] child:keyCareGiverList ]child:strCareGiverId ]
              setValue:@{keyCareGiverName: strCareGiverName,
                         keyCareGiverId:strCareGiverId,
                         KeyStatus:keyStatusPending,
                         keyCreateTime:strcurrentdate,
                         keyModifyTime:strcurrentdate}];
             
             [Global showToastMessageonView:self.view withTitle:@"your request send..."];
             [self dismissViewControllerAnimated:YES completion:nil];
             
             userModel *mod = [Global getUserModelData];

             
             [[[_ref child:keyCareGiver ] child:strCareGiverId ]  observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
              {
                  if(snapshot.childrenCount > 0)
                  {
                      //get values
                      NSDictionary *msg = snapshot.value;
                      NSLog(@"values:%@",msg);
                      NSString *strReciverFcmToken =  [msg valueForKey:KeyFcmToken];
                      //send notification
                      NSString *strBody = [NSString stringWithFormat:@"Please respond to %@'s request",mod.userName];
                      [Global sendpushNotiViaFireBase_PushTitle:@"Request to add new patient" bodyMsg:strBody ReciverToken:strReciverFcmToken Sendername:mod.userName senderFcmId:_fireuser.uid];
                      
                  }
              }];
         }
     }];
}

@end
