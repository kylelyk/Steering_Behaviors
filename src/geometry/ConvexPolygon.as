package geometry{
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import Utils;
	import geometry.Vector2D;
	import datastrucs.BinaryTreeNode;
	import datastrucs.BinarySearchTree;
	//TODO: decide if it should use points or Vector2D's (like the Vehicle Class) for the vertices 
	public class ConvexPolygon extends Sprite {
		private var _clockwise:Boolean;
		private var _numVertices:int = 0;
		
		//in the scope of center of polygon
		private var vertices:Vector.<Point>;
		private var edges:Vector.<Vector2D>;
		
		//all the angles that will have dim
		private var angles:Vector.<Number>;
		//multiples of PI removed from angles Vector
		private var axis:Vector.<Number>;
		
		private var dim:Dictionary;
		
		public var furthestPoints:Dictionary;
		public var unitVectors:Dictionary;
		
		private var _polyArea:Number;
		
		private static const HALFPI:Number = Math.PI * .5;
		private static const TWOPI:Number = Math.PI * 2;
		private static const EPSILON:Number = 0.000001;
		//will throw an error if not convex
		public function ConvexPolygon(args:Vector.<Point>):void {
			var newVertices:Vector.<Point> = args.concat();
			_numVertices = newVertices.length;
			edges = new Vector.<Vector2D>(_numVertices);
			angles = new Vector.<Number>(_numVertices);
			axis = new Vector.<Number>();
			//TODO: see if this statement is necessary
			if (_numVertices < 3) {
				return;
			}
			
			//calculate edges and angles
			for (var i:uint = 0; i < _numVertices; i++) {
				var nextIndex:uint = Utils.wrap(0, _numVertices, i + 1);
				edges[i] = new Vector2D(newVertices[nextIndex].x - newVertices[i].x, newVertices[nextIndex].y - newVertices[i].y);
				angles[i] = edges[i].angle;
			}
			
			//find center and store the vertices
			var center:Point = computeCenter(newVertices);
			this.x = center.x;
			this.y = center.y;
			vertices = new Vector.<Point>(_numVertices);
			for (i = 0; i < _numVertices; i++) {
				vertices[i] = toPolyCoor(newVertices[i]);
			}
			
			//setup up other memory
			updateAxes();
			
			//setup for getting dimAlongAxis
			dim = new Dictionary();
			unitVectors = new Dictionary();
			furthestPoints = new Dictionary();
			
			if (!isConvex()) {
				throw(new Error("Polygon is not convex, cannot create an instance of the ConvexPolygon class."));
			}
		}
		
		//takes in a set of points and spits out a vector of ConvexPolygon instances fully intialized
		public static function makeConvex(points:Vector.<Point>):Vector.<ConvexPolygon> {
			//Triangulation in O(n log* n) time:
			//	Randomize vertices to be added in O(n) time
			//	Add vertices in log* n phases consisting of adding edges, then building a shortcut list of all vertices present in O(n) time
			//	Partition into monotone pieces in O(n) time by identifying the split and merge vertices, then using the trapezoids to add a diagonal in O(1) time
			//Triangulate the monotone pieces in O(n) time
			//Then use hertel-mehlhorn algorithm in O(n) time to remove extra diagonals and cut down the number of convex polygons from n-2 triangles
			
			if (points.length > 3) {
				throw(Error("makeConvex requires atleast 3 vertices."));
			}else if (points.length == 3) {
				return new <ConvexPolygon>[new ConvexPolygon(points)]
			}
			
			var regionCounter:uint = 1;
			var regions:Vector.<Region> = new Vector.<Region>();
			var region:Region = new Region();
			region.boundaries[0] = new Point(-Infinity, -Infinity);
			region.boundaries[1] = new Point(Infinity, -Infinity);
			region.boundaries[2] = new Point(Infinity, Infinity);
			region.boundaries[3] = new Point(-Infinity, Infinity);
			regions.push(region);
		}
		
		/* -------------------
		 * Utility Functions
		 * -------------------
		 */
		
		//returns a vector of vertices that need to be removed in order to make the shape convex
		private function isConvex():Vector.<Point> {
			var result:int = 0;
			var negative:Vector.<Point> = new Vector.<Point>();
			var positive:Vector.<Point> = new Vector.<Point>();
			for (var i:uint = 0; i < _numVertices; i++) {
				var prevIndex:uint = Utils.wrap(0, _numVertices, i - 1);
				var nextIndex:uint = Utils.wrap(0, _numVertices, i + 1);
				//z-component of the crossproduct
				var zCrossProduct:Number = (vertices[i].x - vertices[prevIndex].x) * (vertices[nextIndex].y - vertices[i].y) - (vertices[i].y - vertices[prevIndex].y) * (vertices[nextIndex].x - vertices[i].x);
				if (zCrossProduct < 0) {
					negative.push(vertices[i]);
				}else {
					positive.push(vertices[i]);
				}
			}
			
			//a convex polygon will have all negative or all positive cross products
			if (positive.length == 0 || negative.length == 0) {
				trace("convex");
				return null;
			} else {
				trace("non-convex");
				if (positive.length >= negative.length) {
					return negative;
				} else {
					return positive;
				}
			}
		}
		
		/**
		 * Simplifies the angles vector into an axis vector without repeats and all angles between 0 and PI.
		 */
		private function updateAxes():void {
			axis = angles.concat();
			for (var i:int = 0; i < axis.length; i++) {
				axis[i] = Utils.wrap(0, Math.PI, axis[i])
				for (var j:int = 0; j < i; j++) {
					if (axis[i] == axis[j]) {
						axis.splice(j, 1);
						j--;
					}
				}
			}
		}
		
		/**
		 * Computes the center of mass of the polygon assuming uniform density. Will return (0, 0) if the points are in the polygon coordinate space.
		 *
		 * @param vect A vector of points in a single coordinate space representing the vertices of the polygon.
		 * @return A point in the given coordinate space.
		 */
		private function computeCenter(vect:Vector.<Point>):Point {
			//TODO: after implementing break into simple Polygons function, compute and then average their centriods to find the centriod of a non-simple polygon
			var area:Number = 0;
			var sumX:Number = 0;
			var sumY:Number = 0;
			
			for (var i:uint = 0; i < vect.length; i++) {
				var nextIndex:uint = Utils.wrap(0, vect.length, i + 1);
				var x0:Number = vect[i].x;
				var y0:Number = vect[i].y;
				var x1:Number = vect[nextIndex].x;
				var y1:Number = vect[nextIndex].y;
				
				//compute area
				var areaCal:Number = (x0 * y1) - (x1 * y0);
				area += areaCal;
				//compute x center
				sumX += (x0 + x1) * areaCal;
				//compute y center
				sumY += (y0 + y1) * areaCal;
			}
			_polyArea = Math.abs(area / 2);
			return new Point(sumX / (6 * _polyArea), sumY / (6 * _polyArea));
		}
		
		/**
		 * Computes the 1 dimensional maximum and minimum span of the polygon.
		 *
		 * @param angle The angle of the 1D axis in radians.
		 * @return A vector of length two containing the max and min 1D coordinates.
		 */
		public function dimAlongAxis(angle:Number):Vector.<Number> {
			//wrap and add rotation to get the angle in the polygon's coordinate space
			var newAngle:Number = Utils.wrap(0, TWOPI, angle - getRotation());
			
			//if the angle is between PI and TWOPI, return the min and max flipped of (angle - PI)
			var flip:Boolean = false;
			if (newAngle >= Math.PI) {
				flip = true;
				newAngle -= Math.PI;
			}
			//rounding to avoid almost infinitely long dictionaries
			newAngle = int(newAngle * 100) / 100;
			
			if (dim[newAngle] == null) {
				//add unitVector into library(useful for saving calculations later)
				unitVectors[newAngle] = Vector2D.createUnitVector2D(newAngle);
				//in the form of [0] = max, [1] = min
				furthestPoints[newAngle] = new Vector.<uint>(2);
				
				var projVect:Vector2D;
				var length:Number = 0;
				var min:Number = 0;
				var max:Number = 0;
				
				for (var i:int = 0; i < _numVertices; i++) {
					//find projVect from center of polygon and compare to see if it is a large max or min
					projVect = new Vector2D(vertices[i].x, vertices[i].y).project(newAngle);
					var vectLen:Number = projVect.length;
					var dotProduct:Number = projVect.dotProduct(unitVectors[newAngle]);
					//same direction as angle/opposite direction as angle
					if (dotProduct > 0 && vectLen > max) {
						max = vectLen;
						furthestPoints[newAngle][0] = i;
					} else if (dotProduct < 0 && vectLen > min) {
						min = vectLen;
						furthestPoints[newAngle][1] = i;
					}
				}
				dim[newAngle] = new <Number>[max, min];
				
			}
			if (flip) {
				return new <Number>[dim[newAngle][1], dim[newAngle][0]];
			}
			return dim[newAngle];
		}
		
		/**
		 * Simple representation of the polygon is drawn to the sprite's graphics.
		 *
		 * @param color The border color of the polygon.
		 * @param fillColor The fill color of the polygon.
		 * @param alpha The transparency of the polygon.
		 */
		public function drawGraphics(color:uint, fillColor:uint, alpha:Number = 1):void {
			if (alpha > 1 || alpha < 0) {
				throw(new ArgumentError("Alpha must be between 0 and 1"));
			}
			graphics.lineStyle(1, color, alpha);
			graphics.beginFill(fillColor, alpha);
			drawOutline(color, alpha);
			graphics.endFill();
		}
		
		/**
		 * Simple representation of the polygon is drawn to the sprite's graphics without fill.
		 *
		 * @param color The border color of the polygon.
		 * @param alpha The transparency of the polygon.
		 */
		public function drawOutline(color:uint, alpha:Number = 1):void {
			if (alpha > 1 || alpha < 0) {
				throw(new ArgumentError("Alpha must be between 0 and 1"));
			}
			
			graphics.lineStyle(1, color, alpha);
			graphics.moveTo(vertices[0].x, vertices[0].y);
			for (var i:uint = 1; i < _numVertices; i++) {
				graphics.lineTo(vertices[i].x, vertices[i].y);
			}
			graphics.lineTo(vertices[0].x, vertices[0].y);
		}
		
		/**
		 * Clears the graphics of the polygon.
		 */
		public function clearGraphics():void {
			graphics.clear();
		}
		
		//doesn't work yet completely
		public function addVertex(vertex:Point, index:int = -1):void {
			trace("adding Point")
			var addIndex:int = index;
			vertex = toPolyCoor(vertex);
			//find the correct place to insert so that the polygon will still be simple
			if (addIndex == -1) {
				var closest:uint;
				var record:Number = Infinity
				for (var i:uint = 0; i < _numVertices; i++) {
					var line:Line = new Line(vertices[i], vertices[Utils.wrap(0, _numVertices, i + 1)]);
					var distSqu:Number = line.distToPoint(vertex, true);
					trace("index " + i+": "+Math.sqrt(distSqu))
					if (distSqu < record && distSqu >=0) {
						closest = i;
						record = distSqu;
					}
				}
				addIndex = closest;
			}
			
			trace("smallest distance is: " + closest + " from index "+addIndex)
			
			var prevIndex:uint = Utils.wrap(0, _numVertices, addIndex - 1);
			var nextIndex:uint = Utils.wrap(0, _numVertices, addIndex + 1);
			
			/*graphics.lineStyle(2, 0xFF0000);
			graphics.moveTo(vertices[addIndex].x, vertices[addIndex].y);
			graphics.lineTo(vertices[nextIndex].x, vertices[nextIndex].y);*/
			
			
			
			//add 1 edge, recalculate 1 edge 
			//edges[addIndex].x = vertex.x - vertices[addIndex].x;
			//edges[addIndex].y = vertex.y - vertices[addIndex].y;
			//edges[nextIndex].x = vertices[nextIndex].x - vertex.x;
			//edges[nextIndex].y = vertices[nextIndex].y - vertex.y;
			//edges.splice(addIndex, 0, new Vector2D(vertices[nextIndex].x - vertex.x, vertices[nextIndex].y - vertex.y));
			
			//add 1 angle, recalculate 1 angle,
			//angles[addIndex] = edges[addIndex].angle;
			//angles.splice(nextIndex, 0, edges[nextIndex].angle);
			//updateAxes();
			
			//add 1 vertex
			vertices.splice(nextIndex, 0, vertex);
			_numVertices++;//Should this be here or before the prev and next variables assignment?
			
			//recompute center and shift the polygon
			var centerShift:Point = computeCenter(vertices);
			for (i = 0; i < _numVertices; i++) {
				vertices[i].x -= centerShift.x;
				vertices[i].y -= centerShift.y;
			}
			this.x += centerShift.x;
			this.y += centerShift.y;
			
			/*
			//calculate 1 dim and change all the dim that have max or min of that vertex:
			for each (var angle:Number in axis) {
			   dimAlongAxis(angle);
			 }
			 dimAlongAxis(newAngle);
			   for (var i:uint = 0; i < axis.length; i++) {
			   if (furthestPoints[axis[i]][0] == index || furthestPoints[axis[i]][1] == index) {
			   dimAlongAxis(angles[i]);
			   }
			 }*/
			//TODO: find a better way of reseting the 1D profile dictionary
			dim = new Dictionary();
		}
		
		/**
		 * Deletes the given point or the point at the given index; either one is accepted.
		 *
		 * @param point The vertex in stage coordinates.
		 * @param index An optional index of the point to be deleted.
		 */
		//use stage coordinates when calling
		public function deleteVertex(vertex:Point, index:int = -1):void {
			if (_numVertices < 4) {
				return;
			}
			//check to see if the point given exists
			if (vertex) {
				for (var i:uint = 0; i < _numVertices; i++) {
					if (vertices[i].equals(toPolyCoor(vertex))) {
						index = i;
						break;
					}
				}
			}
			if (index < 0 || index >= _numVertices) {
				trace("vertex was not given or vertex does not exist");
				return;
			}
			
			var prevIndex:uint = Utils.wrap(0, _numVertices, index - 1);
			var nextIndex:uint = Utils.wrap(0, _numVertices, index + 1);
			
			//take out 1 edge, recalculate 1 edge, 
			edges[prevIndex].x = vertices[nextIndex].x - vertices[prevIndex].x;
			edges[prevIndex].y = vertices[nextIndex].y - vertices[prevIndex].y;
			edges.splice(index, 1);
			
			//remove 1 angle, recalculate 1 angle,
			angles[prevIndex] = edges[prevIndex].angle;
			angles.splice(index, 1);
			updateAxes();
			
			//take out 1 vertex
			vertices.splice(index, 1);
			_numVertices--;
			
			//recompute center and shift the polygon
			var centerShift:Point = computeCenter(vertices);
			for (i = 0; i < _numVertices; i++) {
				vertices[i].x -= centerShift.x;
				vertices[i].y -= centerShift.y;
			}
			this.x += centerShift.x;
			this.y += centerShift.y;
			
			//calculate 1 dim and change all the dim that have max or min of that vertex:
			/*for each (var angle:Number in axis) {
			   dimAlongAxis(angle);
			 }*/ /*dimAlongAxis(newAngle);
			   for (var i:uint = 0; i < axis.length; i++) {
			   if (furthestPoints[axis[i]][0] == index || furthestPoints[axis[i]][1] == index) {
			   dimAlongAxis(angles[i]);
			   }
			 }*/
			//TODO: find a better way of reseting the 1D profile dictionary
			dim = new Dictionary();
			
			//isConvex();
		}
		
		//TODO: fix setRotation bug
		public function rotateAroundPoint(rad:Number, point:Point, setRotation:Boolean = false):void {
			//shift the polygon so that it can rotate around the origin
			this.x -= point.x;
			this.y -= point.y;
			var angle:Number = rad;
			if (setRotation) {
				angle -= new Vector2D(this.x - point.x, this.y - point.y).angle;
			}
			//rotate around origin and unshift the polygon
			var sinR:Number = Math.sin(angle);
			var cosR:Number = Math.cos(angle);
			var newP:Point = new Point(this.x * cosR - this.y * sinR, this.x * sinR + this.y * cosR);
			this.x = newP.x + point.x;
			this.y = newP.y + point.y;
			addRotation(angle);
		}
		
		/**
		 * Checks if the specified point lies inside the polygon.
		 *
		 * @param p The point to be checked.
		 * @param stageCoor Whether or not the point is in stage coordinates. If not, it is assumed to be in polygon coordinates.
		 * @return A boolean representing whether the point is inside the polygon.
		 */
		public function checkPointInside(p:Point, stageCoor:Boolean = true):Boolean {
			var point:Point = p;
			if (stageCoor) {
				point = toPolyCoor(p);
			}
			var results:Number = 0;
			var sum:Number = 0;
			for (var i:uint = 0; i < _numVertices; i++) {
				//compute two lines from a pair of vertices to the point and find the angle between them
				var line1:Vector2D = new Vector2D(point.x - vertices[i].x, point.y - vertices[i].y);
				var nextIndex:uint = Utils.wrap(0, _numVertices, i + 1);
				var line2:Vector2D = new Vector2D(point.x - vertices[nextIndex].x, point.y - vertices[nextIndex].y);
				sum += line1.rangedAngleBetween(line2);
			}
			//it will be close to TWOPI if inside, close to 0 if outside
			return Math.abs(sum) > 1;
		}
		
		//Works for:
		//Convex Polygons
		public function checkLineInside(line:Line):Boolean {
			if (checkPointInside(line.p1) && checkPointInside(line.p2)) {
				return true;
			}
			return false;
		}
		
		/**
		 * Converts a point in the stage coordinate space to the corresponding polygon coordinate.
		 *
		 * @param point The point in to be converted.
		 * @return The converted point now in the polygon coordinate space.
		 */
		public function toPolyCoor(point:Point):Point {
			var sinR:Number = Math.sin(-1 * getRotation());
			var cosR:Number = Math.cos(-1 * getRotation());
			
			var newP:Point = new Point(point.x - this.x, point.y - this.y);
			return new Point(newP.x * cosR - newP.y * sinR, newP.x * sinR + newP.y * cosR);
		}
		
		/**
		 * Converts a point in the polygon coordinate space to the corresponding stage coordinate.
		 *
		 * @param point The point in to be converted.
		 * @return The converted point now in the stage coordinate space.
		 */
		public function toStageCoor(point:Point):Point {
			var sinR:Number = Math.sin(getRotation());
			var cosR:Number = Math.cos(getRotation());
			
			var newP:Point = new Point(point.x * cosR - point.y * sinR, point.x * sinR + point.y * cosR);
			return new Point(newP.x + this.x, newP.y + this.y);
		}
		
		/* -------------------
		 * Psuedo Getters and Setters
		 * -------------------
		 */
		
		public function getRotation():Number {
			if (rotation < 0) {
				return (360 + rotation) * Math.PI / 180;
			}
			return rotation * Math.PI / 180;
		}
		
		public function setRotation(angle:Number):void {
			if (angle >= Math.PI) {
				rotation = angle * 180 / Math.PI - 360;
			} else {
				rotation = angle * 180 / Math.PI;
			}
		}
		
		public function addRotation(angle:Number):void {
			rotation += angle * 180 / Math.PI;
		}
		
		/**
		 * Returns the vertex at the given index in stage coordinates.
		 *
		 * @param index The position in the vertex array to be returned.
		 * @return The vertex in stage coordinates or null if out of bounds.
		 */
		public function getVertex(index:uint):Point {
			if (index >= _numVertices) {
				return null;
			}
			return toStageCoor(vertices[index]);
		}
		
		/**
		 * Redefines the vertex at the given index to the given point in stage coordinates.
		 *
		 * @param index The position in the vertex array to be returned.
		 * @return A boolean representing whether the point was successfully added.
		 */
		public function setVertex(index:uint, newVertex:Point):Boolean {
			//TODO: implement this function
			if (index >= _numVertices) {
				return false;
			}
			return true;
		}
		
		/* -------------------
		 * Getters and Setters
		 * -------------------
		 */
		
		public function get clockwise():Boolean {
			//TODO: compute whether points are clockwise or anticlockwise
			return _clockwise;
		}
		
		public function get vertexCount():uint {
			return _numVertices;
		}
		
		public function get area():Number {
			return _polyArea;
		}
		
		public function get rect():Rectangle {
			var width:Vector.<Number> = dimAlongAxis(0);
			var height:Vector.<Number> = dimAlongAxis(HALFPI);
			return
		}
	}
}


import flash.geom.Point;
//basically like a struct in c++ (so that we don't have to use a dynamic object making it harder for the compiler and slower)
class Region() {
	//specify in clockwise order
	public var boundaries:Vector.<Point> = new Vector.<Point>(4, true);
	//public var 
}