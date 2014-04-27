//
//  NSBezierPath+WFBezierCombinatorics.h
//
//  Created by Noah Desch on 1/20/2014.
//  Copyright (c) 2014 Noah Desch.
//


#import <Cocoa/Cocoa.h>

/** WFBezierCombinatorics allows union, subtraction, and intersection operations to be performed on NSBezierPath objects.
 */
@interface NSBezierPath (WFBezierCombinatorics)

/** Returns a new NSBezierPath of the union of the receiver and path.
 @param path NSBezierPath to union with the receiver
 */
- (NSBezierPath *)WFUnionWithPath:(NSBezierPath *)path;

/** Returns a new NSBezierPath of the intersection of the receiver and path.
 @param path NSBezierPath to intersect with the receiver
 */
- (NSBezierPath *)WFIntersectWithPath:(NSBezierPath *)path;

/** Returns a new NSBezierPath with path subtracted from the receiver.
 @param path NSBezierPath to subtract from the receiver
 */
- (NSBezierPath *)WFSubtractPath:(NSBezierPath *)path;

@end
