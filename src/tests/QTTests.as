package tests {
	import asunit.framework.TestCase;
	import datastrucs.QuadTree;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.sampler.NewObjectSample;
	
	/**
	 * ...
	 * @author Kyle Howell
	 */
	public class QTTests extends TestCase {
		private var _instance:QuadTree;
		private var _list:Array;
		
		public function QTTests(testMethod:String) {
			super(testMethod);
		}
		
		override protected function setUp():void {
			super.setUp();
			_instance = new QuadTree(new Rectangle(0, 0, 800, 600));
		}
		
		override protected function tearDown():void {
			super.tearDown();
			_instance = null;
			_list = null;
		}
		
		public function compareInts(a:int, b:int):Boolean {
			return a < b;
		}
		
		public function addToList(data:*):* {
			_list.push(data)
		}
		
		//helper function that adds num of objects specified and returns a list of them
		private function addObjects(num:uint):Array {
			var listRef:Array = new Array(num);
			
			for (var i:uint = 0; i < num; i++) {
				var randPt:Point = new Point(Math.random() * 800, Math.random() * 600);
				var rand:Rectangle = new Rectangle(randPt.x, randPt.y, Math.random() * 100, Math.random() * 100);
				if (rand.right > 800) {
					rand.right = 800
				}
				if (rand.bottom > 600) {
					rand.bottom = 600
				}
				
				//var rand:Rectangle = new Rectangle(i*10, i*20, 30,30);
				var obj:Object = {rect: rand}
				listRef[i] = obj;
				_instance.insert(obj);
			}
			//trace(listRef);
			return listRef;
		}
		
		//Will not work without:
		//traverse()
		public function TestInsert():void {
			var num:uint = 100;
			var allElements:Array = addObjects(num);
			_list = new Array();
			_instance.traverse(addToList);
			assertEquals("Sizes are not the same.", num, _instance.size);
			assertEqualsArraysIgnoringOrder("Lists do not have the same elements.", allElements, _list);
		}
		
		//Will not work without:
		//insert()
		//traverse()
		public function TestRemove():void {
			var num:uint = 100;
			var allElements:Array = addObjects(num);
			
			//remove a third of the objects
			for (var i:uint; i < num / 3; i++) {
				var rand:uint = Math.floor(Math.random() * allElements.length);
				_instance.remove(allElements[rand]);
				allElements.splice(rand, 1);
			}
			
			_list = new Array();
			_instance.traverse(addToList);
			assertEquals("Sizes are not the same.", allElements.length, _instance.size);
			assertEqualsArraysIgnoringOrder("Lists do not have the same elements.", allElements, _list);
		}
		
		//Will not work without:
		//traverse()
		//insert()
		public function TestClear():void {
			var num:uint = 20;
			addObjects(num);
			_instance.clear();
			_list = new Array();
			_instance.traverse(addToList);
			assertEquals("Sizes are not the same.", 0, _instance.size);
			assertEqualsArraysIgnoringOrder("Lists do not have the same elements.", [], _list);
		}
		
		//Will not work without:
		//insert()
		//traverse()
		public function TestQuery():void {
			var num:uint = 100;
			var allElements:Array = addObjects(num);
			
			for (var i:uint = 0; i < 20; i++) {
				//create a random  query box, compute which objects are in it for the reference list
				var randPoint1:Point = new Point(Math.random() * 800, Math.random() * 600);
				var randPoint2:Point = new Point(Math.random() * 800, Math.random() * 600);
				var rect:Rectangle = new Rectangle(randPoint1.x, randPoint1.y, randPoint2.x - randPoint1.x, randPoint2.y - randPoint1.y);
				_list = new Array();
				_list = _instance.query(rect);
				
				//Make a list of objects which do overlap rect
				var refList:Array = new Array();
				for (var j:uint = 0; j < num; j++) {
					if (rect.left <= allElements[j].rect.right && allElements[j].rect.left <= rect.right && rect.top <= allElements[j].rect.bottom && allElements[j].rect.top <= rect.bottom) {
						refList.push(allElements[j]);
					} 
				}
				assertEqualsArraysIgnoringOrder("Lists do not have the same elements.", refList, _list);
				
			}
		}
		
		public function TestWithinDistance():void {
			var num:uint = 100;
			var allElements:Array = addObjects(num);
			
			for (var i:uint = 0; i < 20; i++) {
				//create a random  query box, compute which objects are in it for the reference list
				var randPoint:Point = new Point(Math.random() * 800, Math.random() * 600);
				var dist:Number = Math.random() * 300;
				
				
				var refList:Array = new Array();
				for (var j:uint = 0; j < num; j++) {
					if (_instance.circleIntersectsRect(randPoint, dist, allElements[j].rect)) {
						refList.push(allElements[j]);
					} 
				}
				_list = new Array();
				_list = _instance.withinDistance(randPoint,dist);
				assertEqualsArraysIgnoringOrder("Lists do not have the same elements.", refList, _list);
				
				/*for (j = 0; i < refList.length; j++) {
					var rect:Rectangle = ret[i].rect
					ret[i] = {obj: ret[i], distance: Math.sqrt((rect.x + rect.width * 0.5) * (rect.x + rect.width * 0.5) + (rect.y + rect.height * 0.5) * (rect.y + rect.height * 0.5))}
				}*/
				
			}
		}
	}
}