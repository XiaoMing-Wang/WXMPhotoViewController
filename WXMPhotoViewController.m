//
//  PhotoViewController.m
//  DinpayPurse
//
//  Created by Mac on 17/2/20.
//  Copyright © 2017年 wq. All rights reserved.
//
#define KIPHONE_X ((KHeight == 812.0f) ? YES : NO)
#define KBarHeight ((KIPHONE_X) ? 88.0f : 64.0f)
#define KWidth [UIScreen mainScreen].bounds.size.width
#define KHeight [UIScreen mainScreen].bounds.size.height
#define KRGBColor(r, g, b) [UIColor colorWithRed:(r) / 255.0f green:(g) / 255.0f blue:(b) / 255.0f alpha:1]

#import "WXMPhotoListCell.h"
#import "WXMPhotoManager.h"
#import "WXMPhotoViewController.h"
#import "WXMPhotoDetailViewController.h"

@interface WXMPhotoViewController ()<UITableViewDelegate,UITableViewDataSource>
//@property (nonatomic, strong) void (^imgsBlock)(NSArray *imgs);
@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, strong) NSMutableArray<WXMPhotoList *> *jurisdictionData;
//@property (nonatomic, strong) UIImageView *imageview;
//@property (nonatomic, assign) BOOL needPush;
@end

@implementation WXMPhotoViewController

//+ (instancetype)photoViewControllerWithBlock:(void (^)(NSArray *imgs))imageBlock {
//    PhotoViewController  * photo = [PhotoViewController new];
//    photo.imgsBlock = imageBlock;
//    return photo;
//}
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

    [self.view addSubview:self.listTableView];
    [self noHaveJurisdiction];
}

- (void)pushToPhotoListViewController {
//    PhotoListViewController *photoListVC = [PhotoListViewController new];
//    photoListVC.phoneList = [PhotoTool sharePhotoTool].firstPhotoList;
//    photoListVC.imgsBlock =  self.imgsBlock;
//    photoListVC.photoType = self.photoType;
//    photoListVC.selectArray = self.selectArray;
//    [self.navigationController pushViewController:photoListVC animated:NO];
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
    WXMPhotoDetailViewController *photoDetail = [WXMPhotoDetailViewController new];
    photoDetail.phoneList = self.jurisdictionData[indexPath.row];
    [self.navigationController pushViewController:photoDetail animated:YES];
}

- (void)noHaveJurisdiction {
    [self.jurisdictionData removeAllObjects];;
    void(^photoBlock)(void) = ^(void){
        [[WXMPhotoManager sharedInstance] getAllPhotoListBlock:^(NSArray<WXMPhotoList *> *arr) {
            [self.jurisdictionData addObjectsFromArray:arr];
            [self.listTableView reloadData];
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
//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
////    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : CMPTextDefaultColor()}];
////    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
//}
//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    //[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
//}
///** TableView */
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
@end
