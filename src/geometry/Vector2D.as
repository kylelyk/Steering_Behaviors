package geometry {
	import flash.geom.Point;
	
	public class Vector2D {
		private var _x:Number;
		private var _y:Number;
		private var _length:Number;
		private var updateNeeded:Boolean = true;
		public static const XONLY:uint = 1;
		public static const YONLY:uint = 2;
		
		//TODO: write up all the documentation for this class
		//TODO: write up tests for this class
		public function Vector2D(p_x:Number = 0, p_y:Number = 0) {
			
			_x = p_x;
			_y = p_y;
			updateNeeded = true;
		}
		
		public function get x():Number {
			
			return _x;
		}
		
		public function set x(px:Number):void {
			
			updateNeeded = true;
			_x = px;
		}
		
		public function get y():Number {
			
			return _y;
		}
		
		public function set y(py:Number):void {
			
			updateNeeded = true;
			_y = py;
		}
		
		public function get length():Number {
			
			if (updateNeeded) {
				_length = Math.sqrt(lengthSquared);
				updateNeeded = false
			}
			return _length;
		}
		
		public function set length(len:Number):void {
			if (length == 0) {
				return;
			}
			if (len < 0) {
				negate();
				len *= -1;
			}else if (!isFinite(len)) {
				throw(new Error("Length passed in is not finite."));
			}
			const dif:Number = len / length
			_x *= dif;
			_y *= dif;
			_length = len;
			
		}
		
		public function get lengthSquared():Number {
			
			if (updateNeeded) {
				return _x * _x + _y * _y;
			} else {
				return _length * _length;
			}
		}
		
		//angle clockwise starting at x-axis
		public function get angle():Number {
			
			var angle:Number = Math.atan2(_y, _x);
			if (angle < 0) {
				return angle + Math.PI * 2;
			}
			return angle;
		}
		
		public function addPoint(p:Point):void {
			
			updateNeeded = true;
			_x += p.x;
			_y += p.y;
		}
		
		public function addToPoint(p:Point):Point {
			
			return new Point(p.x + _x, p.y + _y);
		}
		
		public function subtractPoint(p:Point):void {
			
			updateNeeded = true;
			_x -= p.x;
			_y -= p.y;
		}
		
		public function subtractFromPoint(p:Point):Point {
			
			return new Point(p.x - _x, p.y - _y);
		}
		
		public function get pointValue():Point {
			
			return new Point(_x, _y);
		}
		
		public function rangedAngleBetween(v:Vector2D):Number {
			
			const angle:Number = Math.atan2(_y, _x) - Math.atan2(v.y, v.x);
			return simplifyAngle(angle, Math.PI * -1, Math.PI, Math.PI * 2);
		}
		
		//rotates that many radians clockwise; does not set rotation/angle
		public function rotate(angle:Number):Vector2D {
			
			return new Vector2D((_x * Math.cos(angle)) - (_y * Math.sin(angle)), (_x * Math.sin(angle)) + (_y * Math.cos(angle)));
		}
		
		static public function createVector2DFromAngle(angle:Number, length:Number):Vector2D {
			
			return new Vector2D(Math.cos(angle) * length, Math.sin(angle) * length);
		}
		
		static public function createUnitVector2D(angle:Number):Vector2D {
			
			return new Vector2D(Math.cos(angle), Math.sin(angle));
		}
		
		public function project(angle:Number):Vector2D {
			const cos:Number = Math.cos(angle);
			const sin:Number = Math.sin(angle);
			const dp:Number = _x * cos + _y * sin;
			return new Vector2D(dp * cos, dp * sin);
		}
		
		public function reflect(normal:Vector2D):Vector2D {
			
			const d:Number = 2 * (_x * normal.x + _y * normal.y);
			return new Vector2D(_x - d * normal.x, _y - d * normal.y);
		}
		
		public function isNegative(v:Vector2D):Boolean {
			
			/*if (this==v.negate()) {
			   return true;
			 }*/
			return false;
		}
		
		static public function simplifyAngle(angle:Number, min:Number, max:Number, n:Number):Number {
			
			while (angle >= max) {
				angle -= n;
			}
			while (angle < min) {
				angle += n;
			}
			
			return angle;
		}
		
		public function toPrecision(precision:int):Vector2D {
			
			return new Vector2D(int(_x * precision) / precision, int(_y * precision) / precision);
		}
		
		//Vector3D Equivalent Methods
		public function add(v:Vector2D):Vector2D {
			
			return new Vector2D(_x + v._x, _y + v._y);
		}
		
		static public function angleBetween(v1:Vector2D, v2:Vector2D):Number {
			
			return Math.acos(v1.dotProduct(v2) / (v1.length * v2.length));
		}
		
		public function clone():Vector2D {
			
			return new Vector2D(_x, _y);
		}
		
		public function copyFrom(v:Vector2D):void {
			
			updateNeeded = true;
			_x = v._x;
			_y = v._y;
		}
		
		public function decrementBy(v:Vector2D):void {
			
			updateNeeded = true;
			_x -= v._x;
			_y -= v._y;
		}
		
		static public function distance(v1:Vector2D, v2:Vector2D):Number {
			
			return (v1.subtract(v2)).length;
		}
		
		//essentially the length of this vector along vector v.
		public function dotProduct(v:Vector2D):Number {
			
			return _x * v._x + _y * v._y;
		}
		
		public function equals(v:Vector2D, type:int):Boolean {
			
			if ((v.x == _x) && (type == 1)) {
				return true;
			} else if ((v.y == _y) && (type == 2)) {
				return true;
			} else if ((v.x == _x) && (v.y == _y) && (type == 0)) {
				return true;
			}
			return false;
		}
		
		public function incrementBy(v:Vector2D):void {
			
			updateNeeded = true;
			_x += v._x;
			_y += v._y;
		}
		
		public function nearEquals(v:Vector2D, tolerance:Number, type:int = 0):Boolean {
			
			if (type == YONLY) {
				if ((v.x <= _x + tolerance) || (v.x >= _x - tolerance)) {
					return true;
				}
			} else if (type == XONLY) {
				if ((v.y <= _y + tolerance) || (v.y >= _y - tolerance)) {
					return true;
				}
			} else {
				if ((Math.abs(v.x - _x) < tolerance) && (Math.abs(v.y - _y) < tolerance)) {
					return true;
				}
			}
			return false;
		}
		
		public function negate():void {
			
			_x *= -1;
			_y *= -1;
		}
		
		public function normalize():Vector2D {
			
			const l:Number = this.length;
			return new Vector2D(_x / l, _y / l);
		}
		
		public function scaleBy(s:Number):void {
			
			_length *= s;
			_x *= s;
			_y *= s;
		}
		
		public function setTo(px:Number, py:Number):void {
			
			updateNeeded = true;
			_x = px;
			_y = py;
		}
		
		public function subtract(v:Vector2D):Vector2D {
			
			return new Vector2D(_x - v.x, _y - v.y);
		}
		
		public function toString():String {
			
			return "(" + _x + "," + _y + ")";
		}
	}
}