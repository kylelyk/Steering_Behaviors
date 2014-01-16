package datastrucs{
	import datastrucs.BinaryTreeNode;
	/**
	 * A Red Black Tree is a Binary Search Tree that uses a coloring scheme to keep the tree balanced. 
	 * The result is a average time complexity for Inserting and Removing a node of O(log N).
	 * A comparing function is required to sort the tree so that all data can be sorted to your specifications.
	 * 
	 * @author Kyle Howell
	 */
	public class RedBlackTree extends BinaryTree{
		
		/**
		 * Create and initialize a new Red Black Tree.
		 *
		 * @param compFunction A function that takes two data objects as input and returns true when the first is less than the second and false otherwise.
		 */
		public function RedBlackTree(compFunction:Function) {
			_head = null;
			_size = 0;
			_compFunction = compFunction;
		}
		
		/* -------------------
		 * Public Functions
		 * -------------------
		 */
		
		/**
		 * Add the given data object to the tree.
		 *
		 * @param data The data to be added to the tree.
		 */
		public function addData(data:*):void {
			var node:BinaryTreeNode = new BinaryTreeNode(data);
			_size++;
			node.color = "RED";
			
			if (_head) {
				var cursor:BinaryTreeNode = _head;
				var parent:BinaryTreeNode = null;
				while (cursor) {
					parent = cursor;
					if (_compFunction(node.data, cursor.data)) {
						//less than
						cursor = cursor.left;
					} else {
						//more than or equal to
						cursor = cursor.right;
					}
				}
				
				//choose which side of last node to go on
				node.parent = parent;
				if (_compFunction(node.data, parent.data)) {
					parent.left = node;
				} else {
					parent.right = node;
				}
			} else {
				_head = node;
			}
			
			while (true) {
				//Case 1
				if (!node.parent) {
					node.color = "BLACK";
					return;
				}
				
				//Case 2
				if (node.parent.color == "BLACK") {
					return;
				}
				
				//Case 3
				var u:BinaryTreeNode = node.uncle;
				if (u && u.color == "RED") {
					node.parent.color = "BLACK";
					u.color = "BLACK";
					node.grandParent.color = "RED";
					node = node.grandParent;
				} else {
					break;
				}
				
			}
			
			//Case 4
			if (node == node.parent.right && node.parent == node.grandParent.left) {
				rotate(node.parent);
				node = node.left;
			} else if (node == node.parent.left && node.parent == node.grandParent.right) {
				rotate(node.parent, false);
				node = node.right;
			}
			
			//Case 5
			node.parent.color = "BLACK";
			node.grandParent.color = "RED";
			rotate(node.grandParent, node != node.parent.left);
		}
		
		/**
		 * Finds and removes the first instance of the data found in the tree.
		 *
		 * @param data The data to be removed from the tree.
		 * @return True if removed successfully, otherwise false.
		 */
		public function removeData(data:*):Boolean {
			//create a copy so that _compFunction can be used to find the node
			//we also return the node at the end of the function
			var targetNode:BinaryTreeNode = new BinaryTreeNode(data);
			
			//find where node lives so that we actually delete it and not a copy
			var node:BinaryTreeNode = getNode(data);
			if (!node) {
				return false;
			}
			
			//Successfully found node to be deleted
			_size--;
			
			//has two children
			if (node.left && node.right) {
				//replace with in-order predecessor
				var cursor:BinaryTreeNode = node.left;
				while (cursor.right) {
					cursor = cursor.right;
				}
				node.data = cursor.data;
				cursor.data = -1;
				//now focus on the in-order predecessor for the rest of the steps
				node = cursor;
			}
			
			//now has one or no children
			var child:BinaryTreeNode;
			var deleteN:BinaryTreeNode;
			if (node.left) {
				child = node.left;
			}else if (node.right) {
				child = node.right;
			}else {
				child = new BinaryTreeNode(null);
				child.color = "BLACK";
				//since we are making a sentinel node, we will need to delete it after we are done
				deleteN = child;
			}
			
			//FIRST CASE: node is red
			if (!isBlack(node)) {
				//has to have no children
				deleteNode(node);
				return true;
			}
			
			//SECOND CASE: node is black and child is red
			if (!isBlack(child)) {
				child.color = "BLACK";
				if (node.parent) {
					if (node == node.parent.left) {
						node.parent.left = child;
					}else {
						node.parent.right = child;
					}
				}
				child.parent = node.parent;
				return true;
			}
			
			//THIRD CASE: both are black
			//replace M with C
			if (node.parent) {
				if (node == node.parent.left) {
					node.parent.left = child;
				}else {
					node.parent.right = child;
				}
			}
			child.parent = node.parent;
			node = child;
			while(true){
				//Case 1
				if (!node.parent) {
					_head = node;
					deleteNode(deleteN);
					return true;
				}
				
				//Case 2
				if (!isBlack(node.sibling)) {
					node.parent.color = "RED";
					node.sibling.color = "BLACK";
					rotate(node.parent, node == node.parent.left);
				}
				
				//Case 3
				if(isBlack(node.parent) && isBlack(node.sibling) && isBlack(node.sibling.left) && isBlack(node.sibling.right)){
					node.sibling.color = "Red";
					node = node.parent;
				}else {
					break;
				}
			}
			
			//Case 4
			if (!isBlack(node.parent) && isBlack(node.sibling) && isBlack(node.sibling.left) && isBlack(node.sibling.right)) {
				node.sibling.color = "RED";
				node.parent.color = "BLACK";
				deleteNode(deleteN);
				return true;
			}
			
			//Case 5
			if (node == node.parent.left && isBlack(node.sibling.right) && !isBlack(node.sibling.left)) {
				node.sibling.color = "RED";
				setColor(node.sibling.left, "BLACK");
				rotate(node.sibling, false);
			}else if (node == node.parent.right && !isBlack(node.sibling.right) && isBlack(node.sibling.left)) {
				node.sibling.color = "RED";
				setColor(node.sibling.right, "BLACK");
				rotate(node.sibling);
			}
			
			//Case 6
			node.sibling.color = node.parent.color;
			node.parent.color = "BLACK";
			if (node == node.parent.left) {
				setColor(node.sibling.right, "BLACK");
				rotate(node.parent);
			}else {
				setColor(node.sibling.left, "BLACK");
				rotate(node.parent, false);
			}
			deleteNode(deleteN);
			return true;
		}
		
		/**
		 * Checks the node for the color while properly handling leaf (null) nodes.
		 *
		 * @param node The node to be checked.
		 * @return A boolean signifying if the node is black.
		 */
		private function isBlack(node:BinaryTreeNode):Boolean {
			if (!node) {
				return true;
			}
			return node.color == "BLACK"
		}
		
		/**
		 * Set the nodes color while properly handling leaf (null) nodes.
		 *
		 * @param node The node to be changed.
		 */
		private function setColor(node:BinaryTreeNode, color:String):void {
			if (!node) {
				return;
			}
			node.color = color;
		}
	}
}