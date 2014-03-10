//
//  NSBezierPath+WFBezierCombinatorics.m
//
//  Created by Noah Desch on 1/20/2014.
//  Copyright (c) 2014 Noah Desch.
//

#import "NSBezierPath+WFBezierCombinatorics.h"
#import "WFGeometry.h"

#define WFBezierFlag_PathA				(1<<0)		// Node is on path A
#define WFBezierFlag_PathB				(1<<1)		// Node is on path B
#define WFBezierFlag_SubPathStartA		(1<<2)		// Node is the beginning of a sub-path of path A
#define WFBezierFlag_SubPathStartB		(1<<3)		// Node is the beginning of a sub-path of path B
#define WFBezierFlag_SubPathEndA		(1<<4)		// Node is the end of a sub-path of path A
#define WFBezierFlag_SubPathEndB		(1<<5)		// Node is the end of a sub-path of path B
#define WFBezierFlag_OriginalEndptA		(1<<6)		// Node is an original endpoint from the input path A
#define WFBezierFlag_OriginalEndptB		(1<<7)		// Node is an original endpoint from the input path B

#define WFBezierFlag_ParallelIntersect	(1<<10)		// Node is an intersection on a segment where edges from path A and B are parallel
#define WFBezierFlag_ShouldInvalidate	(1<<11)		// Vertex is considered invalid and should be skipped over when reconstructing the path
#define WFBezierFlag_Coincident			(1<<12)		// Vertex is an original polygon corner that is coincident with the other polygon
#define WFBezierFlag_PointInvalid		(1<<13)		// Vertex is considered invalid and should be skipped over when reconstructing the path
#define WFBezierFlag_PointUsed			(1<<14)		// Vertex has been used in path reconstruction



#define WFNodeIsOnBothPaths(node) (((node)->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB)) == (WFBezierFlag_PathA|WFBezierFlag_PathB))


#define WFBezierTraversal_IgnoreParallelIntersections	(1<<0)	// traversal algorithm will ignore special cases for parallel intersections.
#define WFBezierTraversal_DontSkipParallelIntersections	(1<<1)	// traversal algorithm will not attempt to skip parallel edge intersections to optimise output.
#define WFBezierTraversal_InvertParallelPathSwitch		(1<<2)	// traversal algorithm will invert the creteria used to switch paths from parallel intersect points.


typedef struct {
	CGPoint		intersectionPoint;	// X,Y location of the node (even if it isn't an intersection)
	CGPoint		controlPointsA[4];	// Control points of the element on pathA that this node is a part of
	CGPoint		controlPointsB[4];	// Control points of the element on pathB that this node is a part of
	CGFloat		pathA_t;			// Parametric value of this node in the overall sub-polygon of pathA that is is a part of
	CGFloat		pathB_t;			// Parametric value of this node in the overall sub-polygon of pathB that is is a part of
	NSBezierPathElement	elementA;	// bezier path element type of the element on path A that contains this node
	NSBezierPathElement	elementB;	// bezier path element type of the element on path B that contains this node
	int64_t		subPathOriginA;		// index of the base vertex array of the node that starts the current sub-path of NSBezierPath A
	int64_t		subPathEndA;		// index of the base vertex array of the node that ends the current sub-path of NSBezierPath A
	int64_t		subPathOriginB;		// index of the base vertex array of the node that starts the current sub-path of NSBezierPath B
	int64_t		subPathEndB;		// index of the base vertex array of the node that ends the current sub-path of NSBezierPath B
	int64_t		pathAIndex;			// index in the A chain of this node
	int64_t		pathBIndex;			// index in the B chain of this node
	uint16_t	flags;
} WFBezierVertexNode;


typedef struct {
	size_t		indexCount;
	NSUInteger	indexes[];
} WFBezierIndexChain;


#pragma mark - Static C Functions

CGPoint midPointBetweenNodes( WFBezierVertexNode * a, WFBezierVertexNode * b, BOOL isPathA );
BOOL parallelIntersectNodeIsInsideUnion( WFBezierVertexNode * origin, WFBezierVertexNode * vertices, WFBezierIndexChain * indexedPathA, WFBezierIndexChain * indexedPathB );
BOOL parallelIntersectNodeIsEnteringUnion( WFBezierVertexNode * origin, WFBezierVertexNode * vertices, WFBezierIndexChain * indexedPathA, WFBezierIndexChain * indexedPathB, BOOL isPathA );
WFBezierVertexNode * findMoveToNodeOverlappingNode( WFBezierVertexNode * origin, WFBezierVertexNode * vertices, NSUInteger vertexCount, BOOL isPathA );
WFBezierVertexNode * nodeOnIndexPathAfterNode( WFBezierVertexNode * origin, WFBezierVertexNode * vertices, WFBezierIndexChain * path, BOOL isPathA );
WFBezierVertexNode * nextNonRedundantNode( WFBezierVertexNode * origin, WFBezierVertexNode * vertices, WFBezierIndexChain * path, BOOL isPathA );
WFBezierVertexNode * previousNonRedundantNode( WFBezierVertexNode * origin, WFBezierVertexNode * vertices, WFBezierIndexChain * path, BOOL isPathA );
WFBezierVertexNode * nodeOnIndexPathBeforeNode( WFBezierVertexNode * origin, WFBezierVertexNode * vertices, WFBezierIndexChain * path, BOOL isPathA );
WFBezierVertexNode * originalVertexOverlappingNode( WFBezierVertexNode * origin, WFBezierVertexNode * vertices, WFBezierIndexChain * path, BOOL isPathA );
WFBezierVertexNode * intersectionOverlappingNodeIfExists( WFBezierVertexNode * origin, WFBezierVertexNode * vertices, WFBezierIndexChain * path, BOOL isPathA );
void sortIndexPaths(WFBezierVertexNode * vertices, NSUInteger vertexCount, WFBezierIndexChain * indexedPathA_p, WFBezierIndexChain * indexedPathB_p);

CGPoint midPointBetweenNodes( WFBezierVertexNode * a, WFBezierVertexNode * b, BOOL isPathA )
{
	switch ( (isPathA)?b->elementA:b->elementB ) {
		case NSClosePathBezierPathElement:
		case NSLineToBezierPathElement:
		case NSMoveToBezierPathElement:
			return CGPointMake( (b->intersectionPoint.x+a->intersectionPoint.x)/2.0, (b->intersectionPoint.y+a->intersectionPoint.y)/2.0 );
		
		default: {
			CGFloat curveT = (isPathA)?(a->pathA_t + b->pathA_t)/2.0:(a->pathB_t + b->pathB_t)/2.0;
			curveT -= floor( curveT );
			return WFGeometryEvaluateCubicCurve( curveT, (isPathA)?b->controlPointsA:b->controlPointsB );
		}
	}
}

BOOL parallelIntersectNodeIsInsideUnion( WFBezierVertexNode * origin, WFBezierVertexNode * vertices, WFBezierIndexChain * indexedPathA, WFBezierIndexChain * indexedPathB )
{
	assert((origin->flags & WFBezierFlag_ParallelIntersect));
	WFBezierVertexNode * nextNodeA;
	WFBezierVertexNode * nextNodeB;
	
	nextNodeA = nodeOnIndexPathAfterNode( origin, vertices, indexedPathA, YES );
	if ( (nextNodeA->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB)) != (WFBezierFlag_PathA|WFBezierFlag_PathB) && !(nextNodeA->flags & WFBezierFlag_ParallelIntersect) ) return NO;
	nextNodeB = nodeOnIndexPathAfterNode( origin, vertices, indexedPathB, NO );
	if ( (nextNodeB->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB)) != (WFBezierFlag_PathA|WFBezierFlag_PathB) && !(nextNodeB->flags & WFBezierFlag_ParallelIntersect) ) return NO;
	if ( nextNodeA == nextNodeB ) return NO;
	
	nextNodeA = nodeOnIndexPathBeforeNode( origin, vertices, indexedPathA, YES );
	if ( (nextNodeA->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB)) != (WFBezierFlag_PathA|WFBezierFlag_PathB) && !(nextNodeA->flags & WFBezierFlag_ParallelIntersect) ) return NO;
	nextNodeB = nodeOnIndexPathBeforeNode( origin, vertices, indexedPathB, NO );
	if ( (nextNodeB->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB)) != (WFBezierFlag_PathA|WFBezierFlag_PathB) && !(nextNodeB->flags & WFBezierFlag_ParallelIntersect) ) return NO;
	if ( nextNodeA == nextNodeB ) return NO;
	
	return YES;
}


BOOL parallelIntersectNodeIsEnteringUnion( WFBezierVertexNode * origin, WFBezierVertexNode * vertices, WFBezierIndexChain * indexedPathA, WFBezierIndexChain * indexedPathB, BOOL isPathA )
{
	assert((origin->flags & WFBezierFlag_ParallelIntersect));
	if ( isPathA ) {
		WFBezierVertexNode * nextNodeA = nodeOnIndexPathAfterNode( origin, vertices, indexedPathA, YES );
		if ( !(nextNodeA->flags & WFBezierFlag_ParallelIntersect) ) return NO;
		WFBezierVertexNode * subsequentNodeB = nodeOnIndexPathAfterNode( nextNodeA, vertices, indexedPathB, NO );
		if ( subsequentNodeB == origin ) return YES;
		if ( (nextNodeA->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB)) != (WFBezierFlag_PathA|WFBezierFlag_PathB) ) return NO;
		return parallelIntersectNodeIsInsideUnion(nextNodeA, vertices, indexedPathA, indexedPathB );
	} else {
		WFBezierVertexNode * nextNodeB = nodeOnIndexPathAfterNode( origin, vertices, indexedPathB, NO );
		if ( !(nextNodeB->flags & WFBezierFlag_ParallelIntersect) ) return NO;
		WFBezierVertexNode * subsequentNodeA = nodeOnIndexPathAfterNode( nextNodeB, vertices, indexedPathA, YES );
		if ( subsequentNodeA == origin ) return YES;
		if ( (nextNodeB->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB)) != (WFBezierFlag_PathA|WFBezierFlag_PathB) ) return NO;
		return parallelIntersectNodeIsInsideUnion(nextNodeB, vertices, indexedPathA, indexedPathB );
	}
}

WFBezierVertexNode * findMoveToNodeOverlappingNode( WFBezierVertexNode * origin, WFBezierVertexNode * vertices, NSUInteger vertexCount, BOOL isPathA )
{
	for ( NSUInteger i = 0; i < vertexCount; i++ ) {
		WFBezierVertexNode * node = &vertices[i];
		if ( node->flags & WFBezierFlag_ShouldInvalidate ) continue;
		if ( isPathA ) {
			if ( node->elementA == NSMoveToBezierPathElement &&
				WFGeometryDistance(origin->intersectionPoint, node->intersectionPoint) < WFGeometryPointResolution ) {
				return node;
			}
		} else {
			if ( node->elementB == NSMoveToBezierPathElement &&
				WFGeometryDistance(origin->intersectionPoint, node->intersectionPoint) < WFGeometryPointResolution ) {
				return node;
			}
		}
	}
	return NULL;
}

WFBezierVertexNode * originalVertexOverlappingNode( WFBezierVertexNode * origin, WFBezierVertexNode * vertices, WFBezierIndexChain * path, BOOL isPathA )
{
	WFBezierVertexNode * result = nodeOnIndexPathAfterNode( origin, vertices, path, isPathA );
	while ( WFGeometryDistance( origin->intersectionPoint, result->intersectionPoint ) < WFGeometryPointResolution ) {
		if ( (result->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB)) == (isPathA)?(WFBezierFlag_PathA):(WFBezierFlag_PathB) ) {
			return result;
		}
		result = nodeOnIndexPathAfterNode( result, vertices, path, isPathA );
	}
	result = nodeOnIndexPathBeforeNode( origin, vertices, path, isPathA );
	while ( WFGeometryDistance( origin->intersectionPoint, result->intersectionPoint ) < WFGeometryPointResolution ) {
		if ( (result->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB)) == (isPathA)?(WFBezierFlag_PathA):(WFBezierFlag_PathB) ) {
			return result;
		}
		result = nodeOnIndexPathBeforeNode( result, vertices, path, isPathA );
	}
	return NULL;
}

WFBezierVertexNode * intersectionOverlappingNodeIfExists( WFBezierVertexNode * origin, WFBezierVertexNode * vertices, WFBezierIndexChain * path, BOOL isPathA )
{
	WFBezierVertexNode * result = nodeOnIndexPathAfterNode( origin, vertices, path, isPathA );
	while ( WFGeometryDistance( origin->intersectionPoint, result->intersectionPoint ) < WFGeometryPointResolution ) {
		if ( (result->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB)) == (WFBezierFlag_PathA|WFBezierFlag_PathB) ) {
			return result;
		}
		result = nodeOnIndexPathAfterNode( result, vertices, path, isPathA );
	}
	result = nodeOnIndexPathBeforeNode( origin, vertices, path, isPathA );
	while ( WFGeometryDistance( origin->intersectionPoint, result->intersectionPoint ) < WFGeometryPointResolution ) {
		if ( (result->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB)) == (WFBezierFlag_PathA|WFBezierFlag_PathB) ) {
			return result;
		}
		result = nodeOnIndexPathBeforeNode( result, vertices, path, isPathA );
	}
	return origin;
}

WFBezierVertexNode * nextNonRedundantNode( WFBezierVertexNode * origin, WFBezierVertexNode * vertices, WFBezierIndexChain * path, BOOL isPathA )
{
	WFBezierVertexNode * result = nodeOnIndexPathAfterNode( origin, vertices, path, isPathA );
	while ( WFGeometryDistance( origin->intersectionPoint, result->intersectionPoint ) < WFGeometryPointResolution ) {
		result = nodeOnIndexPathAfterNode( result, vertices, path, isPathA );
		if ( result == origin ) return NULL; // we came back around to the origin so all points on this sub-path are redundant
	}
	return result;
}

WFBezierVertexNode * previousNonRedundantNode( WFBezierVertexNode * origin, WFBezierVertexNode * vertices, WFBezierIndexChain * path, BOOL isPathA )
{
	WFBezierVertexNode * result = nodeOnIndexPathBeforeNode( origin, vertices, path, isPathA );
	while ( WFGeometryDistance( origin->intersectionPoint, result->intersectionPoint ) < WFGeometryPointResolution ) {
		result = nodeOnIndexPathBeforeNode( result, vertices, path, isPathA );
		if ( result == origin ) return NULL; // we came back around to the origin so all points on this sub-path are redundant
	}
	return result;
}

WFBezierVertexNode * nodeOnIndexPathAfterNode( WFBezierVertexNode * origin, WFBezierVertexNode * vertices, WFBezierIndexChain * path, BOOL isPathA )
{
	WFBezierVertexNode * result = NULL;
	if ( isPathA ) {
		if ( origin->flags & WFBezierFlag_SubPathEndA ) result = &vertices[origin->subPathOriginA];
		else result = &vertices[path->indexes[origin->pathAIndex+1]];
	} else {
		if ( origin->flags & WFBezierFlag_SubPathEndB ) result = &vertices[origin->subPathOriginB];
		else result = &vertices[path->indexes[origin->pathBIndex+1]];
	}
	if ( result->flags & WFBezierFlag_PointInvalid ) return nodeOnIndexPathAfterNode( result, vertices, path, isPathA );
	return result;
}

WFBezierVertexNode * nodeOnIndexPathBeforeNode( WFBezierVertexNode * origin, WFBezierVertexNode * vertices, WFBezierIndexChain * path, BOOL isPathA )
{
	WFBezierVertexNode * result = NULL;
	if ( isPathA ) {
		if ( origin->flags & WFBezierFlag_SubPathStartA ) result = &vertices[origin->subPathEndA];
		else result = &vertices[path->indexes[origin->pathAIndex-1]];
	} else {
		if ( origin->flags & WFBezierFlag_SubPathStartB ) result = &vertices[origin->subPathEndB];
		else result = &vertices[path->indexes[origin->pathBIndex-1]];
	}
	if ( result->flags & WFBezierFlag_PointInvalid ) return nodeOnIndexPathBeforeNode( result, vertices, path, isPathA );
	return result;
}

void sortIndexPaths(WFBezierVertexNode * vertices, NSUInteger vertexCount, WFBezierIndexChain * indexedPathA_p, WFBezierIndexChain * indexedPathB_p)
{
	qsort_b(indexedPathA_p->indexes, vertexCount, sizeof(NSUInteger), ^int(const void * a, const void * b) {
		uint64_t iA = *(NSUInteger *)a;
		uint64_t iB = *(NSUInteger *)b;
		WFBezierVertexNode * nodeA = &vertices[iA];
		WFBezierVertexNode * nodeB = &vertices[iB];
		if ( !(nodeA->flags & WFBezierFlag_PathA) && (nodeB->flags & WFBezierFlag_PathA) ) return 1; // push nodes not on path A to the back
		if ( !(nodeB->flags & WFBezierFlag_PathA) && (nodeA->flags & WFBezierFlag_PathA) ) return -1; // push nodes not on path A to the back
		if ( nodeA->pathA_t < nodeB->pathA_t ) return -1;
		if ( nodeA->pathA_t > nodeB->pathA_t ) return 1;
		
		// make sure sub-path start points end up at lower indices, and endpoints end up at higher indices
		if ( !(nodeA->flags & WFBezierFlag_SubPathStartA) && (nodeB->flags & WFBezierFlag_SubPathStartA) ) return 1;
		if ( !(nodeB->flags & WFBezierFlag_SubPathStartA) && (nodeA->flags & WFBezierFlag_SubPathStartA) ) return -1;
		if ( !(nodeA->flags & WFBezierFlag_SubPathEndA) && (nodeB->flags & WFBezierFlag_SubPathEndA) ) return -1;
		if ( !(nodeB->flags & WFBezierFlag_SubPathEndA) && (nodeA->flags & WFBezierFlag_SubPathEndA) ) return 1;
			
		return 0;
	});
	
	qsort_b(indexedPathB_p->indexes, vertexCount, sizeof(NSUInteger), ^int(const void * a, const void * b) {
		uint64_t iA = *(NSUInteger *)a;
		uint64_t iB = *(NSUInteger *)b;
		WFBezierVertexNode * nodeA = &vertices[iA];
		WFBezierVertexNode * nodeB = &vertices[iB];
		if ( !(nodeA->flags & WFBezierFlag_PathB) && (nodeB->flags & WFBezierFlag_PathB) ) return 1; // push nodes not on path B to the back
		if ( !(nodeB->flags & WFBezierFlag_PathB) && (nodeA->flags & WFBezierFlag_PathB) ) return -1; // push nodes not on path B to the back
		if ( nodeA->pathB_t < nodeB->pathB_t ) return -1;
		if ( nodeA->pathB_t > nodeB->pathB_t ) return 1;
		
		// make sure sub-path start points end up at lower indices, and endpoints end up at higher indices
		if ( !(nodeA->flags & WFBezierFlag_SubPathStartB) && (nodeB->flags & WFBezierFlag_SubPathStartB) ) return 1;
		if ( !(nodeB->flags & WFBezierFlag_SubPathStartB) && (nodeA->flags & WFBezierFlag_SubPathStartB) ) return -1;
		if ( !(nodeA->flags & WFBezierFlag_SubPathEndB) && (nodeB->flags & WFBezierFlag_SubPathEndB) ) return -1;
		if ( !(nodeB->flags & WFBezierFlag_SubPathEndB) && (nodeA->flags & WFBezierFlag_SubPathEndB) ) return 1;
		
		return 0;
	});
	
	for ( NSUInteger i = 0; i < vertexCount; i++ ) {
		if ( indexedPathA_p->indexCount == NSNotFound ) {
			WFBezierVertexNode * nodeA = &vertices[indexedPathA_p->indexes[i]];
			if ( !(nodeA->flags & WFBezierFlag_PathA) ) {
				indexedPathA_p->indexCount = i;
			}
		}
		if ( indexedPathB_p->indexCount == NSNotFound ) {
			WFBezierVertexNode * nodeB = &vertices[indexedPathB_p->indexes[i]];
			if ( !(nodeB->flags & WFBezierFlag_PathB) ) {
				indexedPathB_p->indexCount = i;
			}
		}
		if ( indexedPathA_p->indexCount != NSNotFound && indexedPathB_p->indexCount != NSNotFound ) break;
	}
	if ( indexedPathA_p->indexCount == NSNotFound ) indexedPathA_p->indexCount = vertexCount;
	if ( indexedPathB_p->indexCount == NSNotFound ) indexedPathB_p->indexCount = vertexCount;
	
	for ( NSUInteger i = 0; i < indexedPathA_p->indexCount; i++ ) {
		WFBezierVertexNode * node = &vertices[indexedPathA_p->indexes[i]];
		node->pathAIndex = i;
	}
	for ( NSUInteger i = 0; i < indexedPathB_p->indexCount; i++ ) {
		WFBezierVertexNode * node = &vertices[indexedPathB_p->indexes[i]];
		node->pathBIndex = i;
	}
}


#pragma mark - Class Definition

@implementation NSBezierPath (WFBezierCombinatorics)

#pragma mark - Combinatorics

- (BOOL)WFContainsNode:(WFBezierVertexNode *)node
{
	if ( node->flags & WFBezierFlag_Coincident ) return NO;
	return [self containsPoint:node->intersectionPoint];
}

- (NSUInteger)WFGatherOperatingPointsForPath:(NSBezierPath *)pathB outPoints:(WFBezierVertexNode **)outPoints
{
	if ( !outPoints ) return 0;
	// Check that both paths begin with a moveTo. This is required.
	if ( [self elementAtIndex:0] != NSMoveToBezierPathElement ) return 0;
	if ( [pathB elementAtIndex:0] != NSMoveToBezierPathElement ) return 0;
	// Check that both paths have correct winding type
	if ( [self windingRule] != NSNonZeroWindingRule ) return 0;
	if ( [pathB windingRule] != NSNonZeroWindingRule ) return 0;
	
	
	__block NSUInteger capacity = [self elementCount] + [pathB elementCount] + 10;
	__block WFBezierVertexNode * result = malloc( sizeof(WFBezierVertexNode)*capacity );
	__block NSUInteger intersectionCount = 0;
	__block WFBezierVertexNode * currentResult = result;
	
	// Declare a block to save the current point and increment results, allocating more memory if necessary.
	// This is called from several different points in the loop below but it shouldn't be its own function because it is only needed here.
	void (^saveCurrentResult)(void);
	saveCurrentResult = ^ {
		currentResult++;
		intersectionCount++;
		if ( intersectionCount == capacity ) {
			capacity += 50;
			result = realloc( result, sizeof(WFBezierVertexNode)*capacity );
			currentResult = &result[intersectionCount];
		}
	};
	
	
	// Add the existing path points
	void (^addPointsFromPath)(NSBezierPath * path);
	addPointsFromPath = ^(NSBezierPath * path) {
		BOOL pathA = (self==path);
		NSUInteger subPathStart = intersectionCount;
		WFBezierVertexNode * lastNode = NULL;
		WFBezierVertexNode * firstNode = NULL;
		NSBezierPathElement currentElement;
		CGPoint lastPoint = CGPointZero;
		for ( NSUInteger i = 0; i<[path elementCount]; i++) {
			if ( pathA ) {
				currentElement = [path elementAtIndex:i associatedPoints:&(currentResult->controlPointsA[1])];
				currentResult->controlPointsA[0] = lastPoint;
				currentResult->elementA = currentElement;
				currentResult->pathA_t = i;
				currentResult->pathB_t = -1;
				currentResult->flags = WFBezierFlag_PathA | WFBezierFlag_OriginalEndptA;
				currentResult->subPathOriginA = subPathStart;
				currentResult->subPathOriginB = NSNotFound;
			} else {
				currentElement = [path elementAtIndex:i associatedPoints:&(currentResult->controlPointsB[1])];
				currentResult->controlPointsB[0] = lastPoint;
				currentResult->elementB = currentElement;
				currentResult->pathA_t = -1;
				currentResult->pathB_t = i;
				currentResult->flags = WFBezierFlag_PathB | WFBezierFlag_OriginalEndptB;
				currentResult->subPathOriginA = NSNotFound;
				currentResult->subPathOriginB = subPathStart;
			}
			
			switch (currentElement) {
				case NSMoveToBezierPathElement:
					if ( firstNode ) {
						if ( pathA ) {
							firstNode->flags |= WFBezierFlag_SubPathStartA;
							firstNode->subPathEndA = intersectionCount-1;
						} else {
							firstNode->flags |= WFBezierFlag_SubPathStartB;
							firstNode->subPathEndB = intersectionCount-1;
						}
						firstNode = NULL;
					}
					if ( lastNode ) {
						if ( pathA ) {
							lastNode->flags |= WFBezierFlag_SubPathEndA;
							lastNode->subPathEndA = intersectionCount-1;
						} else {
							lastNode->flags |= WFBezierFlag_SubPathEndB;
							lastNode->subPathEndB = intersectionCount-1;
						}
						lastNode = NULL;
					}
					subPathStart = intersectionCount;
					currentResult->intersectionPoint = (pathA)?currentResult->controlPointsA[1]:currentResult->controlPointsB[1];
					break;
				case NSLineToBezierPathElement:
				case NSClosePathBezierPathElement:
					currentResult->intersectionPoint = (pathA)?currentResult->controlPointsA[1]:currentResult->controlPointsB[1];
					break;
				case NSCurveToBezierPathElement:
					currentResult->intersectionPoint = (pathA)?currentResult->controlPointsA[3]:currentResult->controlPointsB[3];
					break;
			}
			
			lastPoint = currentResult->intersectionPoint;
			lastNode = currentResult;
			if ( !firstNode ) firstNode = currentResult;
			saveCurrentResult();
		}
		
		if ( firstNode ) {
			if ( pathA ) {
				firstNode->flags |= WFBezierFlag_SubPathStartA;
				firstNode->subPathEndA = intersectionCount-1;
			} else {
				firstNode->flags |= WFBezierFlag_SubPathStartB;
				firstNode->subPathEndB = intersectionCount-1;
			}
			firstNode = NULL;
		}
		if ( lastNode ) {
			if ( pathA ) {
				lastNode->flags |= WFBezierFlag_SubPathEndA;
				lastNode->subPathEndA = intersectionCount-1;
			} else {
				lastNode->flags |= WFBezierFlag_SubPathEndB;
				lastNode->subPathEndB = intersectionCount-1;
			}
			lastNode = NULL;
		}
	};
	addPointsFromPath(self);
	addPointsFromPath(pathB);
	
	
	// Find all the intersections and add those
	CGPoint controlPtsA[4];
	CGPoint controlPtsB[4];
	NSBezierPathElement elementA;
	NSBezierPathElement elementB;
	[self elementAtIndex:0 associatedPoints:controlPtsA];
	for ( NSUInteger i = 1; i<[self elementCount]; i++) {
		elementA = [self elementAtIndex:i associatedPoints:&controlPtsA[1]];
		if ( elementA == NSMoveToBezierPathElement ) {
			controlPtsA[0] = controlPtsA[1];
			continue;
		}
		
		[pathB elementAtIndex:0 associatedPoints:controlPtsB];
		for ( NSUInteger j = 1; j<[pathB elementCount]; j++) {
			elementB = [pathB elementAtIndex:j associatedPoints:&controlPtsB[1]];
			if ( elementB == NSMoveToBezierPathElement ) {
				controlPtsB[0] = controlPtsB[1];
				continue;
			}
			if ( (elementA==NSLineToBezierPathElement||elementA==NSClosePathBezierPathElement) && (elementB==NSLineToBezierPathElement||elementB==NSClosePathBezierPathElement) ) {
				//
				// line to line intersection
				//
				if ( WFGeometryLineToLineIntersection(controlPtsA[0], controlPtsA[1],
													  controlPtsB[0], controlPtsB[1],
													  &(currentResult->pathA_t),
													  &(currentResult->pathB_t)) ) {
					currentResult->flags = WFBezierFlag_PathA|WFBezierFlag_PathB;
					currentResult->intersectionPoint = WFGeometryEvaluateLine(currentResult->pathA_t, controlPtsA[0], controlPtsA[1]);
					currentResult->elementA = elementA;
					currentResult->elementB = elementB;
					memcpy(currentResult->controlPointsA, controlPtsA, sizeof(CGPoint)*1 );
					memcpy(currentResult->controlPointsB, controlPtsB, sizeof(CGPoint)*1 );
					currentResult->pathA_t += i-1;
					currentResult->pathB_t += j-1;
					currentResult->subPathOriginA = NSNotFound;
					currentResult->subPathOriginB = NSNotFound;
					currentResult->pathAIndex = NSNotFound;
					currentResult->pathBIndex = NSNotFound;
					saveCurrentResult();
				}
				
			} else if ( elementA == NSCurveToBezierPathElement && elementB == NSCurveToBezierPathElement ) {
				//
				// curve to curve intersection
				//
				NSUInteger hitCount;
				CGFloat aHits[6];
				CGFloat bHits[6];
				hitCount = WFGeometryCurveCurveIntersection( controlPtsA, controlPtsB, aHits, bHits );
				for ( NSUInteger hit = 0; hit < hitCount; hit++ ) {
					currentResult->intersectionPoint = WFGeometryEvaluateCubicCurve( aHits[hit], controlPtsA );
					currentResult->flags = WFBezierFlag_PathA|WFBezierFlag_PathB;
					currentResult->elementA = elementA;
					currentResult->elementB = elementB;
					memcpy(currentResult->controlPointsA, controlPtsA, sizeof(CGPoint)*4 );
					memcpy(currentResult->controlPointsB, controlPtsB, sizeof(CGPoint)*4 );
					currentResult->pathA_t = aHits[hit]+i-1;
					currentResult->pathB_t = bHits[hit]+j-1;
					currentResult->subPathOriginA = NSNotFound;
					currentResult->subPathOriginB = NSNotFound;
					currentResult->pathAIndex = NSNotFound;
					currentResult->pathBIndex = NSNotFound;
					saveCurrentResult();
				}
				
			} else {
				//
				// line to curve intersection
				//
				NSUInteger hitCount;
				CGFloat aHits[3];
				CGFloat bHits[3];
				if ( elementA == NSLineToBezierPathElement || elementA == NSClosePathBezierPathElement ) {
					hitCount = WFGeometryLineCurveIntersection(controlPtsA[0], controlPtsA[1], controlPtsB, aHits, bHits);
				} else {
					hitCount = WFGeometryLineCurveIntersection(controlPtsB[0], controlPtsB[1], controlPtsA, bHits, aHits);
				}
				
				for ( NSUInteger hit = 0; hit < hitCount; hit++ ) {
					if ( elementA == NSLineToBezierPathElement || elementA == NSClosePathBezierPathElement ) {
						currentResult->intersectionPoint = WFGeometryEvaluateLine(aHits[hit], controlPtsA[0], controlPtsA[1]);
					} else {
						currentResult->intersectionPoint = WFGeometryEvaluateLine(bHits[hit], controlPtsB[0], controlPtsB[1]);
					}
					currentResult->flags = WFBezierFlag_PathA|WFBezierFlag_PathB;
					currentResult->elementA = elementA;
					currentResult->elementB = elementB;
					memcpy(currentResult->controlPointsA, controlPtsA, sizeof(CGPoint)*4 );
					memcpy(currentResult->controlPointsB, controlPtsB, sizeof(CGPoint)*4 );
					currentResult->pathA_t = aHits[hit]+i-1;
					currentResult->pathB_t = bHits[hit]+j-1;
					currentResult->subPathOriginA = NSNotFound;
					currentResult->subPathOriginB = NSNotFound;
					currentResult->pathAIndex = NSNotFound;
					currentResult->pathBIndex = NSNotFound;
					saveCurrentResult();
				}
			}
			if ( elementB == NSLineToBezierPathElement ) {
				controlPtsB[0] = controlPtsB[1];
			} else {
				controlPtsB[0] = controlPtsB[3];
			}
		}
		
		if ( elementA == NSLineToBezierPathElement ) {
			controlPtsA[0] = controlPtsA[1];
		} else {
			controlPtsA[0] = controlPtsA[3];
		}
	}
	
	*outPoints = result;
	return intersectionCount;
}

- (NSBezierPath *)WFTraversePath:(NSBezierPath *)path withOptions:(NSUInteger)options pointFinder:(WFBezierVertexNode*(^)(WFBezierVertexNode * vertices, NSUInteger vertexCount, WFBezierIndexChain * pathA, WFBezierIndexChain * pathB, BOOL * isPathA))findNextStartingPoint
{
	// Get all the path vertices and intersections as a point cloud.
	WFBezierVertexNode * vertices = NULL;
	NSUInteger vertexCount = [self WFGatherOperatingPointsForPath:path outPoints:&vertices];
	if ( !vertices ) return nil;
	if ( !vertexCount ) {
		free( vertices );
		return nil;
	}
	
	// Create sorted indexes for both A and B paths to allow us to traverse the point-cloud in polygon winding order.
	WFBezierIndexChain * indexedPathA = malloc( sizeof(WFBezierIndexChain) + sizeof(NSUInteger)*vertexCount );
	WFBezierIndexChain * indexedPathB = malloc( sizeof(WFBezierIndexChain) + sizeof(NSUInteger)*vertexCount );
	indexedPathA->indexCount = NSNotFound;
	indexedPathB->indexCount = NSNotFound;
	for ( NSUInteger i = 0; i < vertexCount; i++ ) {
		indexedPathA->indexes[i] = i;
		indexedPathB->indexes[i] = i;
	}
	sortIndexPaths(vertices, vertexCount, indexedPathA, indexedPathB);
	
	
	// flag original vertices as coincident so we know that inside/outside detection on those vertices will be unreliable
	// and flag redundant intersections and origin nodes as invalid
	for ( NSUInteger i = 0; i < vertexCount; i++ ) {
		WFBezierVertexNode * node = &vertices[i];
		if ( (node->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB)) != (WFBezierFlag_PathA|WFBezierFlag_PathB) ) continue;
		if ( node->flags & WFBezierFlag_ShouldInvalidate ) continue;
		if ( node->flags & WFBezierFlag_PointInvalid ) continue;
		BOOL pathAOnEndpt = fabs(node->pathA_t-round(node->pathA_t)) < WFGeometryParametricResolution;
		BOOL pathBOnEndpt = fabs(node->pathB_t-round(node->pathB_t)) < WFGeometryParametricResolution;
		
		WFBezierVertexNode * nextNodeA = NULL;
		WFBezierVertexNode * previousNodeA = NULL;
		WFBezierVertexNode * originalA = NULL;
		CGPoint testVec1A;
		CGPoint testVec2A;
		
		WFBezierVertexNode * nextNodeB = NULL;
		WFBezierVertexNode * previousNodeB = NULL;
		WFBezierVertexNode * originalB = NULL;
		CGPoint testVec1B;
		CGPoint testVec2B;
		
		BOOL crossesBoundary = NO;
		BOOL coincidentBoundaries = NO;
		
		if ( pathAOnEndpt ) {
			originalA = originalVertexOverlappingNode(node, vertices, indexedPathA, YES);
			if ( originalA ) {
				CGPoint derivative[3];
				nextNodeA = nextNonRedundantNode( node, vertices, indexedPathA, YES );
				previousNodeA = previousNonRedundantNode( node, vertices, indexedPathA, YES );
				nextNodeA = intersectionOverlappingNodeIfExists( nextNodeA, vertices, indexedPathA, YES );
				previousNodeA = intersectionOverlappingNodeIfExists( previousNodeA, vertices, indexedPathA, YES );
				
				switch ( originalA->elementA ) {
					case NSLineToBezierPathElement:
					case NSMoveToBezierPathElement:
					case NSClosePathBezierPathElement:
						if ( (previousNodeA->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB)) != (WFBezierFlag_PathA|WFBezierFlag_PathB) && floor(previousNodeA->pathA_t) == floor(originalA->pathA_t) ) {
							crossesBoundary = YES;
						} else {
							testVec1A = CGPointMake( previousNodeA->intersectionPoint.x-node->intersectionPoint.x, previousNodeA->intersectionPoint.y-node->intersectionPoint.y );
						}
						break;
					case NSCurveToBezierPathElement:
						WFGeometryBezierDerivative( originalA->controlPointsA, derivative );
						testVec1A = WFGeometryEvaluateQuadraticCurve( 1.0, derivative );
						break;
				}
				switch ( nextNodeA->elementA ) {
					case NSLineToBezierPathElement:
					case NSMoveToBezierPathElement:
					case NSClosePathBezierPathElement:
						if ( (nextNodeA->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB)) != (WFBezierFlag_PathA|WFBezierFlag_PathB) && floor(nextNodeA->pathA_t) == floor(originalA->pathA_t) ) {
							crossesBoundary = YES;
						} else {
							testVec2A = CGPointMake( nextNodeA->intersectionPoint.x-node->intersectionPoint.x, nextNodeA->intersectionPoint.y-node->intersectionPoint.y );
						}
						break;
					case NSCurveToBezierPathElement:
						WFGeometryBezierDerivative( nextNodeA->controlPointsA, derivative );
						testVec2A = WFGeometryEvaluateQuadraticCurve( 0.0, derivative );
						break;
				}
				if ( !pathBOnEndpt) {
					// simple vectors crossing boundary test since path B is not hit on a corner
					CGPoint lineVecA;
					switch ( node->elementB ) {
						case NSLineToBezierPathElement:
						case NSMoveToBezierPathElement:
						case NSClosePathBezierPathElement:
							lineVecA = CGPointMake( node->intersectionPoint.x - node->controlPointsB[0].x, node->intersectionPoint.y - node->controlPointsB[0].y );
							break;
						case NSCurveToBezierPathElement:
							WFGeometryBezierDerivative( node->controlPointsB, derivative );
							lineVecA = WFGeometryEvaluateQuadraticCurve( node->pathB_t-floor(node->pathB_t), derivative );
							break;
					}
					crossesBoundary |= !WFGeometryVectorsOnSameSideOfLine( lineVecA, testVec1A, testVec2A );
					coincidentBoundaries |= WFGeometryVectorsCoincident( lineVecA, testVec1A, testVec2A );
				}
			}
		}
		if ( pathBOnEndpt ) {
			originalB = originalVertexOverlappingNode(node, vertices, indexedPathB, NO);
			if ( originalB ) {
				CGPoint derivative[3];
				nextNodeB = nextNonRedundantNode( node, vertices, indexedPathB, NO );
				previousNodeB = previousNonRedundantNode( node, vertices, indexedPathB, NO );
				nextNodeB = intersectionOverlappingNodeIfExists( nextNodeB, vertices, indexedPathB, NO );
				previousNodeB = intersectionOverlappingNodeIfExists( previousNodeB, vertices, indexedPathB, NO );
				
				switch ( originalB->elementB ) {
					case NSLineToBezierPathElement:
					case NSMoveToBezierPathElement:
					case NSClosePathBezierPathElement:
						if ( (previousNodeB->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB)) != (WFBezierFlag_PathA|WFBezierFlag_PathB) && floor(previousNodeB->pathB_t) == floor(originalB->pathB_t) ) {
							crossesBoundary = YES;
						} else {
							testVec1B = CGPointMake( previousNodeB->intersectionPoint.x-node->intersectionPoint.x, previousNodeB->intersectionPoint.y-node->intersectionPoint.y );
						}
						break;
					case NSCurveToBezierPathElement:
						WFGeometryBezierDerivative( originalB->controlPointsB, derivative );
						testVec1B = WFGeometryEvaluateQuadraticCurve( 1.0, derivative );
						break;
				}
				switch ( nextNodeB->elementB ) {
					case NSLineToBezierPathElement:
					case NSMoveToBezierPathElement:
					case NSClosePathBezierPathElement:
						if ( (nextNodeB->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB)) != (WFBezierFlag_PathA|WFBezierFlag_PathB) && floor(nextNodeB->pathB_t) == floor(originalB->pathB_t) ) {
							crossesBoundary = YES;
						} else {
							testVec2B = CGPointMake( nextNodeB->intersectionPoint.x-node->intersectionPoint.x, nextNodeB->intersectionPoint.y-node->intersectionPoint.y );
						}
						break;
					case NSCurveToBezierPathElement:
						WFGeometryBezierDerivative( nextNodeB->controlPointsB, derivative );
						testVec2B = WFGeometryEvaluateQuadraticCurve( 0.0, derivative );
						break;
				}
				if ( !pathAOnEndpt ) {
					// simple vectors crossing boundary test since path A is not hit on a corner
					CGPoint lineVecB;
					switch ( node->elementA ) {
						case NSLineToBezierPathElement:
						case NSMoveToBezierPathElement:
						case NSClosePathBezierPathElement:
							lineVecB = CGPointMake( node->intersectionPoint.x - node->controlPointsA[0].x, node->intersectionPoint.y - node->controlPointsA[0].y );
							break;
						case NSCurveToBezierPathElement:
							WFGeometryBezierDerivative( node->controlPointsA, derivative );
							lineVecB = WFGeometryEvaluateQuadraticCurve( node->pathA_t-floor(node->pathA_t), derivative );
							break;
					}
					crossesBoundary |= !WFGeometryVectorsOnSameSideOfLine( lineVecB, testVec1B, testVec2B );
					coincidentBoundaries |= WFGeometryVectorsCoincident( lineVecB, testVec1B, testVec2B );
				}
			}
		}
		if ( pathAOnEndpt && pathBOnEndpt ) {
			crossesBoundary = WFGeometryVectorsCrossCorner( testVec1A, testVec2A, testVec1B, testVec2B );
			coincidentBoundaries |= originalA && originalB && WFGeometryVectorsCoincident4( testVec1A, testVec2A, testVec1B, testVec2B );
		}
		
		if ( originalA ) {
			if ( crossesBoundary || coincidentBoundaries ) {
				if ( coincidentBoundaries ) node->flags |= WFBezierFlag_ParallelIntersect;
				node->flags |= originalA->flags & (WFBezierFlag_SubPathStartA|WFBezierFlag_SubPathEndA|WFBezierFlag_OriginalEndptA);
				node->flags |= WFBezierFlag_Coincident;
				node->subPathEndA = originalA->subPathEndA;
				node->subPathOriginA = originalA->subPathOriginA;
				originalA->flags |= WFBezierFlag_ShouldInvalidate;
				nextNodeA = nodeOnIndexPathAfterNode( node, vertices, indexedPathA, YES );
				while ( WFGeometryDistance(node->intersectionPoint, nextNodeA->intersectionPoint) <= WFGeometryPointResolution ) {
					nextNodeA->flags |= WFBezierFlag_ShouldInvalidate;
					nextNodeA = nodeOnIndexPathAfterNode( nextNodeA, vertices, indexedPathA, YES );
				}
				nextNodeA = nodeOnIndexPathBeforeNode( node, vertices, indexedPathA, YES );
				while ( WFGeometryDistance(node->intersectionPoint, nextNodeA->intersectionPoint) <= WFGeometryPointResolution ) {
					nextNodeA->flags |= WFBezierFlag_ShouldInvalidate;
					nextNodeA = nodeOnIndexPathBeforeNode( nextNodeA, vertices, indexedPathA, YES );
				}
				nextNodeA = findMoveToNodeOverlappingNode( node, vertices, vertexCount, YES );
				if ( nextNodeA ) {
					nextNodeA->flags |= WFBezierFlag_ShouldInvalidate;
				}
			} else {
				node->flags |= WFBezierFlag_ShouldInvalidate;
				originalA->flags |= WFBezierFlag_Coincident;
			}
		}
		if ( originalB ) {
			if ( crossesBoundary || coincidentBoundaries ) {
				if ( coincidentBoundaries ) node->flags |= WFBezierFlag_ParallelIntersect;
				node->flags |= originalB->flags & (WFBezierFlag_SubPathStartB|WFBezierFlag_SubPathEndB|WFBezierFlag_OriginalEndptB);
				node->flags |= WFBezierFlag_Coincident;
				node->subPathEndB = originalB->subPathEndB;
				node->subPathOriginB = originalB->subPathOriginB;
				originalB->flags |= WFBezierFlag_ShouldInvalidate;
				nextNodeB = nodeOnIndexPathAfterNode( node, vertices, indexedPathB, NO );
				while ( WFGeometryDistance(node->intersectionPoint, nextNodeB->intersectionPoint) <= WFGeometryPointResolution ) {
					nextNodeB->flags |= WFBezierFlag_ShouldInvalidate;
					nextNodeB = nodeOnIndexPathAfterNode( nextNodeB, vertices, indexedPathB, NO );
				}
				nextNodeB = nodeOnIndexPathBeforeNode( node, vertices, indexedPathB, NO );
				while ( WFGeometryDistance(node->intersectionPoint, nextNodeB->intersectionPoint) <= WFGeometryPointResolution ) {
					nextNodeB->flags |= WFBezierFlag_ShouldInvalidate;
					nextNodeB = nodeOnIndexPathBeforeNode( nextNodeB, vertices, indexedPathB, NO );
				}
				nextNodeB = findMoveToNodeOverlappingNode( node, vertices, vertexCount, NO );
				if ( nextNodeB ) {
					nextNodeB->flags |= WFBezierFlag_ShouldInvalidate;
				}
			} else {
				node->flags |= WFBezierFlag_ShouldInvalidate;
				originalB->flags |= WFBezierFlag_Coincident;
			}
		}
	}
	
	// Invalidate all the nodes we marked
	for ( NSUInteger i = 0; i < vertexCount; i++ ) {
		WFBezierVertexNode * node = &vertices[i];
		if ( node->flags & WFBezierFlag_ShouldInvalidate ) {
			node->flags |= WFBezierFlag_PointInvalid;
		}
	}
	
	// Traverse all the points in our indexed paths and create the resulting path based on the given options and point selector block
	NSUInteger pathIndex = 0;
	NSBezierPath * result = [[NSBezierPath alloc] init];
	BOOL isPathA = YES;
	BOOL isBezierPathStarted = NO;
	
	while ( 1 ) {
		NSUInteger vertexIndex = (isPathA)?indexedPathA->indexes[pathIndex]:indexedPathB->indexes[pathIndex];
		WFBezierVertexNode * node = &vertices[vertexIndex];
		BOOL switchPath = NO;
		
		if ( !isBezierPathStarted ) {
			// Sub-path has not been started, so find a starting node to use
			node = findNextStartingPoint( vertices, vertexCount, indexedPathA, indexedPathB, &isPathA );
			if ( !node ) break;
			//NSLog(@"Starting from (%f,%f) [%lu]", node->intersectionPoint.x, node->intersectionPoint.y, (isPathA)?indexedPathA->indexes[node->pathAIndex]:indexedPathB->indexes[node->pathBIndex] );
			pathIndex = (isPathA)?node->pathAIndex:node->pathBIndex;
		}
		
		//
		// Select the next node on the path
		//
		
		// Node is an intersection, so switch to the alternate path unless node is a a parallel intersection in which case additional checks are needed to determine if we should switch paths.
		if ( !(node->flags & WFBezierFlag_PointInvalid) && (node->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB)) == (WFBezierFlag_PathA|WFBezierFlag_PathB) ) {
			if ( (node->flags & WFBezierFlag_ParallelIntersect) && !(options & WFBezierTraversal_IgnoreParallelIntersections) ) {

				// If node is a parallel path intersection, we should only switch paths if the next node on either path is NOT an intersection
				/*if ( parallelIntersectNodeIsEnteringUnion(node, vertices, indexedPathA, indexedPathB, isPathA)) {
					// Can't enter into a union formed by parallel nodes from both paths
					switchPath = YES;
				} else {
					WFBezierVertexNode * nextNodeA = nodeOnIndexPathAfterNode(node, vertices, indexedPathA, YES);
					WFBezierVertexNode * nextNodeB = nodeOnIndexPathAfterNode(node, vertices, indexedPathB, NO);
					if ( nextNodeA != nextNodeB ) {
						if ( isPathA ) {
							// Can't turn a corner while following parallel intersections
							switchPath = (node->flags & WFBezierFlag_OriginalEndptA) &&
											(nextNodeA->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB)) == (WFBezierFlag_PathA|WFBezierFlag_PathB);
							if ( !switchPath ) {
								if ( (nextNodeA->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB)) == (WFBezierFlag_PathA|WFBezierFlag_PathB) && !(nextNodeA->flags & WFBezierFlag_ParallelIntersect) ) {
									// Can't cross a boundary to a real intersection while following parallel intersectons
									switchPath = YES;
								}
							}
							if ( !switchPath && [path WFContainsNode:nextNodeA] ) {
								switchPath = YES;
							}
						} else {
							// Can't turn a corner while following parallel intersections
							switchPath = (node->flags & WFBezierFlag_OriginalEndptB) &&
											(nextNodeB->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB)) == (WFBezierFlag_PathA|WFBezierFlag_PathB);
							if ( !switchPath ) {
								if ( (nextNodeB->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB)) == (WFBezierFlag_PathA|WFBezierFlag_PathB) && !(nextNodeB->flags & WFBezierFlag_ParallelIntersect) ) {
									// Can't cross a boundary to a real intersection while following parallel intersectons
									switchPath = YES;
								}
							}
							if ( !switchPath && [self WFContainsNode:nextNodeB] ) {
								switchPath = YES;
							}
						}
					}
				}*/
				
				BOOL canUsePathA = YES;
				BOOL canUsePathB = YES;
				
				WFBezierVertexNode * nextNodeA = nodeOnIndexPathAfterNode(node, vertices, indexedPathA, YES);
				WFBezierVertexNode * nextNodeB = nodeOnIndexPathAfterNode(node, vertices, indexedPathB, NO);
				
				if ( nextNodeA != nextNodeB ) {
					canUsePathA &= !parallelIntersectNodeIsEnteringUnion(node, vertices, indexedPathA, indexedPathB, YES);
					canUsePathB &= !parallelIntersectNodeIsEnteringUnion(node, vertices, indexedPathA, indexedPathB, NO);
					
					if ( WFNodeIsOnBothPaths( nextNodeA ) ) {
						CGPoint testPtA = midPointBetweenNodes( node, nextNodeA, YES );
						canUsePathA = canUsePathA && ![path containsPoint:testPtA];
					} else {
						canUsePathA = canUsePathA && ![path WFContainsNode:nextNodeA];
					}
					if ( WFNodeIsOnBothPaths( nextNodeB ) ) {
						CGPoint testPtB = midPointBetweenNodes( node, nextNodeB, NO );
						canUsePathB = canUsePathB && ![self containsPoint:testPtB];
					} else {
						canUsePathB = canUsePathB && ![self WFContainsNode:nextNodeB];
					}
				}
				
				if ( !canUsePathA && !canUsePathB ) {
					// end this sub-path at this node if there is no way to traverse from it
					node->flags |= WFBezierFlag_PointUsed;
					NSLog( @"Terminating path" );
				}
				// Switch paths from a parallel intersect if we can't traverse to the next node on the current path
				switchPath = (isPathA && !canUsePathA) || (!isPathA && !canUsePathB);
				
			} else {
				switchPath = YES;
			}
		}
		if ( !switchPath ) {
			// Node is only on pathA or only pathB, or is invalid and should be skipped
			// Go to next node on this index path
			pathIndex++;
			if ( isPathA ) {
				if ( node->flags & WFBezierFlag_SubPathEndA ) {
					pathIndex = vertices[node->subPathOriginA].pathAIndex;
				}
			} else {
				if ( node->flags & WFBezierFlag_SubPathEndB ) {
					pathIndex = vertices[node->subPathOriginB].pathBIndex;
				}
			}
		}
		
		//
		// Add the current node to the result path if it was valid
		//
		if ( !(node->flags & WFBezierFlag_PointInvalid) ) {
			if ( !isBezierPathStarted ) {
				[result moveToPoint:node->intersectionPoint];
				isBezierPathStarted = YES;
			} else {
				CGPoint * originalCurve;
				NSBezierPathElement curveType = (isPathA)?node->elementA:node->elementB;
				switch ( curveType ) {
					case NSMoveToBezierPathElement:
						break;
					case NSClosePathBezierPathElement:
					case NSLineToBezierPathElement:
						[result lineToPoint:node->intersectionPoint];
						break;
					case NSCurveToBezierPathElement:
						originalCurve = (isPathA)?node->controlPointsA:node->controlPointsB;
						if ( (node->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB)) == (WFBezierFlag_PathA|WFBezierFlag_PathB) ) {
							// node is intersection point on curve
							CGPoint curveSplitPrevious[4];
							CGPoint curveSplitNext[4];
							CGPoint curveSplitFinal[4];
							CGFloat splitT;
							CGFloat previousSplitT;
							WFBezierVertexNode * previousNode;
							if ( isPathA ) {
								previousNode = nodeOnIndexPathBeforeNode(node, vertices, indexedPathA, isPathA);
								splitT = node->pathA_t;
								previousSplitT = previousNode->pathA_t;
							} else {
								previousNode = nodeOnIndexPathBeforeNode(node, vertices, indexedPathB, isPathA);
								splitT = node->pathB_t;
								previousSplitT = previousNode->pathB_t;
							}
							//splitT -= floor(splitT);
							splitT -= floor(previousSplitT);
							WFGeometrySplitCubicCurve(splitT, originalCurve, curveSplitPrevious, curveSplitNext);
							if ( (previousNode->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB)) != (WFBezierFlag_PathA|WFBezierFlag_PathB) ) {
								// previous node is an endpoint, so we can use the split directly
								[result curveToPoint:curveSplitPrevious[3] controlPoint1:curveSplitPrevious[1] controlPoint2:curveSplitPrevious[2]];
							} else {
								// previous node is also an intersection so we have to split the curve again
								splitT = WFGeometryParameterForCubicCurvePoint(curveSplitPrevious, previousNode->intersectionPoint);
								WFGeometrySplitCubicCurve(splitT, curveSplitPrevious, curveSplitNext, curveSplitFinal);
								[result curveToPoint:curveSplitFinal[3] controlPoint1:curveSplitFinal[1] controlPoint2:curveSplitFinal[2]];
							}
							
						} else {
							// node is endpoint of curve
							CGPoint curveSplitPrevious[4];
							CGPoint curveSplitNext[4];
							CGFloat splitT;
							WFBezierVertexNode * previousNode;
							if ( isPathA ) {
								previousNode = nodeOnIndexPathBeforeNode(node, vertices, indexedPathA, isPathA);
								splitT = previousNode->pathA_t;
							} else {
								previousNode = nodeOnIndexPathBeforeNode(node, vertices, indexedPathB, isPathA);
								splitT = previousNode->pathB_t;
							}
							splitT -= floor(splitT);
							WFGeometrySplitCubicCurve(splitT, originalCurve, curveSplitPrevious, curveSplitNext);
							[result curveToPoint:curveSplitNext[3] controlPoint1:curveSplitNext[1] controlPoint2:curveSplitNext[2]];
						}
						break;
				}
			}
		}
		
		if ( (node->flags & WFBezierFlag_PointUsed) && !(node->flags & WFBezierFlag_PointInvalid) ) {
			// We've hit a node that's been used already, so we must be at the end of this sub-path
			isBezierPathStarted = NO;
			continue;
		} else {
			// Mark this node as having been used already
			node->flags |= WFBezierFlag_PointUsed;
		}
		
		if ( switchPath ) {
			// if we're switching paths, find the corresponding index on the other path and increment it to the next point on the other path
			isPathA = !isPathA;
			pathIndex = (isPathA)?node->pathAIndex:node->pathBIndex;
			pathIndex++;
			if ( isPathA ) {
				if ( node->flags & WFBezierFlag_SubPathEndA ) {
					pathIndex = vertices[node->subPathOriginA].pathAIndex;
				}
			} else {
				if ( node->flags & WFBezierFlag_SubPathEndB ) {
					pathIndex = vertices[node->subPathOriginB].pathBIndex;
				}
			}
		}
	}
	
	free( vertices );
	free( indexedPathA );
	free( indexedPathB );
	return result;
}

- (NSBezierPath *)WFUnionWithPath:(NSBezierPath *)path
{
	NSBezierPath * result = [self WFTraversePath:path
									 withOptions:0
									 pointFinder:^WFBezierVertexNode * (WFBezierVertexNode *vertices, NSUInteger vertexCount, WFBezierIndexChain *indexedPathA, WFBezierIndexChain *indexedPathB, BOOL * isPathA) {
		
		for ( NSUInteger i = 0; i < vertexCount; i++ ) {
			if ( vertices[i].flags & (WFBezierFlag_PointUsed|WFBezierFlag_PointInvalid) ) continue;
			WFBezierVertexNode * node = &vertices[i];
			
			if ( (node->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB)) == (WFBezierFlag_PathA|WFBezierFlag_PathB) ) {
				// new node is an intersection, figure out which path to traverse
				
				//if ( node->pathAIndex == 12 && node->pathBIndex == 15 ) {
				//	NSLog(@"Foo");
				//}
				WFBezierVertexNode * nextNodeA = nodeOnIndexPathAfterNode(node, vertices, indexedPathA, YES);
				WFBezierVertexNode * nextNodeB = nodeOnIndexPathAfterNode(node, vertices, indexedPathB, NO);
				
				if ( node->flags & WFBezierFlag_ParallelIntersect ) {
					if ( parallelIntersectNodeIsInsideUnion(node, vertices, indexedPathA, indexedPathB) ) {
						node->flags |= WFBezierFlag_PointUsed;
						continue;
					}
					// Parallel intersect nodes can start on either path, and we can always start on a parallel intersection as long as it is not inside the union.
					return node;
					
					/*
					if ( (nextNodeA->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB)) == (WFBezierFlag_PathA|WFBezierFlag_PathB) &&
						 !(nextNodeA->flags & WFBezierFlag_ParallelIntersect) &&
						 (nextNodeB->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB)) == (WFBezierFlag_PathA|WFBezierFlag_PathB) &&
						 (nextNodeB->flags & WFBezierFlag_ParallelIntersect) &&
						 !(nextNodeA->flags & WFBezierFlag_OriginalEndptA) ) {
						*isPathA = YES;
						return node;
					}
					if ( (nextNodeB->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB)) == (WFBezierFlag_PathA|WFBezierFlag_PathB) &&
						 !(nextNodeB->flags & WFBezierFlag_ParallelIntersect) &&
						 (nextNodeA->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB)) == (WFBezierFlag_PathA|WFBezierFlag_PathB) &&
						 (nextNodeA->flags & WFBezierFlag_ParallelIntersect) &&
						 !(nextNodeB->flags & WFBezierFlag_OriginalEndptB) ) {
						*isPathA = NO;
						return node;
					}
					if ( (nextNodeA->flags & WFBezierFlag_ParallelIntersect) &&
						 (nextNodeB->flags & WFBezierFlag_ParallelIntersect) &&
						 parallelIntersectNodeIsInsideUnion( nextNodeA, vertices, indexedPathA, indexedPathB ) &&
						!parallelIntersectNodeIsInsideUnion( nextNodeB, vertices, indexedPathA, indexedPathB )) {
						*isPathA = YES;
						return node;
					}
					if ( (nextNodeA->flags & WFBezierFlag_ParallelIntersect) &&
						 (nextNodeB->flags & WFBezierFlag_ParallelIntersect) &&
						!parallelIntersectNodeIsInsideUnion( nextNodeA, vertices, indexedPathA, indexedPathB ) &&
						 parallelIntersectNodeIsInsideUnion( nextNodeB, vertices, indexedPathA, indexedPathB )) {
						*isPathA = NO;
						return node;
					}
					*/
				}
				
				if ( (nextNodeA->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB)) != (WFBezierFlag_PathA|WFBezierFlag_PathB) ) {
					if ( ![path WFContainsNode:nextNodeA] ) {
						// Next node on pathA is not an intersection and is not contained in the other path so we can use this node on path A.
						*isPathA = NO;
						return node;
					}
					
				}
				if ( (nextNodeB->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB)) != (WFBezierFlag_PathA|WFBezierFlag_PathB) ) {
					if ( ![self WFContainsNode:nextNodeB] ) {
						// Next node on pathB is not an intersection and is not contained in the other path so we can use this node on path B.
						*isPathA = YES;
						return node;
					}
				}
				if ( nextNodeA == nextNodeB && (nextNodeA->flags & WFBezierFlag_ParallelIntersect) ) {
					if ( node->flags & WFBezierFlag_OriginalEndptA ) {
						*isPathA = YES;
					} else {
						*isPathA = NO;
					}
					return node;
				}
				
			} else {
				// new node is an endpoint
				*isPathA = (node->flags & WFBezierFlag_PathA);
				if ( *isPathA ) {
					if ( ![path WFContainsNode:node] ) {
						// union of paths con't use points contained by the other path
						return node;
					}
				} else {
					if ( ![self WFContainsNode:node] ) {
						// union of paths con't use points contained by the other path
						return node;
					}
				}
			}
			node->flags |= WFBezierFlag_PointUsed;
			continue;
		}
		return NULL;
	}];
	
	return result;
}

- (NSBezierPath *)WFSubtractPath:(NSBezierPath *)path
{
	NSBezierPath * result = [self WFTraversePath:[path bezierPathByReversingPath]
									 withOptions:WFBezierTraversal_IgnoreParallelIntersections
									 pointFinder:^WFBezierVertexNode * (WFBezierVertexNode *vertices, NSUInteger vertexCount, WFBezierIndexChain *indexedPathA, WFBezierIndexChain *indexedPathB, BOOL * isPathA) {
		
		WFBezierVertexNode * node = NULL;
		BOOL freeVertexFound = NO;
		
		for ( NSUInteger i = 0; i < vertexCount; i++ ) {
			if ( vertices[i].flags & (WFBezierFlag_PointUsed|WFBezierFlag_PointInvalid) ) continue;
			node = &vertices[i];
			
			if ( (node->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB)) == (WFBezierFlag_PathA|WFBezierFlag_PathB) ) {
				// new node is an intersection, figure out which path to traverse
				WFBezierVertexNode * nextNode = nodeOnIndexPathAfterNode(node, vertices, indexedPathA, YES);
				if ( (nextNode->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB)) != (WFBezierFlag_PathA|WFBezierFlag_PathB) && ![path WFContainsNode:nextNode] ) {
					// Next node on pathA is not an intersection and is not contained in the other path so we can use this node on path A.
					*isPathA = NO;
				} else {
					nextNode = nodeOnIndexPathAfterNode(node, vertices, indexedPathB, NO);
					if ( (nextNode->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB|WFBezierFlag_ParallelIntersect)) == (WFBezierFlag_PathA|WFBezierFlag_PathB) ) {
						// Next node on pathB is also an intersection so the pathB enters and then leaves pathA, this is valid for a subtraction.
						*isPathA = NO;
					} else if ( ![self WFContainsNode:nextNode] ) {
						// path subtraction can only use pathB points that are enclosed by pathA
						node->flags |= WFBezierFlag_PointUsed;
						continue;
					}
					*isPathA = YES;
				}
			} else {
				// new node is an endpoint
				*isPathA = (node->flags & WFBezierFlag_PathA);
				if ( *isPathA ) {
					if ( [path WFContainsNode:node] ) {
						// path subtraction can't use points on pathA that are enclosed by pathB
						node->flags |= WFBezierFlag_PointUsed;
						continue;
					}
				} else {
					if ( ![self WFContainsNode:node] ) {
						// path subtraction can only use pathB points that are enclosed by pathA
						node->flags |= WFBezierFlag_PointUsed;
						continue;
					}
				}
			}
			
			freeVertexFound = YES;
			break;
		}
		if ( !freeVertexFound ) return NULL;
		return node;
	}];
	
	return result;
}

- (NSBezierPath * )WFIntersectWithPath:(NSBezierPath *)path
{
	NSBezierPath * result = [self WFTraversePath:path
									 withOptions:WFBezierTraversal_DontSkipParallelIntersections|WFBezierTraversal_InvertParallelPathSwitch
									 pointFinder:^WFBezierVertexNode * (WFBezierVertexNode *vertices, NSUInteger vertexCount, WFBezierIndexChain *indexedPathA, WFBezierIndexChain *indexedPathB, BOOL * isPathA) {
	 
		WFBezierVertexNode * node = NULL;
		BOOL freeVertexFound = NO;
		
		for ( NSUInteger i = 0; i < vertexCount; i++ ) {
			if ( vertices[i].flags & (WFBezierFlag_PointUsed|WFBezierFlag_PointInvalid) ) continue;
			node = &vertices[i];
			 
			if ( (node->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB)) == (WFBezierFlag_PathA|WFBezierFlag_PathB) ) {
				// new node is an intersection, figure out which path to traverse
				WFBezierVertexNode * nextNode = nodeOnIndexPathAfterNode(node, vertices, indexedPathA, YES);
				if ( (nextNode->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB)) == (WFBezierFlag_PathA|WFBezierFlag_PathB) ) {
					// Next node on pathA is an intersection so it must be valid
					*isPathA = NO;
				} else if ( [path WFContainsNode:nextNode] ) {
					// Next node on pathA is an endpoint and is contained within pathB so it is valid
					*isPathA = NO;
				} else {
					nextNode = nodeOnIndexPathAfterNode(node, vertices, indexedPathB, NO);
					if ( (nextNode->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB)) == (WFBezierFlag_PathA|WFBezierFlag_PathB) ) {
						// Next node on pathB is also an intersection so it must be valid
						*isPathA = YES;
					} else if ( [self WFContainsNode:nextNode] ) {
						// Next node on pathB is and endpoint and is contained in pathA so it is valid
						*isPathA = YES;
					} else {
						node->flags |= WFBezierFlag_PointUsed;
						continue;
					}
				}
			 } else {
				// new node is an endpoint
				*isPathA = (node->flags & WFBezierFlag_PathA);
				if ( *isPathA ) {
					if ( ![path WFContainsNode:node] ) {
						// intersections only contain vertices that are inside the other shape
						node->flags |= WFBezierFlag_PointUsed;
						continue;
					}
				} else {
					if ( ![self WFContainsNode:node] ) {
						// intersections only contain vertices that are inside the other shape
						node->flags |= WFBezierFlag_PointUsed;
						continue;
					}
				}
			}
			 
			freeVertexFound = YES;
			break;
		}
		if ( !freeVertexFound ) return NULL;
		return node;
	}];
	
	return result;
}


@end
