package datastrucs {
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Kyle Howell
	 */
	
	public class Quadrant {
		public var bounds:Rectangle;
		public var level:uint;
		//subnodes
		public var nodes:Vector.<Quadrant>;
		public var parent:Quadrant;
		//objects that cannot fit in subnodes/all objects if no subnodes exist yet
		public var objects:Array;
		//position in parent
		public var type:int;
		public static const NORTHWEST:int = 0;
		public static const NORTHEAST:int = 1;
		public static const SOUTHEAST:int = 2;
		public static const SOUTHWEST:int = 3;
		
		public function Quadrant(level:uint, type:int, bounds:Rectangle) {
			nodes = new Vector.<Quadrant>(4, true);
			objects = new Array();
			this.level = level;
			this.type = type;
			this.bounds = bounds;
		}
	}

}