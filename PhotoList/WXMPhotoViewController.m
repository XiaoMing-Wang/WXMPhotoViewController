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
@property (nonatomic, strong) NSMutableArray<WXMPhotoList *> *dataSource;
@property (nonatomic, assign) BOOL animation;
@end

@implementation WXMPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = WXMPhoto_SRect;
    self.view.clipsToBounds = YES;
    [self.view addSubview:self.listTableView];
    [self hiddenPhotoListController];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXMPhotoListCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.phoneList = [self.dataSource objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self hiddenPhotoListController];
    if ([self.delegate respondsToSelector:@selector(wp_changePhotoList:)]) {
        [self.delegate wp_changePhotoList:[self.dataSource objectAtIndex:indexPath.row]];
    }
}

/** 返回 */
- (void)wp_backLastViewController {
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)showPhotoListController {
    if (self.animation) return;
    self.animation = YES;
    self.view.hidden = NO;
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
    
    self.dataSource = [WXMPhotoManager sharedInstance].picturesArray.mutableCopy;
    [self.listTableView reloadData];
    
    CGFloat h = WXMPhotoListCellCount * self.listTableView.rowHeight;
    if (WXMPhotoListCellCount == 0) h = WXMPhoto_Height - WXMPhoto_BarHeight;
    [UIView animateWithDuration:.35 delay:0 usingSpringWithDamping:0.98 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.listTableView.frame = CGRectMake(0, 0, WXMPhoto_Width, h);
        self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    } completion:^(BOOL finished) {
        self.animation = NO;
    }];
}

- (void)hiddenPhotoListController {
    if (self.animation) return;
    self.animation = YES;
    CGRect rect = CGRectMake(0, 0, WXMPhoto_Width, 0);
    [UIView animateWithDuration:.35 delay:0 usingSpringWithDamping:0.95 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.listTableView.frame = rect;
        self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
    } completion:^(BOOL finished) {
        self.animation = NO;
        [self.listTableView layoutIfNeeded];
        [self.listTableView setContentOffset:CGPointZero];
        self.view.hidden = YES;
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self hiddenPhotoListController];
    if ([self.delegate respondsToSelector:@selector(wp_touchTitleBarWithUnfold:)]) {
        [self.delegate wp_touchTitleBarWithUnfold:NO];
    }
}

/** TableView */
- (UITableView *)listTableView {
    if (!_listTableView) {
        CGRect rect = CGRectMake(0, 0, WXMPhoto_Width, 0);
        CGRect rectMin = CGRectMake(0, 0, 0, CGFLOAT_MIN);
        _listTableView = [[UITableView alloc] initWithFrame:rect];
        _listTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _listTableView.tableFooterView = [UIView new];
        _listTableView.showsVerticalScrollIndicator = NO;
        _listTableView.separatorColor = WXMPhoto_RGBColor(235, 235, 235);
        _listTableView.backgroundColor = [UIColor whiteColor];
        _listTableView.tableHeaderView = [[UIView alloc] initWithFrame:rectMin];
        _listTableView.rowHeight = WXMPhotoListCellH;
        _listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _listTableView.showsVerticalScrollIndicator = YES;
        _listTableView.delegate = self;
        _listTableView.dataSource = self;
        _listTableView.estimatedRowHeight = 0;
        _listTableView.estimatedSectionHeaderHeight = 0;
        _listTableView.estimatedSectionFooterHeight = 0;
        [_listTableView registerClass:[WXMPhotoListCell class] forCellReuseIdentifier:@"cell"];
    }
    return _listTableView;
}

@end
