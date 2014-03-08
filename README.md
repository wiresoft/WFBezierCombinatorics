WFBezierCombinatorics
=====================

Adds 3 public methods to NSBezierPath for performing boolean operations on paths:

- (NSBezierPath *)WFUnionWithPath:(NSBezierPath *)path;

- (NSBezierPath *)WFIntersectWithPath:(NSBezierPath *)path;

- (NSBezierPath *)WFSubtractPath:(NSBezierPath *)path;

In all cases, the receiver and input paths are not modified. The returned result is a new path constructed by performing the boolean operation on the receiver and input path. A sample app illustrates the usage, which is quite simple.

This code requires ARC. If your project does not use ARC globally, you should enable it on a file-by-file bases for the “NSBezierPath+WFBezierCombinatorics.m” file.