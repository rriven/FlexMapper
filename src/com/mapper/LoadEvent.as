package com.mapper
{
	import flash.events.Event;
	
	public class LoadEvent extends Event
	{
		private var _data:*;
		
		public function LoadEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, result:*=null)
		{
			super(type, bubbles, cancelable);
			this._data = result;
		}
		
		public function get data():* {
			return this._data;
		}
	}
}