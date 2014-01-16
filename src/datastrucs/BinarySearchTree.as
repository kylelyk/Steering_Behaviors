package datastrucs {
	import datastrucs.BinaryTreeNode;
	/**
	 * Binary Search Trees have average case O(log n) insertion and deletion times, with constant time traversal.
	 * If you need a self balancing tree to ensure O(log n) with all possible input sets (certain sets degenerate the tree to O(n)), give a look at the RedBlackTree class.
	 * 
	 * @author Kyle Howell
	 */
	public class BinarySearchTree extends BinaryTree{
		/*private var _head:BinaryTreeNode;
		private var _size:int;
		//returns true if first less than second, false otherwise
		private var _compFunction:Function;*/
		
		/**
		 * Create and initialize a new Binary Search Tree.
		 *
		 * @param compFunction A function that takes two data objects as input and returns true when the first is less than the second and false otherwise.
		 */
		public function BinarySearchTree(compFunction:Function):void {
			_head = null;
			_size = 0;
			_compFunction = compFunction;
		}
		
		/* -------------------
		 * Public Functions
		 * -------------------
		 */
		
		
		/**
		 * Adds the supplied data to the Binary Search Tree.
		 * 
		 * @param data The data object to add.
		 */
		public function addData(data:*):void {
			var node:BinaryTreeNode = new BinaryTreeNode(data);
			_size ++;
			if (!_head) {
				_head = node;
				return;
			}
			
			var cursor:BinaryTreeNode = _head;
			var parent:BinaryTreeNode = null;
			while (cursor) {
				parent = cursor;
				//less than
				if (_compFunction(cursor.data, node.data)) {
					cursor = cursor.right;
				//more than or equal to
				} else {
					cursor = cursor.left;
				}
			}
			//choose which side of last node to go on
			node.parent = parent;
			if (_compFunction(parent.data, node.data)) {
				parent.right = node;
			}else {
				parent.left = node;
			}
		}
		
		/**
		 * Searches for supplied data and removes it if found. Returns true if it was found and removed, false otherwise.
		 * 
		 * @param data The data object to remove.
		 */
		public function removeData(data:*):Boolean {
			var node:BinaryTreeNode = getNode(data);
			if (node == null) {
				return false;
			}
			_size--;
			//overwrite with predecessor, then delete predecessor
			if (node.left && node.right) {
				var predecessor:BinaryTreeNode = node.left;
				while (predecessor.right) {
					predecessor = predecessor.right;
				}
				node.data = predecessor.data;
				node = predecessor;
			}
			if (node.left || node.right) {
				//one child
				var rightOfParent:Boolean = false;
				if (node.parent.right == node) {
					rightOfParent = true;
				}
				
				if (node.right) {
					tempNode = node.right;
					deleteNode(node);
					node.right.parent = node.parent;
				}else {
					var tempNode:BinaryTreeNode = node.left;
					deleteNode(node);
					node.left.parent = node.parent;
				}
				
				if (rightOfParent) {
					node.parent.right = tempNode;
				}else {
					node.parent.left = tempNode;
				}
				
			}else {
				//no children
				deleteNode(node);
			}
			return true;
		}
	}
}