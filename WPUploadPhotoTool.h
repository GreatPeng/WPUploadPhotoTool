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

// 选择后的图片
- (void)imagePickerGetData:(NSData *)data;

@end

@interface WPUploadPhotoTool : NSObject

@property (nonatomic, assign) id <UploadPhotoToolDelegate> delegate;
@property (nonatomic, assign) BOOL isSavePhotos; //是否保存到相册
+ (instancetype)shareInstance;
- (void)showViewToChoodePicture; // 显示actionSheet弹窗

@end
