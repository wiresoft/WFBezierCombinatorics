WFBezierCombinatorics
=====================

Adds 3 public methods to NSBezierPath for performing boolean operations on paths:

- (NSBezierPath *)WFUnionWithPath:(NSBezierPath *)path;

- (NSBezierPath *)WFIntersectWithPath:(NSBezierPath *)path;

- (NSBezierPath *)WFSubtractPath:(NSBezierPath *)path;

In all cases, the receiver and input paths are not modified. The returned result is a new path constructed by performing the boolean operation on the receiver and input path. A sample app illustrates the usage, which is quite simple.


Input Requirements:
===================
- Input paths must be wound using the default NSNonZeroWindingRule
- Input paths must not be self-intersecting
- An input path may not have coincident edges or vertices with itself


Compilation Requirements:
=========================
This code requires ARC. If your project does not use ARC globally, you should enable it on a file-by-file bases for the “NSBezierPath+WFBezierCombinatorics.m” file.


Notes:
======
The output path will not contain elements of type NSClosePathElement. Sub-paths are implicitly closed by a line or arc with an endpoint at the same location as the initial moveTo element that started the path. The last sub-path in the output may (but is not guaranteed) to end with a moveTo element.
