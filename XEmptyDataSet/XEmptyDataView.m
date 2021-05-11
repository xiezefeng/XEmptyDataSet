//
//  XEmptyDataView.m
//  XFrameLayout
//
//  Created by ZF xie on 2021/4/23.
//

#import "XEmptyDataView.h"
#import "XEmptyDataViewSet.h"
#import <WebKit/WebKit.h>
@implementation XEmptyDataViewConfig

/// 初始化
- (instancetype)init
{
    self = [super init];
    if (self) {
        {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
            animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
            animation.toValue = [NSValue valueWithCATransform3D: CATransform3DMakeRotation(M_PI_2, 0.0, 0.0, 1.0) ];
            animation.duration = 0.25;
            animation.cumulative = YES;
            animation.repeatCount = MAXFLOAT;
            self.animation = animation;
        }
        self.titleBottomMargin = ktitleBottomMargin;   ///<距离标题距离
        self.detailBottomMargin = kdetailBottomMargin;   ///<距离标题距离
        self.stateBottomMargin = kimageBottomMargin;   ///<距离标题距离
        self.containTopMargin = kcontainTopMargin;///<容器距离顶部距离
        self.stateSize = kstateSize;
        self.titleFont = ktitleFont;
        self.detailFont = kdetailFont;
        self.detailColor = kdetailColor;
        self.titleColor = ktitlelColor;
        
        self.buttonColor = kbuttonColor;
        self.buttonFont = kbuttonFont;
        self.buttonSize = kbuttonSize;
        self.stateSigntype = XStateSignTypeStaticDiagram;

    }
    return self;
}

- (void)setAnimation:(CAAnimation *)animation {
    _animation = animation;
    self.stateSigntype = XStateSignTypeCustomAnimation;
}

- (void)setGifData:(NSData *)gifData {
    _gifData = gifData;
    self.stateSigntype = XStateSignTypeGif;
}

- (void)setStateImage:(UIImage *)stateImage {
    _stateImage = stateImage;
    self.stateSigntype = XStateSignTypeStaticDiagram;

}

@end

@interface XEmptyDataView()<UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *customView;///<自定义视图
@property (nonatomic, strong) UIImageView *imageView;///<图片
@property (nonatomic, strong) UILabel *detailLabel;///描述
@property (nonatomic, strong) UILabel *titleLabel;///<标题
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIButton *button;///<按钮
@property (nonatomic, strong) UIView *containerView;///<容器视图
@property (nonatomic, strong) UIView *topReferenceView;///<顶部参照视图
@property (nonatomic, strong) WKWebView *imageWebView;///<<#des#>


@end
@implementation XEmptyDataView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}
- (void)commonInit {

    self.backgroundColor = UIColor.whiteColor;
    [self setUpSubViews];
    [self setUpConstraint];
    
}

- (void)x_didTapContentView {
    if (self.tapBackgroundView) {
        self.tapBackgroundView();
    }
}

- (void)x_tapButton {
    if (self.tapButton) {
        self.tapButton();
    }
}
#define kEmptyImageViewAnimationKey @"com.emptyDataSet.imageViewAnimation"

- (void)setEmptyDataViewConfig:(XEmptyDataViewConfig *)emptyDataViewConfig {
    _emptyDataViewConfig = emptyDataViewConfig;
    
    self.titleLabel.font = emptyDataViewConfig.titleFont;
    self.detailLabel.font = emptyDataViewConfig.detailFont;
    self.titleLabel.textColor = emptyDataViewConfig.titleColor;
    self.detailLabel.textColor = emptyDataViewConfig.detailColor;
    self.titleLabel.text = emptyDataViewConfig.titleText;
    self.detailLabel.text = emptyDataViewConfig.detailText;

    if (emptyDataViewConfig.titleAttibutedString) {
        self.titleLabel.attributedText = emptyDataViewConfig.titleAttibutedString;
    }
    
    if (emptyDataViewConfig.detailAttibutedString) {
        self.detailLabel.attributedText = emptyDataViewConfig.detailAttibutedString;
    }
    if (emptyDataViewConfig.buttonText) {
        [self.button setTitle:emptyDataViewConfig.buttonText forState:UIControlStateNormal];
        self.button.titleLabel.font = emptyDataViewConfig.buttonFont;
        [self.button setTitleColor:emptyDataViewConfig.buttonColor forState:UIControlStateNormal];
    }

    switch (self.emptyDataViewConfig.stateSigntype) {
        case XStateSignTypeGif: {
            
            [self.imageWebView loadData:self.emptyDataViewConfig.gifData MIMEType:@"image/gif" characterEncodingName:@"" baseURL:nil];
            //视图加入此gif控件
            [self addSubview: self.imageWebView];
        }
        case XStateSignTypeCustomAnimation: {
           
            [self.imageView.layer addAnimation:emptyDataViewConfig.animation forKey:kEmptyImageViewAnimationKey];
        }
            break;
        case XStateSignTypeStaticDiagram: {
           
            self.imageView.image = emptyDataViewConfig.stateImage;
        }
            break;
            
        default:
            break;
    }
    
    [self setNeedsUpdateConstraints];

}

- (void)setUpSubViews{
    self.containerView = [[UIView alloc] init];
    [self addSubview:self.containerView];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.containerView addSubview:self.titleLabel];
    
    self.detailLabel = [[UILabel alloc] init];
    self.detailLabel.textAlignment = NSTextAlignmentCenter;
    self.detailLabel.numberOfLines = 0;
    [self.containerView addSubview:self.detailLabel];
    
    self.imageView = [[UIImageView alloc] init];
    [self.containerView addSubview:self.imageView];
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(x_didTapContentView)];
    self.tapGesture.delegate = self;
    [self addGestureRecognizer:self.tapGesture];

    self.topReferenceView = [[UIView alloc] init];
    [self.containerView addSubview:self.topReferenceView];

    self.button = [[UIButton alloc] init];
    [self.button addTarget:self action:@selector(x_tapButton) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.button];
}



- (void)setUpConstraint {
    [self.topReferenceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.left.mas_equalTo(0);
        make.height.mas_equalTo(0);
    }];
    
}

- (void)updateConstraints {
    [super updateConstraints];
    
    UIView *topView = self.topReferenceView;
    CGFloat bottomMargin = 0;
    
    if (self.emptyDataViewConfig) {
        
        self.imageView.hidden = YES;
        self.imageWebView.hidden = YES;
        switch (self.emptyDataViewConfig.stateSigntype) {
            case XStateSignTypeGif: {
                [self.imageWebView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(topView.mas_bottom).offset(bottomMargin);
                    make.centerX.equalTo(self);
                    make.size.mas_equalTo(_emptyDataViewConfig.stateSize);
                }];
                topView = self.imageWebView;
                bottomMargin = _emptyDataViewConfig.stateBottomMargin;
                self.imageWebView.hidden = NO;
                break;
            }
            case XStateSignTypeCustomAnimation: {
                [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(topView.mas_bottom).offset(bottomMargin);
                    make.centerX.equalTo(self);
                    make.size.mas_equalTo(_emptyDataViewConfig.stateSize);
                }];
                topView = self.imageView;
                bottomMargin = _emptyDataViewConfig.stateBottomMargin;
                self.imageView.hidden = NO;

            }
                break;
            case XStateSignTypeStaticDiagram: {
                if (self.emptyDataViewConfig.stateImage) {
                    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(topView.mas_bottom).offset(bottomMargin);
                        make.centerX.equalTo(self);
                        make.size.mas_equalTo(_emptyDataViewConfig.stateSize);
                    }];
                    topView = self.imageView;
                    bottomMargin = _emptyDataViewConfig.stateBottomMargin;
                    self.imageView.hidden = NO;
                }
            }
                break;
                
            default:
                break;
        }
        
        
        
        if (_emptyDataViewConfig.titleAttibutedString || _emptyDataViewConfig.titleText) {
            [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(topView.mas_bottom).offset(bottomMargin);
                make.left.right.mas_equalTo(0);
            }];
            topView = self.titleLabel;
            bottomMargin = _emptyDataViewConfig.titleBottomMargin;
            self.titleLabel.hidden = NO;
        }else {
            self.titleLabel.hidden = YES;
        }
        if (_emptyDataViewConfig.detailAttibutedString || _emptyDataViewConfig.detailText) {

            [self.detailLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(topView.mas_bottom).offset(bottomMargin);
                make.left.right.mas_equalTo(0);
            }];
            topView = self.detailLabel;
            bottomMargin = _emptyDataViewConfig.detailBottomMargin;
            self.detailLabel.hidden = NO;
        }else {
            self.detailLabel.hidden = YES;
        }
        
        if (self.emptyDataViewConfig.buttonText) {
            [self.button mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(topView.mas_bottom).offset(bottomMargin);
                make.centerX.mas_equalTo(self.mas_centerX);
                if (self.emptyDataViewConfig) {
                    make.size.mas_equalTo(self.emptyDataViewConfig.buttonSize);
                }
            }];
            topView = self.button;

            self.button.hidden = NO;
        }else {
            self.button.hidden = YES;
        }
        

        [topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.containerView.mas_bottom).offset(-bottomMargin);
        }];
        
        [self.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        
            make.centerX.equalTo(self.mas_centerX);
            if (self.emptyDataViewConfig.containTopMargin > 0) {
                make.top.mas_equalTo(self.emptyDataViewConfig.containTopMargin);
            }else {
                make.centerY.mas_equalTo(self.mas_centerY);
            }
            make.right.left.mas_equalTo(0);
            
        }];
        
    }else {
        for (UIView *subView in self.subviews) {
            subView.hidden = YES;
        }
    }
}



- (void)dealloc
{
    NSLog(@"XEmptyDataView 销毁了");
}

- (WKWebView *)imageWebView {
    if (!_imageWebView) {
        _imageWebView = [[WKWebView alloc] init];
        _imageWebView.userInteractionEnabled = NO;

    }
    return _imageWebView;
}

@end
