package {
	import flash.display.MovieClip;
	import flash.ui.Keyboard;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import com.wispagency.keyboard.KeyboardManager;
	//import Vector2D;
	public class Character extends MovieClip implements IDynamicObject {

		//character specific
		public var pos:Point;
		public var vel:Vector2D;
		public var jumped:Boolean;

		//Dynamic object specific
		private var points:Array;
		private var vectors:Array;
		public var dim:Dictionary;
		private var radRot:Number;

		private NUMOFPOINTS:int=4;
		private const HALFPI:Number=Math.PI*.5;
		private const TWOPI:Number=Math.PI*2;
		public function Character(xStart:int,yStart:int) {

			configUI();
			gotoAndPlay(5);

			pos=new Point(xStart,yStart);
			this.x=pos.x;
			this.y=pos.y;
			vel=new Vector2D(0,0);
			jumped=false;
			radRot=0

			dim=new Dictionary();
			dim[0]=15.15/2;//7.575
			dim[HALFPI]=35.6/2;//17.8
			points=new Array(new Point(0,0),new Point(dim[0],0),new Point(dim[0],dim[HALFPI]),new Point(0,dim[HALFPI]));

			//calculate info from NUMOFPOINTS
			vectors=new Array(NUMOFPOINTS);
			angles=new Array(NUMOFPOINTS);
			axis=new Array(0,HALFPI);
			for (var i:int=0; i<NUMOFPOINTS; i++) {

				if (i==NUMOFPOINTS-1) {
					vectors[i]=new Vector2D(points[0].x-points[i].x,points[0].y-points[i].y);
				} else {
					vectors[i]=new Vector2D(points[i+1].x-points[i].x,points[i+1].y-points[i].y);
				}

				angles[i] = vectors[i].angle;
			
			
			//compute vectors between adjacent points
			vectors=new Array(NUMOFPOINTS);
			for (i=0; i<NUMOFPOINTS; i++) {
				computeVector(i);
			}
			}
		}

		public function moveTo(p:Point):void {

			this.x=p.x;
			this.y=p.y;
		}

		public function shift(p:Point):void {

			this.x+=p.x;
			this.y+=p.y;
		}

		public function setBehavior(s:String):void {

			trace("Behavior is:"+s);
		}

		public function computeVector(num:uint):void {
			if (num==NUMOFPOINTS-1) {
				vectors[num]=new Vector2D(points[0].x-points[num].x,points[0].y-points[num].y);
			} else {
				vectors[num]=new Vector2D(points[num+1].x-points[num].x,points[num+1].y-points[num].y);
			}
		}

		public function dimAlongAxis(angle:Number):Number {

			if (dim[angle-radRot]==null) {

				var vect:Vector2D;
				var vLength:Number=0;

				for (i=0; i<NUMOFPOINTS; i++) {
					vect=vectors[i].project(angle-radRot);
					vLength+=vect.length;
				}
				dim[angle-radRot]=vLength*.5;
			}
			return dim[angle-radRot];
		}

		public function updateDim():void {

			if (dim[angle]==null) {

				var vect:Vector2D;
				var vLength:Number=0;

				for (i=0; i<NUMOFPOINTS; i++) {
					vect=vectors[i].project(angle);
					vLength+=vect.length;
				}
				dim[angle]=vLength*.5;
			}
		}

		public function drawGraphics(color:uint,fill:Boolean,fillColor:uint):void {
		}

		public function addPoint(p:Point,insertPos:int):void {
			NUMOFPOINTS++;
			points.splice(insertPos,0,p);
			vectors.splice(insertPos,0,p);
			computeVector(insertPos-1);
			computeVector(insertPos);
			updateDim();
		}

		public function subtractPoint(deletePos:Point):void {

			NUMOFPOINTS--;
			points.splice(deletePos,1);
			vectors.splice(deletePos,1);
			computeVector(deletePos-1);
			computeVector(deletePos);
			updateDim();
		}

		public function rotate(rad:Number):void {

			radRot = rad;
			rotation=radRot*(180/Math.PI);
		}
		
		/*public function detectKeys():void {
			
			//left or right movement
			if (KeyboardManager.getInstance().isKeyPressed(Keyboard.RIGHT)) {
				if (vel.x<20) {
					if (jumped) {
						vel.x+=1;
					} else {
						vel.x+=2;
					}
				}
			} else if (KeyboardManager.getInstance().isKeyPressed(Keyboard.LEFT)) {
				if (vel.x>-20) {
					if (jumped) {
						vel.x-=1;
					} else {
						vel.x-=2;
					}
				}
			}

			//jumping
			if ((!jumped)&&(KeyboardManager.getInstance().isKeyPressed(Keyboard.UP))) {

				vel.y=-15;
				jumped=true;
			}
		}*/

		public function updatePos():void {

			moveTo(pos);
		}

		protected function configUI():void {
		}
	}
}