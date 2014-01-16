package datastrucs{
	
	/**
	 * Dynamic node class that can be in any type of binary search tree.
	 * @author Kyle Howell
	 */
	public dynamic class BinaryTreeNode {
		public var data:*;
		public var parent:BinaryTreeNode;
		public var left:BinaryTreeNode;
		public var right:BinaryTreeNode;
		
		public function BinaryTreeNode(obj:* = null):void {
			data = obj;
			parent = null;
			left = null;
			right = null;
		}
		
		//In the format of Parent, Data, Left, Right
		public function toString():String {
			var string:String = "";
			if (!parent) {
				string += "null  , ";
			} else {
				string += "[NODE], ";
			}
			
			if (!left) {
				string += String(data) + ", null  , ";
			} else {
				string += String(data) + ", [NODE], ";
			}
			
			if (!right) {
				string += "null";
			} else {
				string += "[NODE]";
			}
			return string
		}
		
		public function clone():BinaryTreeNode {
			var newNode:BinaryTreeNode = new BinaryTreeNode(data);
			newNode.right = right;
			newNode.left = left;
			newNode.parent = parent;
			return newNode;
		}
		
		//remove all references and assigns null to all references that point to this node
		//Note: Does not repair tree; deleteNode() should be used first then destroy()
		public function destroy():void {
			//Check to see if the reference exists, then navigate through the reference and remove it so the node can be Garbage Collected
			//Have to check if the reference is actually to this node; we don't want to rely on trusting this node if it has out-of-date references
			if (parent) {
				if (parent.left == this) {
					parent.left = null;
				}
				if (parent.right == this) {
					parent.right = null;
				}
			}
			if (left) {
				if (left.parent == this) {
					left.parent = null;
				}
			}
			if (right) {
				if (left.parent == this) {
					left.parent = null;
				}
			}
		}
		
		public function get sibling():BinaryTreeNode {
			if (parent) {
				if (parent.left == this) {
					return parent.right;
				} else {
					return parent.left;
				}
			}
			return null;
		}
		
		public function get grandParent():BinaryTreeNode {
			if (parent && parent.parent) {
				return parent.parent;
			}
			return null;
		}
		
		public function get uncle():BinaryTreeNode {
			if (grandParent) {
				if (parent == grandParent.left) {
					return grandParent.right;
				} else {
					return grandParent.left;
				}
			}
			return null;
		}
	}
}