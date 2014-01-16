package datastrucs {
	import flash.display.PixelSnapping;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import geometry.Vector2D;
	import datastrucs.Quadrant;
	
	/**
	 * ...
	 * @author Kyle Howell
	 */
	public class QuadTree {
		public const MAXLEVELS:uint = 5;
		public var maxObjects:uint = 10;
		private var _head:Quadrant;
		private var _size:uint = 0;
		
		public static const ASCENDING:int = 1;
		public static const DESCENDING:int = 2;
		
		public function QuadTree(bounds:Rectangle) {
			_head = new Quadrant(0, -1, bounds.clone());
		}
		
		//object must have rect property
		public function insert(object:*):Boolean {
			try {
				//trace(object.rect)
				var rect:Rectangle = object.rect
			}
			catch (e:Error) {
				throw(new Error("Object to be inserted must a rect property that returns a flash.geom.Rectangle representing its bounding box."));
			}
			
			var curNode:Quadrant = _head;
			//does not fit into topmost node
			var tempRect:Rectangle = curNode.bounds
			if (rect.x < tempRect.x || rect.right > tempRect.right || rect.y < tempRect.y || rect.bottom > tempRect.bottom) {
				return false;
			}
			
			_size++;
			
			//First find the bottom node (leaf or smallest the rect can fit in)
			//If it is not a leaf, then just add to node and return since we can't put into subnodes
			while (curNode.nodes[0]) {
				//find the bottom node
				var index:int = getSub(curNode, rect);
				if (index == -1) {
					//can't fit into subNodes
					curNode.objects.push(object);
					return true;
				}
				curNode = curNode.nodes[index];
			}
			
			//curNode is a leaf so:
			//If there's no more room and we are not at MAXLEVELS yet, then split
			curNode.objects.push(object);
			if (curNode.objects.length > maxObjects && curNode.level < MAXLEVELS) {
				split(curNode);
				var newArr:Array = new Array();
				for (var i:uint = 0; i < curNode.objects.length; i++) {
					var obj:Object = curNode.objects[i];
					index = getSub(curNode, obj.rect);
					//decide if the rect can fit into sub node, otherwise keep in parent
					if (index != -1) {
						curNode.nodes[index].objects.push(obj);
					} else {
						newArr.push(obj);
					}
				}
				//update curNodes objects (those that couldn't fit into subnodes are the ones left)
				curNode.objects = newArr;
			}
			
			return true;
		}
		
		public function remove(object:*):Boolean {
			try {
				var rect:Rectangle = object.rect
			}
			catch (e:Error) {
				throw(new Error("Object to be removed must a rect property that returns a flash.geom.Rectangle representing its bounding box."));
			}
			
			var curNode:Quadrant = _head;
			while (curNode.nodes[0]) {
				//find the bottom node
				var index:int = getSub(curNode, rect);
				if (index == -1) {
					//can't fit into subnodes, so we found the node that possibly contains the object
					break
				}
				curNode = curNode.nodes[index];
			}
			
			index = curNode.objects.indexOf(object);
			if (index == -1) {
				return false;
			}
			
			curNode.objects.splice(index, 1);
			_size--;
			return true;
		}
		
		public function clear():void {
			_head.nodes[0] = null;
			_head.nodes[1] = null;
			_head.nodes[2] = null;
			_head.nodes[3] = null;
			_head.objects = new Array();
			_size = 0;
		}
		
		//if array is specified, then traverse will add objects it finds in the tree to it (so no need to pass in a function just to add the objects traversed);
		public function traverse(funct:Function = null, start:Quadrant = null, array:Array = null):void {
			var stack:Vector.<Quadrant> = new Vector.<Quadrant>;
			var indices:Vector.<int> = new Vector.<int>;
			var n:Quadrant = start;
			if (!n) {
				n = _head;
			}
			var index:int = 0;
			while (n) {
				if (index < 4 && n.nodes[index]) {
					//still have subnodes, so visit them first
					stack.push(n);
					indices.push(index);
					//go to next child and reset index
					n = n.nodes[index];
					index = 0;
				} else {
					//done in this node, passing in final objects, then going to parent
					if (array) {
						array.push.apply(this, n.objects);
					}
					if (funct != null) {
						for (var i:uint = 0; i < n.objects.length; i++) {
							funct(n.objects[i]);
						}
					}
					n = stack.pop();
					index = indices.pop();
					//next child in parent to go to
					index++;
				}
			}
		}
		
		//TODO: remove the stack & indices vectors(its not needed since each node has parent and type)
		//returns an array of objects that touch the given rectangle
		//defaults to no paticular order
		public function query(queryRect:Rectangle):Array {
			//stores child i at index i
			var stack:Vector.<Quadrant> = new Vector.<Quadrant>;
			//stores the index of child i at the ith element
			var indices:Vector.<int> = new Vector.<int>;
			
			var node:Quadrant = _head;
			var index:int = 0;
			var ret:Array = new Array();
			
			//Start at the head node and do this cycle:
			//	If the node is completely contained, then simply put all objects in that node and its subnodes onto the list
			//	If the node is only intersected, then go through its objects to see if they intersect, and then go to its child nodes if its not a leaf
			// 	If the node does not intersect, then go back up to its parent node and then to the next child (or go up several parents if on last child of each)
			while (true) {
				var intersects:Boolean = queryRect.left <= node.bounds.right && node.bounds.left <= queryRect.right && queryRect.top <= node.bounds.bottom && node.bounds.top <= queryRect.bottom
				if (intersects) {
					var contains:Boolean = queryRect.left <= node.bounds.left && queryRect.right >= node.bounds.right && queryRect.top <= node.bounds.top && queryRect.bottom >= node.bounds.bottom;
					if (contains) {
						//rect completley contains node so all subnodes go onto the list
						traverse(null, node, ret);
					} else {
						//node only partially intersects rect so filter through all objects in node
						for (var i:uint = 0; i < node.objects.length; i++) {
							var objRect:Rectangle = node.objects[i].rect;
							if (queryRect.left <= objRect.right && objRect.left <= queryRect.right && queryRect.top <= objRect.bottom && objRect.top <= queryRect.bottom) {
								ret.push(node.objects[i]);
							}
						}
						
						//if it has subnodes, visit them
						if (node.nodes[index]) {
							stack.push(node);
							node = node.nodes[0];
							
							index = 0;
							indices.push(0);
							continue;
						}
					}
				}
				
				//go find siblings if they exist or keep going back up the chain (uncles, etc.) until we can find a node to examine
				do {
					node = stack.pop();
					index = indices.pop();
					index++;
				} while (index == 4 && node);
				
				//no more nodes to be examined
				if (!node) {
					break;
				}
				
				//save the parent and which child we are visiting
				stack.push(node);
				indices.push(index);
				node = node.nodes[index];
				
			}
			return ret;
		}
		
		//defaults to no paticular order
		public function withinDistance(cirCenter:Point, distance:Number, max:int = -1, flags:int = 0):Array {
			var circleDistance:Vector2D = new Vector2D();
			
			//stores child i at index i
			var stack:Vector.<Quadrant> = new Vector.<Quadrant>;
			//stores the index of child i at the ith element
			var indices:Vector.<int> = new Vector.<int>;
			
			var node:Quadrant = _head;
			var index:int = 0;
			var ret:Array = new Array();
			var includeDist:Boolean = Boolean((flags & ASCENDING) | (flags & DESCENDING));
			//Start at the head node and do this cycle:
			//	If the node is completely contained, then simply put all objects in that node and its subnodes onto the list
			//	If the node is only intersected, then go through its objects to see if they intersect, and then go to its child nodes if its not a leaf
			// 	If the node does not intersect, then go back up to its parent node and then to the next child (or go up several parents if on last child of each)
			while (true) {
				var intersects:Boolean = circleIntersectsRect(cirCenter, distance, node.bounds);
				/*circleDistance.x = Math.abs(cirCenter.x - node.bounds.x - node.bounds.width * 0.5);
				   circleDistance.y = Math.abs(cirCenter.y - node.bounds.y - node.bounds.height * 0.5);
				   //decide if node is intersecting with circle
				
				   if (circleDistance.x > node.bounds.width * 0.5 + distance || circleDistance.y > node.bounds.height * 0.5 + distance) {
				   //circle is at least radius away from node edge, so it cannot possibly touch
				   intersects = false;
				   } else if (circleDistance.x <= node.bounds.width * 0.5 || circleDistance.y <= node.bounds.height * 0.5) {
				   //at least one component of the circle center is inside the rectangle, so it has to intersect
				   intersects = true;
				   } else {
				   //corner case, so check if circle is overlapping corner
				   var hDist:Number = circleDistance.x - node.bounds.width * 0.5;
				   var vDist:Number = circleDistance.y - node.bounds.height * 0.5;
				   intersects = hDist * hDist + vDist * vDist <= distance * distance;
				 }*/
				if (intersects) {
					//decide if node is contained in circle
					var contains:Boolean = circleContainsRect(cirCenter, distance, node.bounds);
					
					if (contains) {
						//rect completley contains node so all subnodes go onto the list
						traverse(null, node, ret);
					} else {
						//node only partially intersects circle so filter through all objects in node
						for (var i:uint = 0; i < node.objects.length; i++) {
							var objRect:Rectangle = node.objects[i].rect;
							if (circleIntersectsRect(cirCenter, distance, objRect)) {
								ret.push(node.objects[i]);
							}
						}
						
						//if it has subnodes, visit them
						if (node.nodes[index]) {
							stack.push(node);
							node = node.nodes[0];
							
							index = 0;
							indices.push(0);
							continue;
						}
					}
				}
				
				//go find siblings if they exist or keep going back up the chain (uncles, etc.) until we can find a node to examine
				do {
					node = stack.pop();
					index = indices.pop();
					index++;
				} while (index == 4 && node);
				
				//no more nodes to be examined
				if (!node) {
					break;
				}
				
				//save the parent and which child we are visiting
				stack.push(node);
				indices.push(index);
				node = node.nodes[index];
				
			}
			if ((flags & ASCENDING) | (flags & DESCENDING)) {
				for (i = 0; i < ret.length; i++) {
					var rect:Rectangle = ret[i].rect
					ret[i] = {obj: ret[i], distance: Math.sqrt((rect.x + rect.width * 0.5) * (rect.x + rect.width * 0.5) + (rect.y + rect.height * 0.5) * (rect.y + rect.height * 0.5))}
				}
				if (flags & ASCENDING) {
					ret.sortOn("distance", Array.NUMERIC);
				} else if (flags & DESCENDING) {
					ret.sortOn("distance", Array.NUMERIC | Array.DESCENDING);
				}
			}
			
			return ret;
		}
		
		//TODO: find out how to do this without using r trees or k/d trees
		public function nearest(rect:Rectangle, object:*, count:int = -1):Array {
			return null;
		}
		
		public function circleIntersectsRect(circle:Point, radius:Number, rect:Rectangle):Boolean {
			var circleDistance:Vector2D = new Vector2D();
			circleDistance.x = Math.abs(circle.x - rect.x - rect.width * 0.5);
			circleDistance.y = Math.abs(circle.y - rect.y - rect.height * 0.5);
			//decide if node is intersecting with circle
			if (circleDistance.x > rect.width * 0.5 + radius || circleDistance.y > rect.height * 0.5 + radius) {
				//circle is at least radius away from node edge, so it cannot possibly touch
				return false;
			} else if (circleDistance.x <= rect.width * 0.5 || circleDistance.y <= rect.height * 0.5) {
				//at least one component of the circle center is inside the rectangle, so it has to intersect
				return true;
			} else {
				//corner case, so check if circle is overlapping corner
				var hDist:Number = circleDistance.x - rect.width * 0.5;
				var vDist:Number = circleDistance.y - rect.height * 0.5;
				return hDist * hDist + vDist * vDist <= radius * radius;
			}
		}
		
		public function circleContainsRect(circle:Point, radius:Number, rect:Rectangle):Boolean {
			if ((circle.x - rect.x) * (circle.x - rect.x) + (circle.y - rect.y) * (circle.y - rect.y) > radius * radius) {
				return false;
			} else if ((circle.x - rect.right) * (circle.x - rect.right) + (circle.y - rect.y) * (circle.y - rect.y) > radius * radius) {
				return false;
			} else if ((circle.x - rect.right) * (circle.x - rect.right) + (circle.y - rect.bottom) * (circle.y - rect.bottom) > radius * radius) {
				return false;
			} else if ((circle.x - rect.x) * (circle.x - rect.x) + (circle.y - rect.bottom) * (circle.y - rect.bottom) > radius * radius) {
				return false;
			}
			return true;
		}
		
		//finds the subNode number given the parent and the rectangle to try fitting
		private function getSub(node:Quadrant, rect:Rectangle):int {
			//find the midpoint (cannot assume that the node has sub nodes)
			var midPoint:Point = new Point(node.bounds.x + node.bounds.width * 0.5, node.bounds.y + node.bounds.height * 0.5);
			//fits completely into north/south part of the parent node
			var north:Boolean = (rect.y >= node.bounds.y && rect.bottom <= midPoint.y);
			var south:Boolean = (rect.y >= midPoint.y && rect.bottom <= node.bounds.bottom);
			
			if (rect.x >= node.bounds.x && rect.right <= midPoint.x) {
				//west completely
				if (north) {
					return Quadrant.NORTHWEST;
				} else if (south) {
					return Quadrant.SOUTHWEST;
				}
			} else if (rect.x >= midPoint.x && rect.right <= node.bounds.right) {
				//east completely
				if (north) {
					return Quadrant.NORTHEAST;
				} else if (south) {
					return Quadrant.SOUTHEAST;
				}
				
			}
			//doesn't fit into any of the four completely
			return -1;
		}
		
		private function split(n:Quadrant):void {
			var subWidth:Number = n.bounds.width * 0.5;
			var subHeight:Number = n.bounds.height * 0.5;
			var x:Number = n.bounds.x;
			var y:Number = n.bounds.y;
			
			n.nodes[Quadrant.NORTHWEST] = new Quadrant(n.level + 1, Quadrant.NORTHWEST, new Rectangle(x, y, subWidth, subHeight));
			n.nodes[Quadrant.NORTHWEST].parent = n;
			
			n.nodes[Quadrant.NORTHEAST] = new Quadrant(n.level + 1, Quadrant.NORTHEAST, new Rectangle(x + subWidth, y, subWidth, subHeight));
			n.nodes[Quadrant.NORTHEAST].parent = n;
			
			n.nodes[Quadrant.SOUTHEAST] = new Quadrant(n.level + 1, Quadrant.SOUTHEAST, new Rectangle(x + subWidth, y + subHeight, subWidth, subHeight));
			n.nodes[Quadrant.SOUTHEAST].parent = n;
			
			n.nodes[Quadrant.SOUTHWEST] = new Quadrant(n.level + 1, Quadrant.SOUTHWEST, new Rectangle(x, y + subHeight, subWidth, subHeight));
			n.nodes[Quadrant.SOUTHWEST].parent = n;
		}
		
		public function get size():uint {
			return _size;
		}
	}
}

