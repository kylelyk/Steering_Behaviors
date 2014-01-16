package {
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import KeyList;
	/**
	 * manages the state of ONE single keyboard key
	 * 
	 * @author Jody Hall
	 */
	public class OneKeyManager {
		private var _stage:Stage;
		private var _keyCode:int;
		private var _pressHandler:Function;
		private var _releaseHandler:Function;
		private var _isDown:Boolean;
		private var _isActive:Boolean;

		public function OneKeyManager(theStage:Stage,keyCode:int,pressHandler:Function=null,releaseHandler:Function=null) {
			_stage = theStage;
			_keyCode = keyCode;
			_pressHandler = pressHandler;
			_releaseHandler = releaseHandler;
			_isDown = false;

			_stage.focus = _stage;
			_stage.addEventListener(KeyboardEvent.KEY_DOWN,_stage_onKeyDown);
			_isActive = true;//set flag to indicate KEY_DOWN listener is active
		}
		private function _stage_onKeyDown(event:KeyboardEvent):void {
			if (event.keyCode == _keyCode && _isDown == false) {
				_isDown = true;
				_stage.addEventListener(KeyboardEvent.KEY_UP,_stage_onKeyUp);
				if (_pressHandler != null) {
					_pressHandler(event);
				}
			}
		}
		private function _stage_onKeyUp(event:KeyboardEvent):void {
			if (event.keyCode == _keyCode) {
				_stage.removeEventListener(KeyboardEvent.KEY_UP,_stage_onKeyUp);
				_isDown = false;
				if (_releaseHandler != null) {
					_releaseHandler(event);
				}
			}
		}
		public function set active(value:Boolean):void {
			if (_isActive != value) {
				_isActive = value;
				if (_isActive) {
					_stage.focus = _stage;
					_stage.addEventListener(KeyboardEvent.KEY_DOWN,_stage_onKeyDown);
				} else {
					_stage.removeEventListener(KeyboardEvent.KEY_DOWN,_stage_onKeyDown);
				}
			}
		}
		public function get active():Boolean {
			return _isActive;
		}
		public function set pressHandler(value:Function):void {
			_pressHandler = value;
		}
		public function set releaseHandler(value:Function):void {
			_releaseHandler = value;
		}
		public function get isDown():Boolean {
			return _isDown;
		}
	}
}