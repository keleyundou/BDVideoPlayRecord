//
//  BDPlayVideoViewController.h
//  BDVideoPlayRecord
//
//  Created by 冰点 on 16/3/20.
//  Copyright © 2016年 冰点. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MediaPlayer.h>

@interface BDPlayVideoViewController : UIViewController<
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate
>

- (IBAction)playVideo:(id)sender;

// For opening UIImagePickerController
- (BOOL)startMediaBrowserFromViewController:(UIViewController *)controller usingDelegate:(id)delegate;

@end
