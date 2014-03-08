//
//  WFGeometry.h
//
//  Created by Noah Desch on 12/27/13.
//  Copyright (c) 2013 Noah Desch.
//

#ifndef _WFGeometry_h
#define _WFGeometry_h

#include <CoreGraphics/CGGeometry.h>

// Distance below which two points may be considered coincident by some algorithms
#define WFGeometryPointResolution (1.0E-8)

// Distance below which two parametric values may be considered coincident by some algorithms
#define WFGeometryParametricResolution (1.0E-8)

// Iteration limit for Newton-Raphson root finding
#define WFGeometryNewtonIterationLimit 100


/** Computes determinant for 2x2 matrix:
 [a,b]
 [c,d]
 */
#define WFGeometryDeterminant2x2( a, b, c, d ) ((a)*(d)-(b)*(c))


/** Computes squared distance between 2 points
 @param pointA First point
 @param pointB Second point
 @return Distance between pointA and pointB
 */
#define WFGeometryDistance2( pointA, pointB ) (pointA.x-pointB.x)*(pointA.x-pointB.x) + (pointA.y-pointB.y)*(pointA.y-pointB.y)


/** Computes distance between 2 points
 @param pointA First point
 @param pointB Second point
 @return Distance between pointA and pointB
 */
#define WFGeometryDistance( pointA, pointB ) sqrt((pointA.x-pointB.x)*(pointA.x-pointB.x) + (pointA.y-pointB.y)*(pointA.y-pointB.y))


/** Computes determinant of a 3x3 matrix
 @param matrix The matrix whose determinant will be computed. Must be a row-major matrix with 9 elements.
 */
CGFloat WFGeometryDeterminant3x3( CGFloat ** matrix );


/** Computes the derivate of a cubic bezier curve (which is a quadratic bezier curve).
 @param input The input cubic bezier curve. Must contain 4 points.
 @param output The output bezier curve. Must contain space for at least 3 points.
 */
void WFGeometryBezierDerivative( const CGPoint * input, CGPoint * output );


/** Computes the derivate of a bezier curve (which is also a bezier curve). A curve's derivative is one order lower than the original curve so in this case the output will be a quadratic curve.
 @param input The input quadratic bezier curve. Must contain 3 points.
 @param output The output bezier curve. Must contain space for at least 2 points.
 */
void WFGeometryQuadraticBezierDerivative( const CGPoint * input, CGPoint * output );


/** Computes shortest distance from a point to a line segment
 @param point The lone point
 @param pointA First point on line segment
 @param pointB Second point on line segment
 @return Shortest distance from point to a line segment through pointA and pointB
 */
CGFloat WFGeometryDistanceFromPointToLine( CGPoint point, CGPoint pointA, CGPoint pointB );


/** Computes shortest distance from a point to a cubic bezier curve
 @param point The lone point
 @param Array of control points of a cubic beier curve. Must contain 4 points.
 @return Shortest distance from point to a cubic bezier curve.
 */
CGFloat WFGeometryDistanceFromPointToCurve( CGPoint point, const CGPoint * curve );


/** Splits a cubic bezier curve at parametric point t into two separate cubic curves.
 @param t The parametric point along the input curve at which it will be split
 @param curve The curve to split
 @param outCurve1 The output curve that will go from 0 to t. Must have space for at least 4 CGPoints.
 @param outCurve2 The output curve that will to from t to 1.0. Must have space for at least 4 CGPoints.
 */
void WFGeometrySplitCubicCurve( CGFloat t, const CGPoint * curve, CGPoint * outCurve1, CGPoint * outCurve2 );


/** Determines the parametric value at which a curve intersects a given point on the curve.
 @param curve The cubic bezier curve
 @param point A point on the curve
 @return The parametric value at which curve intersects with point
 */
CGFloat WFGeometryParameterForCubicCurvePoint( const CGPoint * curve, CGPoint point );


/** Finds roots of a cubic bezier curve (where the curve's y value = 0).
 @param curve The control points of the cubic bezier curve. Must contain 4 values.
 @param outTValues On return, contains the parametric values where the curve intersects the x axis. This must have enough space to hold 3 values.
 @return The number of roots. There are a maximum of 3 roots for a cubic curve.
 */
uint64_t WFGeometryFindRootsOfCubicCurve( CGPoint * curve, CGFloat * outTValues );


/** Finds roots of a quadratic bezier curve (where the curve's y value = 0).
 @param curve The control points of the cubic bezier curve. Must contain 3 values.
 @param outTValues On return, contains the parametric values where the curve intersects the x axis. This must have enough space to hold 2 values.
 @return The number of roots. There are a maximum of 2 roots for a quadratic curve.
 */
uint64_t WFGeometryFindRootsOfQuadraticCurve( CGPoint * curve, CGFloat * outTValues );


/** Calculates the point on a cubic bezier curve for the given t value.
 @param t Parametric curve value between 0 and 1.
 @param point Control points of the bezier curve. Must contain 4 values.
 */
CGPoint WFGeometryEvaluateCubicCurve( CGFloat t, const CGPoint * points );


/** Calculates the axis-aligned bounding box of a cubic curve, not including the control points.
 @param curve A cubic curve
 @return The axis-aligned bounding box that encloses all points on the curve.
 */
CGRect WFGeometryCubicCurveBounds( const CGPoint * curve );


/** Calculates the point on a quadratic bezier curve for the given t value.
 @param t Parametric curve value between 0 and 1.
 @param point Control points of the bezier curve. Must contain 3 values.
 */
CGPoint WFGeometryEvaluateQuadraticCurve( CGFloat t, const CGPoint * points );


/** Calculates the point on a line for the given t value.
 @param t Parametric line value between 0 and 1.
 @param linePtA First point on line segment
 @param linePtB Second point on line segment
 */
CGPoint WFGeometryEvaluateLine( CGFloat t, CGPoint linePtA, CGPoint linePtB );


/** Finds the point on a line segment that is closest to another point not on the line.
 @param point The lone point
 @param pointA First point on line segment
 @param pointB Second point on line segment
 @return Point on line segment between pointA and pointB that is closest to point.
 */
CGPoint WFGeometryClosestPointToPointOnLine( CGPoint point, CGPoint pointA, CGPoint pointB );


/** Finds the point on a bezier curve that is closest to another point not on the curve.
 @param point The lone point
 @param curve The cubic bezier curve points. Must hold 4 points.
 @return Point on bezier curve that is closest to point.
 */
CGPoint WFGeometryClosestPointToPointOnCurve( CGPoint point, const CGPoint * curve );


/** Determines if line segment and axis-aligned-rectangle intersect.
 @param rect The axis aligned rectangle
 @param pointA First point on line segment
 @param pointB Second point on line segment
 @return true if the line segment intersects the rectangle, false otherwise.
 */
bool WFGeometryRectIntersectsLine( CGRect rect, CGPoint pointA, CGPoint pointB );

/** Determines if two line segments intersect
 @param line1A First point on first line segment
 @param line1B Second point on first line segment
 @param line2A First point on second line segment
 @param line2B Second point on second line segment
 */
bool WFGeometryLineIntersectsLine( CGPoint line1A, CGPoint line1B, CGPoint line2A, CGPoint line2B );

/** Determines if two line segments intersect and returns the parametric value along each line where the intersect occurrs.
 @param line1A First point on first line segment
 @param line1B Second point on first line segment
 @param line2A First point on second line segment
 @param line2B Second point on second line segment
 @param outT1 Intersect point parameter along first line
 @param outT2 Intersect point parameter along second line
 */
bool WFGeometryLineToLineIntersection( CGPoint pt1, CGPoint pt2, CGPoint pt3, CGPoint pt4, CGFloat * outT1, CGFloat * outT2 );


/** Determines if a line segment intersects a cubic bezier curve
 @param line1A First point on first line segment
 @param line1B Second point on first line segment
 @param curve Curve control points. Must contain 4 elements.
 */
bool WFGeometryLineIntersectsCurve( CGPoint line1A, CGPoint line1B, const CGPoint * curve );


/** Finds the intersection points between a line and a cubic bezier curve
 @param line1A First point on the line segment
 @param line1B Second point on the line segment
 @param curve Curve control points. Must contain 4 elements.
 @param outT1Array Array of t values along the line at which intersections with the curve were found. Must contain 3 elements.
 @param outT2Array Array of t values along the curve at which intersections with the line were found. Must contain 3 elements.
 @return The number of intersections found. Up to 3 intersections can occur between a line and a cubic curve.
 */
uint64_t WFGeometryLineCurveIntersection( CGPoint line1A, CGPoint line1B, const CGPoint * curve, CGFloat * outT1Array, CGFloat * outT2Array );



/** Finds the intersection points between two cubic bezier curves
 @param curveA First cubic bezier curve
 @param curveB Second cubic bezier curve
 @param outT1Array Array of t values along curveA at which intersections were found. Must contain 6 elements.
 @param outT2Array Array of t values along the curve at which intersections with the line were found. Must contain 6 elements.
 @return The number of intersections found. Up to 6 intersections can occur between two cubic curves.
 */
uint64_t WFGeometryCurveCurveIntersection( const CGPoint * curveA, const CGPoint * curveB, CGFloat * outT1Array, CGFloat * outT2Array );


/** Reverses a cubic bezier curve.
 @param curve The curve to reverse. Must contain 4 points. On return, the points will be in reverse order.
 */
void WFGeometryReverseCubicCurve( CGPoint * curve );


/** Determines if two vectors point out of the same side or opposite side of a line
 @param lineVector The vector of the line
 @param v1 First vector to test
 @param v2 Second vector to test
 @return true if both vectors point out of the same side of the line, false otherwise. If one or both vectors are exactly parallel to the line the result is undefined.
 */
bool WFGeometryVectorsOnSameSideOfLine( CGPoint lineVector, CGPoint v1, CGPoint v2 );

/** Determines if a polygon corner is crossed by a corner formed by another polygon
 @param v1
 @param v2
 @param v3
 @param v4
 @return if the corner formed by v1 and v2 and crossed by the corner formed by v3 and v4, returns YES. Otherwise returns NO. If any vector is parallel to any other vector, the result is undefined.
 */
bool WFGeometryVectorsCrossCorner( CGPoint v1, CGPoint v2, CGPoint v3, CGPoint v4 );


/** Normalizes a 2D vector in a CGPoint */
void WFGeometryNormalizeVector( CGPoint * v );

#endif
