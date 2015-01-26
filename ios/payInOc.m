//
//  payInOc.m
//  Bumblebee-app
//
//  Created by ai966669 on 1/14/15.
//
//

#import "payInOc.h"
#import "Pingpp.h"
@implementation payInOc
#define kUrlScheme      @"Bumblebee-app"
#define kUrl @"http://115.159.46.34:1111/myPay1.js"//@"http://121.41.53.103:1111/mypay1.js" //"http://192.168.1.106/lbPaymentSDK/pay.php" // ali @"http://121.41.53.103:1111/mypay1.js" //@"http://115.159.46.34:1111/myPay1.js"
//bendi  http://10.0.1.23:1111/myPay1.js
-(void)functionInOc:(CDVInvokedUrlCommand *)command{
    idOfBusness= [command.arguments objectAtIndex:0];
    [self startPay];
}
-(void)startPay{
    NSURL* url = [NSURL URLWithString:kUrl];
    NSMutableURLRequest * postRequest=[NSMutableURLRequest requestWithURL:url];
    
    NSDictionary* dict = @{
                           @"channel" : @"alipay",
                           @"amount"  : @"1",
                           @"subject" : @"熊佳佳2个",
                           @"livemode": @"true",
                           @"order_no": idOfBusness
                           };
    NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    NSString *bodyData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [postRequest setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:strlen([bodyData UTF8String])]];
    [postRequest setHTTPMethod:@"POST"];
    [postRequest setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
   // ViewController * __weak weakSelf = self;
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:postRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        if (httpResponse.statusCode != 200) {
        //    [weakSelf showAlertMessage:kErrorNet];
            return;
        }
        if (connectionError != nil) {
            NSLog(@"error = %@", connectionError);
        //    [weakSelf showAlertMessage:kErrorNet];
            return;
        }
        NSString* charge = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"charge = %@", charge);
        dispatch_async(dispatch_get_main_queue(), ^{
            [Pingpp createPayment:charge viewController:nil appURLScheme:kUrlScheme withCompletion:
             ^(NSString *result, PingppError *error) {
                 NSLog(@"执行完成");
                 if ([result isEqualToString:@"success"]) {
                     NSLog(@"成功");
                 } else {
                     NSLog(@"PingppError: code=%lu msg=%@", error.code, [error getMsg]);
                 }
             }
             ];
        });
    }];
}
@end
