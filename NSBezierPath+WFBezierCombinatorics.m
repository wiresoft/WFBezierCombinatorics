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

typedef struct WFBezierVectorAngle {
	CGPoint		vector;
	CGFloat		angle;
	BOOL		startA;
	BOOL		endA;
	BOOL		startB;
	BOOL		endB;
} WFBezierVectorAngle;

typedef struct {
	size_t		indexCount;
	NSUInteger	indexes[];
} WFBezierIndexChain;


#pragma mark - Static C Functions

CGPoint midPointBetweenNodes( WFBezierVertexNode * a, WFBezierVertexNode * b, BOOL isPathA );
CGPoint vectorLeavingNodeForNextNode( WFBezierVertexNode * node, WFBezierVertexNode * vertices, WFBezierIndexChain * path, BOOL isPathA );
CGPoint vectorLeavingNodeForPreviousNode( WFBezierVertexNode * node, WFBezierVertexNode * vertices, WFBezierIndexChain * path, BOOL isPathA );
WFBezierVertexNode * findMoveToNodeOverlappingNode( WFBezierVertexNode * origin, WFBezierVertexNode * vertices, NSUInteger vertexCount, BOOL isPathA );
void iterateOriginalVerticesOverlappingNode( WFBezierVertexNode * origin, WFBezierVertexNode * vertices, NSUInteger vertexCount, BOOL isPathA, void(^block)(WFBezierVertexNode* node) );
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

CGPoint vectorLeavingNodeForNextNode( WFBezierVertexNode * node, WFBezierVertexNode * vertices, WFBezierIndexChain * path, BOOL isPathA )
{
	WFBezierVertexNode * next = nodeOnIndexPathAfterNode( node, vertices, path, isPathA );
	if ( next->flags & (WFBezierFlag_SubPathStartA|WFBezierFlag_SubPathStartB) ) {
		// if we looped back around to the beginning we're on a moveTo node which will overlap with the original node so go to the next one after this
		next = nodeOnIndexPathAfterNode( next, vertices, path, isPathA );
	}
	
	CGPoint derivative[3];
	CGFloat pathT;
	
	switch ( (isPathA)?next->elementA:next->elementB ) {
		case NSClosePathBezierPathElement:
			if ( ((isPathA)?node->elementA:node->elementB) == NSMoveToBezierPathElement ) {
				return vectorLeavingNodeForNextNode(next, vertices, path, isPathA);
			}
		case NSLineToBezierPathElement:
		case NSMoveToBezierPathElement:
			return CGPointMake( (next->intersectionPoint.x-node->intersectionPoint.x), (next->intersectionPoint.y-node->intersectionPoint.y) );
			
		default: {
			WFGeometryBezierDerivative( (isPathA)?next->controlPointsA:next->controlPointsB, derivative );
			pathT = (isPathA)?(node->pathA_t-floor(node->pathA_t)):(node->pathB_t-floor(node->pathB_t));
			return WFGeometryEvaluateQuadraticCurve( pathT, derivative );
		}
	}
}

CGPoint vectorLeavingNodeForPreviousNode( WFBezierVertexNode * node, WFBezierVertexNode * vertices, WFBezierIndexChain * path, BOOL isPathA )
{
	WFBezierVertexNode * prev = nodeOnIndexPathBeforeNode( node, vertices, path, isPathA );
	if ( prev->flags & (WFBezierFlag_SubPathEndA|WFBezierFlag_SubPathEndA) ) {
		// if we looped back around to the end we started on a moveTo node which will overlap with the original node so go to the previous one before this
		prev = nodeOnIndexPathBeforeNode( prev, vertices, path, isPathA );
	}
	
	CGPoint derivative[3];
	CGFloat pathT;
	
	switch ( (isPathA)?node->elementA:node->elementB ) {
		case NSMoveToBezierPathElement:
			if ( ((isPathA)?prev->elementA:prev->elementB) == NSClosePathBezierPathElement ) {
				return vectorLeavingNodeForPreviousNode(prev, vertices, path, isPathA);
			}
		case NSClosePathBezierPathElement:
		case NSLineToBezierPathElement:
			return CGPointMake( (prev->intersectionPoint.x-node->intersectionPoint.x), (prev->intersectionPoint.y-node->intersectionPoint.y) );
			
		default: {
			WFGeometryBezierDerivative( (isPathA)?node->controlPointsA:node->controlPointsB, derivative );
			pathT = (isPathA)?(node->pathA_t-floor(node->pathA_t)):(node->pathB_t-floor(node->pathB_t));
			return WFGeometryEvaluateQuadraticCurve( pathT, derivative );
		}
	}
}


void iterateOriginalVerticesOverlappingNode( WFBezierVertexNode * origin, WFBezierVertexNode * vertices, NSUInteger vertexCount, BOOL isPathA, void(^block)(WFBezierVertexNode* node) )
{
	for ( NSUInteger i = 0; i < vertexCount; i++ ) {
		WFBezierVertexNode * node = &vertices[i];
		if ( node->flags & WFBezierFlag_ShouldInvalidate ) continue;
		if ( isPathA ) {
			if ( (node->flags & WFBezierFlag_OriginalEndptA) && WFGeometryDistance(origin->intersectionPoint, node->intersectionPoint) < WFGeometryPointResolution ) {
				block( node );
			}
		} else {
			if ( (node->flags & WFBezierFlag_OriginalEndptB) && WFGeometryDistance(origin->intersectionPoint, node->intersectionPoint) < WFGeometryPointResolution ) {
				block( node );
			}
		}
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

- (CGFloat)WFInteriorAngleFromPoint:(CGPoint)vertex betweenVecA:(CGPoint)vecA andVecB:(CGPoint)vecB
{
	// NOTE: vecA and vecB must be normalized
	CGPoint testPt = CGPointMake( (vecA.x+vecB.x) , (vecA.y+vecB.y) );
	WFGeometryNormalizeVector(&testPt);
	testPt.x *= WFGeometryPointResolution*4.0;
	testPt.y *= WFGeometryPointResolution*4.0;
	testPt.x += vertex.x;
	testPt.y += vertex.y;
	
	if ( [self containsPoint:testPt] ) {
		return asin(fabs( WFGeometryDeterminant2x2(vecA.x, vecA.y, vecB.x, vecB.y) ) );
	} else {
		return 2.0*M_PI-asin( fabs( WFGeometryDeterminant2x2(vecA.x, vecA.y, vecB.x, vecB.y) ) );
	}
}

- (void)WFCoincidentNodeAngularCoverage:(WFBezierVertexNode *)node
								  withPath:(NSBezierPath *)path
								  vertices:(WFBezierVertexNode *)vertices
							   vertexCount:(NSUInteger)vertexCount
								indexPathA:(WFBezierIndexChain *)indexedPathA
								indexPathB:(WFBezierIndexChain *)indexedPathB
								 outXOR:(CGFloat *)outXOR
								 outAND:(CGFloat *)outAND
								  outOR:(CGFloat *)outOR
							   outAOnly:(CGFloat *)outAOnly
{
	NSAssert( node->flags & WFBezierFlag_Coincident, @"Only coincident nodes can be checked" );
	WFBezierVectorAngle vectors[4];
	BOOL found = NO;
	
	if ( node->flags & WFBezierFlag_OriginalEndptA ) {
		vectors[0].vector = vectorLeavingNodeForNextNode( node, vertices, indexedPathA, YES );
		vectors[1].vector = vectorLeavingNodeForPreviousNode( node, vertices, indexedPathA, YES );
		
		for ( NSUInteger i = 0; i < vertexCount; i++) {
			if ( &vertices[i] == node ) continue;
			if ( !(vertices[i].flags & WFBezierFlag_OriginalEndptB) ) continue;
			if ( WFGeometryDistance( vertices[i].intersectionPoint, node->intersectionPoint) > WFGeometryPointResolution ) continue;
			vectors[2].vector = vectorLeavingNodeForNextNode( &vertices[i], vertices, indexedPathB, NO );
			vectors[3].vector = vectorLeavingNodeForPreviousNode( &vertices[i], vertices, indexedPathB, NO );
			found = YES;
			break;
		}
		
	} else if ( node->flags & WFBezierFlag_OriginalEndptB ) {
		vectors[2].vector = vectorLeavingNodeForNextNode( node, vertices, indexedPathB, NO );
		vectors[3].vector = vectorLeavingNodeForPreviousNode( node, vertices, indexedPathB, NO );
		
		for ( NSUInteger i = 0; i < vertexCount; i++) {
			if ( &vertices[i] == node ) continue;
			if ( !(vertices[i].flags & WFBezierFlag_OriginalEndptA) ) continue;
			if ( WFGeometryDistance( vertices[i].intersectionPoint, node->intersectionPoint) > WFGeometryPointResolution ) continue;
			vectors[0].vector = vectorLeavingNodeForNextNode( &vertices[i], vertices, indexedPathA, YES );
			vectors[1].vector = vectorLeavingNodeForPreviousNode( &vertices[i], vertices, indexedPathA, YES );
			found = YES;
			break;
		}
	}
	
	if ( found ) {
		[self WFAngularEnclosureAtVertex:node->intersectionPoint withPath:path vectors:vectors outXOR:outXOR outAND:outAND outOR:outOR outAOnly:outAOnly];
	} else {
		NSLog(@"No overlapping node found for node marked as coincident. Angular coverage can not be determined.");
		*outXOR = 0.0;
		*outAND = 0.0;
		*outOR = 0.0;
	}
}

- (void)WFParallelIntersectEncloseureForNode:(WFBezierVertexNode *)node
									withPath:(NSBezierPath *)path
									vertices:(WFBezierVertexNode *)vertices
								  indexPathA:(WFBezierIndexChain *)indexedPathA
								  indexPathB:(WFBezierIndexChain *)indexedPathB
									  outXOR:(CGFloat *)outXOR
									  outAND:(CGFloat *)outAND
									   outOR:(CGFloat *)outOR
									outAOnly:(CGFloat *)outAOnly
{
	NSAssert( WFNodeIsOnBothPaths(node), @"Parallel intersection enclosure can not be determined for an endpoint node");
	NSAssert( (node->flags & WFBezierFlag_ParallelIntersect), @"Parallel intersection enclosure can not be determined for an intersection that is not on a parallel segment");
	
	WFBezierVectorAngle vectors[4];
	
	vectors[0].vector = vectorLeavingNodeForNextNode( node, vertices, indexedPathA, YES );
	vectors[1].vector = vectorLeavingNodeForPreviousNode( node, vertices, indexedPathA, YES );
	vectors[2].vector = vectorLeavingNodeForNextNode( node, vertices, indexedPathB, NO );
	vectors[3].vector = vectorLeavingNodeForPreviousNode( node, vertices, indexedPathB, NO );
	[self WFAngularEnclosureAtVertex:node->intersectionPoint withPath:path vectors:vectors outXOR:outXOR outAND:outAND outOR:outOR outAOnly:outAOnly];
}

- (void)WFAngularEnclosureAtVertex:(CGPoint)vertex
						  withPath:(NSBezierPath *)path
						   vectors:(WFBezierVectorAngle *)vectors
							outXOR:(CGFloat *)outXOR
							outAND:(CGFloat *)outAND
							 outOR:(CGFloat *)outOR
						  outAOnly:(CGFloat *)outAOnly
{
	WFGeometryNormalizeVector(&vectors[0].vector);
	WFGeometryNormalizeVector(&vectors[1].vector);
	WFGeometryNormalizeVector(&vectors[2].vector);
	WFGeometryNormalizeVector(&vectors[3].vector);
	vectors[0].angle = atan2( vectors[0].vector.y, vectors[0].vector.x );
	vectors[1].angle = atan2( vectors[1].vector.y, vectors[1].vector.x );
	vectors[2].angle = atan2( vectors[2].vector.y, vectors[2].vector.x );
	vectors[3].angle = atan2( vectors[3].vector.y, vectors[3].vector.x );
	for ( NSUInteger i = 0; i < 4; i++ ) {
		vectors[i].startA = NO;
		vectors[i].startB = NO;
		vectors[i].endA = NO;
		vectors[i].endB = NO;
		if ( vectors[i].angle < 0.0 ) {
			vectors[i].angle = 2.0*M_PI + vectors[i].angle;
		}
	}
	
	CGPoint testPt;
	CGPoint normals[2];
	
	normals[0].x = -vectors[0].vector.y;
	normals[0].y = vectors[0].vector.x;
	normals[1].x = vectors[1].vector.y;
	normals[1].y = -vectors[1].vector.x;
	testPt = CGPointMake( (normals[0].x+normals[1].x)/2 , (normals[0].y+normals[1].y)/2 );
	WFGeometryNormalizeVector(&testPt);
	testPt.x *= WFGeometryPointResolution*4.0;
	testPt.y *= WFGeometryPointResolution*4.0;
	testPt.x += vertex.x;
	testPt.y += vertex.y;
	if ( [self containsPoint:testPt] ) {
		vectors[0].startA = YES;
		vectors[0].endA = NO;
		vectors[1].startA = NO;
		vectors[1].endA = YES;
	} else {
		vectors[0].startA = NO;
		vectors[0].endA = YES;
		vectors[1].startA = YES;
		vectors[1].endA = NO;
	}
	
	normals[0].x = -vectors[2].vector.y;
	normals[0].y = vectors[2].vector.x;
	normals[1].x = vectors[3].vector.y;
	normals[1].y = -vectors[3].vector.x;
	testPt = CGPointMake( (normals[0].x+normals[1].x)/2 , (normals[0].y+normals[1].y)/2 );
	WFGeometryNormalizeVector(&testPt);
	testPt.x *= WFGeometryPointResolution*4.0;
	testPt.y *= WFGeometryPointResolution*4.0;
	testPt.x += vertex.x;
	testPt.y += vertex.y;
	if ( [path containsPoint:testPt] ) {
		vectors[2].startB = YES;
		vectors[2].endB = NO;
		vectors[3].startB = NO;
		vectors[3].endB = YES;
	} else {
		vectors[2].startB = NO;
		vectors[2].endB = YES;
		vectors[3].startB = YES;
		vectors[3].endB = NO;
	}
	
	qsort_b( vectors, 4, sizeof(WFBezierVectorAngle), ^int(const void * a, const void * b) {
		WFBezierVectorAngle * pa = (WFBezierVectorAngle *)a;
		WFBezierVectorAngle * pb = (WFBezierVectorAngle *)b;
		if ( pa->angle > pb->angle ) return 1;
		return -1;
	});
	
	BOOL onA = NO;
	BOOL onB = NO;
	BOOL retraceA = NO;
	BOOL startedA = NO;
	BOOL startedB = NO;
	BOOL finishedA = NO;
	BOOL finishedB = NO;
	*outXOR = 0.0;
	*outAND = 0.0;
	*outOR = 0.0;
	*outAOnly = 0.0;
	NSUInteger i = 0;
	
	while ( !vectors[i%4].startA ) i++; // skip to the start of angular coverage of A polygon
	
	while ( !finishedA || !finishedB ) {
		if ( vectors[i%4].startA && !startedA ) {
			onA = YES;
			startedA = YES;
		}
		if ( vectors[i%4].startB && !startedB ) {
			onB = YES;
			startedB = YES;
		}
		if ( vectors[i%4].startA && finishedA ) {
			retraceA = YES;
		}
		
		CGFloat delta = vectors[(i+1)%4].angle - vectors[i%4].angle;
		if ( delta < 0.0 ) delta = 2.0*M_PI+delta;
		
		if ( retraceA ) {
			if ( onB ) {
				*outXOR -= delta;
				*outAND += delta;
				*outAOnly -= delta;
			}
		} else {
			if ( onA != onB ) *outXOR += delta;
			if ( onA && onB ) *outAND += delta;
			if ( onA || onB ) *outOR += delta;
			if ( onA && !onB ) *outAOnly += delta;
		}
		
		if ( vectors[(i+1)%4].endA && startedA ) {
			onA = NO;
			finishedA = YES;
		}
		if ( vectors[(i+1)%4].endB && startedB ) {
			onB = NO;
			finishedB = YES;
		}
		i++;
	}
}

- (BOOL)WFContainsNode:(WFBezierVertexNode *)node
{
	if ( node->flags & WFBezierFlag_Coincident ) return NO;
	if ( WFNodeIsOnBothPaths(node) ) return NO;
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

- (NSBezierPath *)WFTraversePath:(NSBezierPath *)path withOptions:(NSUInteger)options
					 pointFinder:(WFBezierVertexNode*(^)(WFBezierVertexNode * vertices, NSUInteger vertexCount, WFBezierIndexChain * pathA, WFBezierIndexChain * pathB, BOOL * isPathA))findNextStartingPoint
		   parallelIntersectRule:(void(^)(WFBezierVertexNode* node, WFBezierVertexNode * vertices, NSUInteger vertexCount, WFBezierIndexChain * pathA, WFBezierIndexChain * pathB, BOOL * canUsePathA, BOOL * canUsePathB))validTraveralFromParallelIntersection
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
		if ( !WFNodeIsOnBothPaths(node) ) continue;
		if ( node->flags & WFBezierFlag_ShouldInvalidate ) continue;
		if ( node->flags & WFBezierFlag_PointInvalid ) continue;
		BOOL pathAOnEndpt = fabs(node->pathA_t-round(node->pathA_t)) <= WFGeometryParametricResolution;
		BOOL pathBOnEndpt = fabs(node->pathB_t-round(node->pathB_t)) <= WFGeometryParametricResolution;
		
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
		BOOL adjacentBoundaries = NO;
		
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
			coincidentBoundaries |= (originalA && originalB);
			if ( !crossesBoundary && WFNodeIsOnBothPaths(nextNodeA) && !originalVertexOverlappingNode(nextNodeA, vertices, indexedPathA, YES) ) {
				CGPoint testPt = midPointBetweenNodes( node, nextNodeA, YES );
				crossesBoundary |= [path containsPoint:testPt];
			}
			if ( !crossesBoundary && WFNodeIsOnBothPaths(nextNodeB) && !originalVertexOverlappingNode(nextNodeB, vertices, indexedPathB, NO) ) {
				CGPoint testPt = midPointBetweenNodes( node, nextNodeB, NO );
				crossesBoundary |= [self containsPoint:testPt];
			}
			if ( !crossesBoundary ) {
				adjacentBoundaries |= WFGeometryVectorsAdjacent4( testVec1A, testVec2A, testVec1B, testVec2B );
			}
		}
		
		if ( originalA ) {
			if ( crossesBoundary || adjacentBoundaries ) {
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
				/*iterateOriginalVerticesOverlappingNode( node, vertices, vertexCount, YES, ^(WFBezierVertexNode *hit) {
					hit->flags |= WFBezierFlag_ShouldInvalidate;
				});*/
			} else {
				node->flags |= WFBezierFlag_ShouldInvalidate;
				//iterateOriginalVerticesOverlappingNode( node, vertices, vertexCount, YES, ^(WFBezierVertexNode *hit) {
				//	hit->flags |= WFBezierFlag_Coincident;
				//});
				originalA->flags |= WFBezierFlag_Coincident;
			}
		}
		if ( originalB ) {
			if ( crossesBoundary || adjacentBoundaries ) {
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
				/*iterateOriginalVerticesOverlappingNode( node, vertices, vertexCount, NO, ^(WFBezierVertexNode *hit) {
					hit->flags |= WFBezierFlag_ShouldInvalidate;
				});*/
			} else {
				node->flags |= WFBezierFlag_ShouldInvalidate;
				//iterateOriginalVerticesOverlappingNode( node, vertices, vertexCount, NO, ^(WFBezierVertexNode *hit) {
				//	hit->flags |= WFBezierFlag_Coincident;
				//});
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
			pathIndex = (isPathA)?node->pathAIndex:node->pathBIndex;
		}
		
		//
		// Select the next node on the path
		//
		if ( !(node->flags & WFBezierFlag_PointInvalid) && (node->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB)) == (WFBezierFlag_PathA|WFBezierFlag_PathB) ) {
			if ( (node->flags & WFBezierFlag_ParallelIntersect) ) {
				// If node is a parallel path intersection, we should only switch paths if the next node on either path is NOT an intersection
				BOOL canUsePathA = YES;
				BOOL canUsePathB = YES;
				validTraveralFromParallelIntersection( node, vertices, vertexCount, indexedPathA, indexedPathB, &canUsePathA, &canUsePathB );
				if ( !canUsePathA && !canUsePathB ) {
					// end this sub-path at this node if there is no way to traverse from it
					node->flags |= WFBezierFlag_PointUsed;
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
	WFBezierVertexNode * (^pointFinder) (WFBezierVertexNode * vertices, NSUInteger vertexCount, WFBezierIndexChain * indexedPathA, WFBezierIndexChain * indexedPathB, BOOL * isPathA);
	void (^parallelIntersectRules) (WFBezierVertexNode * node, WFBezierVertexNode * vertices, NSUInteger vertexCount, WFBezierIndexChain * pathA, WFBezierIndexChain * pathB, BOOL * canUsePathA, BOOL * canUsePathB);
	
	pointFinder = ^(WFBezierVertexNode * vertices, NSUInteger vertexCount, WFBezierIndexChain * indexedPathA, WFBezierIndexChain * indexedPathB, BOOL * isPathA)
	{
		for ( NSUInteger i = 0; i < vertexCount; i++ ) {
			if ( vertices[i].flags & (WFBezierFlag_PointUsed|WFBezierFlag_PointInvalid) ) continue;
			WFBezierVertexNode * node = &vertices[i];
			
			if ( WFNodeIsOnBothPaths(node) ) {
				// new node is an intersection, figure out which path to traverse
				WFBezierVertexNode * nextNodeA = nodeOnIndexPathAfterNode(node, vertices, indexedPathA, YES);
				WFBezierVertexNode * nextNodeB = nodeOnIndexPathAfterNode(node, vertices, indexedPathB, NO);
				
				if ( node->flags & WFBezierFlag_ParallelIntersect ) {
					CGFloat XORCoverage;
					CGFloat ANDCoverage;
					CGFloat ORCoverage;
					CGFloat ACoverage;
					[self WFParallelIntersectEncloseureForNode:node
													  withPath:path
													  vertices:vertices
													indexPathA:indexedPathA
													indexPathB:indexedPathB
														outXOR:&XORCoverage
														outAND:&ANDCoverage
														 outOR:&ORCoverage
													  outAOnly:&ACoverage];
					if ( XORCoverage >= (2.0*M_PI-WFGeometryAngularResolution) ) {
						node->flags |= WFBezierFlag_PointUsed;
						continue;
					}
					// Parallel intersect nodes can start on either path, and we can always start on a parallel intersection as long as it is not inside the union.
					return node;
				}
				
				if ( !WFNodeIsOnBothPaths(nextNodeA) ) {
					if ( ![path WFContainsNode:nextNodeA] ) {
						// Next node on pathA is not an intersection and is not contained in the other path so we can use this node on path A.
						*isPathA = NO;
						return node;
					}
				}
				if ( !WFNodeIsOnBothPaths(nextNodeB) ) {
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
				if ( node->elementA == NSCurveToBezierPathElement && WFNodeIsOnBothPaths(nextNodeA) && nextNodeA->elementA == NSCurveToBezierPathElement  ) {
					CGPoint p = midPointBetweenNodes(node, nextNodeA, YES);
					if ( ![path containsPoint:p] ) {
						*isPathA = NO;
						return node;
					}
				}
				if ( node->elementB == NSCurveToBezierPathElement && WFNodeIsOnBothPaths(nextNodeB) && nextNodeB->elementB == NSCurveToBezierPathElement  ) {
					CGPoint p = midPointBetweenNodes(node, nextNodeA, NO);
					if ( ![self containsPoint:p] ) {
						*isPathA = YES;
						return node;
					}
				}
				
			} else {
				// new node is an endpoint
				CGFloat XORCoverage;
				CGFloat ANDCoverage;
				CGFloat ORCoverage;
				CGFloat ACoverage;
				*isPathA = (node->flags & WFBezierFlag_PathA);
				if ( node->flags & WFBezierFlag_Coincident ) {
					[self WFCoincidentNodeAngularCoverage:node
												 withPath:path
												 vertices:vertices
											  vertexCount:vertexCount
											   indexPathA:indexedPathA
											   indexPathB:indexedPathB
												   outXOR:&XORCoverage
												   outAND:&ANDCoverage
													outOR:&ORCoverage
												 outAOnly:&ACoverage];
					if ( ORCoverage < 2.0*M_PI-WFGeometryAngularResolution ) {
						return node;
					}
				} else {
					if ( *isPathA ) {
						if ( ![path WFContainsNode:node] ) return node;
					} else {
						if ( ![self WFContainsNode:node] ) return node;
					}
				}
			}
			
			node->flags |= WFBezierFlag_PointUsed;
		}
		return (WFBezierVertexNode *)NULL;
	};
	
	parallelIntersectRules = ^(WFBezierVertexNode* node, WFBezierVertexNode *vertices, NSUInteger vertexCount, WFBezierIndexChain *pathA, WFBezierIndexChain *pathB, BOOL *canUsePathA, BOOL *canUsePathB)
	{
		WFBezierVertexNode * nextNodeA = nodeOnIndexPathAfterNode(node, vertices, pathA, YES);
		WFBezierVertexNode * nextNodeB = nodeOnIndexPathAfterNode(node, vertices, pathB, NO);
		CGFloat XORCoverage;
		CGFloat ANDCoverage;
		CGFloat ORCoverage;
		CGFloat ACoverage;
		
		if ( nextNodeA != nextNodeB ) {
			if ( WFNodeIsOnBothPaths( nextNodeA ) ) {
				if ( nextNodeA->flags & WFBezierFlag_ParallelIntersect ) {
					[self WFParallelIntersectEncloseureForNode:nextNodeA
													  withPath:path
													  vertices:vertices
													indexPathA:pathA
													indexPathB:pathB
														outXOR:&XORCoverage
														outAND:&ANDCoverage
														 outOR:&ORCoverage
													  outAOnly:&ACoverage];
					
					*canUsePathA = *canUsePathA && XORCoverage < (2.0*M_PI-WFGeometryAngularResolution);
				}
				CGPoint testPtA = midPointBetweenNodes( node, nextNodeA, YES );
				*canUsePathA = *canUsePathA && ![path containsPoint:testPtA];
			} else {
				if ( nextNodeA->flags & WFBezierFlag_Coincident ) {
					CGPoint testPtA = midPointBetweenNodes( node, nextNodeA, YES );
					*canUsePathA = *canUsePathA && ![path containsPoint:testPtA];
				} else {
					*canUsePathA = *canUsePathA && ![path WFContainsNode:nextNodeA];
				}
			}
			if ( WFNodeIsOnBothPaths( nextNodeB ) ) {
				if ( nextNodeB->flags & WFBezierFlag_ParallelIntersect ) {
					[self WFParallelIntersectEncloseureForNode:nextNodeB
													  withPath:path
													  vertices:vertices
													indexPathA:pathA
													indexPathB:pathB
														outXOR:&XORCoverage
														outAND:&ANDCoverage
														 outOR:&ORCoverage
													  outAOnly:&ACoverage];
					
					*canUsePathB = *canUsePathB && XORCoverage < (2.0*M_PI-WFGeometryAngularResolution);
				}
				CGPoint testPtB = midPointBetweenNodes( node, nextNodeB, NO );
				*canUsePathB = *canUsePathB && ![self containsPoint:testPtB];
			} else {
				if ( nextNodeB->flags & WFBezierFlag_Coincident ) {
					CGPoint testPtB = midPointBetweenNodes( node, nextNodeB, NO );
					*canUsePathB = *canUsePathB && ![self containsPoint:testPtB];
				} else {
					*canUsePathB = *canUsePathB && ![self WFContainsNode:nextNodeB];
				}
			}
		}
	};
	
	NSBezierPath * result = [self WFTraversePath:path
									 withOptions:0
									 pointFinder:pointFinder
						   parallelIntersectRule:parallelIntersectRules];
	
	return result;
}

- (NSBezierPath *)WFSubtractPath:(NSBezierPath *)path
{
	WFBezierVertexNode * (^pointFinder) (WFBezierVertexNode * vertices, NSUInteger vertexCount, WFBezierIndexChain * indexedPathA, WFBezierIndexChain * indexedPathB, BOOL * isPathA);
	void (^parallelIntersectRules) (WFBezierVertexNode * node, WFBezierVertexNode * vertices, NSUInteger vertexCount, WFBezierIndexChain * pathA, WFBezierIndexChain * pathB, BOOL * canUsePathA, BOOL * canUsePathB);
	
	pointFinder = ^(WFBezierVertexNode * vertices, NSUInteger vertexCount, WFBezierIndexChain * indexedPathA, WFBezierIndexChain * indexedPathB, BOOL * isPathA)
	{
		WFBezierVertexNode * node = NULL;
		
		for ( NSUInteger i = 0; i < vertexCount; i++ ) {
			if ( vertices[i].flags & (WFBezierFlag_PointUsed|WFBezierFlag_PointInvalid) ) continue;
			node = &vertices[i];
			
			if ( (node->flags & (WFBezierFlag_PathA|WFBezierFlag_PathB)) == (WFBezierFlag_PathA|WFBezierFlag_PathB) ) {
				WFBezierVertexNode * nextNodeA = nodeOnIndexPathAfterNode(node, vertices, indexedPathA, YES);
				WFBezierVertexNode * nextNodeB = nodeOnIndexPathAfterNode(node, vertices, indexedPathB, NO);
				
				if ( (node->flags & WFBezierFlag_ParallelIntersect) ) {
					CGFloat XORCoverage;
					CGFloat ANDCoverage;
					CGFloat ORCoverage;
					CGFloat ACoverage;
					[self WFParallelIntersectEncloseureForNode:node
													  withPath:path
													  vertices:vertices
													indexPathA:indexedPathA
													indexPathB:indexedPathB
														outXOR:&XORCoverage
														outAND:&ANDCoverage
														 outOR:&ORCoverage
													  outAOnly:&ACoverage];
					
					if ( ACoverage <= WFGeometryAngularResolution ) {
						node->flags |= WFBezierFlag_PointUsed;
						continue;
					}
					// Parallel intersect nodes can start on either path, and we can always start on a parallel intersection as long as it is not completely subtracted.
					return node;
				}
				
				if ( !WFNodeIsOnBothPaths(nextNodeA) ) {
					if ( ![path WFContainsNode:nextNodeA] ) {
						// Next node on pathA is not an intersection and is not contained within the negative path so we can traverse from pathA
						*isPathA = NO;
						return node;
					}
				} else {
					CGPoint p = midPointBetweenNodes(node, nextNodeA, YES);
					if ( ![path containsPoint:p] ) {
						*isPathA = NO;
						return node;
					}
				}
				if ( !WFNodeIsOnBothPaths(nextNodeB) ) {
					if ( [self WFContainsNode:nextNodeB] ) {
						// Next node on pathB is not an intersection and is contained in the positive path so we can traverse from pathB
						*isPathA = YES;
						return node;
					}
				} else {
					CGPoint p = midPointBetweenNodes(node, nextNodeB, NO);
					if ( [self containsPoint:p] ) {
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
				CGFloat XORCoverage;
				CGFloat ANDCoverage;
				CGFloat ORCoverage;
				CGFloat ACoverage;
				
				*isPathA = (node->flags & WFBezierFlag_PathA);
				if ( node->flags & WFBezierFlag_Coincident ) {
					[self WFCoincidentNodeAngularCoverage:node
												 withPath:path
												 vertices:vertices
											  vertexCount:vertexCount
											   indexPathA:indexedPathA
											   indexPathB:indexedPathB
												   outXOR:&XORCoverage
												   outAND:&ANDCoverage
													outOR:&ORCoverage
												 outAOnly:&ACoverage];
					if ( ACoverage > WFGeometryAngularResolution && (*isPathA) ) return node;
				} else {
					if ( *isPathA ) {
						if ( ![path WFContainsNode:node] ) return node;
					} else {
						if ( [self WFContainsNode:node] ) return node;
					}
				}
			}
			
			node->flags |= WFBezierFlag_PointUsed;
		}
		return (WFBezierVertexNode *)NULL;
	};
	
	parallelIntersectRules = ^(WFBezierVertexNode* node, WFBezierVertexNode *vertices, NSUInteger vertexCount, WFBezierIndexChain *pathA, WFBezierIndexChain *pathB, BOOL *canUsePathA, BOOL *canUsePathB)
	{
		WFBezierVertexNode * nextNodeA = nodeOnIndexPathAfterNode(node, vertices, pathA, YES);
		WFBezierVertexNode * nextNodeB = nodeOnIndexPathAfterNode(node, vertices, pathB, NO);
		CGFloat XORCoverage;
		CGFloat ANDCoverage;
		CGFloat ORCoverage;
		CGFloat ACoverage;
		
		if ( nextNodeA != nextNodeB ) {
			CGPoint testPtA = midPointBetweenNodes( node, nextNodeA, YES );
			CGPoint testPtB = midPointBetweenNodes( node, nextNodeB, NO );
			
			if ( WFNodeIsOnBothPaths( nextNodeA ) ) {
				if ( nextNodeA->flags & WFBezierFlag_ParallelIntersect ) {
					[self WFParallelIntersectEncloseureForNode:nextNodeA
													  withPath:path
													  vertices:vertices
													indexPathA:pathA
													indexPathB:pathB
														outXOR:&XORCoverage
														outAND:&ANDCoverage
														 outOR:&ORCoverage
													  outAOnly:&ACoverage];
					*canUsePathA = *canUsePathA && (ACoverage > WFGeometryAngularResolution);
					if ( nodeOnIndexPathBeforeNode(node, vertices, pathB, NO) == nextNodeA ) {
						*canUsePathA = NO;
					}
				}
				*canUsePathA = *canUsePathA && ![path containsPoint:testPtA];
			} else {
				if ( nextNodeA->flags & WFBezierFlag_Coincident ) {
					[self WFCoincidentNodeAngularCoverage:nextNodeA
												 withPath:path
												 vertices:vertices
											  vertexCount:vertexCount
											   indexPathA:pathA
											   indexPathB:pathB
												   outXOR:&XORCoverage
												   outAND:&ANDCoverage
													outOR:&ORCoverage
												 outAOnly:&ACoverage];
					*canUsePathA = *canUsePathA && ( ACoverage > WFGeometryAngularResolution );
					*canUsePathA = *canUsePathA && ![path containsPoint:testPtA];
				} else {
					*canUsePathA = *canUsePathA && ![path WFContainsNode:nextNodeA];
				}
			}
			if ( WFNodeIsOnBothPaths( nextNodeB ) ) {
				if ( nextNodeB->flags & WFBezierFlag_ParallelIntersect ) {
					[self WFParallelIntersectEncloseureForNode:nextNodeB
													  withPath:path
													  vertices:vertices
													indexPathA:pathA
													indexPathB:pathB
														outXOR:&XORCoverage
														outAND:&ANDCoverage
														 outOR:&ORCoverage
													  outAOnly:&ACoverage];
					*canUsePathB = *canUsePathB && (ACoverage > WFGeometryAngularResolution);
					if ( nodeOnIndexPathBeforeNode(node, vertices, pathA, YES) == nextNodeB ) {
						*canUsePathB = NO;
					}
				}
				*canUsePathB = *canUsePathB && [self containsPoint:testPtB];
			} else {
				if ( nextNodeB->flags & WFBezierFlag_Coincident ) {
					[self WFCoincidentNodeAngularCoverage:nextNodeB
												 withPath:path
												 vertices:vertices
											  vertexCount:vertexCount
											   indexPathA:pathA
											   indexPathB:pathB
												   outXOR:&XORCoverage
												   outAND:&ANDCoverage
													outOR:&ORCoverage
												 outAOnly:&ACoverage];
					*canUsePathB = *canUsePathB && ( ACoverage > WFGeometryAngularResolution );
					*canUsePathB = *canUsePathB && [self containsPoint:testPtB];
				} else {
					*canUsePathB = *canUsePathB && [self WFContainsNode:nextNodeB];
				}
			}
		}
	};
	
	NSBezierPath * result = [self WFTraversePath:[path bezierPathByReversingPath]
									 withOptions:0
									 pointFinder:pointFinder
						   parallelIntersectRule:parallelIntersectRules];
	
	return result;
}

- (NSBezierPath * )WFIntersectWithPath:(NSBezierPath *)path
{
	
	WFBezierVertexNode * (^pointFinder) (WFBezierVertexNode * vertices, NSUInteger vertexCount, WFBezierIndexChain * indexedPathA, WFBezierIndexChain * indexedPathB, BOOL * isPathA);
	void (^parallelIntersectRules) (WFBezierVertexNode * node, WFBezierVertexNode * vertices, NSUInteger vertexCount, WFBezierIndexChain * pathA, WFBezierIndexChain * pathB, BOOL * canUsePathA, BOOL * canUsePathB);
	
	pointFinder = ^(WFBezierVertexNode * vertices, NSUInteger vertexCount, WFBezierIndexChain * indexedPathA, WFBezierIndexChain * indexedPathB, BOOL * isPathA)
	{
		WFBezierVertexNode * node = NULL;
		
		for ( NSUInteger i = 0; i < vertexCount; i++ ) {
			if ( vertices[i].flags & (WFBezierFlag_PointUsed|WFBezierFlag_PointInvalid) ) continue;
			node = &vertices[i];
			
			if ( WFNodeIsOnBothPaths(node) ) {
				WFBezierVertexNode * nextNodeA = nodeOnIndexPathAfterNode(node, vertices, indexedPathA, YES);
				WFBezierVertexNode * nextNodeB = nodeOnIndexPathAfterNode(node, vertices, indexedPathB, NO);
				
				if ( (node->flags & WFBezierFlag_ParallelIntersect) ) {
					CGFloat XORCoverage;
					CGFloat ANDCoverage;
					CGFloat ORCoverage;
					CGFloat ACoverage;
					[self WFParallelIntersectEncloseureForNode:node
													  withPath:path
													  vertices:vertices
													indexPathA:indexedPathA
													indexPathB:indexedPathB
														outXOR:&XORCoverage
														outAND:&ANDCoverage
														 outOR:&ORCoverage
													  outAOnly:&ACoverage];
					
					if ( ANDCoverage <= WFGeometryAngularResolution ) {
						node->flags |= WFBezierFlag_PointUsed;
						continue;
					}
					// Parallel intersect nodes can start on either path, and we can always start on a parallel intersection as long as it encloses a portion of both paths
					return node;
				}
				
				if ( !WFNodeIsOnBothPaths(nextNodeA) ) {
					if ( [path WFContainsNode:nextNodeA] ) {
						*isPathA = NO;
						return node;
					}
				} else {
					CGPoint p = midPointBetweenNodes(node, nextNodeA, YES);
					if ( [path containsPoint:p] ) {
						*isPathA = NO;
						return node;
					}
				}
				
				if ( !WFNodeIsOnBothPaths(nextNodeB) ) {
					if ( [self WFContainsNode:nextNodeB] ) {
						*isPathA = YES;
						return node;
					}
				} else {
					CGPoint p = midPointBetweenNodes(node, nextNodeB, NO);
					if ( [self containsPoint:p] ) {
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
				CGFloat XORCoverage;
				CGFloat ANDCoverage;
				CGFloat ORCoverage;
				CGFloat ACoverage;
				
				*isPathA = (node->flags & WFBezierFlag_PathA);
				if ( node->flags & WFBezierFlag_Coincident ) {
					[self WFCoincidentNodeAngularCoverage:node
												 withPath:path
												 vertices:vertices
											  vertexCount:vertexCount
											   indexPathA:indexedPathA
											   indexPathB:indexedPathB
												   outXOR:&XORCoverage
												   outAND:&ANDCoverage
													outOR:&ORCoverage
												 outAOnly:&ACoverage];
					if ( ANDCoverage > WFGeometryAngularResolution ) return node;
				} else {
					if ( *isPathA ) {
						if ( [path WFContainsNode:node] ) return node;
					} else {
						if ( [self WFContainsNode:node] ) return node;
					}
				}
			}
			
			node->flags |= WFBezierFlag_PointUsed;
		}
		return (WFBezierVertexNode *)NULL;
	};
	
	parallelIntersectRules = ^(WFBezierVertexNode* node, WFBezierVertexNode *vertices, NSUInteger vertexCount, WFBezierIndexChain *pathA, WFBezierIndexChain *pathB, BOOL *canUsePathA, BOOL *canUsePathB)
	{
		WFBezierVertexNode * nextNodeA = nodeOnIndexPathAfterNode(node, vertices, pathA, YES);
		WFBezierVertexNode * nextNodeB = nodeOnIndexPathAfterNode(node, vertices, pathB, NO);
		CGFloat XORCoverage;
		CGFloat ANDCoverage;
		CGFloat ORCoverage;
		CGFloat ACoverage;
		
		if ( nextNodeA != nextNodeB ) {
			CGPoint testPtA = midPointBetweenNodes( node, nextNodeA, YES );
			CGPoint testPtB = midPointBetweenNodes( node, nextNodeB, NO );
			
			if ( WFNodeIsOnBothPaths( nextNodeA ) ) {
				if ( nextNodeA->flags & WFBezierFlag_ParallelIntersect ) {
					[self WFParallelIntersectEncloseureForNode:nextNodeA
													  withPath:path
													  vertices:vertices
													indexPathA:pathA
													indexPathB:pathB
														outXOR:&XORCoverage
														outAND:&ANDCoverage
														 outOR:&ORCoverage
													  outAOnly:&ACoverage];
					*canUsePathA = *canUsePathA && (ANDCoverage > WFGeometryAngularResolution);
					if ( nodeOnIndexPathBeforeNode(node, vertices, pathB, NO) == nextNodeA ) {
						*canUsePathA = NO;
					}
				}
				*canUsePathA = *canUsePathA && [path containsPoint:testPtA];
			} else {
				if ( nextNodeA->flags & WFBezierFlag_Coincident ) {
					[self WFCoincidentNodeAngularCoverage:nextNodeA
												 withPath:path
												 vertices:vertices
											  vertexCount:vertexCount
											   indexPathA:pathA
											   indexPathB:pathB
												   outXOR:&XORCoverage
												   outAND:&ANDCoverage
													outOR:&ORCoverage
												 outAOnly:&ACoverage];
					*canUsePathA = *canUsePathA && ( ANDCoverage > WFGeometryAngularResolution );
					*canUsePathA = *canUsePathA && [path containsPoint:testPtA];
				} else {
					*canUsePathA = *canUsePathA && [path WFContainsNode:nextNodeA];
				}
			}
			if ( WFNodeIsOnBothPaths( nextNodeB ) ) {
				if ( nextNodeB->flags & WFBezierFlag_ParallelIntersect ) {
					[self WFParallelIntersectEncloseureForNode:nextNodeB
													  withPath:path
													  vertices:vertices
													indexPathA:pathA
													indexPathB:pathB
														outXOR:&XORCoverage
														outAND:&ANDCoverage
														 outOR:&ORCoverage
													  outAOnly:&ACoverage];
					*canUsePathB = *canUsePathB && (ANDCoverage > WFGeometryAngularResolution);
					if ( nodeOnIndexPathBeforeNode(node, vertices, pathA, YES) == nextNodeB ) {
						*canUsePathB = NO;
					}
				}
				*canUsePathB = *canUsePathB && [self containsPoint:testPtB];
			} else {
				if ( nextNodeB->flags & WFBezierFlag_Coincident ) {
					[self WFCoincidentNodeAngularCoverage:nextNodeB
												 withPath:path
												 vertices:vertices
											  vertexCount:vertexCount
											   indexPathA:pathA
											   indexPathB:pathB
												   outXOR:&XORCoverage
												   outAND:&ANDCoverage
													outOR:&ORCoverage
												 outAOnly:&ACoverage];
					*canUsePathB = *canUsePathB && ( ANDCoverage > WFGeometryAngularResolution );
					*canUsePathB = *canUsePathB && [self containsPoint:testPtB];
				} else {
					*canUsePathB = *canUsePathB && [self WFContainsNode:nextNodeB];
				}
			}
		}
	};
	
	NSBezierPath * result = [self WFTraversePath:path
									 withOptions:0
									 pointFinder:pointFinder
						   parallelIntersectRule:parallelIntersectRules];
	
	return result;
}

- (NSString *)WFTestCaseDump
{
	NSMutableString * result = [[NSMutableString alloc] init];
	CGPoint points[3];
	[result appendFormat:@"XCTAssertTrue( [result elementCount] == %li, @\"Incorrect element count\" );\n", (long)[self elementCount]];
	for ( NSUInteger i = 0; i < [self elementCount]; i++) {
		NSBezierPathElement element = [self elementAtIndex:i associatedPoints:points];
		[result appendFormat:@"element = [result elementAtIndex:%lu associatedPoints:points];\n", i];
		switch ( element ) {
			case NSLineToBezierPathElement:
				[result appendString:@"XCTAssertTrue( element == NSLineToBezierPathElement, @\"Incorrect element\" );\n"];
				break;
			case NSCurveToBezierPathElement:
				[result appendString:@"XCTAssertTrue( element == NSCurveToBezierPathElement, @\"Incorrect element\" );\n"];
				break;
			case NSMoveToBezierPathElement:
				[result appendString:@"XCTAssertTrue( element == NSMoveToBezierPathElement, @\"Incorrect element\" );\n"];
				break;
			case NSClosePathBezierPathElement:
				[result appendString:@"XCTAssertTrue( element == NSClosePathBezierPathElement, @\"Incorrect element\" );\n"];
				break;
		}
		[result appendFormat:@"XCTAssertTrue( WFGeometryDistance(points[0], CGPointMake(%f, %f)) <= WFBezierPointAcceptanceResolution, @\"Incorrect result point\" );\n", points[0].x, points[0].y];
		if ( element == NSCurveToBezierPathElement ) {
			[result appendFormat:@"XCTAssertTrue( WFGeometryDistance(points[1], CGPointMake(%f, %f)) <= WFBezierPointAcceptanceResolution, @\"Incorrect result point\" );\n", points[1].x, points[1].y];
			[result appendFormat:@"XCTAssertTrue( WFGeometryDistance(points[2], CGPointMake(%f, %f)) <= WFBezierPointAcceptanceResolution, @\"Incorrect result point\" );\n", points[2].x, points[2].y];
		}
	}
	
	return result;
}


@end
