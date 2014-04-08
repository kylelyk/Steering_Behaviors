package tests {
	import asunit.framework.TestCase;
	import datastrucs.BinarySearchTree;
	
	/**
	 * Tests for the BinarySearchTree class
	 * 
	 * @author Kyle Howell
	 */
	public class BSTTests extends TestCase {
		private var _instance:BinarySearchTree;
		private var _list:Array;
		
		public function BSTTests(testMethod:String) {
			super(testMethod);
		}
		
		override protected function setUp():void {
			super.setUp();
			_instance = new BinarySearchTree(compareInts);
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
		public function TestAddData():void {
			var num:uint = 1000;
			var listRef:Array = new Array(num);
			for (var i:uint = 0; i < num; i++) {
				var rand:uint = int(Math.random() * num);
				listRef[i] = rand;
				_instance.addData(rand);
			}
			_list = new Array();
			_instance.inOrderTraverse(addToList);
			
			
			assertEquals("Sizes are not the same.", num, _instance.size);
			listRef.sort(Array.NUMERIC);
			assertEqualsArrays("Lists do not match.", listRef, _list);
		}
		
		//Will not work without:
		//inOrderTraverse()
		//addData()
		public function TestRemoveData():void {
			//testing 0, 1, 2 child and head removal
			var removeList:Array = new Array(1, 6, 2, 4);
			for (var i:uint = 0; i < removeList.length; i++) {
				_instance = new BinarySearchTree(compareInts);
				_instance.addData(4);
				_instance.addData(2);
				_instance.addData(6);
				_instance.addData(1);
				_instance.addData(3);
				_instance.addData(5);
				var target:uint = removeList[i]
				var sortedList:Array = new Array(1, 2, 3, 4, 5, 6);
				_instance.removeData(target);
				_list = new Array();
				_instance.inOrderTraverse(addToList);
				sortedList.splice(sortedList.indexOf(target), 1);
				assertEqualsArrays("Lists do not match.", sortedList, _list);
			}
		}
		
		//Adds nodes such that the resulting tree is balanced
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
	}
}