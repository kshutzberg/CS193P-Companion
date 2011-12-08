//
//  ResultsView.m
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/1/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "BarGraphView.h"
#import <QuartzCore/QuartzCore.h>
#import "AxesDrawer.h"

@interface BarGraphView()
@property (readonly) CGFloat answerWidth;
@property (readonly) CGFloat answerSpacing;

@property (nonatomic) CGFloat yScale; //The height in points of 1 unit

@property (nonatomic, strong) NSMutableArray *answerShapes;
@property (nonatomic, strong) NSMutableArray *textLayers;
@property (nonatomic, strong) CAShapeLayer *correctShape;

- (void)setUpView;
- (CGPathRef)answerBarPathForValue:(NSUInteger)value atIndex:(NSUInteger)index;

@end

CGFloat DegreesToRadians(CGFloat degrees);      CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
CGFloat RadiansToDegrees(CGFloat radians);      CGFloat RadiansToDegrees(CGFloat radians) {return radians * 180 / M_PI;};

@implementation BarGraphView
@synthesize delegate = _delegate;

@synthesize answers = _answers;
@synthesize correctIndex = _correctIndex;

@synthesize answerColor = _answerColor;
@synthesize correctColor = _correctColor;

@synthesize shaddow = _shaddow;
@synthesize roundedCorners = _roundedCorners;
@synthesize showAxes = _showAxes;
@synthesize showValueLabels = _showValueLabels;

@synthesize bottomYOffset = _bottomYOffset;
@synthesize answerWidthFactor = _answerWidthFactor;

@synthesize yScale = _yScale;

@synthesize answerShapes = _answerShapes;
@synthesize correctShape = _correctShape;
@synthesize textLayers = _textLayers;


- (NSMutableArray *)answerShapes
{
    if(!_answerShapes){
        _answerShapes = [[NSMutableArray alloc] init];
    }
    return _answerShapes;
}

-(NSUInteger)numAnswers
{
    return [self.answers count];
}

-(CGFloat)answerWidth
{
    if(!self.numAnswers)return 0;
    CGFloat width = self.bounds.size.width / self.numAnswers;
    width *= self.answerWidthFactor;
    return width;
}

-(CGFloat)answerSpacing
{
    CGFloat totalSpace = self.bounds.size.width - self.numAnswers*self.answerWidth;
    CGFloat spacing = totalSpace/(self.numAnswers + 1.0);
    return spacing;
}

-(CGFloat)yScale
{
    if(!_yScale){
        //Set the yScale:
        NSUInteger maxAnswer = 0;
        for (NSNumber *answer in self.answers) {
            if([answer intValue] > maxAnswer)maxAnswer = [answer intValue];
        }
        
#define MAX_RELATIVE_HEIGHT .75
        
        _yScale = self.bounds.size.height*MAX_RELATIVE_HEIGHT/maxAnswer;
    }
    
    return _yScale;
}


- (void)toggleText:(UITapGestureRecognizer *)recognizer
{
    static CGFloat maxOpacity;
    if(!maxOpacity && [[self.textLayers lastObject] opacity]){
        maxOpacity = [[self.textLayers lastObject] opacity];
    }
    
    CGFloat minOpacity = 0;
    
    for (CATextLayer *layer in self.textLayers) {
        CABasicAnimation *textAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        textAnimation.duration = layer.opacity ? 1.0 : 0.3;
        textAnimation.fromValue = [NSNumber numberWithFloat:layer.opacity ? maxOpacity : minOpacity];
        textAnimation.toValue = [NSNumber numberWithFloat:layer.opacity ? minOpacity : maxOpacity];
        
        layer.opacity = layer.opacity ? minOpacity : maxOpacity;
        [layer addAnimation:textAnimation forKey:@"animateOpacity"];
    }
}

- (void)configureDefaultValues
{
    self.answerColor = [UIColor redColor];
    self.correctColor = [UIColor greenColor];
    self.correctIndex = NSNotFound;
    self.answerWidthFactor = 0.5;
    self.shaddow = NO;
    self.showAxes = NO;
    self.roundedCorners = NO;
    self.showValueLabels = NO;
}

- (void)configureGestureRecognizers
{
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] init];
    [tapGR addTarget:self action:@selector(toggleText:)];
    [self addGestureRecognizer:tapGR];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self configureDefaultValues];
        [self configureGestureRecognizers];
    }
    return self;
}
-(void)awakeFromNib
{
    [self configureDefaultValues];
    [self configureGestureRecognizers];
}

- (NSArray *)arrayWithZeros:(NSUInteger)numZeros
{
    NSArray *retVal = [NSArray array];
    for (int i = 0; i < numZeros ; i++) {
        retVal = [retVal arrayByAddingObject:[NSNumber numberWithInt:0]];
    }
    return retVal;
}

-(void)setAnswers:(NSArray *)answers animated:(BOOL)animated
{
    //NSArray *oldAnswers = self.answers;
    self.answers = answers;
    
    self.yScale = 0;
    BOOL startFromZero = NO;
    if([self.answerShapes count] != [answers count]){
        [self setUpView];
        startFromZero = YES;
    }
    
    if(animated){
        for (int index = 0; index < [answers count]; index++) {
            CAShapeLayer *shape = [self.answerShapes objectAtIndex:index];
            
            CABasicAnimation *barAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
            barAnimation.duration = startFromZero ? 2.0 : 1.0;
            barAnimation.removedOnCompletion = NO;
            barAnimation.fillMode = kCAFillModeForwards;
            //NSInteger oldValue = index < [oldAnswers count] ? [[oldAnswers objectAtIndex:index] intValue] : 0;
            if(startFromZero)
                barAnimation.fromValue = (id)[self answerBarPathForValue:0 atIndex:index];
            else
                barAnimation.fromValue = (id)shape.path; //[self answerBarPathForValue:oldValue atIndex:index];
            barAnimation.toValue = (id)[self answerBarPathForValue:[[answers objectAtIndex:index] intValue] atIndex:index];
            shape.path = (__bridge CGPathRef)barAnimation.toValue;
            [shape addAnimation:barAnimation forKey:@"animatePath"];
        }
    }
}

- (CGPathRef)answerBarPathForValue:(NSUInteger)value atIndex:(NSUInteger)index{
    
    
    CGFloat xLoc = self.answerSpacing + index*(self.answerWidth + self.answerSpacing);
    CGFloat yLoc = self.bounds.size.height - value * self.yScale - self.bottomYOffset;
    CGFloat width = self.answerWidth;
    CGFloat height = value ? value * self.yScale : 1;
    CGRect answerRect = CGRectMake(xLoc, yLoc, width, height);
    CGPathRef path = CGPathCreateWithRect(answerRect, NULL);
    
    if (!self.roundedCorners) {
        return path;
    }
    
#define CORNER_RADIUS self.answerWidth/2
    
    //Make the corners rounded:
    else{
    
    UIBezierPath* roundedRect = [UIBezierPath bezierPathWithRoundedRect:answerRect cornerRadius:CORNER_RADIUS];   
    
        return roundedRect.CGPath;
    }
}

-(void)setUpView
{
    
    //Clear the view:
    for (CAShapeLayer *layer in self.answerShapes) {
        [layer removeFromSuperlayer];
        self.correctShape = nil;
    }
    self.textLayers = [NSMutableArray array];
    
    //Setting it to zero will cause it to recalculate itself next time it is used.
    self.yScale = 0;
    
    //Draw the answers 
    
    for (NSUInteger index = 0; index < [self.answers count]; index++) {
        NSUInteger value = [[self.answers objectAtIndex:index] intValue];
        
        CAShapeLayer *answerBar = [CAShapeLayer layer];
        answerBar.cornerRadius = self.answerWidth/2;
        
        answerBar.path = [self answerBarPathForValue:value atIndex:index];
        answerBar.fillColor = self.answerColor.CGColor;
        answerBar.fillRule = kCAFillRuleNonZero;
        
        //Configure Shadow
        if(self.shaddow){
            answerBar.shadowColor = [UIColor blackColor].CGColor;
            answerBar.shadowOpacity = .6;
            answerBar.shadowOffset = CGSizeMake(self.answerWidth/5, self.answerWidth/10);
        }
        
        answerBar.opacity = .7;
        
        [self.answerShapes addObject:answerBar];
        
        if (index == self.correctIndex) {
            self.correctShape = answerBar;
            answerBar.fillColor = self.correctColor.CGColor;
        }
        
        CATextLayer *label;
        if(self.showValueLabels && [self.delegate respondsToSelector:@selector(descriptionForAnswerAtIndex:)]){
            label = [[CATextLayer alloc] init];
            
            //Get the string from the delegate
            label.string = [self.delegate descriptionForAnswerAtIndex:index];
            
            //Format the label
            label.fontSize = self.answerWidth/2;
            label.truncationMode = kCATruncationEnd;
            label.foregroundColor = [UIColor whiteColor].CGColor;
            label.shadowColor = answerBar.shadowColor;
            label.shadowOpacity = .1;
            label.shadowOffset = answerBar.shadowOffset;
            
            //Size and potition
            label.frame = CGRectMake(0, 0,self.bounds.size.height * MAX_RELATIVE_HEIGHT - answerBar.cornerRadius, label.fontSize);
            label.anchorPoint = CGPointMake(0, .5);
            label.position = CGPointMake(- self.answerWidth/2 + (index + 1)*(self.answerWidth + self.answerSpacing), self.bounds.size.height - self.bottomYOffset - CORNER_RADIUS);
            label.affineTransform = CGAffineTransformMakeRotation(DegreesToRadians(-90));
            
            label.contentsScale = [[UIScreen mainScreen] scale];
            [self.textLayers addObject:label];
        }
        
        [self.layer addSublayer:answerBar];
        if(label)[self.layer addSublayer:label];
    }
    
}

+ (BarGraphView *)resultsViewWithFrame:(CGRect)frame andAnswers:(NSArray *)answers
{
    BarGraphView *graphView = [[BarGraphView alloc] initWithFrame:frame];
    graphView.answers = answers;
    return graphView;
}


-(void)drawRect:(CGRect)rect
{
    if(self.showAxes && [self.answers count]){
        CGPoint origin = CGPointMake(self.answerSpacing * .25, self.bounds.size.height - self.bottomYOffset);
        [AxesDrawer drawAxesInRect:rect originAtPoint:origin scale:self.yScale];
    }
}

@end
