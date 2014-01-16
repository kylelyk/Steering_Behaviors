package {
	
	/**
	* ...
	* @author Kyle Howell
	*/
	public class Utils {
		public function Utils():void {
		
		}
		
		//will wrap around either direction if out of range
		//min inclusive, max exclusive
		static public function wrap(min:Number, max:Number, wrapValue:Number):Number {
			var diff:Number = max - min
			while (wrapValue >= max) {
				wrapValue -= diff;
			}
			while (wrapValue < min) {
				wrapValue += diff;
			}
			return wrapValue;
		}
		
		static public function filterPositive(item:Number, index:uint, vector:Object):Boolean {
			if (item >= 0) {
				return false;
			}
			return true;
		}
		
		static public function filterNegative(item:Number, index:uint, vector:Object):Boolean {
			if (item < 0) {
				return false;
			}
			return true;
		}
		
		static public function sameSign(num1:Number, num2:Number):Boolean {
			if (num1 >= 0) {
				if (num2 >= 0) {
					return true;
				}
				return false;
			} else {
				if (num1 < 0) {
					return true;
				}
				return false;
			}
		}
		
		static public function oppositeSign(num1:Number, num2:Number):Boolean {
			if (num1 >= 0) {
				if (num2 < 0) {
					return true;
				}
				return false;
			} else {
				if (num1 >= 0) {
					return true;
				}
				return false;
			}
		}
		
		static public function toPrecision(num:Number, precision:int):Number {
			
			return int(num * precision) / precision;
		}
	}
}