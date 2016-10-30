//
//  NSFileManager+Cache.m
//  FiveMinutes
//
//  Created by 忆思梦 on 16/9/28.
//  Copyright © 2016年 忆思梦. All rights reserved.
//

#import "NSFileManager+Cache.h"

@implementation NSFileManager (Cache)

NSString * SMDocumentPath(){
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

NSString * SMCachesPath(){
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

NSString * SMLibraryPath(){
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES) objectAtIndex:0];
}

/**
 *  获取单个文件的大小
 *
 *  @param filePath 文件路径
 *
 *  @return 文件大小
 */
+ (long long)fileSizeAtPath:(NSString*)filePath{
    if (filePath) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        float filesize = -1.0;
        if ([fileManager fileExistsAtPath:filePath]) {
            NSDictionary *fileDic = [fileManager attributesOfItemAtPath:filePath error:nil];//获取文件的属性
            unsigned long long size = [[fileDic objectForKey:NSFileSize] longLongValue];
            filesize = size/1024.0;
            return filesize;
        }
    }
    return 0.;
}

/**
 *  遍历文件夹获得文件夹大小,单位KB
 *
 *  @param folderPath 文件夹路径
 *
 *  @return 文件夹大小
 */
+ (float)folderSizeAtPath:(NSString*)folderPath{
    if (folderPath) {
        NSFileManager * manager = [NSFileManager defaultManager];
        if (![manager fileExistsAtPath:folderPath]) {
            return 0;
        }
        NSEnumerator * childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
        NSString * fileName;
        long long folderSize = 0;
        while ((fileName = [childFilesEnumerator nextObject]) != nil) {
            NSString * fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
            folderSize += [self fileSizeAtPath:fileAbsolutePath];
        }
        return folderSize/1024.0;
    }
    return 0.;
}

/**
 *  清空某文件夹
 *
 *  @param cacheDisk 文件夹名称
 */
static bool isCleaningCachePath = NO;
+ (void)clearCachePath:(NSString *)path recreate:(BOOL)recreate completionHandler:(void(^)(NSError *,BOOL))completion{
    if (isCleaningCachePath) {
        completion([NSError errorWithDomain:@"该文件正在清理" code:-1 userInfo:nil],NO);
        return;
    }
    if (path) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                isCleaningCachePath = YES;
                NSError * error;
                [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
                if (error) {
                    completion(error,NO);
                    return ;
                }
                if (recreate) {
                    [[NSFileManager defaultManager] createDirectoryAtPath:path
                                              withIntermediateDirectories:YES
                                                               attributes:nil
                                                                    error:NULL];
                }
                isCleaningCachePath = NO;
                if (completion) {
                    completion(nil,YES);
                }
            });
        }else{
            if (completion) {
                completion([NSError errorWithDomain:@"路径不存在" code:0 userInfo:nil],NO);
            }
        }
    }
}

@end
