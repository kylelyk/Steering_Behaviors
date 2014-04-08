package tests {
	import asunit.framework.TestCase;
	import datastrucs.BinarySearchTree;
	
	/**
	 * Uses BinarySearchTree (insert method) to test the ancestor methods of BinaryTree
	 *
	 * @author Kyle Howell
	 */
	public class BTTests extends TestCase {
		private var _instance:BinarySearchTree;
		private var _list:Array;
		
		public function BTTests(testMethod:String) {
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
			_list.push(data);
		}
		
		//Will not work without:
		//addData()
		public function TestInorderTraverse():void {
			_instance.addData(4);
			_instance.addData(2);
			_instance.addData(6);
			_instance.addData(1);
			_instance.addData(3);
			_instance.addData(5);
			_instance.addData(7);
			
			_list = new Array();
			_instance.inOrderTraverse(addToList);
			assertEqualsArrays([1, 2, 3, 4, 5, 6, 7], _list);
		}
		
		//Will not work without:
		//addData()
		public function TestGetInorderPredessor():void {
			_instance.addData(4);
			_instance.addData(2);
			_instance.addData(6);
			_instance.addData(1);
			_instance.addData(3);
			_instance.addData(5);
			_instance.addData(7);
			
			assertEquals(null, _instance.getInorderPredessor(1))
			for (var i:uint = 2; i < 8; i++) {
				assertEquals(i - 1, _instance.getInorderPredessor(i));
			}
		}
		
		//Will not work without:
		//addData()
		public function TestGetInorderSuccessor():void {
			_instance.addData(4);
			_instance.addData(2);
			_instance.addData(6);
			_instance.addData(1);
			_instance.addData(3);
			_instance.addData(5);
			_instance.addData(7);
			
			assertEquals(null, _instance.getInorderSuccessor(7))
			for (var i:uint = 1; i < 7; i++) {
				assertEquals(i + 1, _instance.getInorderSuccessor(i));
			}
		}
	}
}