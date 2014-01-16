package steering {
	import flash.display.Sprite;
	import steering.BehaviorManager;
	import steering.VehicleManager;
	import steering.Behavior;
	import geometry.Vector2D
	
	/**
	 * Handles steering physics based on behaviors assigned by VehicleManager or itself.
	 *
	 * @author Kyle Howell
	 */
	public class Vehicle extends Sprite {
		//private var _restrictMotion:Boolean; //not going to be supported in the foreseeable future
		public var pos:Vector2D;
		public var vel:Vector2D;
		public var maxVel:Number;
		private var _accel:Vector2D;
		public var maxAccel:Number;
		//private var _mass:Vector2D;//
		public var radius:Number;
		private var behavior:Behavior;
		public var drawGraphics:Boolean;
		public var manager:VehicleManager;
		
		//Creates a new Vehicle instance with default unrestricted motion and no velocity
		public function Vehicle(pos:Vector2D, vel:Vector2D = null) {
			this.pos = pos;
			x = pos.x;
			y = pos.y;
			if (!vel) {
				this.vel = new Vector2D(0, 0);
			} else {
				this.vel = vel;
			}
			
			_accel = new Vector2D(0, 0);
			
			//default behavior
			changeBehavior("none", []);
			drawGraphics = true; //draw graphics from behaviors?
			radius = 5;
		}
		
		//updates position from velocity and acc vectors. Then reset force.
		public function update():void {
			//update velocity
			if (_accel.length > maxAccel) {
				_accel.length = maxAccel;
			}
			
			if (vel.length > maxVel) {
				vel.length = maxVel;
			}
			
			if (drawGraphics) {
				draw();
			} else {
				graphics.clear();
				draw();
			}
			vel.incrementBy(_accel);
			//update position
			pos.incrementBy(vel);
			x = pos.x;
			y = pos.y;
			
			_accel = new Vector2D(0, 0);
		}
		
		public function changeBehavior(behaviorName:String, args:Array):void {
			behavior = Behavior.initBehavior(behaviorName, this, null, args);
		}
		
		public function run():void {
			graphics.clear();
			_accel = behavior.run();
		}
		
		public function draw():void {
			
			graphics.beginFill(0x00AA00);
			graphics.lineStyle(1, 0);
			graphics.drawCircle(0, 0, radius);
			graphics.endFill();
			
			if (drawGraphics) {
				graphics.lineStyle(1, 0xFF00FF);
				graphics.moveTo(0, 0);
				graphics.lineTo(vel.x * 5, vel.y * 5);
				
				graphics.lineStyle(1, 0x228B22);
				graphics.moveTo(0, 0);
				graphics.lineTo(_accel.x * 40, _accel.y * 40);
			}
		}
		
		public function get behaviorArgs():Array {
			return behavior.args;
		}
		
		public function set behaviorArgs(args:Array):void {
			behavior.args = args
		}
	}
}