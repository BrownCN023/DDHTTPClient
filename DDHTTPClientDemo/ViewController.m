//
//  ViewController.m
//  DDHTTPClientDemo
//
//  Created by TongAn001 on 2018/5/31.
//  Copyright © 2018年 abiang. All rights reserved.
//

#import "ViewController.h"
#import "SimpleHttpApiManager.h"

@interface ViewController ()<DDHttpApiManagerDelegate>

@property (nonatomic,strong) SimpleHttpApiManager * apiManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.apiManager = [[SimpleHttpApiManager alloc] init];
    self.apiManager.delegate = self;
    
    //...
    //[self.apiManager get];
    [self.apiManager post];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - DDHttpApiManagerDelegate
- (void)apiManagerDidSuccess:(DDHttpApiManager *)manager{
    
}
- (void)apiManagerFailed:(DDHttpApiManager *)manager error:(NSError *)error{
    
}

@end
