/******************************************************************************
 *
 * Copyright (C) 2013 T Dispatch Ltd
 *
 * Licensed under the GPL License, Version 3.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.gnu.org/licenses/gpl-3.0.html
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 ******************************************************************************
 *
 * @author Marcin Orlowski <marcin.orlowski@webnet.pl>
 *
 ****/

#import "LoginViewController.h"

@interface LoginViewController () <UIWebViewDelegate>

@property (nonatomic, strong) WaitDialog* waitDialog;

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [_cancelButton setTitle:NSLocalizedString(@"oauth_button_cancel", @"") forState:UIControlStateNormal];
    [_cancelButton setTitleColor:[UIColor buttonTextColor] forState:UIControlStateNormal];

    _webView.delegate = self;
    
    NSString* url = [[NetworkEngine getInstance] authUrl];
    
    self.waitDialog = [[WaitDialog alloc] init];
    
    NSURLRequest *requestObject = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                                   cachePolicy:NSURLCacheStorageNotAllowed
                                               timeoutInterval:30];

    [_webView loadRequest:requestObject];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [self setCancelButton:nil];
    [super viewDidUnload];
}

#pragma mark webview delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_waitDialog dismiss];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [_waitDialog show];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL* url = [request URL];
    
    NSLog(@"webView shouldStartRequest: %@", [url absoluteString]);

    NSString* host = [NSString stringWithFormat:@"%@://%@", [url scheme], [url host]];

    if ([host isEqualToString:[[NetworkEngine getInstance] redirectUrl]])
    {
        NSString* query = [[request URL] query];
        NSArray *urlComponents = [query componentsSeparatedByString:@"&"];

        NSString* code = nil;
        
        for (NSString *keyValuePair in urlComponents)
        {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents objectAtIndex:0];
            NSString* value = [pairComponents objectAtIndex:1];
            if ([key isEqualToString:@"code"])
            {
                code = value;
                break;
            }
        }
        
        if ([code isEqualToString:@"denied"])
        {
            //user selected deny!
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            //fixme - show wait dialog
            [[NetworkEngine getInstance] getRefreshToken:code
                                         completionBlock:^(NSObject *o) {
                                             [self.delegate loginFinished:YES];
                                         }
                                            failureBlock:^(NSError* error) {
                                                [self.delegate loginFailed:error];
                                            }];
        }
        
        return NO;
    }
    
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [_waitDialog dismiss];
    
    NSLog(@"%s, %@", __PRETTY_FUNCTION__, error);
    
    if (error.code != 102) //102 == Load frame interrupted, we can ignore this error.
    {
        NSString* path = [[NSBundle mainBundle] pathForResource:@"connect_error" ofType:@"html"];
        NSURL *url = [NSURL fileURLWithPath:path];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [_webView loadRequest:request];
    }
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

