package datastrucs {
	import datastrucs.BinaryTreeNode;
	
	/**
	 * Base class for any type of Binary Tree. If you're looking for where sibling, uncle, or grandparent getters are defined, that is in BinaryTreeNode.as
	 *
	 * @author Kyle Howell
	 */
	public class BinaryTree {
		protected var _head:BinaryTreeNode;
		protected var _size:int;
		//returns true if first less than second, false otherwise
		protected var _compFunction:Function;
		
		//TODO: Add tests for this base class
		public function BinaryTree() {
		
		}
		
		/* -------------------
		 * Public Functions
		 * -------------------
		 */
		
		/**
		 * Traverses the tree In-order, calling the function given when visiting a node.
		 *
		 * @param funct The function called when a node is visited.
		 * @param start The starting node in the tree. If left null, the whole tree will be traversed.
		 */
		public function inOrderTraverse(funct:Function, start:BinaryTreeNode = null):void {
			var stack:Vector.<BinaryTreeNode> = new Vector.<BinaryTreeNode>;
			var node:BinaryTreeNode;
			if (!start) {
				node = _head;
			} else {
				node = start;
			}
			while (stack.length != 0 || node) {
				if (node) {
					stack.push(node);
					node = node.left;
				} else {
					node = stack.pop();
					funct(node.data); //visit node by handing node data to supplied function
					node = node.right;
				}
			}
		}
		
		//before
		public function getInorderPredessor(data:*):* {
			var node:BinaryTreeNode = getNode(data);
			if (!node) {
				return null;
			}
			var cursor:BinaryTreeNode = node;
			
			if (!node.left) {
				//no left child so predessor is closest ancestor such that 
				//node is decended from the right child of the ancestor
				while (cursor.parent) {
					if (cursor.parent.right == cursor) {
						return cursor.parent.data;
					}
					cursor = cursor.parent;
				}
				return null;
			} else {
				//left child so predessor is rightmost descendent
				cursor = node.left;
				while (cursor.right) {
					cursor = cursor.right;
				}
				return cursor.data;
			}
		}
		
		//after
		public function getInorderSuccessor(data:*):* {
			var node:BinaryTreeNode = getNode(data);
			if (!node) {
				return null;
			}
			var cursor:BinaryTreeNode = node;
			if (!node.right) {
				while (cursor.parent) {
					if (cursor.parent.left == cursor) {
						return cursor.parent.data;
					}
					cursor = cursor.parent;
				}
				return null;
			} else {
				cursor = node.right;
				while (cursor.left) {
					cursor = cursor.left;
				}
				return cursor.data;
			}
		}
		
		/**
		 * Finds the specified data object in the tree.
		 *
		 * @param data The data to be searched for.
		 * @return True if successful, false otherwise.
		 */
		public function containsData(data:*):Boolean {
			return getNode(data) != null;
		}
		
		/* -------------------
		 * Protected Functions
		 * -------------------
		 */
		
		/**
		 * Helper function that searches for supplied data and returns containing node if found.
		 *
		 * @param data The data object to search for.
		 * @return The BinaryTreeNode that contains the first instance of data found.
		 */
		protected function getNode(data:*):BinaryTreeNode {
			var cursor:BinaryTreeNode = _head;
			while (cursor) {
				//found it
				if (cursor.data == data) {
					return cursor;
						//less than
				} else if (_compFunction(data, cursor.data)) {
					cursor = cursor.left;
						//more than or equal to
				} else {
					cursor = cursor.right;
				}
			}
			return null;
		}
		
		/**
		 * Helper function that removes all references to the node so that it can be removed from the tree and garbage collected.
		 * WARNING: Does not check if the reference is actually to the node, just that the node has a reference to the particular node. This can cause problems if node is messed around with and is not propertly in the Binary Tree.
		 *
		 * @param node The node to completely removed from the tree.
		 */
		protected function deleteNode(node:BinaryTreeNode):void {
			if (!node) {
				return;
			}
			
			if (_head == node) {
				_head = null;
			}
			if (node.parent) {
				if (node.parent.left == node) {
					node.parent.left = null;
				} else if (node.parent.right == node) {
					node.parent.right = null;
				}
			}
			if (node.left) { //debug errors coming from changing this line to be more flexible
				node.left.parent = null;
			}
			if (node.right) {
				node.right.parent = null;
			}
		
		}
		
		/**
		 * Rotates around the parent Node left or right.
		 *
		 * @param parent The parent of the two nodes that will be rotated.
		 * @param left The side of rotation. Rotate left if True, rotate right if false.
		 */
		protected function rotate(parentN:BinaryTreeNode, left:Boolean = true):void {
			if (left) {
				
				var rightN:BinaryTreeNode = parentN.right;
				//first change
				parentN.right = rightN.left;
				if (rightN.left) {
					rightN.left.parent = parentN;
				}
				//second change
				if (parentN.parent) {
					if (parentN.parent.right == parentN) {
						parentN.parent.right = rightN;
						
					} else {
						parentN.parent.left = rightN;
					}
				}
				rightN.parent = parentN.parent;
				//third change
				rightN.left = parentN;
				parentN.parent = rightN;
				//special case where _head is pointing to parentN
				if (_head == parentN) {
					_head = rightN;
				}
				
			} else {
				
				var leftN:BinaryTreeNode = parentN.left;
				//first change
				parentN.left = leftN.right;
				if (leftN.right) {
					leftN.right.parent = parentN;
				}
				//second change
				if (parentN.parent) {
					if (parentN.parent.right == parentN) {
						parentN.parent.right = leftN;
					} else {
						parentN.parent.left = leftN;
					}
				}
				leftN.parent = parentN.parent;
				//third change
				leftN.right = parentN;
				parentN.parent = leftN;
				//special case where _head is pointing to parentN
				if (_head == parentN) {
					_head = leftN;
				}
				
			}
		}
		
		/* -------------------
		 * Getters and Setters
		 * -------------------
		 */
		
		public function get size():uint {
			return _size;
		}
	}
}