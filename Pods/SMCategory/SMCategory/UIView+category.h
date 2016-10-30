//
//  UIView+category.h
//  忆思梦
//
//  Created by duan on 15/6/9.
//  Copyright (c) 2015年 Yisimeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (category)

/**
 *  设置名称tag值
 *
 *  @param name <#name description#>
 */
- (void)setTagWithName:(NSString *)name;
/**
 *  通过名称tag获取视图
 *
 *  @param name <#name description#>
 *
 *  @return <#return value description#>
 */
- (UIView *)viewWithTagName:(NSString *)name;

/**
 *	@brief	获取左上角横坐标
 *
 *	@return	坐标值
 */
//- (CGFloat)left;
@property (nonatomic, assign) CGFloat left;

/**
 *	@brief	获取左上角纵坐标
 *
 *	@return	坐标值
 */
//- (CGFloat)top;
@property (nonatomic, assign) CGFloat top;

/**
 *	@brief	获取视图右下角横坐标
 *
 *	@return	坐标值
 */
//- (CGFloat)right;
@property (nonatomic, assign) CGFloat right;

/**
 *	@brief	获取视图右下角纵坐标
 *
 *	@return	坐标值
 */
//- (CGFloat)bottom;
@property (nonatomic, assign) CGFloat bottom;


/**
 *	@brief	获取视图宽度
 *
 *	@return	宽度值（像素）
 */
//- (CGFloat)width;
@property (nonatomic, assign) CGFloat width;


/**
 *	@brief	获取视图高度
 *
 *	@return	高度值（像素）
 */
//- (CGFloat)height;
@property (nonatomic, assign) CGFloat height;

/**
 *  视图中心点x坐标
 */
@property (nonatomic, assign) CGFloat centerX;

/**
 *  视图中心点y坐标
 */
@property (nonatomic, assign) CGFloat centerY;

/**
 *  视图起始坐标
 */
@property (nonatomic, assign) CGPoint origin;

/**
 *  视图大小
 */
@property (nonatomic, assign) CGSize size;

/**
 *	@brief	获取视图所在控制器
 *
 *	@return	控制器
 */
- (UIViewController *)viewController;

/**
 *  移除所有子视图
 */
- (void)removeAllSubviews;

/**
 *  添加触摸方法
 *
 *  @param target <#target description#>
 *  @param action <#action description#>
 */
- (void)addTarget:(nullable id)target action:(SEL)action;
@end
