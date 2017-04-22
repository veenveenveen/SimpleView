//
//  UIViewController+BackButtonStyle.m
//  SimpleView
//
//  Created by ileo on 16/5/10.
//  Copyright © 2016年 ileo. All rights reserved.
//

#import "UIViewController+BackButtonStyle.h"
#import "SimpleViewHeader.h"
#import "NSObject+Block.h"
#import "UIView+Sizes.h"
#import "NSObject+Method.h"
#import "UINavigationController+BackButtonStyle.h"
#import <objc/runtime.h>

@interface UIViewController() <UIViewControllerBackButton>

@end

@implementation UIViewController (BackButtonStyle)

+(void)configViewControllerGesturePopBack{
    [UINavigationController configNavigationControllerGesturePopBack];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [UIViewController exchangeSEL:@selector(viewDidAppear:) withSEL:@selector(BackButtonStyle_viewDidAppear:)];
        [UIViewController exchangeSEL:@selector(viewDidDisappear:) withSEL:@selector(BackButtonStyle_viewDidDisappear:)];
    });
}

-(void)BackButtonStyle_viewDidAppear:(BOOL)animated{
    [self BackButtonStyle_viewDidAppear:animated];
    if (self.navigationController) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

-(void)BackButtonStyle_viewDidDisappear:(BOOL)animated{
    [self BackButtonStyle_viewDidDisappear:animated];
    if (![self.navigationController.viewControllers containsObject:self]) {
        if ([self respondsToSelector:@selector(viewDidBePopped)]) {
            [self performSelector:@selector(viewDidBePopped)];
        }
    }
}

static NSDictionary *backItemStyles;

static char keyResetBackButtonBlock;
static char keyBackButtonClick;

static NSString *defaultBackItemStyle;

+(void)configBackItemStyles:(NSDictionary *)styles{
    backItemStyles = styles;
}

+(void)configDefaultBackItemWithStyle:(NSString *)style{
    defaultBackItemStyle = style;
    [UINavigationController configViewControllerSetupDefaultBackButton];
}

-(instancetype)navSetupBackItemWithStyle:(NSString *)style{
    
    if (self.navigationController) {
        [self resetBackItemWithStyle:style];
    }else{
        [UINavigationController configViewControllerResetBackButton];
        __weak __typeof(self) wself = self;
        void (^ResetBackButtonBlock)() = ^(){
            [wself resetBackItemWithStyle:style];
        };
        objc_setAssociatedObject(self, &keyResetBackButtonBlock, ResetBackButtonBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    
    return self;
}

-(instancetype)navSetupBackItemWithStyle:(NSString *)style action:(void (^)())action{
    objc_setAssociatedObject(self, &keyBackButtonClick, action, OBJC_ASSOCIATION_COPY_NONATOMIC);
    return [self navSetupBackItemWithStyle:style];
}

#pragma mark - backbutton
-(void)viewControllerResetBackButton{
    void (^ResetBackButtonBlock)() = objc_getAssociatedObject(self, &keyResetBackButtonBlock);
    if (ResetBackButtonBlock) {
        ResetBackButtonBlock();
    }
}

-(void)viewControllerSetupDefaultBackButton{
    if (defaultBackItemStyle) {
        [self navSetupBackItemWithStyle:defaultBackItemStyle];
    }
}

#pragma mark
-(void)resetBackItemWithStyle:(NSString *)style{
    
    BackItemModel *model = backItemStyles[style];

    NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:3];
    if (model.offsetX != 0){
        [tmp addObject:[UIBarButtonItem barButtonItemSpaceWithWidth:model.offsetX]];
    }
    
    NSString *title = self.navLastTitle;
    if ([self respondsToSelector:@selector(navBackItemTitle)]) {
        title = [self performSelector:@selector(navBackItemTitle)];
    }
    __weak __typeof(self) wself = self;
    if (model.icon) {
        UIButton *button = [UIButton buttonWithCenter:CGPointZero normalImage:model.icon click:^{
            [wself clickOnBack];
        }];
        if (model.hasTitle) {
            UILabel *label = [[[UILabel labelWithFrame:CGRectMake(button.width + model.titleOffsetX, 0, 80, 50) font:model.titleFont text:title textColor:model.titleColor] labelResetTextAlignment:NSTextAlignmentLeft] setupOnView:button];
            label.centerY = button.height/2;
        }
        [tmp addObject:[UIBarButtonItem barButtonItemWithButton:button]];
    }else if (model.hasTitle) {
        [tmp addObject:[UIBarButtonItem barButtonItemWithButton:[UIButton buttonWithCenter:CGPointZero title:title textColor:model.titleColor font:model.titleFont click:^{
            [wself clickOnBack];
        }]]];
    }
    
    if (tmp.count > 0) {
        [self.navigationItem setLeftBarButtonItems:[tmp copy]];
    }
}

-(void)clickOnBack{
    if ([self respondsToSelector:@selector(navBackItemWillHandleClick)]) {
        [self navBackItemWillHandleClick];
    }
    void (^BackButtonClick)() = objc_getAssociatedObject(self, &keyBackButtonClick);
    if (BackButtonClick) {
        BackButtonClick();
    }else if ([self respondsToSelector:@selector(navClickOnBackItem)]) {
        [self performSelector:@selector(navClickOnBackItem)];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(NSString *)navLastTitle{
    if (self.navigationController) {
        NSInteger index = [self.navigationController.viewControllers indexOfObject:self];
        if (index > 0) {
            return (self.navigationController.viewControllers[index - 1]).title;
        }
    }
    return nil;
}

@end

@implementation BackItemModel

+(BackItemModel *)modelWithOffsetX:(CGFloat)offsetX icon:(UIImage *)icon titleOffsetX:(CGFloat)titleOffsetX titleColor:(UIColor *)color titleFont:(UIFont *)font{
    BackItemModel *model = [[BackItemModel alloc] init];
    model.offsetX = offsetX;
    model.icon = icon;
    model.titleOffsetX = titleOffsetX;
    model.titleColor = color;
    model.titleFont = font;
    model.hasTitle = YES;
    return model;
}

+(BackItemModel *)modelWithOffsetX:(CGFloat)offsetX icon:(UIImage *)icon{
    BackItemModel *model = [[BackItemModel alloc] init];
    model.offsetX = offsetX;
    model.icon = icon;
    model.hasTitle = NO;
    return model;
}

@end
