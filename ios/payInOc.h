//
//  payInOc.h
//  Bumblebee-app
//
//  Created by ai966669 on 1/14/15.
//
//

#import <Cordova/CDVPlugin.h>

@interface payInOc : CDVPlugin{
     NSString *idOfBusness;
}
-(void)startPay;
-(void)functionInOc:(CDVInvokedUrlCommand*)command;
@end
