package steering {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Kyle Howell
	 */
	public class BehaviorEvent extends Event {
		private var _payload:*;
		
		public function BehaviorEvent(type:String, payload:*, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			_payload = payload;
		}
		
		public override function clone():Event {
			return new BehaviorEvent(type, _payload, bubbles, cancelable);
		}
		
		public function get payload():* {
			return _payload;
		}
	}
}