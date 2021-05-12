//
//  XEmptyDataView.h
//  XFrameLayout
//
//  Created by ZF xie on 2021/4/23.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, XStateSignType) {
    XStateSignTypeStaticDiagram = 0, //静态图 默认
    XStateSignTypeCustomAnimation = 1 << 1, // 自定义动画图片
    XStateSignTypeGif = 1 << 2, // git 动画图片
};
@interface XEmptyDataViewConfig : NSObject
@property (nonatomic, assign) XStateSignType stateSigntype;   ///<状态图类型

@property (nonatomic, strong) NSAttributedString *titleAttibutedString;   ///<标题
@property (nonatomic, strong) NSAttributedString *detailAttibutedString;   ///<描述
@property (nonatomic, copy) UIImage *stateImage;///<状态图

@property (nonatomic, strong) UIFont *titleFont;///<主标题字体大小
@property (nonatomic, strong) UIFont *detailFont;///<详细描述字体大小
@property (nonatomic, strong) UIFont *buttonFont;///<按钮字体大小


@property (nonatomic, strong) UIColor *titleColor;///<主标题描述字体颜色
@property (nonatomic, strong) UIColor *detailColor;///<详细描述字体颜色
@property (nonatomic, strong) UIColor *buttonColor;///<按钮字体颜色

@property (nonatomic, strong) NSString *titleText;///<主标题描述
@property (nonatomic, strong) NSString *detailText;///<详细描述
@property (nonatomic, strong) NSString *buttonText;///<按钮描述


//@property (nonatomic, assign) CGFloat imageViewBottomMargin;   ///<图片底部距离
@property (nonatomic, assign) CGFloat titleBottomMargin;   ///<距离标题距离
@property (nonatomic, assign) CGFloat detailBottomMargin;   ///<距离标题距离
@property (nonatomic, assign) CGFloat stateBottomMargin;   ///<距离标题距离
@property (nonatomic, assign) CGFloat containTopMargin;///<容器距离顶部距离
@property (nonatomic, assign) CGSize  stateSize;   ///<状态图大小
@property (nonatomic, assign) CGSize  buttonSize;   ///<状态图大小

@property (nonatomic, strong) CAAnimation *animation;///<动画

@property (nonatomic, strong) NSData *gifData;///<git动画二进制

@end

@interface XEmptyDataView : UIView

@property (nonatomic, strong) XEmptyDataViewConfig *emptyDataViewConfig;///<空数据页面配置配置
@property (nonatomic, copy) void(^tapBackgroundView)(void);
@property (nonatomic, copy) void(^tapButton)(void);

@end

NS_ASSUME_NONNULL_END
