//
//  BDMergeVideoViewController.h
//  BDVideoPlayRecord
//
//  Created by 冰点 on 16/3/20.
//  Copyright © 2016年 冰点. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>

@interface BDMergeVideoViewController : UIViewController {
    BOOL isSeletingAssetOne;
}

@property (nonatomic, strong) AVAsset *firstAsset;
@property (nonatomic, strong) AVAsset *secondAsset;
@property (nonatomic, strong) AVAsset *audioAsset;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityView;

- (IBAction)loadAssetOne:(id)sender;
- (IBAction)loadAssetTwo:(id)sender;
- (IBAction)loadAudio:(id)sender;
- (IBAction)mergeAndSave:(id)sender;

- (BOOL)startMediaBrowserFromViewController:(UIViewController *)controller usingDelegate:(id)delegate;
- (void)exportDidfinish:(AVAssetExportSession *)session;

@end
