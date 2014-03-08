//
//  WFBezierComboExampleView.m
//  WFBezierCombinatorics
//
//  Created by Noah Desch on 3/6/14.
//  Copyright (c) 2014 Wireframe Software. All rights reserved.
//

#import "WFBezierComboExampleView.h"
#import "NSBezierPath+WFBezierCombinatorics.h"

@implementation WFBezierComboExampleView


- (NSBezierPath *)pathA
{
	if ( !_pathA) {
		//_pathA = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(100.0, 100.0, 300.0, 300.0)];
		
		_pathA = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
		[_pathA appendBezierPath:[[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(10.0, 10.0, 80.0, 80.0)] bezierPathByReversingPath]];
		
		[_pathA setLineWidth:2.0];
	}
	return _pathA;
}

- (NSBezierPath *)pathB
{
	if ( !_pathB) {
		//_pathB = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(450.0, 450.0, 200.0, 200.0)];
		
		_pathB = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(152.0, 152.0, 100.0, 100.0)];
		[_pathB appendBezierPath:[[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(162.0, 162.0, 80.0, 80.0)] bezierPathByReversingPath]];
		
		[_pathB setLineWidth:2.0];
	}
	return _pathB;
}

- (IBAction)opChanged:(id)sender
{
	[self setOpTag:[[sender selectedCell] tag]];
	[self setNeedsDisplay:YES];
}


- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
	[[NSColor colorWithCalibratedWhite:0.6 alpha:1.0] set];
	[NSBezierPath fillRect:dirtyRect];
	
	// Draw the original paths
	[[NSColor colorWithCalibratedRed:1.0 green:0.0 blue:0.0 alpha:0.3] setStroke];
	[[NSColor colorWithCalibratedRed:0.0 green:1.0 blue:0.0 alpha:0.3] setFill];
	[[self pathA] fill];
	[[self pathA] stroke];
	
	[[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:1.0 alpha:0.3] setFill];
	[[self pathB] fill];
	[[self pathB] stroke];
	
	// Draw the combined result path
	NSBezierPath * result;
	switch ( [self opTag]) {
		case 0:
			result = [[self pathA] WFUnionWithPath:[self pathB]];
			break;
		case 1:
			result = [[self pathA] WFSubtractPath:[self pathB]];
			break;
		case 2:
			result = [[self pathA] WFIntersectWithPath:[self pathB]];
			break;
	}
	[result setLineWidth:4.0];
	[result setLineCapStyle:NSRoundLineCapStyle];
	[[NSColor colorWithCalibratedRed:1.0 green:0.0 blue:0.0 alpha:1.0] setStroke];
	[[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:1.0] setFill];
	[result fill];
	[result stroke];
}


- (void)mouseDown:(NSEvent *)theEvent
{
	NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	[self setTrackingPoint:mousePoint];
	
	if ( [[self pathA] containsPoint:mousePoint] ) {
		[self setTrackingPath:[self pathA]];
	} else if ( [[self pathB] containsPoint:mousePoint] ) {
		[self setTrackingPath:[self pathB]];
	}
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	if ( ![self trackingPath] ) return;
	NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	
	NSAffineTransform * t = [[NSAffineTransform alloc] init];
	[t translateXBy:mousePoint.x - [self trackingPoint].x
				yBy:mousePoint.y - [self trackingPoint].y];
	[[self trackingPath] transformUsingAffineTransform:t];
	[self setNeedsDisplay:YES];
	
	[self setTrackingPoint:mousePoint];
}

@end
