//
//  WPUploadPhotoTool.m
//  Test
//
//  Created by 王鹏 on 17/11/3.
//  Copyright © 2017年 王海鹏. All rights reserved.
//

#import "WPUploadPhotoTool.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/UTCoreTypes.h>

@interface WPUploadPhotoTool () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIAlertController *actionSheet;

@property (nonatomic, assign) id <UploadPhotoToolDelegate> delegate;
@property (nonatomic, assign) BOOL isSavePhotos; //是否保存到相册

@end

static WPUploadPhotoTool *_instance;

@implementation WPUploadPhotoTool

+ (instancetype)shareInstance {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[WPUploadPhotoTool alloc] init];
    });
    return _instance;
}

- (UIAlertController *)actionSheet {

    if (!_actionSheet) {
     
        _actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        // 拍照
        UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self getImageWithCamera];
        }];
        [_actionSheet addAction:takePhoto];
        
        // 相册
        UIAlertAction *photos = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self getImageWithPhotoLibrary];
        }];
        [_actionSheet addAction:photos];
        
        // 取消
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [_actionSheet addAction:cancle];
    }
    return _actionSheet;
}

- (void)showImageActionSheetDelegate:(id)delegate isSavePhotos:(BOOL)isSavePhotos {
    
    _delegate = delegate;
    _isSavePhotos = isSavePhotos;
    // 获取当前控制器
    UIViewController *currentVC = [self getCurrentVC];
    [currentVC presentViewController:self.actionSheet animated:YES completion:nil];
}

//  获取当前页面的控制器
- (UIViewController *)getCurrentVC {
    
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    //app默认windowLevel是UIWindowLevelNormal，如果不是，找到UIWindowLevelNormal的
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    
    id nextResponder = nil;
    UIViewController *appRootVC=window.rootViewController;
    //  如果是present上来的appRootVC.presentedViewController 不为nil
    if (appRootVC.presentedViewController) {
        nextResponder = appRootVC.presentedViewController;
    }else{
        UIView *frontView = [[window subviews] objectAtIndex:0];
        nextResponder = [frontView nextResponder];
    }
    
    if ([nextResponder isKindOfClass:[UITabBarController class]]){
        UITabBarController * tabbar = (UITabBarController *)nextResponder;
        UINavigationController * nav = (UINavigationController *)tabbar.viewControllers[tabbar.selectedIndex];
        // UINavigationController * nav = tabbar.selectedViewController ; 上下两种写法都行
        result=nav.childViewControllers.lastObject;
        
    }else if ([nextResponder isKindOfClass:[UINavigationController class]]){
        UIViewController * nav = (UIViewController *)nextResponder;
        result = nav.childViewControllers.lastObject;
    }else{
        result = nextResponder;
    }
    return result;
}

// 拍照
- (void)getImageWithCamera {

    AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied) { // 未被授权
        
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"提示" message:@"请在设备的\"设置-隐私-相机\"中允许访问相机。" preferredStyle:UIAlertControllerStyleActionSheet];
        // 取消
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertView addAction:cancle];
        
        // 设置
        UIAlertAction *setting = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        [alertView addAction:setting];
        
    }else if (authStatus == AVAuthorizationStatusNotDetermined) { // 尚未授权
        
        [self getMediaFromSource:UIImagePickerControllerSourceTypeCamera];
    }else if (authStatus  == AVAuthorizationStatusAuthorized) { // 授权
     
        [self getMediaFromSource:UIImagePickerControllerSourceTypeCamera];
    }
}

// 相册选择
- (void)getImageWithPhotoLibrary {

    ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];

    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied) { // 未被授权
        
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"提示" message:@"请在设备的\"设置-隐私-照片\"中允许访问照片。" preferredStyle:UIAlertControllerStyleActionSheet];
        // 取消
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertView addAction:cancle];
        
        // 设置
        UIAlertAction *setting = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        [alertView addAction:setting];
        
    }else if (authStatus == AVAuthorizationStatusNotDetermined) { // 尚未授权
        
        [self getMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
    }else if (authStatus  == AVAuthorizationStatusAuthorized) { // 授权
        
        [self getMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

/**
 *  根据类型打开拍照或相册
 *
 *  @param sourceType 类型
 */
- (void)getMediaFromSource:(UIImagePickerControllerSourceType)sourceType
{
    NSArray *mediatypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    if([UIImagePickerController isSourceTypeAvailable:sourceType] &&[mediatypes count] > 0){
        NSArray *mediatypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//      picker.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        
        picker.mediaTypes = mediatypes;
        picker.delegate = self;
        //  picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        NSString *requiredmediatype = (NSString *)kUTTypeImage;
        NSArray *arrmediatypes = [NSArray arrayWithObject:requiredmediatype];
        [picker setMediaTypes:arrmediatypes];
        [[self getCurrentVC] presentViewController:picker animated:YES completion:nil];
    }else{
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"错误信息" message:@"当前设备不支持拍摄功能" preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [[self getCurrentVC] dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alertController addAction:saveAction];
        [[self getCurrentVC] presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image =  [info objectForKey:UIImagePickerControllerOriginalImage];
    // 拍照后保存到相册
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera && self.isSavePhotos) {
        UIImageWriteToSavedPhotosAlbum(image,self,@selector(image:didFinishSavingWithError:contextInfo:),NULL);
    }
    
    CGFloat maxWidth = self.clipMaxWidth > 0 ? self.clipMaxWidth : [UIScreen mainScreen].bounds.size.width/2;
    NSData *imageData = [self resetSizeOfImageData:image maxSize:maxWidth];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    if ([self.delegate respondsToSelector:@selector(imagePickerGetData:)]) {
        [self.delegate imagePickerGetData:imageData];
    }
    
    if ([self.delegate respondsToSelector:@selector(imagePickerGetData:index:)]) {
        [self.delegate imagePickerGetData:imageData index:self.actionSheetTag];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//这个地方只做一个提示的功能
- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo {

//    NSString *isSuccess = error ? @"保存失败":@"保存成功";
//    NSLog(@"%i",isSuccess);
}


- (NSData *)resetSizeOfImageData:(UIImage *)source_image maxSize:(NSInteger)maxSize {
    //先判断当前质量是否满足要求，不满足再进行压缩
    __block NSData *finallImageData = UIImageJPEGRepresentation(source_image,1.0);
    
    NSLog(@"---------------不压缩：%li",finallImageData.length/1024);
    NSUInteger sizeOrigin   = finallImageData.length;
    NSUInteger sizeOriginKB = sizeOrigin / 1024;
    
    if (sizeOriginKB <= maxSize) {
        return finallImageData;
    }
    
    //先调整分辨率
    CGSize defaultSize = CGSizeMake(1024, 1024);
    UIImage *newImage = [self newSizeImage:defaultSize image:source_image];
    
    finallImageData = UIImageJPEGRepresentation(newImage,1.0);
    
    //保存压缩系数
    NSMutableArray *compressionQualityArr = [NSMutableArray array];
    CGFloat avg   = 1.0/250;
    CGFloat value = avg;
    for (int i = 250; i >= 1; i--) {
        value = i*avg;
        [compressionQualityArr addObject:@(value)];
    }
    /*
     调整大小
     说明：压缩系数数组compressionQualityArr是从大到小存储。
     */
    //思路：使用二分法搜索
    finallImageData = [self halfFuntion:compressionQualityArr image:newImage sourceData:finallImageData maxSize:maxSize];
    //如果还是未能压缩到指定大小，则进行降分辨率
    while (finallImageData.length == 0) {
        //每次降100分辨率
        if (defaultSize.width-100 <= 0 || defaultSize.height-100 <= 0) {
            break;
        }
        defaultSize = CGSizeMake(defaultSize.width-100, defaultSize.height-100);
        UIImage *image = [self newSizeImage:defaultSize
                                      image:[UIImage imageWithData:UIImageJPEGRepresentation(newImage,[[compressionQualityArr lastObject] floatValue])]];
        finallImageData = [self halfFuntion:compressionQualityArr image:image sourceData:UIImageJPEGRepresentation(image,1.0) maxSize:maxSize];
    }
    NSLog(@"---------------压缩后：%li",finallImageData.length/1024);
    return finallImageData;
}

#pragma mark 调整图片分辨率/尺寸（等比例缩放）
- (UIImage *)newSizeImage:(CGSize)size image:(UIImage *)source_image {
    CGSize newSize = CGSizeMake(source_image.size.width, source_image.size.height);
    
    CGFloat tempHeight = newSize.height / size.height;
    CGFloat tempWidth = newSize.width / size.width;
    
    if (tempWidth > 1.0 && tempWidth > tempHeight) {
        newSize = CGSizeMake(source_image.size.width / tempWidth, source_image.size.height / tempWidth);
    }
    else if (tempHeight > 1.0 && tempWidth < tempHeight){
        newSize = CGSizeMake(source_image.size.width / tempHeight, source_image.size.height / tempHeight);
    }
    
    UIGraphicsBeginImageContext(newSize);
    [source_image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark 二分法
- (NSData *)halfFuntion:(NSArray *)arr image:(UIImage *)image sourceData:(NSData *)finallImageData maxSize:(NSInteger)maxSize {
    NSData *tempData = [NSData data];
    NSUInteger start = 0;
    NSUInteger end = arr.count - 1;
    NSUInteger index = 0;
    
    NSUInteger difference = NSIntegerMax;
    while(start <= end) {
        index = start + (end - start)/2;
        
        finallImageData = UIImageJPEGRepresentation(image,[arr[index] floatValue]);
        
        NSUInteger sizeOrigin = finallImageData.length;
        NSUInteger sizeOriginKB = sizeOrigin / 1024;
//        NSLog(@"当前降到的质量：%ld", (unsigned long)sizeOriginKB);
//        NSLog(@"\nstart：%zd\nend：%zd\nindex：%zd\n压缩系数：%lf", start, end, (unsigned long)index, [arr[index] floatValue]);
        
        if (sizeOriginKB > maxSize) {
            start = index + 1;
        } else if (sizeOriginKB < maxSize) {
            if (maxSize-sizeOriginKB < difference) {
                difference = maxSize-sizeOriginKB;
                tempData = finallImageData;
            }
            if (index<=0) {
                break;
            }
            end = index - 1;
        } else {
            break;
        }
    }
    return tempData;
}

@end
