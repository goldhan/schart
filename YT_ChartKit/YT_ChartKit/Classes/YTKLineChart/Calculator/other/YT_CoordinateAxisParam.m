//
//  YT_CoordinateAxisParam.m
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/18.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_CoordinateAxisParam.h"

#pragma mark - RangeExtend

BOOL YT_RangeContainLocation(NSRange range, NSUInteger loc)
{
    return (!(loc < range.location) && (loc - range.location) < range.length) ? YES : NO;
}

NSRange YT_RangeIntersectsRange(NSRange range1, NSRange range2)
{
    NSUInteger loc = MAX(range1.location, range2.location);
    NSUInteger max = MIN(range1.location + range1.length, range2.location + range2.length);
    NSUInteger len = max > loc ? max - loc : 0;
    return NSMakeRange(loc, len);
}

NSRange YT_RangeUnionRange(NSRange range1, NSRange range2)
{
    NSUInteger from = range1.location < range2.location ? range1.location : range2.location;
    NSUInteger to1 = range1.location + range1.length;
    NSUInteger to2 = range2.location + range2.length;
    NSUInteger to = to1 > to2 ? to1 : to2;
    return NSMakeRange(from, to - from);
}

NSRange YT_RangeUnionRange2(NSRange range1, NSRange range2)
{
    if (range1.length == 0) {
        return range2;
    }
    if (range2.length == 0) {
        return range1;
    }
    return YT_RangeUnionRange(range1, range2);
}

BOOL YT_RangeContainsRange(NSRange range1, NSRange range2)
{
    return  !((range1.location > range2.location) || (range1.location + range1.length < range2.location + range2.length));
//    return  ((range1.location <= range2.location) &&
//             (range1.location + range1.length >= range2.location + range2.length));
}

NSArray<NSValue *>* _Nullable YT_RangeSubRange(NSRange range1, NSRange range2)
{
    NSMutableArray<NSValue *> * arr_rs = [NSMutableArray array];
    NSRange rsRangePre = NSMakeRange(0, 0),rsRangeSuf  = NSMakeRange(0, 0);
    YT_RangeSubRange2(range1, range2, &rsRangePre, &rsRangeSuf);
    if (rsRangePre.length > 0) {
        [arr_rs addObject:[NSValue valueWithRange:rsRangePre]];
    }
    if (rsRangeSuf.length > 0) {
        [arr_rs addObject:[NSValue valueWithRange:rsRangeSuf]];
    }
    return [arr_rs copy];
}

/**
 NSRange range1 = NSMakeRange(22, 500), range2 = NSMakeRange(3332, 4444);
 NSRange rsRangePre = NSMakeRange(0, 0),rsRangeSuf  = NSMakeRange(0, 0);
 YT_RangeSubRange2(range1, range2, &rsRangePre, &rsRangeSuf);
 */
NSInteger YT_RangeSubRange2(NSRange range1, NSRange range2, NSRange *rsRangePre,NSRange *rsRangeSuf)
{
    NSUInteger max_range1 = range1.location + range1.length;
    NSUInteger max_range2 = range2.location + range2.length;
    if (max_range2 <= range1.location || range2.location >= max_range1) { //没有交集
        rsRangePre->location = range1.location;
        rsRangePre->length =  range1.length;
        return 1;
    }
    NSInteger rsCount = 0;
    if (range2.location > range1.location) {
        rsRangePre->location = range1.location;
        rsRangePre->length =  range2.location - range1.location;
        rsCount ++;
    }
    if (max_range1 > max_range2) {
        rsRangeSuf->location = max_range2;
        rsRangeSuf->length =  max_range1 - max_range2;
        rsCount ++;
    }
    return rsCount;
}

