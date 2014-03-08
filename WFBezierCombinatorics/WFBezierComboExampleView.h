//
//  WFBezierComboExampleView.h
//  WFBezierCombinatorics
//
//  Created by Noah Desch on 3/6/14.
//  Copyright (c) 2014 Wireframe Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface WFBezierComboExampleView : NSView

@property (nonatomic) NSBezierPath * pathA;
@property (nonatomic) NSBezierPath * pathB;
@property (nonatomic) NSBezierPath * trackingPath;
@property (nonatomic,assign) NSPoint trackingPoint;
@property (nonatomic,assign) NSInteger opTag;

- (IBAction)opChanged:(id)sender;

@end
