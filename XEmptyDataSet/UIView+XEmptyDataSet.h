//
//  UIView+XViewAttributeBuilder.h
//  XFrameLayout
//
//  Created by ZF xie on 2021/4/22.
//

#import <UIKit/UIKit.h>
#import "XEmptyDataView.h"
NS_ASSUME_NONNULL_BEGIN

@interface UIView (XEmptyDataSet)

- (void)refreshEmptyDataView:(XEmptyDataViewConfig *)emptyDataViewConfig;
- (void)dismissEmptyDataView;
- (void)addTapBackgroundView:(void(^)(void))tap;
- (void)addTapButton:(void(^)(void))tap;

@end

NS_ASSUME_NONNULL_END
