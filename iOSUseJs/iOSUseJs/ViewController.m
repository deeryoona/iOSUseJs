//
//  ViewController.m
//  iOSUseJs
//
//  Created by macmini on 2022/4/29.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
@interface ViewController ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *webView;//用来和js交互请求接口

@property (nonatomic, strong) WKWebViewConfiguration *configuration;

@end

@implementation ViewController

- (WKWebView *)webView {
    if (!_webView) {
        _configuration = [[WKWebViewConfiguration alloc] init];
        //WKUserContentController这个类主要用来做native与JavaScript的交互管理
        WKUserContentController *wkUController = [[WKUserContentController alloc] init];
        [wkUController addScriptMessageHandler:self name:@"addressToTron"];
        _configuration.userContentController = wkUController;
        // WKPreferences这个类主要设置偏好
        WKPreferences *preference = [[WKPreferences alloc] init];
        // 默认认为YES
        preference.javaScriptEnabled = YES;
        // 在iOS上默认为NO，表示不能自动通过窗口打开
        preference.javaScriptCanOpenWindowsAutomatically = YES;
        _configuration.preferences = preference;
        //使用configuration对象初始化webView
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, 375, 667) configuration:_configuration];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        _webView.allowsBackForwardNavigationGestures = YES;
        [_webView setMultipleTouchEnabled:YES];
        [_webView setAutoresizesSubviews:YES];
        [_webView setUserInteractionEnabled:YES];
        [_webView.scrollView setAlwaysBounceVertical:YES];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _webView.opaque = YES;
        _webView.scrollView.bounces = YES;
        _webView.hidden = NO;//隐藏掉
        [self injectionTronCall:_configuration];
    }
    return _webView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]]];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self testTron];
    });
    
     
}



// 本地波场js
- (void)injectionTronCall:(WKWebViewConfiguration *)configuration{
    //本地加载js文件
    NSString *provider_jspath = [[NSBundle mainBundle] pathForResource:@"callTron-min.js" ofType:nil];
    NSString *provider_string = [NSString stringWithContentsOfFile:provider_jspath encoding:NSUTF8StringEncoding error:nil];
    //将js注入到webView中去
    WKUserScript *provider_injectionScript = [[WKUserScript alloc] initWithSource:provider_string injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    [configuration.userContentController addUserScript:provider_injectionScript];
}

- (void)testTron{
    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"javascript:window.addressToTron('%@');",@"0xc11D9943805e56b630A401D4bd9A29550353EFa1"] completionHandler:^(id _Nullable object, NSError * _Nullable error) {
        // 波场
        NSLog(@"---%@",object);
    }];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"addressToTron"]) {
        NSLog(@"已批量请求到资产 = %@",message.body);
        
    }
}


@end
