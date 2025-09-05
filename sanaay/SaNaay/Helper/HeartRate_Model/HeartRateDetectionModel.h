//  HourOnEarth
//
//  Created by Pradeep on 5/29/18.
//  Copyright © 2018 Pradeep. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

//@protocol HeartRateDetectionModelDelegate
//
//- (void)heartRateStart;
//- (void)heartRateUpdate:(int)bpm atTime:(int)seconds;
//- (void)heartRateEnd;
//
//@end

@interface HeartRateDetectionModel : NSObject

//@property (nonatomic, weak) id<HeartRateDetectionModelDelegate> delegate;

//- (void)startDetection;
//- (void)stopDetection;

+ (NSArray *)butterworthBandpassFilter:(NSArray *)inputData;
+ (int)peakCount:(NSArray *)inputData;
+ (NSArray *)medianSmoothing:(NSArray *)inputData;
+ (float)getMeanHR :(NSArray *)inputData time:(float)time;
+ (NSArray *)butterworthBandpassFilterResp:(NSArray *)inputData sample:(int)sampleFrequency;
+ (NSArray *)butterworthBandpassFilterRespOrder1:(NSArray *)inputData  sample:(int)sampleFrequency;


+ (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;
+ (UIColor *)hrkAverageColorPrecise:(UIImage*)image;
+(BOOL)isFingerPlaced:(CMSampleBufferRef)sampleBuffer maxValue: (double) max;

@end
