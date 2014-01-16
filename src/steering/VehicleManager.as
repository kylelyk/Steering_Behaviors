package steering {
	import geometry.Vector2D;
	
	/**
	 * ...
	 * @author Kyle Howell
	 */
	public class VehicleManager {
		private var _allVehicles:Vector.<Vehicle>;
		public static const MEMOIZE:int = 1;
		
		//public static const DESC:int = 2;
		//serves as communication between vehicles - a query system. Use it to find vehicles with certain properties like proximity or simular velocity.
		//if you want  seperate sets of vehicles, just add the vehicle to a different instance of VehicleManager
		//If you don't need to find other vehicles, then you don't need to use a VehicleManager in order to use vehicles
		public function VehicleManager() {
			_allVehicles = new Vector.<Vehicle>;
		}
		
		public function getVehicle(index:uint):Vehicle {
			if (index >= _allVehicles.length) {
				return null;
			}
			return _allVehicles[index];
		}
		
		public function find(vehicle:Vehicle):int {
			for (var i:uint = 0; i < _allVehicles.length; i++) {
				if (_allVehicles[i] == vehicle) {
					return i;
				}
			}
			return -1;
		}
		
		//gives the index of the new vehicle
		public function addVehicle(vehicle:Vehicle):uint {
			vehicle.manager = this;
			var newVect:Vector.<Number> = new Vector.<Number>(_allVehicles.length + 1);
			return _allVehicles.push(vehicle) - 1;
		}
		
		public function deleteVehicle(vehicle:Vehicle):Boolean {
			var index:int = _allVehicles.indexOf(vehicle);
			if (index == -1) {
				return false;
			}
			
			vehicle.manager = null;
			_allVehicles.splice(index, 1);
			return true;
		}
		
		public function get vehicleCount():uint {
			return _allVehicles.length;
		}
		
		//if reset is true, all distances are reset to -1
		public function simulateAll(reset:Boolean = true):void {
			for (var i:uint = 0; i < _allVehicles.length; i++) {
				_allVehicles[i].run();
			}
			for (i = 0; i < _allVehicles.length; i++) {
				_allVehicles[i].update();
			}
			//code here to update quadtree
		}
		
		//gets the nearest vehicles and returns a vector of objects which contain the vehicle and the distance from the target vehicle
		//if limit is 0 get all vehicles, if positive get that many, and if negative get all vehicles within distance -1*limit
		//TODO: see if there is something better than exhastive search
		public function getNearest(targetVehicle:Vehicle, limit:Number = 0, flags:int = 0):Vector.<Object> {
			if (_allVehicles.length == 0 || !targetVehicle) {
				trace("Branch 5");
				return null;
			}
			var targetIndex:int = find(targetVehicle);
			if (targetIndex == -1) {
				throw(new Error("Could not find vehicle in VehicleManager instance."));
			}
			
			var ret:Vector.<Object> = new Vector.<Object>;
			for (var i:uint = 0; i < _allVehicles.length; i++) {
				if (targetIndex == i) {
					continue;
				}
				ret.push({distance: Vector2D.distance(targetVehicle.pos, _allVehicles[i].pos), vehicle: _allVehicles[i]});
			}
			
			ret.sort(sort);
			//TODO: do binary search inside of linear search
			if (limit > 0 && limit < ret.length) {
				//specified vehicle limit (will not fill ret with null values if limit > ret.length)
				ret.length = limit;
			} else if (limit < 0) {
				//specified distance limit
				limit *= -1;
				for (i = 0; i < ret.length; i++) {
					if (ret[i].distance > limit) {
						ret.length = i;
						break;
					}
				}
			}
			return ret;
		}
		
		private function sort(x:Object, y:Object):Number {
			if (x.distance < y.distance) {
				return -1;
			} else if (x.distance == y.distance) {
				return 0;
			} else {
				return 1;
			}
		}
	}
}