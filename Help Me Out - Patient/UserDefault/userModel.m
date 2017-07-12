

#import "userModel.h"

@implementation userModel

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.userName = [aDecoder decodeObjectForKey:@"userName"];
         self.useremail = [aDecoder decodeObjectForKey:@"useremail"];
         self.userloginType = [aDecoder decodeObjectForKey:@"userloginType"];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.userName forKey:@"userName"];
    [aCoder encodeObject:self.useremail forKey:@"useremail"];
    [aCoder encodeObject:self.userloginType forKey:@"userloginType"];
}
@end
