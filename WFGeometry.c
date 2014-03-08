//
//  WFGeometry.c
//
//  Created by Noah Desch on 12/27/13.
//  Copyright (c) 2013 Noah Desch.
//

#include <math.h>
#include <string.h>

#include "WFGeometry.h"
//#include <CoreGraphics/CGBase.h>
#include <CoreGraphics/CGGeometry.h>

uint64_t WFGeometryCurveCurveIntersection_Recursive( const CGPoint * curveA,
													 const CGPoint * curveB,
													 CGFloat * outT1Array,
													 CGFloat * outT2Array,
													 CGFloat tA,
													 CGFloat tB,
													 uint64_t depth,
													 uint64_t resultCount );




CGFloat WFGeometryDeterminant3x3( CGFloat ** matrix )
{
	return	matrix[0][0] * matrix[1][1] * matrix[2][2] +
			matrix[0][1] * matrix[1][2] * matrix[2][0] +
			matrix[0][2] * matrix[1][0] * matrix[2][1] -
			matrix[0][2] * matrix[1][1] * matrix[2][0] -
			matrix[0][1] * matrix[1][0] * matrix[2][2] -
			matrix[0][0] * matrix[1][2] * matrix[2][1];
}

void WFGeometryBezierDerivative( const CGPoint * input, CGPoint * output )
{
	output[0].x = 3.0 * (input[1].x-input[0].x);
	output[1].x = 3.0 * (input[2].x-input[1].x);
	output[2].x = 3.0 * (input[3].x-input[2].x);
	output[0].y = 3.0 * (input[1].y-input[0].y);
	output[1].y = 3.0 * (input[2].y-input[1].y);
	output[2].y = 3.0 * (input[3].y-input[2].y);
}

void WFGeometryQuadraticBezierDerivative( const CGPoint * input, CGPoint * output )
{
	output[0].x = 2.0 * (input[1].x-input[0].x);
	output[1].x = 2.0 * (input[2].x-input[1].x);
	output[0].y = 2.0 * (input[1].y-input[0].y);
	output[1].y = 2.0 * (input[2].y-input[1].y);
}

CGFloat WFGeometryDistanceFromPointToLine( CGPoint point, CGPoint pointA, CGPoint pointB )
{
	CGPoint segmentL, segmentAP, segmentBP;
	CGFloat dotAPL, dotBPL;
	CGFloat magAP, magBP;
	CGFloat dist = CGFLOAT_MAX;
	
	segmentL = CGPointMake( pointB.x - pointA.x, pointB.y - pointA.y );
	segmentAP = CGPointMake( pointA.x - point.x , pointA.y - point.y );
	segmentBP = CGPointMake( pointB.x - point.x , pointB.y - point.y );
	
	dotAPL = segmentAP.x*segmentL.x + segmentAP.y*segmentL.y;
	dotBPL = segmentBP.x*segmentL.x + segmentBP.y*segmentL.y;
	
	// check distance to endpoints
	magAP = sqrt( segmentAP.x*segmentAP.x + segmentAP.y*segmentAP.y );
	magBP = sqrt( segmentBP.x*segmentBP.x + segmentBP.y*segmentBP.y );
	
	// check line distance
	if ( (dotAPL >= 0.0 && dotBPL <= 0.0) || (dotAPL <= 0.0 && dotBPL >= 0.0 ) ) {
		CGFloat magL = sqrt( segmentL.x*segmentL.x + segmentL.y*segmentL.y );
		segmentL.x /= magL;
		segmentL.y /= magL;
		dist = fabs( segmentL.x*segmentAP.y - segmentL.y*segmentAP.x );
	}
	
	return fmin( fmin(magAP, magBP), dist );
}

CGFloat WFGeometryDistanceFromPointToCurve( CGPoint point, const CGPoint * curve )
{
	CGFloat t = 0.0;
	CGFloat bestT = 0.0;
	CGFloat result = CGFLOAT_MAX;
	
	// gross approximation
	while ( t <= 1.0 ) {
		CGPoint p = WFGeometryEvaluateCubicCurve( t, curve );
		CGFloat d2 = WFGeometryDistance2( p, point );
		if ( d2 < result ) {
			bestT = t;
			result = d2;
		}
		t += 0.005;
	}
	
	// finer approximation
	t = bestT - 0.005;
	CGFloat endT = bestT + 0.005;
	while ( t <= endT ) {
		CGPoint p = WFGeometryEvaluateCubicCurve( t, curve );
		CGFloat d2 = WFGeometryDistance2( p, point );
		if ( d2 < result ) {
			result = d2;
		}
		t += 0.0005;
	}
	
	// TODO: Although technically this function runs in constant time it's still pretty terrible for performance and isn't especially accurate in some cases
	return sqrt( result );
}

void WFGeometrySplitCubicCurve( CGFloat t, const CGPoint * curve, CGPoint * outCurve1, CGPoint * outCurve2 )
{
	CGFloat z = (t-1.0);
	
	outCurve1[0] = curve[0];
	outCurve1[1] = CGPointMake( t*curve[1].x-z*curve[0].x,
							    t*curve[1].y-z*curve[0].y );
	outCurve1[2] = CGPointMake( t*t*curve[2].x-2.0*t*z*curve[1].x+z*z*curve[0].x,
							    t*t*curve[2].y-2.0*t*z*curve[1].y+z*z*curve[0].y );
	outCurve1[3] = CGPointMake( t*t*t*curve[3].x-3.0*t*t*z*curve[2].x+3*t*z*z*curve[1].x-z*z*z*curve[0].x,
							    t*t*t*curve[3].y-3.0*t*t*z*curve[2].y+3*t*z*z*curve[1].y-z*z*z*curve[0].y );
	
	outCurve2[0] = outCurve1[3];
	outCurve2[1] = CGPointMake( t*t*curve[3].x-2.0*t*z*curve[2].x+z*z*curve[1].x,
							    t*t*curve[3].y-2.0*t*z*curve[2].y+z*z*curve[1].y );
	outCurve2[2] = CGPointMake( t*curve[3].x-z*curve[2].x,
							    t*curve[3].y-z*curve[2].y );
	outCurve2[3] = curve[3];
}

CGFloat WFGeometryParameterForCubicCurvePoint( const CGPoint * curve, CGPoint point )
{
	CGPoint shiftedCurve[4];
	CGFloat result[3];
	
	for ( int i = 0; i < 4; i++ ) {
		shiftedCurve[i] = curve[i];
		shiftedCurve[i].y -= point.y;
	}
	uint64_t roots = WFGeometryFindRootsOfCubicCurve(shiftedCurve, result);
	for ( int i = 0; i < roots; i++ ) {
		CGPoint p = WFGeometryEvaluateCubicCurve(result[i], curve);
		CGFloat distance = WFGeometryDistance2(point, p);
		if ( distance < WFGeometryPointResolution/4 ) return result[i];
	}
	return 0;
}

uint64_t WFGeometryFindRootsOfCubicCurve( CGPoint * curve, CGFloat * outTValues )
{
	uint16_t rootCount = 0;
	CGPoint derivative[3];
	const CGFloat step = 0.01;
	
	WFGeometryBezierDerivative( curve, derivative );
	
	CGFloat t = 0.0;
	while ( t < 1.0 ) {
		
		// Newton-Raphson to determine y intercept
		CGFloat z = t;
		uint64_t iterations = 0;
		CGPoint p = WFGeometryEvaluateCubicCurve( z, curve );
		while ( fabs(p.y) > WFGeometryPointResolution/4 && iterations < WFGeometryNewtonIterationLimit ) {
			// TODO: we could optimize this by only operating on the y coordinates of the curve
			CGPoint pp = WFGeometryEvaluateQuadraticCurve( z, derivative );
			if ( pp.y == 0.0 ) break; // We're at a stationary point... can't get anywhere from here. I hope the next starting guess works out better for you.
			z = z - p.y/pp.y;
			z = fmax(z, 0.0);
			z = fmin(z, 1.0);
			iterations++;
			p = WFGeometryEvaluateCubicCurve( z, curve );
		}
		
		// make sure we haven't already found this solution
		if ( fabs(p.y) <= WFGeometryPointResolution/4 && z >= 0.0 && z <= 1.0 ) {
			bool rootAlreadyFound = false;
			for ( uint64_t i = 0; i < rootCount; i++ ) {
				if ( fabs(outTValues[i]-z) < WFGeometryParametricResolution ) {
					rootAlreadyFound = true;
					break;
				}
			}
			if ( !rootAlreadyFound ) {
				outTValues[rootCount] = z;
				rootCount++;
			}
			if ( rootCount == 3 ) break;
		}
		
		t += step;
	}
	
	return rootCount;
}

uint64_t WFGeometryFindRootsOfQuadraticCurve( CGPoint * curve, CGFloat * outTValues )
{
	CGFloat A = curve[0].y - 2.0*curve[1].y + curve[2].y;
	CGFloat B = 2.0*(curve[1].y - curve[0].y);
	CGFloat C = curve[0].y;
	
	// Check if any real roots exist
	CGFloat root = B*B-4.0*A*C;
	if ( root < 0.0 ) return 0;
	
	// Compute t values for roots
	CGFloat t;
	uint64_t rootCount = 0;
	
	t = (-B + sqrt(root))/(2.0*A);
	if ( t >= 0.0 && t <= 1.0 ) {
		outTValues[rootCount] = t;
		rootCount++;
	}
	
	t = (-B - sqrt(root))/(2.0*A);
	if ( t >= 0.0 && t <= 1.0 ) {
		outTValues[rootCount] = t;
		rootCount++;
	}
	
	// Check if roots are distinct
	if ( rootCount == 2 ) {
		CGPoint p0 = WFGeometryEvaluateQuadraticCurve( outTValues[0], curve );
		CGPoint p1 = WFGeometryEvaluateQuadraticCurve( outTValues[1], curve );
		if ( WFGeometryDistance(p1, p0) < WFGeometryPointResolution ) return 1;
	}
	return rootCount;
}

CGPoint WFGeometryClosestPointToPointOnCurve( CGPoint point, const CGPoint * curve )
{
	CGFloat t = 0.0;
	CGPoint bestPoint;
	CGFloat result = CGFLOAT_MAX;
	
	while ( t <= 1.0 ) {
		CGPoint p = WFGeometryEvaluateCubicCurve( t, curve );
		CGFloat d2 = WFGeometryDistance2( p, point );
		if ( d2 < result ) {
			bestPoint = p;
			result = d2;
		}
		t += 0.005;
	}
	
	// TODO: could do a binary search around a small ~linear portion of the parametric space here to improve result
	return bestPoint;
}

CGPoint WFGeometryEvaluateCubicCurve( CGFloat t, const CGPoint * points )
{
	CGPoint result;
	result.x = points[0].x*pow(1.0-t, 3.0) + 3.0*points[1].x*pow(1.0-t, 2.0)*t + 3.0*points[2].x*(1.0-t)*t*t + points[3].x*t*t*t;
	result.y = points[0].y*pow(1.0-t, 3.0) + 3.0*points[1].y*pow(1.0-t, 2.0)*t + 3.0*points[2].y*(1.0-t)*t*t + points[3].y*t*t*t;
	return result;
}

CGRect WFGeometryCubicCurveBounds( const CGPoint * curve )
{
	CGFloat t;
	CGPoint deriv[3];
	CGPoint minimum = CGPointMake(fmin(curve[0].x,curve[3].x), fmin(curve[0].y,curve[3].y));
	CGPoint maximum = CGPointMake(fmax(curve[0].x,curve[3].x), fmax(curve[0].y,curve[3].y));
	
	WFGeometryBezierDerivative( curve, deriv );
	
	CGFloat A = deriv[0].y - 2.0*deriv[1].y + deriv[2].y;
	CGFloat B = 2.0*(deriv[1].y - deriv[0].y);
	CGFloat C = deriv[0].y;
	if ( fabs(A) < 1.0E-10 ) {
		// derivative is a line
		t = -C/B;
		if ( t >= 0.0 && t <= 1.0 ) {
			CGPoint p = WFGeometryEvaluateCubicCurve(t, curve);
			minimum.y = fmin(minimum.y,p.y);
			maximum.y = fmax(maximum.y,p.y);
		}
	} else {
		// Check if any real Y roots exist
		CGFloat root = B*B-4.0*A*C;
		if ( root >= 0.0 ) {
			// Compute roots
			t = (-B + sqrt(root))/(2.0*A);
			if ( t >= 0.0 && t <= 1.0 ) {
				CGPoint p = WFGeometryEvaluateCubicCurve(t, curve);
				minimum.y = fmin(minimum.y,p.y);
				maximum.y = fmax(maximum.y,p.y);
			}
			t = (-B - sqrt(root))/(2.0*A);
			if ( t >= 0.0 && t <= 1.0 ) {
				CGPoint p = WFGeometryEvaluateCubicCurve(t, curve);
				minimum.y = fmin(minimum.y,p.y);
				maximum.y = fmax(maximum.y,p.y);
			}
		}
	}
	
	A = deriv[0].x - 2.0*deriv[1].x + deriv[2].x;
	B = 2.0*(deriv[1].x - deriv[0].x);
	C = deriv[0].x;
	if ( fabs(A) < 1.0E-10 ) {
		// derivative is a line
		t = -C/B;
		if ( t >= 0.0 && t <= 1.0 ) {
			CGPoint p = WFGeometryEvaluateCubicCurve(t, curve);
			minimum.x = fmin(minimum.x,p.x);
			maximum.x = fmax(maximum.x,p.x);
		}
	} else {
		// Check if any real X roots exist
		CGFloat root = B*B-4.0*A*C;
		if ( root >= 0.0 ) {
			// Compute roots
			t = (-B + sqrt(root))/(2.0*A);
			if ( t >= 0.0 && t <= 1.0 ) {
				CGPoint p = WFGeometryEvaluateCubicCurve(t, curve);
				minimum.x = fmin(minimum.x,p.x);
				maximum.x = fmax(maximum.x,p.x);
			}
			t = (-B - sqrt(root))/(2.0*A);
			if ( t >= 0.0 && t <= 1.0 ) {
				CGPoint p = WFGeometryEvaluateCubicCurve(t, curve);
				minimum.x = fmin(minimum.x,p.x);
				maximum.x = fmax(maximum.x,p.x);
			}
		}
	}
	
	return CGRectMake(minimum.x, minimum.y, maximum.x-minimum.x, maximum.y-minimum.y);
}

CGPoint WFGeometryEvaluateQuadraticCurve( CGFloat t, const CGPoint * points )
{
	CGPoint result;
	CGFloat z = 1.0-t;
	result.x = points[0].x*z*z + 2.0*points[1].x*z*t + points[2].x*t*t;
	result.y = points[0].y*z*z + 2.0*points[1].y*z*t + points[2].y*t*t;
	return result;
}

CGPoint WFGeometryEvaluateLine( CGFloat t, CGPoint linePtA, CGPoint linePtB )
{
	CGPoint delta = CGPointMake(linePtB.x-linePtA.x, linePtB.y-linePtA.y);
	return CGPointMake(linePtA.x+t*delta.x, linePtA.y+t*delta.y);
}

CGPoint WFGeometryClosestPointToPointOnLine( CGPoint point, CGPoint pointA, CGPoint pointB )
{
	CGFloat t;
	CGFloat norm;
	CGPoint delta;
	CGPoint result;
	
	delta.x = pointB.x - pointA.x;
	delta.y = pointB.y - pointA.y;
	norm = delta.x*delta.x + delta.y*delta.y;
	
	t = ((point.x-pointA.x)*delta.x + (point.y-pointA.y)*delta.y)/norm;
	t = fmin(fmax(t,0.0),1.0);
	result.x = pointA.x+t*delta.x;
	result.y = pointA.y+t*delta.y;
	return result;
}

bool WFGeometryRectIntersectsLine( CGRect rect, CGPoint pointA, CGPoint pointB )
{
	CGFloat dx, dy;
	CGFloat q[4];
	CGFloat p[4];
	CGFloat u1, u2;
	
	dx = pointB.x - pointA.x;
	dy = pointB.y - pointA.y;
	
	p[0] = -dx;
	q[0] = pointA.x - CGRectGetMinX( rect );
	p[1] = dx;
	q[1] = CGRectGetMaxX( rect ) - pointA.x;
	p[2] = -dy;
	q[2] = pointA.y - CGRectGetMinY( rect );
	p[3] = dy;
	q[3] = CGRectGetMaxY( rect ) - pointA.y;
	
	u1 = 0.0;
	u2 = 1.0;
	for( int k=0; k<4; k++ ) {
		if ( p[k] != 0.0 ) {
			if ( p[k] <= 0.0) {
				u1 = fmax( q[k]/p[k], u1 );
			} else {
				u2 = fmin( q[k]/p[k], u2 );
			}
		} else {
			if ( q[k] < 0.0 ) {
				return false;
			}
		}
	}
	return ( u1 <= u2 );
}

bool WFGeometryLineIntersectsLine( CGPoint pt1, CGPoint pt2, CGPoint pt3, CGPoint pt4 )
{
	CGFloat den = (pt4.y-pt3.y)*(pt2.x-pt1.x) - (pt4.x-pt3.x)*(pt2.y-pt1.y);
	CGFloat ka = ((pt4.x-pt3.x)*(pt1.y-pt3.y) - (pt4.y-pt3.y)*(pt1.x-pt3.x))/den;
	CGFloat kb = ((pt2.x-pt1.x)*(pt1.y-pt3.y) - (pt2.y-pt1.y)*(pt1.x-pt3.x))/den;
	return ka >= 0.0 && ka <= 1.0 && kb >= 0.0 && kb <= 1.0;
}

bool WFGeometryLineToLineIntersection( CGPoint pt1, CGPoint pt2, CGPoint pt3, CGPoint pt4, CGFloat * outT1, CGFloat * outT2 )
{
	CGFloat den = (pt4.y-pt3.y)*(pt2.x-pt1.x) - (pt4.x-pt3.x)*(pt2.y-pt1.y);
	CGFloat ka = ((pt4.x-pt3.x)*(pt1.y-pt3.y) - (pt4.y-pt3.y)*(pt1.x-pt3.x))/den;
	CGFloat kb = ((pt2.x-pt1.x)*(pt1.y-pt3.y) - (pt2.y-pt1.y)*(pt1.x-pt3.x))/den;
	if ( ka >= 0.0 && ka <= 1.0 && kb >= 0.0 && kb <= 1.0 ) {
		*outT1 = ka;
		*outT2 = kb;
		return true;
	}
	return false;
}

bool WFGeometryLineIntersectsCurve( CGPoint pt1, CGPoint pt2, const CGPoint * curve )
{
	CGFloat rotation = atan2( pt2.y-pt1.y, pt2.x-pt1.x );
	CGFloat rcos = cos(rotation);
	CGFloat rsin = sin(rotation);
	
	CGPoint tempCurve[4];
	
	// translate and rotate curve starting point to origin
	for ( uint64_t i = 0; i < 4; i++ ) {
		tempCurve[i].x = curve[i].x - pt1.x;
		tempCurve[i].y = curve[i].y - pt1.y;
		tempCurve[i].x = tempCurve[i].x*rcos - tempCurve[i].y*rsin;
		tempCurve[i].y = tempCurve[i].x*rsin + tempCurve[i].y*rcos;
	}
		
	// find zeros of the curve
	CGFloat curveHits[3];
	return WFGeometryFindRootsOfCubicCurve( tempCurve, curveHits ) > 0;
}

uint64_t WFGeometryLineCurveIntersection( CGPoint pt1, CGPoint pt2, const CGPoint * curve, CGFloat * outT1Array, CGFloat * outT2Array )
{
	CGFloat rotation = -atan2( pt2.y-pt1.y, pt2.x-pt1.x );
	CGFloat rcos = cos(rotation);
	CGFloat rsin = sin(rotation);
	uint64_t hits = 0;
	CGPoint tempCurve[4];
	
	// translate and rotate curve starting point to origin
	for ( uint64_t i = 0; i < 4; i++ ) {
		tempCurve[i].x = curve[i].x - pt1.x;
		tempCurve[i].y = curve[i].y - pt1.y;
		CGFloat newX = tempCurve[i].x*rcos - tempCurve[i].y*rsin;
		tempCurve[i].y = tempCurve[i].x*rsin + tempCurve[i].y*rcos;
		tempCurve[i].x = newX;
	}
	
	// translate and rotate the line to the x axis
	pt2.x -= pt1.x;
	pt2.y -= pt1.y;
	CGFloat axisLinePt = pt2.x*rcos - pt2.y*rsin;
	CGFloat tempTArray[3];
	
	// find zeros of the curve
	uint64_t tempHits = WFGeometryFindRootsOfCubicCurve( tempCurve, tempTArray );
	
	// keep the zeros of the rotated curve that are also on the line segment
	for ( uint64_t i = 0; i < tempHits; i++ ) {
		CGPoint p = WFGeometryEvaluateCubicCurve( tempTArray[i], tempCurve );
		outT1Array[hits] = p.x/axisLinePt;
		if ( outT1Array[hits] >= 0.0 && outT1Array[hits] <= 1.0 ) {
			outT2Array[hits] = tempTArray[i];
			hits++;
		}
	}
	
	return hits;
}

uint64_t WFGeometryCurveCurveIntersection( const CGPoint * curveA, const CGPoint * curveB, CGFloat * outT1Array, CGFloat * outT2Array )
{
	return WFGeometryCurveCurveIntersection_Recursive( curveA, curveB, outT1Array, outT2Array, 0.5, 0.5, 1, 0 );
}

uint64_t WFGeometryCurveCurveIntersection_Recursive( const CGPoint * curveA, const CGPoint * curveB, CGFloat * outT1Array, CGFloat * outT2Array, CGFloat tA, CGFloat tB, uint64_t depth, uint64_t resultCount )
{
	if ( resultCount == 6 ) return 0;
	
	CGRect boundsA = WFGeometryCubicCurveBounds( curveA );
	CGRect boundsB = WFGeometryCubicCurveBounds( curveB );
	
	// If curve bounds don't intersect, exit.
	if ( !CGRectIntersectsRect(boundsA, boundsB) && !CGRectContainsRect(boundsA, boundsB) && !CGRectContainsRect(boundsB, boundsA) ) return 0;
	
	// If curve bounds are small enough, we have found an intersection
	if ( boundsA.size.width < WFGeometryPointResolution/4 &&
		boundsA.size.height < WFGeometryPointResolution/4 &&
		boundsB.size.width < WFGeometryPointResolution/4 &&
		boundsB.size.height < WFGeometryPointResolution/4 ) {
		
		for ( int i = 0; i < resultCount; i++ ) {
			if ( fabs(tA-outT1Array[i]) < WFGeometryParametricResolution ) return 0;
			if ( fabs(tB-outT2Array[i]) < WFGeometryParametricResolution ) return 0;
		}
		outT1Array[resultCount] = tA;
		outT2Array[resultCount] = tB;
		return 1;
	}
	
	// Split curves and recursively check sub-curves for intersection
	uint64_t result = 0;
	CGFloat delta = pow( 0.5, depth+1 );
	CGPoint curveAA[4];
	CGPoint curveAB[4];
	WFGeometrySplitCubicCurve(0.5, curveA, curveAA, curveAB);
	CGPoint curveBA[4];
	CGPoint curveBB[4];
	WFGeometrySplitCubicCurve(0.5, curveB, curveBA, curveBB);
	result += WFGeometryCurveCurveIntersection_Recursive( curveAA, curveBA, outT1Array, outT2Array, tA-delta, tB-delta, depth+1, result+resultCount );
	result += WFGeometryCurveCurveIntersection_Recursive( curveAB, curveBA, outT1Array, outT2Array, tA+delta, tB-delta, depth+1, result+resultCount );
	result += WFGeometryCurveCurveIntersection_Recursive( curveAA, curveBB, outT1Array, outT2Array, tA-delta, tB+delta, depth+1, result+resultCount );
	result += WFGeometryCurveCurveIntersection_Recursive( curveAB, curveBB, outT1Array, outT2Array, tA+delta, tB+delta, depth+1, result+resultCount );
	
	return result;
}

void WFGeometryReverseCubicCurve( CGPoint * curve )
{
	CGPoint temp;
	temp = curve[0];
	curve[0] = curve[3];
	curve[3] = temp;
	temp = curve[1];
	curve[1] = curve[2];
	curve[2] = temp;
}

bool WFGeometryVectorsOnSameSideOfLine( CGPoint lineVector, CGPoint v1, CGPoint v2 )
{
	CGFloat za = WFGeometryDeterminant2x2( v1.x, v1.y, lineVector.x, lineVector.y );
	CGFloat zb = WFGeometryDeterminant2x2( v2.x, v2.y, lineVector.x, lineVector.y );
	return (za > 0.0 && zb > 0.0) || (za < 0.0 && zb < 0.0);
}

bool WFGeometryVectorsCoincident( CGPoint lineVector, CGPoint v1, CGPoint v2 )
{
	WFGeometryNormalizeVector( &v1 );
	CGFloat z = WFGeometryDeterminant2x2( v1.x, v1.y, lineVector.x, lineVector.y );
	if ( fabs(z) < 1.0E-16 ) return true;
	
	WFGeometryNormalizeVector( &v2 );
	z = WFGeometryDeterminant2x2( v2.x, v2.y, lineVector.x, lineVector.y );
	if ( fabs(z) < 1.0E-16 ) return true;
	
	return false;
}


bool WFGeometryVectorsCrossCorner( CGPoint v1, CGPoint v2, CGPoint v3, CGPoint v4 )
{
	WFGeometryNormalizeVector( &v1 );
	WFGeometryNormalizeVector( &v2 );
	WFGeometryNormalizeVector( &v3 );
	WFGeometryNormalizeVector( &v4 );
	
	CGFloat innerAngle = WFGeometryDeterminant2x2( v3.x, v3.y, v4.x, v4.y );
	
	if ( innerAngle > 0 ) {
		CGFloat a;
		a = WFGeometryDeterminant2x2( v3.x, v3.y, v1.x, v1.y );
		if ( a > 0 && a < innerAngle ) return true;
		a = WFGeometryDeterminant2x2( v3.x, v3.y, v2.x, v2.y );
		if ( a > 0 && a < innerAngle ) return true;
	} else {
		CGFloat a;
		a = WFGeometryDeterminant2x2( v3.x, v3.y, v1.x, v1.y );
		if ( a < 0 && a > innerAngle ) return true;
		a = WFGeometryDeterminant2x2( v3.x, v3.y, v2.x, v2.y );
		if ( a < 0 && a > innerAngle ) return true;
	}
	
	return false;
}

void WFGeometryNormalizeVector( CGPoint * v )
{
	CGFloat mag = sqrt( v->x*v->x + v->y*v->y );
	v->x /= mag;
	v->y /= mag;
}


