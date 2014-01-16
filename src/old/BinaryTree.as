package {
	
	/**
	* DO NOT USE: OUT OF DATE, HAS NOT BEEN TESTED, USES SNODES (WHICH IS DIFFERENT THAN ALL THE OTHER DATA STRUCTURES)
	* @author Kyle Howell
	*/
	public class BinaryTree {
		public var root:BinaryTreeNode;
		public var degree:uint;
		public static const LEFTONLY:uint = 1;
		public static const RIGHTONLY:uint = 2;
		public static const LEFTRIGHT:uint = 3;
		public static const RIGHTLEFT:uint = 4;
		
		public static const SNODE:BinaryTreeNode = BinaryTreeNode.SNODE;
		
		public function BinaryTree():void {
			degree = 0;
			root = SNODE
		}
		
		//If childOf is specified, will try to add to that node by filling empty spot (left or right by priority) 
		//OR by inserting between the parent and child (left or right by priority) unless insert is set to false
		//Returns the parent of the inserted node or Null if it can not be inserted 
		public function insert(item:*, parentNode:BinaryTreeNode = null, priority:uint = 0, insert:Boolean = true):BinaryTreeNode {
			var insertNode:BinaryTreeNode
			if (item is BinaryTreeNode) {
				insertNode = item;
			} else {
				insertNode = new BinaryTreeNode(item);
			}
			//Go through all the cases if parentNode is given
			if (parentNode) {
				
				//Case that parentNode is null
				if (!parentNode) {
					return null;
				}
				//Case that right is null
				if (!parentNode.right) {
					parentNode.right = SNODE;
				}
				//Case that left is null
				if (!parentNode.left) {
					parentNode.left = SNODE;
				}
				
				//If priority is not between 1 and 4, randomly assign between LEFTRIGHT and RIGHTLEFT
				if (priority == 0 || priority > 4) {
					var order:uint = int(Math.random() * 2) + 3;
					priority = order
				}
				
				//Checks are in the form:
				//1. IF Node is SNODE --> addNode
				//2. IF Insert is true AND Node is not SNODE --> insertNode
				switch (priority) {
					case 1: 
						//only add left
						if (parentNode.left == SNODE) {
							addLeftNode(parentNode, insertNode);
							return parentNode;
						} else if (insert && parentNode.left != SNODE) {
							insertLeftNode(parentNode, insertNode);
							return parentNode;
						} else {
							return null;
						}
					
					case 2: 
						//only add right
						if (parentNode.right == SNODE) {
							addRightNode(parentNode, insertNode);
							return parentNode;
						} else if (insert && parentNode.right != SNODE) {
							insertRightNode(parentNode, insertNode);
							return parentNode;
						} else {
							return null;
						}
					
					case 3: 
						//try left then right first without inserting then try inserting
						if (parentNode.left == SNODE) {
							addLeftNode(parentNode, insertNode);
							return parentNode;
						} else if (parentNode.right == SNODE) {
							addRightNode(parentNode, insertNode);
							return parentNode;
						} else if (insert) {
							if (parentNode.left != SNODE) {
								insertLeftNode(parentNode, insertNode);
								return parentNode;
							} else if (parentNode.right != SNODE) {
								insertRightNode(parentNode, insertNode);
								return parentNode;
							}
						} else {
							return null;
						}
					
					case 4: 
						//try right then left first without inserting then try inserting
						if (parentNode.right == SNODE) {
							addRightNode(parentNode, insertNode);
							return parentNode;
						} else if (parentNode.left == SNODE) {
							addLeftNode(parentNode, insertNode);
							return parentNode;
						} else if (insert) {
							if (parentNode.right != SNODE) {
								insertRightNode(parentNode, insertNode);
								return parentNode;
							} else if (parentNode.left != SNODE) {
								insertLeftNode(parentNode, insertNode);
								return parentNode;
							}
						} else {
							return null;
						}
					default: 
						trace("Error with priority")
						break;
				}
			} else {
				//didn't get a node so just find some place to add
				if (degree == 0) {
					root = insertNode;
					insertNode.parent = SNODE;
					insertNode.left = SNODE;
					insertNode.right = SNODE;
					insertNode.side = "NONE";
					return SNODE
				}
				var parentNode:BinaryTreeNode = findSNODE(root);
				if (parentNode.left == SNODE) {
					addLeftNode(parentNode, insertNode);
					return parentNode;
				} else if (parentNode.right == SNODE) {
					addRightNode(parentNode, insertNode);
					return parentNode;
				} else {
					trace("Error with findSNODE")
					return null;
				}
			}
			trace("No cases taken in insert() in BinaryTree")
			return null;
		}
		
		//Returns true if successful (only if the node's parent has only one child or zero children)
		//Will try to collapse the child node to the deletedNode's parent if collapse is set to true
		public function deleteNode(deleteNode:BinaryTreeNode, collapse:Boolean = true):Boolean {
			cleanNode(deleteNode)
			
			//Cases are:
			//1. Node has no children
			//2. Node has two children
			//3. Node has one child
			var parentNode:BinaryTreeNode = deleteNode.parent;
			if (deleteNode.left == SNODE && deleteNode.right == SNODE) {
				if (deleteNode.side == "LEFT") {
					parentNode.left = SNODE;
				} else {
					parentNode.right = SNODE;
				}
				return true
			} else if (deleteNode.left != SNODE && deleteNode.right == SNODE) {
				return false
			}
			if(
					
					if (deleteNode.side == "LEFT") {
						deleteNode.left.parent = parentNode;
					} else {
						
					}
					//deleteNode.parent.=deleteNode.left
					return true;
				} else if (deleteNode.left == SNODE && deleteNode.right != SNODE) {
					
					return true;
				}
			}
			return false;
		}
		
		//returns first parent that has SNODE as child it finds
		private function findSNODE(curNode:BinaryTreeNode):BinaryTreeNode {
			if (curNode == SNODE) {
				return curNode;
			} else {
				if (curNode.left == SNODE) {
					return curNode.left;
				} else {
					findSNODE(curNode.left);
				}
				if (curNode.right == SNODE) {
					return curNode.right;
				} else {
					findSNODE(curNode.right);
				}
			}
			trace("Error: could not find SNODE")
			return null;
		}
		
		private function addLeftNode(parentNode:BinaryTreeNode, insertNode:BinaryTreeNode):void {
			parentNode.left = insertNode;
			insertNode.parent = parentNode;
			insertNode.side = "LEFT";
		}
		
		private function addRightNode(parentNode:BinaryTreeNode, insertNode:BinaryTreeNode):void {
			parentNode.right = insertNode;
			insertNode.parent = parentNode;
			insertNode.side = "RIGHT";
		}
		
		private function insertLeftNode(parentNode:BinaryTreeNode, insertNode:BinaryTreeNode):void {
			var oldChild:BinaryTreeNode = parentNode.left;
			parentNode.left = insertNode;
			oldChild.parent = insertNode;
			insertNode.parent = parentNode;
			insertNode.left = oldChild;
			insertNode.side = "LEFT";
		}
		
		private function insertRightNode(parentNode:BinaryTreeNode, insertNode:BinaryTreeNode):void {
			var oldChild:BinaryTreeNode = parentNode.right;
			parentNode.right = insertNode;
			oldChild.parent = insertNode;
			insertNode.parent = parentNode;
			insertNode.right = oldChild;
			insertNode.side = "RIGHT";
		}
		
		private function cleanNode(node:BinaryTreeNode):void {
			if (!node) {
				node = SNODE;
				return
			}
			if (!node.parent) {
				node.parent = SNODE;
			}
			if (!node.left) {
				node.left = SNODE;
			}
			if (!node.right) {
				node.right = SNODE;
			}
		}
	}
}