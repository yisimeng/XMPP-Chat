//
//  UIView+category.m
//  忆思梦
//
//  Created by duan on 15/6/9.
//  Copyright (c) 2015年 Yisimeng. All rights reserved.
//

#import "UIView+category.h"

@implementation UIView (category)
#pragma mark -- 设置tag值

static int tagOffSet = 10;
- (NSMutableArray *)getTagNameArray
{
    static NSMutableArray * tagNameArray = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tagNameArray = [[NSMutableArray alloc] initWithCapacity:1];
    });
    return tagNameArray;
};
/**
 *  为视图设置字符串tag值
 *
 *  @param name 字符串tag值
 */
- (void)setTagWithName:(NSString *)name
{
    NSMutableArray * tagNameArray = [self getTagNameArray];  //获取存放tag值得单例数组
    if (![tagNameArray containsObject:name]) {
        [tagNameArray addObject:name];          //将字符串tag值添加进数组
    }
    self.tag = ([tagNameArray indexOfObject:name] + 1) *tagOffSet;  //设置数值tag值得偏移
}
/**
 *  通过字符串tag值，获取对应的视图
 *
 *  @param name 字符串tag值
 *
 *  @return 字符串tag值对应的视图
 */
- (UIView *)viewWithTagName:(NSString *)name
{
    NSMutableArray * tagNameArray = [self getTagNameArray];
    if (tagNameArray.count == 0) {
        return nil;         //为了防止没有添加字符串tag值到数组中，引起崩溃
    }
    NSInteger tag = ([tagNameArray indexOfObject:name] + 1) *tagOffSet;   //通过获取到字符串tag值所在数组的的位置，而获取的存储的数值tag值
    return [self viewWithTag:tag];      //返回数值tag值所对应的视图
}

- (void)setLeft:(CGFloat)left{
    CGRect frame = self.frame;
    frame.origin.x = left;
    self.frame = frame;
}
- (CGFloat)left{
    return CGRectGetMinX(self.frame);
}
/**
 *	@brief	获取左上角纵坐标
 *
 *	@return	坐标值
 */
- (CGFloat)top{
    return CGRectGetMinY(self.frame);
}
- (void)setTop:(CGFloat)top{
    CGRect frame = self.frame;
    frame.origin.y = top;
    self.frame = frame;
}
/**
 *	@brief	获取视图右下角横坐标
 *
 *	@return	坐标值
 */
- (CGFloat)right{
    return CGRectGetMaxX(self.frame);
}
-(void)setRight:(CGFloat)right{
    CGRect frame = self.frame;
    frame.origin.x = right-frame.size.width;
    self.frame = frame;
}
/**
 *	@brief	获取视图右下角纵坐标
 *
 *	@return	坐标值
 */
- (CGFloat)bottom{
    return CGRectGetMaxY(self.frame);
}
-(void)setBottom:(CGFloat)bottom{
    CGRect frame = self.frame;
    frame.origin.y = bottom-frame.size.height;
    self.frame = frame;
}
/**
 *	@brief	获取视图宽度
 *
 *	@return	宽度值（像素）
 */
- (CGFloat)width{
    return CGRectGetWidth(self.frame);
}
-(void)setWidth:(CGFloat)width{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}
/**
 *	@brief	获取视图高度
 *
 *	@return	高度值（像素）
 */
- (CGFloat)height{
    return CGRectGetHeight(self.frame);
}
-(void)setHeight:(CGFloat)height{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

/**
 *  视图中心x坐标
 *
 *  @return <#return value description#>
 */
- (CGFloat)centerX{
    return CGRectGetMidX(self.frame);
}
- (void)setCenterX:(CGFloat)centerX{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

/**
 *  视图中心y坐标
 *
 *  @return <#return value description#>
 */
- (CGFloat)centerY{
    return CGRectGetMidY(self.frame);
}
- (void)setCenterY:(CGFloat)centerY{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGPoint)origin{
    return CGPointMake(self.left, self.top);
}
- (void)setOrigin:(CGPoint)origin{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)size{
    return CGSizeMake(self.width, self.height);
}
- (void)setSize:(CGSize)size{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

-(UIViewController *)viewController{
    for (UIView* next = [self superview];next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

- (void)addTarget:(nullable id)target action:(SEL)action{
    if (!self.userInteractionEnabled) {
        self.userInteractionEnabled = YES;
    }
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    [self addGestureRecognizer:tap];
}

- (void)removeAllSubviews{
    for (UIView * subview in self.subviews) {
        [subview removeFromSuperview];
    }
}
@end
