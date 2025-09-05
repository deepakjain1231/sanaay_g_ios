//  HourOnEarth
//
//  Created by Pradeep on 5/29/18.
//  Copyright © 2018 Pradeep. All rights reserved.
//

#import "HeartRateDetectionModel.h"
#import <AVFoundation/AVFoundation.h>

const int FRAMES_PER_SECOND = 30;
const int SECONDS = 30;

@interface HeartRateDetectionModel() <AVCaptureVideoDataOutputSampleBufferDelegate>

//@property (nonatomic, strong) AVCaptureSession *session;
//@property (nonatomic, strong) NSMutableArray *dataPointsHue;

@end

@implementation HeartRateDetectionModel

#pragma mark - Data collection

//- (void)startDetection
//{
//    self.dataPointsHue = [[NSMutableArray alloc] init];
//    self.session = [[AVCaptureSession alloc] init];
//    self.session.sessionPreset = AVCaptureSessionPresetLow;
//
//    // Retrieve the back camera
//    NSArray *devices = [AVCaptureDevice devices];
//    AVCaptureDevice *captureDevice;
//    for (AVCaptureDevice *device in devices)
//    {
//        if ([device hasMediaType:AVMediaTypeVideo])
//        {
//            if (device.position == AVCaptureDevicePositionBack)
//            {
//                captureDevice = device;
//                break;
//            }
//        }
//    }
//
//    NSError *error;
//    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:&error];
//    [self.session addInput:input];
//
//    if (error)
//    {
//        NSLog(@"%@", error);
//    }
//
//    // Find the max frame rate we can get from the given device
//    AVCaptureDeviceFormat *currentFormat;
//    for (AVCaptureDeviceFormat *format in captureDevice.formats)
//    {
//        NSArray *ranges = format.videoSupportedFrameRateRanges;
//        AVFrameRateRange *frameRates = ranges[0];
//
//        // Find the lowest resolution format at the frame rate we want.
//        if (frameRates.maxFrameRate == FRAMES_PER_SECOND && (!currentFormat || (CMVideoFormatDescriptionGetDimensions(format.formatDescription).width < CMVideoFormatDescriptionGetDimensions(currentFormat.formatDescription).width && CMVideoFormatDescriptionGetDimensions(format.formatDescription).height < CMVideoFormatDescriptionGetDimensions(currentFormat.formatDescription).height)))
//        {
//            currentFormat = format;
//        }
//    }
//
//    // Tell the device to use the max frame rate.
//    [captureDevice lockForConfiguration:nil];
//    captureDevice.torchMode=AVCaptureTorchModeOn;
//    captureDevice.activeFormat = currentFormat;
//    captureDevice.activeVideoMinFrameDuration = CMTimeMake(1, FRAMES_PER_SECOND);
//    captureDevice.activeVideoMaxFrameDuration = CMTimeMake(1, FRAMES_PER_SECOND);
//    [captureDevice unlockForConfiguration];
//
//    // Set the output
//    AVCaptureVideoDataOutput* videoOutput = [[AVCaptureVideoDataOutput alloc] init];
//
//    // create a queue to run the capture on
//    dispatch_queue_t captureQueue=dispatch_queue_create("catpureQueue", NULL);
//
//    // setup our delegate
//    [videoOutput setSampleBufferDelegate:self queue:captureQueue];
//
//    // configure the pixel format
//    videoOutput.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA], (id)kCVPixelBufferPixelFormatTypeKey,
//                                 nil];
//    videoOutput.alwaysDiscardsLateVideoFrames = NO;
//
//    //    [self.session addInput:input];
//    [self.session addOutput:videoOutput];
//
//    // Start the video session
//    [self.session startRunning];
//
//    if (self.delegate)
//    {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.delegate heartRateStart];
//        });
//    }
//}
//
//- (void)stopDetection
//{
//    [self.session stopRunning];
//
//    if (self.delegate)
//    {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.delegate heartRateEnd];
//        });
//    }
//}
//
//- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
//{
//    static int count=0;
//    count++;
//    // only run if we're not already processing an image
//    // this is the image buffer
//    CVImageBufferRef cvimgRef = CMSampleBufferGetImageBuffer(sampleBuffer);
//
//    // Lock the image buffer
//    CVPixelBufferLockBaseAddress(cvimgRef,0);
//
//    // access the data
//    NSInteger width = CVPixelBufferGetWidth(cvimgRef);
//    NSInteger height = CVPixelBufferGetHeight(cvimgRef);
//
//    // get the raw image bytes
//    uint8_t *buf=(uint8_t *) CVPixelBufferGetBaseAddress(cvimgRef);
//    size_t bprow=CVPixelBufferGetBytesPerRow(cvimgRef);
//    float r=0,g=0,b=0;
//
//    long widthScaleFactor = width/192;
//    long heightScaleFactor = height/144;
//
//    // Get the average rgb values for the entire image.
//    for(int y=0; y < height; y+=heightScaleFactor) {
//        for(int x=0; x < width*4; x+=(4*widthScaleFactor)) {
//            b+=buf[x];
//            g+=buf[x+1];
//            r+=buf[x+2];
//            // a+=buf[x+3];
//        }
//        buf+=bprow;
//    }
//    r/=255*(float) (width*height/widthScaleFactor/heightScaleFactor);
//    g/=255*(float) (width*height/widthScaleFactor/heightScaleFactor);
//    b/=255*(float) (width*height/widthScaleFactor/heightScaleFactor);
//
//    // The hue value is the most expressive when looking for heart beats.
//    // Here we convert our rgb values in hsv and continue with the h value.
//    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
//    CGFloat hue, sat, bright;
//    [color getHue:&hue saturation:&sat brightness:&bright alpha:nil];
//
//    [self.dataPointsHue addObject:@(hue)];
//
//    // Only send UI updates once a second
//    if (self.dataPointsHue.count % FRAMES_PER_SECOND == 0)
//    {
//        if (self.delegate)
//        {
//            float displaySeconds = self.dataPointsHue.count / FRAMES_PER_SECOND;
//
//            NSArray *bandpassFilteredItems = [self butterworthBandpassFilter:self.dataPointsHue];
//            NSArray *smoothedBandpassItems = [self medianSmoothing:bandpassFilteredItems];
//            int peakCount = [self peakCount:smoothedBandpassItems];
//
//            float secondsPassed = smoothedBandpassItems.count / FRAMES_PER_SECOND;
//            float percentage = secondsPassed / 60;
//            float heartRate = peakCount / percentage;
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.delegate heartRateUpdate:heartRate atTime:displaySeconds];
//            });
//        }
//    }
//
//    // If we have enough data points, start the analysis
//    if (self.dataPointsHue.count == (SECONDS * FRAMES_PER_SECOND))
//    {
//        [self stopDetection];
//    }
//
//    // Unlock the image buffer
//    CVPixelBufferUnlockBaseAddress(cvimgRef,0);
//}

#pragma mark - Data processing

//- (NSArray *)butterworthBandpassFilter:(NSArray *)inputData
//{
////    const int NZEROS = 8;
////    const int NPOLES = 8;
////    static float xv[NZEROS+1], yv[NPOLES+1];
//    
//    // http://www-users.cs.york.ac.uk/~fisher/cgi-bin/mkfscript
//    // Butterworth Bandpass filter
//    // 4th order
//    // sample rate - varies between possible camera frequencies. Either 30, 60, 120, or 240 FPS
//    // corner1 freq. = 0.667 Hz (assuming a minimum heart rate of 40 bpm, 40 beats/60 seconds = 0.667 Hz)
//    // corner2 freq. = 4.167 Hz (assuming a maximum heart rate of 250 bpm, 250 beats/60 secods = 4.167 Hz)
//    // Bandpass filter was chosen because it removes frequency noise outside of our target range (both higher and lower)
////    double dGain = 1.232232910e+02;
////
//    NSMutableArray *outputData = [[NSMutableArray alloc] init];
////    for (NSNumber *number in inputData)
////    {
////        double input = number.doubleValue;
////
////        xv[0] = xv[1]; xv[1] = xv[2]; xv[2] = xv[3]; xv[3] = xv[4]; xv[4] = xv[5]; xv[5] = xv[6]; xv[6] = xv[7]; xv[7] = xv[8];
////        xv[8] = input / dGain;
////        yv[0] = yv[1]; yv[1] = yv[2]; yv[2] = yv[3]; yv[3] = yv[4]; yv[4] = yv[5]; yv[5] = yv[6]; yv[6] = yv[7]; yv[7] = yv[8];
////        yv[8] =   (xv[0] + xv[8]) - 4 * (xv[2] + xv[6]) + 6 * xv[4]
////        + ( -0.1397436053 * yv[0]) + (  1.2948188815 * yv[1])
////        + ( -5.4070037946 * yv[2]) + ( 13.2683981280 * yv[3])
////        + (-20.9442560520 * yv[4]) + ( 21.7932169160 * yv[5])
////        + (-14.5817197500 * yv[6]) + (  5.7161939252 * yv[7]);
////
////        [outputData addObject:@(yv[8])];
////    }
////
//    return outputData;
//}


// Find the peaks in our data - these are the heart beats.
// At a 30 Hz detection rate, assuming 250 max beats per minute, a peak can't be closer than 7 data points apart.
- (int)peakCount:(NSArray *)inputData
{
    if (inputData.count == 0)
    {
        return 0;
    }
    
    int count = 0;
    
    for (int i = 3; i < inputData.count - 3;)
    {
        if (inputData[i] > 0 &&
            [inputData[i] doubleValue] > [inputData[i-1] doubleValue] &&
            [inputData[i] doubleValue] > [inputData[i-2] doubleValue] &&
            [inputData[i] doubleValue] > [inputData[i-3] doubleValue] &&
            [inputData[i] doubleValue] >= [inputData[i+1] doubleValue] &&
            [inputData[i] doubleValue] >= [inputData[i+2] doubleValue] &&
            [inputData[i] doubleValue] >= [inputData[i+3] doubleValue]
            )
        {
            count = count + 1;
            i = i + 4;
        }
        else
        {
            i = i + 1;
        }
    }
    
    return count;
}

// Smoothed data helps remove outliers that may be caused by interference, finger movement or pressure changes.
// This will only help with small interference changes.
// This also helps keep the data more consistent.
- (NSArray *)medianSmoothing:(NSArray *)inputData
{
    NSMutableArray *newData = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < inputData.count; i++)
    {
        if (i == 0 ||
            i == 1 ||
            i == 2 ||
            i == inputData.count - 1 ||
            i == inputData.count - 2 ||
            i == inputData.count - 3)        {
            [newData addObject:inputData[i]];
        }
        else
        {
            NSArray *items = [@[
                                inputData[i-2],
                                inputData[i-1],
                                inputData[i],
                                inputData[i+1],
                                inputData[i+2],
                                ] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];
            
            [newData addObject:items[2]];
        }
    }
    
    return newData;
}



#pragma mark - Data processing

+ (NSArray *)butterworthBandpassFilter:(NSArray *)inputData
{
     const int NZEROS = 8;
        const int NPOLES = 8;
        static float xv[NZEROS+1], yv[NPOLES+1];
    //
    //     http://www-users.cs.york.ac.uk/~fisher/cgi-bin/mkfscript
    //     Butterworth Bandpass filter
    //     4th order
    //     sample rate - varies between possible camera frequencies. Either 30, 60, 120, or 240 FPS
    //     corner1 freq. = 0.5 Hz (assuming a minimum heart rate of 40 bpm, 40 beats/60 seconds = 0.667 Hz)
    //     corner2 freq. = 4.167 Hz (assuming a maximum heart rate of 250 bpm, 250 beats/60 secods = 4.167 Hz)
    //     Bandpass filter was chosen because it removes frequency noise outside of our target range (both higher and lower)
        double dGain = 1.054847856e+02;

        NSMutableArray *outputData = [[NSMutableArray alloc] init];
        for (NSNumber *number in inputData)
        {
            double input = number.doubleValue;

            xv[0] = xv[1]; xv[1] = xv[2]; xv[2] = xv[3]; xv[3] = xv[4]; xv[4] = xv[5]; xv[5] = xv[6]; xv[6] = xv[7]; xv[7] = xv[8];
            xv[8] = input / dGain;
            yv[0] = yv[1]; yv[1] = yv[2]; yv[2] = yv[3]; yv[3] = yv[4]; yv[4] = yv[5]; yv[5] = yv[6]; yv[6] = yv[7]; yv[7] = yv[8];
            yv[8] =   (xv[0] + xv[8]) - 4 * (xv[2] + xv[6]) + 6 * xv[4]
                         + ( -0.1265216073 * yv[0]) + (  1.2019524495 * yv[1])
                         + ( -5.1282619994 * yv[2]) + ( 12.8089065060 * yv[3])
                         + (-20.5121242060 * yv[4]) + ( 21.5863072910 * yv[5])
                         + (-14.5560573510 * yv[6]) + (  5.7257694286 * yv[7]);
            [outputData addObject:@(yv[8])];
        }

        return outputData;
   
    /***
    const int NZEROS = 8;
    const int NPOLES = 8;
    static float xv[NZEROS+1], yv[NPOLES+1];
//
//     http://www-users.cs.york.ac.uk/~fisher/cgi-bin/mkfscript
//     Butterworth Bandpass filter
//     4th order
//     sample rate - varies between possible camera frequencies. Either 30, 60, 120, or 240 FPS
//     corner1 freq. = 0.667 Hz (assuming a minimum heart rate of 40 bpm, 40 beats/60 seconds = 0.667 Hz)
//     corner2 freq. = 4.167 Hz (assuming a maximum heart rate of 250 bpm, 250 beats/60 secods = 4.167 Hz)
//     Bandpass filter was chosen because it removes frequency noise outside of our target range (both higher and lower)
    double dGain = 1.232232910e+02;

    NSMutableArray *outputData = [[NSMutableArray alloc] init];
    for (NSNumber *number in inputData)
    {
        double input = number.doubleValue;

        xv[0] = xv[1]; xv[1] = xv[2]; xv[2] = xv[3]; xv[3] = xv[4]; xv[4] = xv[5]; xv[5] = xv[6]; xv[6] = xv[7]; xv[7] = xv[8];
        xv[8] = input / dGain;
        yv[0] = yv[1]; yv[1] = yv[2]; yv[2] = yv[3]; yv[3] = yv[4]; yv[4] = yv[5]; yv[5] = yv[6]; yv[6] = yv[7]; yv[7] = yv[8];
        yv[8] =   (xv[0] + xv[8]) - 4 * (xv[2] + xv[6]) + 6 * xv[4]
        + ( -0.1397436053 * yv[0]) + (  1.2948188815 * yv[1])
        + ( -5.4070037946 * yv[2]) + ( 13.2683981280 * yv[3])
        + (-20.9442560520 * yv[4]) + ( 21.7932169160 * yv[5])
        + (-14.5817197500 * yv[6]) + (  5.7161939252 * yv[7]);

        [outputData addObject:@(yv[8])];
    }

    return outputData;
     
     ***/
    
    
    
    //Testing from other app
    
//    /* Digital filter designed by mkfilter/mkshape/gencode   A.J. Fisher
//     Command line: /www/usr/fisher/helpers/mkfilter -Bu -Bp -o 4 -a 7.0312500000e-02 9.8750000000e-02 -l */
//    //http://www-users.cs.york.ac.uk/~fisher/cgi-bin/mkfscript
//    //0.15, 7);
//    //ORDER 2
//    //Sample rate 15
//#define NZEROS 4
//#define NPOLES 4
//#define GAIN   1.212477282e+00
//
//    static float xv[NZEROS+1], yv[NPOLES+1];
//
//    NSMutableArray *outputData = [[NSMutableArray alloc] init];
//    for (NSNumber *number in inputData)
//    {
//        double input = number.doubleValue;
//
//        xv[0] = xv[1]; xv[1] = xv[2]; xv[2] = xv[3]; xv[3] = xv[4];
//        xv[4] = input / GAIN;
//        yv[0] = yv[1]; yv[1] = yv[2]; yv[2] = yv[3]; yv[3] = yv[4];
//        yv[4] =   (xv[0] + xv[4]) - 2 * xv[2]
//        + ( -0.6804533458 * yv[0]) + ( -0.1390357300 * yv[1])
//        + (  1.6005224139 * yv[2]) + (  0.2058476233 * yv[3]);
//        [outputData addObject:@(yv[4])];
//
//    }
//    return outputData;
    
//    /* Digital filter designed by mkfilter/mkshape/gencode   A.J. Fisher
//     Command line: /www/usr/fisher/helpers/mkfilter -Bu -Bp -o 4 -a 7.0312500000e-02 9.8750000000e-02 -l */
//    //http://www-users.cs.york.ac.uk/~fisher/cgi-bin/mkfscript
//    //0.3, 5);
//    //ORDER 2
//    //Sample rate 15
//#define NZEROS 4
//#define NPOLES 4
//#define GAIN   2.375073474e+00
//
//    static float xv[NZEROS+1], yv[NPOLES+1];
//
//    NSMutableArray *outputData = [[NSMutableArray alloc] init];
//    for (NSNumber *number in inputData)
//    {
//        double input = number.doubleValue;
//
//        xv[0] = xv[1]; xv[1] = xv[2]; xv[2] = xv[3]; xv[3] = xv[4];
//        xv[4] = input / GAIN;
//        yv[0] = yv[1]; yv[1] = yv[2]; yv[2] = yv[3]; yv[3] = yv[4];
//        yv[4] =   (xv[0] + xv[4]) - 2 * xv[2]
//        + ( -0.2107595217 * yv[0]) + ( -0.0383008701 * yv[1])
//        + ( -0.0095472005 * yv[2]) + (  1.2299659908 * yv[3]);
//        [outputData addObject:@(yv[4])];
//
//    }
//    return outputData;
    
//    /* Digital filter designed by mkfilter/mkshape/gencode   A.J. Fisher
//     Command line: /www/usr/fisher/helpers/mkfilter -Bu -Bp -o 4 -a 7.0312500000e-02 9.8750000000e-02 -l */
//    //http://www-users.cs.york.ac.uk/~fisher/cgi-bin/mkfscript
//    //2.25, 3.16);
//    //ORDER 2
//#define NZEROS 4
//#define NPOLES 4
//#define GAIN   3.519543016e+01
//
//    static float xv[NZEROS+1], yv[NPOLES+1];
//
//    NSMutableArray *outputData = [[NSMutableArray alloc] init];
//    for (NSNumber *number in inputData)
//    {
//        double input = number.doubleValue;
//
//        xv[0] = xv[1]; xv[1] = xv[2]; xv[2] = xv[3]; xv[3] = xv[4];
//        xv[4] = input / GAIN;
//        yv[0] = yv[1]; yv[1] = yv[2]; yv[2] = yv[3]; yv[3] = yv[4];
//        yv[4] =   (xv[0] + xv[4]) - 2 * xv[2]
//        + ( -0.5834623180 * yv[0]) + (  1.1382795987 * yv[1])
//        + ( -2.0388350929 * yv[2]) + (  1.4979184357 * yv[3]);
//        [outputData addObject:@(yv[4])];
//
//    }
//    return outputData;
    
//#define NZEROS 8
//#define NPOLES 8
//#define GAIN   1.962234260e+04
//
//    static float xv[NZEROS+1], yv[NPOLES+1];
//
//    NSMutableArray *outputData = [[NSMutableArray alloc] init];
//    for (NSNumber *number in inputData)
//    {
//        double input = number.doubleValue;
//
//        xv[0] = xv[1]; xv[1] = xv[2]; xv[2] = xv[3]; xv[3] = xv[4]; xv[4] = xv[5]; xv[5] = xv[6]; xv[6] = xv[7]; xv[7] = xv[8];
//            xv[8] = input / GAIN;
//            yv[0] = yv[1]; yv[1] = yv[2]; yv[2] = yv[3]; yv[3] = yv[4]; yv[4] = yv[5]; yv[5] = yv[6]; yv[6] = yv[7]; yv[7] = yv[8];
//            yv[8] =   (xv[0] + xv[8]) - 4 * (xv[2] + xv[6]) + 6 * xv[4]
//            + ( -0.6264800768 * yv[0]) + (  4.5917607116 * yv[1])
//            + (-15.4331312720 * yv[2]) + ( 30.8854724760 * yv[3])
//            + (-40.1605878340 * yv[4]) + ( 34.7178799290 * yv[5])
//            + (-19.5006145550 * yv[6]) + (  6.5215795768 * yv[7]);
//          //  next output value = yv[8];
//            [outputData addObject:@(yv[8])];
//
//        }
//    return outputData;
}

+ (NSArray *)butterworthBandpassFilterResp:(NSArray *)inputData  sample:(int)sampleFrequency
    {
        /* Digital filter designed by mkfilter/mkshape/gencode   A.J. Fisher
         Command line: /www/usr/fisher/helpers/mkfilter -Bu -Bp -o 4 -a 7.0312500000e-02 9.8750000000e-02 -l */
#define NZEROS1 4
#define NPOLES1 4

        NSMutableArray *outputData = [[NSMutableArray alloc] init];
        static float xv[NZEROS1+1], yv[NPOLES1+1];

        if (sampleFrequency == 11) {
#define GAIN1   1.528668981e+02
            
            for (NSNumber *number in inputData)
            {
                double input = number.doubleValue;
                
                xv[0] = xv[1]; xv[1] = xv[2]; xv[2] = xv[3]; xv[3] = xv[4];
                xv[4] = input/ GAIN1;
                yv[0] = yv[1]; yv[1] = yv[2]; yv[2] = yv[3]; yv[3] = yv[4];
                yv[4] =   (xv[0] + xv[4]) - 2 * xv[2]
                + ( -0.7847941626 * yv[0]) + (  3.2739618138 * yv[1])
                + ( -5.1874640559 * yv[2]) + (  3.6973539066 * yv[3]);
                [outputData addObject:@(yv[4])];
            }
        } else if (sampleFrequency == 12) {

#define GAIN12   1.802350164e+02
            
            for (NSNumber *number in inputData)
            {
                double input = number.doubleValue;
                
                xv[0] = xv[1]; xv[1] = xv[2]; xv[2] = xv[3]; xv[3] = xv[4];
                xv[4] = input / GAIN12;
                yv[0] = yv[1]; yv[1] = yv[2]; yv[2] = yv[3]; yv[3] = yv[4];
                yv[4] =   (xv[0] + xv[4]) - 2 * xv[2]
                + ( -0.8008026467 * yv[0]) + (  3.3339120271 * yv[1])
                + ( -5.2606285274 * yv[2]) + (  3.7268468645 * yv[3]);
                [outputData addObject:@(yv[4])];
            }
        } else if (sampleFrequency == 13) {
#define GAIN13   2.098518524e+02

            for (NSNumber *number in inputData)
            {

                double input = number.doubleValue;
                
                xv[0] = xv[1]; xv[1] = xv[2]; xv[2] = xv[3]; xv[3] = xv[4];
                xv[4] = input/ GAIN13;
                yv[0] = yv[1]; yv[1] = yv[2]; yv[2] = yv[3]; yv[3] = yv[4];
                yv[4] =   (xv[0] + xv[4]) - 2 * xv[2]
                + ( -0.8146034420 * yv[0]) + (  3.3847750299 * yv[1])
                + ( -5.3219020237 * yv[2]) + (  3.7512381186 * yv[3]);
                [outputData addObject:@(yv[4])];
            }
        } else if (sampleFrequency == 14) {
#define GAIN14   2.417175112e+02

            for (NSNumber *number in inputData)
            {
                double input = number.doubleValue;
                xv[0] = xv[1]; xv[1] = xv[2]; xv[2] = xv[3]; xv[3] = xv[4];
                xv[4] = input / GAIN14;
                yv[0] = yv[1]; yv[1] = yv[2]; yv[2] = yv[3]; yv[3] = yv[4];
                yv[4] =   (xv[0] + xv[4]) - 2 * xv[2]
                + ( -0.8266220533 * yv[0]) + (  3.4284612900 * yv[1])
                + ( -5.3739335485 * yv[2]) + (  3.7717255794 * yv[3]);
            }
        } else {
#define GAIN15   2.758320703e+02

            for (NSNumber *number in inputData)
            {
                double input = number.doubleValue;
                xv[0] = xv[1]; xv[1] = xv[2]; xv[2] = xv[3]; xv[3] = xv[4];
                xv[4] = input/ GAIN15;
                yv[0] = yv[1]; yv[1] = yv[2]; yv[2] = yv[3]; yv[3] = yv[4];
                yv[4] =   (xv[0] + xv[4]) - 2 * xv[2]
                + ( -0.8371816513 * yv[0]) + (  3.4663830666 * yv[1])
                + ( -5.4186463917 * yv[2]) + (  3.7891633752 * yv[3]);
                [outputData addObject:@(yv[4])];
            }
        }
                
        
        //order 2 ---- 0.07 -0.5
//#define NZEROS1 4
//#define NPOLES1 4
//#define GAIN1   5.196868559e+02
//
//        static float xv[NZEROS1+1], yv[NPOLES1+1];
//
//        NSMutableArray *outputData = [[NSMutableArray alloc] init];
//        for (NSNumber *number in inputData)
//        {
//            double input = number.doubleValue;
//
//            xv[0] = xv[1]; xv[1] = xv[2]; xv[2] = xv[3]; xv[3] = xv[4];
//            xv[4] = input / GAIN1;
//            yv[0] = yv[1]; yv[1] = yv[2]; yv[2] = yv[3]; yv[3] = yv[4];
//            yv[4] =   (xv[0] + xv[4]) - 2 * xv[2]
//            + ( -0.8804145223 * yv[0]) + (  3.6308322251 * yv[1])
//            + ( -5.6202394005 * yv[2]) + (  3.8698194836 * yv[3]);
//            [outputData addObject:@(yv[4])];
//        }
        
        
//#define NZEROS1 6
//#define NPOLES1 6
//#define GAIN1   2.591023776e+04
//
//        static float xv[NZEROS1+1], yv[NPOLES1+1];
//
//        NSMutableArray *outputData = [[NSMutableArray alloc] init];
//        for (NSNumber *number in inputData)
//        {
//            double input = number.doubleValue;
//
//            xv[0] = xv[1]; xv[1] = xv[2]; xv[2] = xv[3]; xv[3] = xv[4]; xv[4] = xv[5]; xv[5] = xv[6];
//            xv[6] = input / GAIN1;
//            yv[0] = yv[1]; yv[1] = yv[2]; yv[2] = yv[3]; yv[3] = yv[4]; yv[4] = yv[5]; yv[5] = yv[6];
//            yv[6] =   (xv[6] - xv[0]) + 3 * (xv[2] - xv[4])
//            + ( -0.8708743059 * yv[0]) + (  5.3423192629 * yv[1])
//            + (-13.6599235190 * yv[2]) + ( 18.6345831410 * yv[3])
//            + (-14.3043010560 * yv[4]) + (  5.8581964751 * yv[5]);
//            [outputData addObject:@(yv[6])];
//        }
        
        return outputData;
    }

+ (NSArray *)butterworthBandpassFilterRespOrder1:(NSArray *)inputData  sample:(int)sampleFrequency
{
    //,0.2,0.5
    //http://www-users.cs.york.ac.uk/~fisher/cgi-bin/mkfscript
    /* Digital filter designed by mkfilter/mkshape/gencode   A.J. Fisher
     Command line: /www/usr/fisher/helpers/mkfilter -Bu -Bp -o 4 -a 7.0312500000e-02 9.8750000000e-02 -l */
#define NZEROS11 2
#define NPOLES11 2
    
    NSMutableArray *outputData = [[NSMutableArray alloc] init];
    static float xv[NZEROS11+1], yv[NPOLES11+1];
    
    if (sampleFrequency == 11) {
#define GAIN11   1.236903287e+01
        
        for (NSNumber *number in inputData)
        {
            double input = number.doubleValue;
            xv[0] = xv[1]; xv[1] = xv[2];
            xv[2] = input / GAIN11;
            yv[0] = yv[1]; yv[1] = yv[2];
            yv[2] =   (xv[2] - xv[0])
            + ( -0.8418070516 * yv[0]) + (  1.8117690286 * yv[1]);
            [outputData addObject:@(yv[2])];
        }
    } else if (sampleFrequency == 12) {
        
#define GAIN122   1.340823300e+01
        
        for (NSNumber *number in inputData)
        {
            double input = number.doubleValue;
            xv[0] = xv[1]; xv[1] = xv[2];
            xv[2] = input / GAIN122;
            yv[0] = yv[1]; yv[1] = yv[2];
            yv[2] =   (xv[2] - xv[0])
            + ( -0.8540806855 * yv[0]) + (  1.8286711158 * yv[1]);
            [outputData addObject:@(yv[2])];
        }
    } else if (sampleFrequency == 13) {
#define GAIN133   1.444717314e+01
        
        for (NSNumber *number in inputData)
        {
            
            double input = number.doubleValue;
            xv[0] = xv[1]; xv[1] = xv[2];
            xv[2] = input / GAIN133;
            yv[0] = yv[1]; yv[1] = yv[2];
            yv[2] =   (xv[2] - xv[0])
            + ( -0.8645835448 * yv[0]) + (  1.8428094147 * yv[1]);
            [outputData addObject:@(yv[2])];
        }
    } else if (sampleFrequency == 14) {
#define GAIN144   1.548590817e+01
        
        for (NSNumber *number in inputData)
        {
            double input = number.doubleValue;
            xv[0] = xv[1]; xv[1] = xv[2];
            xv[2] = input / GAIN144;
            yv[0] = yv[1]; yv[1] = yv[2];
            yv[2] =   (xv[2] - xv[0])
            + ( -0.8736736892 * yv[0]) + (  1.8548070266 * yv[1]);
            [outputData addObject:@(yv[2])];
        }
    } else {
#define GAIN155   1.652447855e+01
        
        for (NSNumber *number in inputData)
        {
            double input = number.doubleValue;
            xv[0] = xv[1]; xv[1] = xv[2];
            xv[2] = input / GAIN155;
            yv[0] = yv[1]; yv[1] = yv[2];
            yv[2] =   (xv[2] - xv[0])
            + ( -0.8816185924 * yv[0]) + (  1.8651135902 * yv[1]);
            [outputData addObject:@(yv[2])];
        }
    }
    return outputData;
}

// Find the peaks in our data - these are the heart beats.
// At a 30 Hz detection rate, assuming 250 max beats per minute, a peak can't be closer than 7 data points apart.
+ (int)peakCount:(NSArray *)inputData
{
    if (inputData.count == 0)
    {
        return 0;
    }
    
    int count = 0;
    
    for (int i = 3; i < inputData.count - 3;)
    {
        //inputData[i] > 0 &&
        if (
            [inputData[i] doubleValue] > [inputData[i-1] doubleValue] &&
            [inputData[i] doubleValue] > [inputData[i-2] doubleValue] &&
            [inputData[i] doubleValue] > [inputData[i-3] doubleValue] &&
            [inputData[i] doubleValue] >= [inputData[i+1] doubleValue] &&
            [inputData[i] doubleValue] >= [inputData[i+2] doubleValue] &&
            [inputData[i] doubleValue] >= [inputData[i+3] doubleValue]
            )
        {
            count = count + 1;
            i = i + 4;
        }
        else
        {
            i = i + 1;
        }
    }
    
    return count;
}

// Smoothed data helps remove outliers that may be caused by interference, finger movement or pressure changes.
// This will only help with small interference changes.
// This also helps keep the data more consistent.
+ (NSArray *)medianSmoothing:(NSArray *)inputData
{
    NSMutableArray *newData = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < inputData.count; i++)
    {
        if (i == 0 ||
            i == 1 ||
            i == 2 ||
            i == inputData.count - 1 ||
            i == inputData.count - 2 ||
            i == inputData.count - 3)        {
            [newData addObject:inputData[i]];
        }
        else
        {
            NSArray *items = [@[
                                inputData[i-2],
                                inputData[i-1],
                                inputData[i],
                                inputData[i+1],
                                inputData[i+2],
                                ] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];
            
            [newData addObject:items[2]];
        }
    }
    
    return newData;
}

+ (float)getMeanHR :(NSArray *)inputData time:(float)time {
    //float displaySeconds = inputData.count / 32;
    
    NSArray *bandpassFilteredItems = inputData; //[self butterworthBandpassFilter:self.dataPointsHue];
    NSArray *smoothedBandpassItems = [self medianSmoothing:bandpassFilteredItems];
    int peakCount = [self peakCount:smoothedBandpassItems];
    NSLog(@"Peak counts %d", peakCount);
    NSLog(@"time  %f", time);

    float secondsPassed = smoothedBandpassItems.count / FRAMES_PER_SECOND;
    float percentage = secondsPassed/60.0; //secondsPassed / time;
    float heartRate = peakCount / percentage;
    return heartRate;
}

//FINGER DETECTION

+(BOOL)isFingerPlaced:(CMSampleBufferRef)sampleBuffer maxValue: (double) max {
    UIImage *image = [HeartRateDetectionModel imageFromSampleBuffer:sampleBuffer];
    UIColor *dominantColor = [HeartRateDetectionModel hrkAverageColorPrecise:image];// get the average color from the image
    CGFloat red , green , blue , alpha;
    [dominantColor getRed:&red green:&green blue:&blue alpha:&alpha];
    red = red*255.0;
    NSLog(@"%f", red);
    if (red < max) {
        return NO;
    }
    return YES;
}

+ (UIColor *)hrkAverageColorPrecise:(UIImage*)image
{
    CGImageRef rawImageRef = image.CGImage;
    
    // This function returns the raw pixel values
    CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider(rawImageRef));
    const UInt8 *rawPixelData = CFDataGetBytePtr(data);
    
    NSUInteger imageHeight = CGImageGetHeight(rawImageRef);
    NSUInteger imageWidth  = CGImageGetWidth(rawImageRef);
    NSUInteger bytesPerRow = CGImageGetBytesPerRow(rawImageRef);
    NSUInteger stride = CGImageGetBitsPerPixel(rawImageRef) / 8;
    
    // Here I sort the R,G,B, values and get the average over the whole image
    unsigned int red   = 0;
    unsigned int green = 0;
    unsigned int blue  = 0;
    
    for (int row = 0; row < imageHeight; row++) {
        const UInt8 *rowPtr = rawPixelData + bytesPerRow * row;
        for (int column = 0; column < imageWidth; column++) {
            red    += rowPtr[2];
            green  += rowPtr[1];
            blue   += rowPtr[0];
            rowPtr += stride;
            
        }
    }
    CFRelease(data);
    
    CGFloat f = 1.0f / (255.0f * imageWidth * imageHeight);
    return [UIColor colorWithRed:f*red  green:f*green blue:f*blue alpha:1];
}

// Create a UIImage from sample buffer data
+ (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast);
    
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return image;
}

@end










