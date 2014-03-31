//
//  WFBezierCombinatoricsTests.m
//  WFBezierCombinatoricsTests
//
//  Created by Noah Desch on 3/6/14.
//  Copyright (c) 2014 Noah Desch. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "WFGeometry.h"
#import "NSBezierPath+WFBezierCombinatorics.h"

@interface WFBezierCombinatoricsTests : XCTestCase

@end

@implementation WFBezierCombinatoricsTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#define WFBezierPointAcceptanceResolution (1.0E-6)

- (void)testBezierPathUnion
{
	NSBezierPath * a = [[NSBezierPath alloc] init];
	NSBezierPath * b = [[NSBezierPath alloc] init];
	NSBezierPath * result = nil;
	CGPoint points[3];
	NSBezierPathElement element;
	
	// Single path intersection in top-right corner
	a = [NSBezierPath bezierPathWithRect:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
	b = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(56.0, 52.0, 100.0, 100.0)];
	result = [a WFUnionWithPath:b];
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 52.359143)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(114.713969, 50.590803)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(130.063321, 55.352643)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(141.355339, 66.644661)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(160.881554, 86.170876)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(160.881554, 117.829124)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(141.355339, 137.355339)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(121.829124, 156.881554)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(90.170876, 156.881554)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(70.644661, 137.355339)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:6 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(60.372795, 127.083473)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(55.504497, 113.454260)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(56.039767, 100.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:7 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:8 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:9 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	
	// Single path intersection in bottom left corner
	b = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(-56.0, -53.0, 100.0, 100.0)];
	result = [b WFUnionWithPath:a];
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(29.355339, -38.355339)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(39.881789, -27.828889)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(44.733501, -13.776608)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(43.910475, -0.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 46.640857)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:6 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(-14.713969, 48.409197)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(-30.063321, 43.647357)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(-41.355339, 32.355339)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:7 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(-60.881554, 12.829124)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(-60.881554, -18.829124)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(-41.355339, -38.355339)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:8 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(-21.829124, -57.881554)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(9.829124, -57.881554)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(29.355339, -38.355339)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	
	// Dual path intersect
	[a appendBezierPath:[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(250.0, 250.0, 100.0, 100.0)]];
	[b appendBezierPath:[NSBezierPath bezierPathWithRect:NSMakeRect(200.0, 100.0, 100.0, 200.0)]];
	result = [a WFUnionWithPath:b];
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 46.640857)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(-14.713969, 48.409197)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(-30.063321, 43.647357)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(-41.355339, 32.355339)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(-60.881554, 12.829124)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(-60.881554, -18.829124)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(-41.355339, -38.355339)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:6 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(-21.829124, -57.881554)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(9.829124, -57.881554)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(29.355339, -38.355339)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:7 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(39.881789, -27.828889)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(44.733501, -13.776608)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(43.910475, -0.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:8 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:9 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(335.355339, 264.644661)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:10 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(354.881554, 284.170876)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(354.881554, 315.829124)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(335.355339, 335.355339)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:11 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(315.829124, 354.881554)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(284.170876, 354.881554)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(264.644661, 335.355339)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:12 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(254.881554, 325.592232)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(250.000000, 312.796116)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(250.000000, 300.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:13 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(200.0, 300.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:14 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(200.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:15 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(300.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:16 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(300.0, 250.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:17 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	element = [result elementAtIndex:18 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(200.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	
	// Tripple intersect
	a = [NSBezierPath bezierPathWithRect:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
	b = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(52.0, 62.0, 200.0, 100.0)];
	[a appendBezierPath:[NSBezierPath bezierPathWithRect:NSMakeRect(200.0, 100.0, 100.0, 200.0)]];
	[b appendBezierPath:[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(250.0, 250.0, 100.0, 100.0)]];
	result = [a WFUnionWithPath:b];
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 69.278146)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(138.494006, 57.543350)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(189.419065, 59.998854)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(222.710678, 76.644661)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(236.084849, 83.331746)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(244.878806, 91.441721)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(249.092551, 100.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(300.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:6 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(300.0, 250.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:7 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(312.796116, 250.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(325.592232, 254.881554)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(335.355339, 264.644661)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:8 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(354.881554, 284.170876)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(354.881554, 315.829124)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(335.355339, 335.355339)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:9 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(315.829124, 354.881554)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(284.170876, 354.881554)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(264.644661, 335.355339)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:10 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(254.881554, 325.592232)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(250.000000, 312.796116)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(250.000000, 300.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:11 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(200.0, 300.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:12 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(200.0, 155.878269)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:13 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(162.036434, 166.271692)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(113.440076, 163.430716)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(81.289322, 147.355339)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:14 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(55.611063, 134.516210)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(46.817105, 116.431800)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(54.907449, 100.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:15 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:16 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	
	// Single Paths with holes
	a = [NSBezierPath bezierPathWithRect:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
	[a appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(20.0, 20.0, 60.0, 60.0)] bezierPathByReversingPath]];
	b = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(32.0, 32.0, 100.0, 100.0)];
	[b appendBezierPath:[[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(52.0, 52.0, 60.0, 60.0)] bezierPathByReversingPath]];
	result = [a WFUnionWithPath:b];
	
	// Both paths curved
	a = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
	b = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(56.0, 52.0, 100.0, 100.0)];
	result = [a WFUnionWithPath:b];
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(85.355339, 14.644661)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(95.720325, 25.009647)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(100.583326, 38.793127)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(99.944343, 52.365864)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(114.675254, 50.578805)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(130.049082, 55.338404)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(141.355339, 66.644661)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(160.881554, 86.170876)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(160.881554, 117.829124)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(141.355339, 137.355339)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(121.829124, 156.881554)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(90.170876, 156.881554)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(70.644661, 137.355339)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(60.279675, 126.990353)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(55.416674, 113.206873)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(56.055657, 99.634136)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:6 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(41.324746, 101.421195)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(25.950918, 96.661596)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(14.644661, 85.355339)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:7 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(-4.881554, 65.829124)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(-4.881554, 34.170876)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(14.644661, 14.644661)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:8 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(34.170876, -4.881554)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(65.829124, -4.881554)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(85.355339, 14.644661)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	
	// Both paths curved intersected the other way
	result = [b WFUnionWithPath:a];
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(141.355339, 66.644661)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(160.881554, 86.170876)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(160.881554, 117.829124)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(141.355339, 137.355339)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(121.829124, 156.881554)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(90.170876, 156.881554)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(70.644661, 137.355339)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(60.279675, 126.990353)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(55.416674, 113.206873)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(56.055657, 99.634136)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake( 41.324746, 101.421195)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(25.950918, 96.661596)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(14.644661, 85.355339)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(-4.881554, 65.829124)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(-4.881554, 34.170876)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(14.644661, 14.644661)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:6 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(34.170876, -4.881554)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(65.829124, -4.881554)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(85.355339, 14.644661)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:7 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(95.720325, 25.009647)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(100.583326, 38.793127)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(99.944343, 52.365864)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:8 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(114.675254, 50.578805)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(130.049082, 55.338404)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(141.355339, 66.644661)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	
	// 2 curved paths with curved holes, union has 2 holes
	a = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
	b = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(-52.0, -62.0, 100.0, 100.0)];
	[a appendBezierPath:[[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(10.0, 10.0, 80.0, 80.0)] bezierPathByReversingPath]];
	[b appendBezierPath:[[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(-42.0, -52.0, 80.0, 80.0)] bezierPathByReversingPath]];
	result = [a WFUnionWithPath:b];
	
	// 2 curved paths with curved holes, union has 3 holes
	a = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
	b = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(-42.0, -52.0, 100.0, 100.0)];
	[a appendBezierPath:[[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(10.0, 10.0, 80.0, 80.0)] bezierPathByReversingPath]];
	[b appendBezierPath:[[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(-32.0, -42.0, 80.0, 80.0)] bezierPathByReversingPath]];
	result = [a WFUnionWithPath:b];
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
}


- (void)testBezierPathCornerToEdge
{
	NSBezierPathElement element;
	CGPoint points[3];
	NSBezierPath * a;
	NSBezierPath * b;
	NSBezierPath * result;
	
	// Corner to edge polygons
	a = [NSBezierPath bezierPathWithRect:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
	b = [[NSBezierPath alloc] init];
	[b moveToPoint:NSMakePoint(100.0, 120.0)];
	[b lineToPoint:NSMakePoint(0.0, 120.0)];
	[b lineToPoint:NSMakePoint(50.0, 100.0)];
	[b closePath];
	result = [a WFUnionWithPath:b];
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 120.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:6 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 120.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:7 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(50.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:8 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 120.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:9 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 120.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
}

- (void)testBezierCornerToCurve
{
	NSBezierPathElement element;
	CGPoint points[3];
	NSBezierPath * a;
	NSBezierPath * b;
	NSBezierPath * result;
	
	// Curve to edge polygons
	a = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
	b = [[NSBezierPath alloc] init];
	[b moveToPoint:NSMakePoint(100.0, 120.0)];
	[b lineToPoint:NSMakePoint(0.0, 120.0)];
	[b lineToPoint:NSMakePoint(50.0, 100.0)];
	[b closePath];
	result = [a WFUnionWithPath:b];
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(85.355339, 14.644661)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(104.881554, 34.170876)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(104.881554, 65.829124)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(85.355339, 85.355339)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(65.829124, 104.881554)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(34.170876, 104.881554)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(14.644661, 85.355339)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(-4.881554, 65.829124)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(-4.881554, 34.170876)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(14.644661, 14.644661)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSCurveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(34.170876, -4.881554)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(65.829124, -4.881554)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(85.355339, 14.644661)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 120.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	
	element = [result elementAtIndex:6 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 120.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	
	element = [result elementAtIndex:7 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(50.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	
	element = [result elementAtIndex:8 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 120.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	
	element = [result elementAtIndex:9 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 120.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
}

- (void)testBezierPathCornerToCorner
{
	NSBezierPathElement element;
	CGPoint points[3];
	NSBezierPath * a;
	NSBezierPath * b;
	NSBezierPath * result;
	
	// Corner to corner polygons
	a = [NSBezierPath bezierPathWithRect:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
	b = [NSBezierPath bezierPathWithRect:NSMakeRect(100.0, 100.0, 100.0, 100.0)];
	result = [a WFUnionWithPath:b];
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:6 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(200.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:7 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(200.0, 200.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:8 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 200.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:9 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
}

- (void)testBezierPathPartialEdgeToEdge
{
	NSBezierPathElement element;
	CGPoint points[3];
	NSBezierPath * a;
	NSBezierPath * b;
	NSBezierPath * result;
	
	// Partial edge to edge polygons
	a = [NSBezierPath bezierPathWithRect:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
	b = [NSBezierPath bezierPathWithRect:NSMakeRect(100.0, 80.0, 100.0, 100.0)];
	result = [a WFUnionWithPath:b];
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 80.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(200.0, 80.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(200.0, 180.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 180.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:6 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:7 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:8 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:9 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
}

- (void)testBezierPathPartialEdgeToEdgeSubtract
{
	NSBezierPathElement element;
	CGPoint points[3];
	NSBezierPath * a;
	NSBezierPath * b;
	NSBezierPath * result;
	
	// Partial edge to edge polygons
	a = [NSBezierPath bezierPathWithRect:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
	b = [NSBezierPath bezierPathWithRect:NSMakeRect(100.0, 80.0, 100.0, 100.0)];
	result = [a WFSubtractPath:b];
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 80.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:6 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
}


- (void)testBezierPathFullEdgeToEdge
{
	NSBezierPathElement element;
	CGPoint points[3];
	NSBezierPath * a;
	NSBezierPath * b;
	NSBezierPath * result;
	
	// Exactly coincident identical edges
	a = [NSBezierPath bezierPathWithRect:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
	b = [NSBezierPath bezierPathWithRect:NSMakeRect(100.0, 0.0, 100.0, 100.0)];
	result = [a WFUnionWithPath:b];
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( [result elementCount] == 8, @"Incorrect element count" );
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.000000, 0.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.000000, 0.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(200.000000, 0.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(200.000000, 100.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.000000, 100.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.000000, 100.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:6 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.000000, 0.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:7 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.000000, 0.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
}

- (void)testBezierPathFullEdgeToEdgeSubtract
{
	NSBezierPathElement element;
	CGPoint points[3];
	NSBezierPath * a;
	NSBezierPath * b;
	NSBezierPath * result;
	
	// Exactly coincident identical edges
	a = [NSBezierPath bezierPathWithRect:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
	b = [NSBezierPath bezierPathWithRect:NSMakeRect(100.0, 0.0, 100.0, 100.0)];
	result = [a WFSubtractPath:b];
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( [result elementCount] == 6, @"Result had too many elements" );
}


- (void)testBezierPathOverlappingParallelEdges
{
	NSBezierPathElement element;
	CGPoint points[3];
	NSBezierPath * a;
	NSBezierPath * b;
	NSBezierPath * result;
	
	// Overlapping parallel edges
	a = [NSBezierPath bezierPathWithRect:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
	b = [NSBezierPath bezierPathWithRect:NSMakeRect(50.0, 0.0, 100.0, 100.0)];
	
	// Union op
	result = [a WFUnionWithPath:b];
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(50.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(150.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(150.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:6 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(50.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:7 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:8 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:9 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
}

- (void)testBezierPathOverlappingParallelEdgesSubtract
{
	NSBezierPathElement element;
	CGPoint points[3];
	NSBezierPath * a;
	NSBezierPath * b;
	NSBezierPath * result;
	
	// Overlapping parallel edges
	a = [NSBezierPath bezierPathWithRect:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
	b = [NSBezierPath bezierPathWithRect:NSMakeRect(50.0, 0.0, 100.0, 100.0)];
		
	result = [a WFSubtractPath:b];
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(50.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(50.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	
	// Special case for subtraction that seems to be causing problems
	a = [NSBezierPath bezierPathWithRect:NSMakeRect(0.0, 50.0, 100.0, 100.0)];
	b = [NSBezierPath bezierPathWithRect:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
	result = [a WFSubtractPath:b];
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 150.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 150.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 150.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	XCTAssertTrue( [result elementCount] == 5, @"Result has too many elements" );
}
/*
- (void)testBezierPathOverlappingParallelEdgesIntersect
{
	NSBezierPathElement element;
	CGPoint points[3];
	NSBezierPath * a;
	NSBezierPath * b;
	NSBezierPath * result;
	
	// Overlapping parallel edges
	a = [NSBezierPath bezierPathWithRect:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
	b = [NSBezierPath bezierPathWithRect:NSMakeRect(50.0, 0.0, 100.0, 100.0)];
	
	result = [a WFIntersectWithPath:b];
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(50.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(50.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(50.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	
	// Special case for intersections that seems to be causing problems
	a = [NSBezierPath bezierPathWithRect:NSMakeRect(0.0, 50.0, 100.0, 100.0)];
	b = [NSBezierPath bezierPathWithRect:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
	result = [a WFIntersectWithPath:b];
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 50.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 50.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 50.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
}
*/


- (void)testBezierPathCornerThroughEdge
{
	NSBezierPathElement element;
	CGPoint points[3];
	NSBezierPath * a;
	NSBezierPath * b;
	NSBezierPath * result;
	
	// Corner through edge
	a = [NSBezierPath bezierPathWithRect:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
	b = [[NSBezierPath alloc] init];
	[b moveToPoint:NSMakePoint(150.0, 75.0)];
	[b lineToPoint:NSMakePoint(50.0, 75.0)];
	[b lineToPoint:NSMakePoint(100.0, 25.0)];
	[b closePath];
	result = [a WFUnionWithPath:b];
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 25.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(150.0, 75.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 75.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:6 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:7 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:8 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(150.0, 75.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
}

- (void)testBezierPathCornerThroughEdgeSubtract
{
	NSBezierPathElement element;
	CGPoint points[3];
	NSBezierPath * a;
	NSBezierPath * b;
	NSBezierPath * result;
	
	// Corner through edge
	a = [NSBezierPath bezierPathWithRect:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
	b = [[NSBezierPath alloc] init];
	[b moveToPoint:NSMakePoint(150.0, 75.0)];
	[b lineToPoint:NSMakePoint(50.0, 75.0)];
	[b lineToPoint:NSMakePoint(100.0, 25.0)];
	[b closePath];
	result = [a WFSubtractPath:b];
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 25.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(50.0, 75.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 75.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:6 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:7 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:8 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
}

- (void)testBezierPathCornerThroughCorner
{
	NSBezierPathElement element;
	CGPoint points[3];
	NSBezierPath * a;
	NSBezierPath * b;
	NSBezierPath * result;
	
	// Corner through corner
	a = [NSBezierPath bezierPathWithRect:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
	b = [[NSBezierPath alloc] init];
	[b moveToPoint:NSMakePoint(50.0, 50.0)];
	[b lineToPoint:NSMakePoint(50.0, -50.0)];
	[b lineToPoint:NSMakePoint(150.0, -50.0)];
	[b closePath];
	result = [a WFUnionWithPath:b];
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(50.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(50.0, -50.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(150.0, -50.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:6 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:7 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:8 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
}

- (void)testBezierPathCornerThroughCornerSubtract
{
	NSBezierPathElement element;
	CGPoint points[3];
	NSBezierPath * a;
	NSBezierPath * b;
	NSBezierPath * result;
	
	// Corner through corner
	a = [NSBezierPath bezierPathWithRect:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
	b = [[NSBezierPath alloc] init];
	[b moveToPoint:NSMakePoint(50.0, 50.0)];
	[b lineToPoint:NSMakePoint(50.0, -50.0)];
	[b lineToPoint:NSMakePoint(150.0, -50.0)];
	[b closePath];
	result = [a WFSubtractPath:b];
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(50.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(50.0, 50.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:6 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:7 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(50.0, 50.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
}


- (void)testBezierPathCurveEndpointsCrossing
{
	NSBezierPathElement element;
	CGPoint points[3];
	NSBezierPath * a;
	NSBezierPath * b;
	NSBezierPath * result;
	
	// This was a pretty nasty case due to the multiple bezier curves intersecting at endpoints.
	// Unfortunately the correct result has 28 elements so we'll just do a spot check.
	a = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
	b = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(52.0, 52.0, 100.0, 100.0)];
	[a appendBezierPath:[[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(10.0, 10.0, 80.0, 80.0)] bezierPathByReversingPath]];
	[b appendBezierPath:[[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(62.0, 62.0, 80.0, 80.0)] bezierPathByReversingPath]];
	result = [a WFUnionWithPath:b];
	XCTAssertTrue( [result elementCount] == 28, @"Incorrect number of elements: %lu", [result elementCount] );
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(85.355339, 14.644661)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:9 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(85.355339, 85.355339)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:16 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(78.284271, 21.715729)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:23 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(78.284271, 78.284271)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
}

- (void)testBezierNestingOffsetRects
{
	NSBezierPathElement element;
	CGPoint points[3];
	NSBezierPath * a;
	NSBezierPath * b;
	NSBezierPath * result;
	
	a = [NSBezierPath bezierPathWithRect:NSMakeRect( 0.0, 0.0, 100.0, 100.0 )];
	[a appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(10.0, 10.0, 80.0, 80.0)] bezierPathByReversingPath]];
	b = [NSBezierPath bezierPathWithRect:NSMakeRect( 10.0, 10.0, 100.0, 100.0 )];
	[b appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(20.0, 20.0, 80.0, 80.0)] bezierPathByReversingPath]];
	result = [a WFUnionWithPath:b];
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 10.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(110.0, 10.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(110.0, 110.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.0, 110.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:6 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:7 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:8 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:9 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.0, 90.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:10 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.0, 20.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:11 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(20.0, 20.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:12 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(20.0, 90.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:13 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.0, 90.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:14 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.0, 10.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
}

- (void)testBezierNestingOffsetRectsSubtract
{
	NSBezierPathElement element;
	CGPoint points[3];
	NSBezierPath * a;
	NSBezierPath * b;
	NSBezierPath * result;
	
	a = [NSBezierPath bezierPathWithRect:NSMakeRect( 0.0, 0.0, 100.0, 100.0 )];
	[a appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(10.0, 10.0, 80.0, 80.0)] bezierPathByReversingPath]];
	b = [NSBezierPath bezierPathWithRect:NSMakeRect( 10.0, 10.0, 100.0, 100.0 )];
	[b appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(20.0, 20.0, 80.0, 80.0)] bezierPathByReversingPath]];
	result = [a WFSubtractPath:b];
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 10.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.0, 10.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.0, 10.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.0, 90.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:6 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:7 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:8 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	
	element = [result elementAtIndex:9 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.0, 90.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:10 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.0, 20.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:11 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 20.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:12 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:13 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(20.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:14 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(20.0, 90.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:15 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.0, 90.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
}

- (void)testBezierPartiallyNestingOffsetRects
{
	NSBezierPathElement element;
	CGPoint points[3];
	NSBezierPath * a;
	NSBezierPath * b;
	NSBezierPath * result;
	
	a = [NSBezierPath bezierPathWithRect:NSMakeRect( 0.0, 0.0, 100.0, 100.0 )];
	[a appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(10.0, 10.0, 80.0, 80.0)] bezierPathByReversingPath]];
	b = [NSBezierPath bezierPathWithRect:NSMakeRect( 5.0, 10.0, 100.0, 100.0 )];
	[b appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(15.0, 20.0, 80.0, 80.0)] bezierPathByReversingPath]];
	result = [a WFUnionWithPath:b];
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 10.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(105.0, 10.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(105.0, 110.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(5.0, 110.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:6 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(5.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:7 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:8 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:9 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.0, 90.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:10 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.0, 20.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:11 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(15.0, 20.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:12 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(15.0, 90.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:13 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.0, 90.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:14 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.0, 10.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
}

- (void)testBezierPartiallyNestingOffsetRectsSubtract
{
	NSBezierPathElement element;
	CGPoint points[3];
	NSBezierPath * a;
	NSBezierPath * b;
	NSBezierPath * result;
	
	a = [NSBezierPath bezierPathWithRect:NSMakeRect( 0.0, 0.0, 100.0, 100.0 )];
	[a appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(10.0, 10.0, 80.0, 80.0)] bezierPathByReversingPath]];
	b = [NSBezierPath bezierPathWithRect:NSMakeRect( 5.0, 10.0, 100.0, 100.0 )];
	[b appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(15.0, 20.0, 80.0, 80.0)] bezierPathByReversingPath]];
	result = [a WFSubtractPath:b];
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 10.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.0, 10.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.0, 10.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(5.0, 10.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:6 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(5.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:7 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:8 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	
	element = [result elementAtIndex:9 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.0, 90.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:10 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.0, 20.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:11 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(95.0, 20.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:12 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(95.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:13 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(15.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:14 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(15.0, 90.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:15 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.0, 90.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
}

- (void)testBezierParallelOffsetrects
{
	NSBezierPathElement element;
	CGPoint points[3];
	NSBezierPath * a;
	NSBezierPath * b;
	NSBezierPath * result;
	
	a = [NSBezierPath bezierPathWithRect:NSMakeRect( 0.0, 0.0, 100.0, 100.0 )];
	[a appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(10.0, 10.0, 80.0, 80.0)] bezierPathByReversingPath]];
	b = [NSBezierPath bezierPathWithRect:NSMakeRect( 20.0, 0.0, 100.0, 100.0 )];
	[b appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(30.0, 10.0, 80.0, 80.0)] bezierPathByReversingPath]];
	result = [a WFUnionWithPath:b];
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(20.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(120.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(120.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:6 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(20.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:7 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:8 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:9 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.0, 10.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:10 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.0, 90.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:11 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(20.0, 90.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:12 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(20.0, 10.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:13 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.0, 10.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:14 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(110.0, 90.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:15 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(110.0, 10.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:16 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 10.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:17 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 90.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:18 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(110.0, 90.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:19 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(30.0, 90.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:20 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.0, 90.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:21 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.0, 10.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:22 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(30.0, 10.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:23 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(30.0, 90.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	
	a = [NSBezierPath bezierPathWithRect:NSMakeRect( 0.0, 20.0, 100.0, 100.0 )];
	[a appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(10.0, 30.0, 80.0, 80.0)] bezierPathByReversingPath]];
	b = [NSBezierPath bezierPathWithRect:NSMakeRect( 0.0, 0.0, 100.0, 100.0 )];
	[b appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(10.0, 10.0, 80.0, 80.0)] bezierPathByReversingPath]];
	result = [a WFUnionWithPath:b];
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 120.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 120.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 20.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:6 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 20.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:7 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:8 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 120.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:9 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.0, 110.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:10 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.0, 110.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:11 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:12 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:13 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.0, 110.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:14 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.0, 10.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:15 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.0, 20.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:16 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.0, 20.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:17 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.0, 10.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:18 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.0, 10.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:19 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.0, 90.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:20 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.0, 90.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:21 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.0, 30.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:22 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.0, 30.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:23 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.0, 90.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
}

- (void)testBezierParallelRectsWithCongruentSides
{
	NSBezierPathElement element;
	CGPoint points[3];
	NSBezierPath * a;
	NSBezierPath * b;
	NSBezierPath * result;
	
	a = [NSBezierPath bezierPathWithRect:NSMakeRect( 0.0, 0.0, 100.0, 100.0 )];
	[a appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(10.0, 10.0, 80.0, 80.0)] bezierPathByReversingPath]];
	b = [NSBezierPath bezierPathWithRect:NSMakeRect( 10.0, 0.0, 100.0, 100.0 )];
	[b appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(20.0, 10.0, 80.0, 80.0)] bezierPathByReversingPath]];
	result = [a WFUnionWithPath:b];
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(110.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(110.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:6 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:7 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:8 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:9 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(20.0, 90.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:10 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.0, 90.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:11 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.0, 10.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:12 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(20.0, 10.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:13 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(20.0, 90.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	
	a = [NSBezierPath bezierPathWithRect:NSMakeRect( 0.0, 10.0, 100.0, 100.0 )];
	[a appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(10.0, 20.0, 80.0, 80.0)] bezierPathByReversingPath]];
	b = [NSBezierPath bezierPathWithRect:NSMakeRect( 0.0, 0.0, 100.0, 100.0 )];
	[b appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(10.0, 10.0, 80.0, 80.0)] bezierPathByReversingPath]];
	result = [a WFUnionWithPath:b];
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 110.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 110.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 10.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:6 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 10.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:7 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:8 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 110.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:9 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.0, 90.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:10 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.0, 90.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:11 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.0, 20.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:12 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.0, 20.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:13 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.0, 90.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
}

- (void)testBezierParallelRectsWithCongruentSidesSubtract
{
	NSBezierPathElement element;
	CGPoint points[3];
	NSBezierPath * a;
	NSBezierPath * b;
	NSBezierPath * result;
	
	a = [NSBezierPath bezierPathWithRect:NSMakeRect( 0.0, 0.0, 100.0, 100.0 )];
	[a appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(10.0, 10.0, 80.0, 80.0)] bezierPathByReversingPath]];
	b = [NSBezierPath bezierPathWithRect:NSMakeRect( 80.0, 0.0, 100.0, 100.0 )];
	[b appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(90.0, 10.0, 80.0, 80.0)] bezierPathByReversingPath]];
	result = [a WFSubtractPath:b];
	XCTAssertTrue( [result elementCount] == 14, @"Incorrect element count" );
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.000000, 0.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(80.000000, 0.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(80.000000, 10.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.000000, 10.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.000000, 90.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(80.000000, 90.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:6 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(80.000000, 100.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:7 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.000000, 100.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:8 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.000000, 0.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:9 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.000000, 10.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:10 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.000000, 90.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:11 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.000000, 90.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:12 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.000000, 10.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:13 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.000000, 10.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	
	
	a = [NSBezierPath bezierPathWithRect:NSMakeRect( 0.0, 0.0, 100.0, 100.0 )];
	[a appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(10.0, 10.0, 80.0, 80.0)] bezierPathByReversingPath]];
	b = [NSBezierPath bezierPathWithRect:NSMakeRect( 0.0, 80.0, 100.0, 100.0 )];
	[b appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(10.0, 90.0, 80.0, 80.0)] bezierPathByReversingPath]];
	result = [a WFSubtractPath:b];
	XCTAssertTrue( [result elementCount] == 14, @"Incorrect element count" );
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.000000, 0.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.000000, 0.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.000000, 80.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.000000, 80.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.000000, 10.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.000000, 10.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:6 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.000000, 80.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:7 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.000000, 80.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:8 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.000000, 0.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:9 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.000000, 100.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:10 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.000000, 100.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:11 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.000000, 90.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:12 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.000000, 90.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:13 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.000000, 100.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
}


- (void)testBezierParallelOffsetWithHoleSubtract
{
	NSBezierPathElement element;
	CGPoint points[3];
	NSBezierPath * a;
	NSBezierPath * b;
	NSBezierPath * result;
	
	a = [NSBezierPath bezierPathWithRect:NSMakeRect( 0.0, 0.0, 100.0, 100.0 )];
	[a appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(10.0, 10.0, 80.0, 80.0)] bezierPathByReversingPath]];
	b = [NSBezierPath bezierPathWithRect:NSMakeRect( 90.0, 50.0, 100.0, 100.0 )];
	[b appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(100.0, 60.0, 80.0, 80.0)] bezierPathByReversingPath]];
	result = [a WFSubtractPath:b];
	
	XCTAssertTrue( [result elementCount] == 12, @"Incorrect element count" );
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.000000, 0.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.000000, 0.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.000000, 50.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.000000, 50.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.000000, 10.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.000000, 10.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:6 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.000000, 90.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:7 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.000000, 90.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:8 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.000000, 100.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:9 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.000000, 100.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:10 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.000000, 0.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:11 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.000000, 10.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
}

- (void)testBezierParallelComplexPolygon1
{
	NSBezierPathElement element;
	CGPoint points[3];
	NSBezierPath * a;
	NSBezierPath * b;
	NSBezierPath * result;
	
	a = [NSBezierPath bezierPathWithRect:NSMakeRect(0.0, 00.0, 100.0, 100.0)];
	[a appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(10.0, 20.0, 30.0, 60.0)] bezierPathByReversingPath]];
	[a appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(60.0, 20.0, 30.0, 60.0)] bezierPathByReversingPath]];
	
	NSAffineTransform* tfm = [NSAffineTransform transform];
	[tfm translateXBy:-20 yBy:0];
	b = [tfm transformBezierPath:a];
	
	result = [a WFUnionWithPath:b];
	
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(80.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(-20.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(-20.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:6 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:7 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(80.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:8 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	
	element = [result elementAtIndex:9 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.0, 80.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:10 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.0, 20.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:11 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(80.0, 20.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:12 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(80.0, 80.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:13 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.0, 80.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	
	element = [result elementAtIndex:14 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(-10.0, 20.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:15 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(-10.0, 80.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:16 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 80.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:17 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 20.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:18 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(-10.0, 20.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	
	element = [result elementAtIndex:19 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.0, 80.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:20 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(20.0, 80.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:21 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(20.0, 20.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:22 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.0, 20.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:23 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.0, 80.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	
	element = [result elementAtIndex:24 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(60.0, 80.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:25 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(70.0, 80.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:26 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(70.0, 20.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:27 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(60.0, 20.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:28 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(60.0, 80.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
}

- (void)testBezierParallelComplexPolygon1Subtract
{
	NSBezierPathElement element;
	CGPoint points[3];
	NSBezierPath * a;
	NSBezierPath * b;
	NSBezierPath * result;
	
	a = [NSBezierPath bezierPathWithRect:NSMakeRect(0.0, 00.0, 100.0, 100.0)];
	[a appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(10.0, 20.0, 30.0, 60.0)] bezierPathByReversingPath]];
	[a appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(60.0, 20.0, 30.0, 60.0)] bezierPathByReversingPath]];
	
	NSAffineTransform* tfm = [NSAffineTransform transform];
	[tfm translateXBy:-20 yBy:0];
	b = [tfm transformBezierPath:a];
	
	result = [a WFSubtractPath:b];
	
	XCTAssertTrue( [result elementCount] == 20, @"Incorrect element count" );
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.000000, 0.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.000000, 100.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(80.000000, 100.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(80.000000, 80.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.000000, 80.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.000000, 20.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:6 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(80.000000, 20.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:7 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(80.000000, 0.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:8 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.000000, 0.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:9 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.000000, 20.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:10 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.000000, 20.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:11 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.000000, 80.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:12 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.000000, 80.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:13 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.000000, 20.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:14 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(40.000000, 80.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:15 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(40.000000, 20.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:16 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(60.000000, 20.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:17 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(60.000000, 80.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:18 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(40.000000, 80.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:19 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(70.000000, 20.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
}

- (void)testBezierParallelComplexPolygon2
{
	NSBezierPathElement element;
	CGPoint points[3];
	NSBezierPath * a;
	NSBezierPath * b;
	NSBezierPath * result;
	
	a = [NSBezierPath bezierPathWithRect:NSMakeRect(50.0, 50.0, 300.0, 300.0)];
	[a appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(220.0, 220.0, 110.0, 110.0)] bezierPathByReversingPath]];
	[a appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(70.0, 220.0, 110.0, 110.0)] bezierPathByReversingPath]];
	
	NSAffineTransform* tfm = [NSAffineTransform transform];
	[tfm translateXBy:260 yBy:0];
	b = [tfm transformBezierPath:a];
	
	result = [a WFUnionWithPath:b];

	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(50.0, 50.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(310.0, 50.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(350.0, 50.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(610.0, 50.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(610.0, 350.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(350.0, 350.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:6 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(310.0, 350.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:7 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(50.0, 350.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:8 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(50.0, 50.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	
	element = [result elementAtIndex:9 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(220.0, 220.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:10 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(220.0, 330.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:11 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(310.0, 330.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:12 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(310.0, 220.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:13 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(220.0, 220.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	
	element = [result elementAtIndex:14 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(70.0, 220.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:15 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(70.0, 330.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:16 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(180.0, 330.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:17 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(180.0, 220.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:18 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(70.0, 220.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	
	element = [result elementAtIndex:19 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(480.0, 220.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:20 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(480.0, 330.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:21 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(590.0, 330.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:22 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(590.0, 220.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:23 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(480.0, 220.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	
	element = [result elementAtIndex:24 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(440.0, 330.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:25 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(440.0, 220.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:26 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(350.0, 220.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:27 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(350.0, 330.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:28 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(440.0, 330.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
}

- (void)testBezierParallelComplexPolygon2Subtract
{
	NSBezierPathElement element;
	CGPoint points[3];
	NSBezierPath * a;
	NSBezierPath * b;
	NSBezierPath * result;
	
	a = [NSBezierPath bezierPathWithRect:NSMakeRect(50.0, 50.0, 300.0, 300.0)];
	[a appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(220.0, 220.0, 110.0, 110.0)] bezierPathByReversingPath]];
	[a appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(70.0, 220.0, 110.0, 110.0)] bezierPathByReversingPath]];
	
	NSAffineTransform* tfm = [NSAffineTransform transform];
	[tfm translateXBy:260 yBy:0];
	b = [tfm transformBezierPath:a];
	
	result = [a WFSubtractPath:b];
	
	XCTAssertTrue( [result elementCount] == 19, @"Incorrect element count" );
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(50.000000, 50.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(310.000000, 50.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(310.000000, 220.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(220.000000, 220.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(220.000000, 330.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(310.000000, 330.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:6 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(310.000000, 350.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:7 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(50.000000, 350.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:8 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(50.000000, 50.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:9 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(70.000000, 220.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:10 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(70.000000, 330.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:11 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(180.000000, 330.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:12 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(180.000000, 220.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:13 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(70.000000, 220.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:14 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(350.000000, 220.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:15 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(350.000000, 330.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:16 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(330.000000, 330.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:17 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(330.000000, 220.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:18 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(350.000000, 220.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
}

- (void)testBezierParallelComplexPolygon3
{
	NSBezierPathElement element;
	CGPoint points[3];
	NSBezierPath * a;
	NSBezierPath * b;
	NSBezierPath * result;
	
	a = [NSBezierPath bezierPathWithRect:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
	[a appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(60.0, 20.0, 20.0, 20.0)] bezierPathByReversingPath]];
	NSAffineTransform* tfm = [NSAffineTransform transform];
	[tfm translateXBy:40 yBy:-20];
	b = [tfm transformBezierPath:a];
	
	result = [a WFUnionWithPath:b];
	
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(40.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(40.0, -20.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(140.0, -20.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(140.0, 80.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 80.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:6 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:7 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:8 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	
	element = [result elementAtIndex:9 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(120.0, 20.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:10 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(120.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:11 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:12 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 20.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:13 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(120.0, 20.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
}


- (void)testBezierParallelComplexPolygon3Subtract
{
	NSBezierPathElement element;
	CGPoint points[3];
	NSBezierPath * a;
	NSBezierPath * b;
	NSBezierPath * result;
	
	a = [NSBezierPath bezierPathWithRect:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
	[a appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(60.0, 20.0, 20.0, 20.0)] bezierPathByReversingPath]];
	NSAffineTransform* tfm = [NSAffineTransform transform];
	[tfm translateXBy:40 yBy:-20];
	b = [tfm transformBezierPath:a];
	
	result = [a WFSubtractPath:b];
	
	XCTAssertTrue( [result elementCount] == 7, @"Incorrect element count" );
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.000000, 0.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(40.000000, 0.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(40.000000, 80.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.000000, 80.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.000000, 100.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.000000, 100.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:6 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.000000, 0.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
}

- (void)testBezierParallelComplexPolygon4Subtract
{
	NSBezierPathElement element;
	CGPoint points[3];
	NSBezierPath * a;
	NSBezierPath * b;
	NSBezierPath * result;
	
	a = [NSBezierPath bezierPathWithRect:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
	[a appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(60.0, 20.0, 20.0, 20.0)] bezierPathByReversingPath]];
	[a appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(60.0, 60.0, 20.0, 20.0)] bezierPathByReversingPath]];
	
	b = [NSBezierPath bezierPathWithRect:NSMakeRect(20.0, 0.0, 100.0, 100.0)];
	[b appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(60.0, 20.0, 20.0, 20.0)] bezierPathByReversingPath]];
	[b appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(60.0, 60.0, 20.0, 20.0)] bezierPathByReversingPath]];
	
	result = [a WFSubtractPath:b];
	XCTAssertTrue( [result elementCount] == 6, @"Incorrect element count" );
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.000000, 0.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(20.000000, 0.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(20.000000, 100.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.000000, 100.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.000000, 0.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(80.000000, 60.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
}

- (void)testBezierParallelComplexPolygon5Subtract
{
	NSBezierPathElement element;
	CGPoint points[3];
	NSBezierPath * a;
	NSBezierPath * b;
	NSBezierPath * result;
	
	a = [NSBezierPath bezierPathWithRect:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
	[a appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(60.0, 10.0, 30.0, 30.0)] bezierPathByReversingPath]];
	[a appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(60.0, 60.0, 30.0, 30.0)] bezierPathByReversingPath]];
	
	b = [NSBezierPath bezierPathWithRect:NSMakeRect(50.0, 30.0, 100.0, 100.0)];
	[b appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(60.0, 40.0, 30.0, 30.0)] bezierPathByReversingPath]];
	[b appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(60.0, 90.0, 30.0, 30.0)] bezierPathByReversingPath]];
	
	result = [a WFSubtractPath:b];
	
	XCTAssertTrue( [result elementCount] == 22, @"Incorrect element count" );
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.000000, 0.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.000000, 0.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.000000, 30.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.000000, 30.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.000000, 10.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(60.000000, 10.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:6 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(60.000000, 30.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:7 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(50.000000, 30.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:8 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(50.000000, 100.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:9 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.000000, 100.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:10 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.000000, 0.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:11 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.000000, 100.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:12 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(60.000000, 100.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:13 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(60.000000, 90.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:14 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.000000, 90.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:15 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.000000, 100.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:16 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(60.000000, 40.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:17 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.000000, 40.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:18 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.000000, 60.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:19 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(60.000000, 60.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:20 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(60.000000, 40.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:21 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(60.000000, 70.000000)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
}


- (void)testBezierParallelRectsWithOverlappingCongruentSides
{
	NSBezierPathElement element;
	CGPoint points[3];
	NSBezierPath * a;
	NSBezierPath * b;
	NSBezierPath * result;
	
	a = [NSBezierPath bezierPathWithRect:NSMakeRect( 0.0, 0.0, 100.0, 100.0 )];
	[a appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(10.0, 10.0, 80.0, 80.0)] bezierPathByReversingPath]];
	b = [NSBezierPath bezierPathWithRect:NSMakeRect( 5.0, 0.0, 100.0, 100.0 )];
	[b appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(15.0, 10.0, 80.0, 80.0)] bezierPathByReversingPath]];
	result = [a WFUnionWithPath:b];
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(5.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(105.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(105.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:6 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(5.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:7 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:8 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:9 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(15.0, 90.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:10 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.0, 90.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:11 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.0, 10.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:12 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(15.0, 10.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:13 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(15.0, 90.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	
	a = [NSBezierPath bezierPathWithRect:NSMakeRect( 0.0, 5.0, 100.0, 100.0 )];
	[a appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(10.0, 15.0, 80.0, 80.0)] bezierPathByReversingPath]];
	b = [NSBezierPath bezierPathWithRect:NSMakeRect( 0.0, 0.0, 100.0, 100.0 )];
	[b appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(10.0, 10.0, 80.0, 80.0)] bezierPathByReversingPath]];
	result = [a WFUnionWithPath:b];
	element = [result elementAtIndex:0 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 105.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:1 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 105.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:2 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:3 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 5.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:4 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(0.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:5 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 0.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:6 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 5.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:7 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 100.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:8 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(100.0, 105.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	
	element = [result elementAtIndex:9 associatedPoints:points];
	XCTAssertTrue( element == NSMoveToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.0, 90.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:10 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.0, 90.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:11 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(90.0, 15.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:12 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.0, 15.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
	element = [result elementAtIndex:13 associatedPoints:points];
	XCTAssertTrue( element == NSLineToBezierPathElement, @"Incorrect element" );
	XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(10.0, 90.0)) <= WFBezierPointAcceptanceResolution, @"Incorrect result point" );
}

- (void)testBezierPathSubtraction
{
	NSBezierPath * a = [[NSBezierPath alloc] init];
	NSBezierPath * b = [[NSBezierPath alloc] init];
	NSBezierPath * result = nil;
	
	// Single path intersections along all corners of original path
	a = [NSBezierPath bezierPathWithRect:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
	b = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(56.0, 52.0, 100.0, 100.0)];
	result = [a WFSubtractPath:b];
	b = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(-56.0, -52.0, 100.0, 100.0)];
	result = [a WFSubtractPath:b];
	
	// Dual path intersect
	[a appendBezierPath:[NSBezierPath bezierPathWithRect:NSMakeRect(200.0, 100.0, 100.0, 200.0)]];
	[b appendBezierPath:[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(250.0, 250.0, 100.0, 100.0)]];
	result = [a WFSubtractPath:b];
	
	// Tripple intersect
	a = [NSBezierPath bezierPathWithRect:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
	b = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(52.0, 62.0, 200.0, 100.0)];
	[a appendBezierPath:[NSBezierPath bezierPathWithRect:NSMakeRect(200.0, 100.0, 100.0, 200.0)]];
	[b appendBezierPath:[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(250.0, 250.0, 100.0, 100.0)]];
	result = [a WFSubtractPath:b];
	
	// Single Paths with holes
	a = [NSBezierPath bezierPathWithRect:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
	[a appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(20.0, 20.0, 60.0, 60.0)] bezierPathByReversingPath]];
	b = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(32.0, 32.0, 100.0, 100.0)];
	[b appendBezierPath:[[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(52.0, 52.0, 60.0, 60.0)] bezierPathByReversingPath]];
	result = [a WFSubtractPath:b];
	
	// Both paths curved
	a = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
	b = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(56.0, 52.0, 100.0, 100.0)];
	result = [a WFSubtractPath:b];
	b = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(-32.0, -32.0, 100.0, 100.0)];
	result = [a WFSubtractPath:b];
	
	[a appendBezierPath:[[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(10.0, 10.0, 80.0, 80.0)] bezierPathByReversingPath]];
	[b appendBezierPath:[[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(-22.0, -22.0, 80.0, 80.0)] bezierPathByReversingPath]];
	result = [a WFSubtractPath:b];
}

- (void)testBezierPathIntersection
{
	NSBezierPath * a = [[NSBezierPath alloc] init];
	NSBezierPath * b = [[NSBezierPath alloc] init];
	NSBezierPath * result = nil;
	
	// Single path intersections along all corners of original path
	a = [NSBezierPath bezierPathWithRect:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
	b = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(56.0, 52.0, 100.0, 100.0)];
	result = [a WFIntersectWithPath:b];
	b = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(-56.0, -52.0, 100.0, 100.0)];
	result = [a WFIntersectWithPath:b];
	
	// Dual path intersect
	[a appendBezierPath:[NSBezierPath bezierPathWithRect:NSMakeRect(200.0, 100.0, 100.0, 200.0)]];
	[b appendBezierPath:[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(250.0, 250.0, 100.0, 100.0)]];
	result = [a WFIntersectWithPath:b];
	
	// Tripple intersect
	a = [NSBezierPath bezierPathWithRect:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
	b = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(52.0, 62.0, 200.0, 100.0)];
	[a appendBezierPath:[NSBezierPath bezierPathWithRect:NSMakeRect(200.0, 100.0, 100.0, 200.0)]];
	[b appendBezierPath:[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(250.0, 250.0, 100.0, 100.0)]];
	result = [a WFIntersectWithPath:b];
	
	// Single Paths with holes
	a = [NSBezierPath bezierPathWithRect:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
	[a appendBezierPath:[[NSBezierPath bezierPathWithRect:NSMakeRect(20.0, 20.0, 60.0, 60.0)] bezierPathByReversingPath]];
	b = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(32.0, 32.0, 100.0, 100.0)];
	[b appendBezierPath:[[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(52.0, 52.0, 60.0, 60.0)] bezierPathByReversingPath]];
	result = [a WFIntersectWithPath:b];
	
	// Both paths curved
	a = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
	b = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(56.0, 52.0, 100.0, 100.0)];
	result = [a WFIntersectWithPath:b];
	b = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(-32.0, -32.0, 100.0, 100.0)];
	result = [a WFIntersectWithPath:b];
	
	[a appendBezierPath:[[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(10.0, 10.0, 80.0, 80.0)] bezierPathByReversingPath]];
	[b appendBezierPath:[[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(-22.0, -22.0, 80.0, 80.0)] bezierPathByReversingPath]];
	result = [a WFIntersectWithPath:b];
}

- (void)testCurveZeroFinding
{
	CGPoint curve[4];
	CGFloat result[3];
	
	curve[0] = CGPointMake(120, -160);
	curve[1] = CGPointMake(120, 320);
	curve[2] = CGPointMake(220, -320);
	curve[3] = CGPointMake(220,  160);
	
	uint64_t count = WFGeometryFindRootsOfCubicCurve( curve, result );
	XCTAssert( count == 3, @"Not enough roots found" );
	XCTAssertEqualWithAccuracy( result[0], 0.1726731646460114, WFGeometryParametricResolution, @"Did not find correct root");
	XCTAssertEqualWithAccuracy( result[1], 0.8273268353539885, WFGeometryParametricResolution, @"Did not find correct root");
	XCTAssertEqualWithAccuracy( result[2], 0.4999999999999999, WFGeometryParametricResolution, @"Did not find correct root");
}

@end
