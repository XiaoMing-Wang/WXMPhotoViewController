//
//  PhotoViewController.m
//  DinpayPurse
//
//  Created by Mac on 17/2/20.
//  Copyright © 2017年 wq. All rights reserved.
//
#define KWidth [UIScreen mainScreen].bounds.size.width
#define KHeight [UIScreen mainScreen].bounds.size.height
#define KIPHONE_X (([UIScreen mainScreen].bounds.size.height == 812.0f) ? YES : NO)
#define KBarHeight ((KIPHONE_X) ? 88.0f : 64.0f)
#define KRGBColor(r, g, b) [UIColor colorWithRed:(r) / 255.0f green:(g) / 255.0f blue:(b) / 255.0f alpha:1]

#import "WXMPhotoListCell.h"
#import "WXMPhotoManager.h"
#import "WXMPhotoViewController.h"
#import "WXMPhotoDetailViewController.h"

@interface WXMPhotoViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) CALayer *barLine;
@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, strong) NSMutableArray<WXMPhotoList *> *jurisdictionData;

@end

@implementation WXMPhotoViewController

- (instancetype)init {
    if (self = [super init]) {
        self.pushCamera = YES;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    self.jurisdictionData = @[].mutableCopy;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.title = @"相册";
    self.navigationController.navigationBar.translucent = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (@available(iOS 11.0, *)) {
        self.listTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }

    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar setBackgroundImage:[self imageWithColor:WXMBarColor] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar.layer addSublayer:self.barLine];
        
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:0 target:self
                                                            action:@selector(backLastViewController)];
    item.tintColor = WXMBarTitleColor;
    self.navigationItem.rightBarButtonItem = item;
    
    [self.view addSubview:self.listTableView];
    [self noHaveJurisdiction];
}
/** 返回组 行 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.jurisdictionData.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXMPhotoListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.phoneList = [self.jurisdictionData objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self pushToPhotoListViewController:indexPath];
}

/** 返回 */
- (void)backLastViewController {
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)noHaveJurisdiction {
    [self.jurisdictionData removeAllObjects];;
    void(^photoBlock)(void) = ^(void) {
        if ([WXMPhotoManager sharedInstance].photoData) {
            [self.jurisdictionData addObjectsFromArray:[WXMPhotoManager sharedInstance].photoData];
            [self pushToPhotoListViewController:nil];
            [self.listTableView reloadData];
            return;
        }
        
        [[WXMPhotoManager sharedInstance] getAllPhotoListBlock:^(NSArray<WXMPhotoList *> *arr) {
            [self.jurisdictionData addObjectsFromArray:arr];
            [self.listTableView reloadData];
            [self pushToPhotoListViewController:nil];
        }];
    };

    //未确定权限
    if (PHPhotoLibrary.authorizationStatus == AVAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == AVAuthorizationStatusAuthorized) photoBlock();
            else [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }];
    }

    //已经确定权限(有权限)
    if (PHPhotoLibrary.authorizationStatus == AVAuthorizationStatusAuthorized) photoBlock();
}
- (void)pushToPhotoListViewController:(NSIndexPath *)indexPath {
    if (self.pushCamera == NO && indexPath == nil) return;
    WXMPhotoDetailViewController *photoDetail = [WXMPhotoDetailViewController new];
    photoDetail.results = self.results;
    photoDetail.resultArray = self.resultArray;
    photoDetail.photoType = self.photoType;
    photoDetail.expectSize = self.expectSize;
    if (indexPath == nil) photoDetail.phoneList = [WXMPhotoManager sharedInstance].firstPhotoList;
    if (indexPath) photoDetail.phoneList = self.jurisdictionData[indexPath.row];
    [self.navigationController pushViewController:photoDetail animated:(indexPath != nil)];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.navigationController) return;
    NSDictionary *attributes = @{NSForegroundColorAttributeName : WXMBarTitleColor};
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

/** TableView */
- (UITableView *)listTableView {
    if (!_listTableView) {
        CGRect rect = CGRectMake(0,KBarHeight,KWidth,KHeight - KBarHeight);
        _listTableView = [[UITableView alloc] initWithFrame:rect];
        _listTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _listTableView.tableFooterView = [UIView new];
        _listTableView.showsVerticalScrollIndicator = NO;
        _listTableView.separatorColor = KRGBColor(235, 235, 235);
        _listTableView.backgroundColor = [UIColor whiteColor];
        _listTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
        _listTableView.rowHeight = 100;
        _listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _listTableView.showsVerticalScrollIndicator = YES;
        _listTableView.delegate = self;
        _listTableView.dataSource = self;
        [_listTableView registerClass:[WXMPhotoListCell class] forCellReuseIdentifier:@"cell"];
    }
    return _listTableView;
}
- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
- (CALayer *)barLine {
    if (!_barLine) {
        _barLine = [CALayer layer];
        _barLine.frame = CGRectMake(0, 44, KWidth, 0.5);
        _barLine.backgroundColor = WXMBarLineColor.CGColor;
    }
    return _barLine;
}
@end
