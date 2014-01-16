package datastrucs{
	
	/**
	* Node class that can be in a linked list or hold multiple neighbors in a graph type object.
	* 
	* @author Kyle Howell
	*/
	public class LinkedListNode {
		public var data:*;
		public var next:LinkedListNode;
		public var prev:LinkedListNode;
		
		public function LinkedListNode(obj:* = null):void {
			data = obj;
			next = null;
			prev = null;
		}
		
		//In the format of Prev, Data, Next
		public function toString():String {
			var string:String = "";
			if (prev != null) {
				string += "[Node], " + String(data);
			} else {
				string += "Null, " + String(data);
			}
			
			if (next != null) {
				string += ", [Node]";
			} else {
				string += ", Null";
			}
			return string
		}
		
		public function clone():LinkedListNode {
			var newNode:LinkedListNode = new LinkedListNode(data);
			newNode.prev = prev;
			newNode.next = next;
			return newNode;
		
		}
	}
}