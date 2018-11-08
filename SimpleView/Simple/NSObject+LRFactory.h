//
//  NSObject+LRFactory.h
//  SimpleView
//
//  Created by leo on 2018/11/7.
//  Copyright © 2018 ileo. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN


@interface NSObject (LRFactory)

@property (nonatomic, copy) id tagObject_copy;//用于区分，存值，copy
@property (nonatomic, strong) id tagObject_strong;//用于区分，存值，strong

+(void)lrf_exchangeSEL:(SEL)sel1 withSEL:(SEL)sel2;
+(void)lrf_exchangeClassSEL:(SEL)sel1 withClassSEL:(SEL)sel2;

@end

NS_ASSUME_NONNULL_END
