//
//  KKWebView.m
//  StomatologicalOfCustomer
//
//  Created by 吴灶洲 on 2017/6/30.
//  Copyright © 2017年 吴灶洲. All rights reserved.
//

#import "KKWebView.h"
#import <WebKit/WebKit.h>

@interface KKWebView ()<WKUIDelegate,WKNavigationDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) CALayer *progresslayer;
@property (weak, nonatomic) UIView *bottomView;
@property (weak, nonatomic) WKWebView *webView;

@end

@implementation KKWebView

- (instancetype)initWithUrl:(NSString *)url {
    self = [super init];
    if (self) {
        _urlStr = url;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setupUI];
    
    self.view.backgroundColor = [UIColor whiteColor];
    if (self.navigationController) {
        if ([self.navigationController.viewControllers count] > 1) {
            UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"fanhui"] style:UIBarButtonItemStylePlain target:self action:@selector(onClickBack)];
            leftBarButtonItem.width = -30;
            self.navigationItem.leftBarButtonItem = leftBarButtonItem;
            [self.navigationItem.leftBarButtonItem setTintColor:[UIColor lightGrayColor]];
            
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];}


-(void)setupUI {

    WKWebView *webView=[[WKWebView alloc]initWithFrame:self.view.bounds];
    webView.UIDelegate=self;
    webView.navigationDelegate=self;
    webView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:webView];
    _webView = webView;
    
    //添加属性监听
    [webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    //进度条
    UIView *progress = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 3)];
    progress.backgroundColor = [UIColor clearColor];
    [self.view addSubview:progress];
    
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, 0, 0, 3);
    layer.backgroundColor = [UIColor greenColor].CGColor;
    [progress.layer addSublayer:layer];
    _progresslayer = layer;
    
    NSURL *url=[NSURL URLWithString:self.urlStr];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark---WKNavigationDelegate
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
}

// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    //如果是跳转一个新页面
    if (navigationAction.targetFrame == nil) {
        [webView loadRequest:navigationAction.request];
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}


//加载失败调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    //    [_activityIndicator stopAnimating];
    if (_bottomView == nil) {
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 3, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
        bottomView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:bottomView];
        _bottomView = bottomView;
        UITapGestureRecognizer *recongizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(action)];
        [bottomView addGestureRecognizer:recongizer];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 150)];
        imageView.center = CGPointMake(bottomView.center.x, bottomView.center.y-64.0);
        imageView.contentMode = UIViewContentModeCenter;
        imageView.image = [UIImage imageNamed:@"noData"];
        [bottomView addSubview:imageView];
    }else {
        _bottomView.hidden = NO;
    }
}


/** 观察加载进度 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progresslayer.opacity = 1;
        self.progresslayer.frame = CGRectMake(0, 0, self.view.bounds.size.width * [change[NSKeyValueChangeNewKey] floatValue], 3);
        if ([change[NSKeyValueChangeNewKey] floatValue] == 1) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progresslayer.opacity = 0;
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progresslayer.frame = CGRectMake(0, 0, 0, 3);
            });
        }
    }else if ([keyPath isEqualToString:@"title"]){
        self.title = self.webView.title;
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)action {
    _bottomView.hidden = YES;
    if (!_webView.isLoading) {
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_urlStr]]];
    }
}

- (void)onClickBack {
    if (self.webView.canGoBack==YES) {
        
        [self.webView goBack];
        
    }else{
        
        [self.navigationController popViewControllerAnimated:YES];
    }
//    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc{
    NSLog(@"%@", NSStringFromClass([self class]));
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];
}

@end
