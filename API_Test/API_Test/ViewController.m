//
//  ViewController.m
//  API_Test
//
//  Created by kdh on 2018. 1. 31..
//  Copyright © 2018년 Kim Do Hyun. All rights reserved.
//

#import "ViewController.h"
#import "API.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[API sharedInstance] doRequestMethodType:kHTTPMethodType_GET url:@"http://www.naver.com" header:nil parameter:nil formData:nil progress:^(NSProgress *progress) {
        
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        // Binary 데이터 String 값으로 변경
        NSLog(@"Sucess: %@", [API binaryDataConversionToString:responseObject]);
    } fail:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Fail: %@, %@", task, error);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
