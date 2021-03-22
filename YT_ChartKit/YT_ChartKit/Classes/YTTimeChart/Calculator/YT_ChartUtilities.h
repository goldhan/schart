//
//  CoreGraphics_demo
//
//  Created by zhanghao on 2018/6/1.
//  Copyright © 2018年 snail-z. All rights reserved.
//

#import <UIKit/UIKit.h>

/* Peak value . */
struct CGPeakValue {
    CGFloat max;
    CGFloat min;
};
typedef struct CGPeakValue CGPeakValue;

/*** 定义内联函数 */

/* CGPeakValue */
CG_INLINE CGPeakValue
CGPeakValueMake(CGFloat max, CGFloat min) {
    CGPeakValue peak; peak.max = max; peak.min = min; return peak;
}
#define CGPeakValueZero CGPeakValueMake(0.f, 0.f)

CG_INLINE bool CGPeakEqualToPeak(CGPeakValue peak1, CGPeakValue peak2) {
    return peak1.max == peak2.max && peak1.min == peak2.min;
}

CG_INLINE CGFloat CGGetPeakDistanceValue(CGPeakValue peak) {
    return (CGFloat)fabs(peak.max - peak.min);
}

/** 判断浮点数是否为0 (两位浮点误差) */
CG_INLINE CGFloat CG_Float2fIsZero(CGFloat a) {
    CGFloat _EPSILON = 0.001; // 2位浮点误差
    return (fabs(a) < _EPSILON);
}

/////////////////////////////////////////////////////////////////

typedef CGFloat(^CG_AxisConvertBlock)(CGFloat value);

/** 纵轴换算 */
CG_INLINE CG_AxisConvertBlock CG_YaxisConvertBlock (CGPeakValue peak, CGRect rect) {
    CGFloat delta = peak.max - peak.min; delta = (delta != 0 ? delta : 1);
    return ^(CGFloat value) {
        // 容错处理
        if (value > peak.max) {
            value = peak.max;
        } else if (value < peak.min) {
            value = peak.min;
        }
        CGFloat proportion = fabs(peak.max - value) / delta;
        return rect.origin.y + rect.size.height * proportion;
    };
}

/////////////////////////////////////////////////////////////////

@interface NSValue (TQChart)

+ (NSValue *)valueWithPeakValue:(CGPeakValue)peakValue;
- (CGPeakValue)peakValue;

@end
