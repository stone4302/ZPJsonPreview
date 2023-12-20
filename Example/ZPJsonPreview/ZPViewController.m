//
//  ZPViewController.m
//  ZPJsonPreview
//
//  Created by pengbingxiang on 12/20/2023.
//  Copyright (c) 2023 pengbingxiang. All rights reserved.
//

#import "ZPViewController.h"
#import "ZPJsonPreview.h"

@interface ZPViewController ()<ZPJsonPreviewDelegate>
@property (nonatomic, strong) ZPJsonPreview *jsonPreview;
@end

@implementation ZPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.jsonPreview = [[ZPJsonPreview alloc] init];
    self.jsonPreview.frame = CGRectMake(20, 20, [UIScreen mainScreen].bounds.size.width - 40, [UIScreen mainScreen].bounds.size.height - 40);
    self.jsonPreview.delegate = self;
    self.jsonPreview.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.jsonPreview];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"zp_json_test" ofType:@"json"];
    NSData *pathData = [NSData dataWithContentsOfFile:path];
    
    [self.jsonPreview preview:pathData style:[ZPJSONHighlightStyle new]];
}

- (BOOL)jsonPreview:(ZPJsonPreview *)jsonPreview didClickURL:(NSURL *)url on:(UITextView *)textView
{
    
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
