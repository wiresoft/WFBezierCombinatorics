//
//  WFBezierComboExampleView.m
//  WFBezierCombinatorics
//
//  Created by Noah Desch on 3/6/14.
//  Copyright (c) 2014 Noah Desch.
//

#import "WFBezierComboExampleView.h"
#import "NSBezierPath+WFBezierCombinatorics.h"

@implementation WFBezierComboExampleView


- (NSBezierPath *)pathA
{
	if ( !_pathA) {
		//_pathA = [NSBezierPath bezierPathWithRect:NSMakeRect(50.0, 50.0, 300.0, 300.0)];
		
		_pathA = [NSBezierPath bezierPathWithRect:NSMakeRect(50.0, 50.0, 300.0, 300.0)];
		[_pathA appendBezierPath:[[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(70.0, 70.0, 110.0, 110.0)] bezierPathByReversingPath]];
		[_pathA appendBezierPath:[[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(220.0, 220.0, 110.0, 110.0)] bezierPathByReversingPath]];
		[_pathA appendBezierPath:[[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(70.0, 220.0, 110.0, 110.0)] bezierPathByReversingPath]];
		[_pathA appendBezierPath:[[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(220.0, 70.0, 110.0, 110.0)] bezierPathByReversingPath]];
		
		//_pathA = [NSBezierPath bezierPathWithRect:NSMakeRect(100.0, 100.0, 100.0, 100.0)];
		//[_pathA appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(110.0, 110.0, 80.0, 80.0)] bezierPathByReversingPath]];
		
		/*
		_pathA = [NSBezierPath bezierPathWithRect:NSMakeRect(50.0, 50.0, 300.0, 300.0)];
		[_pathA appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(70.0, 70.0, 110.0, 110.0)] bezierPathByReversingPath]];
		[_pathA appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(220.0, 220.0, 110.0, 110.0)] bezierPathByReversingPath]];
		[_pathA appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(70.0, 220.0, 110.0, 110.0)] bezierPathByReversingPath]];
		[_pathA appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(220.0, 70.0, 110.0, 110.0)] bezierPathByReversingPath]];
		*/
		
		/*
		_pathA = [NSBezierPath bezierPath];
		[_pathA moveToPoint:NSMakePoint(492.697595,623.629134)];
		[_pathA curveToPoint:NSMakePoint(476.697595,607.629134) controlPoint1:NSMakePoint(483.861115,623.629134) controlPoint2:NSMakePoint(476.697595,616.465614)];
		[_pathA lineToPoint:NSMakePoint(476.697595,441.203937)];
		[_pathA curveToPoint:NSMakePoint(492.697595,425.203937) controlPoint1:NSMakePoint(476.697595,432.367457) controlPoint2:NSMakePoint(483.861115,425.203937)];
		[_pathA lineToPoint:NSMakePoint(879.285082,425.203937)];
		[_pathA curveToPoint:NSMakePoint(895.285082,441.203937) controlPoint1:NSMakePoint(888.121562,425.203937) controlPoint2:NSMakePoint(895.285082,432.367457)];
		[_pathA lineToPoint:NSMakePoint(895.285082,607.629134)];
		[_pathA curveToPoint:NSMakePoint(879.285082,623.629134) controlPoint1:NSMakePoint(895.285082,616.465614) controlPoint2:NSMakePoint(888.121562,623.629134)];
		[_pathA closePath];
		*/
		
		[_pathA setLineWidth:2.0];
	}
	return _pathA;
}

- (NSBezierPath *)pathB
{
	if ( !_pathB) {
		//_pathB = [NSBezierPath bezierPathWithRect:NSMakeRect(360.0, 50.0, 300.0, 300.0)];
		
		_pathB = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(280.0, 280.0, 300.0, 300.0)];
		[_pathB appendBezierPath:[[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(300.0, 300.0, 260.0, 260.0)] bezierPathByReversingPath]];
		[_pathB appendBezierPath:[NSBezierPath bezierPathWithRect:NSMakeRect(420.0, 320.0, 20.0, 220.0)]];
		
		/*
		_pathB = [NSBezierPath bezierPathWithRect:NSMakeRect(280.0, 280.0, 300.0, 300.0)];
		[_pathB appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(300.0, 300.0, 260.0, 260.0)] bezierPathByReversingPath]];
		[_pathB appendBezierPath:[NSBezierPath bezierPathWithRect:NSMakeRect(420.0, 320.0, 20.0, 220.0)]];
		*/
		
		/*
		NSAffineTransform* tfm = [NSAffineTransform transform];
		//[tfm translateXBy:330 yBy:-20];
		[tfm translateXBy:100 yBy:0];
		_pathB = [tfm transformBezierPath:[self pathA]];
		*/
		
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
 
	// "snap" mousepoint handling so that exact alignment of paths is easy to produce
	// Use these to hunt for edge cases by dragging shapes around.
	/*
	CGFloat rx, ry;
	rx = fmod( mousePoint.x, 10.0 );
	ry = fmod( mousePoint.y, 10.0 );
	mousePoint.x -= rx;
	mousePoint.y -= ry;
	*/
	
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
	
	// "snap" mousepoint handling so that exact alignment of paths is easy to produce
	// Use these to hunt for find edge by dragging shapes around.
	/*
	CGFloat rx, ry;
	rx = fmod( mousePoint.x, 10.0 );
	ry = fmod( mousePoint.y, 10.0 );
	mousePoint.x -= rx;
	mousePoint.y -= ry;
	*/
	
	NSAffineTransform * t = [[NSAffineTransform alloc] init];
	[t translateXBy:mousePoint.x - [self trackingPoint].x
				yBy:mousePoint.y - [self trackingPoint].y];
	[[self trackingPath] transformUsingAffineTransform:t];
	[self setNeedsDisplay:YES];
	
	[self setTrackingPoint:mousePoint];
}



@end
