package steering {
	import flash.events.EventDispatcher;
	import flash.events.Event
	import geometry.Vector2D
	/**
	 * ...
	 * @author Kyle Howell
	 */
	public class Behavior extends EventDispatcher {
		public var data:Object; //for the function to use
		private var _funct:Function;
		private var _name:String;
		public var args:Array;
		public var vehicle:Vehicle;
		public var subBehaviors:Vector.<Behavior>;
		public var events:Vector.<BehaviorEvent>
		
		private var _parentBehavior:Behavior;
		
		public function Behavior(name:String, funct:Function, vehicle:Vehicle, parent:Behavior, args:Array) {
			_funct = funct;
			_name = name;
			this.args = args;
			this.vehicle = vehicle;
			_parentBehavior = parent;
			data = { frame: uint(0) }
			subBehaviors = new Vector.<Behavior>
			events = new Vector.<BehaviorEvent>
		}
		
		//use initSubBehavior if you want to make a sub-Behavior
		public static function initBehavior(name:String, vehicle:Vehicle, parent:Behavior, args:Array):Behavior {
			var behaviorFunct:Function = BehaviorManager.find(name);
			if (behaviorFunct != null) {
				var behavior:Behavior = new Behavior(name, behaviorFunct, vehicle, parent, args);
			} else {
				throw new Error("Could not find Behavior. Did you add it using addSuite/addBehavior?");
			}
			return behavior;
		}
		
		//public function copy(vehicle:Vehicle):void {}
		
		//"bubbles" events up the tree or dispatches them in order if at top of tree
		//also prevents events from being dispatched until all behaviors are finished (prevents nasty sync bugs)
		public function finishBehavior():void {
			data.frame++;
			if (_parentBehavior) {
				if (events.length > 0) {
					var tempArr:Array = new Array(events.length);
					for (var i:uint = 0; i < events.length; i++) {
						tempArr[i] = events[i];
					}
					_parentBehavior.events.push.apply(this, tempArr);
				}
				
			}else {
				for (i = 0; i < events.length; i++) {
					vehicle.dispatchEvent(events[i]);
				}
			}
			events = new Vector.<BehaviorEvent>;
		}
		
		//returns the finished accel Vector2D produced by the behavior and its sub-Behaviors
		public function run():Vector2D {
			if (!vehicle) {
				throw(new Error("Behavior cannot run without a vehicle."));
			}
			if (!args is Array) {
				
				throw(new Error("Args for behavior is not array."))
			}
			var output:Vector2D = _funct.apply(this, args);
			finishBehavior();
			return output;
		
		}
		
		/////////////////////////////////
		//Methods for Anonymous Functions
		/////////////////////////////////
		
		public function initSubBehavior(name:String, ... args):Behavior {
			var newB:Behavior = Behavior.initBehavior(name, vehicle, this, args);
			subBehaviors.push(newB);
			return newB;
		}
		
		//When this behavior is done, the event will be passed on to its parent behavior and so on until it reaches the top. Then it will be dispatched to the vehicle.
		//This way, events can be caught by superbehaviors (since they should only return a Vector2D) and possibly be "rebranded" as different event.
		public function bubbleEvent(e:BehaviorEvent):void {
			events.push(e);
		}
		
		public function replaceEvent(targetIndex:int, e:BehaviorEvent, inPlace:Boolean = false):void {
			if (!e) {
				return;
			}
			if (inPlace) {
				events[targetIndex] = e;
			}else {
				events.splice(targetIndex, 1);
				events.push(e);
			}
		}
		
		public function deleteEvent(targetIndex:int):void {
			events.splice(targetIndex, 1);
		}
		//anonymous functions?
		
		//returns previous vehicle
		public function assignVehicle(vehicle:Vehicle):Vehicle {
			var previous:Vehicle = this.vehicle;
			this.vehicle = vehicle;
			return previous;
		}
		
		//useful if you don't know the index of the subBehavior
		public function getSubBehavior(name:String):int {
			for (var i:uint = 0; i < subBehaviors.length; i++) {
				if (subBehaviors[i].name == name) {
					return i;
				}
			}
			return -1;
		}
		
		public function getEvent(type:String):int {
			for (var i:uint = 0; i < events.length; i++) {
				if (events[i].type == type) {
					return i;
				}
			}
			return -1;
		}
		
		public function get name():String {
			return _name;
		}
		
		public function get parent():Behavior {
			return _parentBehavior;
		}
	}
}