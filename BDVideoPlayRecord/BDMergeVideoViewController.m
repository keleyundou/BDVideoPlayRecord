//
//  BDMergeVideoViewController.m
//  BDVideoPlayRecord
//
//  Created by 冰点 on 16/3/20.
//  Copyright © 2016年 冰点. All rights reserved.
//

#import "BDMergeVideoViewController.h"

@interface BDMergeVideoViewController () <
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    MPMediaPickerControllerDelegate
>

@end

@implementation BDMergeVideoViewController
@synthesize firstAsset, secondAsset, audioAsset;
@synthesize activityView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)loadAssetOne:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No Saved Album Found"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        isSeletingAssetOne = TRUE;
        [self startMediaBrowserFromViewController:self usingDelegate:self];
    }
}

- (IBAction)loadAssetTwo:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No Saved Album Found"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        isSeletingAssetOne = FALSE;
        [self startMediaBrowserFromViewController:self usingDelegate:self];
    }
}

- (IBAction)loadAudio:(id)sender {
    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAny];
    mediaPicker.delegate = self;
    mediaPicker.prompt = @"Select Audio";
    [self presentViewController:mediaPicker animated:YES completion:NULL];
}

- (IBAction)mergeAndSave:(id)sender {
    if (firstAsset != nil && secondAsset != nil) {
        [activityView startAnimating];
        // 1 - Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
        AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
        // 2 - Video track
        AVMutableCompositionTrack *firstTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, firstAsset.duration) ofTrack:[[firstAsset tracksWithMediaType:AVMediaTypeVideo] firstObject] atTime:kCMTimeZero error:nil];
//        [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, firstAsset.duration) ofTrack:[[secondAsset tracksWithMediaType:AVMediaTypeVideo] firstObject] atTime:firstAsset.duration error:nil];
        AVMutableCompositionTrack *secondTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [secondTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, secondAsset.duration) ofTrack:[[secondAsset tracksWithMediaType:AVMediaTypeVideo] firstObject] atTime:firstAsset.duration error:nil];
        
        // 3 - Audio track
        if (audioAsset != nil) {
            AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeAdd(firstAsset.duration, secondAsset.duration)) ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject] atTime:kCMTimeZero error:nil];
        }
        
        // 2.1 - Create AVMutableVideoCompositionInstruction
        AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeAdd(firstAsset.duration, secondAsset.duration));
        // 2.2 - Create an AVMutableVideoCompositionLayerInstruction for the first track
        AVMutableVideoCompositionLayerInstruction *firstlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:firstTrack];
        AVAssetTrack *firstAssetTrack = [[firstAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        UIImageOrientation firstAssetOrientation_ = UIImageOrientationUp;
        BOOL isFirstAssetPortrait_ = NO;
        CGAffineTransform firstTransform = firstAssetTrack.preferredTransform;
        if (firstTransform.a == 0 && firstTransform.b == 1.0 && firstTransform.c == -1.0 && firstTransform.d == 0) {
            firstAssetOrientation_ = UIImageOrientationRight;
            isFirstAssetPortrait_ = YES;
        }
        
        if (firstTransform.a == 0 && firstTransform.b == -1.0 && firstTransform.c == 1.0 && firstTransform.d == 0) {
            firstAssetOrientation_ = UIImageOrientationLeft;
            isFirstAssetPortrait_ = YES;
        }
        
        if (firstTransform.a == 1.0 && firstTransform.b == 0 && firstTransform.c == 0 && firstTransform.d == 1.0) {
            firstAssetOrientation_ = UIImageOrientationUp;
        }
        
        if (firstTransform.a == -1.0 && firstTransform.b == 0 && firstTransform.c == 0 && firstTransform.d == -1.0) {
            firstAssetOrientation_ = UIImageOrientationDown;
        }
        
        [firstlayerInstruction setTransform:firstAssetTrack.preferredTransform atTime:kCMTimeZero];
        [firstlayerInstruction setOpacity:0.0 atTime:firstAsset.duration];
        
        // 2.3 - Create an AVMutableVideoCompositionLayerInstruction for the second track
        AVMutableVideoCompositionLayerInstruction *secondlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:secondTrack];
        AVAssetTrack *secondAssetTrack = [[secondAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        UIImageOrientation secondAssetOrientation_ = UIImageOrientationUp;
        BOOL isSecondAssetPortrait_ = NO;
        CGAffineTransform secondTransform = secondAssetTrack.preferredTransform;
        if (secondTransform.a == 0 && secondTransform.b == 1.0 && secondTransform.c == -1.0 && secondTransform.d == 0) {
            secondAssetOrientation_ = UIImageOrientationRight;
            isSecondAssetPortrait_ = YES;
        }
        if (secondTransform.a == 0 && secondTransform.b == -1.0 && secondTransform.c == 1.0 && secondTransform.d == 0) {
            secondAssetOrientation_ = UIImageOrientationLeft;
            isSecondAssetPortrait_ = YES;
        }
        
        if (secondTransform.a == 1.0 && secondTransform.b == 0 && secondTransform.c == 0 && secondTransform.d == 1.0) {
            secondAssetOrientation_ = UIImageOrientationUp;
        }
        
        if (secondTransform.a == -1.0 && secondTransform.b == 0 && secondTransform.c == 0 && secondTransform.d == -1.0) {
            secondAssetOrientation_ = UIImageOrientationDown;
        }
        [secondlayerInstruction setTransform:secondAssetTrack.preferredTransform atTime:firstAsset.duration];
        
        // 2.4 - Add instructions
        mainInstruction.layerInstructions = @[firstlayerInstruction , secondlayerInstruction];
        AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
        mainCompositionInst.instructions = @[mainInstruction];
        mainCompositionInst.frameDuration = CMTimeMake(1, 30);
        
        CGSize naturalSizeFirst, naturalSizeSecond;
        if (isFirstAssetPortrait_) {
            naturalSizeFirst = CGSizeMake(firstAssetTrack.naturalSize.height, firstAssetTrack.naturalSize.width);
        } else {
            naturalSizeFirst = firstAssetTrack.naturalSize;
        }
        
        if (isSecondAssetPortrait_) {
            naturalSizeSecond = CGSizeMake(secondAssetTrack.naturalSize.height, secondAssetTrack.naturalSize.width);
        } else {
            naturalSizeSecond = secondAssetTrack.naturalSize;
        }
        
        float renderWidth, renderHeight;
        renderWidth = MAX(naturalSizeFirst.width, naturalSizeSecond.width);
        renderHeight = MAX(naturalSizeFirst.height, naturalSizeSecond.height);
        mainCompositionInst.renderSize = CGSizeMake(renderWidth, renderHeight);
        
        // 4 - Get path
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths firstObject];
        NSString *myPathDocs = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"mergeVideo-%d.mov", arc4random() % 1000]];
        NSURL *url = [NSURL fileURLWithPath:myPathDocs];
        // 5 - Create exporter
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
        exporter.videoComposition = mainCompositionInst;
        exporter.outputURL = url;
        exporter.outputFileType = AVFileTypeQuickTimeMovie;
        exporter.shouldOptimizeForNetworkUse = YES;
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self exportDidfinish:exporter];
            });
        }];
    }
}

- (BOOL)startMediaBrowserFromViewController:(UIViewController *)controller usingDelegate:(id)delegate
{
    // 1 - Validation
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO
        || (delegate == nil)
        || (controller == nil)) {
        return NO;
    }
    
    // 2 - Create image picker
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    mediaUI.mediaTypes = @[(NSString *)kUTTypeMovie];
    mediaUI.allowsEditing = YES;
    mediaUI.delegate = delegate;
    // 3 - Display image picker
    [controller presentViewController:mediaUI animated:YES completion:NULL];
    
    return YES;
}

- (void)exportDidfinish:(AVAssetExportSession *)session
{
    if (session.status == AVAssetExportSessionStatusCompleted) {
        NSURL *outputURL = session.outputURL;
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
            [library writeVideoAtPathToSavedPhotosAlbum:outputURL completionBlock:^(NSURL *assetURL, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"
                                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                    } else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album"
                                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                    }
                });
            }];
        }
    }
    
    firstAsset = nil;
    secondAsset = nil;
    audioAsset = nil;
    [activityView stopAnimating];
    
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    // 1 - Get media type
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    // 2 - Dismiss image picker
    [self dismissViewControllerAnimated:NO completion:NULL];
    // 3 - Handle video selection
    if (CFStringCompare((__bridge CFStringRef)mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        if (isSeletingAssetOne) {
            NSLog(@"Video One  Loaded");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Asset Loaded" message:@"Video One Loaded"
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            firstAsset = [AVAsset assetWithURL:[info objectForKey:UIImagePickerControllerMediaURL]];
        } else {
             NSLog(@"Video two Loaded");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Asset Loaded" message:@"Video Two Loaded"
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            secondAsset = [AVAsset assetWithURL:[info objectForKey:UIImagePickerControllerMediaURL]];
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - MPMediaPickerControllerDelegate
- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection;
{
    NSArray *selectedSong = [mediaItemCollection items];
    if ([selectedSong count]) {
        MPMediaItem *songItem = [selectedSong firstObject];
        NSURL *songURL = [songItem valueForProperty:MPMediaItemPropertyAssetURL];
        audioAsset = [AVAsset assetWithURL:songURL];
        NSLog(@"Audio Loaded");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Asset Loaded" message:@"Audio Loaded"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker;
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
