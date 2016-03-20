//
//  BDUtilityMacro.h
//  BDKit
//
//  Created by 冰点 on 16/2/17.
//  Copyright © 2016年 冰点. All rights reserved.
//  实用宏工具
//

#ifndef BDUtilityMacro_h
#define BDUtilityMacro_h
//=============================================================//

#define SCR_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCR_HEIGHT [UIScreen mainScreen].bounds.size.height
//导航栏高度
#define NPNavigationHeight CGRectGetMaxY([self.navigationController navigationBar].frame)

//是否为4inch
#define DSFourInch ([UIScreen mainScreen].bounds.size.height >= 568.0)
//是否为iOS7
#define iOS7 ([[UIDevice currentDevice].systemVersion doubleValue] >= 7.0)
//是否为iOS8及以上系统
#define iOS8 ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0)

//=============================================================//

//日至输出
#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"\n\n||-->[%s] %s [Line %d] <--||\n" fmt), [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __func__, __LINE__, ##__VA_ARGS__);
#define DLogObject(object) DLog(@"\n      <Object>__%s__</Object>  \n%@", #object, object)

///----------------
/* 打印JSON类 */
///----------------
#define DLogJSON(v)     DLog(@"\n      <JSON>__%s__</JSON>  \n%@", #v, [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:v options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding])


#else
#   define DLog(...)

///----------------
/* 打印集合类 */
///----------------
#define DLogJSON(v)
#define DLogObject(object)
#endif

//=============================================================//

#define Compose_Scale(fmt) fmt * (SCR_WIDTH/320.0)

//=============================================================//
//去除"-(id)performSelector:(SEL)aSelector withObject:(id)object;"的警告
#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

/*
 如果没有返回结果，可以直接按如下方式调用：
 
 SuppressPerformSelectorLeakWarning(
 [_target performSelector:_action withObject:self]
 );
 如果要返回结果，可以按如下方式调用:
 
 id result;
 SuppressPerformSelectorLeakWarning(
 result = [_target performSelector:_action withObject:self]
 );
 */

//=============================================================//


///判断是否为null
#define bd_isNull(oldValue)\
[oldValue isEqual:[NSNull null]]

#define bd_isValue(oldValue)\
(!oldValue)|| ([oldValue length] <= 0)

#endif /* BDUtilityMacro_h */
