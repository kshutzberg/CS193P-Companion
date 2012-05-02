//
//  ResultsView.h
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/1/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BarGraphView;

@protocol BarGraphViewDelegate <NSObject>

@optional
- (NSString *)descriptionForAnswerAtIndex:(NSInteger)index;

@end


@interface BarGraphView : UIView

@property (nonatomic, weak) id<BarGraphViewDelegate> delegate;

@property (nonatomic, copy) NSString *bannerText; //Leaving this emtpy will not display a banner

@property (nonatomic, strong) NSArray *answers; //An array of NSNumber integers
@property (nonatomic) NSUInteger correctIndex; //The index in the array of the correct answer

@property (nonatomic, strong) UIColor *answerColor;     //Default value: RED
@property (nonatomic, strong) UIColor *correctColor;    //Default value: GREEN

@property (nonatomic) BOOL shaddow;             //Default value: NO
@property (nonatomic) BOOL roundedCorners;      //Default value: NO
@property (nonatomic) BOOL showAxes;            //Default value: NO
@property (nonatomic) BOOL showValueLabels;     //Default value: NO

@property (nonatomic) CGFloat bottomYOffset;
@property (nonatomic) CGFloat answerWidthFactor; //A number from 0.0 to 1.0

@property (readonly) NSUInteger numAnswers;

- (void)setAnswers:(NSArray *)answers animated:(BOOL)animated;

+ (BarGraphView *)resultsViewWithFrame:(CGRect)frame andAnswers:(NSArray *)answers;

@end
