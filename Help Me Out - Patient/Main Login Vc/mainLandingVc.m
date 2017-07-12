

#import "mainLandingVc.h"

@interface mainLandingVc ()
{
    NSTimer *timerGetToken;
}
@end

@implementation mainLandingVc

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    btnPatient.enabled = NO;
    btnCareGIver.enabled = NO;
    [self GetFireBaseToken];
}
-(void)GetFireBaseToken
{
    timerGetToken =  [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(getToken:)
                                                    userInfo:nil
                                                     repeats:YES];
}
-(void)getToken:(NSTimer *)timer
{
    NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    if (refreshedToken)
    {
        [timerGetToken invalidate];
        btnPatient.enabled = YES;
        btnCareGIver.enabled = YES;
        NSLog(@"Get refreshedToken:%@",refreshedToken);
    }
}




@end
