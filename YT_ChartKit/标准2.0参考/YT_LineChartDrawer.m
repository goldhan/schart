//
//  YT_LineChartLayer.m
//  KDS_Phone
//
//  Created by yt_liyanshan on 2017/9/19.
//  Copyright © 2017年 kds. All rights reserved.
//

#import "YT_LineChartDrawer.h"
//NSString * const YT_LineChartLayerLineColor = @"color";
@implementation YT_LineChartLineConfig

-(void)configContext:(CGContextRef)ctx{
    if(self.strokColor)
        CGContextSetStrokeColorWithColor(ctx,self.strokColor.CGColor);
    if(self.strokWidth>0)
        CGContextSetLineWidth(ctx, self.strokWidth);
    //    CGContextSetLineCap(ctx, kCGLineCapButt);
}

@end;

@implementation YT_LineChartLine

-(YT_LineChartLineParseLineDataBlock)parseLineDataBlock{
    if (!_parseLineDataBlock) {
        __weak typeof (self) wself = self;
        [self setParseLineDataBlock:^NFloat *(YT_LineChartLine *line,NSInteger index) {
            return [wself.lineData objectAtIndex:index];
        }];
    }
    return _parseLineDataBlock;
}

+(YT_LineChartLine *)lineChartLineColor:(UIColor*)color drawStrategy:(YT_LineChartDrawStrategy)drawStrategy parseLineDataBlock:(YT_LineChartLineParseLineDataBlock)block{
    YT_LineChartLine * line = [[self alloc] init];
//    line.lineType = kLineChartLayerLineTypeLine;
    line.drawStrategy = drawStrategy;
    line.strokColor = color;
    [line setParseLineDataBlock:block];
    return line;
}

@end

@interface YT_LineChartDrawer ()
{
    CGFloat maxZf;
    NSInteger showCount;
    NSInteger useDataCount;    ///< nPos后的数据个数
   __weak YT_LineChartLine *   _drawing_line;//当前正在画的线
}
@end;

@implementation YT_LineChartDrawer

//#define  ArrIsEmpty(A) (#A == nil || [#A count] == 0)

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.strokWidth = 1.0;
        self.strokColor = [UIColor blackColor];
        _lines = [@[] mutableCopy];
        _xAxisWidth = CGFLOAT_MAX;
        _maxShowCount = -1;
        _dataCount =-1;
    }
    return self;
}

-(void)calculatePame{
    if ([NFloat compare:_maxValueOfTop :_minValueOfBottom] <= 0) {
        showCount = 0;
        return;
    }
    //计算需要绘制的点数
    useDataCount = 0;
    if (_dataCount<0) {
        NSArray<NFloat *> * lineData = self.lines.firstObject.lineData;
        if (lineData&&[lineData isKindOfClass:[NSArray class]]) {
            useDataCount = lineData.count - _nPos;
        }
    }else{
        useDataCount = _dataCount-_nPos;
    }

    showCount = _maxShowCount <0?floorf(self.drawRect.size.width/_xAxisWidth):_maxShowCount;
    showCount = MIN(useDataCount, showCount);
    
    //计算最大涨幅
    maxZf = [NFloat sub:_maxValueOfTop :_minValueOfBottom]->fValue;
}

-(void)drawInContext:(CGContextRef)ctx{
    if (showCount < 1) return;
    CGContextSaveGState(ctx);
    [self configContext:ctx];
    [self.lines enumerateObjectsUsingBlock:^(YT_LineChartLine * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        _drawing_line = obj;
        [obj configContext:ctx];
        switch (obj.lineType) {
            case kLineChartLayerLineTypeLine:
                [self _drawLineInContext:ctx];
                break;
            case kLineChartLayerLineTypeGird:
                [self _drawGridInContext:ctx];
                break;
                
            default:
                break;
        }
    }];

   CGContextRestoreGState(ctx);
}

-(void)_drawLineInContext:(CGContextRef)ctx{
    switch (_drawing_line.drawStrategy) {
        case kLineChartDrawStrategyDrawAll:
            [self _drawLineInContext:ctx offPos:0];
            break;
        case kLineChartDrawStrategyDrawAllFixZeroToNil:
            [self _drawLineInContextDrawAllFixZeroToNil:ctx offPos:0];
            break;
        case kLineChartDrawStrategyAutoFixZero:
            [self _drawLineInContextAutoFixZero:ctx offPos:0];
            break;
        case kLineChartDrawStrategyIgnoreZero:
             [self _drawLineInContextIgnoreZero:ctx offPos:0];
            break;
        case kLineChartDrawStrategyIgnorePreZero:
            [self _drawLineInContextIgnorePreZero:ctx offPos:0];
            break;
        default:
            break;
    }
  
    
}


/**
 绘制所有，不跳过点，当点不在绘制范围，重新确定起点
 */
-(void)_drawLineInContext:(CGContextRef)ctx offPos:(NSInteger)offPos{
    
    NSInteger i = offPos;
    CGRect rect = _drawRect;
    CGPoint lastPoint  = [self getPointShouldDraw:&i rect:rect];
    for (; i < showCount; i++) {
        CGPoint drawPoint = [self getPointAtXpos:i+_nPos];
        if ([self rect:rect containsPoint:drawPoint]) {
            CGContextBeginPath(ctx);
            CGContextMoveToPoint(ctx, lastPoint.x, lastPoint.y);
            CGContextAddLineToPoint(ctx, drawPoint.x, drawPoint.y);
            CGContextStrokePath(ctx);
             lastPoint = drawPoint;
        }else{
            [self _drawLineInContext:ctx offPos:i+1];
            break;
        }
    }
}

/**
 绘制所有，修正0为nil，nil为跳过点，当NFloat数据都为0并且0不在绘制范围认为它是跳过点==》
 画线不跳过最小值，并连接上个可画点和下个可画点
 */
-(void)_drawLineInContextDrawAllFixZeroToNil:(CGContextRef)ctx offPos:(NSInteger)offPos{
 
    NSInteger i = offPos;
    CGRect rect = _drawRect;
    BOOL suc = NO;
    rect.size.height +=1;//最小值点不能跳过，就算0是最小值点也不跳过

    CGPoint lastPoint  = [self getPointShouldDraw:&i rect:rect suc:&suc];
    if (suc ==NO) return;
    if (i!=offPos) { //尝试绘制之前的一个点前面部分要过渡
        [self _drawLineTestDrawPer:lastPoint :ctx];
    }
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, lastPoint.x, lastPoint.y);
    
    for (i+=1; i < showCount; i++) {
        CGPoint drawPoint = [self getPointShouldDraw:&i rect:rect suc:&suc];
        //        if(i<showCount)//最后要花，有下一个点要过渡
        if (suc) {
            CGContextAddLineToPoint(ctx, drawPoint.x, drawPoint.y);
            lastPoint = drawPoint;
        }
    }
    CGContextStrokePath(ctx);
    
}

-(void)_drawLineTestDrawPer:(CGPoint)lastPoint :(CGContextRef)ctx{
    if (_nPos>0) {
        BOOL suc;
        CGPoint  prePoint = [self getPrePointShouldDrawIgnoreZeroSuc:&suc];
        if (suc) {
            CGContextBeginPath(ctx);
            CGContextMoveToPoint(ctx, prePoint.x, prePoint.y);
            CGContextAddLineToPoint(ctx, lastPoint.x, lastPoint.y);
            CGContextStrokePath(ctx);
        }
    }
}

/**
 绘制所有，修正0为nil，nil为跳过点，当最小值点等于0时NFloat 数据都为0认为它是跳过点 ==》
 跳过最小值，并连接上个可画点和下个可画点
 */
-(void)_drawLineInContextAutoFixZero:(CGContextRef)ctx offPos:(NSInteger)offPos{
    if(self.minValueOfBottom->fValue ==0){
        [self _drawLineInContextIgnoreZero:ctx offPos:offPos];
    }else{
       [self _drawLineInContextDrawAllFixZeroToNil:ctx offPos:offPos];
    }
}


/**画线跳过最小值
 * prama offPos 偏移_nPos多少
 */
-(void)_drawLineInContextIgnoreZero:(CGContextRef)ctx offPos:(NSInteger)offPos{
    NSInteger i = offPos;
    CGRect rect = _drawRect;
    BOOL suc = NO;
    CGPoint lastPoint  = [self getPointShouldDraw:&i rect:rect suc:&suc];
    if (suc ==NO) return;
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, lastPoint.x, lastPoint.y);
    
    for (i+=1; i < showCount; i++) {
        CGPoint drawPoint = [self getPointShouldDraw:&i rect:rect suc:&suc];
        //        if(i<showCount)//最后要花，有下一个点要过渡
        if (suc) {
            CGContextAddLineToPoint(ctx, drawPoint.x, drawPoint.y);
            lastPoint = drawPoint;
        }
    }
    CGContextStrokePath(ctx);
}

/**画线跳过刚开始的0(0代指最小值)
 * prama offPos 偏移_nPos多少
 */
-(void)_drawLineInContextIgnorePreZero:(CGContextRef)ctx offPos:(NSInteger)offPos{
    NSInteger i = offPos;
    CGRect rect = _drawRect;
    CGPoint lastPoint  = [self getPointShouldDraw:&i rect:rect];
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, lastPoint.x, lastPoint.y);
    rect.size.height+=1;
    for (i+=1; i < showCount; i++) {
        CGPoint drawPoint = [self getPointShouldDraw:&i rect:rect];
//        if(i<showCount)
        CGContextAddLineToPoint(ctx, drawPoint.x, drawPoint.y);
        lastPoint = drawPoint;
    }
    CGContextStrokePath(ctx);
}


-(void)_drawGridInContext:(CGContextRef)ctx{
    CGFloat  zeroAxisY = [self getZeroAxisY];
    for (NSInteger i = 0; i < showCount; i++) {
        CGPoint drawPoint = [self getPointAtXpos:_nPos+i nullPoint:zeroAxisY];
        if (zeroAxisY > drawPoint.y) {
            CGContextSetStrokeColorWithColor(ctx,[UIColor ytColor_01].CGColor);
        } else {
            CGContextSetStrokeColorWithColor(ctx,[UIColor ytColor_02].CGColor);
        }
        CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx, drawPoint.x, zeroAxisY);
        CGContextAddLineToPoint(ctx, drawPoint.x, drawPoint.y);
        CGContextStrokePath(ctx);
    }
}

#pragma mark - tool

//pos>0
-(CGPoint)getPrePointShouldDrawIgnoreZeroSuc:(BOOL *)suc{
//    NFloat *floatData = _drawing_line.parseLineDataBlock(_drawing_line,_nPos);
//    if (!floatData||(floatData->fValue==0&&floatData->nUnit==0&&floatData->nDigit==0)) {
//    }
    NSInteger i=_nPos-1;
    *suc = NO;
    for (; i>=0; i--) {
        NFloat *floatData = _drawing_line.parseLineDataBlock(_drawing_line,i);
        if (!floatData||(floatData->fValue==0)) {//fValue    float    0
//            nDigit    Byte    '\x03'
//            nUnit    Byte    '\0'
        }else{
            *suc = YES;
            break;
        }
    }
    if (i>=0) {
        return [self getPointAtXpos:i];
    }
    return CGPointZero;
}

/**
 获取需要画的下一个点

 @param offPos 偏移_nPos多少  [self getPointAtXpos:*offPos+_nPos];
 @param rect rect判断取点应该画的区域
 */
-(CGPoint)getPointShouldDraw:(NSInteger *)offPos rect:(CGRect)rect{
    BOOL suc = NO;
    return  [self getPointShouldDraw:offPos rect:rect suc:&suc];
}

-(CGPoint)getPointShouldDraw:(NSInteger *)offPos rect:(CGRect)rect suc:(BOOL *)suc{
    CGPoint drawPoint = rect.origin;
     *suc = NO;
    for (; *offPos < useDataCount; *offPos +=1) {
        drawPoint = [self getPointAtXpos:*offPos+_nPos];
        if (CGRectContainsPoint(rect, drawPoint)) {
            *suc = YES;
            break;
        }
    }
    return drawPoint;
}

-(CGPoint)getPointAtXpos:(NSInteger)pos{
    return [self getPointAtXpos:pos nullPoint:CGRectGetMaxY(_drawRect)+100];
}

-(CGPoint)getPointAtXpos:(NSInteger)pos nullPoint:(CGFloat)nullPointyY{
    CGFloat oX = _drawRect.origin.x + _xAxisWidth/2 + _xAxisWidth * (pos -_nPos);//pos -_nPos 差值
    if (0.0f == maxZf)   return CGPointMake(oX, nullPointyY);
    NFloat *floatData = _drawing_line.parseLineDataBlock(_drawing_line,pos);
    if (!floatData)   return CGPointMake(oX, nullPointyY);//跳过点nil
    CGFloat oY = _drawRect.origin.y + ( 1.0 - [NFloat sub:floatData :_minValueOfBottom]->fValue / maxZf )*  _drawRect.size.height;
    return CGPointMake(oX, oY);
}


-(CGFloat)getZeroAxisY{
    CGFloat zeroAxisY;
    if (0.0f == maxZf) {
        zeroAxisY = 0;
    } else {
        zeroAxisY = _drawRect.origin.y + ( 1.0 - [NFloat sub:[NFloat zero] :_minValueOfBottom]->fValue / maxZf )*  _drawRect.size.height;
    }
    return zeroAxisY;
}

-(BOOL)rect:(CGRect)rect containsPoint:(CGPoint)point {
    if (point.x >= rect.origin.x
        && point.x <= rect.origin.x + rect.size.width
        && point.y >= rect.origin.y
        && point.y <= rect.origin.y + rect.size.height) {
        return  YES;
    }
    return  NO;
}

#ifdef DEBUG
-(void)dealloc{
    NSLog(@"完美谢幕%@",NSStringFromClass(self.class));
}
#endif
@end
