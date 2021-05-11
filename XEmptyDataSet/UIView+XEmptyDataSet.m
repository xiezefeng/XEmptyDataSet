//
//  UIView+XViewAttributeBuilder.m
//  XFrameLayout
//
//  Created by ZF xie on 2021/4/22.
//
#import <objc/runtime.h>
#import "XEmptyDataView.h"
#import "UIView+XEmptyDataSet.h"
typedef void(^XViewAddSubView)(UIView *subView);

@interface UIView (XEmptyDataSet)

/// 子视图添加回调
@property (nonatomic, copy) XViewAddSubView viewAddSubView;

@end

@implementation UIView (XEmptyDataSet)
static char const * const kEmptyDataSetView = "emptyDataSetView";


+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethod:NSSelectorFromString(@"addSubview:") withMethod:@selector(x_addSubview:)];
    });
    
}
- (void)x_addSubview:(UIView *)view {
    [self x_addSubview:view];
    if (self.viewAddSubView) {
        self.viewAddSubView(view);
    }
}

#pragma amrk - Swizzle
+ (void)swizzleInstanceMethod:(SEL)origSelector withMethod:(SEL)newSelector {
    Class cls = [self class];
    Method originalMethod = class_getInstanceMethod(cls, origSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, newSelector);
    if (class_addMethod(cls,
                        origSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod)) ) {
        class_replaceMethod(cls,
                            newSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
        
    } else {
        class_replaceMethod(cls,
                            newSelector,
                            class_replaceMethod(cls,
                                                origSelector,
                                                method_getImplementation(swizzledMethod),
                                                method_getTypeEncoding(swizzledMethod)),
                            method_getTypeEncoding(originalMethod));
    }
}

- (XViewAddSubView)viewAddSubView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setViewAddSubView:(XViewAddSubView)viewAddSubView {
    objc_setAssociatedObject(self, @selector(viewAddSubView), viewAddSubView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)refreshEmptyDataView:(XEmptyDataViewConfig *)emptyDataViewConfig {
    self.emptyDataSetView.emptyDataViewConfig = emptyDataViewConfig;
    [self addSubview:self.emptyDataSetView];
    self.emptyDataSetView.hidden = NO;
    __weak UIView *weakSelf = self;
    self.viewAddSubView = ^(UIView *subView){
        if(![subView isEqual: weakSelf.emptyDataSetView] && weakSelf.emptyDataSetView && !weakSelf.emptyDataSetView.hidden) {
            [weakSelf insertSubview:weakSelf.emptyDataSetView atIndex:weakSelf.subviews.count];
        }
    };
}

- (XEmptyDataViewConfig *)emptyDataViewConfig {
    return self.emptyDataSetView.emptyDataViewConfig;
}


#pragma mark - Setters (Private)

- (void)setEmptyDataSetView:(XEmptyDataView *)view
{
    objc_setAssociatedObject(self, kEmptyDataSetView, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (XEmptyDataView *)emptyDataSetView
{
    XEmptyDataView *view = objc_getAssociatedObject(self, kEmptyDataSetView);
    if (!view)
    {
        view = [[XEmptyDataView alloc] initWithFrame:self.frame];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;

        [self setEmptyDataSetView:view];
    }
    return view;
}


- (void)addTapBackgroundView:(void(^)(void))tap {
        self.emptyDataSetView.tapBackgroundView = ^() {
            tap();
        };
}
- (void)addTapButton:(void(^)(void))tap {
        self.emptyDataSetView.tapButton = ^() {
            tap();
        };
}
- (void)dismissEmptyDataView {
    [self.emptyDataSetView removeFromSuperview];
    self.emptyDataSetView = nil;
}
@end
