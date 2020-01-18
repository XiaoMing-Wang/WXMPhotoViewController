//
//  PhotoViewController.m
//  DinpayPurse
//
//  Created by Mac on 17/2/20.
//  Copyright © 2017年 wq. All rights reserved.
//
#import "WXMPhotoListCell.h"
#import "WXMPhotoManager.h"
#import "WXMPhotoConfiguration.h"
#import "WXMPhotoViewController.h"
#import "WXMPhotoDetailViewController.h"

@interface WXMPhotoViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, strong) NSMutableArray<WXMPhotoList *> *jurisdictionData;
@property (nonatomic, assign) UIRectEdge lastEdgesForExtendedLayout;
@end

@implementation WXMPhotoViewController

- (instancetype)init {
    if (self = [super init]) {
        self.expectSize = CGSizeZero;
        self.pushCamera = YES;
        self.exitPreview = YES;
        self.showVideo = YES;
        self.canSelectedVideo = YES;
        self.jurisdictionData = @[].mutableCopy;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.lastEdgesForExtendedLayout = self.edgesForExtendedLayout;
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.title = WXMPhotoVCNavigationItem;
    self.navigationController.navigationBar.translucent = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    UIImage *imageN = [WXMPhotoAssistant wxmPhoto_imageWithColor:WXMBarColor];
    [self.navigationController.navigationBar setBackgroundImage:imageN forBarMetrics:UIBarMetricsDefault];
    [WXMPhotoAssistant wxm_navigationLine:self.navigationController show:YES];
    
    self.navigationItem.rightBarButtonItem = [WXMPhotoAssistant
                                              wxm_createButtonItem:WXMPhotoVCRightItem
                                              target:self
                                              action:@selector(wxm_backLastViewController)];
    
    /** 再次判断权限 */
    [self judgeAuthority];
    [self.view addSubview:self.listTableView];
}

/** 返回组行 */
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
    [self wxm_pushToPhotoListViewController:indexPath];
}

/** 跳转 */
- (void)wxm_pushToPhotoListViewController:(NSIndexPath *)indexPath {
    if (self.pushCamera == NO && indexPath == nil) return;
    WXMPhotoDetailViewController *photoDetail = [WXMPhotoDetailViewController new];
    photoDetail.multiSelectMax = self.multiSelectMax;
    photoDetail.multiSelectVideoMax = self.multiSelectVideoMax;
    photoDetail.exitPreview = self.exitPreview;
    photoDetail.photoType = self.photoType;
    photoDetail.expectSize = self.expectSize;
    photoDetail.showVideo = self.showVideo;
    photoDetail.delegate = self.delegate;
    photoDetail.canSelectedVideo = self.canSelectedVideo;
    if (indexPath == nil) photoDetail.phoneList = [WXMPhotoManager sharedInstance].firstPhotoList;
    if (indexPath) photoDetail.phoneList = self.jurisdictionData[indexPath.row];
    [self.navigationController pushViewController:photoDetail animated:(indexPath != nil)];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

/** 返回 */
- (void)wxm_backLastViewController {
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

/** 判断是否有权限 */
- (void)judgeAuthority {
    __weak __typeof(self) weakself = self;
    [self.jurisdictionData removeAllObjects];
    void(^resultsBlock)(void) = ^(void) {
        if ([WXMPhotoManager sharedInstance].picturesArray) {
            [self.jurisdictionData addObjectsFromArray:[WXMPhotoManager sharedInstance].picturesArray];
            [self wxm_pushToPhotoListViewController:nil];
            [self.listTableView reloadData];
        } else {
            [[WXMPhotoManager sharedInstance] getAllPicturesListBlock:^(NSArray *array) {
                [weakself.jurisdictionData addObjectsFromArray:array];
                [weakself.listTableView reloadData];
                [weakself wxm_pushToPhotoListViewController:nil];
            }];
        }
     };

    /** 未确定权限 */
    if (PHPhotoLibrary.authorizationStatus == AVAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == AVAuthorizationStatusAuthorized) resultsBlock();
            else [weakself wxm_backLastViewController];
        }];
    }

    /** 已经确定权限(有权限) */
    if (PHPhotoLibrary.authorizationStatus == AVAuthorizationStatusAuthorized) resultsBlock();
}

/** TableView */
- (UITableView *)listTableView {
    if (!_listTableView) {
        CGRect rectMin = CGRectMake(0, 0, 0, CGFLOAT_MIN);
        _listTableView = [[UITableView alloc] initWithFrame:WXMPhoto_SRect];
        _listTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _listTableView.tableFooterView = [UIView new];
        _listTableView.showsVerticalScrollIndicator = NO;
        _listTableView.separatorColor = WXMPhoto_RGBColor(235, 235, 235);
        _listTableView.backgroundColor = [UIColor whiteColor];
        _listTableView.tableHeaderView = [[UIView alloc] initWithFrame:rectMin];
        _listTableView.rowHeight = 100;
        _listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _listTableView.showsVerticalScrollIndicator = YES;
        _listTableView.delegate = self;
        _listTableView.dataSource = self;
        [_listTableView registerClass:[WXMPhotoListCell class] forCellReuseIdentifier:@"cell"];
    }
    return _listTableView;
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
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    UIImage *imageN = [WXMPhotoAssistant wxmPhoto_imageWithColor:WXMBarColor];
    [self.navigationController.navigationBar setBackgroundImage:imageN forBarMetrics:UIBarMetricsDefault];
}

- (void)dealloc {
    self.edgesForExtendedLayout = self.lastEdgesForExtendedLayout;
    NSLog(@"释放 %@",NSStringFromClass(self.class));
}
@end
