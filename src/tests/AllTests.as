package tests {
	import asunit.framework.TestSuite;
	
	/**
	 * ...
	 * @author Kyle Howell
	 */
	public class AllTests extends TestSuite {
		public function AllTests() {
			super();
			
			//Binary Tree Class Tests (Relies on BinarySearchTree.addData())
			addTest(new BTTests("TestInorderTraverse"))
			addTest(new BTTests("TestGetInorderPredessor"))
			addTest(new BTTests("TestGetInorderSuccessor"))
			
			//RedBlackTree Class Tests
			addTest(new RBTTests("TestAddData"));
            addTest(new RBTTests("TestInOrderTraverse"));
            addTest(new RBTTests("TestContainsData"));
            addTest(new RBTTests("TestRemoveData"));
			
			//BinaryHeap Class Tests
			addTest(new BHTests("TestMaxHeap"));
			addTest(new BHTests("TestMinHeap"));
			
			//BinarySearchTree Class Tests
			addTest(new BSTTests("TestAddData"));
			addTest(new BSTTests("TestRemoveData"));
			addTest(new BSTTests("TestContainsData"));
			
			//QuadTree Class Tests
			addTest(new QTTests("TestInsert"));
			addTest(new QTTests("TestRemove"));
			addTest(new QTTests("TestClear"));
			addTest(new QTTests("TestQuery"));
			addTest(new QTTests("TestWithinDistance"));
		}
	}
}
