//
//  BDRecordVideoViewController.m
//  BDVideoPlayRecord
//
//  Created by 冰点 on 16/3/20.
//  Copyright © 2016年 冰点. All rights reserved.
//

#import "BDRecordVideoViewController.h"

#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface BDRecordVideoViewController ()

@end

@implementation BDRecordVideoViewController

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

- (IBAction)recordAndPlay:(id)sender {
    [self startCameraControllerFromViewController:self usingDelegate:self];
}

- (BOOL)startCameraControllerFromViewController:(UIViewController *)controller usingDelegate:(id)delegate
{
    // 1 - Validattions
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO
        || (delegate == nil)
        || (controller == nil)) {
        return NO;
    }
    // 2 - Get image picker
    UIImagePickerController *caremaUI = [[UIImagePickerController alloc] init];
    caremaUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    caremaUI.mediaTypes = @[(NSString *)kUTTypeMovie];
    caremaUI.allowsEditing = YES;
    caremaUI.delegate = delegate;
     // 3 - Display image picker
    [controller presentViewController:caremaUI animated:YES completion:NULL];
    return YES;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    [self dismissViewControllerAnimated:NO completion:NULL];
    // Handle a movie capture
    if (CFStringCompare((__bridge CFStringRef)mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        NSString *moviePath = (NSString *)[[info objectForKey:UIImagePickerControllerMediaURL] path];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(moviePath)) {
            UISaveVideoAtPathToSavedPhotosAlbum(moviePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album"
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}
@end
