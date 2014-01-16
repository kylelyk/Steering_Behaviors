package steering {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import geometry.Vector2D
	
	/**
	 * ...
	 * @author Kyle Howell
	 */
	public class BehaviorManager {
		//all known behaviors
		private static var _behaviors:Dictionary = new Dictionary();
		//list of instances
		//private static var _instances:Vector.<Behavior> = new Vector.<Behavior>;
		addBehavior("none", none);
		addBehavior("random", random);
		addBehavior("wander", wander);
		addBehavior("seek", seek);
		addBehavior("flee", flee);
		addBehavior("pursue", pursue);
		addBehavior("evade", evade);
		addBehavior("arrive", arrive);
		addBehavior("separate", separate);
		
		//comes with some starting behaviors. Add behaviors using addSuite or addBehavior
		//Note: each behavior will operate in scope of the vehicle (so keyword this is the vehicle instance), but without the permissions of vehicle so it cannot use properties and methods that are not public. 
		//Feel free to dispatch events, call other public functions like graphics, or store data in the behavior.
		//they will spit out a force vector result which the vehicle/other behaviors then decide what to do with it
		public function BehaviorManager() {
			throw(new Error("BehaviorManager is a static class, no need to initialize the class."));
		}
		
		public static function find(behaviorName:String):Function {
			if (_behaviors[behaviorName]) {
				return _behaviors[behaviorName];
			}
			return null;
		}
		
		//will look for public var behaviors:Dictionary
		public static function addSuite(archive:Class):void {
			try {
				var bDict:Dictionary = archive.behaviors;
			}
			catch (e:Error) {
				throw new Error("Could not find behavior suite in " + archive)
			}
			for (var k:Object in bDict) {
				if (_behaviors[k]) {
					trace("Behavior " + k + " already exists.");
				} else if (!bDict[k] is Function) {
					trace("Behavior " + k + "'s value is not a function.");
				} else {
					_behaviors[k] = bDict[k];
				}
			}
		}
		
		public static function addBehavior(name:String, funct:Function):void {
			if (_behaviors[name]) {
				trace("Behavior " + name + " already exists.");
			} else {
				_behaviors[name] = funct;
			}
		}
		
		//Default Behaviors
		public static var none:Function = function():Vector2D {
			if (this.data.frame == 0) {
				/*do init stuff here*/
					//Init subBehaviors here to prevent creating a new behavior every frame
			}
			/*do other calculations here*/
			return new Vector2D(0, 0); //return acceleration vector
		}
		
		public static var random:Function = function():Vector2D {
			return new Vector2D(Math.random() * 2 - 1, Math.random() * 2 - 1);
		}
		
		//TODO: add parameters for this function and clean up code
		public static var wander:Function = function():Vector2D {
			if (this.data.frame == 0) {
				/*do init stuff here*/
				this.data.angle = Math.random() * 2 * Math.PI //pick random starting angle
			} else {
				this.data.angle += Math.random() * Math.PI / 4 - Math.PI / 8 //random fluctuations
			}
			var velVect:Vector2D = this.vehicle.vel.clone();
			velVect.length = 25 * Math.sqrt(2);
			var unitVect:Vector2D = Vector2D.createVector2DFromAngle(velVect.angle + this.data.angle + Math.PI, 25);
			var steeringVect:Vector2D = velVect.add(unitVect);
			
			this.vehicle.graphics.lineStyle(1, 0);
			this.vehicle.graphics.drawCircle(velVect.x, velVect.y, 25);
			
			//this.vehicle.graphics.lineStyle(1, 0xEE9A00);
			//this.vehicle.graphics.moveTo(0, 0);
			//this.vehicle.graphics.lineTo(steeringVect.x, steeringVect.y);
			steeringVect.length = .25;
			return steeringVect;
			return new Vector2D(Math.random() * 2 - 1, Math.random() * 2 - 1);
		}
		
		//add option for smart seeking:
		//if inside certain radius determined by velocity from targetPoint, brake instead of steering toward desired velocity
		//depends on sidways starting vel, starting pos, max accel
		public static var seek:Function = function(targetPoint:Vector2D):Vector2D {
			if (!targetPoint) {
				throw(new Error("Behavior \"seek\" requires a target point."));
			}
			var posDiff:Vector2D = targetPoint.subtract(this.vehicle.pos);
			//send out event if vehicle touches target
			if (posDiff.length < this.vehicle.radius) {
				this.bubbleEvent(new BehaviorEvent(this.name, "", true));
			}
			posDiff.length = this.vehicle.maxVel;
			var delta:Vector2D = posDiff.subtract(this.vehicle.vel);
			return delta;
		}
		
		public static var flee:Function = function(targetPoint:Vector2D):Vector2D {
			if (!targetPoint) {
				throw(new Error("Behavior \"flee\" requires a target point."));
			}
			var posDiff:Vector2D = targetPoint.subtract(this.vehicle.pos);
			posDiff.length = this.vehicle.maxVel * -1;
			var delta:Vector2D = posDiff.subtract(this.vehicle.vel);
			return delta;
		}
		
		public static var pursue:Function = function(targetVehicle:Vehicle):Vector2D {
			if (!targetVehicle) {
				throw(new Error("Behavior \"pursue\" requires a target vehicle."));
			}
			if (this.data.frame == 0) {
				/*do init stuff here*/
				this.initSubBehavior("seek");
			}
			
			//get the targetpoint by taking the targetVehicle's velocity and scaling by the distance between the two, then add to targetVehicle's position
			var targetPoint:Vector2D = targetVehicle.vel.clone();
			targetPoint.length *= Math.abs(this.vehicle.pos.subtract(targetVehicle.pos).length) * 0.05;
			targetPoint.incrementBy(targetVehicle.pos);
			
			var drawPoint:Point = new Point(targetPoint.x - this.vehicle.pos.x - this.vehicle.vel.x, targetPoint.y - this.vehicle.pos.y - this.vehicle.vel.y);
			this.vehicle.graphics.lineStyle(1, 0);
			this.vehicle.graphics.drawCircle(drawPoint.x, drawPoint.y, 5);
			this.vehicle.graphics.moveTo(drawPoint.x + 10, drawPoint.y);
			this.vehicle.graphics.lineTo(drawPoint.x - 10, drawPoint.y);
			this.vehicle.graphics.moveTo(drawPoint.x, drawPoint.y + 10);
			this.vehicle.graphics.lineTo(drawPoint.x, drawPoint.y - 10);
			
			this.subBehaviors[0].args = [targetPoint];
			var accel:Vector2D = this.subBehaviors[0].run();
			var index:int = this.getEvent("seek");
			if (index != -1) {
				this.deleteEvent(index);
			}
			
			if (this.vehicle.pos.subtract(targetVehicle.pos).length < this.vehicle.radius + targetVehicle.radius) {
				this.bubbleEvent(new BehaviorEvent(this.name, "", true));
			}
			return accel;
		}
		
		public static var evade:Function = function(targetVehicle:Vehicle):Vector2D {
			if (!targetVehicle) {
				throw(new Error("Behavior \"evade\" requires a target point."));
			}
			if (this.data.frame == 0) {
				/*do init stuff here*/
				this.initSubBehavior("flee");
			}
			
			//get the targetpoint by taking the targetVehicle's velocity and scaling by the distance between the two, then add to targetVehicle's position
			var targetPoint:Vector2D = targetVehicle.vel.clone();
			targetPoint.length *= Math.abs(this.vehicle.pos.subtract(targetVehicle.pos).length) * 0.05;
			targetPoint.incrementBy(targetVehicle.pos);
			
			this.subBehaviors[0].args = [targetPoint];
			return this.subBehaviors[0].run();
		}
		
		public static var arrive:Function = function(targetPoint:Vector2D):Vector2D {
			if (!targetPoint) {
				throw(new Error("Behavior \"arrive\" requires a target point."));
			}
			if (this.data.frame == 0) {
				/*do init stuff here*/
				this.initSubBehavior("seek");
			}
			
			//is the only behavior if far enough away, otherwise its combined with arrive behavior
			this.subBehaviors[0].args = [targetPoint];
			var seekAccel:Vector2D = this.subBehaviors[0].run()
			this.events = new <BehaviorEvent>[];
			
			if (this.vehicle.pos.nearEquals(targetPoint, 0.01)) {
				this.bubbleEvent(new BehaviorEvent(this.name, "", true));
				var ret:Vector2D = this.vehicle.vel.clone();
				ret.negate();
				return ret;
			}
			
			//since seek returns a vector with length maxAccel, we take the component parallel to posDiff vector and negate it
			var posDiff:Vector2D = targetPoint.subtract(this.vehicle.pos)
			//send out event if vehicle touches target
			var unitVect:Vector2D = posDiff.clone();
			unitVect.length = 1;
			var dot:Number = this.vehicle.vel.dotProduct(unitVect);
			//the minimum distance away before its not possible to slow down in time
			var minDist:Number = (dot / 2) * (dot / this.vehicle.maxAccel + 7);
			
			this.vehicle.graphics.lineStyle(1, 0);
			this.vehicle.graphics.drawCircle(targetPoint.x - this.vehicle.pos.x, targetPoint.y - this.vehicle.pos.y, minDist);
			//check if its in slow down radius
			if (dot >= 0 && posDiff.length <= minDist) {
				if (this.vehicle.vel.length >= posDiff.length) {
					seekAccel = this.vehicle.vel.subtract(posDiff);
					seekAccel.negate();
				} else {
					//negate the parallel component by adding the negative twice
					seekAccel.incrementBy(Vector2D.createVector2DFromAngle(this.vehicle.vel.angle + Math.PI, dot * 2));
				}
			}
			return seekAccel;
		}
		
		//TODO: add events for seperating and braking/finish
		//brakes if no vehicles are around if braking is true
		//otherwise gives accel vect that is length maxAccel
		public static var separate:Function = function(dist:Number, braking:Boolean = true):Vector2D {
			if (dist < 0) {
				throw(new Error("Distance target parameter between vehicles cannot be a negative number."));
			}
			
			var nearest:Vector.<Object> = this.vehicle.manager.getNearest(this.vehicle, -dist, VehicleManager.MEMOIZE);
			var accel:Vector2D = new Vector2D(0, 0);
			if (nearest.length > 0) {
				//get away from others
				for (var i:uint = 0; i < nearest.length; i++) {
					var temp:Vector2D = this.vehicle.pos.subtract(nearest[i].vehicle.pos);
					if (temp.length != 0) {
						temp.length = 1 / temp.length;
					}
					accel.incrementBy(temp);
				}
				accel.length = this.vehicle.maxAccel;
			} else if (braking) {
				//slow down if braking is true
				accel = this.vehicle.vel.clone();
				if (this.vehicle.vel.length > this.vehicle.maxVel) {
					accel.length = -this.vehicle.maxVel;
				} else {
					accel.length = -this.vehicle.vel.length;
				}
			}
			return accel;
		}
	}
}