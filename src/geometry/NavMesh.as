package geometry{
	import flash.display.Sprite;
	
	/**
	* ...
	* @author Kyle Howell
	*/
	public class NavMesh extends Sprite {
		//At its basis:
		//vector of polygons defined by edges, which are defined by points
		//vector of polygons added/removed/changed since last updateMesh() command
		//drawGraphics() with difference shading depending on polygon state (input alpha too)
		//maybe keep record of reference of shapes so that changed shapes do not need to be removed and added back
		//some system to keep track of polygon "names" for easy deletion/change/read of properties (will actually copy? reference? polygons)
		
		//need/need for A*:
		//vector of edges-will start out as open list
		//information about polygons/edges/vertices (walkable, non, other)
		//some system to get a polygon's neighbors
		//system that puts edges of one polygons together, (and then somehow connected to other polygons)-maybe
		//for each edge, all edges in both polygons that are "straight shots" from edge(all since convex polygons)
		public function NavMesh():void {
			
		}
		
		public function drawGraphics():void {
			
		}
		public function updateMesh():void {
			
		}
		
		//0 is walkable, 1 is not
		public function addPolygon(poly:Polygon, state:uint):void {
			
		}
		
		//might change this to changePolygon() or updatePolygon()
		//moves polygon and adjusts all 
		public function movePolygon():void {
			
		}
	}
}