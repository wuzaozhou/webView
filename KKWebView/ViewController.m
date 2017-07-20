//
//  ViewController.m
//  KKWebView
//
//  Created by 吴灶洲 on 2017/7/20.
//  Copyright © 2017年 吴灶洲. All rights reserved.
//

#import "ViewController.h"
#import "KKWebView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    KKWebView *webView = [[KKWebView alloc] initWithUrl:@"https://www.baidu.com"];
    
    [self.navigationController pushViewController:webView animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
