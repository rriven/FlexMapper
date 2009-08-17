package ui
{
	import com.afcomponents.umap.core.UMap;
	import com.afcomponents.umap.gui.MapTypeControl;
	import com.afcomponents.umap.gui.PositionControl;
	import com.afcomponents.umap.gui.ZoomControl;
	import com.afcomponents.umap.interfaces.IOverlay;
	import com.afcomponents.umap.overlays.KMLLayer;
	import com.afcomponents.umap.providers.MapType;
	import com.mapper.LayerProvider;
	import com.mapper.LoadEvent;
	import com.mapper.wms.WMSTileLayer;
	import com.mapper.wms.WMSTileProvider;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.core.UIComponent;

	public class MapperContainer extends UIComponent {
		
		private var application:FlexMapper = Application.application as FlexMapper;
		
		private var layers:LayerProvider;
		
		private var map:UMap;
		
		private var _timer:Timer;
		
		public function get internalMap():UMap {
			return map;
		}
		
		override protected function createChildren():void {			
			if (!map) {				
				map = new UMap();			
				
				layers = new LayerProvider;
				layers.addEventListener("load", handleLoadedLayers);									
				
				map.setSize(this.getExplicitOrMeasuredWidth(), this.getExplicitOrMeasuredHeight());	
				
				var provider:WMSTileProvider = new WMSTileProvider();

				var geoBase:String = application.parameters.geoprotocol + "://" + application.parameters.geoserver + ":" + 
				application.parameters.geoport + "/" + application.parameters.geocontext + "/wms"
						
				var mapType:MapType = new MapType("Raster", 0x0, 0xFF0000, "Raster", "uhoh");									
				mapType.addLayer(new WMSTileLayer(geoBase, "bcip_raster", "", "", ""));
				provider.addMapType(mapType);
				
				mapType = new MapType("Vector", 0x0, 0xFF0000, "Vector", "nooooooooo");
				mapType.addLayer(new WMSTileLayer(geoBase, "bcip_vector", "", "", ""));
				provider.addMapType(mapType);									

				mapType = new MapType("Korea", 0x0, 0xFF0000, "Korea", "kowa");
				mapType.addLayer(new WMSTileLayer(geoBase, "netcds-korea", "image/png", "", ""));
				provider.addMapType(mapType);									

				map.setProvider(provider);																		
						
				map.addControl(new MapTypeControl({displayProvider: MapTypeControl.DISPLAY_NONE}));
				map.addControl(new ZoomControl());	
				map.addControl(new PositionControl());								

				layers.getLayers();
				
				//addChild(map);
			}
			
			if (!_timer) {
				_timer = new Timer(0,0);
				_timer.addEventListener(TimerEvent.TIMER, handleTimer);				
			}
		}
		
		private function handleLoadedLayers(event:LoadEvent):void {
			if (event.data) {
				var _layers:Array = event.data as Array;
				for each (var layer:Object in _layers) {
					var kml:KMLLayer = new KMLLayer();
					kml.name = layer.name;
					try {
						kml.load(layer.url);
					} catch (error:Error) {
						Alert.show(error.message, "Error: " + error.errorID);
					}
					map.addOverlay(kml);
				}
			}
			addChild(map);
		}
		
		public function start(interval:Number):void {
			_timer.delay = interval;
			_timer.start();
			Alert.show("Reload timer started at " + interval + " milliseconds");
		}
		
		public function stop():void {
			_timer.stop()
			Alert.show("Reload timer stopped");
		}
		
		private function handleTimer():void {
			Alert.show("Reloading layers");
			var overlays:Array = map.getOverlays();
			if (overlays) {
				if (overlays.length > 0) {
					for each (var overlay:IOverlay in overlays) {
						if (overlay.visible) {
							var kmlOverlay:KMLLayer = overlay as KMLLayer;
							try {
								var url:String = generateUrl(kmlOverlay.url);
								Alert.show("Reloading [" + kmlOverlay.name + "] pointed at [" + url + "]");
								kmlOverlay.load(url);
							} catch (error:Error) {
								Alert.show(error.message, "Reload Error: " + error.errorID);
							}
						}
					}
				}
			}
		}
		
		private function generateUrl(url:String):String {
			var tmp:String = new String(url);
			if (tmp.indexOf('?') == -1) {
                tmp = tmp + '?';
            }
            tmp = tmp + '&osalt=' + Math.random();
			return tmp;		
		}

	}
}