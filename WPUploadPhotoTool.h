//
//  WPUploadPhotoTool.h
//
//  压缩算法非原创，摘自：http://www.jianshu.com/p/bc735fc57b50
//  Created by 王鹏 on 17/11/3.
//  Copyright © 2017年 王海鹏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol UploadPhotoToolDelegate <NSObject>

@optional
// 选择后的图片
- (void)imagePickerGetData:(NSData *)data;
// 选择后的图片 tag
- (void)imagePickerGetData:(NSData *)data index:(NSInteger)tag;

@end

@interface WPUploadPhotoTool : NSObject

@property (nonatomic, assign) NSInteger actionSheetTag; // 选择tag
@property (nonatomic, assign) CGFloat clipMaxWidth; // 裁剪宽 默认：屏幕宽/2

+ (instancetype)shareInstance;
// 显示actionSheet弹窗
- (void)showImageActionSheetDelegate:(id)delegate isSavePhotos:(BOOL)isSavePhotos;

@end
