//
//  ViewController.m
//  oc-webApp
//
//  Created by HelloMac on 16/6/27.
//  Copyright © 2016年 HelloMac. All rights reserved.
//

#import "ViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController ()

@property (nonatomic,strong) UIWebView *webView;

@property (nonatomic,strong) NSString *image;

@property (nonatomic,assign) float width;

@property (nonatomic,assign) float height;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
    
    [self createWebView];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)createWebView{
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64,[UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    self.webView.userInteractionEnabled = YES;
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    
    //加载本地文本资源（使用相对路径，绝对路径时，在真机上运行时一片空白）
    
    //NSURL *url = [NSURL fileURLWithPath:@"/Users/van/Desktop/oc-webApp/oc-webApp/js端.html"];
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"js端" ofType:@"html"]];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    [self.webView loadRequest:request];

    //首先创建JSContext对象（此处通过当前webView的键获取到jscontext）
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    //js调用oc方法，使用block回调实现
    context[@"jakilllog"] = ^(){

        [self albumCollection];
    
    };

}

#pragma mark 代理方法

- (void)webViewDidStartLoad:(UIWebView *)webView{
    
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{

    
    }

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    return YES;
}



- (void)albumCollection{
    UIImagePickerController *pickerControll = [[UIImagePickerController alloc] init];
    pickerControll.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerControll.delegate = self;
    
    [self presentViewController:pickerControll animated:YES completion:nil];
}

#pragma mark -imagePicker代理方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSURL *imageurl = info[UIImagePickerControllerReferenceURL];

    NSString *strString = imageurl.absoluteString;
    NSString *imageName = [strString componentsSeparatedByString:@"?"][1];
    
    NSString *str = [self saveImage:image withImageName:imageName];

    self.image = str;
    self.width = image.size.width;
    self.height = image.size.height;

    //首先创建JSContext对象（此处通过当前webView的键获取到jscontext）
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    NSDictionary *dic = @{@"heigth":@(self.height),@"width":@(self.width),@"image":self.image};
    context[@"dic"] = dic;
    //实现oc调用js函数实现传值
    [context evaluateScript:@"log(dic.heigth,dic.width,dic.image)"];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)saveImage:(UIImage *)currentImage withImageName:(NSString *)imageName{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSData *data = UIImageJPEGRepresentation(currentImage, 1);
    NSString *DocumentPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    [fileManager createDirectoryAtPath:DocumentPath withIntermediateDirectories:YES attributes:nil error:nil];
    [fileManager createFileAtPath:[DocumentPath stringByAppendingPathComponent:imageName] contents:data attributes:nil];
    NSString *fullPath = [DocumentPath stringByAppendingPathComponent:imageName];
    
    return fullPath;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
