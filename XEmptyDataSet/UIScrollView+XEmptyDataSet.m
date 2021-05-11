//
//  UIScrollView+XEmptyDataSet.m
//  XFrameLayout
//
//  Created by ZF xie on 2021/4/26.
//
#import <objc/runtime.h>
#import "UIScrollView+XEmptyDataSet.h"
static char const * const kEmptyDataSetView =       "emptyDataSetView";

@implementation UIScrollView (XEmptyDataSet)
- (void)refreshEmptyDataView:(XEmptyDataViewConfig *)emptyDataViewConfig {
  
    self.emptyDataSetView.emptyDataViewConfig = emptyDataViewConfig;
    // We add method sizzling for injecting -x_reloadData implementation to the native -reloadData implementation
    [self swizzleIfPossible:@selector(reloadData)];
    
    // Exclusively for UITableView, we also inject -x_reloadData to -endUpdates
    if ([self isKindOfClass:[UITableView class]]) {
        [self swizzleIfPossible:@selector(endUpdates)];
    }
}

- (void)dismissEmptyDataView {
    [self.emptyDataSetView removeFromSuperview];
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

- (BOOL)x_canDisplay
{
        
    if ([self isKindOfClass:[UITableView class]]
        || [self isKindOfClass:[UICollectionView class]]
        || [self isKindOfClass:[UIScrollView class]]) {
            return YES;
    }
    
    return NO;
}

- (NSInteger)x_itemsCount
{
    NSInteger items = 0;
    
    // UIScollView doesn't respond to 'dataSource' so let's exit
    if (![self respondsToSelector:@selector(dataSource)]) {
        return items;
    }
    
    // UITableView support
    if ([self isKindOfClass:[UITableView class]]) {
        
        UITableView *tableView = (UITableView *)self;
        id <UITableViewDataSource> dataSource = tableView.dataSource;
        
        NSInteger sections = 1;
        
        if (dataSource && [dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
            sections = [dataSource numberOfSectionsInTableView:tableView];
        }
        
        if (dataSource && [dataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
            for (NSInteger section = 0; section < sections; section++) {
                items += [dataSource tableView:tableView numberOfRowsInSection:section];
            }
        }
    }
    // UICollectionView support
    else if ([self isKindOfClass:[UICollectionView class]]) {
        
        UICollectionView *collectionView = (UICollectionView *)self;
        id <UICollectionViewDataSource> dataSource = collectionView.dataSource;

        NSInteger sections = 1;
        
        if (dataSource && [dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
            sections = [dataSource numberOfSectionsInCollectionView:collectionView];
        }
        
        if (dataSource && [dataSource respondsToSelector:@selector(collectionView:numberOfItemsInSection:)]) {
            for (NSInteger section = 0; section < sections; section++) {
                items += [dataSource collectionView:collectionView numberOfItemsInSection:section];
            }
        }
    }
    
    return items;
}

- (void)refreshEmptyDataView {
    if ([self x_itemsCount] == 0) {
        self.emptyDataSetView.hidden = !self.emptyDataSetView.emptyDataViewConfig;
        if(!self.emptyDataSetView.superview) {
            if (([self isKindOfClass:[UITableView class]] || [self isKindOfClass:[UICollectionView class]]) && self.subviews.count > 1) {
                [self insertSubview:self.emptyDataSetView atIndex:self.subviews.count];
            }
            else {
                [self addSubview:self.emptyDataSetView];
            }
        }
    }else {
        [self dismissEmptyDataView];
    }
}

#pragma mark - Method Swizzling

static NSMutableDictionary *_impLookupTable;
static NSString *const xSwizzleInfoPointerKey = @"pointer";
static NSString *const xSwizzleInfoOwnerKey = @"owner";
static NSString *const xSwizzleInfoSelectorKey = @"selector";

void x_original_implementation(id self, SEL _cmd)
{
    // Fetch original implementation from lookup table
    Class baseClass = x_baseClassToSwizzleForTarget(self);
    NSString *key = x_implementationKey(baseClass, _cmd);
    
    NSDictionary *swizzleInfo = [_impLookupTable objectForKey:key];
    NSValue *impValue = [swizzleInfo valueForKey:xSwizzleInfoPointerKey];
    
    IMP impPointer = [impValue pointerValue];
    
    // We then inject the additional implementation for reloading the empty dataset
    // Doing it before calling the original implementation does update the 'isEmptyDataSetVisible' flag on time.
    [self refreshEmptyDataView];
    // If found, call original implementation
    if (impPointer) {
        ((void(*)(id,SEL))impPointer)(self,_cmd);
    }
}

NSString *x_implementationKey(Class class, SEL selector)
{
    if (!class || !selector) {
        return nil;
    }
    
    NSString *className = NSStringFromClass([class class]);
    
    NSString *selectorName = NSStringFromSelector(selector);
    return [NSString stringWithFormat:@"%@_%@",className,selectorName];
}

Class x_baseClassToSwizzleForTarget(id target)
{
    if ([target isKindOfClass:[UITableView class]]) {
        return [UITableView class];
    }
    else if ([target isKindOfClass:[UICollectionView class]]) {
        return [UICollectionView class];
    }
    else if ([target isKindOfClass:[UIScrollView class]]) {
        return [UIScrollView class];
    }
    
    return nil;
}

- (void)swizzleIfPossible:(SEL)selector
{
    // Check if the target responds to selector
    if (![self respondsToSelector:selector]) {
        return;
    }
    
    // Create the lookup table
    if (!_impLookupTable) {
        _impLookupTable = [[NSMutableDictionary alloc] initWithCapacity:3]; // 3 represent the supported base classes
    }
    
    // We make sure that setImplementation is called once per class kind, UITableView or UICollectionView.
    for (NSDictionary *info in [_impLookupTable allValues]) {
        Class class = [info objectForKey:xSwizzleInfoOwnerKey];
        NSString *selectorName = [info objectForKey:xSwizzleInfoSelectorKey];
        
        if ([selectorName isEqualToString:NSStringFromSelector(selector)]) {
            if ([self isKindOfClass:class]) {
                return;
            }
        }
    }
    
    Class baseClass = x_baseClassToSwizzleForTarget(self);
    NSString *key = x_implementationKey(baseClass, selector);
    NSValue *impValue = [[_impLookupTable objectForKey:key] valueForKey:xSwizzleInfoPointerKey];
    
    // If the implementation for this class already exist, skip!!
    if (impValue || !key || !baseClass) {
        return;
    }
    
    // Swizzle by injecting additional implementation
    Method method = class_getInstanceMethod(baseClass, selector);
    IMP x_newImplementation = method_setImplementation(method, (IMP)x_original_implementation);
    
    // Store the new implementation in the lookup table
    NSDictionary *swizzledInfo = @{xSwizzleInfoOwnerKey: baseClass,
                                   xSwizzleInfoSelectorKey: NSStringFromSelector(selector),
                                   xSwizzleInfoPointerKey: [NSValue valueWithPointer:x_newImplementation]};
    
    [_impLookupTable setObject:swizzledInfo forKey:key];
}


@end
