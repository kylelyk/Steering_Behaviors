package geometry{
	
	import flash.geom.Point;
	
	/**
	 * The line class is defined by two points and has slope, length, y-intercept properties.
	 * In order to access current versions of these properties, YOU MUST call update() after you are done reasigning points.
	 *
	 * @author Kyle Howell
	 */
	
	public class Line {
		
		private var _p1:Point;
		private var _p2:Point;
		private var _length:Number;
		private var _slope:Number;
		private var _yint:Number;
		
		private static const EPSILON:Number = 0.00001;
		
		public function Line(p1:Point, p2:Point):void {
			_p1 = p1;
			_p2 = p2;
			update();
		}
		
		/* -------------------
		 * Public Functions
		 * -------------------
		 */
		
		/**
		 * A static function that calculates the insection of two lines.
		 *
		 * @param line1 The first line to be tested.
		 * @param line2 The second line to be tested.
		 * @param extrapolate Whether to return the theoretical intersection even if the line segments do not actually cross.
		 * @return Parallel lines return null, colinear lines return Point(NaN, NaN), otherwise a point of insection is returned.
		 */
		static public function intersect(line1:Line, line2:Line, extrapolate:Boolean = false):Point {
			var p:Point = line1.p1;
			var r:Point = p.subtract(line1.p2);
			var q:Point = line2.p1;
			var s:Point = q.subtract(line2.p2);
			var q_minus_p:Point = q.subtract(p);
			var inverse_r_cross_s:Number = 1 / (r.x * s.y - r.y * s.x);
			var t:Number = (q_minus_p.x * s.y - q_minus_p.y * s.x) * inverse_r_cross_s;
			var u:Number = (q_minus_p.x * r.y - q_minus_p.y * r.x) * inverse_r_cross_s;
			var intersection:Point = new Point(p.x + t * r.x, p.y + t * r.y)
			
			//Check if lines parallel
			if (Math.abs(r.x * s.y - r.y * s.x) <= EPSILON) {
				//check if colinear
				if (Math.abs(q_minus_p.x * r.y - q_minus_p.y * r.x) <= EPSILON) {
					return new Point(NaN, NaN);
				}
				return null
			}
			//If user wants theoretical insection
			if (extrapolate) {
				return intersection;
			}
			
			//Otherwise if t and u are between 0 and 1, return intersection
			if (t >= 0 || t <= 1 || u >= 0 || u <= 1) {
				return intersection;
			} else {
				return null;
			}
		}
		
		//TODO: test this function
		public function distToPoint(point:Point, squared:Boolean = false, useEndpoints:Boolean = true):Number {
			var lenSquared:Number = _length * _length;
			if (lenSquared == 0) {
				if (squared) {
					return squaredDist(point, _p1);
				} else {
					return Math.sqrt(squaredDist(point, _p1));
				}
			}
			trace(length);
			var t:Number = ((point.x - _p1.x) * (_p2.x - p1.x) + (point.y - _p1.y) * (_p2.y - p1.y)) / lenSquared;
			trace("t: " + t)
			//shortest distance is to endpoints
			if (t <= 0) {
				if (useEndpoints) {
					if (squared) {
						return squaredDist(point, _p1);
					} else {
						return Math.sqrt(squaredDist(point, _p1));
					}
				} else {
					return -1;
				}
			} else if (t >= 1) {
				if (useEndpoints) {
					if (squared) {
						return squaredDist(point, _p2);
					} else {
						return Math.sqrt(squaredDist(point, _p2));
					}
				} else {
					return -1;
				}
			//shortest distance is to part of line somewhere
			} else {
				if (squared) {
					return squaredDist(point, new Point(_p1.x + t * (_p2.x - _p1.x), _p1.y + t * (_p2.y - _p1.y)));
				} else {
					return Math.sqrt(squaredDist(point, new Point(_p1.x + t * (_p2.x - _p1.x), _p1.y + t * (_p2.y - _p1.y))));
				}
			}
		}
		
		/**
		 * Find the Y position given an X position on the line. Automatically extrapolates if the Y position isn't defined by the line.
		 *
		 * @param atX The Y position on the line.
		 * @return The Y position on the line.
		 */
		public function yValueAt(atX:Number):Number {
			return (_slope * atX) + _yint;
		}
		
		/**
		 * Find the X position given an Y position on the line. Automatically extrapolates if the X position isn't defined by the line.
		 *
		 * @param atY The Y position on the line.
		 * @return The X position on the line.
		 */
		public function xValueAt(atY:Number):Number {
			return (atY - _yint) / _slope;
		}
		
		/**
		 * Prints the string representation of the line segment.
		 *
		 */
		public function output():void {
			trace('Point 1: (' + _p1.x + ',' + _p1.y + ') Point 2: (' + _p2.x + ',' + _p2.y + ')');
		}
		
		/**
		 * Updates the length, slope, and y-intercept parameters.
		 *
		 */
		public function update():void {
			calculateLength();
			calculateSlope();
			calculateYInt();
		}
		
		/* -------------------
		 * Private Functions
		 * -------------------
		 */
		
		/*private function to get the length of the line*/
		private function calculateLength():void {
			_length = Point.distance(_p1, _p2);
		}
		
		/*private function to get the slope of the line*/
		private function calculateSlope():void {
			if (_p1.x - p2.x != 0) {
				_slope = (_p1.y - _p2.y) / (_p1.x - _p2.x);
			} else {
				_slope = undefined;
			}
		}
		
		/*private function to get the y-intercept of the line*/
		private function calculateYInt():void {
			_yint = (_slope * -_p1.x) + _p1.y;
		}
		
		private function squaredDist(p1:Point, p2:Point):Number {
			return (p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y)
		}
		
		/* -------------------
		 * Getters and Setters
		 * -------------------
		 */
		
		/* use trace(<line>.data) to do the same thing as Output()*/
		public function get data():String {
			var data_string:String = 'Point 1: (' + _p1.x + ',' + _p1.y + ') Point 2: (' + _p2.x + ',' + _p2.y + ')';
			return data_string;
		}
		
		public function get p1():Point {
			return _p1;
		}
		
		public function set p1(value:Point):void {
			_p1 = value;
		}
		
		public function get p1x():Number {
			return _p1.x;
		}
		
		public function set p1x(value:Number):void {
			_p1.x = value;
		}
		
		public function get p1y():Number {
			return _p1.y;
		}
		
		public function set p1y(value:Number):void {
			_p1.y = value;
		}
		
		public function get p2():Point {
			return _p2;
		}
		
		public function set p2(value:Point):void {
			_p2 = value;
		}
		
		public function get p2x():Number {
			return _p2.x;
		}
		
		public function set p2x(value:Number):void {
			_p2.x = value;
		}
		
		public function get p2y():Number {
			return _p2.y;
		}
		
		public function set p2y(value:Number):void {
			_p2.y = value;
		}
		
		public function get length():Number {
			return _length;
		}
		
		public function get slope():Number {
			return _slope;
		}
		
		public function get yIntercept():Number {
			return _yint;
		}
	}
}