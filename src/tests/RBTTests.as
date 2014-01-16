package tests {
	import asunit.framework.TestCase;
	import datastrucs.RedBlackTree;
	
	/**
	 * ...
	 * @author Kyle Howell
	 */
	public class RBTTests extends TestCase {
		private var _instance:RedBlackTree;
		private var _list:Array;
		
		public function RBTTests(testMethod:String) {
			super(testMethod);
		}
		
		override protected function setUp():void {
			super.setUp();
			_instance = new RedBlackTree(compareInts);
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
		
		//Will not work without:
		//inOrderTraverse()
		//get size()
		public function TestAddData():void {
			var num:uint = 1000;
			var listRef:Array = new Array(num);
			for (var i:uint = 0; i < num; i++) {
				var rand:uint = int(Math.random() * num);
				listRef[i] = rand;
				_instance.addData(rand);
			}
			_list = new Array()
			_instance.inOrderTraverse(addToList);
			assertEquals("Sizes are not the same.", num, _instance.size);
			listRef.sort(Array.NUMERIC);
			assertEqualsArrays("Lists do not match.", listRef, _list);
		}
		
		//Adds nodes such that rearrangements/rotations do not occur (not trying to test addData)
		//Will not work without:
		//addData()
		public function TestInOrderTraverse():void {
			_instance.addData(4);
			_instance.addData(2);
			_instance.addData(6);
			_instance.addData(1);
			_instance.addData(3);
			_instance.addData(5);
			_instance.addData(7);
			
			_list = new Array()
			_instance.inOrderTraverse(addToList);
			assertEqualsArrays([1, 2, 3, 4, 5, 6, 7], _list);
		}
		
		//Adds nodes such that rearrangements/rotations do not occur (not trying to test addData)
		//Will not work without:
		//addData()
		public function TestContainsData():void {
			_instance.addData(4);
			_instance.addData(2);
			_instance.addData(6);
			_instance.addData(1);
			_instance.addData(3);
			_instance.addData(5);
			_instance.addData(7);
			
			assertTrue(_instance.containsData(1));
			assertTrue(_instance.containsData(4));
			assertFalse(_instance.containsData(0));
		}
		
		//Requires addData to be fully functioning
		//Might manually make a tree that can test all cases later
		public function TestRemoveData():void {
			var num:uint = 1000;
			var listRef:Array = new Array(num);
			for (var i:uint = 0; i < num; i++) {
				var rand:uint = int(Math.random() * num);
				listRef[i] = rand;
				_instance.addData(rand);
			}
			
			for (i = 0; i < num / 2; i++) {
				rand = int(Math.random() * listRef.length);
				_instance.removeData(listRef[rand])
				listRef.splice(rand, 1);
			}
			_list = new Array()
			_instance.inOrderTraverse(addToList);
			assertEquals("Sizes are not the same.", num/2, _instance.size);
			listRef.sort(Array.NUMERIC);
			assertEqualsArrays("Lists do not match.", listRef, _list);
		}
	}
}