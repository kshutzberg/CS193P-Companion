//
//  ResultsView.m
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/1/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "BarGraphView.h"
#import <QuartzCore/QuartzCore.h>

#ifdef __APPLE__
#import "TargetConditionals.h"
#endif

#define LAYER_KEY @"layerKey"

@interface BarGraphView()
@property (readonly) CGFloat answerWidth;
@property (readonly) CGFloat answerSpacing;

@property (nonatomic) CGFloat yScale; //The height in points of 1 unit

@property (nonatomic, strong) NSMutableArray *answerShapes;
@property (nonatomic, strong) NSMutableArray *textLayers;
@property (nonatomic, strong) CAShapeLayer *correctShape;

- (void)setUpView;
- (CGPathRef)answerBarPathForValue:(NSUInteger)value atIndex:(NSUInteger)index;

- (void)drawBanner;
- (void)drawBannerText;

@property (nonatomic) CGRect textRect;

@end

static inline CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
static inline CGFloat RadiansToDegrees(CGFloat radians) {return radians * 180 / M_PI;};

static inline BOOL rectIsEqualToRect(CGRect rect1, CGRect rect2) { return rect1.origin.x == rect2.origin.x && rect1.origin.y == rect2.origin.y && rect1.size.width == rect2.size.width && rect1.size.height == rect2.size.height; };

@implementation BarGraphView
@synthesize delegate = _delegate;

@synthesize bannerText = _bannerText;

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

@synthesize textRect = _textRect;

- (void)setBannerText:(NSString *)bannerText
{
    if (![bannerText isEqualToString:_bannerText]) {
        _bannerText = bannerText;
    }
    
    if(!rectIsEqualToRect(self.textRect, CGRectZero))[self setNeedsDisplayInRect:self.textRect];
    else [self setNeedsDisplay];
}

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
        if(!maxAnswer)maxAnswer = 1; //We start it at one so we get reasonable results, and the transition from 0 to one is easy.
        
#define MAX_RELATIVE_HEIGHT .75
        
        _yScale = self.bounds.size.height*MAX_RELATIVE_HEIGHT/maxAnswer;
    }
    
    return _yScale;
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
    self.textRect = CGRectZero;
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
    self.layer.shouldRasterize = !TARGET_IPHONE_SIMULATOR;
}


- (CGPathRef)answerBarPathForValue:(NSUInteger)value atIndex:(NSUInteger)index{
    
    
    CGFloat xLoc = self.answerSpacing + index*(self.answerWidth + self.answerSpacing);
    CGFloat yLoc = self.bounds.size.height - value * self.yScale - self.bottomYOffset;
    CGFloat width = self.answerWidth;
    CGFloat height = value * self.yScale > 1 ? value * self.yScale : 1;
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
            
#define MAX_FONT 42 //Sorry if this seems arbitrary.  It was a quick (sloppy) fix for the case where you have one answer that I am implementing last minute.
            
            //Format the label
            label.fontSize = self.answerWidth/2; if(label.fontSize > MAX_FONT)label.fontSize = MAX_FONT;;
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

#pragma mark - Quartz Core Animation

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
            CGPathRef path = [self answerBarPathForValue:[[answers objectAtIndex:index] intValue] atIndex:index];
            if(startFromZero || !CGPathEqualToPath(path, shape.path))
            {
                shape.shouldRasterize = !TARGET_IPHONE_SIMULATOR; //Only rasterize layers on device, for demo purposes, let the macbook make everything look AWESOME
                
                CABasicAnimation *barAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
                barAnimation.duration = startFromZero ? 2.0 : 1.0;
                barAnimation.delegate = self;
                [barAnimation setValue:shape forKey:LAYER_KEY];
                
                if(startFromZero || !shape.path) barAnimation.fromValue = (id)[self answerBarPathForValue:0 atIndex:index];
                else barAnimation.fromValue = (id)shape.path;
                barAnimation.toValue = (__bridge id)path;
                
                [shape addAnimation:barAnimation forKey:@"animatePath"];
                
                [CATransaction begin];
                [CATransaction setDisableActions: YES];
                shape.path = path;
                [CATransaction commit];
            }
        }
    }
}

- (void)toggleText:(UITapGestureRecognizer *)recognizer
{
    static CGFloat maxOpacity;
    if(!maxOpacity && [[self.textLayers lastObject] opacity]){
        maxOpacity = [[self.textLayers lastObject] opacity];
    }
    
    CGFloat minOpacity = 0;
    
    for (CATextLayer *layer in self.textLayers) {
        layer.shouldRasterize = !TARGET_IPHONE_SIMULATOR;
        
        CABasicAnimation *textAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        textAnimation.duration = layer.opacity ? 0.6 : 0.3;
        textAnimation.delegate = self;
        [textAnimation setValue:layer forKey:LAYER_KEY];
        
        textAnimation.fromValue = [NSNumber numberWithFloat:layer.opacity ? maxOpacity : minOpacity];
        textAnimation.toValue = [NSNumber numberWithFloat:layer.opacity ? minOpacity : maxOpacity];
        
        [layer addAnimation:textAnimation forKey:@"animateOpacity"];
        
        [CATransaction begin];
        [CATransaction setDisableActions: YES];
        layer.opacity = layer.opacity ? minOpacity : maxOpacity;
        [CATransaction commit];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    CALayer *layer = [anim valueForKey:LAYER_KEY];
    layer.shouldRasterize = NO;
}



+ (BarGraphView *)resultsViewWithFrame:(CGRect)frame andAnswers:(NSArray *)answers
{
    BarGraphView *graphView = [[BarGraphView alloc] initWithFrame:frame];
    graphView.answers = answers;
    return graphView;
}


#pragma mark - Core Graphics Drawing

#define WIDTH       self.bounds.size.width
#define HEIGHT      self.bounds.size.height

#define DARK_COLOR  [UIColor colorWithRed:0.1 green:0.1 blue:0.25 alpha:0.5].CGColor
#define LIGHT_COLOR [UIColor colorWithWhite:0.7 alpha:.5].CGColor

- (void)drawLineAtHeight:(CGFloat)yLevel withColor:(CGColorRef)color
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    
#define EDGE_INSET      self.answerSpacing
#define CENTER_SPACING  30
    
#define LEFT_EDGE       EDGE_INSET
#define RIGHT_EDGE      ( WIDTH - EDGE_INSET )
#define INNER_LEFT      (WIDTH - CENTER_SPACING)/2
#define INNER_RIGHT     (WIDTH + CENTER_SPACING)/2
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, LEFT_EDGE, yLevel);
    CGContextAddLineToPoint(context, INNER_LEFT, yLevel);
    
    CGContextMoveToPoint(context, INNER_RIGHT, yLevel);
    CGContextAddLineToPoint(context, RIGHT_EDGE, yLevel);
    
    
#define LINE_WIDTH      2
    
    CGContextSetStrokeColorWithColor(context, color);
    CGContextSetLineWidth(context, LINE_WIDTH);
    CGContextStrokePath(context);
    
    UIGraphicsPopContext();
}

- (void)drawNumber:(NSInteger)number atHeight:(CGFloat)height withColor:(CGColorRef)color;
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    
    CGContextSetFillColorWithColor(context, color);
    
    NSString *numberString = [NSString stringWithFormat:@"%i",number];
    UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
    CGSize size = [numberString sizeWithFont:font];
    
    CGRect numberRect = CGRectMake((WIDTH - size.width)/2, height - size.height/2, size.width, size.height);
    CGRect leftRect = CGRectMake((EDGE_INSET - size.width)/2, height - size.height/2, size.width, size.height);
    CGRect rightRect = CGRectMake(WIDTH - (EDGE_INSET+ size.width)/2, height - size.height/2, size.width, size.height);
    
    [numberString drawInRect:numberRect withFont:font];
    [numberString drawInRect:leftRect withFont:font];
    [numberString drawInRect:rightRect withFont:font];
    
    UIGraphicsPopContext();
}

- (void)drawBanner
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    
#define BANNER_WIDTH        (WIDTH -  EDGE_INSET)
#define BANNER_HEIGHT       .6 * (1 - MAX_RELATIVE_HEIGHT) * HEIGHT
#define BANNER_FONT_SIZE    .8 * BANNER_HEIGHT
    
#define BANNER_LEFT         ( WIDTH - BANNER_WIDTH ) / 2.0
#define BANNER_TOP          ((HEIGHT * (1 - MAX_RELATIVE_HEIGHT)) - BANNER_HEIGHT) / 4
#define BANNER_RIGHT        ( BANNER_LEFT + BANNER_WIDTH )
#define BANNER_BOTTOM       ( BANNER_TOP + BANNER_HEIGHT )
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, BANNER_LEFT, BANNER_BOTTOM);
    CGContextAddLineToPoint(context, BANNER_LEFT, BANNER_TOP);
    CGContextAddLineToPoint(context, BANNER_RIGHT, BANNER_TOP);
    
    //Stroke LEFT and TOP - Dark
    CGContextSetLineWidth(context, 4);
    CGContextSetStrokeColorWithColor(context, DARK_COLOR);
    CGContextStrokePath(context);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, BANNER_LEFT, BANNER_BOTTOM); //Bottom Left
    CGContextAddLineToPoint(context, BANNER_RIGHT, BANNER_BOTTOM);              //Top Left
    CGContextAddLineToPoint(context, BANNER_RIGHT, BANNER_TOP); //Top Right
    
    //Stroke BOTTOM and RIGHT - LIGHT
    CGContextSetLineWidth(context, 4);
    CGContextSetStrokeColorWithColor(context, LIGHT_COLOR);
    CGContextStrokePath(context);
    
    [self drawBannerText];
    
    UIGraphicsPopContext();
}


- (void)drawBannerText
{
    CGContextRef context =  UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    
    //Get Text Dimensions
    UIFont *font = [UIFont fontWithName:@"GillSans-Bold" size:BANNER_FONT_SIZE];
    CGSize textSize = [self.bannerText sizeWithFont:font];
    
    CGFloat textLeft = BANNER_LEFT + (BANNER_WIDTH - textSize.width)/2;
    CGFloat textTop = BANNER_TOP + (BANNER_HEIGHT - textSize.height)/2;
    CGRect textRect = CGRectMake(textLeft, textTop, textSize.width, textSize.height);
    
    CGContextSetFillColorWithColor(context, DARK_COLOR);
    [self.bannerText drawInRect:textRect withFont:font];
    
    textTop  -= 2;
    textLeft -= 2;
    textRect = CGRectMake(textLeft, textTop, textSize.width, textSize.height);
    
    CGContextSetFillColorWithColor(context, LIGHT_COLOR);
    [self.bannerText drawInRect:textRect withFont:font];
    
    UIGraphicsPopContext();
}

-(void)drawRect:(CGRect)rect
{
    if (rectIsEqualToRect(rect, self.textRect)) {
        [self drawBannerText];
        return;
    }
    
    //Draw the lines and numbers
    if(self.showAxes){
        CGFloat yLevel = HEIGHT - self.bottomYOffset;
        NSInteger level = 0;
        
        //CGContextRef context = UIGraphicsGetCurrentContext();
        
        while (yLevel >= self.bounds.size.height * (1 - MAX_RELATIVE_HEIGHT) - self.bottomYOffset - 1)
        {
                    
            [self drawLineAtHeight:yLevel withColor:DARK_COLOR];
            [self drawLineAtHeight:yLevel + LINE_WIDTH withColor:LIGHT_COLOR];
            
            if(level && [self.answers count])[self drawNumber:level atHeight:yLevel withColor:DARK_COLOR];
            
            level++;
            yLevel -= self.yScale;
        }
    }
    
    if(self.bannerText)[self drawBanner];
    
}


@end
