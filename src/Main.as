package {
	import datastrucs.QuadTree;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import steering.BehaviorEvent;
	import steering.BehaviorManager;
	import steering.Vehicle;
	import geometry.Vector2D;
	import steering.VehicleManager;
	import flash.geom.Rectangle;
	
	import asunit.textui.TestRunner;
	import tests.AllTests;
	
	/**
	 * ...
	 * @author Kyle Howell
	 */
	public class Main extends Sprite {
		//private var obj:StaticObject;
		//private var stageSpr:Sprite;
		//private var mouseIsDown:Boolean;
		private var vehicle1:Vehicle;
		private var vehicle2:Vehicle;
		private var vehicle3:Vehicle;
		private var vehicleManager:VehicleManager;
		private var timer:Timer;
		
		private var leftKey:OneKeyManager;
		private var rightKey:OneKeyManager;
		private var enterKey:OneKeyManager;
		private var clicked:Boolean = false;
		private var rand:Object;
		//private var hitTarget:Boolean;
		
		private var textBox1:TextField;
		private var textBox2:TextField;
		
		private var curDemo:String;
		private var curIndex:uint = 0;
		
		//TURN THIS ON FOR AUTOMATIC TESTING
		private const TESTING:Boolean = true;
		
		//private const DEMO:String = "SEEK&FLEE";
		//private const DEMO:String = "WANDER";
		//private const DEMO:String = "PURSUE&EVADE";
		//private const DEMO:String = "ARRIVE";
		//private const DEMO:String = "SEPARATE";
		//private const DEMO:String = "QUADTREE";
		private const DEMOARRAY:Array = ["SEEK&FLEE", "WANDER", "PURSUE&EVADE", "ARRIVE", "SEPARATE"]
		

		
		public function Main():void {
			if (stage) {
				init();
			} else {
				addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			if (TESTING) {
				var unittests:TestRunner = new TestRunner();
				stage.addChild(unittests);
				unittests.start(tests.AllTests, null, TestRunner.SHOW_TRACE);
				return;
			}
			
			textBox1 = new TextField();
			var format:TextFormat = new TextFormat(null, 20, 0x999999, null, null, null, null, null, "center");
			addChild(textBox1);
			textBox1.defaultTextFormat = format;
			textBox1.width = stage.stageWidth;
			
			textBox2 = new TextField();
			var format2:TextFormat = new TextFormat(null, 14, 0x999999, null, null, null, null, null, "center");
			addChild(textBox2);
			textBox2.defaultTextFormat = format2;
			textBox2.width = stage.stageWidth;
			textBox2.y = 25;
			textBox2.text = "Left and right keys switch behavior, enter key refreshes current behavior.";
			
			curDemo = DEMOARRAY[0];
			switchDemo();
			leftKey = new OneKeyManager(stage, KeyList.LEFT, null, leftDemo);
			rightKey = new OneKeyManager(stage, KeyList.RIGHT, null, rightDemo);
			enterKey = new OneKeyManager(stage, KeyList.ENTER, null, switchDemo);
			
			stage.addEventListener(Event.ENTER_FRAME, enterFrame);
			return;
		
		/*stage.addEventListener(MouseEvent.CLICK, mouseClicked);
		   stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
		   stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
		   //obj = new StaticObject(new <Point>[new Point(0, 0), new Point(75, 0), new Point(120, 50),new Point(150, 150)])//,new Point(0, 100)])
		   //obj = new StaticObject(new <Point>[new Point(0, 0), new Point(100, 0), new Point(100, 100), new Point(0, 100)]) //,new Point(0, 100)])
		   obj = new StaticObject(new <Point>[new Point(100, 100), new Point(200, 100), new Point(140, 140), new Point(100, 200)], true)
		
		   stage.addChild(obj);
		   obj.drawGraphics(0x000000, 0x000000);
		
		   stageSpr = new Sprite();
		   stage.addChild(stageSpr);
		
		 mouseIsDown = false;*/
		
			//obj.rotate(Math.PI/4);
			//var test:Vector2D = new Vector2D( 100, 100);
			//test = test.project(0);
			//trace(test.dotProduct(Vector2D.createUnitVector2D(0)));
			//trace(obj.dimAlongAxis(Math.PI/4));s
			//var nav:NavMesh = new NavMesh();
		
			//var node:LinkedListNode = new LinkedListNode(9);
			//var linkedList:LinkedList = new LinkedList(1, 2, 3, 4, 5, 6, 7, 8, 9, 0);
			//trace(linkedList);
			//trace(linkedList.clone())
			//trace(linkedList.head.prev + " " + linkedList.tail.next);
			//linkedList = linkedList.reverse();
			//trace(linkedList);
			//linkedList.pop()
			//trace(linkedList);
			//linkedList.pop()
			//linkedList.unshift("a","s","d","f")
			//trace(linkedList);
			
			//trace(linkedList.convertToArray())
		
			//var line1:Line = new Line(new Point(0, 0), new Point(100, 100))
			//var line2:Line = new Line(new Point(0, 150), new Point(100, 0))
			//trace(Line.intersect(line1, line2));
		}
		
		private function seekListener(e:BehaviorEvent):void {
			if (timer && timer.running) {
				return;
			}
			
			timer = new Timer(750, 1);
			timer.start();
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, seekTimer);
		}
		
		private function seekTimer(tEvent:TimerEvent):void {
			
			if (clicked) {
				//debugging
				var unitVect:Vector2D = rand.target.subtract(rand.pos);
				trace("PosDiff: " + unitVect.length);
				
				unitVect.length = 1;
				unitVect.rotate(Math.PI / 2);
				trace("sidways vel: " + rand.vel.dotProduct(unitVect));
				
				trace("maxAccel: " + vehicle1.maxAccel);
				clicked = false;
			}
			
			var randPos:Vector2D = new Vector2D(Math.random() * (stage.stageWidth - 100) + 50, Math.random() * (stage.stageHeight - 100) + 50);
			var randVel:Vector2D = Vector2D.createVector2DFromAngle(Math.random() * Math.PI * 2, Math.random() * 10);
			var randTarget:Vector2D = new Vector2D(Math.random() * (stage.stageWidth - 100) + 50, Math.random() * (stage.stageHeight - 100) + 50);
			
			rand = {pos: randPos, vel: randVel, target: randTarget}
			
			vehicle1.pos = randPos;
			vehicle1.vel = randVel;
			vehicle1.behaviorArgs = [randTarget];
			
			vehicle2.pos = randPos.clone();
			vehicle2.vel = randVel.clone();
			vehicle2.behaviorArgs = [randTarget];
			
			graphics.clear();
			graphics.beginFill(0);
			graphics.drawCircle(randTarget.x, randTarget.y, 2);
			graphics.endFill();
		}
		
		private function pursueListener(e:BehaviorEvent):void {
			
			//trace("In listener for pursue")
			
			//trace("Main recieve event, target is: " + e.target+ " with currentTarget: "+ e.currentTarget);
			var randPos:Vector2D = new Vector2D(Math.random() * (stage.stageWidth - 100) + 50, Math.random() * (stage.stageHeight - 100) + 50);
			var randVel:Vector2D = Vector2D.createVector2DFromAngle(Math.random() * Math.PI * 2, Math.random() * vehicle1.maxVel);
			
			vehicle1.pos = randPos;
			vehicle1.vel = randVel;
			
			vehicle2.pos = randPos.clone();
			vehicle2.vel = randVel.clone();
			
			randPos = new Vector2D(stage.stageWidth / 2, stage.stageHeight / 2);
			randVel = Vector2D.createVector2DFromAngle(Math.random() * Math.PI * 2, Math.random() * vehicle3.maxVel);
			vehicle3.pos = randPos;
			vehicle3.vel = randVel;
		
		}
		
		private function arriveListener(e:BehaviorEvent):void {
			
			//trace("In listener for arrive")
			
			//trace("Main recieve event, target is: " + e.target+ " with currentTarget: "+ e.currentTarget);
			var randPos:Vector2D = new Vector2D(Math.random() * (stage.stageWidth - 100) + 50, Math.random() * (stage.stageHeight - 100) + 50);
			var randVel:Vector2D = Vector2D.createVector2DFromAngle(Math.random() * Math.PI * 2, Math.random() * vehicle1.maxVel);
			var randTarget:Vector2D = new Vector2D(Math.random() * (stage.stageWidth - 100) + 50, Math.random() * (stage.stageHeight - 100) + 50);
			
			vehicle1.pos = randPos;
			vehicle1.vel = randVel;
			vehicle1.behaviorArgs = [randTarget];
			
			graphics.clear()
			graphics.beginFill(0);
			graphics.drawCircle(randTarget.x, randTarget.y, 2);
			graphics.endFill();
		}
		
		private function mouseClicked(e:MouseEvent):void {
			clicked = true;
		}
		
		private function enterFrame(e:Event):void {
			if (vehicle1) {
				vehicle1.run();
				if (vehicle2) {
					vehicle2.run();
					if (vehicle3) {
						vehicle3.run();
						vehicle3.update();
					}
					vehicle2.update();
				}
				vehicle1.update();
			}
			
			if (vehicleManager) {
				vehicleManager.simulateAll();
				if (curDemo == "SEPARATE") {
					var allStopped:Boolean = true;
					for (var i:uint = 0; i < vehicleManager.vehicleCount; i++) {
						if (vehicleManager.getVehicle(i).vel.length != 0) {
							allStopped = false;
						}
					}
					
					//refresh
					if (allStopped) {
						switchDemo();
					}
				}
			}
			
			return;
		
		/*if (!mouseIsDown) {
		   //obj.addRotation(0.008);
		   //obj.rotateAroundPoint(0.03, new Point(mouseX, mouseY));
		   } else {
		   //obj.rotateAroundPoint(0.03, new Point(mouseX, mouseY));
		   //obj.rotateAroundPoint(0, new Point(mouseX, mouseY),true);
		   }
		
		   //from center to mouse
		   var vect:Vector2D = new Vector2D(mouseX - obj.x, mouseY - obj.y);
		   obj.graphics.clear();
		   //obj.drawGraphics(0x000000, 0x000000);
		   obj.drawOutline(0x00000)
		   stageSpr.graphics.clear();
		   stageSpr.graphics.lineStyle(1, 0xCCCCCC);
		   stageSpr.graphics.moveTo(obj.x, obj.y);
		   stageSpr.graphics.lineTo(mouseX, mouseY);
		
		   var angle:Number = Utils.wrap(0, 2 * Math.PI, vect.angle - Math.PI / 2);
		   var dim:Vector.<Number> = obj.dimAlongAxis(angle);
		   vect.negate() //for the blue lines going the opposite way
		
		   //max
		   var newVect:Vector2D = Vector2D.createVector2DFromAngle(angle, dim[0]);
		   stageSpr.graphics.lineStyle(1, 0x00CC00);
		   stageSpr.graphics.lineTo(mouseX + newVect.x, mouseY + newVect.y);
		   var newVect2:Vector2D = Vector2D.createVector2DFromAngle(vect.angle, 1500);
		   stageSpr.graphics.lineStyle(1, 0x0000AA);
		   stageSpr.graphics.lineTo(mouseX + newVect.x + newVect2.x, mouseY + newVect.y + newVect2.y);
		
		   //min
		   newVect = Vector2D.createVector2DFromAngle(angle, dim[1]);
		   stageSpr.graphics.lineStyle(1, 0x00CC00);
		   stageSpr.graphics.moveTo(mouseX, mouseY);
		   stageSpr.graphics.lineTo(mouseX - newVect.x, mouseY - newVect.y);
		   newVect2 = Vector2D.createVector2DFromAngle(vect.angle, 1500);
		   stageSpr.graphics.lineStyle(1, 0x0000AA);
		 stageSpr.graphics.lineTo(mouseX - newVect.x + newVect2.x, mouseY - newVect.y + newVect2.y);*/
		
			//testing addVertex function
			//obj.addVertex(new Point(mouseX, mouseY));
		}
		
		private function switchDemo(e:KeyboardEvent = null):void {
			graphics.clear();
			if (vehicle1) {
				removeChild(vehicle1);
				vehicle1 = null;
			}
			if (vehicle2) {
				removeChild(vehicle2);
				vehicle2 = null;
			}
			if (vehicle3) {
				removeChild(vehicle3);
				vehicle3 = null;
			}
			if (vehicleManager) {
				for (var i:uint = 0; i < vehicleManager.vehicleCount; i++) {
					removeChild(vehicleManager.getVehicle(i));
				}
				vehicleManager = null;
			}
			
			curDemo = DEMOARRAY[curIndex];
			textBox1.text = curDemo + " Behavior";
			
			
			if (curDemo == "SEEK&FLEE") {
				var randPos:Vector2D = new Vector2D(Math.random() * (stage.stageWidth - 100) + 50, Math.random() * (stage.stageHeight - 100) + 50);
				var randVel:Vector2D = Vector2D.createVector2DFromAngle(Math.random() * Math.PI * 2, Math.random() * 10);
				var randTarget:Vector2D = new Vector2D(Math.random() * (stage.stageWidth - 100) + 50, Math.random() * (stage.stageHeight - 100) + 50);
				
				rand = {pos: randPos, vel: randVel, target: randTarget}
				
				vehicle1 = new Vehicle(randPos, randVel);
				vehicle1.maxAccel = 0.25;
				vehicle1.maxVel = 10;
				vehicle1.changeBehavior("seek", [randTarget]);
				addChild(vehicle1);
				
				vehicle2 = new Vehicle(randPos.clone(), randVel.clone());
				vehicle2.maxAccel = 0.5;
				vehicle2.maxVel = 10;
				vehicle2.changeBehavior("flee", [randTarget]);
				addChild(vehicle2);
				
				graphics.beginFill(0);
				graphics.drawCircle(randTarget.x, randTarget.y, 2);
				graphics.endFill();
				
				//hitTarget = false;
				
				vehicle1.addEventListener("seek", seekListener);
				stage.addEventListener(MouseEvent.CLICK, mouseClicked);
			} else if (curDemo == "WANDER") {
				vehicle1 = new Vehicle(new Vector2D(stage.stageWidth / 2, stage.stageHeight / 2));
				vehicle1.maxAccel = 0.25;
				vehicle1.maxVel = 3;
				vehicle1.changeBehavior("wander", []);
				addChild(vehicle1);
			} else if (curDemo == "PURSUE&EVADE") {
				
				randPos = new Vector2D(Math.random() * (stage.stageWidth - 100) + 50, Math.random() * (stage.stageHeight - 100) + 50);
				randVel = Vector2D.createVector2DFromAngle(Math.random() * Math.PI * 2, Math.random() * 7);
				vehicle3 = new Vehicle(randPos, randVel);
				vehicle3.maxAccel = 0.5;
				vehicle3.maxVel = 6;
				addChild(vehicle3);
				
				randPos = new Vector2D(Math.random() * (stage.stageWidth - 100) + 50, Math.random() * (stage.stageHeight - 100) + 50);
				randVel = Vector2D.createVector2DFromAngle(Math.random() * Math.PI * 2, Math.random() * 10);
				
				vehicle1 = new Vehicle(randPos, randVel);
				vehicle1.maxAccel = 0.5;
				vehicle1.maxVel = 20;
				vehicle1.changeBehavior("pursue", [vehicle3]);
				addChild(vehicle1);
				
				vehicle2 = new Vehicle(randPos.clone(), randVel.clone());
				vehicle2.maxAccel = 0.5;
				vehicle2.maxVel = 10;
				vehicle2.changeBehavior("evade", [vehicle3]);
				addChild(vehicle2);
				
				vehicle1.addEventListener("pursue", pursueListener);
			} else if (curDemo == "ARRIVE") {
				randPos = new Vector2D(Math.random() * (stage.stageWidth - 100) + 50, Math.random() * (stage.stageHeight - 100) + 50);
				randVel = Vector2D.createVector2DFromAngle(Math.random() * Math.PI * 2, Math.random() * 10);
				randTarget = new Vector2D(Math.random() * (stage.stageWidth - 100) + 50, Math.random() * (stage.stageHeight - 100) + 50);
				
				vehicle1 = new Vehicle(randPos, randVel);
				vehicle1.maxAccel = 0.5;
				vehicle1.maxVel = 10;
				vehicle1.changeBehavior("arrive", [randTarget]);
				addChild(vehicle1);
				vehicle1.addEventListener("arrive", arriveListener);
				
				graphics.beginFill(0);
				graphics.drawCircle(randTarget.x, randTarget.y, 2);
				graphics.endFill();
			} else if (curDemo == "SEPARATE") {
				vehicleManager = new VehicleManager();
				for (i = 0; i < 150; i++) {
					var veh:Vehicle = new Vehicle(new Vector2D(Math.random() * (stage.stageWidth - 100) + 50, Math.random() * (stage.stageHeight - 100) + 50), Vector2D.createVector2DFromAngle(Math.random() * Math.PI * 2, Math.random() * 10));
					vehicleManager.addVehicle(veh);
					veh.changeBehavior("separate", [25, true]);
					veh.maxAccel = 0.5;
					veh.maxVel = 10;
					addChild(veh);
				}
			} else if (curDemo == "QUADTREE") {
				//unfinished
				var _instance:QuadTree = new QuadTree(new Rectangle(0, 0, 800, 600));
			}
		}
		
		private function rightDemo(e:KeyboardEvent):void {
			curIndex = Utils.wrap(0, DEMOARRAY.length, curIndex + 1);
			switchDemo();
		}
		
		private function leftDemo(e:KeyboardEvent):void {
			curIndex = Utils.wrap(0, DEMOARRAY.length, curIndex - 1);
			switchDemo();
		}
	}
}