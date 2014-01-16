package tests {
	import asunit.framework.TestCase;
	import datastrucs.BinaryHeap;
	
	/**
	 * ...
	 * @author Kyle Howell
	 */
	public class BHTests extends TestCase {
		private var _instance:BinaryHeap;
		private var _list:Array;
		
		public function BHTests(testMethod:String) {
			super(testMethod);
		}
		
		override protected function setUp():void {
			super.setUp();
			_instance = new BinaryHeap(compareInts, true);
		}
		
		override protected function tearDown():void {
			super.tearDown();
			_instance = null;
			_list = null;
		}
		
		public function compareInts(a:int, b:int):Boolean {
			return a < b;
		}
		
		public function TestMaxHeap():void {
			var num:uint = 1000;
			var listRef:Array = new Array(num);
			for (var i:uint = 0; i < num; i++) {
				var rand:uint = int(Math.random() * num);
				listRef[i] = rand;
				_instance.insert(rand);
			}
			listRef.sort(Array.NUMERIC | Array.DESCENDING);
			var list1:Array = new Array(num);//top call
			var list2:Array = new Array(num);//removeTop call
			for (i = 0; i < num; i++) {
				list1[i] = _instance.top;
				list2[i] = _instance.removeTop();
			}
			assertEqualsArrays("get top() error", listRef, list1);
			assertEqualsArrays("removeTop() error", listRef, list2);
		}
		
		public function TestMinHeap():void {
			_instance = new BinaryHeap(compareInts, false);
			var num:uint = 1000;
			var listRef:Array = new Array(num);
			for (var i:uint = 0; i < num; i++) {
				var rand:uint = int(Math.random() * num);
				listRef[i] = rand;
				_instance.insert(rand);
			}
			listRef.sort(Array.NUMERIC);
			var list1:Array = new Array(num);//top call
			var list2:Array = new Array(num);//removeTop call
			for (i = 0; i < num; i++) {
				list1[i] = _instance.top;
				list2[i] = _instance.removeTop();
			}
			assertEqualsArrays("get top() error", listRef, list1);
			assertEqualsArrays("removeTop() error", listRef, list2);
		}
	}
}