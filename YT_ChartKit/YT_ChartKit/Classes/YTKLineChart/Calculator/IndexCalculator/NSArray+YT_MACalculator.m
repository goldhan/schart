//
//  NSArray+YT_MACalculator.m
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/18.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "NSArray+YT_MACalculator.h"
#import "YT_CoordinateAxisParam.h"
#import <objc/runtime.h>

@implementation NSArray (YT_MACalculator)

//#if defined(__YT_CALCALCULATeMAALL__) && __YT_CALCALCULATeMAALL__
- (YTSCFloat)calculateMA2:(NSUInteger)day index:(NSUInteger)index usingBlock:(YTSCFloat (NS_NOESCAPE ^)(id obj, NSUInteger idx))itemBlock {
    if (index >= self.count || day <= 0) {
        return YTSCFLOAT_NULL;
    }
    NSUInteger leng = MIN((index + 1), day);
    return  [self t_calculateSUMForm:index forthLeng:leng usingBlock:itemBlock];
}
//#else
- (YTSCFloat)calculateMA:(NSUInteger)day index:(NSUInteger)index usingBlock:(YTSCFloat (NS_NOESCAPE ^)(id obj, NSUInteger idx))itemBlock {
    //NSAssert(itemBlock, @" itemBlock 不能为空");
    if (index >= self.count || day < 1) {
        return YTSCFLOAT_NULL;
    }
    NSInteger minIndex = day - 1;
    if (index < minIndex) {
        return YTSCFLOAT_NULL;
    }
    return  [self t_calculateSUMForm:index - minIndex leng:day usingBlock:itemBlock]/day;
}
//#endif

- (void)calculateMA:(NSUInteger)day
              range:(NSRange)range
         usingBlock:(YTSCFloat (NS_NOESCAPE ^)(id obj, NSUInteger idx))itemBlock
           progress:(void (NS_NOESCAPE ^)(NSUInteger location, YTSCFloat maValue))progress
           complete:(nullable void (NS_NOESCAPE ^)(NSRange maValueRange, NSError * _Nullable error))complete {

    NSAssert(day > 0, @" day 不能小于1");

    NSRange canUseRange = [self canCalculateMARange:day];
    NSRange targetRange = YT_RangeIntersectsRange(canUseRange, range);
    
    if (targetRange.length == 0) {
        if(complete) complete(targetRange, [NSError errorWithDomain:@"没有可计算范围" code:0 userInfo:nil]);
        return;
    }
    
    NSInteger fromIndex = targetRange.location; // (NSInteger)(targetRange.location - (day - 1)); pre
    NSInteger toIndex =  fromIndex + targetRange.length;
    
    YTSCFloat sum = [self t_calculateSUMForm:fromIndex forthLeng:day usingBlock:itemBlock];
    progress(fromIndex,sum/day);
    
    for (NSUInteger i = fromIndex + 1 ; i < toIndex ; i++) {
        NSUInteger delIndex = i - day;
        sum = sum + (itemBlock ([self objectAtIndex:i], i)) - (itemBlock ([self objectAtIndex:delIndex], delIndex));
        progress(i,sum/day);
    }
    if(complete) complete(targetRange, nil);
}

- (void)calculateMA:(NSUInteger)day
              range:(NSRange)range
         usingGetterSel:(SEL)getter
           progress:(void (NS_NOESCAPE ^)(NSUInteger location, YTSCFloat maValue))progress
           complete:(nullable void (NS_NOESCAPE ^)(NSRange maValueRange, NSError * _Nullable error))complete {

    NSAssert(day > 0, @" day 不能小于1");
    
    NSRange canUseRange = [self canCalculateMARange:day];
    NSRange targetRange = YT_RangeIntersectsRange(canUseRange, range);
    
    if (targetRange.length == 0) {
        if(complete) complete(targetRange, [NSError errorWithDomain:@"没有可计算范围" code:0 userInfo:nil]);
        return;
    }
    
    NSInteger fromIndex = targetRange.location; // (NSInteger)(targetRange.location - (day - 1)); pre
    NSInteger toIndex =  fromIndex + targetRange.length;
    
    IMP imp = [self.firstObject methodForSelector:getter];
    YTSCFloat (*objGetter)(id obj, SEL getter) = (void *)imp;
    YTSCFloat (*objGetterSimple)(id obj) = (void *)imp;

    YTSCFloat sum = [self t_calculateSUMForm:fromIndex forthLeng:day usingMethod:objGetterSimple];
    progress(fromIndex,sum/day);
    
    for (NSUInteger i = fromIndex + 1 ; i < toIndex ; i++) {
        NSUInteger delIndex = i - day;
        sum = sum + (objGetter ([self objectAtIndex:i], getter)) - (objGetter ([self objectAtIndex:delIndex], getter));
        progress(i,sum/day);
    }
    if(complete) complete(targetRange, nil);
}

- (void)calculateMA:(NSUInteger)day
              range:(NSRange)range
            exclude:(NSRange)excludeRange
     usingGetterSel:(SEL)getter
           progress:(void (NS_NOESCAPE ^)(NSUInteger location, YTSCFloat maValue))progress
           complete:(nullable void (NS_NOESCAPE ^)(NSRange maValueRange, NSError * _Nullable error))complete {
    NSRange subRange1 = NSMakeRange(0, 0);
    NSRange subRange2 = NSMakeRange(0, 0);
    YT_RangeSubRange2(range, excludeRange, &subRange1, &subRange2);
    if (subRange1.length > 0) {
        [self calculateMA:day range:subRange1  usingGetterSel:getter progress:progress complete:complete];
    }
    if (subRange2.length > 0) {
        [self calculateMA:day range:subRange2  usingGetterSel:getter progress:progress complete:complete];
    }
}

- (void)calculateFullRangeMA:(NSUInteger)day
                       range:(NSRange)range
              usingGetterSel:(SEL)getter
           fullRangeProgress:(void (NS_NOESCAPE ^)(NSUInteger location, YTSCFloat maValue))progress {
    
    NSAssert(day > 0, @" day 不能小于1");

    NSRange canUseRange = [self canCalculateMARange:day];
    NSRange targetRange = YT_RangeIntersectsRange(NSMakeRange(0, self.count), range);
    
    NSInteger fromIndex = targetRange.location; // (NSInteger)(targetRange.location - (day - 1)); pre
    NSInteger toIndex =  fromIndex + targetRange.length;

    NSUInteger fenGenDian = canUseRange.location > toIndex ? toIndex : canUseRange.location;
    NSUInteger i = fromIndex;
    
    for (; i < fenGenDian ; i++) {
        progress(i,YTSCFLOAT_NULL);
    }
    
    if (i >= toIndex) return;
    
    IMP imp = [self.firstObject methodForSelector:getter];
    YTSCFloat (*objGetter)(id obj, SEL getter) = (void *)imp;
    YTSCFloat (*objGetterSimple)(id obj) = (void *)imp;
    
    YTSCFloat sum = [self t_calculateSUMForm:i forthLeng:day usingMethod:objGetterSimple];
    progress(i,sum/day);
    i++;
    
    for (; i < toIndex ; i++) {
        NSUInteger delIndex = i - day;
        sum = sum + (objGetter ([self objectAtIndex:i], getter)) - (objGetter ([self objectAtIndex:delIndex], getter));
        progress(i,sum/day);
    }
}

- (void)calculateFullRangeMA:(NSUInteger)day
                       range:(NSRange)range
              usingGetterSel:(SEL)getter
              usingSetterSel:(SEL)setter {
    
    NSAssert(day > 0, @" day 不能小于1");
    
    NSRange canUseRange = [self canCalculateMARange:day];
    NSRange targetRange = YT_RangeIntersectsRange(NSMakeRange(0, self.count), range);
    
    NSInteger fromIndex = targetRange.location; // (NSInteger)(targetRange.location - (day - 1)); pre
    NSInteger toIndex =  fromIndex + targetRange.length;
    
    NSUInteger fenGenDian = canUseRange.location > toIndex ? toIndex : canUseRange.location;
    NSUInteger i = fromIndex;
    
    IMP imp_set = [self.firstObject methodForSelector:setter];
    void (*objSetter)(id obj, SEL setter,YTSCFloat aFloat) = (void *)imp_set;
    
    for (; i < fenGenDian ; i++) {
        objSetter ([self objectAtIndex:i], setter, YTSCFLOAT_NULL);
    }
    
    if (i >= toIndex) return;
    
    IMP imp = [self.firstObject methodForSelector:getter];
    YTSCFloat (*objGetter)(id obj, SEL getter) = (void *)imp;
    YTSCFloat (*objGetterSimple)(id obj) = (void *)imp;
    
    YTSCFloat sum = [self t_calculateSUMForm:i forthLeng:day usingMethod:objGetterSimple];
    objSetter ([self objectAtIndex:i], setter, sum/day);
    i++;
    
    for (; i < toIndex ; i++) {
        NSUInteger delIndex = i - day;
        sum = sum + (objGetter ([self objectAtIndex:i], getter)) - (objGetter ([self objectAtIndex:delIndex], getter));
        objSetter ([self objectAtIndex:i], setter, sum/day);
    }
}


#pragma mark  tool

- (NSRange)canCalculateMARange:(NSUInteger)day {
    if (self.count < day || day < 1) return NSMakeRange(day - 1, 0);
    NSUInteger loc = day - 1;
    NSUInteger len = self.count - loc;// self.count > loc ? self.count - loc : 0;
    return NSMakeRange(loc, len);
}

/// 从 location 往后便利 length 长度 数据相加 为了性能没有任何健壮代码，所以调用的时候必须保证数据不会越界
- (YTSCFloat)t_calculateSUMForm:(NSUInteger)location leng:(NSUInteger)length usingBlock:(YTSCFloat (NS_NOESCAPE ^)(id obj, NSUInteger idx))itemBlock {
    
    NSUInteger max = location + length;
    YTSCFloat sum = 0.0;
    for (NSUInteger i = location; i < max; i ++) {
        sum += (itemBlock ([self objectAtIndex:i], i));
    }
    return sum;
}
- (YTSCFloat)t_calculateSUMForm:(NSUInteger)location leng:(NSUInteger)length usingMethod:(YTSCFloat (*)(id obj))objGetter {
    NSUInteger max = location + length;
    YTSCFloat sum = 0.0;
    for (NSUInteger i = location; i < max; i ++) {
        sum += (objGetter ([self objectAtIndex:i]));
    }
    return sum;
}

/// 从 location 往前便利 length 长度 数据相加 为了性能没有任何健壮代码，所以调用的时候必须保证数据不会越界
- (YTSCFloat)t_calculateSUMForm:(NSInteger)location forthLeng:(NSInteger)length usingBlock:(YTSCFloat (NS_NOESCAPE ^)(id obj, NSUInteger idx))itemBlock {
    
    NSInteger min = location - length; // -1 ==> NSInteger
    YTSCFloat sum = 0.0;
    for (NSInteger i = location; i > min ; i --) {
        sum += (itemBlock ([self objectAtIndex:i], i));
    }
    return sum;
}
- (YTSCFloat)t_calculateSUMForm:(NSInteger)location forthLeng:(NSInteger)length usingMethod:(YTSCFloat (*)(id obj))objGetter {
    NSInteger min = location - length; // -1 ==> NSInteger
    YTSCFloat sum = 0.0;
    for (NSInteger i = location; i > min ; i --) {
        sum += (objGetter ([self objectAtIndex:i]));
    }
    return sum;
}


@end

