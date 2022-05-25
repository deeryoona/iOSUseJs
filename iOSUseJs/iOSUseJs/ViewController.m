//
//  ViewController.m
//  iOSUseJs
//
//  Created by macmini on 2022/4/29.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

// WKWebView 内存不释放的问题解决
@interface WeakWebViewScriptMessageDelegate : NSObject <WKScriptMessageHandler>

//WKScriptMessageHandler 这个协议类专门用来处理JavaScript调用原生OC的方法
@property (nonatomic, weak) id <WKScriptMessageHandler> scriptDelegate;

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;


@end

@implementation WeakWebViewScriptMessageDelegate

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate {
    if (self = [super init]) {
        _scriptDelegate = scriptDelegate;
    }
    return self;
}
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([self.scriptDelegate respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]) {
        [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
    }
}

@end

@interface ViewController ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *webView;//用来和js交互请求接口

@property (nonatomic, strong) WKWebViewConfiguration *configuration;

@end

@implementation ViewController

- (WKWebView *)webView {
    if (!_webView) {
        WeakWebViewScriptMessageDelegate *weakScriptMessageDelegate = [[WeakWebViewScriptMessageDelegate alloc] initWithDelegate:self];
        
        _configuration = [[WKWebViewConfiguration alloc] init];
        //WKUserContentController这个类主要用来做native与JavaScript的交互管理
        
        WKUserContentController *wkUController = [[WKUserContentController alloc] init];
        _configuration.userContentController = wkUController;
        [_configuration.userContentController addScriptMessageHandler:weakScriptMessageDelegate name:@"tronTool.version"];
        [_configuration.userContentController addScriptMessageHandler:weakScriptMessageDelegate name:@"tronTool.addressToTron"];
        [_configuration.userContentController addScriptMessageHandler:weakScriptMessageDelegate name:@"tronTool.addressToEth"];
        [_configuration.userContentController addScriptMessageHandler:weakScriptMessageDelegate name:@"tronTool.getTokenInfo"];
        [_configuration.userContentController addScriptMessageHandler:weakScriptMessageDelegate name:@"tronTool.getERC20Name"];
        [_configuration.userContentController addScriptMessageHandler:weakScriptMessageDelegate name:@"tronTool.getERC20Symbol"];
        [_configuration.userContentController addScriptMessageHandler:weakScriptMessageDelegate name:@"tronTool.getERC20Decimals"];
        [_configuration.userContentController addScriptMessageHandler:weakScriptMessageDelegate name:@"tronTool.getERC20Balance"];
        [_configuration.userContentController addScriptMessageHandler:weakScriptMessageDelegate name:@"tronTool.getBalance"];
        [_configuration.userContentController addScriptMessageHandler:weakScriptMessageDelegate name:@"tronTool.getBalances"];
        [_configuration.userContentController addScriptMessageHandler:weakScriptMessageDelegate name:@"tronTool.sendTrx"];
        [_configuration.userContentController addScriptMessageHandler:weakScriptMessageDelegate name:@"tronTool.sendERC20Token"];
        [_configuration.userContentController addScriptMessageHandler:weakScriptMessageDelegate name:@"tronTool.estimateEnergyUsed"];
        [_configuration.userContentController addScriptMessageHandler:weakScriptMessageDelegate name:@"tronTool.getGasLimitWithNetwork_sendTrx"];
        [_configuration.userContentController addScriptMessageHandler:weakScriptMessageDelegate name:@"tronTool.getGasLimit_sendERC20"];
        [_configuration.userContentController addScriptMessageHandler:weakScriptMessageDelegate name:@"tronTool.getTransaction"];
        [_configuration.userContentController addScriptMessageHandler:weakScriptMessageDelegate name:@"tronTool.getTransactionInfo"];
        [_configuration.userContentController addScriptMessageHandler:weakScriptMessageDelegate name:@"tronTool.sign"];
        [_configuration.userContentController addScriptMessageHandler:weakScriptMessageDelegate name:@"tronTool.signTx"];
        
        
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"tronTool.version"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"tronTool.addressToTron"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"tronTool.addressToEth"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"tronTool.getTokenInfo"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"tronTool.getERC20Name"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"tronTool.getERC20Symbol"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"tronTool.getERC20Decimals"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"tronTool.getERC20Balance"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"tronTool.getBalance"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"tronTool.getBalances"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"tronTool.sendTrx"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"tronTool.sendERC20Token"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"tronTool.estimateEnergyUsed"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"tronTool.getGasLimitWithNetwork_sendTrx"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"tronTool.getGasLimit_sendERC20"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"tronTool.getTransaction"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"tronTool.getTransactionInfo"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"tronTool.sign"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"tronTool.signTx"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://fanyi.baidu.com/"]]];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.webView evaluateJavaScript:@"javascript:window.tronTool.mainnet();" completionHandler:^(id _Nullable response, NSError * _Nullable error) {
//            NSLog(@"value111: %@ error: %@", response, error);
//        }];
        [self.webView evaluateJavaScript:@"javascript:window.tronTool.testnet();" completionHandler:^(id _Nullable response, NSError * _Nullable error) {
            NSLog(@"value: %@ error: %@", response, error);
        }];
        [self testTron];
    });
    
     
}



// 本地波场js
- (void)injectionTronCall:(WKWebViewConfiguration *)configuration{
    //本地加载js文件
    NSString *provider_jspath = [[NSBundle mainBundle] pathForResource:@"tronTool-min.js" ofType:nil];
    NSString *provider_string = [NSString stringWithContentsOfFile:provider_jspath encoding:NSUTF8StringEncoding error:nil];
    //将js注入到webView中去
    WKUserScript *provider_injectionScript = [[WKUserScript alloc] initWithSource:provider_string injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    [configuration.userContentController addUserScript:provider_injectionScript];
}

- (void)testTron{
    [self.webView evaluateJavaScript:@"javascript:window.tronTool.delegateCall(window.tronTool.version(), 'tronTool.version');" completionHandler:^(id _Nullable response, NSError * _Nullable error) {}];

    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"javascript:window.tronTool.delegateCall(window.tronTool.addressToTron('%@'), 'tronTool.addressToTron')",@"0xc11d9943805e56b630a401d4bd9a29550353efa1"] completionHandler:^(id _Nullable response, NSError * _Nullable error) {}];

    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"javascript:window.tronTool.delegateCall(window.tronTool.addressToEth('%@'), 'tronTool.addressToEth')",@"TTaJsdnYPsBjLLM1u2qMw1e9fLLoVKnNUX"] completionHandler:^(id _Nullable response, NSError * _Nullable error) {}];

    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"javascript:window.tronTool.delegateCall(window.tronTool.getTokenInfo('%@'), 'tronTool.getTokenInfo')",@"TEzJjjC4NrLrYFthGFHzQon5zrErNw1JN9"] completionHandler:^(id _Nullable response, NSError * _Nullable error) {}];

    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"javascript:window.tronTool.delegateCall(window.tronTool.getERC20Name('%@'), 'tronTool.getERC20Name')",@"TEzJjjC4NrLrYFthGFHzQon5zrErNw1JN9"] completionHandler:^(id _Nullable response, NSError * _Nullable error) {}];

    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"javascript:window.tronTool.delegateCall(window.tronTool.getERC20Symbol('%@'), 'tronTool.getERC20Symbol')",@"TEzJjjC4NrLrYFthGFHzQon5zrErNw1JN9"] completionHandler:^(id _Nullable response, NSError * _Nullable error) {}];

    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"javascript:window.tronTool.delegateCall(window.tronTool.getERC20Decimals('%@'), 'tronTool.getERC20Decimals')",@"TEzJjjC4NrLrYFthGFHzQon5zrErNw1JN9"] completionHandler:^(id _Nullable response, NSError * _Nullable error) {}];

    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"javascript:window.tronTool.delegateCall(window.tronTool.getERC20Balance('%@', '%@'), 'tronTool.getERC20Balance')", @"TTaJsdnYPsBjLLM1u2qMw1e9fLLoVKnNUX", @"TEzJjjC4NrLrYFthGFHzQon5zrErNw1JN9"] completionHandler:^(id _Nullable response, NSError * _Nullable error) {}];

    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"javascript:window.tronTool.delegateCall(window.tronTool.getBalance('%@'), 'tronTool.getBalance')",@"TTaJsdnYPsBjLLM1u2qMw1e9fLLoVKnNUX"] completionHandler:^(id _Nullable response, NSError * _Nullable error) {}];

    NSString *tokens = @"['T9yD14Nj9j7xAB4dbGeiX9h8unkKHxuWwb', 'TXCWs4vtLW2wYFHfi7xWeiC9Kuj2jxpKqJ', 'TEzJjjC4NrLrYFthGFHzQon5zrErNw1JN9', 'TYMQT8152SicTSDuNEob6t6QRLfet1xrMn']";
    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"javascript:window.tronTool.delegateCall(window.tronTool.getBalances('%@', '%@', %@), 'tronTool.getBalances')",@"TCmNMtJQiPpSKiGuXUj4vcJAGKqJstmsBD", @"TTaJsdnYPsBjLLM1u2qMw1e9fLLoVKnNUX", tokens] completionHandler:^(id _Nullable response, NSError * _Nullable error) {}];

    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"javascript:window.tronTool.delegateCall(window.tronTool.sendTrx('%@', '%@', '%@'), 'tronTool.sendTrx')",@"4594348E3482B751AA235B8E580EFEF69DB465B3A291C5662CEDA6459ED12E39", @"TFzEXjcejyAdfLSEANordcppsxeGW9jEm2", @"1"] completionHandler:^(id _Nullable response, NSError * _Nullable error) {}];

    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"javascript:window.tronTool.delegateCall(window.tronTool.sendERC20Token('%@', '%@', '%@', '%@', %@), 'tronTool.sendERC20Token')",@"4594348E3482B751AA235B8E580EFEF69DB465B3A291C5662CEDA6459ED12E39", @"TFzEXjcejyAdfLSEANordcppsxeGW9jEm2", @"1", @"TEzJjjC4NrLrYFthGFHzQon5zrErNw1JN9", @"15000000"] completionHandler:^(id _Nullable response, NSError * _Nullable error) {}];

    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"javascript:window.tronTool.delegateCall(window.tronTool.estimateEnergyUsed('%@', '%@', '%@', '%@', %@), 'tronTool.estimateEnergyUsed')",@"TTaJsdnYPsBjLLM1u2qMw1e9fLLoVKnNUX", @"TEzJjjC4NrLrYFthGFHzQon5zrErNw1JN9", @"transfer(address,uint256)", @"0", @"['TFzEXjcejyAdfLSEANordcppsxeGW9jEm2', '1']"] completionHandler:^(id _Nullable response, NSError * _Nullable error) {}];

    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"javascript:window.tronTool.delegateCall(window.tronTool.getGasLimitWithNetwork_sendTrx('%@', '%@', '%@'), 'tronTool.getGasLimitWithNetwork_sendTrx')",@"TTaJsdnYPsBjLLM1u2qMw1e9fLLoVKnNUX", @"TFzEXjcejyAdfLSEANordcppsxeGW9jEm2", @"1"] completionHandler:^(id _Nullable response, NSError * _Nullable error) {}];

    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"javascript:window.tronTool.delegateCall(window.tronTool.getGasLimit_sendERC20('%@', '%@', '%@', '%@'), 'tronTool.getGasLimit_sendERC20')",@"TTaJsdnYPsBjLLM1u2qMw1e9fLLoVKnNUX", @"TFzEXjcejyAdfLSEANordcppsxeGW9jEm2", @"1", @"TEzJjjC4NrLrYFthGFHzQon5zrErNw1JN9"] completionHandler:^(id _Nullable response, NSError * _Nullable error) {}];

    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"javascript:window.tronTool.delegateCall(window.tronTool.getTransaction('%@'), 'tronTool.getTransaction')",@"ea84b77dcceb74c8516089c7ddde23b502225f4438d66a0a7591b5de37d65add"] completionHandler:^(id _Nullable response, NSError * _Nullable error) {}];

    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"javascript:window.tronTool.delegateCall(window.tronTool.getTransactionInfo('%@'), 'tronTool.getTransactionInfo')",@"ea84b77dcceb74c8516089c7ddde23b502225f4438d66a0a7591b5de37d65add"] completionHandler:^(id _Nullable response, NSError * _Nullable error) {}];

    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"javascript:window.tronTool.delegateCall(window.tronTool.sign('%@', '%@'), 'tronTool.sign')",@"hello world", @"4594348e3482b751aa235b8e580efef69db465b3a291c5662ceda6459ed12e39"] completionHandler:^(id _Nullable response, NSError * _Nullable error) {}];
    
    NSString *txObj = @"{\"visible\":false,\"txID\":\"055239a62bc461568884d6b0f01adc332776ac69b6faff0ed5e428e11b0bf11b\",\"raw_data\":{\"contract\":[{\"parameter\":{\"value\":{\"data\":\"38615bb000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e00000000000000000000000000000000000000000000000000000000000000025544e56546454535046506f76327842414d52536e6e664577586a4544545641415346456836000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002435636135643639382d383032382d343539662d616662332d36616538653933643862323700000000000000000000000000000000000000000000000000000000\",\"owner_address\":\"41c11d9943805e56b630a401d4bd9a29550353efa1\",\"contract_address\":\"41f723e62e48f4e0a5160ebaf69a60d7244e462a05\",\"call_value\":1000000},\"type_url\":\"type.googleapis.com/protocol.TriggerSmartContract\"},\"type\":\"TriggerSmartContract\"}],\"ref_block_bytes\":\"edaa\",\"ref_block_hash\":\"18b51dc44cc41799\",\"expiration\":1653470136000,\"fee_limit\":150000000,\"timestamp\":1653470077372},\"raw_data_hex\":\"0a02edaa220818b51dc44cc4179940c08d80d48f305ab403081f12af030a31747970652e676f6f676c65617069732e636f6d2f70726f746f636f6c2e54726967676572536d617274436f6e747261637412f9020a1541c11d9943805e56b630a401d4bd9a29550353efa1121541f723e62e48f4e0a5160ebaf69a60d7244e462a0518c0843d22c40238615bb000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e00000000000000000000000000000000000000000000000000000000000000025544e56546454535046506f76327842414d52536e6e664577586a4544545641415346456836000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002435636135643639382d383032382d343539662d616662332d3661653865393364386232370000000000000000000000000000000000000000000000000000000070bcc3fcd38f30900180a3c347\"}";
    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"javascript:window.tronTool.delegateCall(window.tronTool.signTx(%@, '%@'), 'tronTool.signTx')",txObj, @"4594348e3482b751aa235b8e580efef69db465b3a291c5662ceda6459ed12e39"] completionHandler:^(id _Nullable response, NSError * _Nullable error) {}];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"===%@",message.name);
//    NSLog(@"===%@",message.body);
    NSLog(@"=-=-=-=-=-=-==-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-=-=-=-=-=");
    if ([message.name isEqualToString:@"tronTool.addressToTron"]) {
        NSLog(@"波场地址 = %@",message.body);
    } else if ([message.name isEqualToString:@"tronTool.version"]) {
        NSLog(@"JS修订版本 = %@",message.body);
    } else if ([message.name isEqualToString:@"tronTool.sign"]) {
        NSLog(@"字符串签名 = %@",message.body);
    }
    // ...
}


@end
