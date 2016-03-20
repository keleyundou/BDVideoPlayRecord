//
//  BDPlayVideoViewController.m
//  BDVideoPlayRecord
//
//  Created by 冰点 on 16/3/20.
//  Copyright © 2016年 冰点. All rights reserved.
//

#import "BDPlayVideoViewController.h"

@interface BDPlayVideoViewController ()

@end

@implementation BDPlayVideoViewController

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

- (IBAction)playVideo:(id)sender {
    [self startMediaBrowserFromViewController:self usingDelegate:self];
}

- (BOOL)startMediaBrowserFromViewController:(UIViewController *)controller usingDelegate:(id)delegate
{
    // 1 - Validations
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO
        || (delegate == nil)
        || (controller == nil)) {
        return NO;
    }
    
    // 2 - Get image picker
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    mediaUI.mediaTypes = @[(NSString *)kUTTypeMovie];
    mediaUI.allowsEditing = YES;
    mediaUI.delegate = delegate;
    // 3 - Display image picker
    [controller presentViewController:mediaUI animated:YES completion:NULL];
    return YES;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    // 1 - Get media type
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    // 2 - Dismiss image picker
    [self dismissViewControllerAnimated:NO completion:NULL];
    // Handle a movie capture
    if (CFStringCompare((__bridge_retained CFStringRef)mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        // 3 - Play the video
        MPMoviePlayerViewController *theMovie = [[MPMoviePlayerViewController alloc]
                                                 initWithContentURL:[info objectForKey:UIImagePickerControllerMediaURL]];
//        [self presentMoviePlayerViewControllerAnimated:theMovie];
        [self presentViewController:theMovie animated:YES completion:NULL];
        // 4 - Register for the playback finished notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:theMovie];
    }
}

// For responding to the user tapping Cancel.
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// When the movie is done, release the controller.
- (void)myMovieFinishedCallback:(NSNotification *)aNotification
{
//    [self dismissMoviePlayerViewControllerAnimated];
    [self dismissViewControllerAnimated:YES completion:NULL];
    MPMoviePlayerController *theMovie = [aNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:theMovie];
}

@end
