//
//  ViewController.m
//  AudioExtract
//
//  Created by Kunliang Wu on 9/5/17.
//  Copyright © 2017 Kunliang Wu. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *srcPath=@"/Users/kunliang/blitzm/local_lab/AudioExtract/input/sample_SovereignHill.mov";
    NSString *dstPath=@"/Users/kunliang/blitzm/local_lab/AudioExtract/output/out.m4a";
    
    [self convertFromFilePath:srcPath toFilePath:dstPath];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)convertFromFilePath:(NSString*)srcPath toFilePath:(NSString*) dstPath {

    NSURL *dstURL = [NSURL fileURLWithPath:dstPath];
    NSURL *srcURL = [NSURL fileURLWithPath:srcPath];


    NSLog(@"Source Video File Path:%@",srcPath);
    NSLog(@"Destination Video File Path:%@",dstPath);

    //get hold of the source auidio track, if there exits only a single track
    AVAsset* srcAsset = [AVURLAsset URLAssetWithURL:srcURL options:nil];
    AVAssetTrack* srcTrack = [[srcAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];


    //the container holding vedio/audio data combo in the memory
    AVMutableComposition*   newAudioAsset = [AVMutableComposition composition];
    //the container holding audio data combo in the memory
    AVMutableCompositionTrack*  dstCompositionTrack = [newAudioAsset addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];


    CMTimeRange timeRange = srcTrack.timeRange;

    NSError*    error;
    //put a time (range) frame into the container in the memory holding the data of destination audio file

    if(NO == [dstCompositionTrack insertTimeRange:timeRange ofTrack:srcTrack atTime:kCMTimeZero error:&error]) {
        NSLog(@"track insert failed: %@\n", error);
        return;
    }


    //set up the config before we export to MP3
    AVAssetExportSession*  exportSesh = [[AVAssetExportSession alloc] initWithAsset:newAudioAsset presetName:AVAssetExportPresetPassthrough];

    exportSesh.outputFileType = AVFileTypeAppleM4A;
    exportSesh.outputURL = dstURL;

    //if the file is there, in order to repalce it, delete it first
    [[NSFileManager defaultManager] removeItemAtURL:dstURL error:nil];


    //and pour the data into the audio data combo container and show the results
    [exportSesh exportAsynchronouslyWithCompletionHandler:^{
        AVAssetExportSessionStatus  status = exportSesh.status;
        NSLog(@"exportAsynchronouslyWithCompletionHandler: %i\n", status);

        if(AVAssetExportSessionStatusFailed == status) {
            NSLog(@"FAILURE: %@\n", exportSesh.error);
        } else if(AVAssetExportSessionStatusCompleted == status) {
            NSLog(@"SUCCESS!\n");

        }
    }];

}






@end
