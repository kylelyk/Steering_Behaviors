package datastrucs {
	import flash.utils.ByteArray;
	
	/**
	 * A binary heap is a data structure that can only retrieve the lowest element if its a minheap, or the largest element if it is a max heap.
	 * Since it self balences, insertions and deletions occur in O(log n) time ignostic of the input set.
	 *
	 * @author Kyle Howell
	 */
	public class BinaryHeap {
		private var _maxHeap:Boolean;
		private var _compFunction:Function;
		private var _elements:Array;
		private var _size:uint;
		
		/**
		 * Create and initialize a new Binary Heap
		 *
		 * @param compFunction A function that takes two data objects as input and returns true when the first is less than the second and false otherwise.
		 * @param maxHeap True if the heap is a max heap and false if the heap is a min heap.
		 */
		public function BinaryHeap(compFunction:Function, maxHeap:Boolean):void {
			_maxHeap = maxHeap;
			_compFunction = compFunction;
			_elements = new Array();
		}
		
		/* -------------------
		 * Public Functions
		 * -------------------
		 */
		
		/**
		 * Inserts the givenp data object into the heap.
		 */
		public function insert(data:*):void {
			var index:uint = _size;
			_size++;
			_elements.push(data);
			//annoying that int(-.5) = 0 so have to use floor here (slower than casting to int)
			while (Math.floor((index - 1) / 2) >= 0) {
				//parent < child
				if (_compFunction(_elements[int((index - 1) / 2)], _elements[index])) {
					if (_maxHeap) {
						swap(int((index - 1) / 2), index);
						index = int((index - 1) / 2);
					} else {
						break;
					}
				//parent >= child
				} else {
					if (_maxHeap) {
						break;
					} else {
						swap(int((index - 1) / 2), index);
						index = int((index - 1) / 2);
					}
				}
			}
		}
		
		/**
		 * Removes and returns the top data object in the heap or null if the heap is empty.
		 */
		public function removeTop():* {
			//zero or only one element left
			if (_size == 0) {
				return null;
			} else if (_size == 1) {
				_size = 0;
				return _elements.pop();
			} 
			
			_size--;
			var ret:* = _elements[0];
			_elements[0] = _elements.pop();
			
			//repair the heap
			var index:uint = 0;
			while (true) {
				//-1 for no such child, 0 for false, 1 for true
				var leftBetter:int;
				var rightBetter:int;
				//1 if left, 2 if right, 0 if neither
				var swapTarget:int = 0;
				
				//determine the if left and/or right child should be swapped with the parent
				if (2 * index + 1 < _size) {
					//esentially XNOR
					leftBetter = 1 - (int(_maxHeap) ^ _compFunction(_elements[index], _elements[2 * index + 1]));
				} else {
					leftBetter = -1;
				}
				if (2 * index + 2 < _size) {
					//esentially XNOR
					rightBetter = 1 - (int(_maxHeap) ^ _compFunction(_elements[index], _elements[2 * index + 2]));
				} else {
					rightBetter = -1;
				}
				
				//determine the swapTarget (left, right, or neither)
				if (leftBetter == 1 && rightBetter == 1) {
					//esentially XNOR + 1
					swapTarget = 2 - (int(_maxHeap) ^ _compFunction(_elements[2 * index + 1], _elements[2 * index + 2]));
				} else if (leftBetter == 1) {
					swapTarget = 1;
				} else if (rightBetter == 1) {
					swapTarget = 2;
				} else {
					break;
				}
				
				//actually swap now
				swap(index, 2 * index + swapTarget);
				index = 2 * index + swapTarget;
			}
			return ret;
		}
		
		/* -------------------
		 * Private Functions
		 * -------------------
		 */
		
		/**
		 * Swap two data objects at index's 1 and 2.
		 *
		 */
		private function swap(index1:uint, index2:uint):void {
			//safety precaution
			if (index1 >= _size || index2 >= _size) {
				return;
			}
			var tempData:* = _elements[index1];
			_elements[index1] = _elements[index2];
			_elements[index2] = tempData;
		}
		
		/*public function clone(source:Object):* {
			var myBA:ByteArray = new ByteArray();
			myBA.writeObject(source);
			myBA.position = 0;
			return myBA.readObject();
		}*/
		
		/* -------------------
		 * Getters and Setters
		 * -------------------
		 */
		
		public function get top():* {
			if (_size > 0) {
				return _elements[0];
			}
			return null;
		}
		
		public function get size():uint {
			return _size;
		}
	}
}