package {
	import flash.ui.Keyboard;
	import flash.geom.Point;
	//import com.wispagency.keyboard.KeyboardManager;
	//import Vector2D;
	//import StaticObject;
	public class Physics {
		public static const GRAVITY:Number=1.7;
		public static const FRICTION:Number=.8;
		public static const BOUNCE:Number=.2;
		private var allObjects:Array;
		private var char:Object;

		public static const HALFPI:Number=Math.PI/2;
		public static const TWOPI:Number=Math.PI*2;
		public function Physics() {

			allObjects= new Array();
		}

		public function addObject(ob:PlatformObject):void {

			allObjects.push(ob);
		}

		public function addCharacter(ob:Object) {

			char=new Object(ob);
		}

		public function roundToPrecision(num:Number,precision:int):Number {

			return int(num*precision+.5)/precision;
		}

		public function toPrecision(num:Number,precision:int):Number {

			return int(num*precision)/precision;
		}

		public function runSim():void {

			char.detectKeys()

			char.vel.y+=GRAVITY;

			char.pos=char.vel.addToPoint(char.pos);

			//collision detection
			trace("BEFORE: x:"+(char.pos.x)+", y:"+(char.pos.y)+", xVel:"+char.vel.x+", yVel:"+char.vel.y);

			//check to see if collision occured
			for (var i:int=0; i<allObjects.length; i++) {
				if (testForPenetration(allObjects[i],char.pos)) {
					
					do {

						//run a sweep test and store the reflection
						var reflection:Vector2D=sweepTest();
						if(reflection==null){
							continue;
						}
						//them calculate new position and adjust velocity
						var leftOver:Vector2D=new Vector2D(char.vel.x-(char.pos.x-char.x),char.vel.y-(char.pos.y-char.y));
						var angle:Number=reflection.angle;
	
						var parall:Vector2D=leftOver.project(angle+HALFPI);
						var perpen:Vector2D=leftOver.project(angle);
						parall.scaleBy(FRICTION);
						perpen.scaleBy(-BOUNCE);
						leftOver.copyFrom(parall);
						leftOver.incrementBy(perpen);
	
						char.x=char.pos.x;
						char.y=char.pos.y;
						char.pos.x+=leftOver.x;
						char.pos.y+=leftOver.y;
	
						parall=char.vel.project(angle+HALFPI);
						perpen=char.vel.project(angle);
						parall.scaleBy(FRICTION);
						perpen.scaleBy(-BOUNCE);
						char.vel.copyFrom(parall);
						char.vel.incrementBy(perpen);

					} while (reflection!=null);
					
					if (angle>Math.PI) {
						char.jumped=false;
					}
					break;
				}
			}

			//x bounds
			if (char.pos.x<char.dim[0]) {

				char.pos.x=char.dim[0];
				char.vel.x=0;

			} else if (char.pos.x>720-char.dim[0]) {

				char.pos.x=720-char.dim[0];
				char.vel.x=0;
			}

			//y bounds
			if (char.pos.y>450-char.dim[HALFPI]) {

				char.pos.y=450-char.dim[HALFPI];
				char.vel.y=0;
				char.jumped=false;

			} else if (char.pos.y<char.dim[HALFPI]) {

				char.pos.y=char.dim[HALFPI];
				char.vel.y=0;
			}

			//rounding velocities
			if(Math.abs(char.vel.x)<.5){
				char.vel.x=0
			}
			
			char.updatePos();

			trace("AFTER: x:"+char.x+", y:"+char.y+", xVel:"+char.vel.x+", yVel:"+char.vel.y);
			trace("");
		}

		//Returns a projection vector
		public function findSmallestProjection(staticObject:Object,pointTested:Point):Vector2D {

			var angle:Number;
			var smallest:Array=new Array(2);

			var linearOV:Number;
			var vectorOV:Vector2D;
			var distance:Vector2D;

			for (var j:int=0; j<staticObject.axis.length; j++) {

				angle=staticObject.axis[j];
				linearOV=char.dimAlongAxis(angle)+staticObject.dimAlongAxis(angle);
				distance=new Vector2D(pointTested.x-staticObject.center[angle].x,pointTested.y-staticObject.center[angle].y);
				distance=distance.project(angle);
				linearOV-=distance.length;

				if (linearOV<0) {
					return null;
				}

				if ((j==0)||(linearOV<smallest[1])) {

					vectorOV=Vector2D.createVector2DFromAngle(distance.angle,linearOV);
					smallest[0]=vectorOV;
					smallest[1]=linearOV;
				}
			}

			return smallest[0];
		}

		//determines if character is in an object
		public function testForPenetration(staticObject:Object,pointTested:Point):Boolean {

			var angle:Number;
			var distance:Vector2D;
			var linearOV:Number;

			for (var j:int=0; j<staticObject.axis.length; j++) {

				angle=staticObject.axis[j];
				linearOV=char.dimAlongAxis(angle)+staticObject.dimAlongAxis(angle);
				distance=new Vector2D(pointTested.x-staticObject.center[angle].x,pointTested.y-staticObject.center[angle].y);
				distance=distance.project(angle);
				linearOV-=distance.length;

				if (linearOV<0) {
					return false;
				}
			}
			return true;
		}

		//goes along the project path and finds where a dynamicObjection intercepts a staticObject
		public function sweepTest():Vector2D {
			var angle:Number=char.vel.angle;
			var testVector:Vector2D=new Vector2D(char.pos.x-char.x,char.pos.y-char.y);//char.x-char.pos.x,char.y-char.pos.y)//
			var increment:Vector2D=Vector2D.createVector2DFromAngle(angle,testVector.length/Math.ceil(testVector.length));
			var currentTest:Point=new Point(char.x,char.y);
			var reflection:Vector2D;

			//step 1 pixel at a time into the shape
			for (i=0; i<Math.ceil(testVector.length); i++) {

				trace("Previous:"+currentTest);
				currentTest=increment.addToPoint(currentTest);
				trace("Next:"+currentTest);

				for (var j:int=0; j<allObjects.length; j++) {
					/*						
					 *Found overlap, now use currentTest to find reflection
					 *Then get out of overlap so char.pos can be set
					 */
					if (testForPenetration(allObjects[j],currentTest)) {
						reflection=findSmallestProjection(allObjects[j],currentTest);
						char.pos.x+=reflection.x
						char.pos.y+=reflection.y
						return reflection;
					}
				}
			}
			return null
		}
	}
}