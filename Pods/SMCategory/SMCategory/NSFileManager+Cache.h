//
//  NSFileManager+Cache.h
//  FiveMinutes
//
//  Created by 忆思梦 on 16/9/28.
//  Copyright © 2016年 忆思梦. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (Cache)

/**
 Document路径

 @return <#return value description#>
 */
NSString * SMDocumentPath();

/**
 Caches路径

 @return <#return value description#>
 */
NSString * SMCachesPath();

/**
 Libaray路径

 @return <#return value description#>
 */
NSString * SMLibraryPath();

/**
 单个文件大小

 @param filePath 文件路径

 @return 文件大小，单位：KB
 */
+ (long long)fileSizeAtPath:(NSString*)filePath;

/**
 获取文件夹大小

 @param folderPath 文件路径
 
 @return 单位：KB
 */
+ (float)folderSizeAtPath:(NSString*)folderPath;

/**
 清理文件

 @param path       路径
 @param recreate   是否重建文件路径
 @param completion 回调
 */
+ (void)clearCachePath:(NSString *)path recreate:(BOOL)recreate completionHandler:(void(^)(NSError *,BOOL))completion;

@end
