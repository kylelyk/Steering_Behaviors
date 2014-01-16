package {
	import flash.geom.Point;
	public class Data {

		private var areas:Array;
		public function Data() {

			areas=new Array();
			
			var area1:Array=new Array(
					[new Point(0,400),new Point(720,400),new Point(720,450),new Point(0,450)]//ground
					,[new Point(320,380),new Point(340,380),new Point(340,400),new Point(320,400)]//trashcan
					//,[new Point(0,400),new Point(720,400),new Point(720,450),new Point(0,450)]//test  
					)
			var area2:Array=new Array(
			
			);
			areas.push(area1);
			areas.push(area2);
			//trace(area1)
			//trace(areas[0])
			//trace(areas[0][1])
		}


		public function read(area:int,which:int=-1):Array {

			if (which==-1) {
				return areas[area];
			} else {
				return areas[area][which];
			}
		}

		public function getLength(area:int):int {

			return areas[area].length;
		}
	}
}