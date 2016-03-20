//
//  BDRecordVideoViewController.h
//  BDVideoPlayRecord
//
//  Created by 冰点 on 16/3/20.
//  Copyright © 2016年 冰点. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BDRecordVideoViewController : UIViewController<
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate
>
- (IBAction)recordAndPlay:(id)sender;

- (BOOL)startCameraControllerFromViewController:(UIViewController *)controller usingDelegate:(id)delegate;

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
@end
