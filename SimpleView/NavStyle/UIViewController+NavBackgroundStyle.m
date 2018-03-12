//
//  UIViewController+NavBackgroundStyle.m
//  SimpleView
//
//  Created by ileo on 16/5/12.
//  Copyright © 2016年 ileo. All rights reserved.
//

#import "UIViewController+NavBackgroundStyle.h"
#import "UIViewController+SimpleNavigation.h"
#import "UINavigationController+SimpleFactory.h"
#import "UINavigationController+BackButtonStyle.h"
#import "UIView+SimpleFactory.h"
#import "UIView+Sizes.h"
#import <objc/runtime.h>
#import "NSObject+Method.h"
#import "SimpleViewHeader.h"
#import "UIViewController+SimpleFactory.h"

@implementation UIViewController (NavBackgroundStyle)

static UIColor *navBackgroundColor;

+(void)configNavBackgroundColor:(UIColor *)color{
    navBackgroundColor = color;
    [[UINavigationBar appearance] setBarTintColor:color];
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
}

+(UIColor *)navBackgroundColor{
    return navBackgroundColor;
}

+(void)configNavBackgroundStyle{
    [UIViewController configSimple];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [UIViewController exchangeSEL:@selector(viewWillDisappearByNavigationPush:) withSEL:@selector(NavBackgroundStyle_viewWillDisappearByNavigationPush:)];
        [UIViewController exchangeSEL:@selector(viewWillAppearByNavigationPush:) withSEL:@selector(NavBackgroundStyle_viewWillAppearByNavigationPush:)];
        [UIViewController exchangeSEL:@selector(viewWillAppearByNavigationPop:) withSEL:@selector(NavBackgroundStyle_viewWillAppearByNavigationPop:)];
    });
}

-(void)NavBackgroundStyle_viewWillDisappearByNavigationPush:(BOOL)animated{
    [self NavBackgroundStyle_viewWillDisappearByNavigationPush:animated];
    
    [self tryUpdateBarHidden];
    [self tryUpdateColor];
    [self tryUpdateShadowImage];
    [self tryUpdateTranslucent];
}

-(void)NavBackgroundStyle_viewWillAppearByNavigationPop:(BOOL)animated{
    [self NavBackgroundStyle_viewWillAppearByNavigationPop:animated];

    if (self.hadNavBarHidden) {
        [self.navigationController setNavigationBarHidden:self.navBarHidden animated:animated];
    }
    if (self.navBackgroundColor) {
        [self.navigationController.navigationBar setBarTintColor:self.navBackgroundColor];
    }
    if (self.navShadowImage) {
        [self.navigationController.navigationBar setShadowImage:self.navShadowImage];
    }
//    if (self.hadNavBackgroundTranslucent) {
        [self.navigationController.navigationBar setTranslucent:self.navBackgroundTranslucent];
//    }
}

-(void)NavBackgroundStyle_viewWillAppearByNavigationPush:(BOOL)animated{
    [self NavBackgroundStyle_viewWillAppearByNavigationPop:animated];

    if (self.hadNavBarHidden) {
        [self.navigationController setNavigationBarHidden:self.navBarHidden animated:animated];
    }
    if (self.navBackgroundColor) {
        [self.navigationController.navigationBar setBarTintColor:self.navBackgroundColor];
    }
    if (self.navShadowImage) {
        [self.navigationController.navigationBar setShadowImage:self.navShadowImage];
    }
//    if (self.hadNavBackgroundTranslucent) {
        [self.navigationController.navigationBar setTranslucent:self.navBackgroundTranslucent];
//    }
}

#pragma mark - navBarHidden

static char keyNavBarHidden;

-(void)setNavBarHidden:(BOOL)navBarHidden{
    [self setNavBarHidden:navBarHidden animated:NO];
}

-(void)setNavBarHidden:(BOOL)navBarHidden animated:(BOOL)animated{
    objc_setAssociatedObject(self, &keyNavBarHidden, @(navBarHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.navigationController) {
        [self.navigationController setNavigationBarHidden:navBarHidden animated:animated];
    }
}

-(BOOL)navBarHidden{
    return [objc_getAssociatedObject(self, &keyNavBarHidden) boolValue];
}

-(BOOL)hadNavBarHidden{
    return objc_getAssociatedObject(self, &keyNavBarHidden);
}

-(void)tryUpdateBarHidden{
    self.navBarHidden = self.navigationController.navigationBarHidden;
}

#pragma mrak - navBackgroundColor

static char keyNavColor;

-(void)setNavBackgroundColor:(UIColor *)navBackgroundColor{
    objc_setAssociatedObject(self, &keyNavColor, navBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.navigationController) {
        [self.navigationController.navigationBar setBarTintColor:navBackgroundColor];
    }
}

-(UIColor *)navBackgroundColor{
    return objc_getAssociatedObject(self, &keyNavColor);
}

-(void)tryUpdateColor{
    self.navBackgroundColor = self.navigationController.navigationBar.barTintColor;
}

#pragma mark - navShadowImage

static char keyNavShadowImage;

-(void)setNavShadowImage:(UIImage *)navShadowImage{
    objc_setAssociatedObject(self, &keyNavShadowImage, navShadowImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.navigationController) {
        [self.navigationController.navigationBar setShadowImage:navShadowImage];
    }
}

-(UIImage *)navShadowImage{
    return objc_getAssociatedObject(self, &keyNavShadowImage);
}

-(void)tryUpdateShadowImage{
    self.navShadowImage = self.navigationController.navigationBar.shadowImage;
}

#pragma mark - navBackgroundTranslucent

static char keyNavTranslucent;

-(void)setNavBackgroundTranslucent:(BOOL)navBackgroundTranslucent{
    objc_setAssociatedObject(self, &keyNavTranslucent, @(navBackgroundTranslucent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.navigationController) {
        [self.navigationController.navigationBar setTranslucent:navBackgroundTranslucent];
    }
}

-(BOOL)navBackgroundTranslucent{
    return [objc_getAssociatedObject(self, &keyNavTranslucent) boolValue];
}

-(BOOL)hadNavBackgroundTranslucent{
    return objc_getAssociatedObject(self, &keyNavTranslucent);
}

-(void)tryUpdateTranslucent{
    self.navBackgroundTranslucent = self.navigationController.navigationBar.translucent;
}


@end
