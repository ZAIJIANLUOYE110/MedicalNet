//
//  HNADatePickButton.m
//  MedicalNet
//
//  Created by gengliming on 15/12/15.
//  Copyright © 2015年 HaiHang. All rights reserved.
//

#import "HNADatePickButton.h"
#import "NSDate+HNA.h"

#define DatePickerHeight 162

@interface HNADatePickButton() {
    UIWindow *_originalKeyWindow;
}
@property (weak, nonatomic) UIView *mask;
@property (weak, nonatomic) UIDatePicker *datePicker;
@property (weak, nonatomic) UIView *pickerContainer;
@property (strong, nonatomic) UIWindow *window;
@end

@implementation HNADatePickButton

#pragma mark - 懒加载
- (UIWindow *)window{
    if (_window == nil) {
        _window = [[UIWindow alloc] init];
        _window.frame = MainScreen.bounds;
        _window.backgroundColor = [UIColor clearColor];
        
        // 添加手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapWindow:)];
        [_window addGestureRecognizer:tap];
    }
    return _window;
}

- (UIView *)mask{
    if (_mask == nil) {
        UIView *mask = [[UIView alloc] initWithFrame:MainScreen.bounds];
        mask.backgroundColor = [UIColor blackColor];
        mask.alpha = 0.5f;
        [self.window addSubview:mask];
        _mask = mask;
    }
    return _mask;
}

- (UIView *)pickerContainer{
    if (_pickerContainer == nil) {
        // 0.创建container
        UIView *container = [[UIView alloc] init];
        container.backgroundColor = [UIColor whiteColor];
        container.layer.cornerRadius = 20;
        
        // 1.设置frame
        CGSize keyWinSize = MainScreen.bounds.size;
        container.frame = CGRectMake(0, keyWinSize.height, keyWinSize.width, DatePickerHeight);
        
        // 2.添加到的window上
        [self.window addSubview:container];
        [self.window bringSubviewToFront:container];
        _pickerContainer = container;
    }
    return _pickerContainer;
}

- (UIDatePicker *)datePicker{
    if (_datePicker == nil) {
        // 0.datePicker属性
        UIDatePicker *datePicker = [[UIDatePicker alloc] init];
        datePicker.datePickerMode = UIDatePickerModeDate;
        
        // 1.设置frame
        datePicker.frame = self.pickerContainer.bounds;
        
        // 2.添加到的window上
        [self.pickerContainer addSubview:datePicker];
        [self.pickerContainer bringSubviewToFront:datePicker];
        _datePicker = datePicker;
        
        // 3.添加事件
        [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _datePicker;
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit{
    // 基本属性
    [self setTitle:@"" forState:UIControlStateNormal];
    [self setTitle:@"" forState:UIControlStateDisabled];
    
    // 添加手势
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMySelf:)];
    [self addGestureRecognizer:tapRecognizer];
}

#pragma mark - 手势
- (void)tapMySelf:(UITapGestureRecognizer *)recognizer{
    // 记录原来的keyWindow
    _originalKeyWindow = KeyWindow;
    [self.window makeKeyAndVisible];
    
    // 设置mask
    self.mask.hidden = NO;
    
    // 动画
    WEAKSELF(weakSelf);
    [UIView animateWithDuration:0.25f delay:0.0f usingSpringWithDamping:0.2f initialSpringVelocity:0.2f options:UIViewAnimationOptionCurveLinear animations:^{
        // 设置pickerContainer的frame
        CGRect frame = weakSelf.pickerContainer.frame;
        frame.origin.y = MainScreen.bounds.size.height - DatePickerHeight;
        weakSelf.pickerContainer.frame = frame;
        
        // 重画datePicker
        [weakSelf.datePicker layoutIfNeeded];
        
    } completion:nil];
    
    // 通知代理
    if ([self.delegate respondsToSelector:@selector(datePickButton:didBeginSelectDate:)]) {
        [self.delegate datePickButton:self didBeginSelectDate:self.datePicker.date];
    }
}

- (void)tapWindow:(UITapGestureRecognizer *)recognizer{
    HNALog(@"%s",__FUNCTION__);
    [_originalKeyWindow makeKeyAndVisible];
    
    self.mask.hidden = YES;
    
    WEAKSELF(weakSelf);
    [UIView animateWithDuration:0.25f delay:0.0f usingSpringWithDamping:0.2f initialSpringVelocity:0.2f options:UIViewAnimationOptionCurveLinear animations:^{
        
        CGSize keyWinSize = MainScreen.bounds.size;
        CGRect frame = weakSelf.pickerContainer.frame;
        frame.origin.y = keyWinSize.height;
        weakSelf.pickerContainer.frame = frame;
        
    } completion:nil];
    
    // 通知代理
    if ([self.delegate respondsToSelector:@selector(datePickButton:didFinishSelectDate:)]) {
        [self.delegate datePickButton:self didFinishSelectDate:self.datePicker.date];
    }
}

#pragma mark - 事件
- (void)datePickerValueChanged:(UIDatePicker *)picker{
    // 设置title
    NSString *title = [picker.date stringWithFormat:@"yyyy-MM-dd"];
    [self setTitle:title forState:UIControlStateNormal];
    
    // 通知代理
    if ([self.delegate respondsToSelector:@selector(datePickButton:dateChanged:)]) {
        [self.delegate datePickButton:self dateChanged:picker.date];
    }
}

- (void)dealloc{
    self.window = nil;
}
@end
