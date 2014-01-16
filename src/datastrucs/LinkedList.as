package datastrucs{
	
	/**
	* Uses the node to create a Doubly Linked List, ignoring the neighbors property of the node
	* @author Kyle Howell
	*/
	public class LinkedList {
		private var _length:uint;
		public var head:LinkedListNode;
		public var tail:LinkedListNode;
		
		public function LinkedList(... args) {
			_length = 0;
			if (args != null) {
				for each (var item:*in args) {
					push(item);
				}
			} else {
				head = null;
				tail = null;
			}
		}
		
		//Getters and Setters
		public function get length():uint {
			return _length;
		}
		
		//WARNING: Will be computed in linear time
		public function nodeAt(index:uint):LinkedListNode {
			var count:uint = 0;
			var curNode:LinkedListNode = head;
			while (count < index) {
				curNode = curNode.next;
				count++;
			}
			return curNode;
		}
		
		//alternative to Splice() function and returns false if the node was not in the list
		public function removeNode(node:LinkedListNode):Boolean {
			//check to see if head or tail
			if (node == head) {
				head = node.next;
				head.prev = null;
			} else if (node == tail) {
				tail = node.prev;
				tail.next = null;
			} else {
				//if not and node does not have both prev and next, return false
				if (node.prev == null || node.next == null) {
					return false;
				}
				//Otherwise it is in middle of linked list
				node.prev.next = node.next;
				node.next.prev = node.prev;
			}
			return true;
		}
		
		//Creates a whole new list with new nodes and properties identical to the original
		public function clone():LinkedList {
			var newLinkedList:LinkedList = new LinkedList()
			var curNode:LinkedListNode = head;
			while (curNode != null) {
				newLinkedList.push(curNode.clone())
				curNode = curNode.next;
			}
			return newLinkedList;
		}
		
		public function convertToArray():Array {
			var newArray:Array = new Array();
			var curNode:LinkedListNode = head;
			while (curNode != null) {
				newArray.push(curNode.data);
				curNode = curNode.next;
			}
			return newArray;
		}
		
		//Array Equivalent Methods (Warnings point out slower times than Arrays)
		public function indexOf(searchElement:*, fromIndex:int = 0):int {
			var curNode:LinkedListNode = nodeAt(fromIndex);
			var count:uint = fromIndex;
			while (curNode.data != searchElement) {
				if (curNode == null) {
					return -1;
				}
				curNode = curNode.next;
				count++;
			}
			return count;
		}
		
		//WARNING: Passing in a node will search for the reference to the node and not the data within the node
		public function lastIndexOf(searchElement:*, fromIndex:int = 0x7fffffff):int {
			var curNode:LinkedListNode = nodeAt(fromIndex);
			var count:uint = fromIndex;
			while (curNode.data != searchElement) {
				if (curNode == null) {
					return -1;
				}
				curNode = curNode.prev;
				count--;
			}
			return count;
		}
		
		public function pop():LinkedListNode {
			var oldTail:LinkedListNode
			switch (_length) {
				case 0: 
					return null;
				case 1: 
					oldTail = tail;
					head = null;
					tail = null;
					_length--;
					return oldTail;
				default: 
					oldTail = tail;
					tail = tail.prev;
					tail.next = null;
					_length--;
					return oldTail;
			}
		}
		
		//Will add to the end the data object or reference to the node passed in
		//Clips off old prev and next data and updates them into the list
		public function push(... args):uint {
			for each (var item:*in args) {
				var newNode:LinkedListNode;
				//Check if node or data object
				newNode = new LinkedListNode(item);
				
				if (_length != 0) {
					tail.next = newNode;
					newNode.prev = tail;
					newNode.next = null;
					tail = newNode;
				} else {
					head = newNode;
					tail = newNode;
					newNode.prev = null;
					newNode.next = null;
				}
				_length++;
			}
			return _length;
		}
		
		public function reverse():LinkedList {
			var newLinkedList:LinkedList = new LinkedList();
			//if length is 0
			if (_length == 0) {
				return newLinkedList;
			}
			
			var curNode:LinkedListNode = tail;
			//Make a copy of the node (otherwise it just passes a reference)
			newLinkedList.push(curNode.clone());
			
			//If length is 1
			if (_length == 1) {
				return newLinkedList;
			}
			
			var count:uint = 1;
			while (count < _length) {
				curNode = curNode.prev;
				newLinkedList.push(curNode.clone());
				count++;
			}
			return newLinkedList;
		}
		
		public function shift():LinkedListNode {
			var oldHead:LinkedListNode
			switch (_length) {
				case 0: 
					return null;
				case 1: 
					oldHead = head;
					head = null;
					tail = null;
					_length--;
					return oldHead;
				default: 
					oldHead = head;
					head = head.next;
					head.prev = null;
					_length--;
					return oldHead;
			}
		}
		
		//WARNING: Will be computed in linear time
		public function slice(startIndex:int = 0, endIndex:int = 16777215):LinkedList {
			return null;
		}
		
		//WARNING: Will be computed in linear time
		public function splice(startIndex:int, deleteCount:uint, ... values):LinkedList {
			return null;
		}
		
		public function toString():String {
			if (_length == 0) {
				return "Empty Linked List";
			}
			var curNode:LinkedListNode = head;
			var string:String = "";
			while (curNode != null) {
				string += String(curNode.data) + " ";
				curNode = curNode.next;
			}
			return string;
		}
		
		public function unshift(... args):uint {
			//have to go backwards so that the args stay in the right order
			for (var i:int = args.length - 1; i >= 0; i--) {
				var newNode:LinkedListNode;
				//Check if node or data object
				if (args[i] is LinkedListNode) {
					newNode = args[i];
				} else {
					newNode = new LinkedListNode(args[i]);
				}
				
				if (_length != 0) {
					head.prev = newNode;
					newNode.prev = null;
					newNode.next = head;
					head = newNode;
				} else {
					head = newNode;
					tail = newNode;
					newNode.prev = null;
					newNode.next = null;
				}
				_length++;
			}
			return _length;
		}
	}
}