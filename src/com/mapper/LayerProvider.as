package com.mapper
{
	import com.adobe.serialization.json.JSON;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.core.Application;
	
	
	[Event (name="load", type="LoadEvent")]
	
	public class LayerProvider extends Sprite
	{

		private var application:FlexMapper = Application.application as FlexMapper;
			
		private var loader:URLLoader = new URLLoader();
		
		public function LayerProvider() {
			loader.addEventListener(Event.COMPLETE, dispatchData);
		}
		
		public function getLayers():void {
			loader.load(new URLRequest(application.parameters.protocol + "://" + application.parameters.server + ":" + 
				application.parameters.port + "/" + application.parameters.context + "/instance/layers/" + application.parameters.instance));
		}
		
		private function dispatchData(event:Event):void {
			var _loader:URLLoader = URLLoader(event.target);
			dispatchEvent(new LoadEvent("load", false, false, JSON.decode(loader.data)));				
		}
		
	}
}